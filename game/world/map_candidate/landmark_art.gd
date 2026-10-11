class_name AlderwakeLandmarkArt
extends Node3D
## Imported appearance only. Source wrappers, physics/nav and stable IDs stay fixed.

const KIT: PackedScene = preload("res://assets/environment/storybook/alderwake_landmark_painted.glb")
const PAINTED_ATLAS: Texture2D = preload("res://assets/environment/storybook/town-painted-albedo.png")
const MAPPING_PATH: String = "res://assets/environment/alderwake_landmark_mapping.json"
var build_errors: PackedStringArray = []
var mappings: Dictionary[String, Dictionary] = {}
var meshes: Dictionary[String, Mesh] = {}
var landmark_ids: PackedStringArray = []
var instance_count: int = 0


func build(crossings: AlderwakeCrossings, forest: AlderwakeForestPopulation, layout: Dictionary) -> void:
	name = "LandmarkArt"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAPPING_PATH))
	if not parsed is Dictionary or parsed.get("snapshot_id") != "alderwake-f4630f9-m002":
		build_errors.append("Landmark mapping unavailable or wrong snapshot")
		return
	var kit: Node3D = KIT.instantiate()
	for visual: Node in kit.find_children("*", "MeshInstance3D", true, false):
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
	kit.free()
	for mapping: Dictionary in parsed.mappings:
		var id: String = str(mapping.module_id)
		if mappings.has(id) or not meshes.has(mapping.mesh_name):
			build_errors.append("Invalid landmark mesh mapping: " + id)
			continue
		mappings[id] = mapping
	for id: String in ["bridge-deck", "bridge-rail", "bridge-landing", "moonwell", "closed-east-gate"]:
		if not mappings.has(id):
			build_errors.append("Missing landmark module: " + id)
	if not build_errors.is_empty():
		return
	var bridge: Node3D = crossings.get_node("moonwood-footbridge")
	var bridge_root: Node3D = bridge.get_node("VisualRoot")
	_clear_visuals(bridge_root)
	_add_mesh(bridge_root, "Deck", "bridge-deck", Vector3(95, 0, -2))
	_add_mesh(bridge_root, "WestLanding", "bridge-landing", Vector3(93, 0, -2))
	_add_mesh(bridge_root, "EastLanding", "bridge-landing", Vector3(101, 0, -2))
	_add_mesh(bridge_root, "NorthRail", "bridge-rail", Vector3(95, 0, -2))
	_add_mesh(bridge_root, "SouthRail", "bridge-rail", Vector3(95, 0, 0.9))
	bridge.set_meta("landmark_art_source_id", "moonwood-footbridge")
	landmark_ids.append("moonwood-footbridge")
	var moonwell: Node3D = forest.get_node("moonwell-prop")
	var moonwell_root: Node3D = moonwell.get_node("VisualRoot")
	_clear_visuals(moonwell_root)
	_add_mesh(moonwell_root, "ImportedMoonwell", "moonwell", Vector3.ZERO)
	moonwell.set_meta("landmark_art_source_id", "moonwell-prop")
	landmark_ids.append("moonwell-prop")
	var gate: Node3D = forest.get_node("future-exit-gate-prop")
	var gate_root: Node3D = gate.get_node("VisualRoot")
	_clear_visuals(gate_root)
	for collider: Dictionary in layout.colliders:
		if collider.id != "future-exit-gate":
			continue
		var rect: Array = collider.rect_xz_m
		var inverse: Transform3D = gate.transform.affine_inverse()
		var visual: MeshInstance3D = _add_mesh(gate_root, "ImportedClosedGate", "closed-east-gate", Vector3.ZERO)
		visual.transform = inverse * Transform3D(Basis.IDENTITY, Vector3(rect[0], 0, rect[1]))
		visual.set_meta("landmark_art_collider_reference", collider.id)
		gate.set_meta("landmark_art_source_id", "future-exit-gate-prop")
		landmark_ids.append("future-exit-gate-prop")
	var sign: Label3D = Label3D.new()
	sign.name = "ClosedTrailSign"
	sign.text = "EAST TRAIL CLOSED\nNO DESTINATION"
	sign.position = Vector3(-1.65, 1.8, 0)
	sign.font_size = 22
	sign.pixel_size = 0.007
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gate_root.add_child(sign)
	if landmark_ids.size() != 3:
		build_errors.append("Expected three retained landmarks")


func _clear_visuals(visual_root: Node3D) -> void:
	for child: Node in visual_root.get_children():
		visual_root.remove_child(child)
		child.free()


func _add_mesh(parent: Node3D, node_name: String, module_id: String, point: Vector3) -> MeshInstance3D:
	var visual: MeshInstance3D = MeshInstance3D.new()
	visual.name = node_name
	visual.mesh = meshes[mappings[module_id].mesh_name]
	visual.position = point
	visual.set_meta("landmark_module_id", module_id)
	parent.add_child(visual)
	instance_count += 1
	return visual
