extends SceneTree
## Output routing and no-overwrite checks with real files in this isolated run.
var failures: Array[String] = []
var assertions: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var directory: String = TestRunEvidence.directory()
	_check(not directory.is_empty(), "runner directory missing")
	var evidence_root: String = ProjectSettings.globalize_path("res://../docs/evidence")
	for destination: String in [evidence_root.path_join("M009"), "res://../docs/evidence-sibling/run/test", "res://../builds/testing/outside", directory.path_join("../other")]:
		_check(not TestRunEvidence.validate(destination, "denied.json").ok, "unsafe directory accepted " + destination)
	for filename: String in ["../escape.json", "nested/file.json", ".", "..", ""]:
		_check(not TestRunEvidence.validate(directory, filename).ok, "unsafe filename accepted")
	_check(TestRunEvidence.write_json("guard-preserved.json", {"exact":0.125, "pid":OS.get_process_id()}), "new report write failed")
	var path: String = directory.path_join("guard-preserved.json")
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	_check(not TestRunEvidence.validate(directory, "guard-preserved.json").ok, "existing file accepted")
	_check(FileAccess.get_file_as_bytes(path) == bytes, "existing report changed")
	DirAccess.make_dir_recursive_absolute(directory.path_join("directory.json"))
	_check(not TestRunEvidence.validate(directory, "directory.json").ok, "existing directory accepted")
	_check(TestRunEvidence.validate(directory, "another-new.json").ok, "new filename rejected")
	var linked: String = OS.get_environment("RETURNING_FAIR_TEST_JUNCTION")
	if not linked.is_empty():
		# Pure rejection under an explicit process-local fixture namespace; restore
		# runner ownership immediately, and never create a file through the link.
		var owned: String = OS.get_environment("RETURNING_FAIR_EVIDENCE_DIR")
		OS.set_environment("RETURNING_FAIR_EVIDENCE_DIR", linked)
		var denied: Dictionary = TestRunEvidence.validate(linked, "denied.json")
		OS.set_environment("RETURNING_FAIR_EVIDENCE_DIR", owned)
		_check(not denied.ok and denied.error.contains("linked"), "linked directory accepted")
	for failure: String in failures: push_error(failure)
	print("Testing evidence: %s assertions=%d" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)
func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
