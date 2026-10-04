class_name AlderwakeElevationSurfaces
extends Node3D
## Pinned physical surfaces. Collision, visible risers and nav input stay separate.

const ORIGIN: Vector2 = Vector2(-22, -18)
var levels: Dictionary[Vector2i, float] = {}
var slopes: Dictionary[Vector2i, Dictionary] = {}
var cliffs: Array[Dictionary] = []
var floor_faces: PackedVector3Array = []
# M018: spatially batch identical riser appearance; cliff bodies stay independent.
const RISER_CHUNK_SIZE: float = 16.0
var riser_surfaces: Dictionary[Vector2i, SurfaceTool] = {}
var riser_batches: Dictionary[Vector2i, MeshInstance3D] = {}


func build(layout: Dictionary) -> void:
	name = "ElevationSurfaces"
	for record: Dictionary in layout.elevation.cells:
		levels[Vector2i(record.cell[0], record.cell[1])] = float(record.height_m)
	for record: Dictionary in layout.elevation.slopes:
		slopes[Vector2i(record.cell[0], record.cell[1])] = record
	for z: int in range(80):
		for x: int in range(147):
			var cell: Vector2i = Vector2i(x, z)
			# The existing solid base owns default level zero. Emit only authored
			# height overrides/ramps, avoiding duplicate coplanar floor contacts.
			if levels.has(cell) or slopes.has(cell):
				floor_faces.append_array(cell_faces(cell, Rect2(Vector2(cell) + ORIGIN, Vector2.ONE)))
			for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
				var other: Vector2i = cell + direction
				if other.x >= 147 or other.y >= 80:
					continue
				var a: Vector2 = Vector2(cell) + ORIGIN + Vector2(direction)
				var b: Vector2 = a + (Vector2.DOWN if direction == Vector2i.RIGHT else Vector2.RIGHT)
				var heights: PackedFloat32Array = PackedFloat32Array([cell_height(cell, a), cell_height(cell, b), cell_height(other, a), cell_height(other, b)])
				if absf(heights[0] - heights[2]) < 0.001 and absf(heights[1] - heights[3]) < 0.001:
					continue # Includes matching parallel ramps and their low/high joins.
				_add_cliff(cell, direction, a, b, heights)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "TerrainFloor"
	body.set_meta("candidate_walkable_floor", true)
	body.collision_layer = 1
	body.collision_mask = 0
	var shape: ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	shape.set_faces(floor_faces)
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	_finish_risers()


func height_at(point: Vector2) -> float:
	return cell_height(Vector2i(floori(point.x - ORIGIN.x), floori(point.y - ORIGIN.y)), point)


func cell_height(cell: Vector2i, point: Vector2) -> float:
	if not slopes.has(cell):
		return levels.get(cell, 0.0)
	var record: Dictionary = slopes[cell]
	var local: Vector2 = point - Vector2(cell) - ORIGIN
	var progress: float = 0.0
	match str(record.ascends_toward):
		"north": progress = 1.0 - local.y
		"east": progress = local.x
		"south": progress = local.y
		"west": progress = 1.0 - local.x
	return float(record.low_height_m) + 0.25 * clampf(progress, 0.0, 1.0)


func cell_faces(cell: Vector2i, rect: Rect2, lift: float = 0.0) -> PackedVector3Array:
	var points: PackedVector3Array = []
	for p: Vector2 in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
		points.append(Vector3(p.x, cell_height(cell, p) + lift, p.y))
	# Godot front faces use clockwise winding when viewed from above.
	return PackedVector3Array([points[0], points[1], points[2], points[0], points[2], points[3]])


func rectangle_faces(rect: Rect2, lift: float = 0.0) -> PackedVector3Array:
	var faces: PackedVector3Array = []
	for z: int in range(floori(rect.position.y - ORIGIN.y), ceili(rect.end.y - ORIGIN.y)):
		for x: int in range(floori(rect.position.x - ORIGIN.x), ceili(rect.end.x - ORIGIN.x)):
			var cell: Vector2i = Vector2i(x, z)
			var part: Rect2 = rect.intersection(Rect2(Vector2(cell) + ORIGIN, Vector2.ONE))
			if part.has_area():
				faces.append_array(cell_faces(cell, part, lift))
	return faces


func _add_cliff(cell: Vector2i, direction: Vector2i, a: Vector2, b: Vector2, heights: PackedFloat32Array) -> void:
	var high: float = maxf(maxf(heights[0], heights[1]), maxf(heights[2], heights[3]))
	var id: String = "cliff-%d-%d-%s" % [cell.x, cell.y, "east" if direction == Vector2i.RIGHT else "south"]
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
	body.collision_layer = 1
	body.collision_mask = 0
	# Bidirectional traversal barrier, including downhill and diagonal cuts.
	# Above-surface part is invisible; visible riser follows actual edge profiles.
	body.position = Vector3((a.x + b.x) / 2, (high + 2.0 - 0.2) / 2, (a.y + b.y) / 2)
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.02 if direction == Vector2i.RIGHT else 1.02, high + 2.2, 1.02 if direction == Vector2i.RIGHT else 0.02)
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	cliffs.append({"id": id, "a": a, "b": b, "heights": heights, "body": body})
	var chunk: Vector2i = Vector2i(floori(a.x / RISER_CHUNK_SIZE), floori(a.y / RISER_CHUNK_SIZE))
	if not riser_surfaces.has(chunk):
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		riser_surfaces[chunk] = surface
	var surface: SurfaceTool = riser_surfaces[chunk]
	var p: Vector3 = Vector3(a.x, heights[0], a.y)
	var q: Vector3 = Vector3(b.x, heights[1], b.y)
	var r: Vector3 = Vector3(b.x, heights[3], b.y)
	var s: Vector3 = Vector3(a.x, heights[2], a.y)
	for point: Vector3 in [p, q, r, p, r, s]:
		surface.add_vertex(point)


func _finish_risers() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.36, 0.30, 0.22)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	for chunk: Vector2i in riser_surfaces:
		var surface: SurfaceTool = riser_surfaces[chunk]
		surface.generate_normals()
		var visual: MeshInstance3D = MeshInstance3D.new()
		visual.name = "Risers-%d-%d" % [chunk.x, chunk.y]
		visual.mesh = surface.commit()
		visual.material_override = material
		add_child(visual)
		riser_batches[chunk] = visual
	# Release construction buffers before steady-state profiling/lifecycle checks.
	riser_surfaces.clear()


func add_navigation_obstructions(geometry: NavigationMeshSourceGeometryData3D) -> void:
	for cliff: Dictionary in cliffs:
		var a: Vector2 = cliff.a
		var b: Vector2 = cliff.b
		var rect: Rect2 = Rect2(a.min(b), (b - a).abs()).grow(0.01)
		# Carve the agent's centre exclusion after erosion. Pre-erosion thin
		# barriers let voxel contours cut the inside turn of the Moonwell ramp.
		for outline: PackedVector2Array in Geometry2D.offset_polygon(AlderwakePropGrayboxes._rectangle(rect), 0.42, Geometry2D.JOIN_ROUND):
			var points: PackedVector3Array = []
			for point: Vector2 in outline:
				points.append(Vector3(point.x, 0, point.y))
			geometry.add_projected_obstruction(points, -0.2, 4.0, true)
