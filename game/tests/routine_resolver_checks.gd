extends SceneTree
## R003 synthetic source-vector/rule checks. No gameplay, durable facts or saves.
var failures: Array[String] = []
var assertions: int = 0
var actors: ContentCatalog = ContentCatalog.new()
var npcs: NpcContentCatalog = NpcContentCatalog.new()
var catalog: RoutineContentCatalog = RoutineContentCatalog.new()
var state: NpcConversationState = NpcConversationState.new()
var vectors: Dictionary
var observed: Array[Dictionary] = []
const VECTORS: String = "res://../tools/routine_migration/reference/vectors.json"

func _initialize() -> void: _run.call_deferred()

func _setup() -> bool:
	_check(actors.initialize(load("res://content/prototype_catalog.tres") as ContentManifest).is_empty(), "actor prerequisites")
	_check(npcs.initialize_path(actors).is_empty(), "NPC prerequisites")
	_check(catalog.initialize_path(npcs).is_empty(), "R002 complete catalog")
	_check(state.initialize(npcs).is_empty(), "real memory owner")
	vectors = JSON.parse_string(FileAccess.get_file_as_string(VECTORS))
	return catalog.initialized and state.initialized

func _run() -> void:
	if not _setup():
		_finish("routine-resolver.json")
		return
	var seen: PackedStringArray = []
	for vector: Dictionary in vectors.selection_cases:
		var memory: NpcConversationState = state.detached_copy()
		for id: String in vector.get("facts", {}):
			var person: ConversationMemory = memory.memory(id)
			person.learned_fact_ids = PackedStringArray(vector.facts[id])
			memory = memory.with_person(person)
		for id: String in vector.get("flags", {}):
			var person: ConversationMemory = memory.memory(id)
			person.flags = PackedStringArray(vector.flags[id])
			memory = memory.with_person(person)
		for count: int in int(vector.get("gather_count", 0)):
			memory = memory.with_events(memory.events().record(NpcEventMemory.GATHER, "moonflower", null, 100.0))
		var env: EnvironmentState = _environment(RoutineDefinition.minute(vector.time), vector.get("weather", "nonstorm"))
		var before: Dictionary = memory.snapshot()
		var context: RoutineResolutionContext = RoutineResolutionContext.capture(env, memory, 100.0, PackedStringArray(vector.get("authored_events", [])))
		var plan: RoutineAssignmentPlan = RoutineResolver.resolve(RoutineResolver.definitions(catalog), context)
		_check(context.errors.is_empty() and plan != null, "valid vector context " + vector.id)
		if plan == null: continue
		var vale: PackedStringArray = []
		for npc_id: String in ["npc-01", "npc-02"]:
			var id: String = plan.routine_for(npc_id)
			if id not in vale: vale.append(id)
		vale.sort()
		var expected: PackedStringArray = PackedStringArray(vector.vale)
		expected.sort()
		_check(vale == expected, "pinned Vale selection " + vector.id)
		for prefix: String in ["celia-repairs", "della-inn", "harlan-docks", "ivo-docks", "maris-chandlery", "tess-store"]:
			_check(prefix + "-" + vector.service_suffix in plan.routine_ids(), "pinned service " + vector.id + "/" + prefix)
		for id: String in plan.routine_ids():
			if id not in seen: seen.append(id)
		_check(memory.snapshot() == before, "selection never mutates memory " + vector.id)
		observed.append({"id": vector.id, "assignments": plan.assignments(), "elapsed": plan.snapshot().elapsed})
	seen.sort()
	_check(seen == RoutineContentCatalog.IDS, "all 25 actually selected in pinned vectors")
	_boundaries()
	_priority_groups()
	_conditions()
	_detachment_and_invalid()
	_finish("routine-resolver.json")

func _environment(minute: float, weather_id: String = "nonstorm", day: int = 0) -> EnvironmentState:
	var env: EnvironmentState = EnvironmentState.new()
	# Initial forecast starts clear; rain/storm cannot exist at every day-zero time.
	# Weather branches are explicitly later-day seeded fixtures, never natural play.
	env.day_index = maxi(day, 1) if weather_id in ["rain", "thunderstorm"] else day
	env.day_cycle_progress = fposmod(minute - EnvironmentClock.START_MINUTES, float(EnvironmentClock.MINUTES_PER_DAY)) / EnvironmentClock.MINUTES_PER_DAY
	var expected: String = "rainy" if weather_id == "rain" else weather_id
	var weather: WeatherConditionService = WeatherConditionService.new()
	weather.bind_environment(env)
	for seed: int in 1000:
		env.weather_seed = seed
		if weather.condition_id() == expected or (expected == "nonstorm" and not weather.has_condition("heavy-rain")): return env
	_check(false, "fixture cannot find seeded weather " + expected)
	return env

func _context(minute: float, memory: NpcConversationState = null) -> RoutineResolutionContext:
	return RoutineResolutionContext.capture(_environment(minute), state if memory == null else memory, 100.0)

func _boundaries() -> void:
	for routine: RoutineDefinition in RoutineResolver.definitions(catalog):
		_check(RoutineResolver.contains(routine, routine.start_minute), "inclusive start " + routine.id)
		_check(not RoutineResolver.contains(routine, routine.end_minute), "exclusive end " + routine.id)
		_check(not RoutineResolver.contains(routine, fposmod(routine.start_minute - 0.0001, 1440.0)), "just before start " + routine.id)
		_check(RoutineResolver.contains(routine, fposmod(routine.end_minute - 0.0001, 1440.0)), "just before end " + routine.id)
		_check(RoutineResolver.contains(routine, fposmod(routine.start_minute + 0.0001, 1440.0)), "just after start " + routine.id)
		_check(not RoutineResolver.contains(routine, fposmod(routine.end_minute + 0.0001, 1440.0)), "just after end " + routine.id)
	var routines: Array[RoutineDefinition] = RoutineResolver.definitions(catalog)
	for minute: int in 1440:
		var context: RoutineResolutionContext = _context(minute)
		var plan: RoutineAssignmentPlan = RoutineResolver.resolve(routines, context)
		_check(plan.assignments().size() == 8, "full roster minute %d" % minute)
		for id: String in plan.routine_ids():
			for npc_id: String in catalog.get_routine(id).participants:
				_check(plan.routine_for(npc_id) == id, "whole group minute %d/%s" % [minute, id])

func _fixture(id: String, priority: int, participants: Array, conditions: Array = []) -> RoutineDefinition:
	var data: Dictionary = catalog.document_snapshot("vale-morning-work")
	data.id = id
	data.priority = priority
	data.participants = participants
	data.conditions = conditions
	return RoutineDefinition.new(data) # labeled resolver-only fixture, no content publication

func _priority_groups() -> void:
	var cases: Array[RoutineDefinition] = [_fixture("z-high", 300, ["npc-01"]), _fixture("a-group", 200, ["npc-01", "npc-02"]), _fixture("z-low", 100, ["npc-02"]), _fixture("a-low", 100, ["npc-02"])]
	var plan: RoutineAssignmentPlan = RoutineResolver.resolve(cases, _context(600))
	_check(plan.assignments() == {"npc-01": "z-high", "npc-02": "a-low"}, "descending priority / ascending ID / whole-group conflict")
	_check(plan.rejections()["a-group"] == {"reason": RoutineResolver.Rejection.PARTICIPANT_CONFLICT, "conflicts": ["npc-01"]}, "conflict diagnostics")
	cases.reverse()
	_check(RoutineResolver.resolve(cases, _context(600)).snapshot() == plan.snapshot(), "catalog order independent")
	var doc: Dictionary = catalog.document_snapshot("edric-evening-rain-shelter")
	var real: Array[RoutineDefinition] = [RoutineDefinition.new(doc)]
	var suppressed: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(600), state, 100.0, [], [doc.id], 0)
	_check(RoutineResolver.resolve(real, suppressed).rejections()[doc.id].reason == RoutineResolver.Rejection.SUPPRESSED_FOR_DAY, "suppression before window and condition")
	_check(RoutineResolver.resolve(real, _context(600)).rejections()[doc.id].reason == RoutineResolver.Rejection.OUTSIDE_WINDOW, "window before condition")
	_check(RoutineResolver.resolve(real, _context(1080)).rejections()[doc.id].reason == RoutineResolver.Rejection.CONDITION_NOT_MET, "condition before conflict")
	var both: Array[RoutineDefinition] = [_fixture("z-high", 999, ["npc-01"]), real[0]]
	var storm: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(1080, "thunderstorm"), state, 100.0)
	# z-high fixture must have an evening window to conflict.
	var high: Dictionary = both[0].snapshot()
	high.timeWindow = doc.timeWindow
	both[0] = RoutineDefinition.new(high)
	_check(RoutineResolver.resolve(both, storm).rejections()[doc.id].reason == RoutineResolver.Rejection.PARTICIPANT_CONFLICT, "last rejection is conflict")

func _event_condition(minimum: int, maximum: Variant, recency: Variant, subject: Variant = "moonflower", target: Variant = null) -> Dictionary:
	return {"kind": "playerEvent", "eventKind": "resourceGathered", "subjectId": subject, "targetId": target, "minimumCount": minimum, "maximumCount": maximum, "occurredWithinActiveSeconds": recency}

func _conditions() -> void:
	var memory: NpcConversationState = state.with_events(state.events().record(NpcEventMemory.GATHER, "moonflower", null, 100.0))
	memory = memory.with_events(memory.events().record(NpcEventMemory.GATHER, "moonflower", null, 100.0))
	var context: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(840), memory, 110.0)
	for row: Array in [[2, 2, 10.0, true], [3, null, null, false], [0, 1, null, false], [1, null, 9.999, false], [0, null, null, true]]:
		_check(RoutineResolver.matches(RoutineDefinition.Condition.new(_event_condition(row[0], row[1], row[2])), context) == row[3], "inclusive min/max/recency " + str(row))
	_check(not RoutineResolver.matches(RoutineDefinition.Condition.new(_event_condition(1, null, null, null)), context), "null subject exact")
	_check(not RoutineResolver.matches(RoutineDefinition.Condition.new(_event_condition(1, null, null, "moonflower", "npc-01")), context), "null target exact")
	_check(not RoutineResolver.matches(RoutineDefinition.Condition.new(_event_condition(0, null, 10.0)), _context(840)), "missing aggregate fails recency even min zero")
	var person: ConversationMemory = memory.memory("npc-01")
	person.learned_fact_ids.append("npc-01-river-fishing")
	memory = memory.with_person(person)
	var conditions: Array = [{"kind": "learnedFact", "npcId": "npc-01", "factId": "npc-01-river-fishing"}, {"kind": "worldEventActive", "eventId": "harbor-festival"}]
	var fixtures: Array[RoutineDefinition] = [_fixture("and-fixture", 1, ["npc-01"], conditions)]
	_check(RoutineResolver.resolve(fixtures, _context(600, memory)).assignments().is_empty(), "all conditions AND")
	var authored: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(600), memory, 100.0, ["harbor-festival"])
	_check(RoutineResolver.resolve(fixtures, authored).routine_for("npc-01") == "and-fixture", "AND satisfied with real-memory snapshots")
	_check(not context.learned("npc-14", "npc-01-river-fishing") and not context.flag_set("npc-14", "npc-02-archive-lead-shared"), "person-specific facts/flags")

func _detachment_and_invalid() -> void:
	var env: EnvironmentState = _environment(600)
	var memory: NpcConversationState = state.detached_copy()
	var ids: PackedStringArray = ["heavy-rain"]
	var context: RoutineResolutionContext = RoutineResolutionContext.capture(env, memory, 100.0, ids)
	var snapshot: Dictionary = context.snapshot()
	ids.clear()
	env.day_index = 1
	snapshot.events.clear()
	_check(context.day_index == 0 and context.event_active("heavy-rain"), "context copies inputs and snapshots")
	_check(context._data.is_read_only() and context._data.people.is_read_only(), "context deep read-only")
	var plan: RoutineAssignmentPlan = RoutineResolver.resolve(RoutineResolver.definitions(catalog), context)
	var assignments: Dictionary = plan.assignments()
	assignments.clear()
	_check(plan.assignments().size() == 8 and plan._data.is_read_only() and plan._data.assignments.is_read_only(), "plan immutable detached view")
	for invalid: RoutineResolutionContext in [RoutineResolutionContext.capture(null, state, 0.0), RoutineResolutionContext.capture(env, null, 0.0), RoutineResolutionContext.capture(env, state, NAN), RoutineResolutionContext.capture(env, state, -1.0), RoutineResolutionContext.capture(env, state, INF), RoutineResolutionContext.capture(env, state, 0.0, ["unknown"]), RoutineResolutionContext.capture(env, state, 0.0, [], ["unknown"], 1), RoutineResolutionContext.capture(env, state, 0.0, [], ["vale-morning-work"]), RoutineResolutionContext.capture(env, state, 0.0, [], [], 2)]:
		_check(not invalid.errors.is_empty() and RoutineResolver.resolve(RoutineResolver.definitions(catalog), invalid) == null, "invalid input refuses resolution")
	var bad: EnvironmentState = _environment(600)
	bad.day_cycle_progress = NAN
	_check(not RoutineResolutionContext.capture(bad, state, 0.0).errors.is_empty(), "invalid existing clock refused")
	var future: NpcConversationState = state.with_events(state.events().record(NpcEventMemory.GATHER, "moonflower", null, 100.0))
	_check(not RoutineResolutionContext.capture(_environment(600), future, 99.0).errors.is_empty(), "future aggregate refused")

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _finish(filename: String) -> void:
	_check(TestRunEvidence.write_json(filename, {"task": "R003", "mode": "synthetic pure rules; no saved-state or gameplay proof", "assertions": assertions, "failures": failures, "vectors": observed}), "write evidence")
	for failure: String in failures: push_error("ASSERTION: " + failure)
	print("R003 %s: %d assertions; %d failures" % [filename, assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)
