extends SceneTree
## Synthetic visual regression at exact ordinary-tour positions. No route/save claim.

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960, 640)
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	var directory: String = TestRunEvidence.directory()
	DirAccess.make_dir_recursive_absolute(directory)
	var index: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_camera_poses.json"))
	var views: Array[Dictionary] = []
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.enabled = false
	game.player_placeholder.set_controls_enabled(false)
	for goal: String in index.goals:
		var point: Array = index.goals[goal].position
		game.player_placeholder.global_position = Vector3(point[0], point[1], point[2])
		# Exact party observations, not invented canopy-free placement.
		var ally: Array = index.goals[goal].companion_position
		game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		game.camera_rig._process(0)
		for orthographic: bool in [true, false]:
			for zoom_value: float in [0.8, 1.0, 1.15]:
				game.camera_rig.zoom_factor = zoom_value
				game.camera_rig.set_orthographic(orthographic)
				game.ui.show_camera(game.camera_rig.description())
				for frame: int in range(3): await process_frame
				await RenderingServer.frame_post_draw
				var path: String = TestRunEvidence.path("%s-%s-%.2f.png" % [goal, "orthographic" if orthographic else "perspective", zoom_value])
				var result: Error = root.get_texture().get_image().save_png(path)
				var hero_screen: Vector2 = game.camera_rig.camera.unproject_position(game.player_placeholder.global_position)
				var ally_screen: Vector2 = game.camera_rig.camera.unproject_position(game.companion.global_position)
				views.append({"goal":goal,"orthographic":orthographic,"zoom":zoom_value,"path":path,"hero_screen":[hero_screen.x,hero_screen.y],"ally_screen":[ally_screen.x,ally_screen.y],"save_png_exit":result})
	# Replay recorded moving-view poses for shader update/camera continuity only.
	var replay_count: int = 0
	for pose: Dictionary in index.moving_poses:
		var hero: Array = pose.position
		var ally: Array = pose.companion_position
		game.player_placeholder.global_position = Vector3(hero[0], hero[1], hero[2])
		game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		game.camera_rig._process(0)
		game.camera_rig.zoom_factor = 1
		game.camera_rig.set_orthographic(false)
		game.ui.show_camera(game.camera_rig.description())
		for frame: int in range(3): await process_frame
		await RenderingServer.frame_post_draw
		var path: String = TestRunEvidence.path("moving-pose-%02d.png" % replay_count)
		var result: Error = root.get_texture().get_image().save_png(path)
		views.append({"goal":"recorded-moving-pose","path":path,"save_png_exit":result,"source_response":pose.source_response})
		replay_count += 1
	var file: FileAccess = FileAccess.open(TestRunEvidence.path("index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"kind":"synthetic visual regression at ordinary-tour feet", "views":views}, "\t") + "\n")
	game.queue_free()
	await process_frame
	print("M016 rendered survey: ", views.size(), " captures")
	quit(0)
