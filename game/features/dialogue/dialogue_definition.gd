class_name DialogueDefinition
extends ContentDefinition
## Immutable authored introduction and terminal choice responses, outside scenes.

@export var speaker_actor_id: String = ""
@export var lines: PackedStringArray = []
@export var choices: Array[DialogueChoice] = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if speaker_actor_id.is_empty():
		errors.append("speaker_actor_id must be nonempty")
	if lines.is_empty():
		errors.append("lines must contain at least one line")
	for line: String in lines:
		if line.strip_edges().is_empty():
			errors.append("lines contains a blank line")
	var seen: PackedStringArray = []
	for choice: DialogueChoice in choices:
		if choice == null:
			errors.append("dialogue choice is null")
			continue
		for error: String in choice.validation_errors():
			errors.append("choice '%s': %s" % [choice.stable_id, error])
		if choice.stable_id in seen:
			errors.append("duplicate choice ID '%s'" % choice.stable_id)
		seen.append(choice.stable_id)
	return errors
