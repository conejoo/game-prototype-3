extends SceneTree
## N003 synthetic rule evidence. No ordinary route/UI/save/asset claim.
var failures: Array[String] = []
var assertions: int = 0
var actors: ContentCatalog = ContentCatalog.new()
var catalog: NpcContentCatalog = NpcContentCatalog.new()
var visited: Dictionary[String, bool] = {}
var accepted: Dictionary[String, bool] = {}
var rejected: Array[String] = []
const INITIAL: PackedStringArray = ["npc-01-initial-conversation", "npc-02-initial-conversation", "npc-03-introduction", "npc-04-introduction", "npc-06-introduction", "npc-07-introduction", "npc-08-introduction", "npc-14-introduction"]
const RETURN: PackedStringArray = ["npc-01-follow-up-conversation", "npc-02-follow-up-conversation", "npc-03-return", "npc-04-return", "npc-06-return", "npc-07-return", "npc-08-return", "npc-14-return"]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_check(actors.initialize(load("res://content/prototype_catalog.tres") as ContentManifest).is_empty(), "Core initialized")
	_check(catalog.initialize_path(actors).is_empty(), "Pinned eight-person content initialized")
	_all_people()
	_event_gates()
	_pure_conditions()
	_fixtures()
	_isolation_and_atomicity()
	await _root_binding()
	var enabled_nodes: int = 0
	var enabled_choices: int = 0
	for id: String in catalog.npc_ids():
		var npc: NpcDefinition = catalog.get_npc(id)
		for node: NpcDialogueGraph.NodeDefinition in npc.graph.nodes.values():
			if node.availability.is_enabled():
				enabled_nodes += 1
				_check(visited.has(node.id), "Enabled node exercised " + node.id)
		for choice: NpcDialogueGraph.Choice in npc.graph.choices.values():
			if choice.availability.is_enabled():
				enabled_choices += 1
				_check(accepted.has(choice.id), "Enabled choice exercised " + choice.id)
	_check(enabled_nodes == 58 and enabled_choices == 38, "Exact enabled coverage")
	_check(TestRunEvidence.write_json("npc-dialogue-rules.json", {"assertions": assertions, "failures": failures, "visited_nodes": visited.keys(), "accepted_choices": accepted.keys(), "rejected_commands": rejected, "evidence_kind": "synthetic-rule"}), "Evidence written")
	for message: String in failures: push_error(message)
	if failures.is_empty(): print("N003 rules: PASS assertions=", assertions, " nodes=", visited.size(), " choices=", accepted.size())
	quit(0 if failures.is_empty() else 1)

func _new_service(content: NpcContentCatalog = null) -> Dictionary:
	var session: GameSession = GameSession.new()
	_check(session.initialize(actors, "prototype-alderwake", "alderwake-start", "prototype-hero", null, catalog if content == null else content).is_empty(), "Fresh session")
	var service: NpcDialogueService = NpcDialogueService.new()
	_check(service.initialize(catalog if content == null else content, session).is_empty(), "Fresh dialogue owner")
	return {"session": session, "service": service}

func _begin(service: NpcDialogueService, id: String, expected: String) -> Dictionary:
	_check(service.begin(id, "contact-" + id).ok, "Begin " + id)
	var view: Dictionary = service.snapshot()
	_check(view.get("node_id", "") == expected, "Source selection " + expected)
	if not view.is_empty(): visited[view.node_id] = true
	return view

func _choose(service: NpcDialogueService, view: Dictionary, id: String, expected: String) -> Dictionary:
	_check(service.choose(view.npc_id, view.instance_id, view.node_id, view.token, id).ok, "Choice " + id)
	accepted[id] = true
	var next: Dictionary = service.snapshot()
	_check(next.get("node_id", "") == expected, "Authored target " + expected)
	if not next.is_empty(): visited[next.node_id] = true
	return next

func _close(service: NpcDialogueService) -> void:
	var view: Dictionary = service.snapshot()
	_check(not view.is_empty() and service.close(view.npc_id, view.instance_id, view.node_id, view.token).ok and not service.active(), "Close always exits")

func _reject(service: NpcDialogueService, session: GameSession, view: Dictionary, choice: String, label: String) -> void:
	var before: Dictionary = session.conversations.snapshot()
	var cursor: Dictionary = service.snapshot()
	var notifications: Array[int] = [0]
	var observer: Callable = func() -> void: notifications[0] += 1
	service.changed.connect(observer)
	_check(not service.choose(view.npc_id, view.instance_id, view.node_id, view.token, choice).ok, label + " rejected")
	_check(session.conversations.snapshot() == before and service.snapshot() == cursor and notifications[0] == 0, label + " unchanged state/cursor/observers")
	service.changed.disconnect(observer)
	rejected.append(label)

func _all_people() -> void:
	for index: int in catalog.npc_ids().size():
		var id: String = catalog.npc_ids()[index]
		var npc: NpcDefinition = catalog.get_npc(id)
		var intro: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[INITIAL[index]]
		for alternative: int in 2:
			var pair: Dictionary = _new_service()
			var session: GameSession = pair.session
			var service: NpcDialogueService = pair.service
			var view: Dictionary = _begin(service, id, INITIAL[index])
			_check(session.conversations.memory(id).affinity == 0 and session.conversations.memory(id).learned_fact_ids == intro.revealed_fact_ids, "Entry discloses only authored facts, no reward " + id)
			_reject(service, session, view, "unknown", "unknown " + id)
			var wrong: Dictionary = view.duplicate(true)
			wrong["npc_id"] = "npc-02" if id != "npc-02" else "npc-01"
			_reject(service, session, wrong, intro.choices[0].id, "wrong speaker " + id)
			wrong = view.duplicate(true); wrong["instance_id"] = "foreign-contact"
			_reject(service, session, wrong, intro.choices[0].id, "wrong instance " + id)
			wrong = view.duplicate(true); wrong["node_id"] = RETURN[index]
			_reject(service, session, wrong, intro.choices[0].id, "wrong node " + id)
			var choice: NpcDialogueGraph.Choice = intro.choices[alternative]
			var end: Dictionary = _choose(service, view, choice.id, choice.target_node_id)
			var memory: ConversationMemory = session.conversations.memory(id)
			_check(memory.affinity == (1 if alternative == 0 else 0) and memory.level(3) == 0, "Signed introduction affinity " + id)
			_check(memory.applied_choice_ids == PackedStringArray([choice.id]) and choice.one_time_reward_flag in memory.flags, "Atomic receipt/flag " + id)
			_check(int(session.conversations.events().count(NpcEventMemory.CHOICE, id, choice.id)) == 1, "One accepted event " + id)
			_reject(service, session, view, choice.id, "stale repeated choice " + id)
			_reject(service, session, view, intro.choices[1-alternative].id, "opposite introduction " + id)
			_check(service.advance(end.npc_id, end.instance_id, end.node_id, end.token).ok and not service.active(), "Terminal exits " + id)
			var returning: Dictionary = _begin(service, id, RETURN[index])
			_reject(service, session, returning, intro.choices[1-alternative].id, "intro cannot replay on revisit " + id)
			for optional: NpcDialogueGraph.Choice in npc.graph.nodes[RETURN[index]].choices:
				if not optional.availability.is_enabled():
					_reject(service, session, returning, optional.id, "deferred " + optional.id)
					var found: bool = false
					for row: Dictionary in returning.choices:
						if row.id == optional.id: found = not row.available and not row.reason.is_empty()
					_check(found, "Deferred honest capability reason " + optional.id)
			if alternative == 0:
				for branch: NpcDialogueGraph.Choice in npc.graph.nodes[RETURN[index]].choices:
					if not branch.availability.is_enabled(): continue
					var response: Dictionary = _choose(service, returning, branch.id, branch.target_node_id)
					for fact: String in npc.graph.nodes[branch.target_node_id].revealed_fact_ids:
						_check(fact in session.conversations.memory(id).learned_fact_ids, "Authored branch fact " + fact)
					_check(service.advance(response.npc_id, response.instance_id, response.node_id, response.token).ok, "Branch exits")
					returning = _begin(service, id, RETURN[index])
			if index < 2:
				_check(returning.can_continue and returning.can_close, "Optional-only choices valid exit")
				_check(service.advance(returning.npc_id, returning.instance_id, returning.node_id, returning.token).ok and not service.active(), "Unavailable choices advance to exit")
			else: _close(service)
			_check(session.relationship.trust == 0 and session.completed_effect_ids.is_empty() and session.progression.upgrade_ids.is_empty(), "No quest/trust/upgrade authority overlap " + id)
		# Close without selecting any response retains entry facts but no rewards.
		var cancelled: Dictionary = _new_service()
		_begin(cancelled.service, id, INITIAL[index])
		var before: Dictionary = cancelled.session.conversations.snapshot()
		cancelled.service.cancel()
		_check(cancelled.session.conversations.snapshot() == before and not cancelled.service.active(), "Cancel no unselected effects " + id)

func _event_gates() -> void:
	var pair: Dictionary = _new_service()
	var service: NpcDialogueService = pair.service
	var session: GameSession = pair.session
	var view: Dictionary = _begin(service, "npc-01", INITIAL[0])
	_choose(service, view, "npc-01-helpful-response", "npc-01-initial-helpful-end")
	_close(service)
	_check(service.record_event(NpcEventMemory.AREA, "woods", null).ok, "Real-key woods fixture event")
	_begin(service, "npc-01", "npc-01-woods-first"); _close(service)
	_begin(service, "npc-01", RETURN[0]); _close(service)
	_check(service.record_event(NpcEventMemory.AREA, "woods", null).ok, "Second woods fixture event")
	_begin(service, "npc-01", "npc-01-woods-repeat"); _close(service)
	_check(service.record_event(NpcEventMemory.GATHER, "moonflower", null).ok, "Gather fixture event")
	view = _begin(service, "npc-01", "npc-01-moonflower-hint")
	_check(session.conversations.memory("npc-01").learned_fact_ids == PackedStringArray(["npc-01-moonflower-preference"]), "Edric only disclosed fact; no role/fishing inferred")
	_reject(service, session, view, "npc-01-gift-moonflower-from-hint", "Edric optional gift")
	_close(service)
	_begin(service, "npc-01", RETURN[0]); _close(service)
	view = _begin(service, "npc-02", INITIAL[1])
	_choose(service, view, "npc-02-careful-research-response", "npc-02-initial-careful-end"); _close(service)
	view = _begin(service, "npc-02", "npc-02-moonflower-hint")
	_check("npc-02-moonflower-pressing" in session.conversations.memory("npc-02").learned_fact_ids and "npc-02-archive-practice" not in session.conversations.memory("npc-02").learned_fact_ids, "Helena public facts only")
	_close(service)
	_begin(service, "npc-02", RETURN[1]); _close(service)
	var before: Dictionary = session.conversations.snapshot()
	for event: Array in [[NpcEventMemory.AREA, "woods", "npc-01"], [NpcEventMemory.GATHER, "unknown", null], ["itemGifted", "moonflower", "npc-01"], [NpcEventMemory.CHOICE, "npc-01", "npc-01-helpful-response"]]:
		_check(not service.record_event(event[0], event[1], event[2]).ok and session.conversations.snapshot() == before, "Unsupported/null mismatch event unchanged")
	_check(session.conversations.events().supported_key_count() == 40, "Fixed allowlist two world keys plus 38 responses")
	_check(session.conversations.events().count(NpcEventMemory.AREA, "woods", null) == 2 and session.conversations.events().count(NpcEventMemory.AREA, "woods", "npc-01") == 0, "Null exact key")
	var rows: Dictionary = session.conversations.events().snapshot()
	_check(rows.last_sequence == 5, "Exactly two introductions, two woods and one gather")
	rows.facts.clear()
	_check(session.conversations.events().snapshot().facts.size() == 4, "Detached event snapshot")

func _pure_conditions() -> void:
	var memory: ConversationMemory = ConversationMemory.new("npc-14")
	var events: NpcEventMemory = NpcEventMemory.new(); events.initialize(catalog)
	var no_bounds: NpcDialogueGraph.Conditions = NpcDialogueGraph.Conditions.new({})
	_check(NpcDialogueRules.matches(no_bounds, memory, events, 0.0, 3), "Source absent condition defaults")
	_check(not NpcDialogueRules.matches(no_bounds, memory, events, NAN, 3), "Nonfinite query fails")
	var guards: Array[Dictionary] = [{"requiredFlags": ["npc-14-introduced"]}, {"requiredFactIds": ["npc-14-quiet-company"]}, {"requiredSeenNodeIds": ["npc-14-quiet"]}, {"minimumAffinity": 1}, {"minimumRelationshipLevel": 1}]
	for guard: Dictionary in guards:
		_check(not NpcDialogueRules.matches(NpcDialogueGraph.Conditions.new(guard), memory, events, 0.0, 3), "Required gate " + str(guard))
	memory.flags = ["npc-14-introduced"]; memory.learned_fact_ids = ["npc-14-quiet-company"]; memory.seen_node_ids = ["npc-14-quiet"]; memory.affinity = 3
	for guard: Dictionary in guards:
		_check(NpcDialogueRules.matches(NpcDialogueGraph.Conditions.new(guard), memory, events, 0.0, 3), "Satisfied gate " + str(guard))
	for guard: Dictionary in [{"excludedFlags": ["npc-14-introduced"]}, {"unknownFactIds": ["npc-14-quiet-company"]}, {"unseenNodeIds": ["npc-14-quiet"]}, {"maximumAffinity": 2}]:
		_check(not NpcDialogueRules.matches(NpcDialogueGraph.Conditions.new(guard), memory, events, 0.0, 3), "Excluded/max gate " + str(guard))
	var edric: NpcDefinition = catalog.get_npc("npc-01")
	var level_one: ConversationMemory = ConversationMemory.new("npc-01")
	level_one.affinity = 3
	level_one.flags = ["npc-01-first-conversation-complete"]
	_check(NpcDialogueRules.resolve(edric, level_one, events, 0.0).id == "npc-01-follow-up-conversation", "Deferred Edric milestone never injected at level one")
	var helena: ConversationMemory = ConversationMemory.new("npc-02")
	helena.flags = ["npc-02-first-conversation-complete"]
	_check(NpcDialogueRules.resolve(catalog.get_npc("npc-02"), helena, events, 0.0).id == "npc-02-follow-up-conversation", "Deferred Helena routine entries never ordinary fallback")
	var positive: NpcDialogueGraph.Choice = catalog.get_npc("npc-14").graph.choices["npc-14-careful-response"]
	memory.affinity = ConversationMemory.MAX_AFFINITY
	_check(memory.responded(positive).affinity == ConversationMemory.MAX_AFFINITY, "Affinity upper clamp")
	var negative: NpcDialogueGraph.Choice = NpcDialogueGraph.Choice.new({"id": "fixture-negative", "text": "Negative", "affinityDelta": -1}, {"status": "enabled", "reason": ""})
	memory.affinity = 0
	_check(memory.responded(negative).affinity == 0, "Affinity lower clamp")
	memory.affinity = 2
	_check(memory.responded(positive).level(3) == 1 and memory.level(3) == 0, "Threshold derivation detached")
	memory.applied_choice_ids = [positive.id]
	_check(memory.responded(positive).snapshot(3) == memory.snapshot(3), "Receipt suppresses full effect")
	memory.applied_choice_ids = []; memory.flags = [positive.one_time_reward_flag]
	_check(memory.responded(positive).snapshot(3) == memory.snapshot(3), "Reward flag suppresses full effect")
	events = events.record(NpcEventMemory.AREA, "woods", null, 10.0)
	var window: NpcDialogueGraph.EventCondition = NpcDialogueGraph.EventCondition.new({"kind": "areaEntered", "subjectId": "woods", "minimumCount": 1, "maximumCount": 1, "occurredWithinActiveSeconds": 5.0})
	_check(events.matches(window, 15.0) and not events.matches(window, 15.01), "Inclusive latest-event window")
	events = events.record(NpcEventMemory.AREA, "woods", null, 20.0)
	_check(not events.matches(window, 20.0), "Maximum event count")
	window.maximum_count = -1
	_check(events.matches(window, 25.0), "Window uses latest rather than first event")
	for seconds: float in [-1.0, NAN, INF, NpcEventMemory.MAX_ACTIVE_SECONDS + 1.0, 19.0]:
		_check(events.record(NpcEventMemory.AREA, "woods", null, seconds) == null, "Bad/regressive active time")
	events._last_sequence = NpcEventMemory.MAX_SEQUENCE
	_check(events.record(NpcEventMemory.AREA, "woods", null, 20.0) == null, "Sequence exhausted without eviction")

func _fixture(kind: String) -> NpcContentCatalog:
	var document: Dictionary = catalog.document_snapshot()
	var package: Dictionary = document.packages[7]
	for node: Dictionary in package.dialogue.nodes:
		match kind:
			"tie", "priority":
				if node.id in ["npc-14-introduction", "npc-14-return"]:
					node["conditions"] = {}
					node["priority"] = 101 if kind == "priority" and node.id == "npc-14-return" else 100
			"hidden":
				if node.id == "npc-14-introduction": node.choices[0]["conditions"] = {"events": [{"kind": "areaEntered", "subjectId": "woods", "minimumCount": 0, "maximumCount": 0}]}
			"continue":
				if node.id == "npc-14-hosting": node["continueTargetId"] = "npc-14-quiet"
			"ends":
				if node.id == "npc-14-introduction":
					node.choices[0].erase("targetNodeId"); node.choices[0]["endsConversation"] = true
			"defaults":
				if node.id == "npc-14-introduction": node.erase("priority"); node.erase("portraitId")
			"repeat":
				if node.id == "npc-14-introduction": node["conditions"] = {}
	if kind in ["tie", "priority"]: package.dialogue.entryNodeIds.reverse()
	var result: NpcContentCatalog = NpcContentCatalog.new()
	_check(result.initialize_document(document, actors).is_empty(), "Validated deliberate fixture " + kind)
	return result

func _fixtures() -> void:
	for kind: String in ["tie", "priority", "defaults"]:
		var pair: Dictionary = _new_service(_fixture(kind))
		var view: Dictionary = _begin(pair.service, "npc-14", "npc-14-return" if kind == "priority" else "npc-14-introduction")
		if kind == "defaults": _check(view.portrait_id == "official-neutral", "Source default expression")
		_close(pair.service)
	var hidden: Dictionary = _new_service(_fixture("hidden"))
	var view: Dictionary = _begin(hidden.service, "npc-14", "npc-14-introduction")
	_check(hidden.service.record_event(NpcEventMemory.AREA, "woods", null).ok, "Eligibility changed after snapshot")
	_reject(hidden.service, hidden.session, view, "npc-14-careful-response", "Condition reevaluated at command time")
	for row: Dictionary in hidden.service.snapshot().choices: _check(row.id != "npc-14-careful-response", "Condition-hidden response omitted")
	_close(hidden.service)
	var chain: Dictionary = _new_service(_fixture("continue"))
	view = _begin(chain.service, "npc-14", "npc-14-introduction")
	_choose(chain.service, view, "npc-14-careful-response", "npc-14-careful-end"); _close(chain.service)
	view = _begin(chain.service, "npc-14", "npc-14-return")
	view = _choose(chain.service, view, "npc-14-ask-hosting", "npc-14-hosting")
	var count: int = chain.session.conversations.events().snapshot().last_sequence
	_check(chain.service.advance(view.npc_id, view.instance_id, view.node_id, view.token).ok and chain.service.snapshot().node_id == "npc-14-quiet", "Finite Continue reaches authored target")
	_check("npc-14-quiet-company" in chain.session.conversations.memory("npc-14").learned_fact_ids and chain.session.conversations.events().snapshot().last_sequence == count, "Continue discloses no response reward/event")
	_close(chain.service)
	var ends: Dictionary = _new_service(_fixture("ends"))
	view = _begin(ends.service, "npc-14", "npc-14-introduction")
	_choose(ends.service, view, "npc-14-careful-response", "")
	_check(not ends.service.active() and ends.session.conversations.memory("npc-14").affinity == 1, "Explicit ends applies response once and exits")
	var repeats: Dictionary = _new_service(_fixture("repeat"))
	view = _begin(repeats.service, "npc-14", "npc-14-introduction")
	_choose(repeats.service, view, "npc-14-careful-response", "npc-14-careful-end"); _close(repeats.service)
	view = _begin(repeats.service, "npc-14", "npc-14-introduction")
	_reject(repeats.service, repeats.session, view, "npc-14-careful-response", "Current-node consumed receipt")
	_close(repeats.service)
	# A validated graph with no eligible entry returns visibly; no disclosure/reward.
	var empty_content: NpcContentCatalog = _fixture("hidden")
	var empty: Dictionary = _new_service(empty_content)
	var unavailable: ConversationMemory = empty.session.conversations.memory("npc-14")
	unavailable.flags = ["npc-14-introduced"]
	var document: Dictionary = empty_content.document_snapshot()
	document.packages[7].dialogue.entryNodeIds = ["npc-14-introduction"]
	_check(empty_content.initialize_document(document, actors).is_empty(), "Finite graph with unavailable sole entry validated")
	empty.session.conversations = empty.session.conversations.with_person(unavailable)
	var original: Dictionary = empty.session.conversations.snapshot()
	_check(not empty.service.begin("npc-14", "contact").ok and empty.session.conversations.snapshot() == original and not empty.service.active(), "Unavailable entry leaves memory untouched")
	var invalid: NpcDialogueService = NpcDialogueService.new()
	_check(not invalid.begin("npc-14", "instance").ok and not invalid.record_event(NpcEventMemory.AREA, "woods", null).ok, "Unbound service rejected")
	_check(not invalid.initialize(NpcContentCatalog.new(), GameSession.new()).is_empty(), "Invalid content/session rejected")

func _isolation_and_atomicity() -> void:
	var pair: Dictionary = _new_service()
	var other: Dictionary = _new_service()
	var service: NpcDialogueService = pair.service
	var view: Dictionary = _begin(service, "npc-14", "npc-14-introduction")
	var untouched: Dictionary = other.session.conversations.snapshot()
	var notifications: Array[int] = [0]
	service.changed.connect(func() -> void:
		notifications[0] += 1
		var memory: ConversationMemory = pair.session.conversations.memory("npc-14")
		_check(memory.affinity == 1 and "npc-14-introduced" in memory.flags and "npc-14-careful-response" in memory.applied_choice_ids and "npc-14-careful-end" in memory.seen_node_ids and pair.session.conversations.events().count(NpcEventMemory.CHOICE, "npc-14", "npc-14-careful-response") == 1 and service.snapshot().node_id == "npc-14-careful-end", "Observer sees whole accepted transaction/cursor")
	)
	_choose(service, view, "npc-14-careful-response", "npc-14-careful-end")
	_check(notifications[0] == 1 and other.session.conversations.snapshot() == untouched, "Single notification, sessions independent")
	_check(pair.session.conversations.memory("npc-03").affinity == 0 and pair.session.conversations.memory("npc-03").flags.is_empty(), "People independent")
	var detached: ConversationMemory = pair.session.conversations.memory("npc-14")
	detached.flags.clear(); detached.affinity = 99
	var snapshot: Dictionary = service.snapshot(); snapshot.memory.flags.clear(); snapshot.choices.clear()
	_check(pair.session.conversations.memory("npc-14").affinity == 1 and not pair.session.conversations.memory("npc-14").flags.is_empty(), "Detached memory/service snapshots")
	var unknown_before: Dictionary = other.session.conversations.snapshot()
	_check(not other.service.begin("npc-05", "instance").ok and not other.service.begin("npc-14", " ").ok and other.session.conversations.snapshot() == unknown_before, "Unknown/blank begin no mutation")
	# Same-session second owner invalidates first cursor, preventing opposite reward.
	var shared: Dictionary = _new_service()
	var second: NpcDialogueService = NpcDialogueService.new()
	_check(second.initialize(catalog, shared.session).is_empty(), "Second same-session fixture owner")
	var stale: Dictionary = _begin(shared.service, "npc-14", "npc-14-introduction")
	var current: Dictionary = _begin(second, "npc-14", "npc-14-introduction")
	_choose(second, current, "npc-14-careful-response", "npc-14-careful-end")
	_reject(shared.service, shared.session, stale, "npc-14-passing-response", "Foreign publication prevents opposite reward")
	# Saturated event budget rejects entire response with no receipt/reward/target entry.
	var full: Dictionary = _new_service()
	view = _begin(full.service, "npc-14", "npc-14-introduction")
	var budget: NpcEventMemory = full.session.conversations.events(); budget._last_sequence = NpcEventMemory.MAX_SEQUENCE
	full.session.conversations = full.session.conversations.with_events(budget)
	full.service._cursor_state = full.session.conversations # Deliberate malformed/range fixture
	_reject(full.service, full.session, view, "npc-14-careful-response", "Exhausted event budget atomic rejection")
	full.service.cancel(); shared.service.cancel(); second.cancel()

func _root_binding() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	_check(game.session.conversations.initialized and game.npc_dialogue._session == game.session, "Actual root owns ready NPC rules")
	game._set_paused(true)
	_check(game.save_run().is_empty(), "Existing manual stable-boundary current-schema save")
	var saved: Dictionary = SaveCodec.snapshot(game.session)
	_check(SaveCodec.SCHEMA_VERSION == 7 and saved.has("conversations"), "N004 current-schema memory durability")
	var view: Dictionary = _begin(game.npc_dialogue, "npc-14", "npc-14-introduction")
	_choose(game.npc_dialogue, view, "npc-14-careful-response", "npc-14-careful-end")
	game.npc_dialogue.cancel()
	var previous: GameSession = game.session
	_check((await game.load_run()).is_empty(), "Actual root successful manual load")
	_check(game.session != previous and game.npc_dialogue._session == game.session and game.session.conversations.initialized and not game.npc_dialogue.active(), "Restored session rebinds cursor owner")
	_check(game.session.conversations.memory("npc-14").affinity == 0 and previous.conversations.memory("npc-14").affinity == 1, "Loading earlier fresh save restores independent memory without inference")
	game.npc_dialogue.record_event(NpcEventMemory.GATHER, "moonflower", null)
	_check(game.session.conversations.events().count(NpcEventMemory.GATHER, "moonflower", null) == 1 and previous.conversations.events().count(NpcEventMemory.GATHER, "moonflower", null) == 0, "New event commands target restored session")
	game._set_paused(false)
	game.queue_free()
	await process_frame

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
