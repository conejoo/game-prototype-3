extends SceneTree
## Synthetic rule/contact fixtures. Normal gameplay evidence is recorded separately.

var failures: PackedStringArray = []
const QUEST: String = "prototype-maris-recovery"
const POSITIVE: String = "prototype-shared-plan"
const NEGATIVE: String = "prototype-orders"

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	if "--phase=write" in OS.get_cmdline_user_args() or "--phase=read" in OS.get_cmdline_user_args():
		await _process_check(game)
	else:
		await _rules(game)
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for message: String in failures:
		push_error(message)
	if failures.is_empty():
		print("P010 checks: PASS — once-only alternatives/trust, earned selection, physical 40 damage, strict current-schema data; phase=", OS.get_cmdline_user_args())
	quit(0 if failures.is_empty() else 1)

func _rules(game: Node3D) -> void:
	var run: GameSession = game.session
	var relation: RelationshipService = game.relationships
	var progress: ProgressionService = game.progression
	var notifications: Array[int] = [0, 0]
	# Reject broken authored references without altering shared source Resources.
	for mutation: String in ["reaction-reference", "reaction-delta", "reaction-owner", "upgrade-effect", "upgrade-bonus"]:
		var manifest: ContentManifest = ContentManifest.new()
		for definition: ContentDefinition in game.content_manifest.definitions:
			manifest.definitions.append(definition.duplicate(true))
		for definition: ContentDefinition in manifest.definitions:
			if definition is ConversationDefinition and definition.stable_id == "prototype-companion-greeting" and mutation == "reaction-reference":
				TestRunConversation.mutate(definition, func(data: Dictionary) -> void: data.nodes[0].choices[2].command.reaction_id = "missing-reaction")
			if definition is ReactionDefinition:
				if mutation == "reaction-delta": (definition as ReactionDefinition).trust_delta = 0
				if mutation == "reaction-owner": (definition as ReactionDefinition).companion_id = "npc-03"
			if definition is UpgradeDefinition:
				if mutation == "upgrade-effect": (definition as UpgradeDefinition).earned_effect_id = "missing-effect"
				if mutation == "upgrade-bonus": (definition as UpgradeDefinition).damage_bonus = 0
		_check(not ContentCatalog.new().initialize(manifest).is_empty(), "Malformed authored consequence accepted: " + mutation)
	relation.changed.connect(func() -> void: notifications[0] += 1)
	progress.changed.connect(func() -> void: notifications[1] += 1)
	_check(not relation.apply("unknown").ok, "Unknown reaction accepted")
	_check(not game._reaction_command(POSITIVE, "alderwake-temporary-companion").ok, "Reaction ran without dialogue")
	_check(not progress.select_upgrade(ProgressionService.UPGRADE_ID).ok and progress.available_points() == 0, "Unearned upgrade accepted")
	_check(relation.apply(POSITIVE).ok and run.relationship.trust == 1, "Positive reaction missing")
	_check(relation.apply(POSITIVE).ok and not relation.apply(NEGATIVE).ok and run.relationship.trust == 1 and notifications[0] == 1, "Replay/alternative repeated trust or notification")
	var other: GameSession = GameSession.new()
	other.initialize(game.catalog, "prototype-alderwake", "alderwake-start", "prototype-hero")
	var other_relation: RelationshipService = RelationshipService.new()
	other_relation.initialize(game.catalog, other)
	_check(other_relation.apply(NEGATIVE).ok and other.relationship.trust == -1 and run.relationship.trust == 1, "Negative/independent reaction failed")
	_check(game.quests.apply(QUEST, "maris-accept-lead", "prototype-alderwake", "npc-03-counter").ok and progress.available_points() == 1, "Lead did not earn point")
	_check(progress.select_upgrade(ProgressionService.UPGRADE_ID).ok and progress.available_points() == 0 and game.player_placeholder.combat.damage == 40, "Upgrade not applied to hero")
	_check(progress.select_upgrade(ProgressionService.UPGRADE_ID).ok and notifications[1] == 1 and progress.available_points() == 0, "Upgrade spent twice")
	game.quests.apply(QUEST, "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
	_check(progress.available_points() == 0, "Lead retry earned extra point")
	var data: Dictionary = SaveCodec.snapshot(run)
	var decoded: SaveCodec.DecodeResult = SaveCodec.validate(data, game.catalog)
	_check(decoded.session != null and decoded.session.relationship.trust == 1 and decoded.session.progression.upgrade_ids.size() == 1, "Round trip lost consequence")
	decoded.session.relationship.trust = 0
	_check(run.relationship.trust == 1, "Save candidate shares mutable relationship")
	for mutation: String in ["trust", "bool", "unknown", "duplicate", "alternative", "companion", "missing", "extra", "upgrade-duplicate", "upgrade-unknown", "unearned"]:
		var bad: Dictionary = data.duplicate(true)
		match mutation:
			"trust": bad.relationship.trust = 2
			"bool": bad.relationship.trust = true
			"unknown": bad.relationship.reaction_ids = ["unknown"]
			"duplicate": bad.relationship.reaction_ids = [POSITIVE, POSITIVE]
			"alternative": bad.relationship.reaction_ids = [POSITIVE, NEGATIVE]; bad.relationship.trust = 0
			"companion": bad.relationship.companion_id = "npc-03"
			"missing": bad.erase("relationship")
			"extra": bad.progression.points = 1
			"upgrade-duplicate": bad.progression.upgrade_ids.append(ProgressionService.UPGRADE_ID)
			"upgrade-unknown": bad.progression.upgrade_ids = ["unknown"]
			"unearned": bad.quests[QUEST] = []; bad.completed_effect_ids = []
		_check(SaveCodec.validate(bad, game.catalog).session == null, "Invalid consequence accepted: " + mutation)
	# Isolated physical contact verifies actual wrapper damage and one swing contact.
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	game.guardian_ai.enabled = false
	game.companion_ai.enabled = false
	game.companion.combat_enabled = false
	game.guardian.move_speed = 0.0
	game.player_placeholder.global_position = Vector3.ZERO
	game.guardian.global_position = Vector3(0, 0, -1.2)
	game.player_placeholder.face_direction(Vector3.FORWARD)
	await physics_frame
	_check(game.player_placeholder.request_attack(), "Upgraded swing not started")
	for frame: int in range(28):
		await physics_frame
	_check(game.guardian.state.health == 60, "Physical upgraded swing did not deal exactly 40")

func _process_check(game: Node3D) -> void:
	game.save_repository = SaveRepository.new("user://saves/p010-process.json")
	if "--phase=write" in OS.get_cmdline_user_args():
		game.quests.apply(QUEST, "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
		game.relationships.apply(NEGATIVE)
		game.progression.select_upgrade(ProgressionService.UPGRADE_ID)
		game._set_paused(true)
		failures.append_array(game.save_run())
	else:
		game._set_paused(true)
		failures.append_array(await game.load_run())
		_check(game.relationships.session == game.session and game.progression.session == game.session, "Restore did not rebind owners")
		_check(game.session.relationship.trust == -1 and game.player_placeholder.combat.damage == 40, "Process restart lost trust/upgrade damage")
		_check(game.relationships.apply(NEGATIVE).ok and not game.relationships.apply(POSITIVE).ok and game.session.relationship.trust == -1, "Reload repeated/replaced reaction")
		_check(game.progression.select_upgrade(ProgressionService.UPGRADE_ID).ok and game.progression.available_points() == 0, "Reload spent/re-earned point")
		game._set_paused(false)
		game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
		await game.world_host.transition_finished
		_check(game.session.relationship.trust == -1 and game.player_placeholder.combat.damage == 40, "Travel lost consequence")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
