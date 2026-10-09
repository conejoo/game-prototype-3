extends "res://tests/routine_inn_render.gd"
## R013 ordinary fresh route and separately labeled synthetic 17:00 river review.
var routes: Array[Dictionary] = []
func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.substr(8)
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate(); root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"default production startup")
	if await _focus_r013():
		if phase == "river": await _river_r013()
		else: await _ordinary_r013()
	_check(TestRunEvidence.write_json("activation-"+phase+"-index.json",{"task":"R013","phase":phase,"assertions":assertions,"failures":failures,"views":captures,"traces":traces,"routes":routes,"nodes":visited,"choices":chosen,"snapshot":SaveCodec.snapshot(game.session),"provenance":"fresh ordinary public WASD/E/GUI/Esc/P, actual facts/gather/gift/flag, default owner and navigation guidance; no state/time/weather/position setup" if phase != "river" else "synthetic initial 17:00 current-schema load/party viewing placement; default owner then full unaccelerated physical river route past unchanged Tess; public projection/zoom/pause"}),"R013 render evidence")
	paused = false; game.queue_free(); await process_frame
	for failure: String in failures: push_error(failure)
	print("R013 render ",phase," assertions=",assertions," captures=",captures.size()," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _focus_r013() -> bool:
	if root.has_focus() and game.window_focused: return true
	DisplayServer.window_move_to_foreground()
	for frame: int in range(10): await process_frame
	_check(root.has_focus() and game.window_focused,"real focused gameplay window")
	return root.has_focus() and game.window_focused

func _ordinary_r013() -> void:
	_check(PeopleSnapshot.from_state(game.session.conversations,game.npc_catalog).people.is_empty(),"unmet People remains empty with schedules")
	await _pause(); await _capture("default-fresh-scheduled-town",true); await _resume()
	if not await _walk(Vector3(-.5,0,-.6),"actual-morning-edric"): return
	if not await _open_person("npc-01","intro-edric-scheduled"): return
	var view: Dictionary = game.dialogue.snapshot()
	if not await _choose(view.choices[0].id,"earned-edric-public-introduction"): return
	_close(); await process_frame
	_check(PeopleSnapshot.from_state(game.session.conversations,game.npc_catalog).people.size() == 1,"only actually met Edric in People")
	# Public north lane avoids the solid shop contact at the corner of the
	# static shortest navmesh path; guidance never moves a body directly.
	if not await _walk(Vector3(12,0,-1),"public-north-shop-lane"): return
	if not await _walk(Vector3(34.5,0,20),"scheduled-ivo-booking"): return
	if not await _open_person("npc-07","intro-ivo-scheduled"): return
	view = game.dialogue.snapshot()
	if not await _choose(view.choices[0].id,"earned-ivo-introduction"): return
	_close(); await process_frame
	if not await _walk(Vector3(27.5,.25,-2),"real-moonflower-for-scheduled-helena"): return
	game._refresh_interaction()
	_check(game.selected_interaction != null and game.selected_interaction.instance_id == "moonflower-01","real finite flower selection")
	if game.selected_interaction == null or game.selected_interaction.instance_id != "moonflower-01": return
	_key(KEY_E,true); await create_timer(.8).timeout; _key(KEY_E,false)
	_check(game.session.inventory.count("item-moonflower") == 1 and game.session.conversations.events().count(NpcEventMemory.GATHER,"moonflower",null) == 1,"actual gather event and conserved item")
	if not await _walk(Vector3(5,0,-5.15),"public-vale-home-door"): return
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(RoutineExecutionWorld.HOME): return
	# Clear the narrow arrival lane with public input before waiting for NPCs.
	for foot: Vector3 in [Vector3(0,0,-4),Vector3(-2,0,-4)]:
		if not await _walk(foot,"public-home-clear-arrival-"+str(foot.x)): return
	routes.append({"case":"natural-home-before-afternoon","actors":game.routine_execution.snapshot()})
	# Wait naturally for the afternoon branch when this short route finishes early.
	for frame: int in range(5400):
		await physics_frame
		var actor: RoutineExecutor = game.routine_execution.actor("npc-02")
		if actor.routine.id == "helena-afternoon-moonflower-records" and actor.map_id == RoutineExecutionWorld.HOME and actor.state == RoutineExecutor.State.ACTING: break
	var actor: RoutineExecutor = game.routine_execution.actor("npc-02")
	routes.append({"case":"natural-home-afternoon","actors":game.routine_execution.snapshot()})
	_check(actor.routine.id == "helena-afternoon-moonflower-records" and actor.map_id == RoutineExecutionWorld.HOME and actor.state == RoutineExecutor.State.ACTING,"real gather selects active home moonflower records "+str(actor.snapshot()))
	if actor.map_id != RoutineExecutionWorld.HOME or actor.state != RoutineExecutor.State.ACTING: return
	if not await _walk(Vector3(2.75,0,0),"scheduled-helena-archive-contact"): return
	if not await _open_person("npc-02","routine-helena-real-gather"): return
	_check(game.ui.dialogue_view.counter_route.visible and game.ui.dialogue_view.counter_route.text == "Chat","visible routine-to-ordinary Chat route")
	var lease: RoutineDialogueContext = game.routine_execution._lease
	await _click(game.ui.dialogue_view.counter_route.get_global_rect().get_center())
	_check(game.dialogue.snapshot().node_id == "npc-02-initial-conversation" and game.routine_execution._lease == lease,"public Chat opens ordinary introduction without releasing routine lease")
	await _dialogue_capture("helena-ordinary-chat-during-routine")
	view = game.dialogue.snapshot()
	if not await _choose(view.choices[0].id,"earned-helena-introduction"): return
	_close(); await process_frame
	if not await _open_person("npc-02","routine-to-gather-preference"): return
	await _click(game.ui.dialogue_view.counter_route.get_global_rect().get_center())
	_check(game.dialogue.snapshot().node_id == "npc-02-moonflower-hint","earned gather preference accessible during routine")
	if not await _choose("npc-02-gift-moonflower-from-hint","ordinary-gift-at-actual-archive"): return
	_close(); await process_frame
	_check(game.session.inventory.count("item-moonflower") == 0 and game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-02") == 1,"actual scheduled gift consumes once")
	if not await _open_person("npc-02","helena-authored-routine-outcome"): return
	if not await _choose("npc-02-review-archive-ledger-choice","earned-ledger-flag"): return
	_check("npc-02-archive-lead-shared" in game.session.conversations.memory("npc-02").flags and game.routine_execution.actor("npc-02").routine.id == "helena-afternoon-ledger-review","real authored flag reselects live ledger routine")
	await _pause(); await _capture("earned-ledger-actual-home"); await _resume()
	if not await _walk(Vector3(0,0,.25),"public-home-return"): return
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(RoutineExecutionWorld.TOWN): return
	if not await _enter_inn("actual-scheduled-della-door"): return
	_check(TestRunRoutines.contacts_match(game) and game.world_host.current_location.npc_contacts.targets.keys() == ["npc-14"],"one actual indoor Della")
	if not await _walk(NpcRegistry.find("npc-14").approach,"actual-scheduled-della-contact"): return
	if not await _open_person("npc-14","intro-della-scheduled"): return
	view = game.dialogue.snapshot()
	if not await _choose(view.choices[0].id,"earned-della-introduction"): return
	_close(); await process_frame
	_check(PeopleSnapshot.from_state(game.session.conversations,game.npc_catalog).people.size() == 4,"met-only People across actual maps excludes four unseen villagers")
	await _pause(); await _capture("scheduled-inn-host"); await _resume()
	if not await _exit_inn("actual-inn-return"): return
	await _pause(); await _capture("ordinary-scheduled-route-complete",true)
	routes.append(game.routine_execution.snapshot())

func _river_r013() -> void:
	await _pause()
	var run: GameSession = game.session
	run.environment.day_cycle_progress = (1020.0-600)/1440
	_check(game.save_repository.write(run,game.catalog).is_empty(),"synthetic 17:00 valid current-schema stage")
	_check((await game.load_run()).is_empty(),"default production owner reconstructed 17:00")
	game.player_placeholder.global_position = Vector3(13,0,-1)
	game.companion.global_position = Vector3(12,0,-1)
	game._sync_npc_visuals()
	await _resume()
	var actor: RoutineExecutor = game.routine_execution.actor("npc-01")
	var start: Vector3 = actor.foot
	var moved: bool = false
	for frame: int in range(2400):
		await physics_frame
		moved = moved or actor.foot.distance_to(start) > 1
		if actor.state in [RoutineExecutor.State.SPEAKING,RoutineExecutor.State.FAILED]: break
	_check(moved and actor.state == RoutineExecutor.State.SPEAKING and actor.foot.distance_to(Vector3(15,0,1.5)) < .005,"full ordinary-rate physical river route around solid Tess")
	if actor.state != RoutineExecutor.State.SPEAKING: return
	await _pause(); await _capture("full-river-route-speech-ortho"); await _resume()
	_key(KEY_P,true); _key(KEY_P,false); await process_frame
	await _pause(); await _capture("full-river-route-speech-perspective"); await _resume()
	for frame: int in range(600):
		await physics_frame
		if actor.state == RoutineExecutor.State.ACTING: break
	_check(actor.state == RoutineExecutor.State.ACTING and game.world_host.current_location.npc_contacts.presenters["npc-01"].active_action() == "action_river_fishing","full route leads to real fishing art, no reward")
	await _pause(); await _capture("full-river-route-fishing")
	routes.append({"start":start,"actor":actor.snapshot(),"mover_repaths":game.world_host.current_location.npc_contacts.movers["npc-01"].repaths})

func _capture(label: String, overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"synthetic" if phase == "river" else "debug-input",overlay,"R013 synthetic initial 17:00/party view; complete unaccelerated physical route and public inputs" if phase == "river" else "R013 fresh ordinary public controls/default schedules/earned facts,gather,gift,flag; navigation guidance only")
	_check(result.ok,result.get("error","capture"))
	if result.ok: captures.append(result)

func _dialogue_capture(label: String) -> void:
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-%03d-" % captures.size()+label,TestRunEvidence.directory(),"debug-input","R013 actual scheduled contact through public WASD/E/GUI; clock continues during dialogue")
	_check(result.ok,result.get("error","dialogue capture"))
	if result.ok: captures.append(result)
