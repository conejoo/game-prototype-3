extends "res://tests/npc_14_render.gd"
## N017 integrated ordinary input route. Inherited input/capture helpers send
## viewport events only; review setup is explicitly separate from ordinary play.
var visited: PackedStringArray = []
var chosen: PackedStringArray = []
var combat_traces: Array[Dictionary] = []
const TOUR: PackedStringArray = ["npc-01","npc-02","npc-06","npc-04","npc-07","npc-08","npc-03","npc-14"]

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase=arg.trim_prefix("--phase=")
	root.size=Vector2i(960,640)
	game=load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array=await game.world_host.transition_finished
	_check(startup[0],"fresh integrated arrival")
	if startup[0]:
		if phase == "survey": await _survey()
		elif phase == "profile": await _profile()
		elif phase == "combat": await _combat_probe()
		else: await _integrated()
	_check(TestRunEvidence.write_json(phase+"-integration.json",{"task":"N017","phase":phase,"pid":OS.get_process_id(),"assertions":assertions,"failures":failures,"captures":captures,"traces":traces,"combat":combat_traces,"nodes":visited,"choices":chosen,"proof":"synthetic visual/performance or combat prerequisite fixture" if phase in ["survey","profile","combat"] else "ordinary WASD/E/pointer/Tab/Enter; no position/progress setup"}),"integration evidence write")
	paused=false
	game.queue_free(); await process_frame
	for failure: String in failures: push_error(failure)
	print("N017 render ",phase," ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _integrated() -> void:
	await _pause(); await _capture("fresh",true)
	var oracle_path: String=game.save_repository.path+".n017-oracle"
	for id: String in TOUR: _check(game.session.conversations.memory(id).seen_node_ids.is_empty(),"no autoload "+id)
	if phase=="read":
		var file: FileAccess=FileAccess.open(oracle_path,FileAccess.READ)
		_check(file!=null,"integrated writer oracle exists")
		if file==null: return
		var oracle: Dictionary=file.get_var(false); file.close()
		var loaded: Dictionary=await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
		_check(loaded.ok,loaded.get("error","GUI Load"))
		var disk: SaveRepository.ReadResult=game.save_repository.read(game.catalog)
		_check(disk.session!=null,"whole typed disk valid")
		if disk.session==null: return
		_check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"different process exact whole state and forecast")
		await _capture("load-confirmed",true); await _resume()
		var effects: PackedStringArray=game.session.completed_effect_ids.duplicate()
		var memories: Dictionary=game.session.conversations.snapshot().people
		for id: String in TOUR:
			if not await _walk(NpcRegistry.find(id).approach,"loaded-"+id): return
			var before_open: Dictionary=game.session.conversations.snapshot()
			if not await _open_person(id,"loaded-"+id): return
			_check(game.dialogue.snapshot().facts.size()==(1 if id=="npc-01" else 2 if id=="npc-02" else 3),"restored public facts "+id)
			_close()
			_check(game.session.conversations.snapshot()==before_open,"remembered reopen has no new event/reward "+id)
		_check(game.session.conversations.snapshot().people==memories,"all-eight remembered reopens preserve independent memories")
		_check(game.session.completed_effect_ids==effects and effects.size()==6,"revisit no duplicate recovery effects")
		_check(game.world_host.current_location.npc_contacts.targets.size()==8 and game.party.members().size()==2,"restart eight wrappers/two-member party")
		await _pause(); return
	await _resume()
	for id: String in TOUR:
		if not await _walk(NpcRegistry.find(id).approach,"introduce-"+id): return
		await _pause(); await _capture("body-"+id); await _resume()
		var before: Dictionary=SaveCodec.snapshot(game.session)
		var before_people: Dictionary=game.session.conversations.snapshot().people
		if not await _open_person(id,"intro-"+id): return
		var snap: Dictionary=game.dialogue.snapshot()
		_check(snap.choices.size()==2,"two exclusive introductions "+id)
		var choice: String=snap.choices[1 if phase=="neutral" else 0].id
		if not await _choose(choice,"accepted-"+id): return
		_close()
		var memory: ConversationMemory=game.session.conversations.memory(id)
		_check(memory.affinity==(0 if phase=="neutral" else 1) and memory.applied_choice_ids.size()==1,"one exclusive receipt "+id)
		for field: String in ["inventory","collected_resource_ids","world_item_placements","quests","completed_effect_ids","relationship","progression","actors","party_member_ids","light_source_overrides"]:
			_check(SaveCodec.snapshot(game.session)[field]==before[field],"introduction preserves "+field+" "+id)
		for other: String in TOUR:
			if other!=id: _check(game.session.conversations.memory(other).snapshot(3)==before_people[other],"person isolation "+id+"/"+other)
		if not await _public_branches(id): return
		if id=="npc-02" and not await _woods_entries(): return
	if not await _walk(Vector3(27.5,.25,-2),"gather-approach"): return
	_key(KEY_E,true); await create_timer(.8).timeout; _key(KEY_E,false)
	_check(game.session.inventory.count("item-moonflower")==1,"ordinary committed Moonflower")
	for id: String in ["npc-01","npc-02"]:
		if not await _walk(NpcRegistry.find(id).approach,"gather-revisit-"+id): return
		if not await _open_person(id,"gather-hint-"+id): return
		_check(game.dialogue.snapshot().node_id==id+"-moonflower-hint","source gather priority "+id)
		_close()
		if not await _public_branches(id): return
	for id: String in TOUR:
		_check(game.session.conversations.memory(id).learned_fact_ids.size()==(1 if id=="npc-01" else 2 if id=="npc-02" else 3),"all21 public facts "+id)
	if phase=="neutral": await _pause(); return
	if not await _recovery_route(): return
	await _pause()
	var saved: Dictionary=await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","GUI Save"))
	var file: FileAccess=FileAccess.open(oracle_path,FileAccess.WRITE)
	_check(file!=null,"whole state oracle write")
	if file!=null: file.store_var(TestRunSnapshot.oracle(game.session)); file.close()
	await _capture("save-confirmed",true)

func _open_person(id: String,label: String) -> bool:
	_key(KEY_E,true); _key(KEY_E,false); await process_frame
	if id=="npc-03" and game.dialogue.active(): await _click(game.ui.dialogue_view.counter_route.get_global_rect().get_center())
	_check(game.dialogue.active() and game.dialogue.snapshot().get("npc_id")==id,"ordinary selected person "+id)
	if not game.dialogue.active() or game.dialogue.snapshot().get("npc_id")!=id: return false
	if label.begins_with("intro-"):
		var foot: Vector3=game.player_placeholder.global_position
		_key(KEY_W,true); _key(KEY_W,false)
		for i: int in range(3):
			_key(KEY_TAB,true); _key(KEY_TAB,false); await process_frame
			_check(game.ui.dialogue_panel.is_ancestor_of(root.gui_get_focus_owner()),"ordinary contained Tab "+id)
		_check(game.player_placeholder.global_position==foot and game.player_placeholder.movement_buttons.is_empty(),"dialogue excludes held world movement "+id)
	await _record_node(label)
	return true

func _record_node(label: String) -> void:
	var snap: Dictionary=game.dialogue.snapshot()
	var id: String=snap.node_id
	if not visited.has(id): visited.append(id)
	if snap.get("npc_id","") in TOUR and snap.get("graph_id","") not in ["prototype-maris-counter","prototype-maris-fitting","prototype-maris-specialist"]:
		var npc: NpcDefinition=game.npc_catalog.get_npc(snap.npc_id)
		var node: NpcDialogueGraph.NodeDefinition=npc.graph.nodes[id]
		_check(snap.text==node.text and snap.portrait_path==npc.portraits[node.portrait_id],"exact authored text/expression "+id)
	await _dialogue_capture(label)

func _choose(id: String,label: String) -> bool:
	var button: Button=game.ui.dialogue_choices.get_node_or_null(NodePath(id))
	_check(button!=null and not button.disabled,"available ordinary choice "+id)
	if button==null or button.disabled: return false
	for step: int in range(20):
		if game.ui.dialogue_view.choice_scroll.get_global_rect().encloses(button.get_global_rect()): break
		await _wheel(game.ui.dialogue_view.choice_scroll,1)
	_check(game.ui.dialogue_view.choice_scroll.get_global_rect().encloses(button.get_global_rect()),"choice visible "+id)
	var prior: String=game.dialogue.snapshot().node_id
	await _click(button.get_global_rect().get_center())
	_check(not game.dialogue.active() or game.dialogue.snapshot().node_id!=prior,"actual GUI response "+id)
	if not chosen.has(id): chosen.append(id)
	if game.dialogue.active(): await _record_node(label)
	return failures.is_empty()

func _public_branches(id: String) -> bool:
	if not await _open_person(id,"return-"+id): return false
	var choices: Array=game.dialogue.snapshot().choices.duplicate(true)
	for row: Dictionary in choices:
		if row.available:
			if not await _choose(row.id,row.id): return false
			_close()
			if not await _open_person(id,"reopen-"+row.id): return false
		else:
			var before: Dictionary=game.session.conversations.snapshot()
			_check(not row.reason.is_empty(),"explicit deferred reason "+row.id)
			var button: Button=game.ui.dialogue_choices.get_node(NodePath(row.id))
			_check(button.disabled,"deferred input disabled "+row.id)
			for step: int in range(20):
				if game.ui.dialogue_view.choice_scroll.get_global_rect().encloses(button.get_global_rect()): break
				await _wheel(game.ui.dialogue_view.choice_scroll,1)
			await _click(button.get_global_rect().get_center())
			_check(game.session.conversations.snapshot()==before,"deferred command inert")
			await _dialogue_capture("disabled-"+row.id)
	if game.dialogue.snapshot().facts.size()>1:
		await _wheel(game.ui.dialogue_view.facts,20)
		for fact: Dictionary in game.dialogue.snapshot().facts:
			_check(game.ui.dialogue_view.facts.get_parsed_text().contains(fact.label),"known-fact text "+fact.id)
		await _dialogue_capture("scrolled-facts-"+id)
	_close(); return failures.is_empty()

func _recovery_route() -> bool:
	if not await _walk(NpcRegistry.find("npc-03").approach,"recovery-lead"): return false
	await _talk("prototype-maris-counter:intro-0","recovery-lead")
	if not await _choose("maris-lead-choice","lead-accepted"): return false
	_close()
	_key(KEY_J,true); _key(KEY_J,false); await process_frame
	await _click(game.ui.upgrade_button.get_global_rect().get_center())
	_check(game.player_placeholder.combat.damage==40,"ordinary journal strike preparation")
	_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	# Existing main bridge and ford are both traversed through ordinary movement.
	for goal: Vector3 in [Vector3(93,0,-.5),Vector3(103,0,-.5),Vector3(107.25,0,-1.25)]:
		if not await _walk(goal,"east-route-"+str(goal.x)): return false
	_key(KEY_E,true); _key(KEY_E,false)
	var arrived: Array=await game.world_host.transition_finished
	_check(arrived[0] and game.session.current_location_id=="prototype-tollworks","ordinary Tollworks gate")
	if not arrived[0]: return false
	await _pause(); await _capture("tollworks-arrival",true); await _resume()
	if not await _walk(Vector3(0,0,-.5),"guardian-combat-approach"): return false
	if not await _fight(): return false
	await _pause(); await _capture("guardian-cleared",true); await _resume()
	if not await _walk(Vector3(3.5,0,4.5),"recovery-vessel"): return false
	_key(KEY_E,true); _key(KEY_E,false); await process_frame
	_check(game.dialogue.active(),"ordinary vessel interaction")
	if not game.dialogue.active(): return false
	await _record_node("vessel");
	for i: int in range(4):
		if not game.ui.dialogue_next.visible: break
		await _click(game.ui.dialogue_next.get_global_rect().get_center())
	if not await _choose("maris-vessel-choice","vessel-open"): return false
	_close()
	if not await _walk(Vector3(0,0,-4.5),"return-gate"): return false
	_key(KEY_E,true); _key(KEY_E,false); arrived=await game.world_host.transition_finished
	_check(arrived[0] and game.session.current_location_id==NpcRegistry.LOCATION,"ordinary town return")
	for goal: Vector3 in [Vector3(75,0,12.5),Vector3(66,0,12.5),NpcRegistry.find("npc-03").approach]:
		if not await _walk(goal,"west-ford-"+str(goal.x)): return false
	await _talk("prototype-maris-fitting:intro-0","fitting")
	for i: int in range(2): await _click(game.ui.dialogue_next.get_global_rect().get_center())
	if not await _choose("maris-reconnect-choice","reconnected"): return false
	_close()
	_check(game.session.completed_effect_ids.size()==6 and game.world_host.current_location.get_node("MarisCounter").presentation=="specialist","complete shortened recovery exactly once")
	_check(game.world_host.current_location.npc_contacts.targets.size()==8 and game.party.members().size()==2,"travel reconstructed each villager once")
	return failures.is_empty()

func _dialogue_capture(label: String) -> void:
	var result: Dictionary=await TestRunInteractionCapture.dialogue(game,phase+"-%03d-" % captures.size()+label,TestRunEvidence.directory(),"debug-input","N017 integrated ordinary WASD/E/GUI at selected production contact; no branch/position setup")
	_check(result.ok,result.get("error","dialogue capture"))
	if result.ok: captures.append(result)

func _check(ok: bool,message: String) -> void:
	assertions+=1
	if not ok: failures.append(message); print("N017_ASSERTION_FAILED ",message)

func _walk(goal: Vector3,label: String) -> bool:
	var result: Dictionary=await TestRunJourney.walk(game,goal,label)
	traces.append(result); _check(result.ok,result.error)
	print("N017_WALK ",label," ",result.ok," ",result.get("actual",result.error))
	return result.ok

func _click(point: Vector2) -> void:
	var motion: InputEventMouseMotion=InputEventMouseMotion.new()
	motion.position=point; motion.global_position=point; root.push_input(motion,true)
	for down: bool in [true,false]:
		var event: InputEventMouseButton=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT; event.position=point; event.global_position=point; event.pressed=down
		root.push_input(event,true); await process_frame

func _capture(label: String,overlay: bool=false) -> void:
	var synthetic: bool=phase in ["survey","profile","combat"]
	var result: Dictionary=await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"synthetic" if synthetic else "debug-input",overlay,"N017 labeled synthetic "+phase+" fixture; setup separate from ordinary route" if synthetic else "N017 ordinary production WASD/E/GUI; no physical placement or progress setup")
	_check(result.ok,result.get("error","pause capture"))
	if result.ok: captures.append(result)

func _fight() -> bool:
	var memories: Dictionary=game.session.conversations.snapshot()
	for attempt: int in range(3):
		for swing: int in range(30):
			if game.player_placeholder.state.health<=0 or game.guardian.state.health<=0: break
			var offset: Vector3=game.guardian.global_position-game.player_placeholder.global_position
			offset.y=0
			if offset.length()>1.9:
				if not await _walk(game.guardian.global_position-offset.normalized()*1.4,"combat-range-"+str(attempt)+"-"+str(swing)): return false
			# Aim at actual floor feet, not a projected point above a moving enemy.
			var screen: Vector2=game.camera_rig.camera.unproject_position(game.guardian.global_position)
			await _click(screen)
			var row: Dictionary={"attempt":attempt,"swing":swing,"hero_health":game.player_placeholder.state.health,"guardian_health":game.guardian.state.health,"attacking":game.player_placeholder.combat.attacking,"controls":game.player_placeholder.controls_enabled,"focus":str(root.gui_get_focus_owner()),"screen":str(screen),"range":game.guardian.global_position.distance_to(game.player_placeholder.global_position),"aim":str(game.player_placeholder.combat.direction)}
			combat_traces.append(row); print("N017_SWING ",row)
			await create_timer(.65).timeout
			await _pause(); await _capture("combat-"+str(attempt)+"-"+str(swing));
			if game.player_placeholder.state.health>0: await _resume()
		if game.guardian.state.health<=0 and game.player_placeholder.state.health>0: return true
		if game.player_placeholder.state.health>0: break
		# Actual death is retained. R uses the existing public retry control.
		_key(KEY_R,true); _key(KEY_R,false)
		var arrival: Array=await game.world_host.transition_finished
		_check(arrival[0] and game.player_placeholder.state.health==100,"ordinary R retry")
		_check(game.session.conversations.snapshot()==memories,"ordinary retry keeps all NPC memories/events")
		if not arrival[0]: return false
	_check(false,"real combat guardian defeated within bounded attempts")
	return false

func _combat_probe() -> void:
	# Explicit synthetic legal prerequisite; this never substitutes for the
	# integrated writer's ordinary town/quest/travel journey.
	var step: QuestStep=game.catalog.get_quest("prototype-maris-recovery").steps[0]
	_check(game.quests.apply("prototype-maris-recovery",step.action_id,step.location_id,step.source_id).ok,"synthetic legal lead only")
	_check(game.progression.select_upgrade(ProgressionService.UPGRADE_ID).ok,"synthetic preparation only")
	game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
	_check((await game.world_host.transition_finished)[0],"probe arrival")
	if await _walk(Vector3(0,0,-.5),"probe-approach"): await _fight()
	await _pause(); await _capture("probe-final",true)

func _survey() -> void:
	await _pause()
	_hide_review_labels(game.world_host.current_location)
	game.player_placeholder.visible=false; game.companion.visible=false
	for id: String in TOUR:
		game.camera_rig.global_position=NpcRegistry.find(id).approach
		for weather: String in ["day","night","rain"]:
			game.session.environment.day_index=1
			game.session.environment.day_cycle_progress=.5 if weather=="night" else .0833333333333333
			for seed: int in range(1000):
				game.session.environment.weather_seed=seed
				if game.session.environment.weather_sample().has_rain()==(weather=="rain"): break
			game._present_environment()
			var result: Dictionary=await TestRunCapture.capture(game,"survey-"+id+"-"+weather,TestRunEvidence.directory(),"synthetic",false,"N017 production eight-contact environment; seeded clock/weather, survey camera, annotations/party hidden; ordinary route proven separately")
			_check(result.ok,result.get("error","survey capture"))
			if result.ok: captures.append(result)

func _woods_entries() -> bool:
	# The first and repeat Edric woods entries must precede gather priority.
	for trip: int in range(2):
		if not await _walk(Vector3(27.5,.25,-2),"woods-"+str(trip)): return false
		if not await _walk(NpcRegistry.find("npc-01").approach,"woods-return-"+str(trip)): return false
		if not await _open_person("npc-01","woods-entry-"+str(trip)): return false
		_check(game.dialogue.snapshot().node_id==("npc-01-woods-first" if trip==0 else "npc-01-woods-repeat"),"actual woods edge priority")
		_close()
	return failures.is_empty()

func _profile() -> void:
	# ABBA paired measurement in the same production map/session/process. Only
	# this synthetic profile changes contact activation and player/camera feet.
	# Baseline is the current map without new contact crowd, not an old executable.
	var rows: Array[Dictionary]=[]
	var views: Array[Vector3]=[Vector3.ZERO,Vector3(42.5,0,17),Vector3(93,0,-.5)]
	for enabled: bool in [false,true,true,false]:
		game.world_host.enabled_npcs=NpcRegistry.ENABLED if enabled else PackedStringArray()
		_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(),"profile transition")
		_check((await game.world_host.transition_finished)[0],"profile arrival")
		for index: int in views.size():
			game.player_placeholder.global_position=views[index]
			game.player_placeholder.reset_physics_interpolation()
			await create_timer(1).timeout
			var intervals: PackedFloat64Array=[]
			var draws: PackedInt32Array=[]
			var begin: int=Time.get_ticks_usec(); var last: int=begin
			while Time.get_ticks_usec()-begin<3000000:
				await process_frame
				var now: int=Time.get_ticks_usec()
				intervals.append((now-last)/1000.0); last=now
				draws.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
			intervals.sort(); draws.sort()
			var row: Dictionary={"crowd":enabled,"view":index,"samples":intervals.size(),"p50_ms":intervals[ceili(intervals.size()*.5)-1],"p95_ms":intervals[ceili(intervals.size()*.95)-1],"p99_ms":intervals[ceili(intervals.size()*.99)-1],"draw_p95":draws[ceili(draws.size()*.95)-1],"focused":game.window_focused}
			rows.append(row)
			_check(game.window_focused and not paused,"profile unpaused/focused")
			print("N017_PROFILE ",row)
	for index: int in views.size():
		var base: float=maxf(rows[index].p95_ms,rows[9+index].p95_ms)
		var crowd: float=maxf(rows[3+index].p95_ms,rows[6+index].p95_ms)
		_check(crowd<=maxf(16.67,base+4),"paired crowd frame p95 budget "+str(index))
		_check(maxf(rows[3+index].p99_ms,rows[6+index].p99_ms)<=25,"current map frame p99 budget "+str(index))
		_check(maxi(rows[3+index].draw_p95,rows[6+index].draw_p95)<=500,"current map draw budget "+str(index))
	_check(TestRunEvidence.write_json("npc-crowd-profile.json",{"task":"N017","proof":"synthetic ABBA current production map without/with contacts; full root idle, not combat/native benchmark","warmup_seconds":1,"sample_seconds":3,"resolution":[960,640],"rows":rows,"failures":failures}),"profile evidence")
	await _pause(); await _capture("profile-final",true)
