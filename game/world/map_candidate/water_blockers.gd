class_name AlderwakeWaterBlockers
extends Node3D
## M004: authored water occupancy, independent of tile art and walkable floor.

const GRID: float = 0.5
var records: Array[Dictionary] = []
var water_cells: Dictionary[Vector2i, bool] = {}
var authored_water_cells: Dictionary[Vector2i, bool] = {}
var blocked_cells: Dictionary[Vector2i, bool] = {}
var gate_rect: Rect2
var dock_cutouts: Array[Rect2] = []


func build(layout: Dictionary, bounds: Rect2, cutouts: Array[Rect2] = []) -> void:
	name = "WaterBlockers"
	dock_cutouts = cutouts
	for value: Variant in layout.colliders:
		var record: Dictionary = value
		var id: String = record.id
		var water: bool = id.begins_with("moonwood-water-") or id.begins_with("south-water-") or id == "passenger-basin-water-01"
		if not water and id != "future-exit-gate":
			continue
		var values: Array = record.rect_xz_m
		var rect: Rect2 = Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))
		var collider_cutouts: Array[Rect2] = []
		if water:
			collider_cutouts.assign(cutouts)
		_add_collider(id, rect, collider_cutouts)
		if water:
			records.append(record)
		else:
			gate_rect = rect
		# Pinned water/gate bounds lie exactly on the half-metre grid. Reject
		# future incompatible records rather than silently snapping geometry.
		for coordinate: float in [rect.position.x, rect.position.y, rect.end.x, rect.end.y]:
			assert(is_equal_approx(coordinate / GRID, roundf(coordinate / GRID)), "water/gate bounds must fit preview grid")
		for z: int in range(roundi((rect.position.y - bounds.position.y) / GRID), roundi((rect.end.y - bounds.position.y) / GRID)):
			for x: int in range(roundi((rect.position.x - bounds.position.x) / GRID), roundi((rect.end.x - bounds.position.x) / GRID)):
				blocked_cells[Vector2i(x, z)] = true
				if water:
					water_cells[Vector2i(x, z)] = true
	authored_water_cells = water_cells.duplicate()
	# User-approved dock exception changes effective water only. Preserve all
	# source records and original union for provenance/regression accounting.
	for cell: Vector2i in water_cells.keys():
		var center: Vector2 = bounds.position + Vector2(cell) * GRID + Vector2.ONE * GRID / 2
		if on_dock(center):
			water_cells.erase(cell)
			blocked_cells.erase(cell)
	# No sprite/paint rectangle owns physics. One independent union mesh shows
	# exact authored water footprint, including overlaps and basin omissions.
	var visuals: Node3D = Node3D.new()
	visuals.name = "WaterVisuals"
	add_child(visuals)
	var faces: PackedVector3Array = surface_faces(bounds, true, 0.015)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vertex: Vector3 in faces:
		surface.set_normal(Vector3.UP)
		surface.add_vertex(vertex)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "AuthoredWaterPreview"
	instance.mesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.22, 0.39, 0.53)
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = material
	visuals.add_child(instance)
	# M007 source prop wrapper owns replaceable gate art; this owner keeps physics.


func _add_collider(id: String, rect: Rect2, cutouts: Array[Rect2]) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
	body.set_meta("source_collider_id", id)
	body.position = Vector3(rect.get_center().x, 1.4, rect.get_center().y)
	body.collision_layer = 1
	body.collision_mask = 0
	body.set_meta("source_rect_xz_m", rect)
	for piece: Rect2 in AlderwakeDockSurfaces.subtract(rect, cutouts):
		var collider: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = Vector3(piece.size.x, 3.2, piece.size.y)
		collider.shape = shape
		collider.position = Vector3(piece.get_center().x - rect.get_center().x, 0, piece.get_center().y - rect.get_center().y)
		body.add_child(collider)
	add_child(body)


func on_dock(point: Vector2) -> bool:
	for rect: Rect2 in dock_cutouts:
		if rect.has_point(point):
			return true
	return false


func add_shore_navigation_margin(geometry: NavigationMeshSourceGeometryData3D) -> void:
	# Town routes exposed fractional shoreline corner cuts in Recast's 0.2m
	# voxels. Conservative 0.2m outline margin is nav-only; physics stays exact.
	for record: Dictionary in records:
		if not str(record.id).begins_with("south-water-"):
			continue
		var r: Array = record.rect_xz_m
		for piece: Rect2 in AlderwakeDockSurfaces.subtract(Rect2(r[0], r[1], r[2], r[3]), dock_cutouts):
			var expanded: Rect2 = piece.grow(0.2)
			geometry.add_projected_obstruction(PackedVector3Array([
				Vector3(expanded.position.x, 0, expanded.position.y), Vector3(expanded.end.x, 0, expanded.position.y),
				Vector3(expanded.end.x, 0, expanded.end.y), Vector3(expanded.position.x, 0, expanded.end.y)]), -0.2, 3, false)


func surface_faces(bounds: Rect2, water: bool, height: float = 0.0) -> PackedVector3Array:
	# Row runs form explicit dry navigation input or water visual triangles.
	# Navigation never parses blocker tops, terrain art or the full base floor.
	var faces: PackedVector3Array = []
	var width: int = roundi(bounds.size.x / GRID)
	var depth: int = roundi(bounds.size.y / GRID)
	for z: int in range(depth):
		var x: int = 0
		while x < width:
			var include: bool = water_cells.has(Vector2i(x, z)) if water else not blocked_cells.has(Vector2i(x, z))
			if not include:
				x += 1
				continue
			var start: int = x
			x += 1
			while x < width and (water_cells.has(Vector2i(x, z)) if water else not blocked_cells.has(Vector2i(x, z))):
				x += 1
			var left: float = bounds.position.x + start * GRID
			var right: float = bounds.position.x + x * GRID
			var top: float = bounds.position.y + z * GRID
			var bottom: float = top + GRID
			var a: Vector3 = Vector3(left, height, top)
			var b: Vector3 = Vector3(right, height, top)
			var c: Vector3 = Vector3(right, height, bottom)
			var d: Vector3 = Vector3(left, height, bottom)
			# Godot front faces use clockwise winding when viewed from above.
			faces.append_array(PackedVector3Array([a, b, c, a, c, d]))
	return faces
