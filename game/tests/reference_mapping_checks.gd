extends SceneTree
## F001 synthetic support/nav/capsule/LOS probes against production composition.
## Historical source geometry retained; runtime activation checked separately in F005.
var failures: PackedStringArray = []
var rows: Array[Dictionary] = []
var route_samples: int = 0
var room: AlderwakeTerrainPreview
var capsule: CapsuleShape3D = CapsuleShape3D.new()

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../docs/foraging-items-backpack/reference/behavior_vectors.json"))
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "Production startup failed")
	room = game.world_host.current_location
	game._set_paused(true)
	await physics_frame
	_check(room.location_id == "prototype-alderwake", "Wrong production location")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1, "F004 current schema/content")
	_check(SaveCodec.snapshot(game.session).inventory == {"item_counts":{}, "active_item_id":null}, "Fresh inventory empty; physical nodes inert")
	capsule.radius = 0.4
	capsule.height = 1.6
	var inert: Dictionary = {}
	for record: Dictionary in room.forest.inert_records:
		if record.kind == "resourceNode":
			inert[record.id] = record
	_check(inert.size() == 4, "Four inert resource records required")
	for node: Dictionary in vectors.nodes:
		var raw: Array = node.authored_foot_xyz_m
		var foot: Vector3 = Vector3(raw[0], raw[1], raw[2])
		var support: Dictionary = _floor(foot)
		_check(inert.has(node.instance_id) and inert[node.instance_id].foot_xyz_m == raw, "Mapped record changed: " + node.instance_id)
		_check(not support.is_empty(), "Unsupported node: " + node.instance_id)
		if support.is_empty():
			continue
		var runtime_foot: Vector3 = Vector3(foot.x, support.position.y, foot.z)
		var expected_blockers: Array = node.expected_geometry.blockers
		var actual_blockers: Array[String] = []
		for blocker: String in support.overhead_obstructions:
			actual_blockers.append(blocker.get_file())
		_check(actual_blockers == Array(expected_blockers, TYPE_STRING, "", null), "Geometry discrepancy changed: " + node.instance_id)
		var approach: Dictionary = _approach(runtime_foot, expected_blockers.is_empty())
		_check(not approach.is_empty(), "No nearby dry reachable approach: " + node.instance_id)
		var paths: Array = []
		if not approach.is_empty():
			for point: Vector3 in approach.path:
				paths.append(_plain(point))
		rows.append({
			"instance_id": node.instance_id, "source_resource_id": node.source_resource_id,
			"item_id": node.item_id, "resource_id": node.resource_id,
			"authored_foot_xyz_m": raw, "terrain_contract_height_m": room.elevation.height_at(Vector2(foot.x, foot.z)),
			"supported_foot_xyz_m": _plain(runtime_foot),
			"height_discrepancy_m": runtime_foot.y - foot.y,
			"support_collider": str(support.collider.get_path()),
			"support_normal": _plain(support.normal),
			"vertical_ray_obstructions": support.overhead_obstructions,
			"nearby_dry_approach_xyz_m": _plain(approach.point) if not approach.is_empty() else [],
			"approach_distance_m": approach.point.distance_to(runtime_foot) if not approach.is_empty() else -1,
			"los_blocker": approach.los_blocker if not approach.is_empty() else "",
			"authored_anchor_usable": expected_blockers.is_empty(),
			"reach_m": 1.5, "path_from_spawn": paths,
			"proof": "synthetic floor ray + dry nav + radius0.4 height1.6 capsule route; LOS measured, known anchor blockers retained; no ordinary input"
		})
		var runtime_target: PrototypeInteractable = room.foraging_pickups.targets.get(node.instance_id)
		_check(runtime_target != null and runtime_target.position == ForagingRegistry.find(node.instance_id).foot, "F005 runtime mapping missing")
	_check(TestRunEvidence.write_json("resource-mapping-report.json", {
		"task": "F001", "proof": "synthetic", "nodes": rows,
		"route_capsule_samples": route_samples, "failures": failures
	}), "Evidence write failed")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("F001 reference_mapping_checks ", "PASS" if failures.is_empty() else "FAILED", "; nodes=", rows.size(), "; route samples=", route_samples)
	quit(0 if failures.is_empty() else 1)

func _floor(point: Vector3) -> Dictionary:
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(point + Vector3.UP * 3.0, point - Vector3.UP * 1.0, 1)
	var obstructions: PackedStringArray = []
	for attempt: int in range(8):
		var hit: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(ray)
		if hit.is_empty():
			return {}
		if hit.collider.get_meta("candidate_walkable_floor", false) and hit.normal.y >= 0.9:
			hit["overhead_obstructions"] = obstructions
			return hit
		obstructions.append(str(hit.collider.get_path()))
		var excluded: Array[RID] = ray.exclude
		excluded.append(hit.rid)
		ray.exclude = excluded
	return {}

func _approach(foot: Vector3, require_usable_anchor: bool) -> Dictionary:
	var map: RID = room.get_world_3d().navigation_map
	for radius: float in [0.75, 1.0, 1.25, 1.45, 2.0, 2.5, 3.0]:
		if require_usable_anchor and radius > 1.5:
			continue
		for index: int in range(16):
			var angle: float = TAU * index / 16.0
			var point: Vector3 = foot + Vector3(cos(angle), 0, sin(angle)) * radius
			var support: Dictionary = _floor(point)
			if support.is_empty() or not support.overhead_obstructions.is_empty():
				continue
			point.y = support.position.y
			if (require_usable_anchor and point.distance_to(foot) > 1.5) or not _clear(point):
				continue
			var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.8, foot + Vector3.UP * 0.8, 1)
			var sight: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(ray)
			if require_usable_anchor and not sight.is_empty():
				continue
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, Vector3.ZERO, point, true)
			if path.size() < 2 or Vector2(path[-1].x - point.x, path[-1].z - point.z).length() > 0.3:
				continue
			if _route_clear(path):
				return {"point": point, "path": path, "los_blocker": str(sight.collider.get_path()) if not sight.is_empty() else ""}
	return {}

func _route_clear(path: PackedVector3Array) -> bool:
	for index: int in range(path.size() - 1):
		var count: int = ceili(path[index].distance_to(path[index + 1]) / 0.1)
		for step: int in range(count + 1):
			var point: Vector3 = path[index].lerp(path[index + 1], float(step) / maxi(1, count))
			point.y = room.elevation.height_at(Vector2(point.x, point.z))
			route_samples += 1
			if not _clear(point):
				return false
	return true

func _clear(foot: Vector3) -> bool:
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = foot + Vector3.UP * 0.82
	query.collision_mask = 1
	return room.get_world_3d().direct_space_state.intersect_shape(query).is_empty()

func _plain(point: Vector3) -> Array[float]:
	return [point.x, point.y, point.z]

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
