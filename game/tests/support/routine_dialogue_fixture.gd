extends "res://tests/support/routine_execution_fixture.gd"
## R011 synthetic clock/plan/memory inputs; actual root contacts/physics/services.
func bind_dialogue() -> void:
	game.dialogue.routine_owner = execution

func begin(id: String) -> bool:
	bind_dialogue()
	var target: PrototypeInteractable = game.world_host.current_location.npc_contacts.targets.get(id)
	check(target != null,"actual loaded contact "+id)
	if target == null: return false
	var result: NpcDialogueService.Result = game.dialogue.begin(id,target.instance_id)
	check(result.ok,"routine begin "+id+": "+result.message)
	return result.ok

func choose(id: String, view: Dictionary = {}) -> NpcDialogueService.Result:
	if view.is_empty(): view = game.dialogue.snapshot()
	return game.dialogue.choose(view.npc_id,view.instance_id,view.node_id,view.token,id)

func reset_archive() -> void:
	game.dialogue.cancel()
	var memory: ConversationMemory = ConversationMemory.new("npc-02")
	var events: NpcEventMemory = NpcEventMemory.new(); events.initialize(game.npc_catalog)
	game.session.conversations = game.session.conversations.with_person(memory,events)
	game.session.routines = RoutineFacts.new()
	game.session.environment.day_cycle_progress = (810.0-600)/1440
	var plan: RoutineAssignmentPlan = RoutineAssignmentPlan.new(game.session.environment.day_index,810,{"npc-02":"helena-afternoon-archive"},{},{})
	check(execution.apply_plan(plan),"synthetic isolated archive assignment")
	var actor: RoutineExecutor = execution.actor("npc-02")
	actor.index = 2; actor.state = RoutineExecutor.State.ACTING; actor.remaining = 40

func finish(filename: String) -> void:
	if game != null: game.dialogue.cancel()
	check(TestRunEvidence.write_json(filename,{"task":"R011","assertions":assertions,"failures":failures,"observations":observations,"provenance":"synthetic clock/plan/memory/fixture directives; actual root/physics/service transaction; not natural day or native delivery"}),"evidence")
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free()
	await process_frame
	for error: String in failures: push_error(error)
	print("R011 %s %d assertions %d failures" % [filename,assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)
