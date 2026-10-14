extends RefCounted
## One reference study. Shared town kit and other placed houses stay intact.

const SCENE: PackedScene = preload("res://assets/environment/storybook/schoolhouse-reference-v1.glb")
const SHADER: Shader = preload("res://world/map_candidate/painted_house.gdshader")
const PROP_ID: String = "mill-road-schoolhouse-exterior-building"
const PARTS: Array[String] = ["plaster", "roof", "timber", "stone", "glass", "door", "iron"]
# Scene-linear art palette, calibrated under the existing outdoor presenter.
const PALETTE: Array[Vector3] = [Vector3(1.19, .96, .69), Vector3(.19, .25, .375),
	Vector3(.43, .25, .15), Vector3(.53, .50, .51), Vector3(.58, .36, .16),
	Vector3(.49, .285, .16), Vector3(.10, .105, .115)]


static func build() -> Dictionary:
	var instance: Node3D = SCENE.instantiate()
	var result: Dictionary = {"mesh":null, "materials":{}, "errors":PackedStringArray()}
	var visuals: Array[Node] = instance.find_children("*", "MeshInstance3D", true, false)
	if visuals.size() != 1:
		result.errors.append("Schoolhouse reference requires one joined mesh")
	else:
		var visual: MeshInstance3D = visuals[0]
		var mesh: ArrayMesh = visual.mesh.duplicate()
		for surface: int in range(mesh.get_surface_count()):
			var imported: Material = mesh.surface_get_material(surface)
			var part: String = imported.resource_name.trim_prefix("MAT-house-")
			var kind: int = PARTS.find(part)
			if kind < 0:
				result.errors.append("Unknown schoolhouse surface: " + imported.resource_name)
				continue
			var material: ShaderMaterial = ShaderMaterial.new()
			material.shader = SHADER
			material.set_shader_parameter("part_kind", kind)
			material.set_shader_parameter("paint_color", PALETTE[kind])
			mesh.surface_set_material(surface, material)
			result.materials[part] = material
		if result.materials.size() != PARTS.size():
			result.errors.append("Schoolhouse reference surface coverage incomplete")
		result.mesh = mesh
	instance.free()
	return result
