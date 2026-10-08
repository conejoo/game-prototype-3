extends SceneTree
## G006 production content/service projection; supplied items/events and boundaries synthetic.
const PeopleQuery = preload("res://features/npcs/people_snapshot.gd")
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_empty_and_boundaries()
	for id: String in NpcContentCatalog.ROSTER:
		for positive: bool in [true, false]: _recipient(id, positive)
	_all_people_and_isolation()
	_portrait_and_sort_boundaries()
	_check(TestRunEvidence.write_json("people-snapshot-report.json", {"task": "G006", "proof": "detached production projection/service; synthetic items/events/invalid-state and portrait boundaries; no ordinary input", "assertions": assertions + 1, "failures": Array(failures)}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("G006 people_snapshot_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _empty_and_boundaries() -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	var before: Dictionary = SaveCodec.snapshot(pair.session)
	_check(PeopleQuery.from_state(pair.session.conversations, pair.catalog).people.is_empty(), "fresh empty despite all actors/catalog/gift rules")
	_check(PeopleQuery.from_state(null, pair.catalog).people.is_empty(), "null state")
	_check(PeopleQuery.from_state(pair.session.conversations, null).people.is_empty(), "null catalog")
	_check(PeopleQuery.from_state(NpcConversationState.new(), pair.catalog).people.is_empty(), "uninitialized state")
	_check(PeopleQuery.from_state(pair.session.conversations, NpcContentCatalog.new()).people.is_empty(), "uninitialized catalog")
	for id: String in ["", "unknown", "npc-05", "npc-01-initial-conversation"]:
		_check(PeopleQuery.person(pair.session.conversations, pair.catalog, id).is_empty(), "unknown/unrequested ID safe " + id)
	_check(PeopleQuery.person(null, pair.catalog, "npc-01").is_empty(), "null single query")
	_check(SaveCodec.snapshot(pair.session) == before, "queries do not mutate fresh durable state")
	# Invalid-state fixtures prove no implicit met/disclosure authority in projection.
	var memory: ConversationMemory = pair.session.conversations.memory("npc-01")
	memory.flags.append("npc-01-introduced")
	memory.affinity = 3
	memory.learned_fact_ids.append("npc-01-moonflower-preference")
	pair.session.conversations = pair.session.conversations.with_person(memory)
	_check(PeopleQuery.from_state(pair.session.conversations, pair.catalog).people.is_empty(), "flags/affinity/facts alone do not mean met")
	memory.seen_node_ids = PackedStringArray(["unknown", "npc-02-initial-conversation"])
	pair.session.conversations = pair.session.conversations.with_person(memory)
	_check(PeopleQuery.from_state(pair.session.conversations, pair.catalog).people.is_empty(), "foreign/unknown seen IDs do not mean met")
	memory.seen_node_ids = PackedStringArray(["npc-01-initial-conversation"])
	memory.learned_fact_ids = PackedStringArray(["unknown", "npc-02-moonflower-pressing", "npc-01-public-role", "npc-01-river-fishing"])
	pair.session.conversations = pair.session.conversations.with_person(memory)
	var row: Dictionary = PeopleQuery.person(pair.session.conversations, pair.catalog, "npc-01")
	_check(not row.is_empty() and row.facts.is_empty(), "foreign/unknown/undisclosed facts excluded")
	for affinity: int in [0, 1, 2, 3, 4, ConversationMemory.MAX_AFFINITY]:
		memory.affinity = affinity
		pair.session.conversations = pair.session.conversations.with_person(memory)
		row = PeopleQuery.person(pair.session.conversations, pair.catalog, "npc-01")
		_check(row.affinity == affinity and row.level == (1 if affinity >= 3 else 0), "affinity boundary " + str(affinity))
		_check(row.level_label == ("Acquaintance" if affinity >= 3 else null), "no extra level label " + str(affinity))
		_check(is_equal_approx(row.progress, minf(float(affinity) / 3.0, 1.0)), "bounded progress " + str(affinity))
	var helena: ConversationMemory = pair.session.conversations.memory("npc-02")
	helena.seen_node_ids = PackedStringArray(["npc-02-routine-archive-default"])
	helena.learned_fact_ids = PackedStringArray(["npc-02-archive-practice"])
	pair.session.conversations = pair.session.conversations.with_person(helena)
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, "npc-02").is_empty(), "deferred-only entry excluded")
	helena.seen_node_ids.append("npc-02-initial-conversation")
	pair.session.conversations = pair.session.conversations.with_person(helena)
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, "npc-02").facts.is_empty(), "deferred archive fact excluded after valid meet")
	before = SaveCodec.snapshot(pair.session)
	for attempt: int in range(3): PeopleQuery.from_state(pair.session.conversations, pair.catalog)
	_check(SaveCodec.snapshot(pair.session) == before, "boundary queries do not grant facts/receipt/milestone")

func _recipient(id: String, positive: bool) -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	var npc: NpcDefinition = pair.catalog.get_npc(id)
	var initial: Dictionary = SaveCodec.snapshot(pair.session)
	_check(pair.service.begin(id, "fixture-" + id).ok, "real node entry " + id)
	var entered: Dictionary = SaveCodec.snapshot(pair.session)
	var row: Dictionary = PeopleQuery.person(pair.session.conversations, pair.catalog, id)
	_check(PeopleQuery.from_state(pair.session.conversations, pair.catalog).people.size() == 1, "only entered person " + id)
	_check(not row.is_empty() and row.affinity == 0 and row.level_label == null, "met before introduction choice " + id)
	_check(row.display_name == npc.display_name and row.pronouns == npc.pronouns and row.threshold == npc.level_one_affinity, "authored public identity " + id)
	_check(row.portrait_path == npc.portraits["official-neutral"] and FileAccess.file_exists(row.portrait_path), "official portrait " + id)
	_check(SaveCodec.snapshot(pair.session) == entered, "entered projection inert " + id)
	var view: Dictionary = pair.service.snapshot()
	_check(SocialSaveFixture.GiftFixture.choose(pair.service, view, view.choices[0 if positive else 1].id).ok, "real authored intro choice " + id)
	pair.service.cancel()
	var old: Dictionary = PeopleQuery.from_state(pair.session.conversations, pair.catalog)
	var old_facts: PackedStringArray = _fact_ids(old.people[0])
	var early_durable: Dictionary = SaveCodec.snapshot(pair.session)
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, id).affinity == (1 if positive else 0), "fresh choice reflected " + id)
	_verify_facts(pair, id)
	SocialSaveFixture.preference(pair, id)
	row = PeopleQuery.person(pair.session.conversations, pair.catalog, id)
	var required: String = npc.gifts[id + "-moonflower-gift"].required_fact_id
	_check(_fact_ids(row).has(required), "actual preference entry reflected " + id)
	_check(_fact_ids(old.people[0]) == old_facts, "old projection retains partial facts " + id)
	_verify_facts(pair, id)
	_check(pair.session.inventory.add("item-moonflower", 2).is_empty(), "synthetic gift inventory " + id)
	for count: int in [1, 2]:
		var previous: Dictionary = PeopleQuery.person(pair.session.conversations, pair.catalog, id)
		SocialSaveFixture.gift(pair, id)
		row = PeopleQuery.person(pair.session.conversations, pair.catalog, id)
		_check(row.affinity == count + (1 if positive else 0) and previous.affinity == row.affinity - 1, "gift fresh, old projection detached " + id)
		_check(row.level == (1 if positive and count == 2 else 0) and row.level_label == (npc.level_one_label if positive and count == 2 else null), "derived gift level " + id)
		_check(is_equal_approx(row.progress, float(row.affinity) / float(row.threshold)), "gift progress " + id)
		_verify_facts(pair, id)
	var durable: Dictionary = SaveCodec.snapshot(pair.session)
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(durable, "", true, true), pair.actors, pair.catalog)
	_check(decoded.session != null and decoded.errors.is_empty(), "strict current save restoration " + id)
	if decoded.session != null:
		_check(PeopleQuery.from_state(decoded.session.conversations, pair.catalog) == PeopleQuery.from_state(pair.session.conversations, pair.catalog), "load projection equality " + id)
		var earlier: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(early_durable, "", true, true), pair.actors, pair.catalog)
		_check(earlier.session != null and earlier.errors.is_empty(), "strict earlier save restoration " + id)
		if earlier.session != null:
			_check(PeopleQuery.from_state(earlier.session.conversations, pair.catalog) == old, "load older affinity/facts without cached later state " + id)
		var empty: Dictionary = PeopleQuery.from_state(SocialSaveFixture.setup().session.conversations, pair.catalog)
		_check(empty.people.is_empty(), "fresh session query does not cache restored people " + id)
		_check(pair.service.initialize(pair.catalog, decoded.session).is_empty(), "rebind loaded owner " + id)
		_check(pair.service.begin(id, "loaded-" + id).ok, "reopen restored owner " + id)
		pair.service.cancel()
		_check(SaveCodec.snapshot(decoded.session) == durable, "reopen after projection/load inert " + id)
	for other: String in NpcContentCatalog.ROSTER:
		if other != id:
			_check(PeopleQuery.person(pair.session.conversations, pair.catalog, other).is_empty() and pair.session.conversations.memory(other).snapshot(3) == initial.conversations.people[other], "independent unmet person " + other)
	var before: Dictionary = SaveCodec.snapshot(pair.session)
	var catalog_before: Dictionary = pair.catalog.document_snapshot()
	row.facts.clear(); row.display_name = "Caller edit"; row.affinity = 999
	old.people.clear()
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, id).display_name == npc.display_name, "caller cannot mutate catalog " + id)
	_check(SaveCodec.snapshot(pair.session) == before and pair.catalog.document_snapshot() == catalog_before, "nested result mutations inert " + id)

func _verify_facts(pair: Dictionary, id: String) -> void:
	var row: Dictionary = PeopleQuery.person(pair.session.conversations, pair.catalog, id)
	var memory: ConversationMemory = pair.session.conversations.memory(id)
	var npc: NpcDefinition = pair.catalog.get_npc(id)
	_check(row.facts.size() == memory.learned_fact_ids.size(), "only persisted learned facts " + id)
	for fact: Dictionary in row.facts:
		var definition: NpcDefinition.Fact = npc.facts[fact.id]
		_check(fact.id in memory.learned_fact_ids and definition.availability.is_enabled(), "learned enabled fact " + fact.id)
		_check(fact.category == definition.category and fact.label == definition.label and fact.description == definition.description, "exact authored fact " + fact.id)
	for index: int in range(1, row.facts.size()):
		var left: Dictionary = row.facts[index - 1]
		var right: Dictionary = row.facts[index]
		_check(left.category < right.category or (left.category == right.category and left.label <= right.label), "category then label sort " + id)

func _all_people_and_isolation() -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	for id: String in NpcContentCatalog.ROSTER:
		SocialSaveFixture.introduce(pair, id)
		SocialSaveFixture.preference(pair, id)
		pair.service.cancel()
	var before: Dictionary = SaveCodec.snapshot(pair.session)
	var content: Dictionary = pair.catalog.document_snapshot()
	var snapshot: Dictionary = PeopleQuery.from_state(pair.session.conversations, pair.catalog)
	_check(snapshot.people.size() == 8, "exact eight met roster")
	var names: PackedStringArray = []
	var ids: PackedStringArray = []
	for row: Dictionary in snapshot.people:
		names.append(row.display_name)
		ids.append(row.npc_id)
		_verify_facts(pair, row.npc_id)
	var sorted: PackedStringArray = names.duplicate(); sorted.sort()
	_check(names == sorted, "authored name sorting")
	_check(ids == PackedStringArray(["npc-08", "npc-14", "npc-04", "npc-02", "npc-07", "npc-03", "npc-01", "npc-06"]), "G001 pinned People name order")
	_check(pair.session.inventory.add("item-moonflower", 1).is_empty(), "synthetic mixed-roster supply")
	SocialSaveFixture.gift(pair, "npc-03")
	for row: Dictionary in snapshot.people:
		var updated: Dictionary = PeopleQuery.person(pair.session.conversations, pair.catalog, row.npc_id)
		_check(updated.affinity == row.affinity + 1 if row.npc_id == "npc-03" else updated == row, "mixed met-roster recipient isolation " + row.npc_id)
	before = SaveCodec.snapshot(pair.session)
	var first: Dictionary = snapshot.people[0]
	var original: Dictionary = first.duplicate(true)
	first.facts[0].description = "caller changed nested fact"
	first.facts.append({"id": "invented"})
	first.pronouns = "changed"; first.portrait_path = "changed"; first.progress = -1
	snapshot.people.reverse()
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, original.npc_id) == original, "nested fact and identity values detached")
	_check(SaveCodec.snapshot(pair.session) == before and pair.catalog.document_snapshot() == content, "full projection edits preserve all durable/catalog values")

func _portrait_and_sort_boundaries() -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	SocialSaveFixture.introduce(pair, "npc-01")
	var npc: NpcDefinition = pair.catalog.get_npc("npc-01")
	var fallback: String = ""
	for expression: String in npc.portraits:
		if expression != "official-neutral": fallback = npc.portraits[expression]; break
	npc.portraits.erase("official-neutral")
	_check(PeopleQuery._portrait(npc) == fallback, "missing primary uses first valid authored fallback")
	npc = pair.catalog.get_npc("npc-01")
	npc.portraits["official-neutral"] = "res://absent.png"
	_check(PeopleQuery._portrait(npc) == fallback, "missing primary asset skips to fallback")
	npc = pair.catalog.get_npc("npc-01")
	npc.portrait_availability["official-neutral"].status = NpcContentAvailability.Status.DEFERRED
	_check(PeopleQuery._portrait(npc) == fallback, "deferred primary skips to fallback")
	for expression: String in npc.portrait_availability: npc.portrait_availability[expression].status = NpcContentAvailability.Status.DEFERRED
	_check(PeopleQuery._portrait(npc).is_empty(), "no usable portrait safe empty")
	_check(PeopleQuery.person(pair.session.conversations, pair.catalog, "npc-01").portrait_path == pair.catalog.get_npc("npc-01").portraits["official-neutral"], "detached portrait edits cannot affect catalog")
	# Validated content variant ensures category takes priority over label, and ties use label.
	var document: Dictionary = pair.catalog.document_snapshot()
	var package: Dictionary = document.packages[2]
	var labels: Array[String] = ["Zebra", "Zulu", "Alpha"]
	var categories: Array[String] = ["A", "B", "B"]
	SocialSaveFixture.introduce(pair, "npc-03")
	var memory: ConversationMemory = pair.session.conversations.memory("npc-03")
	for index: int in package.runtime.facts.size():
		package.runtime.facts[index].label = labels[index]
		package.runtime.facts[index].category = categories[index]
		ConversationMemory._add_unique(memory.learned_fact_ids, package.runtime.facts[index].id)
	var variant: NpcContentCatalog = NpcContentCatalog.new()
	_check(variant.initialize_document(document, pair.actors).is_empty(), "sorting variant retains strict content rules")
	var state: NpcConversationState = pair.session.conversations.with_person(memory)
	var row: Dictionary = PeopleQuery.person(state, variant, "npc-03")
	_check(not row.is_empty() and row.facts.size() == 3 and row.facts[0].label == "Zebra" and row.facts[1].label == "Alpha" and row.facts[2].label == "Zulu", "category primary, label secondary")

func _fact_ids(row: Dictionary) -> PackedStringArray:
	var ids: PackedStringArray = []
	for fact: Dictionary in row.facts: ids.append(fact.id)
	return ids

func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
