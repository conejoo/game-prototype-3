extends SceneTree
## Developer protocol validation plus timed input through the actual application.

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(960, 640)
	var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	_check(not game.has_node("LivePlaytestBridge"), "Bridge enabled without opt-in")
	var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
	game.add_child(bridge)
	var directory: String = ProjectSettings.globalize_path("res://../builds/playtest/check-" + str(OS.get_process_id()))
	bridge.start(game, directory)
	_check(FileAccess.file_exists(directory.path_join("ready.json")), "Bridge did not publish readiness")
	var baseline: Vector3 = game.player_placeholder.global_position
	for invalid: Dictionary in [
		{"boot_id": "old", "steps": [{"op": "hold", "keys": ["W"], "duration_ms": 100}]},
		{"boot_id": bridge.boot_id, "steps": [{"op": "teleport"}]},
		{"boot_id": bridge.boot_id, "steps": [{"op": "hold", "keys": ["BAD"], "duration_ms": 100}]},
		{"boot_id": bridge.boot_id, "steps": [{"op": "hold", "keys": ["W"], "duration_ms": -1}]},
		{"boot_id": bridge.boot_id, "steps": [{"op": "click", "x": "bad", "y": 40}]},
		{"boot_id": bridge.boot_id, "steps": [{"op": "quit"}, {"op": "observe"}]},
	]:
		_check(not bridge._validate(invalid).is_empty(), "Invalid command accepted")
	_check(game.player_placeholder.global_position == baseline, "Validation modified player")
	var request: Dictionary = {"id": "timed", "boot_id": bridge.boot_id, "steps": [
		{"op": "hold", "keys": ["W", "D"], "duration_ms": 100},
		{"op": "observe"},
	]}
	bridge._write_json("request.json", request)
	await create_timer(0.35).timeout
	var response: Variant = JSON.parse_string(FileAccess.get_file_as_string(directory.path_join("timed.json")))
	_check(response is Dictionary and response.get("ok") == true, "Timed command did not finish successfully")
	if response is Dictionary:
		_check(response["steps"][0]["elapsed_ms"] >= 100, "Timed chord released before requested duration")
	_check(game.player_placeholder.global_position.distance_to(baseline) > 0.25, "100ms chord did not move through physics")
	_check(game.player_placeholder.movement_buttons.is_empty(), "Command left movement held")
	var after: Vector3 = game.player_placeholder.global_position
	bridge._write_json("request.json", request)
	await create_timer(0.2).timeout
	_check(game.player_placeholder.global_position.distance_to(after) < 0.01, "Duplicate command ID replayed movement")
	_check(bridge._validate({"boot_id": bridge.boot_id, "steps": [{"op": "capture"}]}).is_empty(), "Capture schema invalid")
	game.queue_free()
	await process_frame
	_check(not FileAccess.file_exists(directory.path_join("ready.json")), "Readiness remained after shutdown")
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P003 bridge checks: PASS — opt-in, validation, readiness, timed chord input, released keys, duplicate suppression and shutdown.")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
