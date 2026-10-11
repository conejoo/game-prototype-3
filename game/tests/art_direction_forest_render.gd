extends "res://tests/art_direction_ground_render.gd"
## AD010 engine review. Separate fresh ordinary-input journey; no save/native claim.

var art: AlderwakeTreeArt
var journey: Array[Dictionary] = []
var shadows: Array[Dictionary] = []
var coverage: Array[Dictionary] = []

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD010 requires real renderer")
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
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	art = location.tree_art
	var ordinary: bool = "--phase=journey" in OS.get_cmdline_user_args()
	if ordinary:
		await _ordinary()
	else:
		await _review(location)
	var output: Dictionary = {"task":"AD010","ordinary":ordinary,"views":views,"samples":samples,"journey":journey,"shadows":shadows,"coverage":coverage,"inventory":inventory,"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),"scope":"fresh ordinary WASD motion" if ordinary else "synthetic frozen feet/time/weather and gallery; short paused sample, not AD019"}
	if not TestRunEvidence.write_json("forest-journey-index.json" if ordinary else "forest-index.json",output): failures.append("index failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD010 forest: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _review(location: AlderwakeTerrainPreview) -> void:
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game,"ad010-forest"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty():
		failures.append("rebind refused")
		return
	if not (await game.world_host.transition_finished)[0]:
		failures.append("rebind failed")
		return
	location = game.world_host.current_location
	art = location.tree_art
	inventory = _physical_inventory(location)
	inventory["trees"] = art.tree_ids.size()
	inventory["variants"] = art.meshes.size()
	inventory["batches"] = art.batches.size()
	inventory["materials"] = art.visibility_materials.size()
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	for phase: int in [0,2]:
		if not review.apply_preset(phase,WeatherSchedule.Condition.SUNNY): failures.append("preset refused")
		for goal: String in ["dense-forest","moonwell","bridge-west","bridge-east","ford-west","ford-east","closed-exit"]:
			_place(poses.goals[goal].position,poses.goals[goal].companion_position)
			for ortho: bool in [true,false]:
				_projection(ortho,1.0)
				await _shot("%s-%s-%s" % [goal,"day" if phase == 0 else "night","ortho" if ortho else "persp"])
			if goal == "dense-forest": await _sample("dense-forest-"+str(phase))
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
	_place(poses.goals["dense-forest"].position,poses.goals["dense-forest"].companion_position)
	for ortho: bool in [true,false]:
		for zoom_value: float in [.8,1.15]:
			_projection(ortho,zoom_value)
			await _shot("forest-zoom-%s-%s" % [str(ortho),str(zoom_value).replace(".","_")])
	if "--phase=before" in OS.get_cmdline_user_args(): return
	game.set_process(false)
	# Dense mixed-species stand, same accepted canopy control foot as AD003.
	var target: Node3D
	var nearest: float = INF
	for record: Dictionary in location.forest.prop_records:
		if record.tree == null or record.tree.species != "oak": continue
		var wrapper: Node3D = location.forest.get_node(NodePath(record.id))
		if wrapper.position.distance_to(game.player_placeholder.position) < nearest:
			nearest = wrapper.position.distance_to(game.player_placeholder.position)
			target = wrapper
	var center: Vector3 = target.position+art.meshes[target.get_meta("tree_art_mesh")].get_aabb().get_center()*Vector3(1,0,1)
	center.y = location.elevation.height_at(Vector2(center.x,center.z))
	_place(TestRunObservation.vector(center+Vector3(-.55,0,.25)),TestRunObservation.vector(center+Vector3(.55,0,.25)))
	for ortho: bool in [true,false]:
		for zoom_value: float in [.8,1.15]:
			_projection(ortho,zoom_value)
			await _shot("canopy-%s-%s-on" % [str(ortho),str(zoom_value).replace(".","_")])
			await _shot("canopy-%s-%s-off" % [str(ortho),str(zoom_value).replace(".","_")],false)
	game.ui.visible = false
	var water: Node3D = location.water_blockers.get_node("WaterVisuals")
	water.visible = false
	for batch: MultiMeshInstance3D in art.batches.values(): batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	for ortho: bool in [true,false]:
		_projection(ortho,1.0)
		await _shot("shadows-%s-on" % str(ortho))
		await _shot("shadows-%s-off" % str(ortho),false)
		var equal: bool = Image.load_from_file(views[-2].path).get_data() == Image.load_from_file(views[-1].path).get_data()
		shadows.append({"orthographic":ortho,"identical_pixels":equal})
		if not equal: failures.append("cutout leaked into shadow pass")
	for batch: MultiMeshInstance3D in art.batches.values(): batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	water.visible = true
	var nodes: float = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var resources: float = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	await _gallery(art.meshes,"tree")
	await _gallery(location.landmark_art.meshes,"landmark")
	await process_frame
	inventory["after_gallery_nodes"] = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	inventory["after_gallery_resources"] = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	if nodes != inventory.after_gallery_nodes or resources != inventory.after_gallery_resources: failures.append("gallery resource/node leak")
	var after: Dictionary = _physical_inventory(location)
	for field: String in after:
		if inventory[field] != after[field]: failures.append("physical inventory changed: "+field)
	if coverage.size() != 26: failures.append("variant/module gallery incomplete")

func _gallery(meshes: Dictionary,kind: String) -> void:
	var gallery: MeshInstance3D = MeshInstance3D.new()
	game.add_child(gallery)
	gallery.position = Vector3(0,40,0)
	var checker: ShaderMaterial = ShaderMaterial.new()
	var shader: Shader = Shader.new()
	shader.code = "shader_type spatial;void fragment(){float c=mod(floor(UV.x*128.0)+floor(UV.y*128.0),2.0);ALBEDO=mix(vec3(.1),vec3(.8),c);ROUGHNESS=1.0;}"
	checker.shader = shader
	for id: String in meshes:
		gallery.mesh = meshes[id]
		var bounds: AABB = gallery.mesh.get_aabb()
		var focus: Vector3 = gallery.global_position+bounds.get_center()
		_projection(true,1.0)
		game.camera_rig.camera.size = maxf(maxf(bounds.size.x,bounds.size.y),bounds.size.z)*1.25+1
		for angle: float in [45,180,270]:
			game.camera_rig.camera.global_position = focus+Vector3(sin(deg_to_rad(angle))*10,5,cos(deg_to_rad(angle))*10)
			game.camera_rig.camera.look_at(focus,Vector3.UP)
			await _shot("%s-%s-face-%d" % [kind,id,int(angle)],false)
		gallery.material_override = checker
		await _shot(kind+"-"+id+"-checker",false)
		gallery.material_override = null
		coverage.append({"kind":kind,"mesh":id,"angles":[45,180,270],"checker":true})
	gallery.free()

func _ordinary() -> void:
	await _shot("ordinary-start")
	var resumed: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	if not resumed.ok:
		failures.append(str(resumed.get("error","resume failed")))
		return
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_D; event.physical_keycode = KEY_D; event.pressed = true
	var start: Vector3 = game.player_placeholder.global_position
	root.push_input(event,true)
	for frame: int in range(15): await physics_frame
	event = InputEventKey.new(); event.keycode = KEY_D; event.physical_keycode = KEY_D; event.pressed = false
	root.push_input(event,true)
	if game.player_placeholder.global_position.distance_to(start) <= .1:
		failures.append("fresh normal D preflight failed")
		return
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	for goal: String in ["moonwell","ford-west","ford-east","bridge-east","bridge-west","dense-forest"]:
		var p: Array = poses.goals[goal].position
		var result: Dictionary = await TestRunJourney.walk(game,Vector3(p[0],p[1],p[2]),goal)
		journey.append(result)
		game._set_paused(true)
		await _shot("ordinary-"+goal)
		if not result.ok:
			failures.append(result.error)
			return
		resumed = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
		if not resumed.ok:
			failures.append("resume after route failed")
			return
	game._set_paused(true)
	# Real bounded D input produces successive forest poses; each capture verifies
	# pause after release. No interpolated/assigned feet or accelerated simulation.
	for ortho: bool in [true,false]:
		_projection(ortho,1.0)
		var motion_start: Vector3 = game.player_placeholder.global_position
		for step: int in range(5):
			resumed = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
			if not resumed.ok:
				failures.append("motion resume failed")
				return
			event = InputEventKey.new(); event.keycode = KEY_D; event.physical_keycode = KEY_D; event.pressed = true
			root.push_input(event,true)
			for frame: int in range(6): await physics_frame
			event = InputEventKey.new(); event.keycode = KEY_D; event.physical_keycode = KEY_D; event.pressed = false
			root.push_input(event,true)
			game._set_paused(true)
			await _shot("ordinary-motion-%s-%d" % [str(ortho),step])
		if game.player_placeholder.global_position.distance_to(motion_start) <= .1: failures.append("normal motion sequence did not move")
	if not game.player_placeholder.movement_buttons.is_empty(): failures.append("ordinary input not released")

func _projection(ortho: bool,zoom_value: float) -> void:
	game.camera_rig.zoom_factor = zoom_value
	game.camera_rig.set_orthographic(ortho)
	game.ui.show_camera(game.camera_rig.description())

func _shot(label: String,protection: bool = true) -> void:
	game._present_environment()
	art.update_visibility(game.camera_rig.camera,game.player_placeholder,game.companion)
	for material: ShaderMaterial in art.visibility_materials: material.set_shader_parameter("protect_party",protection)
	var ordinary: bool = label.begins_with("ordinary")
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic",false,"AD010 fresh ordinary WASD route; observed arrival and pause" if ordinary else "AD010 synthetic frozen feet/day-night/camera; canopy/shadows-only water-hidden controls; elevated real imported mesh/checker gallery")
	if not capture.ok: failures.append(str(capture.get("error","capture failed")))
	else:
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["hud_visible"] = game.ui.visible
		capture["party_protection"] = protection
		var hero_screen: Vector2 = game.camera_rig.camera.unproject_position(game.player_placeholder.global_position+Vector3.UP*.8)
		capture["hero_screen"] = [hero_screen.x,hero_screen.y]
		var ally_screen: Vector2 = game.camera_rig.camera.unproject_position(game.companion.global_position+Vector3.UP*.8)
		capture["ally_screen"] = [ally_screen.x,ally_screen.y]
		views.append(capture)
