extends SceneTree
## W007 synthetic weather/pose matrix; real GPU rain, GUI Save/new-process Load.

var game: Node3D
var directory: String
var phase_name: String
var views: Array[Dictionary] = []
var failures: Array[String] = []
const ORACLE: String = "user://saves/w007-oracle.json"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("W007 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960,640)
	directory = TestRunEvidence.directory()
	phase_name = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	_check(not directory.is_empty(), "evidence directory missing")
	DirAccess.make_dir_recursive_absolute(directory)
	print("W007 render pid=%d phase=%s user_data=%s" % [OS.get_process_id(), phase_name, OS.get_user_data_dir()])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	await _capture("startup", true)
	if phase_name == "write":
		var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_camera_poses.json"))
		for goal: String in ["maris", "moonwell", "dense-forest", "bridge-west", "ford-west"]:
			_place(poses.goals[goal])
			for orthographic: bool in [true,false]:
				game.camera_rig.set_orthographic(orthographic)
				game.ui.show_camera(game.camera_rig.description())
				for condition: int in range(4):
					_force_condition(condition, .05)
					await _capture("%s-%s-%s" % [goal, WeatherSchedule.condition_id(condition as WeatherSchedule.Condition), "ortho" if orthographic else "perspective"])
			# Storm zoom endpoints and navy night preserve actors/aim/canopy.
			for zoom: float in [.8,1.15]:
				game.camera_rig.zoom_factor = zoom
				game.camera_rig._apply_zoom()
				game.ui.show_camera(game.camera_rig.description())
				_force_condition(3, .625)
				await _capture("%s-storm-night-zoom-%s" % [goal, str(zoom).replace(".", "-")])
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig._apply_zoom()
		_place(poses.goals.maris)
		game.camera_rig.set_orthographic(true)
		game.ui.show_camera(game.camera_rig.description())
		_force_condition(3,.05)
		# A camera-only move keeps all surviving world batches/instance coordinates fixed.
		var rain: WorldRain = game.world_host.current_location.world_rain
		var key: Vector2i = rain.batches.keys()[0]
		var old: PackedFloat32Array = rain.batches[key].multimesh.buffer.duplicate()
		game.camera_rig.global_position.x += 2
		game._present_environment()
		if rain.batches.has(key): _check(rain.batches[key].multimesh.buffer == old, "camera moved rain")
		await _capture("camera-pan-stationary-world")
		var phase_before_input: float = rain.phase_seconds
		var point_before_input: Vector3 = game.player_placeholder.global_position
		await _click(game.ui.resume_button)
		_key(KEY_D, true)
		await create_timer(.4).timeout
		_key(KEY_D, false)
		_key(KEY_ESCAPE, true)
		_key(KEY_ESCAPE, false)
		_check(paused and game.ui.pause_overlay.visible, "movement pause failed")
		_check(rain.phase_seconds != phase_before_input and game.player_placeholder.global_position.distance_to(point_before_input) > .1, "rain did not advance")
		await _capture("input-camera-motion-rain")
		game.camera_rig._process(0)
		game._present_environment()
		# Pause pixel proof excludes the pre-existing river TIME shader.
		var hidden: Array[Node3D] = []
		for child: Node in game.world_host.current_location.get_children():
			if child is Node3D and child != rain and child.visible:
				child.visible = false
				hidden.append(child)
		await _capture("pause-rain-only-first")
		await create_timer(.5, true).timeout
		await _capture("pause-rain-only-later")
		var first: Image = Image.load_from_file(TestRunEvidence.path("write-pause-rain-only-first.png"))
		var second: Image = Image.load_from_file(TestRunEvidence.path("write-pause-rain-only-later.png"))
		_check(first.get_data() == second.get_data(), "paused rain pixels moved")
		for child: Node3D in hidden: child.visible = true
		# Actual natural rain->storm schedule transition, sampled at begin/mid/end.
		var sample: WeatherSchedule.Sample = game.session.environment.weather_sample()
		var minutes: float = sample.period_start_minutes
		for offset: float in [0.0,7.5,15.0]:
			_set_minutes(minutes + offset)
			game._present_environment()
			await _capture("transition-storm-%s" % str(offset).replace(".", "-"))
		# Find a real scheduled flash within the current storm and capture its peak.
		var seconds: float = (game.session.environment.day_index + game.session.environment.day_cycle_progress) * 600
		for step: int in range(24000):
			var candidate: float = seconds + float(step) / 1000
			if WeatherVisuals.lightning(game.session.environment.weather_seed, candidate) > .1799:
				_set_minutes(candidate * 2.4)
				break
		game._present_environment()
		_check(game.environment_presenter.weather.flash > .17, "flash fixture missing")
		await _capture("storm-flash")
		# Save at town arrival position for exact renderer reconstruction.
		_place({"position":[0,0,0], "companion_position":[1,0,0]})
		game._present_environment()
		await _click(game.ui.save_button)
		_check(game.ui.save_status.text.begins_with("Saved."), "GUI Save failed")
		await _capture("gui-save-storm", true)
		var oracle: Dictionary = TestRunSnapshot.oracle(game.session)
		oracle["render"] = _render_values()
		var file: FileAccess = FileAccess.open(ORACLE, FileAccess.WRITE)
		file.store_string(JSON.stringify(oracle, "", true, true))
		file.close()
	else:
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ORACLE))
		await _click(game.ui.load_button)
		for frame: int in range(600):
			await process_frame
			if not game.loading_save: break
		_check(not game.loading_save and game.ui.save_status.text.begins_with("Loaded"), "GUI Load failed")
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		for error: String in TestRunSnapshot.compare_restored(game.session, oracle, disk.session):
			_check(false, error)
		_check(_render_values() == oracle.render, "restart changed render values")
		await _capture("gui-load-storm", true)
		await _capture("reconstructed-storm-flash")
		# Legitimate detached quest setup; stable indoor visual tested during storm/flash.
		var lead: NpcDialogueService.Result = game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
		_check(lead.ok, "synthetic guardian setup")
		var old: WeakRef = weakref(game.world_host.current_location.world_rain)
		_check(game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake").is_empty(), "travel request")
		var arrival: Array = await game.world_host.transition_finished
		await process_frame
		_check(arrival[0] and old.get_ref() == null, "weather not disposed")
		for orthographic: bool in [true,false]:
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			game.guardian.combat.attack(Vector3.BACK, true)
			game.guardian._update_feedback()
			await _capture("tollworks-storm-%s" % ["ortho" if orthographic else "perspective"])
			game.guardian.combat.cancel()
			game.guardian._update_feedback()
		_check(is_equal_approx(game.environment_presenter.sun.light_energy, 1.1) and game.world_host.find_children("*","WorldRain",true,false).is_empty(), "indoor flash/rain")
		_check(game.world_host.request_transition("prototype-alderwake", "alderwake-start").is_empty(), "return request")
		arrival = await game.world_host.transition_finished
		_check(arrival[0] and _render_values() == oracle.render, "return changed renderer")
		await _capture("return-restored-storm")
	var file: FileAccess = FileAccess.open(TestRunEvidence.path(phase_name + "-index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"views":views, "failures":failures, "engine_pid":OS.get_process_id(), "phase":phase_name}, "\t", true, true))
	file.close()
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W007 render %s phase=%s captures=%d" % ["PASS" if failures.is_empty() else "FAIL", phase_name, views.size()])
	quit(0 if failures.is_empty() else 1)


func _force_condition(condition: int, progress: float) -> void:
	_check(paused and game.ui.pause_overlay.visible, "fixture lacks pause")
	game.session.environment.day_index = 2
	game.session.environment.day_cycle_progress = progress
	for seed: int in range(10000):
		var schedule: WeatherSchedule = WeatherSchedule.new()
		var forecast: WeatherSchedule.Sample = schedule.sample(seed, 2, progress)
		if forecast.condition == condition and forecast.transition_progress == 1.0:
			game.session.environment.weather_seed = seed
			game._present_environment()
			return
	_check(false, "condition seed missing")


func _set_minutes(minutes: float) -> void:
	game.session.environment.day_index = floori(minutes / 1440)
	game.session.environment.day_cycle_progress = fposmod(minutes, 1440) / 1440


func _render_values() -> String:
	var weather: WeatherVisuals.Sample = game.environment_presenter.weather
	return TestRunSnapshot.exact_json({"cloud":weather.overcast, "rain":weather.rain, "storm":weather.storm, "flash":weather.flash, "phase":weather.phase_seconds, "sun":game.environment_presenter.sun.light_energy})


func _place(pose: Dictionary) -> void:
	_check(paused and game.ui.pause_overlay.visible, "placement lacks pause")
	var p: Array = pose.position
	var ally: Array = pose.companion_position
	game.player_placeholder.global_position = Vector3(p[0],p[1],p[2])
	game.companion.global_position = Vector3(ally[0],ally[1],ally[2])
	game.player_placeholder.reset_physics_interpolation()
	game.companion.reset_physics_interpolation()
	game.camera_rig._process(0)
	game._refresh_interaction()


func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion, true)
	for pressed: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame


func _capture(label: String, overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game, phase_name + "-" + label, directory, "synthetic", overlay, "W007 forced seed/clock and retained pose setup; actual GPU weather and GUI input")
	_check(result.ok, result.get("error", "capture failed"))
	if result.ok:
		result["weather_render"] = _render_values()
		if game.world_host.current_location is AlderwakeExterior:
			var rain: WorldRain = game.world_host.current_location.world_rain
			result["rain_batches"] = rain.batches.size()
			result["shelter_count"] = rain.shelters.size()
			result["rain_instances"] = 0
			for tile: Vector2i in rain.batches:
				var multi: MultiMesh = rain.batches[tile].multimesh
				result["rain_instances"] += multi.instance_count
				var data: WorldRain.RainBatchData = rain.tile_data(tile)
				_check(multi.instance_count == data.transforms.size(), "GPU column count")
				for index: int in range(multi.instance_count):
					_check(multi.get_instance_transform(index).origin.is_equal_approx(data.transforms[index].origin), "GPU world/floor registration")
			_check(rain.selection_error.is_empty(), rain.selection_error)
		views.append(result)


func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)


func _key(code: int, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event, true)
