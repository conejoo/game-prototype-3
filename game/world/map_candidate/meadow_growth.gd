extends RefCounted
## Deterministic visual vegetation. Existing terrain, props, physics and paths own placement.

const CHUNK_SIZE: float = 16.0
const MAX_CLUMPS: int = 4000
const MAX_TRIANGLES: int = 96000
const PALETTE: Array[Color] = [Color("8eaa38"), Color("9aaf3e"), Color("819d32"), Color("a5b94b"), Color("769336")]


static func build(location: AlderwakeTerrainPreview) -> Node3D:
	var builder: GrowthBuilder = GrowthBuilder.new()
	return builder.generate(location)


class GrowthBuilder extends RefCounted:
	var location: AlderwakeTerrainPreview
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var surfaces: Dictionary = {}
	var exclusions: Dictionary = {}
	var occupied: Dictionary = {}
	var doors: Array[PackedVector2Array] = []
	var foundations: Array[Dictionary] = []
	var count: int = 0
	var blades: int = 0
	var triangles: int = 0
	var counts: Dictionary = {"foundation":0, "bank":0, "field":0, "tree":0}

	func generate(owner: AlderwakeTerrainPreview) -> Node3D:
		location = owner
		rng.seed = 13102026
		var root: Node3D = Node3D.new()
		root.name = "MeadowGrowth"
		for outline: PackedVector2Array in location.town.footprints:
			_index_exclusion(outline)
		for outline: PackedVector2Array in location.forest.footprints:
			_index_exclusion(outline)
		for portal: Dictionary in location.layout.portals:
			var r: Array = portal.rect_xz_m
			doors.append(_rectangle(Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3])).grow(0.35)))
		_collect_foundations()
		_grow_foundations()
		_grow_banks()
		_grow_trees()
		_grow_field()
		var shader: Shader = Shader.new()
		shader.code = "shader_type spatial; render_mode cull_disabled; void fragment() { NORMAL = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz); ALBEDO = COLOR.rgb; ROUGHNESS = 1.0; SPECULAR = 0.0; }"
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		for key: Vector2i in surfaces:
			var visual: MeshInstance3D = MeshInstance3D.new()
			visual.name = "Grass_%d_%d" % [key.x, key.y]
			visual.mesh = (surfaces[key] as SurfaceTool).commit()
			visual.material_override = material
			visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			root.add_child(visual)
		var foundation_rects: Array = []
		var foundation_outlines: Array = []
		var door_exclusions: Array = []
		for foundation: Dictionary in foundations:
			var outline: PackedVector2Array = foundation.outline
			var bounds: Rect2 = Rect2(outline[0], Vector2.ZERO)
			var points: Array = []
			for p: Vector2 in outline:
				bounds = bounds.expand(p)
				points.append([p.x, p.y])
			foundation_rects.append([bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y])
			foundation_outlines.append(points)
		for outline: PackedVector2Array in doors:
			var points: Array = []
			for p: Vector2 in outline:
				points.append([p.x, p.y])
			door_exclusions.append(points)
		var inventory: Dictionary = {"clumps":count, "blades":blades, "triangles":triangles,
			"batches":surfaces.size(), "materials":1, "textures":0, "seed":13102026,
			"distribution":counts, "foundation_contacts":foundations.size(), "chunk_size_m":CHUNK_SIZE,
			"collision":false, "navigation":false, "opaque":true, "max_height_m":0.34,
			"foundation_rects":foundation_rects, "foundation_outlines":foundation_outlines, "door_exclusions":door_exclusions}
		root.set_meta("meadow_inventory", inventory)
		root.set_meta("meadow_growth_inventory", inventory)
		return root

	func _relative_transform(node: Node3D) -> Transform3D:
		# Construction runs before tree entry: global_transform is not available yet.
		var result: Transform3D = node.transform
		var parent: Node = node.get_parent()
		while parent != location and parent is Node3D:
			result = (parent as Node3D).transform * result
			parent = parent.get_parent()
		return result

	func _collect_foundations() -> void:
		for wrapper: Node in location.town.get_children():
			var definition: String = str(wrapper.get_meta("definition_id", ""))
			var building: bool = wrapper.has_meta("town_art_definition") and definition not in ["dock-junction", "dock-straight", "passenger-ship-sound", "heirloom-skiff"]
			var wall: bool = definition.begins_with("garden-wall-")
			if not building and not wall:
				continue
			var visual_root: Node = wrapper.get_node_or_null("VisualRoot")
			if visual_root == null:
				continue
			var vertices: PackedVector2Array = []
			for child: Node in visual_root.find_children("*", "MeshInstance3D", true, false):
				var visual: MeshInstance3D = child as MeshInstance3D
				var transform: Transform3D = _relative_transform(visual)
				# Detailed exteriors retain their established ground-contact mesh.
				var foundation_mesh: Mesh = visual.get_meta("meadow_foundation_mesh", visual.mesh)
				for surface_index: int in range(foundation_mesh.get_surface_count()):
					var arrays: Array = foundation_mesh.surface_get_arrays(surface_index)
					var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					for vertex: Vector3 in points:
						var p: Vector3 = transform * vertex
						var xz: Vector2 = Vector2(p.x, p.z)
						# Foundation vertices only: eaves, roof and decorative upper trim are excluded.
						if p.y <= location.elevation.height_at(xz) + 0.12:
							vertices.append(xz)
			if vertices.size() < 3:
				continue
			var hull: PackedVector2Array = Geometry2D.convex_hull(vertices)
			if hull.size() < 4:
				continue
			foundations.append({"outline":hull, "building":building})
			_index_exclusion(hull)
			if building:
				var inverse: Transform3D = (wrapper as Node3D).transform.affine_inverse()
				var low: Vector2 = Vector2(INF, INF)
				var high: Vector2 = Vector2(-INF, -INF)
				for p: Vector2 in hull:
					var local: Vector3 = inverse * Vector3(p.x, 0, p.y)
					low = low.min(Vector2(local.x, local.z))
					high = high.max(Vector2(local.x, local.z))
				# Existing imported buildings place their front door in this central facade lane.
				var door: PackedVector2Array = []
				for p: Vector2 in _rectangle(Rect2((low.x + high.x) * 0.5 - 0.68, high.y - 0.08, 1.36, 1.40)):
					var world: Vector3 = (wrapper as Node3D).transform * Vector3(p.x, 0, p.y)
					door.append(Vector2(world.x, world.z))
				doors.append(door)

	func _grow_foundations() -> void:
		for foundation: Dictionary in foundations:
			var outline: PackedVector2Array = foundation.outline
			for edge: int in range(outline.size() - 1):
				var a: Vector2 = outline[edge]
				var b: Vector2 = outline[edge + 1]
				var tangent: Vector2 = (b - a).normalized()
				var outward: Vector2 = Vector2(tangent.y, -tangent.x)
				if Geometry2D.is_point_in_polygon((a + b) * 0.5 + outward * 0.05, outline):
					outward = -outward
				var distance: float = rng.randf_range(0.06, 0.23)
				var phase: float = rng.randf_range(0.0, TAU)
				while distance < a.distance_to(b):
					var pocket: float = sin(distance * 3.9 + phase) * 0.5 + 0.5
					if rng.randf() < 0.55 + pocket * 0.43:
						var root: Vector2 = a + tangent * distance + outward * rng.randf_range(0.055, 0.16)
						_clump(root, rng.randf_range(0.19, 0.34), "foundation", outward)
						if pocket > 0.35 and rng.randf() < 0.68:
							_clump(root + outward * rng.randf_range(0.10, 0.25) + tangent * rng.randf_range(-0.08, 0.10), rng.randf_range(0.10, 0.23), "foundation", outward)
					distance += rng.randf_range(0.13, 0.26)

	func _grow_banks() -> void:
		var image: Image = location.landscape.mask_image
		var cell_size: Vector2 = location.bounds.size / Vector2(image.get_size())
		for y: int in range(1, image.get_height() - 1):
			for x: int in range(1, image.get_width() - 1):
				var cell: Vector2i = Vector2i(x, y)
				var color: Color = image.get_pixelv(cell)
				if roundi(color.r * 255.0) != 1 or color.a > 0.5:
					continue
				for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
					var neighbor: Color = image.get_pixelv(cell + direction)
					if roundi(neighbor.r * 255.0) not in [2, 4] or neighbor.a > 0.5 or rng.randf() > 0.35:
						continue
					var outward: Vector2 = Vector2(direction)
					var tangent: Vector2 = Vector2(-outward.y, outward.x)
					var root: Vector2 = location.bounds.position + (Vector2(cell) + Vector2.ONE * 0.5) * cell_size
					root += outward * rng.randf_range(0.10, 0.20) + tangent * rng.randf_range(-0.22, 0.22)
					_clump(root, rng.randf_range(0.11, 0.23), "bank", -outward)
					if rng.randf() < 0.30:
						_clump(root - outward * 0.16 + tangent * 0.13, rng.randf_range(0.08, 0.15), "bank", -outward)

	func _grow_trees() -> void:
		for record: Dictionary in location.forest.prop_records:
			if record.tree == null:
				continue
			var foot: Vector2 = Vector2(record.foot_xyz_m[0], record.foot_xyz_m[2])
			# Forest keeps open walking gaps. A few asymmetric root pockets replace rings.
			for pocket: int in range(rng.randi_range(1, 3)):
				var angle: float = rng.randf_range(0.0, TAU)
				var outward: Vector2 = Vector2(cos(angle), sin(angle))
				var root: Vector2 = foot + outward * rng.randf_range(0.32, 0.62)
				_clump(root, rng.randf_range(0.14, 0.24), "tree", outward)

	func _grow_field() -> void:
		var step: float = 1.70
		for row: int in range(ceili(location.bounds.size.y / step)):
			for column: int in range(ceili(location.bounds.size.x / step)):
				if rng.randf() > 0.27:
					continue
				var point: Vector2 = location.bounds.position + Vector2(column, row) * step + Vector2(rng.randf_range(0.12, 1.58), rng.randf_range(0.12, 1.58))
				if _surface_kind(point) != 1:
					continue
				_clump(point, rng.randf_range(0.08, 0.17), "field")
				if rng.randf() < 0.23:
					_clump(point + Vector2(rng.randf_range(-0.25, 0.25), rng.randf_range(-0.22, 0.22)), rng.randf_range(0.07, 0.13), "field")

	func _clump(point: Vector2, height: float, kind: String, outward: Vector2 = Vector2.ZERO) -> void:
		if count >= MAX_CLUMPS or triangles + 36 > MAX_TRIANGLES or not _clear(point):
			return
		var surface_kind: int = _surface_kind(point)
		if surface_kind not in [1, 2] or (kind != "foundation" and surface_kind != 1):
			return
		var cell: Vector2i = Vector2i(floori(point.x * 8.0), floori(point.y * 8.0))
		if occupied.has(cell):
			return
		occupied[cell] = true
		var batch: Vector2i = Vector2i(floori(point.x / CHUNK_SIZE), floori(point.y / CHUNK_SIZE))
		var surface: SurfaceTool = surfaces.get(batch) as SurfaceTool

		var palette: Color = PALETTE[rng.randi_range(0, PALETTE.size() - 1)]
		var root_color: Color = palette.darkened(0.25)
		var mid_color: Color = palette
		var tip_color: Color = palette.lerp(Color("c0cd59"), rng.randf_range(0.15, 0.48))
		var blade_count: int = rng.randi_range(8, 12) if kind == "foundation" else rng.randi_range(5, 8)
		var accepted: int = 0
		for blade: int in range(blade_count):
			var angle: float = rng.randf_range(0.0, TAU)
			var direction: Vector2 = Vector2(cos(angle), sin(angle))
			if outward != Vector2.ZERO:
				direction = (direction + outward * 1.25).normalized()
			var side: Vector2 = Vector2(-direction.y, direction.x)
			var foot: Vector2 = point + side * rng.randf_range(-0.045, 0.045)
			var broad: bool = blade % 4 == 0
			var blade_height: float = height * rng.randf_range(0.55, 1.0) * (0.58 if broad else 1.0)
			var lean: float = rng.randf_range(0.12, 0.24) if broad else rng.randf_range(0.055, 0.17)
			var width: float = rng.randf_range(0.035, 0.059) if broad else rng.randf_range(0.016, 0.034)
			var middle: Vector2 = foot + direction * lean * 0.35
			var tip: Vector2 = foot + direction * lean
			var xz: Array[Vector2] = [foot - side * width * 0.28, foot + side * width * 0.28,
				middle - side * width, middle + side * width, tip]
			var valid: bool = true
			var base_height: float = location.elevation.height_at(foot)
			for p: Vector2 in xz:
				if not _clear(p) or _surface_kind(p) not in [1, 2] or absf(location.elevation.height_at(p) - base_height) > 0.08:
					valid = false
					break
			if not valid:
				continue
			if surface == null:
				surface = SurfaceTool.new()
				surface.begin(Mesh.PRIMITIVE_TRIANGLES)
				surfaces[batch] = surface
			var points: Array[Vector3] = []
			var heights: Array[float] = [0.010, 0.010, blade_height * 0.53, blade_height * 0.53, blade_height]
			var colors: Array[Color] = [root_color, root_color, mid_color, mid_color, tip_color]
			for index: int in range(5):
				points.append(Vector3(xz[index].x, location.elevation.height_at(xz[index]) + heights[index], xz[index].y))
			for index: int in [0, 2, 1, 1, 2, 3, 2, 4, 3]:
				surface.set_normal(Vector3.UP)
				# Match ground albedo's calibrated linear authoring convention once.
				surface.set_color(colors[index].srgb_to_linear())
				surface.add_vertex(points[index])
			accepted += 1
		if accepted > 0:
			count += 1
			counts[kind] += 1
			blades += accepted
			triangles += accepted * 3

	func _surface_kind(point: Vector2) -> int:
		if not location.bounds.grow(-0.20).has_point(point):
			return 0
		var image: Image = location.landscape.mask_image
		var sample: Vector2i = Vector2i((point - location.bounds.position) / location.bounds.size * Vector2(image.get_size()))
		var color: Color = image.get_pixelv(sample)
		return 0 if color.a > 0.5 else roundi(color.r * 255.0)

	func _index_exclusion(outline: PackedVector2Array) -> void:
		if outline.is_empty():
			return
		var bounds: Rect2 = Rect2(outline[0], Vector2.ZERO)
		for p: Vector2 in outline:
			bounds = bounds.expand(p)
		for y: int in range(floori(bounds.position.y / 4.0), floori(bounds.end.y / 4.0) + 1):
			for x: int in range(floori(bounds.position.x / 4.0), floori(bounds.end.x / 4.0) + 1):
				var cell: Vector2i = Vector2i(x, y)
				if not exclusions.has(cell):
					exclusions[cell] = []
				exclusions[cell].append(outline)

	func _clear(point: Vector2) -> bool:
		for door: PackedVector2Array in doors:
			if Geometry2D.is_point_in_polygon(point, door):
				return false
		var cell: Vector2i = Vector2i(floori(point.x / 4.0), floori(point.y / 4.0))
		for outline: PackedVector2Array in exclusions.get(cell, []):
			if Geometry2D.is_point_in_polygon(point, outline):
				return false
		return true

	func _rectangle(rect: Rect2) -> PackedVector2Array:
		return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])

