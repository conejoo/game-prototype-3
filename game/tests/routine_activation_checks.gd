extends SceneTree
## R013 default production root. Matrix seeks/seeded weather/memory and short
## timers are synthetic; all movement uses real collision and unchanged stations.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var baseline: Dictionary
var coverage: Dictionary = {}
var observations: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()
func check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate(); root.add_child(game)
	check((await game.world_host.transition_finished)[0],"default startup")
	game.set_process(false)
	check(game.routine_execution != null and game.dialogue.routine_owner == game.routine_execution and game.world_host.routine_execution == game.routine_execution,"one default production owner, no injected activation")
	check(TestRunRoutines.contacts_match(game),"default scheduled contacts")
	check(game.world_host.current_location.npc_contacts.targets.size() == 6 and not game.world_host.current_location.npc_contacts.targets.has("npc-02") and not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"fresh 10AM Helena at home/Della indoors, no stale town duplicates")
	check(PeopleSnapshot.from_state(game.session.conversations,game.npc_catalog).people.is_empty(),"unmet People empty despite active routines")
	check(TestRunSave.configure(game,"user://saves/r013-activation.json").is_empty(),"isolated slot")
	baseline = SaveCodec.snapshot(game.session)
	await _matrix()
	for row: Array in [[1020,RoutineExecutionWorld.TOWN,"edric-evening-fishing"],[360,RoutineExecutionWorld.TOWN,"ivo-docks-day"],[1320,RoutineExecutionWorld.TOWN,"ivo-docks-evening"],[720,RoutineExecutionWorld.TOWN,"vale-midday-briefing"],[1200,RoutineExecutionWorld.TOWN,"vale-evening-home"],[1320,RoutineExecutionWorld.HOME,"vale-overnight-home"],[360,RoutineExecutionWorld.HOME,"vale-breakfast"],[480,RoutineExecutionWorld.HOME,"vale-morning-work"]]:
		if not await reset(row[0],row[1]): break
		await _physical(row[2])
		if failures.size() > 12: break
	check(coverage.size() == 25,"exact 25-row coverage")
	check(TestRunEvidence.write_json("routine-activation-coverage.json",{"task":"R013","assertions":assertions,"failures":failures,"coverage":coverage,"observations":observations,"provenance":"default production root/owner; synthetic clock/conditions/seeded weather/current-schema restore and shortened wait/action/speech timers; full physical selected routes including Tess, Ivo and Vale; ordinary public controls separately rendered"}),"coverage report")
	paused = false; game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R013 activation %d assertions %d routines %d failures" % [assertions,coverage.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func reset(minute: float, map_id: String, vector: Dictionary = {}) -> bool:
	game.dialogue.cancel(); game._set_paused(true)
	var decoded: SaveCodec.DecodeResult = SaveCodec.validate(baseline,game.catalog,game.npc_catalog)
	check(decoded.session != null,"strict baseline decode")
	if decoded.session == null: return false
	var run: GameSession = decoded.session
	run.environment.day_cycle_progress = fposmod((minute-600)/1440,1)
	run.current_location_id = map_id; run.current_spawn_id = game.catalog.get_location(map_id).spawn_ids[0]
	for count: int in int(vector.get("gather_count",0)):
		run.conversations = run.conversations.with_events(run.conversations.events().record(NpcEventMemory.GATHER,"moonflower",null,run.elapsed_play_seconds))
	if vector.has("authored_events"):
		var facts: RoutineFacts.Result = RoutineFacts.restore({"authored_event_ids":vector.authored_events,"suppressed_routine_ids":[]})
		check(facts.errors.is_empty(),"authored fixture facts")
		if facts.errors.is_empty(): run.routines = facts.state
	var weather_id: String = vector.get("weather","nonstorm")
	if weather_id in ["rain","thunderstorm"]: run.environment.day_index = 1
	var weather: WeatherConditionService = WeatherConditionService.new(); weather.bind_environment(run.environment)
	for seed: int in 1000:
		run.environment.weather_seed = seed
		if weather.condition_id() == ("rainy" if weather_id == "rain" else weather_id) or (weather_id == "nonstorm" and not weather.has_condition("heavy-rain")): break
	var write_errors: PackedStringArray = game.save_repository.write(run,game.catalog)
	check(write_errors.is_empty(),"synthetic current-schema stage "+str(write_errors))
	if not write_errors.is_empty(): return false
	var errors: PackedStringArray = await game.load_run()
	check(errors.is_empty(),"default owner restore "+str(errors))
	if not errors.is_empty(): return false
	game._set_paused(false); game.set_process(false)
	game.player_placeholder.set_physics_process(false); game.companion.set_physics_process(false); game.companion_ai.set_physics_process(false)
	game.world_host.current_location.npc_contacts.set_physics_process(false)
	game.player_placeholder.global_position = Vector3(-15,0,0) if map_id == RoutineExecutionWorld.TOWN else Vector3(2,0,-8.5) if map_id == RoutineExecutionWorld.HOME else Vector3(3,0,-5)
	game.companion.global_position = game.player_placeholder.global_position+Vector3.RIGHT*2
	game._sync_npc_visuals(); await physics_frame
	# Pinned fact/flag vectors are explicitly unsaved synthetic inputs. Edric's
	# fishing fact has no source disclosure node and must not be forged into a save.
	for field: String in ["facts","flags"]:
		for id: String in vector.get(field,{}):
			var person: ConversationMemory = game.session.conversations.memory(id)
			if field == "facts": person.learned_fact_ids = PackedStringArray(vector[field][id])
			else: person.flags = PackedStringArray(vector[field][id])
			game.session.conversations = game.session.conversations.with_person(person)
	if vector.has("facts") or vector.has("flags"):
		var context: RoutineResolutionContext = RoutineResolutionContext.from_session(game.session)
		check(game.routine_execution.apply_plan(RoutineResolver.resolve(RoutineResolver.definitions(game.routine_execution._catalog),context)),"unsaved synthetic fact/flag vector")
	check(TestRunRoutines.contacts_match(game),"restored current-map ownership")
	return true

func _matrix() -> void:
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/vectors.json"))
	for vector: Dictionary in vectors.selection_cases:
		if not await reset(RoutineDefinition.minute(vector.time),RoutineExecutionWorld.TOWN,vector): return
		var owner: RoutineExecutionDirector = game.routine_execution
		var vale: PackedStringArray = []
		for id: String in ["npc-01","npc-02"]:
			var selected: String = owner.actor(id).routine.id
			if selected not in vale: vale.append(selected)
		vale.sort(); var expected: PackedStringArray = PackedStringArray(vector.vale); expected.sort()
		check(vale == expected,"actual default-owner pinned branch "+vector.id)
		for id: String in NpcRegistry.ENABLED:
			var actor: RoutineExecutor = owner.actor(id)
			var routine: RoutineDefinition = actor.routine
			if not coverage.has(routine.id): coverage[routine.id] = {"selectors":[],"participants":{},"conditions":routine.snapshot().conditions,"dialogue":routine.snapshot().interactionPolicy}
			coverage[routine.id].selectors.append(vector.id)
			var steps: Array[Dictionary] = []
			for step: RoutineDefinition.Step in routine.steps(id):
				var row: Dictionary = {"id":step.id,"kind":step.kind,"map":step.map_id,"anchor":step.anchor_id,"action":step.action_id,"art":RoutinePresentation.CLIPS.get(id,{}).get(step.action_id,"exported idle"),"skin":NpcRegistry.VISUAL_ASSETS[id]}
				if step.kind == RoutineDefinition.StepKind.MOVE:
					check(not owner.world.anchor(step.map_id,step.anchor_id).is_empty(),"bound live anchor "+routine.id+"/"+step.id)
					check(game.catalog.get_location(step.map_id) != null,"delivered actual map "+routine.id+"/"+step.id)
				check(ResourceLoader.exists(row.skin),"portable production art "+routine.id+"/"+step.id)
				steps.append(row)
			coverage[routine.id].participants[id] = steps
		observations.append({"vector":vector.id,"snapshot":owner.snapshot(),"weather":game.session.environment.weather_seed})

func _physical(routine_id: String) -> void:
	var owner: RoutineExecutionDirector = game.routine_execution
	var participants: PackedStringArray = []
	for id: String in NpcRegistry.ENABLED:
		if owner.actor(id).routine.id == routine_id: participants.append(id)
	check(not participants.is_empty(),"physical selected "+routine_id)
	var seen: Dictionary = {}
	for id: String in participants:
		var initial: RoutineExecutor = owner.actor(id)
		for index: int in range(initial.index): seen[id+"/"+initial.steps[index].id] = {"proof":"initial zero-duration qualified reconstruction","index":index}
	print("R013_PHYSICAL_START ",routine_id)
	var previous: Dictionary = {}
	var player_map: String = game.session.current_location_id
	var player_foot: Vector3 = game.player_placeholder.global_position
	var camera_target: Node3D = game.camera_rig.target
	for frame: int in range(1800):
		var done: bool = true
		for id: String in participants:
			var actor: RoutineExecutor = owner.actor(id)
			var step: RoutineDefinition.Step = actor.current_step()
			if step != null:
				seen[id+"/"+step.id] = actor.snapshot()
				if step.kind != RoutineDefinition.StepKind.MOVE and actor.state != RoutineExecutor.State.READY: actor.remaining = minf(actor.remaining,.1)
			if actor.state != RoutineExecutor.State.COMPLETED: done = false
			if actor.state == RoutineExecutor.State.FAILED:
				check(false,"physical failure "+routine_id+" "+str(actor.snapshot())); done = true; break
		if done: break
		owner.tick(.1)
		game.world_host.current_location.npc_contacts._physics_process(.1)
		await physics_frame
		for id: String in participants:
			var actor: RoutineExecutor = owner.actor(id)
			if previous.has(id) and previous[id].map == actor.map_id and actor.map_id == player_map:
				check(previous[id].foot.distance_to(actor.foot) <= .2001,"full physical continuous 2m/s "+routine_id)
			previous[id] = {"map":actor.map_id,"foot":actor.foot}
	for id: String in participants:
		var actor: RoutineExecutor = owner.actor(id)
		check(actor.state == RoutineExecutor.State.COMPLETED,"full selected plan completes "+routine_id+"/"+id+" "+str(actor.snapshot()))
		for step: RoutineDefinition.Step in actor.steps: check(seen.has(id+"/"+step.id),"physical plan visits authored step "+routine_id+"/"+step.id)
	check(player_map == game.session.current_location_id and player_foot == game.player_placeholder.global_position and camera_target == game.camera_rig.target and TestRunRoutines.contacts_match(game),"NPC routes preserve player/camera/party/unique actual map")
	observations.append({"physical":routine_id,"steps":seen,"final":owner.snapshot(),"transfers":owner.transfers})
	print("R013_PHYSICAL_END ",routine_id," failures=",failures.size())
