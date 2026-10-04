class_name EnvironmentState
extends RefCounted
## Durable plain environment facts; forecast cursor is transient and never saved.

var day_index: int = 0
var day_cycle_progress: float = 0.0
var weather_seed: int = WeatherSchedule.DEFAULT_SEED
var light_source_overrides: Array[Dictionary] = []
var _forecast: WeatherSchedule = WeatherSchedule.new()


static func fresh() -> EnvironmentState:
	var result: EnvironmentState = EnvironmentState.new()
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.randomize()
	result.weather_seed = random.randi()
	return result


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = EnvironmentClock.validate(day_index, day_cycle_progress)
	if not WeatherSchedule.valid_seed(weather_seed):
		errors.append("environment weather_seed must be an unsigned 32-bit integer")
	errors.append_array(LightSourceRegistry.validate_overrides(light_source_overrides))
	return errors


func set_light_enabled(location_id: String, prop_id: String, source_id: String, enabled: bool) -> PackedStringArray:
	var record: Dictionary = {"location_id": location_id, "prop_id": prop_id, "source_id": source_id, "enabled": enabled}
	var errors: PackedStringArray = LightSourceRegistry.validate_overrides([record])
	errors.append_array(LightSourceRegistry.validate_overrides(light_source_overrides))
	if not errors.is_empty():
		return errors
	for existing: Dictionary in light_source_overrides:
		if existing.location_id == location_id and existing.prop_id == prop_id and existing.source_id == source_id:
			existing.enabled = enabled
			return errors
	light_source_overrides.append(record)
	return errors


func light_enabled(location_id: String, prop_id: String, source_id: String) -> bool:
	var source: Dictionary = LightSourceRegistry.find(location_id, prop_id, source_id)
	if source.is_empty():
		return false
	if source.switchable:
		for record: Dictionary in light_source_overrides:
			if record.location_id == location_id and record.prop_id == prop_id and record.source_id == source_id:
				return record.enabled
	return source.default_enabled


func advance(delta: float) -> PackedStringArray:
	var errors: PackedStringArray = validation_errors()
	if not errors.is_empty():
		return errors
	var result: EnvironmentClock.AdvanceResult = EnvironmentClock.advance(day_index, day_cycle_progress, delta)
	if result.errors.is_empty():
		day_index = result.day_index
		day_cycle_progress = result.day_cycle_progress
	return result.errors


func weather_sample() -> WeatherSchedule.Sample:
	return _forecast.sample(weather_seed, day_index, day_cycle_progress)


func is_heavy_rain() -> bool:
	var current: WeatherSchedule.Sample = weather_sample()
	return current != null and current.is_heavy_rain()
