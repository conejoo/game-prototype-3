class_name AlderwakeTreeArt
extends Node3D
## Appearance only. Source wrappers retain identity/feet/physics independently.

const VISIBILITY_SHADER: Shader = preload("res://world/map_candidate/canopy_visibility.gdshader")
var visibility_materials: Array[ShaderMaterial] = []

const KIT: PackedScene = preload("res://assets/environment/moonwood_tree_kit.glb")
const PAINTED_KIT: PackedScene = preload("res://assets/environment/storybook/moonwood_oak_pilot.glb")
const ROLLOUT_KIT: PackedScene = preload("res://assets/environment/storybook/moonwood_tree_rollout.glb")
const PAINTED_ATLAS: Texture2D = preload("res://assets/environment/storybook/tree-painted-albedo.png")
const MAPPING_PATH: String = "res://assets/environment/moonwood_tree_mapping.json"
const CHUNK_SIZE: float = 32.0
var build_errors: PackedStringArray = []
var mappings: Dictionary[String, Dictionary] = {}
var meshes: Dictionary[String, Mesh] = {}
var batches: Dictionary[String, MultiMeshInstance3D] = {}
var tree_ids: PackedStringArray = []

# Shared per-variant ratios over neutral painted atlas, not original vertex tint.
const SPECIES_TINTS: Dictionary = {
	"alder":[Vector3(.90,.97,.90),Vector3.ONE],
	"birch":[Vector3(1.12,1.08,.91),Vector3(1.85,2.15,2.45)],
	"cherry":[Vector3(.96,.99,.96),Vector3.ONE],
	"maple":[Vector3(1.85,.78,.60),Vector3.ONE],
	"oak":[Vector3.ONE,Vector3.ONE],
	"pine":[Vector3(.70,.84,1.12),Vector3.ONE],
	"rowan":[Vector3(1.12,.99,.84),Vector3.ONE],
	"spruce":[Vector3(.65,.78,1.20),Vector3.ONE],
	"willow":[Vector3(1.10,1.07,.91),Vector3.ONE],
}


func build(population: AlderwakeForestPopulation) -> void:
	name = "TreeArtBatches"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAPPING_PATH))
	if not parsed is Dictionary or parsed.get("snapshot_id") != "alderwake-f4630f9-m002":
		build_errors.append("Tree mapping missing or wrong snapshot")
		return
	var kit: Node3D = KIT.instantiate()
	var painted_kit: Node3D = PAINTED_KIT.instantiate()
	var rollout_kit: Node3D = ROLLOUT_KIT.instantiate()
	var painted_visuals: Dictionary[String, MeshInstance3D] = {}
	for visual: Node in painted_kit.find_children("*", "MeshInstance3D", true, false):
		painted_visuals[str(visual.name)] = visual
	for visual: Node in rollout_kit.find_children("*", "MeshInstance3D", true, false):
		painted_visuals[str(visual.name)] = visual
	for visual: Node in kit.find_children("*", "MeshInstance3D", true, false):
		# Godot importer can place glTF materials on the instance rather than
		# the mesh. MultiMesh has no per-surface instance overrides.
		var source_visual: MeshInstance3D = painted_visuals.get(str(visual.name), visual)
		var painted: bool = painted_visuals.has(str(visual.name))
		var mesh: ArrayMesh = source_visual.mesh.duplicate()
		for surface: int in range(mesh.get_surface_count()):
			var material: StandardMaterial3D = source_visual.get_active_material(surface)
			# Every species samples existing atlas once; source family accents use UV2.
			var visibility: ShaderMaterial = ShaderMaterial.new()
			visibility.shader = VISIBILITY_SHADER
			visibility.set_shader_parameter("base_color", material.albedo_color)
			visibility.set_shader_parameter("surface_roughness", material.roughness)
			visibility.set_shader_parameter("use_painted_texture", painted)
			visibility.set_shader_parameter("use_vertex_tint", not painted)
			if painted:
				visibility.set_shader_parameter("painted_albedo", PAINTED_ATLAS)
				var species: String = str(visual.name).split("-")[1]
				visibility.set_shader_parameter("painted_canopy_tint", SPECIES_TINTS[species][0])
				visibility.set_shader_parameter("painted_bark_tint", SPECIES_TINTS[species][1])
			visibility_materials.append(visibility)
			mesh.surface_set_material(surface, visibility)
		meshes[str(visual.name)] = mesh
	for record: Dictionary in parsed.mappings:
		if mappings.has(record.definition_id) or not meshes.has(record.mesh_name):
			build_errors.append("Tree mapping duplicate or missing mesh: " + record.definition_id)
			continue
		mappings[record.definition_id] = record
	kit.free()
	painted_kit.free()
	rollout_kit.free()
	var grouped: Dictionary[String, Array] = {}
	for record: Dictionary in population.prop_records:
		if record.tree == null:
			continue
		var mapping: Dictionary = mappings.get(record.definition_id, {})
		if mapping.is_empty() or mapping.species != record.tree.species or mapping.size != record.tree.size:
			build_errors.append("Unmapped tree: " + record.id)
			continue
		var wrapper: Node3D = population.get_node(NodePath(record.id))
		var chunk: Vector2i = Vector2i(floori(wrapper.position.x / CHUNK_SIZE), floori(wrapper.position.z / CHUNK_SIZE))
		var key: String = "%s--%d--%d" % [record.definition_id, chunk.x, chunk.y]
		if not grouped.has(key):
			grouped[key] = []
		grouped[key].append(wrapper)
		tree_ids.append(record.id)
		wrapper.set_meta("tree_art_definition", record.definition_id)
		wrapper.set_meta("tree_art_mesh", mapping.mesh_name)
		wrapper.set_meta("tree_art_batch", key)
		wrapper.set_meta("tree_art_index", grouped[key].size() - 1)
		# Remove only old tree art, never its sibling source polygon body.
		var visual_root: Node3D = wrapper.get_node("VisualRoot")
		for child: Node in visual_root.get_children():
			visual_root.remove_child(child)
			child.free()
		visual_root.set_meta("batched_tree_art", key)
	for key: String in grouped:
		var wrappers: Array = grouped[key]
		var definition: String = wrappers[0].get_meta("tree_art_definition")
		var batch: MultiMeshInstance3D = MultiMeshInstance3D.new()
		batch.name = key
		batch.multimesh = MultiMesh.new()
		batch.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		batch.multimesh.mesh = meshes[mappings[definition].mesh_name]
		batch.multimesh.instance_count = wrappers.size()
		# Chunk-local transforms keep culling bounds small; no random placement/yaw.
		batch.position = Vector3(floorf(wrappers[0].position.x / CHUNK_SIZE) * CHUNK_SIZE, 0, floorf(wrappers[0].position.z / CHUNK_SIZE) * CHUNK_SIZE)
		for index: int in range(wrappers.size()):
			var transform: Transform3D = wrappers[index].transform
			transform.origin -= batch.position
			batch.multimesh.set_instance_transform(index, transform)
		add_child(batch)
		batches[key] = batch


func update_visibility(camera: Camera3D, hero: Node3D, ally: Node3D) -> void:
	var enabled: bool = is_instance_valid(hero) and is_instance_valid(ally)
	for material: ShaderMaterial in visibility_materials:
		material.set_shader_parameter("protect_party", enabled)
		if enabled:
			material.set_shader_parameter("camera_view", camera.get_camera_transform().affine_inverse())
			material.set_shader_parameter("camera_projection", camera.get_camera_projection())
			material.set_shader_parameter("hero_center", hero.global_position + Vector3.UP * 0.8)
			material.set_shader_parameter("ally_center", ally.global_position + Vector3.UP * 0.8)
