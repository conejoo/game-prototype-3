extends SceneTree
## Rules and lifecycle checks; positioned test fixtures are not normal-play proof.

class AttackProbe extends Node:
	var requests: int = 0
	func _unhandled_input(event: InputEvent) -> void:
		if event.is_action_pressed("attack"):
			requests += 1

var failures: Array[String] = []
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "Authored catalog rejected")
	var content: DialogueDefinition = catalog.get_dialogue("prototype-companion-greeting")
	var first: DialogueService = DialogueService.new()
	var second: DialogueService = DialogueService.new()
	_check(not first.begin(null, "test").ok and not first.active(), "Missing dialogue accepted")
	_check(first.begin(content, "test-first").ok and second.begin(content, "test-second").ok, "Conversation failed")
	_check(not first.begin(content, "test-again").ok, "Reentry reset active conversation")
	_check(first.awaiting_choice() and not first.advance().ok, "Choice skipped")
	_check(not first.choose("missing").ok and first.awaiting_choice(), "Unknown choice changed state")
	_check(first.choose("prototype-ask-room").ok and first.last_result.action_id == "prototype-observe", "Action result missing")
	_check(not first.choose("prototype-ask-room").ok, "Repeated choice executed")
	_check(second.awaiting_choice() and second.selected_choice_id.is_empty() and content.lines.size() == 1, "Dialogue state leaked to instance/definition")
	_check(first.advance().ok and not first.active(), "Terminal response failed to close")
	_check(not first.advance().ok, "Closed conversation advanced")
	second.cancel()
	second.cancel()
	var detached: DialogueDefinition = content.duplicate(true)
	detached.choices[0].action_id = "grant-quest-reward"
	_check("unsupported dialogue action" in "; ".join(detached.validation_errors()), "Unsupported authored action accepted")
	detached = content.duplicate(true)
	detached.choices[1].stable_id = detached.choices[0].stable_id
	_check("duplicate choice ID" in "; ".join(detached.validation_errors()), "Duplicate choice accepted")
	detached = content.duplicate(true)
	detached.choices[0].response = [" "]
	_check("blank line" in "; ".join(detached.validation_errors()), "Blank choice response accepted")
	_check(content.choices[0].action_id == "prototype-observe", "Negative fixture mutated authored resource")
	var multi: DialogueDefinition = content.duplicate(true)
	multi.lines = ["First line.", "Second line."]
	_check(first.begin(multi, "test-multiline").ok and not first.awaiting_choice(), "Multiline begin failed")
	_check(not first.choose("prototype-ask-room").ok and first.advance().ok and first.awaiting_choice(), "Choice before introduction accepted")
	first.cancel()

	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	var actor: ActorPlaceholder = game.player_placeholder
	var probe: AttackProbe = AttackProbe.new()
	game.add_child(probe)
	for room_id: String in ["prototype-alderwake", "prototype-tollworks"]:
		if game.session.current_location_id != room_id:
			_check(game.world_host.request_transition(room_id, "tollworks-start").is_empty(), "Test travel rejected")
			await game.world_host.transition_finished
		await physics_frame
		var room: PrototypeLocation = game.world_host.current_location
		_check(room.has_node("TemporaryCompanion") and room.has_node("PracticeMarker") and room.has_node("TravelGate"), "Room needs NPC, prop, gate")
		for target_name: String in ["TemporaryCompanion", "PracticeMarker"]:
			var target: PrototypeInteractable = room.get_node(target_name)
			actor.global_position = target.global_position + Vector3(0, 0, 1.2)
			await physics_frame
			await process_frame
			_check(InteractionSelector.select(actor, room) == target, "Nearby target not selected")
			_key(KEY_W, true)
			_key(KEY_E, true)
			_key(KEY_E, false)
			await process_frame
			_check(game.dialogue.active() and game.dialogue.source_instance_id == target.instance_id, "E did not open correct interaction")
			_check(not actor.controls_enabled and actor.movement_buttons.is_empty() and game.ui.dialogue_overlay.visible, "Modal failed to clear held movement")
			var before: Vector3 = actor.global_position
			var camera_before: String = game.camera_rig.description()
			var attacks_before: int = probe.requests
			_key(KEY_D, true)
			_key(KEY_E, true)
			_key(KEY_P, true)
			_click(Vector2(20, 300))
			await create_timer(0.12).timeout
			_check(actor.global_position.distance_to(before) < 0.01 and probe.requests == attacks_before, "Modal leaked movement/attack input")
			_check(game.camera_rig.description() == camera_before and not game.interact().ok, "Modal leaked camera/reentry")
			game._set_paused(true)
			_check(not paused, "Pause layered over dialogue")
			paused = true # Deliberate adversarial fixture; saves still must reject.
			_check(not game.save_run().is_empty() and not (await game.load_run()).is_empty(), "Dialogue save/load boundary accepted")
			paused = false
			# Select via ordinary focused GUI Enter, not direct service command.
			_key(KEY_ENTER, true)
			_key(KEY_ENTER, false)
			await process_frame
			_check(game.dialogue.selected_choice_id != "" and game.dialogue.last_result.ok, "GUI choice failed")
			_key(KEY_ESCAPE, true)
			_key(KEY_ESCAPE, false)
			await process_frame
			_check(not game.dialogue.active() and actor.controls_enabled and not paused and root.gui_get_focus_owner() == null and not game.ui.dialogue_overlay.visible, "Cancel left modal/focus/input stuck")
			await create_timer(0.1).timeout
			_check(actor.global_position.distance_to(before) < 0.01, "Held input resumed after cancel")
			for key: int in [KEY_W, KEY_D, KEY_E, KEY_P]:
				_key(key, false)
			_key(KEY_D, true)
			await create_timer(0.1).timeout
			_key(KEY_D, false)
			_check(actor.global_position.distance_to(before) > 0.1, "Fresh input failed after cancel")
			_click(Vector2(20, 300))
			_check(probe.requests == attacks_before + 1, "Attack input remained locked after cancel")
			_check(actor.combat.attacking, "Fresh attack did not start real combat window")
			# P008 makes this a real swing; finish recovery before next interaction.
			await create_timer(0.7).timeout
			_check(actor.state.health == 100 and game.session.party_member_ids.size() == 2, "Presentation dialogue changed durable actor/party state")
		# Occluded nearby target must not be reachable through a collider.
		var npc: PrototypeInteractable = room.get_node("TemporaryCompanion")
		actor.global_position = npc.global_position + Vector3(0, 0, 1.4)
		var blocker: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = Vector3(1, 2, 0.1)
		shape.shape = box
		blocker.add_child(shape)
		room.add_child(blocker)
		blocker.global_position = npc.global_position + Vector3(0, 1, 0.7)
		await physics_frame
		await physics_frame
		_check(InteractionSelector.select(actor, room) == null and not game.interact().ok, "Occluded interaction accepted")
		blocker.queue_free()
		await physics_frame
		await physics_frame
		_check(game.interact().ok, "LOS recovery failed")
		_check(game.world_host.request_transition(room_id, game.session.current_spawn_id).is_empty(), "Lifecycle reload failed")
		await game.world_host.transition_finished
		_check(not game.dialogue.active() and not game.ui.dialogue_overlay.visible and actor.controls_enabled, "Room unload retained dialogue/stale source")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P006 checks: PASS — authored choices/action rejection, independent runtime state, both-room E/GUI dialogue, held movement and attack-input arbitration, cancel/focus restoration, save boundary, LOS and unload cleanup.")
	quit(0 if failures.is_empty() else 1)


func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event, true)


func _click(point: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
