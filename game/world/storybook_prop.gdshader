shader_type spatial;
render_mode cull_disabled;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 base_color : source_color = vec4(1.0);
uniform bool vertex_palette = false;
uniform float metallic = 0.0;
uniform vec4 glow : source_color = vec4(0.0,0.0,0.0,1.0);
uniform float glow_energy = 0.0;
varying vec3 local_position;
varying vec3 local_normal;
void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}
vec3 brush(vec2 plane) {
	// Mirror one existing plaster patch at64texels/m, inside16px gutters.
	// Continuous fold avoids repeat seams; original no-UV meshes get all-face paint.
	vec2 folded = 1.0 - abs(mod(plane * 64.0 / 480.0 + vec2(0.35,0.45), 2.0) - 1.0);
	return texture(painted_atlas, (vec2(16.0) + folded * 480.0) / 1024.0).rgb;
}
void fragment() {
	vec3 weights = pow(abs(normalize(local_normal)), vec3(4.0));
	weights /= max(weights.x + weights.y + weights.z, 0.0001);
	vec3 paint = brush(local_position.zy) * weights.x + brush(local_position.xz) * weights.y + brush(local_position.xy) * weights.z;
	// Atlas contributes broad brush value only; existing role palette remains authority.
	float value = dot(paint, vec3(0.2126,0.7152,0.0722));
	float stroke = clamp(1.0 + (value - 0.60) * 0.8, 0.82, 1.16);
	vec3 palette = base_color.rgb * (vertex_palette ? COLOR.rgb : vec3(1.0));
	ALBEDO = palette * stroke;
	ROUGHNESS = 0.92;
	METALLIC = metallic;
	EMISSION = glow.rgb * glow_energy;
}
