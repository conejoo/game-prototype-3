class_name SocialSaveFixture
extends RefCounted
## Synthetic approved social catalog and source milestone routing, pending G004.
const GiftFixture = preload("res://tests/social_fixture.gd")

static func setup() -> Dictionary:
	var pair: Dictionary = GiftFixture.pair("npc-01", 0)
	var state: NpcConversationState = NpcConversationState.new()
	assert(state.initialize(pair.catalog).is_empty())
	pair.session.conversations = state
	assert(pair.service.initialize(pair.catalog, pair.session).is_empty())
	return pair

static func introduce(pair: Dictionary, id: String, positive: bool = true) -> void:
	var service: NpcDialogueService = pair.service
	service.cancel()
	pair.session.elapsed_play_seconds += 0.1234567890123456
	assert(service.begin(id, "fixture-" + id).ok)
	var view: Dictionary = service.snapshot()
	assert(GiftFixture.choose(service, view, view.choices[0 if positive else 1].id).ok)
	service.cancel()

static func preference(pair: Dictionary, id: String) -> void:
	var service: NpcDialogueService = pair.service
	service.cancel()
	var npc: NpcDefinition = pair.catalog.get_npc(id)
	var required: String = npc.gifts[id + "-moonflower-gift"].required_fact_id
	if id in ["npc-01", "npc-02"]:
		pair.session.elapsed_play_seconds += 0.1234567890123456
		assert(service.record_event(NpcEventMemory.GATHER, "moonflower", null).ok)
	assert(service.begin(id, "fixture-" + id).ok)
	if required not in pair.session.conversations.memory(id).learned_fact_ids:
		var view: Dictionary = service.snapshot()
		for choice: Dictionary in view.choices:
			var definition: NpcDialogueGraph.Choice = npc.graph.choices[choice.id]
			if not definition.target_node_id.is_empty() and required in npc.graph.nodes[definition.target_node_id].revealed_fact_ids:
				assert(GiftFixture.choose(service, view, choice.id).ok)
				break
	assert(required in pair.session.conversations.memory(id).learned_fact_ids)
	# Hint choice belongs to the still-open disclosure node; preserve that cursor.
	if id not in ["npc-01", "npc-02"]: service.cancel()

static func gift(pair: Dictionary, id: String) -> void:
	var npc: NpcDefinition = pair.catalog.get_npc(id)
	var service: NpcDialogueService = pair.service
	var before: ConversationMemory = pair.session.conversations.memory(id)
	if service.active() and service.snapshot().npc_id != id: service.cancel()
	pair.session.elapsed_play_seconds += 0.1234567890123456
	var selected: NpcDialogueGraph.Choice
	var view: Dictionary
	for attempt: int in range(8):
		if not service.active(): assert(service.begin(id, "fixture-" + id).ok)
		view = service.snapshot()
		for choice: Dictionary in view.choices:
			var definition: NpcDialogueGraph.Choice = npc.graph.choices[choice.id]
			if not definition.gift_rule_id.is_empty(): selected = definition; break
		if selected != null: break
		service.cancel()
	assert(selected != null)
	assert(GiftFixture.choose(service, view, selected.id).ok)
	# G003 proves the legal source replacement without implementing G004 routing.
	var after: ConversationMemory = pair.session.conversations.memory(id)
	if not selected.ends_conversation and after.level(npc.level_one_affinity) > before.level(npc.level_one_affinity) and not npc.milestone_node_id.is_empty():
		if selected.target_node_id not in before.seen_node_ids: after.seen_node_ids.erase(selected.target_node_id)
		after = after.entered(npc.graph.nodes[npc.milestone_node_id])
		ConversationMemory._add_unique(after.flags, npc.milestone_seen_flag_id)
		pair.session.conversations = pair.session.conversations.with_person(after)
	service.cancel()

static func complete() -> Dictionary:
	var pair: Dictionary = setup()
	var run: GameSession = ForagingSaveFixture.make(pair.actors, "tollworks")
	run.conversations = pair.session.conversations
	pair.session = run
	assert(pair.service.initialize(pair.catalog, run).is_empty())
	assert(NpcSaveFixture.populate(run, pair.catalog).is_empty())
	preference(pair, "npc-01")
	gift(pair, "npc-01")
	gift(pair, "npc-01")
	preference(pair, "npc-03")
	gift(pair, "npc-03")
	return pair
