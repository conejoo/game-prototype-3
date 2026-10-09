extends "res://tests/support/routine_execution_fixture.gd"
## Synthetic initial clock and safe party feet; then unaccelerated root execution
## and public WASD/E/P/Esc. No native or full ordinary-day claim.
var views: Array[Dictionary] = []
var traces: Array[Dictionary] = []
var focus_restorations: int = 0

func _run() -> void:
	root.size = Vector2i(960,640)
	if "--phase=morning" not in OS.get_cmdline_user_args() and await setup(1200,"prototype-alderwake",false): await _night()
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free(); await process_frame
	if failures.is_empty() and await setup(480,"prototype-mayor-vale-home",false): await _morning()
	check(TestRunEvidence.write_json("cross-map-render-index.json",{"task":"R010","assertions":assertions,"failures":failures,"views":views,"traces":traces,"observations":observations,"provenance":"synthetic initial 20:00 town and 08:00 home reconstruction/party feet; afterwards unaccelerated root clock and real physical NPC paths, ordinary public WASD/E/P/Esc; no native/natural full-day claim"}),"render evidence")
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R010 render %d assertions %d captures %d failures" % [assertions,views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _night() -> void:
	if not await _focus(): return
	game.player_placeholder.global_position = Vector3(7,0,-2.5)
	game.companion.global_position = Vector3(8.2,0,-2.5)
	for frame: int in range(20): await physics_frame
	await _key(KEY_ESCAPE); await _capture("town-edric-walking"); await _key(KEY_ESCAPE)
	for frame: int in range(600):
		await physics_frame
		if execution.actor("npc-01").phase == "door" and execution.actor("npc-01").foot.distance_to(Vector3(5,0,-5.15)) <= .25: break
	check(execution.actor("npc-01").phase == "door" and execution.actor("npc-01").foot.distance_to(Vector3(5,0,-5.15)) <= .25,"live loaded physical source door approach")
	await _key(KEY_ESCAPE); await _capture("town-edric-door"); await _key(KEY_ESCAPE)
	for frame: int in range(600):
		await physics_frame
		if execution.actor("npc-01").map_id == "prototype-mayor-vale-home": break
	check(execution.actor("npc-01").map_id == "prototype-mayor-vale-home","live unaccelerated loaded departure")
	check(not game.world_host.current_location.npc_contacts.targets.has("npc-01"),"actual departure removes body/contact")
	# Let offscreen valid-chain motion clear its arrival before player enters.
	for frame: int in range(600):
		await physics_frame
		if execution.actor("npc-01").state == RoutineExecutor.State.WAITING: break
	var walked: Dictionary = await TestRunJourney.walk(game,Vector3(5,0,-5.15),"public-follow-edric-home-door")
	traces.append(walked); check(walked.ok,walked.error)
	if not walked.ok: return
	await _key(KEY_E)
	if game.world_host.transitioning: await game.world_host.transition_finished
	check(game.session.current_location_id == "prototype-mayor-vale-home","public E actual home entry")
	if game.session.current_location_id != "prototype-mayor-vale-home": return
	check(game.world_host.current_location.npc_contacts.targets.size() == 2,"one actual Edric/Helena home pair")
	walked = await TestRunJourney.walk(game,Vector3(2,0,-8.5),"public-clear-home-central-hall")
	traces.append(walked); check(walked.ok,walked.error)
	if not walked.ok: return
	await _key(KEY_ESCAPE); await _capture("home-pair-evening-arrival"); await _key(KEY_ESCAPE)
	await _key(KEY_P); await _key(KEY_ESCAPE); await _capture("home-pair-perspective"); await _key(KEY_ESCAPE)
	# Actual sole clock crosses 22:00 naturally; no seek after initial 20:00 setup.
	for frame: int in range(4800):
		await physics_frame
		if not game.window_focused and not await _focus(): return
		var edric: RoutineExecutor = execution.actor("npc-01")
		if edric.state in [RoutineExecutor.State.FAILED,RoutineExecutor.State.CANCELLED]: break
		if edric.routine.id == "vale-overnight-home" and edric.current_step().id == "rest-until-morning" and execution.actor("npc-02").current_step().id == "rest-until-morning": break
	var edric: RoutineExecutor = execution.actor("npc-01")
	check(edric.routine.id == "vale-overnight-home" and edric.current_step().id == "rest-until-morning" and edric.failure == RoutineExecutor.Failure.NONE,"unaccelerated ordinary 22:00 transition reaches home rest")
	check(edric.foot.distance_to(Vector3(-5.5,0,.25)) < .005,"ordinary home rest exact Edric feet")
	await _key(KEY_ESCAPE); await _capture("home-pair-night-rest"); await _key(KEY_ESCAPE)
	# R010 proves physical rest and morning return. Routine dialogue/group leases
	# belong to R011; retained optional contact failure is not relabeled as success.
	observations.append({"case":"unaccelerated 20:00-to-night live clock","clock":game.session.environment.day_cycle_progress,"execution":execution.snapshot(),"transfers":execution.transfers})

func _morning() -> void:
	if not await _focus(): return
	# Synthetic initial viewing pose in the study, clear of both breakfast routes;
	# ordinary companion follow remains active throughout this rendered phase.
	game.player_placeholder.global_position = Vector3(6,0,-4.5)
	game.companion.global_position = Vector3(7,0,-4.5)
	for frame: int in range(30): await physics_frame
	await _key(KEY_ESCAPE); await _capture("home-edric-morning-walk"); await _key(KEY_ESCAPE)
	for frame: int in range(1800):
		await physics_frame
		if not game.window_focused and not await _focus(): return
		if execution.actor("npc-01").map_id == "prototype-alderwake" or execution.actor("npc-01").state == RoutineExecutor.State.FAILED: break
	var movements: Dictionary = {}
	for id: String in game.world_host.current_location.npc_contacts.movers:
		var mover: RoutineMovement = game.world_host.current_location.npc_contacts.movers[id]
		movements[id] = {"state":mover.state,"failure":mover.failure,"blocker":mover.blocker,"repaths":mover.repaths,"path_requests":mover.path_requests}
	observations.append({"case":"rendered physical morning departure","execution":execution.snapshot(),"movements":movements,"player_foot":game.player_placeholder.global_position,"ally_foot":game.companion.global_position,"window_focused":game.window_focused})
	check(execution.actor("npc-01").map_id == "prototype-alderwake" and execution.actor("npc-01").failure == RoutineExecutor.Failure.NONE,"live physical south-door morning departure")
	check(not game.world_host.current_location.npc_contacts.targets.has("npc-01") and game.world_host.current_location.npc_contacts.targets.has("npc-02"),"one Helena retained in home archive")
	var walked: Dictionary = await TestRunJourney.walk(game,Vector3(0,0,.25),"public-follow-edric-south-exit")
	traces.append(walked); check(walked.ok,walked.error)
	if not walked.ok: return
	var before_portal: PrototypeInteractable = InteractionSelector.select(game.player_placeholder,game.world_host.current_location)
	var outcomes: Array[Dictionary] = []
	var remaining_before: float = execution.actor("npc-01").remaining
	game.world_host.transition_finished.connect(func(ok: bool, errors: PackedStringArray) -> void: outcomes.append({"ok":ok,"errors":Array(errors)}),CONNECT_ONE_SHOT)
	await _key(KEY_E)
	for frame: int in range(120):
		if game.session.current_location_id == "prototype-alderwake" or not outcomes.is_empty(): break
		await physics_frame
	if game.session.current_location_id == RoutineExecutionWorld.HOME and not outcomes.is_empty() and not outcomes[0].ok:
		check("spawn 'alderwake-from-mayor-vale-home' is obstructed for 'party-player'" in outcomes[0].errors,"public early return correctly refuses occupied Edric arrival")
		check(execution.actor("npc-01").remaining <= remaining_before,"public rollback cannot restart offscreen travel timer")
		for frame: int in range(300):
			await physics_frame
			if not game.window_focused and not await _focus(): return
			if execution.actor("npc-01").index >= 2: break
		check(execution.actor("npc-01").index >= 2,"ordinary finite clock clears town arrival before public retry")
		game.world_host.transition_finished.connect(func(ok: bool, errors: PackedStringArray) -> void: outcomes.append({"ok":ok,"errors":Array(errors)}),CONNECT_ONE_SHOT)
		await _key(KEY_E)
		for frame: int in range(120):
			if game.session.current_location_id == RoutineExecutionWorld.TOWN or outcomes.size() > 1: break
			await physics_frame
	observations.append({"case":"public morning portal","target":before_portal.instance_id if is_instance_valid(before_portal) else "none","outcomes":outcomes,"location":game.session.current_location_id,"prompt":game.ui.travel_label.text,"dialogue":game.dialogue.active(),"execution":execution.snapshot()})
	check(game.session.current_location_id == "prototype-alderwake","public morning home return")
	if game.session.current_location_id != "prototype-alderwake": return
	for frame: int in range(600):
		await physics_frame
		if execution.actor("npc-01").index >= 2: break
	check(game.world_host.current_location.npc_contacts.targets.has("npc-01") and execution.actor("npc-01").foot.distance_to(Vector3(-.5,0,-1.5)) < .005,"single live town Edric finishes morning arrival")
	await _key(KEY_ESCAPE); await _capture("town-edric-morning-return")

func _capture(label: String, overlay: bool = false) -> void:
	check(paused and game.ui.pause_overlay.visible,"verified pause "+label)
	var before: Dictionary = execution.snapshot()
	var result: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",overlay,"Synthetic initial clock/party feet; subsequent unaccelerated root routine execution, actual door departure/arrival and public WASD/E/P/Esc")
	check(result.ok,result.get("error","capture "+label))
	check(execution.snapshot() == before,"pause/capture preserves feet/timers "+label)
	if result.ok: result.execution = before; views.append(result)

func _key(code: Key) -> void:
	if not await _focus(): return
	var event: InputEventKey = InputEventKey.new(); event.keycode = code; event.physical_keycode = code; event.pressed = true
	root.push_input(event,true); await process_frame
	event = InputEventKey.new(); event.keycode = code; event.physical_keycode = code; event.pressed = false
	root.push_input(event,true); await process_frame

func _focus() -> bool:
	if root.has_focus() and game.window_focused: return true
	# Real OS activation and root notification; never overwrite focus/control gates.
	focus_restorations += 1
	if focus_restorations > 10:
		check(false,"bounded foreground restoration exhausted")
		return false
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var focused: bool = root.has_focus() and game.window_focused
	check(focused,"actual foreground focus after OS activation")
	traces.append({"label":"actual-foreground-restoration","count":focus_restorations,"root_focus":root.has_focus(),"window_focused":game.window_focused})
	return focused
