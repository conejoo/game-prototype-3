class_name WeatherConditionService
extends RefCounted
## Read-only facts for UI and future routine consumers. Never owns a clock.

var _environment: EnvironmentState


func bind_environment(environment: EnvironmentState) -> void:
	_environment = environment


func sample() -> WeatherSchedule.Sample:
	return _environment.weather_sample() if _environment != null else null


func condition_id() -> String:
	var current: WeatherSchedule.Sample = sample()
	return WeatherSchedule.condition_id(current.condition) if current != null else ""


func has_condition(id: String) -> bool:
	var current: WeatherSchedule.Sample = sample()
	return current != null and (current.is_heavy_rain() if id == "heavy-rain" else WeatherSchedule.condition_id(current.condition) == id)


static func display_name(condition: WeatherSchedule.Condition) -> String:
	match condition:
		WeatherSchedule.Condition.SUNNY: return "Clear"
		WeatherSchedule.Condition.CLOUDY: return "Cloudy"
		WeatherSchedule.Condition.RAINY: return "Rain"
		WeatherSchedule.Condition.THUNDERSTORM: return "Thunderstorm"
	return ""
