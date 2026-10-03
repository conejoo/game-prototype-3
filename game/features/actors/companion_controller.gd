class_name CompanionController
extends Node
## Transient follow/fight/return AI. Session owns health; root supplies actors.

var actor: ActorPlaceholder
var hero: ActorPlaceholder
var enemy: ActorPlaceholder
var enabled: bool = false
var mode: String = "follow"
var repaths: int = 0
var catchups: int = 0
var recoveries: int = 0
var route: PackedVector3Array = []
var _route_index: int = 0
var _repath_left: float = 0.0
var _stuck_seconds: float = 0.0
var _recovery_seconds: float = 0.0
var _last_position: Vector3


func reset_route() -> void:
	route.clear()
	_route_index = 0
	_repath_left = 0.0
	_stuck_seconds = 0.0
	_recovery_seconds = 0.0
	_last_position = actor.global_position
	actor.clear_input()
	actor.combat.cancel()


func in_combat() -> bool:
	return is_instance_valid(enemy) and enemy.state.health > 0 and (enemy.global_position.distance_to(hero.global_position) < 5.0 or enemy.global_position.distance_to(actor.global_position) < 5.0)


func _physics_process(delta: float) -> void:
	if not enabled or hero.state.health <= 0:
		actor.move_direction(Vector3.ZERO)
		return
	if actor.state.health == 0:
		mode = "incapacitated"
		_recovery_seconds = 0.0 if in_combat() else _recovery_seconds + delta
		if _recovery_seconds >= 3.0 and _safe_place():
			actor.state.health = actor.state.max_health
			actor.initialize(actor.state)
			recoveries += 1
			reset_route()
		return
	_recovery_seconds = 0.0
	var hero_distance: float = actor.global_position.distance_to(hero.global_position)
	var fight: bool = in_combat() and hero_distance < 6.0 and enemy.state.health > 0
	mode = "fight" if fight else ("return" if hero_distance > 3.0 else "follow")
	var destination: Vector3 = enemy.global_position if fight else hero.global_position
	var distance: float = actor.global_position.distance_to(destination)
	if actor.combat.busy():
		actor.move_direction(Vector3.ZERO)
		return
	if fight and distance < 1.7:
		actor.move_direction(Vector3.ZERO)
		actor.face_direction(destination - actor.global_position)
		actor.request_attack()
		_stuck_seconds = 0.0
		return
	if not fight and distance < 1.6:
		actor.move_direction(Vector3.ZERO)
		_stuck_seconds = 0.0
		return
	_repath_left -= delta
	if _repath_left <= 0.0:
		var map: RID = actor.get_world_3d().navigation_map
		route = NavigationServer3D.map_get_path(map, actor.global_position, destination, true)
		_route_index = 1 if route.size() > 1 else 0
		_repath_left = 0.4
		repaths += 1
	while _route_index < route.size() and _flat(route[_route_index] - actor.global_position).length() < 0.25:
		_route_index += 1
	var direction: Vector3 = _flat(route[_route_index] - actor.global_position).normalized() if _route_index < route.size() else Vector3.ZERO
	actor.move_direction(direction)
	actor.face_direction(direction)
	_stuck_seconds = _stuck_seconds + delta if actor.global_position.distance_to(_last_position) < delta * 0.3 else 0.0
	_last_position = actor.global_position
	# Never teleport or heal through an active encounter. Retry path first.
	if not in_combat() and (_stuck_seconds >= 2.5 or hero_distance > 8.0):
		if _safe_place():
			catchups += 1
			reset_route()


func _safe_place() -> bool:
	var map: RID = actor.get_world_3d().navigation_map
	var space: PhysicsDirectSpaceState3D = actor.get_world_3d().direct_space_state
	var collider: CollisionShape3D = actor.get_node("CollisionShape3D")
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		var wanted: Vector3 = hero.global_position + Vector3(cos(angle), 0, sin(angle)) * 1.8
		var point: Vector3 = NavigationServer3D.map_get_closest_point(map, wanted)
		if _flat(point - wanted).length() > 0.4 or absf(point.y - hero.global_position.y) > 0.35:
			continue
		var floor_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.4, point + Vector3.DOWN * 0.4, 1)
		var floor_hit: Dictionary = space.intersect_ray(floor_query)
		if floor_hit.is_empty() or (floor_hit.normal as Vector3).y < 0.9:
			continue
		point = floor_hit.position
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = collider.shape
		query.transform = Transform3D(Basis.IDENTITY, point + collider.position + Vector3.UP * 0.02)
		query.collision_mask = 3
		query.exclude = [actor.get_rid()]
		if not space.intersect_shape(query).is_empty():
			continue
		var sight: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.3, hero.global_position + Vector3.UP * 0.3, 1)
		if not space.intersect_ray(sight).is_empty():
			continue
		actor.global_position = point
		actor.reset_physics_interpolation()
		return true
	return false


func _flat(direction: Vector3) -> Vector3:
	return Vector3(direction.x, 0, direction.z)
