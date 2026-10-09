extends SceneTree
## N006 synthetic activation/positions on production geometry; no ordinary/art claim.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var samples: int = 0
var contacts: Array[Dictionary] = []
var observed_gather: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "default arrival")
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	_check(game.world_host.current_location.npc_contacts.targets.keys() == Array(NpcRegistry.enabled_for(NpcRegistry.LOCATION)), "production activation matches completed registry")
	var ids: PackedStringArray = []
	for entry: Dictionary in NpcRegistry.entries(): ids.append(entry.npc_id)
	game.world_host.enabled_npcs = ids
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(), "synthetic all-eight transition")
	arrival = await game.world_host.transition_finished
	_check(arrival[0], "all-eight placement: " + str(arrival[1]))
	if not arrival[0]: await _finish(); return
	var room: AlderwakeExterior = game.world_host.current_location
	_check(room.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and room.get_node("MarisCounter") == room.npc_contacts.targets["npc-03"], "one wrapper per person; reuse Maris")
	_check(game.party.members().size() == 2, "NPCs outside party")
	var excluded: Array[RID] = [game.player_placeholder.get_rid(),game.companion.get_rid()]
	_check(room.npc_contacts.placement_errors(room,excluded).is_empty(), "all contact footprints/navigation/LOS")
	var pin: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/npc_migration/reference/contact_registry.json"))
	for entry: Dictionary in NpcRegistry.entries(NpcRegistry.LOCATION):
		var target: PrototypeInteractable = room.npc_contacts.targets[entry.npc_id]
		var source: Dictionary
		for candidate: Dictionary in pin.contacts:
			if candidate.npc_id == entry.npc_id: source = candidate
		_check(target.global_position == Vector3(source.target_foot_m[0],source.target_foot_m[1],source.target_foot_m[2]) and target.instance_id == source.target_wrapper_id and entry.approach == Vector3(source.player_approach_m[0],source.player_approach_m[1],source.player_approach_m[2]), "pinned contact parity " + entry.npc_id)
		_check(target.validation_errors(game.catalog).is_empty(), "typed identity " + entry.npc_id)
		game.player_placeholder.global_position = entry.approach
		game.companion.global_position = Vector3(0,0,0)
		await physics_frame
		_check(InteractionSelector.select(game.player_placeholder,room) == target, "nearest approach " + entry.npc_id)
		_check(game.interact().ok and game.dialogue.snapshot().npc_id == entry.npc_id and game.dialogue.snapshot().instance_id == entry.instance_id, "root source graph binding " + entry.npc_id)
		if entry.npc_id == "npc-03": _check(game._switch_maris_route(game.dialogue.snapshot()).ok, "existing counter ordinary route")
		var view: Dictionary = game.dialogue.snapshot()
		var choice_id: String = view.choices[0].id
		var choice_before: int = game.session.conversations.events().count(NpcEventMemory.CHOICE,entry.npc_id,choice_id)
		_check(game._choose_dialogue(choice_id,view).ok and game.session.conversations.events().count(NpcEventMemory.CHOICE,entry.npc_id,choice_id) == choice_before+1, "root choice records exact subject/target " + entry.npc_id)
		var chosen: Dictionary = game.session.conversations.snapshot()
		_check(not game._choose_dialogue(choice_id,view).ok and game.session.conversations.snapshot() == chosen, "stale world choice no replay " + entry.npc_id)
		game._cancel_dialogue()
		contacts.append({"npc_id":entry.npc_id,"instance_id":entry.instance_id,"path_samples":_audit_path(room,entry.approach,excluded)})
	await _indoor_host()
	room = game.world_host.current_location
	# Fixed contact crowd must preserve all established critical routes.
	for goal: Vector3 in [Vector3(93,0,-0.5),Vector3(103,0,-0.5),Vector3(66,0,12.5),Vector3(75,0,12.5),Vector3(31.51317596435547,0.5,5.25),Vector3(107.25,0,-1.25),Vector3(121.5,0,-7),Vector3(-6,0,11.5)]:
		_audit_path(room,goal,excluded)
	for point: Vector3 in [Vector3(35,0,25),Vector3(41,0,24),Vector3(-7,0,2)]:
		_check(not NpcWorldAdapter.foot_errors(room,point,excluded).is_empty(), "water/building negative")
	# Equal-distance civic targets use stable ID regardless of traversal order.
	await _existing_contacts(room,excluded)
	game.player_placeholder.global_position = Vector3(0.5,0,-1.5)
	await physics_frame
	_check(InteractionSelector.select(game.player_placeholder,room) == room.npc_contacts.targets["npc-01"], "equal distance stable identity")
	var old_room: WeakRef = weakref(room)
	await _events(room)
	await _lifecycle(old_room)
	_rule_failures()
	await _finish()

func _indoor_host() -> void:
	var town: WeakRef = weakref(game.world_host.current_location)
	_check(not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"no invisible town host")
	_check(game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(),"actual-map host access")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0] and town.get_ref()==null,"host access disposes old town owner")
	if not arrival[0]: return
	var room: PrototypeLocation=game.world_host.current_location
	var entry: Dictionary=NpcRegistry.find("npc-14")
	_check(room.npc_contacts.targets.keys()==["npc-14"] and entry.location_id==room.location_id,"one host on actual map")
	var target: PrototypeInteractable=room.npc_contacts.targets["npc-14"]
	_check(target.global_position==Vector3(-6,0,-12) and target.instance_id=="della-inn-host-01","exact source-qualified host")
	var excluded: Array[RID]=[game.player_placeholder.get_rid(),game.companion.get_rid()]
	_check(room.npc_contacts.placement_errors(room,excluded).is_empty(),"real indoor host support/navigation/LOS")
	game.player_placeholder.global_position=entry.approach
	await physics_frame
	_check(InteractionSelector.select(game.player_placeholder,room)==target and game.interact().ok,"real selected indoor host/root binding")
	var snap: Dictionary=game.dialogue.snapshot()
	_check(snap.npc_id=="npc-14" and snap.instance_id==entry.instance_id,"real indoor identity")
	_check(game._choose_dialogue(snap.choices[0].id,snap).ok,"existing source host choice")
	game._cancel_dialogue()
	contacts.append({"npc_id":"npc-14","instance_id":entry.instance_id,"location_id":room.location_id,"physical_access":"actual map transition/validated capsule/nav/LOS/root binding"})
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-from-lantern-rest").is_empty(),"host return through declared arrival")
	_check((await game.world_host.transition_finished)[0] and not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"host remains only indoors after real return")

func _audit_path(room: AlderwakeExterior, end: Vector3, excluded: Array[RID]) -> int:
	# R009 navigation contains static terrain/furniture only. Transient body
	# blocking is verified by routine_movement/occupancy_checks, not baked holes.
	var static_excluded: Array[RID]=excluded.duplicate()
	for id: String in room.npc_contacts.targets:
		var target: PrototypeInteractable=room.npc_contacts.targets[id]
		static_excluded.append((target.get_node("Body" if id=="npc-03" else "ContactBody") as CharacterBody3D).get_rid())
	var path: PackedVector3Array = NavigationServer3D.map_get_path(room.get_world_3d().navigation_map,Vector3.ZERO,end,true)
	_check(path.size() >= 2 and path[-1].distance_to(end) < 0.3, "reachable path " + str(end))
	var count: int = 0
	for i: int in range(1,path.size()):
		var steps: int = maxi(1,ceili(path[i-1].distance_to(path[i])/0.1))
		for step: int in range(steps+1):
			var point: Vector3 = path[i-1].lerp(path[i],float(step)/steps)
			point.y = room.elevation.height_at(Vector2(point.x,point.z))
			_check(_route_safe(room,point,static_excluded), "full static terrain/furniture capsule route support " + str(point))
			count += 1
	samples += count
	return count

func _existing_contacts(room: AlderwakeExterior, excluded: Array[RID]) -> void:
	for target: PrototypeInteractable in room.interactables():
		if target.kind not in ["light","gather","pickup"]: continue
		var reachable: bool = false
		for distance: float in [0.75,1.1,1.4]:
			for direction: Vector3 in [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]:
				var foot: Vector3 = target.global_position+direction*distance
				foot.y = room.elevation.height_at(Vector2(foot.x,foot.z))
				if not NpcWorldAdapter.foot_errors(room,foot,excluded).is_empty(): continue
				game.player_placeholder.global_position = foot
				await physics_frame
				if InteractionSelector.select(game.player_placeholder,room) == target:
					reachable = true
					break
			if reachable: break
		_check(reachable, "all-eight crowd retains deterministic existing contact " + target.instance_id)

func _route_safe(room: AlderwakeExterior, point: Vector3, excluded: Array[RID]) -> bool:
	# Walking routes follow authored ramp heights; fixed contact feet require flat
	# nine-point support via placement_errors above. Keep full capsule clearance.
	var space: PhysicsDirectSpaceState3D = room.get_world_3d().direct_space_state
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = point+Vector3.UP*0.82
	query.collision_mask = 1
	query.exclude = excluded
	if not space.intersect_shape(query).is_empty(): return false
	for offset: Vector3 in [Vector3.ZERO,Vector3(0.4,0,0),Vector3(-0.4,0,0),Vector3(0,0,0.4),Vector3(0,0,-0.4)]:
		var foot: Vector3 = point+offset
		foot.y = room.elevation.height_at(Vector2(foot.x,foot.z))
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(foot+Vector3.UP*0.3,foot-Vector3.UP*0.3,1,excluded))
		if hit.is_empty() or hit.normal.y < 0.9 or absf(hit.position.y-foot.y) > 0.06: return false
		if not hit.collider.get_meta("candidate_walkable_floor",false) and not hit.collider.get_meta("aim_ground",false): return false
	return true

func _count(kind: String, subject: String) -> int:
	return game.session.conversations.events().count(kind,subject,null)

func _events(room: AlderwakeExterior) -> void:
	game.player_placeholder.global_position = Vector3(24.8,0.25,-2)
	room.npc_events.bind(game.session,room,game.player_placeholder.global_position)
	var before: int = _count(NpcEventMemory.AREA,"woods")
	# Actual capsule moves across boundary; root observes physical position.
	for step: int in range(12):
		game.player_placeholder.move_and_collide(Vector3(0.05,0,0))
		game._process(0)
		await physics_frame
	_check(_count(NpcEventMemory.AREA,"woods") == before+1, "one actual physical crossing")
	for frame: int in range(20): game._process(0)
	_check(_count(NpcEventMemory.AREA,"woods") == before+1, "standing frames do not count")
	room.npc_events.bind(game.session,room,game.player_placeholder.global_position)
	game._process(0)
	_check(_count(NpcEventMemory.AREA,"woods") == before+1, "inside restoration seeds only")
	# Overlapping woods rectangles do not count as exiting their union.
	_check(NpcWorldEvents.contains_woods(room,Vector3(111,0,20)), "nested woods member")
	game.player_placeholder.global_position = Vector3(111,0,20)
	game._process(0)
	_check(_count(NpcEventMemory.AREA,"woods") == before+1, "overlap union no new edge")
	game.player_placeholder.global_position = Vector3(24.8,0.25,-2)
	game._process(0)
	game.player_placeholder.move_and_collide(Vector3(0.5,0,0))
	game._process(0)
	_check(_count(NpcEventMemory.AREA,"woods") == before+2, "exit/reentry second event")
	game.session.foraging.committed.connect(_observe_gather)
	var first: ForagingCommandResult = game.session.foraging.gather(NpcRegistry.LOCATION,"moonflower-01","resource-moonflower",game.session.foraging.revision())
	_check(first.accepted and _count(NpcEventMemory.GATHER,"moonflower") == 1 and observed_gather == 1, "gather memory atomic before observers")
	var memory: Dictionary = game.session.conversations.snapshot()
	_check(not game.session.foraging.gather(NpcRegistry.LOCATION,"moonflower-01","resource-moonflower",game.session.foraging.revision()).accepted, "repeated gather reject")
	_check(not game.session.foraging.gather(NpcRegistry.LOCATION,"moonflower-02","resource-moonflower",-1).accepted, "stale gather reject")
	_check(game.session.conversations.snapshot() == memory, "failed gathers never record")
	_check(game.session.foraging.pickup(NpcRegistry.LOCATION,ForagingRegistry.ROD_ORIGIN,ForagingRegistry.ROD_RESOURCE,game.session.foraging.revision()).accepted and _count(NpcEventMemory.GATHER,"moonflower") == 1, "rod pickup no flower event")
	game.session.foraging.committed.disconnect(_observe_gather)
	var held_events: Dictionary = game.session.conversations.events().snapshot()
	game._set_paused(true)
	_check(game.save_run().is_empty(), "manual isolated save")
	_check((await game.load_run()).is_empty(), "manual isolated load")
	_check(game.session.conversations.events().snapshot() == held_events, "load exact event memory; no arrival event")
	game._set_paused(false)

func _observe_gather(_revision: int) -> void:
	observed_gather = _count(NpcEventMemory.GATHER,"moonflower")

func _rule_failures() -> void:
	var run: GameSession = GameSession.new()
	_check(run.initialize(game.catalog,NpcRegistry.LOCATION,"alderwake-start","prototype-hero",null,game.npc_catalog).is_empty(), "full bag fixture initialized")
	_check(run.inventory.add("item-moonflower",game.catalog.get_item("item-moonflower").stack_limit).is_empty(), "fill authored flower stack")
	var before: Dictionary = run.foraging.snapshot()
	_check(not run.foraging.gather(NpcRegistry.LOCATION,"moonflower-01","resource-moonflower",run.foraging.revision()).accepted and run.foraging.snapshot() == before and run.conversations.events().snapshot().last_sequence == 0, "full stack gather records no event")
	var capped: GameSession = GameSession.new()
	_check(capped.initialize(game.catalog,NpcRegistry.LOCATION,"alderwake-start","prototype-hero",null,game.npc_catalog).is_empty(), "capped event fixture initialized")
	var event: NpcEventMemory = capped.conversations.events()
	event._last_sequence = NpcEventMemory.MAX_SEQUENCE
	capped.conversations = capped.conversations.with_events(event)
	before = capped.foraging.snapshot()
	_check(not capped.foraging.gather(NpcRegistry.LOCATION,"moonflower-01","resource-moonflower",capped.foraging.revision()).accepted and capped.foraging.snapshot() == before and capped.inventory.count("item-moonflower") == 0, "event cap fails closed before gather mutation")

func _lifecycle(old_room: WeakRef) -> void:
	_check(old_room.get_ref() == null, "old scene freed after load")
	var room: AlderwakeExterior = game.world_host.current_location
	var run: GameSession = game.session
	var old_ref: WeakRef = weakref(room)
	var events: Dictionary = run.conversations.events().snapshot()
	_check(run.foraging.get_signal_connection_list("committed").size() == 1, "one scene listener after restore")
	_check(game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(), "travel out")
	_check((await game.world_host.transition_finished)[0], "travel out placement")
	_check(old_ref.get_ref() == null and game.world_host.current_location.npc_contacts.targets.is_empty(), "old wrappers disposed, foreign scene no villagers")
	_check(run.foraging.get_signal_connection_list("committed").size() == 1, "one listener after travel")
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-from-tollworks").is_empty(), "return inside woods")
	_check((await game.world_host.transition_finished)[0], "return safe")
	game._process(0)
	_check(run.conversations.events().snapshot() == events, "arrival inside woods no crossing")
	room = game.world_host.current_location
	_check(room.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and run.foraging.get_signal_connection_list("committed").size() == 1, "return single wrappers/listener")
	# Malformed staged physical placement must preserve current scene/session/memory.
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(), "stage invalid NPC")
	while game.world_host.get_child_count() == 0 or game.world_host.get_child(0) == room: await process_frame
	var candidate: PrototypeLocation = game.world_host.get_child(0)
	candidate.npc_contacts.targets["npc-01"].position = Vector3(35,0,25)
	var rejected: Array = await game.world_host.transition_finished
	_check(not rejected[0] and not rejected[1].is_empty(), "invalid foot rejected")
	_check(game.world_host.current_location == room and game.session == run and run.conversations.events().snapshot() == events, "placement rollback preserves owners/facts")
	_check(room.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and run.foraging.get_signal_connection_list("committed").size() == 1, "rollback reconnects one owner")
	game.player_placeholder.state.health = 0
	game.retry_encounter()
	_check((await game.world_host.transition_finished)[0], "retry contact reconstruction")
	await process_frame
	_check(game.world_host.current_location.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and run.conversations.events().snapshot() == events and run.foraging.get_signal_connection_list("committed").size() == 1, "retry no duplicate/event")
	var detached: NpcWorldAdapter = NpcWorldAdapter.new()
	_check(not detached.build(game.world_host.current_location,PackedStringArray(["npc-01","npc-01"])).is_empty() and detached.targets.is_empty(), "duplicate activation rejects before publication")
	detached.free()

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)

func _finish() -> void:
	_check(TestRunEvidence.write_json("npc-world.json", {"task":"N006","proof":"synthetic all-eight activation/positions; production physics/navigation, short actual capsule crossing, real root dispatch; no ordinary character/art/native release claim", "assertions":assertions+1,"path_samples":samples,"contacts":contacts,"failures":failures}), "write evidence")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("N006 npc_world_checks ", "PASS" if failures.is_empty() else "FAIL", " assertions=",assertions," samples=",samples)
	quit(0 if failures.is_empty() else 1)
