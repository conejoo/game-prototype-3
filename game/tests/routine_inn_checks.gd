extends SceneTree
## Synthetic capsule/clock/rollback probes. Ordinary viewport travel has separate renderer.
var game: Node3D
var room: LanternRest
var assertions: int = 0
var failures: PackedStringArray = []
var routes: Array[Dictionary] = []
var sweeps: int = 0
var probe: CharacterBody3D
var capsule: CapsuleShape3D
var excluded: Array[RID] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	_registration_guards()
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0],"production startup")
	if not startup[0]: await _finish(); return
	game._set_paused(true)
	var prior_party: Array[ActorPlaceholder] = game.party.members()
	var original: Dictionary = SaveCodec.snapshot(game.session)
	var entered: PackedStringArray = game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake")
	_check(entered.is_empty(),"zero-affinity production inn request " + str(entered))
	if not entered.is_empty(): await _finish(); return
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0],"production safe inn arrival " + str(arrival[1]))
	if not arrival[0]: await _finish(); return
	room = game.world_host.current_location
	_check(game.party.members() == prior_party,"full persistent party identities")
	_check(game.player_placeholder.global_position.distance_to(Vector3.ZERO) < .08 and game.companion.global_position.distance_to(Vector3(1,0,0)) < .08,"measured safe arrival feet")
	_check(game.session.conversations.snapshot() == original.conversations,"entrance never grants affinity/facts")
	_check(room.npc_contacts.targets.keys() == ["npc-14"],"exactly one actual indoor Della")
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	game._set_paused(false)
	var ready: Dictionary = await TestRunJourney.wait_navigation(room,Vector3.ZERO)
	_check(ready.ok,"exact inn region readiness " + ready.error)
	excluded = [game.player_placeholder.get_rid(),game.companion.get_rid()]
	capsule = CapsuleShape3D.new()
	capsule.radius = .4
	capsule.height = 1.6
	probe = CharacterBody3D.new()
	probe.collision_layer = 0
	probe.collision_mask = 1
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = capsule
	shape.position.y = .8
	probe.add_child(shape)
	room.add_child(probe)
	probe.add_collision_exception_with(game.player_placeholder)
	probe.add_collision_exception_with(game.companion)
	excluded.append(probe.get_rid())
	await physics_frame
	var pins: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/mappings.json"))
	var expected: PackedStringArray = []
	var source_map: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/source/assets/maps/lantern_rest.json"))
	_check(room.layout.colliders.size() == 19 and room.layout.adaptations.is_empty(),"nineteen exact source colliders; no furniture repairs")
	for collider: Dictionary in source_map.colliders:
		var body: StaticBody3D = room.get_node(collider.id)
		var source_rect: Array = [(collider.left-448)/32,(collider.top-672)/32,collider.width/32,collider.height/32]
		_check(body.get_meta("source_rect_xz_m") == source_rect and body.get_meta("runtime_rect_xz_m") == source_rect,"exact source/runtime collider " + collider.id)
		var physical: BoxShape3D = (body.get_child(1) as CollisionShape3D).shape
		_check(is_equal_approx(physical.size.x,source_rect[2]) and is_equal_approx(physical.size.z,source_rect[3]),"actual physics footprint " + collider.id)
	for entry: Dictionary in pins.anchors:
		if entry.source_map_id != "lantern-rest": continue
		expected.append(entry.anchor_id)
		var record: Dictionary = room.find_anchor(room.location_id,entry.anchor_id)
		var feet: Array = entry.proposed_foot_xyz_m
		_check(record.foot == Vector3(feet[0],feet[1],feet[2]),"exact pinned station " + entry.anchor_id)
		var facing: Dictionary = {"north":Vector3.FORWARD,"south":Vector3.BACK,"east":Vector3.RIGHT,"west":Vector3.LEFT}
		_check(record.facing == facing[entry.source_facing],"exact pinned facing " + entry.anchor_id)
		var own: Array[RID] = excluded.duplicate()
		var host_body: StaticBody3D = room.npc_contacts.targets["npc-14"].get_node("ContactBody")
		own.append(host_body.get_rid())
		_check(NpcWorldAdapter.foot_errors(room,record.foot,own).is_empty(),"host capsule supported; only own body excluded")
		_check(not NpcWorldAdapter.foot_errors(room,record.foot,excluded).is_empty(),"host is actual physical blocker")
		_check(room.npc_contacts.targets["npc-14"].global_position == record.foot,"actual host on exact source station")
		var approach: Vector3 = NpcRegistry.find("npc-14").approach
		_audit(_nav(Vector3.ZERO,approach,entry.anchor_id),"arrival-to-host")
		_audit(_nav(approach,Vector3.ZERO,entry.anchor_id+"-return"),"host-to-arrival")
	_check(expected.size() == 1 and room.anchors().size() == 1,"one exact qualified host station")
	_check(room.anchors("lantern-rest").is_empty() and room.find_anchor(room.location_id,"absent").is_empty(),"wrong qualified map/anchor rejects")
	var copy: Array[Dictionary] = room.anchors()
	copy[0].foot = Vector3.INF
	_check(room.anchors()[0].foot.is_finite(),"station metadata detached")
	_check(room.npc_contacts.placement_errors(room,excluded).is_empty(),"real host floor/reach/LOS/party lane validation")
	for stop: Vector3 in [Vector3(-7,0,-5),Vector3(6,0,-4),Vector3(0,0,-16),Vector3(4,0,-12),Vector3(0,0,.65)]:
		_audit(_nav(Vector3.ZERO,stop,str(stop)),"public-inn-lane-"+str(stop))
	for foot: Vector3 in [Vector3(0,0,-20.5),Vector3(-14,0,-10),Vector3(-8,0,2.5),Vector3(7.25,0,-14),Vector3.INF]:
		_check(not NpcWorldAdapter.foot_errors(room,foot,excluded).is_empty(),"wall/bed/cleared floor/nonfinite refusal "+str(foot))
	probe.queue_free()
	await physics_frame
	game.set_process(true)
	game.player_placeholder.set_physics_process(true)
	game.companion.set_physics_process(true)
	game.companion_ai.set_physics_process(true)
	var clock: float = game.session.environment.day_cycle_progress
	for frame: int in range(12): await physics_frame
	_check(game.session.environment.day_cycle_progress > clock,"global clock advances indoors without acceleration")
	game._set_paused(true)
	var sun: DirectionalLight3D = game.get_node("Sun")
	var stable: Transform3D = sun.transform
	var energy: float = sun.light_energy
	for progress: float in [.1,.5,.9]:
		game.session.environment.day_index = 2
		game.session.environment.day_cycle_progress = progress
		game.session.environment.weather_seed = _storm_seed(progress)
		game._present_environment()
		_check(game.session.weather_conditions.has_condition("heavy-rain"),"synthetic storm condition retained globally")
		_check(game.environment_presenter.profile == 0 and sun.transform.is_equal_approx(stable) and sun.light_energy == energy,"indoor lighting ignores exterior time/weather shadows")
		_check(room.find_children("WorldRain","",true,false).is_empty(),"no indoor scene rain; global forecast remains intact")
	var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	_check(TestRunSave.configure(game,"user://saves/r008-inn.json").is_empty(),"startup-safe isolated inn save configuration")
	_check(game.save_run().is_empty(),"manual inn save validates complete current schema")
	_check(game.save_run().is_empty(),"second inn save keeps a validated backup")
	for path: String in [game.save_repository.path,game.save_repository.path+".bak"]:
		_check(FileAccess.file_exists(path),"isolated inn slot exists " + path)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(path),game.catalog,game.npc_catalog)
		_check(decoded.errors.is_empty() and decoded.session != null,"typed inn primary/backup valid " + path)
		if decoded.session != null:
			_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == before,"exact inn identity/environment/all old facts in " + path)
	var old_room: PrototypeLocation = room
	var feet_before: Array = [game.player_placeholder.global_position,game.companion.global_position]
	var definition: LocationDefinition = game.catalog.get_location(room.location_id)
	var scene_before: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/r008/blocked_inn.tscn"
	_check(game.world_host.request_transition(room.location_id,"lantern-rest-from-alderwake").is_empty(),"unsafe inn candidate begins bounded staging")
	var rollback: Array = await game.world_host.transition_finished
	_check(not rollback[0] and str(rollback[1]).contains("obstructed"),"occupied actual inn spawn refuses " + str(rollback[1]))
	definition.scene_path = scene_before
	_check(game.world_host.current_location == old_room and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before and feet_before == [game.player_placeholder.global_position,game.companion.global_position],"failed inn travel restores exact prior room/facts/feet")
	_check(game.world_host.get_child_count() == 1 and NavigationServer3D.map_get_regions(room.get_world_3d().navigation_map).size() == 1,"one room/region after rollback")
	await _finish()

func _registration_guards() -> void:
	_check(NpcRegistry.enabled_for(NpcRegistry.LOCATION).size()==7 and NpcRegistry.enabled_for("prototype-lantern-rest")==PackedStringArray(["npc-14"]) and NpcRegistry.enabled_for("absent").is_empty(),"eight enabled people occupy only declared actual maps")
	for bad: PackedStringArray in [PackedStringArray(["npc-01","npc-01"]),PackedStringArray(["npc-14","npc-14"]),PackedStringArray(["npc-404"])]:
		var candidate: LanternRest=LanternRest.new()
		var adapter: NpcWorldAdapter=NpcWorldAdapter.new()
		_check(not adapter.build(candidate,bad).is_empty() and adapter.targets.is_empty() and adapter.get_child_count()==0,"duplicate/unknown roster rejects atomically even when off-map "+str(bad))
		adapter.free(); candidate.free()
	var impostor: PrototypeLocation=PrototypeLocation.new()
	impostor.location_id="prototype-lantern-rest"
	var adapter: NpcWorldAdapter=NpcWorldAdapter.new()
	_check(not adapter.build(impostor,NpcRegistry.ENABLED).is_empty() and adapter.get_child_count()==0,"claimed indoor map with wrong physical geometry rejects before contact publication")
	adapter.free(); impostor.free()

func _nav(a: Vector3, b: Vector3, label: String) -> PackedVector3Array:
	var path: PackedVector3Array = NavigationServer3D.map_get_path(room.get_world_3d().navigation_map,a,b,true)
	var reachable: bool = path.size() >= 2 and path[0].distance_to(a) < .16 and path[-1].distance_to(b) < .16
	_check(reachable,"reachable exact room leg " + label + " " + str(Array(path)))
	if not reachable: return []
	path[0] = a; path[-1] = b
	return path

func _audit(path: PackedVector3Array, label: String) -> void:
	if path.size() < 2: return
	probe.global_position = Vector3(path[0].x,.02,path[0].z)
	var count: int = 0
	for index: int in range(1,path.size()):
		var steps: int = maxi(1,ceili(path[index-1].distance_to(path[index])/.08))
		for step: int in range(1,steps+1):
			var foot: Vector3 = path[index-1].lerp(path[index],float(step)/steps)
			foot.y = 0
			var foot_errors: PackedStringArray = NpcWorldAdapter.foot_errors(room,foot,excluded)
			_check(foot_errors.is_empty(),"continuous dry capsule footprint " + label + " " + str(foot) + " " + str(foot_errors))
			var collision: KinematicCollision3D = probe.move_and_collide(foot+Vector3.UP*.02-probe.global_position)
			_check(collision == null and probe.global_position.distance_to(foot+Vector3.UP*.02) < .005,"continuous physical capsule sweep " + label + " " + str(foot) + (" hit=" + str(collision.get_collider().name) if collision != null else ""))
			count += 1
			if not foot_errors.is_empty() or collision != null: return
	sweeps += count
	routes.append({"label":label,"path":Array(path),"sweeps":count})

func _storm_seed(progress: float) -> int:
	for seed: int in range(10000):
		var sample: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed,2,progress)
		if sample.condition == WeatherSchedule.Condition.THUNDERSTORM and sample.transition_progress == 1: return seed
	_check(false,"storm fixture seed")
	return 0

func _check(condition: bool, label: String) -> void:
	assertions += 1
	if not condition and not failures.has(label): failures.append(label)

func _finish() -> void:
	_check(TestRunEvidence.write_json("routine-inn.json",{"assertions":assertions,"failures":failures,"routes":routes,"physical_sweeps":sweeps,"provenance":"synthetic 0.4m continuous body sweeps/real host/seeded storms/blocked arrival; separate ordinary input renderer owns door walking"}),"evidence write")
	if is_instance_valid(game): game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("R008 inn: %d assertions, %d sweeps, %d failures" % [assertions,sweeps,failures.size()])
	quit(0 if failures.is_empty() else 1)
