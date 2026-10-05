extends SceneTree
## Synthetic clock fixtures; real viewport keys/GUI and optional rendered review.

var failures: PackedStringArray = []
var game: Node3D
var views: Array[Dictionary] = []
var directory: String = ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(960, 640)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--report-dir="):
			directory = ProjectSettings.globalize_path(argument.trim_prefix("--report-dir="))
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	await game.world_host.transition_finished
	await _frames()
	_check(game.debug_shortcuts_enabled == ("--debug-shortcuts" in OS.get_cmdline_user_args()), "Launch flag did not set debug mode")
	_check(game.ui.debug_toggle.button_pressed == game.debug_shortcuts_enabled, "Launch flag and Settings disagree")
	_check(not game.ui.fps_label.visible and not game.ui.fps_toggle.button_pressed, "FPS enabled without opt-in")
	if "--flag-only" in OS.get_cmdline_user_args():
		game.set_process(false)
		var minutes: float = _minutes()
		_key(KEY_F6)
		_check(is_equal_approx(_minutes() - minutes, 60.0), "Flag-enabled shortcut failed")
		_key(KEY_ESCAPE)
		await _click(game.ui.settings_button)
		await _click(game.ui.debug_toggle)
		_check(not game.debug_shortcuts_enabled, "Settings could not disable flag-enabled mode")
		await _finish()
		return
	# Stop natural clock ticks so exact 60-minute assertions measure the key alone.
	game.set_process(false)
	_check(InputMap.action_get_events("debug_advance_hour")[0].keycode == KEY_F6, "F6 binding incorrect")
	_blocked("debug off")
	_key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible, "Escape did not pause")
	await _click(game.ui.settings_button)
	_check(game.ui.settings_open() and paused and not game.player_placeholder.controls_enabled, "Settings failed to open paused")
	await _capture("settings-defaults")
	await _click(game.ui.fps_toggle)
	_check(game.ui.fps_label.visible and not game.debug_shortcuts_enabled, "FPS not independent of debug")
	await _click(game.ui.debug_toggle)
	_check(game.debug_shortcuts_enabled and game.ui.debug_label.visible, "GUI debug toggle failed")
	_blocked("settings/pause")
	await create_timer(1.1, true).timeout
	_check(game.ui.fps_label.text.begins_with("FPS: ") and game.ui.fps_label.text.trim_prefix("FPS: ").is_valid_int(), "FPS did not sample while paused")
	await _capture("settings-enabled")
	game.ui.settings_back.grab_focus()
	_key(KEY_TAB)
	_check(root.gui_get_focus_owner() == game.ui.fps_toggle, "Settings Tab cycle escaped")
	_key(KEY_TAB)
	_check(root.gui_get_focus_owner() == game.ui.debug_toggle, "Settings Tab did not reach debug toggle")
	_key(KEY_ESCAPE)
	_check(paused and not game.ui.settings_open() and game.ui.pause_overlay.visible, "Settings Escape resumed instead of returning")
	await _capture("pause-with-settings")
	_key(KEY_ESCAPE)
	_check(not paused and game.player_placeholder.controls_enabled and root.gui_get_focus_owner() == null, "Resume did not restore controls/focus")
	var environment: EnvironmentState = game.session.environment
	environment.day_index = 2
	environment.day_cycle_progress = 0.0
	var before: Dictionary = SaveCodec.snapshot(game.session)
	var before_position: Vector3 = game.player_placeholder.global_position
	_key(KEY_F6)
	_check(is_equal_approx(environment.day_cycle_progress, 1.0 / 24.0), "F6 did not advance exactly one hour")
	var after: Dictionary = SaveCodec.snapshot(game.session)
	before.environment = after.environment
	_check(TestRunSnapshot.exact_json(before) == TestRunSnapshot.exact_json(after), "Skip changed facts outside environment")
	_check(game.player_placeholder.global_position == before_position, "Skip moved actor")
	_check(game.ui.debug_label.text.ends_with("11:00 AM"), "Debug clock feedback missing")
	_blocked("key echo", true)
	environment.day_cycle_progress = 13.5 / 24.0
	_key(KEY_F6)
	_check(EnvironmentClock.format_time(environment.day_cycle_progress) == "12:30 AM" and environment.day_index == 2, "Display midnight rollover incorrect")
	environment.day_cycle_progress = 23.5 / 24.0
	_key(KEY_F6)
	_check(environment.day_index == 3 and is_equal_approx(environment.day_cycle_progress, .5 / 24.0), "Authored cycle rollover incorrect")
	var forecast: WeatherSchedule.Sample = environment.weather_sample()
	var independent: WeatherSchedule.Sample = WeatherSchedule.new().sample(environment.weather_seed, environment.day_index, environment.day_cycle_progress)
	_check(forecast.period_index == independent.period_index and forecast.condition == independent.condition, "Skip left stale weather forecast")
	game.ui.pause_button.grab_focus()
	_blocked("GUI focus")
	game.ui.pause_button.release_focus()
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_blocked("window focus")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game._toggle_journal()
	_blocked("journal")
	game._toggle_journal()
	game._present_dialogue(game.dialogue.begin(game.catalog.get_dialogue("prototype-companion-greeting"), "synthetic-debug-gate"))
	_blocked("dialogue")
	game._cancel_dialogue()
	for gate: String in ["loading_save", "retrying"]:
		game.set(gate, true)
		_blocked(gate)
		game.set(gate, false)
	game.player_placeholder.state.health = 0
	game._update_controls()
	_blocked("defeat")
	game.player_placeholder.state.health = game.player_placeholder.state.max_health
	game._update_controls()
	_check(game.world_host.request_transition("prototype-alderwake", "alderwake-start").is_empty(), "Travel failed")
	_blocked("travel")
	await game.world_host.transition_finished
	await _frames()
	environment.day_index = 0
	environment.day_cycle_progress = .25
	game._present_environment()
	var sun_before: Vector3 = game.get_node("Sun").rotation
	_key(KEY_F6)
	_check(game.get_node("Sun").rotation != sun_before, "Skip did not refresh outdoor sun")
	_key(KEY_ESCAPE)
	await _capture("outdoor-fps-debug", false)
	await _click(game.ui.settings_button)
	await _click(game.ui.debug_toggle)
	_check(not game.debug_shortcuts_enabled and not game.ui.debug_label.visible and game.ui.fps_label.visible, "Disabling debug changed FPS")
	await _click(game.ui.fps_toggle)
	_check(not game.ui.fps_label.visible, "FPS could not be hidden")
	_key(KEY_ESCAPE)
	_key(KEY_ESCAPE)
	_blocked("debug disabled again")
	# Supported clock cap rejects atomically; no invalid save facts are introduced.
	game._set_debug_shortcuts_enabled(true)
	environment.day_index = EnvironmentClock.MAX_DAY_INDEX
	environment.day_cycle_progress = .99
	var capped: float = _minutes()
	_key(KEY_F6)
	_check(_minutes() == capped, "Clock-cap rejection mutated time")
	game._set_debug_shortcuts_enabled(false)
	# Separate process verifies actual startup flag, then disabling it via GUI.
	var output: Array = []
	var code: int = OS.execute(OS.get_executable_path(), PackedStringArray(["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/settings_debug_checks.gd", "--", "--debug-shortcuts", "--flag-only", "--save-slot=settings-debug-flag"]), output, true)
	_check(code == 0 and not str(output).contains("SCRIPT ERROR") and not str(output).contains("ERROR:"), "Flag subprocess failed: " + str(output))
	await _finish()


func _minutes() -> float:
	return EnvironmentClock.absolute_minutes(game.session.environment.day_index, game.session.environment.day_cycle_progress)


func _key(code: int, echo: bool = false) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		event.echo = echo and pressed
		root.push_input(event, true)


func _blocked(label: String, echo: bool = false) -> void:
	var before: float = _minutes()
	_key(KEY_F6, echo)
	_check(_minutes() == before, "F6 bypassed " + label)


func _click(control: Control) -> void:
	await _frames()
	var point: Vector2 = control.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
	await _frames()


func _frames() -> void:
	for frame: int in range(4):
		await process_frame


func _capture(label: String, overlay: bool = true) -> void:
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	game._process(0.0)
	var was_settings: bool = game.ui.settings_open()
	var focused: Control = root.gui_get_focus_owner()
	var result: Dictionary = await TestRunCapture.capture(game, label, directory, "synthetic", overlay, "Synthetic exact clock fixtures; settings and shortcuts through viewport GUI/key input")
	if was_settings:
		game.ui.show_settings(true)
		if is_instance_valid(focused):
			focused.grab_focus()
	_check(result.ok, result.get("error", "capture failed"))
	if result.ok:
		views.append(result)


func _finish() -> void:
	game.queue_free()
	await process_frame
	paused = false
	if not directory.is_empty():
		var file: FileAccess = FileAccess.open(directory.path_join("settings-index.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify({"views":views, "failures":failures}, "\t", true, true))
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("Settings/debug PASS: flag, GUI toggles, FPS, pause/focus, exact hour/rollovers, gates, weather refresh and clock cap.")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
