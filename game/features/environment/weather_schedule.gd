class_name WeatherSchedule
extends RefCounted
## Node-independent deterministic forecast; only the transient cursor is cached.

enum Condition { SUNNY, CLOUDY, RAINY, THUNDERSTORM }

const MAX_SEED: int = 0xffffffff
const DEFAULT_SEED: int = 0x6c8e9cf5
const MIN_PERIOD_MINUTES: int = 240
const MAX_PERIOD_MINUTES: int = 480
const TRANSITION_MINUTES: float = 15.0
const BOUNDARY_EPSILON_MINUTES: float = 1e-9

class Sample:
	extends RefCounted
	var condition: Condition = Condition.SUNNY
	var previous_condition: Condition = Condition.SUNNY
	var period_index: int = 0
	var period_start_minutes: int = 0
	var period_end_minutes: int = 0
	var transition_progress: float = 1.0

	func has_rain() -> bool:
		return condition in [Condition.RAINY, Condition.THUNDERSTORM]

	func is_heavy_rain() -> bool:
		return condition == Condition.THUNDERSTORM

var _seed: int = -1
var _cursor: Sample
var _reconstruction_count: int = 0
var _periods_computed: int = 0

# Read-only diagnostics for verifying bounded reconstruction/cache behavior.
var reconstruction_count: int:
	get: return _reconstruction_count
var periods_computed: int:
	get: return _periods_computed


static func valid_seed(seed: int) -> bool:
	return seed >= 0 and seed <= MAX_SEED


static func condition_id(condition: Condition) -> String:
	match condition:
		Condition.SUNNY: return "sunny"
		Condition.CLOUDY: return "cloudy"
		Condition.RAINY: return "rainy"
		Condition.THUNDERSTORM: return "thunderstorm"
	return ""


static func multiply_low32(a: int, b: int) -> int:
	# Every product fits int64; the naive 32x32 product may overflow signed int64.
	a &= MAX_SEED
	b &= MAX_SEED
	return ((a & 65535) * b + ((((a >> 16) * b) & 65535) << 16)) & MAX_SEED


static func mix(seed: int, period_index: int, salt: int) -> int:
	var value: int = (seed ^ multiply_low32(period_index + 1, 0x9e3779b9) ^ salt) & MAX_SEED
	value = (value ^ (value >> 16)) & MAX_SEED
	value = multiply_low32(value, 0x7feb352d)
	value = (value ^ (value >> 15)) & MAX_SEED
	value = multiply_low32(value, 0x846ca68b)
	return (value ^ (value >> 16)) & MAX_SEED


static func period_duration(seed: int, period_index: int) -> int:
	return MIN_PERIOD_MINUTES + mix(seed, period_index, 0x5f356495) % 241


static func next_condition(seed: int, period_index: int, previous: Condition) -> Condition:
	var roll: int = mix(seed, period_index, 0x9e3779b9) % 100
	match previous:
		Condition.SUNNY: return Condition.CLOUDY
		Condition.CLOUDY: return Condition.SUNNY if roll < 55 else Condition.RAINY
		Condition.RAINY: return Condition.CLOUDY if roll < 65 else Condition.THUNDERSTORM
		Condition.THUNDERSTORM: return Condition.RAINY if roll < 75 else Condition.CLOUDY
	return Condition.SUNNY


func sample(seed: int, day_index: int, progress: float) -> Sample:
	if not valid_seed(seed) or not EnvironmentClock.validate(day_index, progress).is_empty():
		return null
	var minutes: float = EnvironmentClock.absolute_minutes(day_index, progress)
	# Normalized clock round trips can place an authored integer minute one ULP
	# below its boundary (e.g. 369/1440*1440). Canonicalize only within 1e-9
	# authored minutes, far below one nanosecond of active time, not relative epsilon.
	var nearest_minute: float = roundf(minutes)
	if absf(minutes - nearest_minute) <= BOUNDARY_EPSILON_MINUTES:
		minutes = nearest_minute
	if _cursor == null or seed != _seed or minutes < _cursor.period_start_minutes:
		_seed = seed
		_cursor = Sample.new()
		_cursor.period_end_minutes = period_duration(seed, 0)
		_reconstruction_count += 1
		_periods_computed += 1
	# At most 21,906 transitions over the supported clock range, once on seek.
	while minutes >= _cursor.period_end_minutes:
		_cursor.previous_condition = _cursor.condition
		_cursor.period_index += 1
		_cursor.period_start_minutes = _cursor.period_end_minutes
		_cursor.condition = next_condition(seed, _cursor.period_index, _cursor.previous_condition)
		_cursor.period_end_minutes += period_duration(seed, _cursor.period_index)
		_periods_computed += 1
	# Return a detached sample so callers cannot corrupt the cursor.
	var result: Sample = Sample.new()
	result.condition = _cursor.condition
	result.previous_condition = _cursor.previous_condition
	result.period_index = _cursor.period_index
	result.period_start_minutes = _cursor.period_start_minutes
	result.period_end_minutes = _cursor.period_end_minutes
	result.transition_progress = 1.0 if result.period_index == 0 else clampf((minutes - result.period_start_minutes) / TRANSITION_MINUTES, 0.0, 1.0)
	return result
