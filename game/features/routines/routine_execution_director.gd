class_name RoutineExecutionDirector
extends RefCounted
## Root-owned transient execution of the complete production catalog.
const MAX_TOTAL_TRANSITIONS: int = 512
var world: RoutineExecutionWorld = RoutineExecutionWorld.new()
var selector: RoutineAssignmentDirector = RoutineAssignmentDirector.new()
var _catalog: RoutineContentCatalog
var _session: GameSession
var _actors: Dictionary[String,RoutineExecutor] = {}
var _positions: Dictionary = {}
var _location: WeakRef
var _day: int = -1
var last_error: String = ""
var revisions: int = 0
var transfers: Array[Dictionary] = []
var directives: Array[Dictionary] = []
var _night_lane: Dictionary = {}
var _lease: RoutineDialogueContext
var reconciliations: int = 0

func initialize(content: ContentCatalog, npcs: NpcContentCatalog, run: GameSession) -> PackedStringArray:
	if _catalog != null: return ["execution director already initialized"]
	var catalog: RoutineContentCatalog = RoutineContentCatalog.new()
	var errors: PackedStringArray = catalog.initialize_path(npcs)
	if errors.is_empty(): errors = world.initialize(content)
	if errors.is_empty(): errors = selector.initialize(catalog)
	if not errors.is_empty(): return errors
	_catalog = catalog
	var initial: Dictionary = _reconstructed(run)
	if not initial.ok: return [initial.error]
	_publish(initial,run)
	return []

func actor(id: String) -> RoutineExecutor: return _actors.get(id)

func snapshot() -> Dictionary:
	capture_loaded()
	var actors: Dictionary = {}
	for id: String in _actors: actors[id] = _actors[id].snapshot()
	return {"actors":actors,"positions":_positions.duplicate(true),"day":_day,"revisions":revisions,"error":last_error,"group_lane":_night_lane.get("phase","")}

func capture_loaded() -> void:
	var location: PrototypeLocation = _live_location()
	if location == null or location.npc_contacts == null: return
	for id: String in location.npc_contacts.targets:
		var foot: Vector3 = location.npc_contacts.targets[id].global_position
		_positions[id] = {"map":location.location_id,"foot":foot}
		if _actors.has(id): _actors[id].foot = foot; _actors[id].map_id = location.location_id

func stage(run: GameSession) -> Dictionary:
	# Detached candidate for restore; ordinary scene replacement retains real feet,
	# cursors and timers. No candidate can change active execution before commit.
	if run != _session: return _reconstructed(run)
	capture_loaded()
	return {"ok":true,"error":"","actors":_actors,"positions":_positions.duplicate(true),"day":_day}

func placements(candidate: Dictionary, map_id: String) -> Dictionary:
	var result: Dictionary = {}
	for id: String in candidate.positions:
		var position: Dictionary = candidate.positions[id]
		if position.map == map_id:
			result[id] = {"foot":position.foot,"facing":candidate.actors[id].facing if candidate.actors.has(id) else Vector3.BACK}
	return result

func commit(candidate: Dictionary, run: GameSession, location: PrototypeLocation) -> void:
	_publish(candidate,run)
	bind_location(location)

func bind_location(location: PrototypeLocation) -> void:
	if _lease != null: _lease.close()
	_location = weakref(location)
	if not _night_lane.is_empty(): _night_lane.started = false
	# Scene replacement/disposal releases movement bindings. Reissue only the
	# unfinished leg from actual new/restored feet, never restart wait/action time.
	for id: String in _actors:
		var cursor: RoutineExecutor = _actors[id]
		if cursor.current_step() != null and cursor.current_step().kind == RoutineDefinition.StepKind.MOVE and (location.npc_contacts.targets.has(id) or cursor.phase != "offscreen"):
			cursor.phase = ""; cursor.remaining = 0
	capture_loaded()
	for id: String in _actors:
		var cursor: RoutineExecutor = _actors[id]
		if location.npc_contacts.targets.has(id) and cursor.state in [RoutineExecutor.State.WAITING,RoutineExecutor.State.ACTING,RoutineExecutor.State.SPEAKING]:
			location.npc_contacts.occupancy.reserve(id,cursor.foot,.4)

func dispose() -> void:
	if _lease != null: _lease.close()
	var location: PrototypeLocation = _live_location()
	if location != null:
		for id: String in _actors: location.npc_contacts.cancel_move(id)
		location.npc_contacts.clear_routines()
	_actors.clear(); _positions.clear(); _location = null; _session = null
	_night_lane.clear()

func _reconstructed(run: GameSession) -> Dictionary:
	var context: RoutineResolutionContext = RoutineResolutionContext.from_session(run)
	if not context.errors.is_empty(): return {"ok":false,"error":"; ".join(context.errors)}
	var plan: RoutineAssignmentPlan = RoutineResolver.resolve(RoutineResolver.definitions(_catalog),context)
	var actors: Dictionary[String,RoutineExecutor] = {}
	var positions: Dictionary = {}
	var count: int = 0
	for id: String in NpcRegistry.ENABLED:
		var record: Dictionary = NpcRegistry.find(id)
		positions[id] = {"map":record.location_id,"foot":record.foot}
		var definition: RoutineDefinition = _catalog.get_routine(plan.routine_for(id))
		if definition == null: continue
		var cursor: RoutineExecutor = RoutineExecutor.new()
		if not cursor.initialize(definition,id,world.origin(definition.id,id)) or not cursor.reconstruct(plan.elapsed_for(id),world):
			return {"ok":false,"error":"reconstruction refused "+id+" failure="+str(cursor.failure)}
		count += cursor.transitions
		if count > MAX_TOTAL_TRANSITIONS: return {"ok":false,"error":"total reconstruction transition limit"}
		cursor.assignment_day = plan.day_index
		actors[id] = cursor; positions[id] = {"map":cursor.map_id,"foot":cursor.foot}
	return {"ok":true,"error":"","actors":actors,"positions":positions,"day":plan.day_index,"transitions":count}

func _publish(candidate: Dictionary, run: GameSession) -> void:
	if run != _session: _night_lane.clear()
	_actors = candidate.actors; _positions = candidate.positions; _day = candidate.day; _session = run
	revisions += 1

func apply_plan(plan: RoutineAssignmentPlan) -> bool:
	if plan == null: return false
	for id: String in plan.assignments():
		if id not in NpcRegistry.ENABLED: return false
	# A group is accepted or rejected in its entirety, including externally supplied
	# plans; never trust a partial participant dictionary from a caller.
	for routine_id: String in plan.routine_ids():
		var definition: RoutineDefinition = _catalog.get_routine(routine_id)
		if definition == null: return false
		for id: String in definition.participants:
			if plan.routine_for(id) != routine_id: return false
	if _lease != null:
		var assignments: Dictionary = plan.assignments()
		for routine_id: String in plan.routine_ids():
			var definition: RoutineDefinition = _catalog.get_routine(routine_id)
			var conflict: bool = false
			for id: String in definition.participants: conflict = conflict or id in _lease._cursors
			if conflict:
				for id: String in definition.participants: assignments.erase(id)
		for id: String in _lease._cursors: assignments[id] = _lease._data.routine
		plan = RoutineAssignmentPlan.new(plan.day_index,plan.minute_of_day,assignments,{},plan.rejections())
	capture_loaded()
	var candidate: Dictionary[String,RoutineExecutor] = {}
	var changed: PackedStringArray = []
	var day_changed: bool = _day != plan.day_index
	for id: String in NpcRegistry.ENABLED:
		var routine_id: String = plan.routine_for(id)
		var old: RoutineExecutor = _actors.get(id)
		if old != null and old.routine.id == routine_id and (old.assignment_day == plan.day_index or (_lease != null and id in _lease._cursors)):
			candidate[id] = old; continue
		if old == null and routine_id.is_empty(): continue
		changed.append(id)
		if routine_id.is_empty(): continue
		var cursor: RoutineExecutor = RoutineExecutor.new()
		if not cursor.initialize(_catalog.get_routine(routine_id),id,_positions[id]): return false
		cursor.assignment_day = plan.day_index
		candidate[id] = cursor
	var location: PrototypeLocation = _live_location()
	if location != null:
		for id: String in changed: location.npc_contacts.cancel_move(id)
	_actors = candidate; _day = plan.day_index
	if "npc-01" in changed or "npc-02" in changed: _night_lane.clear()
	if not changed.is_empty() or day_changed: revisions += 1
	present()
	return true

func present() -> void:
	var location: PrototypeLocation = _live_location()
	if location == null or location.npc_contacts == null: return
	var loaded: Dictionary = {}
	for id: String in _actors:
		if _actors[id].map_id == location.location_id: loaded[id] = _actors[id]
	location.npc_contacts.present_routines(loaded)

func tick(delta: float, held: bool = false) -> void:
	if held or _session == null or not is_finite(delta) or delta <= 0:
		present()
		return
	capture_loaded()
	var update: Dictionary = selector.update(RoutineResolutionContext.from_session(_session),false)
	if not update.errors.is_empty(): last_error = "; ".join(update.errors); return
	if (not update.changed_participants.is_empty() or _day != update.plan.day_index) and not apply_plan(update.plan):
		last_error = "invalid atomic assignment plan"; return
	_prepare_night_lane()
	var ids: Array = _actors.keys(); ids.sort()
	for id: String in ids:
		var cursor: RoutineExecutor = _actors[id]
		if _lease != null and id in _lease._cursors: continue
		if cursor.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED,RoutineExecutor.State.COMPLETED]: continue
		if not _tick_night_lane(cursor,minf(delta,.1)): _tick_actor(cursor,minf(delta,.1))
		if cursor.state == RoutineExecutor.State.FAILED: _fail_group(cursor)
		_positions[id] = {"map":cursor.map_id,"foot":cursor.foot}

	present()

func _tick_actor(cursor: RoutineExecutor, dt: float) -> void:
	var step: RoutineDefinition.Step = cursor.current_step()
	if step == null: return
	var location: PrototypeLocation = _live_location()
	var loaded: bool = location != null and cursor.map_id == location.location_id and location.npc_contacts.targets.has(cursor.npc_id)
	if step.kind != RoutineDefinition.StepKind.MOVE:
		if cursor.state == RoutineExecutor.State.READY:
			cursor.remaining = step.duration_seconds
			cursor.state = [RoutineExecutor.State.READY,RoutineExecutor.State.WAITING,RoutineExecutor.State.ACTING,RoutineExecutor.State.SPEAKING][step.kind]
			if loaded: location.npc_contacts.occupancy.reserve(cursor.npc_id,cursor.foot,.4)
		cursor.remaining = maxf(0,cursor.remaining-dt)
		if cursor.remaining <= .000001:
			if loaded: location.npc_contacts.occupancy.release(cursor.npc_id)
			cursor.advance_step()
		return
	var target: Dictionary = world.anchor(step.map_id,step.anchor_id)
	if target.is_empty(): cursor.fail(RoutineExecutor.Failure.INVALID_ANCHOR); return
	var route: Dictionary = world.chain(cursor.map_id,step.map_id)
	if not route.ok: cursor.fail(RoutineExecutor.Failure.INVALID_CHAIN); return
	var edge: Dictionary = route.legs[0] if not route.legs.is_empty() else {}
	var goal: Vector3 = world.door(edge) if not edge.is_empty() else target.foot
	if loaded:
		var adapter: NpcWorldAdapter = location.npc_contacts
		if cursor.phase.is_empty() and cursor.foot.distance_to(goal) <= RoutineMovement.ARRIVAL_EPSILON:
			if not edge.is_empty(): _transfer(cursor,edge,dt)
			else: cursor.facing = target.facing; cursor.advance_step()
			return
		if cursor.phase.is_empty():
			if not adapter.move_to(cursor.npc_id,goal): cursor.fail(RoutineExecutor.Failure.MOVEMENT); return
			cursor.phase = "door" if not edge.is_empty() else "target"; cursor.state = RoutineExecutor.State.MOVING
		var mover: RoutineMovement = adapter.movers[cursor.npc_id]
		if mover.state == RoutineMovement.State.FAILED:
			cursor.failure_detail = {"movement_failure":mover.failure,"blocker":mover.blocker,"repaths":mover.repaths,"path_requests":mover.path_requests}
			cursor.fail(RoutineExecutor.Failure.MOVEMENT); return
		if mover.state != RoutineMovement.State.ARRIVED: return
		cursor.foot = adapter.targets[cursor.npc_id].global_position
	else:
		if cursor.phase.is_empty():
			cursor.phase = "offscreen"; cursor.remaining = cursor.foot.distance_to(goal)/RoutineMovement.SPEED
			cursor.state = RoutineExecutor.State.MOVING
		cursor.remaining = maxf(0,cursor.remaining-dt)
		if cursor.remaining > .000001: return
		cursor.foot = goal
	if not edge.is_empty():
		_transfer(cursor,edge,dt)
	else:
		cursor.facing = target.facing
		if loaded and location.npc_contacts.presenters.has(cursor.npc_id): location.npc_contacts.presenters[cursor.npc_id].face_direction(cursor.facing)
		cursor.advance_step()

func _transfer(cursor: RoutineExecutor, edge: Dictionary, dt: float) -> void:
	if world.routes.binding(cursor.map_id,edge.portal_id) != edge or not world.arrival(edge).is_finite():
		cursor.fail(RoutineExecutor.Failure.INVALID_CHAIN); return
	var location: PrototypeLocation = _live_location()
	var destination: Vector3 = world.arrival(edge)
	if location != null and location.location_id == edge.destination_location_id:
		var errors: PackedStringArray = location.npc_contacts.materialize(location,cursor.npc_id,destination,cursor.facing)
		if not errors.is_empty():
			cursor.arrival_wait += dt
			if cursor.arrival_wait >= RoutineMovement.MAX_BLOCKED_SECONDS-.000001:
				last_error = "arrival refused "+cursor.npc_id+": "+"; ".join(errors)
				cursor.fail(RoutineExecutor.Failure.ARRIVAL_BLOCKED)
			return
	if location != null and cursor.map_id == location.location_id:
		location.npc_contacts.dematerialize(cursor.npc_id)
	transfers.append({"npc_id":cursor.npc_id,"source":cursor.map_id,"source_foot":cursor.foot,"destination":edge.destination_location_id,"arrival":destination,"portal_id":edge.portal_id})
	# Bounded diagnostic history, not saved event history.
	if transfers.size() > 64: transfers.pop_front()
	cursor.map_id = edge.destination_location_id; cursor.foot = destination
	cursor.phase = ""; cursor.remaining = 0; cursor.arrival_wait = 0; cursor.pending_edge = {}

func _fail_group(failed: RoutineExecutor) -> void:
	_night_lane.clear()
	var location: PrototypeLocation = _live_location()
	for id: String in failed.routine.participants:
		if not _actors.has(id): continue
		if location != null: location.npc_contacts.cancel_move(id)
		if id != failed.npc_id: _actors[id].state = RoutineExecutor.State.CANCELLED; _actors[id].remaining = 0; _actors[id].phase = ""

func _prepare_night_lane() -> void:
	if _lease != null and ("npc-01" in _lease._cursors or "npc-02" in _lease._cursors): return
	if not _night_lane.is_empty() or not _actors.has("npc-01") or not _actors.has("npc-02"): return
	var edric: RoutineExecutor = _actors["npc-01"]
	var helena: RoutineExecutor = _actors["npc-02"]
	var location: PrototypeLocation = _live_location()
	if location == null or location.location_id != RoutineExecutionWorld.HOME: return
	if edric.routine.id != "vale-overnight-home" or helena.routine.id != edric.routine.id or edric.index != 0: return
	if edric.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED] or helena.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED]: return
	if not location.npc_contacts.targets.has("npc-01") or not location.npc_contacts.targets.has("npc-02"): return
	# Measured R010 failure: near-side Helena rest blocks Edric's far-side route.
	# Bounded physical yield to her existing public archive station, then far-side
	# actor first, then return. No authored step, anchor, timer or position rewrite.
	location.npc_contacts.cancel_move("npc-02")
	_night_lane = {"phase":"clear","started":false,"helena_index":helena.index,"helena_remaining":helena.remaining,"helena_state":helena.state}

func _tick_night_lane(cursor: RoutineExecutor, _dt: float) -> bool:
	if _night_lane.is_empty() or cursor.npc_id not in ["npc-01","npc-02"]: return false
	var location: PrototypeLocation = _live_location()
	if location == null or location.location_id != RoutineExecutionWorld.HOME: return false
	var adapter: NpcWorldAdapter = location.npc_contacts
	if _night_lane.phase == "edric":
		if _actors["npc-01"].index >= 1: _night_lane.phase = "return"; _night_lane.started = false
		else: return cursor.npc_id == "npc-02"
	if _night_lane.phase in ["clear","return"]:
		if cursor.npc_id == "npc-01": return cursor.index == 0
		var destination: Dictionary = world.anchor(RoutineExecutionWorld.HOME,"helena-archive-desk" if _night_lane.phase == "clear" else "helena-rest")
		if not _night_lane.started:
			if not adapter.move_to(cursor.npc_id,destination.foot): cursor.fail(RoutineExecutor.Failure.MOVEMENT); return true
			_night_lane.started = true
			cursor.phase = "group-yield"; cursor.state = RoutineExecutor.State.MOVING
		var mover: RoutineMovement = adapter.movers[cursor.npc_id]
		if mover.state == RoutineMovement.State.FAILED:
			cursor.failure_detail = {"movement_failure":mover.failure,"blocker":mover.blocker,"repaths":mover.repaths,"path_requests":mover.path_requests,"group_lane":_night_lane.phase}
			cursor.fail(RoutineExecutor.Failure.MOVEMENT); return true
		if mover.state != RoutineMovement.State.ARRIVED: return true
		cursor.foot = adapter.targets[cursor.npc_id].global_position
		cursor.facing = destination.facing
		adapter.presenters[cursor.npc_id].face_direction(cursor.facing)
		if _night_lane.phase == "clear":
			adapter.occupancy.reserve(cursor.npc_id,cursor.foot,.4)
			_night_lane.phase = "edric"; _night_lane.started = false
			cursor.phase = ""; cursor.state = RoutineExecutor.State.READY
		else:
			if int(_night_lane.helena_index) == 0: cursor.advance_step()
			else:
				cursor.state = _night_lane.helena_state; cursor.remaining = _night_lane.helena_remaining; cursor.phase = ""
			adapter.occupancy.reserve(cursor.npc_id,cursor.foot,.4)
			_night_lane.clear()
		return true
	return false

func _live_location() -> PrototypeLocation:
	var location: PrototypeLocation = _location.get_ref() as PrototypeLocation if _location != null else null
	return location if is_instance_valid(location) and location.is_inside_tree() and not location.is_queued_for_deletion() else null

func acquire_dialogue(speaker: String, instance: String) -> Dictionary:
	if _session == null or _lease != null: return {"ok":false,"reason":"Routine dialogue owner unavailable."}
	var location: PrototypeLocation = _live_location()
	if location == null or location.npc_contacts == null: return {"ok":false,"reason":"Routine contact unloaded."}
	var target: PrototypeInteractable = location.npc_contacts.targets.get(speaker)
	if target == null or not is_instance_valid(target) or target.is_queued_for_deletion() or target.instance_id != instance:
		return {"ok":false,"reason":"Routine contact instance is stale or foreign."}
	var cursor: RoutineExecutor = _actors.get(speaker)
	if cursor == null: return {"ok":true,"context":null}
	if not cursor.routine.allow_dialogue: return {"ok":false,"reason":"Current routine does not allow dialogue."}
	if cursor.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED]: return {"ok":true,"context":null}
	var context: RoutineDialogueContext = RoutineDialogueContext.new()
	context._owner = weakref(self)
	context._data = {"speaker":speaker,"instance":instance,"session":_session,"location":weakref(location),"revision":revisions,"routine":cursor.routine.id,"steps":{}}
	for id: String in cursor.routine.participants:
		var member: RoutineExecutor = _actors.get(id)
		if member == null or member.routine.id != cursor.routine.id: return {"ok":false,"reason":"Incomplete routine group."}
		context._cursors[id] = member
		var step: RoutineDefinition.Step = member.current_step()
		context._data.steps[id] = step.id if step != null else ""
		if location.npc_contacts.targets.has(id): context._targets[id] = weakref(location.npc_contacts.targets[id])
	RoutineDefinition.freeze(context._data)
	_lease = context
	location.npc_contacts.dialogue_leased = PackedStringArray(context._targets.keys())
	return {"ok":true,"context":context}

func valid_lease(context: RoutineDialogueContext) -> bool:
	if _lease != context or context._data.session != _session: return false
	var location: PrototypeLocation = _live_location()
	if location == null or context._data.location.get_ref() != location: return false
	for id: String in context._cursors:
		var cursor: RoutineExecutor = _actors.get(id)
		if cursor != context._cursors[id] or cursor.routine.id != context._data.routine: return false
		var step: RoutineDefinition.Step = cursor.current_step()
		if (step.id if step != null else "") != context._data.steps[id]: return false
	for id: String in context._targets:
		var target: PrototypeInteractable = context._targets[id].get_ref()
		if target == null or target.is_queued_for_deletion() or location.npc_contacts.targets.get(id) != target: return false
	return location.npc_contacts.targets[context._data.speaker].instance_id == context._data.instance

func release_lease(context: RoutineDialogueContext) -> void:
	if _lease != context: return
	var location: PrototypeLocation = _live_location()
	if location != null: location.npc_contacts.dialogue_leased = []
	_lease = null
	if _session == null: return
	var update: Dictionary = selector.update(RoutineResolutionContext.from_session(_session))
	if not update.errors.is_empty(): last_error = "; ".join(update.errors); return
	reconciliations += 1
	if not apply_plan(update.plan): last_error = "invalid plan after dialogue closure"
