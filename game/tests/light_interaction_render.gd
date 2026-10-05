extends SceneTree
## W006 actual E/GUI Save/restart/Load. Forced phase and relocated reviews labeled.

var game: Node3D
var failures: Array[String] = []
var views: Array[Dictionary] = []
var directory: String
var writer: bool
var phase_name: String
var oracle_path: String = "user://saves/w006-render-oracle.json"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("W006 visual proof requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	directory = TestRunEvidence.directory()
	writer = "--phase=write" in OS.get_cmdline_user_args()
	phase_name = "write" if writer else "read"
	DirAccess.make_dir_recursive_absolute(directory)
	print("W006 render phase=%s pid=%d user_data=%s output=%s" % [phase_name, OS.get_process_id(), OS.get_user_data_dir(), directory])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await _pause()
	await _capture("startup-paused", true)
	if writer:
		# Normal movement from fresh arrival through InputMap, no position setup.
		await _resume_gui()
		await _hold(KEY_S, .80)
		await _hold(KEY_D, .25)
		game._refresh_interaction()
		_check(game.selected_interaction != null and game.selected_interaction.instance_id == "dock-lamp-02", "fresh normal movement failed to select dock-lamp-02")
		_key(KEY_E, true)
		_key(KEY_E, false)
		await process_frame
		_check(game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-02", "lantern"), "ordinary E failed to arm lamp02")
		await _pause()
		await _capture("ordinary-day-lamp02-armed")
		# Saved day/time is natural up to here; review phases below are synthetic.
		game.session.environment.day_cycle_progress = .375
		game._present_environment()
		await _capture("synthetic-dusk-lamp02-on")
		game.session.environment.day_cycle_progress = .625
		game._present_environment()
		await _capture("synthetic-night-lamp02-on")
		# Other lamps retain their defaults; disable Dock Row independently with E.
		var target: PrototypeInteractable = _target("dock-row-lamp-01")
		await _place(target)
		game._present_environment()
		await _capture("synthetic-night-dock-row-default-on")
		await _resume_gui()
		_key(KEY_E, true)
		_key(KEY_E, false)
		await process_frame
		await _pause()
		_check(not game.session.environment.light_enabled("prototype-alderwake", "dock-row-lamp-01", "lantern"), "Dock Row E did not disable")
		_check(game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-02", "lantern"), "other lamp changed")
		await _capture("synthetic-night-dock-row-manually-off")
		game.session.environment.day_cycle_progress = .375
		game._present_environment()
		await _capture("synthetic-dusk-dock-row-manually-off")
		game.session.environment.day_cycle_progress = .625
		await _place(_target("dock-lamp-02"))
		game._present_environment()
		await _capture("synthetic-night-lamp02-still-on")
		# Preserve exact values during manual GUI Save (stable pause boundary).
		await _click(game.ui.save_button)
		_check(game.ui.save_status.text.begins_with("Saved."), "GUI Save failed " + game.ui.save_status.text)
		await _capture("gui-save-confirmed", true)
		var file: FileAccess = FileAccess.open(oracle_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(TestRunSnapshot.oracle(game.session), "\t", true, true))
		file.close()
	else:
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(oracle_path))
		_check(int(oracle.writer_pid) != OS.get_process_id(), "reader reused writer process")
		_check(not game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-02", "lantern") and game.session.environment.light_enabled("prototype-alderwake", "dock-row-lamp-01", "lantern"), "fresh reader inherited choices before Load")
		await _click(game.ui.load_button)
		for frame: int in range(600):
			await process_frame
			if not game.loading_save: break
		_check(not game.loading_save and game.ui.save_status.text.begins_with("Loaded"), "GUI Load failed " + game.ui.save_status.text)
		var restored: Dictionary = SaveCodec.snapshot(game.session)
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		for error: String in TestRunSnapshot.compare_restored(game.session, oracle, disk.session):
			_check(false, error)
		_check(restored.light_source_overrides.size() == 2, "restart lost independent choices")
		await _capture("gui-load-confirmed", true)
		await _place(_target("dock-lamp-02"))
		game._present_environment()
		await _capture("synthetic-restart-lamp02-on")
		await _place(_target("dock-row-lamp-01"))
		game._present_environment()
		await _capture("synthetic-restart-dock-row-off")
		# Pose setup is synthetic; travel itself uses E and existing arrival transaction.
		var gate: PrototypeInteractable = game.world_host.current_location.get_node("TravelGate")
		await _place(gate)
		await _resume_gui()
		_key(KEY_E, true)
		_key(KEY_E, false)
		await game.world_host.transition_finished
		await _pause()
		_check(game.session.current_location_id == "prototype-tollworks", "E failed indoor travel")
		await _capture("synthetic-E-travel-tollworks", true)
		var indoor_before: Dictionary = SaveCodec.snapshot(game.session)
		_check(indoor_before.light_source_overrides == restored.light_source_overrides and indoor_before.environment.weather_seed == restored.environment.weather_seed, "travel lost saved choices/seed")
		gate = game.world_host.current_location.get_node("TravelGate")
		await _place(gate)
		await _resume_gui()
		_key(KEY_E, true)
		_key(KEY_E, false)
		await game.world_host.transition_finished
		await _pause()
		_check(game.session.current_location_id == "prototype-alderwake", "E failed exterior return")
		_check(SaveCodec.snapshot(game.session).light_source_overrides == restored.light_source_overrides and game.session.environment.day_index == disk.session.environment.day_index and game.session.environment.weather_seed == disk.session.environment.weather_seed, "round trip lost independent facts")
		_check(game.session.environment.day_cycle_progress >= disk.session.environment.day_cycle_progress and game.session.environment.day_cycle_progress - disk.session.environment.day_cycle_progress < .01, "round trip reset clock")
		await _place(_target("dock-lamp-02"))
		game._present_environment()
		await _capture("synthetic-return-lamp02-on")
		await _place(_target("dock-row-lamp-01"))
		game._present_environment()
		await _capture("synthetic-return-dock-row-off")
		# GUI pause E is blocked and retains choices, then GUI Resume works.
		var choices: Array[Dictionary] = game.session.environment.light_source_overrides.duplicate(true)
		_key(KEY_E, true)
		_key(KEY_E, false)
		_check(game.session.environment.light_source_overrides == choices, "pause E changed lamp")
		await _capture("pause-E-blocked", true)
	var file: FileAccess = FileAccess.open(TestRunEvidence.path(phase_name + "-index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"phase":phase_name, "engine_pid":OS.get_process_id(), "user_data":OS.get_user_data_dir(), "engine":Engine.get_version_info()["string"], "views":views, "failures":failures}, "\t", true, true))
	file.close()
	# No input remains held; dispose the isolated test root before exiting.
	for failure: String in failures: push_error(failure)
	print("W006 render %s: %s captures=%d" % [phase_name, "PASS" if failures.is_empty() else "FAIL", views.size()])
	game.queue_free()
	await process_frame
	paused = false
	quit(0 if failures.is_empty() else 1)


func _target(prop: String) -> PrototypeInteractable:
	return game.world_host.current_location.town.get_node(NodePath(prop + "/LightSwitch"))


func _place(target: PrototypeInteractable) -> void:
	_check(paused, "setup performed before verified pause")
	for direction: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		game.player_placeholder.global_position = target.global_position + direction * 1.1
		game.companion.global_position = game.player_placeholder.global_position + Vector3(1.2, 0, .5)
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		await physics_frame
		if InteractionSelector.select(game.player_placeholder, game.world_host.current_location) == target: break
	game.camera_rig._process(0)
	game._refresh_interaction()
	_check(InteractionSelector.select(game.player_placeholder, game.world_host.current_location) == target, "fixture approach not selected " + target.instance_id)


func _pause() -> void:
	if not paused:
		_key(KEY_ESCAPE, true)
		_key(KEY_ESCAPE, false)
	for frame: int in range(3): await process_frame
	_check(paused and game.ui.pause_overlay.visible, "pause checkpoint not confirmed")


func _resume_gui() -> void:
	_check(paused and game.ui.pause_overlay.visible, "resume lacks verified pause")
	await _click(game.ui.resume_button)
	_check(not paused and game.player_placeholder.controls_enabled, "GUI Resume failed")


func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame


func _hold(code: int, seconds: float) -> void:
	_key(code, true)
	await create_timer(seconds).timeout
	_key(code, false)
	await process_frame


func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event, true)


func _capture(label: String, overlay: bool = false) -> void:
	var synthetic: bool = label.begins_with("synthetic") or label in ["gui-save-confirmed", "gui-load-confirmed", "pause-E-blocked"]
	var result: Dictionary = await TestRunCapture.capture(game, phase_name + "-" + label, directory,
		"synthetic" if synthetic else "debug-input", overlay,
		"Forced phase or setup placement; E/GUI still use input paths" if synthetic else "Fresh startup and camera-relative InputMap movement")
	_check(result.ok, result.get("error", "capture failed"))
	if result.ok:
		views.append(result)

func _check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)
