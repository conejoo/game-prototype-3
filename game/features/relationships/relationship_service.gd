class_name RelationshipService
extends RefCounted
## Commit reaction and trust together; decision alternatives are mutually exclusive.

signal changed
var catalog: ContentCatalog
var session: GameSession

func initialize(content: ContentCatalog, run: GameSession) -> void:
	catalog = content
	session = run

func apply(id: String) -> DialogueService.ActionResult:
	var definition: ReactionDefinition = catalog.get_reaction(id)
	if definition == null:
		return DialogueService.ActionResult.new(false, "Unknown companion reaction.")
	for recorded: String in session.relationship.reaction_ids:
		if catalog.get_reaction(recorded).decision_id == definition.decision_id:
			return DialogueService.ActionResult.new(recorded == id, "Decision already recorded; trust unchanged.")
	session.relationship.reaction_ids.append(id)
	session.relationship.trust += definition.trust_delta
	changed.emit()
	return DialogueService.ActionResult.new(true, "%s · Trust %+d (now %d)." % [definition.display_name, definition.trust_delta, session.relationship.trust])

static func validate_state(data: Variant, catalog: ContentCatalog) -> PackedStringArray:
	if not data is Dictionary or data.size() != 3 or not data.has_all(["companion_id", "trust", "reaction_ids"]) or data.get("companion_id") != "prototype-companion" or not data.get("reaction_ids") is Array:
		return PackedStringArray(["invalid companion relationship fields/identity"])
	var decisions: PackedStringArray = []
	var expected: int = 0
	for id: Variant in data.reaction_ids:
		if not id is String:
			return PackedStringArray(["reaction ID must be string"])
		var definition: ReactionDefinition = catalog.get_reaction(id)
		if definition == null or definition.decision_id in decisions:
			return PackedStringArray(["unknown/duplicate/conflicting reaction"])
		decisions.append(definition.decision_id)
		expected += definition.trust_delta
	if not (data.trust is int or data.trust is float) or not is_finite(float(data.trust)) or float(data.trust) != float(expected):
		return PackedStringArray(["trust disagrees with recorded reactions"])
	return []

func description() -> String:
	var text: String = "Temporary companion (noncanonical) · Trust %d" % session.relationship.trust
	for id: String in session.relationship.reaction_ids:
		text += "\nReaction: " + catalog.get_reaction(id).display_name
	return text
