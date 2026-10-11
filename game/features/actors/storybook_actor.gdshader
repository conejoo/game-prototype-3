shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec3 source_emission : source_color = vec3(0.0);
uniform float source_metallic = 0.0;
uniform float surface_roughness = 0.94;
uniform float role_fill = 0.0;
varying vec3 rest_position;
varying vec3 rest_normal;
void vertex() {
	rest_position = VERTEX;
	rest_normal = NORMAL;
}
float brush(vec2 plane) {
	// Plaster value from existing atlas, mirrored inside its 16px gutters.
	vec2 folded = 1.0 - abs(mod(plane * 96.0 / 480.0 + vec2(0.35,0.45), 2.0) - 1.0);
	vec3 paint = texture(painted_atlas, (vec2(16.0) + folded * 480.0) / 1024.0).rgb;
	return dot(paint, vec3(0.2126,0.7152,0.0722));
}
void fragment() {
	vec3 weights = pow(abs(normalize(rest_normal)), vec3(4.0));
	weights /= max(weights.x + weights.y + weights.z, 0.0001);
	float value = brush(rest_position.zy) * weights.x + brush(rest_position.xz) * weights.y + brush(rest_position.xy) * weights.z;
	float stroke = clamp(1.0 + (value - 0.60) * 0.65, 0.90, 1.08);
	ALBEDO = base_color.rgb * stroke;
	ROUGHNESS = surface_roughness;
	METALLIC = source_metallic;
	SPECULAR = 0.25;
	// Small capsule role fill supports night readability; guardian core stays exact.
	EMISSION = source_emission + base_color.rgb * role_fill;
}
