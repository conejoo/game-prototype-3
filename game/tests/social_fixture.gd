extends RefCounted
## Production catalog with synthetic inventory/memory and optional disabled gates.
static func pair(npc_id: String = "npc-01", quantity: int = 3, enabled: bool = true, giftable: bool = true) -> Dictionary:
	var actors: ContentCatalog = ContentCatalog.new()
	var manifest: ContentManifest = (load("res://content/prototype_catalog.tres") as ContentManifest).duplicate(true)
	for definition: ContentDefinition in manifest.definitions:
		if definition is ItemDefinition and definition.stable_id == "item-moonflower": (definition as ItemDefinition).giftable = giftable
	assert(actors.initialize(manifest).is_empty())
	var catalog: NpcContentCatalog = NpcContentCatalog.new()
	assert(catalog.initialize_path(actors).is_empty())
	var policy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/social_migration/reference/social_activation.json"))
	if not enabled:
		for kind: String in policy.enable:
			for row: Dictionary in policy.enable[kind]:
				catalog._packages[row.npc_id].coverage[kind][row.id] = {"status":"deferred", "reason":"Synthetic disabled capability fixture"}
	var session: GameSession = GameSession.new()
	assert(session.initialize(actors, "prototype-alderwake", "alderwake-start", "prototype-hero", null, catalog).is_empty())
	if quantity > 0: assert(session.inventory.add("item-moonflower", quantity).is_empty())
	var npc: NpcDefinition = catalog.get_npc(npc_id)
	var memory: ConversationMemory = session.conversations.memory(npc_id)
	memory.flags = PackedStringArray([npc_id + "-introduced"])
	memory.learned_fact_ids = PackedStringArray([npc.gifts[npc_id + "-moonflower-gift"].required_fact_id])
	session.conversations = session.conversations.with_person(memory)
	var service: NpcDialogueService = NpcDialogueService.new()
	assert(service.initialize(catalog, session).is_empty())
	return {"actors":actors, "catalog":catalog, "session":session, "service":service, "npc":npc, "policy":policy}

static func gift_rows(pair_value: Dictionary, npc_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Dictionary in pair_value.policy.enable.choice:
		if row.npc_id == npc_id: result.append(row)
	return result

static func view(pair_value: Dictionary, row: Dictionary) -> Dictionary:
	var service: NpcDialogueService = pair_value.service
	service.cancel()
	assert(service.begin(row.npc_id, "synthetic-contact").ok)
	# Hint/follow-up sharing is deliberately inspected at both authored nodes.
	service._node_id = row.node_id
	return service.snapshot()

static func choose(service: NpcDialogueService, view_value: Dictionary, choice_id: String) -> NpcDialogueService.Result:
	return service.choose(view_value.npc_id, view_value.instance_id, view_value.node_id, view_value.token, choice_id)

static func snapshot(pair_value: Dictionary) -> Dictionary:
	return {"durable":SaveCodec.snapshot(pair_value.session), "inventory_revision":pair_value.session.inventory.revision(), "foraging":pair_value.session.foraging.snapshot(), "view":pair_value.service.snapshot()}
