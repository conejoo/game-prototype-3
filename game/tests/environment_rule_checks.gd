extends SceneTree
## W002 pure-rule acceptance. No scene, rendering, save writes or source imports.

var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W002 engine=%s pid=%d user_data=%s" % [Engine.get_version_info()["string"], OS.get_process_id(), OS.get_user_data_dir()])
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_rule_vectors.json"))
	_check(vectors.forecast.size() == 49, "Pinned vector count changed")
	for vector: Dictionary in vectors.low32_multiply:
		_check(WeatherSchedule.multiply_low32(int(vector.a), int(vector.b)) == int(vector.low32), "uint32 product mismatch: " + str(vector))
	var schedule: WeatherSchedule = WeatherSchedule.new()
	for vector: Dictionary in vectors.forecast:
		var sample: WeatherSchedule.Sample = schedule.sample(int(vector.seed), int(vector.day_index), float(vector.day_cycle_progress))
		_matches(sample, vector.expected, "pinned seed=%s time=%s" % [vector.seed, vector.absolute_minutes])
		var restored: WeatherSchedule.Sample = WeatherSchedule.new().sample(int(vector.seed), int(vector.day_index), float(vector.day_cycle_progress))
		_matches(restored, vector.expected, "detached reconstruction")
		_check(sample.is_heavy_rain() == (sample.condition == WeatherSchedule.Condition.THUNDERSTORM), "heavy-rain derivation")
		_check(sample.has_rain() == (sample.condition in [WeatherSchedule.Condition.RAINY, WeatherSchedule.Condition.THUNDERSTORM]), "rain derivation")
	for vector: Dictionary in vectors.clock:
		_check(absf(EnvironmentClock.minute_of_day(float(vector.progress)) - float(vector.minute_of_day)) < 0.000001, "clock vector mismatch")
	var labels: Dictionary[float, String] = {0.0: "10:00 AM", 0.25: "4:00 PM", 0.5: "10:00 PM", 14.0 / 24.0: "12:00 AM", 0.75: "4:00 AM", 0.999: "9:58 AM"}
	for progress: float in labels:
		_check(EnvironmentClock.format_time(progress) == labels[progress], "display label mismatch at " + str(progress))
	for vector: Dictionary in vectors.advance:
		var advanced: EnvironmentClock.AdvanceResult = EnvironmentClock.advance(int(vector.day_index), float(vector.progress), float(vector.delta_seconds))
		_check(advanced.errors.is_empty() and advanced.day_index == int(vector.expected_day_index) and absf(advanced.day_cycle_progress - float(vector.expected_progress)) < 0.000000001, "advance vector mismatch")
	var midnight: EnvironmentClock.AdvanceResult = EnvironmentClock.advance(0, 0.0, 350.0)
	_check(midnight.day_index == 0 and EnvironmentClock.format_time(midnight.day_cycle_progress) == "12:00 AM", "midnight incorrectly wrapped source day")
	var next_day: EnvironmentClock.AdvanceResult = EnvironmentClock.advance(0, 0.0, 600.0)
	_check(next_day.day_index == 1 and EnvironmentClock.format_time(next_day.day_cycle_progress) == "10:00 AM", "10 AM cycle boundary lost")
	var long_advance: EnvironmentClock.AdvanceResult = EnvironmentClock.advance(0, 0.123, 3600.0 * 600.0)
	_check(long_advance.errors.is_empty() and long_advance.day_index == 3600 and absf(long_advance.day_cycle_progress - 0.123) < 0.000000001, "large delta lost days")
	_invalid_inputs()
	_transition_rules()
	_clock_round_trip_boundaries()
	_cache_and_limits()
	_session_rules()
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("W002 rules PASS: %d checks; 49 fixed forecasts, uint32, clock, boundaries, all 100 transition rolls, durations, invalid atomicity, cache/seek, long-run reconstruction, seed lifetime." % checks)
	quit(0 if failures.is_empty() else 1)


func _matches(sample: WeatherSchedule.Sample, expected: Dictionary, context: String) -> void:
	_check(sample != null, "missing sample: " + context)
	if sample == null:
		return
	_check(WeatherSchedule.condition_id(sample.condition) == expected.condition and WeatherSchedule.condition_id(sample.previous_condition) == expected.previous_condition, "condition mismatch: " + context)
	_check(sample.period_index == int(expected.period_index) and sample.period_start_minutes == int(expected.period_start_minutes) and sample.period_end_minutes == int(expected.period_end_minutes), "period mismatch: " + context)
	_check(absf(sample.transition_progress - float(expected.transition_progress)) < 0.000001, "blend mismatch: " + context)


func _invalid_inputs() -> void:
	var schedule: WeatherSchedule = WeatherSchedule.new()
	for seed: int in [-1, 4294967296]:
		_check(schedule.sample(seed, 0, 0.0) == null, "invalid seed accepted")
	for day: int in [-1, 3651]:
		_check(schedule.sample(0, day, 0.0) == null and not EnvironmentClock.advance(day, 0.0, 1.0).errors.is_empty(), "invalid day accepted")
	for progress: float in [-0.1, 1.0, INF, -INF, NAN]:
		_check(schedule.sample(0, 0, progress) == null, "invalid progress accepted")
		_check(is_nan(EnvironmentClock.minute_of_day(progress)) and EnvironmentClock.format_time(progress).is_empty(), "invalid display progress accepted")
		_check(not EnvironmentClock.advance(0, progress, 1.0).errors.is_empty(), "invalid advance state accepted")
	var state: EnvironmentState = EnvironmentState.new()
	state.day_index = 3650
	state.day_cycle_progress = 0.5
	for delta: float in [-1.0, INF, -INF, NAN, 300.0, 1e300]:
		_check(not state.advance(delta).is_empty(), "invalid or beyond-cap delta accepted")
		_check(state.day_index == 3650 and state.day_cycle_progress == 0.5, "failed advance partially mutated state")
	_check(state.advance(299.0).is_empty() and state.day_index == 3650, "valid near-cap advance rejected")
	_check(state.advance(0.0).is_empty(), "zero delta rejected at valid limit")
	state.weather_seed = -1
	var before: float = state.day_cycle_progress
	_check(not state.advance(1.0).is_empty() and state.day_cycle_progress == before and state.weather_sample() == null, "invalid seed mutated state")
	_check(schedule.reconstruction_count == 0 and schedule.periods_computed == 0, "invalid samples changed cache")


func _transition_rules() -> void:
	var rolls: Dictionary[int, int] = {}
	var minimum_seen: int = 481
	var maximum_seen: int = 0
	for index: int in range(8192):
		rolls[WeatherSchedule.mix(0, index, 0x9e3779b9) % 100] = index
		var duration: int = WeatherSchedule.period_duration(0, index)
		minimum_seen = mini(minimum_seen, duration)
		maximum_seen = maxi(maximum_seen, duration)
		_check(duration >= 240 and duration <= 480, "duration outside 4-8 authored hours")
	_check(minimum_seen == 240 and maximum_seen == 480, "inclusive duration endpoints absent")
	_check(rolls.size() == 100, "transition fixture did not cover all rolls")
	var cloudy_sunny: int = 0
	var rainy_cloudy: int = 0
	var storm_rainy: int = 0
	for roll: int in rolls:
		var index: int = rolls[roll]
		_check(WeatherSchedule.next_condition(0, index, WeatherSchedule.Condition.SUNNY) == WeatherSchedule.Condition.CLOUDY, "sunny transition")
		var cloudy: WeatherSchedule.Condition = WeatherSchedule.next_condition(0, index, WeatherSchedule.Condition.CLOUDY)
		var rainy: WeatherSchedule.Condition = WeatherSchedule.next_condition(0, index, WeatherSchedule.Condition.RAINY)
		var storm: WeatherSchedule.Condition = WeatherSchedule.next_condition(0, index, WeatherSchedule.Condition.THUNDERSTORM)
		_check(cloudy == (WeatherSchedule.Condition.SUNNY if roll < 55 else WeatherSchedule.Condition.RAINY), "55/45 threshold")
		_check(rainy == (WeatherSchedule.Condition.CLOUDY if roll < 65 else WeatherSchedule.Condition.THUNDERSTORM), "65/35 threshold")
		_check(storm == (WeatherSchedule.Condition.RAINY if roll < 75 else WeatherSchedule.Condition.CLOUDY), "75/25 threshold")
		cloudy_sunny += int(cloudy == WeatherSchedule.Condition.SUNNY)
		rainy_cloudy += int(rainy == WeatherSchedule.Condition.CLOUDY)
		storm_rainy += int(storm == WeatherSchedule.Condition.RAINY)
	_check(cloudy_sunny == 55 and rainy_cloudy == 65 and storm_rainy == 75, "exact transition probabilities")


func _clock_round_trip_boundaries() -> void:
	var schedule: WeatherSchedule = WeatherSchedule.new()
	var sample: WeatherSchedule.Sample = schedule.sample(123456, 0, 0.0)
	for period: int in range(1200):
		var boundary: int = sample.period_end_minutes
		var before: float = boundary - 0.0001
		var preceding: WeatherSchedule.Sample = schedule.sample(123456, int(before / 1440.0), fmod(before, 1440.0) / 1440.0)
		_check(preceding.period_index == period, "pre-boundary time snapped forward")
		sample = schedule.sample(123456, boundary / 1440, float(boundary % 1440) / 1440.0)
		_check(sample.period_index == period + 1 and sample.transition_progress == 0.0, "normalized integer boundary drift")
		var after: float = boundary + 7.5
		var blend: WeatherSchedule.Sample = schedule.sample(123456, int(after / 1440.0), fmod(after, 1440.0) / 1440.0)
		_check(absf(blend.transition_progress - 0.5) < 0.000001, "normalized half blend drift")


func _cache_and_limits() -> void:
	var schedule: WeatherSchedule = WeatherSchedule.new()
	var first: WeatherSchedule.Sample = schedule.sample(0, 0, 0.0)
	for frame: int in range(1000):
		schedule.sample(0, 0, float(frame) / 10000.0)
	_check(schedule.reconstruction_count == 1 and schedule.periods_computed == 1, "history replayed within first period")
	var edge: float = float(first.period_end_minutes) / 1440.0
	var boundary: WeatherSchedule.Sample = schedule.sample(0, 0, edge)
	_check(boundary.period_index == 1 and boundary.transition_progress == 0.0 and schedule.periods_computed == 2, "exact period boundary/cache advance")
	_check(absf(schedule.sample(0, 0, edge + 7.5 / 1440.0).transition_progress - 0.5) < 0.000001, "half blend")
	_check(schedule.sample(0, 0, edge + 15.0 / 1440.0).transition_progress == 1.0, "blend end")
	boundary.period_end_minutes = 0
	boundary.condition = WeatherSchedule.Condition.THUNDERSTORM
	_check(schedule.sample(0, 0, edge).condition == WeatherSchedule.Condition.CLOUDY, "consumer corrupted cursor")
	schedule.sample(0, 0, 0.0)
	_check(schedule.reconstruction_count == 2, "backward seek did not reconstruct")
	schedule.sample(1, 0, 0.0)
	_check(schedule.reconstruction_count == 3, "seed change did not reconstruct")
	var maximum_us: int = 0
	for seed: int in [0, 1, 77, 123456, 1821285621, 2147483648, 4294967295]:
		var long_run: WeatherSchedule = WeatherSchedule.new()
		var started: int = Time.get_ticks_usec()
		var sample: WeatherSchedule.Sample = long_run.sample(seed, 3650, 0.999999999)
		var duration_us: int = Time.get_ticks_usec() - started
		maximum_us = maxi(maximum_us, duration_us)
		_check(sample != null and sample.period_index <= 21906, "long-run reconstruction bound")
		var computed: int = long_run.periods_computed
		started = Time.get_ticks_usec()
		for frame: int in range(1000):
			long_run.sample(seed, 3650, 0.999999999)
		var cached_us: int = Time.get_ticks_usec() - started
		_check(long_run.reconstruction_count == 1 and long_run.periods_computed == computed, "long-run cached frames replay history")
		print("W002 upper-bound seed=%d period=%d reconstruct_us=%d cached_1000_us=%d" % [seed, sample.period_index, duration_us, cached_us])
	print("W002 maximum measured reconstruction_us=%d" % maximum_us)


func _session_rules() -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "catalog invalid")
	var session: GameSession = GameSession.new()
	_check(not session.advance(1.0).is_empty() and session.elapsed_play_seconds == 0.0, "uninitialized session advanced")
	_check(not session.initialize(catalog, "missing", "missing", "prototype-hero").is_empty(), "bad init accepted")
	_check(session.initialize(catalog, "prototype-test-room", "prototype-start", "prototype-hero").is_empty(), "session init failed")
	var seed: int = session.environment.weather_seed
	_check(WeatherSchedule.valid_seed(seed) and session.environment.day_index == 0 and session.environment.day_cycle_progress == 0.0, "fresh state invalid")
	_check(session.environment.weather_sample().condition == WeatherSchedule.Condition.SUNNY, "fresh weather not sunny")
	_check(not session.initialize(catalog, "prototype-test-room", "prototype-start", "prototype-hero").is_empty() and session.environment.weather_seed == seed, "reinitialize rerolled seed")
	_check(session.advance(1201.0).is_empty() and session.environment.day_index == 2 and absf(session.environment.day_cycle_progress - 1.0 / 600.0) < 0.000000001 and session.elapsed_play_seconds == 1201.0, "session clock not wired")
	_check(session.environment.weather_seed == seed, "advance rerolled seed")
	for delta: float in [-1.0, INF, NAN, 1e300]:
		_check(not session.advance(delta).is_empty() and session.elapsed_play_seconds == 1201.0 and session.environment.day_index == 2, "invalid delta changed session timers")
	var independent: GameSession = GameSession.new()
	_check(independent.environment != session.environment and independent.environment.day_cycle_progress == 0.0, "environment shared between sessions")
	session.environment.day_index = 3650
	session.environment.day_cycle_progress = 0.99
	_check(not session.advance(6.0).is_empty() and session.elapsed_play_seconds == 1201.0 and session.environment.day_cycle_progress == 0.99, "clock cap partially advanced session")


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
