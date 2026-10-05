extends SceneTree
## W006 synthetic placement/state fixtures, real viewport E/GUI arbitration.

var game: Node3D
var failures: Array[String] = []
var assertions: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W006 checks pid=%d user_data=%s" % [OS.get_process_id(), OS.get_user_data_dir()])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	var room: AlderwakeExterior = game.world_host.current_location
	var switch_count: int = 0
	for source: Dictionary in LightSourceRegistry.entries():
		var action: LightSwitchAction = LightSwitchAction.new()
		action.location_id = source.location_id
		action.prop_id = source.prop_id
		action.source_id = source.source_id
		if not source.switchable:
			_check(not action.validation_errors().is_empty(), "automatic action accepted " + source.prop_id)
			_check(not game.session.toggle_light(action, source.default_enabled).is_empty(), "automatic source command accepted")
			continue
		switch_count += 1
		var target: PrototypeInteractable = room.town.get_node(NodePath(source.prop_id + "/LightSwitch"))
		_check(target.validation_errors(game.catalog).is_empty() and target.dialogue_id.is_empty(), "typed wrapper validation")
		await _place(target)
		_check(target.display_prompt(game.session.environment) == ("Turn off lamp" if source.default_enabled else "Turn on lamp"), "initial dynamic prompt")
		var before: Array[Dictionary] = LightSourceRegistry.sorted_overrides(game.session.environment.light_source_overrides)
		_key(KEY_E, true)
		_key(KEY_E, false)
		await process_frame
		_check(game.session.environment.light_enabled(source.location_id, source.prop_id, source.source_id) == not source.default_enabled, "E switch " + source.prop_id)
		_check(not game.dialogue.active(), "light started dialogue")
		_check(target.display_prompt(game.session.environment) == ("Turn on lamp" if source.default_enabled else "Turn off lamp"), "changed prompt")
		_check(game.ui.travel_label.text.contains("Lamp "), "feedback vanished")
		_key(KEY_E, true, true)
		_key(KEY_E, false)
		_check(game.session.environment.light_enabled(source.location_id, source.prop_id, source.source_id) == not source.default_enabled, "echo repeated switch")
		_check(not game.switch_light(weakref(target), source.default_enabled).ok, "stale command changed twice")
		for saved: Dictionary in before:
			_check(game.session.environment.light_enabled(saved.location_id, saved.prop_id, saved.source_id) == saved.enabled, "other lamp mutated")
	_check(switch_count == 6 and game.session.environment.light_source_overrides.size() == 6, "six switchable targets")
	var target: PrototypeInteractable = room.town.get_node("dock-lamp-02/LightSwitch")
	await _place(target)
	var expected: bool = game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-02", "lantern")
	_check(game.ui.travel_label.text == "E: " + target.display_prompt(game.session.environment), "other lamp feedback followed selection")
	var saved_state: Dictionary = SaveCodec.snapshot(game.session)
	for mode: String in ["pause", "dialogue", "journal", "focus", "travel", "loading", "gui", "attack", "dodge", "dead"]:
		match mode:
			"pause": game._set_paused(true)
			"dialogue": game.dialogue.begin(game.catalog.get_dialogue("prototype-companion-greeting"), "fixture")
			"journal": game.journal_open = true
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"travel": game.world_host.transitioning = true
			"loading": game.loading_save = true
			"gui": game.ui.pause_button.grab_focus()
			"attack": game.player_placeholder.combat.attack(Vector3.FORWARD, true)
			"dodge": game.player_placeholder.combat.dodge(Vector3.FORWARD, true)
			"dead": game.player_placeholder.state.health = 0
		_check(not game.switch_light(weakref(target), expected).ok and not game.interact().ok, "command bypassed " + mode)
		_key(KEY_E, true)
		_key(KEY_E, false)
		_check(game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-02", "lantern") == expected, "E bypassed " + mode)
		match mode:
			"pause": game._set_paused(false)
			"dialogue": game._cancel_dialogue()
			"journal": game.journal_open = false
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			"travel": game.world_host.transitioning = false
			"loading": game.loading_save = false
			"gui": game.ui.pause_button.release_focus()
			"attack", "dodge": game.player_placeholder.combat.cancel()
			"dead": game.player_placeholder.state.health = 100
		game._update_controls()
	_check(SaveCodec.snapshot(game.session).environment == saved_state.environment and SaveCodec.snapshot(game.session).light_source_overrides == saved_state.light_source_overrides, "gate checks changed environment")
	# Actual physics LOS wall plus out-of-range and a queued/freed node.
	await _place(target)
	var wall: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(.6, 2, .6)
	shape.shape = box
	wall.add_child(shape)
	room.add_child(wall)
	wall.global_position = (target.global_position + game.player_placeholder.global_position) * .5 + Vector3.UP
	await physics_frame
	await physics_frame
	_check(InteractionSelector.select(game.player_placeholder, room) != target and not game.switch_light(weakref(target), expected).ok, "LOS wall bypassed")
	wall.free()
	await physics_frame
	await _place(target)
	game.player_placeholder.global_position += Vector3(5, 0, 0)
	_check(not game.switch_light(weakref(target), expected).ok, "stale cached prompt bypassed range")
	await _place(target)
	var target_reference: WeakRef = weakref(target)
	var action: LightSwitchAction = target.light_action
	var source_before: String = action.source_id
	action.source_id = "missing"
	_check(not game.switch_light(weakref(target), expected).ok, "unknown source accepted")
	action.source_id = source_before
	var saved_choices: Array[Dictionary] = LightSourceRegistry.sorted_overrides(game.session.environment.light_source_overrides)
	game._set_paused(true)
	for trip: int in range(2):
		_check(game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake").is_empty(), "indoor transition")
		await game.world_host.transition_finished
		_check(not game.switch_light(target_reference, expected).ok, "unloaded target accepted")
		_check(not game.session.toggle_light(action, expected).is_empty(), "session accepted foreign room")
		_check(game.world_host.current_location.find_children("LightSwitch", "", true, false).is_empty(), "switch leaked indoors")
		_check(game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks").is_empty(), "outdoor transition")
		await game.world_host.transition_finished
		_check(LightSourceRegistry.sorted_overrides(game.session.environment.light_source_overrides) == saved_choices, "travel lost choices")
		_check(SaveCodec.snapshot(game.session).environment == saved_state.environment, "paused travel changed clock/seed")
		var lights: ExteriorLights = game.world_host.current_location.exterior_lights
		for record: Dictionary in saved_choices:
			_check(lights.consumers[record.prop_id].enabled == record.enabled, "return consumer not hydrated")
	var queued: PrototypeInteractable = game.world_host.current_location.town.get_node("dock-lamp-02/LightSwitch")
	game._set_paused(false)
	await _place(queued)
	var queued_reference: WeakRef = weakref(queued)
	queued.queue_free()
	_check(not game.switch_light(queued_reference, expected).ok, "queued target accepted")
	await process_frame
	_check(not game.switch_light(queued_reference, expected).ok, "freed target accepted")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("W006 light interaction: %s assertions=%d" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)


func _place(target: PrototypeInteractable) -> void:
	for direction: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		game.player_placeholder.global_position = target.global_position + direction * 1.1
		game.companion.global_position = target.global_position + Vector3(3, 0, 3)
		await physics_frame
		await physics_frame
		if InteractionSelector.select(game.player_placeholder, game.world_host.current_location) == target:
			game._refresh_interaction()
			return
	_check(false, "no selectable fixture approach " + target.instance_id)


func _key(code: int, pressed: bool, echo: bool = false) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	root.push_input(event, true)


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
