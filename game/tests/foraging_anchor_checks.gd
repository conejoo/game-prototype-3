extends SceneTree
## F005 approved relocation safety; synthetic, not pickup/ordinary-route acceptance.
var failures: PackedStringArray = []
var rows: Array[Dictionary] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "production arrival")
	game._set_paused(true)
	await physics_frame
	var room: AlderwakeExterior = game.world_host.current_location as AlderwakeExterior
	_check(room != null, "production exterior")
	if room == null:
		game.queue_free()
		await process_frame
		quit(1)
		return
	var shapes: Array[CollisionShape3D] = []
	_collect_shapes(room, shapes)
	var expected: Dictionary = {
		"fishing-rod-dock-01": [],
		"moonflower-01": [],
		"moonflower-02": [], "moonflower-03": []
	}
	var approaches: Dictionary = {
		"fishing-rod-dock-01": Vector3(-6.5,0,15),
		"moonflower-01": Vector3(27.5,0.25,-2),
		"moonflower-02": Vector3(34.75,0.25,7),
		"moonflower-03": Vector3(30.75,0.5,-9)
	}
	for record: Dictionary in ForagingRegistry.entries():
		var foot: Vector3 = record.foot
		var placed: WorldItemPlacement = WorldItemPlacement.new(ForagingRegistry.ROD_ORIGIN, room.location_id, foot, WorldItemPlacement.AUTHORED)
		var geometry_errors: PackedStringArray = ForagingPlacementGeometry.validate(room, placed)
		_check(geometry_errors.is_empty(), "supported dry footprint/capsule/navigation/arrival route " + record.instance_id + ": " + str(geometry_errors))
		if record.instance_id == ForagingRegistry.ROD_ORIGIN:
			_check(AlderwakeDockSurfaces.cutouts().any(func(rect: Rect2) -> bool: return rect.has_point(Vector2(foot.x, foot.z))), "rod lies on existing dock")
		var sight: Vector3 = foot + Vector3.UP * 0.8
		var blockers: Array[String] = []
		var bounds: Array[Dictionary] = []
		for shape: CollisionShape3D in shapes:
			if shape.disabled or not shape.shape is BoxShape3D:
				continue
			var body: CollisionObject3D = shape.get_parent() as CollisionObject3D
			if body == null or body.collision_layer & 1 == 0 or body.get_meta("candidate_walkable_floor", false):
				continue
			var box: BoxShape3D = shape.shape as BoxShape3D
			var half: Vector3 = box.size / 2.0
			var local: Vector3 = shape.to_local(sight)
			if absf(local.x) <= half.x and absf(local.y) <= half.y and absf(local.z) <= half.z:
				var local_foot: Vector3 = shape.to_local(foot)
				_check(absf(local_foot.x) <= half.x and absf(local_foot.y) <= half.y and absf(local_foot.z) <= half.z, "authored foot containment " + record.instance_id)
				blockers.append(str(body.name))
				bounds.append({"body":str(body.get_path()), "shape_centre":_plain(shape.global_position), "size":_plain(box.size), "foot_local":_plain(shape.to_local(foot)), "sight_local":_plain(local)})
		blockers.sort()
		_check(blockers == Array(expected[record.instance_id], TYPE_STRING, "", null), "sight containment changed " + record.instance_id)
		var approach: Vector3 = approaches[record.instance_id]
		var hit: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(approach + Vector3.UP * 0.8, sight, 1))
		var los_name: String = str(hit.collider.name) if not hit.is_empty() else ""
		_check(los_name == "", "normal sight ray " + record.instance_id)
		var capsule: CapsuleShape3D = CapsuleShape3D.new()
		capsule.radius = 0.4
		capsule.height = 1.6
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform.origin = approach + Vector3.UP * 0.82
		query.collision_mask = 1
		_check(room.get_world_3d().direct_space_state.intersect_shape(query).is_empty(), "nearby approach capsule " + record.instance_id)
		_check(approach.distance_to(foot) <= 1.5, "nearby approach range " + record.instance_id)
		rows.append({"instance_id":record.instance_id, "authored_foot_xyz_m":_plain(record.authored_foot), "foot_xyz_m":_plain(foot), "geometry_errors":geometry_errors, "sight_xyz_m":_plain(sight), "containing_blockers":blockers, "bounds":bounds, "approach_xyz_m":_plain(approach), "los_blocker":los_name})
	_check(TestRunEvidence.write_json("anchor-relocation-report.json", {"task":"F005", "proof":"synthetic production geometry; no interaction or ordinary walking proof", "nodes":rows, "blocked_task":false, "failures":failures}), "report write")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("F005 foraging_anchor_checks ", "PASS" if failures.is_empty() else "FAILED", "; safe runtime anchor geometry only; nodes=", rows.size())
	quit(0 if failures.is_empty() else 1)

func _collect_shapes(parent: Node, result: Array[CollisionShape3D]) -> void:
	for child: Node in parent.get_children():
		if child is CollisionShape3D:
			result.append(child as CollisionShape3D)
		_collect_shapes(child, result)

func _plain(value: Vector3) -> Array[float]:
	return [value.x,value.y,value.z]

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
