shader_type spatial;
render_mode cull_disabled;

uniform sampler2D semantic_mask : filter_nearest, repeat_disable;
uniform vec2 map_origin;
uniform vec2 map_size;
uniform vec4 water_color : source_color;
uniform vec4 stroke_color : source_color;
uniform vec4 bank_color : source_color;
varying vec2 world_xz;

float wet(vec2 p) { return texture(semantic_mask, (p - map_origin) / map_size).a; }
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1)), f.x), f.y);
}
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
	// Nonperiodic broad wash and sparse elongated dabs, anchored in metres.
	// Drift only 0.028m/s; no moving geometry, UV reset or screen-space effect.
	vec2 brush = p * vec2(0.55, 2.3) + vec2(0.0, -TIME * 0.065);
	float visibility = 1.0 - smoothstep(0.25, 0.65, max(fwidth(brush.x), fwidth(brush.y)));
	float stroke = smoothstep(0.76, 0.92, noise(brush)) * visibility;
	float wash = noise(p * 0.23);
	vec3 color = water_color.rgb * (0.97 + wash * 0.06);
	color = mix(color, stroke_color.rgb, stroke * 0.13 * (1.0 - near_edge));
	// Soft olive/mint transition remains INSIDE the exact blocked-water mesh.
	// Sparse edge flecks never form a bright continuous false crossing.
	color = mix(color, bank_color.rgb, near_edge * 0.38);
	float foam = smoothstep(0.65, 0.90, noise(p * 0.75));
	color = mix(color, stroke_color.rgb, edge * foam * 0.10);
	ALBEDO = color;
	ROUGHNESS = 0.94;
	SPECULAR = 0.12;
}
