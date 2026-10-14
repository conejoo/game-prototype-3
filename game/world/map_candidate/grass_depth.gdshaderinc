// GD002: authored local contact darkening, not dynamic physical occlusion.
uniform bool grass_depth_grounding_enabled = false;

float depth_base_band(vec2 p, float x0, float x1, float z, float width) {
    // Signed outward distance: no shading behind the actual facade/stone face.
    float outward = p.y - z;
    if (outward < 0.0 || outward >= width) return 0.0;
    float ends = smoothstep(x0 - 0.08, x0 + 0.12, p.x) * (1.0 - smoothstep(x1 - 0.12, x1 + 0.08, p.x));
    return ends * (1.0 - smoothstep(0.0, width, outward));
}
vec3 grass_depth_ground(vec3 world, vec3 normal, int surface_kind, vec3 color) {
    if (!grass_depth_grounding_enabled || normal.y < 0.95 || abs(world.y) > 0.025 || (surface_kind != 1 && surface_kind != 2)) return color;
    vec2 p = world.xz;
    if (p.x < -20.0 || p.x > 0.0 || p.y < -3.0 || p.y > 14.0) return color;
    // Imported south base Z1.84375. Central door/approach stays clear.
    float facade = max(depth_base_band(p, -18.8, -17.3, 1.84375, 0.30), depth_base_band(p, -14.8, -13.3, 1.84375, 0.30));
    // South wall face is on existing dirt, with visible ground roots at Y0.
    float wall = depth_base_band(p, -18.0, -14.0, 4.96875, 0.25);
    return color * (1.0 - max(facade * 0.34, wall * 0.38));
}
