class_name ForagingAction
extends Resource
## Typed immutable command identity; no state or target ownership.
@export var location_id: String = ""
@export var instance_id: String = ""
@export var resource_id: String = ""

func validation_errors(catalog: ContentCatalog) -> PackedStringArray:
	var definition: ForagingResourceDefinition = catalog.get_resource(resource_id)
	if definition == null:
		return PackedStringArray(["foraging action references missing resource"])
	var entry: Dictionary = ForagingRegistry.find(instance_id)
	if instance_id == ForagingRegistry.DROP_ID:
		if resource_id != ForagingRegistry.ROD_RESOURCE or not location_id in ForagingRegistry.PLACEMENT_LOCATIONS:
			return PackedStringArray(["invalid dropped pickup identity"])
	elif entry.is_empty() or entry.location_id != location_id or entry.resource_id != resource_id:
		return PackedStringArray(["foraging action identity mismatch"])
	return []
