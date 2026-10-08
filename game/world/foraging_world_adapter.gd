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
	var visual: ForagingItemVisual = ForagingItemVisual.new()
	visual.name = "VisualRoot"
	target.add_child(visual)
	visual.build(target.kind == "pickup")
	var label: Label3D = Label3D.new()
	label.name = "ItemName"
	label.text = "Fishing rod" if target.kind == "pickup" else "Moonflower"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = .75
	label.font_size = 24
	label.outline_size = 8
	label.modulate = Color(.9,.95,1)
	label.outline_modulate = Color(.025,.045,.06)
	label.pixel_size = .014
	label.no_depth_test = true
	visual.add_child(label)
