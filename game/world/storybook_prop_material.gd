class_name StorybookPropMaterial
extends Node3D
## Appearance adapter only. Original GLBs, transforms and wrapper owners stay intact.
const SHADER: Shader = preload("res://world/storybook_prop.gdshader")
const ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const SMALL_DEFINITIONS: PackedStringArray = ["berth-broken-piling", "boulder", "boulder-cluster", "craft-fitting-tray", "craft-rope-coil", "direction-sign", "flood-lookout-marker", "heirloom-skiff", "manual-sluice-gate", "passenger-level-gauge", "passenger-ship-sound", "ranger-warning-bell", "refuge-service-barrier", "remedy-display-shelf", "supply-parcel", "survey-stake", "survey-supply-cache", "village-notice-sign"]
static var materials: Dictionary[String, ShaderMaterial] = {}

func _ready() -> void:
	apply(self)

static func painted(source: StandardMaterial3D, vertex_palette: bool = false) -> ShaderMaterial:
	var key: String = "%s/%s/%s/%s/%s" % [source.albedo_color, vertex_palette, source.metallic, source.emission if source.emission_enabled else Color.BLACK, source.emission_energy_multiplier]
	if materials.has(key): return materials[key]
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("painted_atlas", ATLAS)
	material.set_shader_parameter("base_color", source.albedo_color)
	material.set_shader_parameter("vertex_palette", vertex_palette)
	material.set_shader_parameter("metallic", source.metallic)
	material.set_shader_parameter("glow", source.emission if source.emission_enabled else Color.BLACK)
	material.set_shader_parameter("glow_energy", source.emission_energy_multiplier)
	materials[key] = material
	return material

static func apply(node: Node) -> void:
	if node is MeshInstance3D:
		for surface: int in range(node.mesh.get_surface_count()):
			var source: StandardMaterial3D = node.get_active_material(surface) as StandardMaterial3D
			if source != null:
				node.set_surface_override_material(surface, painted(source, source.vertex_color_use_as_albedo))
	for child: Node in node.get_children(): apply(child)
