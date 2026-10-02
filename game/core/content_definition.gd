class_name ContentDefinition
extends Resource
## Authored data, treated as immutable after catalog initialization.

@export var stable_id: String = ""
@export var display_name: String = ""
@export var prototype_fixture: bool = false


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if stable_id.is_empty() or stable_id != stable_id.strip_edges():
		errors.append("stable_id must be nonempty with no surrounding whitespace")
	if display_name.strip_edges().is_empty():
		errors.append("display_name must be nonempty")
	return errors
