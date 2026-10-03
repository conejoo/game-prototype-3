extends SceneTree
## Isolated authored extension, synthetic damage/lifecycle; never normal gameplay.

const FIRST: String = "prototype-maris-recovery"
const SECOND: String = "test-extension-quest"
const ROOM: String = "test-extension-room"
var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var base_manifest: ContentManifest = load("res://content/prototype_catalog.tres")
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(base_manifest.definitions)
	for path: String in ["extension_guardian", "extension_location", "extension_quest"]:
		manifest.definitions.append(load("res://tests/fixtures/%s.tres" % path))
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(manifest).is_empty(), "Extended catalog rejected")
	var base_catalog: ContentCatalog = ContentCatalog.new()
	_check(base_catalog.initialize(base_manifest).is_empty(), "Normal catalog rejected")
	_check(base_catalog.get_quest(SECOND) == null and base_catalog.get_actor("test-extension-guardian") == null and base_catalog.get_location(ROOM) == null, "Extension leaked into normal content")
	var run: GameSession = GameSession.new()
	_check(run.initialize(catalog, "prototype-alderwake", "alderwake-start", "prototype-hero").is_empty(), "Extended session rejected")
	var service: QuestService = QuestService.new()
	service.initialize(catalog, run)
	var first: QuestDefinition = catalog.get_quest(FIRST)
	# Preserve an unfinished first quest while completing the second one.
	_check(service.apply(FIRST, first.steps[0].action_id, first.steps[0].location_id, first.steps[0].source_id).ok, "First lead rejected")
	var first_progress: PackedStringArray = run.quests[FIRST].completed_step_ids.duplicate()
	var first_objective: String = service.objective(FIRST)
	var notifications: Array[int] = [0]
	service.changed.connect(func() -> void:
		notifications[0] += 1
		_check(QuestService.validate_progress(SaveCodec.snapshot(run).quests, Array(run.completed_effect_ids), catalog).is_empty(), "Observer saw partial extended transaction")
	)
	_check(not service.apply(SECOND, "test-extension-clear", ROOM, "test-extension-guardian-01").ok, "Second quest skipped prerequisite")
	_check(not service.apply(SECOND, "test-extension-accept", ROOM, "npc-03-counter").ok, "First source authorized second quest")
	_check(service.apply(SECOND, "test-extension-accept", ROOM, "test-extension-board").ok, "Second lead rejected")
	# Same wrapper and API, new definition and independent instances.
	var variant: ActorDefinition = catalog.get_actor("test-extension-guardian")
	var actor: ActorPlaceholder = load("res://features/combat/guardian.tscn").instantiate()
	root.add_child(actor)
	actor.initialize(ActorState.new("test-extension-guardian-01", variant))
	actor.combat_enabled = true
	actor.set_physics_process(false)
	var other: ActorState = ActorState.new("test-extension-guardian-02", variant)
	var original_shape: Shape3D = actor.get_node("CollisionShape3D").shape
	actor.visual_root.get_node("GuardianModel").free()
	var replacement: MeshInstance3D = MeshInstance3D.new()
	replacement.mesh = BoxMesh.new()
	actor.visual_root.add_child(replacement)
	actor.defeated.connect(func(dead: ActorPlaceholder) -> void:
		_check(service.apply(SECOND, "test-extension-clear", ROOM, dead.state.instance_id).ok, "Variant death did not route stable source")
	)
	_check(actor.receive_damage(25) and actor.state.health == 35, "Variant did not use authored 60 health")
	_check(actor.receive_damage(35) and actor.state.health == 0, "Shared damage API did not defeat variant")
	_check(not actor.receive_damage(35), "Dead variant accepted another hit")
	_check(other.health == 60 and variant.max_health == 60 and catalog.get_actor("prototype-guardian").max_health == 100, "Variant state leaked into definition/other actor")
	_check(actor.get_node("CollisionShape3D").shape == original_shape and actor.state.definition_id == variant.stable_id, "Visual replacement changed wrapper identity/collision")
	for repeat: int in range(3):
		_check(service.apply(SECOND, "test-extension-clear", ROOM, actor.state.instance_id).ok, "Second quest repeat rejected")
	_check(notifications[0] == 2 and run.completed_effect_ids.size() == 3, "Second quest repeated effect/notification")
	_check(run.quests[FIRST].completed_step_ids == first_progress and service.objective(FIRST) == first_objective, "Second quest altered first quest")
	_check(service.objective(SECOND) == "Complete: TEST ONLY training request cleared." and "Maris" not in service.objective(SECOND), "Second completion leaked first quest text")
	_check("Isolated extension fixture" in service.journal(), "Journal ignored authored second note")
	var restored: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(SaveCodec.snapshot(run)), catalog)
	_check(restored.errors.is_empty(), "Extended plain-data round trip failed")
	if restored.session != null:
		service.initialize(catalog, restored.session)
		_check(service.apply(SECOND, "test-extension-clear", ROOM, actor.state.instance_id).ok and restored.session.completed_effect_ids.size() == 3, "Restore repeated second effect")
		_check(restored.session.quests[FIRST].completed_step_ids == first_progress, "Restore lost first progress")
	_check(SaveCodec.decode(JSON.stringify(SaveCodec.snapshot(run)), base_catalog).session == null, "Normal content accepted isolated quest set")
	# Cross-quest effect collisions must fail before catalog publication.
	var duplicate: ContentManifest = ContentManifest.new()
	duplicate.definitions.assign(manifest.definitions)
	var bad: QuestDefinition = (catalog.get_quest(SECOND).duplicate(true) as QuestDefinition)
	bad.steps[0].effect_id = first.steps[0].effect_id
	duplicate.definitions[duplicate.definitions.size() - 1] = bad
	_check(not ContentCatalog.new().initialize(duplicate).is_empty(), "Global effect collision accepted")
	# Existing root/session/WorldHost load an inherited test location by data only.
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	var party_before: Array[ActorPlaceholder] = game.party.members()
	_check(game.world_host.request_transition(ROOM, "prototype-start").is_empty(), "Extension travel request rejected")
	await game.world_host.transition_finished
	_check(game.session.current_location_id == ROOM and game.world_host.current_location.location_id == ROOM, "Extension room failed placement")
	_check(game.world_host.current_location.navigation_region.navigation_mesh.get_polygon_count() > 0, "Extension room has no navigation")
	_check(game.world_host.request_transition("prototype-alderwake", "alderwake-start").is_empty(), "Return request rejected")
	await game.world_host.transition_finished
	_check(game.party.members() == party_before and game.session.quests[FIRST].completed_step_ids.is_empty(), "Extension travel replaced party/advanced first quest")
	game.queue_free()
	actor.queue_free()
	await process_frame
	for message: String in failures:
		push_error(message)
	if failures.is_empty():
		print("P014 extension: PASS — isolated second quest, authored completion, actor variant/shared wrapper, once-only effects, independent first progress, strict save round trip, data-driven room lifecycle; synthetic fixture only")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
