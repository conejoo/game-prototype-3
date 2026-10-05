extends SceneTree
func _initialize() -> void:
	# Literal runtime-only load must be discovered before _initialize runs.
	load("res://tests/fixtures/testing_tools/parse_error.gd")
	quit(0)
