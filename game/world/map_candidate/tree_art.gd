class_name AlderwakeTreeArt
extends Node3D
## Appearance only. Source wrappers retain identity/feet/physics independently.

const KIT: PackedScene = preload("res://assets/environment/moonwood_tree_kit.glb")
const MAPPING_PATH: String = "res://assets/environment/moonwood_tree_mapping.json"
const CHUNK_SIZE: float = 32.0
var build_errors: PackedStringArray = []
var mappings: Dictionary[String, Dictionary] = {}
var meshes: Dictionary[String, Mesh] = {}
var batches: Dictionary[String, MultiMeshInstance3D] = {}
var tree_ids: PackedStringArray = []


func build(population: AlderwakeForestPopulation) -> void:
	name = "TreeArtBatches"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAPPING_PATH))
	if not parsed is Dictionary or parsed.get("snapshot_id") != "alderwake-f4630f9-m002":
		build_errors.append("Tree mapping missing or wrong snapshot")
		return
	var kit: Node3D = KIT.instantiate()
	for visual: Node in kit.find_children("*", "MeshInstance3D", true, false):
		# Godot importer can place glTF materials on the instance rather than
		# the mesh. MultiMesh has no per-surface instance overrides.
		var mesh: ArrayMesh = visual.mesh.duplicate()
		for surface: int in range(mesh.get_surface_count()):
			var material: StandardMaterial3D = visual.get_active_material(surface).duplicate()
			# This Godot import leaves COLOR_0 disabled on its shared material.
			# Enable the exported palette explicitly on our local art resource.
			material.vertex_color_use_as_albedo = true
			mesh.surface_set_material(surface, material)
		meshes[str(visual.name)] = mesh
	for record: Dictionary in parsed.mappings:
		if mappings.has(record.definition_id) or not meshes.has(record.mesh_name):
			build_errors.append("Tree mapping duplicate or missing mesh: " + record.definition_id)
			continue
		mappings[record.definition_id] = record
	kit.free()
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
