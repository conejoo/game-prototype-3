extends SceneTree
## Physical AI, save rules and lifecycle. Direct placements are test fixtures only.

var failures: PackedStringArray = []
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	var ally: ActorPlaceholder = game.companion
	var ai: CompanionController = game.companion_ai
	var identity: int = ally.get_instance_id()
	var state: ActorState = ally.state
	_check(game.party.members().size() == 2 and state == game.session.actors[GameSession.COMPANION_INSTANCE_ID], "Companion ownership invalid")
	for room: String in ["prototype-alderwake", "prototype-tollworks"]:
		if room != game.session.current_location_id:
			game.world_host.request_transition(room, "tollworks-from-alderwake")
			_check(not ai.enabled and ai.route.is_empty() and ally.combat_targets.is_empty(), "Transition left active path/targets")
			await game.world_host.transition_finished
		game.player_placeholder.global_position = Vector3(3, 0, -4)
		ally.global_position = Vector3(3, 0, 0.1)
		ai.reset_route()
		var before: int = ai.catchups
		await _frames(180)
		_check(ally.global_position.distance_to(game.player_placeholder.global_position) < 1.9 and ally.global_position.z < -3, "Companion failed obstacle route in " + room)
		_check(ai.catchups == before and ai.repaths > 0, "Obstacle follow used teleport instead of route")
		_check(ally.is_on_floor() and ally.get_instance_id() == identity and ally.state == state, "Follow lost floor/identity/state")
	# A physical runtime barrier invalidates the baked route; recovery must be safe.
	game.player_placeholder.global_position = Vector3(-4, 0, 4)
	ally.global_position = Vector3(-4, 0, 0)
	var barrier: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(13, 1.6, 0.5)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	barrier.add_child(collision)
	var visual: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = shape.size
	visual.mesh = mesh
	barrier.add_child(visual)
	game.world_host.current_location.add_child(barrier)
	barrier.position = Vector3(0, 0.8, 2)
	ai.reset_route()
	var catches: int = ai.catchups
	await _frames(65)
	await _capture("fixture-blocked-route")
	await _frames(200)
	_check(ai.catchups > catches and ally.global_position.distance_to(game.player_placeholder.global_position) < 2.2, "Stuck route did not safely catch up")
	_check(not _overlaps_world(ally), "Catch-up overlapped world")
	await _capture("fixture-safe-catchup")
	barrier.queue_free()
	await _frames(2)
	game.player_placeholder.global_position = Vector3(-5, 0, -4)
	ally.global_position = Vector3(5, 0, 4)
	ai.reset_route()
	catches = ai.catchups
	await _frames(5)
	_check(ai.catchups == catches + 1 and not _overlaps_world(ally), "Separated catch-up unsafe/unavailable")
	# Real actor damage marks down, pause/modal freeze recovery, no quest effects.
	ally.receive_damage(100)
	await _capture("fixture-incapacitated")
	game._set_paused(true)
	var data: Dictionary = SaveCodec.snapshot(game.session)
	var decoded: SaveCodec.DecodeResult = SaveCodec.validate(data, game.catalog)
	_check(decoded.errors.is_empty() and decoded.session.actors[GameSession.COMPANION_INSTANCE_ID].health == 0, "Down companion not persisted")
	await _frames(4)
	_check(ally.state.health == 0, "Pause recovered companion")
	game._set_paused(false)
	await _frames(195)
	_check(ally.state.health == 100 and ai.recoveries == 1 and game.session.completed_effect_ids.is_empty(), "Safe recovery changed quest or failed")
	await _capture("fixture-recovered")
	# v1/v2 exact migration keeps old facts, deliberately adds fixture member.
	for version: int in [1, 2]:
		var legacy: Dictionary = data.duplicate(true)
		legacy.schema_version = version
		legacy.party_member_ids = [GameSession.PLAYER_INSTANCE_ID]
		legacy.actors = [legacy.actors[0]]
		if version == 1:
			legacy.erase("quests")
			legacy.erase("completed_effect_ids")
		var bytes: String = JSON.stringify(legacy)
		decoded = SaveCodec.validate(legacy, game.catalog)
		_check(decoded.migrated and decoded.session != null and decoded.session.actors[GameSession.COMPANION_INSTANCE_ID].health == 100 and JSON.stringify(legacy) == bytes, "Legacy migration failed/mutated caller")
	for mutation: String in ["duplicate", "missing", "wrong-definition", "bad-health", "extra", "order"]:
		var broken: Dictionary = data.duplicate(true)
		match mutation:
			"duplicate": broken.actors[1].instance_id = GameSession.PLAYER_INSTANCE_ID
			"missing": broken.actors.pop_back()
			"wrong-definition": broken.actors[1].definition_id = "npc-03"
			"bad-health": broken.actors[1].health = 101
			"extra": broken.actors[1].timer = 0
			"order": broken.party_member_ids.reverse()
		_check(SaveCodec.validate(broken, game.catalog).session == null, "Invalid companion save accepted: " + mutation)
	# Quest setup only; combat itself goes through shared API and real death callback.
	game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	game.guardian_ai.enabled = false
	game.guardian.move_direction(Vector3.ZERO)
	game.player_placeholder.global_position = Vector3(0, 0, -1)
	ally.global_position = Vector3(1, 0, 1.8)
	ai.reset_route()
	await _frames(55)
	_check(game.guardian.state.health <= 90 and game.guardian.state.health > 0 and game.player_placeholder.combat.hit_ids.is_empty(), "Companion did not assist through real combat API")
	_check(not game._combat_stable(), "Ally fight allowed save/modal")
	# Leash returns to distant hero; no catch-up through living enemy's threat.
	game.player_placeholder.global_position = Vector3(-5, 0, -4)
	catches = ai.catchups
	await _frames(3)
	_check(ai.mode == "return" and ai.catchups == catches, "Leash did not return or teleported through combat")
	game.player_placeholder.global_position = Vector3(0, 0, -1)
	ally.receive_damage(100)
	await _frames(190)
	_check(ally.state.health == 0, "Companion healed during combat")
	game.guardian.receive_damage(100)
	await _frames(195)
	_check(ally.state.health == 100 and game.session.completed_effect_ids.size() == 3, "Post-combat recovery lost/duplicated clearance")
	game._set_paused(true)
	game.save_repository = SaveRepository.new("user://saves/p009-rules-%d.json" % OS.get_process_id())
	ally.state.health = 37
	_check(game.save_run().is_empty(), "Stable party save failed")
	_check((await game.load_run()).is_empty(), "Party restore failed")
	_check(ally.state.health == 37 and ally.state == game.session.actors[GameSession.COMPANION_INSTANCE_ID] and ally.get_instance_id() == identity and game.party.members().size() == 2 and ai.route.is_empty(), "Restore lost companion ownership/health or stale route")
	game._set_paused(false)
	ally.receive_damage(100)
	game.player_placeholder.receive_damage(100)
	game.retry_encounter()
	await game.world_host.transition_finished
	await process_frame
	_check(game.player_placeholder.state.health == 100 and ally.state.health == 100 and game.session.completed_effect_ids.size() == 3, "Safe retry did not restore party or duplicated progress")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P009 checks: PASS — both obstacle routes, stuck/separated safe catch-up, incapacitation/recovery, assist, once-only guardian effect, v1/v2 migration/rejection, party restore and identity.")
	quit(0 if failures.is_empty() else 1)


func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame


func _capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var path: String = "res://../docs/evidence/P009/%s.png" % label
	_check(root.get_texture().get_image().save_png(path) == OK, "Capture failed: " + label)


func _overlaps_world(actor: ActorPlaceholder) -> bool:
	var collider: CollisionShape3D = actor.get_node("CollisionShape3D")
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = collider.shape
	query.transform = Transform3D(Basis.IDENTITY, actor.global_position + collider.position + Vector3.UP * 0.02)
	query.collision_mask = 1
	return not actor.get_world_3d().direct_space_state.intersect_shape(query).is_empty()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
