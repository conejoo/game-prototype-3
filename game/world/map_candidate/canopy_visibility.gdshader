shader_type spatial;
render_mode cull_back;
uniform vec4 base_color : source_color = vec4(1.0);
uniform float surface_roughness = 0.9;
uniform vec3 hero_center;
uniform vec3 ally_center;
uniform bool protect_party = false;
uniform mat4 camera_view;
uniform mat4 camera_projection;
varying flat float main_view;
varying vec3 world_position;
void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    main_view = distance(INV_VIEW_MATRIX[3].xyz, MAIN_CAM_INV_VIEW_MATRIX[3].xyz) < 0.01 ? 1.0 : 0.0;
}
bool covers_subject(vec3 subject, vec3 fragment_view) {
    vec3 subject_view = (camera_view * vec4(subject, 1.0)).xyz;
    if (fragment_view.z <= subject_view.z + 0.45 || subject_view.z >= 0.0) return false;
    vec4 subject_clip = camera_projection * vec4(subject_view, 1.0);
    vec4 fragment_clip = camera_projection * vec4(fragment_view, 1.0);
    vec4 edge_clip = camera_projection * vec4(subject_view + vec3(0.95, 0.0, 0.0), 1.0);
    float radius = abs(edge_clip.x / edge_clip.w - subject_clip.x / subject_clip.w);
    vec2 offset = fragment_clip.xy / fragment_clip.w - subject_clip.xy / subject_clip.w;
    // Projection's X/Y scales account for viewport aspect ratio.
    offset.y *= camera_projection[0][0] / camera_projection[1][1];
    return length(offset) < radius;
}
void fragment() {
    // Keep authored tree shadows: only the main camera's art pass cuts holes.
    vec3 fragment_view = (camera_view * vec4(world_position, 1.0)).xyz;
    if (protect_party && main_view > 0.5 && (covers_subject(hero_center, fragment_view) || covers_subject(ally_center, fragment_view))) discard;
    ALBEDO = COLOR.rgb * base_color.rgb;
    ROUGHNESS = surface_roughness;
}
