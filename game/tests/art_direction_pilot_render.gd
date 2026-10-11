extends "res://tests/art_direction_dock_render.gd"
## AD008: separate fresh ordinary journey and explicitly synthetic visual review.

var journey: Array[Dictionary] = []
var observations: Array[Dictionary] = []

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("AD008 requires real renderer")
		quit(1)
		return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup failed")
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var ordinary: bool = "--phase=journey" in OS.get_cmdline_user_args()
	if failures.is_empty():
		if ordinary: await _ordinary()
		else: await _review_pilot()
	var output: Dictionary = {"task":"AD008","ordinary":ordinary,"views":views,"samples":samples,"journey":journey,"observations":observations,"inventory":inventory,"failures":failures,
		"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),
		"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"api":RenderingServer.get_video_adapter_api_version(),"vsync":DisplayServer.window_get_vsync_mode(),"max_fps":Engine.max_fps,
		"scope":"fresh ordinary WASD/E/Esc/P pilot journey" if ordinary else "synthetic frozen feet/time/weather/canopy controls; short paused samples, not full profiling"}
	if not TestRunEvidence.write_json("pilot-journey-index.json" if ordinary else "pilot-index.json",output): failures.append("index write failed")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD008 pilot: %d captures, %d samples, %d journeys, %d failures" % [views.size(),samples.size(),journey.size(),failures.size()])
	quit(0 if failures.is_empty() else 1)

func _review_pilot() -> void:
	game._set_paused(true)
	review = REVIEW.new()
	game.add_child(review)
	failures.append_array(review.initialize(game,"ad008-pilot"))
	if not failures.is_empty(): return
	game._pending_restore = game.session
	var errors: PackedStringArray = game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session)
	if not errors.is_empty():
		failures.append("review rebind refused: " + str(errors))
		return
	if not (await game.world_host.transition_finished)[0]:
		failures.append("review rebind failed")
		return
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	inventory = _dock_inventory(location)
	var poses: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(POSES))
	var goals: Dictionary = {"maris":poses.goals.maris,"dock":{"position":[-8,0,18],"companion_position":[-6.8,0,17.5]}}
	for state: Dictionary in [{"label":"day-clear","phase":0,"weather":WeatherSchedule.Condition.SUNNY},
		{"label":"night-clear","phase":2,"weather":WeatherSchedule.Condition.SUNNY},
		{"label":"day-rain","phase":0,"weather":WeatherSchedule.Condition.RAINY},
		{"label":"night-storm","phase":2,"weather":WeatherSchedule.Condition.THUNDERSTORM}]:
		if not review.apply_preset(state.phase,state.weather):
			failures.append("preset refused: " + state.label)
			return
		for goal: String in goals:
			_place(goals[goal].position,goals[goal].companion_position)
			for ortho: bool in [true,false]:
				for zoom_value: float in ([0.8,1.0,1.15] if state.label in ["day-clear","night-storm"] else [1.0]):
					_projection_pilot(ortho,zoom_value)
					await _pilot_shot("%s-%s-%s-%s" % [goal,state.label,"ortho" if ortho else "persp",str(zoom_value).replace(".","_")])
			if state.label in ["day-clear","night-storm"]:
				_projection_pilot(true,1.0)
				await _sample(goal+"-"+state.label)
	# Same forest pose/sample as AD001 links the painted oak to the shared recipe.
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("clear restore refused")
	_place(poses.goals["dense-forest"].position,poses.goals["dense-forest"].companion_position)
	_projection_pilot(true,1.0)
	await _sample("dense-forest-day-clear")
	await _canopy(location)
	var final_inventory: Dictionary = _dock_inventory(location)
	observations.append({"case":"weather-selected render node observation","start_nodes":inventory.nodes,"end_nodes":final_inventory.nodes,"note":"Existing paused rain batches vary by weather/projection/pose, as in AD007. Geometry/semantic/transform guarantees remain exact."})
	var physical_matches: bool = true
	for field: String in inventory:
		if field != "nodes" and inventory[field] != final_inventory[field]:
			physical_matches = false
			failures.append("pilot physical inventory changed: " + field)
	inventory["final_matches"] = physical_matches

func _canopy(location: AlderwakeTerrainPreview) -> void:
	var target: Node3D
	var nearest: float = INF
	for record: Dictionary in location.forest.prop_records:
		if record.tree == null or record.tree.species != "oak": continue
		var wrapper: Node3D = location.forest.get_node(NodePath(record.id))
		var distance: float = wrapper.global_position.distance_to(game.player_placeholder.global_position)
		if distance < nearest:
			nearest = distance
			target = wrapper
	if target == null:
		failures.append("painted oak absent")
		return
	var mesh: Mesh = location.tree_art.meshes[target.get_meta("tree_art_mesh")]
	var center: Vector3 = target.position + mesh.get_aabb().get_center() * Vector3(1,0,1)
	center.y = location.elevation.height_at(Vector2(center.x,center.z))
	_place(TestRunObservation.vector(center+Vector3(-0.55,0,0.25)),TestRunObservation.vector(center+Vector3(0.55,0,0.25)))
	game.set_process(false) # Only diagnostic toggle; root otherwise restores cutout.
	for ortho: bool in [true,false]:
		for zoom_value: float in [0.8,1.15]:
			_projection_pilot(ortho,zoom_value)
			for enabled: bool in [true,false]:
				location.tree_art.update_visibility(game.camera_rig.camera,game.player_placeholder if enabled else null,game.companion if enabled else null)
				await _pilot_shot("canopy-%s-%s-%s" % ["ortho" if ortho else "persp",str(zoom_value).replace(".","_"),"on" if enabled else "off"])
	game.set_process(true)
	location.tree_art.update_visibility(game.camera_rig.camera,game.player_placeholder,game.companion)
	observations.append({"case":"synthetic canopy control","target_id":str(target.name),"hero":TestRunObservation.vector(game.player_placeholder.global_position),"ally":TestRunObservation.vector(game.companion.global_position),"trees":location.tree_art.tree_ids.size(),"batches":location.tree_art.batches.size(),"materials":location.tree_art.visibility_materials.size()})

func _ordinary() -> void:
	game._set_paused(true)
	await _pilot_shot("ordinary-start",true)
	if not await _resume_pilot(): return
	var start: Vector3 = game.player_placeholder.global_position
	_key_pilot(KEY_D,true)
	for frame: int in range(15): await physics_frame
	_key_pilot(KEY_D,false)
	observations.append({"case":"fresh normal D preflight","start":TestRunObservation.vector(start),"actual":TestRunObservation.vector(game.player_placeholder.global_position),"camera":TestRunObservation.camera(game),"released":game.player_placeholder.movement_buttons.is_empty()})
	if game.player_placeholder.global_position.distance_to(start) <= 0.1:
		failures.append("ordinary movement preflight failed")
		return
	if not await _walk_pilot(NpcRegistry.find("npc-03").approach,"maris-approach"): return
	game._refresh_interaction()
	if game.selected_interaction == null or game.selected_interaction.instance_id != "npc-03-counter":
		failures.append("Maris not selected at actual approach: " + game.ui.travel_label.text)
		return
	observations.append({"case":"actual Maris contextual selection","instance_id":game.selected_interaction.instance_id,"prompt":game.ui.travel_label.text,"foot":TestRunObservation.vector(game.selected_interaction.global_position)})
	game._set_paused(true)
	await _pilot_shot("ordinary-maris-approach",true)
	if not await _resume_pilot(): return
	_key_pilot(KEY_E,true); _key_pilot(KEY_E,false)
	await process_frame
	if not game.dialogue.active() or game.dialogue.snapshot().get("npc_id") != "npc-03":
		failures.append("public E did not open Maris dialogue")
		return
	var dialogue_capture: Dictionary = await TestRunInteractionCapture.dialogue(game,"ordinary-maris-dialogue",TestRunEvidence.directory(),"debug-input","AD008 fresh ordinary WASD approach and E; authored Maris counter dialogue; simulation unpaused, controls suspended")
	if not dialogue_capture.ok: failures.append(dialogue_capture.get("error","dialogue capture failed"))
	else: views.append(dialogue_capture)
	observations.append({"case":"actual E dialogue","dialogue":game.dialogue.snapshot(),"controls_enabled":game.player_placeholder.controls_enabled})
	var dialogue_foot: Vector3 = game.player_placeholder.global_position
	_key_pilot(KEY_W,true)
	for frame: int in range(6): await physics_frame
	_key_pilot(KEY_W,false)
	if game.player_placeholder.global_position != dialogue_foot: failures.append("world movement leaked through dialogue")
	_key_pilot(KEY_ESCAPE,true); _key_pilot(KEY_ESCAPE,false)
	await process_frame
	if game.dialogue.active() or not game.player_placeholder.controls_enabled or not game.player_placeholder.movement_buttons.is_empty():
		failures.append("dialogue cancel did not restore controls/release keys")
		return
	for goal: Vector3 in [Vector3(-6.5,0,14.1),Vector3(-6.5,0,15.5),Vector3(-8,0,18.25),Vector3(-6.5,0,14.1),NpcRegistry.find("npc-03").approach]:
		if not await _walk_pilot(goal,"dock-route-%d" % journey.size()): return
		game._set_paused(true)
		await _pilot_shot("ordinary-arrival-%02d" % journey.size(),true)
		if not await _resume_pilot(): return
		if journey.size() == 3:
			_key_pilot(KEY_P,true); _key_pilot(KEY_P,false)
			await process_frame
	if game.camera_rig.camera.projection != Camera3D.PROJECTION_PERSPECTIVE: failures.append("public P projection change failed")
	if game.party.members().size() != 2 or game.session.current_location_id != "prototype-alderwake": failures.append("pilot party/location changed")
	game._set_paused(true)
	await _pilot_shot("ordinary-return-perspective",true)
	observations.append({"case":"ordinary return","party_size":game.party.members().size(),"hero":TestRunObservation.vector(game.player_placeholder.global_position),"ally":TestRunObservation.vector(game.companion.global_position),"released":game.player_placeholder.movement_buttons.is_empty(),"session":SaveCodec.snapshot(game.session)})

func _walk_pilot(goal: Vector3,label: String) -> bool:
	var result: Dictionary = await TestRunJourney.walk(game,goal,label)
	journey.append(result)
	if not result.ok: failures.append(result.error)
	return result.ok

func _resume_pilot() -> bool:
	var resumed: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	if not resumed.ok: failures.append(resumed.get("error","observed GUI Resume failed"))
	return resumed.ok

func _key_pilot(code: Key,pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event,true)

func _projection_pilot(ortho: bool,zoom_value: float) -> void:
	game.camera_rig.zoom_factor = zoom_value
	game.camera_rig.set_orthographic(ortho)
	game.ui.show_camera(game.camera_rig.description())

func _pilot_shot(label: String,ordinary: bool = false) -> void:
	game._present_environment()
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"debug-input" if ordinary else "synthetic",false,
		"AD008 fresh normal input journey; pause verified after observed arrival" if ordinary else "AD008 synthetic fixture feet, detached day/night/rain/storm; paused routines; canopy on/off diagnostic; ordinary gameplay camera and HUD")
	if not capture.ok: failures.append(capture.get("error","capture failed"))
	else:
		capture["ally_position"] = TestRunObservation.vector(game.companion.global_position)
		capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
		capture["rendered_time_weather"] = game.ui.time_label.text
		views.append(capture)
