shader_type spatial;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 base_color : source_color;
uniform vec4 patch_color : source_color;
uniform vec2 patch_origin;
uniform vec2 patch_span;
uniform float stroke_strength = 0.7;
uniform vec4 partition_color : source_color;
uniform vec4 partition_patch : source_color;
varying vec3 room_position;
varying vec3 room_normal;
void vertex() {
	// Metre coordinates make all six box faces intentional, independent of box UV/size.
	// Adjacent floor rectangles share sampling phase; no per-instance material state.
	room_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	room_normal = mat3(MODEL_MATRIX) * NORMAL;
}
vec3 region_brush(vec2 plane, vec2 origin, vec2 span, vec3 reference_color, float strength) {
	vec2 folded = 1.0 - abs(mod(plane * 64.0 / span + vec2(0.35,0.45), 2.0) - 1.0);
	vec3 paint = texture(painted_atlas, (origin + folded * span) / 1024.0).rgb;
	// Normalize each atlas family once, avoiding a second palette multiplication.
	return mix(vec3(1.0),clamp(paint / max(reference_color,vec3(0.001)),vec3(0.84),vec3(1.16)),strength);
}
vec3 brush(vec2 plane) {
	return region_brush(plane,patch_origin,patch_span,patch_color.rgb,stroke_strength);
}
void fragment() {
	vec3 weights = pow(abs(normalize(room_normal)),vec3(4.0));
	weights /= max(weights.x+weights.y+weights.z,0.0001);
	vec3 stroke = brush(room_position.zy)*weights.x + brush(room_position.xz)*weights.y + brush(room_position.xy)*weights.z;
	ALBEDO = base_color.rgb * stroke;
	// Original sofa/island/rug intersect the pinned middle partition at z=-5.5.
	// Their coincident faces share identical plaster sampling/color, eliminating
	// material speckle without moving geometry, changing depth or hiding surfaces.
	if (abs(room_position.z + 5.5) < 0.0001 && abs(room_normal.z) > 0.999 && room_position.y >= 0.0 && room_position.y < 0.65) {
		ALBEDO = partition_color.rgb * region_brush(room_position.xy,vec2(16.0),vec2(480.0),partition_patch.rgb,0.7);
	}
	ROUGHNESS = 0.92;
}
