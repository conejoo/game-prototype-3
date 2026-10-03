extends SceneTree
## Focused damage windows and root lifecycle; direct positions are test setup only.

var failures: PackedStringArray = []
const QUEST: String = "prototype-maris-recovery"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var definition: ActorDefinition = load("res://content/actors/hero.tres")
	var health: ActorState = ActorState.new("target", definition)
	var swing: CombatState = CombatState.new()
	var defense: CombatState = CombatState.new()
	_check(swing.attack(Vector3.FORWARD, true), "Attack not started")
	_check(not swing.active() and not swing.attack(Vector3.FORWARD, true), "Windup/reentry failed")
	swing.advance(0.19)
	_check(swing.can_hit("target", Vector3.FORWARD), "Active forward hit missing")
	_check(not swing.can_hit("target", Vector3.BACK) and not swing.can_hit("target", Vector3.FORWARD * 3), "Facing/range ignored")
	for tick: int in range(6):
		if swing.can_hit("target", Vector3.FORWARD):
			swing.hit_ids.append("target")
			defense.receive(health, swing.damage)
		swing.advance(0.01)
	_check(health.health == 75, "One active swing damaged same target repeatedly")
	swing.advance(0.2)
	_check(not swing.active() and swing.busy(), "Recovery window missing")
	swing.advance(1.0)
	_check(swing.attack(Vector3.FORWARD, true) and swing.hit_ids.is_empty(), "New swing not reset")
	_check(defense.dodge(Vector3.RIGHT, true), "Dodge unavailable")
	_check(not defense.receive(health, 25) and health.health == 75, "Dodge did not block damage")
	defense.advance(0.31)
	_check(defense.receive(health, 200) and health.health == 0 and not defense.receive(health, 25), "Death clamp/repeat failed")
	_check(not defense.attack(Vector3.FORWARD, false) and not defense.dodge(Vector3.RIGHT, false), "Dead actor acted")
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "Combat rollback fixture"
	unsafe.prototype_fixture = true
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	# Legitimate rules setup, not acceptance evidence for normal gameplay.
	game.quests.apply(QUEST, "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	_check(is_instance_valid(game.guardian) and game.guardian.state.instance_id == "tollworks-guardian-01", "Normal guardian absent")
	var hero: ActorPlaceholder = game.player_placeholder
	var guardian: ActorPlaceholder = game.guardian
	guardian_ai_off(game)
	hero.global_position = Vector3(0, 0, 0)
	guardian.global_position = Vector3(0, 0, -1.2)
	hero.face_direction(Vector3.FORWARD)
	await physics_frame
	_check(not game.interact().ok, "Combat allowed interaction modal")
	game._toggle_journal()
	_check(not game.journal_open, "Combat allowed journal")
	hero.request_attack()
	for frame: int in range(28):
		await physics_frame
	_check(guardian.state.health == 75, "Physical active window did not deal exactly one hit")
	_check(not game._save_boundary_errors().is_empty(), "Engaged fight was saveable")
	game.world_host.request_transition(unsafe.stable_id, "unsafe-no-floor")
	var rollback: Array = await game.world_host.transition_finished
	_check(not rollback[0] and game.guardian == guardian and guardian.state.health == 75 and hero.combat_targets == [guardian], "Failed travel lost guardian/target/fight state")
	guardian_ai_off(game)
	# World obstruction excludes damage regardless of mesh/node names.
	hero.combat.cancel()
	hero.global_position = Vector3(3, 0, -3.3)
	guardian.global_position = Vector3(3, 0, -0.7)
	hero.combat.reach = 3.0
	hero.face_direction(Vector3.BACK)
	hero.request_attack()
	for frame: int in range(40):
		await physics_frame
	_check(guardian.state.health == 75, "Attack passed through plinth")
	hero.combat.reach = 2.2
	# Pause freezes windows and damage, release restores input.
	hero.combat.cancel()
	hero.global_position = Vector3(0, 0, 0)
	guardian.global_position = Vector3(0, 0, -1.2)
	hero.face_direction(Vector3.FORWARD)
	hero.request_attack()
	game._set_paused(true)
	var timer: float = hero.combat.elapsed
	for frame: int in range(5):
		await process_frame
	_check(hero.combat.elapsed == timer and guardian.state.health == 75, "Pause advanced combat")
	game._set_paused(false)
	hero.combat.cancel()
	guardian_ai_off(game)
	# Death and real root retry replace room safely; incomplete fight resets.
	hero.receive_damage(100)
	_check(hero.state.health == 0 and not hero.controls_enabled and game.session.completed_effect_ids.size() == 2, "Death state invalid")
	game.retry_encounter()
	await game.world_host.transition_finished
	await process_frame
	_check(hero.state.health == 100 and game.guardian.state.health == 100 and game.session.completed_effect_ids.size() == 2, "Retry did not reset only transient fight")
	guardian_ai_off(game)
	game.guardian.receive_damage(100)
	_check(game.session.completed_effect_ids.size() == 3 and "tollworks-guardian-cleared" in game.session.completed_effect_ids, "Actual defeat not routed to quest")
	game._on_guardian_defeated(game.guardian)
	_check(game.session.completed_effect_ids.size() == 3, "Repeated defeat duplicated effect")
	hero.receive_damage(100)
	game.retry_encounter()
	await game.world_host.transition_finished
	await process_frame
	_check(hero.state.health == 100 and game.guardian.state.health == 0 and game.session.completed_effect_ids.size() == 3, "Post-clear death/retry respawned guardian/reward")
	game._set_paused(true)
	game.save_repository = SaveRepository.new("user://saves/p008-root-%d.json" % OS.get_process_id())
	_check(game.save_run().is_empty(), "Cleared stable boundary save failed")
	_check((await game.load_run()).is_empty(), "Cleared save restore failed")
	_check(game.guardian.state.health == 0 and game.session.completed_effect_ids.size() == 3, "Restore lost durable guardian fact")
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P008 checks: PASS — windows, facing/range/LOS, one contact per swing, dodge, pause, death/retry, real defeat routing, once-only effect and save restore.")
	quit(0 if failures.is_empty() else 1)


func guardian_ai_off(game: Node3D) -> void:
	game.guardian_ai.enabled = false
	game.guardian.move_direction(Vector3.ZERO)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
