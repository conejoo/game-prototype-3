extends SceneTree
## W008 real HUD/GUI travel/load and explicit synthetic review controls.

const ORACLE: String = "user://saves/w008-oracle.json"
var game: Node3D
var directory: String
var phase: String
var views: Array[Dictionary] = []
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(960, 640)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir=res://../docs/evidence/W008/"):
			directory = ProjectSettings.globalize_path(argument.trim_prefix("--report-dir="))
		if argument.begins_with("--phase="): phase = argument.trim_prefix("--phase=")
	_check(DisplayServer.get_name() != "headless" and not directory.is_empty(), "renderer/evidence missing")
	if not failures.is_empty():
		quit(1)
		return
	print("W008 render pid=%d phase=%s user_data=%s" % [OS.get_process_id(), phase, OS.get_user_data_dir()])
	game = load("res://app/game_root.tscn").instantiate()
	if phase == "review": game.environment_review_namespace = "w008-matrix"
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	await _capture("startup", false)
	if phase == "review":
		_check(game.session.review_only and game.environment_review != null, "review not composed")
		_key(KEY_F7)
		_check(game.environment_review.phase_index == 1, "F7 phase control")
		_key(KEY_F8)
		_check(game.session.weather_conditions.condition_id() == "cloudy", "F8 condition control")
		await _capture("review-keys", true)
		for preset: Array in [[2,3],[3,2],[0,0]]:
			_check(game.environment_review.apply_preset(preset[0], preset[1] as WeatherSchedule.Condition), "preset rejected")
			await _capture("review-%d-%d" % [preset[0], preset[1]], false)
		_check(game.ui.save_button.disabled and game.ui.load_button.disabled and not FileAccess.file_exists(game.save_repository.path), "review disk/GUI isolation")
	else:
		if phase == "write":
			# Labeled valid synthetic seeded storm/time; actual GUI persistence follows.
			game.session.environment.day_index = 2
			game.session.environment.day_cycle_progress = .625
			for seed: int in range(10000):
				var sample: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed, 2, .625)
				if sample.condition == WeatherSchedule.Condition.THUNDERSTORM and sample.transition_progress == 1:
					game.session.environment.weather_seed = seed
					break
			game.session.environment.set_light_enabled("prototype-alderwake", "dock-lamp-02", "lantern", true)
			game.session.environment.set_light_enabled("prototype-alderwake", "dock-row-lamp-01", "lantern", false)
			game._present_environment()
			await _capture("storm-hud", false)
			var lamp: PrototypeInteractable = game.world_host.current_location.town.get_node("dock-lamp-01/LightSwitch")
			await _place_target(lamp)
			await _activate_gui(game.ui.resume_button)
			_key(KEY_E)
			await process_frame
			game._set_paused(true)
			_check(not game.light_feedback.is_empty() and game.session.environment.light_enabled("prototype-alderwake", "dock-lamp-01", "lantern"), "light action feedback missing")
			await _capture("light-feedback", false)
			await _activate_gui(game.ui.save_button)
			_check(game.ui.save_status.text.begins_with("Saved."), "GUI save failed")
			var oracle: Dictionary = TestRunSnapshot.oracle(game.session)
			oracle["hud"] = game.ui.time_label.text
			var file: FileAccess = FileAccess.open(ORACLE, FileAccess.WRITE)
			file.store_string(JSON.stringify(oracle, "", true, true))
			file.close()
			await _capture("gui-save", true)
		else:
			await _activate_gui(game.ui.load_button)
			for frame: int in range(600):
				await process_frame
				if not game.loading_save: break
			_check(game.ui.save_status.text.begins_with("Loaded"), "GUI load failed")
			var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ORACLE))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			for error: String in TestRunSnapshot.compare_restored(game.session, oracle, disk.session): _check(false, error)
			_check(game.ui.time_label.text == oracle.hud, "restart HUD mismatch")
			await _capture("gui-load", true)
			await _capture("loaded-storm-hud", false)
			# Existing E path, synthetic gate placement, bounded resumed input.
			await _travel_with_e(false)
			_check(game.environment_presenter.profile == 0 and game.world_host.find_children("WorldRain", "", true, false).is_empty(), "indoor profile/rain")
			await _capture("indoor-hud", false)
			await _travel_with_e(true)
			_check(game.environment_presenter.profile == 1 and game.world_host.find_children("WorldRain", "", true, false).size() == 1, "return rain owner")
			await _capture("return-hud", false)
	var output: FileAccess = FileAccess.open(directory.path_join(phase + "-index.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify({"views":views, "failures":failures, "engine_pid":OS.get_process_id()}, "\t", true, true))
	output.close()
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W008 render %s phase=%s captures=%d" % ["PASS" if failures.is_empty() else "FAIL", phase, views.size()])
	quit(0 if failures.is_empty() else 1)


func _travel_with_e(returning: bool) -> void:
	var gate: PrototypeInteractable = game.world_host.current_location.get_node("TravelGate")
	# Retained safe north-gate/exterior approach used by the passing W008 run.
	game.player_placeholder.global_position = gate.global_position + (Vector3.FORWARD * .8 if returning else Vector3.BACK * .8)
	game.companion.global_position = game.player_placeholder.global_position + Vector3.RIGHT
	game.player_placeholder.reset_physics_interpolation()
	game.companion.reset_physics_interpolation()
	game.camera_rig._process(0)
	await _activate_gui(game.ui.resume_button)
	game._refresh_interaction()
	_check(game.selected_interaction == gate, "gate placement not selected")
	_key(KEY_E)
	if game.world_host.transitioning: await game.world_host.transition_finished
	_key(KEY_ESCAPE)
	for frame: int in range(3): await process_frame
	_check(paused and game.ui.pause_overlay.visible, "travel pause checkpoint missing")
	_check(game.session.current_location_id == ("prototype-alderwake" if returning else "prototype-tollworks"), "E travel failed")


func _capture(label: String, overlay: bool) -> void:
	var result: Dictionary = await TestRunCapture.capture(game, phase + "-" + label, directory, "synthetic", overlay, "W008 synthetic seed/time/gate placement or explicit developer review; actual GPU HUD and viewport GUI/E input")
	_check(result.ok, result.get("error", "capture failed"))
	if result.ok:
		result["hud"] = game.ui.time_label.text
		result["review_only"] = game.session.review_only
		views.append(result)


func _activate_gui(button: Button) -> void:
	# Pause/capture establishes Resume focus. Navigate actual GUI focus cycle.
	for step: int in range(8):
		if root.gui_get_focus_owner() == button: break
		_key(KEY_TAB)
		await process_frame
	_check(root.gui_get_focus_owner() == button and not button.disabled, "GUI focus target unavailable")
	_key(KEY_ENTER)
	for frame: int in range(3): await process_frame


func _place_target(target: PrototypeInteractable) -> void:
	_check(paused and game.ui.pause_overlay.visible, "synthetic placement lacks pause")
	for direction: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		game.player_placeholder.global_position = target.global_position + direction * 1.1
		game.companion.global_position = game.player_placeholder.global_position + Vector3(1.2, 0, .5)
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		await physics_frame
		if InteractionSelector.select(game.player_placeholder, game.world_host.current_location) == target: break
	game.camera_rig._process(0)
	game._refresh_interaction()
	_check(InteractionSelector.select(game.player_placeholder, game.world_host.current_location) == target, "synthetic target approach not selected")


func _key(code: int) -> void:
	for pressed: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event, true)


func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)
