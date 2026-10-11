extends "res://tests/art_direction_baseline_render.gd"
## AD003 frozen engine review and synthetic moving-camera samples. No route claim.

var art: AlderwakeTreeArt
var shadow_comparisons: Array[Dictionary] = []
var inventory: Dictionary = {}

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD003 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	if not startup[0]: failures.append("startup failed")
	game._set_paused(true)
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game, "ad003-tree"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	else:
		var rebound: Array = await game.world_host.transition_finished
		if not rebound[0] or game.world_host.session != game.session: failures.append("session rebind failed")
	if not review.apply_preset(0, WeatherSchedule.Condition.SUNNY): failures.append("day preset refused")
	# Root normally refreshes protect_party every frame; diagnostics own toggles.
	game.set_process(false)
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	art = location.tree_art
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	_place(poses.goals["dense-forest"].position, poses.goals["dense-forest"].companion_position)
	for orthographic: bool in [true, false]:
		game.camera_rig.set_orthographic(orthographic)
		game.ui.show_camera(game.camera_rig.description())
		await _shot("dense-forest-" + ("orthographic" if orthographic else "perspective"))
	var target: Node3D
	var nearest: float = INF
	for record: Dictionary in location.forest.prop_records:
		if record.tree == null or record.tree.species != "oak": continue
		var wrapper: Node3D = location.forest.get_node(NodePath(record.id))
		var distance: float = wrapper.position.distance_to(game.player_placeholder.position)
		if distance < nearest:
			nearest = distance
			target = wrapper
	if target == null:
		failures.append("oak pilot target absent")
	else:
		var mesh: Mesh = art.meshes[target.get_meta("tree_art_mesh")]
		var center: Vector3 = target.position + mesh.get_aabb().get_center() * Vector3(1,0,1)
		center.y = location.elevation.height_at(Vector2(center.x, center.z))
		inventory = {"trees":art.tree_ids.size(), "variants":art.meshes.size(), "batches":art.batches.size(), "materials":art.visibility_materials.size(),
			"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT), "texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED), "target_id":target.name}
		# Deliberate visual placement beneath canopy; does not prove physical route.
		_place_vectors(center + Vector3(-0.55,0,0.25), center + Vector3(0.55,0,0.25))
		for orthographic: bool in [true, false]:
			for zoom_value: float in [0.8, 1.0, 1.15]:
				game.camera_rig.zoom_factor = zoom_value
				game.camera_rig.set_orthographic(orthographic)
				game.ui.show_camera(game.camera_rig.description())
				var label: String = "canopy-%s-%s" % ["orthographic" if orthographic else "perspective", str(zoom_value).replace(".","_")]
				await _shot(label)
				await _shot(label + "-cutout-off", false)
		# Actual rendered shader/camera continuity; simulation remains frozen.
		for orthographic: bool in [true, false]:
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for step: int in range(9):
				var offset: Vector3 = Vector3(lerpf(-1.8,1.8,step/8.0),0,0.25)
				_place_vectors(center + offset + Vector3(-0.55,0,0), center + offset + Vector3(0.55,0,0))
				await _shot("motion-%s-%02d" % ["orthographic" if orthographic else "perspective", step])
		# Show only shadow-casting tree meshes. Protection toggle must have zero
		# effect on ground shadow pixels, in either camera projection.
		_place_vectors(center + Vector3(-0.55,0,0.25), center + Vector3(0.55,0,0.25))
		inventory["after_motion_nodes"] = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
		inventory["after_motion_resources"] = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
		if inventory.nodes != inventory.after_motion_nodes or inventory.resources != inventory.after_motion_resources: failures.append("node/resource growth during motion")
		game.ui.visible = false
		# River shader uses wall-clock TIME even while simulation is paused.
		# Hide its visual only for isolated shadow comparison, then restore it.
		var water_visuals: Node3D = location.water_blockers.get_node("WaterVisuals")
		water_visuals.visible = false
		for batch: MultiMeshInstance3D in art.batches.values(): batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		for orthographic: bool in [true, false]:
			game.camera_rig.set_orthographic(orthographic)
			var label: String = "shadow-only-" + ("orthographic" if orthographic else "perspective")
			await _shot(label + "-on")
			await _shot(label + "-off", false)
			var image_on: Image = Image.load_from_file(views[-2].path)
			var image_off: Image = Image.load_from_file(views[-1].path)
			var equal: bool = image_on.get_data() == image_off.get_data()
			shadow_comparisons.append({"projection":label, "identical_pixels":equal})
			if not equal: failures.append("party hole leaked into shadow pass: " + label)
		for batch: MultiMeshInstance3D in art.batches.values(): batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		water_visuals.visible = true
		# Isolate a real pilot mesh for six-angle/checker coverage diagnostics.
		var gameplay_rotation: Vector3 = game.camera_rig.camera.rotation
		for batch: MultiMeshInstance3D in art.batches.values(): batch.visible = false
		var solo: MeshInstance3D = MeshInstance3D.new()
		solo.mesh = mesh
		location.add_child(solo)
		solo.transform = target.transform
		game.player_placeholder.get_node("VisualRoot").visible = false
		game.companion.get_node("VisualRoot").visible = false
		game.camera_rig.set_orthographic(true)
		game.camera_rig.camera.size = 5.5
		var focus: Vector3 = center + Vector3.UP * 1.7
		for angle: float in [0,45,90,180,225,270]:
			game.camera_rig.camera.global_position = focus + Vector3(sin(deg_to_rad(angle))*7,4,cos(deg_to_rad(angle))*7)
			game.camera_rig.camera.look_at(focus,Vector3.UP)
			await _shot("oak-close-%03d" % int(angle), false)
		var checker: ShaderMaterial = ShaderMaterial.new()
		var checker_shader: Shader = Shader.new()
		checker_shader.code = "shader_type spatial; void fragment(){float c=mod(floor(UV.x*128.0)+floor(UV.y*128.0),2.0); ALBEDO=mix(vec3(0.12),vec3(0.8),c);ROUGHNESS=1.0;}"
		checker.shader = checker_shader
		solo.material_override = checker
		for angle: float in [45,180,270]:
			game.camera_rig.camera.global_position = focus + Vector3(sin(deg_to_rad(angle))*7,4,cos(deg_to_rad(angle))*7)
			game.camera_rig.camera.look_at(focus,Vector3.UP)
			await _shot("oak-checker-%03d" % int(angle), false)
		solo.queue_free()
		game.player_placeholder.get_node("VisualRoot").visible = true
		game.companion.get_node("VisualRoot").visible = true
		for batch: MultiMeshInstance3D in art.batches.values(): batch.visible = true
		game.ui.visible = true
		game.camera_rig.zoom_factor = 1.0
		game.camera_rig.camera.rotation = gameplay_rotation
		game.camera_rig.set_orthographic(true)
		game.ui.show_camera(game.camera_rig.description())
		_place(poses.goals["dense-forest"].position, poses.goals["dense-forest"].companion_position)
		await _shot("dense-forest-final")
		for field: String in ["batches", "materials"]:
			if inventory[field] != (art.batches.size() if field == "batches" else art.visibility_materials.size()): failures.append("inventory grew: " + field)
	var output: Dictionary = {"task":"AD003", "kind":"synthetic frozen tree review; motion samples interpolate party/camera only; no ordinary route or performance claim", "views":views, "failures":failures, "inventory":inventory,
		"shadow_comparisons":shadow_comparisons, "engine_pid":OS.get_process_id(), "engine":Engine.get_version_info(), "user_data":OS.get_user_data_dir(), "renderer":RenderingServer.get_current_rendering_method()}
	if not TestRunEvidence.write_json("tree-index.json", output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD003 tree pilot: %d captures, %d failures" % [views.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _place_vectors(hero: Vector3, ally: Vector3) -> void:
	_place([hero.x,hero.y,hero.z], [ally.x,ally.y,ally.z])

func _shot(label: String, protection: bool = true) -> void:
	game._present_environment()
	art.update_visibility(game.camera_rig.camera,game.player_placeholder,game.companion)
	for material: ShaderMaterial in art.visibility_materials: material.set_shader_parameter("protect_party",protection)
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,
		"AD003 frozen fixture feet/day/clear; deliberately placed under oak; interpolated motion; close/checker/shadow-only diagnostics; ordinary HUD except close/shadow diagnostic")
	if not capture.ok: failures.append(str(capture.get("error","capture failed")))
	else:
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		var hero_screen: Vector2 = game.camera_rig.camera.unproject_position(game.player_placeholder.global_position + Vector3.UP * 0.8)
		var ally_screen: Vector2 = game.camera_rig.camera.unproject_position(game.companion.global_position + Vector3.UP * 0.8)
		capture["hero_screen"] = [hero_screen.x,hero_screen.y]
		capture["ally_screen"] = [ally_screen.x,ally_screen.y]
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["hud_visible"] = game.ui.visible
		capture["party_protection"] = protection
		views.append(capture)
