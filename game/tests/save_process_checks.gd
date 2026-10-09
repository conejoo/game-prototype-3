extends SceneTree
## Two separate OS processes. Synthetic health setup is explicitly test-only.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var write_phase: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	failures.append_array(TestRunSave.configure(game, "user://saves/p005-process-check.json"))
	if write_phase:
		game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
		await game.world_host.transition_finished
		game._set_paused(true)
		game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 37
		game.companion.state.health = 43
		game.session.elapsed_play_seconds = 42.5
		# Exact nontrivial durable fixture; fresh seed generation is not used on read.
		game.session.environment.day_index = 146
		game.session.environment.day_cycle_progress = 0.6180339887498948
		game.session.environment.weather_seed = 4294967295
		for source: Dictionary in LightSourceRegistry.entries():
			if source.switchable:
				failures.append_array(game.session.environment.set_light_enabled(source.location_id, source.prop_id, source.source_id, not source.default_enabled))
		failures.append_array(game.save_run())
		var sample: WeatherSchedule.Sample = game.session.environment.weather_sample()
		var oracle: Dictionary = {"previous":sample.previous_condition,"condition":sample.condition,"period":sample.period_index,"start":sample.period_start_minutes,"end":sample.period_end_minutes,"blend":sample.transition_progress}
		var file: FileAccess = FileAccess.open(game.save_repository.path + ".forecast", FileAccess.WRITE)
		_check(file != null, "Cannot write process forecast oracle")
		if file != null:
			file.store_string(JSON.stringify(oracle, "", true, true))
			file.close()
	else:
		_check(game.session.current_location_id == "prototype-alderwake" and game.player_placeholder.state.health == 100, "Reader inherited writer state before disk load")
		game._set_paused(true)
		failures.append_array(await game.load_run())
		_check(game.session.current_location_id == "prototype-tollworks" and game.session.current_spawn_id == "tollworks-from-alderwake", "Restart restored wrong arrival")
		_check(game.player_placeholder.state.health == 37 and game.session.elapsed_play_seconds == 42.5, "Restart lost health/time")
		_check(game.companion.state.health == 43 and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID], "Restart lost companion health/state binding")
		_check(game.session.party_member_ids == PackedStringArray(["party-player", "party-companion"]) and game.party.members().size() == 2, "Restart lost party")
		_check(game.player_placeholder.global_position.distance_to(Vector3(0, 0, -2.5)) < 0.01, "Restart spawned outside safe anchor")
		var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_save_v8.json"))
		var actual: Dictionary = SaveCodec.snapshot(game.session)
		_check(JSON.parse_string(JSON.stringify(actual.environment, "", true, true)) == expected.environment and actual.light_source_overrides == expected.light_source_overrides, "Separate-process restore lost exact clock/seed/six overrides")
		var sample: WeatherSchedule.Sample = game.session.environment.weather_sample()
		var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(game.save_repository.path + ".forecast"))
		_check(oracle == JSON.parse_string(JSON.stringify({"previous":sample.previous_condition,"condition":sample.condition,"period":sample.period_index,"start":sample.period_start_minutes,"end":sample.period_end_minutes,"blend":sample.transition_progress}, "", true, true)), "Separate process reconstructed different weather")
	print("W003 process environment=", JSON.stringify(SaveCodec.snapshot(game.session).environment), "; overrides=", game.session.environment.light_source_overrides.size())
	print("P005 process %s: pid=%d; path=%s; location=%s; health=%d; time=%.1f; party=%s" % ["write" if write_phase else "read", OS.get_process_id(), ProjectSettings.globalize_path(game.save_repository.path), game.session.current_location_id, game.player_placeholder.state.health, game.session.elapsed_play_seconds, game.session.party_member_ids])
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P005 process %s: PASS" % ["write" if write_phase else "read"])
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
