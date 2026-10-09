extends "res://tests/support/routine_execution_fixture.gd"

func _run() -> void:
	if await setup(600): await _test()
	await finish("executor.json")

func _test() -> void:
	var before: Dictionary = SaveCodec.snapshot(game.session)
	var actor: RoutineExecutor = execution.actor("npc-01")
	var revision: int = execution.revisions
	for repeat: int in range(20): await step()
	check(execution.actor("npc-01") == actor and execution.revisions == revision,"unchanged assignment does not restart cursor")
	var stable: Dictionary = execution.snapshot()
	for repeat: int in range(20): execution.tick(.1,true)
	check(execution.snapshot() == stable,"holds freeze all cursor/timer/assignment state")
	var partial: RoutineAssignmentPlan = RoutineAssignmentPlan.new(0,1320,{"npc-01":"vale-overnight-home"},{},{})
	check(not execution.apply_plan(partial) and execution.snapshot() == stable,"split group rejected atomically")
	# Real reassignment retains real feet, even when elapsed clock window is old.
	var room: PrototypeLocation = game.world_host.current_location
	var adapter: NpcWorldAdapter = room.npc_contacts
	var current: Vector3 = adapter.targets["npc-01"].global_position
	var plan: RoutineAssignmentPlan = RoutineAssignmentPlan.new(0,800,{"npc-01":"edric-afternoon-rounds"},{"npc-01":200},{})
	check(execution.apply_plan(plan),"valid whole assignment")
	check(execution.actor("npc-01").foot == current and adapter.targets["npc-01"].global_position == current,"same-map reassignment begins at actual feet")
	var sparse_revision: int = execution.revisions
	for repeat: int in range(20): check(execution.apply_plan(plan),"unchanged sparse plan accepted")
	check(execution.revisions == sparse_revision,"unassigned-to-unassigned actors cannot create per-frame revisions")
	var dt_before: Dictionary = SaveCodec.snapshot(game.session)
	execution.tick(1e100)
	check(SaveCodec.snapshot(game.session) == dt_before,"huge delta cannot mutate clock/durable/rewards")
	check(SaveCodec.snapshot(game.session) == before,"execution adds no events/items/facts/save cursors")
	check(game.party.members().size() == 2,"NPCs do not join combat party")
	# Timers are finite active deltas; cursor types expose IDs/enums, never private text.
	var definitions: RoutineContentCatalog = RoutineContentCatalog.new()
	check(definitions.initialize_path(game.npc_catalog).is_empty(),"typed immutable definitions")
	var kinds: PackedInt32Array = []
	for routine_id: String in definitions.routine_ids():
		var definition: RoutineDefinition = definitions.get_routine(routine_id)
		for id: String in definition.participants:
			for authored: RoutineDefinition.Step in definition.steps(id):
				if authored.kind not in kinds: kinds.append(authored.kind)
	check(kinds.size() == 4,"all move/wait/action/speech contracts authored")
	for definition_id: String in ["edric-evening-fishing","helena-afternoon-archive","vale-breakfast"]:
		var definition: RoutineDefinition = definitions.get_routine(definition_id)
		var id: String = definition.participants[0]
		for index: int in range(definition.steps(id).size()):
			var authored: RoutineDefinition.Step = definition.steps(id)[index]
			if authored.kind == RoutineDefinition.StepKind.MOVE: continue
			var cursor: RoutineExecutor = RoutineExecutor.new()
			check(cursor.initialize(definition,id,execution.world.origin(definition_id,id)),"timer cursor initialize")
			cursor.index = index
			execution._tick_actor(cursor,.1)
			check(absf(cursor.remaining-(authored.duration_seconds-.1)) < .000001,"finite active timer "+authored.id)
			check(cursor.state == [RoutineExecutor.State.READY,RoutineExecutor.State.WAITING,RoutineExecutor.State.ACTING,RoutineExecutor.State.SPEAKING][authored.kind],"typed timer state "+authored.id)
			check(not cursor.snapshot().has("text") and not cursor.snapshot().has("action_id"),"diagnostic IDs/enums exclude authored/private text")
			cursor.remaining = .05
			execution._tick_actor(cursor,.1)
			check(cursor.index == index+1,"timer expiry advances once "+authored.id)
	observations.append({"unchanged_revision":revision,"real_reassignment_foot":str(current),"all_step_kinds":Array(kinds),"snapshot":execution.snapshot()})
