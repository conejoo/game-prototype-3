extends "res://tests/art_direction_ground_render.gd"
## AD009 actual engine coverage; all diagnostic placements/time are synthetic.

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD009 requires real renderer")
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
	failures.append_array(review.initialize(game,"ad009-town"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	elif not (await game.world_host.transition_finished)[0]: failures.append("review rebind failed")
	var location: AlderwakeExterior = game.world_host.current_location
	inventory = _physical_inventory(location)
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day preset refused")
	var poses: Dictionary = {"street":[-7,0,4],"river":[-8,0,18],"civic":[1,0,-5],"rear":[-6,0,-12],"woodland":[23,0,8.75],"quay":[41,0,19.5]}
	for label: String in poses:
		var feet: Array = poses[label]
		_place(feet,[feet[0]+1.2,feet[1],feet[2]-.5])
		for ortho: bool in [true,false]:
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig.set_orthographic(ortho)
			game.ui.show_camera(game.camera_rig.description())
			await _town_shot(label+ ("-ortho" if ortho else "-persp"))
		if label in ["street","river"]: await _sample(label+"-day")
	_place(poses.street,[-5.8,0,3.5])
	for ortho: bool in [true,false]:
		for zoom_value: float in [.8,1.15]:
			game.camera_rig.zoom_factor = zoom_value
			game.camera_rig.set_orthographic(ortho)
			game.ui.show_camera(game.camera_rig.description())
			await _town_shot("zoom-%s-%s" % ["ortho" if ortho else "persp",str(zoom_value).replace(".","_")])
	if not review.apply_preset(2,WeatherSchedule.Condition.SUNNY): failures.append("night preset refused")
	var window_states: Array[Dictionary] = []
	for consumer: ExteriorLightConsumer in location.exterior_lights.consumers.values():
		if consumer.source_kind != "windows": continue
		game._present_environment()
		if consumer.enabled != game.session.environment.light_enabled(LightSourceRegistry.LOCATION_ID,consumer.prop_id,consumer.source_id): failures.append("window state mismatch")
		if not is_equal_approx(consumer.glow_material.emission_energy_multiplier,consumer.intensity*1.4): failures.append("window emission mismatch")
		window_states.append({"id":consumer.prop_id,"enabled":consumer.enabled,"intensity":consumer.intensity,"panes":consumer.pane_count,"emission":consumer.glow_material.emission_energy_multiplier})
	for label: String in ["street","river","civic"]:
		var feet: Array = poses[label]
		_place(feet,[feet[0]+1.2,feet[1],feet[2]-.5])
		for ortho: bool in [true,false]:
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig.set_orthographic(ortho)
			game.ui.show_camera(game.camera_rig.description())
			await _town_shot(label+ ("-night-ortho" if ortho else "-night-persp"))
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
	# Isolated copies of actual imported meshes above town expose all faces without
	# neighbor occlusion. This is an engine diagnostic gallery, not ordinary play.
	game.ui.visible = false
	var gallery: MeshInstance3D = MeshInstance3D.new()
	game.add_child(gallery)
	gallery.global_position = Vector3(0,40,0)
	var checker: ShaderMaterial = ShaderMaterial.new()
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial; void fragment(){float c=mod(floor(UV.x*128.0)+floor(UV.y*128.0),2.0);ALBEDO=mix(vec3(.1),vec3(.8),c);ROUGHNESS=1.0;}"
	checker.shader = shader
	var coverage: Array[Dictionary] = []
	for id: String in location.town_art.mappings:
		if not location.town_art.mappings[id].has("definition_id"): continue
		gallery.mesh = location.town_art.meshes[location.town_art.mappings[id].mesh_name]
		var bounds: AABB = gallery.mesh.get_aabb()
		var focus: Vector3 = gallery.global_position + bounds.get_center()
		game.camera_rig.set_orthographic(true)
		game.camera_rig.camera.size = maxf(bounds.size.x,bounds.size.z)*1.4+2.5
		for angle: float in [45,135,225,315]:
			game.camera_rig.camera.global_position = focus+Vector3(sin(deg_to_rad(angle))*9,5,cos(deg_to_rad(angle))*9)
			game.camera_rig.camera.look_at(focus,Vector3.UP)
			await _town_shot("%s-face-%03d" % [id,int(angle)])
		gallery.material_override = checker
		await _town_shot(id+"-checker")
		gallery.material_override = null
		coverage.append({"definition":id,"mesh":location.town_art.mappings[id].mesh_name,"group":AlderwakeTownArt.building_group(id),"angles":[45,135,225,315],"bounds":str(bounds)})
	gallery.free()
	game.ui.visible = true
	var final_inventory: Dictionary = _physical_inventory(location)
	for key: String in inventory:
		if key != "nodes" and inventory[key] != final_inventory[key]: failures.append("physical inventory changed: "+key)
	if coverage.size() != 14 or window_states.size() != 14: failures.append("building/window coverage incomplete")
	var output: Dictionary = {"task":"AD009","kind":"synthetic frozen engine town/gallery review; no normal travel/native/save/full-profile claim","views":views,"samples":samples,"coverage":coverage,"windows":window_states,"inventory":inventory,"final_inventory":final_inventory,"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"user_data":OS.get_user_data_dir(),"renderer":RenderingServer.get_current_rendering_method()}
	if not TestRunEvidence.write_json("town-index.json",output): failures.append("index failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD009 town: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _town_shot(label: String) -> void:
	game._present_environment()
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"AD009 synthetic frozen feet/time/weather/camera; gameplay HUD in town; isolated elevated source-mesh copies and checker/HUD-hidden gallery")
	if not capture.ok: failures.append(str(capture.get("error","capture failed")))
	else:
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["hud_visible"] = game.ui.visible
		capture["sun_energy"] = game.get_node("Sun").light_energy
		views.append(capture)
