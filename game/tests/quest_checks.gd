extends SceneTree
## Rules, strict compatibility, real root lifecycle. Positions below are test setup.

const QUEST: String = "prototype-maris-recovery"
var failures: PackedStringArray = []
var catalog: ContentCatalog = ContentCatalog.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "Catalog invalid")
	var definition: QuestDefinition = catalog.get_quest(QUEST)
	var run: GameSession = _session()
	var service: QuestService = QuestService.new()
	service.initialize(catalog, run)
	var other: GameSession = _session()
	var notifications: Array[int] = [0]
	service.changed.connect(func() -> void:
		notifications[0] += 1
		_check(run.quests[QUEST].completed_step_ids.size() == run.completed_effect_ids.size(), "Observer saw partial transaction")
	)
	for step: QuestStep in definition.steps.slice(1):
		_check(not service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Out-of-order action succeeded")
	_check(not service.apply("unknown", "unknown", "", "").ok, "Unknown quest accepted")
	_check(not service.apply(QUEST, "unknown", "", "").ok, "Unknown action accepted")
	for step: QuestStep in definition.steps:
		_check(not service.apply(QUEST, step.action_id, "wrong", step.source_id).ok, "Wrong location accepted")
		_check(not service.apply(QUEST, step.action_id, step.location_id, "wrong").ok, "Wrong source accepted")
		_check(service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Legal step failed")
		var count: int = run.completed_effect_ids.size()
		for repeat: int in range(3):
			_check(service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Idempotent retry failed")
		_check(run.completed_effect_ids.size() == count and notifications[0] == count, "Repeated completion granted/notified twice")
	_check(other.quests[QUEST].completed_step_ids.is_empty() and other.completed_effect_ids.is_empty(), "Sessions share quest state")
	_check(definition.steps.size() == 6 and "Complete:" in service.objective(QUEST), "Sequence/journal incomplete")
	var data: Dictionary = SaveCodec.snapshot(run)
	var restored: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(data), catalog)
	_check(restored.errors.is_empty() and restored.session != run, "Quest round trip failed")
	service.initialize(catalog, restored.session)
	for step: QuestStep in definition.steps:
		_check(service.apply(QUEST, step.action_id, step.location_id, step.source_id).ok, "Replay after load failed")
	_check(restored.session.completed_effect_ids.size() == 6 and notifications[0] == 6, "Load replay duplicated effects")
	restored.session.quests[QUEST].completed_step_ids.clear()
	_check(run.quests[QUEST].completed_step_ids.size() == 6, "Decoded quests share mutable state")
	for mutation: String in ["missing-quests", "missing-effects", "unknown-quest", "skipped-step", "duplicate-step", "unknown-effect", "duplicate-effect", "missing-effect", "future", "legacy-with-extra"]:
		var bad: Dictionary = data.duplicate(true)
		match mutation:
			"missing-quests": bad.erase("quests")
			"missing-effects": bad.erase("completed_effect_ids")
			"unknown-quest": bad.quests = {"unknown": []}
			"skipped-step": bad.quests[QUEST] = ["maris-vessel"]
			"duplicate-step": bad.quests[QUEST] = ["maris-lead", "maris-lead"]
			"unknown-effect": bad.completed_effect_ids[0] = "unknown"
			"duplicate-effect": bad.completed_effect_ids[1] = bad.completed_effect_ids[0]
			"missing-effect": bad.completed_effect_ids.pop_back()
			"future": bad.schema_version = SaveCodec.SCHEMA_VERSION + 1
			"legacy-with-extra": bad.schema_version = 1
		_check(SaveCodec.validate(bad, catalog).session == null, "Malformed progress accepted: " + mutation)
	var legacy: Dictionary = SaveCodec.snapshot(other)
	legacy.schema_version = 1
	legacy.party_member_ids = [GameSession.PLAYER_INSTANCE_ID]
	legacy.actors = [legacy.actors[0]]
	legacy.erase("quests")
	legacy.erase("completed_effect_ids")
	legacy.elapsed_play_seconds = 42.5
	legacy.actors[0].health = 37
	var legacy_bytes: String = JSON.stringify(legacy)
	var migrated: SaveCodec.DecodeResult = SaveCodec.decode(legacy_bytes, catalog)
	_check(migrated.migrated and migrated.errors.is_empty(), "Exact v1 failed migration")
	_check(migrated.session.quests[QUEST].completed_step_ids.is_empty() and migrated.session.completed_effect_ids.is_empty(), "Migration invented progress")
	_check(migrated.session.actors[GameSession.PLAYER_INSTANCE_ID].health == 37 and migrated.session.elapsed_play_seconds == 42.5, "Migration lost v1 facts")
	_check(JSON.stringify(legacy) == legacy_bytes, "Migration mutated caller")
	var path: String = "user://saves/p007-migration-%d.json" % OS.get_process_id()
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "Migration fixture IO blocked")
	if file == null:
		_finish()
		return
	file.store_string(legacy_bytes)
	file.close()
	var repository: SaveRepository = SaveRepository.new(path)
	_check(repository.read(catalog).migrated and FileAccess.get_file_as_string(path) == legacy_bytes, "Read migration changed disk")
	_check(repository.write(migrated.session, catalog).is_empty(), "Explicit v2 publication failed")
	_check(JSON.parse_string(FileAccess.get_file_as_string(path)).schema_version == SaveCodec.SCHEMA_VERSION and repository.read(catalog).session != null, "Explicit save did not publish current schema")
	# Negative authored content: duplicate step/action/effect, absent location/action.
	for mutation: String in ["duplicate", "location", "dialogue"]:
		var manifest: ContentManifest = ContentManifest.new()
		for authored: ContentDefinition in (load("res://content/prototype_catalog.tres") as ContentManifest).definitions:
			manifest.definitions.append(authored.duplicate(true))
		for authored: ContentDefinition in manifest.definitions:
			if authored is QuestDefinition:
				if mutation == "duplicate": authored.steps.append(authored.steps[0])
				if mutation == "location": authored.steps[0].location_id = "absent"
			if mutation == "dialogue" and authored is DialogueDefinition and authored.stable_id == "prototype-maris-counter":
				authored.choices[0].action_id = "absent"
		_check(not ContentCatalog.new().initialize(manifest).is_empty(), "Malformed quest content accepted: " + mutation)
	# Root source command and arrival wiring; no teleport claim of normal gameplay.
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	_check(not game.world_host.current_location.has_node("GuardianTestFixture"), "Test fixture leaked into normal boot")
	game.player_placeholder.global_position = Vector3(-4, 0, 1.8)
	await physics_frame
	await physics_frame
	_check(game.interact().ok and game.dialogue.definition.stable_id == "prototype-maris-counter", "Maris interaction absent")
	_check(not game.dialogue.choose("maris-reconnect-choice").ok and game.dialogue.awaiting_choice(), "Rejected reconnection changed cursor")
	_check(game.dialogue.choose("maris-lead-choice").ok, "Lead not routed to quest owner")
	game._cancel_dialogue()
	game._toggle_journal()
	_check(game.journal_open and not game.player_placeholder.controls_enabled and "[done]" in game.ui.journal_text.text, "Journal/modal did not reflect lead")
	_check(not game.interact().ok, "Journal allowed world command")
	game._set_paused(true)
	_check(not paused, "Journal stacked pause")
	game._toggle_journal()
	_check(game.player_placeholder.controls_enabled and root.get_viewport().gui_get_focus_owner() == null, "Journal close retained input/focus")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	_check(game.session.quests[QUEST].completed_step_ids.size() == 2, "Successful expedition arrival not recorded")
	_check(not game.world_host.current_location.has_node("GuardianTestFixture"), "Normal Tollworks gained simulated objective")
	game.quests.record_arrival("prototype-tollworks")
	_check(game.session.completed_effect_ids.size() == 2, "Repeated arrival changed effects")
	game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks")
	await game.world_host.transition_finished
	_check(game.session.completed_effect_ids.size() == 2, "Early return skipped vessel prerequisite")
	game._set_paused(true)
	game.save_repository = SaveRepository.new("user://saves/p007-root-%d.json" % OS.get_process_id())
	_check(game.save_run().is_empty(), "Root quest save failed")
	var previous: GameSession = game.session
	_check((await game.load_run()).is_empty(), "Root quest restore failed")
	_check(game.session != previous and game.quests.session == game.session and game.session.completed_effect_ids.size() == 2, "Quest service did not rebind restored session")
	game._set_paused(false)
	game.queue_free()
	await process_frame
	_finish()


func _session() -> GameSession:
	var run: GameSession = GameSession.new()
	_check(run.initialize(catalog, "prototype-alderwake", "alderwake-start", "prototype-hero").is_empty(), "Session invalid")
	return run


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _finish() -> void:
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P007 checks: PASS — legal prefixes, source/location gates, atomic once-only effects, independent state, strict v2/v1 migration, root journal/travel/restore.")
	quit(0 if failures.is_empty() else 1)
