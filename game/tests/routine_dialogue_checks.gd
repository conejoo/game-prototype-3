extends "res://tests/support/routine_dialogue_fixture.gd"

func _run() -> void:
	if await setup(810,"prototype-mayor-vale-home"):
		reset_archive()
		_entries_and_policy()
		_stale()
		_chat()
		_gift()
		await _group()
	await finish("routine-dialogue.json")

func _chat() -> void:
	reset_archive()
	if not begin("npc-02"): return
	var view: Dictionary = game.dialogue.snapshot()
	var lease: RoutineDialogueContext = execution._lease
	var actor: Dictionary = execution.actor("npc-02").snapshot()
	check(view.routine_chat,"routine entry exposes ordinary Chat")
	for field: String in ["npc_id","instance_id","node_id","token"]:
		var wrong: Dictionary = view.duplicate(true); wrong[field] = "wrong"
		check(not game.dialogue.ordinary_chat(wrong.npc_id,wrong.instance_id,wrong.node_id,wrong.token).ok,"foreign chat field inert "+field)
	check(game.dialogue.ordinary_chat(view.npc_id,view.instance_id,view.node_id,view.token).ok,"ordinary Chat from actual indexing")
	check(game.dialogue.snapshot().node_id == "npc-02-initial-conversation" and not game.dialogue.snapshot().routine_chat,"ordinary introduction available at zero affinity during routine")
	check(execution._lease == lease and lease.valid() and execution.actor("npc-02").snapshot() == actor,"Chat keeps same group lease/step/feet/timer")
	var before: Dictionary = SaveCodec.snapshot(game.session)
	check(not game.dialogue.ordinary_chat(view.npc_id,view.instance_id,view.node_id,view.token).ok and SaveCodec.snapshot(game.session) == before,"stale Chat cannot repeat disclosure")
	game.dialogue.cancel()
	check(execution._lease == null,"ordinary Chat closes/resumes original routine")

func _entries_and_policy() -> void:
	check(begin("npc-02"),"open archive indexing")
	check(game.dialogue.snapshot().node_id == "npc-02-routine-archive-indexing","step entry wins")
	check("npc-02-archive-practice" not in game.session.conversations.memory("npc-02").learned_fact_ids,"index does not invent practice fact")
	game.dialogue.cancel()
	var package: Dictionary = game.npc_catalog._packages["npc-02"]
	var node: Dictionary = package.dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-02-routine-archive-indexing")[0]
	node.conditions = {"minimumAffinity":1}
	check(begin("npc-02"),"ineligible step falls through")
	check(game.dialogue.snapshot().node_id == "npc-02-routine-archive-default","routine default selected after gated step")
	check("npc-02-archive-practice" in game.session.conversations.memory("npc-02").learned_fact_ids,"actual default entry discloses public practice")
	game.dialogue.cancel()
	var default_node: Dictionary = package.dialogue.nodes.filter(func(n: Dictionary) -> bool: return n.id == "npc-02-routine-archive-default")[0]
	default_node.conditions = {"minimumAffinity":1}
	check(begin("npc-02"),"both preferred entries gated")
	check(game.dialogue.snapshot().node_id == "npc-02-initial-conversation","ordinary fallthrough at zero affinity")
	game.dialogue.cancel(); node.erase("conditions"); default_node.erase("conditions")
	var cursor: RoutineExecutor = execution.actor("npc-02")
	var original: RoutineDefinition = cursor.routine
	var data: Dictionary = original.snapshot(); data.interactionPolicy.allowDialogue = false
	cursor.routine = RoutineDefinition.new(data)
	var before: Dictionary = SaveCodec.snapshot(game.session)
	var target: PrototypeInteractable = game.world_host.current_location.npc_contacts.targets["npc-02"]
	check(not game.dialogue.begin("npc-02",target.instance_id).ok,"allowDialogue=false refuses before overlay")
	check(execution._lease == null and SaveCodec.snapshot(game.session) == before,"blocked entry no lease/fact/token")
	cursor.routine = original
	check(not game.dialogue.begin("npc-02","wrong-instance").ok and execution._lease == null,"invalid instance cannot mint authority")
	game.dialogue.routine_owner = null
	check(game.dialogue.begin("npc-02","ordinary-fixture").ok,"ordinary service remains available")
	check(not game.dialogue.snapshot().node_id.begins_with("npc-02-routine-"),"routine nodes never ordinary priority fallback")
	game.dialogue.cancel(); bind_dialogue()

func _stale() -> void:
	reset_archive()
	if not begin("npc-02"): return
	var view: Dictionary = game.dialogue.snapshot()
	var context: RoutineDialogueContext = game.dialogue._routine_context
	for field: String in ["npc_id","instance_id","node_id","token"]:
		var wrong: Dictionary = view.duplicate(true); wrong[field] = "foreign"
		var before: Dictionary = SaveCodec.snapshot(game.session)
		check(not choose("npc-02-review-archive-ledger-choice",wrong).ok and SaveCodec.snapshot(game.session) == before,"foreign "+field+" inert")
	var cursor: RoutineExecutor = execution.actor("npc-02")
	cursor.index = 3
	var before: Dictionary = SaveCodec.snapshot(game.session)
	check(not context.valid() and not choose("npc-02-review-archive-ledger-choice",view).ok,"changed step invalidates token")
	check(SaveCodec.snapshot(game.session) == before,"stale context has no half effect")
	game.dialogue.cancel()
	check(not context.valid() and not context.stage("npc-02-resume-archive-indexing").ok,"closed context never regains authority")
	reset_archive()
	check(begin("npc-02"),"fresh valid context")
	check(not context.valid(),"new lease cannot resurrect old context")
	game.dialogue.cancel()

func _gift() -> void:
	reset_archive()
	var cursor: RoutineExecutor = execution.actor("npc-02")
	# Labeled no-preferred-entry routine fixture lets real public gift node use lease.
	var data: Dictionary = cursor.routine.snapshot()
	data.interactionPolicy.defaultDialogueEntryNodeId = null; data.interactionPolicy.stepDialogueEntries = []
	cursor.routine = RoutineDefinition.new(data)
	var memory: ConversationMemory = game.session.conversations.memory("npc-02")
	memory.flags = ["npc-02-first-conversation-complete"]
	memory.learned_fact_ids = ["npc-02-moonflower-pressing"]
	game.session.conversations = game.session.conversations.with_person(memory)
	check(game.session.inventory.add("item-moonflower",1).is_empty(),"synthetic owned gift item")
	if not begin("npc-02"): return
	var view: Dictionary = game.dialogue.snapshot()
	var calls: Array[int] = [0]
	var observer: Callable = func() -> void:
		calls[0] += 1
		check(game.session.inventory.count("item-moonflower") == 0 and game.session.conversations.memory("npc-02").affinity == 1,"observer sees gift bag/affinity together")
		check(execution._lease != null,"gift holds routine group through response")
		check(not choose("npc-02-gift-moonflower-follow-up",view).ok,"gift reentrant command inert")
		game.dialogue.cancel(); check(game.dialogue.active(),"reentrant cancellation inert")
	game.dialogue.changed.connect(observer)
	check(choose("npc-02-gift-moonflower-follow-up").ok,"real gift accepted inside lease")
	game.dialogue.changed.disconnect(observer)
	check(calls[0] == 1,"one complete gift publication")
	check(not choose("npc-02-gift-moonflower-follow-up",view).ok,"gift token replay inert")
	game.dialogue.cancel()

func _group() -> void:
	game.dialogue.cancel(); execution.dispose(); game.queue_free(); await process_frame
	if not await setup(0,"prototype-mayor-vale-home"): return
	check(execution.actor("npc-01").routine.id == "vale-overnight-home" and execution.actor("npc-02").routine.id == "vale-overnight-home","synthetic fresh overnight group")
	# Labeled moving-night-group fixture: lease must defer lane setup/cancellation too.
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	execution.actor("npc-01").index = 0; execution.actor("npc-01").state = RoutineExecutor.State.READY
	execution.actor("npc-02").index = 0; execution.actor("npc-02").state = RoutineExecutor.State.MOVING; execution.actor("npc-02").phase = "target"
	execution._night_lane.clear()
	check(adapter.move_to("npc-02",execution.world.anchor(RoutineExecutionWorld.HOME,"helena-archive-desk").foot),"real loaded moving fixture before group lease")
	var path: PackedVector3Array = adapter.movers["npc-02"]._path.duplicate()
	if not begin("npc-02"): return
	check(execution._lease._targets.size() == 2,"both actual loaded group contacts leased")
	var edric: RoutineExecutor = execution.actor("npc-01")
	var helena: RoutineExecutor = execution.actor("npc-02")
	var before: Dictionary = execution.snapshot()
	game.session.advance(260) # Cross morning/window and authoritative 10AM day rollover.
	for index: int in 20:
		execution.tick(.1); game.world_host.current_location.npc_contacts._physics_process(.1)
		await physics_frame
	check(execution.actor("npc-01") == edric and execution.actor("npc-02") == helena,"leased group refuses reassignment across day/window")
	check(edric.snapshot() == before.actors["npc-01"] and helena.snapshot() == before.actors["npc-02"],"both loaded group feet/steps/timers held")
	check(execution._night_lane.is_empty() and adapter.movers["npc-02"].state == RoutineMovement.State.MOVING and adapter.movers["npc-02"]._path == path,"leased moving night group cannot prepare lane/cancel physical leg")
	check(game.session.environment.day_index == 1,"sole clock advances through dialogue day boundary")
	check(execution.actor("npc-14") != null and execution.actor("npc-14").assignment_day == 1,"independent unleased actor still receives latest day assignment")
	var count: int = execution.reconciliations
	game.dialogue.cancel()
	check(execution.reconciliations == count+1 and execution._lease == null,"cancel resumes/reconciles exactly once")
	game.dialogue.cancel(); check(execution.reconciliations == count+1,"duplicate closure inert")
	check(execution.actor("npc-01").routine.id == "vale-morning-work","closure uses latest clock conditions")
	check(execution.actor("npc-01").snapshot().foot == before.actors["npc-01"].foot and execution.actor("npc-02").snapshot().foot == before.actors["npc-02"].foot,"closure reassigns from both actual held feet without relocation")
	observations.append({"case":"group lease boundary","before":before,"after":execution.snapshot(),"reconciliations":execution.reconciliations})
