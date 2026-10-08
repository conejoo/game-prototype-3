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
	var content: ConversationDefinition = catalog.get_dialogue("prototype-companion-greeting")
	var npcs: NpcContentCatalog = NpcContentCatalog.new()
	_check(npcs.initialize_path(catalog).is_empty(), "NPC catalog invalid")
	var session: GameSession = GameSession.new()
	session.initialize(catalog, "prototype-alderwake", "alderwake-start", "prototype-hero", null, npcs)
	var first: NpcDialogueService = NpcDialogueService.new()
	var second: NpcDialogueService = NpcDialogueService.new()
	first.initialize(npcs, session)
	second.initialize(npcs, session)
	_check(not first.begin_graph(null, "test").ok and not first.active(), "Missing dialogue accepted")
	_check(first.begin_graph(content, "test-first").ok and second.begin_graph(content, "test-second").ok, "Conversation failed")
	_check(not first.begin_graph(content, "test-again").ok, "Reentry reset active conversation")
	_check(not first.snapshot().choices.is_empty() and not TestRunConversation.advance(first).ok, "Choice skipped")
	_check(not TestRunConversation.choose(first, "missing").ok and not first.snapshot().choices.is_empty(), "Unknown choice changed state")
	_check(TestRunConversation.choose(first, "prototype-ask-room").action_id == "prototype-observe", "Action result missing")
	_check(not TestRunConversation.choose(first, "prototype-ask-room").ok, "Repeated choice executed")
	_check(not second.snapshot().choices.is_empty() and second.snapshot().selected_choice_id.is_empty() and content.document().nodes[0].choices.size() == 4, "State leaked")
	_check(TestRunConversation.advance(first).ok and not first.active(), "Terminal response failed to close")
	_check(not TestRunConversation.advance(first).ok, "Closed conversation advanced")
	second.cancel()
	second.cancel()
	for mutation: String in ["action", "duplicate", "blank", "cycle", "dangling"]:
		var detached: ConversationDefinition = content.duplicate(true)
		TestRunConversation.mutate(detached, func(data: Dictionary) -> void:
			match mutation:
				"action": data.nodes[0].choices[0].command.action_id = "grant-quest-reward"
				"duplicate": data.nodes[0].choices[1].id = data.nodes[0].choices[0].id
				"blank": data.nodes[1].text = " "
				"cycle": data.nodes[1]["continueTargetId"] = data.nodes[0].id
				"dangling": data.nodes[0].choices[0].targetNodeId = "absent"
		)
		_check(not detached.validation_errors().is_empty(), "Malformed finite graph accepted: " + mutation)
	_check(content.graph().choices["prototype-ask-room"].command.action_id == "prototype-observe", "Fixture mutated authored resource")
	var multi: ConversationDefinition = catalog.get_dialogue("prototype-maris-fitting")
	_check(first.begin_graph(multi, "test-multiline").ok and first.snapshot().choices.is_empty(), "Multinode begin failed")
	_check(not TestRunConversation.choose(first, "maris-reconnect-choice").ok and TestRunConversation.advance(first).ok and first.snapshot().choices.is_empty(), "Early choice accepted")
	_check(TestRunConversation.advance(first).ok and first.snapshot().choices.size() == 2, "Finite continuation failed")
	first.cancel()
	# Owner callbacks cannot reenter a choice or resurrect a canceled cursor.
	var command_count: Array[int] = [0]
	first.reaction_command = func(_id: String, _instance: String) -> NpcDialogueService.Result:
		command_count[0] += 1
		_check(not TestRunConversation.choose(first, "prototype-plan-together").ok, "Callback reentered choice")
		first.cancel()
		return NpcDialogueService.Result.new(true, "Owned fixture command accepted.")
	first.begin_graph(content, "test-owner-callback")
	_check(TestRunConversation.choose(first, "prototype-plan-together").ok and command_count[0] == 1 and not first.active(), "Callback cancellation resurrected cursor or duplicated command")
	first.reaction_command = Callable() # Release fixture's self-capturing callback.

	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.developer_fixtures = true # Explicit P006 reusable practice-prop fixture.
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
			_check(game.dialogue.active() and game.dialogue.snapshot().get("instance_id", "") == target.instance_id, "E did not open correct interaction")
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
			_check(game.dialogue.snapshot().get("selected_choice_id", "") != "" and game.conversation_result.ok, "GUI choice failed")
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
