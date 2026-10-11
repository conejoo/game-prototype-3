extends "res://tests/art_direction_baseline_render.gd"
## AD002 synthetic frozen pilot review; no normal route/save/performance claim.

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD002 requires real renderer")
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
	failures.append_array(review.initialize(game, "ad002-shop"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
	if not errors.is_empty(): failures.append("review rebind refused")
	else:
		var rebound: Array = await game.world_host.transition_finished
		if not rebound[0] or game.world_host.session != game.session: failures.append("session rebind failed")
	if not review.apply_preset(0, WeatherSchedule.Condition.SUNNY): failures.append("day preset refused")
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	_place(poses.goals.maris.position, poses.goals.maris.companion_position)
	var location: Node3D = game.world_host.current_location
	var counter: MarisCounter = location.find_child("MarisCounter", true, false)
	if counter == null:
		failures.append("counter missing")
	else:
		_check_counter(counter)
	for orthographic: bool in [true, false]:
		for zoom_value: float in [0.8, 1.0, 1.15]:
			game.camera_rig.zoom_factor = zoom_value
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			await _shot("maris-%s-%s" % ["orthographic" if orthographic else "perspective", str(zoom_value).replace(".", "_")])
	if not review.apply_preset(2, WeatherSchedule.Condition.THUNDERSTORM): failures.append("night preset refused")
	for orthographic: bool in [true, false]:
		game.camera_rig.zoom_factor = 1.0
		game.camera_rig.set_orthographic(orthographic)
		game.ui.show_camera(game.camera_rig.description())
		await _shot("night-storm-" + ("orthographic" if orthographic else "perspective"))
	if not review.apply_preset(0, WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
	# Close engine diagnostic from six angles exposes every front/back/side surface.
	var shop: Node3D
	for wrapper: Node in location.find_children("*", "Node3D", true, false):
		if wrapper.get_meta("town_art_definition", "") == "reed-chandlery": shop = wrapper
	if shop == null: failures.append("mapped shop missing")
	else:
		game.camera_rig.set_orthographic(true)
		game.camera_rig.camera.size = 8
		var focus: Vector3 = shop.global_position + Vector3(-0.17, 1, -1.19)
		game.ui.visible = false
		for angle: float in [0, 45, 90, 180, 225, 270]:
			game.camera_rig.camera.global_position = focus + Vector3(sin(deg_to_rad(angle))*8, 5, cos(deg_to_rad(angle))*8)
			game.camera_rig.camera.look_at(focus, Vector3.UP)
			await _shot("shop-close-%03d" % int(angle))
		var visual: MeshInstance3D = shop.get_node("VisualRoot/ImportedExterior")
		var checker: ShaderMaterial = ShaderMaterial.new()
		var shader: Shader = Shader.new()
		shader.code = "shader_type spatial; void fragment(){float c=mod(floor(UV.x*64.0)+floor(UV.y*64.0),2.0); ALBEDO=mix(vec3(0.12),vec3(0.8),c);ROUGHNESS=1.0;}"
		checker.shader = shader
		visual.material_override = checker
		for angle: float in [45, 180, 270]:
			game.camera_rig.camera.global_position = focus + Vector3(sin(deg_to_rad(angle))*8, 5, cos(deg_to_rad(angle))*8)
			game.camera_rig.camera.look_at(focus, Vector3.UP)
			await _shot("shop-checker-%03d" % int(angle))
		visual.material_override = null
		game.ui.visible = true
	# Synthetic counter-state swatches use existing fact presentation API only.
	if counter != null:
		game.camera_rig.set_orthographic(true)
		game.camera_rig.camera.size = 5
		var focus: Vector3 = counter.global_position + Vector3(0, 0.6, 0.8)
		game.camera_rig.camera.global_position = focus + Vector3(3, 4, 5)
		game.camera_rig.camera.look_at(focus, Vector3.UP)
		game.ui.visible = false
		for stage: String in ["basic", "fitting", "specialist"]:
			counter.apply_facts(PackedStringArray([] if stage == "basic" else (["maris-returned-to-town"] if stage == "fitting" else ["maris-reconnected"])))
			await _shot("counter-close-" + stage)
		game.ui.visible = true
	var output: Dictionary = {"task":"AD002", "kind":"synthetic frozen pilot: fixture feet/time/weather/camera and counter fact presentation; not normal play", "views":views, "failures":failures,
		"engine_pid":OS.get_process_id(), "engine":Engine.get_version_info(), "user_data":OS.get_user_data_dir(), "renderer":RenderingServer.get_current_rendering_method(),
		"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED), "nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)}
	if not TestRunEvidence.write_json("shop-index.json", output): failures.append("index failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD002 pilot: %d captures, %d failures" % [views.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)


func _shot(label: String) -> void:
	game._present_environment()
	var capture: Dictionary = await TestRunCapture.capture(game, label, TestRunEvidence.directory(), "synthetic", false,
		"AD002 frozen fixture feet and environment_review presets; ordinary HUD at gameplay zoom; close diagnostic camera/HUD hidden and counter stage injection explicitly synthetic")
	if not capture.ok: failures.append(str(capture.get("error", "capture failed")))
	else:
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["hud_visible"] = game.ui.visible
		capture["sun_energy"] = game.get_node("Sun").light_energy
		views.append(capture)


func _check_counter(counter: MarisCounter) -> void:
	var bench: MeshInstance3D = counter.get_node("VisualRoot/Bench")
	if counter.instance_id != "npc-03-counter" or not bench.global_position.is_equal_approx(Vector3(-7.5,0.425,11.8)): failures.append("counter ID/foot changed: " + counter.instance_id + " " + str(bench.global_position))
	if (bench.mesh as BoxMesh).size != Vector3(2.2,0.85,0.7) or (counter.get_node("BenchBody/BenchCollision").shape as BoxShape3D).size != Vector3(2.2,0.85,0.7): failures.append("bench boundary changed")
	if not is_equal_approx((counter.get_node("Body/MarisCollision").shape as CapsuleShape3D).radius, 0.35): failures.append("Maris body changed")
	for path: String in ["VisualRoot/Bench", "VisualRoot/BasicSupplies/LampOil", "VisualRoot/BasicSupplies/Line", "VisualRoot/FittingGear/TestFitting", "VisualRoot/SpecialistGear/RiverGear", "VisualRoot/SpecialistGear/RepairFittings"]:
		var mesh: Mesh = counter.get_node(NodePath(path)).mesh
		var material: StandardMaterial3D = mesh.surface_get_material(0)
		if material.albedo_texture != AlderwakeTownArt.PAINTED_ATLAS or material.albedo_color != Color.WHITE or material.vertex_color_use_as_albedo: failures.append("counter atlas/tint failed: " + path)
		if not material.albedo_texture.get_image().has_mipmaps(): failures.append("painted atlas lacks mip chain")
