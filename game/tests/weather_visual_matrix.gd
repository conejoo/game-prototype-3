extends SceneTree
## W009 synthetic phase/forecast/pose review; actual Compatibility pixels.

var game: Node3D
var directory: String
var views: Array[Dictionary] = []
var failures: Array[String] = []
const PHASES: Array[String] = ["day", "dusk", "night", "dawn"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	directory = TestRunEvidence.directory()
	if DisplayServer.get_name() == "headless" or directory.is_empty():
		push_error("W009 matrix requires real renderer and fresh evidence")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	game = load("res://app/game_root.tscn").instantiate()
	game.environment_review_namespace = "w009-matrix"
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "W009 rollback fixture"
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	DisplayServer.window_move_to_foreground()
	await process_frame
	game._set_paused(true)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_camera_poses.json"))
	for goal: String in ["maris", "dense-forest", "bridge-west", "ford-west"]:
		_place(poses.goals[goal])
		for orthographic: bool in [true, false]:
			game.camera_rig.set_orthographic(orthographic)
			for zoom: float in [.8, 1.15]:
				game.camera_rig.zoom_factor = zoom
				game.camera_rig._apply_zoom()
				game.ui.show_camera(game.camera_rig.description())
				for phase: int in range(4):
					for condition: int in range(4):
						_check(game.environment_review.apply_preset(phase, condition as WeatherSchedule.Condition), "preset rejected")
						_update_view()
						await _capture("%s-%s-z%d-%s-%s" % [goal, "ortho" if orthographic else "persp", roundi(zoom * 100), PHASES[phase], WeatherSchedule.condition_id(condition as WeatherSchedule.Condition)])
			_check(game.environment_review.apply_preset(2, WeatherSchedule.Condition.THUNDERSTORM), "combat storm preset")
			_update_view()
			_check(game.player_placeholder.combat.attack(Vector3.BACK, true), "combat windup setup")
			game.player_placeholder._update_feedback()
			await _capture("%s-night-combat-%s" % [goal, "ortho" if orthographic else "persp"])
			game.player_placeholder.combat.cancel()
			game.player_placeholder._update_feedback()
	# All six source defaults in close views, plus window/waylight registration.
	_check(game.environment_review.apply_preset(2, WeatherSchedule.Condition.THUNDERSTORM), "night storm preset")
	game.camera_rig.set_orthographic(true)
	game.camera_rig.zoom_factor = .8
	game.camera_rig._apply_zoom()
	game.ui.show_camera(game.camera_rig.description())
	var location: AlderwakeExterior = game.world_host.current_location
	for prop: String in location.exterior_lights.consumers:
		var consumer: ExteriorLightConsumer = location.exterior_lights.consumers[prop]
		if consumer.source_kind not in ["dock_lamp", "waylight"]: continue
		var position: Vector3 = consumer.global_position + Vector3(0, 0, 1)
		_place({"position":[position.x, position.y, position.z], "companion_position":[position.x + 1, position.y, position.z]})
		_update_view()
		await _capture("source-default-" + prop)
	await _pause_and_rollback()
	# Stable indoor excludes outdoor rain and flash at every phase/condition.
	_check(game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter").ok, "guardian setup")
	_check(game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake").is_empty(), "indoor request")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "indoor arrival")
	for orthographic: bool in [true, false]:
		game.camera_rig.set_orthographic(orthographic)
		for zoom: float in [.8, 1.15]:
			game.camera_rig.zoom_factor = zoom
			game.camera_rig._apply_zoom()
			for phase: int in range(4):
				for condition: int in range(4):
					_check(game.environment_review.apply_preset(phase, condition as WeatherSchedule.Condition), "indoor preset")
					_check(is_equal_approx(game.environment_presenter.sun.light_energy, 1.1) and game.world_host.find_children("*", "WorldRain", true, false).is_empty(), "indoor weather leaked")
			game.guardian.combat.attack(Vector3.BACK, true)
			game.guardian._update_feedback()
			game.ui.show_camera(game.camera_rig.description())
			await _capture("indoor-telegraph-%s-z%d" % ["ortho" if orthographic else "persp", roundi(zoom * 100)])
			game.guardian.combat.cancel()
			game.guardian._update_feedback()
	_check(not FileAccess.file_exists(game.save_repository.path), "review wrote save")
	_check(views.size() == 280, "incomplete matrix")
	_check(TestRunEvidence.write_json("matrix-index.json", {"views":views, "failures":failures, "engine_pid":OS.get_process_id()}), "index write")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W009 matrix ", "PASS" if failures.is_empty() else "FAIL", " captures=", views.size())
	quit(0 if failures.is_empty() else 1)


func _place(pose: Dictionary) -> void:
	_check(paused and game.ui.pause_overlay.visible, "placement lacks pause")
	var point: Array = pose.position
	var ally: Array = pose.companion_position
	game.player_placeholder.global_position = Vector3(point[0], point[1], point[2])
	game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
	game.player_placeholder.reset_physics_interpolation()
	game.companion.reset_physics_interpolation()
	game.camera_rig._process(0)
	game._refresh_interaction()


func _update_view() -> void:
	var location: AlderwakeExterior = game.world_host.current_location
	location.tree_art.update_visibility(game.camera_rig.camera, game.player_placeholder, game.companion)
	var point: Vector3 = game.player_placeholder.global_position + Vector3(0, 0, .6)
	var screen: Vector2 = game.camera_rig.camera.unproject_position(point)
	var hit: Variant = game.camera_rig.ground_point(screen, point.y)
	_check(hit != null and (hit as Vector3).distance_to(point) <= .15, "aim ground mismatch")
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = screen
	root.push_input(motion, true)
	if hit != null:
		game.player_placeholder.aim_marker.global_position = hit + Vector3.UP * .03
		game.player_placeholder.aim_marker.visible = true
	game._present_environment()


func _capture(label: String) -> void:
	var result: Dictionary = await TestRunCapture.capture(game, label, directory, "synthetic", false, "W009 detached review: real seeded weather, forced phase and retained M016 pose; no normal/native route claim")
	_check(result.ok, result.get("error", "capture failed"))
	if result.ok: views.append(result)


func _pause_and_rollback() -> void:
	var location: AlderwakeExterior = game.world_host.current_location
	var rain: WorldRain = location.world_rain
	var hidden: Array[Node3D] = []
	# Exclude existing river shader TIME; only new weather motion is under review.
	for child: Node in location.get_children():
		if child is Node3D and child != rain and child.visible:
			child.visible = false
			hidden.append(child)
	await _capture("pause-weather-only-first")
	await create_timer(.5, true).timeout
	await _capture("pause-weather-only-later")
	var first: Image = Image.load_from_file(directory.path_join("pause-weather-only-first.png"))
	var later: Image = Image.load_from_file(directory.path_join("pause-weather-only-later.png"))
	_check(first.get_data() == later.get_data(), "paused weather pixels moved")
	for child: Node3D in hidden: child.visible = true
	await _capture("rollback-before")
	var snapshot: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	var profile: int = game.environment_presenter.profile
	var phase: float = rain.phase_seconds
	_check(game.world_host.request_transition("prototype-unsafe-location", "unsafe-no-floor").is_empty(), "rollback request")
	var result: Array = await game.world_host.transition_finished
	_check(not result[0] and game.world_host.current_location == location and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == snapshot and game.environment_presenter.profile == profile and rain.phase_seconds == phase, "rollback changed environment")
	await _capture("rollback-after")


func _check(ok: bool, message: String) -> void:
	if not ok and message not in failures: failures.append(message)
