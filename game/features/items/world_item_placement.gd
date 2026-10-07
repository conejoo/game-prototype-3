class_name WorldItemPlacement
extends RefCounted
## Plain Godot-metre facts. Services retain private copies, never caller objects.

const AUTHORED: String = "authored_override"
const GENERATED: String = "generated_drop"
var instance_id: String = ""
var item_id: String = ForagingRegistry.ROD_ITEM
var location_id: String = ""
var foot: Vector3 = Vector3.ZERO
var provenance: String = ""
var origin_instance_id: String = ForagingRegistry.ROD_ORIGIN


func _init(id: String = "", location: String = "", position: Vector3 = Vector3.ZERO, source: String = "") -> void:
	instance_id = id
	location_id = location
	foot = position
	provenance = source


func detached() -> WorldItemPlacement:
	var result: WorldItemPlacement = WorldItemPlacement.new(instance_id, location_id, foot, provenance)
	result.item_id = item_id
	result.origin_instance_id = origin_instance_id
	return result


func validation_errors() -> PackedStringArray:
	if item_id != ForagingRegistry.ROD_ITEM or origin_instance_id != ForagingRegistry.ROD_ORIGIN:
		return PackedStringArray(["invalid_placement_identity"])
	if not foot.is_finite():
		return PackedStringArray(["invalid_position"])
	if provenance == AUTHORED:
		if instance_id != ForagingRegistry.ROD_ORIGIN or location_id != ForagingRegistry.LOCATION:
			return PackedStringArray(["invalid_authored_placement"])
	elif provenance == GENERATED:
		if instance_id != ForagingRegistry.DROP_ID or not location_id in ForagingRegistry.PLACEMENT_LOCATIONS:
			return PackedStringArray(["invalid_generated_placement"])
	else:
		return PackedStringArray(["invalid_provenance"])
	return []


func to_dictionary() -> Dictionary:
	return {"instance_id": instance_id, "item_id": item_id, "location_id": location_id,
		"foot_xyz_m": [foot.x, foot.y, foot.z], "provenance": provenance, "origin_instance_id": origin_instance_id}
