extends "res://tests/support/routine_dialogue_fixture.gd"

func _run() -> void:
	if await setup(810,"prototype-mayor-vale-home"):
		_earned_save()
		_real_choices()
		_atomic_failures()
		_event_fixtures()
		_boundaries()
	await finish("routine-directives.json")

func _real_choices() -> void:
	for id: String in ["npc-02-resume-archive-indexing-choice","npc-02-review-archive-ledger-choice","npc-02-end-archive-indexing-choice","npc-02-resume-archive-default-choice","npc-02-end-archive-default-choice"]:
		reset_archive()
		var actor: RoutineExecutor = execution.actor("npc-02")
		if id.contains("default"): actor.index = 5
		if not begin("npc-02"): continue
		var context: RoutineDialogueContext = game.dialogue._routine_context
		var view: Dictionary = game.dialogue.snapshot()
		var original_index: int = actor.index
		var original_remaining: float = actor.remaining
		var count: int = execution.reconciliations
		var before_affinity: int = game.session.conversations.memory("npc-02").affinity
		check(choose(id).ok,"real authored choice "+id)
		check(not game.dialogue.active() and not context.valid(),"authored end closes/releases "+id)
		check(execution.reconciliations == count+1,"directive then one reconciliation "+id)
		check(execution.directives[-1].leased and execution.directives[-1].routine == "helena-afternoon-archive","directive applied while bound/leased "+id)
		check(game.session.conversations.events().count(NpcEventMemory.CHOICE,"npc-02",id) == 1,"one real choice event "+id)
		check(game.session.conversations.memory("npc-02").affinity == before_affinity,"routine choice invents no affinity "+id)
		if id.contains("resume"):
			check(execution.actor("npc-02") == actor and actor.index == original_index and actor.remaining == original_remaining,"resume preserves actual cursor/timer")
		elif id.contains("review"):
			check(actor.index == 5 and actor.state == RoutineExecutor.State.READY,"jump reaches declared participant step while leased")
			check("npc-02-archive-lead-shared" in game.session.conversations.memory("npc-02").flags,"real lead flag persists")
			check(id in game.session.conversations.memory("npc-02").applied_choice_ids,"one-time receipt atomic with jump/flag")
			check(execution.actor("npc-02").routine.id == "helena-afternoon-ledger-review","after closure real flag selects priority ledger routine")
		else:
			check(game.session.routines.suppressed("helena-afternoon-archive"),"end suppresses only bound routine for current day")
		var saved: Dictionary = SaveCodec.snapshot(game.session)
		check(not choose(id,view).ok and SaveCodec.snapshot(game.session) == saved,"old token cannot replay reward/directive "+id)
		observations.append({"case":id,"directive":execution.directives[-1],"facts":game.session.routines.snapshot(),"memory":game.session.conversations.memory("npc-02").snapshot(3)})

func _atomic_failures() -> void:
	reset_archive()
	if not begin("npc-02"): return
	var view: Dictionary = game.dialogue.snapshot()
	var actor: RoutineExecutor = execution.actor("npc-02")
	var context: RoutineDialogueContext = game.dialogue._routine_context
	var events: NpcEventMemory = game.session.conversations.events(); events._last_sequence = NpcEventMemory.MAX_SEQUENCE
	game.session.conversations = game.session.conversations.with_events(events); game.dialogue._cursor_state = game.session.conversations
	var before: Dictionary = SaveCodec.snapshot(game.session)
	var cursor: Dictionary = actor.snapshot()
	check(not choose("npc-02-review-archive-ledger-choice").ok,"event exhaustion rejects real jump")
	check(SaveCodec.snapshot(game.session) == before and actor.snapshot() == cursor and context.valid(),"failure has no flag/receipt/jump/partial close")
	game.dialogue.cancel(); reset_archive()
	if not begin("npc-02"): return
	context = game.dialogue._routine_context
	check(not context.stage("npc-01-foreign").ok and not context.stage("npc-02-unknown").ok,"foreign/unknown outcome inert")
	var staged: Dictionary = context.stage("npc-02-review-archive-ledger")
	check(staged.ok,"stage actual jump for negative transaction fixtures")
	before = SaveCodec.snapshot(game.session); cursor = execution.actor("npc-02").snapshot()
	var tampered: Dictionary = staged.duplicate(); tampered.jump_index = 0
	check(not game.session._publish_routine_dialogue(context,tampered,game.session.conversations,game.session.inventory).is_empty(),"tampered jump index cannot publish")
	tampered = staged.duplicate(); tampered.extra_authority = true
	check(not game.session._publish_routine_dialogue(context,tampered,game.session.conversations,game.session.inventory).is_empty(),"foreign staged key cannot publish")
	check(not game.session._publish_routine_dialogue(context,staged,game.session.conversations,InventoryState.new()).is_empty(),"foreign inventory cannot publish")
	check(not GameSession.new()._publish_routine_dialogue(context,staged,game.session.conversations,game.session.inventory).is_empty(),"foreign session cannot publish")
	check(SaveCodec.snapshot(game.session) == before and execution.actor("npc-02").snapshot() == cursor and context.valid(),"malformed transaction preserves all durable/cursor/lease state")
	var original: RoutineDefinition = execution.actor("npc-02").routine
	var data: Dictionary = original.snapshot(); data.id = "helena-evening-archive"
	execution.actor("npc-02").routine = RoutineDefinition.new(data)
	before = SaveCodec.snapshot(game.session)
	check(not choose("npc-02-end-archive-indexing-choice").ok and SaveCodec.snapshot(game.session) == before,"wrong routine context inert")
	execution.actor("npc-02").routine = original; game.dialogue.cancel()
	# One-time ledger receipt cannot be replayed even with a fresh valid lease.
	reset_archive(); if not begin("npc-02"): return
	check(choose("npc-02-review-archive-ledger-choice").ok,"first real ledger receipt")
	execution.actor("npc-02").index = 2
	if not begin("npc-02"): return
	before = SaveCodec.snapshot(game.session)
	check(not choose("npc-02-review-archive-ledger-choice").ok and SaveCodec.snapshot(game.session) == before,"fresh context cannot duplicate one-time flag/event receipt")
	game.dialogue.cancel()

func _event_fixtures() -> void:
	for enabled: bool in [true,false]:
		reset_archive()
		var actor: RoutineExecutor = execution.actor("npc-02")
		var data: Dictionary = actor.routine.snapshot()
		var tag: String = "npc-02-fixture-event-on" if enabled else "npc-02-fixture-event-off"
		data.interactionPolicy.outcomeDirectives.append({"outcomeTag":tag,"directive":{"kind":"activateWorldEvent" if enabled else "deactivateWorldEvent","eventId":"heavy-rain"}})
		actor.routine = RoutineDefinition.new(data)
		if not enabled: check(game.session.apply_routine_command(RoutineFactCommand.set_event(game.session,"heavy-rain",true)).is_empty(),"synthetic authored event precondition")
		var package: Dictionary = game.npc_catalog._packages["npc-02"]
		var node: Dictionary = package.dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-02-routine-archive-indexing")[0]
		var choice: Dictionary = node.choices[0]
		var old: String = choice.outcomeTag; choice.outcomeTag = tag
		if not begin("npc-02"): choice.outcomeTag = old; continue
		var view: Dictionary = game.dialogue.snapshot()
		var forecast: Dictionary = SaveCodec.snapshot(game.session).environment
		var calls: Array[int] = [0]
		var observer: Callable = func() -> void:
			calls[0] += 1
			check(game.session.routines.event_active("heavy-rain") == enabled,"event observer sees complete durable directive")
			check(game.session.conversations.events().count(NpcEventMemory.CHOICE,"npc-02",choice.id) == 1,"event observer sees choice event atomically")
			check(execution._lease != null,"event directive applied before lease release")
			check(not choose(choice.id,view).ok,"reentrant dialogue directive inert")
			check(not game.session.apply_routine_command(RoutineFactCommand.set_event(game.session,"heavy-rain",not enabled)).is_empty(),"reentrant durable command inert")
			check(not game.session.advance(.1).is_empty(),"reentrant clock publication inert")
			game.dialogue.cancel(); check(game.dialogue.active(),"reentrant cancel cannot invalidate atomic publication")
		game.session.routine_facts_changed.connect(observer)
		var count: int = execution.reconciliations
		check(choose(choice.id).ok,"fixture-only event directive accepted "+str(enabled))
		game.session.routine_facts_changed.disconnect(observer)
		check(calls[0] == 1 and execution.reconciliations == count+1,"one event publication then one reconciliation")
		check(SaveCodec.snapshot(game.session).environment == forecast,"event change cannot mutate forecast/light/clock")
		check(execution.directives[-1].leased,"event directive is leased")
		check(not choose(choice.id,view).ok,"event stale token inert")
		choice.outcomeTag = old
		observations.append({"case":"fixture-only event directive","enabled":enabled,"directive":execution.directives[-1],"facts":game.session.routines.snapshot()})

func _boundaries() -> void:
	reset_archive(); if not begin("npc-02"): return
	var context: RoutineDialogueContext = game.dialogue._routine_context
	check(game.session.advance(600).is_empty(),"one full authoritative day through dialogue")
	check(context.valid(),"clock rollover alone cannot invalidate leased step authority")
	check(choose("npc-02-end-archive-indexing-choice").ok,"end uses current day after held rollover")
	check(game.session.environment.day_index == 1 and game.session.routines.suppressed("helena-afternoon-archive"),"suppression applies to publication day")
	check(game.session.advance(200).is_empty() and game.session.routines.suppressed("helena-afternoon-archive"),"suppression survives civil midnight")
	check(game.session.advance(400).is_empty() and not game.session.routines.suppressed("helena-afternoon-archive"),"suppression expires only 10AM day rollover")
	check(game.session.conversations.events().count(NpcEventMemory.CHOICE,"npc-02","npc-02-end-archive-indexing-choice") == 1,"schedule/day crossings replay no directive reward/event")
	var snapshot: Dictionary = SaveCodec.snapshot(game.session)
	var restored: SaveCodec.DecodeResult = SaveCodec.validate(snapshot,game.catalog,game.npc_catalog)
	check(restored.session != null and SaveCodec.snapshot(restored.session) == snapshot,"current schema roundtrip retains all new public routine outcomes")

func _earned_save() -> void:
	# Synthetic placement/items; real authored social and bound routine transactions.
	reset_archive()
	var pair: Dictionary = SocialSaveFixture.setup()
	check(pair.session.inventory.add("item-moonflower",1).is_empty(),"synthetic owned gift item")
	SocialSaveFixture.introduce(pair,"npc-02")
	SocialSaveFixture.preference(pair,"npc-02")
	SocialSaveFixture.gift(pair,"npc-02")
	game.session.conversations = pair.session.conversations
	game.session.inventory = pair.session.inventory
	game.session.elapsed_play_seconds = pair.session.elapsed_play_seconds
	if not begin("npc-02"): return
	check(choose("npc-02-review-archive-ledger-choice").ok,"earned introduction/gift plus actual routine ledger")
	var saved: Dictionary = SaveCodec.snapshot(game.session)
	var restored: SaveCodec.DecodeResult = SaveCodec.validate(saved,game.catalog,game.npc_catalog)
	check(restored.session != null and restored.errors.is_empty(),"independent introduction and ledger receipts restore "+str(restored.errors))
	if restored.session != null:
		check(SaveCodec.snapshot(restored.session) == saved,"earned social/routine facts restore exactly")
	var person: Dictionary = saved.conversations.people["npc-02"]
	check(person.applied_choice_ids.size() == 2 and person.affinity == 2,"introduction plus ledger retain two receipts and one gift reward")
	for field: String in ["applied_choice_ids","flags","affinity"]:
		var bad: Dictionary = saved.duplicate(true)
		if field == "affinity": bad.conversations.people["npc-02"][field] += 1
		else: bad.conversations.people["npc-02"][field].pop_back()
		check(SaveCodec.validate(bad,game.catalog,game.npc_catalog).session == null,"earned save tampered "+field+" rejects")
	# Both mutually exclusive introductions with fully derived rewards/events still fail.
	var bad: Dictionary = saved.duplicate(true)
	var opposite: NpcDialogueGraph.Choice = game.npc_catalog.get_npc("npc-02").graph.choices["npc-02-neighborly-response"]
	var memory: Dictionary = bad.conversations.people["npc-02"]
	memory.applied_choice_ids.append(opposite.id)
	memory.flags.append(opposite.one_time_reward_flag)
	for flag: String in opposite.added_flags:
		if flag not in memory.flags: memory.flags.append(flag)
	if opposite.target_node_id not in memory.seen_node_ids: memory.seen_node_ids.append(opposite.target_node_id)
	memory.affinity += opposite.affinity_delta
	bad.conversations.events.last_sequence += 1
	var sequence: int = bad.conversations.events.last_sequence
	bad.conversations.events.facts.append({"kind":NpcEventMemory.CHOICE,"subject_id":"npc-02","target_id":opposite.id,"count":1,"first_sequence":sequence,"last_sequence":sequence,"first_active_seconds":game.session.elapsed_play_seconds,"last_active_seconds":game.session.elapsed_play_seconds})
	var rejected: SaveCodec.DecodeResult = SaveCodec.validate(bad,game.catalog,game.npc_catalog)
	check(rejected.session == null and "opposite introduction receipts" in str(rejected.errors),"derived opposite introductions remain explicitly rejected")
	observations.append({"case":"R015 earned introduction/gift/ledger save regression","snapshot":saved,"opposite_errors":rejected.errors,"provenance":"synthetic placement/items, production authored social/routine transactions; no ordinary-day claim"})