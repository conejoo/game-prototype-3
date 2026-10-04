class_name AlderwakeTerrainPreview
extends PrototypeLocation
## Isolated source-derived landscape with independent physical elevation/props.

const LAYOUT_PATH: String = "res://content/maps/alderwake_layout.json"
const COLORS: Dictionary[String, Color] = {
	"grass": Color(0.29, 0.43, 0.25),
	"dirt": Color(0.47, 0.32, 0.20),
	"sand": Color(0.73, 0.64, 0.42),
	"cobblestone": Color(0.47, 0.49, 0.49),
	"water": Color(0.27, 0.39, 0.47),
	"wet_shoreline": Color(0.41, 0.43, 0.32),
	"raw-marker": Color(0.70, 0.75, 0.52),
}
var layout: Dictionary = {}
var build_errors: PackedStringArray = []
var preview_report: Dictionary = {}
var bounds: Rect2
var batch_count: int = 0
var water_blockers: AlderwakeWaterBlockers
var crossings: AlderwakeCrossings
var town: AlderwakeTownFootprints
var forest: AlderwakeForestPopulation
var elevation: AlderwakeElevationSurfaces
var construction_usec: int = 0
var navigation_report: Dictionary = {}
var landscape: AlderwakeLandscapeMaterials
var tree_art: AlderwakeTreeArt
var town_art: AlderwakeTownArt
var landmark_art: AlderwakeLandmarkArt


func _init() -> void:
	var started: int = Time.get_ticks_usec()
	location_id = "candidate-alderwake"
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(LAYOUT_PATH)) != OK or not parser.data is Dictionary:
		build_errors.append("candidate layout JSON unavailable or malformed")
		return
	layout = parser.data
	if layout.get("schema_version") != 1 or not layout.get("candidate_only", false):
		build_errors.append("candidate requires pinned layout schema 1")
		return
	var values: Array = layout.coordinates.bounds_xz_m
	bounds = Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
	elevation = AlderwakeElevationSurfaces.new()
	elevation.build(layout)
	add_child(elevation)
	water_blockers = AlderwakeWaterBlockers.new()
	water_blockers.build(layout, bounds, AlderwakeDockSurfaces.cutouts())
	add_child(water_blockers)
	landscape = AlderwakeLandscapeMaterials.new()
	landscape.build(layout, water_blockers, bounds)
	water_blockers.get_node("WaterVisuals/AuthoredWaterPreview").material_override = landscape.river()
	var visuals: Node3D = Node3D.new()
	visuals.name = "TerrainVisuals"
	add_child(visuals)
	var layer_index: int = 0
	for value: Variant in layout.tile_layers:
		var layer: Dictionary = value
		var resolved: Dictionary = resolve_layer(layer)
		preview_report[layer.id] = {"visible": layer.visible, "cell_size_m": layer.cell_size_m,
			"counts": resolved.counts, "rectangle_count": resolved.rectangles.size()}
		if layer.visible:
			_build_layer(visuals, layer.id, resolved.rectangles, 0.003 * (layer_index + 1))
		layer_index += 1
	var center: Vector2 = bounds.get_center()
	# Retain the continuous zero-level support beneath the height surface. It
	# avoids concave-triangle seam recovery at floor/perimeter dodge contacts.
	_add_box("BaseFloor", Vector3(center.x, -0.2, center.y), Vector3(bounds.size.x, 0.4, bounds.size.y), false)
	# Outside-facing wall surfaces coincide with the logical map boundary.
	_add_box("BoundaryWest", Vector3(bounds.position.x - 0.2, 1.5, center.y), Vector3(0.4, 3.0, bounds.size.y + 0.8))
	_add_box("BoundaryEast", Vector3(bounds.end.x + 0.2, 1.5, center.y), Vector3(0.4, 3.0, bounds.size.y + 0.8))
	_add_box("BoundaryNorth", Vector3(center.x, 1.5, bounds.position.y - 0.2), Vector3(bounds.size.x + 0.8, 3.0, 0.4))
	_add_box("BoundarySouth", Vector3(center.x, 1.5, bounds.end.y + 0.2), Vector3(bounds.size.x + 0.8, 3.0, 0.4))
	crossings = AlderwakeCrossings.new()
	crossings.build(layout)
	add_child(crossings)
	build_errors.append_array(crossings.build_errors)
	town = AlderwakeTownFootprints.new()
	town.elevation = elevation
	town.build(layout)
	add_child(town)
	build_errors.append_array(town.build_errors)
	town_art = AlderwakeTownArt.new()
	town_art.build(town, layout)
	add_child(town_art)
	build_errors.append_array(town_art.build_errors)
	forest = AlderwakeForestPopulation.new()
	forest.elevation = elevation
	forest.build(layout)
	add_child(forest)
	build_errors.append_array(forest.build_errors)
	tree_art = AlderwakeTreeArt.new()
	tree_art.build(forest)
	add_child(tree_art)
	build_errors.append_array(tree_art.build_errors)
	landmark_art = AlderwakeLandmarkArt.new()
	landmark_art.build(crossings, forest, layout)
	add_child(landmark_art)
	build_errors.append_array(landmark_art.build_errors)
	var spawns: Node3D = Node3D.new()
	spawns.name = "Spawns"
	add_child(spawns)
	_add_spawn(spawns, "alderwake-start", Vector3(float(layout.spawn_xyz_m[0]), 0, float(layout.spawn_xyz_m[2])))
	_add_spawn(spawns, "alderwake-from-tollworks", Vector3(107.25, 0, 1.25))
	preview_report["water"] = {"authored_records": water_blockers.records.size(), "authored_half_metre_cells": water_blockers.authored_water_cells.size(), "union_half_metre_cells": water_blockers.water_cells.size(), "dock_cutout_count": water_blockers.dock_cutouts.size(), "closed_exit": true}
	preview_report["crossings"] = {"bridge_rect": str(crossings.bridge_rect), "ford_rect": str(crossings.ford_rect), "bridge_clear_width_m": 2.8, "floor_y_m": 0.0}
	preview_report["town"] = {"props": town.prop_records.size(), "authored_colliders": town.collider_records.size(), "blocking_footprints": town.footprints.size(), "inert_portal_pads": town.portal_pads.size()}
	preview_report["forest"] = {"props": forest.prop_records.size(), "species": forest.species_counts, "sizes": forest.size_counts, "blocking_footprints": forest.footprints.size(), "markers": forest.marker_records.size(), "inert_data_records": forest.inert_records.size()}
	preview_report["elevation"] = {"cells": elevation.levels.size(), "ramps": elevation.slopes.size(), "cliffs": elevation.cliffs.size(), "height_per_level_m": 0.25}
	preview_report["landscape"] = {"semantic_mask_size": [294, 160], "world_space_materials": true, "water_vertex_motion": false, "runtime_source_images_reused": 0}
	preview_report["tree_art"] = {"tree_ids": tree_art.tree_ids.size(), "kit_variants": tree_art.mappings.size(), "spatial_batches": tree_art.batches.size(), "chunk_size_m": AlderwakeTreeArt.CHUNK_SIZE}
	preview_report["town_art"] = {"structure_ids": town_art.structure_ids.size(), "kit_meshes": town_art.mappings.size(), "deck_modules": town_art.module_count, "quay_cells": town_art.quay_cells}
	preview_report["landmark_art"] = {"landmark_ids": landmark_art.landmark_ids, "kit_meshes": landmark_art.mappings.size(), "instances": landmark_art.instance_count}
	preview_report["limits"] = "M014 landmark/town/tree/landscape art; all portals/interactions inactive. Routines/resources/NPCs/zones/activities retained data only."
	construction_usec = Time.get_ticks_usec() - started


func resolve_layer(layer: Dictionary) -> Dictionary:
	# Resolve each layer independently: explicit null suppresses its default only.
	# Runs merge adjacent identical paint keys, never across layers or grid sizes.
	var size: float = float(layer.cell_size_m)
	var origin_values: Array = layer.origin_xz_m
	var origin: Vector2 = Vector2(float(origin_values[0]), float(origin_values[1]))
	var width: int = roundi(bounds.size.x / size)
	var depth: int = roundi(bounds.size.y / size)
	var overrides: Dictionary = {}
	for value: Variant in layer.cells:
		var record: Dictionary = value
		overrides[Vector2i(int(record.cell[0]), int(record.cell[1]))] = record.paint
	var rectangles: Array[Dictionary] = []
	var counts: Dictionary = {}
	for z: int in range(depth):
		var x: int = 0
		while x < width:
			var key: String = paint_key(overrides.get(Vector2i(x, z), layer.default_paint))
			var run: int = 1
			# Raw references retain individual 1m placement markers.
			if not key.begins_with("raw:"):
				while x + run < width and paint_key(overrides.get(Vector2i(x + run, z), layer.default_paint)) == key:
					run += 1
			if not key.is_empty():
				counts[key] = int(counts.get(key, 0)) + run
				var rect: Rect2 = Rect2(origin + Vector2(x * size, z * size), Vector2(run * size, size))
				if key.begins_with("raw:"):
					rect = Rect2(rect.get_center() - Vector2.ONE * 0.06, Vector2.ONE * 0.12)
				rectangles.append({"key": key, "rect": rect})
			x += run
	return {"counts": counts, "rectangles": rectangles}


func paint_key(paint: Variant) -> String:
	if paint == null:
		return ""
	var record: Dictionary = paint
	if record.kind in ["centerMaterial", "connectedMaterial"]:
		var material: String = record.material
		if COLORS.has(material):
			return material
	elif record.kind == "raw":
		# Explicit diagnostic representation, not a substitute source sprite.
		return "raw:" + str(record.tileId)
	var error: String = "unsupported preview paint: " + JSON.stringify(record)
	if not build_errors.has(error):
		build_errors.append(error)
	return ""


func _build_layer(parent: Node3D, layer_id: String, rectangles: Array, height: float) -> void:
	var batches: Dictionary = {}
	for value: Variant in rectangles:
		var record: Dictionary = value
		var key: String = "raw-marker" if str(record.key).begins_with("raw:") else str(record.key)
		# Water paint remains inventoried; authored occupancy owns the M004
		# neutral preview. This keeps painted crossing/dock openings visibly dry.
		if key == "water":
			continue
		if not batches.has(key):
			var surface: SurfaceTool = SurfaceTool.new()
			surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			batches[key] = surface
		var rect: Rect2 = record.rect
		var surface: SurfaceTool = batches[key]
		for vertex: Vector3 in elevation.rectangle_faces(rect, height):
			surface.set_normal(Vector3.UP)
			surface.add_vertex(vertex)
	for key: String in batches:
		var material: ShaderMaterial = landscape.terrain(key)
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = layer_id + "--" + key
		instance.mesh = (batches[key] as SurfaceTool).commit()
		instance.material_override = material
		parent.add_child(instance)
		batch_count += 1


func _add_box(id: String, center: Vector3, size: Vector3, visible_box: bool = true) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
	if id == "BaseFloor":
		body.set_meta("candidate_walkable_floor", true)
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	if visible_box:
		var visual: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		# Low graybox rim keeps actors visible from the overhead camera. The
		# separate 3m collider prevents dodge escape; there is no jumping here.
		mesh.size = Vector3(size.x, minf(size.y, 0.6), size.z)
		visual.position.y = (mesh.size.y - size.y) * 0.5
		visual.mesh = mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(0.28, 0.30, 0.29)
		visual.material_override = material
		body.add_child(visual)
	add_child(body)


func _add_spawn(parent: Node3D, id: String, feet: Vector3) -> void:
	var anchor: SpawnAnchor = SpawnAnchor.new()
	anchor.name = id
	anchor.stable_id = id
	anchor.position = Vector3(feet.x, elevation.height_at(Vector2(feet.x, feet.z)), feet.z)
	parent.add_child(anchor)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var mesh: TorusMesh = TorusMesh.new()
	mesh.inner_radius = 0.85
	mesh.outer_radius = 1.0
	ring.mesh = mesh
	ring.position = Vector3(0.5, 0.035, 0)
	anchor.add_child(ring)
	var label: Label3D = Label3D.new()
	label.text = "CANDIDATE PAD\n" + id
	label.font_size = 28
	label.pixel_size = 0.008
	label.position = Vector3(0.5, 0.6, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	anchor.add_child(label)


func prepare_navigation() -> PackedStringArray:
	# Explicit physical dry surfaces, never parsed art or blocker tops. Measured
	# single-region synchronous baking stays inside the full-map loading budget.
	if navigation_region != null:
		return PackedStringArray()
	var started: int = Time.get_ticks_usec()
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.cell_size = 0.2
	mesh.cell_height = 0.05
	# Tight contour error preserves stepped bank corners rather than allowing
	# simplified polygons to cut into the authored water occupancy.
	mesh.edge_max_error = 0.1
	mesh.agent_radius = 0.4
	mesh.agent_height = 1.6
	mesh.agent_max_climb = 0.1
	mesh.agent_max_slope = 20.0 # Authored ramps are 14.04 degrees; cliffs are walls.
	var geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	var faces: PackedVector3Array = []
	var dry_faces: PackedVector3Array = crossings.navigation_faces(water_blockers.surface_faces(bounds, false))
	for index: int in range(0, dry_faces.size(), 6):
		var a: Vector3 = dry_faces[index]
		var c: Vector3 = dry_faces[index + 2]
		faces.append_array(elevation.rectangle_faces(Rect2(Vector2(a.x, a.z), Vector2(c.x - a.x, c.z - a.z))))
	geometry.add_faces(faces, Transform3D.IDENTITY)
	elevation.add_navigation_obstructions(geometry)
	town.add_navigation_obstructions(geometry)
	forest.add_navigation_obstructions(geometry)
	add_service_navigation_obstructions(geometry)
	# Tree detours exposed Recast corner cuts at the thin bridge rails. Apply
	# the same conservative voxel margin as props; physical rails stay exact.
	for rail: Rect2 in crossings.rail_rects:
		var points: PackedVector3Array = []
		for point: Vector2 in AlderwakePropGrayboxes._rectangle(rail.grow(0.2)):
			points.append(Vector3(point.x, 0, point.y))
		geometry.add_projected_obstruction(points, -0.2, 0.6, false)
	water_blockers.add_shore_navigation_margin(geometry)
	# Include the physical perimeter and closed gate in the same explicit
	# blocker input. Radius-only bounds leave exact-contact unsafe vertices.
	for edge: Rect2 in [Rect2(bounds.position.x - 1, bounds.position.y - 1, 1, bounds.size.y + 2),
		Rect2(bounds.end.x, bounds.position.y - 1, 1, bounds.size.y + 2),
		Rect2(bounds.position.x - 1, bounds.position.y - 1, bounds.size.x + 2, 1),
		Rect2(bounds.position.x - 1, bounds.end.y, bounds.size.x + 2, 1), Rect2(123, -11, 2, 8)]:
		var points: PackedVector3Array = []
		for point: Vector2 in AlderwakePropGrayboxes._rectangle(edge.grow(0.05)):
			points.append(Vector3(point.x, 0, point.y))
		geometry.add_projected_obstruction(points, -0.2, 4.0, false)
	var bake_started: int = Time.get_ticks_usec()
	NavigationServer3D.bake_from_source_geometry_data(mesh, geometry)
	var bake_usec: int = Time.get_ticks_usec() - bake_started
	var clip_started: int = Time.get_ticks_usec()
	_clip_navigation(mesh)
	var clip_usec: int = Time.get_ticks_usec() - clip_started
	if mesh.get_polygon_count() == 0:
		return PackedStringArray(["candidate has no dry navigation"])
	navigation_region = NavigationRegion3D.new()
	navigation_region.navigation_mesh = mesh
	# The candidate's exact clipped edges are finer than the default world's
	# 0.25m merge raster. Configure this isolated world, not project defaults.
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map, 0.01)
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, 0.01)
	add_child(navigation_region)
	navigation_report = {"construction_ms": construction_usec / 1000.0,
		"source_ms": (bake_started - started) / 1000.0, "bake_ms": bake_usec / 1000.0,
		"clip_ms": clip_usec / 1000.0,
		"generation_bake_ms": (construction_usec + Time.get_ticks_usec() - started) / 1000.0,
		"polygons": mesh.get_polygon_count(), "vertices": mesh.get_vertices().size(),
		"radius_m": mesh.agent_radius, "height_m": mesh.agent_height,
		"climb_m": mesh.agent_max_climb, "slope_degrees": mesh.agent_max_slope,
		"strategy": "explicit dry height surfaces; post-erosion cliff carve; exact cliff/gate/perimeter centre clipping"}
	return build_errors


func _clip_navigation(mesh: NavigationMesh) -> void:
	# Recast rasterizes exclusion outlines. Clip its resulting polygons against
	# exact agent-centre exclusions so every edge, not only chosen paths, clears
	# physical cliffs. No radius, terrain or movement-mask changes.
	var exclusions: Array[Dictionary] = []
	for cliff: Dictionary in elevation.cliffs:
		var shape: BoxShape3D = cliff.body.get_child(0).shape
		var center: Vector2 = Vector2(cliff.body.position.x, cliff.body.position.z)
		var rect: Rect2 = Rect2(center - Vector2(shape.size.x, shape.size.z) / 2, Vector2(shape.size.x, shape.size.z))
		# Square corner clearance is conservative; the built-in round offset
		# approximates these small arcs too coarsely for a capsule safety gate.
		exclusions.append({"outline": AlderwakePropGrayboxes._rectangle(rect.grow(0.44)), "bounds": rect.grow(0.44)})
	exclusions.append({"outline": AlderwakePropGrayboxes._rectangle(Rect2(123, -11, 2, 8).grow(0.44)), "bounds": Rect2(123, -11, 2, 8).grow(0.44)})
	var old_vertices: PackedVector3Array = mesh.get_vertices()
	var vertices: PackedVector3Array = []
	var polygons: Array[PackedInt32Array] = []
	var vertex_ids: Dictionary[Vector2i, int] = {}
	for index: int in range(mesh.get_polygon_count()):
		var outline: PackedVector2Array = []
		for vertex: int in mesh.get_polygon(index):
			outline.append(Vector2(old_vertices[vertex].x, old_vertices[vertex].z))
		var clipped: Array[PackedVector2Array] = Geometry2D.intersect_polygons(outline, AlderwakePropGrayboxes._rectangle(bounds.grow(-0.44)))
		var polygon_bounds: Rect2 = Rect2(outline[0], Vector2.ZERO)
		for point: Vector2 in outline:
			polygon_bounds = polygon_bounds.expand(point)
		for exclusion: Dictionary in exclusions:
			if not polygon_bounds.intersects(exclusion.bounds):
				continue
			var next: Array[PackedVector2Array] = []
			for part: PackedVector2Array in clipped:
				next.append_array(Geometry2D.clip_polygons(part, exclusion.outline))
			clipped = next
		for part: PackedVector2Array in clipped:
			# A baked obstacle already has a hole; clipping only trims its edge.
			# An unexpected new interior hole must fail rather than become floor.
			if Geometry2D.is_polygon_clockwise(part):
				build_errors.append("unexpected interior hole during navigation clipping")
				continue
			var triangles: PackedInt32Array = Geometry2D.triangulate_polygon(part)
			for triangle: int in range(0, triangles.size(), 3):
				var ids: PackedInt32Array = []
				for corner: int in range(3):
					var point: Vector2 = part[triangles[triangle + corner]]
					var key: Vector2i = Vector2i(roundi(point.x * 100), roundi(point.y * 100))
					# Inset each unique centimetre vertex from its merge raster edge;
					# float roundoff must not alias neighbouring edge endpoints.
					point = Vector2(key) / 100.0 + Vector2.ONE * 0.0001
					if not vertex_ids.has(key):
						vertex_ids[key] = vertices.size()
						vertices.append(Vector3(point.x, elevation.height_at(point) + 0.05, point.y))
					ids.append(vertex_ids[key])
				if ids[0] != ids[1] and ids[1] != ids[2] and ids[0] != ids[2]:
					var a: Vector2 = Vector2(vertices[ids[0]].x, vertices[ids[0]].z)
					var b: Vector2 = Vector2(vertices[ids[1]].x, vertices[ids[1]].z)
					var c: Vector2 = Vector2(vertices[ids[2]].x, vertices[ids[2]].z)
					if absf((b - a).cross(c - a)) > 0.000001:
						polygons.append(ids)
	mesh.clear_polygons()
	mesh.set_vertices(vertices)
	for polygon: PackedInt32Array in polygons:
		mesh.add_polygon(polygon)


func validation_errors(definition: LocationDefinition, catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors(definition, catalog)
	errors.append_array(build_errors)
	return errors


func add_service_navigation_obstructions(_geometry: NavigationMeshSourceGeometryData3D) -> void:
	pass # Isolated harness has no recovery interactions.
