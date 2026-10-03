extends SceneTree
## M004 synthetic placements/sweeps; ordinary rendered input is separate evidence.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var water: AlderwakeWaterBlockers = location.water_blockers
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	var expected: int = 0
	for record: Dictionary in location.layout.colliders:
		if not (str(record.id).begins_with("moonwood-water-") or str(record.id).begins_with("south-water-") or record.id in ["passenger-basin-water-01", "future-exit-gate"]):
			continue
		expected += 1
		var body: StaticBody3D = water.get_node(str(record.id))
		var shape: BoxShape3D = body.get_child(0).shape
		var r: Array = record.rect_xz_m
		_check(body.get_meta("source_collider_id") == record.id, "Lost authored collider ID")
		_check(body.position.distance_to(Vector3(r[0] + r[2] / 2, 1.4, r[1] + r[3] / 2)) < 0.001, "Collider registration: " + str(record.id))
		_check(shape.size.distance_to(Vector3(r[2], 3.2, r[3])) < 0.001, "Collider extents: " + str(record.id))
	_check(water.records.size() + 1 == expected, "Water inventory mismatch")
	print("M004 exact authored blockers: ", expected, " (water=", water.records.size(), ") union cells=", water.water_cells.size())
	# Every occupied half-metre cell has real physics; every exposed edge gets
	# radius-aware motion sweeps at <=0.1m spacing, including tile/record seams.
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	var occupied: int = 0
	var sweep_count: int = 0
	for cell: Vector2i in water.water_cells:
		var center: Vector2 = location.bounds.position + Vector2(cell) * 0.5 + Vector2.ONE * 0.25
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(center.x, 4, center.y), Vector3(center.x, 0.8, center.y), 1))
		_check(not hit.is_empty() and hit.collider.get_parent() == water, "Water cell missing physics: " + str(cell))
		occupied += 1
		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if water.water_cells.has(cell + direction):
				continue
			var normal: Vector2 = Vector2(direction)
			var tangent: Vector2 = Vector2(-normal.y, normal.x)
			for offset: float in [-0.2, -0.1, 0.0, 0.1, 0.2]:
				var edge: Vector2 = center + normal * 0.25 + tangent * offset
				var start: Vector2 = edge + normal * 0.7
				var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
				query.shape = capsule
				query.transform = Transform3D(Basis.IDENTITY, Vector3(start.x, 0.82, start.y))
				query.collision_mask = 1
				if not location.bounds.has_point(start) or not space.intersect_shape(query).is_empty():
					continue # no dry actor approach at this concave corner/perimeter
				query.motion = Vector3(-normal.x, 0, -normal.y) * 1.4
				var fractions: PackedFloat32Array = space.cast_motion(query)
				_check(fractions[0] < 0.4, "Capsule sweep leaks exposed water edge: " + str(edge))
				sweep_count += 1
	_check(sweep_count > 1000, "Insufficient exposed-edge capsule coverage")
	print("M004 occupied cells=", occupied, " exposed-edge capsule sweeps=", sweep_count, " spacing<=0.1m")
	var nav_map: RID = location.get_world_3d().navigation_map
	await physics_frame
	await physics_frame
	await process_frame
	NavigationServer3D.map_force_update(nav_map)
	_check(NavigationServer3D.map_get_regions(nav_map).has(location.navigation_region.get_rid()), "Dry navigation region absent from server")
	var dry_start: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, Vector3.ZERO)
	_check(dry_start.distance_to(Vector3.ZERO) <= 0.3, "Provisional dry start not navigable")
	var dry_return: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, Vector3(107.25, 0, 1.25))
	_check(dry_return.distance_to(Vector3(107.25, 0, 1.25)) <= 0.3, "Provisional dry return not navigable")
	var minimum_water_nav_distance: float = INF
	for cell: Vector2i in water.water_cells:
		var center: Vector2 = location.bounds.position + Vector2(cell) * 0.5 + Vector2.ONE * 0.25
		var point: Vector3 = Vector3(center.x, 0, center.y)
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, point)
		minimum_water_nav_distance = minf(minimum_water_nav_distance, Vector2(closest.x, closest.z).distance_to(center))
		_check(Vector2(closest.x, closest.z).distance_to(center) >= 0.4 and absf(closest.y) <= 0.21, "Water union contains usable navigation: " + str(cell))
	print("M004 dry nav polygons=", location.navigation_region.navigation_mesh.get_polygon_count(), " water center min horizontal distance=", minimum_water_nav_distance, " dry start=", dry_start)
	for point: Vector3 in [Vector3(98.5, 0, -2.5), Vector3(98.5, 0, 1.5), Vector3(70.5, 0, 10.5), Vector3(70.5, 0, 14.5), Vector3(35, 0, 25), Vector3(-10, 0, 25), Vector3(114.5, 0, -15.5), Vector3(124.25, 0, -7)]:
		var closest: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, point)
		_check(Vector2(closest.x, closest.z).distance_to(Vector2(point.x, point.z)) >= 0.4, "Blocked point remained navigable: " + str(point))
		_check(absf(closest.y) <= 0.21, "Navigation baked blocker top")
	# Both authored three-metre openings remain empty, without deck/rail claims.
	for opening: Rect2 in [Rect2(95, -2, 8, 3), Rect2(67, 11, 7, 3)]:
		var z: float = opening.position.y + 0.4
		while z < opening.end.y - 0.39:
			var x: float = opening.position.x + 0.4
			while x < opening.end.x - 0.39:
				var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
				query.shape = capsule
				query.transform = Transform3D(Basis.IDENTITY, Vector3(x, 0.82, z))
				query.collision_mask = 1
				_check(space.intersect_shape(query).is_empty(), "Authored crossing opening blocked")
				x += 0.1
			z += 0.1
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-start")).is_empty(), "Start party pad unsafe")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-from-tollworks")).is_empty(), "Return party pad unsafe")
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true
	var cases: Array[Dictionary] = [
		{"id": "bridge-north", "start": Vector3(98.5, 0, -0.5), "dir": Vector3.FORWARD},
		{"id": "bridge-south", "start": Vector3(98.5, 0, -0.5), "dir": Vector3.BACK},
		{"id": "ford-north", "start": Vector3(70.5, 0, 12.5), "dir": Vector3.FORWARD},
		{"id": "ford-south", "start": Vector3(70.5, 0, 12.5), "dir": Vector3.BACK},
		{"id": "bridge-row-seam", "start": Vector3(96, 0, -3), "dir": Vector3.RIGHT},
		{"id": "ford-row-corner", "start": Vector3(67, 0, 13), "dir": Vector3(1, 0, 1).normalized()},
		{"id": "basin-west", "start": Vector3(26.5, 0, 25), "dir": Vector3.RIGHT},
		{"id": "lake-tip", "start": Vector3(114.5, 0, -17), "dir": Vector3.BACK},
		{"id": "south-shore", "start": Vector3(-10, 0, 13), "dir": Vector3.BACK},
		{"id": "water-perimeter-seam", "start": Vector3(-21.5, 0, 14), "dir": Vector3(-1, 0, 1).normalized()},
		{"id": "closed-east-gate", "start": Vector3(121.5, 0, -7), "dir": Vector3.RIGHT}]
	for test: Dictionary in cases:
		for dodge: bool in [false, true]:
			hero.global_position = test.start
			hero.velocity = Vector3.ZERO
			hero.combat.cancel()
			hero.move_direction(test.dir)
			await physics_frame
			if dodge:
				_check(hero.request_dodge(test.dir), "Fixture dodge rejected")
			var contacts: bool = false
			for step: int in range(90):
				var previous: Vector3 = hero.global_position
				hero._physics_process(1.0 / 60.0)
				contacts = contacts or hero.get_slide_collision_count() > 0
				_check(absf(hero.global_position.y) < 0.05, "Hero fell or climbed water/gate")
				# Inspect every <=0.1m point along real walk/dodge displacement.
				var samples: int = maxi(1, ceili(previous.distance_to(hero.global_position) / 0.1))
				for sample: int in range(samples + 1):
					var feet: Vector3 = previous.lerp(hero.global_position, float(sample) / samples)
					for record: Dictionary in water.records:
						var r: Array = record.rect_xz_m
						_check(not Rect2(r[0], r[1], r[2], r[3]).has_point(Vector2(feet.x, feet.z)), "Walking/dodge entered water: " + str(test.id))
			_check(contacts and hero.global_position.distance_to(test.start) < 3.0, "Hero passed blocker: " + str(test.id))
			_check(hero.global_position.x <= 124.66 and hero.global_position.x >= -21.66, "Hero escaped bounds")
			if test.id == "closed-east-gate":
				_check(hero.global_position.x <= 122.66, "Hero passed closed exit")
			print("M004 actual hero ", test.id, " dodge=", dodge, " feet=", hero.global_position)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M004 map_water_checks PASS: authored inventory/registration, water union, capsule edges/seams, four negative probes, actual walk/dodge, floor/bounds/gate, dry navigation, opening/party clearance")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
