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
		if not (definition is ActorDefinition or definition is LocationDefinition or definition is DialogueDefinition):
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


func _validate_actor_reference(candidate: Dictionary[String, ContentDefinition], owner_id: String, actor_id: String, errors: PackedStringArray) -> void:
	if not candidate.has(actor_id):
		errors.append("'%s': missing actor reference '%s'" % [owner_id, actor_id])
	elif not candidate[actor_id] is ActorDefinition:
		errors.append("'%s': reference '%s' must be an ActorDefinition" % [owner_id, actor_id])
