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

@export var content_manifest: ContentManifest = preload("res://content/prototype_catalog.tres")
@export var initial_location_id: String = "prototype-alderwake"
@export var initial_spawn_id: String = "alderwake-start"


func _ready() -> void:
	get_tree().auto_accept_quit = false
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
	camera_rig.set_target(player_placeholder)
	player_placeholder.configure_controls(camera_rig, ui)
	ui.show_camera(camera_rig.description())
	ui.pause_requested.connect(_toggle_pause)
	ui.resume_requested.connect(_resume)
	ui.quit_requested.connect(_quit)
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
		var location: PrototypeLocation = world_host.current_location
		if location != null:
			ui.show_travel("E: " + location.gate_label if location.can_travel(player_placeholder) else "Walk to glowing travel gate")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_toggle_pause()
	elif event.is_action_pressed("quit") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_quit()
	elif not get_tree().paused and not world_host.transitioning and window_focused and get_viewport().gui_get_focus_owner() == null:
		if event.is_action_pressed("interact") and not event.is_echo():
			var location: PrototypeLocation = world_host.current_location
			if location != null and location.can_travel(player_placeholder):
				var errors: PackedStringArray = world_host.request_transition(location.destination_id, location.destination_spawn_id)
				if not errors.is_empty():
					ui.show_travel("Travel failed: " + "; ".join(errors))
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
	get_tree().paused = paused
	_update_controls()
	ui.show_paused(paused)
	print("P001: %s at play time %.2fs." % ["Paused" if paused else "Resumed", session.elapsed_play_seconds])


func _update_controls() -> void:
	player_placeholder.set_controls_enabled(window_focused and not get_tree().paused and not world_host.transitioning)


func _on_transition_started() -> void:
	ui.show_travel("Travelling…")
	_update_controls()


func _on_transition_finished(success: bool, errors: PackedStringArray) -> void:
	camera_rig.set_target(player_placeholder)
	camera_rig.reset_physics_interpolation()
	_update_controls()
	if success:
		ui.show_location(catalog.get_location(session.current_location_id).display_name)
	else:
		ui.show_travel("Travel failed: " + "; ".join(errors))


func _quit() -> void:
	print("P001: Quit requested%s." % [" while paused" if get_tree().paused else ""])
	get_tree().quit(0)
