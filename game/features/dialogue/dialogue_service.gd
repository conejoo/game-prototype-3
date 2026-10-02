class_name DialogueService
extends RefCounted
## Transient runtime conversation, separate from definitions/session/physical NPC.
## Quest commands delegate to injected owner; rejected commands leave cursor intact.

class ActionResult extends RefCounted:
	var ok: bool
	var message: String
	var action_id: String

	func _init(success: bool, description: String, action: String = "") -> void:
		ok = success
		message = description
		action_id = action

var definition: DialogueDefinition
var quest_command: Callable
var source_instance_id: String = ""
var line_index: int = 0
var selected_choice_id: String = ""
var last_result: ActionResult = ActionResult.new(true, "No conversation started.")


func active() -> bool:
	return definition != null


func begin(content: DialogueDefinition, instance_id: String) -> ActionResult:
	if active():
		return _result(false, "Conversation already active.")
	if content == null or not content.validation_errors().is_empty() or instance_id.is_empty():
		return _result(false, "Invalid dialogue or interaction identity.")
	definition = content
	source_instance_id = instance_id
	line_index = 0
	selected_choice_id = ""
	return _result(true, "Conversation opened.")


func current_lines() -> PackedStringArray:
	if not active():
		return []
	for choice: DialogueChoice in definition.choices:
		if choice.stable_id == selected_choice_id:
			return choice.response
	return definition.lines


func awaiting_choice() -> bool:
	return active() and selected_choice_id.is_empty() and not definition.choices.is_empty() and line_index == current_lines().size() - 1


func advance() -> ActionResult:
	if not active():
		return _result(false, "No active conversation.")
	if awaiting_choice():
		return _result(false, "Choose a response first.")
	if line_index + 1 < current_lines().size():
		line_index += 1
		return _result(true, "Next line.")
	return cancel("Conversation finished.")


func choose(choice_id: String) -> ActionResult:
	if not awaiting_choice():
		return _result(false, "No choice available.")
	for choice: DialogueChoice in definition.choices:
		if choice.stable_id == choice_id:
			# Explicit dispatch. Unknown commands never succeed or mutate run state.
			var message: String = "Prototype response shown; no persistent effects."
			if not choice.quest_id.is_empty():
				if not quest_command.is_valid():
					return _result(false, "Quest owner unavailable.")
				var result: ActionResult = quest_command.call(choice.quest_id, choice.action_id, source_instance_id)
				if not result.ok:
					return _result(false, result.message, choice.action_id)
				message = result.message
			elif choice.action_id not in ["prototype-observe", "prototype-leave"]:
				return _result(false, "Unsupported dialogue action.")
			selected_choice_id = choice_id
			line_index = 0
			return _result(true, message, choice.action_id)
	return _result(false, "Unknown choice '%s'." % choice_id)


func cancel(message: String = "Conversation cancelled.") -> ActionResult:
	definition = null
	source_instance_id = ""
	selected_choice_id = ""
	line_index = 0
	return _result(true, message)


func _result(ok: bool, message: String, action_id: String = "") -> ActionResult:
	last_result = ActionResult.new(ok, message, action_id)
	return last_result
