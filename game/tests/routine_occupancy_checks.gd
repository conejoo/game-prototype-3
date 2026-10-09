extends SceneTree
## Synthetic door/barrier/opposing/party fixtures using actual kinematic collision.
var failures: PackedStringArray=[]
var assertions: int=0
var room: PrototypeLocation
var occupancy: RoutineOccupancy
var targets: Dictionary={}
var movers: Dictionary={}
var outcomes: Array[Dictionary]=[]

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	room=PrototypeLocation.new()
	room.location_id="r009-physical-fixture"
	var floor_body: StaticBody3D=_box(Vector3(0,-.15,0),Vector3(20,.3,20))
	floor_body.set_meta("aim_ground",true)
	room.add_child(floor_body)
	root.add_child(room)
	occupancy=RoutineOccupancy.new()
	_actor("npc-a",Vector3(-2,0,0))
	_actor("npc-b",Vector3(2,0,0))
	await physics_frame
	# Injected deterministic topology; world collision is always authoritative.
	for repeat: int in range(2):
		_place("npc-a",Vector3(-2,0,0)); _place("npc-b",Vector3(2,0,0))
		await physics_frame
		_check(movers["npc-a"].begin(Vector3(2,0,0)) and movers["npc-b"].begin(Vector3(-2,0,0)),"opposing begin")
		for frame: int in range(240):
			movers["npc-a"].step(1.0/60); movers["npc-b"].step(1.0/60)
			await physics_frame
			_check(targets["npc-a"].global_position.distance_to(targets["npc-b"].global_position)>=.8,"opposing never overlap")
			if movers["npc-a"].state==RoutineMovement.State.FAILED and movers["npc-b"].state==RoutineMovement.State.FAILED: break
		var result: Dictionary={"a":str(targets["npc-a"].global_position),"b":str(targets["npc-b"].global_position),"af":movers["npc-a"].failure,"bf":movers["npc-b"].failure,"queries":movers["npc-a"].path_requests}
		outcomes.append(result)
		_check(result.af==RoutineMovement.Failure.BLOCKED and result.bf==RoutineMovement.Failure.BLOCKED,"opposing bounded typed blocked failure")
		_check(movers["npc-a"].repaths==2 and movers["npc-a"].path_requests==3 and movers["npc-a"].blocked_seconds<=1.50001,"0.5s/two repaths/1.5s bound")
	_check(outcomes[0]==outcomes[1],"opposing deterministic exact repeat")
	for blocker: String in ["hero","ally"]:
		_place("npc-a",Vector3(-2,0,0)); _place("npc-b",Vector3(6,0,6))
		var party: CharacterBody3D=CharacterBody3D.new()
		var shape: CollisionShape3D=CollisionShape3D.new()
		var capsule: CapsuleShape3D=CapsuleShape3D.new(); capsule.radius=.35; capsule.height=1.6
		shape.shape=capsule; shape.position.y=.8; party.add_child(shape)
		room.add_child(party); party.position=Vector3(0,0,0)
		_check(occupancy.bind(blocker,party,.35),"injected "+blocker)
		await physics_frame
		_check(movers["npc-a"].begin(Vector3(2,0,0)),"party-blocked begin")
		await _settle("npc-a")
		_check(movers["npc-a"].failure==RoutineMovement.Failure.BLOCKED and targets["npc-a"].global_position.x<=-.76,"party collider respected "+blocker)
		occupancy.unbind(blocker); party.queue_free(); await physics_frame
	# Thin static barrier cannot be ghosted by a huge delta or injected route.
	_place("npc-a",Vector3(-2,0,0))
	var wall: StaticBody3D=_box(Vector3(0,1,0),Vector3(.1,2,8))
	room.add_child(wall); await physics_frame
	_check(movers["npc-a"].begin(Vector3(2,0,0)),"physical barrier begin")
	await _settle("npc-a",1e20)
	_check(targets["npc-a"].global_position.x<-.4 and movers["npc-a"].failure==RoutineMovement.Failure.BLOCKED,"thin barrier/hugedelta never penetrates")
	wall.queue_free(); await physics_frame
	# A narrow doorway is a real physics failure, a wider door succeeds.
	for width: float in [.6,1.4]:
		_place("npc-a",Vector3(-2,0,0))
		var upper: StaticBody3D=_box(Vector3(0,1,2+width/2),Vector3(.2,2,4))
		var lower: StaticBody3D=_box(Vector3(0,1,-2-width/2),Vector3(.2,2,4))
		room.add_child(upper); room.add_child(lower); await physics_frame
		_check(movers["npc-a"].begin(Vector3(2,0,0)),"door begin")
		await _settle("npc-a")
		_check(movers["npc-a"].state==(RoutineMovement.State.FAILED if width<.8 else RoutineMovement.State.ARRIVED),"actual capsule doorway "+str(width))
		upper.queue_free(); lower.queue_free(); await physics_frame
	_place("npc-a",Vector3(-2,0,0)); _place("npc-b",Vector3(2,0,0)); await physics_frame
	_check(movers["npc-a"].begin(Vector3.ZERO) and movers["npc-b"].begin(Vector3.ZERO),"station contention queued")
	_check(occupancy.snapshot().reservations.keys()==["npc-a"],"first accepted exclusive station wins")
	movers["npc-a"].cancel(); movers["npc-b"].step(.1)
	_check(occupancy.snapshot().reservations.keys()==["npc-b"],"cancel releases station to waiter")
	movers["npc-b"].dispose()
	_check(not occupancy.snapshot().reservations.has("npc-b"),"dispose releases waiter reservation")
	var target: PrototypeInteractable=targets["npc-a"]
	_check(movers["npc-a"].begin(Vector3(0,0,4)),"unload active leg")
	target.queue_free(); await physics_frame
	movers["npc-a"].step(.1)
	_check(movers["npc-a"].failure==RoutineMovement.Failure.DISPOSED and occupancy.snapshot().reservations.is_empty(),"freed wrapper prunes weak body and fails safely")
	occupancy.clear()
	_check(occupancy.snapshot().bodies==0,"scene cleanup no occupancy growth")
	_check(TestRunEvidence.write_json("occupancy.json",{"task":"R009","assertions":assertions,"outcomes":outcomes,"failures":failures,"provenance":"synthetic injected route topology and barrier/door/party bodies; real kinematic collision"}),"evidence")
	room.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R009 occupancy %d assertions %d failures" % [assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)

func _actor(id: String, foot: Vector3) -> void:
	var target: PrototypeInteractable=PrototypeInteractable.new()
	room.add_child(target); target.position=foot
	var body: CharacterBody3D=CharacterBody3D.new()
	var shape: CollisionShape3D=CollisionShape3D.new()
	var capsule: CapsuleShape3D=CapsuleShape3D.new(); capsule.radius=.4; capsule.height=1.6
	shape.shape=capsule; shape.position.y=.8; body.add_child(shape); target.add_child(body)
	var mover: RoutineMovement=RoutineMovement.new()
	_check(mover.configure(id,target,body,room,occupancy,.4,func(a: Vector3,b: Vector3)->PackedVector3Array: return [a,b]),"injected binding")
	targets[id]=target; movers[id]=mover

func _place(id: String, foot: Vector3) -> void:
	movers[id].cancel(); targets[id].position=foot

func _settle(id: String, dt: float=1.0/60) -> void:
	for frame: int in range(360):
		if movers[id].state not in [RoutineMovement.State.MOVING,RoutineMovement.State.WAITING]: break
		movers[id].step(dt); await physics_frame
	_check(movers[id].state in [RoutineMovement.State.ARRIVED,RoutineMovement.State.FAILED],"finite termination")
	_check(movers[id].path_requests<=3 and movers[id].repaths<=2,"bounded queries")

func _box(point: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D=StaticBody3D.new(); body.position=point
	var shape: CollisionShape3D=CollisionShape3D.new()
	var box: BoxShape3D=BoxShape3D.new(); box.size=size; shape.shape=box; body.add_child(shape)
	return body

func _check(ok: bool, label: String) -> void:
	assertions+=1
	if not ok: failures.append(label)
