// Grass visual pilot. Inactive unless explicitly configured; no physics input.
uniform bool grass_pilot_enabled = false;
uniform sampler2D grass_pilot_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_pilot_context : filter_linear, repeat_disable;
uniform vec4 grass_pilot_rect = vec4(-20.0, -3.0, 20.0, 17.0);
uniform float grass_pilot_tile_metres = 8.0;
uniform float grass_pilot_blend = 1.0;
uniform float grass_pilot_saturation = 0.90;
uniform float grass_pilot_edge_detail = 0.30;
uniform float grass_pilot_value = 1.0;
uniform float grass_pilot_contrast = 1.0;
uniform float grass_pilot_filter_bias = 0.0;

vec3 grass_pilot_sample(vec2 uv) {
    vec3 color = texture(grass_pilot_albedo, uv, grass_pilot_filter_bias).rgb;
    // Compatibility keeps texture samples in sRGB. Existing painted ground
    // authoring colors are supplied in linear form; match that convention.
    if (OUTPUT_IS_SRGB) {
        color = mix(color / 12.92, pow((color + vec3(0.055)) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
    }
    return color;
}
vec3 grass_pilot_paint(vec2 p, vec3 old_color) {
    vec2 local = p - grass_pilot_rect.xy;
    vec2 to_edge = min(local, grass_pilot_rect.zw - local);
    float inside = smoothstep(0.0, 0.6, min(to_edge.x, to_edge.y));
    if (!grass_pilot_enabled || inside <= 0.0) return old_color;
    vec2 uv = (p + vec2(2.37, 4.81)) / grass_pilot_tile_metres;
    vec3 paint = grass_pilot_sample(uv);
    float edge = texture(grass_pilot_context, local / grass_pilot_rect.zw).r;
    // A second shared botanical sample increases cluster density only at edges.
    vec3 edge_paint = grass_pilot_sample(uv * 1.43 + vec2(0.31, 0.57));
    paint = mix(paint, edge_paint, edge * grass_pilot_edge_detail);
    // User softness revision: lift dark marks and restrain bright dabs while
    // retaining the same botanical texture, scale and original-look path.
    paint = mix(vec3(0.29, 0.36, 0.10), paint, grass_pilot_contrast);
    float value = dot(paint, vec3(0.2126, 0.7152, 0.0722));
    paint = mix(vec3(value), paint, grass_pilot_saturation);
    paint *= grass_pilot_value * (1.0 - edge * 0.055);
    return mix(old_color, paint, inside * grass_pilot_blend);
}
