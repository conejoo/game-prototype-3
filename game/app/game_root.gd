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
		errors = session.initialize(catalog, initial_location_id, initial_spawn_id, "prototype-hero")
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
	if world_host.current_location is AlderwakeTerrainPreview and not world_host.transitioning:
		(world_host.current_location as AlderwakeTerrainPreview).tree_art.update_visibility(camera_rig.camera, player_placeholder, companion)
	if not get_tree().paused and not world_host.transitioning and not loading_save and not retrying:
		session.advance(delta)
		_present_environment()
		ui.show_play_time(session.elapsed_play_seconds)
		_refresh_interaction()
	ui.show_combat(player_placeholder.state, guardian, retrying, player_placeholder.combat.damage)
	ui.show_debug_time(session.environment.day_cycle_progress)
	if is_instance_valid(companion):
		ui.show_companion(companion.state, companion_ai.mode, session.relationship.trust)
	ui.set_save_busy(session.review_only or world_host.transitioning or loading_save or dialogue.active() or journal_open or not _combat_stable(), world_host.transitioning or loading_save)


func _input(event: InputEvent) -> void:
	if environment_review != null and environment_review.handle_input(event):
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
	if (dialogue.active() or journal_open) and not event.is_action("quit"):
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
	if get_tree().paused or world_host.transitioning or loading_save or retrying or dialogue.active() or journal_open or not window_focused or get_viewport().gui_get_focus_owner() != null:
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
	if paused:
		ui.show_save_status("No autosave. Save here; reopen and choose Load to continue." if _combat_stable() else "Combat paused. Resume and retreat, or R: retry after death; save/load locked.")
	print("P001: %s at play time %.2fs." % ["Paused" if paused else "Resumed", session.elapsed_play_seconds])


func _update_controls() -> void:
	var enabled: bool = window_focused and not get_tree().paused and not world_host.transitioning and not loading_save and not dialogue.active() and not journal_open
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
	ui.set_save_busy(session.review_only or world_host.transitioning or loading_save or dialogue.active() or journal_open or not _combat_stable(), world_host.transitioning or loading_save)


func _on_transition_started() -> void:
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
		_refresh_world_presentation()
		ui.show_location(catalog.get_location(session.current_location_id).display_name)
		_refresh_interaction()
	else:
		_refresh_combat_targets()
		if is_instance_valid(guardian):
			player_placeholder.combat_targets = [guardian]
			_update_controls()
		ui.show_travel("Travel failed: " + "; ".join(errors))


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
	if not _combat_stable():
		selected_interaction = null
		ui.show_travel("Quest progress kept; retry restarts at last arrival anchor." if player_placeholder.state.health == 0 else "Click: attack · Space: dodge · Finish fight or retreat to interact / save")
		return
	selected_interaction = InteractionSelector.select(player_placeholder, world_host.current_location)
	ui.show_travel("E: " + selected_interaction.display_prompt(session.environment) if selected_interaction != null else "E near lamps / Chandlery Maris / purple station / forest Tollworks entrance" if session.current_location_id == "prototype-alderwake" else "E near southeast vessel / north return gate")
	if selected_interaction != null and selected_interaction.instance_id == light_feedback_instance_id and not light_feedback.is_empty() and session.elapsed_play_seconds < light_feedback_until:
		ui.show_travel(light_feedback + " · " + ui.travel_label.text)


func switch_light(target_reference: WeakRef, expected_enabled: bool) -> DialogueService.ActionResult:
	var target: PrototypeInteractable = target_reference.get_ref() as PrototypeInteractable if target_reference != null else null
	if not _combat_stable() or dialogue.active() or journal_open or get_tree().paused or world_host.transitioning or loading_save or not window_focused or get_viewport().gui_get_focus_owner() != null:
		return DialogueService.ActionResult.new(false, "Light switching blocked by current input mode.", "light")
	var location: PrototypeLocation = world_host.current_location
	if not is_instance_valid(target) or target.is_queued_for_deletion() or location == null or not target.is_inside_tree() or not location.is_ancestor_of(target) or InteractionSelector.select(player_placeholder, location) != target:
		return DialogueService.ActionResult.new(false, "Light target unloaded, stale or out of reach.", "light")
	if target.kind != "light" or target.light_action == null or not target.validation_errors(catalog).is_empty():
		return DialogueService.ActionResult.new(false, "Invalid light source interaction.", "light")
	var errors: PackedStringArray = session.toggle_light(target.light_action, expected_enabled)
	var message: String = "; ".join(errors)
	if errors.is_empty():
		message = "Lamp off." if expected_enabled else "Lamp on — ready for dusk." if ExteriorLights.night_factor(session.environment.day_cycle_progress) == 0.0 else "Lamp on."
		_present_environment()
	light_feedback = message
	light_feedback_instance_id = target.instance_id
	light_feedback_until = session.elapsed_play_seconds + 2.5
	_refresh_interaction()
	return DialogueService.ActionResult.new(errors.is_empty(), message, "light")


func interact() -> DialogueService.ActionResult:
	if not _combat_stable():
		return DialogueService.ActionResult.new(false, "Finish combat or retreat before interaction.")
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
	if target.kind == "light":
		if target.light_action == null:
			return DialogueService.ActionResult.new(false, "Invalid light source interaction.", "light")
		var action: LightSwitchAction = target.light_action
		return switch_light(weakref(target), session.environment.light_enabled(action.location_id, action.prop_id, action.source_id))
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
	if saved.migrated:
		message += " Migrated legacy save: v1/v2 add temporary companion; v1–v3 start with neutral trust and no upgrades; v1–v4 start environment at 10 AM with fixed forecast and light defaults. v1–v5 start with empty inventory/collected/placement facts. Save writes v6."
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


func _toggle_journal() -> void:
	if not journal_open and not _combat_stable():
		return
	if dialogue.active() or get_tree().paused or world_host.transitioning or loading_save:
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
	var result: DialogueService.ActionResult = quests.apply("prototype-maris-recovery", "maris-clear-guardian", session.current_location_id, actor.state.instance_id)
	if not result.ok:
		push_error("Guardian clearance failed: " + result.message)
	print("P008 guardian defeat: ", result.message)


func _on_player_defeated(_actor: ActorPlaceholder) -> void:
	_update_controls()
	print("P008 hero defeated; R retries at arrival anchor, quest facts retained.")


func retry_encounter() -> void:
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


func _reaction_command(id: String, source_id: String) -> DialogueService.ActionResult:
	if world_host.transitioning or loading_save or get_tree().paused or not dialogue.active() or not window_focused:
		return DialogueService.ActionResult.new(false, "Reaction blocked by input mode.")
	for target: PrototypeInteractable in world_host.current_location.interactables():
		if target.instance_id == source_id and target.dialogue_id == dialogue.definition.stable_id:
			for choice: DialogueChoice in dialogue.definition.choices:
				if choice.reaction_id == id:
					return relationships.apply(id)
	return DialogueService.ActionResult.new(false, "Reaction source/action unavailable.")

func _select_upgrade() -> void:
	if not journal_open or not window_focused or get_tree().paused or dialogue.active() or world_host.transitioning or loading_save or not _combat_stable():
		return
	var result: DialogueService.ActionResult = progression.select_upgrade(ProgressionService.UPGRADE_ID)
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
