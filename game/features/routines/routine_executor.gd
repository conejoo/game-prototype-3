class_name RoutineExecutor
extends RefCounted
## Transient participant cursor. Positions ALWAYS travel with their map identity.
enum State { READY, MOVING, WAITING, ACTING, SPEAKING, COMPLETED, FAILED, CANCELLED }
enum Failure { NONE, INVALID_ORIGIN, INVALID_ANCHOR, INVALID_CHAIN, MOVEMENT, ARRIVAL_BLOCKED, TRANSITION_LIMIT }
const MAX_TRANSITIONS: int = 64
var npc_id: String
var routine: RoutineDefinition
var steps: Array[RoutineDefinition.Step] = []
var map_id: String
var foot: Vector3
var facing: Vector3 = Vector3.BACK
var index: int = 0
var remaining: float = 0
var state: State = State.READY
var failure: Failure = Failure.NONE
var phase: String = ""
var transitions: int = 0
var pending_edge: Dictionary = {}
var arrival_wait: float = 0
var failure_detail: Dictionary = {}

func initialize(definition: RoutineDefinition, id: String, origin: Dictionary) -> bool:
	if definition == null or id not in definition.participants or not origin.has("map") or not origin.map is String or origin.map.is_empty() or not origin.has("foot") or not origin.foot is Vector3 or not origin.foot.is_finite():
		return fail(Failure.INVALID_ORIGIN)
	routine = definition; npc_id = id; steps = routine.steps(id)
	map_id = origin.map; foot = origin.foot
	return true

func current_step() -> RoutineDefinition.Step:
	return steps[index] if index < steps.size() else null

func advance_step() -> void:
	index += 1; transitions += 1; remaining = 0; phase = ""; pending_edge = {}; arrival_wait = 0
	state = State.COMPLETED if index >= steps.size() else State.READY
	if transitions > MAX_TRANSITIONS: fail(Failure.TRANSITION_LIMIT)

func fail(reason: Failure) -> bool:
	failure = reason; state = State.FAILED; remaining = 0; phase = ""; pending_edge = {}
	return false

func snapshot() -> Dictionary:
	var step: RoutineDefinition.Step = current_step()
	return {"npc_id":npc_id,"routine_id":routine.id if routine != null else "","map_id":map_id,"foot":foot,"step_id":step.id if step != null else "","index":index,"state":state,"failure":failure,"failure_detail":failure_detail.duplicate(true),"remaining":remaining,"phase":phase,"transitions":transitions}

func reconstruct(elapsed: float, world: RoutineExecutionWorld) -> bool:
	if not is_finite(elapsed) or elapsed < 0: return fail(Failure.INVALID_ORIGIN)
	# Finite forward sweep over authored steps; never iterate elapsed seconds/days.
	var budget: float = elapsed
	while state not in [State.COMPLETED,State.FAILED] and transitions <= MAX_TRANSITIONS:
		var step: RoutineDefinition.Step = current_step()
		if step.kind == RoutineDefinition.StepKind.MOVE:
			var target: Dictionary = world.anchor(step.map_id,step.anchor_id)
			if target.is_empty(): return fail(Failure.INVALID_ANCHOR)
			var route: Dictionary = world.chain(map_id,step.map_id)
			if not route.ok: return fail(Failure.INVALID_CHAIN)
			# Offscreen historical legs resolve only after a complete validated chain.
			var distance: float = 0
			var origin: Vector3 = foot
			for edge: Dictionary in route.legs:
				distance += origin.distance_to(world.door(edge))
				origin = world.arrival(edge)
			distance += origin.distance_to(target.foot)
			var duration: float = distance/RoutineMovement.SPEED
			if budget+0.000001 < duration:
				# A partially reconstructed move keeps its qualified safe origin. Loaded
				# presentation walks the remaining leg; no interpolated wall crossing.
				state = State.READY
				return true
			budget = maxf(0,budget-duration); map_id = step.map_id; foot = target.foot; facing = target.facing
			advance_step()
		else:
			remaining = maxf(0,step.duration_seconds-budget)
			state = [State.READY,State.WAITING,State.ACTING,State.SPEAKING][step.kind]
			if remaining > 0: return true
			budget = maxf(0,budget-step.duration_seconds); advance_step()
	return state != State.FAILED
