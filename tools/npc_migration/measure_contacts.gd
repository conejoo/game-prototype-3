extends SceneTree
## N001 synthetic physical specification probe. No NPC/game/source activation.
var game: Node3D
var location: AlderwakeExterior
var failures: PackedStringArray = []
var report: Dictionary = {"proof": "synthetic production-geometry probe; no ordinary player/UI/ART acceptance", "contacts": [], "negative_probes": []}
var specs: Array[Dictionary] = [
	{"npc_id":"npc-01", "foot":[-0.5,0,-1.5], "approach":[-0.5,0,-0.5]},
	{"npc_id":"npc-02", "foot":[1.5,0,-1.5], "approach":[2.5,0,-1.5]},
	{"npc_id":"npc-03", "foot":[-7.5,0,11], "approach":[-6,0,11]},
	{"npc_id":"npc-04", "foot":[41,0,17], "approach":[42.5,0,17]},
	{"npc_id":"npc-06", "foot":[7.5,0,5], "approach":[9,0,5]},
	{"npc_id":"npc-07", "foot":[36,0,20], "approach":[34.5,0,20]},
	{"npc_id":"npc-08", "foot":[-3.5,0,12], "approach":[-3.5,0,13]},
	{"npc_id":"npc-14", "foot":[-9,0,3.5], "approach":[-9,0,4.5]},
]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrived: Array = await game.world_host.transition_finished
	if not arrived[0]:
		failures.append("production arrival failed: " + str(arrived[1]))
		_finish()
		return
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	location = game.world_host.current_location
	await physics_frame
	await physics_frame
	report["definitions"] = game.catalog.definition_count()
	report["location_id"] = location.location_id
	report["existing_interactions"] = []
	for target: PrototypeInteractable in location.interactables():
		report.existing_interactions.append({"id":target.instance_id,"foot":_plain(target.global_position),"reach":target.reach})
	for spec: Dictionary in specs:
		var foot: Vector3 = _vec(spec.foot)
		var exclusions: Array[RID] = []
		if spec.npc_id == "npc-03": exclusions.append(location.get_node("MarisCounter/Body").get_rid())
		spec["actor_support"] = _safe(foot,exclusions)
		if not spec.actor_support.errors.is_empty(): failures.append(spec.npc_id + " actor: " + str(spec.actor_support.errors))
		if spec.npc_id != "npc-03":
			location.service_outlines.append(Rect2(foot.x-.4,foot.z-.4,.8,.8))
	# Rebuild task-owned in-memory navigation with every future contact reservation.
	location.navigation_region.free()
	location.navigation_region = null
	var nav_errors: PackedStringArray = location.prepare_navigation()
	failures.append_array(nav_errors)
	await process_frame
	await process_frame
	await physics_frame
	var map: RID = location.get_world_3d().navigation_map
	NavigationServer3D.region_set_map(location.navigation_region.get_rid(),map)
	NavigationServer3D.map_set_active(map,true)
	NavigationServer3D.map_force_update(map)
	failures.append_array(await game.world_host._synchronize_navigation(location,location.find_spawn("alderwake-start")))
	report["reserved_navigation"] = location.navigation_report
	for spec: Dictionary in specs:
		var foot: Vector3 = _vec(spec.foot)
		var approach: Vector3 = _vec(spec.approach)
		var safety: Dictionary = _safe(approach)
		if not safety.errors.is_empty(): failures.append(spec.npc_id + " approach: " + str(safety.errors))
		var nearest: Vector3 = NavigationServer3D.map_get_closest_point(map,approach)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map,Vector3.ZERO,approach,true)
		var path_errors: PackedStringArray = []
		var length: float = 0
		var samples: int = 0
		if nearest.distance_to(approach) > .3 or path.size()<2 or path[-1].distance_to(approach)>.3: path_errors.append("no exact reachable approach")
		for i: int in range(1,path.size()):
			var distance: float = path[i-1].distance_to(path[i])
			length += distance
			var steps: int = maxi(1,ceili(distance/.1))
			for step: int in range(steps+1):
				var point: Vector3 = path[i-1].lerp(path[i],float(step)/steps)
				point.y = location.elevation.height_at(Vector2(point.x,point.z))
				var probe: Dictionary = _safe(point)
				for error: String in probe.errors:
					if not path_errors.has(error): path_errors.append(error)
				for other: Dictionary in specs:
					if other.npc_id != "npc-03" and Vector2(point.x-other.foot[0],point.z-other.foot[2]).length() < .8:
						if not path_errors.has("future contact envelope"): path_errors.append("future contact envelope")
				samples += 1
		var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(approach+Vector3.UP*.8,foot+Vector3.UP*.8,1)
		var hit: Dictionary = location.get_world_3d().direct_space_state.intersect_ray(ray)
		var los: bool = hit.is_empty() or spec.npc_id=="npc-03" and location.get_node("MarisCounter").is_ancestor_of(hit.collider)
		if not los: failures.append(spec.npc_id + " blocked LOS")
		if not path_errors.is_empty(): failures.append(spec.npc_id + " path: " + str(path_errors))
		var competitors: Array = []
		for target: PrototypeInteractable in location.interactables():
			var distance: float = target.global_position.distance_to(approach)
			if distance <= target.reach: competitors.append({"id":target.instance_id,"distance_m":distance})
		for other: Dictionary in specs:
			if other.npc_id!=spec.npc_id and _vec(other.foot).distance_to(approach) <= 1.7:
				competitors.append({"id":other.npc_id,"distance_m":_vec(other.foot).distance_to(approach)})
		for competitor: Dictionary in competitors:
			if competitor.id != "npc-03-counter" or spec.npc_id != "npc-03":
				if float(competitor.distance_m) <= approach.distance_to(foot): failures.append(spec.npc_id+" closer/equal interaction " + competitor.id)
		report.contacts.append({"npc_id":spec.npc_id,"actor_foot":spec.foot,"player_approach":spec.approach,"actor_support":spec.actor_support,"approach_support":safety,"nav_distance_m":nearest.distance_to(approach),"path_length_m":length,"path_samples":samples,"path_errors":Array(path_errors),"path":_path(path),"los":los,"interaction_distance_m":approach.distance_to(foot),"competing_targets":competitors})
	for point: Vector3 in [Vector3(35,0,25),Vector3(41,0,24),Vector3(-7,0,2)]:
		var negative: Dictionary = _safe(point)
		report.negative_probes.append({"foot":_plain(point),"errors":negative.errors})
		if negative.errors.is_empty(): failures.append("negative accepted: " + str(point))
	_finish()

func _safe(foot: Vector3, exclusions: Array[RID] = []) -> Dictionary:
	var errors: PackedStringArray = []
	var support: Array = []
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	for offset: Vector3 in [Vector3.ZERO,Vector3(.4,0,0),Vector3(-.4,0,0),Vector3(0,0,.4),Vector3(0,0,-.4),Vector3(.28,0,.28),Vector3(-.28,0,.28),Vector3(.28,0,-.28),Vector3(-.28,0,-.28)]:
		var point: Vector3 = foot+offset
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point+Vector3.UP*.3,point-Vector3.UP*.3,1,exclusions))
		if hit.is_empty() or hit.normal.y<.9 or absf(hit.position.y-foot.y)>.06:
			errors.append("unsupported/steep foot")
			continue
		var body: Node = hit.collider
		if not body.get_meta("candidate_walkable_floor",false) and not body.get_meta("aim_ground",false): errors.append("not dry floor")
		support.append({"height_m":hit.position.y,"body":str(body.get_path())})
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius=.4
	capsule.height=1.6
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape=capsule
	query.transform.origin=foot+Vector3.UP*.82
	query.collision_mask=1
	query.exclude=exclusions
	var hits: Array[Dictionary] = space.intersect_shape(query)
	for hit: Dictionary in hits: errors.append("capsule blocked: "+str(hit.collider.get_path()))
	return {"errors":Array(errors),"support":support}

func _vec(a: Array) -> Vector3: return Vector3(a[0],a[1],a[2])
func _plain(v: Vector3) -> Array: return [v.x,v.y,v.z]
func _path(points: PackedVector3Array) -> Array:
	var result: Array=[]
	for point: Vector3 in points: result.append(_plain(point))
	return result
func _finish() -> void:
	report["failures"] = Array(failures)
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var path: String = args[0] if not args.is_empty() else ""
	if path.is_empty():
		push_error("explicit evidence output required")
		quit(2)
		return
	var output: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"\t")+"\n")
	output.close()
	print("N001_PLACEMENT ","PASS" if failures.is_empty() else "FAIL", " contacts=",report.contacts.size()," failures=",failures)
	if game!=null: game.free()
	quit(0 if failures.is_empty() else 1)
