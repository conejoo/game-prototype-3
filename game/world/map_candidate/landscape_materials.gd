class_name AlderwakeLandscapeMaterials
extends RefCounted
## Appearance only. Semantic half-metre mask is never physics/nav input.

const TERRAIN_SHADER: Shader = preload("res://world/map_candidate/landscape.gdshader")
const WATER_SHADER: Shader = preload("res://world/map_candidate/river.gdshader")
const STONE_ATLAS: Texture2D = preload("res://assets/environment/storybook/dock-painted-albedo.png")
const GRASS_PILOT: Script = preload("res://world/map_candidate/grass_pilot_material.gd")
const MEADOW_TEXTURE: Texture2D = preload("res://assets/environment/storybook/grass-meadow-albedo-v3.png")
const DIRT_TEXTURE: Texture2D = preload("res://assets/environment/storybook/dirt-path-albedo-v1.png")
const KINDS: Dictionary[String, int] = {"grass": 1, "dirt": 2, "sand": 3, "cobblestone": 4, "wet_shoreline": 5, "raw-marker": 6}
const COLORS: Dictionary[String, Color] = {
	"grass": Color("949f68"), "dirt": Color("e1bf94"),
	"sand": Color(0.82, 0.71, 0.43), "cobblestone": Color(0.48, 0.47, 0.40),
	"wet_shoreline": Color("768064"), "raw-marker": Color(0.43, 0.49, 0.21),
}
var mask: ImageTexture
var mask_image: Image
var bounds: Rect2
var pilot_layout: Dictionary = {}
var meadow_context: ImageTexture
var meadow_context_image: Image


static func meadow_active() -> bool:
	return GRASS_PILOT.command_variant().is_empty() and "--meadow=off" not in OS.get_cmdline_user_args()


func build(layout: Dictionary, water: AlderwakeWaterBlockers, map_bounds: Rect2) -> void:
	bounds = map_bounds
	pilot_layout = layout
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
	meadow_context_image = Image.create(588, 320, false, Image.FORMAT_RG8)
	for z: int in range(320):
		for x: int in range(588):
			var semantic: Color = mask_image.get_pixel(x / 2, z / 2)
			meadow_context_image.set_pixel(x, z, Color(1.0 if roundi(semantic.r * 255.0) == 1 and semantic.a < 0.5 else 0.0, 0, 0))
	meadow_context = ImageTexture.create_from_image(meadow_context_image)


func configure_meadow_contacts(outlines: Array) -> void:
	# Narrow visual occlusion follows measured stone bases, never collision padding.
	var pixels_per_metre: Vector2 = Vector2(meadow_context_image.get_size()) / bounds.size
	for values: Array in outlines:
		var outline: PackedVector2Array = []
		for point: Array in values: outline.append(Vector2(point[0], point[1]))
		var rect: Rect2 = Rect2(outline[0], Vector2.ZERO)
		for point: Vector2 in outline: rect = rect.expand(point)
		var low: Vector2i = Vector2i((rect.position - Vector2.ONE * .65 - bounds.position) * pixels_per_metre).max(Vector2i.ZERO)
		var high: Vector2i = Vector2i((rect.end + Vector2.ONE * .65 - bounds.position) * pixels_per_metre).min(meadow_context_image.get_size() - Vector2i.ONE)
		for z: int in range(low.y, high.y + 1):
			for x: int in range(low.x, high.x + 1):
				var point: Vector2 = bounds.position + (Vector2(x,z) + Vector2.ONE * .5) / pixels_per_metre
				var distance: float = 1.0
				for edge: int in range(outline.size() - 1):
					distance = minf(distance, point.distance_to(Geometry2D.get_closest_point_to_segment(point, outline[edge], outline[edge + 1])))
				var contact: float = 1.0 - smoothstep(.02, .52, distance)
				var value: Color = meadow_context_image.get_pixel(x,z)
				value.g = maxf(value.g, contact)
				meadow_context_image.set_pixel(x,z,value)
	meadow_context.update(meadow_context_image)


func terrain(kind: String) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = TERRAIN_SHADER
	# Supply calibrated painted colors in linear form. Keep legacy kinds
	# unchanged; convert only new painted authoring sRGB swatches once.
	material.set_shader_parameter("base_color", COLORS[kind].srgb_to_linear() if kind in ["grass", "dirt", "wet_shoreline"] else COLORS[kind])
	material.set_shader_parameter("kind", KINDS[kind])
	material.set_shader_parameter("meadow_color", COLORS.grass.srgb_to_linear())
	if kind == "cobblestone": material.set_shader_parameter("painted_stone_atlas", STONE_ATLAS)
	_common(material)
	material.set_shader_parameter("meadow_enabled", meadow_active())
	material.set_shader_parameter("meadow_albedo", MEADOW_TEXTURE)
	material.set_shader_parameter("meadow_context", meadow_context)
	material.set_shader_parameter("dirt_paint_enabled", kind == "dirt" and "--dirt=original" not in OS.get_cmdline_user_args())
	if kind == "dirt":
		material.set_shader_parameter("dirt_painted_albedo", DIRT_TEXTURE)
	if kind == "grass": GRASS_PILOT.apply(material, pilot_layout, bounds, mask_image, GRASS_PILOT.command_variant())
	# Depth is opt-in, and only accompanies the pinned A pilot.
	material.set_shader_parameter("grass_depth_grounding_enabled", GRASS_PILOT.command_variant() == "a" and ("--grass-depth=grounding" in OS.get_cmdline_user_args() or "--grass-depth=edges" in OS.get_cmdline_user_args() or "--grass-depth=tufts" in OS.get_cmdline_user_args()))
	return material


static func painted_riser() -> ShaderMaterial:
	# One resource shared by every existing riser chunk; geometry stays untouched.
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = TERRAIN_SHADER
	material.set_shader_parameter("base_color", Color("8b8c7b").srgb_to_linear())
	material.set_shader_parameter("kind", 7)
	return material


func river() -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = WATER_SHADER
	# Authoring sRGB swatches converted once, like accepted painted ground.
	material.set_shader_parameter("water_color", Color("429c93").srgb_to_linear())
	material.set_shader_parameter("stroke_color", Color("87c7b7").srgb_to_linear())
	material.set_shader_parameter("bank_color", Color("6d8063").srgb_to_linear())
	_common(material)
	return material


func _common(material: ShaderMaterial) -> void:
	material.set_shader_parameter("semantic_mask", mask)
	material.set_shader_parameter("map_origin", bounds.position)
	material.set_shader_parameter("map_size", bounds.size)
