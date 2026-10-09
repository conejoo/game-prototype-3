extends "res://tests/routine_lifecycle_checks.gd"
## R014 distinct OS writer/reader using default active root, never injected director.
func _run() -> void:
	if not await _boot(): await _done("integration-start-failed.json"); return
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	var oracle_path: String = game.save_repository.path+".oracle"
	var fresh: GameSession = game.session
	var stale: RoutineFactCommand = RoutineFactCommand.set_event(fresh,"harbor-festival",true)
	if writing:
		if not await _seed_complete(): await _done("integration-seed-failed.json"); return
		_write(oracle_path,JSON.stringify(TestRunSnapshot.oracle(game.session),"",true,true))
	else:
		_check(game.session.routines.authored_events().is_empty() and game.session.conversations.events().snapshot().last_sequence == 0,"new PID starts fresh without autoload")
		_check((await game.load_run()).is_empty(),"reader production manual Load")
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(oracle_path))
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		_check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"distinct PID exact whole typed durable/forecast oracle")
		_check(not game.session.apply_routine_command(stale).is_empty() and fresh.routines.authored_events().is_empty(),"foreign pre-load authority inert")
		_bindings("reader")
		_check(game.save_run().is_empty(),"reader exact re-save")
		for suffix: String in ["",".bak"]:
			var raw: String = FileAccess.get_file_as_string(game.save_repository.path+suffix)
			var decoded: SaveCodec.DecodeResult = SaveCodec.decode(raw,game.catalog,game.npc_catalog)
			_check(decoded.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == oracle.snapshot_json,"primary/backup full exact state "+suffix)
			var data: Dictionary = JSON.parse_string(raw)
			_check(data.routine_facts.size() == 2 and data.routine_facts.has("authored_event_ids") and data.routine_facts.has("suppressed_routine_ids"),"only durable routine facts serialized "+suffix)
			for key: String in ["routine_execution","positions","cursors","paths","leases","speech","animation","occupancy"]: _check(not data.has(key),"no transient JSON "+key+suffix)
	var durable: Dictionary = SaveCodec.snapshot(game.session)
	var protected: Dictionary = {"events":durable.conversations,"items":durable.inventory,"effects":durable.completed_effect_ids,"quests":durable.quests,"facts":durable.routine_facts,"environment":durable.environment}
	# Loaded town, real home rest and single indoor Della reconstructed from same
	# durable fixture. Live cursor work cannot replay historical social/recovery effects.
	for map_id: String in [MAPS[1],MAPS[0],MAPS[2],MAPS[0]]:
		if not await _travel(map_id): break
		game.world_host.current_location.npc_contacts.set_physics_process(false)
		game.player_placeholder.set_physics_process(false); game.companion.set_physics_process(false); game.companion_ai.set_physics_process(false)
		game.player_placeholder.global_position = Vector3(-15,0,0) if map_id == MAPS[0] else Vector3(2,0,-8.5)
		game.companion.global_position = Vector3(-14,0,0) if map_id == MAPS[0] else Vector3(5,0,-8.5)
		game._set_paused(false); game._sync_npc_visuals()
		for frame: int in range(30):
			game.routine_execution.tick(.016)
			game.world_host.current_location.npc_contacts._physics_process(.016)
			await physics_frame
		game._set_paused(true)
		var after: Dictionary = SaveCodec.snapshot(game.session)
		_check({"events":after.conversations,"items":after.inventory,"effects":after.completed_effect_ids,"quests":after.quests,"facts":after.routine_facts,"environment":after.environment} == protected,"reconstructed live execution no duplicate events/gifts/items/quests/clock "+map_id)
	observations.append({"phase":"write" if writing else "read","writer_oracle":oracle_path,"execution":game.routine_execution.snapshot(),"snapshot":SaveCodec.snapshot(game.session)})
	await _done("routine-integration-write.json" if writing else "routine-integration-read.json")
