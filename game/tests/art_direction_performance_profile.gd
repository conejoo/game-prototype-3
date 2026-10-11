extends "res://tests/map_performance_profile.gd"
## AD019 M018 cadence/draw method, detached weather setup, full unpaused root.

var benchmark_condition: int = 0
var benchmark_progress: float = .05
var benchmark_seed: int = 0
var effect_counts: Array[Dictionary] = []
var conditions: Array[int] = [0, 3]
var benchmark_views: Array[String] = ["maris", "dense-forest", "bridge-west", "ford-west"]


func _run() -> void:
	if "--profile-storm-only" in OS.get_cmdline_user_args(): conditions = [3]
	if "--profile-ford-only" in OS.get_cmdline_user_args(): benchmark_views = ["ford-west"]
	output = TestRunEvidence.directory()
	if DisplayServer.get_name() == "headless" or output.is_empty() or DirAccess.dir_exists_absolute(output):
		push_error("AD019 requires real renderer and fresh evidence directory")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(960, 640)
	game = load("res://app/game_root.tscn").instantiate()
	game.environment_review_namespace = "ad019-profile"
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "production arrival failed")
	DisplayServer.window_move_to_foreground()
	await process_frame
	_check(game.session.review_only and paused, "profile not isolated")
	var location: AlderwakeExterior = game.world_host.current_location
	game._pending_restore = game.session
	var rebind_errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id, game.session.current_spawn_id, game.session)
	_check(rebind_errors.is_empty(), "detached review rebind rejected")
	if not rebind_errors.is_empty(): quit(1); return
	_check((await game.world_host.transition_finished)[0], "detached review rebind failed")
	location = game.world_host.current_location
	_check(game.routine_execution != null and game.world_host.routine_execution == game.routine_execution, "default routine owner missing")
	report["initial_inventory"] = _inventory(location)
	report["settings"] = {"engine":Engine.get_version_info(), "pid":OS.get_process_id(), "adapter":RenderingServer.get_video_adapter_name(), "vendor":RenderingServer.get_video_adapter_vendor(), "api":RenderingServer.get_video_adapter_api_version(), "renderer":RenderingServer.get_current_rendering_method(), "viewport":[root.size.x, root.size.y], "vsync_mode":DisplayServer.window_get_vsync_mode(), "max_fps":Engine.max_fps, "warmup_seconds":warmup, "run_seconds":duration, "runs_per_view_condition":runs, "projection":"orthographic", "zoom":1.0, "setup":"synthetic detached review; full unpaused production root/actors/AI/UI/shadows/rain; clock advances naturally inside each sample; clear-day defaults and storm-night all six lamps enabled"}
	_check(DisplayServer.window_get_vsync_mode() == 0 and Engine.max_fps == 0, "vsync/cap mismatch")
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/map_camera_poses.json"))
	report["conditions"] = conditions.duplicate()
	report["views_requested"] = benchmark_views.duplicate()
	for condition: int in conditions:
		benchmark_condition = condition
		benchmark_progress = .05 if condition == 0 else .625
		benchmark_seed = _find_seed()
		for view: String in benchmark_views:
			game._set_paused(true)
			var pose: Dictionary = poses.goals[view]
			var point: Array = pose.position
			var ally: Array = pose.companion_position
			game.player_placeholder.global_position = Vector3(point[0], point[1], point[2])
			game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
			game.player_placeholder.velocity = Vector3.ZERO
			game.companion.velocity = Vector3.ZERO
			game.player_placeholder.reset_physics_interpolation()
			game.companion.reset_physics_interpolation()
			game.camera_rig._process(0)
			game.camera_rig.set_orthographic(true)
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig._apply_zoom()
			_reset_scenario()
			DisplayServer.window_move_to_foreground()
			game._set_paused(false)
			_stage("warmup-%s-%s" % [view, _condition_label()])
			await create_timer(warmup).timeout
			for run: int in range(runs):
				game._set_paused(true)
				_reset_scenario()
				DisplayServer.window_move_to_foreground()
				for frame: int in range(5): await process_frame
				if not game.window_focused or not root.has_focus():
					push_error("AD019 sample requires actual foreground window focus")
					quit(1)
					return
				await _capture_profile(view + "-" + _condition_label() + "-" + str(run))
				game._set_paused(false)
				# Complete render publication before measuring cadence, as in M018.
				for frame: int in range(5): await process_frame
				await _sample(view + "-" + _condition_label(), run)
				_check(int(game.session.environment.weather_sample().condition) == benchmark_condition, "benchmark weather changed")
				_check(game.environment_presenter.weather.rain == (0.0 if condition == 0 else 1.0), "benchmark rain blend changed")
				if condition == 3: _check(ExteriorLights.night_factor(game.session.environment.day_cycle_progress) == 1.0, "night illumination changed")
			await _queries(location)
	game._set_paused(true)
	benchmark_condition = 3
	benchmark_progress = .625
	benchmark_seed = _find_seed()
	_reset_scenario()
	game._set_paused(false)
	await _lifecycle()
	report["effect_counts"] = effect_counts
	_check(effect_counts.size() == 2 and effect_counts[0] == effect_counts[1], "effect/light counts accumulated")
	if report.lifecycle.size() == 2:
		for key: String in ["nodes", "objects", "resources", "orphan_nodes", "regions", "world_children", "party"]:
			_check(report.lifecycle[0][key] == report.lifecycle[1][key], "lifecycle count changed: " + key)
	report["final_inventory"] = _inventory(game.world_host.current_location)
	_check(report.initial_inventory == report.final_inventory, "map inventory changed")
	_check(not FileAccess.file_exists(game.save_repository.path), "profile wrote save")
	report["failures"] = failures
	report["acceptance_duration"] = warmup >= 10 and duration >= 60 and runs >= 3
	_write("report.json", report)
	_stage("done")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD019 profile ", "PASS" if failures.is_empty() else "FAIL", " failures=", failures)
	quit(0 if failures.is_empty() else 1)


func _find_seed() -> int:
	for seed: int in range(10000):
		var sample: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed, 2, benchmark_progress)
		if int(sample.condition) == benchmark_condition and sample.transition_progress == 1.0 and sample.period_end_minutes - (2 + benchmark_progress) * 1440 >= (duration + 2) * 2.4:
			return seed
	_check(false, "no full-window benchmark seed")
	return 0


func _reset_scenario() -> void:
	game.session.environment.day_index = 2
	game.session.environment.day_cycle_progress = benchmark_progress
	game.session.environment.weather_seed = benchmark_seed
	game.session.environment.light_source_overrides.clear()
	if benchmark_condition == 3:
		for prop: String in ["dock-lamp-01", "dock-lamp-02", "dock-lamp-03", "dock-lamp-04", "dock-lamp-05", "dock-row-lamp-01"]:
			_check(game.session.environment.set_light_enabled("prototype-alderwake", prop, "lantern", true).is_empty(), "lamp setup failed")
	game.environment_review.phase_index = 0 if benchmark_condition == 0 else 2
	game.environment_review.condition = benchmark_condition as WeatherSchedule.Condition
	game.environment_review._update_banner()
	game._present_environment()


func _condition_label() -> String:
	return "clear-day" if benchmark_condition == 0 else "storm-night-all-lamps"


func _sample(view: String, run: int) -> void:
	var start: Dictionary = TestRunSnapshot.weather(game.session.environment)
	await super._sample(view, run)
	report.views[-1]["environment_start"] = start
	report.views[-1]["environment_end"] = TestRunSnapshot.weather(game.session.environment)
	report.views[-1]["rain_batches"] = game.world_host.current_location.world_rain.batches.size()
	report.views[-1]["local_emitters"] = game.world_host.current_location.exterior_lights.emitter_count
	report["failures"] = failures
	_write("report.json", report)
	if not failures.is_empty():
		# Stop after the first invalid window; never continue unfocused samples.
		for failure: String in failures: push_error(failure)
		quit(1)


func _capture_profile(label: String) -> void:
	if game.ui.get("storybook") != null: game.ui.storybook._process(.15)
	var result: Dictionary = await TestRunCapture.capture(game, label, output, "synthetic", false, "AD019 benchmark: detached clock/seed/pose; normal processing resumes for measurement; storm lights all enabled")
	_check(result.ok, result.get("error", "profile capture failed"))
	if not report.has("captures"): report["captures"] = []
	if result.ok: report.captures.append(result)


func _stage(value: String) -> void:
	if value in ["idle-baseline", "idle-final"]:
		# Match phase/view exactly before resource checkpoint; no phase drift bias.
		game._set_paused(true)
		_reset_scenario()
		game._set_paused(false)
	if value in ["checkpoint-baseline", "checkpoint-final"]:
		var location: AlderwakeExterior = game.world_host.current_location
		effect_counts.append({"rain_owners":game.world_host.find_children("WorldRain", "", true, false).size(), "batches":location.world_rain.batches.size(), "consumers":location.exterior_lights.consumers.size(), "emitters":location.exterior_lights.emitter_count, "presenters":game.find_children("EnvironmentPresenter", "", true, false).size()})
		_check(effect_counts[-1].rain_owners == 1 and effect_counts[-1].presenters == 1 and effect_counts[-1].consumers == 23 and effect_counts[-1].emitters == 8, "missing/duplicate environment owner or consumers")
	_write("stage.json", {"stage":value, "ticks_usec":Time.get_ticks_usec(), "pid":OS.get_process_id()})
	print("AD019 STAGE ", value)


func _inventory(location: AlderwakeTerrainPreview) -> Dictionary:
	# M018 pins every tree/cliff/region/structure before returning its inventory.
	# Default routines added since M018 legitimately transfer live contact bodies
	# between maps. Compare unchanged static physics, record live bodies separately.
	var inventory: Dictionary = super._inventory(location)
	var bodies: Array[Node] = location.find_children("*", "CharacterBody3D", true, false)
	if not report.has("contact_inventory"): report["contact_inventory"] = []
	report.contact_inventory.append({"physics_nodes":inventory.physics_nodes,"live_character_bodies":bodies.size(),"contacts":location.npc_contacts.targets.keys()})
	inventory.physics_nodes -= bodies.size()
	return inventory
