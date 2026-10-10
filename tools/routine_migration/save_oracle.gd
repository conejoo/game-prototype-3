extends SceneTree
## Detached production-code replay of native GUI-save bytes, never live mutation.

func _initialize() -> void:
	var paths: Dictionary = {}
	for argument: String in OS.get_cmdline_user_args():
		for key: String in ["writer", "reader", "output"]:
			if argument.begins_with("--oracle-" + key + "="):
				paths[key] = argument.trim_prefix("--oracle-" + key + "=")
	var failures: PackedStringArray = []
	var catalog: ContentCatalog = ContentCatalog.new()
	failures.append_array(catalog.initialize(load("res://content/prototype_catalog.tres")))
	var writer: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(paths.writer), catalog)
	var reader: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(paths.reader), catalog)
	failures.append_array(writer.errors)
	failures.append_array(reader.errors)
	var result: Dictionary = {"task":"R016","schema":SaveCodec.SCHEMA_VERSION,"content_version":SaveCodec.CONTENT_VERSION,"proof":"Detached packed production codec/forecast replay of ordinary native GUI Save/Load/Save outputs", "engine_pid":OS.get_process_id()}
	if writer.session != null and reader.session != null:
		var before: String = JSON.stringify(SaveCodec.snapshot(writer.session), "", true, true)
		var after: String = JSON.stringify(SaveCodec.snapshot(reader.session), "", true, true)
		result.typed_snapshot_exact = before == after
		result.writer_snapshot = SaveCodec.snapshot(writer.session)
		result.reader_snapshot = SaveCodec.snapshot(reader.session)
		result.writer_weather = _weather(writer.session.environment)
		result.reader_weather = _weather(reader.session.environment)
		result.forecast_exact = JSON.stringify(result.writer_weather,"",true,true) == JSON.stringify(result.reader_weather,"",true,true)
		if not result.typed_snapshot_exact: failures.append("Typed whole-save snapshots differ")
		if not result.forecast_exact: failures.append("Reconstructed forecast differs")
	else:
		failures.append("Native GUI save does not decode")
	result.failures = failures
	var file: FileAccess = FileAccess.open(paths.output,FileAccess.WRITE)
	if file == null:
		push_error("Cannot write native save oracle evidence")
		quit(1)
		return
	file.store_string(JSON.stringify(result,"\t",true,true)+"\n")
	file.close()
	print("R016 typed native save/forecast oracle: ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _weather(state: EnvironmentState) -> Dictionary:
	var sample: WeatherSchedule.Sample = state.weather_sample()
	return {"condition":sample.condition,"previous":sample.previous_condition,"period":sample.period_index,
		"start":sample.period_start_minutes,"end":sample.period_end_minutes,
		"blend":sample.transition_progress,"heavy_rain":sample.is_heavy_rain()}
