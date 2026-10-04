shader_type spatial;
render_mode cull_disabled;

uniform sampler2D semantic_mask : filter_nearest, repeat_disable;
uniform vec2 map_origin;
uniform vec2 map_size;
varying vec2 world_xz;

float wet(vec2 p) { return texture(semantic_mask, (p - map_origin) / map_size).a; }
void vertex() {
	// No vertex displacement: fixed outline cannot cover a dry deck or bank.
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}
void fragment() {
	vec2 p = world_xz;
	float edge = 0.0;
	float near_edge = 0.0;
	for (int i = 0; i < 4; i++) {
		vec2 axis = vec2(i == 0 ? 1.0 : (i == 1 ? -1.0 : 0.0), i == 2 ? 1.0 : (i == 3 ? -1.0 : 0.0));
		edge = max(edge, 1.0 - wet(p + axis * 0.30));
		near_edge = max(near_edge, 1.0 - wet(p + axis * 0.10));
	}
	float phase = TIME * 0.28;
	float ripple = sin(p.x * 3.2 + p.y * 5.1 - phase) * sin(p.y * 2.4 + phase * 0.7);
	float stream = smoothstep(0.94, 1.0, sin(p.y * 4.6 + sin(p.x * 1.7) * 1.6 - phase));
	vec3 color = vec3(0.12, 0.39, 0.40) + ripple * 0.012;
	color = mix(color, vec3(0.29, 0.49, 0.43), edge * 0.43);
	// Wet earth marks the exact blocked edge, all inside the water footprint.
	color = mix(color, vec3(0.33, 0.34, 0.22), near_edge * 0.75);
	color += vec3(0.06, 0.09, 0.08) * stream * (1.0 - near_edge) * 0.30;
	ALBEDO = color;
	ROUGHNESS = 0.82;
	SPECULAR = 0.18;
}
