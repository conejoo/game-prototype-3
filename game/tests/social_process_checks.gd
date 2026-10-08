extends SceneTree
## G003 independent OS processes, production root/repository, synthetic social state.
var failures: PackedStringArray = []
var assertions: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var writing: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = ContentManifest.new(); manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-g003-unsafe"; unsafe.display_name = "G003 fixture"
	unsafe.prototype_fixture = true; unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = ["unsafe-no-floor","unsafe-blocked"]; manifest.definitions.append(unsafe); game.content_manifest = manifest
	root.add_child(game); await game.world_host.transition_finished
	game._set_paused(true)
	var pair: Dictionary = SocialSaveFixture.setup()
	game.npc_catalog = pair.catalog
	failures.append_array(TestRunSave.configure(game,"user://saves/g003-process.json"))
	game.save_repository.npc_catalog = pair.catalog
	var repo: SaveRepository = game.save_repository
	var oracle: String = repo.path + ".oracle"
	if writing:
		pair = SocialSaveFixture.complete()
		failures.append_array(repo.write(pair.session,game.catalog))
		failures.append_array(await game.load_run())
		failures.append_array(game.save_run())
		_write(oracle,JSON.stringify(SaveCodec.snapshot(game.session),"",true,true))
		_write(repo.path + ".pid",str(OS.get_process_id()))
	else:
		_check(game.session.conversations.events().snapshot().last_sequence == 0,"fresh reader no inherited state/autoload")
		_check(FileAccess.get_file_as_string(repo.path + ".pid").to_int() != OS.get_process_id(),"different writer/reader PID")
		var previous: GameSession = game.session
		failures.append_array(await game.load_run())
		var expected: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(oracle),game.catalog,pair.catalog)
		_check(expected.session != null,"exact binary64 oracle readable")
		var before: Dictionary = SaveCodec.snapshot(game.session)
		if expected.session != null: _check(before == SaveCodec.snapshot(expected.session),"every social/inventory/quest/trust/upgrade/environment/timer field equal")
		_check(game.session != previous and game.dialogue._session == game.session and not game.dialogue.active(),"fresh inactive rebound conversation owner")
		_check(game.party.members().size() == 2 and game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID],"old actor/party bindings")
		_check(game.player_placeholder.global_position.distance_to(Vector3(0,0,-2.5)) < 0.01,"safe arrival anchor")
		var raw: String = FileAccess.get_file_as_string(repo.path)
		failures.append_array(game.save_run())
		_check(FileAccess.get_file_as_string(repo.path) == raw and SaveCodec.snapshot(game.session) == before,"paused re-save exact bytes/state")
		for id: String in ["npc-01","npc-03"]:
			_check(game.dialogue.begin(id,"fixture-reopen").ok,"restore reopen " + id)
			game.dialogue.cancel()
		_check(SaveCodec.snapshot(game.session) == before,"reopen cannot duplicate milestone/gift/rewards/facts")
		var live: GameSession = game.session
		var room: PrototypeLocation = game.world_host.current_location
		var foot: Vector3 = game.player_placeholder.global_position
		for spawn: String in unsafe.spawn_ids:
			var bad: Dictionary = before.duplicate(true); bad.location_id = unsafe.stable_id; bad.spawn_id = spawn
			_write(repo.path,JSON.stringify(bad,"",true,true))
			_check(not (await game.load_run()).is_empty(),"unsafe staged load rejects " + spawn)
			_check(game.session == live and game.world_host.current_location == room and game.player_placeholder.global_position == foot and game.dialogue._session == live and SaveCodec.snapshot(live) == before,"travel/load rollback preserves social and old state " + spawn)
		_write(repo.path,raw)
		_check(DirAccess.make_dir_absolute(repo.path + ".tmp") == OK,"temporary obstruction")
		_check(not game.save_run().is_empty() and FileAccess.get_file_as_string(repo.path) == raw and FileAccess.get_file_as_string(repo.path + ".bak") == raw,"root failed write files preserved")
		_check(DirAccess.remove_absolute(repo.path + ".tmp") == OK,"owned obstruction removed")
		var malformed: Dictionary = before.duplicate(true); malformed.conversations.people["npc-01"].affinity += 1
		_write(repo.path,JSON.stringify(malformed,"",true,true)); _write(repo.path + ".bak","broken")
		_check(not (await game.load_run()).is_empty() and game.session == live and SaveCodec.snapshot(live) == before,"corrupt social load never swaps live state")
		_write(repo.path + ".bak",raw); _write(repo.path,"broken")
		_check((await game.load_run()).is_empty() and SaveCodec.snapshot(game.session) == before,"root backup exact recovery")
		_check(FileAccess.get_file_as_string(repo.path) == "broken" and FileAccess.get_file_as_string(repo.path + ".bak") == raw,"backup read does not rewrite files")
	_check(TestRunEvidence.write_json("social-process-write.json" if writing else "social-process-read.json",{"pid":OS.get_process_id(),"phase":"write" if writing else "read","assertions":assertions,"failures":failures,"snapshot":SaveCodec.snapshot(game.session),"proof":"synthetic social setup, production independent-process manual Save/Load"}),"report")
	game._set_paused(false); game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("G003 social process ","write" if writing else "read",": ","PASS" if failures.is_empty() else "FAILED"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
func _write(path: String, raw: String) -> void:
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	_check(file != null,"fixture IO")
	if file != null: file.store_string(raw); file.close()
func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
