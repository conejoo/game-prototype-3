extends "res://tests/routine_activation_render.gd"
## R015 fresh ordinary day. Observation never mutates clock, actors or facts.
var day_log: Array[Dictionary] = []
var last_keys: Dictionary = {}
var start_clock: float = 0
var started_ms: int = 0
var next_progress: float = 0
var observing: bool = false
var ivo_distance: float = 0
var ivo_previous: Vector3
var ivo_bound: bool = false
var ivo_states: Dictionary = {}
var presentation_seen: Dictionary = {}

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.substr(8)
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate(); root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"fresh default production startup")
	if await _focus_r013():
		if phase == "read": await _read_day()
		else:
			start_clock = _clock(); started_ms = Time.get_ticks_msec()
			observing = true; physics_frame.connect(_observe_day)
			await _write_day()
			observing = false; physics_frame.disconnect(_observe_day)
	_check(TestRunEvidence.write_json("full-day-"+phase+"-index.json",{"task":"R015","phase":phase,"pid":OS.get_process_id(),"assertions":assertions+1,"failures":failures,"views":captures,"traces":traces,"routes":routes,"combat":combat_traces,"nodes":visited,"choices":chosen,"day_log":day_log,"active_seconds":_clock()-start_clock if phase != "read" else 0,"wall_seconds":(Time.get_ticks_msec()-started_ms)/1000.0 if phase != "read" else 0,"ivo_loaded_distance":ivo_distance,"ivo_loaded_states":ivo_states,"presentations":presentation_seen,"snapshot":SaveCodec.snapshot(game.session),"approved_correction":"User: yes, validate that; Ivo movement/waits/conversation, Edric/Helena authored action/speech; no authored content change","provenance":"fresh ordinary public WASD/E/Esc/P/GUI/Tab/Enter/F10 with runtime-nav guidance; no time/weather/state/health/affinity/position setup; read uses actual GUI Load of ordinary writer"}),"full-day evidence write")
	for failure: String in failures: push_error(failure)
	print("R015_FULL_DAY ",phase," assertions=",assertions," captures=",captures.size()," failures=",failures.size())
	if failures.is_empty(): _key(KEY_F10,true); _key(KEY_F10,false)
	else:
		paused = false; game.queue_free(); await process_frame; quit(1)

func _clock() -> float:
	return (game.session.environment.day_index+game.session.environment.day_cycle_progress)*EnvironmentClock.CYCLE_SECONDS

func _observe_day() -> void:
	if not observing: return
	if game.world_host.transitioning or not is_instance_valid(game.world_host.current_location) or not game.world_host.current_location.is_inside_tree():
		ivo_bound = false
		return
	var elapsed: float = _clock()-start_clock
	if elapsed >= next_progress:
		print("R015_ACTIVE seconds=",elapsed," time=",EnvironmentClock.format_time(game.session.environment.day_cycle_progress)," map=",game.session.current_location_id," paused=",paused," focus=",game.window_focused)
		next_progress += 30
		day_log.append({"active_seconds":elapsed,"wall_ms":Time.get_ticks_msec()-started_ms,"map":game.session.current_location_id,"time_scale":Engine.time_scale,"environment":TestRunSnapshot.weather(game.session.environment),"paused":paused,"focus":game.window_focused})
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	for id: String in game.routine_execution._actors:
		var actor: RoutineExecutor = game.routine_execution.actor(id)
		var snap: Dictionary = actor.snapshot()
		var key: String = str([snap.routine_id,snap.map_id,snap.step_id,snap.state,snap.phase])
		if last_keys.get(id,"") != key:
			last_keys[id] = key
			day_log.append({"active_seconds":elapsed,"wall_ms":Time.get_ticks_msec()-started_ms,"location":game.session.current_location_id,"loaded":adapter.targets.has(id),"actor":snap})
		if id == "npc-07" and adapter.targets.has(id) and is_instance_valid(adapter.targets[id]) and adapter.targets[id].is_inside_tree():
			var foot: Vector3 = adapter.targets[id].global_position
			if ivo_bound and foot.distance_to(ivo_previous) < .5: ivo_distance += foot.distance_to(ivo_previous)
			ivo_previous = foot; ivo_bound = true
			ivo_states[str(actor.state)] = true
		elif id == "npc-07": ivo_bound = false

func _until(predicate: Callable, limit_seconds: float, label: String) -> bool:
	var end: int = Time.get_ticks_msec()+int(limit_seconds*1000)
	while Time.get_ticks_msec() < end:
		await physics_frame
		if predicate.call(): return true
	_check(false,"natural wait timeout "+label+" active="+str(_clock()-start_clock)+" actors="+str(game.routine_execution.snapshot()))
	return false

func _write_day() -> void:
	await _ordinary_r013()
	if not failures.is_empty(): return
	await _resume()
	await _click(game.ui.people_button.get_global_rect().get_center())
	_check(game.journal_open and game.ui.people_view.rows.size() == 4,"ordinary met-only People across both actual rooms")
	var people_capture: Dictionary = await TestRunInteractionCapture.journal(game,"write-ordinary-met-only-people",TestRunEvidence.directory(),"debug-input","R015 only four actually met villagers; earned facts/gift/flag; ordinary HUD People")
	_check(people_capture.ok,people_capture.get("error","actual People capture"))
	if people_capture.ok: captures.append(people_capture)
	_close(); await process_frame
	if not await _walk(Vector3(12,0,-1),"natural-river-view"): return
	if not await _until(func() -> bool: return (game.routine_execution.actor("npc-01").state == RoutineExecutor.State.SPEAKING and game.routine_execution.actor("npc-01").routine.id == "edric-evening-fishing") or game.routine_execution.actor("npc-01").routine.id == "edric-evening-rain-shelter",150,"Edric natural evening branch"): return
	if game.routine_execution.actor("npc-01").routine.id == "edric-evening-fishing":
		await _presentation("npc-01",RoutineExecutor.State.SPEAKING,"edric-natural-river-speech")
		if not await _until(func() -> bool: return game.routine_execution.actor("npc-01").state == RoutineExecutor.State.ACTING,10,"Edric fishing action"): return
		await _presentation("npc-01",RoutineExecutor.State.ACTING,"edric-natural-fishing-action")
	else:
		# Random storm is not a luck gate. The existing separately labeled
		# deterministic river renderer supplies fishing art/speech if suppressed.
		presentation_seen["natural-storm-shelter"] = game.routine_execution.actor("npc-01").snapshot()
		await _pause(); await _capture("natural-storm-shelter-branch",true); await _resume()
	if not await _walk(Vector3(12,0,-1),"dock-north-lane"): return
	if not await _walk(Vector3(32,0,15),"dock-circuit-safe-view"): return
	if not await _until(func() -> bool: return game.routine_execution.actor("npc-07").routine.id == "ivo-docks-evening" and game.routine_execution.actor("npc-07").state == RoutineExecutor.State.WAITING,180,"Ivo evening wait"): return
	var ivo: RoutineExecutor = game.routine_execution.actor("npc-07")
	var remaining: float = ivo.remaining
	await _pause(); await _capture("ivo-natural-evening-wait"); await _resume()
	await create_timer(1).timeout
	_check(ivo.state == RoutineExecutor.State.WAITING and ivo.remaining < remaining,"Ivo actual timed wait consumes ordinary active time")
	if not await _until(func() -> bool: return ivo.state == RoutineExecutor.State.MOVING,55,"Ivo natural shore departure"): return
	await _pause(); await _capture("ivo-natural-shore-walk"); await _resume()
	if not await _until(func() -> bool: return ivo.state == RoutineExecutor.State.WAITING and ivo.current_step().id == "review-shore-lines",20,"Ivo shore wait"): return
	await _pause(); await _capture("ivo-natural-shore-wait"); await _resume()
	if not await _until(func() -> bool: return ivo.state == RoutineExecutor.State.MOVING,30,"Ivo booking return"): return
	await _pause(); await _capture("ivo-natural-booking-return"); await _resume()
	if not await _until(func() -> bool: return ivo.state == RoutineExecutor.State.WAITING and ivo.current_step().id == "remain-available-at-berth",20,"Ivo completed circuit"): return
	_check(ivo_distance > 2 and ivo_states.has(str(RoutineExecutor.State.MOVING)) and ivo_states.has(str(RoutineExecutor.State.WAITING)),"actual loaded Ivo circuit movement/wait evidence")
	if not await _walk(Vector3(12,0,-1),"night-home-north-lane"): return
	if not await _walk(Vector3(5,0,-5.15),"night-home-public-door"): return
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(RoutineExecutionWorld.HOME): return
	if not await _walk(Vector3(2,0,-8.5),"night-home-clear-central-hall"): return
	if not await _until(func() -> bool: return _resting("npc-01") and _resting("npc-02"),30,"actual family night rest"): return
	_check(TestRunRoutines.contacts_match(game),"one real resting family and unchanged full party")
	await _pause(); await _capture("family-natural-night-rest"); await _resume()
	# Both party bodies must clear the kitchen entry before breakfast paths.
	# Standing in that lane correctly produces bounded BLOCKED.
	if not await _walk(Vector3(6,0,-4.5),"night-clear-breakfast-family-lanes"): return
	var breakfast_seen: Dictionary = {}
	var breakfast_deadline: int = Time.get_ticks_msec()+180000
	while breakfast_seen.size() < 2 and Time.get_ticks_msec() < breakfast_deadline:
		await physics_frame
		for id: String in ["npc-01","npc-02"]:
			var actor: RoutineExecutor = game.routine_execution.actor(id)
			if actor.routine.id == "vale-breakfast" and actor.state == RoutineExecutor.State.SPEAKING and not breakfast_seen.has(id):
				breakfast_seen[id] = true
				await _presentation(id,RoutineExecutor.State.SPEAKING,id+"-natural-breakfast-speech")
	_check(breakfast_seen.size() == 2,"natural morning group breakfast/speech on both actual family bodies")
	if not failures.is_empty(): return
	# Inspect Helena's staggered tail after Edric's billboard naturally clears.
	if not await _until(func() -> bool: return game.routine_execution.actor("npc-01").state != RoutineExecutor.State.SPEAKING and game.routine_execution.actor("npc-02").state == RoutineExecutor.State.SPEAKING,6,"natural solo breakfast speech tail"): return
	await _presentation("npc-02",RoutineExecutor.State.SPEAKING,"helena-natural-breakfast-solo-tail")
	if not await _until(func() -> bool: return game.routine_execution.actor("npc-01").routine.id == "vale-morning-work" and game.routine_execution.actor("npc-01").map_id == RoutineExecutionWorld.TOWN and game.routine_execution.actor("npc-02").state == RoutineExecutor.State.ACTING,100,"natural morning departure/archive"): return
	await _presentation("npc-02",RoutineExecutor.State.ACTING,"helena-natural-morning-archive")
	# Helena's actual breakfast speech is already captured. The authoritative
	# 10AM day rollover may restart morning work; don't require a later optional
	# archive line to occur before that routine's noon window closes.
	if not await _until(func() -> bool: return _clock()-start_clock >= 600,80,"full600 active seconds"): return
	_check(_clock()-start_clock >= 600 and is_equal_approx(Engine.time_scale,1),"at least600 actual clock seconds with no acceleration")
	await _pause(); await _capture("full-natural-day-complete",true); await _resume()
	if not await _walk(Vector3(0,0,.25),"morning-home-public-return"): return
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(RoutineExecutionWorld.TOWN): return
	if not await _recovery_day(): return
	await _pause()
	var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","actual GUI Save"))
	if not saved.ok: return
	# Current repository publishes a valid first backup atomically with primary.
	var backup: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(game.save_repository.path+".bak"),game.catalog,game.npc_catalog)
	_check(backup.session != null and backup.errors.is_empty() and SaveCodec.snapshot(backup.session) == SaveCodec.snapshot(game.session),"ordinary GUI Save complete typed first backup")
	var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
	_check(disk.session != null and disk.errors.is_empty() and SaveCodec.snapshot(disk.session) == SaveCodec.snapshot(game.session),"ordinary whole typed GUI save")
	var file: FileAccess = FileAccess.open(game.save_repository.path+".r015-oracle",FileAccess.WRITE)
	_check(file != null,"isolated ordinary writer oracle")
	if file != null: file.store_var(TestRunSnapshot.oracle(game.session)); file.close()
	await _capture("ordinary-recovery-gui-save",true)

func _resting(id: String) -> bool:
	var actor: RoutineExecutor = game.routine_execution.actor(id)
	return actor.routine.id == "vale-overnight-home" and actor.current_step().id == "rest-until-morning" and actor.state == RoutineExecutor.State.WAITING and actor.map_id == RoutineExecutionWorld.HOME

func _presentation(id: String, state: RoutineExecutor.State, label: String) -> void:
	var actor: RoutineExecutor = game.routine_execution.actor(id)
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	_check(actor.state == state and adapter.targets.has(id),"actual loaded presentation "+label)
	if not adapter.targets.has(id): return
	await _pause()
	var output: RoutinePresentation = adapter.routine_presentations[id]
	if state == RoutineExecutor.State.SPEAKING: _check(output.speech.visible and output.speech.text == actor.current_step().text,"exact current authored public speech "+label)
	else: _check(adapter.presenters[id].active_action() == RoutinePresentation.CLIPS[id][actor.current_step().action_id],"actual exported action clip "+label)
	presentation_seen[label] = {"actor":actor.snapshot(),"speech":output.speech.text,"action":adapter.presenters[id].active_action()}
	await _capture(label)
	await _resume()
	_key(KEY_P,true); _key(KEY_P,false); await process_frame
	await _pause(); await _capture(label+"-alternate-projection"); await _resume()

func _recovery_day() -> bool:
	if not await _walk(NpcRegistry.find("npc-03").approach,"ordinary-recovery-lead"): return false
	await _talk("prototype-maris-counter:intro-0","recovery-lead")
	if not await _choose("maris-lead-choice","lead-accepted"): return false
	_close()
	_key(KEY_J,true); _key(KEY_J,false); await process_frame
	await _click(game.ui.upgrade_button.get_global_rect().get_center())
	_check(game.player_placeholder.combat.damage == 40,"ordinary journal strike preparation")
	_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	for goal: Vector3 in [Vector3(93,0,-.5),Vector3(103,0,-.5),Vector3(107.25,0,-1.25)]:
		if not await _walk(goal,"ordinary-east-main-bridge-"+str(goal.x)): return false
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn("prototype-tollworks"): return false
	await _pause(); await _capture("ordinary-tollworks-full-party",true); await _resume()
	if not await _walk(Vector3(0,0,-.5),"ordinary-guardian-combat"): return false
	if not await _fight(): return false
	await _pause(); await _capture("ordinary-guardian-cleared",true); await _resume()
	if not await _walk(Vector3(3.5,0,4.5),"ordinary-recovery-vessel"): return false
	_key(KEY_E,true); _key(KEY_E,false); await process_frame
	_check(game.dialogue.active(),"ordinary vessel interaction")
	if not game.dialogue.active(): return false
	await _record_node("ordinary-vessel")
	for index: int in range(4):
		if not game.ui.dialogue_next.visible: break
		await _click(game.ui.dialogue_next.get_global_rect().get_center())
	if not await _choose("maris-vessel-choice","ordinary-vessel-open"): return false
	_close()
	if not await _walk(Vector3(0,0,-4.5),"ordinary-tollworks-return-gate"): return false
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(RoutineExecutionWorld.TOWN): return false
	for goal: Vector3 in [Vector3(75,0,12.5),Vector3(66,0,12.5),NpcRegistry.find("npc-03").approach]:
		if not await _walk(goal,"ordinary-west-ford-"+str(goal.x)): return false
	await _talk("prototype-maris-fitting:intro-0","ordinary-fitting")
	for index: int in range(2): await _click(game.ui.dialogue_next.get_global_rect().get_center())
	if not await _choose("maris-reconnect-choice","ordinary-reconnected"): return false
	_close()
	_check(game.session.completed_effect_ids.size() == 6 and game.world_host.current_location.get_node("MarisCounter").presentation == "specialist","ordinary complete recovery exactly once")
	_check(TestRunRoutines.contacts_match(game) and game.party.members().size() == 2,"actual scheduled contacts and persistent ally after both crossings")
	return failures.is_empty()

func _read_day() -> void:
	await _pause()
	_check(game.session.conversations.events().snapshot().last_sequence == 0,"fresh separate reader before Load")
	var file: FileAccess = FileAccess.open(game.save_repository.path+".r015-oracle",FileAccess.READ)
	_check(file != null,"ordinary writer oracle exists in isolated shared group")
	if file == null: return
	var oracle: Dictionary = file.get_var(false); file.close()
	var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
	_check(loaded.ok,loaded.get("error","actual GUI Load"))
	if not loaded.ok: return
	var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
	_check(disk.session != null and disk.errors.is_empty(),"typed current-schema reader")
	if disk.session == null: return
	_check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"exact complete durable/forecast/new PID oracle")
	var backup: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(game.save_repository.path+".bak"),game.catalog,game.npc_catalog)
	_check(backup.session != null and backup.errors.is_empty() and TestRunSnapshot.exact_json(SaveCodec.snapshot(backup.session)) == oracle.snapshot_json,"complete typed backup equals ordinary writer oracle")
	_check(TestRunRoutines.contacts_match(game),"restored actual scheduled identities")
	await _capture("new-process-exact-gui-load",true); await _resume()
	if not await _walk(NpcRegistry.find("npc-03").approach,"restored-maris-physical-revisit"): return
	await _talk("prototype-maris-specialist:intro-0","remembered-specialist")
	_close(); await process_frame
	_check(game.session.completed_effect_ids.size() == 6 and game.session.inventory.count("item-moonflower") == 0 and game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-02") == 1,"revisit retains recovery/social/item conservation")
	if not await _enter_inn("restored-public-della-revisit-door"): return
	if not await _walk(NpcRegistry.find("npc-14").approach,"restored-della-physical-revisit"): return
	if not await _open_person("npc-14","remembered-della-after-full-day"): return
	_check(game.dialogue.snapshot().node_id == "npc-14-return","remembered ordinary indoor Della")
	_close(); await process_frame
	if not await _exit_inn("restored-inn-return"): return
	await _pause(); await _capture("new-process-physical-revisits-complete",true)

func _capture(label: String, overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input",overlay,"R015 fresh ordinary public controls, natural clock/forecast and actual physical routines; nav guidance only; no state/position/time/weather setup")
	_check(result.ok,result.get("error","verified pause capture"))
	if result.ok: captures.append(result)

func _dialogue_capture(label: String) -> void:
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-%03d-" % captures.size()+label,TestRunEvidence.directory(),"debug-input","R015 actual scheduled contact through ordinary WASD/E/GUI; natural clock continues during dialogue")
	_check(result.ok,result.get("error","live dialogue capture"))
	if result.ok: captures.append(result)
