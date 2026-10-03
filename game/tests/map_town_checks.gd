extends SceneTree
## M006 synthetic geometry, queries and real capsule paths; rendered input separate.

var failures: PackedStringArray = []
var physics_probes: int = 0
var path_samples: int = 0
var walked_routes: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var town: AlderwakeTownFootprints = location.town
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	_check(town.build_errors.is_empty(), "Town failed construction")
	_check(town.prop_records.size() == 56 and town.collider_records.size() == 11 and town.footprints.size() == 55, "Town inventory mismatch")
	_check(town.portal_pads.size() == 6 and town.dock_decks.size() == 3, "Door/dock inventory mismatch")
	var ids: Dictionary = {}
	for record: Dictionary in town.prop_records:
		_check(not ids.has(record.id), "Duplicate prop wrapper: " + record.id)
		ids[record.id] = true
		var wrapper: Node3D = town.get_node(NodePath(record.id))
		_check(wrapper.get_meta("source_prop_id") == record.id and wrapper.get_meta("source") == record.source, "Lost prop provenance")
		_check(wrapper.position.distance_to(Vector3(record.foot_xyz_m[0], 0, record.foot_xyz_m[2])) < 0.001, "Rounded or misplaced prop foot: " + record.id)
		_check(is_equal_approx(wrapper.rotation.y, deg_to_rad(record.yaw_degrees)), "Rotation missing: " + record.id)
		_check(wrapper.has_node("Collision") == (record.collision != null), "Collision-enabled/none boundary: " + record.id)
		_check(wrapper.get_node("VisualRoot").find_children("*", "CollisionObject3D", true, false).is_empty(), "Art owns collision")
		if record.collision != null:
			_audit_polygon(space, wrapper, AlderwakeTownFootprints._outline(record.collision.vertices_xz_m))
	for record: Dictionary in town.collider_records:
		var r: Array = record.rect_xz_m
		var wrapper: Node3D = town.get_node(NodePath("collider--" + record.id))
		_check(wrapper.get_meta("source_collider_id") == record.id, "Lost authored collider identity")
		_audit_polygon(space, wrapper, AlderwakeTownFootprints._rectangle(Rect2(r[0], r[1], r[2], r[3])))
	_check(not town.has_node("moonwell-prop") and not town.has_node("dock-row-willow-tree-01"), "M007 props installed early")
	_check(location.interactables().is_empty() and location.destination_id.is_empty(), "Town installed gameplay/interiors")
	_check(town.get_node("market-lane-boulder-01").get_meta("collision_enabled") == false, "Disabled catalog collision changed")
	_check(town.get_node("passenger-control-shelter-01").get_meta("collision_enabled") == false, "Shelter baffles replaced with sprite box")
	# Independent grouped Chandlery measurement: (480,896)+(-90,-72,169,68).
	var chandlery: Node3D = town.get_node("reed-chandlery-exterior-building")
	_check(chandlery.position == Vector3(-7, 0, 10), "Chandlery group pivot conversion")
	_audit_polygon(space, chandlery, PackedVector2Array([Vector2(-9.8125, 7.75), Vector2(-4.53125, 7.75), Vector2(-4.53125, 9.875), Vector2(-9.8125, 9.875)]))
	await _rotation_fixtures(location, space)
	# Existing WorldHost validates both real party capsules/offsets on both pads.
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-start")).is_empty(), "Town start pad unsafe")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-from-tollworks")).is_empty(), "Forest return pad unsafe")
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	for point: Vector3 in [Vector3(-7.5, 0, 11), Vector3(-6, 0, 11.5), Vector3(-4.5, 0, 11.5)]:
		_check(_clear(space, capsule, point), "Maris/player/customer reserved clearance: " + str(point))
	# Normal navigation paths exercise town circulation without obstacle tops.
	var goals: Dictionary[String, Vector3] = town.portal_pads.duplicate()
	goals["maris"] = Vector3(-7.5, 0, 11)
	goals["fitting-player"] = Vector3(-6, 0, 11.5)
	goals["fitting-customer"] = Vector3(-4.5, 0, 11.5)
	goals["west-dock"] = Vector3(-18, 0, 18.25)
	goals["junction-dock"] = Vector3(-13, 0, 19.25)
	goals["east-dock"] = Vector3(-8, 0, 18.25)
	goals["nets-shore-approach"] = Vector3(16, 0, 12.75)
	goals["quay-north"] = Vector3(34, 0, 18.5)
	goals["quay-west"] = Vector3(26.5, 0, 27)
	goals["quay-east"] = Vector3(44.5, 0, 27)
	goals["control-approach"] = Vector3(41, 0, 19.5)
	# Unported homes have no authored door. Named side approaches avoid shoreline
	# water where no full capsule fits between a south-facing wall and the bank.
	for record: Dictionary in town.prop_records:
		if str(record.id).ends_with("building") and record.collision != null:
			goals["front:" + record.id] = Vector3(record.foot_xyz_m[0], 0, float(record.foot_xyz_m[2]) + 0.75)
	goals.erase("front:dock-row-net-shed-01-building")
	goals.erase("front:dock-row-net-shed-02-building")
	goals.erase("front:mill-road-home-03-building")
	goals["shed-west-side"] = Vector3(-7.1, 0, 14)
	goals["shed-east-side"] = Vector3(19.9, 0, 13.2)
	goals["mill-home-03-side"] = Vector3(-10.3, 0, 13)
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	game.companion.global_position = Vector3(120, 0, 55)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true # Shared non-player movement API guard, as other physics fixtures.
	var map: RID = location.get_world_3d().navigation_map
	for sync_attempt: int in range(120):
		if NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid():
			break
		await create_timer(0.01).timeout
	_check(NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid(), "Town nav did not synchronize")
	for id: String in goals:
		var goal: Vector3 = goals[id]
		_check(_clear(space, capsule, goal), "Town approach capsule blocked: " + id)
		for backwards: bool in [false, true]:
			var start: Vector3 = goal if backwards else Vector3.ZERO
			var end: Vector3 = Vector3.ZERO if backwards else goal
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, start, end, true)
			if id == "junction-dock":
				print("M006 junction path backwards=", backwards, " endpoint=", path[-1] if not path.is_empty() else Vector3.INF, " goal=", end)
			_check(path.size() >= 2, "Disconnected town approach: " + id)
			if path.size() < 2:
				continue
			_check(Vector2(path[-1].x - end.x, path[-1].z - end.z).length() < 0.3, "Approach snapped away from target: " + id)
			for index: int in range(1, path.size()):
				var count: int = ceili(path[index - 1].distance_to(path[index]) / 0.1)
				for sample: int in range(count + 1):
					var point: Vector3 = path[index - 1].lerp(path[index], float(sample) / maxf(count, 1))
					point.y = 0
					_check(_clear(space, capsule, point), "Unsafe town nav path: %s at %s" % [id, point])
					path_samples += 1
			# Actual shared hero movement, synthetic placement/manual stepping.
			hero.global_position = start
			hero.velocity = Vector3.ZERO
			hero.combat.cancel()
			await physics_frame
			for target: Vector3 in path:
				target.y = 0
				var stalled: int = 0
				for step: int in range(2400):
					var delta: Vector3 = target - hero.global_position
					delta.y = 0
					if delta.length() < 0.08:
						break
					hero.move_direction(delta.normalized())
					var previous: Vector3 = hero.global_position
					hero._physics_process(1.0 / 60.0)
					stalled = stalled + 1 if hero.global_position.distance_to(previous) < 0.001 else 0
					if stalled > 12:
						_check(false, "Synthetic path stalled: %s at %s" % [id, hero.global_position])
						break
				_check(absf(hero.global_position.y) < 0.05, "Town route lost grounding: " + id)
			_check(Vector2(hero.global_position.x - end.x, hero.global_position.z - end.z).length() < 0.3, "Physical town circulation snag: " + id)
			walked_routes += 1
		print("M006 circulation ", id, " bidirectional paths/walking")
	print("M006 inventory props=56 authored_colliders=11 blocking_footprints=55 inactive_pads=6 docks=3 physics_probes=", physics_probes, " path_samples=", path_samples, " physical_routes=", walked_routes)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M006 map_town_checks PASS: exact polygons, fractional/grouped/rotated fixtures, disabled/none collision, town/doors/service/quays/docks circulation, party pads, inactive gameplay; documented user-approved dock cutouts")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _rotation_fixtures(location: Node3D, space: PhysicsDirectSpaceState3D) -> void:
	# Hand-derived asymmetric 2x1 rectangle around fractional foot (10.25,50.5).
	# Clockwise source q1 is (-z,x); groups already flattened by M002 extractor.
	var expected: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(9.25, 48.5), Vector2(11.25, 48.5), Vector2(11.25, 49.5), Vector2(9.25, 49.5)]),
		PackedVector2Array([Vector2(12.25, 49.5), Vector2(12.25, 51.5), Vector2(11.25, 51.5), Vector2(11.25, 49.5)]),
		PackedVector2Array([Vector2(11.25, 52.5), Vector2(9.25, 52.5), Vector2(9.25, 51.5), Vector2(11.25, 51.5)]),
		PackedVector2Array([Vector2(8.25, 51.5), Vector2(8.25, 49.5), Vector2(9.25, 49.5), Vector2(9.25, 51.5)])]
	for q: int in range(4):
		var values: Array = []
		for point: Vector2 in expected[q]:
			values.append([point.x, point.y])
		var record: Dictionary = {"id": "fixture-building", "definition_id": "fixture", "foot_xyz_m": [10.25, 0, 50.5], "tree": null,
			"quarter_turns": q, "yaw_degrees": -90 * q, "collision_enabled": true,
			"collision": {"id": "fixture-box", "kind": "box", "vertices_xz_m": values}, "source": {"group_id": "rotated-fixture", "path": "fixture"}}
		var fixture: AlderwakeTownFootprints = AlderwakeTownFootprints.new()
		fixture.build({"props": [record], "catalog_reference": [{"id": "fixture", "kind": "structure", "label": "ROTATED TEST"}], "colliders": [], "art_layers": [], "portals": []})
		location.add_child(fixture)
		await physics_frame
		_audit_polygon(space, fixture.get_node("fixture-building"), expected[q])
		fixture.queue_free()
		await physics_frame
	# Concave footprint must keep notch empty, unlike a convex hull/bounding box.
	var concave: PackedVector2Array = PackedVector2Array([Vector2(10, 50), Vector2(13, 50), Vector2(13, 51), Vector2(11, 51), Vector2(11, 53), Vector2(10, 53)])
	var fixture: AlderwakeTownFootprints = AlderwakeTownFootprints.new()
	location.add_child(fixture)
	var wrapper: Node3D = fixture._wrapper("concave-fixture", Vector3.ZERO)
	fixture._add_prism(wrapper, "concave", concave, 1.0, true, Color.GRAY)
	await physics_frame
	_audit_polygon(space, wrapper, concave)
	fixture.queue_free()
	await physics_frame


func _audit_polygon(space: PhysicsDirectSpaceState3D, wrapper: Node3D, expected: PackedVector2Array) -> void:
	var body: StaticBody3D = wrapper.get_node("Collision")
	_check(body.collision_layer == 1 and body.collision_mask == 0, "Town physics layers")
	var found: Dictionary = {}
	for collider: CollisionShape3D in body.get_children():
		for local: Vector3 in (collider.shape as ConvexPolygonShape3D).points:
			var world: Vector3 = collider.global_transform * local
			var point: Vector2 = Vector2(world.x, world.z)
			var match_vertex: bool = false
			for index: int in range(expected.size()):
				if point.distance_to(expected[index]) < 0.001:
					found[index] = true
					match_vertex = true
			_check(match_vertex, "Collision vertex differs from exact source outline: " + str(wrapper.name))
	_check(found.size() == expected.size(), "Missing polygon corners: " + str(wrapper.name))
	var bounds: Rect2 = Rect2(expected[0], Vector2.ZERO)
	for point: Vector2 in expected:
		bounds = bounds.expand(point)
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 0.003
	for x: int in range(ceili((bounds.size.x + 0.2) * 10) + 1):
		for z: int in range(ceili((bounds.size.y + 0.2) * 10) + 1):
			var point: Vector2 = bounds.position - Vector2.ONE * 0.1 + Vector2(x, z) * 0.1
			var boundary: bool = false
			for index: int in range(expected.size()):
				boundary = boundary or Geometry2D.get_closest_point_to_segment(point, expected[index], expected[(index + 1) % expected.size()]).distance_to(point) < 0.012
			if boundary:
				continue
			var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
			query.shape = sphere
			query.transform.origin = Vector3(point.x, 0.3, point.y)
			query.collision_mask = 1
			var contact: bool = false
			for hit: Dictionary in space.intersect_shape(query, 32):
				contact = contact or hit.collider == body
			_check(contact == Geometry2D.is_point_in_polygon(point, expected), "Polygon filled outside/empty inside: %s %s" % [wrapper.name, point])
			physics_probes += 1


func _clear(space: PhysicsDirectSpaceState3D, capsule: CapsuleShape3D, feet: Vector3) -> bool:
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = feet + Vector3.UP * 0.82
	query.collision_mask = 1
	return space.intersect_shape(query).is_empty()


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
