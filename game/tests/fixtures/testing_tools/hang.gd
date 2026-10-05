extends SceneTree
func _initialize() -> void:
	print("TESTING_FIXTURE=" + JSON.stringify({"pid":OS.get_process_id(), "user_data":OS.get_user_data_dir()}))
	# Intentional bounded-runner timeout: no game root or held input.
