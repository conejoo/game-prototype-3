class_name ForagingPlacementGeometry
extends RefCounted
## Shared restore/live geometry gate. Rod lies along world X, length 0.9m.
const REACH: float = 1.5

static func validate(location: PrototypeLocation, placed: WorldItemPlacement) -> PackedStringArray:
	if location == null or not location.is_inside_tree() or location.location_id != placed.location_id or location.navigation_region == null or not location.navigation_region.enabled:
		return PackedStringArray(["placement room is not synchronized"])
	var foot: Vector3 = placed.foot
	if not foot.is_finite(): return PackedStringArray(["placement foot is not finite"])
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	# Include rod endpoints/corners with 0.05m length margin, not only centre.
	for offset: Vector3 in [Vector3.ZERO, Vector3(0.5,0,0), Vector3(-0.5,0,0), Vector3(0,0,0.22), Vector3(0,0,-0.22), Vector3(0.5,0,0.22), Vector3(-0.5,0,0.22), Vector3(0.5,0,-0.22), Vector3(-0.5,0,-0.22)]:
		var point: Vector3 = foot + offset
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.25, point - Vector3.UP * 0.25, 1))
		if hit.is_empty() or hit.normal.y < 0.9 or absf(hit.position.y - foot.y) > 0.06:
			return PackedStringArray(["placement lacks level supported floor"])
		var body: Node = hit.collider
		if not body.get_meta("candidate_walkable_floor", false) and not body.get_meta("aim_ground", false):
			return PackedStringArray(["placement is not dry walkable floor"])
	# Endpoint support rays cannot detect a tall narrow prop when starting inside
	# it. Test the rod's complete clearance volume separately from hero capsule.
	var footprint: BoxShape3D = BoxShape3D.new()
	footprint.size = Vector3(1.0,0.14,0.44)
	var footprint_query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	footprint_query.shape = footprint
	footprint_query.transform.origin = foot + Vector3.UP * 0.1
	footprint_query.collision_mask = 1
	if not space.intersect_shape(footprint_query).is_empty():
		return PackedStringArray(["placement rod footprint obstructed"])
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	var shape: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	shape.shape = capsule
	shape.transform.origin = foot + Vector3.UP * 0.82
	shape.collision_mask = 1
	if not space.intersect_shape(shape).is_empty():
		return PackedStringArray(["placement blocked or not retrievable"])
	for child: Node in location.get_node("Spawns").get_children():
		if child is SpawnAnchor and child.global_position.distance_to(foot) < 1.5:
			return PackedStringArray(["placement overlaps arrival reservation"])
	if location.has_node("TravelGate") and location.get_node("TravelGate").global_position.distance_to(foot) < 2.0:
		return PackedStringArray(["placement overlaps portal reservation"])
	var map: RID = location.get_world_3d().navigation_map
	var closest: Vector3 = NavigationServer3D.map_get_closest_point(map, foot)
	if closest.distance_to(foot) > 0.4 or NavigationServer3D.map_get_closest_point_owner(map, foot) != location.navigation_region.get_rid():
		return PackedStringArray(["placement outside reachable navigation"])
	var origin: SpawnAnchor = location.get_node("Spawns").get_child(0) as SpawnAnchor
	var path: PackedVector3Array = NavigationServer3D.map_get_path(map, origin.global_position, closest, true)
	if path.size() < 2 or path[-1].distance_to(closest) > 0.1:
		return PackedStringArray(["placement has no arrival route"])
	for index: int in range(path.size() - 1):
		var steps: int = maxi(1, ceili(path[index].distance_to(path[index + 1]) / 0.2))
		for step: int in range(steps + 1):
			var point: Vector3 = path[index].lerp(path[index + 1], float(step) / steps)
			if location is AlderwakeTerrainPreview:
				point.y = (location as AlderwakeTerrainPreview).elevation.height_at(Vector2(point.x, point.z))
			else:
				point.y = foot.y
			shape.transform.origin = point + Vector3.UP * 0.82
			if not space.intersect_shape(shape).is_empty():
				return PackedStringArray(["placement arrival route obstructed"])
	return []


static func validate_nearby(location: PrototypeLocation, placed: WorldItemPlacement, hero: ActorPlaceholder) -> PackedStringArray:
	if not placed.foot.is_finite() or not is_instance_valid(hero) or hero.global_position.distance_to(placed.foot) > REACH:
		return PackedStringArray(["placement is beyond nearby reach"])
	var errors: PackedStringArray = validate(location, placed)
	if not errors.is_empty(): return errors
	# An arrival route alone could travel around a river. Require a clear dry local
	# approach from the hero, without jumps across banks, height steps or props.
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	var steps: int = maxi(1, ceili(hero.global_position.distance_to(placed.foot) / 0.1))
	var previous_y: float = hero.global_position.y
	for step: int in range(steps + 1):
		var point: Vector3 = hero.global_position.lerp(placed.foot, float(step) / steps)
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.3, point - Vector3.UP * 0.3, 1))
		if hit.is_empty() or hit.normal.y < 0.9:
			return PackedStringArray(["placement approach unsupported or steep"])
		var body: Node = hit.collider
		if not body.get_meta("candidate_walkable_floor", false) and not body.get_meta("aim_ground", false):
			return PackedStringArray(["placement approach is not dry"])
		point.y = hit.position.y
		if absf(point.y - previous_y) > 0.1:
			return PackedStringArray(["placement approach crosses a step"])
		previous_y = point.y
		query.transform.origin = point + Vector3.UP * 0.82
		if not space.intersect_shape(query).is_empty():
			return PackedStringArray(["placement approach blocked"])
	var sight: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(hero.global_position + Vector3.UP * 0.8, placed.foot + Vector3.UP * 0.8, 1)
	if not space.intersect_ray(sight).is_empty():
		return PackedStringArray(["placement approach has no line of sight"])
	return []


static func nearby_drop(location: PrototypeLocation, hero: ActorPlaceholder) -> Variant:
	var facing: Vector3 = -hero.visual_root.global_basis.z
	facing.y = 0
	if facing.length_squared() < 0.01: facing = Vector3.FORWARD
	facing = facing.normalized()
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	for radius: float in [0.85,1.1,1.35]:
		for degrees: float in [0.0,45.0,-45.0,90.0,-90.0,135.0,-135.0,180.0]:
			var point: Vector3 = hero.global_position + facing.rotated(Vector3.UP,deg_to_rad(degrees)) * radius
			var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.3,point - Vector3.UP * 0.3,1))
			if hit.is_empty(): continue
			var candidate: WorldItemPlacement = WorldItemPlacement.new(ForagingRegistry.DROP_ID,location.location_id,hit.position,WorldItemPlacement.GENERATED)
			if validate_nearby(location,candidate,hero).is_empty(): return candidate.foot
	return null
