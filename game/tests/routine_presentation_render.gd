extends "res://tests/support/routine_execution_fixture.gd"
## R012 synthetic initial clock/party; subsequent live unaccelerated execution.
var views: Array[Dictionary] = []
var traces: Array[Dictionary] = []
var focus_restorations: int = 0
func _run() -> void:
	root.size = Vector2i(960,640)
	if await setup(1050,RoutineExecutionWorld.TOWN,false): await _river()
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free(); await process_frame
	if failures.is_empty() and await setup(850,RoutineExecutionWorld.HOME,false): await _archive()
	check(TestRunEvidence.write_json("presentation-render-index.json",{"task":"R012","assertions":assertions,"failures":failures,"views":views,"traces":traces,"observations":observations,"provenance":"synthetic initial clocks/party viewing feet; subsequent unaccelerated real routines/physics/animation and public projection/zoom/journal/pause; no ordinary schedule activation/native/full-day claim"}),"render index")
	paused = false
	if execution != null: execution.dispose()
	if game != null: game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R012 presentation render %d assertions %d captures %d failures" % [assertions,views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _river() -> void:
	if not await _focus(): return
	game.player_placeholder.global_position = Vector3(13,0,3.5)
	game.companion.global_position = Vector3(12,0,3.5)
	var cursor: RoutineExecutor = execution.actor("npc-01")
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	# Explicit bounded art setup: start one metre before the unchanged pinned
	# river anchor, then real 2m/s physics completes the existing declared leg.
	cursor.index = 1; cursor.state = RoutineExecutor.State.READY; cursor.phase = ""; cursor.remaining = 0
	adapter.targets["npc-01"].global_position = Vector3(14,0,1.5)
	cursor.foot = Vector3(14,0,1.5)
	for frame: int in range(10): await physics_frame
	check(cursor.state == RoutineExecutor.State.MOVING and adapter.presenters["npc-01"].player.current_animation == "walk","physical river walk without rod")
	await _key(KEY_ESCAPE); await _capture("edric-river-walk"); await _key(KEY_ESCAPE)
	for frame: int in range(700):
		await physics_frame
		if cursor.state == RoutineExecutor.State.SPEAKING: break
	check(cursor.state == RoutineExecutor.State.SPEAKING,"natural current-step river speech")
	await _key(KEY_ESCAPE); await _capture("edric-speech-ortho"); await _key(KEY_ESCAPE); await _key(KEY_P); await _key(KEY_ESCAPE); await _capture("edric-speech-perspective")
	await _key(KEY_ESCAPE); await _key(KEY_MINUS); await _key(KEY_MINUS); await _key(KEY_MINUS); await _key(KEY_ESCAPE); await _capture("edric-speech-far")
	check(is_equal_approx(game.camera_rig.zoom_factor,1.15),"actual far zoom bound")
	await _key(KEY_ESCAPE)
	for press: int in range(7): await _key(KEY_PLUS)
	await _key(KEY_ESCAPE); await _capture("edric-speech-near")
	check(is_equal_approx(game.camera_rig.zoom_factor,.8),"actual near zoom bound")
	await _key(KEY_ESCAPE)
	var remaining: float = cursor.remaining
	await _key(KEY_J)
	check(game.journal_open,"public modal holds speech")
	for frame: int in range(10): await physics_frame
	check(cursor.remaining <= remaining and not adapter.routine_presentations["npc-01"].speech.visible,"modal hides speech and freezes active timer")
	var modal_remaining: float = cursor.remaining
	for frame: int in range(10): await physics_frame
	check(cursor.remaining == modal_remaining,"actual modal timer exact")
	await _key(KEY_ESCAPE)
	for frame: int in range(360):
		await physics_frame
		if cursor.state == RoutineExecutor.State.ACTING: break
	check(cursor.state == RoutineExecutor.State.ACTING and adapter.presenters["npc-01"].active_action() == "action_river_fishing" and not adapter.routine_presentations["npc-01"].speech.visible,"speech expires into actual fishing prop")
	await _key(KEY_ESCAPE); await _capture("edric-fishing-perspective"); await _key(KEY_ESCAPE); await _key(KEY_P); await _key(KEY_ESCAPE); await _capture("edric-fishing-ortho"); await _key(KEY_ESCAPE)
	for frame: int in range(20): await physics_frame
	await _key(KEY_ESCAPE); await _capture("edric-fishing-next-pose")

func _archive() -> void:
	if not await _focus(): return
	game.player_placeholder.global_position = Vector3(6,0,-4.5)
	game.companion.global_position = Vector3(7,0,-3.5)
	var cursor: RoutineExecutor = execution.actor("npc-02")
	for frame: int in range(30): await physics_frame
	check(cursor.state == RoutineExecutor.State.ACTING and game.world_host.current_location.npc_contacts.presenters["npc-02"].active_action() == "action_archive_work","live archive action at exact desk")
	await _key(KEY_ESCAPE); await _capture("helena-archive-ortho"); await _key(KEY_ESCAPE); await _key(KEY_P); await _key(KEY_ESCAPE); await _capture("helena-archive-perspective"); await _key(KEY_ESCAPE)
	for frame: int in range(4800):
		await physics_frame
		if cursor.state == RoutineExecutor.State.SPEAKING: break
	check(cursor.state == RoutineExecutor.State.SPEAKING,"archive action completes into finite public speech")
	await _key(KEY_ESCAPE); await _capture("helena-archive-speech"); await _key(KEY_ESCAPE)
	for frame: int in range(500):
		await physics_frame
		if cursor.state == RoutineExecutor.State.MOVING: break
	check(cursor.state == RoutineExecutor.State.MOVING,"archive speech expires into physical shelf walk")
	for frame: int in range(8): await physics_frame
	await _key(KEY_ESCAPE); await _capture("helena-shelf-walk"); await _key(KEY_ESCAPE)
	for frame: int in range(500):
		await physics_frame
		if cursor.state == RoutineExecutor.State.ACTING: break
	check(cursor.state == RoutineExecutor.State.ACTING,"shelf walk returns to declared action")
	await _key(KEY_ESCAPE); await _capture("helena-shelf-action")

func _capture(label: String) -> void:
	check(paused and game.ui.pause_overlay.visible,"verified pause "+label)
	var before: Dictionary = execution.snapshot()
	var result: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"Synthetic initial clock/party viewing feet; unaccelerated live actual feet/action/speech, public pause/projection/zoom, explicit river one-metre precursor placement, no default activation")
	check(result.ok,result.get("error","capture"))
	check(execution.snapshot() == before,"capture freezes executor feet/timers")
	if result.ok: result.execution = before; views.append(result)

func _key(code: Key) -> void:
	if not await _focus(): return
	var event: InputEventKey = InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=true
	root.push_input(event,true); await process_frame
	event = InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=false
	root.push_input(event,true); await process_frame

func _focus() -> bool:
	if root.has_focus() and game.window_focused: return true
	focus_restorations += 1
	if focus_restorations > 10: check(false,"focus restoration limit"); return false
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var focused: bool = root.has_focus() and game.window_focused
	check(focused,"guarded real window focus")
	return focused
