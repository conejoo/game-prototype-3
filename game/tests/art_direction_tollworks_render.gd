extends "res://tests/art_direction_actor_render.gd"
## AD016 engine review. Only quest lead/direct room setup synthetic in input phases.
const ROOM_PAINT: Script = preload("res://world/storybook_tollworks_material.gd")
var room: PrototypeLocation
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD016 requires renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED); Engine.max_fps = 0
	phase = "paint"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.trim_prefix("--phase=")
	game = preload("res://app/game_root.tscn").instantiate(); root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	game._set_paused(true); DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	if phase == "paint": await _room_art()
	else:
		await _input_sample()
		if failures.is_empty(): await _recovery_input()
	var output: Dictionary = {"task":"AD016","phase":phase,"views":views,"live_views":live_views,"traces":traces,"failures":failures,"pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"kind":"synthetic frozen feet/cameras/time/weather/direct transition; only room overrides removed in before controls" if phase == "paint" else "synthetic quest lead/direct Tollworks transition; subsequent bounded viewport WASD/pointer/click/SPACE combat and E/GUI recovery with verified pause. Not ordinary route/native/save/profile"}
	if not TestRunEvidence.write_json("tollworks-"+phase+"-index.json",output): failures.append("index")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD016 Tollworks rendered: ",phase," captures=",views.size()," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _room_art() -> void:
	if not game.quests.apply("prototype-maris-recovery","maris-accept-lead","prototype-alderwake","npc-03-counter").ok: failures.append("synthetic lead")
	if not game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(): failures.append("room request"); return
	if not (await game.world_host.transition_finished)[0]: failures.append("room arrival"); return
	room = game.world_host.current_location
	for stop: Dictionary in [{"name":"entry","hero":[0,0,-2.5],"ally":[1.2,0,-2.5]},{"name":"combat","hero":[0,0,-.5],"ally":[1.2,0,-.5]},{"name":"vessel","hero":[2.9,0,2.5],"ally":[1.2,0,3.5]}]:
		_place(stop.hero,stop.ally)
		for ortho: bool in [true,false]:
			for zoom_value: float in ([.8,1.15] if stop.name == "combat" else [1.0]):
				game.camera_rig.zoom_factor = zoom_value; game.camera_rig.set_orthographic(ortho); game.ui.show_camera(game.camera_rig.description())
				var label: String = "%s-%s-%d" % [stop.name,"ortho" if ortho else "perspective",roundi(zoom_value*100)]
				await _shot(label+"-painted"); _room_original(true); await _shot(label+"-original"); _room_original(false)
	_place([0,0,-.5],[1.2,0,-.5]); game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(true); game.ui.show_camera(game.camera_rig.description())
	for night: bool in [false,true]:
		game.session.environment.day_index = 2
		game.session.environment.day_cycle_progress = .625 if night else .05
		var matched: bool = false
		for seed: int in range(10000):
			var weather: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed,2,game.session.environment.day_cycle_progress)
			if weather.condition == (WeatherSchedule.Condition.THUNDERSTORM if night else WeatherSchedule.Condition.SUNNY) and weather.transition_progress == 1:
				game.session.environment.weather_seed = seed; matched = true; break
		if not matched: failures.append("weather preset unavailable")
		game._present_environment(); await _shot("indoor-storm-night" if night else "indoor-clear-day")
		if game.environment_presenter.profile != LocationDefinition.LightingProfile.STABLE_INDOOR or not game.find_children("WorldRain","",true,false).is_empty(): failures.append("indoor weather leaked")
	game.ui.visible = false; game.camera_rig.set_orthographic(true); game.camera_rig.camera.size = 20
	for angle: float in [0,90,180,270]:
		var target: Vector3 = Vector3(0,.3,0)
		game.camera_rig.camera.global_position = target+Vector3(sin(deg_to_rad(angle))*18,20,cos(deg_to_rad(angle))*18)
		game.camera_rig.camera.look_at(target,Vector3.UP); await _shot("all-surface-"+str(int(angle)))
	game.ui.visible = true

func _room_original(on: bool) -> void:
	for owner: String in ["Floor","BackWall","SideWall","FrontWall","RightWall"]:
		room.get_node(owner+"/Mesh").material_override = null if on else ROOM_PAINT.painted(owner)

func _shot(label: String,overlay: bool = false) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic" if phase == "paint" else "debug-input",overlay,"AD016 synthetic frozen room/feet/cameras/time/weather; original controls remove five room overrides only" if phase == "paint" else "AD016 only lead/direct room setup synthetic; bounded normal viewport movement/aim/attack/dodge/combat/recovery afterward; verified pause")
	if not capture.ok: failures.append(str(capture.get("error","capture"))); return
	capture["ally"] = TestRunObservation.vector(game.companion.global_position)
	capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
	capture["sun"] = {"transform":str(game.get_node("Sun").transform),"energy":game.get_node("Sun").light_energy}
	capture["subjects"] = []
	for actor: ActorPlaceholder in [game.player_placeholder,game.companion,game.guardian]:
		if not is_instance_valid(actor): continue
		capture.subjects.append({"name":str(actor.name),"feet":TestRunObservation.vector(actor.global_position),"health":actor.state.health,"attack":actor.combat.attacking,"active":actor.combat.active(),"elapsed":actor.combat.elapsed,"windup":actor.combat.windup,"dodge_left":actor.combat.dodge_left,"marker":actor.combat_marker.visible})
	views.append(capture)

func _live_aim() -> void:
	# Aim itself is inherited unchanged; AD016 needs combat-floor/cues, not a live aim capture.
	# Its following pause capture still carries actual pointer state and ordinary attack.
	await process_frame

func _recovery_input() -> void:
	# Natural combat continues only in this bounded loop; no damage/health/AI mutation.
	if not await _resume(): return
	var began: int = Time.get_ticks_msec()
	for frame: int in range(720):
		if game.guardian.state.health <= 0 or game.player_placeholder.state.health <= 0: break
		if not game.player_placeholder.combat.busy():
			_pointer(game.camera_rig.camera.unproject_position(game.guardian.global_position+Vector3(0,.1,0)),true)
		await physics_frame
	game._set_paused(true)
	traces.append({"label":"bounded-real-combat","elapsed_ms":Time.get_ticks_msec()-began,"hero_health":game.player_placeholder.state.health,"ally_health":game.companion.state.health,"guardian_health":game.guardian.state.health,"effects":game.session.completed_effect_ids.duplicate()})
	if game.guardian.state.health > 0 or game.player_placeholder.state.health <= 0: failures.append("bounded combat did not safely clear guardian"); return
	if not "tollworks-guardian-cleared" in game.session.completed_effect_ids: failures.append("real defeat fact absent"); return
	await _shot(phase+"-guardian-cleared",true)
	if not await _resume(): return
	var walked: Dictionary = await TestRunJourney.walk(game,Vector3(2.9,0,2.5),"cleared-room-vessel")
	traces.append(walked)
	if not walked.ok: failures.append(str(walked.error)); game._set_paused(true); return
	game._refresh_interaction()
	if game.selected_interaction == null or game.selected_interaction.instance_id != "maris-recovery-vessel": failures.append("normal vessel selector"); game._set_paused(true); return
	_key(KEY_E,true); _key(KEY_E,false)
	var dialogue_capture: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-vessel-dialogue",TestRunEvidence.directory(),"debug-input","AD016 real WASD/E after bounded natural combat; only original lead/room transition synthetic")
	if not dialogue_capture.ok: failures.append(str(dialogue_capture.error)); return
	views.append(dialogue_capture)
	var selected: bool = false
	for step: int in range(16):
		var focus: Control = root.gui_get_focus_owner()
		if focus != null and str(focus.name) == "maris-vessel-choice": selected = true; break
		_key(KEY_TAB,true); _key(KEY_TAB,false); await process_frame
	if not selected: failures.append("recovery choice focus unavailable"); return
	_key(KEY_ENTER,true); _key(KEY_ENTER,false)
	for frame: int in range(4): await process_frame
	if not "maris-return-path-open" in game.session.completed_effect_ids: failures.append("real GUI recovery effect absent"); return
	var recovered: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-vessel-recovered",TestRunEvidence.directory(),"debug-input","AD016 actual focused Enter opens recovery path; no quest/damage/reward injection")
	if not recovered.ok: failures.append(str(recovered.error)); return
	views.append(recovered)
	_key(KEY_ESCAPE,true); _key(KEY_ESCAPE,false); game._set_paused(true)
	await _shot(phase+"-recovery-checkpoint",true)
	if not game.player_placeholder.movement_buttons.is_empty(): failures.append("recovery keys held")
