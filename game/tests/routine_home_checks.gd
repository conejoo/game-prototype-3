extends SceneTree
## Synthetic capsule/clock/rollback probes. Ordinary viewport travel has separate renderer.
var game: Node3D
var room: MayorValeHome
var assertions: int = 0
var failures: PackedStringArray = []
var routes: Array[Dictionary] = []
var sweeps: int = 0
var probe: CharacterBody3D
var capsule: CapsuleShape3D
var excluded: Array[RID] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0],"production startup")
	if not startup[0]: await _finish(); return
	game._set_paused(true)
	var prior_party: Array[ActorPlaceholder] = game.party.members()
	var original: Dictionary = SaveCodec.snapshot(game.session)
	var entered: PackedStringArray = game.world_host.request_transition("prototype-mayor-vale-home","mayor-vale-home-from-alderwake")
	_check(entered.is_empty(),"zero-affinity production home request " + str(entered))
	if not entered.is_empty(): await _finish(); return
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0],"production safe home arrival " + str(arrival[1]))
	if not arrival[0]: await _finish(); return
	room = game.world_host.current_location
	_check(game.party.members() == prior_party,"full persistent party identities")
	_check(game.player_placeholder.global_position.distance_to(Vector3(0,0,-2)) < .08 and game.companion.global_position.distance_to(Vector3(1,0,-2)) < .08,"measured safe arrival feet")
	_check(game.session.conversations.snapshot() == original.conversations,"entrance never grants affinity/facts")
	_check(room.npc_contacts.targets.is_empty(),"no duplicate/fake Vale contacts before routine execution task")
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	game._set_paused(false)
	var ready: Dictionary = await TestRunJourney.wait_navigation(room,Vector3(0,0,-2))
	_check(ready.ok,"exact home region readiness " + ready.error)
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
	var source_map: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/source/assets/maps/mayor_vale_home.json"))
	_check(room.layout.colliders.size() == 32 and room.layout.adaptations.size() == 2,"all source colliders retained; only two measured furniture repairs")
	for collider: Dictionary in source_map.colliders:
		var body: StaticBody3D = room.get_node(collider.id)
		var source_rect: Array = [(collider.left-256)/32,(collider.top-384)/32,collider.width/32,collider.height/32]
		_check(body.get_meta("source_rect_xz_m") == source_rect,"exact original collider provenance " + collider.id)
		if collider.id not in ["bedroom-bed","study-sideboard"]:
			_check(body.get_meta("runtime_rect_xz_m") == source_rect,"all other collider geometry unchanged " + collider.id)
		var shape_node: CollisionShape3D = body.get_child(1)
		var physical: BoxShape3D = shape_node.shape
		var actual: Array = body.get_meta("runtime_rect_xz_m")
		_check(is_equal_approx(physical.size.x,actual[2]) and is_equal_approx(physical.size.z,actual[3]),"real physics footprint matches recorded geometry " + collider.id)
	for entry: Dictionary in pins.anchors:
		if entry.source_map_id != "mayor-vale-home": continue
		expected.append(entry.anchor_id)
		var record: Dictionary = room.find_anchor(room.location_id,entry.anchor_id)
		var feet: Array = entry.proposed_foot_xyz_m
		_check(record.foot == Vector3(feet[0],feet[1],feet[2]),"exact pinned station " + entry.anchor_id)
		var facing: Dictionary = {"north":Vector3.FORWARD,"south":Vector3.BACK,"east":Vector3.RIGHT,"west":Vector3.LEFT}
		_check(record.facing == facing[entry.source_facing],"exact pinned facing " + entry.anchor_id)
		_check(NpcWorldAdapter.foot_errors(room,record.foot,excluded).is_empty(),"0.4m Vale capsule dry/clear at " + entry.anchor_id)
		_audit(_nav(Vector3(0,0,-2),record.foot,entry.anchor_id),"arrival-to-"+entry.anchor_id)
		_audit(_nav(record.foot,Vector3(0,0,-2),entry.anchor_id+"-return"),entry.anchor_id+"-return")
	_check(expected.size() == 9 and room.anchors().size() == 9,"exact nine qualified stations")
	_check(room.anchors("mayor-vale-home").is_empty() and room.find_anchor(room.location_id,"absent").is_empty(),"wrong qualified map/anchor rejects")
	var copy: Array[Dictionary] = room.anchors()
	copy[0].foot = Vector3.INF
	_check(room.anchors()[0].foot.is_finite(),"station metadata detached")
	var audit: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/routine_migration/reference/geometry_audit.json"))
	for leg: Dictionary in audit.consecutive_move_legs:
		if not leg.source.begins_with("mayor-vale-home:") or not leg.destination.begins_with("mayor-vale-home:"): continue
		var a: Vector3 = room.find_anchor(room.location_id,leg.source.get_slice(":",1)).foot
		var b: Vector3 = room.find_anchor(room.location_id,leg.destination.get_slice(":",1)).foot
		_audit(_nav(a,b,leg.routine_id+"/"+leg.step_id),leg.routine_id+"/"+leg.step_id)
	for pair: Array in [["edric-breakfast","helena-breakfast"],["edric-evening-seat","helena-evening-seat"],["edric-rest","helena-rest"],["edric-home-study","helena-archive-desk"]]:
		var a: Vector3 = room.find_anchor(room.location_id,pair[0]).foot
		var b: Vector3 = room.find_anchor(room.location_id,pair[1]).foot
		_check(a.distance_to(b) >= .9,"simultaneous Vale body separation " + str(pair))
		var body: StaticBody3D = StaticBody3D.new()
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.shape = capsule
		collider.position.y = .8
		body.add_child(collider)
		body.position = a
		room.add_child(body)
		await physics_frame
		_check(NpcWorldAdapter.foot_errors(room,b,[probe.get_rid()]).is_empty(),"full party plus both actual Vale capsule bodies fit " + str(pair))
		body.queue_free()
		await physics_frame
	# Collision-negative proof retains real bed, desk, walls and cleared floor.
	for feet: Vector3 in [Vector3(-4.5,0,-1),Vector3(4,0,-1.5),Vector3(.9,0,0),Vector3(3,0,1.5),Vector3.INF]:
		_check(not NpcWorldAdapter.foot_errors(room,feet,excluded).is_empty(),"solid furniture/hall/cleared floor/nonfinite refuses " + str(feet))
	_check(not room.get_node("bedroom-bed").get_meta("source_collider_id","").is_empty(),"bed collision retained")
	_audit(_nav(Vector3(0,0,-2),Vector3(0,0,.25),"public exit approach"),"public exit approach")
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
	_check(TestRunSave.configure(game,"user://saves/r007-home.json").is_empty(),"startup-safe isolated home save configuration")
	_check(game.save_run().is_empty(),"manual home save validates complete current schema")
	_check(game.save_run().is_empty(),"second home save keeps a validated backup")
	for path: String in [game.save_repository.path,game.save_repository.path+".bak"]:
		_check(FileAccess.file_exists(path),"isolated home slot exists " + path)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(path),game.catalog,game.npc_catalog)
		_check(decoded.errors.is_empty() and decoded.session != null,"typed home primary/backup valid " + path)
		if decoded.session != null:
			_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == before,"exact home identity/environment/all old facts in " + path)
	var old_room: PrototypeLocation = room
	var feet_before: Array = [game.player_placeholder.global_position,game.companion.global_position]
	var definition: LocationDefinition = game.catalog.get_location(room.location_id)
	var scene_before: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/r007/blocked_home.tscn"
	_check(game.world_host.request_transition(room.location_id,"mayor-vale-home-from-alderwake").is_empty(),"unsafe home candidate begins bounded staging")
	var rollback: Array = await game.world_host.transition_finished
	_check(not rollback[0] and str(rollback[1]).contains("obstructed"),"occupied actual home spawn refuses " + str(rollback[1]))
	definition.scene_path = scene_before
	_check(game.world_host.current_location == old_room and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before and feet_before == [game.player_placeholder.global_position,game.companion.global_position],"failed home travel restores exact prior room/facts/feet")
	_check(game.world_host.get_child_count() == 1 and NavigationServer3D.map_get_regions(room.get_world_3d().navigation_map).size() == 1,"one room/region after rollback")
	await _finish()

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
			_check(collision == null and probe.global_position.distance_to(foot+Vector3.UP*.02) < .005,"continuous physical Vale sweep " + label + " " + str(foot) + (" hit=" + str(collision.get_collider().name) if collision != null else ""))
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
	_check(TestRunEvidence.write_json("routine-home.json",{"assertions":assertions,"failures":failures,"routes":routes,"physical_sweeps":sweeps,"provenance":"synthetic 0.4m body sweeps/paired Vale capsules/seeded storms/blocked arrival; separate ordinary input renderer owns door walking"}),"evidence write")
	if is_instance_valid(game): game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("R007 home: %d assertions, %d sweeps, %d failures" % [assertions,sweeps,failures.size()])
	quit(0 if failures.is_empty() else 1)
