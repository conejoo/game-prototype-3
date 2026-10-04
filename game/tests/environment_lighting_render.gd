extends SceneTree
## W004 synthetic phase/pose review. No normal route, weather, native or save claim.

var game: Node3D
var directory: String
var views: Array[Dictionary] = []
var failures: Array[String] = []
const PHASES: Dictionary[String, float] = {"day": 0.0, "dusk": .375, "night": .625, "dawn": .875}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("W004 visual review requires a real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	directory = ProjectSettings.globalize_path("res://../docs/evidence/W004/run-%d-%d/render" % [OS.get_process_id(), Time.get_ticks_usec()])
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir=res://../docs/evidence/W004/"):
			directory = ProjectSettings.globalize_path(argument.trim_prefix("--report-dir="))
	DirAccess.make_dir_recursive_absolute(directory)
	print("W004 render engine=%s pid=%d user_data=%s output=%s" % [Engine.get_version_info()["string"], OS.get_process_id(), OS.get_user_data_dir(), directory])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	if not paused or not game.ui.get_node("Screen/PauseOverlay").visible:
		push_error("W004 review pause failed")
		quit(1)
		return
	await _capture("startup-paused")
	# All review placement/time mutation occurs in this standalone test process.
	# Keep simulation paused; hide only the overlay for unobstructed visual review.
	game.ui.show_paused(false)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_camera_poses.json"))
	for goal: String in ["maris", "dense-forest", "moonwell"]:
		var pose: Dictionary = poses.goals[goal]
		var point: Array = pose.position
		var ally: Array = pose.companion_position
		game.player_placeholder.global_position = Vector3(point[0], point[1], point[2])
		game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		game.camera_rig._process(0)
		game._refresh_interaction()
		for orthographic: bool in [true, false]:
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			# Review a visible floor, not a cliff/prop beyond the Moonwell approach.
			var ground: Variant = null
			for offset: Vector3 in [Vector3(1,0,1), Vector3(.6,0,0), Vector3(0,0,.6), Vector3(-.6,0,0)]:
				var aim_screen: Vector2 = game.camera_rig.camera.unproject_position(game.player_placeholder.global_position + offset)
				ground = game.camera_rig.ground_point(aim_screen, game.player_placeholder.global_position.y)
				if ground != null: break
			if ground == null: failures.append("aim floor missing: " + goal)
			else:
				game.player_placeholder.aim_marker.global_position = ground + Vector3.UP * .03
				game.player_placeholder.aim_marker.visible = true
			for phase: String in PHASES:
				game.session.environment.day_cycle_progress = PHASES[phase]
				game._present_environment()
				await _capture("%s-%s-%s" % [goal, phase, "orthographic" if orthographic else "perspective"])
	# Legitimate quest service setup, explicitly synthetic, spawns the real guardian.
	var lead: DialogueService.ActionResult = game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
	if not lead.ok: failures.append(lead.message)
	game.ui.show_paused(true)
	game.session.environment.day_cycle_progress = .625
	game._present_environment()
	await _capture("night-before-indoor-paused")
	var errors: PackedStringArray = game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	if not errors.is_empty(): failures.append(str(errors))
	else:
		var arrival: Array = await game.world_host.transition_finished
		if not arrival[0]: failures.append(str(arrival[1]))
		await _capture("indoor-first-committed-paused", 0)
		game.ui.show_paused(false)
		# Place the party within the same real room to review a frozen normal windup.
		game.player_placeholder.global_position = Vector3(0,0,3.3)
		game.companion.global_position = Vector3(1.2,0,3.5)
		game.camera_rig._process(0)
		game.guardian.combat.attack(Vector3.BACK, true)
		game.guardian._update_feedback()
		for orthographic: bool in [true, false]:
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for phase: String in PHASES:
				game.session.environment.day_cycle_progress = PHASES[phase]
				game._present_environment()
				await _capture("tollworks-%s-%s" % [phase, "orthographic" if orthographic else "perspective"])
		game.guardian.combat.cancel()
		game.guardian._update_feedback()
		game.ui.show_paused(true)
		game.session.environment.day_cycle_progress = .625
		game._present_environment()
		errors = game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks")
		if errors.is_empty():
			arrival = await game.world_host.transition_finished
			if not arrival[0]: failures.append(str(arrival[1]))
			await _capture("night-first-return-committed-paused", 0)
		else:
			failures.append(str(errors))
		game._set_paused(false)
		for frame: int in range(8): await process_frame
		game._set_paused(true)
		await _capture("night-resume-paused")
	var file: FileAccess = FileAccess.open(directory.path_join("index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"synthetic W004 phase/pose/windup review; simulation paused during captures", "engine_pid":OS.get_process_id(), "user_data":OS.get_user_data_dir(), "views":views, "failures":failures}, "\t") + "\n")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W004 rendered review %s: %d captures" % ["PASS" if failures.is_empty() else "FAIL", views.size()])
	quit(0 if failures.is_empty() else 1)


func _capture(label: String, settle_frames: int = 4) -> void:
	# Canopy presenter normally follows root's process even while tree is paused.
	for frame: int in range(settle_frames): await process_frame
	await RenderingServer.frame_post_draw
	var path: String = directory.path_join(label + ".png")
	var error: Error = root.get_texture().get_image().save_png(path)
	if error != OK: failures.append("capture failed: " + label)
	var sun: DirectionalLight3D = game.get_node("Sun")
	views.append({"label":label, "path":path, "png_exit":error, "paused":paused, "profile":game.environment_presenter.profile, "progress":game.session.environment.day_cycle_progress, "sun_energy":sun.light_energy, "sun_direction":str(-sun.basis.z), "selected_interaction":game.selected_interaction.instance_id if game.selected_interaction != null else ""})
