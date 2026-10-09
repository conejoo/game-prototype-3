class_name FishingSessionService
extends RefCounted
## Root-owned transient coordinator. No save fields, scene-owned counts or callbacks.
## The private controller's actual result identity is required for a reward commit.

class Result extends RefCounted:
	var accepted: bool = false
	var outcome: String = ""
	var message: String = ""
	var rewarded: bool = false
	var item_id: String = ""
	var count: int = 0

var _controller: FishingChallengeController = FishingChallengeController.new()
var _mode: String = "idle"
var _session: WeakRef
var _location: WeakRef
var _inventory: WeakRef
var _catalog: WeakRef
var _rod_signature: Array = []
var _health: int = 0
var _point: Vector3 = Vector3.ZERO
var _generation: int = 0
var _sources: Dictionary[String, bool] = {}
var _blocked_sources: Dictionary[String, bool] = {}
var _pending: FishingChallengeController.Resolution
var _consumed: int = 0
var _committing: bool = false
var _last: Result = Result.new()

func mode() -> String: return _mode
func active() -> bool: return _mode == "attempt" and _controller.is_active()
func snapshot() -> Dictionary:
	var state: FishingChallengeController.Snapshot = _controller.snapshot()
	return {"mode":_mode, "phase":state.phase if _mode == "attempt" else _mode,
		"token":state.attempt_token, "item_id":state.fish_item_id, "point":_point,
		"tension":state.tension, "progress":state.landing_progress,
		"wait_seconds":state.wait_seconds, "phase_seconds":state.phase_elapsed_seconds,
		"outcome":_last.outcome, "message":_last.message, "rewarded":_last.rewarded,
		"reel_held":not _sources.is_empty(), "safe_min":state.optimal_minimum,
		"safe_max":state.optimal_maximum, "danger_min":state.danger_minimum,
		"danger_max":state.danger_maximum, "danger_seconds":state.danger_seconds}

static func rod(session: GameSession) -> RodActivationDefinition:
	if session == null or not session.initialized: return null
	var item: ItemDefinition = session.inventory.active_tool()
	if item == null or item.stable_id != ForagingRegistry.ROD_ITEM or session.inventory.count(item.stable_id) != 1 or item.rod_activation == null or not item.rod_activation.validation_errors().is_empty(): return null
	return item.rod_activation

func enter(session: GameSession, location: PrototypeLocation, catalog: ContentCatalog) -> Result:
	if _mode != "idle" or _committing: return _result(false, "blocked", "Fishing already active.")
	if catalog == null or not catalog.initialized: return _result(false,"invalid_context","Fishing catalog unavailable.")
	var capability: RodActivationDefinition = rod(session)
	if capability == null: return _result(false, "rod_required", "Select your owned fishing rod in B first.")
	if not is_instance_valid(location) or not location.is_inside_tree() or not location is AlderwakeTerrainPreview or location.location_id != "prototype-alderwake" or session.current_location_id != location.location_id:
		return _result(false, "invalid_map", "Fishing requires Alderwake open water.")
	_session = weakref(session)
	_inventory = weakref(session.inventory)
	_location = weakref(location)
	_catalog = weakref(catalog)
	_rod_signature = _signature(capability)
	_health = session.actors[GameSession.PLAYER_INSTANCE_ID].health
	_mode = "targeting"
	return _result(true, "targeting", "Aim at open water; click to cast. F / right-click: cancel.")

func binding_valid(session: GameSession, location: PrototypeLocation, catalog: ContentCatalog) -> bool:
	if session == null or catalog == null or not session.initialized or not catalog.initialized: return false
	if _mode == "idle" or _session == null or _session.get_ref() != session or _inventory.get_ref() != session.inventory or _catalog.get_ref() != catalog or _location.get_ref() != location: return false
	var capability: RodActivationDefinition = rod(session)
	return is_instance_valid(location) and not location.is_queued_for_deletion() and location.is_inside_tree() and location.location_id == session.current_location_id and location.location_id == "prototype-alderwake" and capability != null and _signature(capability) == _rod_signature and session.actors[GameSession.PLAYER_INSTANCE_ID].health == _health and _health > 0

func cast(session: GameSession, location: PrototypeLocation, catalog: ContentCatalog,
		camera: Camera3D, pointer: Vector2, foot: Vector3, pointer_allowed: bool,
		encounter_roll: Variant, wait_roll: Variant, keyboard_held: bool = false) -> Result:
	if _mode != "targeting" or not binding_valid(session, location, catalog) or _committing:
		return _result(false, "blocked", "Fishing context changed.")
	# Resolve from the current ray, never a caller-supplied/cached eligibility token.
	var target: FishingWaterTargetResolver.Result = FishingWaterTargetResolver.from_pointer(location,catalog,camera,pointer,foot,pointer_allowed,rod(session))
	if target.status == "no_area": return _result(false, "no_area", "No fishing area here; aim elsewhere.")
	if target.status != "eligible": return _result(false, "invalid_target", "Cannot cast: " + target.reason.replace("_", " ") + ".")
	var encounter: FishingActivityResolver.Result = FishingActivityResolver.resolve(catalog,Vector2(target.point.x,target.point.z),encounter_roll,location.location_id)
	if encounter.status not in ["fish", "miss"]: return _result(false,"invalid_roll","Invalid fishing encounter.")
	var feature: FishingChallengeDefinition = null
	if encounter.status == "fish":
		if not session.inventory.can_add(encounter.item_id,1).is_empty(): return _result(false,"capacity","Backpack full for this fish; cast not started.")
		feature = catalog.get_item(encounter.item_id).fishing_challenge
	_sources.clear()
	if keyboard_held: _sources["keyboard"] = true
	var started: FishingChallengeController.CommandResult = _controller.start(encounter.item_id,feature,wait_roll,_generation,keyboard_held)
	if not started.accepted:
		_sources.clear()
		return _result(false,"invalid_roll",started.error)
	_point = target.point
	_pending = null
	_mode = "attempt"
	return _result(true,"waiting","Waiting for a bite. Fresh E: hook; F / right-click: cancel.")

func reel(source: String, held: bool, session: GameSession, location: PrototypeLocation, catalog: ContentCatalog) -> Result:
	if source not in ["keyboard","pointer"]: return _result(false,"invalid_input","Unknown reel input.")
	if not held:
		_blocked_sources.erase(source)
		_sources.erase(source)
		if active(): return advance(0.0,session,location,catalog)
		return _result(false,"inactive","No active fishing attempt.")
	if not active() or _blocked_sources.has(source): return _result(false,"blocked","Release reel before pressing again.")
	if _sources.has(source): return _result(false,"held","Reel already held.")
	var was_held: bool = not _sources.is_empty()
	_sources[source] = true
	if not was_held: _generation += 1
	return advance(0.0,session,location,catalog)

func advance(delta: Variant, session: GameSession, location: PrototypeLocation, catalog: ContentCatalog) -> Result:
	if not active(): return _result(false,"inactive","No active fishing attempt.")
	if not binding_valid(session,location,catalog): return cancel("context changed")
	var updated: FishingChallengeController.CommandResult = _controller.update(delta,not _sources.is_empty(),_generation,_controller.snapshot().attempt_token)
	if not updated.accepted: return _result(false,"invalid_input",updated.error)
	if updated.resolution != null:
		_pending = updated.resolution
		return complete(_pending,session,location,catalog)
	return _result(true,_controller.snapshot().phase,"")

func complete(resolution: FishingChallengeController.Resolution, session: GameSession,
		location: PrototypeLocation, catalog: ContentCatalog) -> Result:
	var terminal: FishingChallengeController.Snapshot = _controller.snapshot()
	if _committing or _mode != "attempt" or resolution == null or resolution != _pending or terminal.phase != "terminal" or resolution.attempt_token != terminal.attempt_token or resolution.attempt_token <= _consumed or resolution.outcome != terminal.outcome or resolution.fish_item_id != terminal.fish_item_id or resolution.reward_eligible != (terminal.outcome == "landed"):
		return _result(false,"invalid_result","Stale or unverified fishing result.")
	# Consume before the existing command. No observer/callback can retry this token.
	_consumed = resolution.attempt_token
	_committing = true
	var outcome: String = terminal.outcome
	var rewarded: bool = false
	if outcome == "landed":
		var item: ItemDefinition = catalog.get_item(terminal.fish_item_id) if catalog != null else null
		if not binding_valid(session,location,catalog) or item == null or item.category != "fish" or not item.validation_errors().is_empty():
			outcome = "stale_reward"
		elif not session.inventory.can_add(item.stable_id,1).is_empty():
			outcome = "capacity"
		else:
			rewarded = session.inventory.add(item.stable_id,1).is_empty()
			if not rewarded: outcome = "capacity"
	var messages: Dictionary = {"no_bite":"No bite. Try casting again.","early_reel":"Reeled too early; fish scared away.","missed_hook":"Missed the bite. Press E freshly when it bites.","line_slack":"Line went slack; fish escaped.","line_snapped":"Line snapped; release E to lower tension.","exhausted":"Fish escaped; fight took too long.","capacity":"Backpack full; fish not added.","stale_reward":"Fishing context changed; fish not added.","canceled":"Fishing canceled."}
	var message: String = "Landed %s! +1 in backpack." % catalog.get_item(terminal.fish_item_id).display_name if rewarded else messages.get(outcome,"Fishing ended.")
	_finish()
	_committing = false
	var result: Result = _result(true,outcome,message)
	result.rewarded = rewarded
	result.item_id = terminal.fish_item_id
	result.count = session.inventory.count(terminal.fish_item_id) if rewarded else 0
	_remember(result)
	return result

func cancel(reason: String = "explicit") -> Result:
	if _committing: return _result(false,"blocked","Reward commit in progress.")
	if active():
		var token: int = _controller.snapshot().attempt_token
		_controller.cancel(token,reason)
		_consumed = maxi(_consumed,token)
	_finish()
	return _result(true,"canceled","Fishing canceled: " + reason + ".")

func _finish() -> void:
	for source: String in _sources: _blocked_sources[source] = true
	_sources.clear()
	_mode = "idle"
	_pending = null
	_session = null
	_inventory = null
	_location = null
	_catalog = null
	_rod_signature.clear()

static func _signature(capability: RodActivationDefinition) -> Array:
	return [capability.activity_id,capability.target_cell_size_m,capability.maximum_range_m,capability.required_surface,capability.action]

func _result(accepted: bool, outcome: String, message: String) -> Result:
	var result: Result = Result.new()
	result.accepted = accepted
	result.outcome = outcome
	result.message = message
	if accepted or (_mode == "targeting" and not message.is_empty()) or (_mode == "idle" and outcome in ["rod_required","invalid_map","invalid_context"]): _remember(result)
	return result

func _remember(result: Result) -> void:
	_last = Result.new()
	_last.accepted = result.accepted
	_last.outcome = result.outcome
	_last.message = result.message
	_last.rewarded = result.rewarded
	_last.item_id = result.item_id
	_last.count = result.count
