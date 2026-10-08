class_name ConversationMemory
extends RefCounted
## Detached per-person value. Only NpcDialogueService publishes accepted changes.
const MAX_AFFINITY: int = 2147483647
var npc_id: String
var affinity: int = 0
var flags: PackedStringArray = []
var learned_fact_ids: PackedStringArray = []
var seen_node_ids: PackedStringArray = []
var applied_choice_ids: PackedStringArray = []

func _init(id: String = "") -> void:
	npc_id = id

func level(threshold: int) -> int:
	return 1 if affinity >= threshold else 0

func detached_copy() -> ConversationMemory:
	var result: ConversationMemory = ConversationMemory.new(npc_id)
	result.affinity = affinity
	result.flags = flags.duplicate()
	result.learned_fact_ids = learned_fact_ids.duplicate()
	result.seen_node_ids = seen_node_ids.duplicate()
	result.applied_choice_ids = applied_choice_ids.duplicate()
	return result

func entered(node: NpcDialogueGraph.NodeDefinition) -> ConversationMemory:
	var result: ConversationMemory = detached_copy()
	_add_unique(result.seen_node_ids, node.id)
	for id: String in node.revealed_fact_ids:
		_add_unique(result.learned_fact_ids, id)
	return result

func consumed(choice: NpcDialogueGraph.Choice) -> bool:
	return choice.has_one_time_effect() and (choice.id in applied_choice_ids or (not choice.one_time_reward_flag.is_empty() and choice.one_time_reward_flag in flags))

func responded(choice: NpcDialogueGraph.Choice) -> ConversationMemory:
	var result: ConversationMemory = detached_copy()
	if consumed(choice): return result
	result.affinity = clampi(affinity + choice.affinity_delta, 0, MAX_AFFINITY)
	for id: String in choice.added_flags:
		_add_unique(result.flags, id)
	if not choice.one_time_reward_flag.is_empty(): _add_unique(result.flags, choice.one_time_reward_flag)
	if choice.has_one_time_effect(): _add_unique(result.applied_choice_ids, choice.id)
	return result

func snapshot(threshold: int) -> Dictionary:
	return {"npc_id": npc_id, "affinity": affinity, "level": level(threshold), "flags": Array(flags), "learned_fact_ids": Array(learned_fact_ids), "seen_node_ids": Array(seen_node_ids), "applied_choice_ids": Array(applied_choice_ids)}

static func _add_unique(values: PackedStringArray, id: String) -> void:
	if id not in values:
		values.append(id)
		values.sort()
