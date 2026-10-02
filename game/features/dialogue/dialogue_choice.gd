class_name DialogueChoice
extends Resource
## Immutable authored choice. P006 actions are presentation-only, no rewards.

@export var stable_id: String = ""
@export var label: String = ""
@export var action_id: String = "prototype-observe"
@export var response: PackedStringArray = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if stable_id.is_empty() or stable_id != stable_id.strip_edges():
		errors.append("choice ID must be nonempty and unpadded")
	if label.strip_edges().is_empty():
		errors.append("choice label must be nonempty")
	if action_id not in ["prototype-observe", "prototype-leave"]:
		errors.append("unsupported dialogue action '%s'" % action_id)
	if response.is_empty():
		errors.append("choice response must contain at least one line")
	for line: String in response:
		if line.strip_edges().is_empty():
			errors.append("choice response contains a blank line")
	return errors
