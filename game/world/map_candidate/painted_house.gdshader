shader_type spatial;
render_mode cull_back;

uniform vec3 paint_color = vec3(0.5);
uniform int part_kind = 0;
varying vec3 local_position;

float house_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float house_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(house_hash(i), house_hash(i + vec2(1,0)), f.x),
		mix(house_hash(i + vec2(0,1)), house_hash(i + vec2(1,1)), f.x), f.y);
}

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float tint = clamp((COLOR.r - 0.42) / 0.16, 0.0, 1.0);
	float variation = part_kind == 1 ? mix(0.84, 1.16, tint) : mix(0.92, 1.08, tint);
	vec3 color = paint_color * variation;
	float wash = house_noise(UV * vec2(3.1, 4.5));
	if (part_kind == 0) {
		// Cream panels remain calm beside the modeled timber and roof detail.
		color *= 0.975 + wash * 0.05;
		color *= mix(0.88, 1.0, smoothstep(0.25, 0.75, local_position.y));
	} else if (part_kind == 1) {
		color *= 0.975 + house_noise(UV * vec2(8.0, 4.0)) * 0.05;
	} else if (part_kind == 2 || part_kind == 5) {
		// UV.y follows the authored wood grain. Fade subpixel detail.
		vec2 grain_uv = UV * vec2(58.0, 2.0);
		float visibility = 1.0 - smoothstep(0.4, 1.2, max(fwidth(grain_uv.x), fwidth(grain_uv.y)));
		color *= 1.0 + (house_noise(grain_uv) - 0.5) * 0.16 * visibility;
	} else if (part_kind == 3) {
		color *= 0.96 + wash * 0.08;
	} else if (part_kind == 4) {
		color *= 0.94 + house_noise(UV * 9.0) * 0.12;
	}
	ALBEDO = color;
	ROUGHNESS = part_kind == 4 ? 0.82 : 0.96;
	SPECULAR = 0.12;
	METALLIC = 0.0;
}
