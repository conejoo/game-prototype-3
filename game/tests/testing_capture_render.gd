extends SceneTree
## Actual renderer tests of capture refusal and pause-overlay restoration.
var failures: PackedStringArray = []
var views: Array[Dictionary] = []
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	root.size = Vector2i(960, 640)
	var directory: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir="):
			directory = ProjectSettings.globalize_path(argument.trim_prefix("--report-dir="))
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		push_error("capture check requires real renderer and report-dir")
		quit(1)
		return
	var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	var denied: Dictionary = await TestRunCapture.capture(game, "unpaused", directory, "debug-input", false, "refusal fixture")
	_check(not denied.ok, "unpaused capture accepted")
	paused = true
	game.ui.show_paused(false)
	denied = await TestRunCapture.capture(game, "overlay-unverified", directory, "synthetic", false, "pause guard fixture")
	_check(not denied.ok, "paused tree without overlay accepted")
	game.ui.show_paused(true)
	for row: Array in [["../unsafe", directory, "debug-input", "fixture"],
		["outside", ProjectSettings.globalize_path("res://../builds/testing/outside"), "debug-input", "fixture"],
		["bad-kind", directory, "native-input", "fixture"], ["no-note", directory, "debug-input", ""]]:
		denied = await TestRunCapture.capture(game, row[0], row[1], row[2], false, row[3])
		_check(not denied.ok, "invalid capture accepted " + str(row[0]))
	var captured: Dictionary = await TestRunCapture.capture(game, "capture-guard-world", directory, "synthetic", false, "Fresh startup; programmatic pause fixture")
	_check(captured.ok and paused and game.ui.pause_overlay.visible, "world capture failed or overlay not restored")
	if captured.ok:
		views.append(captured)
		var bytes: PackedByteArray = FileAccess.get_file_as_bytes(captured.path)
		denied = await TestRunCapture.capture(game, "capture-guard-world", directory, "debug-input", false, "duplicate fixture")
		_check(not denied.ok and FileAccess.get_file_as_bytes(captured.path) == bytes, "existing PNG overwritten")
	captured = await TestRunCapture.capture(game, "capture-guard-overlay", directory, "synthetic", true, "Fresh startup; programmatic pause fixture")
	_check(captured.ok and captured.overlay and paused and game.ui.pause_overlay.visible, "overlay capture failed")
	if captured.ok:
		views.append(captured)
	var file: FileAccess = FileAccess.open(directory.path_join("check-index.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"views":views, "failures":failures}, "\t", true, true))
	file.close()
	for failure: String in failures:
		push_error(failure)
	print("Testing capture render: %s captures=%d" % ["PASS" if failures.is_empty() else "FAIL", views.size()])
	game.queue_free()
	await process_frame
	paused = false
	quit(0 if failures.is_empty() else 1)
func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
