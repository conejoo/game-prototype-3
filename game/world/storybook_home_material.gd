extends RefCounted
## AD014 appearance only. Original box materials remain recoverable beneath overrides.
const SHADER: Shader = preload("res://world/storybook_home.gdshader")
const ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
static var materials: Dictionary[String, ShaderMaterial] = {}

static func family(source: Color, owner: String, center: Vector3) -> String:
	if owner == "Floor": return "oak-floor"
	if source.is_equal_approx(Color(.64,.58,.46)): return "plaster"
	if source.is_equal_approx(Color(.52,.68,.73)): return "glass"
	if source.is_equal_approx(Color(.09,.065,.04)): return "hearth-dark"
	if source.is_equal_approx(Color(.85,.34,.07)): return "hearth-ember"
	if source.is_equal_approx(Color(.36,.32,.28)): return "stone"
	if source.is_equal_approx(Color(.10,.11,.16)): return "ink"
	if source.is_equal_approx(Color(.83,.80,.63)) or source.is_equal_approx(Color(.88,.85,.72)) or source.is_equal_approx(Color(.66,.71,.71)): return "linen"
	if source.is_equal_approx(Color(.65,.61,.47)): return "worktop"
	if source.is_equal_approx(Color(.28,.40,.44)): return "bed-cloth"
	if "armchair" in owner or "sofa" in owner: return "upholstery"
	if owner.begins_with("study-bookcase") and not source.is_equal_approx(Color(.29,.17,.09)) and not source.is_equal_approx(Color(.58,.36,.16)): return "book"
	if owner == "MayorValeHome" and center.y < .06 and center.y > .01: return "rug"
	if owner == "MayorValeHome" and center.y < .01: return "plank-seam"
	return "timber"

static func painted(source: Color, owner: String, center: Vector3) -> ShaderMaterial:
	var kind: String = family(source,owner,center)
	var tone: Color
	match kind:
		"oak-floor": tone = Color("956a40")
		"plaster": tone = Color("dcc49a")
		"glass": tone = Color("809eaa")
		"hearth-dark": tone = Color("30281f")
		"hearth-ember": tone = Color("cd7135")
		"stone": tone = Color("929080")
		"ink": tone = Color("343b49")
		"linen": tone = Color("e3cf9f")
		"worktop": tone = Color("b8b19a")
		"bed-cloth": tone = Color("58777f")
		"upholstery": tone = Color("597a73").lightened(.10 if source.g > .44 else 0)
		"book": tone = [Color("92714e"),Color("5d7185"),Color("7a835d"),Color("9c6f58")][int(round(source.g*100))%4]
		"rug": tone = Color("567169") if source.g > source.b else Color("626d83")
		"plank-seam": tone = Color("684b32")
		_: tone = Color("735033").lightened(.08 if source.r > .4 else 0)
	var key: String = kind+"/"+str(tone)
	if not materials.has(key):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_meta("storybook_family",kind)
		material.set_shader_parameter("painted_atlas",ATLAS)
		material.set_shader_parameter("base_color",tone)
		material.set_shader_parameter("partition_color",Color("dcc49a"))
		material.set_shader_parameter("partition_patch",Color("e7c98f"))
		var wood: bool = kind in ["oak-floor","timber","plank-seam"]
		var stone: bool = kind in ["stone","worktop"]
		var linen: bool = kind == "linen"
		material.set_shader_parameter("patch_origin",Vector2(16,528) if wood else Vector2(528,528) if stone else Vector2(784,784) if linen else Vector2(16,16))
		material.set_shader_parameter("patch_span",Vector2(480,480) if wood or not (stone or linen) else Vector2(224,224))
		material.set_shader_parameter("patch_color",Color("735033") if wood else Color("8b8c7b") if stone else Color("e3cf9f") if linen else Color("e7c98f"))
		# Broad wood/plaster/cloth brush. Small books/ink/glass stay quiet at distance.
		material.set_shader_parameter("stroke_strength",.30 if kind in ["book","ink","glass","plank-seam","hearth-dark","hearth-ember"] else .70)
		materials[key] = material
	return materials[key]
