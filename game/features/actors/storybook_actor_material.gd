extends RefCounted
## AD013 surface adapter. Meshes, feet, markers and transient feedback stay owned by actors.
const SHADER: Shader = preload("res://features/actors/storybook_actor.gdshader")
const ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const HERO: Color = Color(0.26,0.80,0.88)
const ALLY: Color = Color(0.60,0.46,0.88)
static var materials: Dictionary[String, ShaderMaterial] = {}

static func apply(actor: Node3D) -> void:
	var guardian: Node3D = actor.get_node_or_null("VisualRoot/GuardianModel")
	if guardian != null:
		for mesh: MeshInstance3D in _meshes(guardian):
			for surface: int in range(mesh.mesh.get_surface_count()):
				var source: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
				mesh.set_surface_override_material(surface,_material(source,"guardian"))
		return
	var body: MeshInstance3D = actor.get_node_or_null("VisualRoot/Body")
	if body != null:
		var source: StandardMaterial3D = body.mesh.surface_get_material(0)
		body.material_override = _material(source,"hero" if actor.player_controlled else "ally")

static func _material(source: StandardMaterial3D, role: String) -> ShaderMaterial:
	# Value keys reuse the same finish after a room reload releases imported resources.
	var key: String = "%s/%s/%s/%s/%s/%s" % [role,source.albedo_color,source.metallic,source.roughness,source.emission if source.emission_enabled else Color.BLACK,source.emission_energy_multiplier]
	if not materials.has(key):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter("painted_atlas",ATLAS)
		material.set_shader_parameter("base_color",HERO if role == "hero" else ALLY if role == "ally" else source.albedo_color)
		material.set_shader_parameter("source_emission",source.emission*source.emission_energy_multiplier if source.emission_enabled else Color.BLACK)
		material.set_shader_parameter("source_metallic",source.metallic)
		material.set_shader_parameter("surface_roughness",maxf(source.roughness,0.78) if source.metallic > 0 else 0.94)
		material.set_shader_parameter("role_fill",0.045 if role != "guardian" else 0.0)
		materials[key] = material
	return materials[key]

static func _meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D: result.append(node)
	for child: Node in node.get_children(): result.append_array(_meshes(child))
	return result
