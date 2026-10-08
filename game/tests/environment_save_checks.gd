extends SceneTree
## W003 plain-data/IO fixtures; synthetic state, never normal-player save slots.

var failures: PackedStringArray = []
var assertions: int = 0
var catalog: ContentCatalog = ContentCatalog.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "Catalog prerequisite")
	var numbers: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_save_numbers.json"))
	for vector: Dictionary in numbers.vectors:
		var bytes: PackedByteArray = []
		bytes.resize(8)
		bytes.encode_double(0, SaveNumber.parse(vector.decimal))
		_check(bytes.decode_u32(0) == int(vector.low) and bytes.decode_u32(4) == int(vector.high), "Independent binary64 oracle " + vector.decimal)
	_check(is_nan(SaveNumber.parse("0." + "1".repeat(1100))), "Numeric token bound")
	var expected_registry: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_light_registry.json"))
	_check(LightSourceRegistry.entries() == expected_registry, "All 23 pinned identities/defaults/switchability")
	var registry: Array[Dictionary] = LightSourceRegistry.entries()
	registry[0].default_enabled = false
	_check(LightSourceRegistry.entries() == expected_registry, "Registry query must be detached")
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_save_v6.json"))
	var duplicate_time: String = JSON.stringify(data).replace('"day_index":146', '"day_cycle_progress":0.5,"day_index":146')
	_check(SaveCodec.decode(duplicate_time, catalog).session == null, "Duplicate clock lexeme rejected")
	var newer_time: String = duplicate_time.replace('"schema_version":6', '"schema_version":7')
	_check(SaveCodec.decode(newer_time, catalog).incompatible, "Newer envelope protects files even with duplicate numeric fields")
	var escaped_time: String = JSON.stringify(data, "", true, true).replace('"day_cycle_progress"', '"day_cycle_\\u0070rogress"')
	_check(SaveCodec.decode(escaped_time, catalog).session != null, "Escaped JSON key decoded normally")
	var decoded: SaveCodec.DecodeResult = SaveCodec.validate(data, catalog)
	_check(decoded.session != null and decoded.errors.is_empty(), "Authored current-schema fixture validates")
	if decoded.session == null:
		_finish()
		return
	_check(_plain(SaveCodec.snapshot(decoded.session)) == _plain(data), "Exact clock/seed/six overrides and every durable fact")
	var original: String = JSON.stringify(data)
	var state: EnvironmentState = decoded.session.environment
	for row: Dictionary in expected_registry:
		_check(state.light_enabled(row.location_id, row.prop_id, row.source_id) == (not row.default_enabled if row.switchable else row.default_enabled), "Default/override precedence " + row.prop_id)
		if not row.switchable:
			_check(not state.set_light_enabled(row.location_id, row.prop_id, row.source_id, true).is_empty(), "Automatic source rejects command " + row.prop_id)
	var cursor: WeatherSchedule.Sample = state.weather_sample()
	var restored: GameSession = SaveCodec.decode(JSON.stringify(SaveCodec.snapshot(decoded.session), "", true, true), catalog).session
	var reconstructed: WeatherSchedule.Sample = restored.environment.weather_sample()
	_check(_weather(cursor) == _weather(reconstructed), "Exact forecast reconstructed without serialized cursor")
	state.set_light_enabled("prototype-alderwake", "dock-lamp-01", "lantern", false)
	state.day_cycle_progress = 0.1
	_check(JSON.stringify(data) == original and restored.environment.day_cycle_progress == 0.6180339887498948 and restored.environment.light_enabled("prototype-alderwake", "dock-lamp-01", "lantern"), "Candidates/caller overrides and clock detached")
	var unordered: Dictionary = data.duplicate(true)
	unordered.light_source_overrides.reverse()
	var unsorted_bytes: String = JSON.stringify(unordered)
	var sorted_run: GameSession = SaveCodec.validate(unordered, catalog).session
	_check(sorted_run != null and _plain(SaveCodec.snapshot(sorted_run)) == _plain(data) and JSON.stringify(unordered) == unsorted_bytes, "Tuple sort on snapshot only, without caller mutation")
	for field: String in ["environment", "light_source_overrides"]:
		var bad: Dictionary = data.duplicate(true)
		bad.erase(field)
		_reject(bad, "missing " + field)
	for raw: Variant in [null, [], true, "clock", {}, {"day_index": 0, "day_cycle_progress": 0, "weather_seed": 1, "cursor": 0}]:
		var bad: Dictionary = data.duplicate(true)
		bad.environment = raw
		_reject(bad, "invalid environment fields " + str(raw))
	for field: String in ["day_index", "day_cycle_progress", "weather_seed"]:
		var bad: Dictionary = data.duplicate(true)
		bad.environment.erase(field)
		_reject(bad, "missing environment " + field)
		var invalid: Array = [null, true, "0", [], {}, NAN, INF, -INF, -1]
		if field == "day_cycle_progress":
			invalid.append_array([1, 1.000001])
		else:
			invalid.append_array([0.5, 3651 if field == "day_index" else 4294967296])
		for value: Variant in invalid:
			bad = data.duplicate(true)
			bad.environment[field] = value
			_reject(bad, "invalid %s=%s" % [field, value])
	for seed: int in [0, 1821285621, 2147483648, 4294967295]:
		for day: int in [0, 3650]:
			var edges: Dictionary = data.duplicate(true)
			# Construct the preceding double arithmetically; decimal GDScript literal
			# parsing rounds 0.9999999999999999 to 1 in the installed engine.
			edges.environment = {"day_index": day, "day_cycle_progress": 1.0 - pow(2.0, -53.0), "weather_seed": seed}
			var edge_result: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(edges, "", true, true), catalog)
			var edge_run: GameSession = edge_result.session
			if edge_run == null or SaveCodec.snapshot(edge_run).environment != edges.environment:
				print("W003 edge diagnostic: expected=", JSON.stringify(edges.environment, "", true, true), "; actual=", "null" if edge_run == null else JSON.stringify(SaveCodec.snapshot(edge_run).environment, "", true, true), "; errors=", edge_result.errors)
			_check(edge_run != null and SaveCodec.snapshot(edge_run).environment == edges.environment, "Exact supported numeric edges")
	for records: Variant in [null, {}, true, [null], [true], ["light"], [[]], [{}]]:
		var bad: Dictionary = data.duplicate(true)
		bad.light_source_overrides = records
		_reject(bad, "invalid override container " + str(records))
	for mutation: String in ["missing", "extra", "bool-int", "bool-string", "unknown-location", "source-map", "unknown-prop", "unknown-source", "wrong-type", "automatic", "duplicate", "conflicting-duplicate"]:
		var bad: Dictionary = data.duplicate(true)
		var record: Dictionary = bad.light_source_overrides[0]
		match mutation:
			"missing": record.erase("source_id")
			"extra": record["node"] = "VisualRoot"
			"bool-int": record.enabled = 1
			"bool-string": record.enabled = "true"
			"unknown-location": record.location_id = "prototype-tollworks"
			"source-map": record.location_id = "alderwake"
			"unknown-prop": record.prop_id = "dock-lamp-99"
			"unknown-source": record.source_id = "windows"
			"wrong-type": record.prop_id = 1
			"automatic": record.prop_id = "safeguard-waylight-east-01"; record.source_id = "answer-light"
			"duplicate": bad.light_source_overrides.append(record.duplicate())
			"conflicting-duplicate":
				var duplicate: Dictionary = record.duplicate()
				duplicate.enabled = not duplicate.enabled
				bad.light_source_overrides.append(duplicate)
		_reject(bad, mutation)
	_disk_checks(data)
	var edge_run: GameSession = SaveCodec.validate(data, catalog).session
	edge_run.environment.day_index = 3650
	edge_run.environment.day_cycle_progress = 1.0 - pow(2.0, -53.0)
	var repository: SaveRepository = SaveRepository.new("user://saves/w003-edge-%d.json" % OS.get_process_id())
	_check(repository.write(edge_run, catalog).is_empty(), "Last supported clock double saves")
	var edge_read: SaveRepository.ReadResult = repository.read(catalog)
	_check(edge_read.session != null and edge_read.session.environment.day_cycle_progress == edge_run.environment.day_cycle_progress and edge_read.session.environment.weather_seed == edge_run.environment.weather_seed, "Exact last supported double survives filesystem/backup")
	var primary: String = FileAccess.get_file_as_string(repository.path)
	edge_run.environment.light_source_overrides[0]["extra"] = false
	_check(not repository.write(edge_run, catalog).is_empty() and FileAccess.get_file_as_string(repository.path) == primary, "Malformed runtime override refuses save without mutation/runtime indexing errors")
	_finish()


func _disk_checks(current: Dictionary) -> void:
	var directory: String = "user://saves/w003-codec-%d" % OS.get_process_id()
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "Isolated directory")
	var before: String = JSON.stringify(current, "\t", true, true)
	var repository: SaveRepository = SaveRepository.new(directory.path_join("current.json"))
	_write(repository.path, before)
	_write(repository.path + ".bak", before)
	var read: SaveRepository.ReadResult = repository.read(catalog)
	_check(read.session != null and _plain(SaveCodec.snapshot(read.session)) == _plain(current), "Exact current-schema disk read")
	_check(FileAccess.get_file_as_string(repository.path) == before and FileAccess.get_file_as_string(repository.path + ".bak") == before, "Read leaves primary/backup unchanged")
	if read.session == null:
		return
	_check(repository.write(read.session, catalog).is_empty(), "Explicit current-schema publication")
	_check(_plain(JSON.parse_string(FileAccess.get_file_as_string(repository.path))) == _plain(current) and _plain(JSON.parse_string(FileAccess.get_file_as_string(repository.path + ".bak"))) == _plain(current), "Primary/backup preserve all durable facts")
	_write(repository.path, "{broken")
	read = repository.read(catalog)
	_check(read.recovered and read.session != null and _plain(SaveCodec.snapshot(read.session)) == _plain(current) and FileAccess.get_file_as_string(repository.path) == "{broken", "Environment backup recovery without writes")
	print("W003 codec pid=%d; user_data=%s; files=%s" % [OS.get_process_id(), OS.get_user_data_dir(), ProjectSettings.globalize_path(directory)])


func _weather(sample: WeatherSchedule.Sample) -> Array:
	return [sample.previous_condition, sample.condition, sample.period_index, sample.period_start_minutes, sample.period_end_minutes, sample.transition_progress]


func _plain(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value, "", true, true))


func _write(path: String, bytes: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "Fixture write " + path)
	if file != null:
		file.store_string(bytes)
		file.close()


func _reject(data: Dictionary, label: String) -> void:
	var result: SaveCodec.DecodeResult = SaveCodec.validate(data, catalog)
	_check(result.session == null and not result.errors.is_empty(), "Rejected " + label)


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		push_error(failure)
	print("W003 environment codec: %s; assertions=%d" % ["PASS" if failures.is_empty() else "FAILED", assertions])
	quit(0 if failures.is_empty() else 1)
