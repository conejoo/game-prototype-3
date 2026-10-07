class_name ForagingPlacementGeometry
extends RefCounted
## Conservative restore gate against actual synchronized collision and navigation.
## F007 may refine search/preview; unsafe saved facts never reach live session.

static func validate(location: PrototypeLocation, placed: WorldItemPlacement) -> PackedStringArray:
	if location.location_id != placed.location_id or location.navigation_region == null:
		return PackedStringArray(["placement room is not synchronized"])
	var foot: Vector3 = placed.foot
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	# Small rod footprint must all lie on supported dry floor at saved height.
	for offset: Vector3 in [Vector3.ZERO, Vector3(0.22,0,0), Vector3(-0.22,0,0), Vector3(0,0,0.22), Vector3(0,0,-0.22)]:
		var point: Vector3 = foot + offset
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.25, point - Vector3.UP * 0.25, 1))
		if hit.is_empty() or hit.normal.y < 0.9 or absf(hit.position.y - foot.y) > 0.06:
			return PackedStringArray(["placement lacks level supported floor"])
		var body: Node = hit.collider
		if not body.get_meta("candidate_walkable_floor", false) and not body.get_meta("aim_ground", false):
			return PackedStringArray(["placement is not dry walkable floor"])
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
