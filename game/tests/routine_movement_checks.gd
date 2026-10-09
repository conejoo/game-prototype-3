extends SceneTree
## R009 synthetic commands/party setup; real production physics/nav/rig/interaction.
var game: Node3D
var room: PrototypeLocation
var adapter: NpcWorldAdapter
var assertions: int = 0
var samples: int = 0
var failures: PackedStringArray = []
var legs: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0],"production startup")
	if arrival[0]: await _test()
	_check(TestRunEvidence.write_json("movement.json",{"task":"R009","assertions":assertions,"samples":samples,"legs":legs,"failures":failures,"provenance":"synthetic commands/party placement; actual production map/path/physical kinematic body and exported rigs, no ordinary schedule claim"}),"evidence")
	paused = false
	game.queue_free()
	await process_frame
	for error: String in failures: push_error(error)
	print("R009 movement %d assertions %d samples %d failures" % [assertions,samples,failures.size()])
	quit(0 if failures.is_empty() else 1)

func _test() -> void:
	room = game.world_host.current_location
	adapter = room.npc_contacts
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	adapter.set_physics_process(false)
	game.player_placeholder.global_position = Vector3(-15,0,0)
	game.companion.global_position = Vector3(-14,0,0)
	await physics_frame
	game._sync_npc_visuals()
	var before: Dictionary = SaveCodec.snapshot(game.session)
	_check((room as AlderwakeExterior).service_outlines.size()==2,"only real bench and unrelated fixed companion station remain baked")
	for id: String in adapter.targets:
		var body: CharacterBody3D = adapter.targets[id].get_node("Body" if id=="npc-03" else "ContactBody")
		_check(body is CharacterBody3D and not body is ActorPlaceholder,"NPC has noncombatant kinematic body "+id)
		var foot: Vector3=adapter.targets[id].global_position
		_check(NavigationServer3D.map_get_closest_point(room.get_world_3d().navigation_map,foot).distance_to(foot)<.3,"retired static hole gone "+id)
	# The live Helena body occupies Edric's civic return path. Physically clear
	# that lane in this synthetic scenario; blocked outcomes have their own fixture.
	await _walk("npc-02",Vector3(2.5,0,0),"helena-physically-clears-civic-return-lane")
	for anchor: String in ["edric-market-rounds","edric-rain-shelter","edric-river-bank","edric-town-square","passenger-salvage-handoff-01","passenger-booking-ivo-01"]:
		var entry: Dictionary = RoutineExteriorRegistry.find(room.location_id,anchor)
		await _walk(entry.npc_id,entry.foot,anchor)
	await _walk("npc-02",NpcRegistry.find("npc-02").foot,"helena-return-to-source-station")
	for id: String in ["npc-04","npc-06","npc-08"]:
		var entry: Dictionary=NpcRegistry.find(id)
		await _walk(id,entry.approach,id+"-station-lane")
		await _walk(id,entry.foot,id+"-source-station-return")
	var maris: PrototypeInteractable = adapter.targets["npc-03"]
	var bench: Node3D=maris.get_node("BenchBody")
	var bench_before: Transform3D=bench.global_transform
	var gear: Node3D=maris.get_node("VisualRoot/SpecialistGear")
	var gear_before: Transform3D=gear.global_transform
	await _walk("npc-03",Vector3(-6,0,11),"maris-away-from-real-counter")
	_check(bench.global_transform==bench_before and gear.global_transform==gear_before,"counter furniture/gear stays fixed while single Maris walks")
	var excluded: Array[RID]=[(maris.get_node("Body") as CharacterBody3D).get_rid(),game.player_placeholder.get_rid(),game.companion.get_rid()]
	_check(not NpcWorldAdapter.foot_errors(room,Vector3(-7.5,0,11.8),excluded).is_empty(),"actual bench stays solid after actor departure")
	game.player_placeholder.global_position=Vector3(-5,0,11)
	game.companion.global_position=Vector3(-14,0,0)
	await physics_frame
	_check(InteractionSelector.select(game.player_placeholder,room)==maris,"selector follows moved Maris actual feet")
	var barrier: StaticBody3D=StaticBody3D.new()
	var barrier_shape: CollisionShape3D=CollisionShape3D.new()
	var box: BoxShape3D=BoxShape3D.new(); box.size=Vector3(.1,2,2)
	barrier_shape.shape=box; barrier.add_child(barrier_shape); room.add_child(barrier)
	barrier.position=Vector3(-5.5,1,11); await physics_frame
	_check(InteractionSelector.select(game.player_placeholder,room)!=maris,"moved actual feet LOS rejects intervening barrier")
	barrier.queue_free(); await physics_frame
	_check(game.interact().ok,"moved Maris retains existing recovery route")
	game._cancel_dialogue()
	game.player_placeholder.global_position=Vector3(-9,0,11); await physics_frame
	_check(InteractionSelector.select(game.player_placeholder,room)!=maris,"retired registry foot cannot select departed Maris")
	game.player_placeholder.global_position=Vector3(-15,0,0)
	await physics_frame
	await _walk("npc-03",Vector3(-7.5,0,11),"maris-return-to-counter")
	await _holds()
	var mover: RoutineMovement=adapter.movers["npc-07"]
	_check(not mover.begin(Vector3.INF) and mover.failure==RoutineMovement.Failure.INVALID_TARGET,"nonfinite target inert typed failure")
	_check(not mover.begin(Vector3(107.25,0,-2)) and mover.failure==RoutineMovement.Failure.NO_PATH,"disconnected endpoint typed no-path")
	_check(adapter.occupancy.snapshot().reservations.is_empty(),"failed/cancelled legs release reservations")
	_check(SaveCodec.snapshot(game.session)==before,"synthetic movement/holds do not mutate full durable state")
	var old: WeakRef=weakref(adapter)
	var old_occupancy: RoutineOccupancy=adapter.occupancy
	var old_mover: RoutineMovement=adapter.movers["npc-07"]
	_check(adapter.move_to("npc-07",Vector3(31,0,20)),"active reserved leg before unload")
	_check(game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(),"real inn transition")
	var arrival: Array=await game.world_host.transition_finished
	_check(arrival[0] and old.get_ref()==null,"unload frees movement owner")
	_check(old_occupancy.snapshot().bodies==0 and old_occupancy.snapshot().reservations.is_empty() and old_mover.failure==RoutineMovement.Failure.DISPOSED,"unload releases all weak bodies/active reservations")
	if not arrival[0]: return
	room=game.world_host.current_location; adapter=room.npc_contacts
	adapter.set_physics_process(false)
	game.player_placeholder.global_position=Vector3(0,0,0); game.companion.global_position=Vector3(1,0,0)
	await physics_frame
	game._sync_npc_visuals()
	_check(NavigationServer3D.map_get_closest_point(room.get_world_3d().navigation_map,Vector3(-6,0,-12)).distance_to(Vector3(-6,0,-12))<.3,"inn retired host hole gone")
	await _walk("npc-14",Vector3(-6,0,-10.8),"della-real-host-door-lane")
	await _walk("npc-14",Vector3(-6,0,-12),"della-real-host-return")
	_check(adapter.targets.size()==1 and game.party.members().size()==2,"one indoor Della/unchanged party")

func _walk(id: String, goal: Vector3, label: String) -> void:
	var mover: RoutineMovement=adapter.movers[id]
	var target: PrototypeInteractable=adapter.targets[id]
	var start: Vector3=target.global_position
	_check(adapter.move_to(id,goal),"begin "+label)
	var max_speed: float=0
	for frame: int in range(1400):
		if mover.state not in [RoutineMovement.State.MOVING,RoutineMovement.State.WAITING]: break
		var previous: Vector3=target.global_position
		adapter._physics_process(.1)
		await physics_frame
		var displacement: float=Vector2(target.global_position.x-previous.x,target.global_position.z-previous.z).length()
		_check(displacement<=.20001,"no snap/speed bound "+label)
		var body: CharacterBody3D=target.get_node("Body" if id=="npc-03" else "ContactBody")
		var own: Array[RID]=[body.get_rid()]
		_check(NpcWorldAdapter.foot_errors(room,target.global_position,own).is_empty(),"actual capsule/terrain clearance "+label+" "+str(target.global_position))
		max_speed=maxf(max_speed,mover.achieved_speed)
		var presenter: NpcVisualPresenter=adapter.presenters[id]
		_check(presenter.player.current_animation==("walk" if mover.achieved_speed>.001 else "idle"),"rig uses achieved motion "+label)
		samples+=1
		if failures.size()>8: break
	_check(mover.state==RoutineMovement.State.ARRIVED and target.global_position.distance_to(goal)<=.005,"arrived "+label+" state="+str(mover.state)+" failure="+str(mover.failure)+" foot="+str(target.global_position))
	_check(mover.path_requests==1 and mover.repaths==0,"unobstructed leg one path request/no per-frame query "+label)
	_check(max_speed<=2.0001 and (max_speed>=1.99 if start.distance_to(goal)>.3 else true),"pinned achieved 2m/s "+label)
	legs.append({"id":id,"label":label,"start":str(start),"goal":str(goal),"actual":str(target.global_position),"state":mover.state,"failure":mover.failure,"queries":mover.path_requests,"repaths":mover.repaths,"max_speed":max_speed})

func _holds() -> void:
	var id: String="npc-07"
	_check(adapter.move_to(id,Vector3(31,0,20)),"hold-test leg")
	var mover: RoutineMovement=adapter.movers[id]
	var target: PrototypeInteractable=adapter.targets[id]
	for reason: String in ["pause","dialogue","modal","focus","death","travel"]:
		var holds: Dictionary={reason:true}
		adapter.sync_visuals(holds,"",game.player_placeholder.global_position,[game.player_placeholder,game.companion])
		var feet: Vector3=target.global_position
		var blocked: float=mover.blocked_seconds
		for frame: int in range(20): adapter._physics_process(.1)
		_check(target.global_position==feet and mover.blocked_seconds==blocked and mover.achieved_speed==0,"hold freezes feet/timer/achieved speed "+reason)
		_check(adapter.presenters[id].suspended(),"hold freezes exported rig "+reason)
		adapter.sync_visuals({reason:false},"",game.player_placeholder.global_position,[game.player_placeholder,game.companion])
	game.window_focused=false; game._sync_npc_visuals()
	var feet: Vector3=target.global_position
	adapter._physics_process(.1)
	_check(target.global_position==feet,"actual root focus gate stops movement")
	game.window_focused=true; game._sync_npc_visuals()
	for property: String in ["journal_open","backpack_open","loading_save","retrying"]:
		game.set(property,true); game._sync_npc_visuals()
		adapter._physics_process(.1)
		_check(target.global_position==feet,"actual root hold "+property)
		game.set(property,false); game._sync_npc_visuals()
	var health: int=game.player_placeholder.state.health
	game.player_placeholder.state.health=0; game._sync_npc_visuals(); adapter._physics_process(.1)
	_check(target.global_position==feet,"actual root death hold")
	game.player_placeholder.state.health=health; game._sync_npc_visuals()
	game._set_paused(true); adapter._physics_process(.1)
	_check(target.global_position==feet,"actual root pause hold")
	game._set_paused(false)
	adapter._physics_process(.1)
	await physics_frame
	_check(target.global_position.distance_to(feet)>0,"resume continues from actual held feet")
	adapter.cancel_move(id)
	_check(mover.state==RoutineMovement.State.CANCELLED and adapter.occupancy.snapshot().reservations.is_empty(),"cancel releases station")

func _check(ok: bool, label: String) -> void:
	assertions+=1
	if not ok: failures.append(label)
