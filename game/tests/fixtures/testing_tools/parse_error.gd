extends SceneTree
# Deliberate parser failure: runner must reject before executing any check.
func _initialize( -> void:
	quit(0)
