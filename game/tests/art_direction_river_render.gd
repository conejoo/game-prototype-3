extends "res://tests/art_direction_ground_render.gd"
## AD005: synthetic fixed feet/weather/cues; real renderer and live shader TIME.

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD005 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
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
	failures.append_array(review.initialize(game, "ad005-river"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	else:
		if not (await game.world_host.transition_finished)[0]: failures.append("review rebind failed")
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	inventory = _physical_inventory(location)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	poses.goals["dock"] = {"position":[-7,0,18], "companion_position":[-8.3,0,17.5]}
	for phase: int in [0, 2]:
		if not review.apply_preset(phase, WeatherSchedule.Condition.SUNNY): failures.append("clear day/night preset refused")
		for goal: String in ["maris", "dock", "bridge-west", "bridge-east", "ford-west", "ford-east"]:
			_place(poses.goals[goal].position, poses.goals[goal].companion_position)
			for orthographic: bool in [true, false]:
				for zoom_value: float in ([0.8,1.0,1.15] if phase == 0 and goal in ["dock","bridge-west","ford-west"] else [1.0]):
					game.camera_rig.zoom_factor = zoom_value
					game.camera_rig.set_orthographic(orthographic)
					game.ui.show_camera(game.camera_rig.description())
					await _river_shot("%s-%s-%s-%s" % [goal, "day" if phase == 0 else "night", "ortho" if orthographic else "persp", str(zoom_value).replace(".","_")])
		# Fixed camera and simulation, real continuously advancing water shader TIME.
		_place(poses.goals.dock.position, poses.goals.dock.companion_position)
		for orthographic: bool in [true,false]:
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for step: int in range(6):
				# SceneTree timers can finish a few ms early at uncapped FPS.
				# Monotonic bound makes the declared capture interval exact.
				var deadline: int = Time.get_ticks_msec() + 400
				while Time.get_ticks_msec() < deadline: await process_frame
				await _river_shot("motion-%s-%s-%02d" % ["day" if phase == 0 else "night", "ortho" if orthographic else "persp",step])
		if phase == 0: await _sample("dock-day")
		# Exact production target resolver/visuals, disposable presentation only.
		var preview: FishingTargetPreview = FishingTargetPreview.new()
		location.add_child(preview)
		var effects: FishingEffects = FishingEffects.new()
		location.add_child(effects)
		var target: Vector3 = Vector3(-4.75,0.015,20.25)
		var result: FishingWaterTargetResolver.Result = preview.refresh(location,game.catalog,game.camera_rig.camera,game.camera_rig.camera.unproject_position(target),game.player_placeholder.global_position,true,game.catalog.get_item("item-fishing-rod").rod_activation)
		if result.status != "eligible": failures.append("synthetic eligible fishing target refused: " + result.reason)
		await _river_shot("fishing-%s-target" % ["day" if phase == 0 else "night"])
		preview.clear()
		for cue: String in ["waiting","bite"]:
			effects.present({"mode":"attempt","phase":cue,"point":target,"phase_seconds":0.5},game.player_placeholder.global_position)
			await _river_shot("fishing-%s-%s" % ["day" if phase == 0 else "night",cue])
		preview.queue_free()
		effects.queue_free()
		await process_frame
	# Close shoreline, then slow camera translation at each zoom bound.
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
	_place(poses.goals.dock.position,poses.goals.dock.companion_position)
	game.camera_rig.set_orthographic(true)
	game.camera_rig.camera.size = 8.0
	game.ui.show_camera(game.camera_rig.description())
	await _river_shot("shore-close")
	game.camera_rig.camera.size = 18.0
	for orthographic: bool in [true,false]:
		for zoom_value: float in [0.8,1.15]:
			game.camera_rig.zoom_factor = zoom_value
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for step: int in range(4):
				_place([-7 + step * 0.08,0,18],[-8.3 + step * 0.08,0,17.5])
				await _river_shot("camera-%s-%s-%02d" % ["ortho" if orthographic else "persp",str(zoom_value).replace(".","_"),step])
	var final_inventory: Dictionary = _physical_inventory(location)
	for key: String in inventory:
		if final_inventory[key] != inventory[key]: failures.append("physical/resource inventory changed: " + key)
	var output: Dictionary = {"task":"AD005","kind":"synthetic feet/day/night/fishing presentation; paused simulation; actual advancing shader TIME; no ordinary cast, route or full profiling", "views":views,"samples":samples,"inventory":inventory,"final_inventory":final_inventory,"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"user_data":OS.get_user_data_dir(),"renderer":RenderingServer.get_current_rendering_method(),"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version()}
	if not TestRunEvidence.write_json("river-index.json",output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD005 river: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _river_shot(label: String) -> void:
	game._present_environment()
	if not game.ui.time_label.text.begins_with(EnvironmentClock.format_time(game.session.environment.day_cycle_progress)): failures.append("HUD preset mismatch: " + label)
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"AD005 fixed fixture feet and detached clear day/night preset; paused routines/actors, real shader TIME; motion frames separated by >=0.4s; fishing uses synthetic production resolver/visual snapshots only; close view camera size8")
	if not capture.ok: failures.append(capture.get("error","capture failed"))
	else:
		capture["ticks_msec"] = Time.get_ticks_msec()
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["rendered_time_weather"] = game.ui.time_label.text
		capture["sun_energy"] = game.get_node("Sun").light_energy
		views.append(capture)
