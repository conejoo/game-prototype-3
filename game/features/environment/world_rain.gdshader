shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;
uniform float session_phase = 0.0;
uniform float rain_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 camera_right = vec3(1.0, 0.0, 0.0);
varying float drop_alpha;
void vertex() {
	// Fixed world X/Z origins. Animation changes only height; no wall clock or camera offset.
	float cycle = fract(INSTANCE_CUSTOM.r - session_phase / 1.6);
	float height = cycle * 6.4;
	VERTEX = camera_right * VERTEX.x + vec3(0.0, height + VERTEX.y, 0.0);
	float selection = smoothstep(INSTANCE_CUSTOM.g, INSTANCE_CUSTOM.g + 0.12, rain_amount);
	drop_alpha = selection * smoothstep(0.0, 0.24, height) * (1.0 - smoothstep(5.8, 6.4, height));
}
void fragment() {
	float edge = 1.0 - abs(UV.x * 2.0 - 1.0);
	float taper = sin(UV.y * 3.14159265);
	ALBEDO = vec3(0.60, 0.75, 0.86);
	ALPHA = edge * taper * drop_alpha * 0.48;
}
