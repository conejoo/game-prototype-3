extends SceneTree
## Detached rules, real filesystem failures/recovery, and root load transactions.

var failures: Array[String] = []
var directory: String
var catalog: ContentCatalog = ContentCatalog.new()
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	directory = "user://saves/p005-checks-" + str(OS.get_process_id()) + "-" + str(Time.get_ticks_usec())
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Cannot create isolated test directory")
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "Catalog prerequisite failed")
	var run: GameSession = GameSession.new()
	_check(run.initialize(catalog, "prototype-tollworks", "tollworks-from-alderwake", "prototype-hero").is_empty(), "Run prerequisite failed")
	run.actors[GameSession.PLAYER_INSTANCE_ID].health = 37 # Labeled test setup, not combat.
	run.elapsed_play_seconds = 42.5
	var data: Dictionary = SaveCodec.snapshot(run)
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(data), catalog)
	_check(decoded.errors.is_empty() and decoded.session != run, "Round trip did not create detached candidate")
	_check(decoded.session.actors[GameSession.PLAYER_INSTANCE_ID].health == 37 and decoded.session.elapsed_play_seconds == 42.5, "Round trip lost actor/time")
	decoded.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 3
	_check(run.actors[GameSession.PLAYER_INSTANCE_ID].health == 37 and catalog.get_actor("prototype-hero").max_health == 100, "Decoded state shares mutable health/definition")
	for invalid: Variant in [null, [], true, "string"]:
		_check(SaveCodec.validate(invalid, catalog).session == null, "Non-object envelope accepted")
	for key: String in ["schema_version", "content_version", "elapsed_play_seconds", "party_member_ids", "actors", "location_id", "spawn_id", "player_instance_id"]:
		var broken: Dictionary = data.duplicate(true)
		broken.erase(key)
		_reject(broken, "missing " + key)
	for pair: Array in [["schema_version", SaveCodec.SCHEMA_VERSION + 1], ["content_version", 2], ["schema_version", 0], ["schema_version", 1.5], ["schema_version", true], ["location_id", "unknown"], ["spawn_id", "unknown"], ["player_instance_id", "npc-03"], ["party_member_ids", ["party-player", "party-player"]], ["actors", []], ["elapsed_play_seconds", -1], ["elapsed_play_seconds", INF], ["elapsed_play_seconds", true]]:
		var broken: Dictionary = data.duplicate(true)
		broken[pair[0]] = pair[1]
		_reject(broken, str(pair))
	for pair: Array in [["health", -1], ["health", 101], ["health", 1.5], ["health", true], ["definition_id", "npc-03"], ["instance_id", "other"]]:
		var broken: Dictionary = data.duplicate(true)
		broken.actors[0][pair[0]] = pair[1]
		_reject(broken, str(pair))
	var extra: Dictionary = data.duplicate(true)
	extra["world_node"] = NodePath("WorldHost")
	_reject(extra, "unknown field")
	_check(SaveCodec.decode("{bad", catalog).session == null, "Malformed JSON accepted")
	_check(SaveCodec.decode(" ".repeat(SaveCodec.MAX_BYTES + 1), catalog).session == null, "Oversized save accepted")

	var repository: SaveRepository = SaveRepository.new(directory.path_join("slot.json"))
	_check(repository.read(catalog).session == null, "Missing save unexpectedly loaded")
	_check(repository.write(run, catalog).is_empty(), "First disk save failed")
	var good_primary: String = FileAccess.get_file_as_string(repository.path)
	var good_backup: String = FileAccess.get_file_as_string(repository.path + ".bak")
	_check(repository.read(catalog).session.actors[GameSession.PLAYER_INSTANCE_ID].health == 37, "Disk round trip lost health")
	run.actors[GameSession.PLAYER_INSTANCE_ID].health = 63
	_check(repository.write(run, catalog).is_empty(), "Second disk save failed")
	_check(FileAccess.get_file_as_string(repository.path + ".bak") == good_primary, "Backup is not previous known-good save")
	good_primary = FileAccess.get_file_as_string(repository.path)
	good_backup = FileAccess.get_file_as_string(repository.path + ".bak")

	# Failed staging must preserve primary and backup bytes.
	_check(DirAccess.make_dir_absolute(repository.path + ".tmp") == OK, "Cannot create temporary write obstruction")
	_check(not repository.write(run, catalog).is_empty(), "Blocked temporary file did not fail")
	_unchanged(repository, good_primary, good_backup, "failed temporary write")
	_check(DirAccess.remove_absolute(repository.path + ".tmp") == OK, "Cannot remove temporary obstruction")
	_check(DirAccess.make_dir_absolute(repository.path + ".bak.tmp") == OK, "Cannot create backup staging obstruction")
	_check(not repository.write(run, catalog).is_empty(), "Blocked backup staging did not fail")
	_unchanged(repository, good_primary, good_backup, "failed backup staging")
	_check(DirAccess.remove_absolute(repository.path + ".bak.tmp") == OK, "Cannot remove backup obstruction")
	_check(repository.read(catalog).session.actors[GameSession.PLAYER_INSTANCE_ID].health == 63, "Uncommitted .tmp displaced primary")

	# Invalid runtime state cannot replace any good file.
	run.actors[GameSession.PLAYER_INSTANCE_ID].health = -1
	_check(not repository.write(run, catalog).is_empty(), "Invalid live snapshot saved")
	_unchanged(repository, good_primary, good_backup, "invalid runtime snapshot")
	run.actors[GameSession.PLAYER_INSTANCE_ID].health = 63
	_write(repository.path, "{truncated")
	var recovered: SaveRepository.ReadResult = repository.read(catalog)
	_check(recovered.recovered and recovered.session.actors[GameSession.PLAYER_INSTANCE_ID].health == 37, "Corrupt primary did not recover previous backup")
	_unchanged(repository, "{truncated", good_backup, "recovery read")
	_check(repository.write(run, catalog).is_empty(), "Cannot save after validated backup recovery")
	_check(FileAccess.get_file_as_string(repository.path + ".bak") == good_backup, "Corrupt primary overwrote good backup")
	_check(DirAccess.remove_absolute(repository.path) == OK, "Cannot remove test primary")
	_check(repository.read(catalog).recovered, "Missing primary did not recover backup")
	_write(repository.path, good_primary)
	var future: Dictionary = data.duplicate(true)
	future.schema_version = SaveCodec.SCHEMA_VERSION + 1
	var future_raw: String = JSON.stringify(future)
	_write(repository.path, future_raw)
	_check(repository.read(catalog).session == null, "Newer primary silently fell back to old backup")
	_check(not repository.write(run, catalog).is_empty(), "Newer primary overwritten")
	_unchanged(repository, future_raw, good_backup, "newer primary")
	_write(repository.path, good_primary)
	_write(repository.path + ".bak", future_raw)
	_check(not repository.write(run, catalog).is_empty(), "Newer backup overwritten")
	_unchanged(repository, good_primary, future_raw, "newer backup")
	_write(repository.path, "corrupt")
	_write(repository.path + ".bak", "also corrupt")
	_check(repository.read(catalog).session == null and not repository.write(run, catalog).is_empty(), "Both corrupt files not rejected")
	_unchanged(repository, "corrupt", "also corrupt", "both corrupt")
	_write(repository.path, " ".repeat(SaveCodec.MAX_BYTES + 1))
	_check(repository.read(catalog).session == null, "Oversized disk file accepted")

	await _root_checks()
	print("P005 test files retained: ", ProjectSettings.globalize_path(directory))
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P005 checks: PASS — detached plain data, versions/IDs/types/health/size, checked IO, backup recovery/preservation, stable boundaries, atomic live restore and unsafe spawn rollback.")
	quit(0 if failures.is_empty() else 1)


func _root_checks() -> void:
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.save_repository = SaveRepository.new(directory.path_join("root.json"))
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "Unsafe save fixture"
	unsafe.prototype_fixture = true
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	var actor_id: int = game.player_placeholder.get_instance_id()
	_check(not game.save_run().is_empty(), "Unpaused save accepted")
	_check(not (await game.load_run()).is_empty(), "Unpaused load accepted")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	game._set_paused(true)
	_check(not game.save_run().is_empty(), "In-flight save accepted")
	_check(not (await game.load_run()).is_empty(), "In-flight load accepted")
	await game.world_host.transition_finished
	game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 37
	game.session.elapsed_play_seconds = 42.5
	game.session.environment.day_index = 4
	game.session.environment.day_cycle_progress = 0.1234567890123456
	game.session.environment.weather_seed = 2147483648
	_check(game.session.environment.set_light_enabled("prototype-alderwake", "dock-lamp-01", "lantern", true).is_empty(), "Root light prerequisite")
	_check(game.save_run().is_empty(), "Paused root save failed")
	var saved: String = FileAccess.get_file_as_string(game.save_repository.path)
	game._set_paused(false)
	game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks")
	await game.world_host.transition_finished
	game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 81
	game._set_paused(true)
	var old: GameSession = game.session
	# Observe lock before async restore finishes, using concurrent deferred check.
	_probe_restore_lock.call_deferred()
	_check((await game.load_run()).is_empty(), "Valid root restore failed")
	_check(game.session != old and game.session == game.world_host.session, "Owners did not adopt detached saved run")
	_check(game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.player_placeholder.state.health == 37, "Wrapper not rebound to restored actor")
	_check(game.session.current_location_id == "prototype-tollworks" and game.session.elapsed_play_seconds == 42.5, "Root restore lost location/time")
	_check(game.player_placeholder.global_position.distance_to(Vector3(0, 0, -2.5)) < 0.01 and paused and not game.player_placeholder.controls_enabled, "Load did not respect arrival anchor/pause")
	_check(game.ui.travel_label.text == "E near southeast vessel / north return gate", "Paused restore retained stale loading prompt")
	_check(game.player_placeholder.get_instance_id() == actor_id and game.party.members().size() == 2, "Load duplicated actor wrapper")
	_check(JSON.parse_string(JSON.stringify(SaveCodec.snapshot(game.session), "", true, true)).environment == JSON.parse_string(saved).environment and SaveCodec.snapshot(game.session).light_source_overrides == JSON.parse_string(saved).light_source_overrides, "Root restore lost environment/overrides")

	var live: GameSession = game.session
	var live_environment: EnvironmentState = live.environment
	# Candidate environment differs from the live run during physical rejection.
	live_environment.day_index = 19
	live_environment.day_cycle_progress = 0.875
	live_environment.weather_seed = 4294967295
	live_environment.set_light_enabled("prototype-alderwake", "dock-lamp-01", "lantern", false)
	var environment_before: Dictionary = SaveCodec.snapshot(live).environment
	var overrides_before: Array = SaveCodec.snapshot(live).light_source_overrides
	var forecast_before: WeatherSchedule.Sample = live_environment.weather_sample()
	var room: PrototypeLocation = game.world_host.current_location
	var position_before: Vector3 = game.player_placeholder.global_position
	var future: Dictionary = JSON.parse_string(saved)
	future.schema_version = 99
	_write(game.save_repository.path, JSON.stringify(future))
	_check(not (await game.load_run()).is_empty(), "Future root save accepted")
	_check(game.session == live and game.world_host.current_location == room and game.player_placeholder.state.health == 37, "Rejected save replaced live session/world")
	_write(game.save_repository.path, "broken")
	_write(game.save_repository.path + ".bak", "broken backup")
	_check(not (await game.load_run()).is_empty() and game.session == live, "Corrupt root save replaced live run")
	for spawn: String in unsafe.spawn_ids:
		var invalid: Dictionary = JSON.parse_string(saved)
		invalid.location_id = unsafe.stable_id
		invalid.spawn_id = spawn
		_write(game.save_repository.path, JSON.stringify(invalid, "", true, true))
		_check(not (await game.load_run()).is_empty(), "Physically unsafe saved spawn accepted")
		_check(game.session == live and game.world_host.session == live and game.world_host.current_location == room, "Unsafe restore replaced live owners")
		_check(game.player_placeholder.global_position == position_before and game.player_placeholder.state.health == 37 and paused and not game.loading_save and not game.party.suspended, "Unsafe restore did not rollback state/lifecycle")
		_check(game.session.environment == live_environment and SaveCodec.snapshot(game.session).environment == environment_before and SaveCodec.snapshot(game.session).light_source_overrides == overrides_before, "Physical rejection changed clock/seed/light overrides")
		var forecast_after: WeatherSchedule.Sample = game.session.environment.weather_sample()
		_check(forecast_before.condition == forecast_after.condition and forecast_before.period_index == forecast_after.period_index and forecast_before.transition_progress == forecast_after.transition_progress, "Physical rejection changed forecast")
	_write(game.save_repository.path, "broken")
	_write(game.save_repository.path + ".bak", saved)
	_check((await game.load_run()).is_empty() and "Recovered backup" in game.ui.save_status.text, "Root recovery failed or not visible")
	_check(FileAccess.get_file_as_string(game.save_repository.path) == "broken", "Root recovery rewrote primary silently")
	game._set_paused(false)
	_check(game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null, "Resume retained load-button focus/input lock")
	game.queue_free()
	await process_frame


func _probe_restore_lock() -> void:
	_check(game.loading_save and game.world_host.transitioning and not game.player_placeholder.controls_enabled, "Restore did not lock synchronously")
	_check(not game.save_run().is_empty(), "Save raced live restore")
	_check(not (await game.load_run()).is_empty(), "Repeated load raced restore")
	game._resume()
	_check(paused, "Resume bypassed restore lock")


func _reject(data: Variant, label: String) -> void:
	var result: SaveCodec.DecodeResult = SaveCodec.validate(data, catalog)
	_check(result.session == null and not result.errors.is_empty(), "Accepted " + label)


func _unchanged(repository: SaveRepository, primary: String, backup: String, label: String) -> void:
	_check(FileAccess.get_file_as_string(repository.path) == primary and FileAccess.get_file_as_string(repository.path + ".bak") == backup, "Changed files during " + label)


func _write(path: String, raw: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "Cannot write fixture: " + path)
	if file != null:
		file.store_string(raw)
		_check(file.get_error() == OK, "Fixture write failed")
		file.close()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
