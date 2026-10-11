shader_type spatial;
render_mode cull_disabled;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
varying vec3 world_position;
varying vec3 world_normal;
void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
	// Same64 texels/m as module UVs. Dominant-plane projection covers closed
	// exact prisms; joins are local mortar, with no baked directional sun shade.
	vec2 face = abs(world_normal.y) > 0.8 ? world_position.xz : (abs(world_normal.x) > abs(world_normal.z) ? world_position.zy : world_position.xy);
	vec2 extent = vec2(992.0,480.0);
	vec2 pixel = vec2(16.0,528.0) + fract(face * 64.0 / extent) * extent;
	ALBEDO = texture(painted_atlas,pixel/1024.0).rgb;
	ROUGHNESS = 0.97;
}
