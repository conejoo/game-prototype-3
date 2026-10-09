class_name NpcDialogueService
extends RefCounted
## Node-independent cursor; stable commands publish state once before notifications.
signal changed
class Result extends RefCounted:
	var ok: bool
	var message: String
	var action_id: String
	func _init(success: bool, description: String, action: String = "") -> void:
		ok = success
		message = description
		action_id = action
var quest_command: Callable
var reaction_command: Callable
var _prototype: ConversationDefinition
var _selected_choice: String = ""
var _executing: bool = false
var _catalog: NpcContentCatalog
var _session: GameSession
var _npc_id: String = ""
var _instance_id: String = ""
var _node_id: String = ""
var _generation: int = 0
var _cursor_state: NpcConversationState
var _cursor_inventory: InventoryState
var _gift_feedback: String = ""

func initialize(catalog: NpcContentCatalog, session: GameSession) -> PackedStringArray:
	if _executing: return PackedStringArray(["Conversation command busy"])
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
	if _executing or _session == null or active() or instance_id.strip_edges().is_empty(): return Result.new(false, "Conversation owner unavailable, active or invalid instance.")
	var npc: NpcDefinition = _catalog.get_npc(npc_id)
	var memory: ConversationMemory = _session.conversations.memory(npc_id)
	var node: NpcDialogueGraph.NodeDefinition = NpcDialogueRules.resolve(npc, memory, _session.conversations.events(), _session.elapsed_play_seconds)
	if node == null: return Result.new(false, "No available ordinary entry.")
	_session.conversations = _session.conversations.with_person(NpcDialogueRules.enter(npc, memory, node))
	_cursor_state = _session.conversations
	_cursor_inventory = _session.inventory
	_npc_id = npc_id
	_instance_id = instance_id
	_node_id = node.id
	_generation += 1
	changed.emit()
	return Result.new(true, "Conversation opened.")

func begin_graph(content: ConversationDefinition, instance_id: String) -> Result:
	if _executing or _session == null or active() or content == null or not content.validation_errors().is_empty() or instance_id.strip_edges().is_empty():
		return Result.new(false, "Invalid or active conversation owner.")
	_prototype = content.duplicate(true) as ConversationDefinition
	_npc_id = content.speaker_actor_id
	_instance_id = instance_id
	_node_id = content.graph().entry_node_ids[0]
	_cursor_state = _session.conversations
	_cursor_inventory = _session.inventory
	_generation += 1
	changed.emit()
	return Result.new(true, "Conversation opened.")

func snapshot() -> Dictionary:
	if not active(): return {}
	if _prototype != null: return _prototype_snapshot()
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	var memory: ConversationMemory = _session.conversations.memory(_npc_id)
	var rows: Array[Dictionary] = []
	var available: int = 0
	for choice: NpcDialogueGraph.Choice in node.choices:
		var reason: String = NpcDialogueRules.choice_reason(npc, choice, memory, _session.conversations.events(), _session.elapsed_play_seconds, _session.inventory)
		# Hidden conditions stay hidden; deferred capability rows explain availability.
		if not NpcDialogueRules.matches(choice.conditions, memory, _session.conversations.events(), _session.elapsed_play_seconds, npc.level_one_affinity): continue
		var notice: String = reason
		if not reason.is_empty() and not choice.availability.is_enabled():
			notice = "Gifts are unavailable in this prototype." if not choice.gift_rule_id.is_empty() else "Paid rooms, booking and sleep are unavailable in this prototype." if choice.id == "npc-14-ask-room" else "This response is unavailable in this prototype."
		rows.append({"id": choice.id, "text": choice.text, "available": reason.is_empty(), "reason": notice})
		if reason.is_empty(): available += 1
	var facts: Array[Dictionary] = []
	for id: String in memory.learned_fact_ids:
		var fact: NpcDefinition.Fact = npc.facts[id]
		facts.append({"id":id, "label":fact.label, "description":fact.description, "highlight_term":fact.highlight_term})
	return {"graph_id":_npc_id, "npc_id": _npc_id, "instance_id": _instance_id, "node_id": _node_id, "token": _token(), "speaker": node.speaker, "text": node.text, "portrait_id": node.portrait_id, "portrait_path": npc.portraits[node.portrait_id], "choices": rows, "can_continue": not node.continue_target_id.is_empty() or available == 0, "can_close": true, "memory": memory.snapshot(npc.level_one_affinity), "social":_social_snapshot(npc), "gift_feedback":_gift_feedback, "facts":facts, "revealed_fact_ids":node.revealed_fact_ids.duplicate(), "selected_choice_id":_selected_choice, "presentation_index":0}

func _social_snapshot(npc: NpcDefinition) -> Dictionary:
	var memory: ConversationMemory = _session.conversations.memory(npc.id)
	return {"affinity":memory.affinity, "threshold":npc.level_one_affinity, "level":memory.level(npc.level_one_affinity), "level_label":npc.level_one_label, "moonflowers":_session.inventory.count("item-moonflower")}

func _prototype_snapshot() -> Dictionary:
	var node: NpcDialogueGraph.NodeDefinition = _prototype.graph().nodes[_node_id]
	var rows: Array[Dictionary] = []
	for choice: NpcDialogueGraph.Choice in node.choices:
		rows.append({"id":choice.id, "text":choice.text, "available":true, "reason":""})
	var path: String = ""
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	if npc != null and not node.portrait_id.is_empty(): path = npc.portraits.get(node.portrait_id, "")
	var facts: Array[Dictionary] = []
	if npc != null:
		for id: String in _session.conversations.memory(_npc_id).learned_fact_ids:
			var fact: NpcDefinition.Fact = npc.facts[id]
			facts.append({"id":id, "label":fact.label, "description":fact.description, "highlight_term":fact.highlight_term})
	return {"graph_id":_prototype.stable_id, "npc_id":_npc_id, "instance_id":_instance_id, "node_id":_node_id, "token":_token(), "speaker":node.speaker, "text":node.text, "portrait_id":node.portrait_id, "portrait_path":path, "choices":rows, "can_continue":rows.is_empty(), "can_close":true, "facts":facts, "revealed_fact_ids":[], "selected_choice_id":_selected_choice, "presentation_index":node.presentation_index}

func choose(npc_id: String, instance_id: String, node_id: String, token: String, choice_id: String) -> Result:
	if not _command_matches(npc_id, instance_id, node_id, token): return Result.new(false, "Stale or foreign conversation command.")
	if _prototype != null: return _choose_prototype(choice_id)
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	var choice: NpcDialogueGraph.Choice
	for row: NpcDialogueGraph.Choice in node.choices:
		if row.id == choice_id: choice = row
	if choice == null: return Result.new(false, "Unknown response on current node.")
	var memory: ConversationMemory = _session.conversations.memory(_npc_id)
	var reason: String = NpcDialogueRules.choice_reason(npc, choice, memory, _session.conversations.events(), _session.elapsed_play_seconds, _session.inventory)
	if not reason.is_empty(): return Result.new(false, reason)
	if not choice.gift_rule_id.is_empty(): return _choose_gift(npc, choice)
	var candidate: ConversationMemory = memory.responded(choice)
	var transition: Dictionary = NpcDialogueRules.transition(npc, choice, memory, candidate)
	if not transition.reason.is_empty(): return Result.new(false, transition.reason)
	var next: NpcDialogueGraph.NodeDefinition = transition.node
	var event_value: NpcEventMemory = _session.conversations.events().record(NpcEventMemory.CHOICE, _npc_id, choice.id, _session.elapsed_play_seconds)
	if event_value == null: return Result.new(false, "Event memory range exhausted or invalid active time.")
	if next != null: candidate = NpcDialogueRules.enter(npc, candidate, next)
	_session.conversations = _session.conversations.with_person(candidate, event_value)
	_cursor_state = _session.conversations
	if next == null: _clear()
	else:
		_node_id = next.id
		_selected_choice = choice_id
		_generation += 1
	_executing = true
	changed.emit()
	_executing = false
	return Result.new(true, "Response accepted.")

func _choose_gift(npc: NpcDefinition, choice: NpcDialogueGraph.Choice) -> Result:
	if _cursor_inventory != _session.inventory: return Result.new(false, "Inventory owner changed; reopen conversation.")
	var candidate: NpcGiftRules.Candidate = NpcGiftRules.stage(npc, _node_id, choice.id, _session.conversations, _session.inventory, _session.inventory.revision(), _session.elapsed_play_seconds)
	if not candidate.ok(): return Result.new(false, candidate.reason)
	_executing = true
	# No observer runs between these signal-free assignments. Foraging reads session bag.
	_session.inventory = candidate.inventory
	_session.conversations = candidate.conversations
	_cursor_inventory = _session.inventory
	_cursor_state = _session.conversations
	if candidate.next_node_id.is_empty(): _clear()
	else:
		_node_id = candidate.next_node_id
		_selected_choice = choice.id
		_generation += 1
	_gift_feedback = "Gifted Moonflower to %s. Backpack: %d remaining. Friendship +%d (%d / %d toward %s)." % [npc.display_name, _session.inventory.count("item-moonflower"), npc.gifts[choice.gift_rule_id].affinity_delta, _session.conversations.memory(npc.id).affinity, npc.level_one_affinity, npc.level_one_label]
	changed.emit()
	_executing = false
	return Result.new(true, _gift_feedback)

func _choose_prototype(choice_id: String) -> Result:
	var graph: NpcDialogueGraph = _prototype.graph()
	var node: NpcDialogueGraph.NodeDefinition = graph.nodes[_node_id]
	var choice: NpcDialogueGraph.Choice
	for row: NpcDialogueGraph.Choice in node.choices:
		if row.id == choice_id: choice = row
	if choice == null: return Result.new(false, "Unknown response on current node.")
	var command: Dictionary = choice.command
	var result: Result = Result.new(true, "Prototype response shown; no persistent effects.", command.action_id)
	var owner_token: String = _token()
	_executing = true
	if not command.get("reaction_id", "").is_empty():
		result = reaction_command.call(command.reaction_id, _instance_id) if reaction_command.is_valid() else Result.new(false, "Relationship owner unavailable.")
	elif not command.get("quest_id", "").is_empty():
		result = quest_command.call(command.quest_id, command.action_id, _instance_id) if quest_command.is_valid() else Result.new(false, "Quest owner unavailable.")
	elif command.action_id not in ["prototype-observe", "prototype-leave"]: result = Result.new(false, "Unsupported dialogue action.")
	_executing = false
	if not result.ok: return result
	if not active() or owner_token != _token(): return Result.new(true, result.message, command.action_id)
	_node_id = choice.target_node_id
	_selected_choice = choice_id
	_generation += 1
	changed.emit()
	return Result.new(true, result.message, command.action_id)

func advance(npc_id: String, instance_id: String, node_id: String, token: String) -> Result:
	if not _command_matches(npc_id, instance_id, node_id, token): return Result.new(false, "Stale or foreign conversation command.")
	if _prototype != null:
		var current: NpcDialogueGraph.NodeDefinition = _prototype.graph().nodes[_node_id]
		if not current.choices.is_empty(): return Result.new(false, "Choose a response or Close.")
		if current.continue_target_id.is_empty(): return close(npc_id, instance_id, node_id, token)
		_node_id = current.continue_target_id
		_generation += 1
		changed.emit()
		return Result.new(true, "Conversation continued.")
	var npc: NpcDefinition = _catalog.get_npc(_npc_id)
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[_node_id]
	if node.continue_target_id.is_empty():
		for choice: NpcDialogueGraph.Choice in node.choices:
			if NpcDialogueRules.choice_reason(npc, choice, _session.conversations.memory(_npc_id), _session.conversations.events(), _session.elapsed_play_seconds, _session.inventory).is_empty(): return Result.new(false, "Choose a response or Close.")
		return close(npc_id, instance_id, node_id, token)
	var next: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(node.continue_target_id)
	if next == null or not next.availability.is_enabled(): return Result.new(false, "Continuation unavailable; Close remains available.")
	_session.conversations = _session.conversations.with_person(NpcDialogueRules.enter(npc, _session.conversations.memory(_npc_id), next))
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
	if _executing or _session == null: return Result.new(false, "Event owner unavailable or command busy.")
	# Choices belong to choose(); no caller may fabricate a receipt/event.
	if kind not in [NpcEventMemory.AREA, NpcEventMemory.GATHER]: return Result.new(false, "Unsupported external event adapter.")
	var candidate: NpcEventMemory = _session.conversations.events().record(kind, subject, target, _session.elapsed_play_seconds)
	if candidate == null: return Result.new(false, "Unsupported event key, time or range.")
	_session.conversations = _session.conversations.with_events(candidate)
	if active(): _cursor_state = _session.conversations
	changed.emit()
	return Result.new(true, "Event recorded.")

func _command_matches(npc_id: String, instance_id: String, node_id: String, token: String) -> bool:
	return not _executing and active() and _cursor_state == _session.conversations and _npc_id == npc_id and _instance_id == instance_id and _node_id == node_id and _token() == token

func _token() -> String:
	return "%d:%d:%d" % [get_instance_id(), _generation, _session.inventory.revision() if _session != null else -1]

func _clear() -> void:
	_gift_feedback = ""
	_prototype = null
	_selected_choice = ""
	_cursor_state = null
	_cursor_inventory = null
	_npc_id = ""
	_instance_id = ""
	_node_id = ""
	_generation += 1
