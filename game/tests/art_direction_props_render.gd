extends "res://tests/art_direction_baseline_render.gd"
## AD011 synthetic art matrix and separate fresh ordinary viewport interaction phase.
var traces: Array[Dictionary] = []
var inventory: Dictionary = {}

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD011 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup failed")
	game._set_paused(true)
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var ordinary: bool = "--phase=journey" in OS.get_cmdline_user_args()
	if "--phase=controls" in OS.get_cmdline_user_args(): await _controls()
	elif ordinary: await _ordinary()
	else: await _review()
	var output: Dictionary = {"task":"AD011", "views":views, "samples":samples, "traces":traces, "inventory":inventory, "failures":failures, "engine_pid":OS.get_process_id(), "user_data":OS.get_user_data_dir(), "engine":Engine.get_version_info(), "renderer":RenderingServer.get_current_rendering_method(), "scope":"fresh ordinary WASD/E/F/pointer, no pose/fact/time/RNG setup" if ordinary else "synthetic frozen feet/time/weather/counter states/direct room transition/close cameras; not ordinary play or AD019"}
	var index_name: String = "props-controls-index.json" if "--phase=controls" in OS.get_cmdline_user_args() else "props-journey-index.json" if ordinary else "props-index.json"
	if not TestRunEvidence.write_json(index_name,output): failures.append("index failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD011 props: %d captures, %d failures" % [views.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _controls() -> void:
	# Diagnostic material controls reproduce exact pre-AD011 graybox color,
	# roughness and culling, without touching any vertices or wrapper transforms.
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game,"ad011-props"))
	game._pending_restore = game.session
	if not game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session).is_empty():
		failures.append("control rebind refused")
		return
	if not (await game.world_host.transition_finished)[0] or not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("control preset/rebind failed")
	game.set_process(false)
	var location: AlderwakeExterior = game.world_host.current_location
	for definition: String in ["berth-broken-piling","manual-sluice-gate"]:
		var subject: Node3D
		for wrapper: Node3D in location.town.get_children():
			if wrapper.get_meta("definition_id","") == definition:
				subject = wrapper.get_node("VisualRoot")
				break
		if subject == null:
			failures.append("control subject missing")
			continue
		await _close(subject,"control-painted-"+definition,1.5,true)
		var restore: Dictionary[MeshInstance3D, Material] = {}
		for visual: MeshInstance3D in subject.find_children("*","MeshInstance3D",true,false):
			var painted: ShaderMaterial = visual.material_override
			restore[visual] = painted
			var original: StandardMaterial3D = StandardMaterial3D.new()
			original.albedo_color = painted.get_shader_parameter("base_color")
			original.roughness = 1.0
			original.cull_mode = BaseMaterial3D.CULL_DISABLED
			visual.material_override = original
		await _close(subject,"control-original-color-"+definition,1.5,true)
		for visual: MeshInstance3D in restore: visual.material_override = restore[visual]
	game.set_process(true)

func _review() -> void:
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game,"ad011-props"))
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty():
		failures.append("rebind refused")
		return
	if not (await game.world_host.transition_finished)[0]: failures.append("rebind failed")
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	inventory = {"pickups":location.foraging_pickups.targets.size(), "consumers":location.exterior_lights.consumers.size(), "emitters":location.exterior_lights.emitter_count, "small_props":[]}
	for population: Node in [location.town,location.forest]:
		for wrapper: Node3D in population.get_children():
			if wrapper.get_meta("definition_id","") in StorybookPropMaterial.SMALL_DEFINITIONS:
				inventory.small_props.append({"id":str(wrapper.name),"definition":wrapper.get_meta("definition_id"),"transform":str(wrapper.transform)})
	var approaches: Dictionary = {"rod":[-6.5,0,15], "flower":[27.5,.25,-2], "maris":[-5.9959779,0,10.5802193], "lamp":[0.5,0,14.25]}
	for phase: int in [0,2]:
		if not review.apply_preset(phase,WeatherSchedule.Condition.SUNNY if phase == 0 else WeatherSchedule.Condition.THUNDERSTORM): failures.append("preset refused")
		for id: String in approaches:
			var foot: Array = approaches[id]
			_place(foot,[foot[0]+1.5,foot[1],foot[2]+.5])
			for ortho: bool in [true,false]:
				_projection(ortho,1.0)
				await _shot(id+"-"+str(phase)+"-"+str(ortho))
		if phase == 0: await _sample("props-day")
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore refused")
	for id: String in ["rod","flower"]:
		var foot: Array = approaches[id]
		_place(foot,[foot[0]+1.5,foot[1],foot[2]+.5])
		for ortho: bool in [true,false]:
			for zoom_value: float in [.8,1.15]:
				_projection(ortho,zoom_value)
				await _shot(id+"-zoom-"+str(ortho)+"-"+str(zoom_value).replace(".","_"))
	game.set_process(false)
	var counter: MarisCounter = location.get_node("MarisCounter")
	for stage: String in ["basic","fitting","specialist"]:
		counter.apply_facts(PackedStringArray([] if stage == "basic" else (["maris-returned-to-town"] if stage == "fitting" else ["maris-reconnected"])))
		_place(approaches.maris,[-4.48,0,10.28])
		await _pair("gear-"+stage)
		await _close(counter.get_node("VisualRoot"),"gear-"+stage,4.0)
	for id: String in location.foraging_pickups.targets:
		await _close(location.foraging_pickups.targets[id].get_node("VisualRoot"),id,1.5)
	for kind: String in ["dock_lamp","waylight","woven_net"]:
		for consumer: ExteriorLightConsumer in location.exterior_lights.consumers.values():
			if consumer.source_kind == kind:
				await _close(consumer,kind,3.0)
				break
	var family_subjects: Dictionary[String, Node3D] = {}
	for population: Node in [location.town,location.forest]:
		for wrapper: Node3D in population.get_children():
			var definition: String = str(wrapper.get_meta("definition_id",""))
			if definition in StorybookPropMaterial.SMALL_DEFINITIONS and not family_subjects.has(definition):
				family_subjects[definition] = wrapper.get_node("VisualRoot")
	for definition: String in family_subjects:
		await _close(family_subjects[definition],"prop-"+definition,1.5,true)
	inventory["reviewed_small_families"] = family_subjects.keys()
	game.set_process(true)
	var transition_errors: PackedStringArray = game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
	if not transition_errors.is_empty():
		failures.append("room transition refused")
		return
	if not (await game.world_host.transition_finished)[0]: failures.append("room arrival failed")
	_place([0,0,3.3],[1.2,0,3.5])
	await _pair("recovery-room")
	_place([2.9,0,2.5],[1.2,0,3.5])
	game._refresh_interaction()
	if game.selected_interaction == null or game.selected_interaction.instance_id != "maris-recovery-vessel": failures.append("vessel selector disconnected")
	# Close diagnostic hides UI, so re-open the synthetic pause checkpoint to
	# restore normal pause focus before sending real GUI/input actions.
	game._set_paused(false)
	game._set_paused(true)
	if await _resume():
		_key(KEY_E,true); _key(KEY_E,false)
		var interaction: Dictionary = await TestRunInteractionCapture.dialogue(game,"vessel-input-dialogue",TestRunEvidence.directory(),"synthetic","Real E opens unchanged vessel dialogue after explicit synthetic room transition/feet; no quest or defeat setup")
		if not interaction.ok: failures.append(str(interaction.get("error","vessel E dialogue failed")))
		else: views.append(interaction)
		_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
		game._set_paused(true)
	game.set_process(false)
	await _close(game.world_host.current_location.get_node("RecoveryVessel/VisualRoot"),"vessel",2.0)
	await _close(game.world_host.current_location.get_node("Plinth/VisualRoot"),"plinth",3.5)
	inventory["texture_bytes"] = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
	inventory["shared_painted_materials"] = StorybookPropMaterial.materials.size()
	game.set_process(true)

func _projection(ortho: bool, zoom_value: float) -> void:
	game.camera_rig.zoom_factor = zoom_value
	game.camera_rig.set_orthographic(ortho)
	game.ui.show_camera(game.camera_rig.description())

func _shot(label: String, ordinary: bool = false) -> void:
	game._present_environment()
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic",false,"AD011 fresh ordinary viewport interaction" if ordinary else "AD011 synthetic feet/time/weather/camera/counter presentation/direct room transition")
	if not capture.ok: failures.append(str(capture.get("error","capture failed")))
	else:
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["hud_visible"] = game.ui.visible
		views.append(capture)

func _close(subject: Node3D, label: String, size: float, fit_bounds: bool = false) -> void:
	game.ui.visible = false
	_projection(true,1.0)
	var center: Vector3 = subject.global_position+Vector3(0,.4,0)
	if fit_bounds:
		var bounds: AABB = AABB()
		for mesh: MeshInstance3D in subject.find_children("*","MeshInstance3D",true,false):
			var box: AABB = mesh.global_transform * mesh.get_aabb()
			bounds = bounds.merge(box) if bounds.has_volume() else box
		center = bounds.get_center()
		size = maxf(size,maxf(maxf(bounds.size.x,bounds.size.y),bounds.size.z)*1.25+.5)
	game.camera_rig.camera.size = size
	var distance: float = maxf(5,size*1.8) if fit_bounds else 5
	for angle: float in [45,180,270]:
		game.camera_rig.camera.global_position = center+Vector3(sin(deg_to_rad(angle))*distance,maxf(3,size*.8) if fit_bounds else 3,cos(deg_to_rad(angle))*distance)
		game.camera_rig.camera.look_at(center,Vector3.UP)
		await _shot(label+"-close-"+str(int(angle)))
	game.ui.visible = true

func _key(code: int, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code; event.physical_keycode = code; event.pressed = down
	root.push_input(event,true)

func _resume() -> bool:
	var result: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	if not result.ok: failures.append(str(result.get("error","resume failed")))
	return result.ok

func _walk(goal: Vector3, label: String) -> bool:
	var result: Dictionary = await TestRunJourney.walk(game,goal,label)
	traces.append(result)
	if not result.ok: failures.append(str(result.error))
	return result.ok

func _ordinary() -> void:
	await _shot("ordinary-start",true)
	if not await _resume(): return
	var start: Vector3 = game.player_placeholder.global_position
	_key(KEY_S,true); await create_timer(.8).timeout; _key(KEY_S,false)
	_key(KEY_D,true); await create_timer(.25).timeout; _key(KEY_D,false)
	game._refresh_interaction()
	if game.player_placeholder.global_position.distance_to(start) < .1 or game.selected_interaction == null or game.selected_interaction.instance_id != "dock-lamp-02":
		failures.append("ordinary movement/lamp preflight failed")
		return
	_key(KEY_E,true); _key(KEY_E,false)
	if not game.session.environment.light_enabled("prototype-alderwake","dock-lamp-02","lantern"): failures.append("ordinary lamp switch failed")
	game._set_paused(true)
	await _shot("ordinary-lamp-on",true)
	if not await _resume(): return
	# Safe land/berth waypoints avoid the pre-existing straight-line rod route failure.
	for goal: Vector3 in [Vector3(-4,0,12.5),Vector3(-5.5,0,14),Vector3(-6.5,0,15)]:
		if not await _walk(goal,"rod-approach-"+str(traces.size())): return
	game._refresh_interaction()
	if game.selected_interaction == null or game.selected_interaction.instance_id != ForagingRegistry.ROD_ORIGIN:
		failures.append("ordinary rod selection failed")
		return
	game._set_paused(true)
	await _shot("ordinary-rod",true)
	if not await _resume(): return
	_key(KEY_E,true)
	await create_timer(.12).timeout
	var live: Dictionary = await TestRunInteractionCapture.hold(game,"ordinary-rod-hold",TestRunEvidence.directory(),"debug-input","Fresh WASD route and real E hold; no setup")
	if not live.ok: failures.append(str(live.get("error","hold capture failed")))
	else: views.append(live)
	_key(KEY_E,false)
	if game.foraging_hold.active() or game.session.inventory.count(ForagingRegistry.ROD_ITEM) != 0: failures.append("hold cancellation changed reward")
	_key(KEY_E,true)
	await create_timer(.85).timeout
	_key(KEY_E,false)
	if game.session.inventory.count(ForagingRegistry.ROD_ITEM) != 1: failures.append("ordinary rod pickup failed")
	game._set_paused(true)
	await _shot("ordinary-rod-collected",true)
	if not await _resume(): return
	_key(KEY_B,true); _key(KEY_B,false)
	for frame: int in range(4): await process_frame
	if not game.backpack_open:
		failures.append("ordinary backpack failed")
		return
	_key(KEY_ENTER,true); _key(KEY_ENTER,false)
	for frame: int in range(4): await process_frame
	if game.session.inventory.snapshot().active_item_id != ForagingRegistry.ROD_ITEM: failures.append("ordinary backpack rod selection failed")
	var bag: Dictionary = await TestRunInteractionCapture.backpack(game,"ordinary-selected-rod",TestRunEvidence.directory(),"debug-input","Ordinary B/Enter selects collected rod")
	if not bag.ok: failures.append(str(bag.get("error","bag capture failed")))
	else: views.append(bag)
	_key(KEY_B,true); _key(KEY_B,false)
	if not await _walk(Vector3(-7,0,18),"cast-dock"): return
	_key(KEY_F,true); _key(KEY_F,false)
	var pointer: Vector2 = game.camera_rig.camera.unproject_position(Vector3(-4.75,.015,20.25))
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = pointer; root.push_input(motion,true)
	for down: bool in [true,false]:
		var mouse: InputEventMouseButton = InputEventMouseButton.new()
		mouse.position = pointer; mouse.button_index = MOUSE_BUTTON_LEFT; mouse.pressed = down
		root.push_input(mouse,true)
	if not game.fishing.active():
		failures.append("ordinary F/click cast failed")
		return
	var fishing: Dictionary = await TestRunInteractionCapture.fishing(game,"ordinary-fishing-wait",TestRunEvidence.directory(),"debug-input","Ordinary collected rod and F/click; natural RNG/time","waiting")
	if not fishing.ok: failures.append(str(fishing.get("error","fishing capture failed")))
	else: views.append(fishing)
	_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	if not paused or game.fishing.active(): failures.append("ordinary fishing cancel/pause failed")
	await _shot("ordinary-fishing-canceled",true)
	if not await _resume(): return
	for goal: Vector3 in [Vector3(-6.5,0,15),Vector3(-5.5,0,14),Vector3(-4,0,12.5),Vector3(-5.9959779,0,10.5802193)]:
		if not await _walk(goal,"return-maris-"+str(traces.size())): return
	game._refresh_interaction()
	_key(KEY_E,true); _key(KEY_E,false)
	if not game.dialogue.active():
		failures.append("ordinary Maris dialogue failed")
		return
	var dialogue: Dictionary = await TestRunInteractionCapture.dialogue(game,"ordinary-maris-dialogue",TestRunEvidence.directory(),"debug-input","Fresh ordinary WASD approach and E at painted counter; Esc cancels")
	if not dialogue.ok: failures.append(str(dialogue.get("error","dialogue capture failed")))
	else: views.append(dialogue)
	_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false)
	# Keep route clear of existing achieved NPC contacts; never bypass collision.
	for goal: Vector3 in [Vector3(5,0,6),Vector3(18,0,5),Vector3(27.5,.25,-2)]:
		if not await _walk(goal,"flower-approach-"+str(traces.size())): return
	game._refresh_interaction()
	if game.selected_interaction == null or game.selected_interaction.instance_id != "moonflower-01":
		failures.append("ordinary flower selector failed")
		return
	game._set_paused(true)
	await _shot("ordinary-flower",true)
	if not await _resume(): return
	_key(KEY_E,true); await create_timer(.12).timeout
	live = await TestRunInteractionCapture.hold(game,"ordinary-flower-hold",TestRunEvidence.directory(),"debug-input","Fresh ordinary WASD and E; live gather progress")
	if not live.ok: failures.append(str(live.get("error","flower hold capture failed")))
	else: views.append(live)
	await create_timer(.75).timeout
	_key(KEY_E,false)
	if game.session.inventory.count("item-moonflower") != 1: failures.append("ordinary flower reward failed")
	game._set_paused(true)
	await _shot("ordinary-flower-gathered",true)
