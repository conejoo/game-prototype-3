// Painted compact earth. World-space albedo only; no geometry or time dependency.
uniform bool dirt_paint_enabled = false;
uniform sampler2D dirt_painted_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;

vec3 dirt_linear(vec3 color) {
    if (OUTPUT_IS_SRGB) return mix(color / 12.92, pow((color + vec3(0.055)) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
    return color;
}

vec3 dirt_path_paint(vec2 p) {
    vec2 uv = (p + vec2(3.17, 8.43)) / 7.0;
    vec3 primary = dirt_linear(texture(dirt_painted_albedo, uv, 0.10).rgb);
    vec2 alternate_uv = mat2(vec2(0.8,0.6), vec2(-0.6,0.8)) * uv * 0.71 + vec2(0.29,0.63);
    vec3 alternate = dirt_linear(texture(dirt_painted_albedo, alternate_uv, 0.10).rgb);
    // Preserve short brush marks while disrupting recognizable tile repetition.
    vec3 paint = mix(primary, alternate, 0.18);
    // Compress ochre/cream flecks around the source's linear median. Calibrated
    // in the daylight renderer against the concept's softly painted earth.
    paint = mix(vec3(0.973445, 0.485150, 0.102242), paint, vec3(0.55, 0.75, 0.75));
    return paint * vec3(0.634, 1.004, 2.62);
}
