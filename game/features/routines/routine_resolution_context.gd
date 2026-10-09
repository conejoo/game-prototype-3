class_name RoutineResolutionContext
extends RefCounted
## Detached read-only sample of existing owners. No clock or durable state here.
var _data: Dictionary = {}
var _events: NpcEventMemory
var _errors: PackedStringArray = []
var errors: PackedStringArray:
	get: return _errors.duplicate()
var day_index: int:
	get: return int(_data.get("day_index", 0))
var minute_of_day: float:
	get: return float(_data.get("minute", 0.0))
var active_seconds: float:
	get: return float(_data.get("active_seconds", 0.0))

static func from_session(session: GameSession) -> RoutineResolutionContext:
	if session == null or not session.initialized:
		var invalid: RoutineResolutionContext = RoutineResolutionContext.new()
		invalid._errors.append("routine context requires initialized session")
		return invalid
	var facts: RoutineFacts.Result = RoutineFacts.restore(session.routines.snapshot())
	if not facts.errors.is_empty():
		var invalid: RoutineResolutionContext = RoutineResolutionContext.new()
		invalid._errors = facts.errors
		return invalid
	return capture(session.environment, session.conversations, session.elapsed_play_seconds,
		session.routines.authored_events(), session.routines.suppressed_ids(), session.environment.day_index)

static func capture(environment: EnvironmentState, conversations: NpcConversationState, seconds: float, authored_events: PackedStringArray = [], suppressed_ids: PackedStringArray = [], suppression_day: int = -1) -> RoutineResolutionContext:
	var result: RoutineResolutionContext = RoutineResolutionContext.new()
	if environment == null or conversations == null or not conversations.initialized:
		result._errors.append("routine context requires environment and initialized conversations")
		return result
	result._errors.append_array(environment.validation_errors())
	if not NpcEventMemory.valid_time(seconds): result._errors.append("routine active seconds out of range")
	if suppression_day < -1 or suppression_day > EnvironmentClock.MAX_DAY_INDEX:
		result._errors.append("routine suppression day out of range")
	if not suppressed_ids.is_empty() and suppression_day == -1:
		result._errors.append("routine suppression requires authoritative day")
	if suppression_day > environment.day_index:
		result._errors.append("routine suppression day is in the future")
	for id: String in authored_events:
		if id not in RoutineFacts.EVENT_IDS: result._errors.append("unknown authored routine event " + id)
	for id: String in suppressed_ids:
		if id not in RoutineContentCatalog.IDS: result._errors.append("unknown suppressed routine " + id)
	result._events = conversations.events()
	for row: Dictionary in result._events.snapshot().facts:
		if float(row.last_active_seconds) > seconds: result._errors.append("routine sample predates event memory")
	if not result._errors.is_empty(): return result
	var weather: WeatherConditionService = WeatherConditionService.new()
	weather.bind_environment(environment)
	var effective: PackedStringArray = authored_events.duplicate()
	if weather.has_condition("heavy-rain") and "heavy-rain" not in effective: effective.append("heavy-rain")
	effective.sort()
	var suppressed: PackedStringArray = suppressed_ids.duplicate() if suppression_day == environment.day_index else PackedStringArray()
	suppressed.sort()
	var minute: float = EnvironmentClock.minute_of_day(environment.day_cycle_progress)
	# Same narrow float round-trip normalization as WeatherSchedule, not time seeking.
	if absf(minute - round(minute)) <= WeatherSchedule.BOUNDARY_EPSILON_MINUTES:
		minute = fmod(round(minute), float(EnvironmentClock.MINUTES_PER_DAY))
	result._data = {"day_index": environment.day_index, "minute": minute, "active_seconds": seconds, "events": Array(effective), "suppressed": Array(suppressed), "people": conversations.snapshot().people}
	RoutineDefinition.freeze(result._data)
	return result

func suppressed(id: String) -> bool: return id in _data.get("suppressed", [])
func event_active(id: String) -> bool: return id in _data.get("events", [])
func learned(npc_id: String, fact_id: String) -> bool:
	return fact_id in _data.get("people", {}).get(npc_id, {}).get("learned_fact_ids", [])
func flag_set(npc_id: String, flag_id: String) -> bool:
	return flag_id in _data.get("people", {}).get(npc_id, {}).get("flags", [])
func event_matches(condition: RoutineDefinition.Condition) -> bool:
	var query: NpcDialogueGraph.EventCondition = NpcDialogueGraph.EventCondition.new({"kind": condition.event_kind, "subjectId": condition.subject_id, "targetId": condition.target_id, "minimumCount": condition.minimum_count, "maximumCount": condition.maximum_count, "occurredWithinActiveSeconds": condition.recency_seconds})
	return _events.matches(query, active_seconds)
func snapshot() -> Dictionary: return _data.duplicate(true)
