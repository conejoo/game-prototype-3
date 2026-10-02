extends Node3D
## Persistent composition root. WorldHost replaces locations; Party persists.

@onready var camera_rig: PrototypeCameraRig = $CameraRig
@onready var player_placeholder: ActorPlaceholder = $Party/PlayerPlaceholder
@onready var ui: PrototypeUI = $UI
@onready var world_host: PrototypeWorldHost = $WorldHost
@onready var party: PrototypeParty = $Party

var session: GameSession = GameSession.new()
var catalog: ContentCatalog = ContentCatalog.new()
var window_focused: bool = true
var save_repository: SaveRepository = SaveRepository.new()
var loading_save: bool = false
var _pending_restore: GameSession
var dialogue: DialogueService = DialogueService.new()
var selected_interaction: PrototypeInteractable
var quests: QuestService = QuestService.new()
var journal_open: bool = false

@export var content_manifest: ContentManifest = preload("res://content/prototype_catalog.tres")
@export var initial_location_id: String = "prototype-alderwake"
@export var initial_spawn_id: String = "alderwake-start"


func _ready() -> void:
	get_tree().auto_accept_quit = false
	# Debug-only named slot isolates playtest files; normal runs use the main slot.
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--save-slot="):
				var slot: String = argument.trim_prefix("--save-slot=")
				if RegEx.create_from_string("^[A-Za-z0-9_-]{1,48}$").search(slot) == null:
					push_error("Invalid debug save slot name")
					get_tree().quit(1)
					return
				save_repository = SaveRepository.new("user://saves/playtest-" + slot + ".json")
	var errors: PackedStringArray = catalog.initialize(content_manifest)
	if errors.is_empty():
		errors = session.initialize(catalog, initial_location_id, initial_spawn_id, "prototype-hero")
	if not errors.is_empty():
		set_process(false)
		set_process_unhandled_input(false)
		for error: String in errors:
			push_error("Application initialization failed: %s" % error)
		get_tree().quit(1)
		return
	player_placeholder.initialize(session.actors[GameSession.PLAYER_INSTANCE_ID])
	quests.initialize(catalog, session)
	quests.changed.connect(_refresh_journal)
	dialogue.quest_command = _quest_command
	camera_rig.set_target(player_placeholder)
	player_placeholder.configure_controls(camera_rig, ui)
	ui.show_camera(camera_rig.description())
	ui.pause_requested.connect(_toggle_pause)
	ui.resume_requested.connect(_resume)
	ui.quit_requested.connect(_quit)
	ui.save_requested.connect(func() -> void: save_run())
	ui.load_requested.connect(func() -> void: await load_run())
	ui.dialogue_advance_requested.connect(func() -> void: _present_dialogue(dialogue.advance()))
	ui.dialogue_choice_requested.connect(func(id: String) -> void: _present_dialogue(dialogue.choose(id)))
	ui.dialogue_cancel_requested.connect(_cancel_dialogue)
	ui.journal_requested.connect(_toggle_journal)
	ui.show_paused(false)
	world_host.initialize(catalog, session, party)
	world_host.transition_started.connect(_on_transition_started)
	world_host.transition_finished.connect(_on_transition_finished)
	errors = world_host.request_transition(initial_location_id, initial_spawn_id)
	if not errors.is_empty():
		push_error("Initial location failed: " + "; ".join(errors))
		get_tree().quit(1)
		return
	var arrival: Array = await world_host.transition_finished
	if not arrival[0]:
		push_error("Initial placement failed: " + "; ".join(arrival[1]))
		get_tree().quit(1)
		return
	print("P001: GameRoot ready; WorldHost, Party, CameraRig, UI initialized.")
	print("P002: %d definitions validated; player instance '%s' initialized." % [catalog.definition_count(), player_placeholder.state.instance_id])
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--playtest-dir="):
				var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
				bridge.name = "LivePlaytestBridge"
				add_child(bridge)
				bridge.start(self, argument.trim_prefix("--playtest-dir="))


func _process(delta: float) -> void:
	if not get_tree().paused and not world_host.transitioning:
		session.advance(delta)
		ui.show_play_time(session.elapsed_play_seconds)
		_refresh_interaction()


func _input(event: InputEvent) -> void:
	if journal_open:
		if (event.is_action_pressed("pause") or event.is_action_pressed("journal")) and not event.is_echo():
			_toggle_journal()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and not event.is_action("quit"):
			if event.keycode not in [KEY_TAB, KEY_ENTER]:
				get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and not ui.journal_panel.get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
		return
	# Escape cancels dialogue even while a choice has GUI focus. World keys do
	# not reach actors; mouse clicks remain available to the modal's buttons.
	if dialogue.active():
		if event.is_action_pressed("pause") and not event.is_echo():
			_cancel_dialogue()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and not event.is_action("quit"):
			for action: String in ["move_left", "move_right", "move_forward", "move_back", "interact", "dodge", "camera_projection", "zoom_in", "zoom_out"]:
				if event.is_action(action):
					get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and not ui.dialogue_accepts_pointer(event.position):
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if (dialogue.active() or journal_open) and not event.is_action("quit"):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_toggle_pause()
	elif event.is_action_pressed("quit") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_quit()
	elif not get_tree().paused and not world_host.transitioning and window_focused and get_viewport().gui_get_focus_owner() == null:
		if event.is_action_pressed("interact") and not event.is_echo():
			interact()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("journal") and not event.is_echo():
			_toggle_journal()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and not ui.accepts_world_pointer(event.position):
			return
		if event.is_action_pressed("camera_projection") and not event.is_echo():
			camera_rig.toggle_projection()
		elif event.is_action_pressed("zoom_in"):
			camera_rig.zoom(1.0)
		elif event.is_action_pressed("zoom_out"):
			camera_rig.zoom(-1.0)
		else:
			return
		ui.show_camera(camera_rig.description())
		get_viewport().set_input_as_handled()
		if "--p003-evidence" in OS.get_cmdline_user_args():
			print("P003 camera: %s; player=%s" % [camera_rig.description(), player_placeholder.global_position])


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player_placeholder):
		window_focused = false
		_update_controls()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN and is_instance_valid(player_placeholder):
		window_focused = true
		_update_controls()


func _toggle_pause() -> void:
	_set_paused(not get_tree().paused)


func _resume() -> void:
	_set_paused(false)


func _set_paused(paused: bool) -> void:
	if loading_save or dialogue.active() or journal_open:
		return
	get_tree().paused = paused
	_update_controls()
	ui.show_paused(paused)
	print("P001: %s at play time %.2fs." % ["Paused" if paused else "Resumed", session.elapsed_play_seconds])


func _update_controls() -> void:
	player_placeholder.set_controls_enabled(window_focused and not get_tree().paused and not world_host.transitioning and not loading_save and not dialogue.active() and not journal_open)
	ui.set_save_busy(world_host.transitioning or loading_save or dialogue.active() or journal_open)


func _on_transition_started() -> void:
	journal_open = false
	ui.show_journal(false, "")
	_cancel_dialogue()
	selected_interaction = null
	ui.show_travel("Travelling…")
	_update_controls()


func _on_transition_finished(success: bool, errors: PackedStringArray) -> void:
	# Root commits candidate only after WorldHost proves physical placement safe.
	# This handler is connected before other observers; UI sees one restored run.
	var restoring: bool = _pending_restore != null
	if success and restoring:
		session = _pending_restore
		world_host.session = session
		player_placeholder.initialize(session.actors[GameSession.PLAYER_INSTANCE_ID])
		quests.initialize(catalog, session)
	_pending_restore = null
	camera_rig.set_target(player_placeholder)
	camera_rig.reset_physics_interpolation()
	_update_controls()
	if success:
		_configure_quest_fixture()
		if not restoring:
			quests.record_arrival(session.current_location_id)
		_refresh_journal()
		ui.show_location(catalog.get_location(session.current_location_id).display_name)
		_refresh_interaction()
	else:
		ui.show_travel("Travel failed: " + "; ".join(errors))


func _save_boundary_errors() -> PackedStringArray:
	if journal_open:
		return PackedStringArray(["close journal before save/load"])
	if dialogue.active():
		return PackedStringArray(["close dialogue before save/load"])
	if not session.initialized or world_host.current_location == null:
		return PackedStringArray(["run is not ready"])
	if world_host.transitioning or loading_save:
		return PackedStringArray(["save/load unavailable during transition"])
	if not get_tree().paused:
		return PackedStringArray(["pause first; save/load only at stable pause boundary"])
	return PackedStringArray()


func save_run() -> PackedStringArray:
	var errors: PackedStringArray = _save_boundary_errors()
	if errors.is_empty():
		errors = save_repository.write(session, catalog)
	ui.show_save_status("Saved. Load returns to last arrival anchor." if errors.is_empty() else "Save failed: " + "; ".join(errors))
	print("P005 save: ", "OK" if errors.is_empty() else errors)
	return errors


func _refresh_interaction() -> void:
	if dialogue.active() or journal_open:
		selected_interaction = null
		ui.show_travel("Journal open · J / Esc: close" if journal_open else "Dialogue open · Esc: close")
		return
	selected_interaction = InteractionSelector.select(player_placeholder, world_host.current_location)
	ui.show_travel("E: " + selected_interaction.prompt if selected_interaction != null else "Walk near purple companion, gold marker, or glowing gate")


func interact() -> DialogueService.ActionResult:
	if dialogue.active() or journal_open or get_tree().paused or world_host.transitioning or loading_save or not window_focused or get_viewport().gui_get_focus_owner() != null:
		return DialogueService.ActionResult.new(false, "Interaction blocked by current input mode.")
	# Never trust last frame's prompt or hold an old room's node after travel.
	var target: PrototypeInteractable = InteractionSelector.select(player_placeholder, world_host.current_location)
	if target == null:
		return DialogueService.ActionResult.new(false, "No nearby visible interaction.")
	if target.kind == "travel":
		var location: PrototypeLocation = world_host.current_location
		var errors: PackedStringArray = world_host.request_transition(location.destination_id, location.destination_spawn_id)
		var result: DialogueService.ActionResult = DialogueService.ActionResult.new(errors.is_empty(), "Travel started." if errors.is_empty() else "; ".join(errors), "travel")
		if not result.ok:
			ui.show_travel(result.message)
		return result
	var result: DialogueService.ActionResult = dialogue.begin(catalog.get_dialogue(target.dialogue_id), target.instance_id)
	_present_dialogue(result)
	return result


func _present_dialogue(result: DialogueService.ActionResult) -> void:
	ui.show_dialogue(dialogue, result)
	_update_controls()
	if not world_host.transitioning:
		_refresh_interaction()


func _cancel_dialogue() -> void:
	_present_dialogue(dialogue.cancel())


func load_run() -> PackedStringArray:
	var errors: PackedStringArray = _save_boundary_errors()
	if not errors.is_empty():
		ui.show_save_status("Load failed: " + "; ".join(errors))
		return errors
	var saved: SaveRepository.ReadResult = save_repository.read(catalog)
	if saved.session == null:
		ui.show_save_status("Load failed: " + "; ".join(saved.errors))
		print("P005 load rejected: ", saved.errors)
		return saved.errors
	loading_save = true
	_pending_restore = saved.session
	_update_controls()
	ui.show_save_status("Loading saved run…")
	errors = world_host.request_transition(saved.session.current_location_id, saved.session.current_spawn_id)
	if errors.is_empty():
		var arrival: Array = await world_host.transition_finished
		if not arrival[0]:
			errors = arrival[1]
	_pending_restore = null
	loading_save = false
	_update_controls()
	ui.show_play_time(session.elapsed_play_seconds)
	var message: String = "Recovered backup. Primary left unchanged." if saved.recovered else "Loaded saved run at arrival anchor."
	if saved.migrated:
		message += " Migrated v1: quest unstarted; Save writes v2."
	ui.show_save_status(message if errors.is_empty() else "Load failed: " + "; ".join(errors))
	print("P005 load: ", message if errors.is_empty() else errors)
	return errors


func _quit() -> void:
	print("P001: Quit requested%s." % [" while paused" if get_tree().paused else ""])
	get_tree().quit(0)


func _quest_command(quest_id: String, action_id: String, source_id: String) -> DialogueService.ActionResult:
	if world_host.transitioning or loading_save or get_tree().paused or not dialogue.active():
		return DialogueService.ActionResult.new(false, "Quest command blocked by input mode.", action_id)
	var exists: bool = false
	for target: PrototypeInteractable in world_host.current_location.interactables():
		if target.instance_id == source_id and target.dialogue_id == dialogue.definition.stable_id:
			exists = true
	if not exists:
		return DialogueService.ActionResult.new(false, "Quest source unloaded.", action_id)
	return quests.apply(quest_id, action_id, session.current_location_id, source_id)


func _refresh_journal() -> void:
	ui.show_objective(quests.objective("prototype-maris-recovery"))
	if journal_open:
		ui.show_journal(true, quests.journal())


func _toggle_journal() -> void:
	if dialogue.active() or get_tree().paused or world_host.transitioning or loading_save:
		return
	journal_open = not journal_open
	ui.show_journal(journal_open, quests.journal())
	_update_controls()
	_refresh_interaction()


func _configure_quest_fixture() -> void:
	# Explicit, debug-only simulated objective. No fact mutation on boot/load.
	if session.current_location_id != "prototype-tollworks" or not OS.is_debug_build() or "--quest-test-fixtures" not in OS.get_cmdline_user_args():
		return
	var fixture: PrototypeInteractable = preload("res://features/interaction/prop_interaction.tscn").instantiate()
	fixture.name = "GuardianTestFixture"
	fixture.instance_id = "prototype-guardian-test"
	fixture.dialogue_id = "prototype-guardian-test-dialogue"
	fixture.prompt = "TEST ONLY: simulate guardian clearance (P008 pending)"
	fixture.position = Vector3(-4, 0, 3)
	fixture.get_node("Sign").text = "TEST ONLY\nGuardian clearance"
	world_host.current_location.add_child(fixture)
