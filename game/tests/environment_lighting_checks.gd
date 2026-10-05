extends SceneTree
## W004 pure sampling and committed root ownership. Synthetic, isolated saves.

var failures: Array[String] = []
var assertions: int = 0
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W004 engine=%s pid=%d user_data=%s" % [Engine.get_version_info()["string"], OS.get_process_id(), OS.get_user_data_dir()])
	for invalid: float in [-1.0, 1.0, INF, NAN]:
		_check(EnvironmentLighting.sample(invalid) == null, "invalid sample accepted")
	var previous: EnvironmentLighting.Sample = EnvironmentLighting.sample(0.0)
	for step: int in range(1, 10001):
		var sample: EnvironmentLighting.Sample = EnvironmentLighting.sample(float(step) / 10001.0)
		_check(sample.sun_direction.y < -.65 and sample.sun_direction.z > 0.0 and is_equal_approx(sample.sun_direction.length(), 1.0), "unsafe ray/map axes")
		_check(sample.direct_energy >= .18 and sample.ambient_energy >= .48 and sample.shadow_opacity >= 0.0 and sample.shadow_opacity <= 1.0, "readability bounds")
		_check(absf(sample.direct_energy - previous.direct_energy) < .003 and sample.sun_direction.distance_to(previous.sun_direction) < .003, "cycle discontinuity")
		previous = sample
	var start: EnvironmentLighting.Sample = EnvironmentLighting.sample(0.0)
	_check(previous.sun_direction.distance_to(start.sun_direction) < .001 and absf(previous.direct_energy - start.direct_energy) < .001, "10 AM wrap seam")
	_check(EnvironmentLighting.sample(.375).sun_direction.x > 0 and EnvironmentLighting.sample(.875).sun_direction.x < 0, "evening/morning cast sense")
	_check(EnvironmentLighting.sample(.625).shadow_opacity == 0 and EnvironmentLighting.sample(0).direct_energy > EnvironmentLighting.sample(.625).direct_energy, "night/day contrast")
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "W004 unsafe fixture"
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	unsafe.lighting_profile = LocationDefinition.LightingProfile.STABLE_INDOOR
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	var presenter: EnvironmentPresenter = game.environment_presenter
	var sun: DirectionalLight3D = game.get_node("Sun")
	var environment: Environment = (game.get_node("WorldEnvironment") as WorldEnvironment).environment
	var indoor: LocationDefinition = game.catalog.get_location("prototype-tollworks")
	_check(game.catalog.get_location("prototype-alderwake").lighting_profile == LocationDefinition.LightingProfile.OUTDOOR_CYCLE and indoor.lighting_profile == LocationDefinition.LightingProfile.STABLE_INDOOR, "production profiles")
	_check(game.catalog.get_location("prototype-test-room").lighting_profile == LocationDefinition.LightingProfile.STABLE_INDOOR and LocationDefinition.new().lighting_profile == 0, "intentional fixture default")
	var invalid_profile: LocationDefinition = indoor.duplicate() as LocationDefinition
	invalid_profile.set("lighting_profile", 99)
	_check("lighting_profile" in "; ".join(invalid_profile.validation_errors()), "invalid authored profile accepted")
	game._set_paused(true)
	game.session.environment.day_cycle_progress = .625
	# W004 tests clear-sky phase values; W007 separately covers weather composition.
	for seed: int in range(10000):
		var forecast: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed, 0, .625)
		if forecast.condition == WeatherSchedule.Condition.SUNNY and forecast.transition_progress == 1:
			game.session.environment.weather_seed = seed
			break
	game._present_environment()
	_check(is_equal_approx(sun.light_energy, .18) and sun.shadow_opacity == 0.0 and (-sun.basis.z).distance_to(EnvironmentLighting.sample(.625).sun_direction) < .00001, "sample not applied")
	var night_basis: Basis = sun.basis
	var before: float = game.session.environment.day_cycle_progress
	for frame: int in range(8): await process_frame
	_check(paused and game.session.environment.day_cycle_progress == before and sun.basis == night_basis, "pause changed clock/sun")
	_check(not presenter.present(LocationDefinition.LightingProfile.OUTDOOR_CYCLE, NAN) and sun.basis == night_basis, "invalid presentation mutated sun")
	game._set_paused(false)
	for frame: int in range(8): await process_frame
	_check(game.session.environment.day_cycle_progress > before and sun.basis != night_basis, "resume did not move sun")
	game._set_paused(true)
	var old_session: GameSession = game.session
	var old_room: PrototypeLocation = game.world_host.current_location
	before = game.session.environment.day_cycle_progress
	var old_basis: Basis = sun.basis
	_check(game.world_host.request_transition(unsafe.stable_id, "unsafe-no-floor").is_empty(), "unsafe request rejected early")
	var arrival: Array = await game.world_host.transition_finished
	_check(not arrival[0] and game.world_host.current_location == old_room and game.session == old_session and sun.basis == old_basis and presenter.profile == 1, "rollback changed committed lighting")
	for trip: int in range(3):
		for location: String in ["prototype-tollworks", "prototype-alderwake"]:
			var spawn: String = "tollworks-from-alderwake" if location == "prototype-tollworks" else "alderwake-from-tollworks"
			_check(game.world_host.request_transition(location, spawn).is_empty(), "travel rejected")
			old_basis = sun.basis
			_check(presenter.profile == (1 if location == "prototype-tollworks" else 0), "profile changed before commit")
			arrival = await game.world_host.transition_finished
			_check(arrival[0] and game.session.environment.day_cycle_progress == before, "travel failed/advanced clock")
			_check(game.environment_presenter == presenter and game.get_node("EnvironmentPresenter") == presenter and game.world_host.get_child_count() == 1, "abandoned/duplicate owner")
			if location == "prototype-tollworks":
				_check(presenter.profile == 0 and sun.rotation_degrees.is_equal_approx(Vector3(-55,-25,0)) and sun.light_color == Color(1,.89,.73) and is_equal_approx(sun.light_energy, 1.1) and sun.shadow_opacity == 1, "indoor sun differs")
				_check(environment.ambient_light_color == Color(.65,.76,.86) and is_equal_approx(environment.ambient_light_energy, .65) and environment.background_color == Color(.055,.075,.095), "indoor environment differs")
				var indoor_basis: Basis = sun.basis
				game._set_paused(false)
				for frame: int in range(8): await process_frame
				_check(game.session.environment.day_cycle_progress > before and sun.basis.is_equal_approx(indoor_basis), "indoor clock/light stability")
				game._set_paused(true)
				before = game.session.environment.day_cycle_progress
			else:
				_check(presenter.profile == 1 and sun.light_energy < .3 and sun.basis != old_basis, "outdoor commit not hydrated synchronously")
	# PackedScene re-instantiation must retain the historical resource unchanged.
	var other: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	_check((other.get_node("WorldEnvironment") as WorldEnvironment).environment != environment and is_equal_approx((other.get_node("WorldEnvironment") as WorldEnvironment).environment.ambient_light_energy, .65), "shared environment mutated")
	other.free()
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W004 lighting %s: %d assertions; cycle/axes/profiles/pause/commit/rollback/ownership." % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition and failures.size() < 30: failures.append(message)
