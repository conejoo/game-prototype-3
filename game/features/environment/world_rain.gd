class_name WorldRain
extends Node3D
## Location-owned fixed world tiles; no processing, timer, listener or save facts.

class RainBatchData:
	extends RefCounted
	var transforms: Array[Transform3D] = []
	var custom: Array[Color] = []

const TILE_SIZE: float = 16.0
const COLUMNS: int = 24
const MAX_BATCHES: int = 64
const COLUMN_MARGIN: float = .05
const SHADER: Shader = preload("res://features/environment/world_rain.gdshader")
var material: ShaderMaterial
var mesh: QuadMesh
var batches: Dictionary[Vector2i, MultiMeshInstance3D] = {}
var shelters: Array[Rect2] = []
var bounds: Rect2
var elevation: AlderwakeElevationSurfaces
var selection_error: String = ""
var amount: float = 0.0
var phase_seconds: float = 0.0


func build(location: AlderwakeTerrainPreview) -> void:
	name = "WorldRain"
	bounds = location.bounds
	elevation = location.elevation
	# Imported building bounds include actual roof overhang, unlike source collider footprints.
	for visual: Node in location.town.find_children("ImportedExterior", "MeshInstance3D", true, false):
		var instance: MeshInstance3D = visual as MeshInstance3D
		var transform_to_room: Transform3D = _relative_transform(instance, location)
		var box: AABB = transform_to_room * instance.get_aabb()
		shelters.append(Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(.12))
	material = ShaderMaterial.new()
	material.shader = SHADER
	mesh = QuadMesh.new()
	mesh.size = Vector2(.045, .44)
	# Bottom of every streak remains above its independently sampled physical floor.
	mesh.center_offset = Vector3(0, .22, 0)
	mesh.material = material


static func _relative_transform(node: Node3D, ancestor: Node3D) -> Transform3D:
	var result: Transform3D = node.transform
	var parent: Node = node.get_parent()
	while parent != ancestor and parent is Node3D:
		result = (parent as Node3D).transform * result
		parent = parent.get_parent()
	return result


func sheltered(point: Vector2) -> bool:
	for roof: Rect2 in shelters:
		if roof.has_point(point):
			return true
	return false


static func column(tile: Vector2i, index: int) -> Vector2:
	var cell: Vector2i = tile * COLUMNS + Vector2i(index % COLUMNS, floori(float(index) / COLUMNS))
	var hash_index: int = WeatherSchedule.multiply_low32(cell.x & 0xffffffff, 73856093) ^ WeatherSchedule.multiply_low32(cell.y & 0xffffffff, 19349663)
	var hash_value: int = WeatherSchedule.mix(0x735ac921, hash_index, 0x4187c361)
	# Jitter independently within each cell; equal spacing/density at tile boundaries.
	var jitter: Vector2 = Vector2(.15 + .7 * float(hash_value & 65535) / 65535.0, .15 + .7 * float(hash_value >> 16) / 65535.0)
	return (Vector2(cell) + jitter) * (TILE_SIZE / COLUMNS)


func visible_rect(camera: Camera3D) -> Rect2:
	var size: Vector2 = camera.get_viewport().get_visible_rect().size
	var points: PackedVector2Array = []
	# Project both bottom and top of rain volume, including raised hills.
	for height: float in [0.0, 8.6]:
		for corner: Vector2 in [Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)]:
			var origin: Vector3 = camera.project_ray_origin(corner)
			var direction: Vector3 = camera.project_ray_normal(corner)
			if direction.y >= -.001:
				continue
			var distance: float = (height - origin.y) / direction.y
			var point: Vector3 = origin + direction * maxf(0.0, distance)
			points.append(Vector2(point.x, point.z))
	if points.is_empty():
		return Rect2()
	var rect: Rect2 = Rect2(points[0], Vector2.ZERO)
	for point: Vector2 in points:
		rect = rect.expand(point)
	return rect.grow(2.0).intersection(bounds)


func present(sample: WeatherVisuals.Sample, camera: Camera3D) -> void:
	amount = sample.rain
	phase_seconds = sample.phase_seconds
	visible = amount > 0.0
	material.set_shader_parameter("rain_amount", amount)
	material.set_shader_parameter("session_phase", phase_seconds)
	var right: Vector3 = camera.global_basis.x
	right.y = 0.0
	material.set_shader_parameter("camera_right", right.normalized())
	# Retain existing bounded tiles during dry spells; never create invisible rain.
	if not visible:
		return
	select_tiles(visible_rect(camera))


func select_tiles(rect: Rect2) -> void:
	var required: Array[Vector2i] = []
	if rect.has_area():
		for z: int in range(floori(rect.position.y / TILE_SIZE), ceili(rect.end.y / TILE_SIZE)):
			for x: int in range(floori(rect.position.x / TILE_SIZE), ceili(rect.end.x / TILE_SIZE)):
				required.append(Vector2i(x, z))
	if required.size() > MAX_BATCHES:
		selection_error = "rain frustum exceeds fixed 64-batch bound"
		return
	selection_error = ""
	# Retire before adding: even transient resource count remains bounded.
	for key: Vector2i in batches.keys():
		if key not in required:
			var old: MultiMeshInstance3D = batches[key]
			remove_child(old)
			old.free()
			batches.erase(key)
	for key: Vector2i in required:
		if not batches.has(key):
			_build_tile(key)


func tile_data(tile: Vector2i) -> RainBatchData:
	var data: RainBatchData = RainBatchData.new()
	for index: int in range(COLUMNS * COLUMNS):
		var point: Vector2 = column(tile, index)
		if not bounds.has_point(point) or sheltered(point):
			continue
		var floor_height: float = elevation.height_at(point) + COLUMN_MARGIN
		var hash_value: int = WeatherSchedule.mix(0x735ac921, tile.x * 4096 + tile.y * 64 + index, 0x387a6159)
		data.transforms.append(Transform3D(Basis.IDENTITY, Vector3(point.x, floor_height, point.y)))
		data.custom.append(Color(float(hash_value & 65535) / 65536.0, float(hash_value >> 16) / 65536.0 * .88, 0, 1))
	return data


func _build_tile(tile: Vector2i) -> void:
	var data: RainBatchData = tile_data(tile)
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_custom_data = true
	multi.mesh = mesh
	multi.instance_count = data.transforms.size()
	for index: int in range(data.transforms.size()):
		multi.set_instance_transform(index, data.transforms[index])
		multi.set_instance_custom_data(index, data.custom[index])
	# Shader displacement requires explicit volume; no rain shadows or collision.
	multi.custom_aabb = AABB(Vector3(tile.x * TILE_SIZE - .1, 0, tile.y * TILE_SIZE - .1), Vector3(TILE_SIZE + .2, 9, TILE_SIZE + .2))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Rain_%d_%d" % [tile.x, tile.y]
	instance.multimesh = multi
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)
	batches[tile] = instance
