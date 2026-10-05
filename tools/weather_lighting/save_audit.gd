extends SceneTree
## Read-only typed reconstruction of actual native GUI saves against release pack.

func _initialize() -> void:
	var before_path: String = ""
	var after_path: String = ""
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--before="): before_path = argument.trim_prefix("--before=")
		if argument.begins_with("--after="): after_path = argument.trim_prefix("--after=")
		if argument.begins_with("--audit-output="): output = argument.trim_prefix("--audit-output=")
	var catalog: ContentCatalog = ContentCatalog.new()
	var failures: PackedStringArray = catalog.initialize(load("res://content/prototype_catalog.tres"))
	var before: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(before_path),catalog)
	var after: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(after_path),catalog)
	failures.append_array(before.errors)
	failures.append_array(after.errors)
	if not failures.is_empty():
		push_error(str(failures))
		quit(1)
		return
	var snapshot_before: String = JSON.stringify(SaveCodec.snapshot(before.session),"",true,true)
	var snapshot_after: String = JSON.stringify(SaveCodec.snapshot(after.session),"",true,true)
	var forecast_before: Dictionary = _forecast(before.session.environment)
	var forecast_after: Dictionary = _forecast(after.session.environment)
	if snapshot_before != snapshot_after: failures.append("Native restart durable facts differ")
	if JSON.stringify(forecast_before,"",true,true) != JSON.stringify(forecast_after,"",true,true): failures.append("Native restart forecast differs")
	var result: Dictionary = {"engine_pid":OS.get_process_id(),"before":before_path,"after":after_path,"typed_snapshot_exact":snapshot_before==snapshot_after,"forecast_before":forecast_before,"forecast_after":forecast_after,"display_time":EnvironmentClock.format_time(before.session.environment.day_cycle_progress),"failures":failures}
	var file: FileAccess = FileAccess.open(output,FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"\t",true,true)+"\n")
	file.close()
	print("W010 native save/forecast audit: ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _forecast(state: EnvironmentState) -> Dictionary:
	var sample: WeatherSchedule.Sample = state.weather_sample()
	return {"seed":state.weather_seed,"day_index":state.day_index,"progress":state.day_cycle_progress,"condition":WeatherSchedule.condition_id(sample.condition),"previous":WeatherSchedule.condition_id(sample.previous_condition),"period":sample.period_index,"start":sample.period_start_minutes,"end":sample.period_end_minutes,"blend":sample.transition_progress,"heavy_rain":sample.is_heavy_rain()}
