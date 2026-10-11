extends "res://tests/art_direction_ground_render.gd"
## AD007 paired engine lighting review. Detached synthetic facts/feet, no Save.

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD007 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup failed")
	game._set_paused(true)
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game,"ad007-lighting"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	elif not (await game.world_host.transition_finished)[0]: failures.append("rebind failed")
	inventory = _physical_inventory(game.world_host.current_location)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	var goals: Dictionary = {"maris":poses.goals.maris,"dock":{"position":[-8,0,18],"companion_position":[-6.8,0,17.5]}}
	for phase: int in range(4):
		_preset(phase,WeatherSchedule.Condition.SUNNY)
		for goal: String in goals:
			_place(goals[goal].position,goals[goal].companion_position)
			for ortho: bool in [true,false]:
				_projection(ortho,1.0)
				await _lighting_shot("%s-%s-clear-%s" % [goal,review.PHASE_NAMES[phase].to_lower(),"ortho" if ortho else "persp"])
	for weather: WeatherSchedule.Condition in [WeatherSchedule.Condition.CLOUDY,WeatherSchedule.Condition.RAINY,WeatherSchedule.Condition.THUNDERSTORM]:
		_preset(0,weather)
		for goal: String in goals:
			_place(goals[goal].position,goals[goal].companion_position)
			for ortho: bool in [true,false]:
				_projection(ortho,1.0)
				await _lighting_shot("%s-day-%s-%s" % [goal,WeatherSchedule.condition_id(weather),"ortho" if ortho else "persp"])
	# Noon, zoom bounds, clear and storm darkest foliage/wayfinding checks.
	_preset(0,WeatherSchedule.Condition.SUNNY)
	game.session.environment.day_cycle_progress = 1.0 / 12.0
	game._present_environment()
	_place(goals.maris.position,goals.maris.companion_position)
	for ortho: bool in [true,false]:
		_projection(ortho,1.0)
		await _lighting_shot("maris-noon-clear-%s" % ["ortho" if ortho else "persp"])
	for goal: String in ["maris","dense-forest","moonwell"]:
		_place(poses.goals[goal].position,poses.goals[goal].companion_position)
		for weather: WeatherSchedule.Condition in [WeatherSchedule.Condition.SUNNY,WeatherSchedule.Condition.THUNDERSTORM]:
			_preset(2,weather)
			for ortho: bool in [true,false]:
				_projection(ortho,1.0)
				await _lighting_shot("%s-night-%s-%s" % [goal,WeatherSchedule.condition_id(weather),"ortho" if ortho else "persp"])
	_preset(2,WeatherSchedule.Condition.THUNDERSTORM)
	_place(goals.dock.position,goals.dock.companion_position)
	for ortho: bool in [true,false]:
		for zoom_value: float in [.8,1.15]:
			_projection(ortho,zoom_value)
			await _lighting_shot("dock-night-storm-%s-%s" % ["ortho" if ortho else "persp",str(zoom_value).replace(".","_")])
	_projection(true,1.0)
	# One existing switch source only; actual logical override API, synthetic command.
	_preset(2,WeatherSchedule.Condition.SUNNY)
	var action: LightSwitchAction = LightSwitchAction.new()
	action.location_id = "prototype-alderwake"
	action.prop_id = "dock-row-lamp-01"
	action.source_id = "lantern"
	for enabled: bool in [false,true]:
		failures.append_array(game.session.toggle_light(action,not enabled))
		await _lighting_shot("dock-night-lamp-" + ("on" if enabled else "off"))
	# Scheduled real flash at peak. Preserve forecast, only advance detached clock.
	_preset(2,WeatherSchedule.Condition.THUNDERSTORM)
	var start_seconds: float = (game.session.environment.day_index + game.session.environment.day_cycle_progress) * 600.0
	var peak_seconds: float = start_seconds
	var peak: float = 0.0
	for step: int in range(24000):
		var seconds: float = start_seconds + float(step) / 1000.0
		var flash: float = WeatherVisuals.lightning(game.session.environment.weather_seed,seconds)
		if flash > peak:
			peak = flash
			peak_seconds = seconds
	game.session.environment.day_index = floori(peak_seconds / 600.0)
	game.session.environment.day_cycle_progress = fposmod(peak_seconds,600.0) / 600.0
	game._present_environment()
	if game.environment_presenter.weather.flash < .179: failures.append("scheduled storm peak absent")
	await _lighting_shot("dock-storm-flash")
	await create_timer(.5,true).timeout
	await _lighting_shot("dock-storm-flash-paused-repeat")
	# Hide world geometry only for identical rain/flash-only pause pixel proof.
	var rain: WorldRain = game.world_host.current_location.world_rain
	var hidden: Array[Node3D] = []
	for child: Node in game.world_host.current_location.get_children():
		if child is Node3D and child != rain and child.visible:
			child.visible = false
			hidden.append(child)
	await _lighting_shot("rain-flash-only-paused-first")
	await create_timer(.5,true).timeout
	await _lighting_shot("rain-flash-only-paused-later")
	var a: Image = Image.load_from_file(views[-2].path)
	var b: Image = Image.load_from_file(views[-1].path)
	var pause_pixels_identical: bool = a.get_data() == b.get_data()
	if not pause_pixels_identical: failures.append("paused rain/flash pixels moved")
	for child: Node3D in hidden: child.visible = true
	var old_phase: float = rain.phase_seconds
	game._set_paused(false)
	await create_timer(.35,true).timeout
	game._set_paused(true)
	var resumed_rain_phase_changed: bool = rain.phase_seconds != old_phase
	if not resumed_rain_phase_changed: failures.append("resumed rain phase did not move")
	await _lighting_shot("dock-storm-resumed-paused")
	var final_inventory: Dictionary = _physical_inventory(game.world_host.current_location)
	# Rain selection varies with projection/pose/condition. Keep node observations,
	# compare every immutable semantic/floor/render fingerprint independently.
	for key: String in inventory:
		if key != "nodes" and final_inventory[key] != inventory[key]: failures.append("physical inventory changed: " + key)
	# Existing dry rooms, both extreme metadata states; profiles must remain identical.
	for room: Dictionary in [{"id":"prototype-mayor-vale-home","spawn":"mayor-vale-home-from-alderwake","label":"home","hero":[0,0,-5],"ally":[1,0,-4]},
		{"id":"prototype-lantern-rest","spawn":"lantern-rest-from-alderwake","label":"inn","hero":[0,0,-8],"ally":[1,0,-7]},
		{"id":"prototype-tollworks","spawn":"tollworks-from-alderwake","label":"tollworks","hero":[0,0,3.3],"ally":[1.2,0,3.5]}]:
		errors = game.world_host.request_transition(room.id,room.spawn)
		if not errors.is_empty(): failures.append("room request refused: " + room.label)
		elif not (await game.world_host.transition_finished)[0]: failures.append("room arrival failed")
		_place(room.hero,room.ally)
		for ortho: bool in [true,false]:
			_projection(ortho,1.0)
			for phase: int in [0,2]:
				_preset(phase,WeatherSchedule.Condition.SUNNY if phase == 0 else WeatherSchedule.Condition.THUNDERSTORM)
				await _lighting_shot("%s-%s-%s" % [room.label,"day-clear" if phase == 0 else "night-storm","ortho" if ortho else "persp"])
	var output: Dictionary = {"task":"AD007","kind":"synthetic detached deterministic time/weather, frozen feet/routines and override; actual GPU lighting/rain/flash; no ordinary/native/full-profile claim",
		"views":views,"inventory":inventory,"final_inventory":final_inventory,"pause_rain_flash_pixels_identical":pause_pixels_identical,"resumed_rain_phase_changed":resumed_rain_phase_changed,
		"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"user_data":OS.get_user_data_dir(),"renderer":RenderingServer.get_current_rendering_method(),"gpu":RenderingServer.get_video_adapter_name()}
	if not TestRunEvidence.write_json("lighting-index.json",output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD007 lighting: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _preset(phase: int,weather: WeatherSchedule.Condition) -> void:
	if not review.apply_preset(phase,weather): failures.append("preset refused")

func _projection(ortho: bool,zoom_value: float) -> void:
	game.camera_rig.zoom_factor = zoom_value
	game.camera_rig.set_orthographic(ortho)
	game.ui.show_camera(game.camera_rig.description())

func _lighting_shot(label: String) -> void:
	game._present_environment()
	if not game.ui.time_label.text.begins_with(EnvironmentClock.format_time(game.session.environment.day_cycle_progress)):
		failures.append("HUD time mismatch: " + label)
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,
		"AD007 synthetic detached deterministic phase/forecast/feet/one lamp override; paused routines; real GPU rain/flash; resume bounded .35s; rain-only controls hide geometry")
	if not capture.ok: failures.append(capture.get("error","capture failed"))
	else:
		var sun: DirectionalLight3D = game.environment_presenter.sun
		var environment: Environment = game.environment_presenter.world_environment.environment
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["rendered_time_weather"] = game.ui.time_label.text
		capture["lighting"] = {"sun_color":str(sun.light_color),"sun_energy":sun.light_energy,"sun_direction":str(-sun.basis.z),"shadow_opacity":sun.shadow_opacity,"ambient_color":str(environment.ambient_light_color),"ambient_energy":environment.ambient_light_energy,"background":str(environment.background_color),"profile":game.environment_presenter.profile}
		capture["rain_flash"] = {"rain":game.environment_presenter.weather.rain,"flash":game.environment_presenter.weather.flash,"phase":game.environment_presenter.weather.phase_seconds}
		if game.world_host.current_location is AlderwakeExterior:
			var lights: ExteriorLights = game.world_host.current_location.exterior_lights
			var active: int = 0
			for consumer: ExteriorLightConsumer in lights.consumers.values():
				if consumer.emitter != null:
					if consumer.emitter.shadow_enabled: failures.append("shadowed local emitter")
					if consumer.emitter.visible: active += 1
			if active > 8 or lights.emitter_count > 8: failures.append("local emitter cap exceeded")
			capture["local_lights"] = {"active":active,"allocated":lights.emitter_count,"consumer_count":lights.consumers.size()}
		else:
			if not game.world_host.find_children("*","WorldRain",true,false).is_empty(): failures.append("indoor rain")
		views.append(capture)
