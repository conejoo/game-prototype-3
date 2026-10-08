class_name NpcConversationState
extends RefCounted
## Session-owned publication: every person and event aggregate swaps together.
var initialized: bool = false
var _memories: Dictionary[String, ConversationMemory] = {}
var _thresholds: Dictionary[String, int] = {}
var _events: NpcEventMemory = NpcEventMemory.new()

func initialize(catalog: NpcContentCatalog) -> PackedStringArray:
	if initialized: return PackedStringArray(["Conversation state already initialized"])
	if catalog == null or not catalog.initialized: return PackedStringArray(["Conversation state requires validated NPC content"])
	for id: String in catalog.npc_ids():
		_memories[id] = ConversationMemory.new(id)
		_thresholds[id] = catalog.get_npc(id).level_one_affinity
	_events.initialize(catalog)
	initialized = true
	return []

func memory(id: String) -> ConversationMemory:
	return _memories[id].detached_copy() if _memories.has(id) else null

func events() -> NpcEventMemory:
	return _events.detached_copy()

func with_person(value: ConversationMemory, event_value: NpcEventMemory = null) -> NpcConversationState:
	var result: NpcConversationState = detached_copy()
	result._memories[value.npc_id] = value.detached_copy()
	if event_value != null: result._events = event_value.detached_copy()
	return result

func with_events(value: NpcEventMemory) -> NpcConversationState:
	var result: NpcConversationState = detached_copy()
	result._events = value.detached_copy()
	return result

func detached_copy() -> NpcConversationState:
	var result: NpcConversationState = NpcConversationState.new()
	result.initialized = initialized
	result._thresholds = _thresholds.duplicate()
	result._events = _events.detached_copy()
	for id: String in _memories: result._memories[id] = _memories[id].detached_copy()
	return result

func snapshot() -> Dictionary:
	var people: Dictionary = {}
	for id: String in _memories: people[id] = _memories[id].snapshot(_thresholds[id])
	return {"people": people, "events": _events.snapshot()}
