class_name ContentCatalog
extends RefCounted
## Validates the full candidate before publishing indexes. Definitions are read-only.

var _definitions: Dictionary[String, ContentDefinition] = {}
var initialized: bool = false


func initialize(manifest: ContentManifest) -> PackedStringArray:
	var errors: PackedStringArray = []
	if manifest == null:
		return PackedStringArray(["catalog manifest is missing"])
	if manifest.definitions.is_empty():
		return PackedStringArray(["catalog manifest has no definitions"])
	var candidate: Dictionary[String, ContentDefinition] = {}
	for index: int in range(manifest.definitions.size()):
		var definition: ContentDefinition = manifest.definitions[index]
		if definition == null:
			errors.append("definition[%d] is null" % index)
			continue
		var label: String = "definition[%d] '%s'" % [index, definition.stable_id]
		if not (definition is ActorDefinition or definition is LocationDefinition or definition is DialogueDefinition or definition is QuestDefinition or definition is ReactionDefinition or definition is UpgradeDefinition):
			errors.append("%s has unsupported definition type" % label)
		for error: String in definition.validation_errors():
			errors.append("%s: %s" % [label, error])
		if candidate.has(definition.stable_id):
			errors.append("%s: duplicate stable ID" % label)
		else:
			candidate[definition.stable_id] = definition
	for definition: ContentDefinition in manifest.definitions:
		if definition is LocationDefinition:
			for actor_id: String in (definition as LocationDefinition).actor_ids:
				_validate_actor_reference(candidate, definition.stable_id, actor_id, errors)
		elif definition is DialogueDefinition:
			_validate_actor_reference(candidate, definition.stable_id, (definition as DialogueDefinition).speaker_actor_id, errors)
			for choice: DialogueChoice in (definition as DialogueDefinition).choices:
				if choice != null and not choice.reaction_id.is_empty():
					var reaction: ReactionDefinition = candidate.get(choice.reaction_id) as ReactionDefinition
					if reaction == null or reaction.companion_id != (definition as DialogueDefinition).speaker_actor_id:
						errors.append("dialogue references absent/wrong companion reaction")
				if choice != null and not choice.quest_id.is_empty():
					var quest: QuestDefinition = candidate.get(choice.quest_id) as QuestDefinition
					var found: bool = false
					if quest != null:
						for step: QuestStep in quest.steps:
							if step != null and step.action_id == choice.action_id:
								found = true
					if not found:
						errors.append("dialogue references absent quest/action")
		elif definition is ReactionDefinition:
			_validate_actor_reference(candidate, definition.stable_id, (definition as ReactionDefinition).companion_id, errors)
			if (definition as ReactionDefinition).companion_id != "prototype-companion":
				errors.append("reaction must target temporary companion")
		elif definition is QuestDefinition:
			for step: QuestStep in (definition as QuestDefinition).steps:
				if step != null and not candidate.get(step.location_id) is LocationDefinition:
					errors.append("quest references absent location '%s'" % step.location_id)
	# Effect identities must be unique across quests, too.
	var effects: PackedStringArray = []
	for definition: ContentDefinition in manifest.definitions:
		if definition is QuestDefinition:
			for step: QuestStep in (definition as QuestDefinition).steps:
				if step == null:
					continue
				if step.effect_id in effects:
					errors.append("duplicate global quest effect ID")
				effects.append(step.effect_id)
	for definition: ContentDefinition in manifest.definitions:
		if definition is UpgradeDefinition and (definition as UpgradeDefinition).earned_effect_id not in effects:
			errors.append("upgrade references absent earned effect")
	if errors.is_empty():
		_definitions = candidate
		initialized = true
	return errors


func get_actor(id: String) -> ActorDefinition:
	return _definitions.get(id) as ActorDefinition


func get_location(id: String) -> LocationDefinition:
	return _definitions.get(id) as LocationDefinition


func get_dialogue(id: String) -> DialogueDefinition:
	return _definitions.get(id) as DialogueDefinition


func definition_count() -> int:
	return _definitions.size()


func get_quest(id: String) -> QuestDefinition:
	return _definitions.get(id) as QuestDefinition


func quest_definitions() -> Array[QuestDefinition]:
	var result: Array[QuestDefinition] = []
	for id: String in _definitions:
		if _definitions[id] is QuestDefinition:
			result.append(_definitions[id] as QuestDefinition)
	result.sort_custom(func(a: QuestDefinition, b: QuestDefinition) -> bool: return a.stable_id < b.stable_id)
	return result


func _validate_actor_reference(candidate: Dictionary[String, ContentDefinition], owner_id: String, actor_id: String, errors: PackedStringArray) -> void:
	if not candidate.has(actor_id):
		errors.append("'%s': missing actor reference '%s'" % [owner_id, actor_id])
	elif not candidate[actor_id] is ActorDefinition:
		errors.append("'%s': reference '%s' must be an ActorDefinition" % [owner_id, actor_id])


func get_reaction(id: String) -> ReactionDefinition:
	return _definitions.get(id) as ReactionDefinition


func get_upgrade(id: String) -> UpgradeDefinition:
	return _definitions.get(id) as UpgradeDefinition
