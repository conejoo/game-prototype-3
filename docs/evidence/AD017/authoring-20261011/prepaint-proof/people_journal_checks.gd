extends SceneTree
## Synthetic social and lifecycle setup; production root and actual viewport input.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var captures: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960, 640)
	game = load("res://app/game_root.tscn").instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "root startup")
	game.set_process(false) # Exact synthetic state comparisons; policy checked separately.
	await _empty_and_modal()
	await _people()
	await _lifecycle()
	_check(TestRunEvidence.write_json("people-journal.json", {"task":"G007", "proof":"synthetic social/lifecycle/long-fact fixtures; actual production root and viewport input", "assertions":assertions+1, "failures":failures, "views":captures, "rendered":DisplayServer.get_name() != "headless"}), "write evidence")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("G007 people_journal_checks ", "PASS" if failures.is_empty() else "FAIL", " assertions=", assertions, " captures=", captures.size())
	quit(0 if failures.is_empty() else 1)

func _empty_and_modal() -> void:
	var social: Dictionary = game.session.conversations.snapshot()
	_key(KEY_W, true)
	_key(KEY_J)
	_check(game.journal_open and game.ui.journal_tab == "quests", "J opens existing quest journal")
	_check(game.ui.journal_text.text == game._journal_text() and game.ui.upgrade_button.visible, "quest/trust/upgrade retained")
	_check(game.player_placeholder.movement_buttons.is_empty() and not game.player_placeholder.controls_enabled and not game.companion_ai.enabled, "held actor input cleared")
	_key(KEY_W, false)
	await _click(game.ui.people_tab)
	_check(game.ui.people_view.rows.is_empty() and game.ui.people_view.empty.visible and game.ui.people_view.empty.text.contains("Meet someone"), "empty met-only hint")
	await _capture("empty-960")
	var position: Vector3 = game.player_placeholder.global_position
	var projection: int = game.camera_rig.camera.projection
	var zoom: float = game.camera_rig.camera.size
	for code: int in [KEY_W, KEY_SPACE, KEY_E, KEY_B, KEY_P, KEY_PLUS, KEY_MINUS, KEY_F6]: _key(code)
	_pointer(Vector2(500, 400), MOUSE_BUTTON_LEFT)
	_pointer(Vector2(500, 400), MOUSE_BUTTON_WHEEL_UP)
	await physics_frame
	_check(game.journal_open and not game.backpack_open and not game.dialogue.active() and not game.player_placeholder.combat.busy() and game.player_placeholder.global_position.is_equal_approx(position), "journal blocks actions/movement/bag/dialogue")
	_check(game.camera_rig.camera.projection == projection and game.camera_rig.camera.size == zoom, "journal blocks projection/zoom")
	_check(not game._save_boundary_errors().is_empty(), "journal blocks save/load boundary")
	game._set_paused(true)
	_check(not paused and not game.ui.pause_overlay.visible, "journal cannot overlap pause")
	var seconds: float = game.session.elapsed_play_seconds
	var day: float = game.session.environment.day_cycle_progress
	game._process(0.25)
	_check(game.session.elapsed_play_seconds > seconds and game.session.environment.day_cycle_progress > day and not paused, "journal preserves continuing simulation policy")
	_check(game.session.conversations.snapshot() == social, "opening and blocked input disclose nothing")
	_key(KEY_J)
	_check(not game.journal_open and game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null, "J exits and restores fresh controls")
	await _click(game.ui.people_button)
	_check(game.journal_open and game.ui.journal_tab == "people", "HUD opens People directly")
	_key(KEY_ESCAPE)
	_check(not game.journal_open, "Esc exit")
	_key(KEY_J)
	_check(game.ui.journal_tab == "quests", "fresh J defaults to quest tab")
	game.ui.journal_close.grab_focus()
	_key(KEY_ENTER)
	_check(not game.journal_open, "keyboard Close exit")
	game._present_dialogue(game.dialogue.begin("npc-01", "g007-entered-only"))
	game._cancel_dialogue()
	game._open_people()
	_check(game.ui.people_view.rows.size() == 1 and game.ui.people_view.facts.text.contains("No learned facts") and game.ui.people_view.relationship.text.contains("0 / 3"), "entered-only partial roster has no inferred facts")
	await _capture("met-no-facts")
	_key(KEY_ESCAPE)

func _people() -> void:
	var pair: Dictionary = {"catalog":game.npc_catalog, "session":game.session, "service":game.dialogue}
	for id: String in NpcContentCatalog.ROSTER:
		SocialSaveFixture.introduce(pair, id)
		SocialSaveFixture.preference(pair, id)
	game.session.inventory.add("item-moonflower", 2) # Synthetic two-gift progression.
	SocialSaveFixture.gift(pair, "npc-01")
	SocialSaveFixture.gift(pair, "npc-01")
	game._cancel_dialogue()
	var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	game._open_people()
	var view: PeopleJournalView = game.ui.people_view
	_check(view.rows.size() == 8, "all eight met independently")
	var names: Array[String] = []
	for row: Button in view.rows: names.append(row.text)
	var expected: Array[String] = []
	for person: Dictionary in PeopleSnapshot.from_state(game.session.conversations, game.npc_catalog).people: expected.append(person.display_name)
	_check(names == expected and view.rows[6].name == "npc-01", "authored name sort")
	for step: int in range(4): _key(KEY_TAB)
	_check(root.gui_get_focus_owner() == view.rows[1], "Tab reaches second person from opening Close")
	_key(KEY_ENTER)
	_check(view.selected_id == "npc-14", "Enter selects person without relationship command")
	for row: Button in view.rows:
		row.grab_focus()
		await _frames(3) # follow_focus scrolls the eight-person list before clicking.
		await _click(row)
		var person: Dictionary = PeopleSnapshot.person(game.session.conversations, game.npc_catalog, String(row.name))
		_check(view.selected_id == row.name and view.identity.text == person.display_name+"\n"+person.pronouns, "selected public identity "+row.name)
		_check(view.portrait.texture != null and view.portrait.texture.resource_path == person.portrait_path, "primary portrait "+row.name)
		_check(view.progress.value == person.progress and view.relationship.text.contains("%d / 3" % person.affinity), "authored progress "+row.name)
		for fact: Dictionary in person.facts:
			_check(view.facts.text.contains(fact.label) and view.facts.text.contains(fact.description) and view.facts.text.contains(fact.category.capitalize()), "only learned detail "+fact.id)
		_check(not view.facts.text.contains("Archive practice") and not view.facts.text.contains("River fishing"), "deferred facts excluded")
		await _capture("person-"+row.name)
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before, "selection/tab/capture never mutates durable state")
	view.select("npc-01")
	_check(view.relationship.text.contains("Reached") and view.relationship.text.contains("Acquaintance") and view.progress.value == 1, "Edric threshold without level2")
	_key(KEY_ESCAPE)
	game._open_people()
	_check(view.selected_id == "npc-08", "transient selection resets on reopen")
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before, "reopening cannot duplicate milestone/gifts/facts")
	# Long detached display fixture; no authored/catalog changes or disclosure claims.
	var snapshot: Dictionary = PeopleSnapshot.from_state(game.session.conversations, game.npc_catalog)
	snapshot.people[0].facts[0].description = "Long learned description for scrolling fixture. ".repeat(120)
	view.present(snapshot)
	for size: Vector2i in [Vector2i(960,640), Vector2i(1440,900)]:
		root.size = size
		await _frames(6)
		_check(root.get_visible_rect().encloses(game.ui.journal_panel.get_global_rect()) and root.get_visible_rect().encloses(game.ui.journal_close.get_global_rect()), "panel/exit fits actual "+str(root.get_visible_rect().size))
		_check(view.detail_scroll.get_v_scroll_bar().max_value > view.detail_scroll.get_v_scroll_bar().page, "long facts scroll")
		var scroll: float = view.detail_scroll.get_v_scroll_bar().value
		_pointer(view.detail_scroll.get_global_rect().get_center(), MOUSE_BUTTON_WHEEL_DOWN)
		await _frames(2)
		_check(view.detail_scroll.get_v_scroll_bar().value > scroll, "wheel scrolls detail")
		view.detail_scroll.grab_focus()
		_key(KEY_DOWN)
		_key(KEY_TAB)
		_check(root.gui_get_focus_owner() == game.ui.journal_close, "detail Tab reaches Close: "+str(root.gui_get_focus_owner()))
		await _capture("long-facts-"+str(size.x))
		_key(KEY_TAB, null, false, true)
		_check(root.gui_get_focus_owner() == view.detail_scroll, "Shift-Tab returns to detail: "+str(root.gui_get_focus_owner()))
		var controls: Array[Control] = [game.ui.quest_tab, game.ui.people_tab]
		controls.append_array(view.focus_controls())
		controls.append(game.ui.journal_close)
		game.ui.quest_tab.grab_focus()
		for control: Control in controls:
			_check(root.gui_get_focus_owner() == control, "contained tab cycle "+str(control.name))
			_key(KEY_TAB)
		_check(root.gui_get_focus_owner() == game.ui.quest_tab, "Tab wraps in journal")
		game.ui.journal_close.grab_focus()
		_key(KEY_ENTER)
		_check(not game.journal_open, "long view keyboard exit")
		game._open_people()
		view.present(snapshot)
	root.size = Vector2i(960,640)
	_key(KEY_ESCAPE)
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before, "long detached fixture never changes owner")
	# Existing preparation command remains operable through real journal button.
	_check(game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter").ok, "synthetic accepted quest lead")
	game._toggle_journal()
	await _capture("quest-upgrade")
	await _click(game.ui.upgrade_button)
	_check(ProgressionService.UPGRADE_ID in game.session.progression.upgrade_ids and game.player_placeholder.combat.damage == 40, "existing upgrade button works")
	_key(KEY_ESCAPE)

func _lifecycle() -> void:
	for mode: String in ["dialogue", "backpack", "pause", "travel", "load", "retry", "focus", "death"]:
		match mode:
			"dialogue": game._present_dialogue(game.dialogue.begin("npc-01", "g007-fixture"))
			"backpack": game._toggle_backpack()
			"pause": game._set_paused(true)
			"travel": game.world_host.transitioning = true
			"load": game.loading_save = true
			"retry": game.retrying = true
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"death": game.player_placeholder.state.health = 0
		game._open_people()
		_check(not game.journal_open, "cannot open during "+mode)
		match mode:
			"dialogue": game._cancel_dialogue()
			"backpack": game._close_backpack()
			"pause": game._set_paused(false)
			"travel": game.world_host.transitioning = false
			"load": game.loading_save = false
			"retry": game.retrying = false
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			"death": game.player_placeholder.state.health = game.player_placeholder.state.max_health
		game._update_controls()
	game._open_people()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not game.journal_open and not game.ui.journal_overlay.visible and not game.player_placeholder.controls_enabled, "focus loss closes journal/releases input")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null, "focus regain clean")
	game._open_people()
	game.player_placeholder.state.health = 0
	game._on_player_defeated(game.player_placeholder)
	_check(not game.journal_open and root.gui_get_focus_owner() == null, "death closes journal")
	game.player_placeholder.state.health = game.player_placeholder.state.max_health
	game._update_controls()
	game._open_people()
	var requested: PackedStringArray = game.world_host.request_transition("prototype-alderwake", "alderwake-start")
	_check(requested.is_empty(), "real travel request")
	if requested.is_empty():
		var arrived: Array = await game.world_host.transition_finished
		_check(arrived[0] and not game.journal_open and not game.ui.journal_overlay.visible and game.player_placeholder.controls_enabled, "unload/travel closes journal")
	# Actual pre-existing gather target with synthetic range/hold setup.
	var target: PrototypeInteractable
	for pickup: PrototypeInteractable in game.world_host.current_location.interactables():
		if pickup.instance_id == "moonflower-01": target = pickup
	_check(target != null, "hold target exists")
	if target != null:
		game.foraging_hold.start(target, game.session, 0.6)
		game._e_down = true
		game._open_people()
		_check(not game.foraging_hold.active() and not game.ui.gather_progress.visible, "journal cancels hold")
		_key(KEY_E, false)
		_key(KEY_ESCAPE)
	var rod: PrototypeInteractable
	for pickup: PrototypeInteractable in game.world_host.current_location.interactables():
		if pickup.foraging_action != null and pickup.foraging_action.resource_id == ForagingRegistry.ROD_RESOURCE: rod = pickup
	_check(rod != null, "authored rod for synthetic drag cancellation")
	if rod != null:
		var items: Dictionary = game.session.foraging.snapshot()
		game.item_drag.start(game.session, rod)
		game._drag_mouse_owned = true
		game._open_people()
		_check(not game.item_drag.active() and game.session.foraging.snapshot() == items, "journal cancels drag without placement mutation")
		_pointer(Vector2(500,400), MOUSE_BUTTON_LEFT)
		_check(not game._drag_mouse_owned and game.player_placeholder.pointer_position == Vector2(-1,-1), "trailing drag release consumed before fresh pointer input")
		_key(KEY_ESCAPE)
	# Journal cancellation of drag uses root's same owner cleanup, regression suite
	# also exercises production drag/hold validation.
	game._open_people()
	game._open_people()
	_check(game.journal_open and not game.backpack_open and not game.dialogue.active(), "repeated HUD request cannot overlap panels")
	# Explicit synthetic night/rain presentation, not ordinary time/weather proof.
	var weather: WeatherSchedule = WeatherSchedule.new()
	for seed: int in range(256):
		var sample: WeatherSchedule.Sample = weather.sample(seed, 2, 0.625)
		if sample.condition == WeatherSchedule.Condition.RAINY and sample.transition_progress >= 1.0:
			game.session.environment.day_index = 2
			game.session.environment.day_cycle_progress = 0.625
			game.session.environment.weather_seed = seed
			break
	game._present_environment()
	_check(game.session.environment.weather_sample().condition == WeatherSchedule.Condition.RAINY, "synthetic night/rain forecast selected")
	await _capture("night-rain-960")
	_key(KEY_ESCAPE)

func _frames(count: int) -> void:
	for frame: int in range(count): await process_frame

func _capture(label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	var result: Dictionary = await TestRunInteractionCapture.journal(game, label, TestRunEvidence.directory(), "synthetic", "Production journal/root; synthetic social/lifecycle and explicitly long detached text fixtures")
	_check(result.ok, result.get("error", "capture"))
	if result.ok: captures.append(result)

func _click(button: Button) -> void:
	await _frames(3)
	_pointer(button.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)
	await _frames(2)

func _pointer(point: Vector2, code: int) -> void:
	for down: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = code
		event.pressed = down
		root.push_input(event, true)

func _key(code: int, pressed: Variant = null, echo: bool = false, shift: bool = false) -> void:
	for down: bool in ([true, false] if pressed == null else [pressed]):
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		event.echo = echo
		event.shift_pressed = shift
		root.push_input(event, true)

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message); print("G007_ASSERTION_FAILED ", message)
