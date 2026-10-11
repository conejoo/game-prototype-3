extends SceneTree
## AD001 only: synthetic frozen art baseline. No route, save, or performance acceptance.

const REVIEW: Script = preload("res://tests/environment_review.gd")
const POSES: String = "res://tests/fixtures/map_camera_poses.json"
var game: Node3D
var review: Node
var views: Array[Dictionary] = []
var samples: Array[Dictionary] = []
var failures: PackedStringArray = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD001 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960, 640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	if not startup[0]: failures.append("startup: " + str(startup[1]))
	game._set_paused(true)
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game, "ad001-baseline"))
	# Review.initialize detaches the session. It normally runs during root startup;
	# this post-startup fixture must use the existing restore lifecycle to rebind
	# every session owner, otherwise presets change metadata but not the render.
	if failures.is_empty():
		game._pending_restore = game.session
		var rebind_errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
		if not rebind_errors.is_empty(): failures.append("review rebind: " + str(rebind_errors))
		else:
			var rebound: Array = await game.world_host.transition_finished
			if not rebound[0] or game.world_host.session != game.session: failures.append("review session owners not rebound")
	if failures.is_empty() and not review.apply_preset(0, WeatherSchedule.Condition.SUNNY):
		failures.append("paused deterministic day/sunny preset refused")
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	if failures.is_empty():
		for goal: String in ["maris", "dense-forest", "moonwell", "bridge-west", "ford-west"]:
			_place(poses.goals[goal].position, poses.goals[goal].companion_position)
			await _pair(goal)
			if goal in ["maris", "dense-forest"]: await _sample(goal + "-day")
		_place(poses.goals.maris.position, poses.goals.maris.companion_position)
		if not review.apply_preset(2, WeatherSchedule.Condition.THUNDERSTORM): failures.append("night/storm preset refused")
		await _pair("maris-night-storm")
		await _sample("maris-night-storm")
		if not review.apply_preset(0, WeatherSchedule.Condition.SUNNY): failures.append("day/sunny restore refused")
		for room: Dictionary in [
			{"id":"prototype-mayor-vale-home", "spawn":"mayor-vale-home-from-alderwake", "label":"home", "hero":[0,0,-5], "ally":[1,0,-4]},
			{"id":"prototype-lantern-rest", "spawn":"lantern-rest-from-alderwake", "label":"inn", "hero":[0,0,-8], "ally":[1,0,-7]},
			{"id":"prototype-tollworks", "spawn":"tollworks-from-alderwake", "label":"tollworks", "hero":[0,0,3.3], "ally":[1.2,0,3.5]}]:
			if room.label == "tollworks":
				var lead: NpcDialogueService.Result = game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
				if not lead.ok: failures.append("synthetic guardian prerequisite: " + lead.message)
			var errors: PackedStringArray = game.world_host.request_transition(room.id, room.spawn)
			if not errors.is_empty():
				failures.append("transition: " + str(errors))
				break
			var arrival: Array = await game.world_host.transition_finished
			if not arrival[0]:
				failures.append("arrival: " + str(arrival[1]))
				break
			_place(room.hero, room.ally)
			await _pair(room.label)
			await _sample(room.label)
	var output: Dictionary = {"task":"AD001", "kind":"synthetic frozen baseline; not ordinary gameplay or full profiling", "views":views, "samples":samples, "failures":failures,
		"engine":Engine.get_version_info(), "engine_pid":OS.get_process_id(), "user_data":OS.get_user_data_dir(),
		"cpu":OS.get_processor_name(), "gpu":RenderingServer.get_video_adapter_name(), "api":RenderingServer.get_video_adapter_api_version(),
		"renderer":RenderingServer.get_current_rendering_method(), "max_fps":Engine.max_fps, "vsync":DisplayServer.window_get_vsync_mode()}
	if not TestRunEvidence.write_json("baseline-index.json", output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD001 baseline: %d captures, %d observational samples, %d failures" % [views.size(), samples.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _place(hero: Array, ally: Array) -> void:
	game.player_placeholder.global_position = Vector3(hero[0], hero[1], hero[2])
	game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
	game.player_placeholder.reset_physics_interpolation()
	game.companion.reset_physics_interpolation()
	game.camera_rig._process(0)
	game._refresh_interaction()

func _pair(label: String) -> void:
	game._present_environment()
	if not game.ui.time_label.text.begins_with(EnvironmentClock.format_time(game.session.environment.day_cycle_progress)):
		failures.append("rendered HUD time disagrees with preset: " + label)
	for orthographic: bool in [true, false]:
		game.camera_rig.zoom_factor = 1.0
		game.camera_rig.set_orthographic(orthographic)
		game.ui.show_camera(game.camera_rig.description())
		var capture: Dictionary = await TestRunCapture.capture(game, label + ("-orthographic" if orthographic else "-perspective"), TestRunEvidence.directory(), "synthetic", false,
			"AD001: fixture feet/direct room transition; detached environment_review day/sunny or night/storm; startup routines frozen; synthetic Tollworks quest lead; ordinary HUD visible, pause overlay hidden only during PNG")
		if not capture.ok: failures.append(capture.get("error", "capture failed"))
		else:
			capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
			capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
			capture["rendered_time_weather"] = game.ui.time_label.text
			capture["sun_energy"] = game.get_node("Sun").light_energy
			capture["presented_profile"] = game.environment_presenter.profile
			capture["guardian_present"] = is_instance_valid(game.guardian)
			views.append(capture)

func _sample(label: String) -> void:
	game.camera_rig.set_orthographic(true)
	game.ui.show_camera(game.camera_rig.description())
	game.ui.pause_overlay.visible = false
	for frame: int in range(120): await process_frame
	var intervals: Array[float] = []
	var draws: Array[float] = []
	var previous: int = Time.get_ticks_usec()
	for frame: int in range(120):
		await process_frame
		var current: int = Time.get_ticks_usec()
		intervals.append((current - previous) / 1000.0)
		previous = current
		draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	intervals.sort()
	draws.sort()
	samples.append({"label":label, "paused":paused, "hud":"ordinary HUD; pause overlay hidden; synthetic review banner", "warmup_frames":120, "sample_frames":120,
		"frame_p95_ms":intervals[113], "frame_p99_ms":intervals[118], "draw_p95":draws[113],
		"engine_static_bytes":OS.get_static_memory_usage(), "render_texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"render_buffer_bytes":Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED), "nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT), "note":"nearest rank; frozen simulation; short frame cadence observation only; memory counters are not process working set or travel-growth acceptance"})
	game.ui.pause_overlay.visible = true
