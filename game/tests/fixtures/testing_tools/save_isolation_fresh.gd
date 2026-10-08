extends SceneTree

func _initialize() -> void:
	var slot: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-slot="): slot = argument.trim_prefix("--save-slot=")
	var failures: PackedStringArray = []
	if slot.is_empty(): failures.append("Fresh fixture requires runner slot")
	# Checking the whole directory catches leaked named slots with different names,
	# as well as fixed paths, backup and sidecar files from an earlier check.
	if DirAccess.dir_exists_absolute("user://saves") and not DirAccess.get_files_at("user://saves").is_empty():
		failures.append("Independent check inherited files from another group")
	print("SAVE_FIXTURE=" + JSON.stringify({"pid":OS.get_process_id(),"slot":slot,"phase":"fresh","user_data":OS.get_user_data_dir(),"failures":failures}))
	for failure: String in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
