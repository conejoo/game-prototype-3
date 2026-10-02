class_name PrototypeCameraRig
extends Node3D
## Camera receives its target from the composition root.

@onready var camera: Camera3D = $Camera3D
var target: Node3D
var zoom_factor: float = 1.0
const OFFSET: Vector3 = Vector3(10, 14, 16)
const DEFAULT_SIZE: float = 18.0


func _ready() -> void:
	# Follow after physics movement; aim updates after this rig's process.
	process_priority = -10
	set_orthographic(true)


func set_target(new_target: Node3D) -> void:
	target = new_target
	global_position = target.global_position
	camera.look_at(target.global_position, Vector3.UP)


func _process(_delta: float) -> void:
	if is_instance_valid(target):
		global_position = target.global_position


func movement_direction(axes: Vector2) -> Vector3:
	var right: Vector3 = camera.global_basis.x
	right.y = 0.0
	var back: Vector3 = camera.global_basis.z
	back.y = 0.0
	return right.normalized() * axes.x + back.normalized() * axes.y


func ground_point(screen_point: Vector2, height: float) -> Variant:
	return Plane(Vector3.UP, height).intersects_ray(
		camera.project_ray_origin(screen_point), camera.project_ray_normal(screen_point)
	)


func set_orthographic(enabled: bool) -> void:
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL if enabled else Camera3D.PROJECTION_PERSPECTIVE
	_apply_zoom()


func toggle_projection() -> void:
	set_orthographic(camera.projection != Camera3D.PROJECTION_ORTHOGONAL)


func zoom(steps: float) -> void:
	zoom_factor = clampf(zoom_factor - steps * 0.05, 0.8, 1.15)
	_apply_zoom()


func description() -> String:
	return "%s · zoom %.2f" % ["Orthographic" if camera.projection == Camera3D.PROJECTION_ORTHOGONAL else "Perspective 45°", zoom_factor]


func _apply_zoom() -> void:
	camera.position = OFFSET * zoom_factor
	camera.size = DEFAULT_SIZE * zoom_factor
	camera.fov = 45.0
	camera.look_at(global_position, Vector3.UP)
