extends SceneTree
## W007 render rules, world registration, shelters, clock/persistence and disposal.

var assertions: int = 0
var failures: Array[String] = []
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W007 checks pid=%d user_data=%s" % [OS.get_process_id(), OS.get_user_data_dir()])
	var forecast: WeatherSchedule.Sample = WeatherSchedule.Sample.new()
	for invalid: float in [-1.0, INF, NAN]:
		_check(WeatherVisuals.sample(forecast, 1, invalid) == null, "invalid time")
	_check(WeatherVisuals.sample(null, 1, 0) == null and WeatherVisuals.sample(forecast, -1, 0) == null, "invalid forecast/seed")
	for before: int in range(4):
		for after: int in range(4):
			forecast.previous_condition = before as WeatherSchedule.Condition
			forecast.condition = after as WeatherSchedule.Condition
			var previous: WeatherVisuals.Sample
			for step: int in range(101):
				forecast.transition_progress = float(step) / 100
				var sample: WeatherVisuals.Sample = WeatherVisuals.sample(forecast, 1, 19.0)
				if step == 0:
					_check(sample.overcast == WeatherVisuals.OVERCAST[before] and sample.rain == WeatherVisuals.RAIN[before], "transition start")
				elif step == 100:
					_check(sample.overcast == WeatherVisuals.OVERCAST[after] and sample.rain == WeatherVisuals.RAIN[after], "transition end")
				else:
					_check(absf(sample.overcast - previous.overcast) <= .0151 and absf(sample.rain - previous.rain) <= .0151, "transition discontinuity")
				_check(sample.flash >= 0 and sample.flash <= .18 and sample.phase_seconds == 19.0, "bounded sample")
				previous = sample
	var flashes: int = 0
	var last_flash: float = -100
	for step: int in range(20001):
		var seconds: float = float(step) / 100
		var pulse: float = WeatherVisuals.lightning(0xffffffff, seconds)
		_check(pulse >= 0 and pulse <= .180001 and pulse == WeatherVisuals.lightning(0xffffffff, seconds), "determinism/bound")
		if pulse > 0 and seconds - last_flash > .5:
			flashes += 1
			_check(seconds - last_flash >= 4.0, "flash frequency")
		if pulse > 0:
			last_flash = seconds
	_check(flashes >= 3 and flashes <= 25, "deterministic storm never flashes or excessive")
	forecast.condition = WeatherSchedule.Condition.SUNNY
	forecast.previous_condition = forecast.condition
	forecast.transition_progress = 1.0
	_check(WeatherVisuals.sample(forecast, 1, 2190000.0).phase_seconds == fposmod(2190000.0, 64), "long-run phase")
	_check(WeatherVisuals.sample(forecast, 1, 64.0).phase_seconds == 0, "64-second loop")
	_check(WeatherVisuals.sample(forecast, 1, 19.0).flash == 0, "clear lightning")
	_check(not "TIME" in FileAccess.get_file_as_string("res://features/environment/world_rain.gdshader"), "shader time")
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	var location: AlderwakeExterior = game.world_host.current_location
	var rain: WorldRain = location.world_rain
	_check(rain.shelters.size() >= 10 and rain.get_parent() == location and not rain.is_processing(), "roof/owner/timer")
	# Find real deterministic fully blended storm facts, not a fake forecast.
	for seed: int in range(1000):
		var schedule: WeatherSchedule = WeatherSchedule.new()
		var sample: WeatherSchedule.Sample = schedule.sample(seed, 2, .05)
		if sample.condition == WeatherSchedule.Condition.THUNDERSTORM and sample.transition_progress == 1.0:
			game.session.environment.weather_seed = seed
			break
	game.session.environment.day_index = 2
	game.session.environment.day_cycle_progress = .05
	game._present_environment()
	_check(rain.amount == 1.0 and rain.visible and rain.selection_error.is_empty(), "committed storm")
	var phase: float = rain.phase_seconds
	var light: float = game.environment_presenter.sun.light_energy
	var flash: float = game.environment_presenter.weather.flash
	for frame: int in range(12): await process_frame
	_check(rain.phase_seconds == phase and game.environment_presenter.weather.flash == flash and game.environment_presenter.sun.light_energy == light and float(rain.material.get_shader_parameter("session_phase")) == phase, "pause moved weather")
	for orthographic: bool in [true, false]:
		game.camera_rig.set_orthographic(orthographic)
		for zoom: float in [.8, 1.15]:
			game.camera_rig.zoom_factor = zoom
			game.camera_rig._apply_zoom()
			for point: Vector3 in [Vector3.ZERO, Vector3(31.5,.5,5.25), Vector3(98,0,-.5), Vector3(70,0,12.5), Vector3(85,0,34)]:
				game.player_placeholder.global_position = point
				game.camera_rig._process(0)
				game._present_environment()
				_check(rain.selection_error.is_empty() and rain.batches.size() <= WorldRain.MAX_BATCHES and rain.get_child_count() == rain.batches.size(), "frustum resources")
				_audit_columns(rain)
	var key: Vector2i = rain.batches.keys()[0]
	var old_batch: MultiMeshInstance3D = rain.batches[key]
	var old_buffer: PackedFloat32Array = old_batch.multimesh.buffer.duplicate()
	game.player_placeholder.global_position.x += .1
	game.camera_rig._process(0)
	game._present_environment()
	_check(rain.batches.has(key) and rain.batches[key] == old_batch and rain.batches[key].multimesh.buffer == old_buffer, "camera dragged existing rain")
	rain.select_tiles(Rect2(-16, -16, 16, 16))
	var fixed_data: Array[Transform3D] = rain.tile_data(Vector2i(-1,-1)).transforms
	rain.select_tiles(Rect2(96, 32, 16, 16))
	rain.select_tiles(Rect2(-16, -16, 16, 16))
	_check(rain.tile_data(Vector2i(-1,-1)).transforms == fixed_data, "rebuild changed world drops")
	# Cross-seam cell distributions stay on the same uninterrupted world grid.
	for row: int in range(24):
		var left: Vector2 = WorldRain.column(Vector2i(-1,0), row * 24 + 23)
		var right: Vector2 = WorldRain.column(Vector2i(0,0), row * 24)
		_check(right.x > left.x and right.x - left.x < 1.15, "batch seam spacing")
	var before_json: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(before_json, game.catalog)
	_check(decoded.errors.is_empty() and TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == before_json, "weather save round trip")
	var state: EnvironmentState = decoded.session.environment
	var restored: WeatherVisuals.Sample = WeatherVisuals.sample(state.weather_sample(), state.weather_seed, (state.day_index + state.day_cycle_progress) * 600)
	_check(restored.phase_seconds == rain.phase_seconds and restored.rain == rain.amount and restored.flash == game.environment_presenter.weather.flash, "restored render phase")
	game._set_paused(false)
	for frame: int in range(8): await process_frame
	game._set_paused(true)
	_check(rain.phase_seconds > phase, "resume did not move rain")
	# Basic W007 owner disposal and indoor suppression; full transaction matrix belongs W008.
	var old: WeakRef = weakref(rain)
	_check(game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake").is_empty(), "indoor request")
	var arrival: Array = await game.world_host.transition_finished
	await process_frame
	_check(arrival[0] and old.get_ref() == null and game.world_host.find_children("*", "WorldRain", true, false).is_empty(), "rain retained indoors")
	_check(is_equal_approx(game.environment_presenter.sun.light_energy, 1.1) and is_equal_approx(game.environment_presenter.world_environment.environment.ambient_light_energy, .65), "indoor weather leak")
	_check(game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks").is_empty(), "exterior request")
	arrival = await game.world_host.transition_finished
	_check(arrival[0] and game.world_host.current_location.world_rain.amount == 1.0 and game.world_host.find_children("*", "WorldRain", true, false).size() == 1, "return owner/hydration")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W007 weather %s: %d assertions" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)


func _audit_columns(rain: WorldRain) -> void:
	for tile: Vector2i in rain.batches:
		var multi: MultiMesh = rain.batches[tile].multimesh
		_check(multi.instance_count <= 576 and multi.use_custom_data and multi.custom_aabb.size.y == 9, "batch bound/AABB")
		var data: WorldRain.RainBatchData = rain.tile_data(tile)
		_check(data.transforms.size() == multi.instance_count, "generated columns not uploaded")
		for transform: Transform3D in data.transforms:
			var point: Vector3 = transform.origin
			var xz: Vector2 = Vector2(point.x, point.z)
			_check(rain.bounds.has_point(xz) and not rain.sheltered(xz) and point.y >= rain.elevation.height_at(xz) + .04999, "roof/terrain exclusion")


func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok and failures.size() < 25:
		failures.append(message)
