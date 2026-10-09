class_name PortalBinding
extends Resource
## Authored directed edge. Identity is qualified by source location.

@export var portal_id: String = ""
@export var source_location_id: String = ""
@export var destination_location_id: String = ""
@export var arrival_id: String = ""

func snapshot() -> Dictionary:
	return {"portal_id":portal_id, "source_location_id":source_location_id,
		"destination_location_id":destination_location_id, "arrival_id":arrival_id}

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	for key: String in snapshot():
		var value: String = snapshot()[key]
		if value.is_empty() or value != value.strip_edges(): errors.append("portal %s must be nonempty and unpadded" % key)
	if source_location_id == destination_location_id: errors.append("portal must connect distinct locations")
	return errors
