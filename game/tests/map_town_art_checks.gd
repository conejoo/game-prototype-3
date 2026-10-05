extends SceneTree
## M013 imported geometry, exact base outlines, shared modules and inert ownership.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var art: AlderwakeTownArt = location.town_art
	_check(location.build_errors.is_empty(), "Candidate art construction errors")
	_check(art.structure_ids.size() == 24 and art.mappings.size() == 16 and art.meshes.size() == 16, "Structure/kit inventory")
	var triangles: int = 0
	var base_samples: int = 0
	var definitions: Dictionary = {}
	for definition: Dictionary in location.layout.catalog_reference:
		definitions[definition.id] = definition
	for id: String in art.mappings:
		var mapping: Dictionary = art.mappings[id]
		var mesh: Mesh = art.meshes[mapping.mesh_name]
		_check(mesh.get_surface_count() == 1, "Single shared palette surface: " + id)
		var arrays: Array = mesh.surface_get_arrays(0)
		_check(not arrays[Mesh.ARRAY_COLOR].is_empty(), "Vertex palette missing: " + id)
		var material: StandardMaterial3D = mesh.surface_get_material(0)
		_check(material != null and material.vertex_color_use_as_albedo and material.albedo_texture == null and material.metallic == 0 and material.roughness > 0.85, "Portable matte palette: " + id)
		var bounds: AABB = mesh.get_aabb()
		_check(absf(bounds.end.y - float(mapping.height_m)) < 0.005, "Imported up-axis/height: " + id)
		triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
		if not mapping.has("definition_id"):
			continue
		_check(absf(bounds.position.y) < 0.001 and bounds.end.y < 3.5, "Building ground/overhead budget: " + id)
		var polygon: PackedVector2Array = AlderwakePropGrayboxes._outline(mapping.local_polygon_xz_m)
		for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			var point: Vector2 = Vector2(vertex.x, vertex.z)
			if absf(vertex.y) < 0.001:
				var nearest: float = INF
				for corner: Vector2 in polygon:
					nearest = minf(nearest, corner.distance_to(point))
				_check(nearest < 0.001, "Base vertex moved from exact catalog corner: " + id)
				base_samples += 1
			# Source skew polygons stay polygons. Roof/detail must not invade streets.
			if not Geometry2D.is_point_in_polygon(point, polygon):
				var nearest_edge: float = INF
				for index: int in range(polygon.size()):
					nearest_edge = minf(nearest_edge, Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()]).distance_to(point))
				_check(nearest_edge <= 0.02, "Art extends beyond physical footprint: " + id)
	var ids: Dictionary = {}
	var module_area: float = 0
	for record: Dictionary in location.town.prop_records:
		if definitions[record.definition_id].kind != "structure":
			continue
		var wrapper: Node3D = location.town.get_node(NodePath(record.id))
		_check(not ids.has(record.id) and art.structure_ids.has(record.id), "Missing/duplicate structure: " + record.id)
		ids[record.id] = true
		_check(wrapper.position.distance_to(Vector3(record.foot_xyz_m[0], record.foot_xyz_m[1], record.foot_xyz_m[2])) < 0.001 and is_equal_approx(wrapper.rotation.y, deg_to_rad(record.yaw_degrees)), "Structure foot/yaw changed: " + record.id)
		_check(wrapper.get_meta("town_art_source_id") == record.id and wrapper.has_node("Collision") == (record.collision != null), "Source ID/collision flag changed: " + record.id)
		var visual_root: Node3D = wrapper.get_node("VisualRoot")
		_check(visual_root.find_children("*", "CollisionObject3D", true, false).is_empty(), "Imported art owns physics: " + record.id)
		if not str(record.definition_id).begins_with("dock-"):
			_check(visual_root.get_child_count() == 1, "Old graybox duplicate: " + record.id)
			var visual: MeshInstance3D = visual_root.get_child(0)
			_check(visual.transform == Transform3D.IDENTITY and visual.mesh == art.meshes[art.mappings[record.definition_id].mesh_name], "Shared local-foot mesh changed: " + record.id)
			continue
		var expected_area: float = 0
		for rect: Rect2 in AlderwakeDockSurfaces.SURFACES[record.id]:
			expected_area += rect.get_area()
		var actual_area: float = 0
		for visual: MeshInstance3D in visual_root.get_children():
			var rect: Rect2 = visual.get_meta("world_rect_xz_m")
			actual_area += rect.get_area()
			var world_transform: Transform3D = wrapper.transform * visual.transform
			_check(world_transform.origin.distance_to(Vector3(rect.position.x, 0, rect.position.y)) < 0.001, "Dock module registration")
			_check(world_transform.basis.is_equal_approx(Basis.from_scale(Vector3(rect.size.x, 1, rect.size.y))), "Dock module scale/yaw")
			var covered: bool = false
			for approved: Rect2 in AlderwakeDockSurfaces.SURFACES[record.id]:
				covered = covered or approved.encloses(rect)
			_check(covered, "Dock art extends outside approved floor")
		_check(absf(actual_area - expected_area) < 0.001, "Missing/duplicate dock deck area")
		module_area += actual_area
	_check(absf(module_area - 48) < 0.001 and art.dock_rectangles.size() == 7, "Approved dock movement mask changed")
	_check(art.quay_cells == location.town.get_node("QuayArtPreview/VisualRoot").get_child_count(), "Quay art missing")
	_check(location.interactables().is_empty() and location.destination_id.is_empty() and location.town.portal_pads.size() == 6, "Inactive doors installed gameplay")
	var report: Dictionary = {"structures": ids.size(), "kit_meshes": art.meshes.size(), "kit_triangles": triangles, "exact_base_samples": base_samples, "dock_area_m2": module_area, "deck_modules": art.module_count, "quay_cells": art.quay_cells, "failures": failures}
	# Read-only navigation guide for subsequent ordinary-input rendered tour.
	var map: RID = location.get_world_3d().navigation_map
	for attempt: int in range(120):
		if NavigationServer3D.map_get_closest_point_owner(map, Vector3.ZERO) == location.navigation_region.get_rid():
			break
		await create_timer(0.01).timeout
	var goals: Dictionary[String, Vector3] = {"maris": Vector3(-7.5, 0, 11), "west-dock": Vector3(-18, 0, 18.25), "west-dock-back": Vector3(-18, 0, 13.5), "junction-dock": Vector3(-13, 0, 19.25), "junction-back": Vector3(-13, 0, 13.5), "east-dock": Vector3(-8, 0, 18.25), "east-back": Vector3(-6.5, 0, 13), "mill-school": Vector3(-16, 0, 2.75), "inn": Vector3(-7, 0, 3.75), "hall": Vector3(0, 0, -1.25), "alder-rise": Vector3(-4, 0, -11.25), "mayor": Vector3(4, 0, -7.25), "general-goods": Vector3(9, 0, 4.75), "woodland-home": Vector3(23, 0, 8.75), "control-shelter": Vector3(41, 0, 19.5), "quay-west": Vector3(26.5, 0, 27), "quay-east": Vector3(44.5, 0, 27)}
	var guide: Array[Dictionary] = []
	var previous: Vector3 = Vector3.ZERO
	for goal: String in goals:
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, previous, goals[goal], true)
		var points: Array = []
		for point: Vector3 in path:
			points.append([point.x, point.y, point.z])
		guide.append({"goal": goal, "path": points})
		previous = goals[goal]
	var guide_file: FileAccess = FileAccess.open(TestRunEvidence.path("tour-guide.json"), FileAccess.WRITE)
	guide_file.store_string(JSON.stringify(guide, "\t") + "\n")
	var file: FileAccess = FileAccess.open(TestRunEvidence.path("town-art-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	for failure: String in failures:
		push_error(failure)
	print("M013 town art report: ", JSON.stringify(report))
	print("M013 map_town_art_checks ", "PASS" if failures.is_empty() else "FAIL")
	game.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
