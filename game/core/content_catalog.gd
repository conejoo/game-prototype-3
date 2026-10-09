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
	var definitions: Array[ContentDefinition] = manifest.definitions.duplicate()
	if not manifest.fishing_area_layout_path.is_empty():
		var adapted: FishingAreaAdapter.Result = FishingAreaAdapter.read_layout(manifest.fishing_area_layout_path)
		errors.append_array(adapted.errors)
		for area: FishingAreaDefinition in adapted.areas: definitions.append(area)
	for index: int in range(definitions.size()):
		var definition: ContentDefinition = definitions[index]
		if definition == null:
			errors.append("definition[%d] is null" % index)
			continue
		var label: String = "definition[%d] '%s'" % [index, definition.stable_id]
		if not (definition is ActorDefinition or definition is LocationDefinition or definition is ConversationDefinition or definition is QuestDefinition or definition is ReactionDefinition or definition is UpgradeDefinition or definition is ItemDefinition or definition is ForagingResourceDefinition or definition is FishingAreaDefinition):
			errors.append("%s has unsupported definition type" % label)
		for error: String in definition.validation_errors():
			errors.append("%s: %s" % [label, error])
		if candidate.has(definition.stable_id):
			errors.append("%s: duplicate stable ID" % label)
		else:
			candidate[definition.stable_id] = definition
	var item_sources: PackedStringArray = []
	var resource_sources: PackedStringArray = []
	var fishing_weight: float = 0.0
	for definition: ContentDefinition in definitions:
		if definition is ItemDefinition:
			var item: ItemDefinition = definition as ItemDefinition
			if item.source_item_id in item_sources:
				errors.append("duplicate source item ID")
			item_sources.append(item.source_item_id)
		elif definition is FishingAreaDefinition:
			var area: FishingAreaDefinition = definition
			fishing_weight += area.blend_weight
			if not candidate.get(area.location_id) is LocationDefinition:
				errors.append("fishing area references unknown location")
			for source_id: String in area.outcome_source_ids:
				var fish: ItemDefinition = null
				for content: ContentDefinition in definitions:
					if content is ItemDefinition and (content as ItemDefinition).source_item_id == source_id: fish = content
				if fish == null or fish.category != "fish" or fish.fishing_challenge == null:
					errors.append("fishing area references unknown/nonfish outcome '%s'" % source_id)
		elif definition is ForagingResourceDefinition:
			var resource: ForagingResourceDefinition = definition as ForagingResourceDefinition
			if resource.source_resource_id in resource_sources:
				errors.append("duplicate source resource ID")
			resource_sources.append(resource.source_resource_id)
			var item: ItemDefinition = candidate.get(resource.item_id) as ItemDefinition
			if item == null:
				errors.append("resource references absent/wrong item '%s'" % resource.item_id)
			elif item.source_item_id != resource.source_resource_id:
				errors.append("resource and item source IDs must match")
		elif definition is LocationDefinition:
			for actor_id: String in (definition as LocationDefinition).actor_ids:
				_validate_actor_reference(candidate, definition.stable_id, actor_id, errors)
		elif definition is ConversationDefinition:
			var conversation: ConversationDefinition = definition
			_validate_actor_reference(candidate, definition.stable_id, conversation.speaker_actor_id, errors)
			if conversation.validation_errors().is_empty():
				for choice: NpcDialogueGraph.Choice in conversation.graph().choices.values():
					var command: Dictionary = choice.command
					if not command.get("reaction_id", "").is_empty():
						var reaction: ReactionDefinition = candidate.get(command.reaction_id) as ReactionDefinition
						if reaction == null or reaction.companion_id != conversation.speaker_actor_id: errors.append("dialogue references absent/wrong companion reaction")
					if not command.get("quest_id", "").is_empty():
						var quest: QuestDefinition = candidate.get(command.quest_id) as QuestDefinition
						var found: bool = false
						if quest != null:
							for step: QuestStep in quest.steps:
								if step != null and step.action_id == command.action_id: found = true
						if not found: errors.append("dialogue references absent quest/action")
		elif definition is ReactionDefinition:
			_validate_actor_reference(candidate, definition.stable_id, (definition as ReactionDefinition).companion_id, errors)
			if (definition as ReactionDefinition).companion_id != "prototype-companion":
				errors.append("reaction must target temporary companion")
		elif definition is QuestDefinition:
			for step: QuestStep in (definition as QuestDefinition).steps:
				if step != null and not candidate.get(step.location_id) is LocationDefinition:
					errors.append("quest references absent location '%s'" % step.location_id)
	if not is_finite(fishing_weight): errors.append("aggregate fishing weights must be finite")
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


func get_dialogue(id: String) -> ConversationDefinition:
	return _definitions.get(id) as ConversationDefinition


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


func get_item(id: String) -> ItemDefinition:
	return _definitions.get(id) as ItemDefinition


func get_resource(id: String) -> ForagingResourceDefinition:
	return _definitions.get(id) as ForagingResourceDefinition


func get_item_by_source(source_id: String) -> ItemDefinition:
	for definition: ContentDefinition in _definitions.values():
		if definition is ItemDefinition and (definition as ItemDefinition).source_item_id == source_id:
			return definition as ItemDefinition
	return null


func fishing_areas() -> Array[FishingAreaDefinition]:
	var result: Array[FishingAreaDefinition] = []
	for definition: ContentDefinition in _definitions.values():
		if definition is FishingAreaDefinition: result.append(definition as FishingAreaDefinition)
	result.sort_custom(func(a: FishingAreaDefinition, b: FishingAreaDefinition) -> bool: return a.stable_id < b.stable_id)
	return result
