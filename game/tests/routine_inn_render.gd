extends "res://tests/npc_integration_render.gd"
## R008 fresh ordinary public controls; navigation guidance only, no state/position setup.
func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase=arg.trim_prefix("--phase=")
	root.size=Vector2i(960,640)
	game=load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array=await game.world_host.transition_finished
	_check(startup[0],"fresh production startup")
	if startup[0]:
		if phase=="read": await _read_inn()
		else: await _write_inn()
	_check(TestRunEvidence.write_json(phase+"-inn-index.json",{"task":"R008","phase":phase,"assertions":assertions+1,"failures":failures,"views":captures,"traces":traces,"nodes":visited,"choices":chosen,"snapshot":SaveCodec.snapshot(game.session),"provenance":"fresh ordinary WASD/E/Esc/P/+/-/mouse/Tab/Enter input, runtime navigation guidance; no placement, affinity/items/weather/time setup"}),"evidence write")
	paused=false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("R008 inn rendered ",phase," assertions=",assertions," captures=",captures.size()," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _enter_inn(label: String) -> bool:
	if not await _walk(RoutineExteriorRegistry.entrance(NpcRegistry.LOCATION,"lantern-rest-entrance-01").player_approach,label): return false
	_key(KEY_E,true); _key(KEY_E,false)
	return await _arrival_inn("prototype-lantern-rest")

func _exit_inn(label: String) -> bool:
	if not await _walk(Vector3(0,0,.65),label): return false
	_key(KEY_E,true); _key(KEY_E,false)
	if not await _arrival_inn(NpcRegistry.LOCATION): return false
	_check(game.session.current_spawn_id=="alderwake-from-lantern-rest" and not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"measured exterior return/no invisible town Della")
	return true

func _arrival_inn(id: String) -> bool:
	for frame: int in range(600):
		await physics_frame
		if game.session.current_location_id==id and not game.world_host.transitioning:
			for settle: int in range(4): await physics_frame
			_check(game.party.members().size()==2 and game.player_placeholder.is_on_floor() and game.companion.is_on_floor(),"persistent full party grounded at "+id)
			return true
	_check(false,"public door did not arrive "+id+" current="+game.session.current_location_id)
	return false

func _write_inn() -> void:
	_check(game.session.conversations.memory("npc-14").affinity==0,"fresh zero affinity host access")
	_check(not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"Della absent from town interaction/collision/presenter owner")
	if not await _enter_inn("zero-affinity-public-inn-door"): return
	_check(game.world_host.current_location.npc_contacts.targets.keys()==["npc-14"],"one actual indoor host")
	await _pause(); await _capture("zero-affinity-inn-arrival",true); await _resume()
	if not await _walk(NpcRegistry.find("npc-14").approach,"ordinary-host-approach"): return
	if not await _open_person("npc-14","intro-della-indoor"): return
	_check(game.session.conversations.memory("npc-14").affinity==0 and not game.dialogue.snapshot().text.contains("interior is not open"),"ordinary talk at zero affinity/current indoor wording")
	if not await _choose("npc-14-careful-response","indoor-introduction-response"): return
	_close(); await process_frame
	_check(not game.dialogue.active() and game.player_placeholder.controls_enabled,"public Esc closes dialogue/resumes world controls")
	for stop: Dictionary in [{"id":"host","foot":NpcRegistry.find("npc-14").approach},{"id":"breakfast","foot":Vector3(6,0,-4)}]:
		if not await _walk(stop.foot,"ordinary-inn-"+stop.id): return
		for orthographic: bool in [true,false]:
			if (game.camera_rig.camera.projection==Camera3D.PROJECTION_ORTHOGONAL)!=orthographic: _key(KEY_P,true); _key(KEY_P,false); await process_frame
			for zoom: float in [.8,1.0,1.15]:
				for step: int in range(8):
					if absf(game.camera_rig.zoom_factor-zoom)<.01: break
					var zoom_key: Key = KEY_EQUAL if game.camera_rig.zoom_factor>zoom else KEY_MINUS
					_key(zoom_key,true); _key(zoom_key,false); await process_frame
				_check(absf(game.camera_rig.zoom_factor-zoom)<.01,"public projection/zoom accepted")
				await _pause(); await _capture("inn-%s-%s-%02d" % [stop.id,"ortho" if orthographic else "perspective",roundi(zoom*100)]); await _resume()
	if not await _exit_inn("ordinary-inn-first-return"): return
	await _pause(); await _capture("town-inn-return",true); await _resume()
	if not await _walk(Vector3(27.5,.25,-2),"ordinary-flower-for-della"): return
	game._refresh_interaction()
	_check(game.selected_interaction!=null and game.selected_interaction.instance_id=="moonflower-01","actual finite flower selected")
	if game.selected_interaction==null or game.selected_interaction.instance_id!="moonflower-01": return
	_key(KEY_E,true); await create_timer(.8).timeout; _key(KEY_E,false)
	_check(game.session.foraging.is_collected("moonflower-01") and game.session.inventory.count("item-moonflower")==1,"ordinary gathering owns one conserved flower")
	if not await _enter_inn("ordinary-flower-carry-to-inn"): return
	if not await _walk(NpcRegistry.find("npc-14").approach,"ordinary-indoor-gift-approach"): return
	if not await _open_person("npc-14","indoor-preference-entry"): return
	if not await _choose("npc-14-ask-hobby","indoor-preference-disclosure"): return
	_close(); await process_frame
	if not await _open_person("npc-14","indoor-gift-entry"): return
	var before: Dictionary=game.dialogue.snapshot()
	if not await _choose("npc-14-gift-moonflower","ordinary-indoor-gift-accepted"): return
	_check(game.session.inventory.count("item-moonflower")==0 and game.session.conversations.memory("npc-14").affinity==2 and game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-14")==1,"exact single gift consumption/social receipt")
	var memories: Dictionary=game.session.conversations.snapshot()
	_check(not game._choose_dialogue("npc-14-gift-moonflower",before).ok and game.session.conversations.snapshot()==memories,"stale gift inert")
	_close(); await process_frame
	await _pause()
	var saved: Dictionary=await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","GUI Save"))
	if not saved.ok: return
	var file: FileAccess=FileAccess.open(game.save_repository.path+".r008-oracle",FileAccess.WRITE)
	file.store_var(TestRunSnapshot.oracle(game.session)); file.close()
	await _capture("indoor-gift-gui-save",true)

func _read_inn() -> void:
	await _pause()
	_check(game.session.conversations.memory("npc-14").affinity==0,"fresh process starts without prior social facts")
	var file: FileAccess=FileAccess.open(game.save_repository.path+".r008-oracle",FileAccess.READ)
	_check(file!=null,"writer oracle exists in isolated shared render group")
	if file==null: return
	var oracle: Dictionary=file.get_var(false); file.close()
	var loaded: Dictionary=await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
	_check(loaded.ok,loaded.get("error","GUI Load"))
	if not loaded.ok: return
	var disk: SaveRepository.ReadResult=game.save_repository.read(game.catalog)
	_check(disk.errors.is_empty() and disk.session!=null,"typed current-schema disk read")
	if disk.session!=null: _check(TestRunSnapshot.compare_restored(game.session,oracle,disk.session).is_empty(),"exact whole-save/new PID/global forecast oracle")
	_check(game.session.current_location_id=="prototype-lantern-rest" and game.world_host.current_location.npc_contacts.targets.keys()==["npc-14"],"GUI restore rebinds one real host indoors")
	await _capture("fresh-process-indoor-gui-load",true)
	await _resume()
	var memory: Dictionary=game.session.conversations.snapshot().people
	if not await _walk(NpcRegistry.find("npc-14").approach,"restored-indoor-host-revisit"): return
	if not await _open_person("npc-14","remembered-indoor-host"): return
	_check(game.dialogue.snapshot().node_id=="npc-14-return" and game.session.conversations.memory("npc-14").affinity==2,"remembered host/gift retained")
	_close(); await process_frame
	if not await _exit_inn("restored-inn-physical-return"): return
	_check(game.session.conversations.snapshot().people==memory and game.session.inventory.count("item-moonflower")==0,"physical return preserves exact people/gift/item conservation")
	await _pause(); await _capture("restored-town-return",true)

func _capture(label: String,overlay: bool=false) -> void:
	var result: Dictionary=await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input",overlay,"R008 ordinary public WASD/E/P/+/-/GUI with runtime-nav route guidance; no placement/state/weather/time setup")
	_check(result.ok,result.get("error","pause capture"))
	if result.ok: captures.append(result)

func _dialogue_capture(label: String) -> void:
	var result: Dictionary=await TestRunInteractionCapture.dialogue(game,phase+"-%03d-" % captures.size()+label,TestRunEvidence.directory(),"debug-input","R008 ordinary selected indoor host through WASD/E/GUI; time continues during dialogue")
	_check(result.ok,result.get("error","dialogue capture"))
	if result.ok: captures.append(result)
