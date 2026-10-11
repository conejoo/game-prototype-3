class_name NpcContentCatalog
extends RefCounted
## Strict target-local loader. Validate a complete candidate before one publication.
## Canonical dictionaries never escape; typed lookups and document snapshots detach.

const PATH: String = "res://content/npcs/catalog.json"
const REFERENCE_SHEET_MANIFEST: String = "res://content/npcs/reference_sheet_manifest.json"
const REFERENCE_SHEET_MANIFEST_SHA256: String = "51d32379c24db0fbac0c91e1ff70af2d3cf424ac8946f4bca2a8a010ef0e13fa"
const ROSTER: PackedStringArray = ["npc-01", "npc-02", "npc-03", "npc-04", "npc-06", "npc-07", "npc-08", "npc-14"]
const SOURCE_REVISION: String = "60c20eb2816e7271fb84afaba286af006ebe3ccf"
const MAX_INTEGER: int = 2147483647
const CONDITION_ARRAYS: PackedStringArray = ["requiredFlags", "excludedFlags", "requiredFactIds", "unknownFactIds", "requiredSeenNodeIds", "unseenNodeIds"]
const EVENT_KINDS: PackedStringArray = ["areaEntered", "resourceGathered", "itemGifted", "dialogueChoiceSelected"]
var initialized: bool = false
var _document: Dictionary = {}
var _packages: Dictionary[String, Dictionary] = {}

func initialize_path(actors: ContentCatalog, path: String = PATH) -> PackedStringArray:
	if not path.begins_with("res://") or not FileAccess.file_exists(path):
		return PackedStringArray(["NPC catalog requires an existing res:// file"])
	var json: JSON = JSON.new()
	var result: Error = json.parse(FileAccess.get_file_as_string(path))
	if result != OK:
		return PackedStringArray(["NPC catalog JSON line %d: %s" % [json.get_error_line(), json.get_error_message()]])
	return initialize_document(json.data, actors)

func initialize_document(value: Variant, actors: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	if actors == null or not actors.initialized or actors.get_actor("npc-03") == null:
		return PackedStringArray(["NPC catalog requires validated legacy actors including npc-03"])
	var document: Dictionary = _object(value, ["format_version", "source_revision", "packages"], [], "catalog", errors)
	_integer(document.get("format_version"), 1, 1, "format_version", errors)
	if _text(document.get("source_revision"), "source_revision", errors) != SOURCE_REVISION:
		errors.append("source_revision must match N001 pin")
	var packages: Array = _array(document.get("packages"), "packages", errors)
	if packages.size() != ROSTER.size():
		errors.append("catalog must contain exactly eight selected packages")
	var candidate: Dictionary[String, Dictionary] = {}
	for index: int in packages.size():
		var label: String = "packages[%d]" % index
		var package: Dictionary = _object(packages[index], ["id", "actor_id", "runtime", "dialogue", "visuals", "coverage"], [], label, errors)
		var id: String = _id(package.get("id"), label + ".id", errors)
		if id not in ROSTER:
			errors.append(label + ": unrequested NPC identity")
		elif index < ROSTER.size() and id != ROSTER[index]:
			errors.append(label + ": selected roster order mismatch")
		if candidate.has(id):
			errors.append(label + ": duplicate NPC ID")
		candidate[id] = package
		if _id(package.get("actor_id"), label + ".actor_id", errors) != id:
			errors.append(label + ": illegal actor identity mapping")
		if not id.is_empty():
			_validate_package(package, id, errors)
	if errors.is_empty():
		# Detach before publication, so caller edits cannot alter accepted content.
		_document = document.duplicate(true)
		_packages.clear()
		for package: Dictionary in _document["packages"]:
			_packages[package["id"]] = package
		initialized = true
	return errors

func npc_ids() -> PackedStringArray:
	return ROSTER.duplicate() if initialized else PackedStringArray()

func definition_count() -> int:
	return _packages.size()

func get_npc(id: String) -> NpcDefinition:
	return NpcDefinition.new(_packages[id].duplicate(true)) if _packages.has(id) else null

func document_snapshot() -> Dictionary:
	return _document.duplicate(true)

func _validate_package(package: Dictionary, id: String, errors: PackedStringArray) -> void:
	var start: int = errors.size()
	var runtime: Dictionary = _object(package.get("runtime"), ["id", "displayName", "shortName", "title", "pronouns", "interactionPrompt", "relationship", "dimensions", "routine", "facts", "acceptedGiftRules"], [], id + ".runtime", errors)
	if _id(runtime.get("id"), id + ".runtime.id", errors) != id:
		errors.append(id + ": cross-person runtime identity")
	for key: String in ["displayName", "shortName", "title", "pronouns", "interactionPrompt"]:
		_text(runtime.get(key), id + "." + key, errors)
	var relationship: Dictionary = _object(runtime.get("relationship"), ["levelOneAffinity", "levelOneLabel"], ["levelOneMilestone"], id + ".relationship", errors)
	_integer(relationship.get("levelOneAffinity"), 1, MAX_INTEGER, id + ".levelOneAffinity", errors)
	_text(relationship.get("levelOneLabel"), id + ".levelOneLabel", errors)
	var milestone: Dictionary = {}
	if relationship.has("levelOneMilestone"):
		milestone = _object(relationship["levelOneMilestone"], ["dialogueNodeId", "seenFlagId"], [], id + ".milestone", errors)
		_id(milestone.get("dialogueNodeId"), id + ".milestone.node", errors)
		_id(milestone.get("seenFlagId"), id + ".milestone.flag", errors)
	var dimensions: Dictionary = _object(runtime.get("dimensions"), ["hitWidth", "hitHeight", "interactionRadius"], [], id + ".dimensions", errors)
	for key: String in ["hitWidth", "hitHeight", "interactionRadius"]:
		_number(dimensions.get(key), 0.001, 4096.0, id + "." + key, errors)
	var routine: Dictionary = _object(runtime.get("routine"), ["agentProfile", "actionIds", "relationshipFlagIds"], [], id + ".routine", errors)
	var profile: Dictionary = _object(routine.get("agentProfile"), ["id", "footprintRadius", "clearance"], [], id + ".agentProfile", errors)
	_id(profile.get("id"), id + ".agentProfile.id", errors)
	_number(profile.get("footprintRadius"), 0.001, 4096.0, id + ".footprintRadius", errors)
	_number(profile.get("clearance"), 0.0, 4096.0, id + ".clearance", errors)
	var actions: PackedStringArray = _ids(routine.get("actionIds"), id + ".actions", errors)
	var flags: PackedStringArray = _ids(routine.get("relationshipFlagIds"), id + ".flags", errors)
	for flag: String in flags:
		if not flag.begins_with(id + "-") and not (id == "npc-01" and flag == "relationshipLevel1Seen"):
			errors.append(id + ": cross-person flag " + flag)
	var facts: Dictionary = _indexed(runtime.get("facts"), ["id", "category", "label", "description", "highlightTerm"], [], id, "facts", errors)
	for fact_id: String in facts:
		for key: String in ["category", "label", "description", "highlightTerm"]:
			_text(facts[fact_id].get(key), fact_id + "." + key, errors)
	var gifts: Dictionary = _indexed(runtime.get("acceptedGiftRules"), ["id", "itemId", "affinityDelta", "acceptanceCap"], ["requiredFactId"], id, "gifts", errors)
	for gift_id: String in gifts:
		var gift: Dictionary = gifts[gift_id]
		if _id(gift.get("itemId"), gift_id + ".itemId", errors) != "moonflower":
			errors.append(gift_id + ": unsupported gift item reference")
		_integer(gift.get("affinityDelta"), -1, 1, gift_id + ".affinityDelta", errors)
		_integer(gift.get("acceptanceCap"), 1, MAX_INTEGER, gift_id + ".acceptanceCap", errors)
		if gift.has("requiredFactId"):
			_reference(gift["requiredFactId"], facts, gift_id + ".requiredFactId", errors)
	var graph: Dictionary = _object(package.get("dialogue"), ["npcId", "entryNodeIds", "nodes"], [], id + ".dialogue", errors)
	if _id(graph.get("npcId"), id + ".dialogue.npcId", errors) != id:
		errors.append(id + ": cross-person graph identity")
	var entries: PackedStringArray = _ids(graph.get("entryNodeIds"), id + ".entries", errors)
	var nodes: Dictionary = _indexed(graph.get("nodes"), ["id", "text"], ["priority", "portraitId", "conditions", "revealedFactIds", "choices", "continueTargetId"], id, "nodes", errors)
	if entries.is_empty() or nodes.is_empty():
		errors.append(id + ": graph requires nodes and entries")
	var visuals: Dictionary = _object(package.get("visuals"), ["npcId", "portraits", "world"], [], id + ".visuals", errors)
	if _id(visuals.get("npcId"), id + ".visuals.npcId", errors) != id:
		errors.append(id + ": cross-person visual identity")
	var portraits: Dictionary = _object(visuals.get("portraits"), [], [], id + ".portraits", errors, true)
	if portraits.size() != 6:
		errors.append(id + ": requires six portraits")
	for expression: Variant in portraits:
		_id(expression, id + ".portrait.expression", errors)
		_image(portraits[expression], "res://assets/npcs/portraits/" + id + "/", Vector2i(512, 512), id + ".portrait", errors)
	var world: Dictionary = _object(visuals.get("world"), ["worldCellWidth", "worldCellHeight", "rowOrder", "idle", "walk", "actions"], [], id + ".world", errors)
	_integer(world.get("worldCellWidth"), 1, 4096, id + ".worldCellWidth", errors)
	_integer(world.get("worldCellHeight"), 1, 4096, id + ".worldCellHeight", errors)
	var rows: PackedStringArray = _ids(world.get("rowOrder"), id + ".rowOrder", errors)
	if rows != PackedStringArray(["south", "north", "west", "east"]):
		errors.append(id + ": unsupported facing row order")
	var action_sheets: Dictionary = _object(world.get("actions"), [], [], id + ".actionSheets", errors, true)
	var sheets: Dictionary = {"idle": world.get("idle"), "walk": world.get("walk")}
	for action: Variant in action_sheets:
		if action not in actions or action in sheets:
			errors.append(id + ": undeclared/duplicate action " + str(action))
		sheets[action] = action_sheets[action]
	for action: String in actions:
		if not action_sheets.has(action):
			errors.append(id + ": missing declared action " + action)
	for sheet_id: Variant in sheets:
		var sheet: Dictionary = _object(sheets[sheet_id], ["asset", "textureCellWidth", "textureCellHeight", "framesPerFacing", "stepSeconds"], [], id + ".sheet." + str(sheet_id), errors)
		var width: int = _integer(sheet.get("textureCellWidth"), 1, 4096, id + ".textureCellWidth", errors)
		var height: int = _integer(sheet.get("textureCellHeight"), 1, 4096, id + ".textureCellHeight", errors)
		var frames: int = _integer(sheet.get("framesPerFacing"), 1, 64, id + ".framesPerFacing", errors)
		_number(sheet.get("stepSeconds"), 0.001, 60.0, id + ".stepSeconds", errors)
		_image(sheet.get("asset"), "res://assets/npcs/reference/" + id + "/", Vector2i(width * frames, height * 4), id + ".sheet", errors)
	# Do not index ill-typed documents during semantic validation.
	if errors.size() != start:
		return
	for entry: String in entries:
		_reference(entry, nodes, id + ".entry", errors)
	if not milestone.is_empty():
		_reference(milestone["dialogueNodeId"], nodes, id + ".milestone.node", errors)
		_reference(milestone["seenFlagId"], flags, id + ".milestone.flag", errors)
	var choices: Dictionary = {}
	var edges: Dictionary = {}
	for node_id: String in nodes:
		var node: Dictionary = nodes[node_id]
		_text(node["text"], node_id + ".text", errors)
		_integer(node.get("priority", 0), -MAX_INTEGER, MAX_INTEGER, node_id + ".priority", errors)
		_reference(node.get("portraitId", "official-neutral"), portraits, node_id + ".portraitId", errors)
		_refs(node.get("revealedFactIds", []), facts, node_id + ".revealedFactIds", errors)
		_conditions(node.get("conditions", {}), flags, facts, nodes, node_id, errors)
		var node_choices: Dictionary = _indexed(node.get("choices", []), ["id", "text"], ["affinityDelta", "oneTime", "oneTimeRewardFlag", "addedFlags", "outcomeTag", "targetNodeId", "endsConversation", "giftRuleId", "conditions"], id, node_id + ".choices", errors)
		var targets: PackedStringArray = []
		for choice_id: String in node_choices:
			if choices.has(choice_id):
				errors.append(choice_id + ": duplicate global choice ID")
			var choice: Dictionary = node_choices[choice_id]
			choices[choice_id] = choice
			_text(choice.get("text"), choice_id + ".text", errors)
			_integer(choice.get("affinityDelta", 0), -1, 1, choice_id + ".affinityDelta", errors)
			_boolean(choice.get("oneTime", false), choice_id + ".oneTime", errors)
			var ends: bool = _boolean(choice.get("endsConversation", false), choice_id + ".endsConversation", errors)
			if choice.has("targetNodeId"):
				_reference(choice["targetNodeId"], nodes, choice_id + ".targetNodeId", errors)
				if choice["targetNodeId"] is String:
					targets.append(choice["targetNodeId"])
			if choice.has("targetNodeId") == ends:
				errors.append(choice_id + ": transition requires exactly target or end")
			if choice.has("oneTimeRewardFlag"):
				_reference(choice["oneTimeRewardFlag"], flags, choice_id + ".rewardFlag", errors)
			_refs(choice.get("addedFlags", []), flags, choice_id + ".addedFlags", errors)
			if choice.has("giftRuleId"):
				_reference(choice["giftRuleId"], gifts, choice_id + ".giftRuleId", errors)
			if choice.has("outcomeTag"):
				_owned(choice["outcomeTag"], id, choice_id + ".outcomeTag", errors)
			_conditions(choice.get("conditions", {}), flags, facts, nodes, choice_id, errors)
		if node.has("continueTargetId"):
			_reference(node["continueTargetId"], nodes, node_id + ".continueTargetId", errors)
			if node["continueTargetId"] is String:
				targets.append(node["continueTargetId"])
			if not node_choices.is_empty():
				errors.append(node_id + ": choices and continue cannot coexist")
		edges[node_id] = targets
	var coverage: Dictionary = _object(package.get("coverage"), ["node", "choice", "fact", "gift_rule", "portrait", "sheet"], [], id + ".coverage", errors)
	for kind: String in ["node", "choice", "fact", "gift_rule", "portrait", "sheet"]:
		var expected: Dictionary = {"node": nodes, "choice": choices, "fact": facts, "gift_rule": gifts, "portrait": portraits, "sheet": sheets}[kind]
		_coverage(coverage.get(kind), expected, id + ".coverage." + kind, errors)
	if errors.size() != start:
		return
	for gift_id: String in gifts:
		_require_enabled(coverage["gift_rule"][gift_id], gift_id, errors)
	for choice_id: String in choices:
		var choice: Dictionary = choices[choice_id]
		if choice.has("outcomeTag"):
			if choice_id not in ["npc-02-resume-archive-default-choice","npc-02-end-archive-default-choice","npc-02-resume-archive-indexing-choice","npc-02-review-archive-ledger-choice","npc-02-end-archive-indexing-choice"]:
				errors.append(choice_id + ": unsupported routine outcome")
			_require_enabled(coverage["choice"][choice_id], choice_id, errors)
		if choice_id == "npc-14-ask-room":
			_require_deferred(coverage["choice"][choice_id], choice_id, errors)
		if choice.has("giftRuleId"):
			_require_enabled(coverage["choice"][choice_id], choice_id, errors)
		if choice.has("giftRuleId") and choice.has("targetNodeId"):
			_require_enabled(coverage["node"][choice["targetNodeId"]], choice["targetNodeId"], errors)
	for node_id: String in nodes:
		var node: Dictionary = nodes[node_id]
		if node_id == "npc-01-level-1-milestone":
			_require_enabled(coverage["node"][node_id], node_id, errors)
		if node_id in ["npc-02-routine-archive-default","npc-02-routine-archive-indexing"]:
			_require_enabled(coverage["node"][node_id], node_id, errors)
		if node_id == "npc-14-room":
			_require_deferred(coverage["node"][node_id], node_id, errors)
		if coverage["node"][node_id]["status"] == "deferred":
			for choice: Dictionary in node.get("choices", []):
				_require_deferred(coverage["choice"][choice["id"]], choice["id"], errors)
		for target: String in edges[node_id]:
			if node.has("continueTargetId") and coverage["node"][node_id]["status"] == "enabled" and coverage["node"][target]["status"] == "deferred":
				errors.append(node_id + ": enabled continue targets deferred node")
		for choice: Dictionary in node.get("choices", []):
			if choice.has("targetNodeId") and coverage["choice"][choice["id"]]["status"] == "enabled" and coverage["node"][choice["targetNodeId"]]["status"] == "deferred":
				errors.append(choice["id"] + ": enabled choice targets deferred node")
	for fact_id: String in facts:
		var disclosed: bool = false
		for node_id: String in nodes:
			if fact_id in nodes[node_id].get("revealedFactIds", []) and coverage["node"][node_id]["status"] == "enabled":
				disclosed = true
		if (coverage["fact"][fact_id]["status"] == "enabled") != disclosed:
			errors.append(fact_id + ": fact disclosure classification mismatch")
	# All branches, including unreachable/deferred content, must be finite.
	var colors: Dictionary = {}
	for node_id: String in edges:
		_visit(node_id, edges, colors, errors)

func _conditions(value: Variant, flags: PackedStringArray, facts: Dictionary, nodes: Dictionary, label: String, errors: PackedStringArray) -> void:
	var optional: PackedStringArray = CONDITION_ARRAYS.duplicate()
	optional.append_array(["minimumAffinity", "maximumAffinity", "minimumRelationshipLevel", "events"])
	var data: Dictionary = _object(value, [], optional, label + ".conditions", errors)
	for key: String in CONDITION_ARRAYS:
		var expected: Variant = flags if key in ["requiredFlags", "excludedFlags"] else (facts if key in ["requiredFactIds", "unknownFactIds"] else nodes)
		_refs(data.get(key, []), expected, label + "." + key, errors)
	for key: String in ["minimumAffinity", "maximumAffinity", "minimumRelationshipLevel"]:
		if data.has(key):
			_integer(data[key], 0, MAX_INTEGER, label + "." + key, errors)
	if data.has("minimumAffinity") and data.has("maximumAffinity") and _numeric(data["minimumAffinity"]) and _numeric(data["maximumAffinity"]) and data["minimumAffinity"] > data["maximumAffinity"]:
		errors.append(label + ": inverted affinity bounds")
	for pair: Array in [["requiredFlags", "excludedFlags"], ["requiredFactIds", "unknownFactIds"], ["requiredSeenNodeIds", "unseenNodeIds"]]:
		if data.get(pair[0], []) is Array and data.get(pair[1], []) is Array:
			for ref: Variant in data.get(pair[0], []):
				if ref in data.get(pair[1], []):
					errors.append(label + ": contradictory conditions")
	for row: Variant in _array(data.get("events", []), label + ".events", errors):
		var event: Dictionary = _object(row, ["kind"], ["subjectId", "targetId", "minimumCount", "maximumCount", "occurredWithinActiveSeconds"], label + ".event", errors)
		if _id(event.get("kind"), label + ".event.kind", errors) not in EVENT_KINDS:
			errors.append(label + ": unsupported event kind")
		for key: String in ["subjectId", "targetId"]:
			if event.get(key) != null:
				_id(event[key], label + ".event." + key, errors)
		var minimum: int = _integer(event.get("minimumCount", 1), 0, MAX_INTEGER, label + ".minimumCount", errors)
		if event.has("maximumCount"):
			_integer(event["maximumCount"], minimum, MAX_INTEGER, label + ".maximumCount", errors)
		if event.has("occurredWithinActiveSeconds"):
			_number(event["occurredWithinActiveSeconds"], 0.0, float(MAX_INTEGER), label + ".event.window", errors)

func _coverage(value: Variant, expected: Dictionary, label: String, errors: PackedStringArray) -> void:
	var data: Dictionary = _object(value, [], [], label, errors, true)
	if data.size() != expected.size():
		errors.append(label + ": coverage count mismatch")
	for id: Variant in data:
		if not expected.has(id):
			errors.append(label + ": unknown coverage ID")
		var row: Dictionary = _object(data[id], ["status", "reason"], [], label + "." + str(id), errors)
		if row.get("status") not in ["enabled", "deferred"]:
			errors.append(label + ": unsupported availability status")
		_text(row.get("reason"), label + ".reason", errors)
	for id: Variant in expected:
		if not data.has(id):
			errors.append(label + ": missing coverage ID " + str(id))

func _require_deferred(row: Dictionary, label: String, errors: PackedStringArray) -> void:
	if row["status"] != "deferred":
		errors.append(label + ": unavailable capability must stay deferred")

func _require_enabled(row: Dictionary, label: String, errors: PackedStringArray) -> void:
	if row["status"] != "enabled":
		errors.append(label + ": approved social capability must be enabled")

func _visit(id: String, edges: Dictionary, colors: Dictionary, errors: PackedStringArray) -> void:
	if colors.get(id, 0) == 1:
		errors.append(id + ": cyclic finite graph transition")
		return
	if colors.get(id, 0) == 2:
		return
	colors[id] = 1
	for next: String in edges[id]:
		_visit(next, edges, colors, errors)
	colors[id] = 2

func _object(value: Variant, required: PackedStringArray, optional: PackedStringArray, label: String, errors: PackedStringArray, open_keys: bool = false) -> Dictionary:
	if not value is Dictionary:
		errors.append(label + ": must be object")
		return {}
	var data: Dictionary = value
	for key: String in required:
		if not data.has(key):
			errors.append(label + ": missing key " + key)
	for key: Variant in data:
		if not key is String or (not open_keys and key not in required and key not in optional):
			errors.append(label + ": unsupported key " + str(key))
	return data

func _array(value: Variant, label: String, errors: PackedStringArray) -> Array:
	if not value is Array:
		errors.append(label + ": must be array")
		return []
	return value

func _text(value: Variant, label: String, errors: PackedStringArray) -> String:
	if not value is String or value.strip_edges().is_empty():
		errors.append(label + ": must be nonempty string")
		return ""
	return value

func _id(value: Variant, label: String, errors: PackedStringArray) -> String:
	var id: String = _text(value, label, errors)
	if not id.is_empty() and RegEx.create_from_string("^[A-Za-z0-9_-]+$").search(id) == null:
		errors.append(label + ": invalid stable ID")
	return id

func _owned(value: Variant, owner: String, label: String, errors: PackedStringArray) -> String:
	var id: String = _id(value, label, errors)
	if not id.begins_with(owner + "-"):
		errors.append(label + ": cross-person ID " + id)
	return id

func _ids(value: Variant, label: String, errors: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	for row: Variant in _array(value, label, errors):
		var id: String = _id(row, label, errors)
		if id in result:
			errors.append(label + ": duplicate ID " + id)
		result.append(id)
	return result

func _indexed(value: Variant, required: PackedStringArray, optional: PackedStringArray, owner: String, label: String, errors: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	for row: Variant in _array(value, owner + "." + label, errors):
		var data: Dictionary = _object(row, required, optional, owner + "." + label, errors)
		var id: String = _owned(data.get("id"), owner, owner + "." + label, errors)
		if result.has(id):
			errors.append(label + ": duplicate ID " + id)
		result[id] = data
	return result

func _reference(value: Variant, expected: Variant, label: String, errors: PackedStringArray) -> void:
	var id: String = _id(value, label, errors)
	if id not in expected:
		errors.append(label + ": missing/cross-person reference " + id)

func _refs(value: Variant, expected: Variant, label: String, errors: PackedStringArray) -> void:
	for id: String in _ids(value, label, errors):
		_reference(id, expected, label, errors)

func _numeric(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

func _integer(value: Variant, minimum: int, maximum: int, label: String, errors: PackedStringArray) -> int:
	# Godot JSON numbers are floats; accept integral finite values, never booleans.
	if not _numeric(value) or float(value) != floor(float(value)) or float(value) < minimum or float(value) > maximum:
		errors.append(label + ": must be integer in %d..%d" % [minimum, maximum])
		return minimum
	return int(value)

func _number(value: Variant, minimum: float, maximum: float, label: String, errors: PackedStringArray) -> float:
	if not _numeric(value) or float(value) < minimum or float(value) > maximum:
		errors.append(label + ": must be finite number in range")
		return minimum
	return float(value)

func _boolean(value: Variant, label: String, errors: PackedStringArray) -> bool:
	if not value is bool:
		errors.append(label + ": must be boolean")
		return false
	return value

func _image(value: Variant, prefix: String, size: Vector2i, label: String, errors: PackedStringArray) -> void:
	var path: String = _text(value, label + ".path", errors)
	if not path.begins_with(prefix) or not path.ends_with(".png") or path.contains("..") or path.contains("\\") or path.trim_prefix(prefix).contains("/"):
		errors.append(label + ": image must be owned target-local PNG")
		return
	# Exported packs retain exact authoring references and pinned dimensions,
	# while GLBs own runtime animation. Source runs still validate real rasters.
	if prefix.begins_with("res://assets/npcs/reference/") and FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"):
		if FileAccess.get_sha256(REFERENCE_SHEET_MANIFEST) != REFERENCE_SHEET_MANIFEST_SHA256:
			errors.append(label + ": reference sheet manifest pin differs")
			return
		var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(REFERENCE_SHEET_MANIFEST))
		var entry: Dictionary = manifest.sheets.get(path, {})
		var dimensions: Array = entry.get("size", [])
		if manifest.source_revision != SOURCE_REVISION or dimensions.size() != 2 or Vector2i(int(dimensions[0]), int(dimensions[1])) != size:
			errors.append(label + ": invalid pinned reference image dimensions")
		return
	if not ResourceLoader.exists(path, "Texture2D"):
		errors.append(label + ": missing image " + path)
		return
	var texture: Texture2D = load(path) as Texture2D
	if texture == null or Vector2i(texture.get_width(), texture.get_height()) != size:
		errors.append(label + ": invalid image dimensions")
