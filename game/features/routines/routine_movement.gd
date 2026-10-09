class_name RoutineMovement
extends RefCounted
## Noncombatant same-map leg. Caller owns physics stepping, holds and scene lifetime.
enum State { IDLE, MOVING, WAITING, ARRIVED, FAILED, CANCELLED }
enum Failure { NONE, INVALID_TARGET, NO_PATH, BLOCKED, UNSUPPORTED, DISPOSED }
const SPEED: float = 2.0 # Pinned 64 source units/s at 32 units/metre.
const WAIT_SECONDS: float = 0.5
const MAX_REPATHS: int = 2
const MAX_BLOCKED_SECONDS: float = 1.5
const ARRIVAL_EPSILON: float = 0.005
var state: State = State.IDLE
var failure: Failure = Failure.NONE
var achieved_speed: float = 0
var achieved_direction: Vector3 = Vector3.ZERO
var path_requests: int = 0
var repaths: int = 0
var blocked_seconds: float = 0
var blocker: String = ""
var goal: Vector3
var _id: String
var _target: WeakRef
var _body: WeakRef
var _location: WeakRef
var _occupancy: RoutineOccupancy
var _query: Callable
var _radius: float
var _path: PackedVector3Array = []
var _index: int = 0
var _wait: float = 0
var _reserved: bool = false

func configure(id: String, target: PrototypeInteractable, body: CharacterBody3D, location: PrototypeLocation, occupancy: RoutineOccupancy, radius: float, query: Callable = Callable()) -> bool:
	if id.is_empty() or not is_instance_valid(target) or not is_instance_valid(body) or not is_instance_valid(location) or occupancy == null or not is_finite(radius) or radius <= 0: return false
	_id = id; _target = weakref(target); _body = weakref(body); _location = weakref(location)
	_occupancy = occupancy; _radius = radius; _query = query
	body.safe_margin = 0.001
	return occupancy.bind(id,body,radius)

func begin(foot: Vector3) -> bool:
	cancel()
	failure = Failure.NONE; path_requests = 0; repaths = 0; blocked_seconds = 0; _wait = 0; blocker = ""
	if not _live(): return _fail(Failure.DISPOSED)
	if not foot.is_finite(): return _fail(Failure.INVALID_TARGET)
	goal = foot
	if not _make_path(): return _fail(Failure.NO_PATH)
	state = State.MOVING
	_reserved = _occupancy.reserve(_id,goal,_radius)
	return true

func cancel() -> void:
	if _occupancy != null: _occupancy.release(_id)
	_reserved = false; achieved_speed = 0; achieved_direction = Vector3.ZERO; _path.clear()
	if _body != null and is_instance_valid(_body.get_ref()): (_body.get_ref() as CharacterBody3D).velocity = Vector3.ZERO
	state = State.CANCELLED

func dispose() -> void:
	cancel()
	if _occupancy != null: _occupancy.unbind(_id)
	failure = Failure.DISPOSED

func step(delta: float, held: bool = false) -> void:
	achieved_speed = 0
	achieved_direction = Vector3.ZERO
	if state not in [State.MOVING,State.WAITING]: return
	if not _live(): _fail(Failure.DISPOSED); return
	var body: CharacterBody3D = _body.get_ref()
	body.velocity = Vector3.ZERO
	if held or not is_finite(delta) or delta <= 0: return
	# A huge finite caller delta cannot bypass physical/timeout bounds.
	var dt: float = minf(delta,0.1)
	if not _reserved:
		_reserved = _occupancy.reserve(_id,goal,_radius)
		if not _reserved: _blocked(dt,"station"); return
	if state == State.WAITING:
		_wait += dt; blocked_seconds += dt
		if blocked_seconds >= MAX_BLOCKED_SECONDS-0.000001: _fail(Failure.BLOCKED); return
		if _wait < WAIT_SECONDS-0.000001: return
		_wait = 0
		if repaths >= MAX_REPATHS: _fail(Failure.BLOCKED); return
		repaths += 1
		if not _make_path(): _fail(Failure.NO_PATH); return
		state = State.MOVING
	var target: PrototypeInteractable = _target.get_ref()
	var current: Vector3 = target.global_position
	while _index < _path.size() and current.distance_to(_path[_index]) <= ARRIVAL_EPSILON: _index += 1
	if _index >= _path.size():
		state = State.ARRIVED; _occupancy.release(_id); _reserved = false
		return
	var direction: Vector3 = _path[_index]-current
	var distance: float = Vector2(direction.x,direction.z).length()
	if distance <= ARRIVAL_EPSILON: _fail(Failure.UNSUPPORTED); return
	var next: Vector3 = current+Vector3(direction.x,0,direction.z).normalized()*minf(SPEED*dt,distance)
	var room: PrototypeLocation = _location.get_ref()
	if room is AlderwakeTerrainPreview:
		next.y = (room as AlderwakeTerrainPreview).elevation.height_at(Vector2(next.x,next.z))
	else: next.y = goal.y
	blocker = _occupancy.blocked(_id,current,next,_radius)
	if not blocker.is_empty(): _blocked(dt,blocker); return
	if not _supported(room,next,body): _fail(Failure.UNSUPPORTED); return
	var collision: KinematicCollision3D = body.move_and_collide(next-current)
	# Translate wrapper by achieved physical displacement. Body's world transform
	# stays unchanged; furniture marked top-level stays at its actual station.
	var achieved: Vector3 = body.global_position-current
	target.global_position += achieved
	body.position = Vector3.ZERO
	achieved_speed = Vector2(achieved.x,achieved.z).length()/dt
	achieved_direction = achieved
	if collision != null or achieved_speed < 0.001:
		_blocked(dt,"physics")
	else:
		state = State.MOVING; blocked_seconds = 0; _wait = 0; blocker = ""

func _blocked(dt: float, reason: String) -> void:
	blocker = reason; state = State.WAITING; _wait += dt; blocked_seconds += dt
	if blocked_seconds >= MAX_BLOCKED_SECONDS-0.000001: _fail(Failure.BLOCKED)

func _make_path() -> bool:
	var room: PrototypeLocation = _location.get_ref()
	var start: Vector3 = (_target.get_ref() as PrototypeInteractable).global_position
	path_requests += 1
	_path = _query.call(start,goal) if _query.is_valid() else NavigationServer3D.map_get_path(room.get_world_3d().navigation_map,start,goal,true)
	_index = 0
	if _path.is_empty() or _path[0].distance_to(start) > 0.3 or _path[-1].distance_to(goal) > 0.3: return false
	for index: int in range(_path.size()):
		if not _path[index].is_finite(): return false
		var point: Vector3 = _path[index]
		point.y = (room as AlderwakeTerrainPreview).elevation.height_at(Vector2(point.x,point.z)) if room is AlderwakeTerrainPreview else goal.y
		_path[index] = point
	# Exact station/feet are physical terminal legs, never a visible endpoint snap.
	_path[0] = start
	if _path[-1] != goal: _path.append(goal)
	return true

func _supported(room: PrototypeLocation, foot: Vector3, body: CharacterBody3D) -> bool:
	var space: PhysicsDirectSpaceState3D = room.get_world_3d().direct_space_state
	for offset: Vector3 in [Vector3.ZERO,Vector3(_radius,0,0),Vector3(-_radius,0,0),Vector3(0,0,_radius),Vector3(0,0,-_radius)]:
		var point: Vector3 = foot+offset
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point+Vector3.UP*0.15,point-Vector3.UP*0.15,1,[body.get_rid()]))
		if hit.is_empty() or hit.normal.y < 0.9 or absf(hit.position.y-foot.y) > 0.11 or not (hit.collider.get_meta("candidate_walkable_floor",false) or hit.collider.get_meta("aim_ground",false)): return false
	return true

func _live() -> bool:
	if _target == null or _body == null or _location == null: return false
	for ref: WeakRef in [_target,_body,_location]:
		var node: Variant = ref.get_ref()
		if not is_instance_valid(node) or not node.is_inside_tree() or node.is_queued_for_deletion(): return false
	return true

func _fail(reason: Failure) -> bool:
	cancel(); state = State.FAILED; failure = reason
	return false
