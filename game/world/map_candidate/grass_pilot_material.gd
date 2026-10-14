extends RefCounted
## Bounded, opt-in grass appearance pilot. Original material remains default.
const TEXTURE_PATH: String = "res://assets/environment/storybook/grass-pilot-albedo-v1.png"
const PAINTERLY_TEXTURE_PATH: String = "res://assets/environment/storybook/grass-painterly-albedo-v2.png"
const RECT: Rect2 = Rect2(-20.0, -3.0, 20.0, 17.0)
const VARIANTS: Dictionary = {
    "a": {"label":"A - restrained meadow", "tile":6.0, "blend":0.82, "saturation":0.80, "edge":0.12, "value":1.0},
    "b": {"label":"B - painted meadow", "tile":8.0, "blend":1.0, "saturation":0.90, "edge":0.30, "value":1.0},
    "c": {"label":"C - lush edges", "tile":10.0, "blend":1.0, "saturation":0.94, "edge":0.48, "value":1.0},
}

static func command_variant() -> String:
    for argument: String in OS.get_cmdline_user_args():
        if argument.begins_with("--grass-pilot="):
            var candidate: String = argument.trim_prefix("--grass-pilot=")
            return candidate if VARIANTS.has(candidate) else ""
    return ""

static func apply(material: ShaderMaterial, layout: Dictionary, map_bounds: Rect2, semantic_image: Image, variant: String, original_look: bool = false) -> void:
    material.set_shader_parameter("grass_pilot_enabled", false)
    material.set_shader_parameter("grass_pilot_contrast", 1.0)
    material.set_shader_parameter("grass_pilot_filter_bias", 0.0)
    if not VARIANTS.has(variant): return
    material.set_shader_parameter("meadow_enabled", false)
    var settings: Dictionary = VARIANTS[variant]
    original_look = original_look or "--grass-look=original" in OS.get_cmdline_user_args()
    var painterly: bool = variant == "a" and not original_look
    if painterly:
        material.set_shader_parameter("grass_pilot_contrast", 0.60)
        material.set_shader_parameter("grass_pilot_filter_bias", 0.15)
    material.set_shader_parameter("grass_pilot_albedo", load(PAINTERLY_TEXTURE_PATH if painterly else TEXTURE_PATH))
    material.set_shader_parameter("grass_pilot_context", _context(layout, map_bounds, semantic_image))
    material.set_shader_parameter("grass_pilot_rect", Vector4(RECT.position.x, RECT.position.y, RECT.size.x, RECT.size.y))
    material.set_shader_parameter("grass_pilot_tile_metres", settings.tile)
    material.set_shader_parameter("grass_pilot_blend", settings.blend)
    material.set_shader_parameter("grass_pilot_saturation", settings.saturation)
    material.set_shader_parameter("grass_pilot_edge_detail", settings.edge)
    material.set_shader_parameter("grass_pilot_value", settings.value)
    material.set_shader_parameter("grass_pilot_enabled", true)

static func _context(layout: Dictionary, map_bounds: Rect2, semantic_image: Image) -> ImageTexture:
    var foundations: Array[Rect2] = []
    var trunks: Array[Vector2] = []
    for record: Dictionary in layout.props:
        var point: Vector2 = Vector2(record.foot_xyz_m[0], record.foot_xyz_m[2])
        if record.tree != null and RECT.grow(2.0).has_point(point): trunks.append(point)
        if record.collision != null and record.collision.has("rect_xz_m"):
            var r: Array = record.collision.rect_xz_m
            var footprint: Rect2 = Rect2(r[0], r[1], r[2], r[3])
            if RECT.grow(2.0).intersects(footprint): foundations.append(footprint)
    var image: Image = Image.create(128, 128, false, Image.FORMAT_R8)
    for y: int in range(128):
        for x: int in range(128):
            var point: Vector2 = RECT.position + (Vector2(x, y) + Vector2.ONE * 0.5) / 128.0 * RECT.size
            var nearest: float = 2.0
            for footprint: Rect2 in foundations:
                var outside: Vector2 = (footprint.position - point).max(point - footprint.end).max(Vector2.ZERO)
                nearest = minf(nearest, outside.length())
            for trunk: Vector2 in trunks: nearest = minf(nearest, maxf(0.0, point.distance_to(trunk) - 0.3))
            var edge: float = 1.0 - smoothstep(0.15, 1.25, nearest)
            for offset: Vector2 in [Vector2(.5,0), Vector2(-.5,0), Vector2(0,.5), Vector2(0,-.5)]:
                var sample: Vector2i = Vector2i((point + offset - map_bounds.position) / map_bounds.size * Vector2(semantic_image.get_size()))
                if Rect2i(Vector2i.ZERO, semantic_image.get_size()).has_point(sample):
                    var kind: int = roundi(semantic_image.get_pixelv(sample).r * 255.0)
                    if kind in [2, 4]: edge = maxf(edge, 0.8)
            image.set_pixel(x, y, Color(edge, edge, edge))
    return ImageTexture.create_from_image(image)
