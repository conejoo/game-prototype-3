shader_type spatial;
render_mode cull_disabled;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform bool stone_enabled = true;
varying vec3 world_position;
varying vec3 world_normal;

float stone_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float stone_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(stone_hash(i), stone_hash(i + vec2(1,0)), f.x),
		mix(stone_hash(i + vec2(0,1)), stone_hash(i + vec2(1,1)), f.x), f.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
	vec2 face = abs(world_normal.y) > 0.8 ? world_position.xz : (abs(world_normal.x) > abs(world_normal.z) ? world_position.zy : world_position.xy);
	vec2 extent = vec2(992.0,480.0);
	vec2 pixel = vec2(16.0,528.0) + fract(face * 64.0 / extent) * extent;
	vec3 color = texture(painted_atlas,pixel/1024.0).rgb;
	if (stone_enabled) {
		// Mesh UVs are metres. Three staggered courses under a 15cm cap on
		// ordinary 60cm walls; taller authored walls continue the same scale.
		float depth = max(UV.y - 0.15, 0.0);
		float row = floor(depth / 0.15);
		float width = mix(0.39, 0.47, stone_hash(vec2(row, 4.3)));
		vec2 cell = vec2((UV.x + mod(row, 2.0) * width * 0.5) / width, depth / 0.15);
		vec2 id = floor(cell);
		vec2 inside = fract(cell) * vec2(width, 0.15);
		vec2 edge = min(inside, vec2(width, 0.15) - inside);
		float irregular = (stone_noise(face * 31.0) - 0.5) * 0.002;
		float distance = min(edge.x, edge.y) + irregular;
		float aa = max(fwidth(UV.x), fwidth(UV.y)) * 0.60;
		float solid = smoothstep(0.005 - aa, 0.009 + aa, distance);
		float bevel = smoothstep(0.005, 0.022, distance);
		float seed = stone_hash(id + vec2(12.7, 6.1));
		vec3 stone = vec3(0.53, 0.50, 0.51) * mix(0.91, 1.09, seed);
		stone += vec3(0.015, 0.004, -0.012) * (stone_hash(id + 17.3) - 0.5);
		stone *= 0.98 + stone_noise(face * vec2(9.0, 14.0)) * 0.04;
		stone *= mix(0.87, 1.0, bevel);
		// Small painted arris. Actual cap bevels receive ordinary scene light.
		stone += vec3(0.019) * (1.0 - smoothstep(0.009, 0.023, inside.y));
		color = mix(vec3(0.32, 0.32, 0.35), stone, solid);
		if (COLOR.r > 0.5) {
			float top = smoothstep(0.3, 0.95, abs(world_normal.y));
			color = mix(vec3(0.53, 0.50, 0.51), vec3(0.445, 0.423, 0.411), top);
			color *= mix(0.92, 1.08, COLOR.g);
			color *= 0.985 + stone_noise(world_position.xz * 11.0) * 0.03;
		}
	}
	ALBEDO = color;
	ROUGHNESS = 0.97;
}
