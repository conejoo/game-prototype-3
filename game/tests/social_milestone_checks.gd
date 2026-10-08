extends SceneTree
## G004 production catalog/service rules. Items/events and authoring variants synthetic.
const Fixture = preload("res://tests/social_fixture.gd")
var failures: PackedStringArray = []
var assertions: int = 0
var visited: PackedStringArray = []
var selected: PackedStringArray = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for id: String in NpcContentCatalog.ROSTER:
		for positive: bool in [true, false]: _recipient(id, positive)
	_entry_and_order()
	_non_gift()
	var pair: Dictionary = SocialSaveFixture.setup()
	for row: Dictionary in pair.policy.enable.node: _check(row.id in visited, "approved node exercised " + row.id)
	for row: Dictionary in pair.policy.enable.choice: _check(row.id in selected, "approved choice exercised " + row.id)
	_check(TestRunEvidence.write_json("social-milestone-report.json", {"task":"G004", "proof":"production service/content; synthetic items/events/authoring boundaries", "assertions":assertions+1, "visited":Array(visited), "selected":Array(selected), "failures":Array(failures)}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("G004 social_milestone_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _recipient(id: String, positive: bool) -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	SocialSaveFixture.introduce(pair, id, positive)
	var session: GameSession = pair.session
	var service: NpcDialogueService = pair.service
	_check(session.inventory.add("item-moonflower", 3).is_empty(), "synthetic supply")
	# Close/cancel unselected gift applies nothing, including no event or bag revision.
	if not service.active(): _check(service.begin(id, "fixture-" + id).ok, "open gift")
	var before: Dictionary = SaveCodec.snapshot(session)
	var view: Dictionary = service.snapshot()
	_check(service.close(view.npc_id, view.instance_id, view.node_id, view.token).ok, "close unselected")
	_check(SaveCodec.snapshot(session) == before, "close cannot grant gift")
	_check(service.begin(id, "fixture-" + id).ok, "reopen gift")
	before = SaveCodec.snapshot(session)
	service.cancel()
	_check(SaveCodec.snapshot(session) == before, "cancel cannot grant gift")
	SocialSaveFixture.preference(pair, id)
	var old: Dictionary = SaveCodec.snapshot(session)
	for count: int in [1,2]:
		if not service.active(): _check(service.begin(id, "fixture-" + id).ok, "ordinary resolver open " + id)
		view = service.snapshot()
		var choice_id: String = ""
		for row: Dictionary in view.choices:
			if not pair.catalog.get_npc(id).graph.choices[row.id].gift_rule_id.is_empty(): choice_id = row.id
		_check(not choice_id.is_empty(), "authored gift exposed " + id)
		var notifications: Array[int] = [0]
		var expected_affinity: int = (1 if positive else 0) + count
		var expected_node: String = "npc-01-level-1-milestone" if id == "npc-01" and expected_affinity == 3 else pair.catalog.get_npc(id).graph.choices[choice_id].target_node_id
		var observer: Callable = func() -> void:
			notifications[0] += 1
			var memory: ConversationMemory = session.conversations.memory(id)
			_check(session.inventory.count("item-moonflower") == 3-count and memory.affinity == expected_affinity and service.snapshot().node_id == expected_node, "observer sees full delta/consume/target " + id)
			_check(("relationshipLevel1Seen" in memory.flags) == (id == "npc-01" and expected_affinity == 3), "entry flag atomic before observer " + id)
		service.changed.connect(observer)
		_check(Fixture.choose(service, view, choice_id).ok and notifications[0] == 1, "one accepted notification " + id)
		service.changed.disconnect(observer)
		ConversationMemory._add_unique(selected, choice_id)
		ConversationMemory._add_unique(visited, service.snapshot().node_id)
		var after: Dictionary = SaveCodec.snapshot(session)
		_check(not Fixture.choose(service, view, choice_id).ok and SaveCodec.snapshot(session) == after, "stale token cannot repeat " + id)
		var events: NpcEventMemory = session.conversations.events()
		var gift: Dictionary = events._facts[NpcEventMemory.key(NpcEventMemory.GIFT, "moonflower", id)]
		var choice: Dictionary = events._facts[NpcEventMemory.key(NpcEventMemory.CHOICE, id, choice_id)]
		_check(gift.count == count and gift.last_sequence+1 == choice.last_sequence and gift.last_active_seconds == choice.last_active_seconds, "gift before choice at exact time " + id)
		_check(session.conversations.memory(id).level(3) == (1 if positive and count == 2 else 0), "positive/neutral derived level " + id)
		_check(SaveCodec.validate(after, pair.actors).session != null, "default production save validates " + id)
		service.cancel()
	view = {}
	_check(service.begin(id, "fixture-" + id).ok, "reopen after two gifts")
	_check(service.snapshot().node_id != "npc-01-level-1-milestone", "milestone not replayed on reopen")
	view = service.snapshot()
	before = SaveCodec.snapshot(session)
	for row: Dictionary in view.choices:
		if not pair.catalog.get_npc(id).graph.choices[row.id].gift_rule_id.is_empty():
			_check(not row.available and row.reason == "Gift acceptance cap reached." and not Fixture.choose(service, view, row.id).ok, "shared cap after reopen " + id)
	_check(SaveCodec.snapshot(session) == before, "cap preserves all durable state")
	service.cancel()
	var restored: SaveCodec.DecodeResult = SaveCodec.validate(SaveCodec.snapshot(session), pair.actors)
	_check(restored.session != null, "restorable production social history")
	if restored.session != null:
		_check(service.initialize(pair.catalog, restored.session).is_empty() and service.begin(id, "restored-" + id).ok, "load/reopen service")
		_check(service.snapshot().node_id != "npc-01-level-1-milestone", "saved receipt prevents replay")
		service.cancel()
	var now: Dictionary = SaveCodec.snapshot(session)
	now.inventory = old.inventory; now.conversations = old.conversations
	_check(now == old, "quest/trust/environment/old fields independent " + id)
	for other: String in NpcContentCatalog.ROSTER:
		if other != id: _check(session.conversations.memory(other).snapshot(3) == old.conversations.people[other], "other person independent " + id)

func _entry_and_order() -> void:
	var pair: Dictionary = SocialSaveFixture.setup()
	SocialSaveFixture.introduce(pair, "npc-01")
	SocialSaveFixture.preference(pair, "npc-01")
	pair.session.inventory.add("item-moonflower", 2)
	SocialSaveFixture.gift(pair, "npc-01")
	var choice: Dictionary = pair.catalog._packages["npc-01"].dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-01-follow-up-conversation")[0].choices[0]
	choice.endsConversation = true # synthetic ends precedence variant
	SocialSaveFixture.gift(pair, "npc-01")
	_check(pair.session.conversations.memory("npc-01").affinity == 3 and "relationshipLevel1Seen" not in pair.session.conversations.memory("npc-01").flags, "ends precedes milestone entry")
	_check(pair.service.begin("npc-01", "later-entry").ok and pair.service.snapshot().node_id == "npc-01-level-1-milestone", "normal resolution enters delayed milestone")
	_check("relationshipLevel1Seen" in pair.session.conversations.memory("npc-01").flags, "normal entry records seen flag")
	pair.service.cancel()
	var memory: ConversationMemory = pair.session.conversations.memory("npc-01")
	memory.affinity = 2 # synthetic decline/re-cross, flag must still suppress replay
	pair.session.conversations = pair.session.conversations.with_person(memory)
	var npc: NpcDefinition = pair.catalog.get_npc("npc-01")
	var gift_choice: NpcDialogueGraph.Choice = npc.graph.choices["npc-01-gift-moonflower-follow-up"]
	gift_choice.ends_conversation = false
	var after: ConversationMemory = memory.detached_copy(); after.affinity = 3
	_check(NpcDialogueRules.transition(npc, gift_choice, memory, after).node.id == "npc-01-gift-response", "decline/re-cross seen flag prevents replay")
	# Linked Continue entry follows same flag owner without another social reward.
	memory.flags.erase("relationshipLevel1Seen")
	pair.session.conversations = pair.session.conversations.with_person(memory)
	_check(pair.service.begin("npc-01", "continue-entry").ok, "begin below level for continue variant")
	pair.catalog._packages["npc-01"].dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-01-follow-up-conversation")[0]["continueTargetId"] = npc.milestone_node_id
	var view: Dictionary = pair.service.snapshot()
	_check(pair.service.advance(view.npc_id, view.instance_id, view.node_id, view.token).ok and "relationshipLevel1Seen" in pair.session.conversations.memory("npc-01").flags, "linked entry records flag")
	pair.service.cancel()

func _non_gift() -> void:
	# Synthetic threshold prestate exercises ordinary response path and atomic rejection.
	for ends: bool in [false, true]:
		var pair: Dictionary = SocialSaveFixture.setup()
		var memory: ConversationMemory = pair.session.conversations.memory("npc-01"); memory.affinity = 2
		pair.session.conversations = pair.session.conversations.with_person(memory)
		var definition: Dictionary = pair.catalog._packages["npc-01"].dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-01-initial-conversation")[0].choices[0]
		definition.endsConversation = ends
		_check(pair.service.begin("npc-01", "non-gift").ok, "non-gift below threshold")
		var view: Dictionary = pair.service.snapshot()
		if not ends:
			pair.catalog._packages["npc-01"].coverage.node["npc-01-level-1-milestone"].status = "deferred"
			var before: Dictionary = SaveCodec.snapshot(pair.session)
			_check(not Fixture.choose(pair.service, view, definition.id).ok and SaveCodec.snapshot(pair.session) == before and pair.service.snapshot() == view, "invalid ordinary milestone rejects entire response")
			pair.catalog._packages["npc-01"].coverage.node["npc-01-level-1-milestone"].status = "enabled"
		_check(Fixture.choose(pair.service, view, definition.id).ok, "ordinary response crossing accepted")
		_check(pair.session.conversations.memory("npc-01").affinity == 3 and pair.session.inventory.count("item-moonflower") == 0 and pair.session.conversations.events().count(NpcEventMemory.GIFT, "moonflower", "npc-01") == 0, "ordinary response cannot create gift")
		_check(not pair.service.active() if ends else pair.service.snapshot().node_id == "npc-01-level-1-milestone", "ordinary response source routing")
		_check(("relationshipLevel1Seen" in pair.session.conversations.memory("npc-01").flags) == not ends, "ordinary response entry flag/ends precedence")
		pair.service.cancel()

func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
