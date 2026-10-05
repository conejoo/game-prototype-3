class_name TestRunEvidence
extends RefCounted
## Run-scoped output, never the historical task root. Runner also rejects symlinks.

static func directory() -> String:
	var requested: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir="):
			requested = argument.trim_prefix("--report-dir=")
	if requested.is_empty():
		for argument: String in OS.get_cmdline_user_args():
			if argument.begins_with("--profile-output="): requested = argument.trim_prefix("--profile-output=")
	var checked: Dictionary = validate(requested, "probe.json")
	if not checked.ok:
		push_error(checked.error)
		return ""
	return checked.directory


static func validate(destination: String, filename: String) -> Dictionary:
	var evidence: String = ProjectSettings.globalize_path("res://../docs/evidence").replace("\\", "/").simplify_path()
	var absolute: String = ProjectSettings.globalize_path(destination).replace("\\", "/").simplify_path().trim_suffix("/")
	if destination.is_empty() or not absolute.begins_with(evidence + "/"):
		return {"ok":false, "error":"report directory must be inside project evidence"}
	var parts: PackedStringArray = absolute.trim_prefix(evidence + "/").split("/", false)
	if parts.size() < 2:
		return {"ok":false, "error":"report directory requires task and fresh run subdirectory"}
	var owned: String = OS.get_environment("RETURNING_FAIR_EVIDENCE_DIR").replace("\\", "/").simplify_path().trim_suffix("/")
	if not owned.is_empty() and absolute != owned:
		return {"ok":false, "error":"report directory differs from runner-owned output"}
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[A-Za-z0-9_-][A-Za-z0-9_.-]{0,127}$")
	if pattern.search(filename) == null:
		return {"ok":false, "error":"invalid evidence filename"}
	# Check every existing ancestor: Godot's lexical simplify_path does not resolve links.
	var ancestor: String = absolute
	while ancestor.begins_with(evidence):
		var access: DirAccess = DirAccess.open(ancestor.get_base_dir())
		if access != null and access.is_link(ancestor.get_file()):
			return {"ok":false, "error":"linked evidence directory rejected"}
		ancestor = ancestor.get_base_dir()
	var output: String = absolute.path_join(filename)
	var parent: DirAccess = DirAccess.open(absolute)
	if FileAccess.file_exists(output) or DirAccess.dir_exists_absolute(output) or (parent != null and parent.is_link(filename)):
		return {"ok":false, "error":"evidence output already exists"}
	return {"ok":true, "directory":absolute, "path":output}


static func path(filename: String) -> String:
	var checked: Dictionary = validate(directory(), filename)
	if not checked.ok:
		push_error(checked.error)
		return ""
	if DirAccess.make_dir_recursive_absolute(checked.directory) != OK:
		push_error("cannot create evidence directory")
		return ""
	return checked.path


static func write_json(filename: String, data: Variant) -> bool:
	var output: String = path(filename)
	if output.is_empty(): return false
	var file: FileAccess = FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		push_error("cannot write evidence: " + output)
		return false
	file.store_string(JSON.stringify(data, "\t", true, true) + "\n")
	file.close()
	return true
