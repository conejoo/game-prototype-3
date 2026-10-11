class_name AlderwakeTownArt
extends Node3D
## Imported appearance only; existing source wrappers/floors/physics stay owned by town.

const KIT: PackedScene = preload("res://assets/environment/alderwake_town_kit.glb")
const SHOP_PILOT: PackedScene = preload("res://assets/environment/storybook/alderwake_shop_pilot.glb")
const PAINTED_ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const MAPPING_PATH: String = "res://assets/environment/alderwake_town_mapping.json"
var build_errors: PackedStringArray = []
var mappings: Dictionary[String, Dictionary] = {}
var meshes: Dictionary[String, Mesh] = {}
var structure_ids: PackedStringArray = []
var module_count: int = 0
var dock_rectangles: Array[Rect2] = []
var quay_cells: int = 0


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
			visual.mesh = meshes[mappings[module_id].mesh_name]
			visual.transform = inverse * Transform3D(Basis.from_scale(Vector3(width, 1, depth)), Vector3(rect.position.x + x, 0, rect.position.y + z))
			visual.set_meta("module_id", module_id)
			visual.set_meta("world_rect_xz_m", Rect2(rect.position + Vector2(x, z), Vector2(width, depth)))
			visual_root.add_child(visual)
			module_count += 1
