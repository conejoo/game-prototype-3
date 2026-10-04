extends SceneTree
## M009 synthetic navigation/physics, budgets, transactional replacement tests.
## No normal save writes or production activation. Rendered input is separate.

var failures: PackedStringArray = []
var report: Dictionary = {"routes": {}, "negative_probes": [], "loads": [], "queries_usec": []}
var samples: int = 0
var game: Node3D
var location: AlderwakeTerrainPreview
var capsule: CapsuleShape3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var cold_started: int = Time.get_ticks_usec()
	game = load("res://tests/map_candidate.tscn").instantiate()
	var detached: ContentManifest = ContentManifest.new()
	detached.definitions.assign(game.content_manifest.definitions)
	for fixture: Dictionary in [{"id": "prototype-unsafe-location", "scene": "res://tests/fixtures/unsafe_location.tscn", "spawns": ["unsafe-no-floor", "unsafe-blocked"]},
		{"id": "candidate-nav-failure", "scene": "res://tests/fixtures/map_navigation_failure.tscn", "spawns": ["alderwake-start", "alderwake-from-tollworks"]}]:
		var definition: LocationDefinition = LocationDefinition.new()
		definition.stable_id = fixture.id
		definition.display_name = "M009 synthetic rejection fixture"
		definition.prototype_fixture = true
		definition.scene_path = fixture.scene
		definition.spawn_ids = PackedStringArray(fixture.spawns)
		detached.definitions.append(definition)
	game.content_manifest = detached
	root.add_child(game)
	var arrived: Array = await game.world_host.transition_finished
	_check(arrived[0], "Cold candidate arrival failed")
	location = game.world_host.current_location
	report["cold_arrival_ms"] = (Time.get_ticks_usec() - cold_started) / 1000.0
	report["navigation"] = location.navigation_report.duplicate()
	_check(float(location.navigation_report.generation_bake_ms) <= 5000, "Cold generation/bake exceeds 5 seconds")
	game.companion_ai.enabled = false
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	capsule = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	await _sync()
	var map: RID = location.get_world_3d().navigation_map
	var host: PrototypeWorldHost = game.world_host
	var original: PrototypeLocation = host.current_location
	var original_region: RID = original.navigation_region.get_rid()
	var transition_count: int = host.transition_count
	for fixture: Array in [["prototype-unsafe-location", "unsafe-no-floor"], ["prototype-unsafe-location", "unsafe-blocked"], ["candidate-nav-failure", "alderwake-start"]]:
		_check(host.request_transition(fixture[0], fixture[1]).is_empty(), "Rollback fixture failed to reach placement/bake")
		var rejected: Array = await host.transition_finished
		_check(not rejected[0] and not rejected[1].is_empty(), "Rollback fixture unexpectedly committed")
		_check(host.current_location == original and host.transition_count == transition_count, "Rollback replaced original exterior")
		_check(not game.party.suspended and host.get_child_count() == 1, "Rollback lost party/lifecycle")
		_check(NavigationServer3D.map_get_regions(map) == [original_region], "Rollback leaked failed navigation region")
		_check(NavigationServer3D.map_get_path(map, Vector3.ZERO, Vector3(31.51317596435547, 0.5, 5.25), true).size() >= 2, "Rollback lost exterior connectivity")
	report["rollback_rejections"] = 3
	var goals: Dictionary[String, Vector3] = {
		"bridge-west": Vector3(93, 0, -0.5), "bridge-east": Vector3(103, 0, -0.5),
		"ford-west": Vector3(66, 0, 12.5), "ford-east": Vector3(75, 0, 12.5),
		"moonwell-approach": Vector3(31.51317596435547, 0.5, 5.25),
		"tollworks-approach": Vector3(107.25, 0, -1.25),
		"return-pad": Vector3(107.25, 0, 1.25), "closed-exit-approach": Vector3(121.5, 0, -7),
		"maris-pad": Vector3(-6, 0, 11.5),
	}
	for id: String in goals:
		for reverse: bool in [false, true]:
			var start: Vector3 = goals[id] if reverse else Vector3.ZERO
			var end: Vector3 = Vector3.ZERO if reverse else goals[id]
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, start, end, true)
			_check(path.size() >= 2, "Disconnected route: " + id)
			if path.size() < 2:
				continue
			_check(Vector2(path[0].x - start.x, path[0].z - start.z).length() < 0.3, "Route start snapped: " + id)
			_check(Vector2(path[-1].x - end.x, path[-1].z - end.z).length() < 0.3, "Route end snapped: " + id)
			var length: float = _audit_path(path, id)
			_check(length <= (180.0 if id.begins_with("tollworks") else 200.0), "Route exceeds length budget: " + id)
			report.routes[id + ("-reverse" if reverse else "-forward")] = {"length_m": length, "path": _plain(path)}
	# Crossing endpoint paths must actually use their opening, in both directions.
	for id: String in ["bridge", "ford"]:
		for reverse: bool in [false, true]:
			var a: Vector3 = goals[id + ("-east" if reverse else "-west")]
			var b: Vector3 = goals[id + ("-west" if reverse else "-east")]
			var path: PackedVector3Array = NavigationServer3D.map_get_path(map, a, b, true)
			_check(path.size() >= 2 and _audit_path(path, id) < 15, "Crossing routed elsewhere: " + id)
			report.routes[id + ("-reverse" if reverse else "-forward")] = {"path": _plain(path)}
	for point: Vector3 in [Vector3(98.5, 0, -2.5), Vector3(98.5, 0, 1.5), Vector3(70.5, 0, 10.5), Vector3(70.5, 0, 14.5), Vector3(35, 0, 25), Vector3(-10, 0, 25), Vector3(114.5, 0, -15.5), Vector3(124.25, 0, -7)]:
		var nearest: Vector3 = NavigationServer3D.map_get_closest_point(map, point)
		var distance: float = Vector2(nearest.x - point.x, nearest.z - point.z).length()
		_check(distance >= 0.4, "Water/gate negative remained navigable: " + str(point))
		report.negative_probes.append({"point": [point.x, point.y, point.z], "nav_distance_m": distance})
	# Audit every nav polygon edge and centre, not only required funnel paths.
	var mesh: NavigationMesh = location.navigation_region.navigation_mesh
	var vertices: PackedVector3Array = mesh.get_vertices()
	var edge_counts: Dictionary[Vector2i, int] = {}
	for polygon_index: int in range(mesh.get_polygon_count()):
		var polygon: PackedInt32Array = mesh.get_polygon(polygon_index)
		var center: Vector3 = Vector3.ZERO
		for index: int in range(polygon.size()):
			var a: int = polygon[index]
			var b: int = polygon[(index + 1) % polygon.size()]
			var edge: Vector2i = Vector2i(mini(a, b), maxi(a, b))
			edge_counts[edge] = edge_counts.get(edge, 0) + 1
			_check(edge_counts[edge] <= 2, "Non-manifold nav edge: " + str(edge))
			center += vertices[polygon[index]]
			_audit_path(PackedVector3Array([vertices[polygon[index]], vertices[polygon[(index + 1) % polygon.size()]]]), "mesh")
		_safe(center / polygon.size(), "mesh-centre")
	for index: int in range(30):
		var keys: Array[String] = goals.keys()
		var started: int = Time.get_ticks_usec()
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, goals[keys[index % keys.size()]], goals[keys[(index + 4) % keys.size()]], true)
		report.queries_usec.append(Time.get_ticks_usec() - started)
		_check(path.size() >= 2, "Query benchmark disconnected")
	var times: Array = report.queries_usec.duplicate()
	times.sort()
	report["query_p95_usec"] = times[ceili(times.size() * 0.95) - 1]
	_check(int(report.query_p95_usec) <= 5000, "Path query p95 exceeds 5ms")
	await _lifecycle()
	report["samples"] = samples
	report["failures"] = failures
	var output: FileAccess = FileAccess.open("res://../docs/evidence/M009/navigation-report.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t") + "\n")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M009 map_navigation_checks ", "PASS" if failures.is_empty() else "FAILED", "; samples=", samples, "; query p95 us=", report.query_p95_usec, "; navigation=", report.navigation, "; loads=", report.loads)
	quit(0 if failures.is_empty() else 1)


func _sync() -> void:
	var map: RID = location.get_world_3d().navigation_map
	for attempt: int in range(120):
		await physics_frame
		NavigationServer3D.map_force_update(map)
		if NavigationServer3D.map_get_closest_point_owner(map, location.find_spawn("alderwake-start").global_position) == location.navigation_region.get_rid():
			return
	_check(false, "Candidate navigation failed to synchronize")


func _safe(point: Vector3, id: String) -> void:
	var ground: float = location.elevation.height_at(Vector2(point.x, point.z))
	_check(absf(point.y - ground) <= 0.16, "Phantom height: " + id + " " + str(point))
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = Vector3(point.x, ground + 0.82, point.z)
	query.collision_mask = 1
	var hits: Array[Dictionary] = location.get_world_3d().direct_space_state.intersect_shape(query)
	_check(hits.is_empty(), "Unsafe 0.4m navigation: " + id + " " + str(point) + (" " + str(hits[0].collider.name) if not hits.is_empty() else ""))
	samples += 1


func _audit_path(path: PackedVector3Array, id: String) -> float:
	var length: float = 0
	for index: int in range(1, path.size()):
		var distance: float = path[index - 1].distance_to(path[index])
		length += distance
		var count: int = maxi(1, ceili(distance / 0.1))
		for sample: int in range(count + 1):
			_safe(path[index - 1].lerp(path[index], float(sample) / count), id)
	return length


func _lifecycle() -> void:
	var host: PrototypeWorldHost = game.world_host
	var identities: Array[int] = [game.player_placeholder.get_instance_id(), game.companion.get_instance_id()]
	var map: RID = location.get_world_3d().navigation_map
	for trip: int in range(4):
		for destination: String in ["prototype-tollworks", "candidate-alderwake"]:
			var old_location: WeakRef = weakref(host.current_location)
			var old_region: RID = host.current_location.navigation_region.get_rid()
			var started: int = Time.get_ticks_usec()
			var spawn: String = "tollworks-from-alderwake" if destination == "prototype-tollworks" else "alderwake-from-tollworks"
			_check(host.request_transition(destination, spawn).is_empty(), "Lifecycle transition rejected")
			_check(game.party.suspended and host.transitioning, "Travel did not suspend party")
			_check(not host.request_transition(destination, spawn).is_empty(), "Repeated transition accepted")
			var result: Array = await host.transition_finished
			var elapsed_ms: float = (Time.get_ticks_usec() - started) / 1000.0
			_check(result[0], "Lifecycle arrival failed: " + str(result[1]))
			_check(NavigationServer3D.map_get_closest_point_owner(map, host.current_location.find_spawn(spawn).global_position) == host.current_location.navigation_region.get_rid(), "Navigation not synchronized at commit")
			if destination == "candidate-alderwake":
				location = host.current_location
				await _sync()
			else:
				await physics_frame
				NavigationServer3D.map_force_update(map)
				_check(host.current_location.destination_id == "prototype-alderwake" and host.current_location.destination_spawn_id == "alderwake-from-tollworks", "Tollworks return routing changed")
			_check(old_location.get_ref() == null, "Old location retained")
			_check(not old_region in NavigationServer3D.map_get_regions(map), "Old region retained")
			_check(NavigationServer3D.map_get_regions(map).size() == 1, "Stale/duplicate navigation regions")
			_check(host.get_child_count() == 1 and game.party.members().size() == 2, "Scene swap duplicated world/party")
			_check([game.player_placeholder.get_instance_id(), game.companion.get_instance_id()] == identities, "Party wrappers changed")
			_check(not game.party.suspended and host._placement_errors(host.current_location.find_spawn(spawn)).is_empty(), "Unsafe party arrival")
			report.loads.append({"trip": trip, "destination": destination, "request_to_commit_ms": elapsed_ms})
			_check(elapsed_ms <= 2000, "Warm request-to-commit exceeds 2s")


func _plain(path: PackedVector3Array) -> Array:
	var result: Array = []
	for point: Vector3 in path:
		result.append([point.x, point.y, point.z])
	return result


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
