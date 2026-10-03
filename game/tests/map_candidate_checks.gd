extends SceneTree
## M003 synthetic terrain/physics checks; rendered input evidence is separate.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://tests/map_candidate.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	_check(location != null and location.build_errors.is_empty(), "Candidate did not initialize")
	_check(location.bounds == Rect2(-22, -18, 147, 80), "Full logical bounds differ")
	_check(location.batch_count == 6, "Terrain must use six layer/material batches plus separate water union, not per-cell nodes")
	_check(location.interactables().is_empty() and location.destination_id.is_empty(), "Candidate activated gameplay records")
	_check(game.party.members().size() == 2, "Candidate changed party ownership")
	_check(game.save_repository.path == "user://saves/playtest-map-candidate.json", "Candidate must default to isolated save slot")
	var normal: ContentCatalog = ContentCatalog.new()
	_check(normal.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "Normal catalog broken")
	_check(normal.get_location("candidate-alderwake") == null, "Candidate leaked into normal catalog")
	_check(SaveCodec.validate(SaveCodec.snapshot(game.session), normal).session == null, "Normal save decoder accepted candidate location")
	_check(location.preview_report.ground.counts.grass == 47040, "Empty ground layer lost default grass")
	_check(location.preview_report.terrain.counts == {"cobblestone": 1113, "dirt": 2851, "sand": 1140, "water": 8374}, "Source material inventory differs")
	_check(location.preview_report.decorations.rectangle_count == 183, "1m raw grid marker inventory differs")
	_check(location.preview_report["shoreline-details"].counts.wet_shoreline == 156, "Shoreline inventory differs")
	# Independent source-coordinate probes, read actual emitted mesh triangles.
	_check(_mesh_covers(location, "ground--grass", Vector2(124.75, 61.75)), "Default grass misses far southeast cell")
	_check(_mesh_covers(location, "terrain--sand", Vector2(114.25, -15.75)), "Source terrain cell (272,4) has wrong 0.5m registration")
	_check(_mesh_covers(location, "shoreline-details--wet_shoreline", Vector2(114.25, -12.25)), "Shoreline cell (272,11) registration")
	_check(_mesh_covers(location, "decorations--raw-marker", Vector2(28.5, -13.5)), "Decoration cell (50,4) has wrong 1m center")
	_check(not _mesh_covers(location, "decorations--raw-marker", Vector2(3.25, -15.75)), "Decoration confused 1m grid with terrain 0.5m")
	# Small detached fixture: default, clear and mixed-grid overrides have hand-calculated counts.
	var real_bounds: Rect2 = location.bounds
	location.bounds = Rect2(0, 0, 2, 1)
	var fixture: Dictionary = {"cell_size_m": 0.5, "origin_xz_m": [0, 0],
		"default_paint": {"kind": "centerMaterial", "material": "grass"},
		"cells": [{"cell": [0, 0], "paint": null}, {"cell": [1, 0], "paint": {"kind": "connectedMaterial", "material": "sand"}}]}
	var resolved: Dictionary = location.resolve_layer(fixture)
	_check(resolved.counts == {"grass": 6, "sand": 1}, "Explicit clear/default resolution failed")
	_check(resolved.rectangles[0].rect == Rect2(0.5, 0, 0.5, 0.5), "Fixture coordinate registration")
	fixture.cell_size_m = 1.0
	fixture.cells = [{"cell": [0, 0], "paint": null}]
	_check(location.resolve_layer(fixture).counts == {"grass": 1}, "1m defaults/clear resolution failed")
	location.bounds = real_bounds
	# Raycast centers across all 11,760 gameplay cells; one authoritative flat floor.
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	var floor_count: int = 0
	var excluded_blockers: Array[RID] = []
	for body: Node in location.water_blockers.get_children():
		if body is StaticBody3D:
			excluded_blockers.append(body.get_rid())
	# Town blockers are tested independently; this ray inventory checks the
	# underlying floor, including beneath all independent prop wrappers.
	for wrapper: Node in location.town.get_children():
		if wrapper.has_node("Collision"):
			excluded_blockers.append(wrapper.get_node("Collision").get_rid())
	for z: int in range(-18, 62):
		for x: int in range(-22, 125):
			var feet: Vector3 = Vector3(x + 0.5, 0, z + 0.5)
			var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(feet + Vector3.UP, feet + Vector3.DOWN, 1, excluded_blockers))
			if not hit.is_empty() and absf((hit.position as Vector3).y) < 0.005 and (hit.normal as Vector3).y > 0.99:
				floor_count += 1
	_check(floor_count == 11760, "Flat floor contains holes or wrong heights")
	print("M003 floor probes: ", floor_count)
	# WorldHost verifies both real capsules at both anchors, preserving party identity.
	var hero_id: int = game.player_placeholder.get_instance_id()
	var ally_id: int = game.companion.get_instance_id()
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-start")).is_empty(), "Start pad unsafe")
	_check(game.world_host._placement_errors(location.find_spawn("alderwake-from-tollworks")).is_empty(), "Return pad unsafe")
	_check(game.world_host.request_transition("candidate-alderwake", "alderwake-from-tollworks").is_empty(), "Return anchor request failed")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "Return anchor placement failed")
	location = game.world_host.current_location
	_check(game.player_placeholder.global_position.distance_to(Vector3(107.25, 0, 1.25)) < 0.01, "Hero return position")
	_check(game.companion.global_position.distance_to(Vector3(108.25, 0, 1.25)) < 0.05, "Ally return offset")
	_check(hero_id == game.player_placeholder.get_instance_id() and ally_id == game.companion.get_instance_id(), "Party replaced on candidate reload")
	# Synthetic edge fixtures use actual hero capsule and shared movement/dodge API.
	# Disable hero input and AI; fixture placement is not ordinary-input journey proof.
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	var hero: ActorPlaceholder = game.player_placeholder
	hero.set_physics_process(false)
	hero.player_controlled = false
	hero.combat_enabled = true
	var cases: Array[Dictionary] = [
		{"start": Vector3(-21, 0, 0), "direction": Vector3.LEFT, "axis": "x", "limit": -21.65},
		{"start": Vector3(124, 0, 0), "direction": Vector3.RIGHT, "axis": "x", "limit": 124.65},
		{"start": Vector3(0, 0, -17), "direction": Vector3.FORWARD, "axis": "z", "limit": -17.65},
		{"start": Vector3(0, 0, 61), "direction": Vector3.BACK, "axis": "z", "limit": 61.65},
		{"start": Vector3(-21, 0, -17), "direction": Vector3(-1, 0, -1).normalized(), "axis": "corner", "limit": 0}]
	for test: Dictionary in cases:
		for dodge: bool in [false, true]:
			hero.global_position = test.start
			hero.velocity = Vector3.ZERO
			hero.combat.cancel()
			hero.move_direction(test.direction)
			await physics_frame
			if dodge:
				_check(hero.request_dodge(test.direction), "Synthetic dodge rejected")
			for step: int in range(90):
				hero._physics_process(1.0 / 60.0)
			# Godot contact recovery can penetrate a few millimetres; 1cm margin
			# keeps the capsule center inside, allowing only numerical contact penetration.
			_check(hero.global_position.x >= -21.66 and hero.global_position.x <= 124.66 and hero.global_position.z >= -17.66 and hero.global_position.z <= 61.66, "Capsule escaped perimeter")
			_check(absf(hero.global_position.y) < 0.05, "Hero lost flat floor")
			_check(hero.get_slide_collision_count() > 0, "No perimeter contact")
			print("M003 edge fixture ", test.axis, " dodge=", dodge, " feet=", hero.global_position)
	# Full-width/height real capsule traversal in synthetic physics stepping.
	hero.global_position = Vector3(-20, 0, 60)
	hero.velocity = Vector3.ZERO
	hero.combat.cancel()
	hero.move_direction(Vector3.RIGHT)
	await physics_frame
	for step: int in range(2100):
		hero._physics_process(1.0 / 60.0)
	_check(hero.global_position.x > 119, "Hero cannot traverse full map width")
	hero.move_direction(Vector3.FORWARD)
	for step: int in range(1100):
		hero._physics_process(1.0 / 60.0)
	_check(hero.global_position.z < -12 and absf(hero.global_position.y) < 0.05, "Hero cannot traverse full map depth")
	print("M003 full-footprint synthetic traversal end: ", hero.global_position)
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("M003 map_candidate_checks PASS: batching/defaults/grids/registration/full floor/party pads/save isolation/physical edges and full-footprint movement")
	else:
		for failure: String in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)


func _mesh_covers(location: AlderwakeTerrainPreview, name: String, point: Vector2) -> bool:
	var instance: MeshInstance3D = location.get_node("TerrainVisuals/" + name)
	var arrays: Array = instance.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for index: int in range(0, vertices.size(), 6):
		var min_corner: Vector2 = Vector2(vertices[index].x, vertices[index].z)
		var max_corner: Vector2 = Vector2(vertices[index + 2].x, vertices[index + 2].z)
		if Rect2(min_corner, max_corner - min_corner).has_point(point):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
