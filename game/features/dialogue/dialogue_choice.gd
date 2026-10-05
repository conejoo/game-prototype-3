class_name DialogueChoice
extends Resource
## Immutable authored choice; quest/reaction commands delegate to owning services.

@export var stable_id: String = ""
@export var label: String = ""
@export var action_id: String = "prototype-observe"
@export var quest_id: String = ""
@export var reaction_id: String = ""
@export var response: PackedStringArray = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if stable_id.is_empty() or stable_id != stable_id.strip_edges():
		errors.append("choice ID must be nonempty and unpadded")
	if label.strip_edges().is_empty():
		errors.append("choice label must be nonempty")
	if not reaction_id.is_empty() and (not quest_id.is_empty() or action_id != "companion-react"):
		errors.append("reaction requires companion-react action and no quest command")
	if action_id not in ["prototype-observe", "prototype-leave"] and reaction_id.is_empty() and (quest_id.is_empty() or action_id.is_empty()):
		errors.append("unsupported dialogue action '%s'" % action_id)
	if response.is_empty():
		errors.append("choice response must contain at least one line")
	for line: String in response:
		if line.strip_edges().is_empty():
			errors.append("choice response contains a blank line")
	return errors
