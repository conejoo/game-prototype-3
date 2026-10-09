class_name FishingWaterTargetResolver
extends RefCounted
## Read-only semantic water + physical visibility query. No input, RNG or rewards.

class Result:
	extends RefCounted
	var status: String = "invalid"
	var reason: String = "invalid_context"
	var has_point: bool = false
	var surface_valid: bool = false
	var cell: Vector2i = Vector2i.ZERO
	var point: Vector3 = Vector3.ZERO
	var distance_m: float = 0.0
	var area_ids: PackedStringArray = []

	func snapshot() -> Dictionary:
		return {"status":status, "reason":reason, "has_point":has_point,
			"surface_valid":surface_valid, "cell":cell, "point":point,
			"distance_m":distance_m, "area_ids":area_ids.duplicate()}


static func from_pointer(location: Node3D, catalog: ContentCatalog, camera: Camera3D,
		pointer: Vector2, player_foot: Vector3, pointer_allowed: bool,
		rod: RodActivationDefinition) -> Result:
	if not pointer_allowed: return _invalid("ui_pointer")
	if not is_instance_valid(camera) or not camera.is_inside_tree() or not pointer.is_finite():
		return _invalid("invalid_ray")
	if camera.projection not in [Camera3D.PROJECTION_ORTHOGONAL, Camera3D.PROJECTION_PERSPECTIVE]:
		return _invalid("invalid_ray")
	if not camera.get_viewport().get_visible_rect().has_point(pointer): return _invalid("ui_pointer")
	return from_ray(location, catalog, camera.project_ray_origin(pointer),
		camera.project_ray_normal(pointer), camera.far, player_foot, rod)


static func from_ray(location: Node3D, catalog: ContentCatalog, origin: Vector3,
		direction: Vector3, maximum_distance: float, player_foot: Vector3,
		rod: RodActivationDefinition) -> Result:
	if not is_instance_valid(location) or not location.is_inside_tree() or not location is AlderwakeTerrainPreview:
		return _invalid("unsupported_location")
	var room: AlderwakeTerrainPreview = location as AlderwakeTerrainPreview
	if room.location_id != "prototype-alderwake": return _invalid("unsupported_location")
	if catalog == null or not catalog.initialized or rod == null or not rod.validation_errors().is_empty():
		return _invalid("invalid_context")
	if not origin.is_finite() or not direction.is_finite() or not player_foot.is_finite() or not is_finite(maximum_distance) or maximum_distance <= 0.0:
		return _invalid("invalid_ray")
	if direction.length_squared() < 0.000001: return _invalid("invalid_ray")
	var normal: Vector3 = direction.normalized()
	if normal.y >= -0.000001: return _invalid("invalid_ray")
	var water: MeshInstance3D = room.water_blockers.get_node_or_null("WaterVisuals/AuthoredWaterPreview") as MeshInstance3D
	if water == null or water.mesh == null: return _invalid("invalid_context")
	# Undisplaced authored mesh owns water elevation; floor and safety tops do not.
	var water_y: float = (water.global_transform * water.mesh.get_aabb().position).y
	var along: float = (water_y - origin.y) / normal.y
	if not is_finite(along) or along <= 0.0 or along > maximum_distance: return _invalid("invalid_ray")
	var raw: Vector3 = origin + normal * along
	var xz: Vector2 = Vector2(raw.x, raw.z)
	if not room.bounds.has_point(xz): return _invalid("out_of_bounds")
	var result: Result = Result.new()
	result.has_point = true
	var grid: float = rod.target_cell_size_m
	result.cell = Vector2i(floori((xz.x-room.bounds.position.x)/grid), floori((xz.y-room.bounds.position.y)/grid))
	var center: Vector2 = room.bounds.position + Vector2(result.cell)*grid + Vector2.ONE*grid/2.0
	result.point = Vector3(center.x, water_y, center.y)
	result.distance_m = Vector2(player_foot.x, player_foot.z).distance_to(center)
	if room.water_blockers.on_dock(xz) or room.water_blockers.on_dock(center) or room.crossings.bridge_rect.has_point(xz) or room.crossings.bridge_rect.has_point(center):
		result.reason = "dry_structure"
		return result
	if not room.water_blockers.water_cells.has(result.cell):
		result.reason = "dry_land"
		return result
	if result.distance_m > rod.maximum_range_m:
		result.reason = "out_of_range"
		return result
	# Only the water owner's known authored safety bodies may be excluded. The
	# future gate, cliffs, terrain, props and all other layer-1 solids remain.
	var excluded: Array[RID] = []
	var water_ids: PackedStringArray = []
	for record: Dictionary in room.water_blockers.records: water_ids.append(record.id)
	for child: Node in room.water_blockers.get_children():
		if child is StaticBody3D and child.get_meta("source_collider_id", "") in water_ids:
			excluded.append(child.get_rid())
	var space: PhysicsDirectSpaceState3D = room.get_world_3d().direct_space_state
	# Recheck both pointer hit and quantized center. Snapping cannot slip behind
	# a bank or a solid corner. A separate rod line handles player-side occlusion.
	for segment: Array in [[origin, raw], [origin, result.point], [player_foot+Vector3.UP, result.point]]:
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(segment[0], segment[1], 1, excluded)
		query.hit_from_inside = true
		if not space.intersect_ray(query).is_empty():
			result.reason = "solid_occlusion"
			return result
	var activity: FishingActivityResolver.Result = FishingActivityResolver.distribution(catalog, center, room.location_id)
	if activity.status not in ["eligible", "no_area"]: return _invalid("invalid_context")
	result.surface_valid = true
	result.status = activity.status
	result.reason = "open_water" if activity.status == "eligible" else "no_area"
	result.area_ids = activity.area_ids.duplicate()
	return result


static func _invalid(reason: String) -> Result:
	var result: Result = Result.new()
	result.reason = reason
	return result
