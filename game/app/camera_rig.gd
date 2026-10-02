class_name PrototypeCameraRig
extends Node3D
## Camera receives its target from the composition root.

@onready var camera: Camera3D = $Camera3D


func set_target(target: Node3D) -> void:
	global_position = target.global_position
	camera.look_at(target.global_position, Vector3.UP)
