extends "res://tests/art_direction_pilot_render.gd"
## AD018: bounded integrated review. Setup provenance never implies ordinary travel.
var clips: Array[Dictionary] = []
var phase: String = "visual"

func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD018 requires renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.trim_prefix("--phase=")
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	game._set_paused(true)
	if failures.is_empty():
		if phase == "journey":
			await _motion("ordinary-town",true)
			if failures.is_empty(): await _ordinary()
		elif phase == "rooms": await _ordinary_rooms()
		else: await _integrated()
	if not game.player_placeholder.movement_buttons.is_empty(): failures.append("held input at finish")
	game._set_paused(true)
	var output: Dictionary = {"task":"AD018","phase":phase,"views":views,"journey":journey,"observations":observations,"clips":clips,"failures":failures,"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"note":"Fresh ordinary startup/input in journey. Visual phase uses labeled synthetic feet/direct room/preset setup; subsequent crossings use actual WASD/nav guidance. No native/save-restart/full-profile claim."}
	if not TestRunEvidence.write_json("integration-"+phase+"-index.json",output): failures.append("index write")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD018 integrated: ",phase," views=",views.size()," routes=",journey.size()," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _integrated() -> void:
	review = REVIEW.new(); game.add_child(review)
	failures.append_array(review.initialize(game,"ad018-integrated"))
	if not failures.is_empty(): return
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty(): failures.append(str(errors)); return
	if not (await game.world_host.transition_finished)[0]: failures.append("review rebind"); return
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("clear preset"); return
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	for goal: String in ["maris","dense-forest","moonwell","bridge-west","ford-west"]:
		_place(poses.goals[goal].position,poses.goals[goal].companion_position)
		await _pair(goal)
	_place(poses.goals.maris.position,poses.goals.maris.companion_position)
	if not review.apply_preset(2,WeatherSchedule.Condition.THUNDERSTORM): failures.append("storm preset"); return
	await _pair("maris-night-storm")
	# Compact representative matrix: every phase/weather, each camera and zoom bound.
	for state: Dictionary in [{"goal":"dense-forest","phase":1,"weather":1,"label":"dusk-cloudy","zoom":.8},{"goal":"ford-west","phase":3,"weather":2,"label":"dawn-rain","zoom":1.15},{"goal":"bridge-west","phase":2,"weather":3,"label":"night-storm","zoom":.8}]:
		if not review.apply_preset(state.phase,state.weather): failures.append("preset "+state.label); return
		_place(poses.goals[state.goal].position,poses.goals[state.goal].companion_position)
		for ortho: bool in [true,false]:
			_projection_pilot(ortho,state.zoom)
			await _pilot_shot(state.goal+"-"+state.label+("-ortho" if ortho else "-perspective"))
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day restore"); return
	_place(poses.goals["dense-forest"].position,poses.goals["dense-forest"].companion_position)
	await _canopy(game.world_host.current_location)
	_place(poses.goals["dense-forest"].position,poses.goals["dense-forest"].companion_position)
	_projection_pilot(false,1.0)
	await _motion("synthetic-forest",false)
	for crossing: String in ["bridge","ford"]:
		var west: Dictionary = poses.goals[crossing+"-west"]
		var east: Dictionary = poses.goals[crossing+"-east"]
		_place(west.position,west.companion_position); _projection_pilot(true,1.0)
		if not await _resume_pilot(): return
		if not await _walk_pilot(Vector3(east.position[0],east.position[1],east.position[2]),"synthetic-start-"+crossing+"-east"): return
		game._set_paused(true); await _pilot_shot(crossing+"-actual-crossed-east")
		if not await _resume_pilot(): return
		if not await _walk_pilot(Vector3(west.position[0],west.position[1],west.position[2]),"synthetic-start-"+crossing+"-return"): return
		game._set_paused(true); await _pilot_shot(crossing+"-actual-return-west")
	for room: Dictionary in [{"id":"prototype-mayor-vale-home","spawn":"mayor-vale-home-from-alderwake","label":"home","hero":[0,0,-5],"ally":[1,0,-4]},{"id":"prototype-lantern-rest","spawn":"lantern-rest-from-alderwake","label":"inn","hero":[0,0,-8],"ally":[1,0,-7]},{"id":"prototype-tollworks","spawn":"tollworks-from-alderwake","label":"tollworks","hero":[0,0,3.3],"ally":[1.2,0,3.5]}]:
		if room.label == "tollworks" and not game.quests.apply("prototype-maris-recovery","maris-accept-lead","prototype-alderwake","npc-03-counter").ok: failures.append("synthetic lead"); return
		if not game.world_host.request_transition(room.id,room.spawn).is_empty(): failures.append("room request"); return
		if not (await game.world_host.transition_finished)[0]: failures.append("room arrival"); return
		_place(room.hero,room.ally); await _pair(room.label)
		if game.environment_presenter.profile != 0 or not game.world_host.current_location.find_children("WorldRain","",true,false).is_empty(): failures.append("indoor weather leak")

func _pair(label: String) -> void:
	for ortho: bool in [true,false]:
		_projection_pilot(ortho,1.0)
		await _pilot_shot(label+("-orthographic" if ortho else "-perspective"))

func _pilot_shot(label: String,ordinary: bool = false) -> void:
	game._present_environment()
	# Frozen placement bypasses the presenter's normal 0.15s process refresh.
	# Evaluate presentation once, without ticking gameplay or changing label rules.
	game.ui.storybook._process(.15)
	var visible_labels: int = 0
	for entry: Dictionary in game.ui.storybook.labels:
		if is_instance_valid(entry.node) and entry.node.visible: visible_labels += 1
	if visible_labels > 1: failures.append("stale static label presentation "+label)
	var result: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic",false,"AD018 fresh ordinary input" if ordinary else "AD018 synthetic frozen feet/phase/weather/direct room, canopy controls; crossings after placement use actual inputs")
	if not result.ok: failures.append(result.get("error","capture")); return
	result["ally_position"] = TestRunObservation.vector(game.companion.global_position)
	result["camera_transform"] = str(game.camera_rig.camera.global_transform)
	result["sun_energy"] = game.get_node("Sun").light_energy
	views.append(result)

func _motion(label: String,ordinary: bool) -> void:
	if not await _resume_pilot(): return
	var start: Vector3 = game.player_placeholder.global_position
	var frames: Array[Dictionary] = []
	_key_pilot(KEY_D,true)
	for index: int in range(12):
		for tick: int in range(6): await physics_frame
		var result: Dictionary = await TestRunInteractionCapture.hold(game,"%s-motion-%02d" % [label,index],TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic","AD018 live D movement, automatic clock/AI/weather; fresh town startup" if ordinary else "AD018 synthetic forest start/camera/day-clear; actual D input, automatic clock/AI/weather",false)
		if not result.ok: failures.append(result.get("error","live motion")); break
		views.append(result); frames.append(result)
	_key_pilot(KEY_D,false)
	game._set_paused(true)
	var moved: float = game.player_placeholder.global_position.distance_to(start)
	if moved <= .1 or not game.player_placeholder.movement_buttons.is_empty(): failures.append("motion/release "+label)
	clips.append({"label":label,"frames":frames,"distance_m":moved,"released":game.player_placeholder.movement_buttons.is_empty(),"note":"sequential actual rendered frames; timestamps retain variable capture cadence"})
	await _pilot_shot(label+"-motion-final",ordinary)

func _ordinary_rooms() -> void:
	# Current public approaches copied from established room journeys, not teleports.
	for room: Dictionary in [{"label":"home","id":"prototype-mayor-vale-home","approach":Vector3(5,0,-5.15),"stops":[Vector3(2,0,0),Vector3(-3.5,0,.25),Vector3(-3,0,-6.75),Vector3(4.5,0,-6.5)]},{"label":"inn","id":"prototype-lantern-rest","approach":RoutineExteriorRegistry.entrance(NpcRegistry.LOCATION,"lantern-rest-entrance-01").player_approach,"stops":[Vector3(-6,0,-10.8),Vector3(-7,0,-5),Vector3(6,0,-4)]}]:
		if not await _resume_pilot(): return
		if not await _walk_pilot(room.approach,"ordinary-"+room.label+"-door"): return
		await _tap(KEY_E)
		if not await _arrival_integration(room.id): return
		var index: int = 0
		for goal: Vector3 in room.stops:
			if not await _walk_pilot(goal,"ordinary-"+room.label+"-stop-"+str(index)): return
			if room.label == "inn" and index == 0:
				game._refresh_interaction()
				if game.selected_interaction == null or game.selected_interaction.instance_id != "della-inn-host-01": failures.append("actual host selection"); return
				await _tap(KEY_E)
				var dialogue_shot: Dictionary = await TestRunInteractionCapture.dialogue(game,"ordinary-inn-host-dialogue",TestRunEvidence.directory(),"debug-input","AD018 fresh public inn entry, actual WASD/E host; no placement/fact/time/affinity setup")
				if not dialogue_shot.ok: failures.append(dialogue_shot.get("error","host dialogue")); return
				views.append(dialogue_shot)
				await _tap(KEY_ESCAPE)
				if game.dialogue.active() or not game.player_placeholder.controls_enabled: failures.append("host close"); return
			if index == 1: await _tap(KEY_P)
			await _tap(KEY_ESCAPE)
			if not paused or not game.ui.pause_overlay.visible: failures.append("public room pause"); return
			await _pilot_shot("ordinary-"+room.label+"-stop-"+str(index),true)
			if not await _resume_pilot(): return
			index += 1
		if not await _walk_pilot(Vector3(0,0,.65),"ordinary-"+room.label+"-exit"): return
		await _tap(KEY_E)
		if not await _arrival_integration("prototype-alderwake"): return
		await _tap(KEY_ESCAPE)
		if not paused or not game.ui.pause_overlay.visible: failures.append("public return pause"); return
		await _pilot_shot("ordinary-"+room.label+"-returned",true)
	if game.party.members().size() != 2 or NavigationServer3D.map_get_regions(game.get_world_3d().navigation_map).size() != 1: failures.append("room return ownership")

func _tap(code: Key) -> void:
	_key_pilot(code,true); await process_frame
	_key_pilot(code,false); await process_frame

func _arrival_integration(id: String) -> bool:
	for tick: int in range(600):
		await physics_frame
		if game.session.current_location_id == id and not game.world_host.transitioning:
			for settle: int in range(4): await physics_frame
			return true
	failures.append("public arrival "+id); return false
