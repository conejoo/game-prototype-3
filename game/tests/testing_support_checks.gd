extends SceneTree
## Shared test infrastructure: strict restart numbers, observations and capture gates.
var failures: PackedStringArray = []
var assertions: int = 0
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "catalog")
	var session: GameSession = SaveCodec.decode(FileAccess.get_file_as_string("res://tests/fixtures/environment_save_v5.json"), catalog).session
	_check(session != null, "typed fixture")
	if session == null:
		quit(1)
		return
	for progress: float in [0.0, 0.1, 0.6180339887498948, 1.0 - pow(2.0, -53)]:
		session.environment.day_cycle_progress = progress
		var saved: Dictionary = TestRunSnapshot.oracle(session)
		var disk: GameSession = SaveCodec.decode(saved.snapshot_json, catalog).session
		var parsed: Dictionary = JSON.parse_string(JSON.stringify(saved))
		_check(disk != null and disk.environment.day_cycle_progress == progress, "exact binary64 progress")
		_check(TestRunSnapshot.compare_restored(session, parsed, disk, false).is_empty(), "JSON oracle exact round trip")
		_check(not TestRunSnapshot.compare_restored(session, parsed, disk).is_empty(), "same process rejected")
		var changed: Dictionary = parsed.duplicate(true)
		changed.weather_json = "{}"
		_check("restart changed reconstructed forecast" in TestRunSnapshot.compare_restored(session, changed, disk, false), "forecast mismatch rejected")
		disk.environment.weather_seed = (session.environment.weather_seed + 1) % 4294967296
		_check("GUI Load differs from typed disk facts" in TestRunSnapshot.compare_restored(session, parsed, disk, false), "disk seed mismatch rejected")
		changed = parsed.duplicate(true)
		changed.writer_pid = null
		_check(not TestRunSnapshot.compare_restored(session, changed, session, false).is_empty(), "malformed oracle rejected")
	var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	paused = true
	game.ui.show_paused(true)
	game.session.environment.day_cycle_progress = .625 # synthetic observation fixture
	game.session.environment.set_light_enabled("prototype-alderwake", "dock-lamp-02", "lantern", true)
	game._present_environment()
	var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	var bridge: Node = load("res://tests/live_playtest_bridge.gd").new()
	bridge.game = game
	game.add_child(bridge)
	var observed: Dictionary = bridge._observe()
	_check(observed.paused and observed.pause_overlay_visible, "pause independently observed")
	_check(observed.camera_controls == TestRunObservation.camera(game), "camera axes observed from live API")
	_check(observed.environment.sources.size() == 23 and observed.environment.consumer_count == 23 and observed.environment.emitter_count <= 8, "all live sources observed")
	_check(observed.environment.day_cycle_progress == .625 and observed.environment.weather_seed == game.session.environment.weather_seed, "clock and seed observed")
	_check(observed.environment.weather == TestRunSnapshot.weather(game.session.environment), "forecast observed")
	for row: Dictionary in observed.environment.sources:
		var consumer: ExteriorLightConsumer = game.world_host.current_location.exterior_lights.consumers[row.prop_id]
		_check(row.presented and row.intensity == consumer.intensity and row.consumer_enabled == consumer.enabled, "actual consumer " + row.prop_id)
		if consumer.emitter != null:
			_check(row.light_energy == consumer.emitter.light_energy, "actual emitter " + row.prop_id)
	observed.environment.light_source_overrides[0].enabled = false
	observed.environment.sources[0].enabled = false
	_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before, "observation and caller edits cannot mutate facts")
	var denied: Dictionary = await TestRunCapture.capture(game, "headless", ProjectSettings.globalize_path("res://../docs/evidence/TESTING/denied"), "synthetic", false, "headless rejection")
	_check(not denied.ok, "headless capture rejected")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures:
		push_error(failure)
	print("Testing support: %s assertions=%d" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
