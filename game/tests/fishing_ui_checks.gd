extends "res://tests/support/fishing_root_fixture.gd"
## FS006 synthetic setup; actual root, HUD, pointer/keyboard routing and gates.
func _exercise() -> void:
	task = "FS006"
	suite = "ui"
	var view: FishingView = game.ui.fishing_view
	game.session.inventory.select(null)
	var rejected_facts: String = _facts()
	_key(KEY_F)
	game._present_fishing()
	_check(game.fishing.snapshot().outcome == "rod_required" and view.title.text.to_lower().contains("rod required") and view.instruction.text.contains("Select") and _facts() == rejected_facts,"rejected entry presents its real outcome without durable mutation")
	_cast()
	await process_frame
	await process_frame
	game._present_fishing()
	_check(view.visible and view.title.text.contains("Waiting") and view.instruction.text.contains("Do not reel"),"waiting labels from real phase")
	_check(not view.meter.visible and view.reel_button.visible,"waiting has Reel without misleading tension")
	_check(not game.ui.accepts_world_pointer(view.reel_button.get_global_rect().get_center()),"HUD owns pointer; cannot attack/cast under panel")
	var facts: String = _facts()
	var observed: Dictionary = TestRunObservation.fishing(game)
	observed.point[0] = 999
	observed["tension"] = -5
	_check(_facts() == facts and game.fishing.snapshot().point.x != 999,"read-only detached fishing observation")
	_mouse(true,view.reel_button)
	_mouse(false,null)
	_check(game.fishing.snapshot().outcome == "early_reel" and not game.fishing.snapshot().reel_held and not view._pointer_held,"pointer waiting reel fails early, never strands held state")
	_check(not game.fishing_effects.visible and not game.player_placeholder.combat.busy(),"terminal hides effects, button cannot trigger attack")
	_phase("bite")
	game._present_fishing()
	await process_frame
	_check(view.title.text.begins_with("BITE") and view.instruction.text.contains("Fresh"),"bite fresh-press text")
	_mouse(true,view.reel_button)
	_check(game.fishing.snapshot().phase == "fighting" and game.fishing.snapshot().reel_held,"actual pointer down hooks")
	_key(KEY_E,true)
	_mouse(false,null)
	_check(game.fishing.snapshot().reel_held and not view._pointer_held,"pointer release outside leaves held keyboard source")
	_key(KEY_E,false)
	_check(not game.fishing.snapshot().reel_held,"both sources released")
	await process_frame
	_check(not game.ui.accepts_world_pointer(view.reel_button.get_global_rect().get_center()),"fight Reel stays within pointer-owned panel " + str(view.panel.get_global_rect()) + " " + str(view.reel_button.get_global_rect()))
	_mouse(true,view.reel_button)
	_check(view._pointer_held,"second pointer press reacquires " + str(view.reel_button.get_global_rect()) + " button=" + str(view.reel_button.is_pressed()))
	_key(KEY_E,true)
	_key(KEY_E,false)
	_check(game.fishing.snapshot().reel_held,"keyboard release leaves pointer source " + str(game.fishing.snapshot()) + " pointer=" + str(view._pointer_held))
	_pointer(Vector2(20,300))
	await process_frame
	_mouse(false,null)
	_check(not game.fishing.snapshot().reel_held and not view._pointer_held,"outside pointer/mouse exit release")
	_check(view.title.text.contains("Bluegill") and view.tension_text.text.contains("SAFE") and view.legend.text.contains("Safe 30-70%"),"species, tension numbers and text zones")
	_check(view.meter.visible and view.landing.visible and view.progress_text.text.contains("Landing"),"fight meters visible")
	_check(game.fishing_effects.visible and game.fishing_effects.ripple.position.is_equal_approx(game.fishing.snapshot().point+Vector3(0,.035,0)),"effects anchored to committed water surface")
	_check(game.fishing_effects.find_children("*","CollisionObject3D",true,false).is_empty() and game.fishing_effects.find_children("*","NavigationRegion3D",true,false).is_empty(),"effects contain no physics/navigation")
	_mouse(true,view.reel_button)
	_key(KEY_F)
	_check(not view._pointer_held and not game.fishing.snapshot().reel_held and not game.fishing_effects.visible,"F clears all pointer/effects")
	_mouse(false,null)
	_cast()
	_key(KEY_E,true)
	_check(game.fishing.snapshot().outcome == "early_reel","fresh recast requires new input, no stale hook")
	_key(KEY_E,false)
	for phase: String in ["waiting","bite","fighting"]:
		_phase(phase)
		game._present_fishing()
		await process_frame
		_pointer(view.cancel_button.get_global_rect().get_center())
		_click(view.cancel_button.get_global_rect().get_center())
		_check(game.fishing.mode() == "idle" and not game.fishing_effects.visible and not view._pointer_held,"actual Cancel pointer " + phase)
		game._present_fishing()
		_check(view.title.text.contains("Canceled") and view.instruction.text.contains("canceled"),"cancel result feedback " + phase)
	_phase("fighting")
	_mouse(true,view.reel_button)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(game.fishing.mode() == "idle" and not view.visible and not game.fishing_effects.visible and not view._pointer_held,"focus loss teardown")
	_mouse(false,null)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for id: String in FISH:
		_check(game.session.inventory.add(id,2).is_empty(),"synthetic bag fish " + id)
		game._toggle_backpack()
		game._select_inventory_item(id)
		game.ui.show_inventory(game.session.inventory.snapshot(),game.catalog)
		_check(ForagingItemVisual.icon(id) != null and ForagingItemVisual.icon(id).get_width() > 0,"source-derived icon " + id)
		var slot: int = game.ui.backpack.slot_ids.find(id)
		_check(slot >= 0 and game.ui.backpack.slots[slot].icon != null and game.ui.backpack.slots[slot].text.contains("2 / 99") and game.ui.backpack.slots[slot].button_pressed,"existing bag name/count/icon/selection " + id)
		_check(game.session.inventory.active_tool() == null and not game.ui.backpack.drop_button.visible and game.ui.backpack.details.text.contains("No direct use, drop or current gift recipient") and not game.ui.active_item_label.text.contains("Gift through conversation"),"fish no tool/drop/gift promise " + id)
		game._toggle_backpack()
	game.session.inventory.select(ForagingRegistry.ROD_ITEM)
	game.ui.show_inventory(game.session.inventory.snapshot(),game.catalog)
	_check(game.ui.active_item_label.text.contains("F: aim") and not game.catalog.get_item(ForagingRegistry.ROD_ITEM).description.contains("unavailable"),"public rod functionality help")
	var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
	bridge.game = game
	game.add_child(bridge)
	bridge.boot_id = "fs006"
	_check(bridge._validate({"boot_id":"fs006","steps":[{"op":"hold","keys":["F"],"duration_ms":70}]}).is_empty(),"debug bounded F support")
	for op: String in ["force_catch","rng","set_time","reward"]:
		_check(not bridge._validate({"boot_id":"fs006","steps":[{"op":op}]}).is_empty(),"no acceptance shortcut " + op)
	_check(bridge._observe().fishing == TestRunObservation.fishing(game),"bridge delegates detached read-only fishing")
	_check(not TestRunInteractionCapture._guard(game,"fishing-bite").is_empty(),"inactive/frozen phase capture refused")
	_key(KEY_ESCAPE)
	_check(not view.visible and not game.fishing_effects.visible and paused and game.ui.pause_overlay.visible,"pause hides result/effects")
	_check(not TestRunInteractionCapture._guard(game,"fishing-result").is_empty(),"paused result cannot masquerade as live phase")

func _mouse(down: bool, button: Button) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = button.get_global_rect().get_center() if button != null else Vector2(30,300)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	_pointer(event.position)
	root.push_input(event,true)
