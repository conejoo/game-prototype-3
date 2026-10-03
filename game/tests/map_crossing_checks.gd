extends SceneTree
## M005 synthetic registration/clearance/real capsule movement; rendered journey separate.

var failures: PackedStringArray = []
var sample_count: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var crossings: AlderwakeCrossings = location.crossings
	_check(crossings.build_errors.is_empty(), "Crossings did not build")
	_check(crossings.bridge_rect == Rect2(95, -2, 6, 3), "Bridge source footprint mismatch")
	_check(crossings.ford_rect == Rect2(67, 11, 7, 3), "Ford source footprint mismatch")
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	var body_count: int = 0
	for wrapper: Node in crossings.get_children():
		_check((wrapper.has_meta("source_landmark_id") or wrapper.has_meta("source_cell_range")) and wrapper.has_node("VisualRoot"), "Crossing wrapper/visual boundary missing")
		for child: Node in wrapper.get_children():
			if not child is StaticBody3D:
				continue
			body_count += 1
			var box: BoxShape3D = child.get_child(0).shape
			var rect: Rect2 = Rect2(child.position.x - box.size.x / 2, child.position.z - box.size.z / 2, box.size.x, box.size.z)
			_check(child.collision_layer == 1 and child.collision_mask == 0, "Crossing physics layer mismatch")
			for record: Dictionary in location.water_blockers.records:
				var r: Array = record.rect_xz_m
				_check(not rect.intersection(Rect2(r[0], r[1], r[2], r[3])).has_area(), "Crossing intrudes into water: " + str(child.name))
			if not str(child.name).ends_with("Rail"):
				_check(absf(child.position.y + box.size.y / 2) < 0.001, "Crossing floor is not flush")
			else:
				_check(absf(box.size.y - 0.6) < 0.001, "Rail height mismatch")
	_check(body_count == 8, "Expected six floors and two rails")
	_check(crossings.get_node("moonwood-sand-ford").get_meta("source_cell_range") == "x89..95,y29..31", "Ford terrain provenance missing")
	_check(crossings.rail_rects[1].position.y - crossings.rail_rects[0].end.y >= 1.6, "Bridge usable width below contract")
	var clearance_count: int = 0
	for route: Rect2 in [Rect2(93, -1.5, 10, 2), Rect2(66, 11.5, 9, 2)]:
		for zi: int in range(21):
			for xi: int in range(roundi(route.size.x * 10) + 1):
				var point: Vector3 = Vector3(route.position.x + xi * 0.1, 0, route.position.y + zi * 0.1)
				var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
				query.shape = capsule
				query.transform = Transform3D(Basis.IDENTITY, point + Vector3.UP * 0.82)
				query.collision_mask = 1
				_check(space.intersect_shape(query).is_empty(), "Crossing capsule clearance: " + str(point))
				var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point + Vector3.UP * 0.1, point + Vector3.DOWN * 0.1, 1))
				_check(not hit.is_empty() and absf(hit.position.y) < 0.005 and hit.normal.y > 0.99, "Crossing floor gap: " + str(point))
				clearance_count += 1
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-start")).is_empty(), "Start pad regressed")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-from-tollworks")).is_empty(), "Return pad regressed")
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true
	var runs: int = 0
	# Sweep 21 walking lanes and five dodge lanes, both directions; near-edge
	# paths exercise rail ends and landing joins, not only the easy centre line.
	for route: Dictionary in [{"id": "bridge", "west": 93.0, "east": 103.0, "z": -1.5}, {"id": "ford", "west": 66.0, "east": 75.0, "z": 11.5}]:
		for lane: int in range(21):
			for sign_value: int in [-1, 1]:
				for dodge: bool in [false, true]:
					if dodge and lane % 5 != 0:
						continue
					var start: Vector3 = Vector3(route.west if sign_value == 1 else route.east, 0, route.z + lane * 0.1)
					var target_x: float = route.east if sign_value == 1 else route.west
					hero.global_position = start
					hero.velocity = Vector3.ZERO
					hero.combat.cancel()
					hero.move_direction(Vector3.RIGHT * sign_value)
					await physics_frame
					if dodge:
						_check(hero.request_dodge(Vector3.RIGHT * sign_value), "Crossing fixture dodge rejected")
					for step: int in range(170):
						var previous: Vector3 = hero.global_position
						hero._physics_process(1.0 / 60.0)
						_audit_motion(previous, hero.global_position, location.water_blockers)
						if (hero.global_position.x - target_x) * sign_value >= 0:
							break
					_check((hero.global_position.x - target_x) * sign_value >= -0.01, "Crossing snag: %s lane%d dir%d dodge%s" % [route.id, lane, sign_value, dodge])
					_check(absf(hero.global_position.z - start.z) < 0.01, "Crossing pushed hero sideways")
					runs += 1
	# Deliberate diagonals touch each rail, then slide lengthwise past its end.
	for side: int in [-1, 1]:
		for sign_value: int in [-1, 1]:
			hero.global_position = Vector3(94 if sign_value == 1 else 102, 0, -0.5)
			hero.velocity = Vector3.ZERO
			hero.combat.cancel()
			hero.move_direction(Vector3(sign_value, 0, side).normalized())
			await physics_frame
			var rail_contact: bool = false
			for step: int in range(200):
				var previous: Vector3 = hero.global_position
				hero._physics_process(1.0 / 60.0)
				_audit_motion(previous, hero.global_position, location.water_blockers)
				for contact: int in range(hero.get_slide_collision_count()):
					rail_contact = rail_contact or str(hero.get_slide_collision(contact).get_collider().name).ends_with("Rail")
			_check(rail_contact, "Diagonal fixture missed rail")
			_check(hero.global_position.x > 102 if sign_value == 1 else hero.global_position.x < 94, "Rail end snag")
	_check(location.water_blockers.records.size() == 90 and location.water_blockers.water_cells.size() == 8766, "Crossings changed authored water inventory")
	print("M005 physics: bodies=", body_count, " clearance/floor probes=", clearance_count, " bidirectional walk/dodge lane runs=", runs, " rail slide runs=4 displacement samples=", sample_count)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M005 map_crossing_checks PASS: pinned registration, flush floors, clear lanes/rail ends, actual bidirectional capsule walk/dodge, no added water route, party pads")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _audit_motion(previous: Vector3, current: Vector3, water: AlderwakeWaterBlockers) -> void:
	_check(absf(current.y) < 0.05, "Hero lost crossing grounding")
	var count: int = maxi(1, ceili(previous.distance_to(current) / 0.1))
	for index: int in range(count + 1):
		var feet: Vector3 = previous.lerp(current, float(index) / count)
		for record: Dictionary in water.records:
			var r: Array = record.rect_xz_m
			_check(not Rect2(r[0], r[1], r[2], r[3]).has_point(Vector2(feet.x, feet.z)), "Hero entered water during crossing")
		sample_count += 1


func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message):
		failures.append(message)
