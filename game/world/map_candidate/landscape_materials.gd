class_name AlderwakeLandscapeMaterials
extends RefCounted
## M011 appearance only. Semantic half-metre mask is never physics/nav input.

const TERRAIN_SHADER: Shader = preload("res://world/map_candidate/landscape.gdshader")
const WATER_SHADER: Shader = preload("res://world/map_candidate/river.gdshader")
const KINDS: Dictionary[String, int] = {"grass": 1, "dirt": 2, "sand": 3, "cobblestone": 4, "wet_shoreline": 5, "raw-marker": 6}
const COLORS: Dictionary[String, Color] = {
	"grass": Color(0.36, 0.46, 0.18), "dirt": Color(0.64, 0.46, 0.25),
	"sand": Color(0.82, 0.71, 0.43), "cobblestone": Color(0.48, 0.47, 0.40),
	"wet_shoreline": Color(0.32, 0.38, 0.17), "raw-marker": Color(0.43, 0.49, 0.21),
}
var mask: ImageTexture
var mask_image: Image
var bounds: Rect2


func build(layout: Dictionary, water: AlderwakeWaterBlockers, map_bounds: Rect2) -> void:
	bounds = map_bounds
	mask_image = Image.create(294, 160, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color(1.0 / 255.0, 0, 0, 0))
	# Resolve defaults/clears independently, matching the retained terrain layer.
	for layer: Dictionary in layout.tile_layers:
		if layer.id != "terrain" or not layer.visible:
			continue
		var overrides: Dictionary[Vector2i, Variant] = {}
		for record: Dictionary in layer.cells:
			overrides[Vector2i(record.cell[0], record.cell[1])] = record.paint
		for z: int in range(160):
			for x: int in range(294):
				var paint: Variant = overrides.get(Vector2i(x, z), layer.default_paint)
				if paint != null and paint.material != "water":
					mask_image.set_pixel(x, z, Color(float(KINDS[paint.material]) / 255.0, 0, 0, 0))
	# Effective union includes the approved dock exception; paint cannot fill a
	# crossing. Exact mask edges align with the separate authored water mesh.
	for cell: Vector2i in water.water_cells:
		var value: Color = mask_image.get_pixelv(cell)
		value.a = 1.0
		mask_image.set_pixelv(cell, value)
	mask = ImageTexture.create_from_image(mask_image)


func terrain(kind: String) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = TERRAIN_SHADER
	material.set_shader_parameter("base_color", COLORS[kind])
	material.set_shader_parameter("kind", KINDS[kind])
	_common(material)
	return material


func river() -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = WATER_SHADER
	_common(material)
	return material


func _common(material: ShaderMaterial) -> void:
	material.set_shader_parameter("semantic_mask", mask)
	material.set_shader_parameter("map_origin", bounds.position)
	material.set_shader_parameter("map_size", bounds.size)
