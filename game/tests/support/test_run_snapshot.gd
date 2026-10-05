class_name TestRunSnapshot
extends RefCounted
## Exact durable restart oracle. JSON numbers are decoded through SaveCodec.

static func weather(state: EnvironmentState) -> Dictionary:
	var sample: WeatherSchedule.Sample = state.weather_sample()
	return {"condition":sample.condition, "previous":sample.previous_condition,
		"period":sample.period_index, "start":sample.period_start_minutes,
		"end":sample.period_end_minutes, "blend":sample.transition_progress,
		"heavy_rain":sample.is_heavy_rain()}


static func exact_json(value: Dictionary) -> String:
	return JSON.stringify(value, "", true, true)


static func oracle(session: GameSession) -> Dictionary:
	return {"schema_version":1, "writer_pid":OS.get_process_id(),
		"snapshot_json":exact_json(SaveCodec.snapshot(session)),
		"weather_json":exact_json(weather(session.environment))}


static func compare_restored(session: GameSession, saved: Dictionary, disk: GameSession, require_new_process: bool = true) -> PackedStringArray:
	var errors: PackedStringArray = []
	if saved.get("schema_version") != 1 or not saved.get("snapshot_json") is String or not saved.get("weather_json") is String:
		return PackedStringArray(["invalid restart oracle"])
	var writer: Variant = saved.get("writer_pid")
	if not writer is float and not writer is int:
		return PackedStringArray(["invalid writer PID"])
	if not is_finite(float(writer)) or float(writer) != floor(float(writer)) or float(writer) <= 0:
		return PackedStringArray(["invalid writer PID"])
	if require_new_process and int(writer) == OS.get_process_id():
		errors.append("reader reused writer process")
	if session == null or disk == null:
		return PackedStringArray(["restored or disk session missing"])
	var actual: String = exact_json(SaveCodec.snapshot(session))
	if actual != exact_json(SaveCodec.snapshot(disk)):
		errors.append("GUI Load differs from typed disk facts")
	if actual != saved.snapshot_json:
		errors.append("restart changed durable facts")
	if exact_json(weather(session.environment)) != saved.weather_json:
		errors.append("restart changed reconstructed forecast")
	return errors
