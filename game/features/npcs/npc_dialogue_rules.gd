class_name NpcDialogueRules
extends RefCounted
## Pure authored queries; linked target conditions are entry gates, as in source.
static func matches(conditions: NpcDialogueGraph.Conditions, memory: ConversationMemory, events: NpcEventMemory, seconds: float, threshold: int) -> bool:
	if conditions == null or memory == null or events == null or not NpcEventMemory.valid_time(seconds): return false
	if conditions.minimum_affinity >= 0 and memory.affinity < conditions.minimum_affinity: return false
	if conditions.maximum_affinity >= 0 and memory.affinity > conditions.maximum_affinity: return false
	if memory.level(threshold) < conditions.minimum_relationship_level: return false
	for id: String in conditions.required_flags:
		if id not in memory.flags: return false
	for id: String in conditions.excluded_flags:
		if id in memory.flags: return false
	for id: String in conditions.required_fact_ids:
		if id not in memory.learned_fact_ids: return false
	for id: String in conditions.unknown_fact_ids:
		if id in memory.learned_fact_ids: return false
	for id: String in conditions.required_seen_node_ids:
		if id not in memory.seen_node_ids: return false
	for id: String in conditions.unseen_node_ids:
		if id in memory.seen_node_ids: return false
	for condition: NpcDialogueGraph.EventCondition in conditions.events:
		if not events.matches(condition, seconds): return false
	return true

static func resolve(npc: NpcDefinition, memory: ConversationMemory, events: NpcEventMemory, seconds: float) -> NpcDialogueGraph.NodeDefinition:
	if npc == null or memory == null or memory.npc_id != npc.id: return null
	var selected: NpcDialogueGraph.NodeDefinition
	for id: String in npc.graph.entry_node_ids:
		var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(id)
		if node == null or node.id.begins_with("npc-02-routine-") or not node.availability.is_enabled() or not matches(node.conditions, memory, events, seconds, npc.level_one_affinity): continue
		if selected == null or node.priority > selected.priority or (node.priority == selected.priority and node.id < selected.id): selected = node
	return selected

static func choice_reason(npc: NpcDefinition, choice: NpcDialogueGraph.Choice, memory: ConversationMemory, events: NpcEventMemory, seconds: float, inventory: InventoryState = null, context: RoutineDialogueContext = null) -> String:
	if not choice.availability.is_enabled(): return choice.availability.reason
	if not choice.gift_rule_id.is_empty(): return NpcGiftRules.eligibility(npc, choice, memory, events, inventory, seconds)
	if not choice.outcome_tag.is_empty():
		if context == null: return "Routine capability is unavailable."
		var staged: Dictionary = context.stage(choice.outcome_tag)
		if not staged.ok: return staged.reason
	if memory.consumed(choice): return "Response already applied."
	if not matches(choice.conditions, memory, events, seconds, npc.level_one_affinity): return "Response conditions are not met."
	return ""

static func transition(npc: NpcDefinition, choice: NpcDialogueGraph.Choice, before: ConversationMemory, after: ConversationMemory) -> Dictionary:
	# Source endsConversation wins, then unseen crossing milestone, then authored target.
	if choice.ends_conversation: return {"node":null, "reason":""}
	var target: String = choice.target_node_id
	var crossing: bool = after.level(npc.level_one_affinity) > before.level(npc.level_one_affinity)
	var milestone: bool = crossing and not npc.milestone_node_id.is_empty() and npc.milestone_seen_flag_id not in after.flags
	if milestone: target = npc.milestone_node_id
	if target.is_empty(): return {"node":null, "reason":""}
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(target)
	if node == null or node.npc_id != npc.id or not node.availability.is_enabled():
		return {"node":null, "reason":"Relationship milestone target unavailable." if milestone else "Response target unavailable."}
	return {"node":node, "reason":""}

static func enter(npc: NpcDefinition, memory: ConversationMemory, node: NpcDialogueGraph.NodeDefinition) -> ConversationMemory:
	var result: ConversationMemory = memory.entered(node)
	if node.id == npc.milestone_node_id and not npc.milestone_seen_flag_id.is_empty():
		ConversationMemory._add_unique(result.flags, npc.milestone_seen_flag_id)
	return result
