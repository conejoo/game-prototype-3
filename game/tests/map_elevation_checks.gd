extends SceneTree
## Synthetic placement and fixed physics stepping; rendered normal inputs separate.

var failures: PackedStringArray = []
var grounding_error: float = 0.0
var motion_samples: int = 0
var slope_runs: int = 0
var cliff_runs: int = 0
var report: Dictionary = {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var terrain: AlderwakeElevationSurfaces = location.elevation
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	_check(terrain.levels.size() == 472 and terrain.slopes.size() == 16, "Pinned height inventory")
	_check(terrain.cliffs.size() == 238, "Derived cliff inventory")
	var exclusions: Array[RID] = []
	for body: Node in location.find_children("*", "StaticBody3D", true, false):
		if body != terrain.get_node("TerrainFloor"):
			exclusions.append(body.get_rid())
	var floor_probes: int = 0
	for record: Dictionary in location.layout.elevation.cells + location.layout.elevation.slopes:
		var cell: Vector2i = Vector2i(record.cell[0], record.cell[1])
		for u: float in [0.1, 0.5, 0.9]:
			for v: float in [0.1, 0.5, 0.9]:
				var p: Vector2 = Vector2(cell) + terrain.ORIGIN + Vector2(u, v)
				var expected: float = terrain.cell_height(cell, p)
				var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(p.x, 3, p.y), Vector3(p.x, -1, p.y), 1, exclusions))
				_check(not hit.is_empty() and absf(hit.position.y - expected) < 0.005 and hit.normal.y > 0.96, "Height/normal mismatch at " + str(p))
				floor_probes += 1
	for id: String in ["alderwake-start", "alderwake-from-tollworks"]:
		_check(game.world_host._placement_errors(location.find_spawn(id)).is_empty(), "Unsafe full-party anchor " + id)
	for population: AlderwakePropGrayboxes in [location.town, location.forest]:
		for record: Dictionary in population.prop_records:
			var wrapper: Node3D = population.get_node(NodePath(record.id))
			_check(wrapper.position.distance_to(Vector3(record.foot_xyz_m[0], record.foot_xyz_m[1], record.foot_xyz_m[2])) < 0.001, "Physical prop foot changed " + record.id)
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	game.companion.global_position = Vector3(120, 0, 55)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true
	var capsule: CapsuleShape3D = hero.get_node("CollisionShape3D").shape
	var routes: Dictionary = {}
	for cell: Vector2i in terrain.slopes:
		var slope: Dictionary = terrain.slopes[cell]
		var ascent: Vector3 = {"east": Vector3.RIGHT, "west": Vector3.LEFT, "north": Vector3.FORWARD, "south": Vector3.BACK}[slope.ascends_toward]
		var center: Vector3 = Vector3(cell.x - 21.5, 0, cell.y - 17.5)
		var low: Vector3 = center - ascent
		var high: Vector3 = center + ascent
		low.y = terrain.height_at(Vector2(low.x, low.z))
		high.y = terrain.height_at(Vector2(high.x, high.z))
		_check(_clear(space, capsule, low) and _clear(space, capsule, high), "Authored ramp endpoint obstructed " + str(slope.id))
		for backwards: bool in [false, true]:
			for dodge: bool in [false, true]:
				var start: Vector3 = high if backwards else low
				var end: Vector3 = low if backwards else high
				hero.global_position = start + Vector3.UP * 0.015
				hero.velocity = Vector3.ZERO
				hero.combat.cancel()
				hero.move_direction(Vector3.ZERO)
				await physics_frame
				for settle: int in range(3):
					hero._physics_process(1.0 / 60.0)
				hero.move_direction(-ascent if backwards else ascent)
				if dodge:
					_check(hero.request_dodge(-ascent if backwards else ascent), "Ramp dodge rejected")
				for step: int in range(70):
					var previous: Vector3 = hero.global_position
					hero._physics_process(1.0 / 60.0)
					_audit_ground(previous, hero.global_position, terrain)
					if Vector2(hero.global_position.x - end.x, hero.global_position.z - end.z).length() < 0.08:
						break
					if (hero.global_position - end).dot(-ascent if backwards else ascent) >= 0:
						break
				_check(Vector2(hero.global_position.x - end.x, hero.global_position.z - end.z).length() < 0.18, "Ramp traversal stalled " + str(slope.id) + " backwards=" + str(backwards) + " dodge=" + str(dodge))
				slope_runs += 1
			routes[str(slope.id) + ("-down" if backwards else "-up")] = [[low.x, low.y, low.z], [center.x, (low.y + high.y) / 2, center.z], [high.x, high.y, high.z]] if not backwards else [[high.x, high.y, high.z], [center.x, (low.y + high.y) / 2, center.z], [low.x, low.y, low.z]]
	# Every differing-height edge and ramp side must intercept a bidirectional
	# capsule cast. Actual walk/dodge fixtures additionally sample diagonal cuts.
	var cast_count: int = 0
	for cliff: Dictionary in terrain.cliffs:
		var a: Vector2 = cliff.a
		var b: Vector2 = cliff.b
		var center: Vector2 = (a + b) / 2
		var normal: Vector2 = Vector2(1, 0) if a.x == b.x else Vector2(0, 1)
		for sign_value: int in [-1, 1]:
			var point: Vector2 = center + normal * sign_value * 0.6
			var feet: Vector3 = Vector3(point.x, terrain.height_at(point), point.y)
			var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
			query.shape = capsule
			query.transform.origin = feet + Vector3.UP * 0.82
			query.collision_mask = 1
			query.motion = Vector3(-normal.x, 0, -normal.y) * sign_value * 1.2
			_check(space.cast_motion(query)[0] < 0.5, "Cliff cast crossed " + str(cliff.id))
			cast_count += 1
			if not _clear(space, capsule, feet):
				continue # Source prop or another cliff obstructs fixture start.
			for diagonal: float in [0.0, -0.3, 0.3]:
				for dodge: bool in [false, true]:
					hero.global_position = feet + Vector3.UP * 0.015
					hero.velocity = Vector3.ZERO
					hero.combat.cancel()
					var tangent: Vector2 = Vector2(-normal.y, normal.x)
					var direction: Vector2 = -normal * sign_value + tangent * diagonal
					hero.move_direction(Vector3.ZERO)
					await physics_frame
					# Synthetic relocation must discard cached contact state from
					# the previous height before testing movement at this edge.
					for settle: int in range(3):
						hero._physics_process(1.0 / 60.0)
					hero.move_direction(Vector3(direction.x, 0, direction.y).normalized())
					if dodge:
						hero.request_dodge(hero.requested_direction)
					for step: int in range(12):
						var previous: Vector3 = hero.global_position
						hero._physics_process(1.0 / 60.0)
						_audit_ground(previous, hero.global_position, terrain)
					var delta: Vector2 = Vector2(hero.global_position.x, hero.global_position.z) - center
					_check(delta.dot(normal) * sign_value > 0.3, "Walking/dodge cliff cut " + str(cliff.id))
					cliff_runs += 1
	report = {"floor_probes": floor_probes, "height_cells": 472, "slopes": 16, "cliffs": terrain.cliffs.size(), "slope_runs": slope_runs, "cliff_casts": cast_count, "cliff_runs": cliff_runs, "motion_samples": motion_samples, "max_grounding_error_m": grounding_error, "routes": routes, "failures": failures}
	var output: FileAccess = FileAccess.open(TestRunEvidence.path("elevation-report.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t") + "\n")
	print("M008 elevation counts ", JSON.stringify(report.duplicate().merged({"routes": "see report"}, true)))
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("M008 map_elevation_checks PASS")
	quit(0 if failures.is_empty() else 1)


func _audit_ground(a: Vector3, b: Vector3, terrain: AlderwakeElevationSurfaces) -> void:
	var count: int = maxi(1, ceili(a.distance_to(b) / 0.1))
	for index: int in range(count + 1):
		var point: Vector3 = a.lerp(b, float(index) / count)
		var error: float = absf(point.y - terrain.height_at(Vector2(point.x, point.z)))
		grounding_error = maxf(grounding_error, error)
		_check(error < 0.05, "Lost grounding at " + str(point))
		motion_samples += 1


func _clear(space: PhysicsDirectSpaceState3D, capsule: CapsuleShape3D, feet: Vector3) -> bool:
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = feet + Vector3.UP * 0.82
	query.collision_mask = 1
	return space.intersect_shape(query).is_empty()


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
