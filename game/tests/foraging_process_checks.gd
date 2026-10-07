extends SceneTree
## Independent writer/reader; binary oracle preserves exact all-field numeric facts.
var failures: PackedStringArray = []
var cases: Array[Dictionary] = []
var assertions: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var writer: bool = "--phase=write" in OS.get_cmdline_user_args()
	var orphan_catalog: ContentCatalog = ContentCatalog.new()
	orphan_catalog.initialize(load("res://content/prototype_catalog.tres"))
	var orphan_owner: GameSession = GameSession.new()
	orphan_owner.initialize(orphan_catalog,ForagingRegistry.LOCATION,"alderwake-start","prototype-hero")
	var orphan: ForagingState = orphan_owner.foraging
	orphan_owner = null
	_check(not orphan.restore_facts({"item_counts":{},"active_item_id":null}, [], []).is_empty(), "orphan hydration fails closed")
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	_check(game.session.inventory.snapshot().to_dictionary() == {"item_counts":{},"active_item_id":null} and game.session.foraging.snapshot().collected_resource_ids.is_empty(), "fresh process empty")
	for kind: String in ["bag", "alderwake", "tollworks", "authored"]:
		game.save_repository = SaveRepository.new("user://saves/f004-process-%s.json" % kind)
		var oracle_path: String = game.save_repository.path + ".oracle"
		if writer:
			var candidate: GameSession = ForagingSaveFixture.make(game.catalog,kind)
			_check(game.save_repository.write(candidate,game.catalog).is_empty(), "writer publish fixture " + kind)
			_check((await game.load_run()).is_empty(), "writer physical load " + kind)
			var expected: Dictionary = SaveCodec.snapshot(candidate)
			_check(SaveCodec.snapshot(game.session) == expected, "writer exact physical candidate " + kind)
			var oracle: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
			oracle.store_var({"pid":OS.get_process_id(),"expected":expected})
			oracle.close()
			_check(game.save_run().is_empty(), "stable paused writer save " + kind)
		else:
			var oracle: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
			_check(oracle != null,"reader oracle " + kind)
			if oracle == null: break
			var expected: Dictionary = oracle.get_var(false)
			oracle.close()
			_check(expected.pid != OS.get_process_id(), "distinct OS process " + kind)
			var old: GameSession = game.session
			_check((await game.load_run()).is_empty(), "reader physical load " + kind)
			_check(game.session != old and SaveCodec.snapshot(game.session) == expected.expected, "exact all-field restart oracle " + kind)
			_check(old.foraging.get_signal_connection_list("committed").is_empty(), "old session has no scene listener " + kind)
		_check(game.world_host.session == game.session and game.quests.session == game.session and game.relationships.session == game.session and game.progression.session == game.session, "service rebinding " + kind)
		_check(game.player_placeholder.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID] and game.companion.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID], "actor rebinding " + kind)
		_check(game.session.foraging.revision() == 0 and game.session.foraging.rod_count() == 1, "fresh transient revision/conservation " + kind)
		_check(game.player_placeholder.velocity.is_zero_approx() and not game.player_placeholder.controls_enabled and game.selected_interaction == null and not game.loading_save, "no carried world input " + kind)
		_check(game.session.foraging.get_signal_connection_list("committed").size() == 1, "one current scene listener " + kind)
		var facts: Dictionary = game.world_host.current_location.foraging_facts()
		_check(facts.collected_resource_ids == game.session.foraging.snapshot().collected_resource_ids, "scene fact binding " + kind)
		_check(game.player_placeholder.global_position.distance_to(game.world_host.current_location.find_spawn(game.session.current_spawn_id).global_position) < 0.01, "last arrival anchor " + kind)
		cases.append({"kind":kind,"snapshot":SaveCodec.snapshot(game.session),"save_path":ProjectSettings.globalize_path(game.save_repository.path)})
	# Generated rod in foreign Alderwake persists while hero saves inside Tollworks.
	game.save_repository = SaveRepository.new("user://saves/f004-process-foreign.json")
	if writer:
		var foreign: GameSession = ForagingSaveFixture.make(game.catalog,"alderwake")
		foreign.current_location_id = "prototype-tollworks"
		foreign.current_spawn_id = "tollworks-from-alderwake"
		_check(game.save_repository.write(foreign,game.catalog).is_empty(),"foreign writer")
		var oracle: FileAccess = FileAccess.open(game.save_repository.path + ".oracle",FileAccess.WRITE)
		oracle.store_var(SaveCodec.snapshot(foreign))
		oracle.close()
	_check((await game.load_run()).is_empty(),"foreign placement physical load")
	var oracle: FileAccess = FileAccess.open(game.save_repository.path + ".oracle",FileAccess.READ)
	_check(SaveCodec.snapshot(game.session) == oracle.get_var(false),"foreign exact oracle")
	oracle.close()
	_check(game.world_host.current_location.foraging_facts().world_item_placements.is_empty() and game.world_host.get_child_count() == 1,"foreign facts filtered/probe freed")
	game.world_host.request_transition("prototype-alderwake","alderwake-start")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0] and game.world_host.current_location.foraging_facts().world_item_placements.size() == 1 and game.session.foraging.rod_count() == 1,"foreign rod on revisit")
	_check(TestRunEvidence.write_json("%s-report.json" % ("write" if writer else "read"),{"pid":OS.get_process_id(),"assertions":assertions + 1,"cases":cases,"failures":failures,"proof":"synthetic service fixture; headless independent OS processes; exact binary oracle"}),"report")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F004 foraging_process_checks ", "write" if writer else "read", " ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _check(ok: bool,label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
