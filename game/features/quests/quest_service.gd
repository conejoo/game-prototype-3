class_name QuestService
extends RefCounted
## Node-independent commands. Commit step and durable effect before notification.

signal changed

var catalog: ContentCatalog
var session: GameSession


func initialize(content: ContentCatalog, run: GameSession) -> void:
	catalog = content
	session = run


func apply(quest_id: String, action_id: String, location_id: String, source_id: String) -> NpcDialogueService.Result:
	var definition: QuestDefinition = catalog.get_quest(quest_id)
	var state: QuestState = session.quests.get(quest_id)
	if definition == null or state == null:
		return NpcDialogueService.Result.new(false, "Unknown quest.", action_id)
	for index: int in range(definition.steps.size()):
		var step: QuestStep = definition.steps[index]
		if step.action_id != action_id:
			continue
		if step.location_id != location_id or step.source_id != source_id:
			return NpcDialogueService.Result.new(false, "Wrong quest location or source.", action_id)
		if index < state.completed_step_ids.size():
			return NpcDialogueService.Result.new(true, "Already recorded; no effect repeated.", action_id)
		if index != state.completed_step_ids.size():
			return NpcDialogueService.Result.new(false, "Prerequisite incomplete. " + objective(quest_id), action_id)
		if step.effect_id in session.completed_effect_ids:
			return NpcDialogueService.Result.new(false, "Inconsistent completed effect; command rejected.", action_id)
		state.completed_step_ids.append(step.stable_id)
		session.completed_effect_ids.append(step.effect_id)
		changed.emit()
		return NpcDialogueService.Result.new(true, "Recorded. " + objective(quest_id), action_id)
	return NpcDialogueService.Result.new(false, "Unknown quest action.", action_id)


func record_arrival(location_id: String) -> void:
	for definition: QuestDefinition in catalog.quest_definitions():
		var count: int = session.quests[definition.stable_id].completed_step_ids.size()
		if count < definition.steps.size():
			var step: QuestStep = definition.steps[count]
			if step.source_id == "location-arrival" and step.location_id == location_id:
				apply(definition.stable_id, step.action_id, location_id, "location-arrival")


func objective(quest_id: String) -> String:
	var definition: QuestDefinition = catalog.get_quest(quest_id)
	var count: int = session.quests[quest_id].completed_step_ids.size()
	return definition.steps[count].objective if count < definition.steps.size() else definition.completion_text


func journal() -> String:
	var entries: PackedStringArray = []
	for definition: QuestDefinition in catalog.quest_definitions():
		entries.append(definition.display_name)
		if not definition.journal_note.is_empty():
			entries.append(definition.journal_note + "\n")
		var count: int = session.quests[definition.stable_id].completed_step_ids.size()
		for index: int in range(definition.steps.size()):
			entries.append(("[done] " if index < count else ("[next] " if index == count else "[later] ")) + definition.steps[index].objective)
		entries.append("\n" + objective(definition.stable_id))
	return "\n".join(entries)


static func validate_progress(data: Variant, effects: Variant, catalog: ContentCatalog) -> PackedStringArray:
	if not data is Dictionary or not effects is Array:
		return PackedStringArray(["quests must be object; completed_effect_ids must be array"])
	var definitions: Array[QuestDefinition] = catalog.quest_definitions()
	if data.size() != definitions.size():
		return PackedStringArray(["quest set differs from compatible content"])
	var expected: Array[String] = []
	for definition: QuestDefinition in definitions:
		var progress: Variant = data.get(definition.stable_id)
		if not progress is Array or progress.size() > definition.steps.size():
			return PackedStringArray(["unknown/missing quest or malformed progress"])
		for index: int in range(progress.size()):
			if progress[index] != definition.steps[index].stable_id:
				return PackedStringArray(["quest progress must be legal ordered prefix"])
			expected.append(definition.steps[index].effect_id)
	if effects.size() != expected.size():
		return PackedStringArray(["completed effects disagree with quest progress"])
	var seen: Array[String] = []
	for effect: Variant in effects:
		if not effect is String or effect not in expected or effect in seen:
			return PackedStringArray(["unknown/duplicate completed effect"])
		seen.append(effect)
	return []
