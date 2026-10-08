class_name NpcGiftRules
extends RefCounted
## Pure detached staging. Session/cursor ownership and publication belong to dialogue.
const ITEM_MAPPING: Dictionary = {"moonflower": "item-moonflower"}

class Candidate extends RefCounted:
	var reason: String = ""
	var inventory: InventoryState
	var conversations: NpcConversationState
	var next_node_id: String = ""
	func ok() -> bool:
		return reason.is_empty() and inventory != null and conversations != null

static func eligibility(npc: NpcDefinition, choice: NpcDialogueGraph.Choice, memory: ConversationMemory, events: NpcEventMemory, inventory: InventoryState, seconds: float) -> String:
	if npc == null or choice == null or memory == null or memory.npc_id != npc.id or events == null or inventory == null or not inventory.initialized:
		return "Gift owner unavailable."
	if not choice.availability.is_enabled(): return choice.availability.reason
	if memory.consumed(choice): return "Response already applied."
	if not NpcDialogueRules.matches(choice.conditions, memory, events, seconds, npc.level_one_affinity): return "Response conditions are not met."
	var rule: NpcDefinition.GiftRule = npc.gifts.get(choice.gift_rule_id)
	if rule == null or not rule.availability.is_enabled(): return "Gift rule unavailable."
	var item_id: String = ITEM_MAPPING.get(rule.item_id, "")
	var item: ItemDefinition = inventory.item_definition(item_id)
	if item == null or item.source_item_id != rule.item_id: return "Unknown gift item."
	if not item.giftable: return "Item cannot be gifted."
	if inventory.count(item_id) < 1: return "No owned Moonflower."
	if not rule.required_fact_id.is_empty() and rule.required_fact_id not in memory.learned_fact_ids: return "Learn this person's preference first."
	if events.count(NpcEventMemory.GIFT, rule.item_id, npc.id) >= rule.acceptance_cap: return "Gift acceptance cap reached."
	return ""

static func stage(npc: NpcDefinition, node_id: String, choice_id: String, state: NpcConversationState, inventory: InventoryState, expected_revision: Variant, seconds: float) -> Candidate:
	var result: Candidate = Candidate.new()
	if npc == null or state == null or not state.initialized or inventory == null or not inventory.initialized:
		result.reason = "Gift owner unavailable."
		return result
	if typeof(expected_revision) != TYPE_INT or expected_revision != inventory.revision():
		result.reason = "Inventory changed; choose again."
		return result
	var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(node_id)
	var choice: NpcDialogueGraph.Choice
	if node != null and node.npc_id == npc.id and node.availability.is_enabled():
		for row: NpcDialogueGraph.Choice in node.choices:
			if row.id == choice_id: choice = row
	if choice == null or choice.gift_rule_id.is_empty() or not choice.outcome_tag.is_empty():
		result.reason = "Unknown gift response on current node."
		return result
	var memory: ConversationMemory = state.memory(npc.id)
	var events: NpcEventMemory = state.events()
	result.reason = eligibility(npc, choice, memory, events, inventory, seconds)
	if not result.reason.is_empty(): return result
	var next: NpcDialogueGraph.NodeDefinition
	if not choice.ends_conversation and not choice.target_node_id.is_empty():
		next = npc.graph.nodes.get(choice.target_node_id)
		if next == null or next.npc_id != npc.id or not next.availability.is_enabled():
			result.reason = "Response target unavailable."
			return result
	var rule: NpcDefinition.GiftRule = npc.gifts[choice.gift_rule_id]
	# Source order: choice effects, signed gift delta, authored target entry.
	# G004 adds milestone routing between delta and entry.
	var person: ConversationMemory = memory.responded(choice)
	person.affinity = clampi(person.affinity + rule.affinity_delta, 0, ConversationMemory.MAX_AFFINITY)
	if not choice.ends_conversation and person.level(npc.level_one_affinity) > memory.level(npc.level_one_affinity) and not npc.milestone_node_id.is_empty() and npc.milestone_seen_flag_id not in person.flags:
		var milestone: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(npc.milestone_node_id)
		if milestone == null or milestone.npc_id != npc.id or not milestone.availability.is_enabled():
			result.reason = "Relationship milestone target unavailable."
			return result
	if next != null: person = person.entered(next)
	var gifted: NpcEventMemory = events.record(NpcEventMemory.GIFT, rule.item_id, npc.id, seconds)
	var selected: NpcEventMemory = gifted.record(NpcEventMemory.CHOICE, npc.id, choice.id, seconds) if gifted != null else null
	if selected == null:
		result.reason = "Event memory range exhausted or invalid active time."
		return result
	var bag: InventoryState = inventory.detached_copy()
	if not bag.consume(ITEM_MAPPING[rule.item_id]).is_empty():
		result.reason = "Gift item consumption failed."
		return result
	result.inventory = bag
	result.conversations = state.with_person(person, selected)
	result.next_node_id = next.id if next != null else ""
	return result
