extends SceneTree
## Independent processes, real root manual Save/Load, full exact schema7 oracle.
var failures: PackedStringArray = []
var assertions: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	failures.append_array(TestRunSave.configure(game, "user://saves/n004-process.json"))
	game._set_paused(true)
	var oracle_path: String = game.save_repository.path + ".oracle"
	if writing:
		var run: GameSession = ForagingSaveFixture.make(game.catalog, "tollworks")
		failures.append_array(NpcSaveFixture.populate(run, game.npc_catalog))
		# Stage via ordinary detached load/placement validation, then manual save.
		failures.append_array(game.save_repository.write(run, game.catalog))
		failures.append_array(await game.load_run())
		failures.append_array(game.save_run())
		var file: FileAccess = FileAccess.open(oracle_path, FileAccess.WRITE)
		_check(file != null, "oracle created")
		if file != null:
			file.store_string(JSON.stringify(SaveCodec.snapshot(game.session), "", true, true)); file.close()
	else:
		_check(game.session.conversations.events().snapshot().last_sequence == 0, "reader fresh, no autoload")
		var previous: GameSession = game.session
		failures.append_array(await game.load_run())
		var expected: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(oracle_path), game.catalog)
		_check(expected.session != null, "exact persisted oracle readable")
		if expected.session != null:
			_check(SaveCodec.snapshot(game.session) == SaveCodec.snapshot(expected.session), "every durable field exactly restored")
		_check(game.session != previous and game.dialogue._session == game.session and not game.dialogue.active(), "fresh bound cursor owner")
		_check(game.party.members().size() == 2 and game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID], "party bindings preserved")
		_check(game.player_placeholder.global_position.distance_to(Vector3(0,0,-2.5)) < 0.01, "arrival restoration")
		var events: NpcEventMemory = game.session.conversations.events()
		_check(game.dialogue.record_event(NpcEventMemory.AREA, "woods", null).ok and game.session.conversations.events().count(NpcEventMemory.AREA, "woods", null) == events.count(NpcEventMemory.AREA, "woods", null) + 1, "allowlist/latest timestamp rebuilt")
		_check(previous.conversations.events().snapshot().last_sequence == 0, "old session remains detached")
	_check(TestRunEvidence.write_json("npc-process-write.json" if writing else "npc-process-read.json", {"phase":"write" if writing else "read", "pid":OS.get_process_id(), "assertions":assertions, "failures":failures, "snapshot":SaveCodec.snapshot(game.session), "proof":"synthetic fixture / independent-process production Save-Load"}), "report")
	game._set_paused(false); game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("N004 process ", "write" if writing else "read", ": ", "PASS" if failures.is_empty() else "FAILED", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)
func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
