extends "res://tests/routine_save_checks.gd"
## R004 separate OS writer/reader with exact full typed oracle, manual root Save/Load.
func _run() -> void:
	if not _setup(): _finish("routine-process-failed.json"); return
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game); await game.world_host.transition_finished
	_check(TestRunSave.configure(game,"user://saves/r004-process.json").is_empty(),"process-isolated startup repository")
	game._set_paused(true)
	var oracle_path: String = game.save_repository.path+".oracle"
	var fresh: GameSession = game.session
	var fresh_command: RoutineFactCommand = RoutineFactCommand.set_event(fresh,"heavy-rain",true)
	if writing:
		var run: GameSession = _complete_run()
		_check(game.save_repository.write(run,game.catalog).is_empty(),"writer stages complete synthetic state")
		_check((await game.load_run()).is_empty() and game.save_run().is_empty(),"writer production Load/Save")
		_write(oracle_path,JSON.stringify(TestRunSnapshot.oracle(game.session),"",true,true))
	else:
		_check(game.session.routines.authored_events().is_empty() and game.session.routines.suppressed_ids().is_empty() and game.session.conversations.events().snapshot().last_sequence == 0,"new process starts fresh without autoload")
		_check((await game.load_run()).is_empty(),"reader production manual Load")
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(oracle_path))
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		_check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"distinct PID full typed snapshot and exact forecast")
		_check(not game.session.apply_routine_command(fresh_command).is_empty() and fresh.routines.authored_events().is_empty(),"stale pre-load owner command inert")
		_check(game.session.routines.authored_events() == RoutineFacts.EVENT_IDS and game.session.routines.suppressed_ids().size() == 3,"nonempty routine facts survive process boundary")
		_check(game.session == game.world_host.session and game.dialogue._session == game.session and game.party.members().size() == 2 and game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID],"all actual owners rebound without duplicate party")
		_check(game.player_placeholder.global_position.distance_to(Vector3(0,0,-2.5)) < 0.01,"actual safe arrival")
		_check(game.save_run().is_empty(),"reader manual re-save")
		for suffix: String in ["", ".bak"]:
			var bytes: String = FileAccess.get_file_as_string(game.save_repository.path+suffix)
			var decoded: SaveCodec.DecodeResult = SaveCodec.decode(bytes,game.catalog,game.npc_catalog)
			_check(decoded.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == oracle.snapshot_json,"primary/backup full exact durable oracle " + suffix)
		var before: Dictionary = SaveCodec.snapshot(game.session)
		var primary: String = FileAccess.get_file_as_string(game.save_repository.path)
		var backup: String = FileAccess.get_file_as_string(game.save_repository.path+".bak")
		_check(game.session.advance(0.0).is_empty() and SaveCodec.snapshot(game.session) == before,"same-day resume preserves suppression")
		_check(game.session.advance(600.0*(1.0-game.session.environment.day_cycle_progress)).is_empty() and game.session.routines.suppressed_ids().is_empty() and game.session.routines.authored_events() == RoutineFacts.EVENT_IDS,"actual clock rollover after restart expires only suppression")
		_check(game.session.apply_routine_command(RoutineFactCommand.suppress_for_day(game.session,"vale-breakfast")).is_empty(),"restored owner bound fresh day command")
		_check(FileAccess.get_file_as_string(game.save_repository.path) == primary and FileAccess.get_file_as_string(game.save_repository.path+".bak") == backup,"clock/commands never autosave primary or backup")
	_check(TestRunEvidence.write_json("routine-process-write.json" if writing else "routine-process-read.json",{"phase":"write" if writing else "read","pid":OS.get_process_id(),"assertions":assertions,"failures":failures,"snapshot":SaveCodec.snapshot(game.session),"proof":"synthetic prior/social/routine facts; separate-process production manual Save/Load"}),"report")
	game._set_paused(false); game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R004 process ","write" if writing else "read",": ","PASS" if failures.is_empty() else "FAILED"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
