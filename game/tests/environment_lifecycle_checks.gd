extends SceneTree
## W008 synthetic lifecycle/focus/rollback and isolated review acceptance.

var game: Node3D
var failures: Array[String] = []
var assertions: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W008 pid=%d user_data=%s" % [OS.get_process_id(), OS.get_user_data_dir()])
	game = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "W008 unsafe fixture"
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	_check(game.ui.time_label.text.begins_with("10:00 AM\nClear"), "startup HUD not hydrated synchronously")
	_check(game.environment_review == null and not game.session.review_only, "normal startup review present")
	game._set_paused(true)
	game.session.environment.day_index = 2
	game.session.environment.day_cycle_progress = .625
	game.session.environment.weather_seed = _seed(WeatherSchedule.Condition.THUNDERSTORM, .625)
	game.session.environment.set_light_enabled("prototype-alderwake", "dock-lamp-02", "lantern", true)
	game.session.environment.set_light_enabled("prototype-alderwake", "dock-row-lamp-01", "lantern", false)
	game._present_environment()
	_check(game.ui.time_label.text == "1:00 AM\nThunderstorm", "night HUD")
	var conditions: WeatherConditionService = game.session.weather_conditions
	_check(conditions.has_condition("heavy-rain") and conditions.has_condition("thunderstorm") and not conditions.has_condition("rainy") and not conditions.has_condition("bogus"), "derived condition query")
	var detached: WeatherSchedule.Sample = conditions.sample()
	detached.condition = WeatherSchedule.Condition.SUNNY
	_check(conditions.has_condition("heavy-rain"), "query leaked mutable cursor")
	game.session.environment.weather_seed = _seed(WeatherSchedule.Condition.RAINY, .625)
	_check(not conditions.has_condition("heavy-rain") and conditions.has_condition("rainy"), "ordinary rain became heavy-rain")
	game.session.environment.weather_seed = _seed(WeatherSchedule.Condition.THUNDERSTORM, .625)
	game._present_environment()
	game.save_repository = SaveRepository.new("user://saves/w008-lifecycle.json")
	_check(game.save_run().is_empty(), "isolated save failed")
	var saved: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	game.session.environment.day_cycle_progress = .05
	game._present_environment()
	_check((await game.load_run()).is_empty(), "restore failed")
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == saved and game.ui.time_label.text == "1:00 AM\nThunderstorm", "restore stale facts/HUD")
	_check(game.session.weather_conditions != conditions and game.session.weather_conditions.has_condition("heavy-rain"), "restore service binding")
	var live: GameSession = game.session
	var old_room: PrototypeLocation = game.world_host.current_location
	var rendered: String = _render_values()
	for spawn: String in unsafe.spawn_ids:
		var broken: Dictionary = SaveCodec.snapshot(game.session)
		broken.location_id = unsafe.stable_id
		broken.spawn_id = spawn
		broken.environment.day_cycle_progress = .05
		broken.environment.weather_seed = 0
		_write(game.save_repository.path, TestRunSnapshot.exact_json(broken))
		_check(not (await game.load_run()).is_empty(), "unsafe load accepted")
		_check(game.session == live and game.world_host.current_location == old_room and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == saved and _render_values() == rendered, "failed load published environment")
		_check(game.world_host.request_transition(unsafe.stable_id, spawn).is_empty(), "unsafe travel preflight")
		_check(_render_values() == rendered and game.selected_interaction == null and game.light_feedback.is_empty(), "transition presented candidate or stale target")
		var result: Array = await game.world_host.transition_finished
		_check(not result[0] and _render_values() == rendered and game.session == live, "failed travel changed committed environment")
	# Focus clears input; existing policy keeps session time advancing.
	game._set_paused(false)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var before: float = game.session.environment.day_cycle_progress
	for frame: int in range(5): await process_frame
	_check(not game.player_placeholder.controls_enabled and game.session.environment.day_cycle_progress > before, "focus policy changed")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game._set_paused(true)
	var clock: Dictionary = SaveCodec.snapshot(game.session).environment
	var overrides: Array = SaveCodec.snapshot(game.session).light_source_overrides
	for trip: int in range(5):
		for destination: String in ["prototype-tollworks", "prototype-alderwake"]:
			var owner: WeakRef = weakref(game.world_host.current_location)
			var rain: WeakRef
			var mesh: WeakRef
			var material: WeakRef
			if game.world_host.current_location is AlderwakeExterior:
				rain = weakref(game.world_host.current_location.world_rain)
				mesh = weakref(game.world_host.current_location.world_rain.mesh)
				material = weakref(game.world_host.current_location.world_rain.material)
			var spawn: String = "tollworks-from-alderwake" if destination == "prototype-tollworks" else "alderwake-start"
			_check(game.world_host.request_transition(destination, spawn).is_empty(), "replacement request")
			var arrival: Array = await game.world_host.transition_finished
			_check(arrival[0] and game.world_host.session == game.session and game.world_host.current_location.location_id == game.session.current_location_id, "replacement ownership")
			_check(SaveCodec.snapshot(game.session).environment == clock and SaveCodec.snapshot(game.session).light_source_overrides == overrides, "replacement changed durable environment")
			_check(owner.get_ref() == null and (rain == null or (rain.get_ref() == null and mesh.get_ref() == null and material.get_ref() == null)), "retained location/rain resources")
			_check(game.find_children("EnvironmentPresenter", "", false, false).size() == 1 and game.world_host.get_child_count() == 1 and game.world_host.find_children("WorldRain", "", true, false).size() == (1 if destination == "prototype-alderwake" else 0), "duplicate presenters/effects")
			_check(game.ui.time_label.text == "1:00 AM\nThunderstorm", "replacement stale HUD")
			_check(game.environment_presenter.profile == (1 if destination == "prototype-alderwake" else 0), "replacement stale profile")
			if destination == "prototype-alderwake":
				_check(game.world_host.current_location.world_rain.amount == 1.0 and game.world_host.current_location.world_rain.batches.size() > 0, "arrival rain not hydrated")
	# Synthetic death/retry; clock and lights remain durable through replacement.
	game.player_placeholder.state.health = 0
	await game.retry_encounter()
	game._set_paused(true)
	_check(game.player_placeholder.state.health == game.player_placeholder.state.max_health and SaveCodec.snapshot(game.session).light_source_overrides == overrides and game.session.environment.weather_seed == clock.weather_seed and game.session.environment.day_index == clock.day_index and game.session.environment.day_cycle_progress >= clock.day_cycle_progress, "retry lost environment facts")
	var presenter: WeakRef = weakref(game.environment_presenter)
	var room: WeakRef = weakref(game.world_host.current_location)
	game.queue_free()
	await process_frame
	_check(presenter.get_ref() == null and room.get_ref() == null, "root teardown retained owner")
	paused = false
	await _review_checks()
	var output: Array = []
	var code: int = OS.execute(OS.get_executable_path(), PackedStringArray(["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/environment_review_flag_checks.gd", "--", "--environment-review=w008-cli", "--save-slot=w008-cli"]), output, true)
	_check(code == 0 and not str(output).contains("SCRIPT ERROR") and not str(output).contains("ERROR:") and not str(output).contains("WARNING:"), "actual review flag subprocess failed: " + str(output))
	print("W008 review flag subprocess: ", output)
	for failure: String in failures: push_error(failure)
	print("W008 lifecycle %s: %d assertions" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)


func _review_checks() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	game.environment_review_namespace = "w008-synthetic"
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	_check(paused and game.session.review_only and game.environment_review != null and game.session == game.world_host.session, "review startup not paused/detached/bound")
	_check(game.save_repository.path == "user://environment-review/w008-synthetic/disabled.json", "review namespace")
	var invalid: Node = load("res://tests/environment_review.gd").new()
	var unchanged: GameSession = game.session
	_check(not invalid.initialize(game, "../normal").is_empty() and game.session == unchanged, "unsafe namespace accepted/mutated run")
	invalid.free()
	for phase: int in range(4):
		for condition: int in range(4):
			_check(game.environment_review.apply_preset(phase, condition as WeatherSchedule.Condition), "review preset unavailable")
			_check(game.session.weather_conditions.condition_id() == WeatherSchedule.condition_id(condition as WeatherSchedule.Condition), "review forecast mismatch")
			_check(not game.save_run().is_empty() and not (await game.load_run()).is_empty() and not SaveRepository.new("user://saves/returning-fair.json").write(game.session, game.catalog).is_empty(), "review escaped save guard")
	_check(not FileAccess.file_exists(game.save_repository.path) and not FileAccess.file_exists("user://saves/returning-fair.json"), "review wrote save")
	_check(game.ui.save_button.disabled and game.ui.load_button.disabled, "review GUI save not disabled")
	_check(not game.ui.resume_button.disabled, "review cannot resume")
	var snapshot: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	game.window_focused = false
	_check(not game.environment_review.apply_preset(0, WeatherSchedule.Condition.SUNNY), "review ignored focus")
	game.window_focused = true
	game._set_paused(false)
	_check(not game.environment_review.apply_preset(0, WeatherSchedule.Condition.SUNNY), "review changed active session")
	game._set_paused(true)
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == snapshot, "rejected review mutated facts")
	var review: WeakRef = weakref(game.environment_review)
	game.queue_free()
	await process_frame
	_check(review.get_ref() == null, "review teardown")
	paused = false


func _seed(condition: WeatherSchedule.Condition, progress: float) -> int:
	for seed: int in range(10000):
		var sample: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed, 2, progress)
		if sample.condition == condition and sample.transition_progress == 1.0: return seed
	_check(false, "seed missing")
	return 0


func _render_values() -> String:
	return TestRunSnapshot.exact_json({"hud":game.ui.time_label.text, "profile":game.environment_presenter.profile, "cloud":game.environment_presenter.weather.overcast, "rain":game.environment_presenter.weather.rain, "phase":game.environment_presenter.weather.phase_seconds, "flash":game.environment_presenter.weather.flash, "sun":game.get_node("Sun").light_energy})


func _write(path: String, value: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()


func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
