class_name RoutineAssignmentDirector
extends RefCounted
## Caller samples existing owners each update, even without player input. No ticks,
## durable suppression, executor, movement or production root wiring in R003.
var _routines: Array[RoutineDefinition] = []
var _key: Array = []
var _plan: RoutineAssignmentPlan
var _resolution_count: int = 0
var _revision: int = 0
var _conditions: Dictionary = {}
var resolution_count: int:
	get: return _resolution_count
var revision: int:
	get: return _revision
var current_plan: RoutineAssignmentPlan:
	get: return _plan

func initialize(catalog: RoutineContentCatalog) -> PackedStringArray:
	if not _routines.is_empty(): return PackedStringArray(["routine director already initialized"])
	if catalog == null or not catalog.initialized: return PackedStringArray(["routine director requires validated catalog"])
	_routines = RoutineResolver.definitions(catalog)
	# Content is immutable; retain detached typed conditions instead of building
	# and freezing the same wrappers on every active update.
	for routine: RoutineDefinition in _routines: _conditions[routine.id] = routine.conditions()
	return []

func update(context: RoutineResolutionContext, resample_elapsed: bool = true) -> Dictionary:
	if _routines.is_empty(): return {"errors": PackedStringArray(["routine director not initialized"])}
	if context == null: return {"errors": PackedStringArray(["routine director requires context"])}
	if not context.errors.is_empty(): return {"errors": context.errors}
	var key: Array = [context.day_index]
	for routine: RoutineDefinition in _routines:
		var conditions: Array[bool] = []
		for condition: RoutineDefinition.Condition in _conditions[routine.id]: conditions.append(RoutineResolver.matches(condition,context))
		key.append([routine.id,context.suppressed(routine.id),RoutineResolver.contains(routine,context.minute_of_day),conditions])
	var reevaluated: bool = _plan == null or key != _key
	var candidate: RoutineAssignmentPlan
	if reevaluated:
		candidate = RoutineResolver.resolve(_routines, context)
		_resolution_count += 1
	elif resample_elapsed:
		candidate = RoutineResolver.sample_plan(_routines, context, _plan.assignments(), _plan.rejections())
	else:
		# Loaded execution consumes physical cursors, not reconstruction elapsed.
		# Still evaluate every time/weather/fact/recency gate on every update.
		return {"errors":PackedStringArray(),"plan":_plan,"reevaluated":false,"changed_participants":PackedStringArray(),"revision":_revision}
	var changed: PackedStringArray = []
	for npc_id: String in NpcContentCatalog.ROSTER:
		if _plan == null or candidate.routine_for(npc_id) != _plan.routine_for(npc_id) or (candidate.day_index != _plan.day_index and not candidate.routine_for(npc_id).is_empty()): changed.append(npc_id)
	if not changed.is_empty(): _revision += 1
	_key = key.duplicate(true)
	_plan = candidate
	return {"errors": PackedStringArray(), "plan": _plan, "reevaluated": reevaluated, "changed_participants": changed, "revision": _revision}
