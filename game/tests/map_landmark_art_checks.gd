extends SceneTree
## M014 independent import/registration audit and art-swap physics/navigation invariant.
## Read-only guide supplies ordinary WASD tour; no gameplay state mutation in tour.

var failures: PackedStringArray = []
var vertex_samples: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var art: AlderwakeLandmarkArt = location.landmark_art
	_check(location.build_errors.is_empty(), "Candidate construction errors")
	_check(art.landmark_ids == PackedStringArray(["moonwood-footbridge", "moonwell-prop", "future-exit-gate-prop"]), "Landmark source inventory")
	_check(art.meshes.size() == 5 and art.mappings.size() == 5 and art.instance_count == 7, "Reusable kit inventory")
	var triangles: int = 0
	for id: String in art.mappings:
		var mapping: Dictionary = art.mappings[id]
		var mesh: Mesh = art.meshes[mapping.mesh_name]
		_check(mesh.get_surface_count() == 1, "Single palette surface: " + id)
		var arrays: Array = mesh.surface_get_arrays(0)
		_check(not arrays[Mesh.ARRAY_COLOR].is_empty(), "Missing vertex palette: " + id)
		var material: StandardMaterial3D = mesh.surface_get_material(0)
		_check(material != null and material.vertex_color_use_as_albedo and material.albedo_texture == null and material.metallic == 0 and material.roughness > 0.85, "Portable palette: " + id)
		triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
		var a: Array = mapping.bounds_xzy_m[0]
		var b: Array = mapping.bounds_xzy_m[1]
		var bounds: AABB = mesh.get_aabb()
		_check(bounds.position.distance_to(Vector3(a[0], a[2], a[1])) < 0.001 and bounds.end.distance_to(Vector3(b[0], b[2], b[1])) < 0.001, "Export axes/scale/bounds: " + id)
		for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			vertex_samples += 1
			if id == "moonwell":
				var polygon: PackedVector2Array = AlderwakePropGrayboxes._outline(mapping.local_polygon_xz_m)
				var point: Vector2 = Vector2(vertex.x, vertex.z)
				var nearest: float = INF
				for i: int in range(polygon.size()):
					nearest = minf(nearest, point.distance_to(Geometry2D.get_closest_point_to_segment(point, polygon[i], polygon[(i + 1) % polygon.size()])))
				_check(Geometry2D.is_point_in_polygon(point, polygon) or nearest <= 0.001, "Moonwell exceeds exact catalog footprint")
				_check(vertex.y >= -0.001 and vertex.y <= 0.601, "Moonwell overhead height")
			elif id.begins_with("bridge-"):
				var height_limit: float = 0.601 if id == "bridge-rail" else 0.03
				_check(vertex.y <= height_limit, "Bridge promises raised floor/rail: " + id)
	_check(triangles == 4276, "Kit topology inventory")
	var bridge: Node3D = location.crossings.get_node("moonwood-footbridge")
	var root_visual: Node3D = bridge.get_node("VisualRoot")
	_check(root_visual.get_child_count() == 5, "Bridge graybox duplicate or omitted part")
	for name_id: String in ["Deck", "WestLanding", "EastLanding", "NorthRail", "SouthRail"]:
		var visual: MeshInstance3D = root_visual.get_node(NodePath(name_id))
		var body: StaticBody3D = bridge.get_node(NodePath(name_id))
		var shape: BoxShape3D = body.get_child(0).shape
		var physical: AABB = AABB(body.position - shape.size / 2, shape.size)
		var render_bounds: AABB = visual.transform * visual.mesh.get_aabb()
		_check(absf(render_bounds.position.x - physical.position.x) <= 0.001 and absf(render_bounds.end.x - physical.end.x) <= 0.001 and absf(render_bounds.position.z - physical.position.z) <= 0.001 and absf(render_bounds.end.z - physical.end.z) <= 0.001, "Bridge art/physics horizontal mismatch: " + name_id)
		if name_id.ends_with("Rail"):
			_check(absf(render_bounds.end.y - physical.end.y) < 0.001 and is_equal_approx(shape.size.z, 0.1), "Rail height/width changed")
	_check(location.crossings.rail_rects == [Rect2(95, -2, 6, 0.1), Rect2(95, 0.9, 6, 0.1)], "2.8m usable width changed")
	var moonwell: Node3D = location.forest.get_node("moonwell-prop")
	var gate: Node3D = location.forest.get_node("future-exit-gate-prop")
	for wrapper: Node3D in [moonwell, gate]:
		var record: Dictionary = wrapper.get_meta("source_record")
		_check(wrapper.position.distance_to(Vector3(record.foot_xyz_m[0], record.foot_xyz_m[1], record.foot_xyz_m[2])) < 0.001 and is_equal_approx(wrapper.rotation.y, deg_to_rad(record.yaw_degrees)), "Source foot/yaw changed")
		_check(wrapper.get_meta("landmark_art_source_id") == record.id and wrapper.has_node("Collision") == (record.collision != null), "Source ID/flag changed")
	_check(moonwell.position.distance_to(Vector3(31.51317596435547, 0.5, 4.621034622192383)) < 0.001, "Moonwell fractional foot snapped")
	_check(moonwell.get_node("VisualRoot").get_child_count() == 1 and moonwell.get_node("VisualRoot/ImportedMoonwell").transform == Transform3D.IDENTITY, "Moonwell art local foot or graybox duplicate")
	_check(moonwell.get_node("Collision").get_child_count() == 6, "Moonwell octagon physics changed")
	var gate_visual: MeshInstance3D = gate.get_node("VisualRoot/ImportedClosedGate")
	var gate_world: AABB = gate.transform * gate_visual.transform * gate_visual.mesh.get_aabb()
	_check(gate_world.position.distance_to(Vector3(123, 0, -11)) < 0.001 and gate_world.end.distance_to(Vector3(125, 1.48, -3)) < 0.001, "Gate art differs from sole authored blocker")
	_check(gate.get_node("VisualRoot/ClosedTrailSign").text == "EAST TRAIL CLOSED\nNO DESTINATION", "Closed gate label")
	for visual_root: Node3D in [root_visual, moonwell.get_node("VisualRoot"), gate.get_node("VisualRoot")]:
		_check(visual_root.find_children("*", "CollisionObject3D", true, false).is_empty() and visual_root.find_children("*", "NavigationRegion3D", true, false).is_empty() and visual_root.find_children("*", "Area3D", true, false).is_empty(), "Art installs physics/navigation/interaction")
	var before: Array = _physics_signature(location)
	var nav: NavigationMesh = location.navigation_region.navigation_mesh
	var nav_hash: int = hash(nav.get_vertices())
	var nav_polygon_count: int = nav.get_polygon_count()
	var replacement: AlderwakeLandmarkArt = AlderwakeLandmarkArt.new()
	replacement.build(location.crossings, location.forest, location.layout)
	location.remove_child(art)
	art.free()
	location.landmark_art = replacement
	location.add_child(replacement)
	_check(replacement.build_errors.is_empty() and replacement.instance_count == 7, "Appearance replacement failed")
	_check(before == _physics_signature(location), "Art swap changed physical node/shape identity or transform")
	_check(nav == location.navigation_region.navigation_mesh and nav_hash == hash(nav.get_vertices()) and nav_polygon_count == nav.get_polygon_count(), "Art swap rebaked/mutated navigation")
	_check(location.interactables().is_empty() and location.destination_id.is_empty(), "Appearance activated gameplay")
	var report: Dictionary = {"landmarks": replacement.landmark_ids, "meshes": replacement.meshes.size(), "triangles": triangles, "vertex_samples": vertex_samples, "instances": replacement.instance_count, "physical_nodes_unchanged": before.size(), "nav_polygons_unchanged": nav_polygon_count, "nav_vertex_hash_unchanged": nav_hash, "failures": failures}
	var map: RID = location.get_world_3d().navigation_map
	for attempt: int in range(120):
		if NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid():
			break
		await create_timer(0.01).timeout
	var goals: Dictionary[String, Vector3] = {"moonwell": Vector3(31.51317596435547, 0.5, 5.25), "bridge-west": Vector3(93, 0, -0.5), "bridge-mid": Vector3(98, 0, -0.5), "bridge-east": Vector3(103, 0, -0.5), "bridge-back-mid": Vector3(98, 0, -0.5), "bridge-back-west": Vector3(93, 0, -0.5), "closed-east-gate": Vector3(121.5, 0, -7)}
	var guide: Array[Dictionary] = []
	var previous: Vector3 = Vector3.ZERO
	for goal: String in goals:
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, previous, goals[goal], true)
		_check(path.size() >= 2, "Missing tour route: " + goal)
		var points: Array = []
		for point: Vector3 in path:
			points.append([point.x, point.y, point.z])
		guide.append({"goal": goal, "path": points})
		previous = goals[goal]
	_write("tour-guide.json", guide)
	_write("landmark-art-report.json", report)
	for failure: String in failures:
		push_error(failure)
	print("M014 landmark art report: ", JSON.stringify(report))
	print("M014 map_landmark_art_checks ", "PASS" if failures.is_empty() else "FAIL")
	game.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


func _physics_signature(location: Node3D) -> Array:
	var result: Array = []
	for body: Node3D in location.find_children("*", "StaticBody3D", true, false):
		var shapes: Array = []
		for shape: CollisionShape3D in body.find_children("*", "CollisionShape3D", true, false):
			shapes.append([shape.get_instance_id(), shape.transform, shape.shape.get_rid()])
		result.append([body.get_instance_id(), body.transform, body.collision_layer, body.collision_mask, shapes])
	return result


func _write(name_id: String, data: Variant) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../docs/evidence/M014"))
	var file: FileAccess = FileAccess.open("res://../docs/evidence/M014/" + name_id, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t") + "\n")


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)