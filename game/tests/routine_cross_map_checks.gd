extends "res://tests/support/routine_execution_fixture.gd"

func _run() -> void:
	if await setup(1199):
		await _test()
		await _active_arrival(false)
		await _active_arrival(true)
		await _loaded_night()
		await _offscreen_rollback()
	await finish("cross-map.json")

func _test() -> void:
	var player_map: String = game.session.current_location_id
	var player_foot: Vector3 = game.player_placeholder.global_position
	var camera_target: Node3D = game.camera_rig.target
	var previous: Vector3 = execution.actor("npc-01").foot
	var samples: int = 0
	# Synthetic initial clock; ordinary continuous clock advance crosses 20/22/00.
	# Physics and finite .1 active deltas, no subsequent seek or catch-up placement.
	for frame: int in range(2500):
		await step(.1,true)
		var actor: RoutineExecutor = execution.actor("npc-01")
		if actor.map_id == player_map:
			check(actor.foot.distance_to(previous) <= .2001,"continuous loaded 2m/s/no catch-up snap")
			previous = actor.foot
		check(actor.state != RoutineExecutor.State.FAILED,"ordinary Edric never hidden failed "+str(actor.snapshot()))
		if frame % 100 == 0: observations.append({"case":"continuous ordinary active-delta night transition","clock":game.session.environment.day_cycle_progress,"edric":actor.snapshot()})
		samples += 1
		if failures.size() > 8: break
		if game.session.environment.day_cycle_progress > .65 and actor.routine.id == "vale-overnight-home" and actor.current_step().id == "rest-until-morning": break
	check(execution.actor("npc-01").map_id == "prototype-mayor-vale-home" and execution.actor("npc-01").foot == Vector3(-5.5,0,.25),"continuous night reaches Edric home rest")
	check(execution.actor("npc-02").map_id == "prototype-mayor-vale-home","atomic Vale assignment includes Helena")
	check(not game.world_host.current_location.npc_contacts.targets.has("npc-01"),"departure removes collider/interaction/presenter, no hidden town Edric")
	check(game.session.current_location_id == player_map and game.player_placeholder.global_position == player_foot and game.camera_rig.target == camera_target and game.party.members().size() == 2,"NPC transfer never moves WorldHost/player/camera/party")
	var town_departure: Dictionary = {}
	for record: Dictionary in execution.transfers:
		if record.npc_id == "npc-01" and record.source == player_map: town_departure = record
	check(not town_departure.is_empty() and town_departure.source_foot.distance_to(Vector3(5,0,-5.15)) <= .005,"loaded actor physically reaches measured source door before departure")
	if not await travel("prototype-mayor-vale-home"): return
	var room: PrototypeLocation = game.world_host.current_location
	check(room.npc_contacts.targets.size() == 2 and room.npc_contacts.targets.has("npc-01") and room.npc_contacts.targets.has("npc-02"),"exact two safe active home wrappers")
	check(room.npc_contacts.targets["npc-01"].global_position == Vector3(-5.5,0,.25),"one visible Edric at authored rest")
	check(NavigationServer3D.map_get_regions(room.get_world_3d().navigation_map).size() == 1,"one active navigation region")
	# Failed replacement restores old scene/bodies/logical timers and no stale region.
	var old_room: PrototypeLocation = room
	var old_state: Dictionary = execution.snapshot()
	var definition: LocationDefinition = game.catalog.get_location("prototype-mayor-vale-home")
	var path: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/r007/blocked_home.tscn"
	check(game.world_host.request_transition(definition.stable_id,definition.spawn_ids[0]).is_empty(),"unsafe scene replacement attempts actual placement")
	var result: Array = await game.world_host.transition_finished
	check(not result[0],"unsafe replacement refuses")
	definition.scene_path = path
	check(game.world_host.current_location == old_room and execution.snapshot() == old_state,"rollback retains consistent scene/qualified logical ownership")
	check(old_room.npc_contacts.occupancy.snapshot().bodies == 4,"rollback rebinds both NPC and persistent party bodies")
	for id: String in ["npc-01","npc-02"]:
		check(old_room.npc_contacts.occupancy._bodies[id].body.get_ref() == old_room.npc_contacts.targets[id].get_node("ContactBody"),"rollback binds exact existing body "+id)
	check(NavigationServer3D.map_get_regions(old_room.get_world_3d().navigation_map).size() == 1,"rollback no stale region")
	manual_mode()
	# Continue actual clock from midnight through breakfast and morning; room-loaded
	# Edric must leave via south door, Helena stays in real archive.
	for frame: int in range(2500):
		await step(.1,true)
		var actor: RoutineExecutor = execution.actor("npc-01")
		check(actor.state != RoutineExecutor.State.FAILED,"continuous morning Edric route valid "+str(actor.snapshot()))
		if actor.routine.id == "vale-morning-work" and actor.map_id == "prototype-alderwake" and actor.index >= 2: break
		if failures.size() > 8: break
	check(execution.actor("npc-01").routine.id == "vale-morning-work" and execution.actor("npc-01").map_id == "prototype-alderwake","ordinary home rest/breakfast/morning return")
	check(not old_room.npc_contacts.targets.has("npc-01") and old_room.npc_contacts.targets.has("npc-02"),"morning split maps retains atomic assignment and one Helena")
	if not await travel("prototype-alderwake"): return
	check(game.world_host.current_location.npc_contacts.targets.has("npc-01"),"Edric safely materializes once in town")
	check(game.world_host.current_location.npc_contacts.targets["npc-01"].global_position.distance_to(Vector3(-.5,0,-1.5)) < .005,"morning authored town endpoint")
	observations.append({"case":"completed night/morning","samples":samples,"transfers":execution.transfers,"snapshot":execution.snapshot()})

func _active_arrival(blocked: bool) -> void:
	# Independent synthetic 08:00 restart setup; thereafter ordinary executor tick.
	game.session.environment.day_cycle_progress = fposmod((480.0-600.0)/1440.0,1)
	execution.dispose()
	execution = RoutineExecutionDirector.new()
	check(execution.initialize(game.catalog,game.npc_catalog,game.session).is_empty(),"08:00 independent start")
	game.routine_execution = execution; game.world_host.routine_execution = execution
	if not await travel("prototype-alderwake"): return
	var room: PrototypeLocation = game.world_host.current_location
	check(not room.npc_contacts.targets.has("npc-01"),"offscreen Edric has no hidden town wrapper before arrival")
	var player_foot: Vector3 = game.player_placeholder.global_position
	if blocked:
		game.player_placeholder.global_position = Vector3(4,0,-4.6)
		player_foot = game.player_placeholder.global_position
		game._sync_npc_visuals(); await physics_frame
	var initial_bodies: int = room.npc_contacts.occupancy.snapshot().bodies
	var saw_reservation: bool = false
	for frame: int in range(600):
		await step()
		if room.npc_contacts.targets.has("npc-01"):
			saw_reservation = saw_reservation or room.npc_contacts.occupancy.snapshot().reservations.has("npc-01")
			check(room.npc_contacts.targets.size() == 6 and not room.npc_contacts.targets.has("npc-02"),"one active Edric wrapper; Helena remains home")
		if execution.actor("npc-01").state == RoutineExecutor.State.FAILED or execution.actor("npc-01").index >= 2: break
	var edric: RoutineExecutor = execution.actor("npc-01")
	if blocked:
		check(edric.failure == RoutineExecutor.Failure.ARRIVAL_BLOCKED and edric.map_id == "prototype-mayor-vale-home","blocked active arrival retains safe source map/feet with typed failure")
		check(execution.actor("npc-02").state == RoutineExecutor.State.CANCELLED,"failed transfer cancels whole atomic group")
		check(not room.npc_contacts.targets.has("npc-01") and room.npc_contacts.occupancy.snapshot().bodies == initial_bodies,"failed transfer publishes no stale wrapper/body")
		check(not room.npc_contacts.occupancy.snapshot().reservations.has("npc-01"),"failed arrival releases claim")
	else:
		check(edric.failure == RoutineExecutor.Failure.NONE and edric.index >= 2 and edric.map_id == room.location_id,"offscreen route physically arrives/walks active town endpoint")
		check(saw_reservation and room.npc_contacts.occupancy.snapshot().bodies == initial_bodies+1,"safe active arrival owns one wrapper/body/reservation")
		check(edric.foot.distance_to(Vector3(-.5,0,-1.5)) < .005,"active arrival never jumps directly to station")
	check(game.session.current_location_id == room.location_id and game.player_placeholder.global_position == player_foot,"active NPC arrival leaves player location/feet unchanged")
	observations.append({"case":"blocked active arrival" if blocked else "safe active arrival","edric":edric.snapshot(),"transfers":execution.transfers,"error":execution.last_error})

func _loaded_night() -> void:
	game.session.environment.day_cycle_progress = fposmod((1319.0-600.0)/1440.0,1)
	execution.dispose(); execution = RoutineExecutionDirector.new()
	check(execution.initialize(game.catalog,game.npc_catalog,game.session).is_empty(),"21:59 loaded-home reconstruction setup")
	game.routine_execution = execution; game.world_host.routine_execution = execution
	if not await travel("prototype-mayor-vale-home"): return
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	for frame: int in range(600):
		await step(.1,true)
		if execution.actor("npc-01").state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED]: break
		if execution.actor("npc-01").current_step().id == "rest-until-morning" and execution.actor("npc-02").current_step().id == "rest-until-morning": break
	check(execution.actor("npc-01").current_step().id == "rest-until-morning" and execution.actor("npc-02").current_step().id == "rest-until-morning","both loaded physical actors reach rest after continuous22:00")
	check(execution.actor("npc-01").foot.distance_to(Vector3(-5.5,0,.25)) < .005 and execution.actor("npc-02").foot.distance_to(Vector3(-3.5,0,.25)) < .005,"loaded overnight feet exact, no snap/hidden actor")
	check(adapter.targets.size() == 2 and adapter.occupancy.snapshot().reservations.size() == 2,"loaded rest one wrapper and station claim each")
	observations.append({"case":"loaded-home continuous22:00 physical regression","execution":execution.snapshot()})
	var edric: RoutineExecutor = execution.actor("npc-01")
	var helena: RoutineExecutor = execution.actor("npc-02")
	var before_day: int = game.session.environment.day_index
	var before_remaining: float = edric.remaining
	var elapsed: float = 0
	var last_minute: float = EnvironmentClock.minute_of_day(game.session.environment.day_cycle_progress)
	var crossed_midnight: bool = false
	for frame: int in range(1400):
		await step(.1,true); elapsed += .1
		check(edric.foot.distance_to(Vector3(-5.5,0,.25)) < .005 and helena.foot.distance_to(Vector3(-3.5,0,.25)) < .005,"loaded overnight stays at rest through midnight, no repeated yield")
		var minute: float = EnvironmentClock.minute_of_day(game.session.environment.day_cycle_progress)
		if minute < last_minute:
			crossed_midnight = true
			await step(); elapsed += .1
			break
		last_minute = minute
	check(crossed_midnight and game.session.environment.day_index == before_day,"civil midnight crossed under unchanged authoritative10:00-based clock day")
	check(execution.actor("npc-01") == edric and execution.actor("npc-02") == helena and execution.snapshot().group_lane.is_empty(),"same wrapping overnight group keeps cursors across midnight")
	check(absf(edric.remaining-(before_remaining-elapsed)) < .00001,"midnight preserves active wait remaining rather than restarting")
	observations.append({"case":"loaded overnight midnight continuity","elapsed":elapsed,"execution":execution.snapshot()})

func _offscreen_rollback() -> void:
	game.session.environment.day_cycle_progress = fposmod((480.0-600.0)/1440.0,1)
	execution.dispose(); execution = RoutineExecutionDirector.new()
	check(execution.initialize(game.catalog,game.npc_catalog,game.session).is_empty(),"morning offscreen rollback initialize")
	game.routine_execution = execution; game.world_host.routine_execution = execution
	if not await travel("prototype-mayor-vale-home"): return
	for frame: int in range(600):
		await step()
		if execution.actor("npc-01").map_id == RoutineExecutionWorld.TOWN and execution.actor("npc-01").phase == "offscreen": break
	var actor: RoutineExecutor = execution.actor("npc-01")
	check(actor.map_id == RoutineExecutionWorld.TOWN and actor.phase == "offscreen" and actor.remaining > 0,"physical departure begins finite offscreen town leg")
	var old_room: PrototypeLocation = game.world_host.current_location
	var before: Dictionary = execution.snapshot()
	check(game.world_host.request_transition(RoutineExecutionWorld.TOWN,"alderwake-from-mayor-vale-home").is_empty(),"actual player return attempts occupied NPC arrival")
	var result: Array = await game.world_host.transition_finished
	check(not result[0] and "spawn 'alderwake-from-mayor-vale-home' is obstructed for 'party-player'" in result[1],"actual collision refuses player arrival, no ghosting")
	check(game.world_host.current_location == old_room and actor.snapshot() == before.actors["npc-01"] and execution.snapshot().positions == before.positions and execution.revisions == before.revisions,"rollback preserves exact offscreen remaining/phase/feet and qualified ownership")
	check(execution.actor("npc-02").foot == before.actors["npc-02"].foot,"loaded unfinished leg rebinds at actual held Helena feet")
	check(NavigationServer3D.map_get_regions(old_room.get_world_3d().navigation_map).size() == 1,"occupied return rollback leaves one region")
	manual_mode()
	for frame: int in range(60):
		await step()
		if actor.index >= 2: break
	check(actor.index >= 2 and actor.failure == RoutineExecutor.Failure.NONE,"retained offscreen timer naturally clears player arrival")
	check(game.world_host.request_transition(RoutineExecutionWorld.TOWN,"alderwake-from-mayor-vale-home").is_empty(),"retry actual cleared return")
	result = await game.world_host.transition_finished
	check(result[0] and game.session.current_location_id == RoutineExecutionWorld.TOWN,"retry publishes one safe town after finite progress")
	check(game.world_host.current_location.npc_contacts.targets.has("npc-01") and game.world_host.current_location.npc_contacts.targets.size() == 6,"retry one Edric, Helena home, no stale bodies")
	observations.append({"case":"occupied player return rollback preserves offscreen progress","before":before,"after":execution.snapshot()})
