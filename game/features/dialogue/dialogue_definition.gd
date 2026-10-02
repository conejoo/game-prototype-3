class_name DialogueDefinition
extends ContentDefinition
## Catalog fixture only; no dialogue runner, choices, or narrative effects yet.

@export var speaker_actor_id: String = ""
@export var lines: PackedStringArray = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if speaker_actor_id.is_empty():
		errors.append("speaker_actor_id must be nonempty")
	if lines.is_empty():
		errors.append("lines must contain at least one line")
	for line: String in lines:
		if line.strip_edges().is_empty():
			errors.append("lines contains a blank line")
	return errors
