// World-space meadow paint and irregular shoulders. Appearance only.
uniform bool meadow_enabled = false;
uniform sampler2D meadow_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D meadow_context : filter_linear, repeat_disable;

vec3 meadow_linear(vec3 color) {
    if (OUTPUT_IS_SRGB) return mix(color / 12.92, pow((color + vec3(0.055)) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
    return color;
}

vec3 meadow_paint(vec2 p) {
    // Two incommensurate scales hide repeated brush groups without blurring them.
    vec2 uv = p / 7.2;
    vec3 a = meadow_linear(texture(meadow_albedo, uv, 0.35).rgb);
    vec3 b = meadow_linear(texture(meadow_albedo, mat2(vec2(0.8,0.6),vec2(-0.6,0.8)) * uv * 0.73 + vec2(0.37,0.61), 0.35).rgb);
    vec3 paint = mix(a, b, 0.24);
    // A quiet olive wash keeps fine dabs subordinate at gameplay scale.
    return mix(vec3(0.295, 0.355, 0.072), paint, 0.72) * vec3(1.23, 1.14, 3.35);
}
