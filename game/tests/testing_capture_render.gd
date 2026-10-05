extends SceneTree
## Actual renderer tests of capture refusal and pause-overlay restoration.
var failures: PackedStringArray = []
var views: Array[Dictionary] = []
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	root.size = Vector2i(960, 640)
	var directory: String = TestRunEvidence.directory()
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
	# GUI guard failures must send no activation; real focus input verifies outcomes.
	var gui: Dictionary = await TestRunGui.activate(game, game.ui.save_button, func() -> bool: return true)
	_check(not gui.ok and not FileAccess.file_exists(game.save_repository.path), "stale GUI outcome accepted")
	game.ui.save_button.disabled = true # Explicit refusal fixture; no gameplay claim.
	gui = await TestRunGui.activate(game, game.ui.save_button, func() -> bool: return false)
	_check(not gui.ok and not FileAccess.file_exists(game.save_repository.path), "disabled GUI target activated")
	game.ui.save_button.disabled = false
	gui = await TestRunGui.activate(game, game.ui.settings_button, func() -> bool: return false, 16, 2)
	_check(not gui.ok and game.ui.settings_open(), "unmet GUI outcome silently accepted")
	var focus: Control = root.gui_get_focus_owner()
	gui = await TestRunGui.activate(game, game.ui.resume_button, func() -> bool: return not paused)
	_check(not gui.ok and paused, "hidden target bypassed settings modal")
	captured = await TestRunCapture.capture(game, "capture-settings-world", directory, "synthetic", false, "Settings opened with actual focus input; capture must preserve modal and focus")
	_check(captured.ok and game.ui.settings_open() and root.gui_get_focus_owner() == focus, "capture reset settings or focus")
	if captured.ok: views.append(captured)
	gui = await TestRunGui.activate(game, game.ui.settings_back, func() -> bool: return not game.ui.settings_open())
	_check(gui.ok and paused, "actual settings Back outcome failed")
	gui = await TestRunGui.activate(game, game.ui.save_button, func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(gui.ok and FileAccess.file_exists(game.save_repository.path), "GUI Save outcome or isolated file missing")
	gui = await TestRunGui.activate(game, game.ui.resume_button, func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	_check(gui.ok, "GUI Resume outcome failed")
	gui = await TestRunGui.activate(game, game.ui.save_button, func() -> bool: return false)
	_check(not gui.ok, "unpaused GUI activation accepted")
	game._set_paused(true)
	var file: FileAccess = FileAccess.open(TestRunEvidence.path("check-index.json"), FileAccess.WRITE)
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
