extends SceneTree
## Focused root/input/pause check. Real-window acceptance remains separate.

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("P001 smoke: engine %s" % Engine.get_version_info()["string"])
	var packed: PackedScene = load("res://app/game_root.tscn")
	var game: Node3D = packed.instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	for child_name: String in ["WorldHost", "Party", "CameraRig", "UI"]:
		_check(game.has_node(child_name), "Root missing %s" % child_name)
	_check(game.get_node("WorldHost").get_child_count() == 1, "WorldHost must own one room")
	_check(game.get_node("Party").get_child_count() == 1, "Party must own one placeholder")
	var keys: Dictionary[String, int] = {
		"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A,
		"move_right": KEY_D, "dodge": KEY_SPACE, "interact": KEY_E,
		"pause": KEY_ESCAPE, "quit": KEY_F10,
	}
	for action: String in keys:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		_check(events.size() == 1 and events[0] is InputEventKey, "Bad key action %s" % action)
		if events.size() == 1 and events[0] is InputEventKey:
			var binding: InputEventKey = events[0] as InputEventKey
			var code: int = binding.physical_keycode if action in ["dodge", "interact"] else binding.keycode
			_check(code == keys[action], "Wrong key for %s" % action)
	var attacks: Array[InputEvent] = InputMap.action_get_events("attack")
	_check(attacks.size() == 1 and attacks[0] is InputEventMouseButton, "Attack must use mouse")
	if attacks.size() == 1 and attacks[0] is InputEventMouseButton:
		_check((attacks[0] as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT, "Wrong attack button")
	var session: GameSession = game.session
	_check(session.initialized and game.catalog.initialized, "Root services were not initialized")
	_check(session.current_location_id == "prototype-test-room", "Root location ID is wrong")
	_check(game.player_placeholder.state == session.actors[GameSession.PLAYER_INSTANCE_ID], "Wrapper does not receive authoritative session actor state")
	_check(game.player_placeholder.has_node("VisualRoot"), "Actor visual wrapper missing")
	var independent: GameSession = GameSession.new()
	var beacon: Node3D = game.get_node("WorldHost/TestRoom/TestBeacon")
	for frame: int in range(8):
		await process_frame
	_check(session.elapsed_play_seconds > 0.0, "Run timer did not advance")
	_check(independent.elapsed_play_seconds == 0.0, "Sessions share mutable state")
	_send_escape()
	await process_frame
	_check(paused, "Escape did not pause")
	_check(not game.get_node("WorldHost").can_process(), "WorldHost still processing while paused")
	_check(not game.get_node("Party").can_process(), "Party still processing while paused")
	_check(not game.get_node("CameraRig").can_process(), "CameraRig still processing while paused")
	_check(game.get_node("UI").can_process(), "Pause UI cannot process")
	_check(game.get_node("UI/Screen/PauseOverlay").visible, "Pause overlay hidden")
	var paused_time: float = session.elapsed_play_seconds
	var paused_rotation: Vector3 = beacon.rotation
	for frame: int in range(8):
		await process_frame
	_check(session.elapsed_play_seconds == paused_time, "Timer advanced while paused")
	_check(beacon.rotation == paused_rotation, "World animated while paused")
	_send_escape()
	await process_frame
	_check(not paused, "Escape did not resume")
	_check(not game.get_node("UI/Screen/PauseOverlay").visible, "Overlay remains after resume")
	for frame: int in range(8):
		await process_frame
	_check(session.elapsed_play_seconds > paused_time, "Timer did not resume")
	_check(beacon.rotation != paused_rotation, "World did not resume")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("P001 smoke: PASS — composition, bindings, independent state, pause and resume.")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _send_escape() -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = KEY_ESCAPE
	event.keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.physical_keycode = KEY_ESCAPE
	event.keycode = KEY_ESCAPE
	event.pressed = false
	Input.parse_input_event(event)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
