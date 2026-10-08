class_name PeopleSnapshot
extends RefCounted
## Read-only, detached public projection. No cached session, facts or met authority.

static func from_state(state: NpcConversationState, catalog: NpcContentCatalog) -> Dictionary:
	var people: Array[Dictionary] = []
	if state == null or not state.initialized or catalog == null or not catalog.initialized:
		return {"people": people}
	for id: String in catalog.npc_ids():
		var row: Dictionary = person(state, catalog, id)
		if not row.is_empty(): people.append(row)
	people.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return left.npc_id < right.npc_id if left.display_name == right.display_name else left.display_name < right.display_name)
	return {"people": people}

static func person(state: NpcConversationState, catalog: NpcContentCatalog, id: String) -> Dictionary:
	if state == null or not state.initialized or catalog == null or not catalog.initialized: return {}
	var npc: NpcDefinition = catalog.get_npc(id)
	var memory: ConversationMemory = state.memory(id)
	if npc == null or memory == null: return {}
	var met: bool = false
	for node_id: String in memory.seen_node_ids:
		if npc.graph.nodes.has(node_id) and npc.graph.nodes[node_id].availability.is_enabled():
			met = true
			break
	if not met: return {}
	var facts: Array[Dictionary] = []
	for fact_id: String in memory.learned_fact_ids:
		if not npc.facts.has(fact_id): continue
		var fact: NpcDefinition.Fact = npc.facts[fact_id]
		if not fact.availability.is_enabled(): continue
		facts.append({"id": fact.id, "category": fact.category, "label": fact.label, "description": fact.description})
	facts.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if left.category != right.category: return left.category < right.category
		return left.id < right.id if left.label == right.label else left.label < right.label)
	var level: int = memory.level(npc.level_one_affinity)
	return {"npc_id": id, "display_name": npc.display_name, "pronouns": npc.pronouns,
		"portrait_path": _portrait(npc), "affinity": memory.affinity, "threshold": npc.level_one_affinity,
		"level": level, "level_label": npc.level_one_label if level == 1 else null,
		"progress": clampf(float(memory.affinity) / float(npc.level_one_affinity), 0.0, 1.0), "facts": facts}

static func _portrait(npc: NpcDefinition) -> String:
	if _valid_portrait(npc, "official-neutral"): return npc.portraits["official-neutral"]
	for expression: String in npc.portraits:
		if _valid_portrait(npc, expression): return npc.portraits[expression]
	return ""

static func _valid_portrait(npc: NpcDefinition, expression: String) -> bool:
	return npc.portraits.has(expression) and npc.portrait_availability.has(expression) \
		and npc.portrait_availability[expression].is_enabled() and ResourceLoader.exists(npc.portraits[expression])
