extends SceneTree
## M011 mesh/mask registration; actual appearance requires separate captures.

var failures: PackedStringArray = []
var terrain_quads: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	_check(location.build_errors.is_empty(), "Landscape failed construction")
	var ground: Dictionary[Vector2i, int] = {}
	for mesh: MeshInstance3D in location.get_node("TerrainVisuals").get_children():
		_check(mesh.material_override is ShaderMaterial, "Diagnostic material retained: " + mesh.name)
		var vertices: PackedVector3Array = mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		var lift: float = 0.003 if mesh.name == "ground--grass" else (0.009 if str(mesh.name).begins_with("shoreline") else (0.012 if str(mesh.name).begins_with("decorations") else 0.006))
		for i: int in range(0, vertices.size(), 6):
			var a: Vector3 = vertices[i]
			var c: Vector3 = vertices[i + 2]
			var center: Vector2 = Vector2((a.x + c.x) / 2, (a.z + c.z) / 2)
			var cell: Vector2i = Vector2i(floori(center.x + 22), floori(center.y + 18))
			for vertex: Vector3 in vertices.slice(i, i + 6):
				_check(absf(vertex.y - location.elevation.cell_height(cell, Vector2(vertex.x, vertex.z)) - lift) < 0.0001, "Render surface height differs from physical cell")
			if mesh.name == "ground--grass":
				var half_cell: Vector2i = Vector2i(roundi((a.x + 22) * 2), roundi((a.z + 18) * 2))
				# Ground row runs are tessellated per physical metre, covering 2x1
				# half-metre samples without gaps or duplicate coplanar ground.
				for z: int in range(half_cell.y, roundi((c.z + 18) * 2)):
					for x: int in range(half_cell.x, roundi((c.x + 22) * 2)):
						var key: Vector2i = Vector2i(x, z)
						ground[key] = ground.get(key, 0) + 1
			terrain_quads += 1
	_check(ground.size() == 47040, "Default grass lost full extent")
	for count: int in ground.values():
		_check(count == 1, "Default grass overlap/crack")
	var water_mesh: MeshInstance3D = location.water_blockers.get_node("WaterVisuals/AuthoredWaterPreview")
	_check(water_mesh.material_override is ShaderMaterial, "Water preview material retained")
	_check(water_mesh.material_override.shader == AlderwakeLandscapeMaterials.WATER_SHADER, "Water flow shader missing")
	var water_vertices: PackedVector3Array = water_mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var painted_water: Dictionary[Vector2i, int] = {}
	for i: int in range(0, water_vertices.size(), 6):
		var a: Vector3 = water_vertices[i]
		var c: Vector3 = water_vertices[i + 2]
		_check(absf(a.y - 0.015) < 0.0001 and absf(c.y - 0.015) < 0.0001, "Water plane displaced")
		for z: int in range(roundi((a.z + 18) * 2), roundi((c.z + 18) * 2)):
			for x: int in range(roundi((a.x + 22) * 2), roundi((c.x + 22) * 2)):
				var cell: Vector2i = Vector2i(x, z)
				painted_water[cell] = painted_water.get(cell, 0) + 1
	_check(painted_water.size() == 8598, "Water visible union area changed")
	var overrides: Dictionary[Vector2i, Variant] = {}
	for record: Dictionary in location.layout.tile_layers[1].cells:
		overrides[Vector2i(record.cell[0], record.cell[1])] = record.paint
	for z: int in range(160):
		for x: int in range(294):
			var cell: Vector2i = Vector2i(x, z)
			var wet: bool = location.water_blockers.water_cells.has(cell)
			_check(painted_water.get(cell, 0) == (1 if wet else 0), "Water art contradicts effective physics occupancy")
			var mask: Color = location.landscape.mask_image.get_pixelv(cell)
			_check((mask.a > 0.5) == wet, "Bank mask disagrees with collision")
			var paint: Variant = overrides.get(cell)
			var material_kind: int = 1 if paint == null or paint.material == "water" else AlderwakeLandscapeMaterials.KINDS[paint.material]
			_check(roundi(mask.r * 255) == material_kind, "Path/sand/cobble mask registration differs")
	# Dry crossing/dock rectangles must not be rendered wet, even where source
	# water paint is present. This uses actual emitted mesh, not shader metadata.
	for rect: Rect2 in [location.crossings.bridge_rect, location.crossings.ford_rect] + location.water_blockers.dock_cutouts:
		for z: float in range(roundi(rect.position.y * 2), roundi(rect.end.y * 2)):
			for x: float in range(roundi(rect.position.x * 2), roundi(rect.end.x * 2)):
				_check(not painted_water.has(Vector2i(roundi(x + 44), roundi(z + 36))), "Water covers crossing/dock deck")
	var render_routes: Dictionary = {}
	var nav_map: RID = location.get_world_3d().navigation_map
	for pair: Array in [["bridge-to-tollworks", Vector3(103, 0.05, -0.5), Vector3(107.25, 0.05, -1.25)], ["tollworks-to-exit", Vector3(107.25, 0.05, -1.25), Vector3(121.5, 0.05, -7)]]:
		var path: PackedVector3Array = NavigationServer3D.map_get_path(nav_map, pair[1], pair[2], true)
		_check(path.size() >= 2 and path[-1].distance_to(pair[2]) < 0.1, "Rendered tour destination disconnected")
		var plain: Array = []
		for point: Vector3 in path:
			plain.append([point.x, point.y, point.z])
		render_routes[pair[0]] = {"path": plain}
	var report: Dictionary = {"terrain_quads": terrain_quads, "default_grass_samples": ground.size(), "semantic_samples": 47040, "water_samples": painted_water.size(), "terrain_batches": location.batch_count, "water_y_m": 0.015, "render_routes": render_routes, "failures": failures}
	var file: FileAccess = FileAccess.open("res://../docs/evidence/M011/landscape-report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("M011 landscape report: ", JSON.stringify(report))
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M011 map_landscape_checks ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
