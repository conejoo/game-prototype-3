class_name AlderwakePropGrayboxes
extends Node3D
## Shared exact polygon physics and replaceable graybox visuals; no gameplay state.

var footprints: Array[PackedVector2Array] = []
var build_errors: PackedStringArray = []
var elevation: AlderwakeElevationSurfaces


func _wrapper(id: String, foot: Vector3) -> Node3D:
	var wrapper: Node3D = Node3D.new()
	wrapper.name = id
	wrapper.position = foot
	var visuals: Node3D = Node3D.new()
	visuals.name = "VisualRoot"
	wrapper.add_child(visuals)
	add_child(wrapper)
	return wrapper


func _add_dock_floor(wrapper: Node3D, rect: Rect2, index: int) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "DeckFloor%d" % index
	body.set_meta("candidate_walkable_floor", true)
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = wrapper.transform.affine_inverse() * Vector3(rect.get_center().x, -0.06, rect.get_center().y)
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(rect.size.x, 0.12, rect.size.y)
	collider.shape = shape
	body.add_child(collider)
	wrapper.add_child(body)


func _local_outline(wrapper: Node3D, outline: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = []
	for point: Vector2 in outline:
		var local: Vector3 = wrapper.transform.affine_inverse() * Vector3(point.x, 0, point.y)
		result.append(Vector2(local.x, local.z))
	return result


func _add_prism(wrapper: Node3D, id: String, outline: PackedVector2Array, height: float, blocking: bool, color: Color) -> void:
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(outline)
	if indices.is_empty():
		build_errors.append("invalid prop polygon: " + id)
		return
	var body: StaticBody3D
	if blocking:
		body = StaticBody3D.new()
		body.name = "Collision"
		body.set_meta("source_collision_id", id)
		body.collision_layer = 1
		body.collision_mask = 0
		wrapper.add_child(body)
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var low: float = -0.2 if blocking else 0.0
	if blocking and elevation != null:
		# Keep source polygon blocking where it straddles a height edge. The
		# primitive's vertical extent adapts; its exact X/Z outline never changes.
		for point: Vector2 in outline:
			var world: Vector3 = wrapper.transform * Vector3(point.x, 0, point.y)
			var ground: float = elevation.height_at(Vector2(world.x, world.z)) - wrapper.position.y
			low = minf(low, ground - 0.2)
			height = maxf(height, ground + 0.6)
	for index: int in range(0, indices.size(), 3):
		var points: PackedVector3Array = []
		for vertex_index: int in range(3):
			var point: Vector2 = outline[indices[index + vertex_index]]
			points.append(Vector3(point.x, height, point.y))
			points.append(Vector3(point.x, low, point.y))
		if blocking:
			# One convex prism per triangle preserves concave footprints exactly.
			var shape: ConvexPolygonShape3D = ConvexPolygonShape3D.new()
			shape.points = points
			var collider: CollisionShape3D = CollisionShape3D.new()
			collider.shape = shape
			body.add_child(collider)
		for vertex: Vector3 in [points[0], points[2], points[4]]:
			surface.add_vertex(vertex)
	for index: int in range(outline.size()):
		var a: Vector2 = outline[index]
		var b: Vector2 = outline[(index + 1) % outline.size()]
		for vertex: Vector3 in [Vector3(a.x, low, a.y), Vector3(a.x, height, a.y), Vector3(b.x, height, b.y),
			Vector3(a.x, low, a.y), Vector3(b.x, height, b.y), Vector3(b.x, low, b.y)]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var visual: MeshInstance3D = MeshInstance3D.new()
	visual.name = id.replace(":", "--")
	visual.mesh = surface.commit()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = material
	wrapper.get_node("VisualRoot").add_child(visual)


func add_navigation_obstructions(geometry: NavigationMeshSourceGeometryData3D) -> void:
	# Bake expanded obstacles with existing agent radius. Never feed roofs/decks
	# or blocker tops as traversable surfaces. Complete height/nav remains M009.
	for outline: PackedVector2Array in footprints:
		# One 0.2m voxel of conservative margin prevents Recast contours from
		# cutting fractional prop corners. Physical footprints remain exact.
		for expanded: PackedVector2Array in Geometry2D.offset_polygon(outline, 0.2):
			var points: PackedVector3Array = []
			for point: Vector2 in expanded:
				points.append(Vector3(point.x, 0, point.y))
			geometry.add_projected_obstruction(points, -0.2, 3.0, false)


static func _outline(values: Array) -> PackedVector2Array:
	var result: PackedVector2Array = []
	for value: Array in values:
		result.append(Vector2(value[0], value[1]))
	return result


static func _rectangle(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])


func _label(parent: Node3D, text: String, point: Vector3) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.position = point
	label.font_size = 22
	label.pixel_size = 0.007
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
