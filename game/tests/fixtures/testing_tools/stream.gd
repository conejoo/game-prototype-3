extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	print("LIVE_LOG_READY")
	await create_timer(6.0).timeout
	print("LIVE_LOG_FINISHED")
	quit(0)
