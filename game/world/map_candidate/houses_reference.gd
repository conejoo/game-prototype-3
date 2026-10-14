extends RefCounted
## Shared detailed exteriors; original wrappers and light consumers stay in place.

const SCENE: PackedScene = preload("res://assets/environment/storybook/houses-reference-v1.glb")
const STUDY: Script = preload("res://world/map_candidate/schoolhouse_reference.gd")
const DEFINITIONS: Array[String] = ["alderwake-hall", "house-dockside", "house-plaster-slate",
	"house-plaster-terracotta", "house-timber-slate", "house-timber-terracotta",
	"house-woodland-cottage", "lantern-rest", "mayor-vale-home", "net-shed",
	"passenger-control-shelter", "reed-chandlery", "tess-general-goods"]


static func build(groups: Dictionary) -> Dictionary:
	var result: Dictionary = {"meshes":{}, "materials":{}, "errors":PackedStringArray()}
	for family: String in ["slate", "terracotta", "teal", "civic", "woodland"]:
		var palette: Array[Vector3] = STUDY.PALETTE.duplicate()
		if family in ["terracotta", "civic"]: palette[1] = Vector3(.54, .26, .15)
		elif family == "woodland": palette[1] = Vector3(.30, .34, .14)
		if family == "teal": palette[0] = Vector3(.19, .54, .60)
		var materials: Dictionary = {}
		for kind: int in range(STUDY.PARTS.size()):
			var material: ShaderMaterial = ShaderMaterial.new()
			material.shader = STUDY.SHADER
			material.set_shader_parameter("part_kind", kind)
			material.set_shader_parameter("paint_color", palette[kind])
			materials[STUDY.PARTS[kind]] = material
		result.materials[family] = materials
	var instance: Node3D = SCENE.instantiate()
	for visual: Node in instance.find_children("*", "MeshInstance3D", true, false):
		var definition: String = str(visual.name).trim_prefix("GEO-house-reference-")
		if definition not in DEFINITIONS or result.meshes.has(definition):
			result.errors.append("Unknown or duplicate reference house: " + definition)
			continue
		if visual.transform != Transform3D.IDENTITY:
			result.errors.append("Reference house has a nonlocal transform: " + definition)
			continue
		var family: String = groups.get(definition, "")
		if not result.materials.has(family):
			result.errors.append("Missing reference house family: " + definition)
			continue
		var mesh: ArrayMesh = visual.mesh.duplicate()
		var coverage: Dictionary = {}
		for surface: int in range(mesh.get_surface_count()):
			var imported: Material = mesh.surface_get_material(surface)
			var part: String = "" if imported == null else imported.resource_name.trim_prefix("MAT-house-")
			if part not in STUDY.PARTS or coverage.has(part):
				result.errors.append("Unknown or duplicate house surface: " + definition + "/" + part)
				continue
			coverage[part] = true
			mesh.surface_set_material(surface, result.materials[family][part])
		if coverage.size() != STUDY.PARTS.size():
			result.errors.append("Incomplete reference house surfaces: " + definition)
		result.meshes[definition] = mesh
	instance.free()
	if result.meshes.size() != DEFINITIONS.size():
		result.errors.append("Reference house kit does not cover all remaining definitions")
	return result
