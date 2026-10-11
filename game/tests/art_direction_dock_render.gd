extends "res://tests/art_direction_ground_render.gd"
## AD006 controlled material review; ordinary input phase starts fresh, no setup.

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD006 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup failed")
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var ordinary: bool = "--phase=approach" in OS.get_cmdline_user_args()
	var journey: Array[Dictionary] = []
	if ordinary:
		game._set_paused(true)
		await _dock_shot("ordinary-start",true)
		game._set_paused(false)
		var preflight_start: Vector3 = game.player_placeholder.global_position
		var key: InputEventKey = InputEventKey.new()
		key.keycode = KEY_D
		key.physical_keycode = KEY_D
		key.pressed = true
		root.push_input(key,true)
		for frame: int in range(15): await physics_frame
		key = InputEventKey.new()
		key.keycode = KEY_D
		key.physical_keycode = KEY_D
		key.pressed = false
		root.push_input(key,true)
		if game.player_placeholder.global_position.distance_to(preflight_start) <= 0.1: failures.append("ordinary short movement preflight failed")
		journey.append({"label":"movement-preflight","start":TestRunObservation.vector(preflight_start),"actual":TestRunObservation.vector(game.player_placeholder.global_position),"camera":TestRunObservation.camera(game),"released":game.player_placeholder.movement_buttons.is_empty()})
		# Fresh default startup only. walk injects normal camera-relative WASD,
		# checks navigation owner, focus, arrival, stall and owned key release.
		for goal: Vector3 in [Vector3(-6.5,0,14.1),Vector3(-6.5,0,15.5),Vector3(-8,0,18.25),Vector3(-6.5,0,14.1)]:
			var result: Dictionary = await TestRunJourney.walk(game,goal,"dock-%d" % journey.size())
			journey.append(result)
			if not result.ok:
				failures.append(result.error)
				break
			game._set_paused(true)
			await _dock_shot("ordinary-%02d" % journey.size(),true)
			game._set_paused(false)
		game._set_paused(true)
	else:
		game._set_paused(true)
		review = REVIEW.new()
		game.add_child(review)
		failures.append_array(review.initialize(game,"ad006-dock"))
		game._pending_restore = game.session
		var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
		if not errors.is_empty(): failures.append("review rebind refused")
		elif not (await game.world_host.transition_finished)[0]: failures.append("rebind failed")
		inventory = _dock_inventory(game.world_host.current_location)
		var goals: Dictionary = {"street":[-7,0,12],"river":[-8,0,18],"plaza":[8,0,4.5],"quay":[35,0,26]}
		for phase: int in [0,2]:
			if not review.apply_preset(phase,WeatherSchedule.Condition.SUNNY): failures.append("preset refused")
			for label: String in goals:
				var p: Array = goals[label]
				_place(p,[p[0]+1.2,p[1],p[2]-0.5])
				for ortho: bool in [true,false]:
					for zoom_value: float in ([0.8,1.0,1.15] if phase == 0 else [1.0]):
						game.camera_rig.zoom_factor = zoom_value
						game.camera_rig.set_orthographic(ortho)
						game.ui.show_camera(game.camera_rig.description())
						await _dock_shot("%s-%s-%s-%s" % [label,"day" if phase == 0 else "night","ortho" if ortho else "persp",str(zoom_value).replace(".","_")])
			if phase == 0:
				game.camera_rig.zoom_factor = 1.0
				await _sample("quay-day")
		if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
		game.ui.visible = false
		game.camera_rig.set_orthographic(true)
		game.camera_rig.camera.size = 5
		for subject: Dictionary in [{"id":"dock","focus":Vector3(-8,0,18)},{"id":"wall","focus":Vector3(-16,0.3,4.5)},{"id":"quay","focus":Vector3(44.5,0,24)}]:
			for angle: int in [45,180,270]:
				game.camera_rig.camera.global_position = subject.focus + Vector3(sin(deg_to_rad(angle))*7,4,cos(deg_to_rad(angle))*7)
				game.camera_rig.camera.look_at(subject.focus)
				await _dock_shot("%s-close-%d" % [subject.id,angle])
				if angle == 45 and subject.id in ["dock","wall"]:
					await create_timer(0.5,true).timeout
					await _dock_shot("%s-close-%d-repeat" % [subject.id,angle])
		# UV checker on existing shared module geometry, no source mutation.
		var checker: ShaderMaterial = ShaderMaterial.new()
		var checker_shader: Shader = Shader.new()
		checker_shader.code = "shader_type spatial; void fragment(){float c=mod(floor(UV.x*128.0)+floor(UV.y*128.0),2.0);ALBEDO=mix(vec3(0.15),vec3(0.75),c);ROUGHNESS=1.0;}"
		checker.shader = checker_shader
		var changed: Array[MeshInstance3D] = []
		for child: Node in game.world_host.current_location.town.find_children("*","MeshInstance3D",true,false):
			if child.has_meta("module_id"):
				child.material_override = checker
				changed.append(child)
		for subject: Dictionary in [{"id":"dock","focus":Vector3(-8,0,18)},{"id":"quay","focus":Vector3(44.5,0,24)}]:
			game.camera_rig.camera.global_position = subject.focus + Vector3(4,4,6)
			game.camera_rig.camera.look_at(subject.focus)
			await _dock_shot(subject.id+"-checker")
		for child: MeshInstance3D in changed: child.material_override = null
		game.ui.visible = true
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var output: Dictionary = {"task":"AD006","ordinary":ordinary,"views":views,"samples":samples,"journey":journey,"inventory":inventory,"final_inventory":_dock_inventory(location),"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version()}
	if not TestRunEvidence.write_json("dock-approach-index.json" if ordinary else "dock-index.json",output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD006 dock: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _dock_shot(label: String, ordinary: bool = false) -> void:
	game._present_environment()
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic",false,"AD006 fresh startup normal camera-relative WASD dock approach; paused after arrival" if ordinary else "AD006 fixed feet/day-night weather; paused actors/routines; close camera diagnostic")
	if not capture.ok: failures.append(capture.get("error","capture failed"))
	else:
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["rendered_time_weather"] = game.ui.time_label.text
		views.append(capture)

func _dock_inventory(location: AlderwakeTerrainPreview) -> Dictionary:
	var result: Dictionary = _physical_inventory(location)
	var town_meshes: Dictionary = {}
	for child: Node in location.town.find_children("*","MeshInstance3D",true,false):
		var mesh: Mesh = child.mesh
		var arrays: Array = mesh.surface_get_arrays(0)
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		# Sort triangle coordinates: UV splitting changes vertex inventory, never
		# physical triangle positions. Preserve world transforms independently.
		var triangles: PackedStringArray = []
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		for vertex_index: int in (indices if not indices.is_empty() else range(points.size())):
			triangles.append("%.5f,%.5f,%.5f" % [points[vertex_index].x,points[vertex_index].y,points[vertex_index].z])
		triangles.sort()
		town_meshes[str(location.town.get_path_to(child))] = {"vertices":str(triangles).sha256_text(),"transform":str(child.global_transform)}
	result.town_meshes = town_meshes
	result.dock_rectangles = str(location.town_art.dock_rectangles)
	result.module_count = location.town_art.module_count
	result.quay_cells = location.town_art.quay_cells
	return result
