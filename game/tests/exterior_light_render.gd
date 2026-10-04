extends SceneTree
## W005 actual renderer, synthetic paused source/phase/override review only.

var game: Node3D
var directory: String
var views: Array[Dictionary] = []
var failures: Array[String] = []
const PHASES: Dictionary[String, float] = {"day":0, "dusk":.375, "night":.625, "dawn":.875}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("W005 requires real Compatibility renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	directory = ProjectSettings.globalize_path("res://../docs/evidence/W005/run-%d-%d/render" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir=res://../docs/evidence/W005/"):
			directory = ProjectSettings.globalize_path(argument.trim_prefix("--report-dir="))
	DirAccess.make_dir_recursive_absolute(directory)
	print("W005 render pid=%d user_data=%s output=%s" % [OS.get_process_id(), OS.get_user_data_dir(), directory])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	if not paused or not game.ui.get_node("Screen/PauseOverlay").visible:
		push_error("W005 pause not confirmed")
		quit(1)
		return
	await _capture("startup-paused")
	game.ui.show_paused(false)
	var lights: ExteriorLights = game.world_host.current_location.get("exterior_lights") as ExteriorLights
	# Every consumer gets a close night view with actual pinned defaults.
	game.session.environment.day_cycle_progress = .625
	for consumer: ExteriorLightConsumer in lights.consumers.values():
		_place(consumer)
		game.camera_rig.set_orthographic(true)
		game._present_environment()
		await _capture(consumer.prop_id + "-default-night")
	# Representative town/art/waylight matrices in both ordinary projections.
	for prop: String in ["dock-row-lamp-01", "reed-chandlery-exterior-building", "safeguard-waylight-east-01", "safeguard-waylight-west-01"]:
		_place(lights.consumers[prop])
		for orthographic: bool in [true, false]:
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for phase: String in PHASES:
				game.session.environment.day_cycle_progress = PHASES[phase]
				game._present_environment()
				await _capture("%s-%s-%s" % [prop, phase, "ortho" if orthographic else "perspective"])
	# On/off comparison uses EnvironmentState only in this isolated test process.
	var lamp: ExteriorLightConsumer = lights.consumers["dock-lamp-01"]
	_place(lamp)
	game.camera_rig.set_orthographic(true)
	game.session.environment.day_cycle_progress = .625
	game._present_environment()
	await _capture("dock-lamp-01-night-off")
	game.session.environment.set_light_enabled(LightSourceRegistry.LOCATION_ID, lamp.prop_id, lamp.source_id, true)
	game._present_environment()
	await _capture("dock-lamp-01-night-on")
	# Same on frame without local illumination proves actual pool contribution.
	lamp.emitter.visible = false
	await _capture("dock-lamp-01-night-emission-only")
	game._present_environment()
	game.session.environment.set_light_enabled(LightSourceRegistry.LOCATION_ID, "dock-row-lamp-01", "lantern", false)
	_place(lights.consumers["dock-row-lamp-01"])
	game._present_environment()
	await _capture("dock-row-night-manually-off")
	game.session.environment.light_source_overrides.clear()
	game._present_environment()
	await _capture("dock-row-night-on")
	lights.consumers["dock-row-lamp-01"].emitter.visible = false
	await _capture("dock-row-night-emission-only")
	game._present_environment()
	# Maximum overlap on actual batched terrain: all eight emitters armed.
	for row: Dictionary in LightSourceRegistry.entries():
		if row.switchable: game.session.environment.set_light_enabled(row.location_id, row.prop_id, row.source_id, true)
	_place(lamp)
	game._present_environment()
	await _capture("town-eight-emitters-armed")
	game.session.environment.light_source_overrides.clear()
	# Reframe window registration at supported zoom endpoints, real meshes.
	_place(lights.consumers["lantern-rest-exterior-building"])
	for zoom: float in [.8, 1.15]:
		game.camera_rig.zoom_factor = zoom
		game.camera_rig._apply_zoom()
		game._present_environment()
		await _capture("lantern-rest-night-zoom-%.2f" % zoom)
	var file: FileAccess = FileAccess.open(directory.path_join("index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"W005 synthetic paused source/phase/override visual review", "engine_pid":OS.get_process_id(), "engine":Engine.get_version_info()["string"], "user_data":OS.get_user_data_dir(), "local_light_limit":ProjectSettings.get_setting("rendering/limits/opengl/max_lights_per_object"), "views":views, "failures":failures}, "\t") + "\n")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W005 rendered %s: %d captures" % ["PASS" if failures.is_empty() else "FAIL", views.size()])
	quit(0 if failures.is_empty() else 1)


func _place(consumer: ExteriorLightConsumer) -> void:
	var point: Vector3 = consumer.anchor.global_position
	game.player_placeholder.global_position = Vector3(point.x, consumer.global_position.y, point.z + 2.0)
	game.companion.global_position = game.player_placeholder.global_position + Vector3(1.2,0,.4)
	game.player_placeholder.reset_physics_interpolation()
	game.companion.reset_physics_interpolation()
	game.camera_rig._process(0)
	game._refresh_interaction()


func _capture(label: String) -> void:
	game.ui.show_camera(game.camera_rig.description())
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var path: String = directory.path_join(label + ".png")
	var error: Error = root.get_texture().get_image().save_png(path)
	if error != OK: failures.append("PNG write failed " + label)
	var sources: Array[Dictionary] = []
	var lights: ExteriorLights = game.world_host.current_location.get("exterior_lights") as ExteriorLights
	var visible_local: int = 0
	for consumer: ExteriorLightConsumer in lights.consumers.values():
		var local_energy: float = consumer.emitter.light_energy if consumer.emitter != null and consumer.emitter.visible else 0.0
		if local_energy > 0: visible_local += 1
		sources.append({"prop_id":consumer.prop_id, "enabled":consumer.enabled, "intensity":consumer.intensity, "energy":local_energy})
	if visible_local > 8: failures.append("local budget exceeded")
	views.append({"label":label, "path":path, "png_exit":error, "paused":paused, "phase":game.session.environment.day_cycle_progress, "projection":game.camera_rig.description(), "visible_local":visible_local, "sources":sources, "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)})
