class_name ForagingWorldAdapter
extends Node3D
## Nonblocking replaceable visuals/typed wrappers from committed location facts.
var targets: Dictionary[String, PrototypeInteractable] = {}

func apply(location_id: String, facts: Dictionary, source_records: Array[Dictionary]) -> void:
	var desired: Dictionary = {}
	if location_id == ForagingRegistry.LOCATION:
		for record: Dictionary in source_records:
			if record.kind != "resourceNode": continue
			var entry: Dictionary = ForagingRegistry.find(record.id)
			if not entry.is_empty() and not entry.instance_id in facts.collected_resource_ids:
				desired[entry.instance_id] = entry.duplicate()
	for placement: Dictionary in facts.world_item_placements:
		if placement.location_id != location_id: continue
		var xyz: Array = placement.foot_xyz_m
		desired[placement.instance_id] = {"instance_id":placement.instance_id,
			"location_id":location_id, "resource_id":ForagingRegistry.ROD_RESOURCE,
			"item_id":ForagingRegistry.ROD_ITEM, "foot":Vector3(xyz[0],xyz[1],xyz[2])}
	for id: String in targets.keys():
		if not desired.has(id):
			var old: PrototypeInteractable = targets[id]
			targets.erase(id)
			remove_child(old)
			old.queue_free()
	for id: String in desired:
		var entry: Dictionary = desired[id]
		if not targets.has(id):
			var target: PrototypeInteractable = PrototypeInteractable.new()
			target.name = id
			target.instance_id = id
			target.kind = "pickup" if entry.item_id == ForagingRegistry.ROD_ITEM else "gather"
			target.prompt = "Pick up fishing rod" if target.kind == "pickup" else "Gather moonflower"
			target.reach = 1.5
			target.foraging_action = ForagingAction.new()
			target.foraging_action.instance_id = id
			target.foraging_action.location_id = location_id
			target.foraging_action.resource_id = entry.resource_id
			add_child(target)
			targets[id] = target
			_build_visual(target)
		targets[id].position = entry.foot

func _build_visual(target: PrototypeInteractable) -> void:
	var visual: Node3D = Node3D.new()
	visual.name = "VisualRoot"
	target.add_child(visual)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.94,0.74,0.3) if target.kind == "pickup" else Color(0.76,0.83,1)
	material.roughness = 0.8
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "PickupMesh"
	if target.kind == "pickup":
		var rod: CylinderMesh = CylinderMesh.new()
		rod.top_radius = 0.025
		rod.bottom_radius = 0.045
		rod.height = 0.9
		mesh.mesh = rod
		mesh.rotation.z = PI / 2
		mesh.position.y = 0.08
	else:
		var bloom: SphereMesh = SphereMesh.new()
		bloom.radius = 0.17
		bloom.height = 0.25
		mesh.mesh = bloom
		mesh.position.y = 0.3
		var stem: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.02
		cylinder.bottom_radius = 0.025
		cylinder.height = 0.25
		stem.mesh = cylinder
		stem.position.y = 0.125
		var green: StandardMaterial3D = StandardMaterial3D.new()
		green.albedo_color = Color(0.3,0.55,0.32)
		stem.material_override = green
		visual.add_child(stem)
	mesh.material_override = material
	visual.add_child(mesh)
	var label: Label3D = Label3D.new()
	label.text = "Fishing rod" if target.kind == "pickup" else "Moonflower"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 0.75
	label.font_size = 22
	label.pixel_size = 0.01
	visual.add_child(label)
