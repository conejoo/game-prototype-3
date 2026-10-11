class_name StorybookNpcMaterial
extends RefCounted
## Appearance only: keep imported geometry, palette UVs, skin and animation resources.
const SHADER: Shader = preload("res://features/npcs/storybook_npc.gdshader")
const ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const ASSETS: PackedStringArray = [
	"res://assets/models/npcs/npc-01.glb", "res://assets/models/npcs/npc-01-actions.glb",
	"res://assets/models/npcs/npc-02.glb", "res://assets/models/npcs/npc-02-actions.glb",
	"res://assets/models/npcs/npc-03.glb", "res://assets/models/npcs/npc-04.glb",
	"res://assets/models/npcs/npc-06.glb", "res://assets/models/npcs/npc-07.glb",
	"res://assets/models/npcs/npc-08.glb", "res://assets/models/npcs/npc-14.glb"]
static var materials: Dictionary[StandardMaterial3D, ShaderMaterial] = {}

static func apply(model: Node3D, asset_path: String) -> void:
	if asset_path not in ASSETS: return
	for mesh: MeshInstance3D in _meshes(model):
		for surface: int in range(mesh.mesh.get_surface_count()):
			var source: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
			if not materials.has(source):
				var material: ShaderMaterial = ShaderMaterial.new()
				material.shader = SHADER
				material.set_shader_parameter("painted_atlas", ATLAS)
				material.set_shader_parameter("palette", source.albedo_texture)
				material.set_shader_parameter("base_color", source.albedo_color)
				material.set_shader_parameter("vertex_palette", source.vertex_color_use_as_albedo)
				materials[source] = material
			mesh.set_surface_override_material(surface, materials[source])

## Local recursive traversal avoids any dependency on test helpers at runtime.
static func _meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D: result.append(node)
	for child: Node in node.get_children(): result.append_array(_meshes(child))
	return result
