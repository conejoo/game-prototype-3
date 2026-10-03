class_name AlderwakeTerrainPreview
extends PrototypeLocation
## M003–M006: flat preview with independent water, crossings and town wrappers.

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


func _init() -> void:
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
	_add_box("FlatFloor", Vector3(center.x, -0.2, center.y), Vector3(bounds.size.x, 0.4, bounds.size.y), false)
	# Outside-facing wall surfaces coincide with the logical map boundary.
	_add_box("BoundaryWest", Vector3(bounds.position.x - 0.2, 1.5, center.y), Vector3(0.4, 3.0, bounds.size.y + 0.8))
	_add_box("BoundaryEast", Vector3(bounds.end.x + 0.2, 1.5, center.y), Vector3(0.4, 3.0, bounds.size.y + 0.8))
	_add_box("BoundaryNorth", Vector3(center.x, 1.5, bounds.position.y - 0.2), Vector3(bounds.size.x + 0.8, 3.0, 0.4))
	_add_box("BoundarySouth", Vector3(center.x, 1.5, bounds.end.y + 0.2), Vector3(bounds.size.x + 0.8, 3.0, 0.4))
	water_blockers = AlderwakeWaterBlockers.new()
	water_blockers.build(layout, bounds, AlderwakeDockSurfaces.cutouts())
	add_child(water_blockers)
	crossings = AlderwakeCrossings.new()
	crossings.build(layout)
	add_child(crossings)
	build_errors.append_array(crossings.build_errors)
	town = AlderwakeTownFootprints.new()
	town.build(layout)
	add_child(town)
	build_errors.append_array(town.build_errors)
	var spawns: Node3D = Node3D.new()
	spawns.name = "Spawns"
	add_child(spawns)
	_add_spawn(spawns, "alderwake-start", Vector3(float(layout.spawn_xyz_m[0]), 0, float(layout.spawn_xyz_m[2])))
	_add_spawn(spawns, "alderwake-from-tollworks", Vector3(107.25, 0, 1.25))
	preview_report["water"] = {"authored_records": water_blockers.records.size(), "authored_half_metre_cells": water_blockers.authored_water_cells.size(), "union_half_metre_cells": water_blockers.water_cells.size(), "dock_cutout_count": water_blockers.dock_cutouts.size(), "closed_exit": true}
	preview_report["crossings"] = {"bridge_rect": str(crossings.bridge_rect), "ford_rect": str(crossings.ford_rect), "bridge_clear_width_m": 2.8, "floor_y_m": 0.0}
	preview_report["town"] = {"props": town.prop_records.size(), "authored_colliders": town.collider_records.size(), "blocking_footprints": town.footprints.size(), "inert_portal_pads": town.portal_pads.size()}
	preview_report["limits"] = "M006 town/dock grayboxes; water/gate blocked; flat elevation M008; provisional navigation M009; trees/forest props M007; final art M011-M014; all portals/interactions inactive."


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
		var a: Vector3 = Vector3(rect.position.x, height, rect.position.y)
		var b: Vector3 = Vector3(rect.end.x, height, rect.position.y)
		var c: Vector3 = Vector3(rect.end.x, height, rect.end.y)
		var d: Vector3 = Vector3(rect.position.x, height, rect.end.y)
		for vertex: Vector3 in [a, b, c, a, c, d]:
			surface.set_normal(Vector3.UP)
			surface.add_vertex(vertex)
	for key: String in batches:
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = COLORS[key]
		material.roughness = 1.0
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = layer_id + "--" + key
		instance.mesh = (batches[key] as SurfaceTool).commit()
		instance.material_override = material
		parent.add_child(instance)
		batch_count += 1


func _add_box(id: String, center: Vector3, size: Vector3, visible_box: bool = true) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
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
	anchor.position = feet
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
	# M004 provisional dry-only bake; M009 owns complete exterior strategy.
	if navigation_region != null:
		return PackedStringArray()
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.cell_size = 0.2
	mesh.cell_height = 0.1
	# Tight contour error preserves stepped bank corners rather than allowing
	# simplified polygons to cut into the authored water occupancy.
	mesh.edge_max_error = 0.1
	mesh.agent_radius = 0.4
	mesh.agent_height = 1.6
	mesh.agent_max_climb = 0.1
	var geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	geometry.add_faces(crossings.navigation_faces(water_blockers.surface_faces(bounds, false)), Transform3D.IDENTITY)
	town.add_navigation_obstructions(geometry)
	water_blockers.add_shore_navigation_margin(geometry)
	NavigationServer3D.bake_from_source_geometry_data(mesh, geometry)
	if mesh.get_polygon_count() == 0:
		return PackedStringArray(["candidate has no dry navigation"])
	navigation_region = NavigationRegion3D.new()
	navigation_region.navigation_mesh = mesh
	add_child(navigation_region)
	return build_errors


func validation_errors(definition: LocationDefinition, catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors(definition, catalog)
	errors.append_array(build_errors)
	return errors
