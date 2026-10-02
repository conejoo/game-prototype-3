class_name QuestStep
extends Resource
## Ordered authored prerequisite: previous step must be complete.

@export var stable_id: String = ""
@export var action_id: String = ""
@export var effect_id: String = ""
@export var location_id: String = ""
@export var source_id: String = ""
@export var objective: String = ""


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	for value: String in [stable_id, action_id, effect_id, location_id, source_id, objective]:
		if value.is_empty() or value != value.strip_edges():
			errors.append("step fields must be nonempty and unpadded")
	return errors
