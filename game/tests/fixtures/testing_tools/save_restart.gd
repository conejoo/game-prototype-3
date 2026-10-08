extends SceneTree
## Real disk sentinels prove both named slots and fixed fixture paths are isolated.

func _initialize() -> void:
	var slot: String = ""
	var phase: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-slot="): slot = argument.trim_prefix("--save-slot=")
		if argument.begins_with("--phase="): phase = argument.trim_prefix("--phase=")
	if slot.is_empty():
		push_error("Save fixture requires runner slot")
		quit(1)
		return
	var paths: PackedStringArray = ["user://saves/playtest-" + slot + ".json", "user://saves/fixed-fixture.json"]
	var failures: PackedStringArray = []
	if phase != "read":
		DirAccess.make_dir_recursive_absolute("user://saves")
	for path: String in paths:
		for suffix: String in ["", ".bak", ".oracle"]:
			var filename: String = path + suffix
			if phase == "read":
				if not FileAccess.file_exists(filename):
					failures.append("Missing shared restart file: " + filename)
					continue
				var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(filename))
				if not saved is Dictionary or saved.slot != slot or saved.pid == OS.get_process_id() or saved.suffix != suffix:
					failures.append("Restart slot/process/bytes changed: " + filename)
			else:
				if FileAccess.file_exists(filename): failures.append("New group inherited save file: " + filename)
				var file: FileAccess = FileAccess.open(filename, FileAccess.WRITE)
				if file == null:
					failures.append("Cannot write sentinel: " + filename)
					continue
				file.store_string(JSON.stringify({"slot":slot,"pid":OS.get_process_id(),"suffix":suffix}))
				file.close()
	print("SAVE_FIXTURE=" + JSON.stringify({"pid":OS.get_process_id(),"slot":slot,"phase":phase,"user_data":OS.get_user_data_dir(),"failures":failures}))
	for failure: String in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
