extends SceneTree
## Synthetic service publication/token guards. No ordinary UI or persistence claim.
const Fixture = preload("res://tests/social_fixture.gd")
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for id: String in NpcContentCatalog.ROSTER: _recipient(id)
	_rejections()
	_observers()
	_check(TestRunEvidence.write_json("social-transaction-report.json", {"task":"G002", "proof":"synthetic service publication", "assertions":assertions + 1, "failures":failures}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("G002 social_transaction_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _recipient(id: String) -> void:
	var pair: Dictionary = Fixture.pair(id)
	var separate: Dictionary = Fixture.pair(id)
	var other_before: Dictionary = Fixture.snapshot(separate)
	var rows: Array[Dictionary] = Fixture.gift_rows(pair, id)
	var baseline: Dictionary = SaveCodec.snapshot(pair.session)
	for index: int in 2:
		var row: Dictionary = rows[index % rows.size()]
		var view: Dictionary = Fixture.view(pair, row)
		var old_bag: InventoryState = pair.session.inventory
		var old_state: NpcConversationState = pair.session.conversations
		var foraging_revision: int = pair.session.foraging.revision()
		_check(Fixture.choose(pair.service, view, row.id).ok, "accepted intentional gift " + id + ":" + row.id)
		_check(pair.session.inventory != old_bag and pair.session.conversations != old_state, "both detached owners swapped " + id)
		_check(pair.session.inventory.count("item-moonflower") == 2 - index and pair.session.conversations.memory(id).affinity == index + 1, "one consume/delta " + id)
		_check(pair.session.foraging.revision() == foraging_revision + 1 and pair.session.foraging.snapshot().inventory == pair.session.inventory.snapshot().to_dictionary(), "foraging follows new bag/revision " + id)
		_check(pair.session.conversations.events().count(NpcEventMemory.GIFT, "moonflower", id) == index + 1, "gift aggregate once " + id)
		_reject(pair, view, row.id, "stale/double-click token " + id)
	var view: Dictionary = Fixture.view(pair, rows[0])
	_reject(pair, view, rows[0].id, "shared cap " + id)
	var after: Dictionary = SaveCodec.snapshot(pair.session)
	after.inventory = baseline.inventory
	after.conversations = baseline.conversations
	_check(after == baseline, "all old durable fields/trust/quests/environment unchanged " + id)
	_check(Fixture.snapshot(separate) == other_before, "sessions independent " + id)
	for other: String in NpcContentCatalog.ROSTER:
		if other != id: _check(pair.session.conversations.memory(other).snapshot(3) == baseline.conversations.people[other], "other NPC unchanged " + id + ":" + other)
	pair.service.cancel()

func _rejections() -> void:
	var pair: Dictionary = Fixture.pair()
	var row: Dictionary = Fixture.gift_rows(pair, "npc-01")[0]
	var view: Dictionary = Fixture.view(pair, row)
	for field: String in ["npc_id", "node_id", "instance_id", "token"]:
		var wrong: Dictionary = view.duplicate(true); wrong[field] = "foreign"
		_reject(pair, wrong, row.id, "foreign " + field)
	_reject(pair, view, "unknown", "unknown choice")
	pair.session.inventory.select("item-moonflower")
	_reject(pair, view, row.id, "changed inventory selection/revision")
	view = pair.service.snapshot()
	pair.session.inventory = pair.session.inventory.detached_copy()
	_reject(pair, view, row.id, "replacement inventory same revision")
	for budget: int in [NpcEventMemory.MAX_SEQUENCE, NpcEventMemory.MAX_SEQUENCE - 1]:
		pair = Fixture.pair(); view = Fixture.view(pair, row)
		var events: NpcEventMemory = pair.session.conversations.events(); events._last_sequence = budget
		pair.session.conversations = pair.session.conversations.with_events(events)
		pair.service._cursor_state = pair.session.conversations # Deliberate event-boundary fixture
		_reject(pair, view, row.id, "atomic event exhaustion")
	pair = Fixture.pair(); view = Fixture.view(pair, row)
	pair.catalog._packages["npc-01"].coverage.node["npc-01-gift-response"].status = "deferred"
	_reject(pair, view, row.id, "unavailable target")
	pair = Fixture.pair("npc-01", 0); view = Fixture.view(pair, row)
	_reject(pair, view, row.id, "missing owned item")
	pair = Fixture.pair(); view = Fixture.view(pair, row)
	var person: ConversationMemory = pair.session.conversations.memory("npc-01"); person.learned_fact_ids.clear()
	pair.session.conversations = pair.session.conversations.with_person(person); pair.service._cursor_state = pair.session.conversations
	_reject(pair, view, row.id, "missing fact")
	pair = Fixture.pair("npc-01", 3, false); view = Fixture.view(pair, row)
	_reject(pair, view, row.id, "ordinary production capability deferred")
	_check(not pair.service.record_event(NpcEventMemory.GIFT, "moonflower", "npc-01").ok, "external caller cannot fabricate gifts")
	pair = Fixture.pair(); view = Fixture.view(pair, row)
	var second: NpcDialogueService = NpcDialogueService.new(); second.initialize(pair.catalog, pair.session)
	second.begin("npc-02", "other-contact")
	_reject(pair, view, row.id, "foreign social publication invalidates cursor")
	second.cancel(); pair.service.cancel()

func _observers() -> void:
	var pair: Dictionary = Fixture.pair("npc-01", 2)
	var row: Dictionary = Fixture.gift_rows(pair, "npc-01")[0]
	var view: Dictionary = Fixture.view(pair, row)
	var notifications: Array[int] = [0]
	pair.service.changed.connect(func() -> void:
		notifications[0] += 1
		var events: NpcEventMemory = pair.session.conversations.events()
		_check(pair.session.inventory.count("item-moonflower") == 1 and pair.session.conversations.memory("npc-01").affinity == 1 and events.count(NpcEventMemory.GIFT, "moonflower", "npc-01") == 1 and events.count(NpcEventMemory.CHOICE, "npc-01", row.id) == 1 and pair.service.snapshot().node_id == "npc-01-gift-response", "reader observes complete bag/social/events/cursor")
		_check(pair.session.foraging.snapshot().inventory == pair.session.inventory.snapshot().to_dictionary(), "reader observes foraging current bag")
		var fresh: Dictionary = pair.service.snapshot()
		_check(not Fixture.choose(pair.service, fresh, row.id).ok and not Fixture.choose(pair.service, view, row.id).ok, "callback fresh/stale reentrancy blocked")
		_check(not pair.service.record_event(NpcEventMemory.GATHER, "moonflower", null).ok, "callback event reentrancy blocked")
		_check(not pair.service.begin("npc-02", "other").ok and not pair.service.initialize(pair.catalog, pair.session).is_empty(), "callback owner replacement blocked")
	)
	_check(Fixture.choose(pair.service, view, row.id).ok and notifications[0] == 1, "single atomic notification")
	# Do not emit cancellation into acceptance observer after its one-shot assertion.
	for connection: Dictionary in pair.service.changed.get_connections(): pair.service.changed.disconnect(connection.callable)
	pair.service.cancel()
	view = Fixture.view(pair, row)
	_check(Fixture.choose(pair.service, view, row.id).ok and pair.session.inventory.count("item-moonflower") == 0, "reopened deliberate second command accepted")
	_check(pair.session.conversations.memory("npc-01").applied_choice_ids.is_empty(), "stale protection does not impose gift receipt")

func _reject(pair: Dictionary, view: Dictionary, choice_id: String, label: String) -> void:
	var before: Dictionary = Fixture.snapshot(pair)
	var bag: InventoryState = pair.session.inventory
	var conversations: NpcConversationState = pair.session.conversations
	var notifications: Array[int] = [0]
	var observer: Callable = func() -> void: notifications[0] += 1
	pair.service.changed.connect(observer)
	var result: NpcDialogueService.Result = Fixture.choose(pair.service, view, choice_id)
	pair.service.changed.disconnect(observer)
	_check(not result.ok and not result.message.is_empty(), label + " rejected")
	_check(Fixture.snapshot(pair) == before and bag == pair.session.inventory and conversations == pair.session.conversations and notifications[0] == 0, label + " exact no-publication/no-observer")

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition: failures.append(label)
