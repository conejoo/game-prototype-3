extends SceneTree
## M010 synthetic setup, shared physical movement and actual companion AI.
## Fixed stepping accelerates checks; rendered ordinary-input evidence is separate.

const DT: float = 1.0 / 60.0
var failures: PackedStringArray = []
var report: Dictionary = {"follow_routes": {}, "rejections": {}, "suspension": {}}
var game: Node3D
var location: AlderwakeTerrainPreview
var hero: ActorPlaceholder
var ally: ActorPlaceholder
var ai: CompanionController
var samples: int = 0
var max_ground_error: float = 0.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	game = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	location = game.world_host.current_location
	hero = game.player_placeholder
	ally = game.companion
	ai = game.companion_ai
	hero.set_physics_process(false)
	ally.set_physics_process(false)
	ai.set_physics_process(false)
	hero.player_controlled = false
	var identity: int = ally.get_instance_id()
	var state: ActorState = ally.state
	var bank_path: PackedVector3Array = NavigationServer3D.map_get_path(game.get_world_3d().navigation_map, Vector3(66, 0, 12.5), Vector3(93, 0, -0.5), true)
	var bank_points: Array = []
	for point: Vector3 in bank_path:
		bank_points.append(_plain(point))
	report["render_routes"] = {"ford-west-to-bridge-west": {"path": bank_points}}
	for crossing: Array in [["bridge", Vector3(93, 0, -0.5), Vector3(103, 0, -0.5)], ["ford", Vector3(66, 0, 12.5), Vector3(75, 0, 12.5)]]:
		await _follow(crossing[0] + "-forward", crossing[1], crossing[2])
		await _follow(crossing[0] + "-reverse", crossing[2], crossing[1])
	await _follow("moonwell-forward", Vector3.ZERO, Vector3(31.51317596435547, 0.5, 5.25))
	await _follow("moonwell-reverse", Vector3(31.51317596435547, 0.5, 5.25), Vector3.ZERO)
	# Full journeys exercise the ramp networks. A 2m individual ramp probe can
	# stop the ally 1.6m short by design; it cannot prove complete AI traversal.
	for goal: Array in [["western-rise", Vector3(-14, 0.75, -15.5)], ["upper-moonwood", Vector3(32, 0.5, -5.5)], ["western-side-rise", Vector3(-15.5, 0.75, -12.5)]]:
		await _follow(goal[0] + "-forward", Vector3.ZERO, goal[1])
		await _follow(goal[0] + "-reverse", goal[1], Vector3.ZERO)
	# Northern high pad is an authored isolated terrace, reached only in this
	# fixture. Test its internal ramp without inventing a route through cliffs.
	await _follow("northern-rise-up", Vector3(8.5, 1.5, -15.5), Vector3(4.5, 1.75, -15.5))
	await _follow("northern-rise-down", Vector3(4.5, 1.75, -15.5), Vector3(4.5, 1.5, -16.5))
	# Physically stall the actor on an unbaked low curb. Recovery must wait until
	# the obstruction is removed and its corridor becomes traversable.
	await _setup(Vector3(2.5, 0, 0), Vector3.ZERO)
	var curb: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.1, 0.15, 0.8)
	var collider: CollisionShape3D = CollisionShape3D.new()
	collider.shape = shape
	curb.add_child(collider)
	location.add_child(curb)
	curb.position = Vector3(1, 0.075, 0)
	await physics_frame
	var before: int = ai.catchups
	for tick: int in range(360):
		_step()
	_check(ai.catchups == before and ally.global_position.x < 1, "Physical stall skipped the low curb")
	_check(ai._stuck_seconds >= 2.5, "Physical stall failed to accumulate real stuck time")
	curb.queue_free()
	await physics_frame
	# The blocked route becomes traversable after removal. Invoke the same AI
	# recovery tick before further movement so the retained stall timer is tested.
	ai._physics_process(DT)
	_check(ai.catchups == before + 1 and _flat(ally.global_position - hero.global_position).length() < 2.2, "Cleared physical stall failed safe catch-up")
	report["stall"] = {"blocked_ticks": 360, "catchups_after_clear": ai.catchups - before, "feet": _plain(ally.global_position)}
	# A genuine shared-API incapacitation waits 3s, remains connected, and heals
	# the same state only after safe placement; timers must freeze in every gate.
	await _setup(Vector3(6, 0, 0), Vector3(4, 0, 0))
	_check(ally.receive_damage(100), "Incapacitation damage rejected")
	for gate: String in ["pause", "dialogue", "focus", "journal"]:
		match gate:
			"pause": game._set_paused(true)
			"dialogue":
				game.dialogue.begin(game.catalog.get_dialogue("prototype-companion-greeting"), "m010-synthetic-station")
				game._update_controls()
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"journal":
				game.journal_open = true
				game._update_controls()
		var feet: Vector3 = ally.global_position
		var timer: float = ai._recovery_seconds
		var repaths: int = ai.repaths
		for tick: int in range(240):
			ai._physics_process(DT)
		await process_frame
		_check(not ai.enabled and ally.state.health == 0 and ally.global_position == feet and ai._recovery_seconds == timer and ai.repaths == repaths, "AI did not suspend: " + gate)
		report.suspension[gate] = true
		match gate:
			"pause": game._set_paused(false)
			"dialogue": game._cancel_dialogue()
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			"journal":
				game.journal_open = false
				game._update_controls()
	var heals: int = ai.recoveries
	for tick: int in range(179):
		_step()
	_check(ally.state.health == 0 and ai.recoveries == heals, "Recovery healed before three seconds")
	for tick: int in range(10):
		_step()
	_check(ally.state.health == 100 and ai.recoveries == heals + 1 and ally.state == state, "Connected recovery failed/changed ownership")
	report["incapacitation"] = {"delay_seconds": 3, "recoveries": ai.recoveries - heals}
	# Actual retained river and cliff pairs have a route via a crossing/ramp but
	# the relocation chord is blocked. No shortcuts even with local hero LOS.
	for fixture: Array in [["river", Vector3(66, 0, 10), Vector3(75, 0, 10)], ["cliff", Vector3(24, 0, 3), Vector3(26, 0.25, 3)]]:
		await _setup(fixture[2], fixture[1])
		await _reject(fixture[0])
		ally.receive_damage(100)
		for tick: int in range(240):
			ai._physics_process(DT)
		_check(ally.state.health == 0, "Blocked " + fixture[0] + " healed companion")
	# Query returns nonempty path on an island: reject incomplete end even when
	# floor, capsule and hero sight are clear. Separate synthetic navigation map.
	await _setup(Vector3(6, 0, 0), Vector3.ZERO)
	var island_map: RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_active(island_map, true)
	var regions: Array[RID] = []
	var island_meshes: Array[NavigationMesh] = []
	for center: Vector3 in [Vector3.ZERO, Vector3(6, 0, 0)]:
		var mesh: NavigationMesh = NavigationMesh.new()
		mesh.vertices = PackedVector3Array([center + Vector3(-2, 0, -2), center + Vector3(2, 0, -2), center + Vector3(2, 0, 2), center + Vector3(-2, 0, 2)])
		mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
		island_meshes.append(mesh)
		var region: RID = NavigationServer3D.region_create()
		NavigationServer3D.region_set_enabled(region, true)
		NavigationServer3D.region_set_navigation_mesh(region, mesh)
		NavigationServer3D.region_set_map(region, island_map)
		regions.append(region)
	NavigationServer3D.map_force_update(island_map)
	for attempt: int in range(120):
		if NavigationServer3D.map_get_iteration_id(island_map) > 0 and NavigationServer3D.map_get_closest_point_owner(island_map, Vector3.ZERO) == regions[0]:
			break
		await create_timer(0.01).timeout
	var wanted: Vector3 = Vector3(7.8, 0, 0)
	var incomplete: PackedVector3Array = NavigationServer3D.map_get_path(island_map, ally.global_position, wanted, true)
	_check(not incomplete.is_empty(), "Island fixture needs nonempty partial path")
	var connected: bool = ai._connected_placement(island_map, game.get_world_3d().direct_space_state, wanted, ally.get_node("CollisionShape3D"))
	_check(not connected, "Disconnected island placement accepted")
	report.rejections["disconnected-islands"] = {"accepted": connected, "partial_path_points": incomplete.size(), "partial_end": _plain(incomplete[-1]) if not incomplete.is_empty() else [], "iteration": NavigationServer3D.map_get_iteration_id(island_map)}
	for region: RID in regions:
		NavigationServer3D.free_rid(region)
	NavigationServer3D.free_rid(island_map)
	# Stale baked route across a newly placed full barrier is rejected by physics.
	await _setup(Vector3(6, 0, 0), Vector3.ZERO)
	var barrier: StaticBody3D = StaticBody3D.new()
	var barrier_shape: BoxShape3D = BoxShape3D.new()
	barrier_shape.size = Vector3(0.05, 0.2, 20)
	var barrier_collision: CollisionShape3D = CollisionShape3D.new()
	barrier_collision.shape = barrier_shape
	barrier.add_child(barrier_collision)
	location.add_child(barrier)
	barrier.position = Vector3(3, 0.1, 0)
	await physics_frame
	await _reject("stale-low-barrier")
	barrier.queue_free()
	await physics_frame
	# Threat check belongs inside placement too, not only in recovery callers.
	var enemy: ActorPlaceholder = hero.duplicate()
	location.add_child(enemy)
	enemy.player_controlled = false
	enemy.initialize(ActorState.new("m010-enemy", game.catalog.get_actor(hero.state.definition_id)))
	enemy.set_physics_process(false)
	enemy.global_position = hero.global_position + Vector3.BACK
	ai.enemy = enemy
	await _reject("combat")
	ai.enemy = null
	enemy.queue_free()
	# Existing travel transaction suspends/reset timers and retains both wrappers.
	hero.set_physics_process(true)
	ally.set_physics_process(true)
	ai.set_physics_process(true)
	hero.player_controlled = true
	for target: Array in [["prototype-tollworks", "tollworks-from-alderwake"], ["candidate-alderwake", "alderwake-from-tollworks"]]:
		game.world_host.request_transition(target[0], target[1])
		_check(not ai.enabled and ai.route.is_empty() and ai._recovery_seconds == 0.0 and ai._stuck_seconds == 0.0 and game.party.suspended, "Travel left AI active")
		await game.world_host.transition_finished
		_check(ai.enabled and not game.party.suspended and ally.get_instance_id() == identity and ally.state == state, "Travel lost AI/party ownership")
	report.suspension["travel"] = true
	_check(game.session.completed_effect_ids.is_empty() and game.party.members().size() == 2, "Candidate recovery changed durable effects/party")
	report["motion_samples"] = samples
	report["max_ground_error_m"] = max_ground_error
	report["failures"] = failures
	var file: FileAccess = FileAccess.open(TestRunEvidence.path("companion-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M010 map_companion_checks ", "PASS" if failures.is_empty() else "FAIL", ": ", samples, " movement samples, ", report.follow_routes.size(), " routes, ground error ", max_ground_error)
	quit(0 if failures.is_empty() else 1)


func _setup(leader: Vector3, follower: Vector3) -> void:
	hero.global_position = _floor(leader)
	ally.global_position = _floor(follower)
	hero.clear_input()
	ally.clear_input()
	hero.initialize(hero.state)
	ally.state.health = 100
	ally.initialize(ally.state)
	game._update_controls()
	ai.reset_route()
	await physics_frame
	for tick: int in range(3):
		hero._physics_process(DT)
		ally._physics_process(DT)


func _follow(id: String, start: Vector3, end: Vector3) -> void:
	# Start colocated only in this fixture (party members do not block each other).
	await _setup(start, start)
	hero.move_speed = 2.8
	var path: PackedVector3Array = NavigationServer3D.map_get_path(game.get_world_3d().navigation_map, start, end, true)
	_check(path.size() >= 2 and _flat(path[-1] - end).length() < 0.4, "Follower test endpoint disconnected: " + id)
	var catches: int = ai.catchups
	var repaths: int = ai.repaths
	var ticks: int = 0
	for target: Vector3 in path:
		for tick: int in range(4000):
			var direction: Vector3 = _flat(target - hero.global_position)
			if direction.length() < 0.08:
				break
			hero.move_direction(direction.normalized())
			_step()
			ticks += 1
			if tick == 3999:
				_check(false, "Leader stalled " + id)
	hero.move_direction(Vector3.ZERO)
	for tick: int in range(180):
		_step()
	var gap: float = _flat(ally.global_position - hero.global_position).length()
	_check(gap < 1.9 and _flat(hero.global_position - end).length() < 0.3, "Ally follow stalled: %s gap %.3f feet %s" % [id, gap, ally.global_position])
	_check(ai.catchups == catches and ai.repaths > repaths, "Follow needed teleport/no repath: " + id)
	report.follow_routes[id] = {"ticks": ticks, "gap_m": gap, "catchups": ai.catchups - catches, "repaths": ai.repaths - repaths, "end": _plain(hero.global_position), "ally_end": _plain(ally.global_position)}
	print("M010 follow ", id, " gap ", gap, " catches ", ai.catchups - catches)
	hero.move_speed = 4.0


func _reject(id: String) -> void:
	var before: Vector3 = ally.global_position
	var catches: int = ai.catchups
	var result: bool = ai._safe_place()
	_check(not result and ally.global_position == before and ai.catchups == catches, "Unsafe recovery accepted: " + id)
	report.rejections[id] = {"accepted": result, "ally": _plain(before), "hero": _plain(hero.global_position)}


func _step() -> void:
	hero._physics_process(DT)
	ally._physics_process(DT)
	ai._physics_process(DT)
	for actor: ActorPlaceholder in [hero, ally]:
		var error: float = absf(actor.global_position.y - location.elevation.height_at(Vector2(actor.global_position.x, actor.global_position.z)))
		max_ground_error = maxf(max_ground_error, error)
		_check(error < 0.05, "Follower/leader lost ground")
		samples += 1


func _floor(point: Vector3) -> Vector3:
	return Vector3(point.x, location.elevation.height_at(Vector2(point.x, point.z)), point.z)


func _flat(point: Vector3) -> Vector3:
	return Vector3(point.x, 0, point.z)


func _plain(point: Vector3) -> Array:
	return [point.x, point.y, point.z]


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
