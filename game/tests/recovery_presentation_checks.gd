extends SceneTree
## Synthetic lifecycle/save fixtures; normal gameplay evidence recorded separately.

const QUEST: String = "prototype-maris-recovery"
const SAVE_PREFIX: String = "user://saves/p011-presentation-"
var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	var phase: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	if phase == "write":
		for count: int in [0, 5, 6]:
			_check(SaveRepository.new(SAVE_PREFIX + str(count) + ".json").write(_candidate(game.catalog, count), game.catalog).is_empty(), "Process fixture save failed")
	elif phase == "read":
		for count: int in [0, 5, 6]:
			game._set_paused(true)
			game.save_repository = SaveRepository.new(SAVE_PREFIX + str(count) + ".json")
			_check((await game.load_run()).is_empty(), "Process restore failed")
			_assert_view(game, "specialist" if count == 6 else ("fitting" if count == 5 else "basic"))
			_check(game.session.completed_effect_ids.size() == count, "Process restore changed effects")
			game._set_paused(false)
	else:
		await _lifecycle(game)
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P011 checks: PASS — stage-derived counter, practical dialogue/cancel/input, once-only reconnection, travel, bidirectional save restore; phase=", phase)
	quit(0 if failures.is_empty() else 1)


func _lifecycle(game: Node3D) -> void:
	_assert_view(game, "basic")
	var basic: ConversationDefinition = game.catalog.get_dialogue("prototype-maris-counter")
	var original_graph: String = basic.graph_json
	var returned: ConversationDefinition = game.catalog.get_dialogue("prototype-maris-fitting")
	_check(returned.prototype_fixture and returned.document().nodes.filter(func(node: Dictionary) -> bool: return node.id.begins_with(returned.stable_id + ":intro-")).size() == 3, "Return scene must be labeled and contain practical steps")
	var bad_catalog: ContentCatalog = ContentCatalog.new()
	var manifest: ContentManifest = ContentManifest.new()
	for definition: ContentDefinition in game.content_manifest.definitions:
		if definition.stable_id != "prototype-maris-specialist":
			manifest.definitions.append(definition)
	bad_catalog.initialize(manifest)
	_check(not _counter(game).validation_errors(bad_catalog).is_empty(), "Missing variant not rejected")
	# Neither lead, guardian clearance nor vessel release should restore shop.
	var service: QuestService = game.quests
	for step: QuestStep in game.catalog.get_quest(QUEST).steps.slice(0, 4):
		_check(service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Fixture prefix failed")
		_assert_view(game, "basic")
	var unrecovered: GameSession = _candidate(game.catalog, 0)
	var path: String = "user://saves/p011-live-%d.json" % OS.get_process_id()
	game.save_repository = SaveRepository.new(path)
	_check(game.save_repository.write(unrecovered, game.catalog).is_empty(), "Unrecovered fixture publication failed")
	_check(service.apply(QUEST, "maris-return-to-town", "prototype-alderwake", "location-arrival").ok, "Return fixture failed")
	_assert_view(game, "fitting")
	game.player_placeholder.global_position = _counter(game).global_position + Vector3(1.5, 0, 0.5)
	await physics_frame
	await physics_frame
	_check(game.interact().ok and game.dialogue.snapshot().get("graph_id", "") == returned.stable_id, "Returned scene not selected")
	_check(not game._choose_dialogue("maris-reconnect-choice").ok, "Completion skipped introduction")
	_check(not game.player_placeholder.controls_enabled and not game.companion_ai.enabled, "Scene did not lock gameplay")
	game._set_paused(true)
	_check(not paused, "Scene stacked pause")
	_check(not game.save_run().is_empty(), "Scene allowed save")
	game._advance_dialogue()
	game._cancel_dialogue()
	_assert_view(game, "fitting")
	_check(game.session.completed_effect_ids.size() == 5 and game.player_placeholder.controls_enabled, "Cancel completed fitting or retained control")
	# Replay starts from beginning; final choice is only available after practice.
	_check(game.interact().ok and game.dialogue.snapshot().get("presentation_index", -1) == 0, "Cancelled scene not replayable")
	game._advance_dialogue()
	game._advance_dialogue()
	_check(game._choose_dialogue("maris-fitting-leave").ok, "Pause choice failed")
	game._cancel_dialogue()
	_assert_view(game, "fitting")
	game.interact()
	game._advance_dialogue()
	game._advance_dialogue()
	_check(game._choose_dialogue("maris-reconnect-choice").ok, "Fitting completion failed")
	_assert_view(game, "specialist")
	_check(game.dialogue.active() and not game.player_placeholder.controls_enabled, "Variant update interrupted response")
	game._cancel_dialogue()
	var count: int = game.session.completed_effect_ids.size()
	_check(service.apply(QUEST, "maris-reconnect", "prototype-alderwake", "npc-03-counter").ok and game.session.completed_effect_ids.size() == count, "Reconnection replay duplicated effects")
	game.interact()
	_check(game.dialogue.snapshot().get("graph_id", "") == "prototype-maris-specialist" and game._choose_dialogue("maris-specialist-inspect").ok, "Restored service preview absent")
	game._cancel_dialogue()
	_check(game.session.completed_effect_ids.size() == count and basic.graph_json == original_graph, "Presentation/preview mutated facts or definition")
	var recovered: GameSession = SaveCodec.validate(SaveCodec.snapshot(game.session), game.catalog).session
	for destination: String in ["prototype-tollworks", "prototype-alderwake"]:
		game.world_host.request_transition(destination, "tollworks-from-alderwake" if destination == "prototype-tollworks" else "alderwake-from-tollworks")
		await game.world_host.transition_finished
	_assert_view(game, "specialist")
	# Load must replace previous presentation in both directions, without arrivals.
	game._set_paused(true)
	_check((await game.load_run()).is_empty(), "Unrecovered load failed")
	_assert_view(game, "basic")
	_check(game.session.completed_effect_ids.is_empty(), "Unrecovered restore replayed arrivals")
	_check(game.save_repository.write(recovered, game.catalog).is_empty(), "Recovered publication failed")
	_check((await game.load_run()).is_empty(), "Recovered load failed")
	_assert_view(game, "specialist")
	_check(game.session.completed_effect_ids.size() == 6, "Recovered restore replayed effects")
	_check(game.save_repository.write(unrecovered, game.catalog).is_empty(), "Second unrecovered publication failed")
	_check((await game.load_run()).is_empty(), "Second unrecovered load failed")
	_assert_view(game, "basic")
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)


func _candidate(catalog: ContentCatalog, count: int) -> GameSession:
	var run: GameSession = GameSession.new()
	run.initialize(catalog, "prototype-alderwake", "alderwake-start", "prototype-hero")
	var service: QuestService = QuestService.new()
	service.initialize(catalog, run)
	for step: QuestStep in catalog.get_quest(QUEST).steps.slice(0, count):
		_check(service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Candidate prefix failed")
	return run


func _counter(game: Node3D) -> MarisCounter:
	return game.world_host.current_location.get_node("MarisCounter") as MarisCounter


func _assert_view(game: Node3D, expected: String) -> void:
	var counter: MarisCounter = _counter(game)
	_check(counter.presentation == expected and counter.instance_id == "npc-03-counter", "Wrong shop variant/identity: " + expected)
	_check(counter.get_node("VisualRoot/BasicSupplies").visible, "Basic supplies disappeared")
	_check(counter.get_node("VisualRoot/SpecialistGear").visible == (expected == "specialist"), "Wrong specialist gear visibility")
	_check(counter.get_node("VisualRoot/FittingGear").visible == (expected == "fitting"), "Wrong fitting gear visibility")
	_check(counter.get_node("Body/BenchCollision").disabled == false, "Variant changed collision")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
