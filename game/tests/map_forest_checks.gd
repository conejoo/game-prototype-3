extends SceneTree
## M007 synthetic inventory, physical polygons and real capsule route walking.
## Rendered ordinary-input evidence is separate; this test places actors directly.

var failures: PackedStringArray = []
var physics_probes: int = 0
var path_samples: int = 0
var walked_routes: int = 0
var route_report: Dictionary = {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var forest: AlderwakeForestPopulation = location.forest
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	_check(forest.build_errors.is_empty(), "Forest construction failed")
	_check(forest.prop_records.size() == 412 and forest.footprints.size() == 411, "Forest prop/footprint inventory")
	_check(forest.species_counts == {"alder": 70, "birch": 37, "cherry": 22, "maple": 36, "oak": 38, "pine": 48, "rowan": 36, "spruce": 60, "willow": 48}, "Tree species inventory")
	_check(forest.size_counts == {"small": 65, "standard": 266, "large": 64}, "Tree size inventory")
	_check(forest.marker_records.size() == 6 and forest.inert_records.size() == 85, "Marker/inert inventory")
	var ids: Dictionary = {}
	var collision_ids: Dictionary = {}
	for population: AlderwakePropGrayboxes in [location.town, forest]:
		for wrapper: Node in population.get_children():
			if not wrapper.has_meta("source_prop_id"):
				continue
			var id: String = wrapper.get_meta("source_prop_id")
			_check(not ids.has(id), "Duplicate prop: " + id)
			ids[id] = true
			if wrapper.has_node("Collision"):
				var collision_id: String = wrapper.get_node("Collision").get_meta("source_collision_id")
				_check(not collision_ids.has(collision_id), "Duplicate catalog collision: " + collision_id)
				collision_ids[collision_id] = true
	_check(ids.size() == 468 and collision_ids.size() == 455, "Whole-map exact prop/collision inventory")
	for record: Dictionary in forest.prop_records:
		var wrapper: Node3D = forest.get_node(NodePath(record.id))
		_check(wrapper.position.distance_to(Vector3(record.foot_xyz_m[0], 0, record.foot_xyz_m[2])) < 0.001, "Rounded prop foot: " + record.id)
		for field: String in ["definition_id", "source", "quarter_turns", "collision_enabled", "tree", "foot_xyz_m", "light_source_states", "render_depth_offset_units"]:
			_check((wrapper.get_meta(field) if wrapper.has_meta(field) else null) == record[field], "Lost metadata: %s %s" % [record.id, field])
		_check(wrapper.get_meta("source_record") == record, "Lost full source record")
		_check(is_equal_approx(wrapper.rotation.y, deg_to_rad(record.yaw_degrees)), "Lost prop rotation")
		_check(wrapper.has_node("Collision") == (record.collision != null), "Collision none/disabled changed: " + record.id)
		_check(wrapper.get_node("VisualRoot").find_children("*", "CollisionObject3D", true, false).is_empty(), "Art owns forest physics")
		if record.collision != null:
			_audit_polygon(space, wrapper, AlderwakePropGrayboxes._outline(record.collision.vertices_xz_m))
	var moonwell: Node3D = forest.get_node("moonwell-prop")
	_check(moonwell.position.distance_to(Vector3(31.51317596435547, 0, 4.621034622192383)) < 0.001, "Moonwell fractional foot")
	_check(moonwell.get_node("Collision").get_child_count() == 6, "Moonwell eight-corner polygon replaced")
	_check(not forest.get_node("future-exit-gate-prop").has_node("Collision"), "Duplicate gate catalog blocker")
	_check(location.water_blockers.get_node("future-exit-gate").get_meta("source_rect_xz_m") == Rect2(123, -11, 2, 8), "Authored gate changed")
	var authored_ids: Dictionary = {}
	for body: Node in location.find_children("*", "Node3D", true, false):
		if body.has_meta("source_collider_id"):
			var id: String = body.get_meta("source_collider_id")
			_check(not authored_ids.has(id), "Duplicate authored collider: " + id)
			authored_ids[id] = true
	_check(authored_ids.size() == 102, "Missing authored collider")
	for marker: Dictionary in forest.marker_records:
		var wrapper: Node3D = forest.get_node(NodePath(marker.id))
		_check(wrapper.get_meta("source_record") == marker and not wrapper.get_meta("runtime_enabled"), "Marker provenance/runtime changed")
		_check(wrapper.find_children("*", "CollisionObject3D", true, false).is_empty(), "Inert marker blocks")
	for record: Dictionary in forest.inert_records:
		_check(not record.runtime_enabled and not forest.has_node(NodePath(record.id)), "Inert routine/resource/NPC installed behavior")
	_check(location.interactables().is_empty() and location.destination_id.is_empty(), "Forest installed gameplay destination")
	_check(forest.get_node("tollworks-entrance-01").position == Vector3(107.25, 0, -1.25), "Entrance marker conversion")
	_check(not forest.get_node("tollworks-entrance-01").get_meta("runtime_enabled"), "Entrance activated early")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-start")).is_empty(), "Start pad regressed")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-from-tollworks")).is_empty(), "Return pad regressed")
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	game.companion.global_position = Vector3(120, 0, 55)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	var goals: Dictionary[String, Vector3] = {
		"bridge-west": Vector3(93, 0, -0.5), "bridge-east": Vector3(103, 0, -0.5),
		"ford-west": Vector3(66, 0, 12.5), "ford-east": Vector3(75, 0, 12.5),
		"moonwell-approach": Vector3(31.51317596435547, 0, 5.621034622192383),
		"tollworks-approach": Vector3(107.25, 0, -1.25),
		"return-pad": Vector3(107.25, 0, 1.25), "closed-exit-approach": Vector3(121.5, 0, -7),
	}
	var map: RID = location.get_world_3d().navigation_map
	await physics_frame
	await physics_frame
	await process_frame
	NavigationServer3D.map_force_update(map)
	# Full population increases the asynchronous server iteration cost. Wait
	# for this region to become queryable; do not count an empty stale map.
	for sync_attempt: int in range(120):
		if NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid():
			break
		await create_timer(0.01).timeout
	_check(NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid(), "Provisional nav did not synchronize")
	print("M007 nav map=", map, " regions=", NavigationServer3D.map_get_regions(map), " region map=", NavigationServer3D.region_get_map(location.navigation_region.get_rid()), " polygons=", location.navigation_region.navigation_mesh.get_polygon_count(), " closest start=", NavigationServer3D.map_get_closest_point(map, Vector3.ZERO), " iteration=", NavigationServer3D.map_get_iteration_id(map))
	print("M007 nav active=", NavigationServer3D.map_is_active(map), " enabled=", NavigationServer3D.region_get_enabled(location.navigation_region.get_rid()), " layers=", NavigationServer3D.region_get_navigation_layers(location.navigation_region.get_rid()), " region closest=", NavigationServer3D.region_get_closest_point(location.navigation_region.get_rid(), Vector3.ZERO), " mesh vertices=", location.navigation_region.navigation_mesh.get_vertices().size())
	for id: String in goals:
		var goal: Vector3 = goals[id]
		_check(_clear(space, capsule, goal), "Approach blocked: " + id)
		for backwards: bool in [false, true]:
			var start: Vector3 = goal if backwards else Vector3.ZERO
			var end: Vector3 = Vector3.ZERO if backwards else goal
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, start, end, true)
			_check(path.size() >= 2, "Approach disconnected: " + id)
			if path.size() < 2:
				continue
			_check(Vector2(path[-1].x - end.x, path[-1].z - end.z).length() < 0.3, "Approach snapped: " + id)
			var length: float = 0.0
			for index: int in range(1, path.size()):
				length += path[index - 1].distance_to(path[index])
				var count: int = ceili(path[index - 1].distance_to(path[index]) / 0.1)
				for sample: int in range(count + 1):
					var point: Vector3 = path[index - 1].lerp(path[index], float(sample) / maxf(count, 1))
					point.y = 0
					_check(_clear(space, capsule, point), "Unsafe forest path: %s at %s" % [id, point])
					path_samples += 1
			hero.global_position = start
			hero.velocity = Vector3.ZERO
			hero.combat.cancel()
			await physics_frame
			for target: Vector3 in path:
				target.y = 0
				var stalled: int = 0
				for step: int in range(3000):
					var delta: Vector3 = target - hero.global_position
					delta.y = 0
					if delta.length() < 0.08:
						break
					hero.move_direction(delta.normalized())
					var previous: Vector3 = hero.global_position
					hero._physics_process(1.0 / 60.0)
					stalled = stalled + 1 if hero.global_position.distance_to(previous) < 0.001 else 0
					if stalled > 12:
						_check(false, "Physical forest path stalled: %s at %s" % [id, hero.global_position])
						break
				_check(absf(hero.global_position.y) < 0.05, "Forest lost grounding")
			_check(Vector2(hero.global_position.x - end.x, hero.global_position.z - end.z).length() < 0.3, "Physical approach snag: " + id)
			walked_routes += 1
			route_report[id + ("-reverse" if backwards else "-forward")] = {"length_m": length, "path": _plain_path(path)}
		print("M007 reachable/walked bidirectional: ", id)
	# Gate is interior to bounds: walking and dodge must contact its real body.
	_check(not _clear(space, capsule, Vector3(124.25, 0, -7)), "Beyond-gate probe became clear")
	# Gate spans X123..125 up to the eastern perimeter; no safe eastern actor
	# start exists. Do not place a synthetic hero inside the gate to test reverse.
	for dodge: bool in [false, true]:
		hero.global_position = Vector3(121.5, 0, -7)
		hero.velocity = Vector3.ZERO
		hero.combat.cancel()
		var direction: Vector3 = Vector3.RIGHT
		hero.move_direction(direction)
		await physics_frame
		if dodge:
			_check(hero.request_dodge(direction), "Gate dodge fixture rejected")
		var gate_contact: bool = false
		for step: int in range(70):
			hero._physics_process(1.0 / 60.0)
			for index: int in range(hero.get_slide_collision_count()):
				gate_contact = gate_contact or hero.get_slide_collision(index).get_collider() == location.water_blockers.get_node("future-exit-gate")
		_check(gate_contact, "Gate negative never contacted authored body")
		_check(hero.global_position.x < 123, "Gate opened")
	var report: Dictionary = {"props": ids.size(), "catalog_collisions": collision_ids.size(), "authored_colliders": authored_ids.size(), "forest_props": forest.prop_records.size(), "species": forest.species_counts, "sizes": forest.size_counts, "physics_probes": physics_probes, "path_samples": path_samples, "walked_routes": walked_routes, "routes": route_report, "failures": failures}
	var output: FileAccess = FileAccess.open("res://../docs/evidence/M007/physics-report.json", FileAccess.WRITE)
	if output != null:
		output.store_string(JSON.stringify(report, "\t") + "\n")
	print("M007 counts: ", JSON.stringify(report.duplicate().merged({"routes": "see physics-report.json"}, true)))
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M007 map_forest_checks PASS: pinned inventory/metadata, exact trunk/Moonwell polygons, single closed gate, inactive records, bidirectional physical approach routes and safe party pads")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _plain_path(path: PackedVector3Array) -> Array:
	var result: Array = []
	for point: Vector3 in path:
		result.append([point.x, point.y, point.z])
	return result


func _audit_polygon(space: PhysicsDirectSpaceState3D, wrapper: Node3D, expected: PackedVector2Array) -> void:
	var body: StaticBody3D = wrapper.get_node("Collision")
	_check(body.collision_layer == 1 and body.collision_mask == 0, "Prop physics layers")
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
