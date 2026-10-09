class_name RoutineResolver
extends RefCounted
## Pure source precedence. IDs/enums only in diagnostics; never actors or effects.
enum Rejection { SUPPRESSED_FOR_DAY, OUTSIDE_WINDOW, CONDITION_NOT_MET, PARTICIPANT_CONFLICT }

static func definitions(catalog: RoutineContentCatalog) -> Array[RoutineDefinition]:
	var result: Array[RoutineDefinition] = []
	if catalog != null and catalog.initialized:
		for id: String in catalog.routine_ids(): result.append(catalog.get_routine(id))
	return result

static func contains(routine: RoutineDefinition, minute: float) -> bool:
	if not is_finite(minute) or minute < 0.0 or minute >= EnvironmentClock.MINUTES_PER_DAY: return false
	if routine.start_minute == routine.end_minute: return false
	return minute >= routine.start_minute or minute < routine.end_minute if routine.overnight else minute >= routine.start_minute and minute < routine.end_minute

static func elapsed_window_seconds(routine: RoutineDefinition, minute: float) -> float:
	return fposmod(minute - routine.start_minute, float(EnvironmentClock.MINUTES_PER_DAY)) / EnvironmentClock.MINUTES_PER_DAY * EnvironmentClock.CYCLE_SECONDS

static func matches(condition: RoutineDefinition.Condition, context: RoutineResolutionContext) -> bool:
	match condition.kind:
		RoutineDefinition.ConditionKind.EVENT_ACTIVE: return context.event_active(condition.event_id)
		RoutineDefinition.ConditionKind.EVENT_INACTIVE: return not context.event_active(condition.event_id)
		RoutineDefinition.ConditionKind.LEARNED_FACT: return context.learned(condition.npc_id, condition.fact_id)
		RoutineDefinition.ConditionKind.FLAG_SET: return context.flag_set(condition.npc_id, condition.flag_id)
		RoutineDefinition.ConditionKind.FLAG_UNSET: return not context.flag_set(condition.npc_id, condition.flag_id)
		RoutineDefinition.ConditionKind.PLAYER_EVENT: return context.event_matches(condition)
	return false

static func decision_key(routines: Array[RoutineDefinition], context: RoutineResolutionContext) -> Array:
	var key: Array = [context.day_index]
	for routine: RoutineDefinition in routines:
		var conditions: Array[bool] = []
		for condition: RoutineDefinition.Condition in routine.conditions(): conditions.append(matches(condition, context))
		key.append([routine.id, context.suppressed(routine.id), contains(routine, context.minute_of_day), conditions])
	return key

static func resolve(routines: Array[RoutineDefinition], context: RoutineResolutionContext) -> RoutineAssignmentPlan:
	if context == null or not context.errors.is_empty(): return null
	var candidates: Array[RoutineDefinition] = []
	var assignments: Dictionary = {}
	var rejections: Dictionary = {}
	for routine: RoutineDefinition in routines:
		if context.suppressed(routine.id):
			rejections[routine.id] = {"reason": Rejection.SUPPRESSED_FOR_DAY, "conflicts": []}
		elif not contains(routine, context.minute_of_day):
			rejections[routine.id] = {"reason": Rejection.OUTSIDE_WINDOW, "conflicts": []}
		else:
			var eligible: bool = true
			for condition: RoutineDefinition.Condition in routine.conditions():
				if not matches(condition, context): eligible = false
			if eligible: candidates.append(routine)
			else: rejections[routine.id] = {"reason": Rejection.CONDITION_NOT_MET, "conflicts": []}
	candidates.sort_custom(func(left: RoutineDefinition, right: RoutineDefinition) -> bool: return left.priority > right.priority if left.priority != right.priority else left.id < right.id)
	for routine: RoutineDefinition in candidates:
		var conflicts: PackedStringArray = []
		for npc_id: String in routine.participants:
			if assignments.has(npc_id): conflicts.append(npc_id)
		if not conflicts.is_empty():
			conflicts.sort()
			rejections[routine.id] = {"reason": Rejection.PARTICIPANT_CONFLICT, "conflicts": Array(conflicts)}
			continue
		for npc_id: String in routine.participants: assignments[npc_id] = routine.id
	return sample_plan(routines, context, assignments, rejections)

static func sample_plan(routines: Array[RoutineDefinition], context: RoutineResolutionContext, assignments: Dictionary, rejections: Dictionary) -> RoutineAssignmentPlan:
	var elapsed: Dictionary = {}
	var sorted_assignments: Dictionary = {}
	var sorted_rejections: Dictionary = {}
	var ids: Array = assignments.keys()
	ids.sort()
	for npc_id: String in ids:
		sorted_assignments[npc_id] = assignments[npc_id]
		for routine: RoutineDefinition in routines:
			if routine.id == assignments[npc_id]: elapsed[npc_id] = elapsed_window_seconds(routine, context.minute_of_day)
	ids = rejections.keys()
	ids.sort()
	for id: String in ids: sorted_rejections[id] = rejections[id]
	return RoutineAssignmentPlan.new(context.day_index, context.minute_of_day, sorted_assignments, elapsed, sorted_rejections)
