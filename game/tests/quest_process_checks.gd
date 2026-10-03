extends SceneTree
## Separate writer/reader processes. Guardian and direct commands are TEST SETUP.

var failures: PackedStringArray = []
const QUEST: String = "prototype-maris-recovery"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var writer: bool = "--phase=write" in OS.get_cmdline_user_args()
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	game.save_repository = SaveRepository.new("user://saves/p007-process.json")
	root.add_child(game)
	await game.world_host.transition_finished
	var definition: QuestDefinition = game.catalog.get_quest(QUEST)
	if writer:
		var lead: QuestStep = definition.steps[0]
		_check(game.quests.apply(QUEST, lead.action_id, lead.location_id, lead.source_id).ok, "Writer lead failed")
		game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
		await game.world_host.transition_finished
		# P008 requires physical defeat state and quest fact to agree at save boundary.
		# Direct damage is TEST SETUP, never normal-combat acceptance evidence.
		_check(game.guardian.receive_damage(100), "Writer synthetic guardian damage failed")
		var step: QuestStep = definition.steps[3]
		_check(game.quests.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Writer synthetic vessel failed")
		game._set_paused(true)
		failures.append_array(game.save_run())
	else:
		_check(game.session.completed_effect_ids.is_empty(), "Reader inherited in-memory quest")
		game._set_paused(true)
		failures.append_array(await game.load_run())
		_check(game.session.current_location_id == "prototype-tollworks" and game.session.completed_effect_ids.size() == 4, "Restart lost vessel/expedition facts")
		var vessel: QuestStep = definition.steps[3]
		_check(game.quests.apply(QUEST, vessel.action_id, vessel.location_id, vessel.source_id).ok and game.session.completed_effect_ids.size() == 4, "Restart vessel retry duplicated effect")
		game._set_paused(false)
		game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks")
		await game.world_host.transition_finished
		var reconnect: QuestStep = definition.steps[5]
		_check(game.quests.apply(QUEST, reconnect.action_id, reconnect.location_id, reconnect.source_id).ok, "Reader reconnection failed")
		_check(game.session.completed_effect_ids.size() == 6, "Reader completed sequence lost effects")
	print("P007 process %s: pid=%d; path=%s; steps=%s; effects=%s" % ["write" if writer else "read", OS.get_process_id(), ProjectSettings.globalize_path(game.save_repository.path), game.session.quests[QUEST].completed_step_ids, game.session.completed_effect_ids])
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P007 process %s: PASS" % ["write" if writer else "read"])
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
