extends RefCounted
## Visual masonry inside an existing wall's bounds. Collision remains owned by the source prop.

const CAP_HEIGHT: float = 0.15
const TARGET_CAP_LENGTH: float = 0.56
const CAP_JOINT: float = 0.008
const CAP_BEVEL: float = 0.023


static func build(source: Mesh) -> ArrayMesh:
	var result: ArrayMesh = ArrayMesh.new()
	if source == null:
		return result
	var bounds: AABB = source.get_aabb()
	if minf(bounds.size.x, minf(bounds.size.y, bounds.size.z)) <= 0.0001:
		return result
	var builder: WallBuilder = WallBuilder.new()
	builder.top_y = bounds.end.y
	builder.long_axis = 0 if bounds.size.x >= bounds.size.z else 2
	builder.surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cap_height: float = minf(CAP_HEIGHT, bounds.size.y * 0.5)
	var body_high: Vector3 = bounds.end
	body_high.y -= cap_height
	builder.box(bounds.position, body_high, Color(0.0, 0.0, 0.0, 1.0))
	var length: float = bounds.size[builder.long_axis]
	var cap_count: int = maxi(1, ceili(length / TARGET_CAP_LENGTH))
	var step: float = length / float(cap_count)
	for stone: int in range(cap_count):
		var low: Vector3 = bounds.position
		var high: Vector3 = bounds.end
		low.y = body_high.y
		low[builder.long_axis] = bounds.position[builder.long_axis] + step * stone
		high[builder.long_axis] = bounds.position[builder.long_axis] + step * (stone + 1)
		# Only internal joints remove width. The outer stones still touch the original bounds.
		if stone > 0:
			low[builder.long_axis] += CAP_JOINT * 0.5
		else:
			low[builder.long_axis] = bounds.position[builder.long_axis]
		if stone < cap_count - 1:
			high[builder.long_axis] -= CAP_JOINT * 0.5
		else:
			high[builder.long_axis] = bounds.end[builder.long_axis]
		var variation: float = float((stone * 73 + 37) % 101) / 100.0
		builder.chamfered_box(low, high, Color(1.0, variation, 0.0, 1.0))
	builder.surface.commit(result)
	return result


class WallBuilder extends RefCounted:
	var surface: SurfaceTool = SurfaceTool.new()
	var top_y: float = 0.0
	var long_axis: int = 0


	func box(low: Vector3, high: Vector3, color: Color) -> void:
		var center: Vector3 = (low + high) * 0.5
		var half: Vector3 = (high - low) * 0.5
		for axis: int in range(3):
			var u: int = (axis + 1) % 3
			var v: int = (axis + 2) % 3
			for sign_value: float in [-1.0, 1.0]:
				var normal: Vector3 = Vector3.ZERO
				normal[axis] = sign_value
				var vertices: PackedVector3Array = []
				for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
					var point: Vector3 = center
					point[axis] += half[axis] * sign_value
					point[u] += half[u] * corner.x
					point[v] += half[v] * corner.y
					vertices.append(point)
				face(vertices, normal, color)


	func chamfered_box(low: Vector3, high: Vector3, color: Color) -> void:
		var center: Vector3 = (low + high) * 0.5
		var half: Vector3 = (high - low) * 0.5
		var bevel: float = minf(CAP_BEVEL, minf(half.x, minf(half.y, half.z)) * 0.45)
		var inset: Vector3 = half - Vector3.ONE * bevel
		# Six inset faces, twelve edge strips and eight corner triangles: 44 triangles.
		for axis: int in range(3):
			var u: int = (axis + 1) % 3
			var v: int = (axis + 2) % 3
			for sign_value: float in [-1.0, 1.0]:
				var normal: Vector3 = Vector3.ZERO
				normal[axis] = sign_value
				var vertices: PackedVector3Array = []
				for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
					var point: Vector3 = center
					point[axis] += half[axis] * sign_value
					point[u] += inset[u] * corner.x
					point[v] += inset[v] * corner.y
					vertices.append(point)
				face(vertices, normal, color)
		# Each axis is the length direction of four edge strips.
		for axis: int in range(3):
			var u: int = (axis + 1) % 3
			var v: int = (axis + 2) % 3
			for sign_u: float in [-1.0, 1.0]:
				for sign_v: float in [-1.0, 1.0]:
					var normal: Vector3 = Vector3.ZERO
					normal[u] = sign_u
					normal[v] = sign_v
					var first: Vector3 = center
					first[axis] -= inset[axis]
					first[u] += half[u] * sign_u
					first[v] += inset[v] * sign_v
					var second: Vector3 = center
					second[axis] -= inset[axis]
					second[u] += inset[u] * sign_u
					second[v] += half[v] * sign_v
					var third: Vector3 = second
					third[axis] += inset[axis] * 2.0
					var fourth: Vector3 = first
					fourth[axis] += inset[axis] * 2.0
					face(PackedVector3Array([first, second, third, fourth]), normal.normalized(), color)
		for x_sign: float in [-1.0, 1.0]:
			for y_sign: float in [-1.0, 1.0]:
				for z_sign: float in [-1.0, 1.0]:
					var signs: Vector3 = Vector3(x_sign, y_sign, z_sign)
					var vertices: PackedVector3Array = []
					for axis: int in range(3):
						var point: Vector3 = center + inset * signs
						point[axis] += bevel * signs[axis]
						vertices.append(point)
					face(vertices, signs.normalized(), color)


	func face(points: PackedVector3Array, normal: Vector3, color: Color) -> void:
		for index: int in range(1, points.size() - 1):
			var a: Vector3 = points[0]
			var b: Vector3 = points[index]
			var c: Vector3 = points[index + 1]
			var cross: Vector3 = (b - a).cross(c - a)
			if cross.length_squared() <= 0.000000000001:
				continue
			# Godot's front faces use clockwise winding when viewed from outside.
			if cross.dot(normal) > 0.0:
				var swap: Vector3 = b
				b = c
				c = swap
			for point: Vector3 in [a, b, c]:
				surface.set_normal(normal)
				surface.set_color(color)
				var horizontal: float = point[long_axis]
				if absf(normal.x) > absf(normal.z) and absf(normal.x) >= absf(normal.y):
					horizontal = point.z
				elif absf(normal.z) >= absf(normal.x) and absf(normal.z) >= absf(normal.y):
					horizontal = point.x
				surface.set_uv(Vector2(horizontal, top_y - point.y))
				surface.add_vertex(point)
