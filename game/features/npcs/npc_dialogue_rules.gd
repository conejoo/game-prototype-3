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
		if node == null or not node.availability.is_enabled() or not matches(node.conditions, memory, events, seconds, npc.level_one_affinity): continue
		if selected == null or node.priority > selected.priority or (node.priority == selected.priority and node.id < selected.id): selected = node
	return selected

static func choice_reason(npc: NpcDefinition, choice: NpcDialogueGraph.Choice, memory: ConversationMemory, events: NpcEventMemory, seconds: float) -> String:
	if not choice.availability.is_enabled(): return choice.availability.reason
	if not choice.gift_rule_id.is_empty(): return "Gifting capability is unavailable."
	if not choice.outcome_tag.is_empty(): return "Routine capability is unavailable."
	if memory.consumed(choice): return "Response already applied."
	if not matches(choice.conditions, memory, events, seconds, npc.level_one_affinity): return "Response conditions are not met."
	return ""
