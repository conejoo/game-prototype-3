extends Node3D
## Persistent composition root. WorldHost replaces locations; Party persists.

@onready var camera_rig: PrototypeCameraRig = $CameraRig
@onready var player_placeholder: ActorPlaceholder = $Party/PlayerPlaceholder
@onready var ui: PrototypeUI = $UI
@onready var world_host: PrototypeWorldHost = $WorldHost
@onready var party: PrototypeParty = $Party

var session: GameSession = GameSession.new()
var catalog: ContentCatalog = ContentCatalog.new()
var npc_catalog: NpcContentCatalog = NpcContentCatalog.new()
var window_focused: bool = true
var save_repository: SaveRepository = SaveRepository.new()
var loading_save: bool = false
var _pending_restore: GameSession
var dialogue: NpcDialogueService = NpcDialogueService.new()
var conversation_result: NpcDialogueService.Result = NpcDialogueService.Result.new(true, "No conversation started.")
var selected_interaction: PrototypeInteractable
var quests: QuestService = QuestService.new()
var journal_open: bool = false
var backpack_open: bool = false
var relationships: RelationshipService = RelationshipService.new()
var progression: ProgressionService = ProgressionService.new()
var guardian: ActorPlaceholder
var guardian_ai: GuardianController
var retrying: bool = false
var companion: ActorPlaceholder
var companion_ai: CompanionController
var environment_presenter: EnvironmentPresenter
var light_feedback: String = ""
var light_feedback_until: float = 0.0
var light_feedback_instance_id: String = ""
var debug_shortcuts_enabled: bool = false
var environment_review: Node
var environment_review_namespace: String = ""
var foraging_hold: ForagingHoldController = ForagingHoldController.new()
var _e_down: bool = false
var _e_consumed: bool = false
var foraging_feedback: String = ""
var foraging_feedback_until: float = 0.0
var item_drag: WorldItemDrag = WorldItemDrag.new()
var drag_preview: Node3D
var _drag_pointer: Vector2 = Vector2(-1,-1)
var _drag_mouse_owned: bool = false

@export var content_manifest: ContentManifest = preload("res://content/prototype_catalog.tres")
@export var initial_location_id: String = "prototype-alderwake"
@export var initial_spawn_id: String = "alderwake-start"
@export var developer_fixtures: bool = false


func _ready() -> void:
	get_tree().auto_accept_quit = false
	ui.debug_mode_requested.connect(_set_debug_shortcuts_enabled)
	_set_debug_shortcuts_enabled("--debug-shortcuts" in OS.get_cmdline_user_args())
	world_host.developer_fixtures = OS.is_debug_build() and (developer_fixtures or "--developer-fixtures" in OS.get_cmdline_user_args())
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
		errors = npc_catalog.initialize_path(catalog)
	if errors.is_empty():
		errors = session.initialize(catalog, initial_location_id, initial_spawn_id, "prototype-hero", null, npc_catalog)
	if errors.is_empty():
		errors = dialogue.initialize(npc_catalog, session)
	if not errors.is_empty():
		set_process(false)
		set_process_unhandled_input(false)
		for error: String in errors:
			push_error("Application initialization failed: %s" % error)
		get_tree().quit(1)
		return
	# Review code lives outside release exports and is loaded only by opt-in.
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--environment-review="):
				environment_review_namespace = argument.trim_prefix("--environment-review=")
				if environment_review_namespace.is_empty():
					push_error("Review requires a nonempty isolated namespace")
					get_tree().quit(1)
					return
		if not environment_review_namespace.is_empty():
			environment_review = load("res://tests/environment_review.gd").new()
			environment_review.name = "EnvironmentReview"
			add_child(environment_review)
			errors = environment_review.initialize(self, environment_review_namespace)
			if not errors.is_empty():
				push_error("Review initialization failed: " + "; ".join(errors))
				get_tree().quit(1)
				return
	player_placeholder.initialize(session.actors[GameSession.PLAYER_INSTANCE_ID])
	environment_presenter = EnvironmentPresenter.new()
	environment_presenter.name = "EnvironmentPresenter"
	add_child(environment_presenter)
	environment_presenter.initialize($Sun, $WorldEnvironment)
	companion = preload("res://features/actors/companion.tscn").instantiate()
	party.add_child(companion)
	companion.initialize(session.actors[GameSession.COMPANION_INSTANCE_ID])
	player_placeholder.add_collision_exception_with(companion)
	companion.move_speed = 4.4
	companion.combat.damage = 10
	companion.combat.windup = 0.35
	companion.combat.recovery = 0.6
	companion_ai = CompanionController.new()
	companion_ai.actor = companion
	companion_ai.hero = player_placeholder
	companion.add_child(companion_ai)
	player_placeholder.defeated.connect(_on_player_defeated)
	quests.initialize(catalog, session)
	relationships.initialize(catalog, session)
	progression.initialize(catalog, session)
	relationships.changed.connect(_refresh_journal)
	progression.changed.connect(_refresh_progression)
	quests.changed.connect(_refresh_journal)
	quests.changed.connect(_refresh_world_presentation)
	dialogue.reaction_command = _reaction_command
	ui.upgrade_requested.connect(_select_upgrade)
	dialogue.quest_command = _quest_command
	camera_rig.set_target(player_placeholder)
	player_placeholder.configure_controls(camera_rig, ui)
	ui.show_camera(camera_rig.description())
	ui.pause_requested.connect(_toggle_pause)
	ui.resume_requested.connect(_resume)
	ui.quit_requested.connect(_quit)
	ui.save_requested.connect(func() -> void: save_run())
	ui.load_requested.connect(func() -> void: await load_run())
	ui.dialogue_advance_requested.connect(_advance_dialogue)
	ui.dialogue_choice_requested.connect(_choose_dialogue)
	ui.dialogue_cancel_requested.connect(_cancel_dialogue)
	ui.dialogue_view.counter_route_requested.connect(_switch_maris_route)
	ui.journal_requested.connect(_toggle_journal)
	ui.backpack_requested.connect(_toggle_backpack)
	ui.inventory_selection_requested.connect(_select_inventory_item)
	ui.backpack.drop_requested.connect(_drop_active_rod)
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
	if environment_review != null:
		_set_paused(true)
		environment_review.apply_preset(0, WeatherSchedule.Condition.SUNNY)
	if OS.is_debug_build():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--playtest-dir="):
				var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
				bridge.name = "LivePlaytestBridge"
				add_child(bridge)
				bridge.start(self, argument.trim_prefix("--playtest-dir="))


func _process(delta: float) -> void:
	if not session.initialized or player_placeholder.state == null:
		return
	_sync_npc_visuals()
	if world_host.current_location is AlderwakeTerrainPreview and not world_host.transitioning:
		(world_host.current_location as AlderwakeTerrainPreview).tree_art.update_visibility(camera_rig.camera, player_placeholder, companion)
	if not get_tree().paused and not world_host.transitioning and not loading_save and not retrying:
		session.advance(delta)
		if window_focused and player_placeholder.state.health > 0 and world_host.current_location != null:
			world_host.current_location.npc_events.observe(session, world_host.current_location, player_placeholder.global_position, dialogue)
		_present_environment()
		ui.show_play_time(session.elapsed_play_seconds)
		_refresh_interaction()
	_tick_item_drag()
	_tick_foraging_hold(delta)
	ui.show_inventory(session.inventory.snapshot(),catalog)
	ui.show_combat(player_placeholder.state, guardian, retrying, player_placeholder.combat.damage)
	ui.show_debug_time(session.environment.day_cycle_progress)
	if is_instance_valid(companion):
		ui.show_companion(companion.state, companion_ai.mode, session.relationship.trust)
	ui.set_save_busy(session.review_only or world_host.transitioning or loading_save or dialogue.active() or journal_open or backpack_open or not _combat_stable(), world_host.transitioning or loading_save)


func _input(event: InputEvent) -> void:
	# Observe releases even when GUI consumes input. A hold never rearms itself.
	if event.is_action_released("interact"):
		_e_down = false
		_e_consumed = false
		_cancel_foraging_hold("released")
	elif event.is_action_pressed("interact"):
		if _e_down or event.is_echo():
			get_viewport().set_input_as_handled()
			return
		_e_down = true
		if not _foraging_input_allowed(): _e_consumed = true
	if foraging_hold.active() and not _foraging_input_allowed():
		_cancel_foraging_hold("input mode")
	if _drag_mouse_owned and not item_drag.active() and (event is InputEventMouseMotion or event is InputEventMouseButton):
		player_placeholder.pointer_position = Vector2(-1,-1)
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_drag_mouse_owned = false
		get_viewport().set_input_as_handled()
		return
	if item_drag.active():
		if event.is_action_pressed("pause"):
			_cancel_item_drag()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("backpack") or event.is_action_pressed("journal"):
			_cancel_item_drag()
		elif not event.is_action("quit"):
			if event is InputEventMouseMotion:
				_drag_pointer = event.position
				_tick_item_drag()
			elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				_drag_pointer = event.position
				_finish_item_drag()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _foraging_input_allowed() and ui.accepts_world_pointer(event.position):
		var pickup: PrototypeInteractable = _rod_under_pointer(event.position)
		if pickup != null:
			_start_item_drag(pickup,event.position)
			get_viewport().set_input_as_handled()
			return
	if environment_review != null and environment_review.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("backpack") and not event.is_echo():
		_toggle_backpack()
		get_viewport().set_input_as_handled()
		return
	if backpack_open:
		if event.is_action_pressed("pause") and not event.is_echo():
			_close_backpack()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and not event.is_action("quit"):
			if event.keycode not in [KEY_TAB,KEY_ENTER,KEY_KP_ENTER,KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
				get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and (event.button_index != MOUSE_BUTTON_LEFT or not ui.backpack.panel.get_global_rect().has_point(event.position)):
			get_viewport().set_input_as_handled()
		return
	if ui.settings_open() and event.is_action_pressed("pause") and not event.is_echo():
		ui.show_settings(false)
		get_viewport().set_input_as_handled()
		return
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
	if event.is_action_pressed("retry") and not event.is_echo() and player_placeholder.state.health == 0:
		get_viewport().set_input_as_handled()
		retry_encounter()
		return
	if (dialogue.active() or journal_open or backpack_open) and not event.is_action("quit"):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_toggle_pause()
	elif event.is_action_pressed("quit") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_quit()
	elif event.is_action_pressed("debug_advance_hour") and not event.is_echo():
		if _advance_debug_hour():
			get_viewport().set_input_as_handled()
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


func _set_debug_shortcuts_enabled(enabled: bool) -> void:
	debug_shortcuts_enabled = enabled
	ui.show_debug_mode(enabled)
	ui.show_debug_time(session.environment.day_cycle_progress)


func _advance_debug_hour() -> bool:
	if not debug_shortcuts_enabled or not session.initialized or not player_placeholder.controls_enabled:
		return false
	if get_tree().paused or world_host.transitioning or loading_save or retrying or dialogue.active() or journal_open or backpack_open or not window_focused or get_viewport().gui_get_focus_owner() != null:
		return false
	# One game hour is 1/24 of the authored 600-second day. Skip only the
	# environment clock: play time, actor timers and quest facts remain intact.
	var errors: PackedStringArray = session.environment.advance(EnvironmentClock.CYCLE_SECONDS / 24.0)
	if errors.is_empty():
		_present_environment()
		ui.show_debug_time(session.environment.day_cycle_progress)
	else:
		ui.debug_label.text = "Debug · Time skip unavailable: " + "; ".join(errors)
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_quit()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player_placeholder):
		window_focused = false
		_cancel_dialogue()
		_update_controls()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN and is_instance_valid(player_placeholder):
		window_focused = true
		_update_controls()


func _toggle_pause() -> void:
	_set_paused(not get_tree().paused)


func _resume() -> void:
	_set_paused(false)


func _set_paused(paused: bool) -> void:
	if loading_save or dialogue.active() or journal_open or backpack_open:
		return
	_cancel_item_drag()
	get_tree().paused = paused
	_update_controls()
	ui.show_paused(paused)
	if paused:
		ui.show_save_status("No autosave. Save here; reopen and choose Load to continue." if _combat_stable() else "Combat paused. Resume and retreat, or R: retry after death; save/load locked.")
	print("P001: %s at play time %.2fs." % ["Paused" if paused else "Resumed", session.elapsed_play_seconds])


func _update_controls() -> void:
	_sync_npc_visuals()
	var enabled: bool = window_focused and not get_tree().paused and not world_host.transitioning and not loading_save and not dialogue.active() and not journal_open and not backpack_open
	if item_drag.active() and (not enabled or retrying or player_placeholder.state.health <= 0):
		_dispose_item_drag()
	enabled = enabled and not item_drag.active()
	if not enabled or player_placeholder.state.health <= 0:
		_cancel_foraging_hold("input mode")
	player_placeholder.set_controls_enabled(enabled and player_placeholder.state.health > 0)
	player_placeholder.combat_enabled = enabled
	if is_instance_valid(companion):
		companion.combat_enabled = enabled and player_placeholder.state.health > 0
		companion_ai.enabled = companion.combat_enabled
		if not companion_ai.enabled:
			companion.clear_input()
	if is_instance_valid(guardian):
		guardian.combat_enabled = enabled and player_placeholder.state.health > 0
		guardian_ai.enabled = guardian.combat_enabled
		if not guardian.combat_enabled:
			guardian.clear_input()
	ui.set_save_busy(session.review_only or world_host.transitioning or loading_save or dialogue.active() or journal_open or backpack_open or not _combat_stable(), world_host.transitioning or loading_save)

func _sync_npc_visuals() -> void:
	if world_host.current_location == null or not is_instance_valid(player_placeholder): return
	world_host.current_location.npc_contacts.sync_visuals({
		"dialogue":dialogue.active(), "pause":get_tree().paused, "focus":not window_focused,
		"travel":world_host.transitioning or loading_save or retrying,
		"modal":journal_open or backpack_open, "death":player_placeholder.state != null and player_placeholder.state.health <= 0
	}, dialogue.snapshot().get("npc_id", ""), player_placeholder.global_position)


func _on_transition_started() -> void:
	_cancel_item_drag()
	_close_backpack()
	_cancel_foraging_hold("travel")
	foraging_feedback = ""
	light_feedback = ""
	light_feedback_instance_id = ""
	companion_ai.reset_route()
	companion.combat_targets.clear()
	companion_ai.enemy = null
	player_placeholder.combat.cancel()
	player_placeholder.combat_targets.clear()
	if is_instance_valid(guardian):
		guardian.combat.cancel()
		guardian.combat_enabled = false
		guardian_ai.enabled = false
		guardian.clear_input()
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
		companion.initialize(session.actors[GameSession.COMPANION_INSTANCE_ID])
		quests.initialize(catalog, session)
		relationships.initialize(catalog, session)
		progression.initialize(catalog, session)
		# Bind restored durable memory; dialogue cursor is always fresh.
		dialogue.initialize(npc_catalog, session)
		_refresh_progression()
	_pending_restore = null
	camera_rig.set_target(player_placeholder)
	camera_rig.reset_physics_interpolation()
	# Apply committed lighting and rain frustum at the new camera before drawing.
	# Failed transitions retain the previous session/profile, including failed loads.
	_present_environment()
	companion_ai.reset_route()
	for actor: ActorPlaceholder in party.members():
		actor.floor_snap_length = 0.04 if world_host.current_location is AlderwakeTerrainPreview else 0.1
		actor.floor_contact_height = _exterior_floor_height.bind(actor) if world_host.current_location is AlderwakeTerrainPreview else Callable()
	_update_controls()
	if success:
		guardian = null
		guardian_ai = null
		if not restoring:
			quests.record_arrival(session.current_location_id)
		_configure_guardian()
		_refresh_combat_targets()
		_update_controls()
		_refresh_journal()
		world_host.current_location.bind_foraging(session)
		session.foraging.bind_placement_validator(_validate_live_placement.bind(weakref(session)))
		_refresh_world_presentation()
		ui.show_location(catalog.get_location(session.current_location_id).display_name)
		_refresh_interaction()
	else:
		_refresh_combat_targets()
		if is_instance_valid(guardian):
			player_placeholder.combat_targets = [guardian]
			_update_controls()
		ui.show_travel("Travel failed: " + "; ".join(errors))
	# A failed transition detached the old scene too; reconnect exactly one owner.
	if world_host.current_location != null:
		if not success: world_host.current_location.bind_foraging(session)
		world_host.current_location.npc_events.bind(session, world_host.current_location, player_placeholder.global_position)


func _present_environment() -> void:
	if environment_presenter != null and world_host.current_location != null and not world_host.transitioning and world_host.session == session and world_host.current_location.location_id == session.current_location_id:
		var definition: LocationDefinition = catalog.get_location(session.current_location_id)
		var environment: EnvironmentState = session.environment
		var seconds: float = (environment.day_index + environment.day_cycle_progress) * EnvironmentClock.CYCLE_SECONDS
		var forecast: WeatherSchedule.Sample = session.weather_conditions.sample()
		var weather: WeatherVisuals.Sample = WeatherVisuals.sample(forecast, environment.weather_seed, seconds)
		environment_presenter.present(definition.lighting_profile, environment.day_cycle_progress, weather)
		ui.show_environment(environment.day_cycle_progress, forecast.condition)
		if world_host.current_location is AlderwakeExterior:
			(world_host.current_location as AlderwakeExterior).world_rain.present(weather, camera_rig.camera)
			(world_host.current_location as AlderwakeExterior).exterior_lights.present(session.environment, player_placeholder.global_position)


func _save_boundary_errors() -> PackedStringArray:
	if session.review_only:
		return PackedStringArray(["developer environment review cannot Save/Load; restart without review flag for normal play"])
	if not _combat_stable():
		return PackedStringArray(["save/load requires living hero outside combat/action windows; retreat or retry first"])
	if backpack_open:
		return PackedStringArray(["close backpack before save/load"])
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
	ui.show_foraging_feedback("")
	if item_drag.active():
		selected_interaction = null
		ui.show_travel("Place rod: release mouse · Esc: cancel" if item_drag.errors.is_empty() else "Cannot place here · Release keeps original · Esc: cancel")
		ui.show_foraging_feedback("")
		return
	if dialogue.active() or journal_open or backpack_open:
		selected_interaction = null
		ui.show_travel("Backpack open · B / Esc: close" if backpack_open else "Journal open · J / Esc: close" if journal_open else "Dialogue open · Esc: close")
		return
	if not _combat_stable():
		selected_interaction = null
		ui.show_travel("Quest progress kept; retry restarts at last arrival anchor." if player_placeholder.state.health == 0 else "Click: attack · Space: dodge · Finish fight or retreat to interact / save")
		return
	selected_interaction = InteractionSelector.select(player_placeholder, world_host.current_location)
	ui.show_travel(("Hold E %.1fs: " % (catalog.get_resource(selected_interaction.foraging_action.resource_id).hold_milliseconds / 1000.0) if selected_interaction.foraging_action != null else "E: ") + selected_interaction.display_prompt(session.environment) if selected_interaction != null else "E near lamps / Chandlery Maris / purple station / forest Tollworks entrance" if session.current_location_id == "prototype-alderwake" else "E near southeast vessel / north return gate")
	if not foraging_feedback.is_empty() and session.elapsed_play_seconds < foraging_feedback_until:
		ui.show_foraging_feedback(foraging_feedback)
	else:
		ui.show_foraging_feedback("")
	if selected_interaction != null and selected_interaction.instance_id == light_feedback_instance_id and not light_feedback.is_empty() and session.elapsed_play_seconds < light_feedback_until:
		ui.show_travel(light_feedback + " · " + ui.travel_label.text)


func switch_light(target_reference: WeakRef, expected_enabled: bool) -> NpcDialogueService.Result:
	var target: PrototypeInteractable = target_reference.get_ref() as PrototypeInteractable if target_reference != null else null
	if item_drag.active() or not _combat_stable() or dialogue.active() or journal_open or backpack_open or get_tree().paused or world_host.transitioning or loading_save or not window_focused or get_viewport().gui_get_focus_owner() != null:
		return NpcDialogueService.Result.new(false, "Light switching blocked by current input mode.", "light")
	var location: PrototypeLocation = world_host.current_location
	if not is_instance_valid(target) or target.is_queued_for_deletion() or location == null or not target.is_inside_tree() or not location.is_ancestor_of(target) or InteractionSelector.select(player_placeholder, location) != target:
		return NpcDialogueService.Result.new(false, "Light target unloaded, stale or out of reach.", "light")
	if target.kind != "light" or target.light_action == null or not target.validation_errors(catalog).is_empty():
		return NpcDialogueService.Result.new(false, "Invalid light source interaction.", "light")
	var errors: PackedStringArray = session.toggle_light(target.light_action, expected_enabled)
	var message: String = "; ".join(errors)
	if errors.is_empty():
		message = "Lamp off." if expected_enabled else "Lamp on — ready for dusk." if ExteriorLights.night_factor(session.environment.day_cycle_progress) == 0.0 else "Lamp on."
		_present_environment()
	light_feedback = message
	light_feedback_instance_id = target.instance_id
	light_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()
	return NpcDialogueService.Result.new(errors.is_empty(), message, "light")


func interact() -> NpcDialogueService.Result:
	if _e_down and _e_consumed:
		return NpcDialogueService.Result.new(false, "Release E before another interaction.")
	if _e_down: _e_consumed = true
	if not _combat_stable():
		return NpcDialogueService.Result.new(false, "Finish combat or retreat before interaction.")
	if item_drag.active() or dialogue.active() or journal_open or backpack_open or get_tree().paused or world_host.transitioning or loading_save or not window_focused or get_viewport().gui_get_focus_owner() != null:
		return NpcDialogueService.Result.new(false, "Interaction blocked by current input mode.")
	# Never trust last frame's prompt or hold an old room's node after travel.
	var target: PrototypeInteractable = InteractionSelector.select(player_placeholder, world_host.current_location)
	if target == null:
		return NpcDialogueService.Result.new(false, "No nearby visible interaction.")
	if target.foraging_action != null:
		if not _e_down or not _foraging_input_allowed() or not target.validation_errors(catalog).is_empty():
			return NpcDialogueService.Result.new(false, "Press and hold E near the pickup.")
		var definition: ForagingResourceDefinition = catalog.get_resource(target.foraging_action.resource_id)
		foraging_feedback = ""
		ui.show_foraging_feedback("")
		foraging_hold.start(target, session, definition.hold_milliseconds / 1000.0)
		ui.show_foraging_progress(0, true)
		return NpcDialogueService.Result.new(true, "Hold started.", target.kind)
	if target.kind == "travel":
		var location: PrototypeLocation = world_host.current_location
		var errors: PackedStringArray = world_host.request_transition(location.destination_id, location.destination_spawn_id)
		var result: NpcDialogueService.Result = NpcDialogueService.Result.new(errors.is_empty(), "Travel started." if errors.is_empty() else "; ".join(errors), "travel")
		if not result.ok:
			ui.show_travel(result.message)
		return result
	if target.kind == "light":
		if target.light_action == null:
			return NpcDialogueService.Result.new(false, "Invalid light source interaction.", "light")
		var action: LightSwitchAction = target.light_action
		return switch_light(weakref(target), session.environment.light_enabled(action.location_id, action.prop_id, action.source_id))
	if not target.validation_errors(catalog).is_empty(): return NpcDialogueService.Result.new(false, "Invalid conversation contact.")
	var result: NpcDialogueService.Result = dialogue.begin(target.npc_id, target.instance_id) if not target.npc_id.is_empty() and not target is MarisCounter else dialogue.begin_graph(catalog.get_dialogue(target.dialogue_id), target.instance_id)
	_present_dialogue(result)
	return result


func _present_dialogue(result: NpcDialogueService.Result) -> void:
	conversation_result = result
	ui.show_dialogue(dialogue.snapshot(), result)
	_update_controls()
	if not world_host.transitioning:
		_refresh_interaction()


func _advance_dialogue(command: Dictionary = {}) -> NpcDialogueService.Result:
	var view: Dictionary = dialogue.snapshot() if command.is_empty() else command
	if not _dialogue_command_allowed(view): return NpcDialogueService.Result.new(false, "Conversation input unavailable.")
	var result: NpcDialogueService.Result = dialogue.advance(view.npc_id, view.instance_id, view.node_id, view.token)
	_present_dialogue(result)
	return result


func _choose_dialogue(id: String, command: Dictionary = {}) -> NpcDialogueService.Result:
	var view: Dictionary = dialogue.snapshot() if command.is_empty() else command
	if not _dialogue_command_allowed(view): return NpcDialogueService.Result.new(false, "Conversation input unavailable.")
	var result: NpcDialogueService.Result = dialogue.choose(view.npc_id, view.instance_id, view.node_id, view.token, id)
	_present_dialogue(result)
	return result


func _dialogue_command_allowed(view: Dictionary) -> bool:
	return not view.is_empty() and window_focused and not get_tree().paused and not world_host.transitioning and not loading_save and not retrying


func _switch_maris_route(command: Dictionary) -> NpcDialogueService.Result:
	var current: Dictionary = dialogue.snapshot()
	if not _dialogue_command_allowed(command) or current.is_empty() or command != current or current.npc_id != "npc-03" or current.instance_id != "npc-03-counter":
		return NpcDialogueService.Result.new(false, "Stale or unavailable counter route.")
	var counter: MarisCounter = world_host.current_location.get_node_or_null("MarisCounter") as MarisCounter
	if counter == null or world_host.current_location.npc_contacts.targets.get("npc-03") != counter or InteractionSelector.select(player_placeholder, world_host.current_location) != counter:
		return NpcDialogueService.Result.new(false, "Counter contact unavailable.")
	# Same live person/cursor; routing grants no quest, inventory or trust effect.
	var ordinary: bool = current.graph_id != "npc-03"
	dialogue.cancel()
	var result: NpcDialogueService.Result = dialogue.begin("npc-03", counter.instance_id) if ordinary else dialogue.begin_graph(catalog.get_dialogue(counter.dialogue_id), counter.instance_id)
	_present_dialogue(result)
	return result


func _cancel_dialogue() -> void:
	dialogue.cancel()
	_present_dialogue(NpcDialogueService.Result.new(true, "Conversation closed."))


func load_run() -> PackedStringArray:
	_cancel_item_drag()
	_cancel_foraging_hold("load")
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
	errors = world_host.request_transition(saved.session.current_location_id, saved.session.current_spawn_id, saved.session)
	if errors.is_empty():
		var arrival: Array = await world_host.transition_finished
		if not arrival[0]:
			errors = arrival[1]
	_pending_restore = null
	loading_save = false
	_update_controls()
	ui.show_play_time(session.elapsed_play_seconds)
	var message: String = "Recovered backup. Primary left unchanged." if saved.recovered else "Loaded saved run at arrival anchor."
	ui.show_save_status(message if errors.is_empty() else "Load failed: " + "; ".join(errors))
	print("P005 load: ", message if errors.is_empty() else errors)
	return errors


func _quit() -> void:
	print("P001: Quit requested%s." % [" while paused" if get_tree().paused else ""])
	get_tree().quit(0)


func _quest_command(quest_id: String, action_id: String, source_id: String) -> NpcDialogueService.Result:
	if world_host.transitioning or loading_save or get_tree().paused or not dialogue.active() or not window_focused:
		return NpcDialogueService.Result.new(false, "Quest command blocked by input mode.", action_id)
	var exists: bool = false
	for target: PrototypeInteractable in world_host.current_location.interactables():
		if target.instance_id == source_id and target.dialogue_id == dialogue.snapshot().get("graph_id", ""):
			var definition: ConversationDefinition = catalog.get_dialogue(target.dialogue_id)
			for choice: NpcDialogueGraph.Choice in definition.graph().nodes[dialogue.snapshot().node_id].choices:
				if choice.command.get("quest_id", "") == quest_id and choice.command.get("action_id", "") == action_id: exists = true
	if not exists:
		return NpcDialogueService.Result.new(false, "Quest source unloaded.", action_id)
	return quests.apply(quest_id, action_id, session.current_location_id, source_id)


func _refresh_journal() -> void:
	var objective: String = quests.objective("prototype-maris-recovery")
	var definition: QuestDefinition = catalog.get_quest("prototype-maris-recovery")
	var count: int = session.quests[definition.stable_id].completed_step_ids.size()
	if count < definition.steps.size():
		var step: QuestStep = definition.steps[count]
		if step.source_id != "location-arrival" and step.location_id != session.current_location_id:
			objective = "E at %s: travel to %s for next objective." % ["forest Tollworks entrance" if session.current_location_id == "prototype-alderwake" else "north return gate", catalog.get_location(step.location_id).display_name]
	var optional: PackedStringArray = []
	if session.relationship.reaction_ids.is_empty():
		optional.append("purple station: companion choice")
	if progression.available_points() > 0:
		optional.append("J: spend preparation point")
	var hint: String = "Optional · " + " · ".join(optional) if not optional.is_empty() else "Esc: save outside combat · No autosave; reopen then Load"
	ui.show_objective(objective + "\n" + hint)
	if journal_open:
		ui.show_journal(true, _journal_text())
		ui.show_upgrade(progression)


func _refresh_world_presentation() -> void:
	if world_host.current_location == null:
		return
	for target: PrototypeInteractable in world_host.current_location.interactables():
		if target is MarisCounter:
			(target as MarisCounter).apply_facts(session.completed_effect_ids)


func _toggle_backpack() -> void:
	_cancel_item_drag()
	if backpack_open:
		_close_backpack()
		return
	if not session.initialized or not window_focused or get_tree().paused or world_host.transitioning or loading_save or retrying or dialogue.active() or journal_open or not _combat_stable():
		return
	backpack_open = true
	_cancel_foraging_hold("backpack")
	selected_interaction = null
	_update_controls()
	ui.show_inventory(session.inventory.snapshot(),catalog)
	ui.backpack.drop_available = true
	ui.backpack.open(session.inventory.snapshot(),catalog)
	ui.show_foraging_feedback("")
	ui.pause_button.disabled = true
	ui.journal_button.disabled = true
	ui.backpack_button.disabled = true
	ui.travel_label.hide()
	player_placeholder.pointer_position = Vector2(-1,-1)


func _close_backpack() -> void:
	if not backpack_open: return
	backpack_open = false
	ui.backpack.close()
	player_placeholder.pointer_position = Vector2(-1,-1)
	_update_controls()
	ui.pause_button.disabled = get_tree().paused or dialogue.active() or journal_open
	ui.journal_button.disabled = get_tree().paused or dialogue.active()
	ui.travel_label.visible = not get_tree().paused and not dialogue.active() and not journal_open
	ui.show_inventory(session.inventory.snapshot(),catalog)
	_refresh_interaction()


func _select_inventory_item(item_id: Variant) -> PackedStringArray:
	if not backpack_open or not window_focused or get_tree().paused or world_host.transitioning or loading_save or retrying or dialogue.active() or journal_open:
		return PackedStringArray(["inventory selection blocked by current input mode"])
	var errors: PackedStringArray = session.inventory.select(item_id)
	ui.backpack.present(session.inventory.snapshot(),catalog,true)
	ui.show_inventory(session.inventory.snapshot(),catalog)
	return errors


func _toggle_journal() -> void:
	_cancel_item_drag()
	if not journal_open and not _combat_stable():
		return
	if backpack_open or dialogue.active() or get_tree().paused or world_host.transitioning or loading_save:
		return
	journal_open = not journal_open
	ui.show_journal(journal_open, _journal_text())
	ui.show_upgrade(progression)
	_update_controls()
	_refresh_interaction()


func _configure_guardian() -> void:
	# Existing stable quest effect is the authoritative guardian instance fact.
	if session.current_location_id != "prototype-tollworks" or "maris-expedition-started" not in session.completed_effect_ids:
		return
	guardian = preload("res://features/combat/guardian.tscn").instantiate()
	world_host.current_location.add_child(guardian)
	guardian.global_position = Vector3(0, 0, 1.8)
	guardian.team = "guardian"
	guardian.move_speed = 2.0
	var guardian_state: ActorState = ActorState.new("tollworks-guardian-01", catalog.get_actor("prototype-guardian"))
	if "tollworks-guardian-cleared" in session.completed_effect_ids:
		guardian_state.health = 0
	guardian.initialize(guardian_state)
	guardian.combat.windup = 0.75
	guardian.combat.recovery = 0.85
	guardian.combat.reach = 2.0
	guardian.combat_targets = [player_placeholder]
	player_placeholder.combat_targets = [guardian]
	guardian.defeated.connect(_on_guardian_defeated)
	guardian_ai = GuardianController.new()
	guardian_ai.actor = guardian
	guardian_ai.target = player_placeholder
	guardian_ai.party_targets = party.members()
	guardian.add_child(guardian_ai)


func _refresh_combat_targets() -> void:
	companion_ai.enemy = guardian if is_instance_valid(guardian) else null
	companion.combat_targets.clear()
	player_placeholder.combat_targets.clear()
	if is_instance_valid(guardian):
		companion.combat_targets.append(guardian)
		player_placeholder.combat_targets.append(guardian)
		guardian.combat_targets = party.members()


func _combat_stable() -> bool:
	return player_placeholder.state != null and player_placeholder.state.health > 0 and not player_placeholder.combat.busy() and not retrying and (not is_instance_valid(companion) or (not companion.combat.busy() and not companion_ai.in_combat())) and not (is_instance_valid(guardian) and guardian.state.health > 0 and (guardian_ai.engaged or guardian.global_position.distance_to(player_placeholder.global_position) < 5.0))


func _on_guardian_defeated(actor: ActorPlaceholder) -> void:
	if actor != guardian or actor.state.health != 0 or session.current_location_id != "prototype-tollworks":
		return
	var result: NpcDialogueService.Result = quests.apply("prototype-maris-recovery", "maris-clear-guardian", session.current_location_id, actor.state.instance_id)
	if not result.ok:
		push_error("Guardian clearance failed: " + result.message)
	print("P008 guardian defeat: ", result.message)


func _on_player_defeated(_actor: ActorPlaceholder) -> void:
	_update_controls()
	print("P008 hero defeated; R retries at arrival anchor, quest facts retained.")


func retry_encounter() -> void:
	_cancel_item_drag()
	_close_backpack()
	_cancel_foraging_hold("retry")
	if player_placeholder.state.health > 0 or retrying or world_host.transitioning or loading_save:
		return
	retrying = true
	get_tree().paused = false
	ui.show_paused(false)
	var errors: PackedStringArray = world_host.request_transition(session.current_location_id, session.current_spawn_id)
	if errors.is_empty():
		var arrival: Array = await world_host.transition_finished
		if arrival[0]:
			player_placeholder.state.health = player_placeholder.state.max_health
			player_placeholder.initialize(player_placeholder.state)
			companion.state.health = companion.state.max_health
			companion.initialize(companion.state)
		else:
			ui.show_travel("Retry failed: " + "; ".join(arrival[1]))
			print("Retry placement rejected: " + "; ".join(arrival[1]))
	else:
		ui.show_travel("Retry failed: " + "; ".join(errors))
		print("Retry rejected: " + "; ".join(errors))
	retrying = false
	_update_controls()


func _reaction_command(id: String, source_id: String) -> NpcDialogueService.Result:
	if world_host.transitioning or loading_save or get_tree().paused or not dialogue.active() or not window_focused:
		return NpcDialogueService.Result.new(false, "Reaction blocked by input mode.")
	for target: PrototypeInteractable in world_host.current_location.interactables():
		if target.instance_id == source_id and target.dialogue_id == dialogue.snapshot().get("graph_id", ""):
			var definition: ConversationDefinition = catalog.get_dialogue(target.dialogue_id)
			for choice: NpcDialogueGraph.Choice in definition.graph().nodes[dialogue.snapshot().node_id].choices:
				if choice.command.get("reaction_id", "") == id:
					return relationships.apply(id)
	return NpcDialogueService.Result.new(false, "Reaction source/action unavailable.")

func _select_upgrade() -> void:
	if not journal_open or backpack_open or not window_focused or get_tree().paused or dialogue.active() or world_host.transitioning or loading_save or not _combat_stable():
		return
	var result: NpcDialogueService.Result = progression.select_upgrade(ProgressionService.UPGRADE_ID)
	_refresh_progression()
	ui.upgrade_status.text = result.message

func _refresh_progression() -> void:
	player_placeholder.combat.damage = progression.hero_damage()
	_refresh_journal()

func _journal_text() -> String:
	return quests.journal() + "\n\n" + relationships.description()


func _exterior_floor_height(feet: Vector3, actor: ActorPlaceholder) -> float:
	if not world_host.current_location is AlderwakeTerrainPreview:
		return NAN
	var space: PhysicsDirectSpaceState3D = actor.get_world_3d().direct_space_state
	var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(feet + Vector3.UP * 0.11, feet + Vector3.DOWN * 0.11, 1))
	if hit.is_empty() or hit.normal.y < 0.96 or not hit.collider.has_meta("candidate_walkable_floor"):
		return NAN
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = actor.get_node("CollisionShape3D").shape
	query.transform.origin = Vector3(feet.x, hit.position.y + 0.82, feet.z)
	query.collision_mask = 1
	return float(hit.position.y) if space.intersect_shape(query).is_empty() else NAN


func _foraging_input_allowed() -> bool:
	return not item_drag.active() and _drag_input_allowed()


func _drag_input_allowed() -> bool:
	return _combat_stable() and window_focused and not get_tree().paused and not world_host.transitioning and not loading_save and not retrying and not dialogue.active() and not journal_open and not backpack_open and not ui.settings_open() and get_viewport().gui_get_focus_owner() == null


func _validate_live_placement(candidate: WorldItemPlacement, _facts: Dictionary, owner: WeakRef) -> PackedStringArray:
	if owner.get_ref() != session or world_host.session != session or world_host.transitioning or loading_save or retrying or not window_focused or get_tree().paused or dialogue.active() or journal_open or not _combat_stable():
		return PackedStringArray(["placement input mode changed"])
	return ForagingPlacementGeometry.validate_nearby(world_host.current_location,candidate,player_placeholder)


func _drop_active_rod() -> void:
	if not backpack_open or not window_focused or get_tree().paused or world_host.transitioning or loading_save or retrying or dialogue.active() or journal_open or not _combat_stable() or session.inventory.snapshot().active_item_id != ForagingRegistry.ROD_ITEM:
		return
	var foot: Variant = ForagingPlacementGeometry.nearby_drop(world_host.current_location,player_placeholder)
	if foot == null:
		ui.backpack.feedback.text = "No clear nearby ground. Rod stays in backpack."
		return
	var result: ForagingCommandResult = session.foraging.drop(session.current_location_id,ForagingRegistry.ROD_ITEM,foot,session.foraging.revision())
	if not result.accepted:
		ui.backpack.feedback.text = "Cannot place rod here. Rod stays in backpack."
		return
	_close_backpack()
	foraging_feedback = "Dropped fishing rod · Drag nearby rod to reposition."
	foraging_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()


func _rod_under_pointer(point: Vector2) -> PrototypeInteractable:
	var location: PrototypeLocation = world_host.current_location
	if location == null or location.foraging_pickups == null: return null
	for pickup: PrototypeInteractable in location.foraging_pickups.targets.values():
		if pickup.foraging_action.resource_id != ForagingRegistry.ROD_RESOURCE or not _reachable_rod(pickup): continue
		var centre: Vector3 = pickup.global_position + Vector3.UP * 0.08
		if camera_rig.camera.is_position_behind(centre): continue
		var a: Vector2 = camera_rig.camera.unproject_position(centre + Vector3.LEFT * 0.45)
		var b: Vector2 = camera_rig.camera.unproject_position(centre + Vector3.RIGHT * 0.45)
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point,a,b)) <= 14.0: return pickup
	return null


func _reachable_rod(pickup: PrototypeInteractable) -> bool:
	var location: PrototypeLocation = world_host.current_location
	if not is_instance_valid(pickup) or pickup.is_queued_for_deletion() or not pickup.is_inside_tree() or location == null or not location.is_ancestor_of(pickup) or pickup.foraging_action == null or pickup.foraging_action.resource_id != ForagingRegistry.ROD_RESOURCE or pickup.foraging_action.location_id != session.current_location_id or not pickup.validation_errors(catalog).is_empty() or player_placeholder.global_position.distance_to(pickup.global_position) > pickup.reach:
		return false
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(player_placeholder.global_position + Vector3.UP * 0.8,pickup.global_position + Vector3.UP * 0.8,1)
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func _start_item_drag(pickup: PrototypeInteractable, point: Vector2) -> void:
	if not _foraging_input_allowed() or not _reachable_rod(pickup): return
	_cancel_foraging_hold("drag")
	item_drag.start(session,pickup)
	_drag_mouse_owned = true
	_drag_pointer = point
	drag_preview = Node3D.new()
	drag_preview.name = "RodPlacementPreview"
	add_child(drag_preview)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var rod: CylinderMesh = CylinderMesh.new()
	rod.height = 0.9
	rod.top_radius = 0.06
	rod.bottom_radius = 0.06
	mesh.mesh = rod
	mesh.rotation.z = PI / 2
	mesh.position.y = 0.1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	mesh.material_override = material
	drag_preview.add_child(mesh)
	_update_controls()
	_tick_item_drag()


func _tick_item_drag() -> void:
	if not item_drag.active(): return
	var target: PrototypeInteractable = item_drag.target()
	if not _drag_input_allowed() or item_drag.owner() != session or item_drag.expected_revision != session.foraging.revision() or not _reachable_rod(target) or target.instance_id != item_drag.instance_id or not target.global_position.is_equal_approx(item_drag.original_foot):
		_cancel_item_drag()
		return
	item_drag.preview_foot = camera_rig.ground_point(_drag_pointer,player_placeholder.global_position.y) if ui.accepts_world_pointer(_drag_pointer) else null
	item_drag.errors = PackedStringArray(["no dry ground under pointer"])
	if item_drag.preview_foot != null:
		var provenance: String = WorldItemPlacement.AUTHORED if item_drag.instance_id == ForagingRegistry.ROD_ORIGIN else WorldItemPlacement.GENERATED
		var candidate: WorldItemPlacement = WorldItemPlacement.new(item_drag.instance_id,item_drag.location_id,item_drag.preview_foot,provenance)
		item_drag.errors = ForagingPlacementGeometry.validate_nearby(world_host.current_location,candidate,player_placeholder)
	drag_preview.global_position = item_drag.preview_foot if item_drag.preview_foot != null else item_drag.original_foot
	var material: StandardMaterial3D = drag_preview.get_child(0).material_override
	material.albedo_color = Color(.2,1,.6,.8) if item_drag.errors.is_empty() else Color(1,.2,.15,.8)
	_refresh_interaction()


func _finish_item_drag() -> void:
	_drag_mouse_owned = false
	_tick_item_drag()
	if not item_drag.active(): return
	var accepted: bool = false
	if item_drag.errors.is_empty() and item_drag.preview_foot != null:
		var result: ForagingCommandResult = session.foraging.move(item_drag.location_id,item_drag.instance_id,ForagingRegistry.ROD_ITEM,item_drag.preview_foot,item_drag.expected_revision)
		accepted = result.accepted
	_dispose_item_drag()
	_update_controls()
	foraging_feedback = "Repositioned fishing rod." if accepted else "Cannot place here — rod kept at original position."
	foraging_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()


func _dispose_item_drag() -> void:
	item_drag.cancel()
	if is_instance_valid(drag_preview):
		remove_child(drag_preview)
		drag_preview.queue_free()
	drag_preview = null
	_drag_pointer = Vector2(-1,-1)
	player_placeholder.pointer_position = Vector2(-1,-1)


func _cancel_item_drag() -> void:
	if not item_drag.active(): return
	_dispose_item_drag()
	_update_controls()
	foraging_feedback = "Placement cancelled · Rod stays at original position."
	foraging_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()


func _cancel_foraging_hold(reason: String) -> void:
	var was_active: bool = foraging_hold.active()
	foraging_hold.cancel(reason)
	if was_active and reason != "completed":
		foraging_feedback = "Gather cancelled · Pickup stays in place. Press E again to retry."
		foraging_feedback_until = session.elapsed_play_seconds + 2.5
	if is_instance_valid(ui) and ui.gather_progress != null:
		ui.show_foraging_progress(0, false)


func _tick_foraging_hold(delta: float) -> void:
	if not foraging_hold.active(): return
	var target: PrototypeInteractable = foraging_hold.target()
	var location: PrototypeLocation = world_host.current_location
	var action: ForagingAction = foraging_hold.action
	if not _e_down or not _foraging_input_allowed():
		_cancel_foraging_hold("input mode")
		return
	if foraging_hold.owner() != session or session.foraging.revision() != foraging_hold.expected_revision or not is_instance_valid(target) or target.is_queued_for_deletion() or not target.is_inside_tree() or location == null or not location.is_ancestor_of(target):
		_cancel_foraging_hold("stale target/session")
		return
	if InteractionSelector.select(player_placeholder, location) != target or not target.global_position.is_equal_approx(foraging_hold.target_position) or target.foraging_action == null or target.foraging_action.location_id != action.location_id or target.foraging_action.instance_id != action.instance_id or target.foraging_action.resource_id != action.resource_id or not target.validation_errors(catalog).is_empty():
		_cancel_foraging_hold("target/range/LOS changed")
		return
	foraging_hold.elapsed += maxf(delta, 0)
	ui.show_foraging_progress(foraging_hold.progress(), true)
	if foraging_hold.elapsed + 0.0000001 < foraging_hold.duration: return
	# End attempt before synchronous committed callbacks remove its physical node.
	var revision: int = foraging_hold.expected_revision
	var kind: String = target.kind
	_cancel_foraging_hold("completed")
	var result: ForagingCommandResult = session.foraging.pickup(action.location_id, action.instance_id, action.resource_id, revision) if kind == "pickup" else session.foraging.gather(action.location_id, action.instance_id, action.resource_id, revision)
	if result.accepted:
		foraging_feedback = "Picked up fishing rod." if kind == "pickup" else "Gathered moonflower."
	elif "stack_full" in result.errors or "backpack_full" in result.errors:
		foraging_feedback = "Backpack full — pickup kept in place."
	else:
		foraging_feedback = "Gather cancelled — pickup unchanged."
	foraging_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()
