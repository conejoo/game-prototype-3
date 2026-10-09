extends "res://tests/routine_save_checks.gd"
## R014 full production-root stress. Setup is synthetic, never public walking.
var game: Node3D
var observations: Array[Dictionary] = []
const MAPS: Array[String] = [RoutineExecutionWorld.TOWN,RoutineExecutionWorld.HOME,RoutineExecutionWorld.INN]

func _boot() -> bool:
	if not _setup(): return false
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var ready: Array = await game.world_host.transition_finished
	_check(ready[0],"default production root startup")
	if not ready[0]: return false
	game.set_process(false)
	game._set_paused(true)
	_check(TestRunSave.configure(game,"user://saves/r014-integration.json").is_empty(),"isolated startup slot")
	return true

func _seed_complete() -> bool:
	var run: GameSession = _complete_run()
	run.current_location_id = MAPS[0]; run.current_spawn_id = "alderwake-start"
	run.environment.day_cycle_progress = (1440.0-600.0)/1440.0
	_check(game.save_repository.write(run,game.catalog).is_empty(),"complete current-schema synthetic fixture")
	var errors: PackedStringArray = await game.load_run()
	_check(errors.is_empty(),"production full-state restore "+str(errors))
	_check(game.save_run().is_empty(),"production stable pause Save")
	_bindings("seed")
	return errors.is_empty()

func _bindings(label: String) -> void:
	var owner: RoutineExecutionDirector = game.routine_execution
	var room: PrototypeLocation = game.world_host.current_location
	_check(owner._session == game.session and game.world_host.session == game.session and game.dialogue._session == game.session,"session owners "+label)
	_check(game.world_host.routine_execution == owner and game.dialogue.routine_owner == owner,"single director "+label)
	_check(TestRunRoutines.contacts_match(game),"unique actual-map contacts "+label)
	_check(game.world_host.get_child_count() == 1 and NavigationServer3D.map_get_regions(room.get_world_3d().navigation_map).size() == 1,"one room/region "+label)
	_check(game.party.members().size() == 2 and game.camera_rig.target == game.player_placeholder,"party/camera ownership "+label)
	_check(game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID],"party state bindings "+label)
	var adapter: NpcWorldAdapter = room.npc_contacts
	_check(adapter.occupancy.snapshot().bodies == adapter.targets.size()+2,"exact live occupancy "+label)
	for id: String in adapter.targets:
		var body: CharacterBody3D = adapter.targets[id].get_node("Body" if id == "npc-03" else "ContactBody")
		_check(adapter.occupancy._bodies[id].body.get_ref() == body and adapter.movers[id]._location.get_ref() == room,"exact body/mover binding "+id+"/"+label)

func _travel(map_id: String) -> bool:
	var old: WeakRef = weakref(game.world_host.current_location)
	var old_adapter: WeakRef = weakref(game.world_host.current_location.npc_contacts)
	var definition: LocationDefinition = game.catalog.get_location(map_id)
	var errors: PackedStringArray = game.world_host.request_transition(map_id,definition.spawn_ids[0])
	_check(errors.is_empty(),"actual scene replacement request "+map_id+str(errors))
	if not errors.is_empty(): return false
	var ready: Array = await game.world_host.transition_finished
	_check(ready[0],"actual scene replacement result "+map_id+str(ready[1]))
	if not ready[0]: return false
	await process_frame
	_check(old.get_ref() == null and old_adapter.get_ref() == null,"disposed former scene and occupancy owner "+map_id)
	_bindings(map_id)
	return true

func _stats() -> Dictionary:
	var nodes: Array[Node] = [game]
	var count: int = 0
	var listeners: int = 0
	while not nodes.is_empty():
		var node: Node = nodes.pop_back()
		count += 1
		for signal_row: Dictionary in node.get_signal_list(): listeners += node.get_signal_connection_list(signal_row.name).size()
		for child: Node in node.get_children(): nodes.append(child)
	for object: Object in [game.session,game.session.foraging,game.dialogue,game.quests,game.relationships,game.progression]:
		for signal_row: Dictionary in object.get_signal_list(): listeners += object.get_signal_connection_list(signal_row.name).size()
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	return {"nodes":count,"listeners":listeners,"wrappers":adapter.targets.size(),"movers":adapter.movers.size(),"presenters":adapter.presenters.size(),"speech_owners":adapter.routine_presentations.size(),"bodies":adapter.occupancy.snapshot().bodies,"reservations":adapter.occupancy.snapshot().reservations.size(),"executors":game.routine_execution._actors.size(),"positions":game.routine_execution._positions.size(),"rooms":game.world_host.get_child_count(),"regions":NavigationServer3D.map_get_regions(game.get_world_3d().navigation_map).size()}

func _working_set() -> int:
	var output: Array = []
	var code: int = OS.execute("powershell.exe",PackedStringArray(["-NoProfile","-NonInteractive","-Command","(Get-Process -Id "+str(OS.get_process_id())+").WorkingSet64"]),output,true)
	_check(code == 0 and not output.is_empty() and str(output[0]).strip_edges().is_valid_int(),"owned PID working set probe")
	return int(str(output[0]).strip_edges()) if code == 0 and not output.is_empty() else 0

func _settle() -> void: await create_timer(2.0,true).timeout

func _rollback() -> void:
	var run: GameSession = game.session
	var room: PrototypeLocation = game.world_host.current_location
	var durable: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(run))
	var execution: Dictionary = game.routine_execution.snapshot()
	var definition: LocationDefinition = game.catalog.get_location(MAPS[1])
	var path: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/r007/blocked_home.tscn"
	var errors: PackedStringArray = game.world_host.request_transition(MAPS[1],definition.spawn_ids[0])
	_check(errors.is_empty(),"unsafe physical travel reaches staging "+str(errors))
	if errors.is_empty(): _check(not (await game.world_host.transition_finished)[0],"unsafe physical travel refuses")
	_check(game.session == run and game.world_host.current_location == room and game.routine_execution.snapshot() == execution and TestRunSnapshot.exact_json(SaveCodec.snapshot(run)) == durable,"failed travel preserves complete committed owners/cursors/facts")
	_bindings("failed travel")
	var bad: Dictionary = SaveCodec.snapshot(run)
	bad.location_id = MAPS[1]; bad.spawn_id = definition.spawn_ids[0]
	_write(game.save_repository.path,TestRunSnapshot.exact_json(bad))
	_check(not (await game.load_run()).is_empty(),"current-schema unsafe candidate Load refuses")
	_check(game.session == run and game.world_host.current_location == room and game.routine_execution.snapshot() == execution and TestRunSnapshot.exact_json(SaveCodec.snapshot(run)) == durable,"failed Load publishes no staged state")
	_bindings("failed Load")
	definition.scene_path = path
	_write(game.save_repository.path,durable); _write(game.save_repository.path+".bak",durable)
	# Incompatible primary refuses even when backup is valid.
	for version: int in [7,9]:
		bad = SaveCodec.snapshot(run); bad.schema_version = version
		_write(game.save_repository.path,TestRunSnapshot.exact_json(bad))
		_check(not (await game.load_run()).is_empty() and game.session == run and game.world_host.current_location == room,"incompatible Load inert "+str(version))
	_write(game.save_repository.path,"{broken")
	_check((await game.load_run()).is_empty(),"malformed primary recovers valid backup")
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == durable,"backup exact durable state")
	_check(FileAccess.get_file_as_string(game.save_repository.path) == "{broken","recovery leaves corrupt primary unchanged")
	_bindings("backup recovery")
	_write(game.save_repository.path,durable)
	_check(game.save_run().is_empty(),"repaired manual save")
	observations.append({"probe":"physical failed travel/current-schema failed Load/incompatible refusal/backup recovery","execution":game.routine_execution.snapshot()})

func _retry() -> void:
	var before: Dictionary = SaveCodec.snapshot(game.session)
	game.player_placeholder.receive_damage(1000)
	await game.retry_encounter()
	game._set_paused(true)
	_check(SaveCodec.snapshot(game.session) == before,"death/retry retains all healed durable facts/events/suppression/social/items/quest effects/clock")
	_bindings("retry")

func _companion_dialogue() -> void:
	var station: PrototypeInteractable
	for target: PrototypeInteractable in game.world_host.current_location.interactables():
		if target.dialogue_id == "prototype-companion-greeting": station = target; break
	_check(station != null,"existing public companion station retained")
	if station == null: return
	var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	game._set_paused(false)
	var result: NpcDialogueService.Result = game.dialogue.begin_graph(game.catalog.get_dialogue(station.dialogue_id),station.instance_id)
	_check(result.ok and game.dialogue.active(),"existing companion graph opens under default routine activation")
	game._present_dialogue(result)
	_check(not game.companion_ai.enabled and not game.player_placeholder.controls_enabled and game.routine_execution._lease == null,"prototype companion dialogue holds root without acquiring villager lease")
	game._cancel_dialogue(); game._set_paused(true)
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before,"opening/canceling prototype companion preserves all durable state")
	_check(not game.dialogue.begin("npc-01","stale-r014-contact").ok and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before,"villager stale instance still rejected before publication")

func _cycles() -> void:
	var baselines: Dictionary = {}
	# Warm every actual room/art resource before equal-settle baseline sampling.
	for map_id: String in [MAPS[1],MAPS[2],MAPS[0]]:
		if not await _travel(map_id): return
		await _settle(); baselines[map_id] = _stats()
	var memory_before: int = _working_set()
	for cycle: int in range(10):
		for map_id: String in [MAPS[1],MAPS[0],MAPS[2],MAPS[0]]:
			if not await _travel(map_id): return
		await _settle()
		_check(_stats() == baselines[MAPS[0]],"ten-cycle exact owned nodes/listeners/wrappers/reservations "+str(cycle))
		observations.append({"cycle":cycle+1,"ownership":_stats(),"object_count":Performance.get_monitor(Performance.OBJECT_COUNT),"memory_static":OS.get_static_memory_usage()})
	# Recheck room-specific ownership after all ten cycles, not only town.
	for map_id: String in [MAPS[1],MAPS[2],MAPS[0]]:
		if not await _travel(map_id): return
		await _settle(); _check(_stats() == baselines[map_id],"no per-room owner/listener/reservation growth "+map_id)
	var memory_after: int = _working_set()
	_check(memory_before > 0 and memory_after-memory_before <= 64*1024*1024,"ten-cycle working-set growth <=64MiB")
	observations.append({"case":"ten town/home/town/inn/town cycles, 2s equal settling","baseline":baselines,"working_set_before":memory_before,"working_set_after":memory_after,"growth_bytes":memory_after-memory_before})

func _done(filename: String) -> void:
	_check(TestRunEvidence.write_json(filename,{"task":"R014","assertions":assertions,"failures":failures,"pid":OS.get_process_id(),"observations":observations,"provenance":"synthetic complete current-schema state, scripted physical scene replacement/rollback/retry; no ordinary journey/natural day/native claim"}),"evidence")
	paused = false
	if game != null: game.queue_free()
	await process_frame
	for error: String in failures: push_error(error)
	print("R014 ",filename," assertions=",assertions," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _run() -> void:
	if await _boot() and await _seed_complete():
		_selector_fast_path()
		_companion_dialogue()
		await _rollback()
		await _retry()
		await _cycles()
	await _done("routine-lifecycle.json")

func _selector_fast_path() -> void:
	var catalog: RoutineContentCatalog = game.routine_execution._catalog
	var fast: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	var sampled: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
	_check(fast.initialize(catalog).is_empty() and sampled.initialize(catalog).is_empty(),"paired fast/sample directors")
	var run: GameSession = _fresh()
	run.elapsed_play_seconds = 100
	for minute: int in [600,601,719,720,840,1020,1200,1320,0,599]:
		run.environment.day_cycle_progress = fposmod(minute-EnvironmentClock.START_MINUTES,1440.0)/1440.0
		_compare_selectors(fast,sampled,run,"clock "+str(minute))
	run.environment.day_cycle_progress = (840.0-600.0)/1440.0
	var person: ConversationMemory = run.conversations.memory("npc-01")
	person.learned_fact_ids.append("npc-01-river-fishing")
	run.conversations = run.conversations.with_person(person)
	_compare_selectors(fast,sampled,run,"learned fact")
	person = run.conversations.memory("npc-02"); person.flags.append("npc-02-archive-lead-shared")
	run.conversations = run.conversations.with_person(person)
	_compare_selectors(fast,sampled,run,"flag")
	run.conversations = run.conversations.with_events(run.conversations.events().record(NpcEventMemory.GATHER,"moonflower",null,100))
	_compare_selectors(fast,sampled,run,"real aggregate")
	run.routines = run.routines.with_event("heavy-rain",true)
	_compare_selectors(fast,sampled,run,"authored event")
	run.routines = run.routines.with_suppression("edric-afternoon-river-notes")
	_compare_selectors(fast,sampled,run,"suppression")
	run.environment.day_index += 1; run.routines = run.routines.without_suppression()
	_compare_selectors(fast,sampled,run,"authoritative day rollover")
	# Finite recency expires with no new input on the assignment-only path too.
	var documents: Dictionary = {}
	for id: String in catalog.routine_ids(): documents[RoutineContentCatalog._asset(id)] = catalog.document_snapshot(id)
	documents[RoutineContentCatalog._asset("helena-afternoon-moonflower-records")].conditions[1].occurredWithinActiveSeconds = 10.0
	var finite: RoutineContentCatalog = RoutineContentCatalog.new()
	_check(finite.initialize_documents(catalog.index_snapshot(),documents,game.npc_catalog).is_empty(),"finite recency catalog")
	fast = RoutineAssignmentDirector.new(); sampled = RoutineAssignmentDirector.new()
	_check(fast.initialize(finite).is_empty() and sampled.initialize(finite).is_empty(),"finite paired directors")
	person = run.conversations.memory("npc-02"); person.flags.clear(); run.conversations = run.conversations.with_person(person)
	for seconds: float in [100.0,110.0,110.00001,120.0]:
		run.elapsed_play_seconds = seconds
		_compare_selectors(fast,sampled,run,"finite recency "+str(seconds))

func _compare_selectors(fast: RoutineAssignmentDirector, sampled: RoutineAssignmentDirector, run: GameSession, label: String) -> void:
	var context: RoutineResolutionContext = RoutineResolutionContext.from_session(run)
	var previous: RoutineAssignmentPlan = fast.current_plan
	var actual: Dictionary = fast.update(context,false)
	var oracle: Dictionary = sampled.update(context)
	_check(actual.errors.is_empty() and oracle.errors.is_empty(),"valid paired sample "+label)
	_check(actual.plan.assignments() == oracle.plan.assignments() and actual.plan.rejections() == oracle.plan.rejections() and actual.changed_participants == oracle.changed_participants,"fast assignment/diagnostics/change oracle "+label)
	_check(actual.reevaluated or actual.plan == previous,"unchanged fast plan retained "+label)
