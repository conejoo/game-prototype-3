class_name AlderwakeCrossings
extends Node3D
## M005 flat crossing wrappers. VisualRoot can be replaced without physics changes.

var bridge_rect: Rect2
var ford_rect: Rect2 = Rect2(67, 11, 7, 3)
var rail_rects: Array[Rect2] = []
var build_errors: PackedStringArray = []


func build(layout: Dictionary) -> void:
	name = "Crossings"
	# Derive the complete art footprint from the three pinned flattened rows.
	var cells: Array[Vector2i] = []
	for layer: Dictionary in layout.art_layers:
		if str(layer.id).begins_with("moonwood-footbridge--"):
			for record: Dictionary in layer.cells:
				cells.append(Vector2i(record.cell[0], record.cell[1]))
	if cells.size() != 18:
		build_errors.append("bridge requires the pinned 18 art cells")
		return
	var low: Vector2i = cells[0]
	var high: Vector2i = cells[0]
	for cell: Vector2i in cells:
		low = low.min(cell)
		high = high.max(cell)
	bridge_rect = Rect2(Vector2(low) + Vector2(-22, -18), Vector2(high - low + Vector2i.ONE))
	if bridge_rect != Rect2(95, -2, 6, 3):
		build_errors.append("bridge footprint differs from pinned contract")
		return
	var bridge: Node3D = _wrapper("moonwood-footbridge")
	_floor(bridge, "Deck", bridge_rect, Color(0.48, 0.34, 0.23))
	_floor(bridge, "WestLanding", Rect2(93, -2, 2, 3), Color(0.58, 0.48, 0.33))
	_floor(bridge, "EastLanding", Rect2(101, -2, 2, 3), Color(0.58, 0.48, 0.33))
	# Art rows are not one-metre-wide blockers. Thin edge rails preserve 2.8m
	# usable deck and terminate flush with it, with no inward posts/end caps.
	rail_rects.assign([Rect2(95, -2, 6, 0.1), Rect2(95, 0.9, 6, 0.1)])
	for index: int in range(rail_rects.size()):
		var id: String = "NorthRail" if index == 0 else "SouthRail"
		_box(bridge, id, rail_rects[index], 0.0, 0.6, Color(0.32, 0.27, 0.21))
	# Shallow separate markings make the entire deck read as a crossing.
	for index: int in range(12):
		_visual(bridge.get_node("VisualRoot"), "Plank%02d" % index, Rect2(95 + index * 0.5, -1.9, 0.025, 2.8), 0.019, 0.003, Color(0.31, 0.24, 0.18))
	var ford: Node3D = _wrapper("moonwood-sand-ford")
	_floor(ford, "Bed", ford_rect, Color(0.76, 0.66, 0.43))
	_floor(ford, "WestLanding", Rect2(66, 11, 1, 3), Color(0.67, 0.59, 0.40))
	_floor(ford, "EastLanding", Rect2(74, 11, 1, 3), Color(0.67, 0.59, 0.40))


func _wrapper(id: String) -> Node3D:
	var wrapper: Node3D = Node3D.new()
	wrapper.name = id
	if id == "moonwood-footbridge":
		wrapper.set_meta("source_landmark_id", id)
	else:
		# Ford has terrain coordinates, not a named source prop/group. This
		# local wrapper ID is not the unrelated western old-ford zone.
		wrapper.set_meta("candidate_landmark_id", id)
		wrapper.set_meta("source_cell_range", "x89..95,y29..31")
	var visuals: Node3D = Node3D.new()
	visuals.name = "VisualRoot"
	wrapper.add_child(visuals)
	add_child(wrapper)
	return wrapper


func _floor(parent: Node3D, id: String, rect: Rect2, color: Color) -> void:
	# Physical top is exactly Y=0, shared with both banks until M008.
	_box(parent, id, rect, -0.12, 0.0, color, 0.018)


func _box(parent: Node3D, id: String, rect: Rect2, low: float, high: float, color: Color, visual_top: float = NAN) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
	if not id.ends_with("Rail"):
		body.set_meta("candidate_walkable_floor", true)
	body.position = Vector3(rect.get_center().x, (low + high) * 0.5, rect.get_center().y)
	body.collision_layer = 1
	body.collision_mask = 0
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(rect.size.x, high - low, rect.size.y)
	collider.shape = shape
	body.add_child(collider)
	parent.add_child(body)
	var top: float = high if is_nan(visual_top) else visual_top
	_visual(parent.get_node("VisualRoot"), id, rect, low, top - low, color)


func _visual(parent: Node3D, id: String, rect: Rect2, low: float, height: float, color: Color) -> void:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = id
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(rect.size.x, height, rect.size.y)
	instance.mesh = mesh
	instance.position = Vector3(rect.get_center().x, low + height * 0.5, rect.get_center().y)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	instance.material_override = material
	parent.add_child(instance)


func navigation_faces(faces: PackedVector3Array) -> PackedVector3Array:
	# Clip rail footprints out of the provisional dry rectangles before baking.
	# Never feed rail tops or visual meshes into navigation.
	var result: PackedVector3Array = []
	for index: int in range(0, faces.size(), 6):
		var a: Vector3 = faces[index]
		var c: Vector3 = faces[index + 2]
		var pieces: Array[Rect2] = [Rect2(Vector2(a.x, a.z), Vector2(c.x - a.x, c.z - a.z))]
		for rail: Rect2 in rail_rects:
			var remaining: Array[Rect2] = []
			for piece: Rect2 in pieces:
				var cut: Rect2 = piece.intersection(rail)
				if not cut.has_area():
					remaining.append(piece)
					continue
				for part: Rect2 in [Rect2(piece.position, Vector2(piece.size.x, cut.position.y - piece.position.y)),
					Rect2(piece.position.x, cut.end.y, piece.size.x, piece.end.y - cut.end.y),
					Rect2(piece.position.x, cut.position.y, cut.position.x - piece.position.x, cut.size.y),
					Rect2(cut.end.x, cut.position.y, piece.end.x - cut.end.x, cut.size.y)]:
					if part.has_area():
						remaining.append(part)
			pieces = remaining
		for piece: Rect2 in pieces:
			var p: Vector3 = Vector3(piece.position.x, a.y, piece.position.y)
			var q: Vector3 = Vector3(piece.end.x, a.y, piece.position.y)
			var r: Vector3 = Vector3(piece.end.x, a.y, piece.end.y)
			var s: Vector3 = Vector3(piece.position.x, a.y, piece.end.y)
			result.append_array(PackedVector3Array([p, q, r, p, r, s]))
	return result
