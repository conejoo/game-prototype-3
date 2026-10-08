class_name ConversationDefinition
extends ContentDefinition
## Authored prototype finite graphs. Same node/cursor model as selected NPC graphs.
@export var speaker_actor_id: String = ""
@export var graph_json: String = ""

func document() -> Dictionary:
	var value: Variant = JSON.parse_string(graph_json)
	return value if value is Dictionary else {}

func graph() -> NpcDialogueGraph:
	var data: Dictionary = document()
	var coverage: Dictionary = {"node": {}, "choice": {}}
	for node: Dictionary in data["nodes"]:
		coverage.node[node.id] = {"status":"enabled", "reason":"Prototype adaptation"}
		for choice: Dictionary in node.get("choices", []):
			coverage.choice[choice.id] = {"status":"enabled", "reason":"Prototype adaptation"}
	return NpcDialogueGraph.new(data, display_name, coverage)

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if speaker_actor_id.is_empty(): errors.append("speaker_actor_id must be nonempty")
	var data: Dictionary = document()
	if data.keys().size() != 3 or data.get("npcId") != speaker_actor_id or not data.get("entryNodeIds") is Array or not data.get("nodes") is Array:
		return errors + PackedStringArray(["conversation requires speaker, entries and nodes"])
	var nodes: Dictionary = {}
	var choices: Dictionary = {}
	for value: Variant in data.nodes:
		if not value is Dictionary:
			errors.append("conversation node must be object")
			continue
		var node: Dictionary = value
		_check_keys(node, ["id", "text", "portraitId", "continueTargetId", "choices", "presentationIndex"], errors)
		if not _text(node.get("id")) or nodes.has(node.get("id")): errors.append("duplicate or invalid node ID")
		else: nodes[node.id] = node
		if not _text(node.get("text")): errors.append("node contains blank line")
		if not node.get("portraitId", "") is String or node.get("portraitId", "") not in ["", "official-neutral"]: errors.append("invalid prototype portrait")
		var index: Variant = node.get("presentationIndex", 0)
		if not (index is int or index is float) or not is_finite(float(index)) or float(index) != floor(float(index)) or float(index) < 0 or float(index) > 256: errors.append("invalid presentation index")
		if not node.get("continueTargetId", "") is String: errors.append("invalid continuation")
		if not node.get("choices", []) is Array:
			errors.append("choices must be array")
			continue
		if node.get("continueTargetId", "") is String and not node.get("continueTargetId", "").is_empty() and not node.get("choices", []).is_empty(): errors.append("node cannot continue and choose")
		for row: Variant in node.get("choices", []):
			if not row is Dictionary:
				errors.append("choice must be object")
				continue
			_check_keys(row, ["id", "text", "targetNodeId", "command"], errors)
			if not _text(row.get("id")) or choices.has(row.get("id")): errors.append("duplicate choice ID")
			else: choices[row.id] = true
			if not _text(row.get("text")) or not _text(row.get("targetNodeId")): errors.append("choice text/target missing")
			if not row.get("command") is Dictionary:
				errors.append("choice command missing")
				continue
			var command: Dictionary = row.command
			_check_keys(command, ["action_id", "quest_id", "reaction_id"], errors)
			if not _text(command.get("action_id")): errors.append("command action ID required")
			for key: String in ["action_id", "quest_id", "reaction_id"]:
				if not command.get(key, "") is String: errors.append("command IDs must be strings")
			if not errors.is_empty(): continue
			if not command.get("reaction_id", "").is_empty():
				if command.action_id != "companion-react" or not command.get("quest_id", "").is_empty(): errors.append("invalid reaction command")
			elif command.get("quest_id", "").is_empty() and command.get("action_id") not in ["prototype-observe", "prototype-leave"]: errors.append("unsupported dialogue action")
	if nodes.is_empty(): errors.append("conversation requires at least one node")
	if data.entryNodeIds.size() != 1 or not nodes.has(data.entryNodeIds[0]): errors.append("prototype requires one valid entry")
	if errors.is_empty():
		for node: Dictionary in nodes.values():
			for target: String in _targets(node):
				if not nodes.has(target): errors.append("dangling conversation target")
	if errors.is_empty():
		var visited: Dictionary = {}
		if not _finite(data.entryNodeIds[0], nodes, {}, visited): errors.append("conversation cycle")
		if visited.size() != nodes.size(): errors.append("unreachable conversation node")
	return errors

func _finite(id: String, nodes: Dictionary, visiting: Dictionary, visited: Dictionary) -> bool:
	if visiting.has(id): return false
	if visited.has(id): return true
	visiting[id] = true
	for target: String in _targets(nodes[id]):
		if not _finite(target, nodes, visiting, visited): return false
	visiting.erase(id)
	visited[id] = true
	return true

func _targets(node: Dictionary) -> PackedStringArray:
	var result: PackedStringArray = []
	if not node.get("continueTargetId", "").is_empty(): result.append(node.continueTargetId)
	for choice: Dictionary in node.get("choices", []): result.append(choice.targetNodeId)
	return result

func _check_keys(value: Dictionary, allowed: Array, errors: PackedStringArray) -> void:
	for key: Variant in value:
		if key not in allowed: errors.append("unknown conversation key")

func _text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty() and value == value.strip_edges()
