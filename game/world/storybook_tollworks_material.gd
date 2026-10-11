extends MeshInstance3D
## AD016 appearance only. Original scene meshes/materials/collision stay intact.
const SHADER: Shader = preload("res://world/storybook_inn.gdshader")
const ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
static var materials: Dictionary[String, ShaderMaterial] = {}

func _ready() -> void:
	material_override = painted(str(get_parent().name))

static func painted(owner: String) -> ShaderMaterial:
	var kind: String = "worn-slate-floor" if owner == "Floor" else "cool-stone-wall"
	if not materials.has(kind):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_meta("storybook_family",kind)
		material.set_shader_parameter("painted_atlas",ATLAS)
		material.set_shader_parameter("base_color",Color("4d5d63") if owner == "Floor" else Color("858b85"))
		material.set_shader_parameter("patch_origin",Vector2(528,528))
		material.set_shader_parameter("patch_span",Vector2(224,224))
		material.set_shader_parameter("patch_color",Color("8b8c7b"))
		material.set_shader_parameter("stroke_strength",.70)
		materials[kind] = material
	return materials[kind]
