shader_type spatial;
render_mode cull_disabled;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 roof_tint = vec3(1.0);
uniform vec3 plaster_tint = vec3(1.0);
void fragment() {
	vec3 paint = texture(painted_atlas, UV).rgb;
	// Calibrated in the project's Compatibility renderer. Original mixed face
	// winding remains intact; two-sided rendering preserves every source surface.
	// Regions remain separated by16px gutters. No vertex-palette multiplication.
	if (UV.x > 0.5 && UV.y < 0.5) paint *= roof_tint;
	if (UV.x < 0.5 && UV.y < 0.5) paint *= plaster_tint;
	ALBEDO = paint;
	ROUGHNESS = 0.92;
	METALLIC = 0.0;
}
