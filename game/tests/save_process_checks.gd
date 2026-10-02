extends SceneTree
## Two separate OS processes. Synthetic health setup is explicitly test-only.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var write_phase: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.save_repository = SaveRepository.new("user://saves/p005-process-check.json")
	root.add_child(game)
	await game.world_host.transition_finished
	if write_phase:
		game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
		await game.world_host.transition_finished
		game._set_paused(true)
		game.session.actors[GameSession.PLAYER_INSTANCE_ID].health = 37
		game.session.elapsed_play_seconds = 42.5
		failures.append_array(game.save_run())
	else:
		_check(game.session.current_location_id == "prototype-alderwake" and game.player_placeholder.state.health == 100, "Reader inherited writer state before disk load")
		game._set_paused(true)
		failures.append_array(await game.load_run())
		_check(game.session.current_location_id == "prototype-tollworks" and game.session.current_spawn_id == "tollworks-from-alderwake", "Restart restored wrong arrival")
		_check(game.player_placeholder.state.health == 37 and game.session.elapsed_play_seconds == 42.5, "Restart lost health/time")
		_check(game.session.party_member_ids == PackedStringArray(["party-player"]) and game.party.members().size() == 1, "Restart lost party")
		_check(game.player_placeholder.global_position.distance_to(Vector3(0, 0, -2.5)) < 0.01, "Restart spawned outside safe anchor")
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
