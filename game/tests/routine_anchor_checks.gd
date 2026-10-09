extends SceneTree
## Synthetic geometry/physical sweeps on the real production exterior.
## Own stationary actor is excluded as self, not furniture/other actors.
var game: Node3D
var room: AlderwakeExterior
var failures: PackedStringArray = []
var assertions: int = 0
var samples: int = 0
var routes: Array[Dictionary] = []
var stations: Array[Dictionary] = []
var doors: Array[Dictionary] = []
var capsule: CapsuleShape3D
var probe: CharacterBody3D
var party_excluded: Array[RID] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "production startup")
	if not startup[0]: await _finish(); return
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	room = game.world_host.current_location
	party_excluded = [game.player_placeholder.get_rid(),game.companion.get_rid()]
	var readiness: Dictionary = await TestRunJourney.wait_navigation(room,Vector3.ZERO)
	_check(readiness.ok, "production nav readiness " + readiness.error)
	var before: Dictionary = SaveCodec.snapshot(game.session)
	var camera_before: Transform3D = game.camera_rig.global_transform
	var actor_feet: Array = [game.player_placeholder.global_position,game.companion.global_position]
	var catalog: RoutineContentCatalog = RoutineContentCatalog.new()
	_check(catalog.initialize_path(game.npc_catalog).is_empty(), "R002 immutable catalog")
	_rules(catalog)
	capsule = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	probe = CharacterBody3D.new()
	probe.name = "R006SyntheticCapsuleProbe"
	probe.collision_layer = 0
	probe.collision_mask = 1
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = capsule
	shape.position.y = 0.8
	probe.add_child(shape)
	room.add_child(probe)
	probe.add_collision_exception_with(game.player_placeholder)
	probe.add_collision_exception_with(game.companion)
	await physics_frame
	for entry: Dictionary in RoutineExteriorRegistry.anchors():
		var owner: PrototypeInteractable = room.npc_contacts.targets[entry.npc_id]
		var body: StaticBody3D = owner.get_node("Body" if entry.npc_id == "npc-03" else "ContactBody")
		var excluded: Array[RID] = party_excluded.duplicate()
		excluded.append(body.get_rid())
		excluded.append(probe.get_rid())
		probe.add_collision_exception_with(body)
		_check(NpcWorldAdapter.foot_errors(room,entry.foot,excluded).is_empty(), "station dry/flat/clear " + entry.anchor_id)
		var approach_excluded: Array[RID] = party_excluded.duplicate()
		approach_excluded.append(probe.get_rid())
		_check(NpcWorldAdapter.foot_errors(room,entry.player_approach,approach_excluded).is_empty(), "approach dry/flat/clear with owner present " + entry.anchor_id)
		_check(entry.foot.y == room.elevation.height_at(Vector2(entry.foot.x,entry.foot.z)), "exact station elevation " + entry.anchor_id)
		_check(_sight(entry.player_approach,entry.foot,excluded), "dialogue LOS " + entry.anchor_id)
		_check(entry.player_approach.distance_to(entry.foot) <= 1.7, "dialogue reach " + entry.anchor_id)
		_overlap(entry.foot,0.4,entry.npc_id)
		_overlap(entry.player_approach,0.4,entry.npc_id)
		var path: PackedVector3Array = _nav(Vector3.ZERO,entry.player_approach,entry.anchor_id)
		path.append(entry.foot)
		_audit(path,entry.anchor_id,excluded)
		path.reverse()
		_audit(path,entry.anchor_id+"-return",excluded)
		var source: Dictionary = {}
		var mappings: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/mappings.json"))
		for mapping: Dictionary in mappings.anchors:
			if mapping.source_map_id == "alderwake" and mapping.anchor_id == entry.anchor_id: source = mapping
		stations.append({"anchor_id":entry.anchor_id,"npc_id":entry.npc_id,"source_xz_unchanged":true,"source_foot_units":source.source_foot_units,
			"foot":_xyz(entry.foot),"player_approach":_xyz(entry.player_approach),"facing":_xyz(entry.facing),
			"self_body_excluded":str(body.get_path()),"real_furniture_excluded":false})
		probe.remove_collision_exception_with(body)
	var excluded: Array[RID] = party_excluded.duplicate()
	excluded.append(probe.get_rid())
	for door: Dictionary in RoutineExteriorRegistry.entrances():
		for field: String in ["foot","player_approach","ally_approach","return_foot","return_ally_foot"]:
			var foot: Vector3 = door[field]
			_check(NpcWorldAdapter.foot_errors(room,foot,excluded).is_empty(), "door support/clearance " + door.portal_id+"/"+field)
			_overlap(foot,0.4,"",field.begins_with("return"))
			_audit(_nav(Vector3.ZERO,foot,door.portal_id+"/"+field),door.portal_id+"/"+field,excluded)
		_check(_sight(door.player_approach,door.foot,excluded), "door approach LOS " + door.portal_id)
		_check(door.player_approach.distance_to(door.ally_approach) >= 0.8, "party door approach separation " + door.portal_id)
		_check(door.return_foot.distance_to(door.return_ally_foot) >= 0.8, "party arrival separation " + door.portal_id)
		_check(door.return_ally_foot == door.return_foot+Vector3.RIGHT, "existing WorldHost/Party 1m east arrival contract " + door.portal_id)
		for entry: Dictionary in RoutineExteriorRegistry.anchors():
			_check(door.return_foot.distance_to(entry.foot) >= 0.85 and door.return_ally_foot.distance_to(entry.foot) >= 0.85, "arrival/station separation " + door.portal_id+"/"+entry.anchor_id)
		_check(door.enabled == (door.portal_id == "mayor-vale-home-entrance") and (game.catalog.get_location(door.destination_location_id) != null if door.enabled else game.catalog.get_location(door.destination_location_id) == null), "delivered home enabled; absent inn remains inactive " + door.portal_id)
		doors.append({"portal_id":door.portal_id,"foot":_xyz(door.foot),"approach":_xyz(door.player_approach),"ally_approach":_xyz(door.ally_approach),
			"source_return":_xyz(door.source_return_foot),"return_hero":_xyz(door.return_foot),"return_ally":_xyz(door.return_ally_foot),
			"return_delta_m":door.return_foot.distance_to(door.source_return_foot),"enabled":door.enabled})
	await _negative(excluded)
	_check(SaveCodec.snapshot(game.session) == before, "geometry queries preserve entire durable snapshot")
	_check(game.camera_rig.global_transform == camera_before and actor_feet == [game.player_placeholder.global_position,game.companion.global_position], "queries preserve player/ally/camera")
	_check(room.npc_contacts.targets.size() == 8 and game.party.members().size() == 2, "contacts/party preserved")
	_check(NavigationServer3D.map_get_regions(room.get_world_3d().navigation_map) == [room.navigation_region.get_rid()], "one unchanged navigation region")
	probe.queue_free()
	await physics_frame
	await _finish()

func _rules(catalog: RoutineContentCatalog) -> void:
	var pin: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/mappings.json"))
	var expected: PackedStringArray = []
	for row: Dictionary in pin.anchors:
		if row.source_map_id != "alderwake": continue
		expected.append(row.anchor_id)
		var entry: Dictionary = RoutineExteriorRegistry.find("prototype-alderwake",row.anchor_id)
		_check(not entry.is_empty() and entry.foot == Vector3(row.proposed_foot_xyz_m[0],row.proposed_foot_xyz_m[1],row.proposed_foot_xyz_m[2]), "exact source station " + row.anchor_id)
		var facing: Dictionary = {"west":Vector3.LEFT,"east":Vector3.RIGHT,"south":Vector3.BACK,"north":Vector3.FORWARD}
		_check(entry.facing == facing[row.source_facing], "source facing " + row.anchor_id)
	_check(expected.size() == 11 and RoutineExteriorRegistry.anchors().size() == 11, "exact eleven exterior targets")
	_check(catalog.reference_snapshot().maps[0].anchors == Array(expected), "immutable declared anchor parity")
	for bad: String in ["alderwake","prototype-lantern-rest","prototype-mayor-vale-home",""]:
		_check(RoutineExteriorRegistry.anchors(bad).is_empty() and RoutineExteriorRegistry.find(bad,expected[0]).is_empty() and RoutineExteriorRegistry.entrances(bad).is_empty(), "wrong map rejected " + bad)
	_check(RoutineExteriorRegistry.find(RoutineExteriorRegistry.LOCATION,"missing").is_empty(), "unknown anchor rejected")
	var detached: Array[Dictionary] = RoutineExteriorRegistry.anchors()
	detached[0].foot = Vector3.INF
	detached.clear()
	_check(RoutineExteriorRegistry.find(RoutineExteriorRegistry.LOCATION,expected[0]).foot.is_finite(), "station metadata detached")
	var entrance: Dictionary = RoutineExteriorRegistry.entrance(RoutineExteriorRegistry.LOCATION,"mayor-vale-home-entrance")
	entrance.enabled = false
	_check(RoutineExteriorRegistry.entrance(RoutineExteriorRegistry.LOCATION,"mayor-vale-home-entrance").enabled, "door metadata detached")
	_check(RoutineExteriorRegistry.entrance("prototype-lantern-rest","lantern-rest-entrance-01").is_empty(), "wrong-source entrance rejected")
	for portal: Dictionary in pin.portals:
		if portal.source_map_id != "alderwake": continue
		var actual: Dictionary = RoutineExteriorRegistry.entrance(RoutineExteriorRegistry.LOCATION,portal.id)
		_check(actual.foot == Vector3(portal.source_point_xz_m[0],0,portal.source_point_xz_m[1]) and actual.destination_location_id == portal.destination_location_id and actual.arrival_id == portal.arrival_id, "exact qualified portal " + portal.id)

func _nav(start: Vector3, end: Vector3, label: String) -> PackedVector3Array:
	var path: PackedVector3Array = NavigationServer3D.map_get_path(room.get_world_3d().navigation_map,start,end,true)
	_check(path.size() >= 2 and path[0].distance_to(start) <= 0.3 and path[-1].distance_to(end) <= 0.3, "reachable unsnapped path " + label)
	if path.size() >= 2: path[-1] = end
	return path

func _audit(path: PackedVector3Array, label: String, excluded: Array[RID]) -> void:
	if path.size() < 2: return
	probe.global_position = _height(path[0])+Vector3.UP*0.02 # labeled fixture start only
	var length: float = 0
	var count: int = 0
	for index: int in range(1,path.size()):
		var steps: int = maxi(1,ceili(path[index-1].distance_to(path[index])/0.08))
		for step: int in range(1,steps+1):
			var foot: Vector3 = _height(path[index-1].lerp(path[index],float(step)/steps))
			var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
			query.shape = capsule
			query.transform.origin = foot+Vector3.UP*0.82
			query.collision_mask = 1
			query.exclude = excluded
			_check(room.get_world_3d().direct_space_state.intersect_shape(query).is_empty(), "route capsule clearance " + label + " " + str(foot))
			for offset: Vector3 in [Vector3.ZERO,Vector3(0.4,0,0),Vector3(-0.4,0,0),Vector3(0,0,0.4),Vector3(0,0,-0.4)]:
				var sample: Vector3 = _height(foot+offset)
				var hit: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(sample+Vector3.UP*0.3,sample-Vector3.UP*0.3,1,excluded))
				_check(not hit.is_empty() and hit.normal.y >= 0.9 and absf(hit.position.y-sample.y) <= 0.06 and (hit.collider.get_meta("candidate_walkable_floor",false) or hit.collider.get_meta("aim_ground",false)), "route dry footprint " + label + " " + str(sample))
			var movement: Vector3 = foot+Vector3.UP*0.02-probe.global_position
			length += movement.length()
			var collision: KinematicCollision3D = probe.move_and_collide(movement)
			_check(collision == null and probe.global_position.distance_to(foot+Vector3.UP*0.02) <= 0.005, "continuous physical capsule sweep " + label + " " + str(foot) + (" hit="+str(collision.get_collider()) if collision != null else ""))
			count += 1
			if failures.size() > 100: return
	samples += count
	routes.append({"label":label,"length_m":length,"physical_sweeps":count,"path":Array(path),"endpoint":_xyz(probe.global_position-Vector3.UP*0.02)})

func _overlap(foot: Vector3, radius: float, own_npc: String, future_arrival: bool = false) -> void:
	for target: PrototypeInteractable in room.interactables():
		if target.npc_id == own_npc and not own_npc.is_empty(): continue
		if target.kind in ["gather","pickup","light"] or not target.npc_id.is_empty() or target.instance_id == "alderwake-temporary-companion":
			_check(foot.distance_to(target.global_position) >= radius+0.4, "no resource/lamp/other actor/station overlap " + str(foot)+"/"+target.instance_id)
	for spawn: Node3D in room.get_node("Spawns").get_children():
		# Public return may share a transient player interaction approach. Actual
		# NPC station feet must remain disjoint; no actor reserves both player feet.
		if spawn.stable_id == "alderwake-from-mayor-vale-home":
			for station: Dictionary in RoutineExteriorRegistry.anchors():
				_check(station.foot.distance_to(spawn.global_position) >= .85 and station.foot.distance_to(spawn.global_position+Vector3.RIGHT) >= .85,"delivered return clears actual station " + station.anchor_id)
			continue
		_check(foot.distance_to(spawn.global_position) >= radius+0.35, "no existing arrival overlap " + str(foot)+"/"+spawn.name)
		_check(foot.distance_to(spawn.global_position+Vector3.RIGHT) >= radius+0.35, "no existing ally arrival overlap " + str(foot)+"/"+spawn.name)
	if future_arrival:
		_check(foot.distance_to(Vector3(-2,0,0)) >= radius+0.35, "future arrival clears companion station")

func _sight(a: Vector3, b: Vector3, excluded: Array[RID]) -> bool:
	return room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a+Vector3.UP*0.8,b+Vector3.UP*0.8,1,excluded)).is_empty()

func _negative(excluded: Array[RID]) -> void:
	for foot: Vector3 in [Vector3(35,0,25),Vector3(41,0,24),Vector3(-10,0,25),Vector3(-7,0,2),Vector3(98.5,0,-2.5),Vector3(70.5,0,14.5),Vector3(4,0.5,-5.5),Vector3.INF]:
		_check(not NpcWorldAdapter.foot_errors(room,foot,excluded).is_empty(), "negative water/building/elevation/nonfinite " + str(foot))
	var maris: PrototypeInteractable = room.npc_contacts.targets["npc-03"]
	var self_excluded: Array[RID] = excluded.duplicate()
	self_excluded.append((maris.get_node("Body") as StaticBody3D).get_rid())
	_check(not NpcWorldAdapter.foot_errors(room,Vector3(-7.5,0,11.8),self_excluded).is_empty(), "real bench remains solid with Maris self excluded")
	var bench: CollisionShape3D = maris.get_node("BenchBody/BenchCollision")
	_check(bench.position == Vector3(0,0.425,0.8) and (bench.shape as BoxShape3D).size == Vector3(2.2,0.85,0.7), "original bench geometry retained")
	# Source home return would collide with an NPC at the rain-shelter station.
	var source_return: Vector3 = RoutineExteriorRegistry.entrances()[0].source_return_foot
	_check(source_return == RoutineExteriorRegistry.find(RoutineExteriorRegistry.LOCATION,"edric-rain-shelter").foot, "source arrival/station conflict reproduced")
	var blocker: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = capsule
	shape.position.y = 0.8
	blocker.add_child(shape)
	blocker.position = source_return
	room.add_child(blocker)
	await physics_frame
	_check(not NpcWorldAdapter.foot_errors(room,source_return,excluded).is_empty(), "original return refuses occupied shelter")
	var return_foot: Vector3 = RoutineExteriorRegistry.entrances()[0].return_foot
	_check(NpcWorldAdapter.foot_errors(room,return_foot,excluded).is_empty(), "measured adapted return clears occupied shelter")
	_check(return_foot.distance_to(source_return) >= 0.4+0.4+0.1-0.00001, "minimal conservative radius/gap adaptation")
	blocker.queue_free()
	await physics_frame
	# A thin physical wall blocks the otherwise safe terminal leg. The nav path
	# alone cannot certify a station behind a new dynamic obstruction.
	var wall: StaticBody3D = StaticBody3D.new()
	var wall_shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(1.2,1.6,0.02)
	wall_shape.shape = box
	wall.add_child(wall_shape)
	wall.position = Vector3(-2,0.8,2.55)
	room.add_child(wall)
	await physics_frame
	probe.global_position = Vector3(-2,0.02,3.1)
	var collision: KinematicCollision3D = probe.move_and_collide(Vector3(0,0,-1.1))
	_check(collision != null and collision.get_collider() == wall and probe.global_position.z > 2.9, "thin barrier rejects continuous terminal sweep")
	wall.queue_free()
	await physics_frame

func _height(point: Vector3) -> Vector3:
	return Vector3(point.x,room.elevation.height_at(Vector2(point.x,point.z)),point.z)

func _xyz(point: Vector3) -> Array: return [point.x,point.y,point.z]

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition and not failures.has(label): failures.append(label)

func _finish() -> void:
	_check(TestRunEvidence.write_json("routine-anchors.json", {"task":"R006","assertions":assertions,
		"physical_sweep_samples":samples,"stations":stations,"doors":doors,"routes":routes,"failures":failures,
		"provenance":"synthetic fixture start/0.4m capsule continuous collision sweeps and production nav/physics; own actor excluded as self; real furniture retained; no ordinary input, moving NPC, interior or enabled portal claim"}), "evidence write")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("R006 anchors: %d assertions, %d physical samples, %d failures" % [assertions,samples,failures.size()])
	quit(0 if failures.is_empty() else 1)
