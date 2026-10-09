extends SceneTree
## UI fixtures only: real root/modal/GUI; no ordinary villager placement/route claim.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var captures: Array[Dictionary] = []
var rendered: bool = false

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	rendered = DisplayServer.get_name() != "headless"
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	game.routine_execution = null # Explicit test-room portrait/modal fixtures, no live contacts.
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "Actual root startup")
	for frame: int in range(4): await process_frame
	for id: String in NpcContentCatalog.ROSTER:
		await _person(id)
	await _scroll_and_exit()
	await _lifecycle()
	game._set_paused(true)
	_check(paused and game.ui.pause_overlay.visible, "Verified final pause")
	_check(TestRunEvidence.write_json("npc-dialogue-ui.json", {"assertions":assertions, "failures":failures, "kind":"synthetic UI fixtures with real viewport input", "rendered":rendered, "views":captures, "engine_pid":OS.get_process_id(), "viewport_sizes":[[960,640],[1440,900]], "schema":SaveCodec.SCHEMA_VERSION}), "Evidence write")
	paused = false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	if failures.is_empty(): print("N005_UI PASS assertions=", assertions, " portraits=48 people=8 captures=", captures.size(), " rendered=", rendered)
	quit(0 if failures.is_empty() else 1)

func _person(id: String) -> void:
	var npc: NpcDefinition = game.npc_catalog.get_npc(id)
	_key(KEY_W, true)
	_check(not game.player_placeholder.movement_buttons.is_empty(), id + " held movement accepted before open")
	var result: NpcDialogueService.Result = game.dialogue.begin(id, "n005-fixture-" + id)
	_check(result.ok, id + " source entry")
	game._present_dialogue(result)
	_key(KEY_W, false)
	await process_frame
	var view: Dictionary = game.dialogue.snapshot()
	_check(game.ui.dialogue_view.portrait.texture.resource_path == view.portrait_path and game.ui.dialogue_text.get_parsed_text() == view.text.replace("**", "") and game.ui.dialogue_title.text == npc.display_name, id + " actual node portrait/body/speaker")
	_check(game.player_placeholder.movement_buttons.is_empty() and game.player_placeholder.velocity == Vector3.ZERO and not game.player_placeholder.controls_enabled and not game.companion_ai.enabled, id + " open clears controls/AI")
	_check(game.ui.dialogue_view.portrait.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and game.ui.dialogue_view.portrait.size.is_equal_approx(Vector2(184,184)), id + " square unstretched portrait")
	_assert_facts(id)
	await _capture(id + "-introduction", "Actual source node, portrait, choices and only disclosed public facts; synthetic contact binding.")
	# View all six owned byte-exact source portraits; override display only, no memory.
	for expression: String in npc.portraits:
		var display: Dictionary = view.duplicate(true)
		display.portrait_id = expression
		display.portrait_path = npc.portraits[expression]
		game.ui.show_dialogue(display, NpcDialogueService.Result.new(true, "Portrait review fixture"))
		await process_frame
		var texture: Texture2D = game.ui.dialogue_view.portrait.texture
		_check(texture != null and texture.get_size() == Vector2(512,512) and texture.resource_path == display.portrait_path, id + " source expression " + expression)
		await _capture(id + "-" + expression, "Display-only expression review; real source PNG, synthetic portrait selection; no gameplay mutation.")
	game._present_dialogue(NpcDialogueService.Result.new(true, "Choose an authored introduction."))
	var before: Dictionary = game.session.conversations.snapshot()
	await _blocked_inputs()
	_check(game.session.conversations.snapshot() == before, id + " blocked keys/mouse mutate no memory")
	var first: Button = game.ui.dialogue_choices.get_child(0)
	first.grab_focus()
	_key(KEY_ENTER)
	await process_frame
	_check(game.dialogue.active() and game.dialogue.snapshot().node_id != view.node_id and game.session.conversations.memory(id).affinity == 1, id + " Enter chooses real authored branch")
	var accepted: Dictionary = game.session.conversations.snapshot()
	_check(not game._choose_dialogue(view.choices[0].id, view).ok and game.session.conversations.snapshot() == accepted, id + " stale GUI command cannot replay")
	_check(game.player_placeholder.movement_buttons.is_empty(), id + " node change clears controls")
	_key(KEY_ESCAPE)
	await process_frame
	_check(not game.dialogue.active() and game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null and not paused, id + " Esc closes without pause/input lock")
	_check(game.session.conversations.snapshot() == accepted, id + " Close applies no reward")
	result = game.dialogue.begin(id, "n005-fixture-" + id)
	game._present_dialogue(result)
	await process_frame
	_check(result.ok and game.dialogue.snapshot().node_id != view.node_id, id + " remembered reopen")
	# Source follow-up disclosure selected through pointer GUI where available.
	for button: Node in game.ui.dialogue_choices.get_children():
		if button is Button and not button.disabled:
			await _click(button.get_global_rect().get_center())
			break
	_assert_facts(id)
	await _capture(id + "-revisit-facts", "Remembered source conversation and authored branch/fact display; ordinary GUI input on synthetic binding.")
	_check(not game.ui.dialogue_view.facts.get_parsed_text().contains("archive-practice"), id + " no deferred archival disclosure")
	game._cancel_dialogue()
	await process_frame

func _assert_facts(id: String) -> void:
	var view: Dictionary = game.dialogue.snapshot()
	var memory: ConversationMemory = game.session.conversations.memory(id)
	var ids: PackedStringArray = []
	for fact: Dictionary in view.facts: ids.append(fact.id)
	_check(ids == memory.learned_fact_ids, id + " facts exactly authoritative learned IDs")
	var npc: NpcDefinition = game.npc_catalog.get_npc(id)
	for fact: NpcDefinition.Fact in npc.facts.values():
		_check(game.ui.dialogue_view.facts.get_parsed_text().contains(fact.description) == (fact.id in ids), id + " fact text inclusion " + fact.id)
	_check(game.ui.dialogue_text.get_parsed_text() == view.text.replace("**", ""), id + " formatting preserves authored words and literal brackets")
	for fact: Dictionary in view.facts:
		if fact.id in view.revealed_fact_ids and view.text.findn(fact.highlight_term) >= 0:
			_check(fact.highlight_term in game.ui.dialogue_view.highlighted_terms, id + " disclosed fact highlight")

func _blocked_inputs() -> void:
	var position: Vector3 = game.player_placeholder.position
	var camera: Dictionary = TestRunObservation.camera(game)
	for code: int in [KEY_W,KEY_D,KEY_E,KEY_SPACE,KEY_P,KEY_EQUAL,KEY_MINUS,KEY_J,KEY_B,KEY_R,KEY_F6]: _key(code)
	await _click(Vector2(8,350))
	for index: int in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = Vector2(8,350)
		event.button_index = index
		event.pressed = true
		root.push_input(event,true)
	for frame: int in range(3): await physics_frame
	_check(game.player_placeholder.position.is_equal_approx(position) and not game.player_placeholder.combat.busy(), "Dialogue blocks movement/attack/dodge")
	_check(TestRunObservation.camera(game) == camera and not game.foraging_hold.active() and not game.item_drag.active() and not game.backpack_open and not game.journal_open, "Dialogue blocks zoom/projection/gather/drag/other modals")
	_check(not game.interact().ok and not game._advance_debug_hour(), "Dialogue blocks world commands")
	game._set_paused(true)
	_check(not paused, "Dialogue prevents pause stacking")
	paused = true
	_check(not game.save_run().is_empty() and not (await game.load_run()).is_empty(), "Dialogue unsaveable even forced pause")
	paused = false
	for step: int in range(9):
		_key(KEY_TAB)
		var focus: Control = root.gui_get_focus_owner()
		_check(focus != null and game.ui.dialogue_panel.is_ancestor_of(focus), "Tab stays inside conversation")

func _scroll_and_exit() -> void:
	# Pathological length fixture exercises bounded layout, not source story content.
	var content: ConversationDefinition = game.catalog.get_dialogue("prototype-marker-inspection").duplicate(true)
	TestRunConversation.mutate(content, func(data: Dictionary) -> void:
		data.nodes[0].text = ("[Literal authored brackets] " + "Long dialogue with readable wrapping. ".repeat(95)).strip_edges()
		for choice: Dictionary in data.nodes[0].choices:
			choice.text = "Long selectable response. ".repeat(18).strip_edges()
	)
	var opened: NpcDialogueService.Result = game.dialogue.begin_graph(content, "n005-length-fixture")
	_check(opened.ok, "Long finite fixture accepted")
	if not opened.ok: return
	game._present_dialogue(opened)
	for frame: int in range(4): await process_frame
	_check(root.get_visible_rect().encloses(game.ui.dialogue_panel.get_global_rect()), "960x640 long panel fits")
	_check(game.ui.dialogue_text.get_v_scroll_bar().max_value > game.ui.dialogue_text.get_v_scroll_bar().page and game.ui.dialogue_view.choice_scroll.get_v_scroll_bar().max_value > game.ui.dialogue_view.choice_scroll.get_v_scroll_bar().page, "Long body/choices independently scroll")
	game.ui.dialogue_text.scroll_to_line(game.ui.dialogue_text.get_line_count()-1)
	game.ui.dialogue_choices.get_child(1).grab_focus()
	await _capture("long-text-960", "Synthetic long text/response fixture, scrolled ending; literal brackets preserved.")
	root.size = Vector2i(1440,900)
	for frame: int in range(4): await process_frame
	_check(root.get_visible_rect().encloses(game.ui.dialogue_panel.get_global_rect()), "1440x900 panel fits")
	await _capture("long-text-1440", "Same long fixture at larger viewport; bounded centered modal with visible exits.")
	game._cancel_dialogue()
	root.size = Vector2i(960,640)
	for frame: int in range(3): await process_frame
	# Real Edric follow-up has no owned gift item; Continue and Close work.
	var opened_npc: NpcDialogueService.Result = game.dialogue.begin("npc-01", "n005-fixture-npc-01")
	game._present_dialogue(opened_npc)
	_check(opened_npc.ok and game.dialogue.snapshot().can_continue and game.ui.dialogue_next.visible, "No enabled choices has valid Continue exit")
	var disabled: int = 0
	for button: Button in game.ui.dialogue_choices.get_children():
		if button.disabled: disabled += 1
	_check(disabled > 0, "Missing owned gift item visible honestly unavailable")
	for choice: Dictionary in game.dialogue.snapshot().choices:
		_check(choice.available or choice.reason == "No owned Moonflower.", "Gift UI explains missing owned item")
	await _capture("missing-item-gift-close", "Actual Edric missing-item gift with Continue/Close and no fabricated inventory transaction.")
	var state: Dictionary = game.session.conversations.snapshot()
	# Both keyboard directions and pointer exits work with every choice disabled.
	_key(KEY_TAB)
	_check(root.gui_get_focus_owner() == game.ui.dialogue_close, "Tab reaches Close past unavailable gift")
	_key(KEY_LEFT)
	_check(root.gui_get_focus_owner() == game.ui.dialogue_next, "Arrow returns to Continue past unavailable gift")
	var reverse: InputEventKey = InputEventKey.new()
	reverse.keycode = KEY_TAB
	reverse.physical_keycode = KEY_TAB
	reverse.shift_pressed = true
	reverse.pressed = true
	root.push_input(reverse, true)
	reverse = reverse.duplicate()
	reverse.pressed = false
	root.push_input(reverse, true)
	_check(root.gui_get_focus_owner() == game.ui.dialogue_close, "Shift-Tab stays within unavailable-only conversation")
	await _click(game.ui.dialogue_choices.get_child(0).get_global_rect().get_center())
	_check(game.dialogue.active() and state == game.session.conversations.snapshot(), "Pointer cannot transact disabled gift")
	await _click(game.ui.dialogue_close.get_global_rect().get_center())
	_check(not game.dialogue.active() and game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null and state == game.session.conversations.snapshot(), "Mouse Close exits unavailable-only node without effects or lock")
	game._present_dialogue(game.dialogue.begin("npc-01", "n005-fixture-npc-01"))
	_key(KEY_ESCAPE)
	await process_frame
	_check(not game.dialogue.active() and state == game.session.conversations.snapshot(), "Esc exits unavailable-only node without effects")
	game._present_dialogue(game.dialogue.begin("npc-01", "n005-fixture-npc-01"))
	game.ui.dialogue_next.grab_focus()
	_key(KEY_ENTER)
	await process_frame
	_check(not game.dialogue.active() and state == game.session.conversations.snapshot(), "Continue exits unavailable-only node without effects")

func _lifecycle() -> void:
	# Existing recovery composition displays Maris's previously disclosed ordinary
	# facts, while its quest flow cannot grant NPC facts/affinity.
	var prior: Dictionary = game.session.conversations.snapshot()
	var opened: NpcDialogueService.Result = game.dialogue.begin_graph(game.catalog.get_dialogue("prototype-maris-counter"), "n005-counter-fixture")
	game._present_dialogue(opened)
	_assert_facts("npc-03")
	await _capture("maris-counter-existing-flow", "Existing recovery graph/quest choices with Maris portrait and same person's remembered facts; synthetic binding.")
	_check(game.session.conversations.snapshot() == prior and not game._choose_dialogue("maris-lead-choice").ok, "Prototype binding cannot fabricate legal quest source or change NPC memory")
	game._cancel_dialogue()
	game._present_dialogue(game.dialogue.begin("npc-14", "n005-fixture-npc-14"))
	var state: Dictionary = game.session.conversations.snapshot()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not game.dialogue.active() and not game.ui.dialogue_overlay.visible and not game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null and game.session.conversations.snapshot() == state, "Focus loss cancels safely without effects")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(game.player_placeholder.controls_enabled and game.player_placeholder.movement_buttons.is_empty(), "Focus gain requires fresh controls")
	game._present_dialogue(game.dialogue.begin("npc-03", "n005-fixture-npc-03"))
	state = game.session.conversations.snapshot()
	game.world_host.request_transition("prototype-test-room", "prototype-start")
	await game.world_host.transition_finished
	_check(not game.dialogue.active() and not game.ui.dialogue_overlay.visible and game.player_placeholder.controls_enabled and game.session.conversations.snapshot() == state, "Unload cancels cursor; memory persists without rewards")
	# Current schema manual round trip with disclosed UI memories (isolated slot).
	game._set_paused(true)
	_check(game.save_run().is_empty(), "Closed dialogue can manually Save")
	var old: GameSession = game.session
	_check((await game.load_run()).is_empty() and game.session != old and game.session.conversations.snapshot() == state and not game.dialogue.active(), "Manual Load binds exact memories to inactive cursor")
	game._set_paused(false)

func _capture(label: String, note: String) -> void:
	if not rendered: return
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,label,TestRunEvidence.directory(),"synthetic",note)
	captures.append(result)
	_check(result.ok, "Capture " + label + ": " + result.get("error", ""))

func _key(code: int, pressed: Variant = null) -> void:
	var states: Array = [true,false] if pressed == null else [pressed]
	for value: bool in states:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = value
		root.push_input(event,true)

func _click(point: Vector2) -> void:
	for value: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = value
		root.push_input(event,true)
	await process_frame

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok:
		failures.append(message)
		print("N005_ASSERTION_FAILED ", message)
