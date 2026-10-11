extends "res://tests/art_direction_baseline_render.gd"
## AD004 paired, frozen real-renderer ground review. All placements are synthetic.

var inventory: Dictionary = {}

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD004 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	if not startup[0]: failures.append("startup failed")
	game._set_paused(true)
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game, "ad004-ground"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	else:
		var rebound: Array = await game.world_host.transition_finished
		if not rebound[0] or game.world_host.session != game.session: failures.append("session rebind failed")
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	inventory = _physical_inventory(location)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	for condition: WeatherSchedule.Condition in [WeatherSchedule.Condition.SUNNY, WeatherSchedule.Condition.CLOUDY]:
		if not review.apply_preset(0, condition): failures.append("day preset refused")
		var weather: String = "clear" if condition == WeatherSchedule.Condition.SUNNY else "cloudy"
		for goal: String in ["maris", "entry-ramp", "dense-forest", "moonwell"]:
			_place(poses.goals[goal].position, poses.goals[goal].companion_position)
			for orthographic: bool in [true, false]:
				for zoom_value: float in ([0.8, 1.0, 1.15] if condition == WeatherSchedule.Condition.SUNNY and goal != "moonwell" else [1.0]):
					game.camera_rig.zoom_factor = zoom_value
					game.camera_rig.set_orthographic(orthographic)
					game.ui.show_camera(game.camera_rig.description())
					await _ground_shot("%s-%s-%s-%s" % [goal, weather, "ortho" if orthographic else "persp", str(zoom_value).replace(".","_")])
			if goal in ["maris", "dense-forest"] and condition == WeatherSchedule.Condition.SUNNY:
				game.camera_rig.zoom_factor = 1.0
				await _sample(goal + "-clear")
	# Subpixel-to-metre camera motion at both zoom bounds tests procedural filtering.
	if not review.apply_preset(0, WeatherSchedule.Condition.SUNNY): failures.append("clear restore refused")
	var feet: Array = poses.goals["entry-ramp"].position
	var ally: Array = poses.goals["entry-ramp"].companion_position
	for orthographic: bool in [true, false]:
		for zoom_value: float in [0.8, 1.15]:
			game.camera_rig.zoom_factor = zoom_value
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for step: int in range(5):
				var offset: float = step * 0.08
				_place([feet[0] + offset, feet[1], feet[2]], [ally[0] + offset, ally[1], ally[2]])
				await _ground_shot("motion-%s-%s-%02d" % ["ortho" if orthographic else "persp", str(zoom_value).replace(".","_"), step])
	# Close actual ramp/riser junction. HUD/party retained; no mesh replacement.
	_place(poses.goals["entry-ramp"].position, poses.goals["entry-ramp"].companion_position)
	game.camera_rig.zoom_factor = 1.0
	game.camera_rig.set_orthographic(true)
	game.camera_rig.camera.size = 7.0
	game.ui.show_camera(game.camera_rig.description())
	await _ground_shot("ramp-close")
	await _ground_shot("ramp-close-repeat")
	var static_a: Image = Image.load_from_file(views[-2].path).get_region(Rect2i(500, 335, 100, 80))
	var static_b: Image = Image.load_from_file(views[-1].path).get_region(Rect2i(500, 335, 100, 80))
	if static_a.get_data() != static_b.get_data(): failures.append("frozen ground pixels shimmered between frames")
	inventory["static_ground_pixels_identical"] = static_a.get_data() == static_b.get_data()
	game.camera_rig.camera.size = 18.0
	var final_inventory: Dictionary = _physical_inventory(location)
	for key: String in final_inventory:
		if inventory[key] != final_inventory[key]: failures.append("ground/physical inventory changed during review: " + key)
	var output: Dictionary = {"task":"AD004", "kind":"synthetic frozen ground/lighting/party/camera review; no ordinary route or full profiling claim", "views":views, "samples":samples,
		"inventory":inventory, "final_inventory":final_inventory, "failures":failures, "engine_pid":OS.get_process_id(), "engine":Engine.get_version_info(),
		"user_data":OS.get_user_data_dir(), "renderer":RenderingServer.get_current_rendering_method(), "cpu":OS.get_processor_name(), "gpu":RenderingServer.get_video_adapter_name(), "api":RenderingServer.get_video_adapter_api_version()}
	if not TestRunEvidence.write_json("ground-index.json", output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD004 ground: %d captures, %d failures" % [views.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _ground_shot(label: String) -> void:
	game._present_environment()
	if not game.ui.time_label.text.begins_with(EnvironmentClock.format_time(game.session.environment.day_cycle_progress)):
		failures.append("rendered HUD time disagrees: " + label)
	var capture: Dictionary = await TestRunCapture.capture(game, label, TestRunEvidence.directory(), "synthetic", false,
		"AD004: fixed fixture feet and detached day clear/cloudy preset; routines paused; 5-frame interpolated party/camera motion only; HUD visible; close ramp changes camera size only")
	if not capture.ok: failures.append(capture.get("error", "capture failed"))
	else:
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["rendered_time_weather"] = game.ui.time_label.text
		capture["sun_energy"] = game.get_node("Sun").light_energy
		views.append(capture)

func _physical_inventory(location: AlderwakeTerrainPreview) -> Dictionary:
	var meshes: Dictionary = {}
	for parent: Node in [location.get_node("TerrainVisuals"), location.elevation, location.water_blockers.get_node("WaterVisuals")]:
		for child: Node in parent.get_children():
			if child is MeshInstance3D:
				var data: PackedVector3Array = child.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				meshes[str(child.name)] = data.to_byte_array().hex_encode().sha256_text()
	return {"semantic_rgba_sha256":location.landscape.mask_image.get_data().hex_encode().sha256_text(),
		"floor_vertices_sha256":location.elevation.floor_faces.to_byte_array().hex_encode().sha256_text(), "render_mesh_vertex_hashes":meshes,
		"terrain_batches":location.batch_count, "riser_batches":location.elevation.riser_batches.size(), "levels":location.elevation.levels.size(),
		"slopes":location.elevation.slopes.size(), "cliffs":location.elevation.cliffs.size(), "wet_cells":location.water_blockers.water_cells.size(),
		"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT)}
