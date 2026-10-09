extends SceneTree
## Synthetic all-eight bag/event setup; real production snapshots, root and GUI input.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var captures: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	game.routine_execution = null # Explicit all-eight synthetic GUI bindings, no schedule claim.
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "root ready")
	game.set_process(false) # Exact rejection comparisons; synthetic UI fixture only.
	for id: String in NpcContentCatalog.ROSTER:
		await _recipient(id)
	await _long_view()
	_check(TestRunEvidence.write_json("social-gift-ui.json", {"task":"G005", "proof":"synthetic inventory/events with actual root/UI input", "assertions":assertions+1, "failures":failures, "views":captures, "rendered":DisplayServer.get_name() != "headless", "viewport_sizes":[[960,640],[1440,900]]}), "write report")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("G005 social_gift_ui_checks ", "PASS" if failures.is_empty() else "FAIL", " assertions=",assertions," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _recipient(id: String) -> void:
	var pair: Dictionary = {"catalog":game.npc_catalog, "session":game.session, "service":game.dialogue}
	SocialSaveFixture.introduce(pair,id)
	game._cancel_dialogue()
	game.session.inventory.add("item-moonflower",1)
	game._present_dialogue(game.dialogue.begin(id,"g005-fixture-"+id))
	var unknown_gift: Button = _gift_button()
	var required: String = game.npc_catalog.get_npc(id).gifts[id+"-moonflower-gift"].required_fact_id
	var learned: bool = required in game.session.conversations.memory(id).learned_fact_ids
	_check(unknown_gift != null and (not unknown_gift.disabled if learned else unknown_gift.disabled and unknown_gift.text.contains("Learn this person's preference first.")), id+" availability follows actual entered-node disclosure")
	await _scroll_to(unknown_gift)
	await _capture(id+"-preference-gate")
	game._cancel_dialogue()
	game.session.inventory.consume("item-moonflower")
	SocialSaveFixture.preference(pair,id)
	game._cancel_dialogue()
	var npc: NpcDefinition = game.npc_catalog.get_npc(id)
	game._present_dialogue(game.dialogue.begin(id,"g005-fixture-"+id))
	var view: Dictionary = game.dialogue.snapshot()
	_check(view.social.affinity == 1 and view.social.threshold == npc.level_one_affinity and view.social.level_label == npc.level_one_label, id+" authored threshold/label")
	var gift: Button = _gift_button()
	_check(gift != null and gift.disabled and gift.text.contains("No owned Moonflower."), id+" missing item reason")
	await _scroll_to(gift)
	await _capture(id+"-missing")
	game._cancel_dialogue()
	game.session.inventory.add("item-moonflower",3)
	game.session.inventory.select("item-moonflower")
	game._present_dialogue(game.dialogue.begin(id,"g005-fixture-"+id))
	for count: int in [1,2]:
		view = game.dialogue.snapshot()
		gift = _gift_button()
		_check(gift != null and not gift.disabled, id+" deliberate gift enabled")
		if gift == null: return
		var before: Dictionary = game.session.conversations.snapshot()
		var command: Dictionary = view.duplicate(true)
		var choice: String = gift.name
		# Two notifications from same old button represent a double-click command.
		if count == 1:
			gift.pressed.emit()
			gift.pressed.emit()
		else:
			gift.grab_focus()
			_key(KEY_ENTER)
		await process_frame
		_check(game.session.inventory.count("item-moonflower") == 3-count and game.session.conversations.memory(id).affinity == 1+count, id+" one consume/delta")
		_check(game.session.inventory.snapshot().active_item_id == "item-moonflower", id+" retain selected remaining flower")
		for other: String in NpcContentCatalog.ROSTER:
			if other != id: _check(game.session.conversations.memory(other).snapshot(3) == before.people[other], id+" recipient only "+other)
		_check(game.ui.dialogue_view.friendship.text.contains("%d / 3" % (1+count)) and game.ui.dialogue_view.friendship.text.contains("Backpack: %d" % (3-count)), id+" immediate progress/bag")
		_check(game.ui.dialogue_status.text.contains("Gifted Moonflower to "+npc.display_name) and game.ui.dialogue_status.text.contains("Friendship +1"), id+" feedback survives response node and duplicate rejection")
		_check(game.ui.backpack.slots[0].text.contains(str(3-count)+" / 99"), id+" root refreshes hidden bag immediately")
		var accepted: Dictionary = game.session.conversations.snapshot()
		_check(not game._choose_dialogue(choice,command).ok and game.session.conversations.snapshot() == accepted, id+" stale command no repeat")
		_key(KEY_ENTER,true,true)
		_key(KEY_ENTER,false)
		_check(game.dialogue.active() and game.session.conversations.snapshot() == accepted, id+" key repeat ignored at new node")
		await _capture(id+"-gift-"+str(count))
		# Detachment includes social display data; never a second authority.
		var detached: Dictionary = game.dialogue.snapshot()
		detached.social.affinity = 999
		_check(game.dialogue.snapshot().social.affinity == 1+count, id+" detached display")
		_key(KEY_ESCAPE)
		game._present_dialogue(game.dialogue.begin(id,"g005-fixture-"+id))
	_check(game.ui.dialogue_view.friendship.text.contains("Acquaintance") and game.ui.dialogue_view.friendship.text.contains("Reached"), id+" reached threshold no level2")
	gift = _gift_button()
	_check(gift != null and gift.disabled and gift.text.contains("Gift acceptance cap reached."), id+" cap reason with owned supply")
	await _scroll_to(gift)
	await _capture(id+"-cap")
	var state: Dictionary = game.session.conversations.snapshot()
	_key(KEY_TAB)
	_check(root.gui_get_focus_owner() != null and game.ui.dialogue_panel.is_ancestor_of(root.gui_get_focus_owner()), id+" focus contained past disabled gift")
	var exit_button: Button = game.ui.dialogue_next if game.dialogue.snapshot().can_continue else game.ui.dialogue_close
	exit_button.grab_focus()
	_key(KEY_ENTER)
	_check(not game.dialogue.active() and game.session.conversations.snapshot() == state, id+" visible Continue/Close exits cap node")
	game.session.inventory.consume("item-moonflower")
	_check(game.session.inventory.snapshot().active_item_id == null, id+" clean final selected unit fixture")

func _long_view() -> void:
	game._present_dialogue(game.dialogue.begin("npc-01","g005-length"))
	var display: Dictionary = game.dialogue.snapshot()
	display.choices[0].text = "Long authored response wrapping fixture. ".repeat(24)
	game.ui.show_dialogue(display,NpcDialogueService.Result.new(false,"No owned Moonflower."))
	for size: Vector2i in [Vector2i(960,640),Vector2i(1440,900)]:
		root.size = size
		for frame: int in range(5): await process_frame
		_check(root.get_visible_rect().encloses(game.ui.dialogue_panel.get_global_rect()), "long social panel fits "+str(size))
		_check(game.ui.dialogue_view.choice_scroll.get_v_scroll_bar().max_value > game.ui.dialogue_view.choice_scroll.get_v_scroll_bar().page, "long response scrolls "+str(size))
		game.ui.dialogue_close.grab_focus()
		await _capture("long-"+str(size.x))
		_check(root.get_visible_rect().encloses(game.ui.dialogue_close.get_global_rect()), "Close reachable "+str(size))
	_key(KEY_ENTER)
	_check(not game.dialogue.active(),"keyboard Close after long display")
	root.size = Vector2i(960,640)
	game._present_dialogue(game.dialogue.begin("npc-01","g005-focus"))
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not game.dialogue.active() and game.player_placeholder.movement_buttons.is_empty() and not game.player_placeholder.controls_enabled,"focus loss clears cursor/controls")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null,"focus regain needs fresh input")

func _gift_button() -> Button:
	var view: Dictionary = game.dialogue.snapshot()
	var npc: NpcDefinition = game.npc_catalog.get_npc(view.npc_id)
	for button: Button in game.ui.dialogue_choices.get_children():
		if not npc.graph.choices[String(button.name)].gift_rule_id.is_empty(): return button
	return null

func _scroll_to(button: Button) -> void:
	if button == null: return
	for frame: int in range(3): await process_frame
	var scroll: ScrollContainer = game.ui.dialogue_view.choice_scroll
	for step: int in range(20):
		if scroll.get_global_rect().encloses(button.get_global_rect()): break
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = scroll.get_global_rect().get_center()
		root.push_input(motion,true)
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = scroll.get_global_rect().get_center()
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		root.push_input(event,true)
		event = event.duplicate()
		event.pressed = false
		root.push_input(event,true)
		await process_frame
	_check(scroll.get_global_rect().encloses(button.get_global_rect()),"mouse wheel reveals full gift choice/rejection "+str(button.name)+" button="+str(button.get_global_rect())+" scroll="+str(scroll.get_global_rect())+" value="+str(scroll.scroll_vertical))

func _capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,label,TestRunEvidence.directory(),"synthetic","Production source graph/root/buttons; supplied items/events and long text explicitly synthetic")
	_check(result.ok,result.get("error","capture"))
	if result.ok: captures.append(result)

func _key(code: int, pressed: Variant = null, echo: bool = false) -> void:
	for down: bool in ([true,false] if pressed == null else [pressed]):
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		event.echo = echo
		root.push_input(event,true)

func _check(ok: bool,message: String) -> void:
	assertions += 1
	if not ok: failures.append(message); print("G005_ASSERTION_FAILED ",message)
