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


func ground_point(screen_point: Vector2, _height: float) -> Variant:
	# Tiny neighboring rays cover floating-point concave-triangle seams. Select
	# the nearest visible floor, never the underlying base through a ramp seam.
	var origin: Vector3 = camera.project_ray_origin(screen_point)
	var direction: Vector3 = camera.project_ray_normal(screen_point)
	var nearest: Variant = null
	var distance: float = INF
	for offset: Vector2 in [Vector2.ZERO, Vector2(0.02, 0.01), Vector2(-0.02, -0.01)]:
		var hit: Variant = _floor_ray(screen_point + offset)
		if hit != null:
			var along_ray: float = (hit as Vector3 - origin).dot(direction)
			if along_ray < distance:
				nearest = hit
				distance = along_ray
	return nearest


func _floor_ray(screen_point: Vector2) -> Variant:
	# Physics floors own aim height. Actor bodies and unmarked props/water/cliff
	# blockers cannot supply aim height; imported art has no physics role.
	var origin: Vector3 = camera.project_ray_origin(screen_point)
	var end: Vector3 = origin + camera.project_ray_normal(screen_point) * camera.far
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, 1)
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	for attempt: int in range(64):
		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty(): return null
		var body: CollisionObject3D = hit.collider as CollisionObject3D
		if body.get_meta("candidate_walkable_floor", false) or body.get_meta("aim_ground", false):
			if hit.normal.y < 0.9: return null
			# The solid base also exists beneath elevated cells. A ray entering
			# under a cliff side must not present that hidden support as ground.
			if body.get_meta("candidate_base_support", false) and not _base_is_exposed(hit.position): return null
			return hit.position
		var excluded: Array[RID] = query.exclude
		excluded.append(body.get_rid())
		query.exclude = excluded
	return null


func _base_is_exposed(point: Vector3) -> bool:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(point + Vector3.UP * 8, point + Vector3.UP * 0.01, 1)
	for attempt: int in range(64):
		var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty(): return true
		var body: CollisionObject3D = hit.collider as CollisionObject3D
		if body.get_meta("candidate_walkable_floor", false): return false
		var excluded: Array[RID] = query.exclude
		excluded.append(body.get_rid())
		query.exclude = excluded
	return false


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
