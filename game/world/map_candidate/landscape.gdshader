shader_type spatial;
render_mode cull_disabled;

uniform vec4 base_color : source_color;
uniform vec4 meadow_color : source_color = vec4(0.57255, 0.61176, 0.29804, 1.0);
uniform int kind = 1;
uniform sampler2D semantic_mask : filter_nearest, repeat_disable;
uniform vec2 map_origin;
uniform vec2 map_size;
varying vec3 world_position;
varying vec3 world_normal;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1)), f.x), f.y);
}
vec4 semantic(vec2 p) { return texture(semantic_mask, (p - map_origin) / map_size); }
// Filter small dabs by pixel footprint. No TIME, periodic UVs or cell-local seed.
// Marks span roughly 0.3-0.8m; large palette pools span several metres.
float painted_dabs(vec2 p) {
	vec2 q = p * vec2(2.5, 1.7);
	float visibility = 1.0 - smoothstep(0.25, 0.65, max(fwidth(q.x), fwidth(q.y)));
	return mix(0.5, smoothstep(0.25, 0.75, noise(q + vec2(noise(p * 0.43), noise(p * 0.37 + 13.0)) * 0.8)), visibility);
}
vec3 painted_surface(vec2 p, vec3 base, float strength) {
	float wash = noise(p * 0.32);
	float dab = painted_dabs(p);
	return base * (0.98 + wash * 0.04 + (dab - 0.5) * strength);
}
void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
	vec2 p = world_position.xz;
	float broad = noise(p * 0.55);
	float grain = noise(p * 13.0);
	vec3 color = base_color.rgb * (0.91 + broad * 0.14 + grain * 0.05);
	if (kind == 1) {
		// Low-contrast sage wash and soft elongated dabs, beneath actor detail.
		color = painted_surface(p, base_color.rgb, 0.06);
		color *= 1.0 - smoothstep(0.45, 0.85, noise(p * 0.17)) * 0.05;
	} else if (kind == 2) {
		color = painted_surface(p + vec2(7.3, -3.7), base_color.rgb, 0.08);
	} else if (kind == 5) {
		// Existing authored wet-shoreline cells only; no mask or sand-path change.
		color = painted_surface(p, base_color.rgb, 0.06);
	} else if (kind == 7) {
		// Vertical metre scale prevents XZ-only sampling stretching down cliffs.
		vec2 face = abs(world_normal.x) > abs(world_normal.z) ? world_position.zy : world_position.xy;
		color = painted_surface(face, base_color.rgb, 0.08);
	} else if (kind == 4) {
		// World-aligned irregular cobbles, no per-tile UV seam or image dependency.
		vec2 row = vec2(p.x * 2.8 + mod(floor(p.y * 2.6), 2.0) * 0.5, p.y * 2.6);
		vec2 f = fract(row);
		float joint = 1.0 - smoothstep(0.015, 0.055, min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)));
		color *= 0.90 + hash(floor(row)) * 0.15;
		color = mix(color, vec3(0.27, 0.28, 0.22), joint * 0.38);
	} else if (kind == 6) {
		// Retained source grass-tuft centers become tiny matte flecks, not dots.
		vec2 local = fract(p) - vec2(0.5);
		if (length(local * vec2(1.0, 1.65)) > 0.055) { discard; }
		color *= 0.85 + smoothstep(-0.04, 0.04, local.x) * 0.2;
	}
	if (kind == 2 || kind == 3 || kind == 4) {
		// Blend only the outer few centimetres toward neighboring grass.
		// Semantic placement/layer grids and physical surface do not move.
		float shoulder = 0.0;
		for (int i = 0; i < 4; i++) {
			vec2 offset = vec2(i == 0 ? 0.065 : (i == 1 ? -0.065 : 0.0), i == 2 ? 0.065 : (i == 3 ? -0.065 : 0.0));
			vec4 neighbor = semantic(p + offset);
			shoulder += (abs(neighbor.r * 255.0 - 1.0) < 0.5 && neighbor.a < 0.5) ? 1.0 : 0.0;
		}
		// Retain old shore/cobble shoulder policy until their owning tasks.
		vec3 shoulder_color = kind == 2 ? painted_surface(p, meadow_color.rgb, 0.06) : vec3(0.36, 0.46, 0.18);
		color = mix(color, shoulder_color, min(shoulder, 1.0) * 0.40);
	}
	ALBEDO = color;
	ROUGHNESS = 0.97;
}
