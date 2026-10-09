class_name FishingChallengeController
extends RefCounted
## Pure, transient rules. Input is sampled at the beginning of update's interval.
## Generations count fresh presses, not held frames. The caller owns input aggregation.
## A token is local to this controller; root integration must also bind its session.

const STEP_SECONDS: float = 1.0 / 240.0
const MAX_UPDATE_SECONDS: float = 60.0
const EPSILON: float = 1e-10
const DANGER_GRACE_SECONDS: float = 0.75

class Snapshot extends RefCounted:
	var attempt_token: int = 0
	var phase: String = "inactive"
	var outcome: String = ""
	var fish_item_id: String = ""
	var wait_seconds: float = 0.0
	var phase_elapsed_seconds: float = 0.0
	var elapsed_fight_seconds: float = 0.0
	var pending_fight_seconds: float = 0.0
	var maximum_fight_seconds: float = 0.0
	var tension: float = 0.5
	var landing_progress: float = 0.0
	var danger_seconds: float = 0.0
	var struggle_force: float = 0.0
	var optimal_minimum: float = 0.0
	var optimal_maximum: float = 0.0
	var danger_minimum: float = 0.0
	var danger_maximum: float = 0.0
	var reel_held: bool = false

class Resolution extends RefCounted:
	var attempt_token: int = 0
	var outcome: String = ""
	var fish_item_id: String = ""
	var reward_eligible: bool = false
	var cancel_reason: String = ""

class CommandResult extends RefCounted:
	var accepted: bool = false
	var error: String = ""
	var resolution: Resolution = null

var _state: Snapshot = Snapshot.new()
var _feature: FishingChallengeDefinition = null
var _next_token: int = 0
var _generation: int = 0

func is_active() -> bool:
	return _state.phase in ["waiting", "bite", "fighting"]

func snapshot() -> Snapshot:
	var result: Snapshot = Snapshot.new()
	for property: String in ["attempt_token", "phase", "outcome", "fish_item_id",
		"wait_seconds", "phase_elapsed_seconds", "elapsed_fight_seconds", "pending_fight_seconds",
		"maximum_fight_seconds", "tension", "landing_progress", "danger_seconds",
		"struggle_force", "optimal_minimum", "optimal_maximum", "danger_minimum",
		"danger_maximum", "reel_held"]:
		result.set(property, _state.get(property))
	return result

func start(item_id: String, feature: FishingChallengeDefinition, wait_roll: Variant,
		reel_generation: Variant, reel_held: Variant = false) -> CommandResult:
	if is_active(): return _reject("attempt already active")
	if (item_id.is_empty()) != (feature == null): return _reject("fish and feature must be paired")
	if not item_id.is_empty() and item_id.strip_edges() != item_id: return _reject("invalid fish identity")
	if feature != null and not feature.validation_errors().is_empty(): return _reject("invalid challenge definition")
	if not _number(wait_roll) or wait_roll < 0 or wait_roll >= 1: return _reject("wait roll must be finite [0,1)")
	if typeof(reel_generation) != TYPE_INT or reel_generation < 0: return _reject("invalid reel generation")
	if typeof(reel_held) != TYPE_BOOL: return _reject("invalid held input")
	_next_token += 1
	_state = Snapshot.new()
	_state.attempt_token = _next_token
	_state.phase = "waiting"
	_state.fish_item_id = item_id
	_state.wait_seconds = 1.5 + 1.5 * float(wait_roll)
	_state.reel_held = reel_held
	_generation = reel_generation
	_feature = feature.duplicate(true) if feature != null else null
	if _feature != null:
		_state.maximum_fight_seconds = _feature.maximum_fight_seconds
		var bounds: Vector4 = tier_bounds(_feature.difficulty)
		_state.optimal_minimum = bounds.x
		_state.optimal_maximum = bounds.y
		_state.danger_minimum = bounds.z
		_state.danger_maximum = bounds.w
	return _accept()

func update(dt: Variant, reel_held: Variant, reel_generation: Variant, token: Variant) -> CommandResult:
	if not _number(dt) or dt < 0 or dt > MAX_UPDATE_SECONDS: return _reject("elapsed time must be finite [0,60]")
	if typeof(reel_held) != TYPE_BOOL: return _reject("invalid held input")
	if typeof(reel_generation) != TYPE_INT or reel_generation < _generation: return _reject("invalid reel generation")
	if typeof(token) != TYPE_INT or token != _state.attempt_token or token <= 0: return _reject("stale attempt token")
	if not is_active(): return _reject("attempt already terminal")
	var fresh_press: bool = reel_generation > _generation
	# Held input cannot rise without a press generation. A press and release may
	# both occur between observations; that still counts as early reeling in waiting.
	if reel_held and not _state.reel_held and not fresh_press: return _reject("held rise requires fresh press")
	if fresh_press and _state.reel_held: return _reject("fresh press requires observed release")
	_generation = reel_generation
	_state.reel_held = reel_held
	if _state.phase == "waiting" and fresh_press: return _resolve("early_reel")
	if _state.phase == "bite" and fresh_press and reel_held:
		_state.phase = "fighting"
		_state.phase_elapsed_seconds = 0.0
	var remaining: float = float(dt)
	if _state.phase == "waiting":
		var until_bite: float = _state.wait_seconds - _state.phase_elapsed_seconds
		if remaining + EPSILON < until_bite:
			_state.phase_elapsed_seconds += remaining
			return _accept()
		remaining = maxf(0.0, remaining - until_bite)
		_state.phase_elapsed_seconds = 0.0
		if _feature == null: return _resolve("no_bite")
		_state.phase = "bite"
	if _state.phase == "bite":
		_state.phase_elapsed_seconds += remaining
		if _state.phase_elapsed_seconds + EPSILON >= _feature.hook_window_seconds:
			_state.phase_elapsed_seconds = _feature.hook_window_seconds
			return _resolve("missed_hook")
		return _accept()
	# Carry fractions rather than integrating a frame-dependent last substep.
	# One accepted update performs at most 14,401 steps, including prior carry.
	_state.pending_fight_seconds += remaining
	while is_active():
		var step: float = minf(STEP_SECONDS, _feature.maximum_fight_seconds - _state.elapsed_fight_seconds)
		if _state.pending_fight_seconds + EPSILON < step: break
		_state.pending_fight_seconds = maxf(0.0, _state.pending_fight_seconds - step)
		var result: CommandResult = _fight_step(step)
		if result.resolution != null: return result
	_state.phase_elapsed_seconds = _state.elapsed_fight_seconds + _state.pending_fight_seconds
	return _accept()

func cancel(token: Variant, reason: String = "explicit") -> CommandResult:
	if typeof(token) != TYPE_INT or token != _state.attempt_token or token <= 0: return _reject("stale attempt token")
	if not is_active(): return _reject("attempt already terminal")
	if reason.strip_edges().is_empty(): return _reject("cancel reason required")
	var result: CommandResult = _resolve("canceled")
	result.resolution.cancel_reason = reason
	return result

func _fight_step(dt: float) -> CommandResult:
	_state.elapsed_fight_seconds += dt
	_state.phase_elapsed_seconds = _state.elapsed_fight_seconds
	_state.struggle_force = struggle_force(_state.elapsed_fight_seconds, _feature.difficulty)
	var input_force: float = 0.65 if _state.reel_held else -0.55
	_state.tension = clampf(_state.tension + (input_force + _state.struggle_force) * dt, 0.0, 1.0)
	var dangerous: bool = _state.tension <= _state.danger_minimum or _state.tension >= _state.danger_maximum
	_state.danger_seconds = _state.danger_seconds + dt if dangerous else 0.0
	var optimal: bool = _state.tension >= _state.optimal_minimum and _state.tension <= _state.optimal_maximum
	var multiplier: float = 0.0 if dangerous else (1.0 if optimal else 0.25)
	_state.landing_progress = minf(1.0, _state.landing_progress + dt * multiplier / _feature.minimum_fight_seconds)
	if _state.danger_seconds + EPSILON >= DANGER_GRACE_SECONDS:
		return _resolve("line_slack" if _state.tension <= _state.danger_minimum else "line_snapped")
	if _state.landing_progress + EPSILON >= 1.0:
		_state.landing_progress = 1.0
		return _resolve("landed")
	if _state.elapsed_fight_seconds + EPSILON >= _feature.maximum_fight_seconds: return _resolve("exhausted")
	return _accept()

func _resolve(outcome: String) -> CommandResult:
	_state.phase = "terminal"
	_state.outcome = outcome
	_state.reel_held = false
	_state.pending_fight_seconds = 0.0
	var result: CommandResult = _accept()
	result.resolution = Resolution.new()
	result.resolution.attempt_token = _state.attempt_token
	result.resolution.outcome = outcome
	result.resolution.fish_item_id = _state.fish_item_id
	result.resolution.reward_eligible = outcome == "landed"
	_feature = null
	return result

static func tier_bounds(tier: String) -> Vector4:
	match tier:
		"easy": return Vector4(0.30, 0.70, 0.10, 0.90)
		"medium": return Vector4(0.35, 0.65, 0.15, 0.85)
		"hard": return Vector4(0.40, 0.60, 0.20, 0.80)
	return Vector4.ZERO

static func struggle_force(seconds: float, tier: String) -> float:
	match tier:
		"easy": return 0.12 * sin(PI * seconds)
		"medium": return 0.22 * sin(2.0 * PI * seconds / 1.35)
		"hard": return 0.22 * sin(2.0 * PI * seconds / 1.9) + 0.10 * sin(2.0 * PI * seconds / 0.8)
	return 0.0

static func _number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))

static func _reject(error: String) -> CommandResult:
	var result: CommandResult = CommandResult.new()
	result.error = error
	return result

static func _accept() -> CommandResult:
	var result: CommandResult = CommandResult.new()
	result.accepted = true
	return result
