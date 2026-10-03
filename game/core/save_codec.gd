class_name SaveCodec
extends RefCounted
## Versioned plain-data boundary. Validation creates a detached candidate only.

const SCHEMA_VERSION: int = 4
const CONTENT_VERSION: int = 1
const MAX_BYTES: int = 131072

class DecodeResult:
	extends RefCounted
	var session: GameSession
	var errors: PackedStringArray = []
	var incompatible: bool = false
	var migrated: bool = false


static func snapshot(run: GameSession) -> Dictionary:
	var actor_data: Array[Dictionary] = []
	var quest_data: Dictionary = {}
	for id: String in run.quests:
		quest_data[id] = Array(run.quests[id].completed_step_ids)
	for id: String in run.party_member_ids:
		var actor: ActorState = run.actors.get(id)
		if actor != null:
			actor_data.append({"instance_id": id, "definition_id": actor.definition_id, "health": actor.health})
	return {
		"schema_version": SCHEMA_VERSION, "content_version": CONTENT_VERSION,
		"location_id": run.current_location_id, "spawn_id": run.current_spawn_id,
		"player_instance_id": GameSession.PLAYER_INSTANCE_ID,
		"party_member_ids": Array(run.party_member_ids), "actors": actor_data,
		"elapsed_play_seconds": run.elapsed_play_seconds,
		"quests": quest_data, "completed_effect_ids": Array(run.completed_effect_ids),
		"relationship": {"companion_id": "prototype-companion", "trust": run.relationship.trust, "reaction_ids": Array(run.relationship.reaction_ids)},
		"progression": {"upgrade_ids": Array(run.progression.upgrade_ids)},
	}


static func decode(raw: String, catalog: ContentCatalog) -> DecodeResult:
	var result: DecodeResult = DecodeResult.new()
	if raw.to_utf8_buffer().size() > MAX_BYTES:
		result.errors.append("save exceeds 128KiB limit")
		return result
	var parser: JSON = JSON.new()
	if parser.parse(raw) != OK:
		result.errors.append("invalid save JSON at line %d: %s" % [parser.get_error_line(), parser.get_error_message()])
		return result
	return validate(parser.data, catalog)


static func validate(raw_data: Variant, catalog: ContentCatalog) -> DecodeResult:
	var result: DecodeResult = DecodeResult.new()
	var data: Variant = raw_data
	if catalog == null or not catalog.initialized:
		result.errors.append("save requires initialized catalog")
		return result
	if not data is Dictionary:
		result.errors.append("save envelope must be an object")
		return result
	for key: String in ["schema_version", "content_version"]:
		if not _integer(data.get(key), 1, 2147483647):
			result.errors.append("%s must be a positive integer" % key)
			return result
		var supported: int = SCHEMA_VERSION if key == "schema_version" else CONTENT_VERSION
		if int(data[key]) != supported and not (key == "schema_version" and int(data[key]) in [1, 2, 3]):
			result.incompatible = true
			result.errors.append("unsupported %s %s; supported %d; files left unchanged" % [key, data[key], supported])
			return result
	var fields: Array[String] = ["schema_version", "content_version", "location_id", "spawn_id", "player_instance_id", "party_member_ids", "actors", "elapsed_play_seconds"]
	var legacy: bool = int(data.schema_version) < SCHEMA_VERSION
	var legacy_quests: bool = int(data.schema_version) == 1
	if not legacy_quests:
		fields.append_array(["quests", "completed_effect_ids"])
	if not legacy:
		fields.append_array(["relationship", "progression"])
	if not _exact_fields(data, fields):
		result.errors.append("schema v%d requires exactly: " % int(data.schema_version) + ", ".join(fields))
		return result
	result.migrated = legacy
	if legacy_quests:
		# Only exact v1 content-v1 envelopes migrate. Preserve caller and disk bytes.
		data = data.duplicate(true)
		data.schema_version = SCHEMA_VERSION
		data["quests"] = {}
		for quest: QuestDefinition in catalog.quest_definitions():
			data.quests[quest.stable_id] = []
		data["completed_effect_ids"] = []
		result.migrated = true
	result.errors = QuestService.validate_progress(data.quests, data.completed_effect_ids, catalog)
	if not result.errors.is_empty():
		return result
	if not data.location_id is String or not data.spawn_id is String:
		result.errors.append("location_id/spawn_id must be strings")
		return result
	var location: LocationDefinition = catalog.get_location(data.location_id)
	if location == null or not data.spawn_id in location.spawn_ids:
		result.errors.append("unknown saved location/spawn '%s/%s'; no ID remapping available" % [data.location_id, data.spawn_id])
		return result
	var expected_ids: Array[String] = [GameSession.PLAYER_INSTANCE_ID]
	var expected_definitions: Array[String] = ["prototype-hero"]
	if int(raw_data.schema_version) >= 3:
		expected_ids.append(GameSession.COMPANION_INSTANCE_ID)
		expected_definitions.append("prototype-companion")
	if data.player_instance_id != GameSession.PLAYER_INSTANCE_ID or not data.party_member_ids is Array or data.party_member_ids != expected_ids:
		result.errors.append("party must contain ordered IDs: " + ", ".join(expected_ids))
		return result
	if not data.actors is Array or data.actors.size() != expected_ids.size():
		result.errors.append("save requires %d actor records" % expected_ids.size())
		return result
	for index: int in range(expected_ids.size()):
		if not data.actors[index] is Dictionary:
			result.errors.append("actor record must be an object")
			return result
		var actor: Dictionary = data.actors[index]
		if not _exact_fields(actor, ["instance_id", "definition_id", "health"]) or actor.get("instance_id") != expected_ids[index] or actor.get("definition_id") != expected_definitions[index]:
			result.errors.append("invalid actor identity/fields for " + expected_ids[index])
			return result
		var definition: ActorDefinition = catalog.get_actor(actor.definition_id)
		if definition == null or not _integer(actor.health, 0, definition.max_health):
			result.errors.append("saved health must be an integer within actor definition limits")
			return result
	var seconds: Variant = data.elapsed_play_seconds
	if not (seconds is float or seconds is int) or not is_finite(float(seconds)) or float(seconds) < 0.0 or float(seconds) > 315360000.0:
		result.errors.append("elapsed_play_seconds must be finite, nonnegative, <=10 years")
		return result
	if not legacy:
		result.errors = RelationshipService.validate_state(data.relationship, catalog)
		result.errors.append_array(ProgressionService.validate_state(data.progression, data.completed_effect_ids, catalog))
		if not result.errors.is_empty():
			return result
	var candidate: GameSession = GameSession.new()
	result.errors = candidate.initialize(catalog, data.location_id, data.spawn_id, "prototype-hero")
	if result.errors.is_empty():
		for actor: Dictionary in data.actors:
			candidate.actors[actor.instance_id].health = int(actor.health)
		candidate.elapsed_play_seconds = float(seconds)
		for id: String in candidate.quests:
			candidate.quests[id].completed_step_ids = PackedStringArray(data.quests[id])
		candidate.completed_effect_ids = PackedStringArray(data.completed_effect_ids)
		if not legacy:
			candidate.relationship.trust = int(data.relationship.trust)
			candidate.relationship.reaction_ids = PackedStringArray(data.relationship.reaction_ids)
			candidate.progression.upgrade_ids = PackedStringArray(data.progression.upgrade_ids)
		result.session = candidate
	return result


static func _integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and float(value) >= minimum and float(value) <= maximum


static func _exact_fields(data: Dictionary, fields: Array[String]) -> bool:
	if data.size() != fields.size():
		return false
	for field: String in fields:
		if not data.has(field):
			return false
	return true
