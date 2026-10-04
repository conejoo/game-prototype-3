extends SceneTree
## Audit imported geometry/materials and each actual instance against pinned data.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	if DisplayServer.get_name() == "headless":
		push_error("Use windowed Compatibility renderer: dummy renderer does not retain MultiMesh instance transforms")
		game.free()
		quit(1)
		return
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	await process_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var art: AlderwakeTreeArt = location.tree_art
	_check(art.build_errors.is_empty(), "Tree art construction errors")
	_check(art.tree_ids.size() == 395 and art.mappings.size() == 21 and art.meshes.size() == 21, "Tree/variant/import inventory")
	_check(art.find_children("*", "CollisionObject3D", true, false).is_empty(), "Tree art added physics")
	var ids: Dictionary = {}
	var triangles: int = 0
	for definition: String in art.mappings:
		var mapping: Dictionary = art.mappings[definition]
		var mesh: Mesh = art.meshes[mapping.mesh_name]
		_check(mesh.get_surface_count() == 1, "Tree mesh surface count: " + definition)
		var arrays: Array = mesh.surface_get_arrays(0)
		_check(not arrays[Mesh.ARRAY_COLOR].is_empty(), "Portable vertex colors missing: " + definition)
		var material: ShaderMaterial = mesh.surface_get_material(0)
		_check(material != null and material.shader == AlderwakeTreeArt.VISIBILITY_SHADER and arrays[Mesh.ARRAY_COLOR].size() > 0, "Tree palette import missing: " + definition)
		_check(float(material.get_shader_parameter("surface_roughness")) > 0.85, "Tree material not matte: " + definition)
		var bounds: AABB = mesh.get_aabb()
		_check(absf(bounds.position.y) < 0.001 and absf(bounds.end.y - float(mapping.height_m)) < 0.005, "Tree up-axis/height mismatch: " + definition)
		_check(bounds.size.y >= 2.5 and bounds.size.y <= 4.3, "Tree overhead height budget: " + definition)
		triangles += arrays[Mesh.ARRAY_INDEX].size() / 3
	for record: Dictionary in location.forest.prop_records:
		if record.tree == null:
			continue
		var wrapper: Node3D = location.forest.get_node(NodePath(record.id))
		var key: String = wrapper.get_meta("tree_art_batch")
		var index: int = wrapper.get_meta("tree_art_index")
		var batch: MultiMeshInstance3D = art.batches[key]
		var transform: Transform3D = batch.transform * batch.multimesh.get_instance_transform(index)
		_check(transform.origin.distance_to(wrapper.position) < 0.001 and transform.basis.is_equal_approx(wrapper.transform.basis), "Batched foot/yaw changed: " + record.id)
		_check(wrapper.get_meta("source_record") == record and wrapper.has_node("Collision") == (record.collision != null), "Source collision/metadata changed: " + record.id)
		_check(wrapper.get_node("VisualRoot").get_child_count() == 0, "Duplicate old tree visuals: " + record.id)
		_check(not ids.has(key + ":" + str(index)), "Duplicate batch index")
		ids[key + ":" + str(index)] = record.id
		var mapping: Dictionary = art.mappings[record.definition_id]
		# Imported bole vertices at Y0 must span the exact source catalog box.
		var arrays: Array = batch.multimesh.mesh.surface_get_arrays(0)
		var base: PackedVector2Array = []
		for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
			if absf(vertex.y) < 0.001:
				var point: Vector3 = transform * vertex
				base.append(Vector2(point.x, point.z))
		var physical: PackedVector2Array = AlderwakePropGrayboxes._outline(record.collision.vertices_xz_m)
		var physical_rect: Rect2 = Rect2(physical[0], Vector2.ZERO)
		var art_rect: Rect2 = Rect2(base[0], Vector2.ZERO)
		for point: Vector2 in physical:
			physical_rect = physical_rect.expand(point)
		for point: Vector2 in base:
			art_rect = art_rect.expand(point)
		# Octagonal bole root corners are inset, preserving source bbox extents.
		_check(art_rect.position.distance_to(physical_rect.position) < 0.10 and art_rect.end.distance_to(physical_rect.end) < 0.10, "Trunk visual/collision disagreement: " + record.id)
		_check(mapping.species == record.tree.species and mapping.size == record.tree.size, "Tree identity lost")
	var report: Dictionary = {"trees": ids.size(), "variants": art.mappings.size(), "batches": art.batches.size(), "kit_triangles": triangles, "failures": failures}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../docs/evidence/M012"))
	var file: FileAccess = FileAccess.open("res://../docs/evidence/M012/tree-report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("M012 tree report: ", JSON.stringify(report))
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M012 map_tree_art_checks ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
