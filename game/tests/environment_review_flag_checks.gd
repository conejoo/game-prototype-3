extends SceneTree
## Child launched by W008 lifecycle checks with the actual review CLI flag.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	var ok: bool = paused and game.session.review_only and game.environment_review != null and game.environment_review_namespace == "w008-cli" and game.save_repository.path == "user://environment-review/w008-cli/disabled.json"
	ok = ok and game.ui.time_label.text == "11:12 AM\nClear" and not game.ui.resume_button.disabled and game.ui.save_button.disabled and game.ui.load_button.disabled
	print("W008 actual CLI flag %s pid=%d user_data=%s" % ["PASS" if ok else "FAIL", OS.get_process_id(), OS.get_user_data_dir()])
	game.queue_free()
	await process_frame
	paused = false
	quit(0 if ok else 1)
