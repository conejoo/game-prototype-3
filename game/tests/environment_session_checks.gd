extends SceneTree
## W002 actual root/session gates. Synthetic headless setup, no save writes.

var failures: Array[String] = []
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W002 engine=%s pid=%d user_data=%s" % [Engine.get_version_info()["string"], OS.get_process_id(), OS.get_user_data_dir()])
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	await game.world_host.transition_finished
	var environment: EnvironmentState = game.session.environment
	var seed: int = environment.weather_seed
	var before: float = _minutes()
	await _frames()
	_check(_minutes() > before, "active clock did not advance")
	game._set_paused(true)
	before = _minutes()
	var elapsed: float = game.session.elapsed_play_seconds
	await _frames()
	_check(paused and _minutes() == before and game.session.elapsed_play_seconds == elapsed, "pause advanced environment")
	# Loading is legally requested only while paused; exercise that same gate.
	game.loading_save = true
	await _frames()
	_check(_minutes() == before, "paused load lock advanced environment")
	game.loading_save = false
	game._set_paused(false)
	await _frames()
	_check(_minutes() > before, "resume did not advance environment")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	before = _minutes()
	await _frames()
	_check(not game.window_focused and not game.player_placeholder.controls_enabled and _minutes() > before, "focus policy changed session clock")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	game._toggle_journal()
	before = _minutes()
	await _frames()
	_check(game.journal_open and not game.player_placeholder.controls_enabled and _minutes() > before, "journal incorrectly froze environment")
	game._toggle_journal()
	game._present_dialogue(game.dialogue.begin_graph(game.catalog.get_dialogue("prototype-companion-greeting"), "synthetic-clock-gate"))
	before = _minutes()
	await _frames()
	_check(game.dialogue.active() and not game.player_placeholder.controls_enabled and _minutes() > before, "dialogue incorrectly froze environment")
	game._cancel_dialogue()
	for location: String in ["prototype-tollworks", "prototype-alderwake"]:
		var spawn: String = "tollworks-from-alderwake" if location == "prototype-tollworks" else "alderwake-from-tollworks"
		_check(game.world_host.request_transition(location, spawn).is_empty(), "travel rejected")
		before = _minutes()
		elapsed = game.session.elapsed_play_seconds
		_check(game.world_host.transitioning, "travel did not lock")
		var arrival: Array = await game.world_host.transition_finished
		_check(arrival[0] and _minutes() == before and game.session.elapsed_play_seconds == elapsed, "travel gate advanced clock")
		_check(game.session.environment == environment and environment.weather_seed == seed, "travel replaced state or rerolled seed")
		await _frames()
		_check(_minutes() > before, "active room clock did not resume: " + location)
	game._set_paused(true)
	_check(paused, "cleanup pause failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("W002 session PASS: active/pause/resume, paused load lock, focus/modal advancing policy, travel freeze, indoor/outdoor shared clock and seed.")
	quit(0 if failures.is_empty() else 1)


func _minutes() -> float:
	return EnvironmentClock.absolute_minutes(game.session.environment.day_index, game.session.environment.day_cycle_progress)


func _frames() -> void:
	for frame: int in range(8):
		await process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
