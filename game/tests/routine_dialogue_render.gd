extends "res://tests/support/routine_dialogue_fixture.gd"
## Synthetic initial 13:30/00:00 clock, real party arrivals; public input afterwards.
var views: Array[Dictionary] = []
var traces: Array[Dictionary] = []
var phase: String = "write"

func _run() -> void:
	root.size = Vector2i(960,640)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.substr(8)
	if await setup(810 if phase == "write" else 600,"prototype-mayor-vale-home" if phase == "write" else "prototype-alderwake",false):
		bind_dialogue()
		check(TestRunSave.configure(game,"user://saves/r011-dialogue.json").is_empty(),"isolated GUI primary/backup slot")
		if await _focus():
			if phase == "write": await _archive()
			else: await _restart()
	if phase == "write" and failures.is_empty():
		paused = false; game.dialogue.cancel(); execution.dispose(); game.queue_free(); await process_frame
		if await setup(0,"prototype-mayor-vale-home",false):
			bind_dialogue()
			if await _focus(): await _rest_access()
	check(TestRunEvidence.write_json("routine-dialogue-"+phase+"-index.json",{"task":"R011","assertions":assertions,"failures":failures,"views":views,"traces":traces,"observations":observations,"provenance":"synthetic initial clock/real arrival; ordinary viewport WASD/E/GUI choices/Esc/P; unaccelerated clock thereafter; no natural full-day/native claim"}),"render index")
	await finish("render-"+phase+".json")

func _archive() -> void:
	if not await _walk(Vector3(2.75,0,0),"archive-contact-approach"): return
	await _key(KEY_E)
	check(game.dialogue.active() and game.dialogue.snapshot().get("node_id") == "npc-02-routine-archive-indexing","public E opens live indexing step")
	if not game.dialogue.active(): return
	await _dialogue_capture("archive-indexing")
	var actor: RoutineExecutor = execution.actor("npc-02")
	var state: Dictionary = actor.snapshot()
	for frame: int in 30: await physics_frame
	check(actor.snapshot() == state,"actual visible conversation holds action timer/feet")
	check(not game.save_run().is_empty(),"manual save blocked during dialogue")
	await _choice("npc-02-resume-archive-indexing-choice")
	check(not game.dialogue.active() and execution._lease == null,"public resume closes lease")
	await _key(KEY_E)
	check(game.dialogue.active(),"public reopen indexing")
	if not game.dialogue.active(): return
	await _choice("npc-02-review-archive-ledger-choice")
	check("npc-02-archive-lead-shared" in game.session.conversations.memory("npc-02").flags,"public real Helena lead flag")
	check(execution.actor("npc-02").routine.id == "helena-afternoon-ledger-review","public close selects real ledger condition")
	await _key(KEY_E)
	check(game.dialogue.active() and game.dialogue.snapshot().get("node_id") == "npc-02-routine-archive-default","new movement step opens routine default")
	if not game.dialogue.active(): return
	check("npc-02-archive-practice" in game.session.conversations.memory("npc-02").learned_fact_ids,"public default entry grants authored practice fact")
	await _dialogue_capture("archive-default-fact")
	await _choice("npc-02-end-archive-default-choice")
	check(game.session.routines.suppressed("helena-afternoon-ledger-review"),"public end suppresses current ledger routine")
	await _key(KEY_ESCAPE)
	check(paused and game.ui.pause_overlay.visible,"verified pause before GUI Save")
	var result: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return FileAccess.file_exists(game.save_repository.path))
	traces.append(result); check(result.ok,result.get("error","GUI Save"))
	if not result.ok: return
	check(FileAccess.file_exists(game.save_repository.path+".bak"),"first GUI Save publishes primary and backup")
	var file: FileAccess = FileAccess.open(game.save_repository.path+".oracle",FileAccess.WRITE)
	check(file != null,"GUI writer oracle")
	if file != null: file.store_string(JSON.stringify(TestRunSnapshot.oracle(game.session),"",true,true)); file.close()
	await _capture("archive-saved",true)
	observations.append({"case":"public Helena three directives","directives":execution.directives,"snapshot":SaveCodec.snapshot(game.session),"pid":OS.get_process_id()})

func _restart() -> void:
	await _key(KEY_ESCAPE)
	check(paused and game.ui.pause_overlay.visible,"fresh reader verified pause")
	var old: GameSession = game.session
	var result: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.session != old and not game.loading_save and not game.world_host.transitioning)
	traces.append(result); check(result.ok,result.get("error","new-process GUI Load"))
	if not result.ok: return
	var oracle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(game.save_repository.path+".oracle"))
	var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
	check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"exact full typed durable/forecast different-process GUI restore")
	check(game.dialogue.routine_owner == execution and execution._session == game.session and execution._lease == null,"restore binds actual owner without saved lease")
	for suffix: String in ["",".bak"]:
		var restored: SaveCodec.DecodeResult = SaveCodec.decode(FileAccess.get_file_as_string(game.save_repository.path+suffix),game.catalog,game.npc_catalog)
		check(restored.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(restored.session)) == oracle.snapshot_json,"exact current primary/backup "+suffix)
	await _capture("restored-archive-facts",true)
	observations.append({"case":"exact new-process GUI Load","pid":OS.get_process_id(),"writer_pid":oracle.writer_pid,"snapshot":SaveCodec.snapshot(game.session)})

func _rest_access() -> void:
	# Measured north-side route avoids Helena's solid capsule in south bed passage.
	for foot: Vector3 in [Vector3(0,0,-4),Vector3(-2,0,-4),Vector3(-5.35,0,-3.85)]:
		if not await _walk(foot,"far-side-rest-"+str(traces.size())): return
	for foot: Vector3 in [Vector3(-5.35,0,-2.35),Vector3(-5.58,0,-2.12),Vector3(-5.65,0,-1.05)]:
		if not await _corner_input(foot): return
	var target: PrototypeInteractable = InteractionSelector.select(game.player_placeholder,game.world_host.current_location)
	check(target != null and target.npc_id == "npc-01","far-side actual Edric range/LOS, no duplicate or collision exclusion")
	await _key(KEY_E)
	check(game.dialogue.active() and game.dialogue.snapshot().get("npc_id") == "npc-01","public E reaches far-side rest Edric")
	if not game.dialogue.active(): return
	check(execution._lease._targets.size() == 2,"rest conversation leases both actual loaded Vale contacts")
	var edric: Dictionary = execution.actor("npc-01").snapshot()
	var helena: Dictionary = execution.actor("npc-02").snapshot()
	await _dialogue_capture("far-side-rest-edric")
	for frame: int in 30: await physics_frame
	check(execution.actor("npc-01").snapshot() == edric and execution.actor("npc-02").snapshot() == helena,"actual rest group holds both feet/timers")
	await _key(KEY_ESCAPE); await _key(KEY_ESCAPE)
	await _capture("far-side-rest-overhead")
	await _key(KEY_ESCAPE); await _key(KEY_P); await _key(KEY_ESCAPE)
	await _capture("far-side-rest-perspective")

func _walk(foot: Vector3,label: String) -> bool:
	if not await _focus(): return false
	var result: Dictionary = await TestRunJourney.walk(game,foot,label,{"max_ms":30000,"max_frames":1800})
	traces.append(result); check(result.ok,result.error)
	return result.ok

func _choice(id: String) -> void:
	var view: Dictionary = game.dialogue.snapshot()
	var index: int = -1
	for i: int in view.choices.size():
		if view.choices[i].id == id: index = i
	check(index >= 0,"authored visible choice "+id)
	if index < 0: return
	var button: Button = game.ui.dialogue_choices.get_child(index)
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new(); motion.position = point
	root.push_input(motion,true); await process_frame
	for down: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT; event.position = point; event.pressed = down
		root.push_input(event,true); await process_frame
	check(not game.dialogue.active(),"actual GUI directive closes "+id)

func _dialogue_capture(label: String) -> void:
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-"+label,TestRunEvidence.directory(),"synthetic","Synthetic initial clock and actual arrival; ordinary viewport WASD/E/GUI, real routine lease")
	check(result.ok,result.get("error","dialogue capture"))
	if result.ok: views.append(result)

func _capture(label: String,overlay: bool = false) -> void:
	check(paused and game.ui.pause_overlay.visible,"verified pause "+label)
	var result: Dictionary = await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"synthetic",overlay,"Synthetic initial clock and actual arrival; ordinary viewport WASD/E/GUI/P/Esc; verified pause")
	check(result.ok,result.get("error","pause capture"))
	if result.ok: views.append(result)

func _key(code: Key) -> void:
	if not await _focus(): return
	for down: bool in [true,false]:
		var event: InputEventKey = InputEventKey.new(); event.keycode = code; event.physical_keycode = code; event.pressed = down
		root.push_input(event,true); await process_frame

func _focus() -> bool:
	if root.has_focus() and game.window_focused: return true
	DisplayServer.window_move_to_foreground()
	for frame: int in 5: await process_frame
	var ok: bool = root.has_focus() and game.window_focused
	check(ok,"actual OS foreground focus")
	return ok

func _corner_input(goal: Vector3) -> bool:
	# Static nav's extra 10cm furniture outline erodes this diagonal corner.
	# One bounded atomic viewport key hold per measured segment; physics remains
	# authoritative. No path override, collision exclusion, placement or input loop.
	if not await _focus(): return false
	var start: Vector3 = game.player_placeholder.global_position
	var direction: Vector3 = goal-start; direction.y = 0
	var best: Dictionary = {}; var dot: float = -INF
	for option: Dictionary in TestRunJourney.DIRECTIONS:
		var candidate: float = direction.normalized().dot(game.camera_rig.movement_direction(option.axes))
		if candidate > dot: best = option; dot = candidate
	var frames: int = clampi(roundi(direction.length()/game.player_placeholder.move_speed*Engine.physics_ticks_per_second),1,30)
	for code: Key in best.keys:
		var event: InputEventKey = InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=true
		root.push_input(event,true)
	for frame: int in frames: await physics_frame
	# Always release every key acquired by this bounded segment before observation.
	for code: Key in best.keys:
		var event: InputEventKey = InputEventKey.new(); event.keycode=code; event.physical_keycode=code; event.pressed=false
		root.push_input(event,true)
	for frame: int in 3: await physics_frame
	var actual: Vector3 = game.player_placeholder.global_position
	var ok: bool = actual.distance_to(goal) < .16 and game.player_placeholder.movement_buttons.is_empty()
	traces.append({"label":"bounded public corner key hold","start":TestRunObservation.vector(start),"goal":TestRunObservation.vector(goal),"actual":TestRunObservation.vector(actual),"frames":frames,"keys":best.keys,"camera":TestRunObservation.camera(game),"ok":ok,"setup":"no placement/collision/nav override"})
	check(ok,"measured physical corner segment "+str(actual)+" goal="+str(goal))
	return ok
