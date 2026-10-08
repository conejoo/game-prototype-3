class_name NpcDialogueService
extends RefCounted
## Node-independent cursor; stable commands publish state once before notifications.
signal changed
class Result extends RefCounted:
	var ok: bool
	var message: String
	func _init(success: bool, description: String) -> void:
		ok = success
		message = description
var _catalog: NpcContentCatalog
var _session: GameSession
var _npc_id: String = ""
var _instance_id: String = ""
var _node_id: String = ""
var _generation: int = 0
var _cursor_state: NpcConversationState

func initialize(catalog: NpcContentCatalog, session: GameSession) -> PackedStringArray:
	if catalog == null or not catalog.initialized or session == null or not session.initialized:
		return PackedStringArray(["Dialogue requires validated content and initialized session"])
	if not session.conversations.initialized:
		var errors: PackedStringArray = session.conversations.initialize(catalog)
		if not errors.is_empty(): return errors
	_catalog = catalog
	_session = session
	_clear()
	return []

func active() -> bool:
	return not _node_id.is_empty()

func begin(npc_id: String, instance_id: String) -> Result:
	if _session == null or active() or instance_id.strip_edges().is_empty(): return Result.new(false, "Conversation owner unavailable, active or invalid instance.")
	var npc: NpcDefinition = _catalog.get_npc(npc_id)
	var memory: ConversationMemory = _session.conversations.memory(npc_id)
	var node: NpcDialogueGraph.NodeDefinition = NpcDialogueRules.resolve(npc, memory, _session.conversations.events(), _session.elapsed_play_seconds)
	if node == null: return Result.new(false, "No available ordinary entry.")
	_session.conversations = _session.conversations.with_person(memory.entered(node))
	_cursor_state = _session.conversations
	_npc_id = npc_id
	_instance_id = instance_id
	_node_id = node.id
	_generation += 1
	changed.emit()
	return Result.new(true, "Conversation opened.")

func snapshot() -> Dictionary:
	if not active(): return {}
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	var memory: ConversationMemory = _session.conversations.memory(_npc_id)
	var rows: Array[Dictionary] = []
	var available: int = 0
	for choice: NpcDialogueGraph.Choice in node.choices:
		var reason: String = NpcDialogueRules.choice_reason(npc, choice, memory, _session.conversations.events(), _session.elapsed_play_seconds)
		# Hidden conditions stay hidden; deferred capability rows explain availability.
		if not NpcDialogueRules.matches(choice.conditions, memory, _session.conversations.events(), _session.elapsed_play_seconds, npc.level_one_affinity): continue
		rows.append({"id": choice.id, "text": choice.text, "available": reason.is_empty(), "reason": reason})
		if reason.is_empty(): available += 1
	return {"npc_id": _npc_id, "instance_id": _instance_id, "node_id": _node_id, "token": _token(), "speaker": node.speaker, "text": node.text, "portrait_id": node.portrait_id, "portrait_path": npc.portraits[node.portrait_id], "choices": rows, "can_continue": not node.continue_target_id.is_empty() or available == 0, "can_close": true, "memory": memory.snapshot(npc.level_one_affinity)}

func choose(npc_id: String, instance_id: String, node_id: String, token: String, choice_id: String) -> Result:
	if not _command_matches(npc_id, instance_id, node_id, token): return Result.new(false, "Stale or foreign conversation command.")
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	var choice: NpcDialogueGraph.Choice
	for row: NpcDialogueGraph.Choice in node.choices:
		if row.id == choice_id: choice = row
	if choice == null: return Result.new(false, "Unknown response on current node.")
	var memory: ConversationMemory = _session.conversations.memory(_npc_id)
	var reason: String = NpcDialogueRules.choice_reason(npc, choice, memory, _session.conversations.events(), _session.elapsed_play_seconds)
	if not reason.is_empty(): return Result.new(false, reason)
	var next: NpcDialogueGraph.NodeDefinition
	if not choice.ends_conversation and not choice.target_node_id.is_empty():
		next = npc.graph.nodes.get(choice.target_node_id)
		if next == null or not next.availability.is_enabled(): return Result.new(false, "Response target unavailable.")
	# Edric milestone is deferred; never inject it merely for crossing level one.
	var event_value: NpcEventMemory = _session.conversations.events().record(NpcEventMemory.CHOICE, _npc_id, choice.id, _session.elapsed_play_seconds)
	if event_value == null: return Result.new(false, "Event memory range exhausted or invalid active time.")
	var candidate: ConversationMemory = memory.responded(choice)
	if next != null: candidate = candidate.entered(next)
	_session.conversations = _session.conversations.with_person(candidate, event_value)
	_cursor_state = _session.conversations
	if next == null: _clear()
	else:
		_node_id = next.id
		_generation += 1
	changed.emit()
	return Result.new(true, "Response accepted.")

func advance(npc_id: String, instance_id: String, node_id: String, token: String) -> Result:
	if not _command_matches(npc_id, instance_id, node_id, token): return Result.new(false, "Stale or foreign conversation command.")
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	if node.continue_target_id.is_empty():
		for choice: NpcDialogueGraph.Choice in node.choices:
			if NpcDialogueRules.choice_reason(npc, choice, _session.conversations.memory(_npc_id), _session.conversations.events(), _session.elapsed_play_seconds).is_empty(): return Result.new(false, "Choose a response or Close.")
		return close(npc_id, instance_id, node_id, token)
	var next: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(node.continue_target_id)
	if next == null or not next.availability.is_enabled(): return Result.new(false, "Continuation unavailable; Close remains available.")
	_session.conversations = _session.conversations.with_person(_session.conversations.memory(_npc_id).entered(next))
	_cursor_state = _session.conversations
	_node_id = next.id
	_generation += 1
	changed.emit()
	return Result.new(true, "Conversation continued.")

func close(npc_id: String, instance_id: String, node_id: String, token: String) -> Result:
	if not _command_matches(npc_id, instance_id, node_id, token): return Result.new(false, "Stale or foreign conversation command.")
	_clear()
	changed.emit()
	return Result.new(true, "Conversation closed.")

func cancel() -> void:
	# Owner lifecycle cancellation applies no unselected effects.
	if not active(): return
	_clear()
	changed.emit()

func record_event(kind: String, subject: Variant, target: Variant) -> Result:
	if _session == null: return Result.new(false, "Event owner unavailable.")
	# Choices belong to choose(); no caller may fabricate a receipt/event.
	if kind not in [NpcEventMemory.AREA, NpcEventMemory.GATHER]: return Result.new(false, "Unsupported external event adapter.")
	var candidate: NpcEventMemory = _session.conversations.events().record(kind, subject, target, _session.elapsed_play_seconds)
	if candidate == null: return Result.new(false, "Unsupported event key, time or range.")
	_session.conversations = _session.conversations.with_events(candidate)
	if active(): _cursor_state = _session.conversations
	changed.emit()
	return Result.new(true, "Event recorded.")

func _command_matches(npc_id: String, instance_id: String, node_id: String, token: String) -> bool:
	return active() and _cursor_state == _session.conversations and _npc_id == npc_id and _instance_id == instance_id and _node_id == node_id and _token() == token

func _token() -> String:
	return "%d:%d" % [get_instance_id(), _generation]

func _clear() -> void:
	_cursor_state = null
	_npc_id = ""
	_instance_id = ""
	_node_id = ""
	_generation += 1
