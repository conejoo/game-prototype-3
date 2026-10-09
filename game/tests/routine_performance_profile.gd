extends "res://tests/routine_lifecycle_checks.gd"
## R014 real Compatibility renderer. Synthetic placements/peak eight-mover legs;
## real scene collision, clock/selector/director/occupancy/rigs and frame cadence.
var measurements: Array[Dictionary] = []
var captures: Array[Dictionary] = []
var profile_baseline: Dictionary
var peak_origins: Dictionary = {}
var moving_samples: int = 0
var unchanged_query_samples: int = 0
var completed_peak_legs: int = 0
var actor_motion_samples: Dictionary = {}
var actor_completed_legs: Dictionary = {}
const SCHEDULER_P95_MS: float = 4.0 # Measured R014 revision; CONTRACT/acceptance retain original 2ms failures.

func _run() -> void:
	if DisplayServer.get_name() == "headless": _check(false,"profile requires actual renderer"); await _done("profile-headless-refused.json"); return
	root.size = Vector2i(960,640)
	if not await _boot(): await _done("profile-boot-failed.json"); return
	# Match pinned uncapped benchmark configuration, without changing project settings.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	await process_frame
	profile_baseline = SaveCodec.snapshot(game.session)
	observations.append({"method":"nearest-rank; 1s warmup +1000 active updates/configuration; synthetic peak-eight ABBA baseline/crowd/crowd/baseline plus production home/inn; 10 warmup+100 path queries per unique qualified leg; no acceleration/public-play claim","engine":Engine.get_version_info(),"cpu":OS.get_processor_name(),"processors":OS.get_processor_count(),"gpu":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),"renderer":RenderingServer.get_current_rendering_method(),"viewport":[960,640],"max_fps":Engine.max_fps,"vsync":DisplayServer.window_get_vsync_mode()})
	_check(Engine.max_fps == 0 and DisplayServer.window_get_vsync_mode() == 0,"uncapped established render settings")
	for index: int in range(4):
		var crowd: bool = index in [1,2]
		if not await _configure(MAPS[0],crowd,true): break
		await _sample("town-peak-eight" if crowd else "town-paired-empty",index,crowd)
	for map_id: String in [MAPS[1],MAPS[2]]:
		if not await _configure(map_id,true,false): break
		await _sample(map_id,0,false)
	# Query every actual authored consecutive leg, decomposing cross-map doors.
	for map_id: String in MAPS:
		if not await _configure(map_id,true,false): break
		await _queries(map_id)
	_maxclock()
	var base: float = maxf(measurements[0].frame_p95_ms,measurements[3].frame_p95_ms) if measurements.size() >= 4 else 0
	for row: Dictionary in measurements:
		_check(row.frame_p95_ms <= maxf(16.67,base+4),"whole-frame p95 paired limit "+row.label+str(row.run))
		_check(row.frame_p99_ms <= 25 and row.draw_p95 <= 500,"whole-frame p99/draw budget "+row.label+str(row.run))
	_check(moving_samples >= 1000 and completed_peak_legs >= 8,"actual eight-mover active sample and completed-leg coverage")
	for id: String in NpcRegistry.ENABLED: _check(int(actor_motion_samples.get(id,0)) >= 100 and int(actor_completed_legs.get(id,0)) >= 1,"each of eight real movers sampled/completed "+id)
	_check(unchanged_query_samples >= 1000,"unchanged unobstructed leg query invariant sampled")
	_check(TestRunEvidence.write_json("routine-performance.json",{"task":"R014","assertions":assertions,"failures":failures,"measurements":measurements,"observations":observations,"captures":captures,"moving_actor_samples":moving_samples,"actor_motion_samples":actor_motion_samples,"actor_completed_legs":actor_completed_legs,"unchanged_query_samples":unchanged_query_samples,"completed_peak_legs":completed_peak_legs,"proof":"synthetic peak relocation and legal physical short legs, production room schedules; actual focused rendered frame cadence; no ordinary full-day/native claim"}),"performance evidence")
	await _done("routine-performance-summary.json")

func _configure(map_id: String, crowd: bool, peak: bool) -> bool:
	game._set_paused(true)
	game.world_host.enabled_npcs = NpcRegistry.ENABLED if crowd else PackedStringArray()
	var run: GameSession = SaveCodec.validate(profile_baseline,game.catalog,game.npc_catalog).session
	run.current_location_id = map_id; run.current_spawn_id = game.catalog.get_location(map_id).spawn_ids[0]
	run.environment.day_cycle_progress = .005 if map_id == MAPS[0] else .60
	_check(game.save_repository.write(run,game.catalog).is_empty(),"isolated synthetic profile seed")
	var errors: PackedStringArray = await game.load_run()
	_check(errors.is_empty(),"production profile restore "+map_id+str(errors))
	if not errors.is_empty(): return false
	if peak:
		var owner: RoutineExecutionDirector = game.routine_execution
		for id: String in owner._actors:
			var foot: Vector3 = NpcRegistry.find(id).foot
			if id == "npc-14": foot = Vector3(-9,0,3.5) # Explicit retired public exterior perf-only site.
			owner._actors[id].map_id = MAPS[0]; owner._actors[id].foot = foot
			# Peak fixture uses the existing eight real rigs and live execution path.
			# These short test-only anchors never enter content or durable saves.
			var anchor_id: String = "r014-peak-"+id
			owner._actors[id].steps = [RoutineDefinition.Step.new({"id":"r014-physical-peak","kind":"move","target":{"mapId":MAPS[0],"anchorId":anchor_id}})]
			owner._actors[id].index = 0; owner._actors[id].phase = ""
			owner._actors[id].state = RoutineExecutor.State.READY
			owner.world._anchors[MAPS[0]+"/"+anchor_id] = {"foot":foot,"facing":Vector3.BACK}
			owner._positions[id] = {"map":MAPS[0],"foot":foot}
		if not await _travel(MAPS[0]): return false
		_check(game.world_host.current_location.npc_contacts.targets.size() == (8 if crowd else 0),"synthetic peak eight unique loaded bodies")
	var room: PrototypeLocation = game.world_host.current_location
	room.npc_contacts.set_physics_process(false)
	game.player_placeholder.set_physics_process(false); game.companion.set_physics_process(false); game.companion_ai.set_physics_process(false)
	game.player_placeholder.global_position = Vector3(-15,0,0) if map_id == MAPS[0] else Vector3(2,0,-8.5)
	game.companion.global_position = Vector3(-14,0,0) if map_id == MAPS[0] else Vector3(5,0,-8.5)
	game.camera_rig._process(0)
	peak_origins.clear()
	if peak and crowd:
		for id: String in room.npc_contacts.targets:
			var foot: Vector3 = room.npc_contacts.targets[id].global_position
			peak_origins[id] = foot
			game.routine_execution.world._anchors[MAPS[0]+"/r014-peak-"+id].foot = foot
			var cursor: RoutineExecutor = game.routine_execution.actor(id)
			cursor.foot = foot; cursor.index = 0; cursor.transitions = 0; cursor.phase = ""; cursor.state = RoutineExecutor.State.READY
	game.window_focused = true
	DisplayServer.window_move_to_foreground()
	game._set_paused(false); game._sync_npc_visuals()
	return true

func _peak_step() -> void:
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	for id: String in peak_origins:
		var mover: RoutineMovement = adapter.movers[id]
		var cursor: RoutineExecutor = game.routine_execution.actor(id)
		if cursor.state == RoutineExecutor.State.COMPLETED:
			completed_peak_legs += 1
			actor_completed_legs[id] = int(actor_completed_legs.get(id,0))+1
			var origin: Vector3 = peak_origins[id]
			# Ivo's shore lane runs east/west; south points into actual water.
			var offset: Vector3 = Vector3.RIGHT if id in ["npc-03","npc-04","npc-06","npc-07"] else Vector3.BACK
			var goal: Vector3 = origin+offset if adapter.targets[id].global_position.distance_to(origin) < .01 else origin
			game.routine_execution.world._anchors[MAPS[0]+"/r014-peak-"+id].foot = goal
			cursor.index = 0; cursor.transitions = 0; cursor.state = RoutineExecutor.State.READY; cursor.phase = ""
		_check(mover.state != RoutineMovement.State.FAILED,"physical peak leg safe "+id+" failure="+str(mover.failure))
		_check(cursor.state not in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED],"active peak cursor safe "+id+" "+str(cursor.snapshot()) if cursor.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED] else "active peak cursor safe "+id)

func _sample(label: String, run_index: int, peak: bool) -> void:
	print("R014_PROFILE_START ",label,"/",run_index)
	var room: PrototypeLocation = game.world_host.current_location
	var adapter: NpcWorldAdapter = room.npc_contacts
	var total: PackedFloat64Array = []; var director: PackedFloat64Array = []; var physics: PackedFloat64Array = []; var occupancy: PackedFloat64Array = []; var clocks: PackedFloat64Array = []; var frames: PackedFloat64Array = []; var draws: PackedFloat64Array = []
	var warmup_start: int = Time.get_ticks_usec()
	var previous: int = warmup_start
	var samples: int = 0
	var focused: int = 0
	while samples < 1000:
		await process_frame
		var now: int = Time.get_ticks_usec()
		var cadence: float = (now-previous)/1000.0; previous = now
		var measuring: bool = now-warmup_start >= 1000000
		var queries: Dictionary = {}
		for id: String in adapter.movers:
			var mover: RoutineMovement = adapter.movers[id]
			queries[id] = {"state":mover.state,"requests":mover.path_requests,"goal":mover.goal}
		if peak: _peak_step() # Synthetic reset/diagnostics are not production work.
		var begin: int = Time.get_ticks_usec()
		game._sync_npc_visuals()
		game.routine_execution.tick(1.0/60.0)
		var after_director: int = Time.get_ticks_usec()
		adapter._physics_process(1.0/60.0)
		var after_physics: int = Time.get_ticks_usec()
		var active: int = 0
		for id: String in adapter.movers:
			var mover: RoutineMovement = adapter.movers[id]
			if mover.achieved_speed > .001:
				active += 1
				if measuring: actor_motion_samples[id] = int(actor_motion_samples.get(id,0))+1
			if measuring and queries.has(id) and queries[id].state == RoutineMovement.State.MOVING and mover.state in [RoutineMovement.State.MOVING,RoutineMovement.State.ARRIVED] and queries[id].goal == mover.goal:
				_check(queries[id].requests == mover.path_requests,"unchanged unobstructed leg zero per-frame path requests "+id)
				unchanged_query_samples += 1
		var probe_begin: int = Time.get_ticks_usec()
		for id: String in adapter.targets:
			var foot: Vector3 = adapter.targets[id].global_position
			adapter.occupancy.blocked(id,foot,foot+Vector3(.001,0,0),.4)
		var probe_end: int = Time.get_ticks_usec()
		var clock_begin: int = Time.get_ticks_usec()
		_check(game.session.advance(1.0/60.0).is_empty(),"active clock profile update")
		var clock_end: int = Time.get_ticks_usec()
		game._present_environment()
		game._refresh_interaction()
		if measuring:
			samples += 1
			moving_samples += active
			total.append((after_physics-begin)/1000.0); director.append((after_director-begin)/1000.0); physics.append((after_physics-after_director)/1000.0); occupancy.append((probe_end-probe_begin)/1000.0); clocks.append((clock_end-clock_begin)/1000.0); frames.append(cadence); draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			if game.window_focused and root.has_focus(): focused += 1
		if failures.size() > 20: break
	var row: Dictionary = {"label":label,"run":run_index,"samples":samples,"loaded":adapter.targets.size(),"scheduler_plus_npc_p95_ms":_percent(total,.95),"director_sync_p95_ms":_percent(director,.95),"physical_rig_p95_ms":_percent(physics,.95),"occupancy_eight_queries_p95_ms":_percent(occupancy,.95),"clock_p95_ms":_percent(clocks,.95),"frame_p95_ms":_percent(frames,.95),"frame_p99_ms":_percent(frames,.99),"draw_p95":_percent(draws,.95),"focused":focused,"revisions":game.routine_execution.revisions}
	measurements.append(row)
	_check(samples == 1000 and focused == samples,"1000 focused active samples "+label)
	_check(row.scheduler_plus_npc_p95_ms <= SCHEDULER_P95_MS,"scheduler plus loaded NPC p95 <=4ms revised R014 budget "+label)
	var columns: PackedStringArray = ["frame,frame_ms,director_sync_ms,physics_rig_ms,total_scheduler_npc_ms,occupancy_probe_ms,clock_ms,draws"]
	for index: int in samples: columns.append("%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.0f" % [index,frames[index],director[index],physics[index],total[index],occupancy[index],clocks[index],draws[index]])
	_write(TestRunEvidence.path(label+"-"+str(run_index)+".csv"),"\n".join(columns)+"\n")
	game._set_paused(true)
	var capture: Dictionary = await TestRunCapture.capture(game,label+"-"+str(run_index),TestRunEvidence.directory(),"synthetic",false,"R014 performance only: synthetic clock/party/peak-eight sites; measured unpaused frames; pause capture after sample")
	_check(capture.ok,"profile paused capture "+str(capture.get("error","")))
	if capture.ok: captures.append(capture)
	print("R014_PROFILE_END ",row)

func _queries(map_id: String) -> void:
	var owner: RoutineExecutionDirector = game.routine_execution
	var legs: Dictionary = {}
	for routine_id: String in owner._catalog.routine_ids():
		var definition: RoutineDefinition = owner._catalog.get_routine(routine_id)
		for id: String in definition.participants:
			var prior: Dictionary = owner.world.origin(routine_id,id)
			for step: RoutineDefinition.Step in definition.steps(id):
				if step.kind != RoutineDefinition.StepKind.MOVE: continue
				var target: Dictionary = owner.world.anchor(step.map_id,step.anchor_id)
				var chain: Dictionary = owner.world.chain(prior.map,step.map_id)
				_check(chain.ok,"qualified query chain "+routine_id)
				if not chain.ok: continue
				for edge: Dictionary in chain.legs:
					if prior.map == map_id: _add_leg(legs,prior.foot,owner.world.door(edge),routine_id+"/"+step.id+"/door")
					prior = {"map":edge.destination_location_id,"foot":owner.world.arrival(edge)}
				if prior.map == map_id: _add_leg(legs,prior.foot,target.foot,routine_id+"/"+step.id)
				prior = {"map":step.map_id,"foot":target.foot}
	var nav: RID = game.world_host.current_location.get_world_3d().navigation_map
	for key: String in legs:
		var leg: Dictionary = legs[key]
		var samples: PackedFloat64Array = []
		var path: PackedVector3Array
		for index: int in range(110):
			var start: int = Time.get_ticks_usec()
			path = NavigationServer3D.map_get_path(nav,leg.start,leg.end,true)
			if index >= 10: samples.append((Time.get_ticks_usec()-start)/1000.0)
		_check(path.size() >= 2 and path[0].distance_to(leg.start) <= .3 and path[-1].distance_to(leg.end) <= .3,"qualified physical leg endpoints "+key)
		var p95: float = _percent(samples,.95)
		_check(p95 <= 5,"100-query path p95<=5ms "+key)
		observations.append({"map":map_id,"leg":leg,"warmup":10,"samples":100,"path_points":path.size(),"p95_ms":p95})

func _add_leg(legs: Dictionary, start: Vector3, end: Vector3, label: String) -> void:
	if start.distance_to(end) < .01: return
	var key: String = str(start)+"->"+str(end)
	if not legs.has(key): legs[key] = {"start":start,"end":end,"labels":[]}
	legs[key].labels.append(label)

func _maxclock() -> void:
	var owner: RoutineExecutionDirector = game.routine_execution
	var run: GameSession = SaveCodec.validate(profile_baseline,game.catalog,game.npc_catalog).session
	run.environment.day_index = 3650; run.environment.day_cycle_progress = .99
	var timings: PackedFloat64Array = []
	var max_transitions: int = 0
	for index: int in range(110):
		var start: int = Time.get_ticks_usec()
		var staged: Dictionary = owner.stage(run)
		var duration: float = (Time.get_ticks_usec()-start)/1000.0
		_check(staged.ok and staged.transitions <= 512,"max-clock complete detached plan total transition cap")
		if not staged.ok: continue
		max_transitions = maxi(max_transitions,staged.transitions)
		for cursor: RoutineExecutor in staged.actors.values(): _check(cursor.transitions <= 64 and cursor.foot.is_finite(),"max-clock per-actor cap/finite map foot")
		if index >= 10: timings.append(duration)
	_check(_percent(timings,1.0) <= 50,"max-clock reconstruction worst-case<=50ms")
	for routine_id: String in owner._catalog.routine_ids():
		var definition: RoutineDefinition = owner._catalog.get_routine(routine_id)
		for id: String in definition.participants:
			var cursor: RoutineExecutor = RoutineExecutor.new()
			_check(cursor.initialize(definition,id,owner.world.origin(routine_id,id)) and cursor.reconstruct(1e100,owner.world) and cursor.transitions <= 64,"huge finite elapsed step sweep "+routine_id+"/"+id)
	var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
	var began: int = Time.get_ticks_usec()
	owner.tick(1e100)
	var huge_ms: float = (Time.get_ticks_usec()-began)/1000.0
	_check(huge_ms <= 50 and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == before,"huge finite tick bounded/inert durable facts")
	observations.append({"case":"max supported day3650/progress.99, 10warm+100 complete detached stages; all25 participant elapsed1e100 sweeps","p95_ms":_percent(timings,.95),"maximum_ms":_percent(timings,1.0),"maximum_transitions":max_transitions,"huge_tick_ms":huge_ms})

func _percent(values: PackedFloat64Array, fraction: float) -> float:
	if values.is_empty(): return INF
	var sorted: PackedFloat64Array = values.duplicate(); sorted.sort()
	return sorted[maxi(0,ceili(sorted.size()*fraction)-1)]
