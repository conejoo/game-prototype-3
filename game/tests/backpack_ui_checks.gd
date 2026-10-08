extends SceneTree
## Synthetic owned inventory/capacity and mode fixtures; actual viewport keys/pointer.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	var manifest: ContentManifest = game.content_manifest.duplicate()
	for index: int in range(18):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "f006-fixture-%02d" % index
		item.display_name = "Sample %02d" % (index + 1)
		item.source_item_id = item.stable_id
		item.description = "Synthetic capacity fixture; no gameplay source."
		manifest.definitions.append(item)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	_check(InputMap.has_action("backpack") and InputMap.action_has_event("backpack",_event(KEY_B,true)), "B InputMap action")
	game.ui.show_foraging_feedback("Gathered moonflower.")
	_key(KEY_B)
	_check(not game.ui.foraging_notice.visible,"feedback hidden immediately by backpack")
	_check(game.ui.travel_label.get_parent().get_index() < game.ui.pause_overlay.get_index() and game.ui.travel_label.get_parent().get_index() < game.ui.backpack.get_index(),"field status below modal layers")
	_check(game.backpack_open and game.ui.backpack.visible and not paused, "B opens unpaused modal")
	_check(game.ui.backpack.slots.size() == 20 and game.ui.backpack.slot_ids.is_empty(), "twenty empty slots")
	for button: Button in game.ui.backpack.slots:
		_check(button.disabled and button.text == "Empty" and not button.button_pressed, "empty slot honest")
	_check(root.gui_get_focus_owner() == game.ui.backpack.close_button, "empty focus Close")
	_check(game._select_inventory_item(ForagingRegistry.ROD_ITEM).has("missing_owned_item") and game.session.inventory.snapshot().active_item_id == null, "known unowned selection rejected")
	_key(KEY_TAB)
	_check(root.gui_get_focus_owner() == game.ui.backpack.close_button, "empty focus contained")
	_key(KEY_B)
	_check(not game.backpack_open and root.gui_get_focus_owner() == null, "B closes and releases focus")
	game.session.inventory.add("item-moonflower",3)
	game.session.inventory.add(ForagingRegistry.ROD_ITEM,1)
	_key(KEY_D,true)
	for frame: int in range(10): await physics_frame
	_check(game.player_placeholder.movement_buttons.has("move_right"), "normal accepted held movement")
	_key(KEY_B)
	_check(game.player_placeholder.movement_buttons.is_empty() and game.player_placeholder.velocity == Vector3.ZERO, "open clears held controls")
	_check(not game.player_placeholder.controls_enabled and not game.player_placeholder.combat_enabled and not game.companion_ai.enabled, "modal disables actors")
	var position: Vector3 = game.player_placeholder.position
	var facing: Basis = game.player_placeholder.visual_root.basis
	var camera: Dictionary = TestRunObservation.camera(game)
	var facts: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	for code: int in [KEY_W,KEY_E,KEY_SPACE,KEY_P,KEY_EQUAL,KEY_MINUS,KEY_J,KEY_R,KEY_F6]: _key(code)
	_pointer(Vector2(600,450))
	await _click_point(Vector2(5,350))
	for button_index: int in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		var wheel: InputEventMouseButton = InputEventMouseButton.new()
		wheel.position = Vector2(400,350)
		wheel.button_index = button_index
		wheel.pressed = true
		root.push_input(wheel,true)
	for frame: int in range(12): await physics_frame
	_check(game.player_placeholder.position.is_equal_approx(position), "modal blocks movement")
	_check(not game.player_placeholder.combat.busy() and not game.foraging_hold.active() and not game.dialogue.active() and not game.journal_open, "modal blocks attack/dodge/interact/conflicts")
	_check(TestRunObservation.camera(game) == camera and game.player_placeholder.visual_root.basis == facing and not game.player_placeholder.aim_marker.visible, "modal blocks aim/projection/zoom")
	_check(TestRunSnapshot.exact_json(game.session.inventory.snapshot().to_dictionary()) == TestRunSnapshot.exact_json({"item_counts":{"item-moonflower":3,ForagingRegistry.ROD_ITEM:1},"active_item_id":null}), "world keys leave inventory intact")
	_check(not game.interact().ok and not game._save_boundary_errors().is_empty(), "direct commands reject modal")
	# Synthetic earned point exposes a leaked journal command even when selection UI is hidden.
	var earned_effect: String = game.catalog.get_upgrade(ProgressionService.UPGRADE_ID).earned_effect_id
	game.session.completed_effect_ids.append(earned_effect)
	game._select_upgrade()
	_check(game.session.progression.upgrade_ids.is_empty() and game.progression.available_points() == 1, "backpack cannot spend journal upgrade point")
	game.session.completed_effect_ids.erase(earned_effect)
	_check(not game._select_inventory_item("missing-owned-item").is_empty() and game.session.inventory.snapshot().active_item_id == null, "missing selection rejected")
	_key(KEY_ENTER)
	_check(game.session.inventory.active_tool() == game.catalog.get_item(ForagingRegistry.ROD_ITEM) and game.ui.backpack.slots[0].button_pressed, "Enter selects rod")
	_check(game.ui.active_item_label.text.begins_with("Active tool: Fishing rod") and game.ui.backpack.drop_button.visible and not game.ui.backpack.drop_button.disabled, "active HUD/safe Drop available")
	_key(KEY_ENTER)
	_check(game.ui.backpack.slots[0].button_pressed, "reselect retains highlight")
	_key(KEY_TAB)
	_key(KEY_ENTER)
	_check(game.session.inventory.snapshot().active_item_id == "item-moonflower" and game.session.inventory.active_tool() == null, "Tab/Enter selects non-tool")
	_check(game.ui.active_item_label.text.begins_with("Selected item: Moonflower") and game.ui.backpack.details.text.contains("Gift through conversation") and not game.ui.backpack.drop_button.visible, "non-tool authored gift help truthful")
	await _click(game.ui.backpack.slots[0])
	_check(game.session.inventory.active_tool() == game.catalog.get_item(ForagingRegistry.ROD_ITEM), "pointer selects rod")
	for step: int in range(12):
		_key(KEY_TAB)
		_check(game.ui.backpack.is_ancestor_of(root.gui_get_focus_owner()), "occupied focus cycle contained")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not game._select_inventory_item("item-moonflower").is_empty() and not game.player_placeholder.controls_enabled, "unfocused selection rejected")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_key(KEY_ESCAPE)
	_check(not game.backpack_open and not paused and root.gui_get_focus_owner() == null, "Esc closes before pause")
	for frame: int in range(10): await physics_frame
	_check(game.player_placeholder.position.is_equal_approx(position) and not game.player_placeholder.aim_marker.visible, "held movement/old pointer stay cleared after close")
	_key(KEY_D,false)
	_key(KEY_D,true)
	for frame: int in range(10): await physics_frame
	_key(KEY_D,false)
	_check(game.player_placeholder.position.distance_to(position) > .2, "fresh movement after close")
	_key(KEY_B)
	await _click(game.ui.backpack.clear_button)
	_check(game.session.inventory.snapshot().active_item_id == null and game.ui.active_item_label.text.contains("none"), "clear selection")
	await _click(game.ui.backpack.close_button)
	_check(not game.backpack_open, "Close button closes")
	for mode: String in ["pause","journal","dialogue","loading","travel","retry","focus","attack"]:
		match mode:
			"pause": game._set_paused(true)
			"journal": game._toggle_journal()
			"dialogue": game._present_dialogue(game.dialogue.begin_graph(game.catalog.get_dialogue("prototype-companion-greeting"),"fixture"))
			"loading": game.loading_save = true
			"travel": game.world_host.transitioning = true
			"retry": game.retrying = true
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"attack": game.player_placeholder.combat.attack(Vector3.FORWARD,true)
		_key(KEY_B)
		_check(not game.backpack_open, "B conflict " + mode)
		_check(not game._select_inventory_item(ForagingRegistry.ROD_ITEM).is_empty(), "selection conflict " + mode)
		match mode:
			"pause": game._set_paused(false)
			"journal": game._toggle_journal()
			"dialogue": game._cancel_dialogue()
			"loading": game.loading_save = false
			"travel": game.world_host.transitioning = false
			"retry": game.retrying = false
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			"attack": game.player_placeholder.combat.cancel()
		game._update_controls()
	# Selection and presentation clear when the last active unit disappears.
	_key(KEY_B)
	game._select_inventory_item("item-moonflower")
	game.session.inventory.consume("item-moonflower",3)
	game._process(0)
	_check(game.session.inventory.snapshot().active_item_id == null and game.ui.active_item_label.text.contains("none") and game.ui.backpack.details.text.begins_with("No active item"), "final-unit HUD/detail clearing")
	_check(game.ui.backpack.slot_ids.size() == 1 and game.ui.backpack.slots[1].disabled, "removed stack returns empty slot")
	_key(KEY_B)
	# Synthetic twenty-type capacity view, no durable save or ordinary-route claim.
	game.session.inventory.add("item-moonflower",99)
	for index: int in range(18): game.session.inventory.add("f006-fixture-%02d" % index,99)
	_key(KEY_B)
	_check(game.ui.backpack.slot_ids.size() == 20 and game.ui.backpack.capacity.text.begins_with("20 / 20"), "capacity twenty")
	for index: int in range(20):
		var id: String = game.ui.backpack.slot_ids[index]
		_check(game.ui.backpack.slots[index].text.contains("%d / %d" % [game.session.inventory.count(id),game.catalog.get_item(id).stack_limit]), "capacity count/cap " + id)
	for window: Vector2i in [Vector2i(960,640),Vector2i(800,600)]:
		root.size = window
		for frame: int in range(6): await process_frame
		_check(root.get_visible_rect().encloses(game.ui.backpack.panel.get_global_rect()), "panel fits " + str(window))
		for button: Button in game.ui.backpack.slots:
			_check(game.ui.backpack.panel.get_global_rect().encloses(button.get_global_rect()), "slot fits " + str(window))
	_key(KEY_B)
	await _click_point(Vector2(600,300))
	_check(game.player_placeholder.combat.attacking, "fresh pointer attack after close")
	game.player_placeholder.combat.cancel()
	_key(KEY_SPACE)
	_check(game.player_placeholder.combat.dodge_left > 0, "fresh dodge after close")
	game.player_placeholder.combat.cancel()
	var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
	game.add_child(bridge)
	_check(bridge._validate({"boot_id":bridge.boot_id,"steps":[{"op":"hold","keys":["B"],"duration_ms":100}]}).is_empty(), "bridge B allowlist")
	_check(TestRunEvidence.write_json("backpack-ui.json",{"assertions":assertions,"failures":failures,"proof":"synthetic inventory/capacity/modes; actual viewport input","initial_snapshot":facts}), "evidence")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F006 backpack UI ","PASS" if failures.is_empty() else "FAIL","; assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _event(code: int,down: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	return event

func _key(code: int,down: Variant = null) -> void:
	if down == null:
		root.push_input(_event(code,true),true)
		root.push_input(_event(code,false),true)
	else: root.push_input(_event(code,down),true)

func _pointer(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	root.push_input(event,true)

func _click(button: Button) -> void:
	for frame: int in range(3): await process_frame
	await _click_point(button.get_global_rect().get_center())

func _click_point(point: Vector2) -> void:
	_pointer(point)
	for down: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event,true)
	for frame: int in range(3): await process_frame

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
