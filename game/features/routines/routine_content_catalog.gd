class_name RoutineContentCatalog
extends RefCounted
## Data-only, strict detached catalog. Validate all files/references before publish.
## Declared portal connectivity is not physical route/room acceptance.
const PATH: String = "res://content/routines/catalog.json"
const REFERENCES: String = "res://content/routines/references.json"
const REFERENCES_SHA256: String = "86a805680f8d279c73a84e4a0f4f6f08fa230f35ef44e14bfed816a9a2b6993b"
const IDS: PackedStringArray = ["celia-repairs-day", "celia-repairs-evening", "della-inn-day", "della-inn-evening", "edric-afternoon-river-notes", "edric-afternoon-rounds", "edric-evening-fishing", "edric-evening-rain-shelter", "harlan-docks-day", "harlan-docks-evening", "helena-afternoon-archive", "helena-afternoon-ledger-review", "helena-afternoon-moonflower-records", "helena-evening-archive", "ivo-docks-day", "ivo-docks-evening", "maris-chandlery-day", "maris-chandlery-evening", "tess-store-day", "tess-store-evening", "vale-breakfast", "vale-evening-home", "vale-midday-briefing", "vale-morning-work", "vale-overnight-home"]
const MAX_INTEGER: int = 2147483647
var _initialized: bool = false
var initialized: bool:
	get: return _initialized
var _documents: Dictionary = {}
var _index: Dictionary = {}
var _references: Dictionary = {}

func initialize_path(npcs: NpcContentCatalog) -> PackedStringArray:
	if not FileAccess.file_exists(PATH): return PackedStringArray([PATH + ": missing catalog"])
	var texts: Dictionary = {}
	for id: String in IDS:
		var path: String = _asset(id)
		if not FileAccess.file_exists(path): return PackedStringArray(["routine " + id + " file " + path + ": missing file"])
		texts[path] = FileAccess.get_file_as_string(path)
	return initialize_texts(FileAccess.get_file_as_string(PATH), texts, npcs)

func initialize_texts(index_text: String, texts: Dictionary, npcs: NpcContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	var parsed: Dictionary = RoutineJson.new().decode(index_text, PATH)
	errors.append_array(parsed["errors"])
	var documents: Dictionary = {}
	for path: Variant in texts:
		if not path is String or not texts[path] is String:
			errors.append("routine file " + str(path) + ": expected JSON text")
			continue
		var decoded: Dictionary = RoutineJson.new().decode(texts[path], "routine " + str(path).get_file().get_basename() + " file " + str(path))
		errors.append_array(decoded["errors"])
		documents[path] = decoded.get("value")
	if not errors.is_empty(): return errors
	return initialize_documents(parsed.get("value"), documents, npcs)

func initialize_documents(value: Variant, documents: Dictionary, npcs: NpcContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	if npcs == null or not npcs.initialized:
		return PackedStringArray([PATH + ": requires validated current NPC catalog"])
	if not FileAccess.file_exists(REFERENCES) or FileAccess.get_sha256(REFERENCES) != REFERENCES_SHA256:
		return PackedStringArray([REFERENCES + ": R001 declaration pin drift; refuse catalog"])
	var decoded: Dictionary = RoutineJson.new().decode(FileAccess.get_file_as_string(REFERENCES), REFERENCES)
	if not decoded["errors"].is_empty(): return decoded["errors"]
	var refs: Dictionary = decoded["value"]
	var index: Dictionary = _object(value, ["schemaVersion", "routines"], PATH, errors)
	_integer(index.get("schemaVersion"), 1, 1, PATH + ".schemaVersion", errors)
	var rows: Array = _array(index.get("routines"), PATH + ".routines", errors)
	if rows.size() != IDS.size(): errors.append(PATH + ": requires exactly 25 selected routines")
	if documents.size() != IDS.size(): errors.append(PATH + ": requires exactly 25 routine files")
	var candidate: Dictionary = {}
	var assets: PackedStringArray = []
	for offset: int in rows.size():
		var label: String = PATH + ".routines[%d]" % offset
		var row: Dictionary = _object(rows[offset], ["schemaVersion", "id", "asset"], label, errors)
		_integer(row.get("schemaVersion"), 1, 1, label + ".schemaVersion", errors)
		var id: String = _id(row.get("id"), label + ".id", errors)
		if id not in IDS: errors.append(label + ": excluded/unknown routine " + id)
		if candidate.has(id): errors.append(label + ": duplicate routine ID " + id)
		var asset: String = _text(row.get("asset"), label + ".asset", errors)
		if asset != _asset(id): errors.append(label + ": unsupported file reference " + asset)
		if asset in assets: errors.append(label + ": duplicate asset " + asset)
		assets.append(asset)
		if not documents.has(asset):
			errors.append(label + " routine " + id + " file " + asset + ": missing routine document")
			continue
		candidate[id] = documents[asset]
		_validate(documents[asset], id, "routine " + id + " file " + asset, npcs, refs, errors)
	for id: String in IDS:
		if not candidate.has(id): errors.append(PATH + ": missing selected ID " + id)
	for asset: Variant in documents:
		if not asset is String or asset not in assets: errors.append(PATH + ": unindexed file " + str(asset))
	if errors.is_empty():
		# No prior published state changes until complete candidate validates.
		_documents = candidate.duplicate(true)
		_index = index.duplicate(true)
		_references = refs.duplicate(true)
		RoutineDefinition.freeze(_documents)
		RoutineDefinition.freeze(_index)
		RoutineDefinition.freeze(_references)
		_initialized = true
	return errors

func routine_ids() -> PackedStringArray:
	return IDS.duplicate() if initialized else PackedStringArray()

func definition_count() -> int: return _documents.size()

func get_routine(id: String) -> RoutineDefinition:
	return RoutineDefinition.new(_documents[id]) if _documents.has(id) else null

func document_snapshot(id: String) -> Dictionary:
	return _documents[id].duplicate(true) if _documents.has(id) else {}

func index_snapshot() -> Dictionary: return _index.duplicate(true)

func reference_snapshot() -> Dictionary: return _references.duplicate(true)

func _validate(value: Variant, expected_id: String, label: String, npcs: NpcContentCatalog, refs: Dictionary, errors: PackedStringArray) -> void:
	var start: int = errors.size()
	var doc: Dictionary = _object(value, ["schemaVersion", "id", "priority", "timeWindow", "participants", "conditions", "interactionPolicy", "participantSteps"], label, errors)
	_integer(doc.get("schemaVersion"), 1, 1, label + ".schemaVersion", errors)
	if _id(doc.get("id"), label + ".id", errors) != expected_id: errors.append(label + ": index/document identity mismatch")
	_integer(doc.get("priority"), 0, MAX_INTEGER, label + ".priority", errors)
	var window: Dictionary = _object(doc.get("timeWindow"), ["start", "end"], label + ".timeWindow", errors)
	for key: String in ["start", "end"]:
		var time: String = _text(window.get(key), label + ".timeWindow." + key, errors)
		if RegEx.create_from_string("^([01][0-9]|2[0-3]):[0-5][0-9]$").search(time) == null: errors.append(label + ".timeWindow." + key + ": expected HH:mm")
	if window.get("start") is String and window.get("end") is String and window["start"] == window["end"]: errors.append(label + ".timeWindow: equal/empty window")
	var participants: PackedStringArray = _ids(doc.get("participants"), label + ".participants", errors)
	if participants.is_empty(): errors.append(label + ": missing participants")
	for npc_id: String in participants: _reference(npc_id, npcs.npc_ids(), label + ".participants", errors)
	var conditions: Array = _array(doc.get("conditions"), label + ".conditions", errors)
	for offset: int in conditions.size(): _condition(conditions[offset], label + ".conditions[%d]" % offset, npcs, refs, errors)
	var plans: Dictionary = {}
	for row: Variant in _array(doc.get("participantSteps"), label + ".participantSteps", errors):
		var plan: Dictionary = _object(row, ["participantId", "steps"], label + ".participantSteps", errors)
		var npc_id: String = _id(plan.get("participantId"), label + ".participantId", errors)
		if npc_id not in participants: errors.append(label + ": undeclared participant plan " + npc_id)
		if plans.has(npc_id): errors.append(label + ": duplicate participant plan " + npc_id)
		var steps: Array = _array(plan.get("steps"), label + ".plan " + npc_id, errors)
		var ids: PackedStringArray = []
		var prior_map: String = ""
		if steps.is_empty(): errors.append(label + ".plan " + npc_id + ": missing steps")
		for offset: int in steps.size():
			var step_label: String = label + ".participant " + npc_id + ".steps[%d]" % offset
			var step: Dictionary = steps[offset] if steps[offset] is Dictionary else {}
			var step_id: String = _id(step.get("id"), step_label + ".id", errors)
			step_label += " step " + step_id
			if step_id in ids: errors.append(step_label + ": duplicate step ID")
			ids.append(step_id)
			var kind: String = _text(step.get("kind"), step_label + ".kind", errors)
			var keys: PackedStringArray = ["kind", "id"]
			match kind:
				"move": keys.append("target")
				"wait": keys.append("durationSeconds")
				"action": keys.append_array(["actionId", "durationSeconds"])
				"speech": keys.append_array(["text", "durationSeconds"])
				_: errors.append(step_label + ": unsupported step kind " + kind)
			_object(steps[offset], keys, step_label, errors)
			if kind == "move":
				var target: Dictionary = _object(step.get("target"), ["mapId", "anchorId"], step_label + ".target", errors)
				var map_id: String = _id(target.get("mapId"), step_label + ".mapId", errors)
				var anchors: PackedStringArray = []
				for map_row: Dictionary in refs["maps"]:
					if map_row["id"] == map_id: anchors = PackedStringArray(map_row["anchors"])
				if anchors.is_empty(): errors.append(step_label + ": unsupported map " + map_id)
				_reference(target.get("anchorId"), anchors, step_label + ".anchorId", errors)
				if not prior_map.is_empty() and not _connected(prior_map, map_id, refs): errors.append(step_label + ": missing directed portal chain " + prior_map + " -> " + map_id)
				prior_map = map_id
			elif kind in ["wait", "action", "speech"]:
				_number(step.get("durationSeconds"), true, step_label + ".durationSeconds", errors)
				if kind == "action":
					var npc: NpcDefinition = npcs.get_npc(npc_id)
					_reference(step.get("actionId"), npc.action_ids if npc != null else PackedStringArray(), step_label + ".actionId", errors)
				if kind == "speech": _text(step.get("text"), step_label + ".text", errors)
		plans[npc_id] = ids
	for npc_id: String in participants:
		if not plans.has(npc_id): errors.append(label + ": missing participant plan " + npc_id)
	# Structural errors must never lead to unsafe semantic indexing.
	if errors.size() != start: return
	_policy(doc["interactionPolicy"], participants, plans, label + ".interactionPolicy", npcs, refs, errors)

func _condition(value: Variant, label: String, npcs: NpcContentCatalog, refs: Dictionary, errors: PackedStringArray) -> void:
	var data: Dictionary = value if value is Dictionary else {}
	var kind: String = _text(data.get("kind"), label + ".kind", errors)
	var keys: PackedStringArray = ["kind"]
	match kind:
		"worldEventActive", "worldEventInactive": keys.append("eventId")
		"learnedFact": keys.append_array(["npcId", "factId"])
		"relationshipFlagSet", "relationshipFlagUnset": keys.append_array(["npcId", "flagId"])
		"playerEvent": keys.append_array(["eventKind", "subjectId", "targetId", "minimumCount", "maximumCount", "occurredWithinActiveSeconds"])
		_: errors.append(label + ": unsupported condition kind " + kind)
	_object(value, keys, label, errors)
	if kind in ["worldEventActive", "worldEventInactive"]:
		_reference(data.get("eventId"), refs["events"], label + ".eventId", errors)
	elif kind in ["learnedFact", "relationshipFlagSet", "relationshipFlagUnset"]:
		var npc_id: String = _id(data.get("npcId"), label + ".npcId", errors)
		var npc: NpcDefinition = npcs.get_npc(npc_id)
		if npc == null: errors.append(label + ": missing NPC " + npc_id)
		elif kind == "learnedFact": _reference(data.get("factId"), npc.facts, label + ".factId", errors)
		else: _reference(data.get("flagId"), npc.flag_ids, label + ".flagId", errors)
	elif kind == "playerEvent":
		var event_kind: String = _id(data.get("eventKind"), label + ".eventKind", errors)
		if event_kind not in NpcContentCatalog.EVENT_KINDS: errors.append(label + ": unsupported player event " + event_kind)
		var minimum: int = _integer(data.get("minimumCount"), 0, MAX_INTEGER, label + ".minimumCount", errors)
		if data.get("maximumCount") != null: _integer(data["maximumCount"], minimum, MAX_INTEGER, label + ".maximumCount", errors)
		if data.get("occurredWithinActiveSeconds") != null: _number(data["occurredWithinActiveSeconds"], false, label + ".occurredWithinActiveSeconds", errors)
		var subject: Variant = data.get("subjectId")
		var target: Variant = data.get("targetId")
		if subject != null: _id(subject, label + ".subjectId", errors)
		if target != null: _id(target, label + ".targetId", errors)
		if (subject != null and not subject is String) or (target != null and not target is String): return
		match event_kind:
			"areaEntered", "resourceGathered":
				if subject != null: _reference(subject, refs["areas"] if event_kind == "areaEntered" else refs["resources"], label + ".subjectId", errors)
				if target != null: errors.append(label + ".targetId: spatial/gather events require null target")
			"itemGifted":
				if subject != null: _reference(subject, refs["giftItems"], label + ".subjectId", errors)
				if target != null: _reference(target, npcs.npc_ids(), label + ".targetId", errors)
			"dialogueChoiceSelected":
				if subject != null: _reference(subject, npcs.npc_ids(), label + ".subjectId", errors)
				var choices: PackedStringArray = []
				for npc_id: String in npcs.npc_ids():
					if subject == null or subject == npc_id: choices.append_array(PackedStringArray(npcs.get_npc(npc_id).graph.choices.keys()))
				if target != null: _reference(target, choices, label + ".targetId", errors)

func _policy(value: Variant, participants: PackedStringArray, plans: Dictionary, label: String, npcs: NpcContentCatalog, refs: Dictionary, errors: PackedStringArray) -> void:
	var policy: Dictionary = _object(value, ["allowDialogue", "defaultDialogueEntryNodeId", "stepDialogueEntries", "outcomeDirectives"], label, errors)
	if not policy.get("allowDialogue") is bool: errors.append(label + ".allowDialogue: expected boolean")
	var default_entry: Variant = policy.get("defaultDialogueEntryNodeId")
	if default_entry != null:
		for npc_id: String in participants: _reference(default_entry, npcs.get_npc(npc_id).graph.nodes, label + ".default " + npc_id, errors)
	var entries: Array = _array(policy.get("stepDialogueEntries"), label + ".stepDialogueEntries", errors)
	var pairs: PackedStringArray = []
	for value_entry: Variant in entries:
		var entry: Dictionary = _object(value_entry, ["participantId", "stepId", "dialogueEntryNodeId"], label + ".entry", errors)
		var pair: String = str(entry.get("participantId")) + ":" + str(entry.get("stepId"))
		if pair in pairs: errors.append(label + ".entry: duplicate participant/step " + pair)
		pairs.append(pair)
		var npc_id: String = _plan_ref(entry, plans, label + ".entry step " + str(entry.get("stepId")), errors)
		var npc: NpcDefinition = npcs.get_npc(npc_id)
		_reference(entry.get("dialogueEntryNodeId"), npc.graph.nodes if npc != null else {}, label + ".entry " + pair + ".dialogueEntryNodeId", errors)
	var bindings: Array = _array(policy.get("outcomeDirectives"), label + ".outcomeDirectives", errors)
	var available_tags: PackedStringArray = []
	for npc_id: String in participants:
		for choice: NpcDialogueGraph.Choice in npcs.get_npc(npc_id).graph.choices.values():
			if not choice.outcome_tag.is_empty(): available_tags.append(choice.outcome_tag)
	var tags: PackedStringArray = []
	for value_binding: Variant in bindings:
		var binding: Dictionary = _object(value_binding, ["outcomeTag", "directive"], label + ".binding", errors)
		var tag: String = _id(binding.get("outcomeTag"), label + ".outcomeTag", errors)
		if tag in tags: errors.append(label + ": duplicate outcome tag " + tag)
		tags.append(tag)
		_reference(tag, available_tags, label + ".outcomeTag", errors)
		var directive: Dictionary = binding.get("directive") if binding.get("directive") is Dictionary else {}
		var kind: String = _text(directive.get("kind"), label + ".directive.kind", errors)
		var keys: PackedStringArray = ["kind"]
		match kind:
			"resume", "endRoutineForDay": pass
			"jumpToStep": keys.append_array(["participantId", "stepId"])
			"activateWorldEvent", "deactivateWorldEvent": keys.append("eventId")
			_: errors.append(label + ": unsupported directive " + kind)
		_object(binding.get("directive"), keys, label + ".directive " + tag, errors)
		if kind == "jumpToStep": _plan_ref(directive, plans, label + ".jump step " + str(directive.get("stepId")), errors)
		if kind in ["activateWorldEvent", "deactivateWorldEvent"]: _reference(directive.get("eventId"), refs["events"], label + ".directive.eventId", errors)
	if policy.get("allowDialogue") is bool and not policy["allowDialogue"] and (default_entry != null or not entries.is_empty() or not bindings.is_empty()): errors.append(label + ": dialogue disabled but entries/outcomes present")

func _plan_ref(data: Dictionary, plans: Dictionary, label: String, errors: PackedStringArray) -> String:
	var npc_id: String = _id(data.get("participantId"), label + ".participantId", errors)
	_reference(data.get("stepId"), plans.get(npc_id, PackedStringArray()), label + ".stepId", errors)
	if not plans.has(npc_id): errors.append(label + ": missing participant plan " + npc_id)
	return npc_id

func _connected(source: String, destination: String, refs: Dictionary) -> bool:
	var pending: PackedStringArray = [source]
	var visited: PackedStringArray = []
	while not pending.is_empty():
		var current: String = pending[0]
		pending.remove_at(0)
		if current == destination: return true
		if current in visited: continue
		visited.append(current)
		for portal: Dictionary in refs["portals"]:
			if portal["sourceMapId"] == current: pending.append(portal["destinationMapId"])
	return false

static func _asset(id: String) -> String: return "res://content/routines/" + id + ".json"

func _object(value: Variant, keys: PackedStringArray, label: String, errors: PackedStringArray) -> Dictionary:
	if not value is Dictionary:
		errors.append(label + ": expected object")
		return {}
	for key: String in keys:
		if not value.has(key): errors.append(label + ": missing key " + key)
	for key: Variant in value:
		if not key is String or key not in keys: errors.append(label + ": unsupported key " + str(key))
	return value

func _array(value: Variant, label: String, errors: PackedStringArray) -> Array:
	if value is Array: return value
	errors.append(label + ": expected array")
	return []

func _text(value: Variant, label: String, errors: PackedStringArray) -> String:
	if value is String and not value.strip_edges().is_empty(): return value
	errors.append(label + ": expected nonempty string")
	return ""

func _id(value: Variant, label: String, errors: PackedStringArray) -> String:
	var id: String = _text(value, label, errors)
	if RegEx.create_from_string("^[A-Za-z0-9_-]+$").search(id) == null: errors.append(label + ": invalid stable ID")
	return id

func _ids(value: Variant, label: String, errors: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	for entry: Variant in _array(value, label, errors):
		var id: String = _id(entry, label, errors)
		if id in result: errors.append(label + ": duplicate ID " + id)
		result.append(id)
	return result

func _reference(value: Variant, expected: Variant, label: String, errors: PackedStringArray) -> void:
	var id: String = _id(value, label, errors)
	if id not in expected: errors.append(label + ": unsupported/missing reference " + id)

func _integer(value: Variant, minimum: int, maximum: int, label: String, errors: PackedStringArray) -> int:
	if (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and float(value) >= minimum and float(value) <= maximum: return int(value)
	errors.append(label + ": expected finite integer in %d..%d" % [minimum, maximum])
	return minimum

func _number(value: Variant, positive: bool, label: String, errors: PackedStringArray) -> void:
	if (value is int or value is float) and is_finite(float(value)) and (float(value) > 0.0 if positive else float(value) >= 0.0): return
	errors.append(label + ": expected finite " + ("positive" if positive else "nonnegative") + " number")
