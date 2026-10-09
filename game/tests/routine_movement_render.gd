extends SceneTree
## R009 synthetic leg/initial party placement; ordinary live physics and public UI.
var game: Node3D
var adapter: NpcWorldAdapter
var target: PrototypeInteractable
var mover: RoutineMovement
var failures: PackedStringArray=[]
var assertions: int=0
var views: Array[Dictionary]=[]
var traces: Array[Dictionary]=[]

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size=Vector2i(960,640)
	game=load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array=await game.world_host.transition_finished
	_check(arrival[0],"fresh startup")
	if arrival[0]: await _journey()
	_check(TestRunEvidence.write_json("movement-render-index.json",{"task":"R009","assertions":assertions,"failures":failures,"views":views,"traces":traces,"provenance":"synthetic initial party placement and Ivo leg commands; unaccelerated real physics and public viewport walking/dialogue/journal/pause, no schedule activation"}),"evidence")
	paused=false; game.queue_free(); await process_frame
	for error: String in failures: push_error(error)
	print("R009 rendered movement %d assertions %d captures %d failures" % [assertions,views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _journey() -> void:
	adapter=game.world_host.current_location.npc_contacts
	target=adapter.targets["npc-07"]; mover=adapter.movers["npc-07"]
	game.player_placeholder.global_position=Vector3(34,0,18.5)
	game.companion.global_position=Vector3(35.2,0,18.5)
	for frame: int in range(8): await physics_frame
	_check(adapter.move_to("npc-07",Vector3(31,0,20)),"synthetic authored handoff leg")
	for frame: int in range(20): await physics_frame
	_check(mover.achieved_speed>1.99 and adapter.presenters["npc-07"].player.current_animation=="walk","live achieved motion selects exported walk")
	await _key(KEY_ESCAPE)
	await _capture("ivo-walk-ortho")
	await _key(KEY_ESCAPE); await _key(KEY_P)
	for frame: int in range(15): await physics_frame
	await _key(KEY_ESCAPE)
	await _capture("ivo-walk-perspective")
	await _key(KEY_ESCAPE)
	for frame: int in range(240):
		await physics_frame
		if mover.state not in [RoutineMovement.State.MOVING,RoutineMovement.State.WAITING]: break
	_check(mover.state==RoutineMovement.State.ARRIVED and target.global_position.distance_to(Vector3(31,0,20))<.005,"live physical arrival exact source handoff")
	for frame: int in range(4): await physics_frame
	_check(adapter.presenters["npc-07"].player.current_animation=="idle","arrival stops walk animation")
	await _key(KEY_ESCAPE); await _capture("ivo-arrived-idle"); await _key(KEY_ESCAPE)
	var walked: Dictionary=await TestRunJourney.walk(game,Vector3(32.1,0,20),"public-walk-to-moved-ivo")
	traces.append(walked); _check(walked.ok,walked.error)
	if not walked.ok: return
	_check(InteractionSelector.select(game.player_placeholder,game.world_host.current_location)==target,"public player route finds Ivo at actual moved station")
	# Start a return, then open ordinary conversation immediately. The root's
	# existing dialogue hold suspends live physics at actual feet.
	_check(adapter.move_to("npc-07",Vector3(36,0,20)),"synthetic return before public dialogue")
	await _key(KEY_E)
	_check(game.dialogue.active() and game.dialogue.snapshot().npc_id=="npc-07","public E moved contact")
	var feet: Vector3=target.global_position
	for frame: int in range(12): await physics_frame
	_check(target.global_position==feet and adapter.presenters["npc-07"].suspended(),"public dialogue holds moving actor")
	var captured: Dictionary=await TestRunInteractionCapture.dialogue(game,"ivo-dialogue-hold",TestRunEvidence.directory(),"synthetic","Synthetic Ivo leg/initial party feet; actual public walk/E conversation at moved feet, root hold, no routine dialogue")
	_check(captured.ok,captured.get("error","live dialogue capture"))
	if captured.ok: views.append(captured)
	await _key(KEY_ESCAPE)
	adapter.cancel_move("npc-07")
	walked=await TestRunJourney.walk(game,Vector3(33,0,18),"public-clear-ivo-return-lane")
	traces.append(walked); _check(walked.ok,walked.error)
	if not walked.ok: return
	_check(adapter.move_to("npc-07",Vector3(36,0,20)),"resume return from actual feet")
	await _key(KEY_J)
	_check(game.journal_open,"public journal opened")
	feet=target.global_position
	for frame: int in range(12): await physics_frame
	_check(target.global_position==feet,"public journal stops live motion")
	captured=await TestRunInteractionCapture.journal(game,"ivo-journal-hold",TestRunEvidence.directory(),"synthetic","Synthetic leg; public J root modal holds movement without pausing clock")
	_check(captured.ok,captured.get("error","live journal capture"))
	if captured.ok: views.append(captured)
	await _key(KEY_ESCAPE)
	for frame: int in range(240):
		await physics_frame
		if mover.state not in [RoutineMovement.State.MOVING,RoutineMovement.State.WAITING]: break
	_check(mover.state==RoutineMovement.State.ARRIVED and target.global_position.distance_to(Vector3(36,0,20))<.005,"return resumes physically without snap")
	await _key(KEY_P); await _key(KEY_ESCAPE); await _capture("ivo-return-idle-ortho",true)
	_check(adapter.occupancy.snapshot().reservations.is_empty(),"final no reserved station")

func _capture(label: String, overlay: bool=false) -> void:
	_check(paused and game.ui.pause_overlay.visible,"verified pause checkpoint "+label)
	var feet: Vector3=target.global_position
	var result: Dictionary=await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",overlay,"Synthetic Ivo move command/initial party placement; actual unaccelerated live 2m/s collision and public pause/projection; no ordinary schedule claim")
	_check(result.ok,result.get("error","capture "+label))
	_check(target.global_position==feet,"no movement through pause/capture "+label)
	if result.ok:
		result.npc_id="npc-07"; result.npc_foot=str(feet); result.movement_state=mover.state
		views.append(result)

func _key(code: Key) -> void:
	var event: InputEventKey=InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=true
	root.push_input(event,true); await process_frame
	event=InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=false
	root.push_input(event,true); await process_frame

func _check(ok: bool, label: String) -> void:
	assertions+=1
	if not ok: failures.append(label)
