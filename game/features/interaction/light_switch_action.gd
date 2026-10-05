class_name LightSwitchAction
extends Resource
## Immutable authored source identity; runtime enabled state stays in the session.

@export var location_id: String = ""
@export var prop_id: String = ""
@export var source_id: String = ""


func validation_errors() -> PackedStringArray:
	var source: Dictionary = LightSourceRegistry.find(location_id, prop_id, source_id)
	if source.is_empty() or not source.switchable:
		return PackedStringArray(["light action must name a known switchable source"])
	return PackedStringArray()
