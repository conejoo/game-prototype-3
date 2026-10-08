extends SceneTree
## Synthetic detached eligibility/candidate proof, never ordinary play/save proof.
const Fixture = preload("res://tests/social_fixture.gd")
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for id: String in NpcContentCatalog.ROSTER:
		_recipient(id)
	_gates()
	_signed_effects()
	_target_boundaries()
	_check(TestRunEvidence.write_json("social-gift-report.json", {"task":"G002", "proof":"synthetic pure detached candidates", "assertions":assertions + 1, "failures":failures}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("G002 social_gift_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _recipient(id: String) -> void:
	var pair: Dictionary = Fixture.pair(id)
	var rows: Array[Dictionary] = Fixture.gift_rows(pair, id)
	var bag: InventoryState = pair.session.inventory
	bag.select("item-moonflower")
	var state: NpcConversationState = pair.session.conversations
	var before: Dictionary = Fixture.snapshot(pair)
	for index: int in 2:
		var row: Dictionary = rows[index % rows.size()]
		var candidate: NpcGiftRules.Candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, state, bag, bag.revision(), 2.25)
		_check(candidate.ok(), "gift accepted " + id + ":" + row.id)
		if not candidate.ok(): continue
		_check(Fixture.snapshot(pair) == before, "staging leaves entire session/cursor untouched " + id)
		_check(candidate.inventory.count("item-moonflower") == 2 - index, "one unit only " + id)
		_check(candidate.inventory.snapshot().active_item_id == "item-moonflower", "selection retained with units " + id)
		_check(candidate.inventory.revision() == bag.revision() + 1, "detached revision monotonic " + id)
		_check(candidate.conversations.memory(id).affinity == index + 1, "gift delta once " + id)
		_check(candidate.conversations.memory(id).applied_choice_ids.is_empty(), "repeatable gift has no once-only receipt " + id)
		var events: NpcEventMemory = candidate.conversations.events()
		_check(events.count(NpcEventMemory.GIFT, "moonflower", id) == index + 1, "shared per-item/person cap aggregate " + id)
		var gift_event: Dictionary = events._facts[NpcEventMemory.key(NpcEventMemory.GIFT, "moonflower", id)]
		var choice_event: Dictionary = events._facts[NpcEventMemory.key(NpcEventMemory.CHOICE, id, row.id)]
		_check(gift_event.last_sequence + 1 == choice_event.last_sequence and gift_event.last_active_seconds == 2.25 and choice_event.last_active_seconds == 2.25, "source event order/exact time " + id)
		for other: String in NpcContentCatalog.ROSTER:
			if other != id: _check(candidate.conversations.memory(other).snapshot(3) == state.memory(other).snapshot(3), "other person unchanged " + id + ":" + other)
		state = candidate.conversations
		bag = candidate.inventory
	var row: Dictionary = rows[0]
	var rejected: NpcGiftRules.Candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, state, bag, bag.revision(), 2.25)
	_check(not rejected.ok() and rejected.reason == "Gift acceptance cap reached.", "third gift/shared alternate choice rejected " + id)
	_check(Fixture.snapshot(pair) == before, "all candidates remain detached " + id)

func _gates() -> void:
	var pair: Dictionary = Fixture.pair()
	var row: Dictionary = Fixture.gift_rows(pair, "npc-01")[0]
	var state: NpcConversationState = pair.session.conversations
	var bag: InventoryState = pair.session.inventory
	var memory: ConversationMemory = state.memory("npc-01")
	memory.learned_fact_ids.clear()
	_reject(pair.npc, row, state.with_person(memory), bag, bag.revision(), 0.0, "missing learned fact")
	var empty: InventoryState = bag.detached_copy(); empty.consume("item-moonflower", 3)
	_reject(pair.npc, row, state, empty, empty.revision(), 0.0, "missing owned item")
	var nongift: Dictionary = Fixture.pair("npc-01", 3, true, false)
	_reject(nongift.npc, row, nongift.session.conversations, nongift.session.inventory, nongift.session.inventory.revision(), 0.0, "non-giftable item")
	var unknown: NpcDefinition = pair.catalog.get_npc("npc-01")
	unknown.gifts["npc-01-moonflower-gift"].item_id = "unknown"
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "unknown item mapping")
	unknown = pair.catalog.get_npc("npc-01"); unknown.gifts.clear()
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "missing rule")
	unknown = pair.catalog.get_npc("npc-01")
	unknown.graph.choices[row.id].conditions.required_flags = ["npc-01-helpful-response"]
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "choice condition gate")
	unknown = pair.catalog.get_npc("npc-01")
	unknown.graph.nodes.erase(unknown.graph.choices[row.id].target_node_id)
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "invalid target")
	unknown = pair.catalog.get_npc("npc-01")
	unknown.graph.nodes[unknown.graph.choices[row.id].target_node_id].availability.status = NpcContentAvailability.Status.DEFERRED
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "deferred target")
	_reject(pair.npc, row, state, bag, bag.revision() - 1, 0.0, "changed inventory revision")
	_reject(pair.npc, row, state, bag, 1.5, 0.0, "fractional revision")
	_reject(pair.npc, row, state, bag, bag.revision(), NAN, "invalid time")
	var foreign: Dictionary = row.duplicate(); foreign.node_id = "npc-02-moonflower-hint"
	_reject(pair.npc, foreign, state, bag, bag.revision(), 0.0, "foreign node")
	foreign = row.duplicate(); foreign.id = "npc-02-gift-moonflower-from-hint"
	_reject(pair.npc, foreign, state, bag, bag.revision(), 0.0, "foreign choice")
	for budget: int in [NpcEventMemory.MAX_SEQUENCE, NpcEventMemory.MAX_SEQUENCE - 1]:
		var events: NpcEventMemory = state.events(); events._last_sequence = budget
		_reject(pair.npc, row, state.with_events(events), bag, bag.revision(), 0.0, "two-event budget exhaustion")
	var unsupported: NpcEventMemory = state.events()
	unsupported._allowed.erase(NpcEventMemory.key(NpcEventMemory.CHOICE, row.npc_id, row.id))
	_reject(pair.npc, row, state.with_events(unsupported), bag, bag.revision(), 0.0, "second event unsupported")
	var last: Dictionary = Fixture.pair("npc-01", 1)
	last.session.inventory.select("item-moonflower")
	var candidate: NpcGiftRules.Candidate = NpcGiftRules.stage(last.npc, row.node_id, row.id, last.session.conversations, last.session.inventory, last.session.inventory.revision(), 0.0)
	_check(candidate.ok() and candidate.inventory.snapshot().active_item_id == null and candidate.inventory.count("item-moonflower") == 0, "last unit clears selection")
	bag.add("item-fishing-rod"); bag.select("item-fishing-rod")
	candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, state, bag, bag.revision(), 0.0)
	_check(candidate.ok() and candidate.inventory.snapshot().active_item_id == "item-fishing-rod" and candidate.inventory.count("item-fishing-rod") == 1, "other selected item retained")
	candidate.inventory.consume("item-fishing-rod")
	candidate.conversations._memories["npc-02"].affinity = 99
	_check(bag.count("item-fishing-rod") == 1 and state.memory("npc-02").affinity == 0, "caller edits cannot mutate input inventory/people")
	_check(not bag.item_definition("item-fishing-rod").giftable and bag.item_definition("item-moonflower").giftable, "explicit authored item metadata")
	var baseline: Dictionary = Fixture.pair("npc-01", 3, false)
	_reject(baseline.npc, row, baseline.session.conversations, baseline.session.inventory, baseline.session.inventory.revision(), 0.0, "production gifts remain unavailable")
	_check(baseline.session.conversations.events().supported_key_count() == 40 and state.events().supported_key_count() == 58, "bounded conditional allowlist 40 baseline / 58 future")
	var metadata: ItemDefinition = bag.item_definition("item-moonflower"); metadata.giftable = false
	_check(bag.item_definition("item-moonflower").giftable, "item query detaches authored metadata")
	var missing: NpcConversationState = state.detached_copy(); missing._memories.erase("npc-01")
	_reject(pair.npc, row, missing, bag, bag.revision(), 0.0, "unknown person memory")
	var unsupported_gift: NpcEventMemory = state.events(); unsupported_gift._allowed.erase(NpcEventMemory.key(NpcEventMemory.GIFT, "moonflower", "npc-01"))
	_reject(pair.npc, row, state.with_events(unsupported_gift), bag, bag.revision(), 0.0, "first event unsupported")
	var future: NpcEventMemory = state.events().record(NpcEventMemory.GATHER, "moonflower", null, 10.0)
	_reject(pair.npc, row, state.with_events(future), bag, bag.revision(), 9.0, "backward event time")
	unknown = pair.catalog.get_npc("npc-01"); unknown.gifts["npc-01-moonflower-gift"].availability.status = NpcContentAvailability.Status.DEFERRED
	_reject(unknown, row, state, bag, bag.revision(), 0.0, "unavailable rule")

func _signed_effects() -> void:
	var pair: Dictionary = Fixture.pair()
	var row: Dictionary = Fixture.gift_rows(pair, "npc-01")[0]
	var choice: NpcDialogueGraph.Choice = pair.npc.graph.choices[row.id]
	choice.affinity_delta = -1
	choice.added_flags = ["npc-01-helpful-response"]
	var candidate: NpcGiftRules.Candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, pair.session.conversations, pair.session.inventory, pair.session.inventory.revision(), 0.0)
	_check(candidate.ok() and candidate.conversations.memory("npc-01").affinity == 1 and "npc-01-helpful-response" in candidate.conversations.memory("npc-01").flags, "choice signed clamp then gift delta/flags")
	pair.npc.gifts["npc-01-moonflower-gift"].affinity_delta = -1
	candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, pair.session.conversations, pair.session.inventory, pair.session.inventory.revision(), 0.0)
	_check(candidate.ok() and candidate.conversations.memory("npc-01").affinity == 0, "signed gift clamps zero")
	var person: ConversationMemory = pair.session.conversations.memory("npc-01"); person.affinity = ConversationMemory.MAX_AFFINITY
	pair.npc.gifts["npc-01-moonflower-gift"].affinity_delta = 1; choice.affinity_delta = 1
	candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, pair.session.conversations.with_person(person), pair.session.inventory, pair.session.inventory.revision(), 0.0)
	_check(candidate.ok() and candidate.conversations.memory("npc-01").affinity == ConversationMemory.MAX_AFFINITY, "signed clamp upper bound")
	choice.one_time = true; choice.one_time_reward_flag = "npc-01-helpful-reward"
	candidate = NpcGiftRules.stage(pair.npc, row.node_id, row.id, pair.session.conversations, pair.session.inventory, pair.session.inventory.revision(), 0.0)
	_check(candidate.ok() and row.id in candidate.conversations.memory("npc-01").applied_choice_ids and "npc-01-helpful-reward" in candidate.conversations.memory("npc-01").flags, "synthetic choice delta/flag/receipt staged once")
	_reject(pair.npc, row, candidate.conversations, candidate.inventory, candidate.inventory.revision(), 0.0, "synthetic once-only choice gate")

func _target_boundaries() -> void:
	var pair: Dictionary = Fixture.pair()
	var row: Dictionary = Fixture.gift_rows(pair, "npc-01")[0]
	var person: ConversationMemory = pair.session.conversations.memory("npc-01"); person.affinity = 2
	var state: NpcConversationState = pair.session.conversations.with_person(person)
	var bag: InventoryState = pair.session.inventory
	var npc: NpcDefinition = pair.catalog.get_npc("npc-01")
	npc.graph.nodes.erase(npc.milestone_node_id)
	_reject(npc, row, state, bag, bag.revision(), 0.0, "missing prospective milestone")
	npc = pair.catalog.get_npc("npc-01"); npc.graph.nodes[npc.milestone_node_id].availability.status = NpcContentAvailability.Status.DEFERRED
	_reject(npc, row, state, bag, bag.revision(), 0.0, "deferred prospective milestone")
	npc = pair.catalog.get_npc("npc-01"); npc.graph.nodes[npc.milestone_node_id].npc_id = "npc-02"
	_reject(npc, row, state, bag, bag.revision(), 0.0, "foreign prospective milestone")
	npc = pair.catalog.get_npc("npc-01")
	npc.graph.choices[row.id].ends_conversation = true
	npc.graph.nodes.erase(npc.milestone_node_id)
	var candidate: NpcGiftRules.Candidate = NpcGiftRules.stage(npc, row.node_id, row.id, state, bag, bag.revision(), 0.0)
	_check(candidate.ok() and candidate.next_node_id.is_empty() and candidate.conversations.memory("npc-01").affinity == 3, "synthetic endsConversation precedence skips target/milestone")
	person.flags.append("relationshipLevel1Seen"); state = state.with_person(person)
	npc.graph.choices[row.id].ends_conversation = false
	candidate = NpcGiftRules.stage(npc, row.node_id, row.id, state, bag, bag.revision(), 0.0)
	_check(candidate.ok() and candidate.next_node_id == "npc-01-gift-response", "seen milestone requires no new transition")

func _reject(npc: NpcDefinition, row: Dictionary, state: NpcConversationState, bag: InventoryState, revision: Variant, seconds: float, label: String) -> void:
	var before: Dictionary = {"state":state.snapshot(), "bag":bag.snapshot().to_dictionary(), "revision":bag.revision()}
	var result: NpcGiftRules.Candidate = NpcGiftRules.stage(npc, row.node_id, row.id, state, bag, revision, seconds)
	_check(not result.ok() and not result.reason.is_empty() and result.inventory == null and result.conversations == null, label + " rejects full candidate")
	_check(before == {"state":state.snapshot(), "bag":bag.snapshot().to_dictionary(), "revision":bag.revision()}, label + " preserves exact input")

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition: failures.append(label)
