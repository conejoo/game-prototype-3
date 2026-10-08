extends SceneTree
## Ordinary N014 writer/reader/neutral journeys; separate labeled art/weather review.
var game: Node3D
var failures: PackedStringArray = []
var captures: Array[Dictionary] = []
var traces: Array[Dictionary] = []
var assertions: int = 0
var phase: String = "review"

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase=arg.trim_prefix("--phase=")
	root.size=Vector2i(960,640)
	if phase == "review": await _review()
	else:
		game=load("res://app/game_root.tscn").instantiate()
		root.add_child(game)
		var startup: Array=await game.world_host.transition_finished
		_check(startup[0],"fresh production arrival")
		if startup[0]: await _ordinary()
	_check(TestRunEvidence.write_json(phase+"-npc-08.json",{"task":"N014","phase":phase,"pid":OS.get_process_id(),"assertions":assertions,"failures":failures,"captures":captures,"traces":traces,"proof":"ordinary WASD/E/pointer/Tab/Enter and exact separate-process GUI restart" if phase != "review" else "synthetic exported art/weather review"}),"evidence write")
	paused=false
	if is_instance_valid(game): game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("N014 render ",phase," ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions," captures=",captures.size())
	quit(0 if failures.is_empty() else 1)

func _ordinary() -> void:
	await _pause()
	await _capture("fresh",true)
	var oracle_path: String=game.save_repository.path+".n014-oracle"
	_check(game.session.conversations.memory("npc-08").flags.is_empty(),"fresh no implicit memory/autoload")
	if phase == "read":
		var file: FileAccess=FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"writer oracle exists")
		if file == null: return
		var oracle: Dictionary=file.get_var(false); file.close()
		var loaded: Dictionary=await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
		_check(loaded.ok,loaded.get("error","GUI Load"))
		var disk: SaveRepository.ReadResult=game.save_repository.read(game.catalog)
		_check(disk.session != null,"typed disk valid")
		if disk.session == null: return
		var comparison: PackedStringArray=TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
		_check(comparison.is_empty(),"exact every old/new durable fact: "+str(comparison))
		await _capture("load-confirmed",true)
		await _resume()
		if not await _walk(NpcRegistry.find("npc-08").approach,"restored-contact"): return
		await _talk("npc-08-return","remembered-fact")
		_check(game.dialogue.snapshot().facts.size()==3,"all three restored facts visible once")
		await _scroll_facts("restored-public-facts")
		_close(); await _pause(); return
	await _resume()
	if not await _walk(NpcRegistry.find("npc-08").approach,"repair-introduction"): return
	var before_dialogue: Dictionary=SaveCodec.snapshot(game.session)
	await _pause(); await _capture("ordinary-repair-body"); await _resume()
	await _talk("npc-08-introduction","introduction")
	_check(game.ui.dialogue_view.status.text.contains("Repair services and fair boat rides unavailable"),"repair/ride boundary readable on ordinary modal")
	_check(game.dialogue.snapshot().facts.size()==1 and game.dialogue.snapshot().facts[0].id=="npc-08-public-role","source public role only")
	var old: Dictionary=game.dialogue.snapshot()
	var index: int=1 if phase == "neutral" else 0
	await _click(game.ui.dialogue_choices.get_child(index).get_global_rect().get_center())
	_check(game.dialogue.snapshot().get("node_id") == ("npc-08-passing-end" if phase == "neutral" else "npc-08-careful-end"),"exclusive actual introduction")
	await _dialogue_capture("accepted-introduction")
	var accepted: Dictionary=game.session.conversations.snapshot()
	_check(not game._choose_dialogue(old.choices[1-index].id,old).ok and game.session.conversations.snapshot()==accepted,"stale alternate cannot grant both")
	_close()
	var memory: ConversationMemory=game.session.conversations.memory("npc-08")
	_check(memory.affinity==(0 if phase == "neutral" else 1) and memory.applied_choice_ids.size()==1,"exact one introduction reward")
	for branch: Dictionary in [{"index":0,"node":"npc-08-supplies","facts":2},{"index":1,"node":"npc-08-demo","facts":2},{"index":2,"node":"npc-08-busy","facts":2},{"index":3,"node":"npc-08-hobby","facts":3}]:
		await _talk("npc-08-return","return-before-"+branch.node)
		await _click(game.ui.dialogue_choices.get_child(branch.index).get_global_rect().get_center())
		_check(game.dialogue.snapshot().get("node_id")==branch.node and game.dialogue.snapshot().facts.size()==branch.facts,"ordinary branch/facts "+branch.node)
		await _dialogue_capture(branch.node)
		_close()
	await _talk("npc-08-return","known-fact-revisit")
	await _scroll_facts("all-public-facts")
	await _wheel(game.ui.dialogue_view.choice_scroll,8)
	var snapshot: Dictionary=game.session.conversations.snapshot()
	var gift: Button=game.ui.dialogue_choices.get_child(4)
	_check(game.ui.dialogue_view.choice_scroll.get_global_rect().encloses(gift.get_global_rect()),"disabled gift fully visible after ordinary wheel input")
	await _click(gift.get_global_rect().get_center())
	_check(gift.disabled and not game.dialogue.snapshot().choices[4].available and not game.dialogue.snapshot().choices[4].reason.is_empty() and game.session.conversations.snapshot()==snapshot,"gift honestly unavailable and inert")
	await _dialogue_capture("visible-disabled-gift")
	memory=game.session.conversations.memory("npc-08")
	_check(memory.level(3)==0 and memory.learned_fact_ids.size()==3,"public facts accessible at zero level")
	_check(game.session.completed_effect_ids.is_empty() and game.session.relationship.trust==0 and game.session.inventory.count("item-moonflower")==0,"dialogue no quest/trust/supply reward")
	var after_dialogue: Dictionary=SaveCodec.snapshot(game.session)
	for field: String in ["inventory","collected_resource_ids","world_item_placements","quests","completed_effect_ids","relationship","progression","actors","party_member_ids","light_source_overrides"]:
		_check(after_dialogue[field]==before_dialogue[field],"ordinary dialogue preserves complete "+field)
	for id: String in NpcContentCatalog.ROSTER:
		if id != "npc-08":
			var other: ConversationMemory=game.session.conversations.memory(id)
			_check(other.affinity==0 and other.flags.is_empty() and other.learned_fact_ids.is_empty() and other.seen_node_ids.is_empty(),"cross-person isolation "+id)
	_close()
	if phase == "neutral": await _pause(); return
	# Ordinary repair lane round trip; source geography unchanged.
	if not await _walk(Vector3(-3.5,0,14.5),"repair-lane-clear"): return
	await _pause(); await _capture("repair-lane-clear"); await _resume()
	if not await _walk(NpcRegistry.find("npc-08").approach,"repair-lane-return"): return
	await _talk("npc-08-return","repair-revisit"); _close()
	await _pause()
	var saved: Dictionary=await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","GUI Save"))
	var file: FileAccess=FileAccess.open(oracle_path,FileAccess.WRITE)
	_check(file != null,"oracle created")
	if file != null: file.store_var(TestRunSnapshot.oracle(game.session)); file.close()
	await _capture("save-confirmed",true)

func _talk(node: String,label: String) -> void:
	_key(KEY_E,true); _key(KEY_E,false)
	await process_frame
	_check(game.dialogue.active() and game.dialogue.snapshot().get("node_id")==node,"ordinary E selects "+node)
	if game.dialogue.active(): await _dialogue_capture(label)

func _close() -> void: _key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)

func _scroll_facts(label: String) -> void:
	var facts: RichTextLabel=game.ui.dialogue_view.facts
	var before: Dictionary=game.session.conversations.snapshot()
	await _wheel(facts,6)
	await _dialogue_capture(label+"-middle")
	await _wheel(facts,20)
	var bar: VScrollBar=facts.get_v_scroll_bar()
	_check(bar.value>0 and absf(bar.value-(bar.max_value-bar.page))<1,"ordinary wheel reaches last public fact")
	_check(facts.get_parsed_text().contains("Woodcarving") and game.session.conversations.snapshot()==before,"fact browsing readable/inert")
	await _dialogue_capture(label)

func _wheel(control: Control,count: int) -> void:
	var point: Vector2=control.get_global_rect().get_center()
	var motion: InputEventMouseMotion=InputEventMouseMotion.new()
	motion.position=point; root.push_input(motion,true)
	for i: int in range(count):
		for down: bool in [true,false]:
			var event: InputEventMouseButton=InputEventMouseButton.new()
			event.button_index=MOUSE_BUTTON_WHEEL_DOWN; event.position=point; event.pressed=down
			root.push_input(event,true)
		await process_frame

func _walk(goal: Vector3,label: String) -> bool:
	var result: Dictionary=await TestRunJourney.walk(game,goal,label)
	traces.append(result)
	_check(result.ok,result.error)
	print("N014_WALK ",label," ",result.ok," ",result.get("actual",result.error))
	return result.ok

func _pause() -> void:
	if not paused: _close()
	for frame: int in range(3): await process_frame
	_check(paused and game.ui.pause_overlay.visible,"verified pause checkpoint")

func _resume() -> void:
	var result: Dictionary=await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	_check(result.ok,result.get("error","GUI Resume"))
	for frame: int in range(3): await process_frame

func _dialogue_capture(label: String) -> void:
	var result: Dictionary=await TestRunInteractionCapture.dialogue(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input","Ordinary viewport walk/E/GUI at production repair contact, authored source graph")
	_check(result.ok,result.get("error","dialogue capture"))
	if result.ok: captures.append(result)

func _capture(label: String,overlay: bool=false) -> void:
	var result: Dictionary=await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input",overlay,"Ordinary production WASD/E/GUI; no physical placement or branch seeding")
	_check(result.ok,result.get("error","pause capture"))
	if result.ok: captures.append(result)

func _key(code: int,down: bool) -> void:
	var event: InputEventKey=InputEventKey.new()
	event.keycode=code; event.physical_keycode=code; event.pressed=down
	root.push_input(event,true)

func _click(point: Vector2) -> void:
	var motion: InputEventMouseMotion=InputEventMouseMotion.new()
	motion.position=point
	root.push_input(motion,true)
	for down: bool in [true,false]:
		var event: InputEventMouseButton=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT; event.position=point; event.pressed=down
		root.push_input(event,true)
		await process_frame

func _check(ok: bool,message: String) -> void:
	assertions+=1
	if not ok: failures.append(message); print("N014_ASSERTION_FAILED ",message)

func _review() -> void:
	# Labeled independent studio; source clips reviewed without gameplay claims.
	var stage: Node3D=Node3D.new()
	root.add_child(stage)
	var world: WorldEnvironment=WorldEnvironment.new()
	world.environment=Environment.new()
	world.environment.background_mode=Environment.BG_COLOR
	world.environment.background_color=Color(.12,.15,.20)
	world.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color=Color(.8,.85,1)
	world.environment.ambient_light_energy=.7
	stage.add_child(world)
	var sun: DirectionalLight3D=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-40,-35,0)
	sun.light_energy=1.0
	stage.add_child(sun)
	var p: NpcVisualPresenter=NpcVisualPresenter.new()
	stage.add_child(p)
	_check(p.mount(load("res://assets/models/npcs/npc-08.glb")).is_empty(),"review named asset mount")
	if p.player == null: stage.queue_free(); return
	p.player.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var camera: Camera3D=Camera3D.new()
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.current=true
	stage.add_child(camera)
	var title: Label=Label.new()
	title.position=Vector2(16,16)
	root.add_child(title)
	for view: String in ["front","profile","back","face"]:
		camera.size=.5 if view == "face" else 2.5
		var focus: Vector3=Vector3(0,1.44,0) if view == "face" else Vector3(0,.8,0)
		camera.position=focus+(Vector3(3,.2,0) if view == "profile" else Vector3(0,.15,3) if view == "back" else Vector3(0,.15,-3))
		camera.look_at(focus)
		NpcAssetProbe.sample(p,"idle",0)
		title.text="N014 / CELIA / exported 3D identity / "+view+"\nSynthetic studio review. Walk review-only; idle ordinary repair contact."
		await _raw_capture("review-"+view,"identity "+view)
	camera.size=2.5; camera.position=Vector3(1.8,1.4,-3); camera.look_at(Vector3(0,.8,0))
	for light: String in ["day","night"]:
		sun.light_energy=1.0 if light == "day" else .3
		world.environment.ambient_light_energy=.7 if light == "day" else .4
		for clip: String in ["idle","walk"]:
			for t: float in [0.0,.25,.5,.75]:
				NpcAssetProbe.sample(p,clip,t*(4 if clip=="idle" else .8))
				title.text="N014 / CELIA / "+light+" / "+clip+" / phase "+str(t)+"\nExported clip synthetic review; walk review-only."
				await _raw_capture("review-"+light+"-"+clip+"-"+str(roundi(t*100)),"exported clip sample")
	NpcAssetProbe.sample(p,"idle",0)
	p.set_locomotion(.8)
	for i: int in range(16):
		p.player.advance(1.0/120)
		if i in [0,3,7,11,15]:
			title.text="N014 / actual idle-walk blend / step "+str(i)
			await _raw_capture("review-blend-"+str(i),"actual .12s transition")
	title.queue_free(); stage.queue_free()
	await process_frame
	# Actual production exterior lighting/canopy/weather, with seeded clock fixture.
	game=load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"weather review world arrival")
	await _pause()
	# Survey from side avoids player/companion obscuring repair contact. Label3D
	# annotations are hidden only in this labeled review fixture, never production.
	_hide_review_labels(game.world_host.current_location)
	game.player_placeholder.visible=false
	game.companion.visible=false
	game.camera_rig.global_position=NpcRegistry.find("npc-08").approach
	var default_camera_transform: Transform3D=game.camera_rig.camera.global_transform
	for light: String in ["day","night","rain"]:
		game.session.environment.day_index=1
		game.session.environment.day_cycle_progress=.0833333333333333 if light != "night" else .5
		for seed: int in range(1000):
			game.session.environment.weather_seed=seed
			if game.session.environment.weather_sample().has_rain() == (light=="rain"): break
		_check(game.session.environment.weather_sample().has_rain()==(light=="rain"),"weather fixture truly "+light)
		game._present_environment()
		var camera_live: Camera3D=game.camera_rig.camera
		camera_live.size=PrototypeCameraRig.DEFAULT_SIZE
		camera_live.global_transform=default_camera_transform
		var overhead: Dictionary=await TestRunCapture.capture(game,"review-overhead-"+light,TestRunEvidence.directory(),"synthetic",false,"Actual default gameplay camera distance and production repair asset/weather; seeded clock, annotations/party hidden for survey only")
		_check(overhead.ok,overhead.get("error","actual-scale weather survey"))
		if overhead.ok: captures.append(overhead)
		camera_live.size=3.0
		camera_live.global_position=Vector3(-1.5,2.5,14)
		camera_live.look_at(Vector3(-3.5,.8,12))
		var result: Dictionary=await TestRunCapture.capture(game,"review-world-"+light,TestRunEvidence.directory(),"synthetic",false,"Actual production Celia/repair foot/weather; seeded clock/camera, party visuals and Label3D annotations hidden for survey only; no ordinary route claim")
		_check(result.ok,result.get("error","world weather capture"))
		if result.ok: captures.append(result)

func _hide_review_labels(node: Node) -> void:
	if node is Label3D: node.visible=false
	for child: Node in node.get_children(): _hide_review_labels(child)

func _raw_capture(label: String,note: String) -> void:
	for frame: int in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var path: String=TestRunEvidence.path(label+".png")
	var error: Error=root.get_texture().get_image().save_png(path)
	_check(error==OK,"raw review capture "+label)
	captures.append({"path":path,"label":label,"note":note,"kind":"synthetic studio","pid":OS.get_process_id(),"dimensions":[960,640]})
