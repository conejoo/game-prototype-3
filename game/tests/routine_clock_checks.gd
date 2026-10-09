extends "res://tests/routine_resolver_checks.gd"
## Synthetic clock/director acceptance. Existing clock advances; director samples.
func _run() -> void:
	if not _setup():
		_finish("routine-clock.json")
		return
	_clock_vectors()
	_suppression_day()
	_stable_plans_and_changes()
	_recency_expiry()
	_weather_union()
	_finish("routine-clock.json")

func _clock_vectors() -> void:
	for vector: Dictionary in vectors.clock_cases:
		var env: EnvironmentState = EnvironmentState.new()
		env.day_index = int(vector.day_index)
		env.day_cycle_progress = float(vector.progress)
		var context: RoutineResolutionContext = RoutineResolutionContext.capture(env, state, 0.0)
		_check(context.errors.is_empty() and absf(context.minute_of_day - float(vector.minute)) < 0.000001, "pinned clock " + vector.id)
	for vector: Dictionary in vectors.reconstruction_cases:
		var minute: int = RoutineDefinition.minute(vector.time)
		var context: RoutineResolutionContext = _context(minute)
		var plan: RoutineAssignmentPlan = RoutineResolver.resolve(RoutineResolver.definitions(catalog), context)
		_check(plan.routine_for("npc-01") == vector.routine, "elapsed assignment " + vector.time)
		_check(absf(plan.elapsed_for("npc-01") - float(vector.elapsed_seconds)) < 0.000001, "pinned elapsed " + vector.time)
		observed.append({"time": vector.time, "elapsed_seconds": plan.elapsed_for("npc-01"), "mode": "elapsed only; no R010 reconstruction"})
	var env: EnvironmentState = _environment(599.9, "sunny", EnvironmentClock.MAX_DAY_INDEX)
	var before: float = env.day_cycle_progress
	_check(not env.advance(1e300).is_empty() and env.day_cycle_progress == before, "huge delta rejected by sole clock atomically")
	var empty: Dictionary = catalog.document_snapshot("vale-morning-work")
	empty.timeWindow.end = empty.timeWindow.start
	_check(not RoutineResolver.contains(RoutineDefinition.new(empty), 600.0), "empty window never active")
	for minute: float in [NAN, INF, -1.0, 1440.0]:
		_check(not RoutineResolver.contains(catalog.get_routine("vale-morning-work"), minute), "invalid minute never active")

func _suppression_day() -> void:
	var ids: PackedStringArray = ["vale-overnight-home", "vale-morning-work"]
	var director: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(director.initialize(catalog).is_empty(), "director initialized")
	var before: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(1439), state, 100.0, [], ids, 0)
	var midnight: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(0), state, 100.0, [], ids, 0)
	_check(before.suppressed("vale-overnight-home") and midnight.suppressed("vale-overnight-home"), "midnight retains current-day suppression")
	var result: Dictionary = director.update(before)
	_check(result.plan.routine_for("npc-01").is_empty(), "suppressed overnight not selected")
	var revision_before: int = director.revision
	result = director.update(midnight)
	_check(not result.reevaluated and result.changed_participants.is_empty() and director.revision == revision_before, "midnight within overnight does not restart")
	var env: EnvironmentState = _environment(599.0)
	var context: RoutineResolutionContext = RoutineResolutionContext.capture(env, state, 100.0, [], ids, 0)
	_check(context.suppressed("vale-morning-work"), "before 10 AM suppression retained")
	_check(env.advance(EnvironmentClock.CYCLE_SECONDS / EnvironmentClock.MINUTES_PER_DAY).is_empty(), "real clock rolls at 10 AM")
	context = RoutineResolutionContext.capture(env, state, 100.0, [], ids, 0)
	_check(context.day_index == 1 and not context.suppressed("vale-morning-work"), "day rollover expires supplied old-day suppression")
	_check(ids.size() == 2, "pure suppression filtering does not mutate durable caller inputs")
	result = director.update(context)
	_check(result.plan.routine_for("npc-01") == "vale-morning-work" and result.reevaluated, "day rollover re-evaluates without player action")
	var current: RoutineResolutionContext = RoutineResolutionContext.capture(env, state, 100.0, [], ids, 1)
	_check(current.suppressed("vale-morning-work"), "new authoritative day suppression honored")

func _stable_plans_and_changes() -> void:
	var director: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(director.initialize(catalog).is_empty(), "stable director initialized")
	_check(not director.initialize(catalog).is_empty(), "double initialization refused")
	var env: EnvironmentState = _environment(600)
	var memory_before: Dictionary = state.snapshot()
	var result: Dictionary = director.update(RoutineResolutionContext.capture(env, state, 100.0))
	_check(result.reevaluated and result.changed_participants == NpcContentCatalog.ROSTER, "initial full assignment")
	var revision_before: int = director.revision
	for frame: int in 120:
		_check(env.advance(1.0 / 60.0).is_empty(), "sole clock advances frame")
		result = director.update(RoutineResolutionContext.capture(env, state, 100.0 + float(frame + 1) / 60.0))
		_check(not result.reevaluated and result.changed_participants.is_empty() and director.revision == revision_before, "unchanged plans never restart frame %d" % frame)
	_check(director.resolution_count == 1, "no repeated resolution on unchanged decisions")
	_check(absf(result.plan.elapsed_for("npc-01") - 52.0) < 0.000001, "latest plan elapsed advances without restart")
	var saved_plan: RoutineAssignmentPlan = director.current_plan
	var previous_count: int = director.resolution_count
	result = director.update(RoutineResolutionContext.capture(null, state, 100.0))
	_check(not result.errors.is_empty() and director.current_plan == saved_plan and director.resolution_count == previous_count, "invalid update leaves accepted plan intact")
	result = director.update(_context(719.999))
	_check(result.changed_participants.is_empty(), "just before window expiry stable")
	result = director.update(_context(720.0))
	_check(result.reevaluated and result.changed_participants == PackedStringArray(["npc-01", "npc-02"]), "window expiry atomically changes group without input")
	_check(result.plan.routine_for("npc-01") == "vale-midday-briefing" and result.plan.routine_for("npc-02") == "vale-midday-briefing", "new group whole")
	result = director.update(_context(840))
	_check(result.changed_participants.size() == 2, "group to solos reconciles both")
	var person: ConversationMemory = state.memory("npc-01")
	person.learned_fact_ids.append("npc-01-river-fishing")
	var memory: NpcConversationState = state.with_person(person)
	result = director.update(_context(840, memory))
	_check(result.reevaluated and result.changed_participants == PackedStringArray(["npc-01"]) and result.plan.routine_for("npc-01") == "edric-afternoon-river-notes", "real learned-fact snapshot reassigns only Edric")
	person = memory.memory("npc-02")
	person.flags.append("npc-02-archive-lead-shared")
	memory = memory.with_person(person)
	result = director.update(_context(840, memory))
	_check(result.reevaluated and result.changed_participants == PackedStringArray(["npc-02"]) and result.plan.routine_for("npc-02") == "helena-afternoon-ledger-review", "flag snapshot reassigns Helena")
	_check(state.snapshot() == memory_before, "director never publishes fixture memory")
	var without_catalog: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(not without_catalog.initialize(RoutineContentCatalog.new()).is_empty() and not without_catalog.update(_context(600)).errors.is_empty(), "unvalidated catalog rejected")

func _recency_expiry() -> void:
	# Production has unbounded gather history; finite-recency fixture uses the real
	# strict catalog loader, event aggregates and same director, without saves.
	var documents: Dictionary = {}
	for id: String in catalog.routine_ids(): documents[RoutineContentCatalog._asset(id)] = catalog.document_snapshot(id)
	documents[RoutineContentCatalog._asset("helena-afternoon-moonflower-records")].conditions[1].occurredWithinActiveSeconds = 10.0
	documents[RoutineContentCatalog._asset("helena-afternoon-moonflower-records")].conditions[1].maximumCount = 2
	var finite_catalog: RoutineContentCatalog = RoutineContentCatalog.new()
	var errors: PackedStringArray = finite_catalog.initialize_documents(catalog.index_snapshot(), documents, npcs)
	_check(errors.is_empty(), "validated recency fixture " + "; ".join(errors))
	if not errors.is_empty(): return
	var director: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(director.initialize(finite_catalog).is_empty(), "recency director initialized")
	var memory: NpcConversationState = state.with_events(state.events().record(NpcEventMemory.GATHER, "moonflower", null, 100.0))
	var env: EnvironmentState = _environment(840)
	var result: Dictionary = director.update(RoutineResolutionContext.capture(env, memory, 100.0))
	_check(result.plan.routine_for("npc-02") == "helena-afternoon-moonflower-records", "recent real aggregate selects")
	result = director.update(RoutineResolutionContext.capture(env, memory, 110.0))
	_check(not result.reevaluated and result.plan.routine_for("npc-02") == "helena-afternoon-moonflower-records", "recency end inclusive")
	result = director.update(RoutineResolutionContext.capture(env, memory, 110.00001))
	_check(result.reevaluated and result.changed_participants == PackedStringArray(["npc-02"]) and result.plan.routine_for("npc-02") == "helena-afternoon-archive", "recency expires without new event/player action")
	result = director.update(RoutineResolutionContext.capture(env, memory, 120.0))
	_check(not result.reevaluated, "expired decisions stable")
	memory = memory.with_events(memory.events().record(NpcEventMemory.GATHER, "moonflower", null, 120.0))
	result = director.update(RoutineResolutionContext.capture(env, memory, 120.0))
	_check(result.plan.routine_for("npc-02") == "helena-afternoon-moonflower-records", "new event refreshes recency")
	memory = memory.with_events(memory.events().record(NpcEventMemory.GATHER, "moonflower", null, 120.0))
	result = director.update(RoutineResolutionContext.capture(env, memory, 120.0))
	_check(result.reevaluated and result.plan.routine_for("npc-02") == "helena-afternoon-archive", "maximum count exceeded")

func _weather_union() -> void:
	var env: EnvironmentState = _environment(1080, "thunderstorm")
	var seed_before: int = env.weather_seed
	var before: RoutineResolutionContext = RoutineResolutionContext.capture(env, state, 100.0, ["heavy-rain"])
	var after: RoutineResolutionContext = RoutineResolutionContext.capture(env, state, 100.0)
	_check(before.event_active("heavy-rain") and after.event_active("heavy-rain"), "authored event removal cannot clear derived storm")
	_check(env.weather_seed == seed_before and env.is_heavy_rain(), "read-only capture preserves forecast")
	var ordinary: RoutineResolutionContext = RoutineResolutionContext.capture(_environment(1080, "rain"), state, 100.0)
	_check(not ordinary.event_active("heavy-rain"), "rain does not derive heavy-rain")
	var director: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(director.initialize(catalog).is_empty(), "weather director initialized")
	var result: Dictionary = director.update(before)
	var count_before: int = director.resolution_count
	result = director.update(after)
	_check(not result.reevaluated and result.changed_participants.is_empty() and director.resolution_count == count_before, "same effective storm stable after authored removal")
	result = director.update(ordinary)
	_check(result.reevaluated and result.changed_participants == PackedStringArray(["npc-01"]) and result.plan.routine_for("npc-01") == "edric-evening-fishing", "actual weather branch change reconciles")
