class_name AlderwakeTownArt
extends Node3D
## Imported appearance only; existing source wrappers/floors/physics stay owned by town.

const KIT: PackedScene = preload("res://assets/environment/alderwake_town_kit.glb")
const SHOP_PILOT: PackedScene = preload("res://assets/environment/storybook/alderwake_shop_pilot.glb")
const TOWN_ROLLOUT: PackedScene = preload("res://assets/environment/storybook/alderwake_town_rollout.glb")
const BUILDING_SHADER: Shader = preload("res://world/map_candidate/painted_building.gdshader")
const PAINTED_ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const DOCK_PILOT: PackedScene = preload("res://assets/environment/storybook/alderwake_dock_pilot.glb")
const DOCK_ATLAS: Texture2D = preload("res://assets/environment/storybook/dock-painted-albedo.png")
const WALL_SHADER: Shader = preload("res://world/map_candidate/painted_wall.gdshader")
const MAPPING_PATH: String = "res://assets/environment/alderwake_town_mapping.json"
var build_errors: PackedStringArray = []
var mappings: Dictionary[String, Dictionary] = {}
var meshes: Dictionary[String, Mesh] = {}
var structure_ids: PackedStringArray = []
var module_count: int = 0
var dock_rectangles: Array[Rect2] = []
var quay_cells: int = 0
var painted_wall_count: int = 0
var wall_material: ShaderMaterial
var partial_module_meshes: Dictionary[String, Mesh] = {}
var building_materials: Dictionary[String, ShaderMaterial] = {}


static func building_group(id: String) -> String:
	if id in ["alderwake-hall", "mayor-vale-home"]: return "civic"
	if id in ["house-dockside", "net-shed"]: return "teal"
	if id == "house-woodland-cottage": return "woodland"
	if id.contains("terracotta") or id == "tess-general-goods": return "terracotta"
	return "slate"


func build(town: AlderwakeTownFootprints, layout: Dictionary) -> void:
	name = "TownArt"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAPPING_PATH))
	if not parsed is Dictionary or parsed.get("snapshot_id") != "alderwake-f4630f9-m002":
		build_errors.append("Town art mapping unavailable or wrong snapshot")
		return
	var kit: Node3D = KIT.instantiate()
	for visual: Node in kit.find_children("*", "MeshInstance3D", true, false):
		var mesh: ArrayMesh = visual.mesh.duplicate()
		for surface: int in range(mesh.get_surface_count()):
			var material: StandardMaterial3D = visual.get_active_material(surface).duplicate()
			material.vertex_color_use_as_albedo = true
			mesh.surface_set_material(surface, material)
		meshes[str(visual.name)] = mesh
	kit.free()
	# AD002: one mapped shop only. Original kit and other palette meshes stay intact.
	# Painted albedo supplies color; old vertex palette must not multiply it again.
	var pilot: Node3D = SHOP_PILOT.instantiate()
	for visual: Node in pilot.find_children("*", "MeshInstance3D", true, false):
		var mesh: ArrayMesh = visual.mesh.duplicate()
		for surface: int in range(mesh.get_surface_count()):
			var material: StandardMaterial3D = visual.get_active_material(surface).duplicate()
			material.vertex_color_use_as_albedo = false
			material.albedo_color = Color.WHITE
			material.albedo_texture = PAINTED_ATLAS
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			material.texture_repeat = false
			mesh.surface_set_material(surface, material)
		meshes[str(visual.name)] = mesh
	pilot.free()
	# AD009: thirteen remaining building meshes; five shared palette variants.
	# UVs carry every original face. Physics, light anchors and mapping stay external.
	for group: String in ["slate", "terracotta", "teal", "civic", "woodland"]:
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = BUILDING_SHADER
		material.set_shader_parameter("painted_atlas", PAINTED_ATLAS)
		material.set_shader_parameter("roof_tint", Vector3(2.7, 1.25, .65) if group in ["terracotta", "civic"] else (Vector3(1.7, 1.45, .65) if group == "woodland" else Vector3.ONE))
		material.set_shader_parameter("plaster_tint", Vector3(.36, .65, .82) if group == "teal" else Vector3.ONE)
		building_materials[group] = material
	var rollout: Node3D = TOWN_ROLLOUT.instantiate()
	for visual: Node in rollout.find_children("*", "MeshInstance3D", true, false):
		var mesh: ArrayMesh = visual.mesh.duplicate()
		var definition: String = str(visual.name).trim_prefix("GEO-")
		mesh.surface_set_material(0, building_materials[building_group(definition)])
		meshes[str(visual.name)] = mesh
	rollout.free()
	# AD006: existing metre modules only. Single shared material, full face UVs.
	var dock_pilot: Node3D = DOCK_PILOT.instantiate()
	var dock_material: StandardMaterial3D = StandardMaterial3D.new()
	dock_material.albedo_texture = DOCK_ATLAS
	dock_material.roughness = 0.97
	dock_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	dock_material.texture_repeat = false
	for visual: Node in dock_pilot.find_children("*", "MeshInstance3D", true, false):
		var mesh: ArrayMesh = visual.mesh.duplicate()
		mesh.surface_set_material(0, dock_material)
		meshes[str(visual.name)] = mesh
	dock_pilot.free()
	# Exact existing low-wall prisms receive world-metre coverage on every face.
	# Structure/counter, nets, pilings, baffles and unrelated props retain materials.
	wall_material = ShaderMaterial.new()
	wall_material.shader = WALL_SHADER
	wall_material.set_shader_parameter("painted_atlas", DOCK_ATLAS)
	for wrapper: Node in town.get_children():
		var definition: String = str(wrapper.get_meta("definition_id", ""))
		var collider_id: String = str(wrapper.get_meta("source_collider_id", ""))
		if not definition.begins_with("garden-wall-") and collider_id not in ["passenger-basin-south-wall-01", "passenger-east-quay-edge-01", "passenger-north-quay-west-edge-01", "passenger-west-quay-edge-01"]:
			continue
		for visual: Node in wrapper.get_node("VisualRoot").get_children():
			if visual is MeshInstance3D:
				visual.material_override = wall_material
				painted_wall_count += 1
	for mapping: Dictionary in parsed.mappings:
		var id: String = str(mapping.get("definition_id", mapping.get("module_id", "")))
		if id.is_empty() or mappings.has(id) or not meshes.has(mapping.mesh_name):
			build_errors.append("Invalid town mesh mapping: " + id)
			continue
		mappings[id] = mapping
	var structures: Dictionary = {}
	for definition: Dictionary in layout.catalog_reference:
		if definition.kind == "structure":
			structures[definition.id] = true
	for record: Dictionary in town.prop_records:
		if not structures.has(record.definition_id):
			continue
		var wrapper: Node3D = town.get_node(NodePath(record.id))
		var visual_root: Node3D = wrapper.get_node("VisualRoot")
		if record.definition_id in parsed.dock_definitions:
			_clear_visuals(visual_root)
			for rect: Rect2 in AlderwakeDockSurfaces.SURFACES[record.id]:
				dock_rectangles.append(rect)
				_tile_rect(visual_root, wrapper.transform.affine_inverse(), rect, "dock-plank-module")
			wrapper.set_meta("town_art_definition", "dock-plank-module")
		elif mappings.has(record.definition_id):
			_clear_visuals(visual_root)
			var visual: MeshInstance3D = MeshInstance3D.new()
			visual.name = "ImportedExterior"
			visual.mesh = meshes[mappings[record.definition_id].mesh_name]
			visual_root.add_child(visual)
			wrapper.set_meta("town_art_definition", record.definition_id)
		else:
			build_errors.append("Unmapped structure: " + record.id)
			continue
		structure_ids.append(record.id)
		wrapper.set_meta("town_art_source_id", record.id)
	# Existing quay grid becomes shared stone modules; authored quay edge bodies remain.
	var quay: Node3D = town.get_node("QuayArtPreview/VisualRoot")
	_clear_visuals(quay)
	for layer: Dictionary in layout.art_layers:
		if not str(layer.id).begins_with("passenger-") or not str(layer.id).ends_with("--quay-deck") or not layer.visible:
			continue
		for cell: Dictionary in layer.cells:
			if cell.tile_id == null:
				continue
			_tile_rect(quay, Transform3D.IDENTITY, Rect2(float(cell.cell[0]) - 22, float(cell.cell[1]) - 18, 1, 1), "quay-stone-module")
			quay_cells += 1


func _clear_visuals(visual_root: Node3D) -> void:
	for child: Node in visual_root.get_children():
		visual_root.remove_child(child)
		child.free()


func _tile_rect(visual_root: Node3D, inverse: Transform3D, rect: Rect2, module_id: String) -> void:
	if not mappings.has(module_id):
		build_errors.append("Missing deck module: " + module_id)
		return
	for x: int in range(ceili(rect.size.x)):
		for z: int in range(ceili(rect.size.y)):
			var width: float = minf(1, rect.size.x - x)
			var depth: float = minf(1, rect.size.y - z)
			var visual: MeshInstance3D = MeshInstance3D.new()
			visual.name = "Module%d" % module_count
			visual.mesh = _module_mesh(module_id, width, depth)
			visual.transform = inverse * Transform3D(Basis.from_scale(Vector3(width, 1, depth)), Vector3(rect.position.x + x, 0, rect.position.y + z))
			visual.set_meta("module_id", module_id)
			visual.set_meta("world_rect_xz_m", Rect2(rect.position + Vector2(x, z), Vector2(width, depth)))
			visual_root.add_child(visual)
			module_count += 1


func _module_mesh(module_id: String, width: float, depth: float) -> Mesh:
	var source_mesh: Mesh = meshes[mappings[module_id].mesh_name]
	if width == 1.0 and depth == 1.0: return source_mesh
	var key: String = "%s/%s/%s" % [module_id, width, depth]
	if partial_module_meshes.has(key): return partial_module_meshes[key]
	# Existing fractional edge pieces keep exact original vertices/transforms.
	# Crop paint coordinates around the patch center to retain64texels/m on
	# every plane, rather than stretching one metre of paint over half a metre.
	var arrays: Array = source_mesh.surface_get_arrays(0)
	var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV].duplicate()
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var low: Vector2 = uv[0]
	var high: Vector2 = uv[0]
	for point: Vector2 in uv:
		low = low.min(point)
		high = high.max(point)
	var center: Vector2 = (low + high) * 0.5
	for index: int in range(uv.size()):
		var normal: Vector3 = normals[index].abs()
		var scale_uv: Vector2 = Vector2(width, depth) if normal.y > 0.9 else (Vector2(depth, 1.0) if normal.x > 0.9 else Vector2(width, 1.0))
		uv[index] = center + (uv[index] - center) * scale_uv
	arrays[Mesh.ARRAY_TEX_UV] = uv
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, source_mesh.surface_get_material(0))
	partial_module_meshes[key] = mesh
	return mesh
