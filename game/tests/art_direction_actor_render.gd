extends "res://tests/art_direction_baseline_render.gd"
## AD013 engine art review and bounded ordinary combat input after labeled room setup.
const PAINT: Script = preload("res://features/actors/storybook_actor_material.gd")
var review_guardian: ActorPlaceholder
var traces: Array[Dictionary] = []
var live_views: Array[Dictionary] = []
var phase: String = "pilot"
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD013 needs renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED); Engine.max_fps = 0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.trim_prefix("--phase=")
	game = preload("res://app/game_root.tscn").instantiate(); root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	game._set_paused(true); DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	if phase == "pilot": await _art()
	else: await _input_sample()
	var output: Dictionary = {"task":"AD013","phase":phase,"views":views,"live_views":live_views,"traces":traces,"failures":failures,"pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"texture_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"kind":"synthetic feet/cameras/time/weather/review guardian/feedback poses" if phase == "pilot" else "synthetic quest lead/direct Tollworks transition only; real bounded viewport WASD/pointer/click/SPACE combat and observed pause checkpoints; not ordinary route/native/save/profile"}
	if not TestRunEvidence.write_json("actors-"+phase+"-index.json",output): failures.append("index")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD013 rendered actors: ",phase," captures=",views.size()," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _art() -> void:
	review = REVIEW.new(); game.add_child(review)
	failures.append_array(review.initialize(game,"ad013-actors"))
	game._pending_restore = game.session
	if not game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session).is_empty(): failures.append("rebind"); return
	if not (await game.world_host.transition_finished)[0]: failures.append("rebind arrival"); return
	review_guardian = load("res://features/combat/guardian.tscn").instantiate(); game.add_child(review_guardian)
	review_guardian.initialize(ActorState.new("ad013-review",game.catalog.get_actor("prototype-guardian")))
	for night: bool in [false,true]:
		if not review.apply_preset(2 if night else 0,WeatherSchedule.Condition.THUNDERSTORM if night else WeatherSchedule.Condition.SUNNY): failures.append("preset")
		for setup: Dictionary in [{"name":"meadow","feet":[-5.5,0,12]},{"name":"shore","feet":[-7,0,18]},{"name":"forest","feet":[27.5,.25,-2]}]:
			var f: Array = setup.feet
			_place(f,[f[0]+1.2,f[1],f[2]+.5]); review_guardian.global_position = Vector3(f[0]-1.2,f[1],f[2])
			for ortho: bool in [true,false]:
				for zoom_value: float in ([.8,1.15] if setup.name == "meadow" and not night else [1.0]):
					game.camera_rig.zoom_factor = zoom_value; game.camera_rig.set_orthographic(ortho); game.ui.show_camera(game.camera_rig.description())
					var label: String = "%s-%s-%s-%s" % [setup.name,"night" if night else "day","ortho" if ortho else "perspective",str(zoom_value).replace(".","_")]
					await _shot(label+"-painted")
					_original(true); await _shot(label+"-original"); _original(false)
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("restore day")
	# Expose all original surfaces, with elevated diagnostic copies and real engine lighting.
	for actor: ActorPlaceholder in [game.player_placeholder,game.companion,review_guardian]:
		_place([-5.5,40,12],[-4.3,40,12.5]); review_guardian.global_position = Vector3(-6.7,40,12)
		game.player_placeholder.visible = actor == game.player_placeholder
		game.companion.visible = actor == game.companion
		review_guardian.visible = actor == review_guardian
		game.ui.visible = false; game.camera_rig.set_orthographic(true); game.camera_rig.camera.size = 2.4
		var center: Vector3 = actor.global_position+Vector3(0,.8,0)
		for angle: float in [0,90,180]:
			game.camera_rig.camera.global_position = center+Vector3(sin(deg_to_rad(angle))*5,1.2,cos(deg_to_rad(angle))*5)
			game.camera_rig.camera.look_at(center,Vector3.UP)
			await _shot(str(actor.name)+"-close-"+str(int(angle))+"-painted")
			if angle == 0: _original(true); await _shot(str(actor.name)+"-close-0-original"); _original(false)
	game.player_placeholder.visible = true; game.companion.visible = true; review_guardian.free(); review_guardian = null; game.ui.visible = true
	var lead: NpcDialogueService.Result = game.quests.apply("prototype-maris-recovery","maris-accept-lead","prototype-alderwake","npc-03-counter")
	if not lead.ok: failures.append("lead")
	if not game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(): failures.append("room"); return
	if not (await game.world_host.transition_finished)[0]: failures.append("arrival"); return
	_place([0,0,-.5],[1.2,0,-.5])
	for ortho: bool in [true,false]:
		game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(ortho); game.ui.show_camera(game.camera_rig.description())
		var label: String = "tollworks-"+("ortho" if ortho else "perspective")
		await _shot(label+"-painted"); _original(true); await _shot(label+"-original"); _original(false)
		var hero: ActorPlaceholder = game.player_placeholder
		hero.combat_enabled = true; hero.combat.cancel(); hero.combat.hit_flash = 0
		hero.request_attack(); hero._update_feedback(); await _shot(label+"-windup")
		hero.combat.advance(.18); hero._update_feedback(); await _shot(label+"-active")
		hero.combat.advance(.14); hero._update_feedback(); await _shot(label+"-recovery")
		hero.combat.advance(.30); hero.request_dodge(Vector3.RIGHT); hero._update_feedback(); await _shot(label+"-dodge")
		hero.combat.advance(.30); hero.receive_damage(25); hero._update_feedback(); await _shot(label+"-damage")
		# Synthetic lethal receive exercises actual death presentation; restore session health only for next review pose.
		hero.receive_damage(100); hero._update_feedback(); await _shot(label+"-death")
		hero.state.health = 100; hero.initialize(hero.state); hero.combat.hit_flash = 0; hero._update_feedback()

func _original(on: bool) -> void:
	var actors: Array[ActorPlaceholder] = [game.player_placeholder,game.companion]
	if is_instance_valid(review_guardian): actors.append(review_guardian)
	if is_instance_valid(game.guardian): actors.append(game.guardian)
	for actor: ActorPlaceholder in actors:
		if not on: PAINT.apply(actor); continue
		var body: MeshInstance3D = actor.get_node_or_null("VisualRoot/Body")
		if body != null: body.material_override = null
		else:
			for mesh: MeshInstance3D in PAINT._meshes(actor.visual_root):
				for surface: int in range(mesh.mesh.get_surface_count()): mesh.set_surface_override_material(surface,null)

func _shot(label: String,overlay: bool = false) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic" if phase == "pilot" else "debug-input",overlay,"AD013: frozen synthetic feet/time/weather/direct room/gallery/actual feedback calls" if phase == "pilot" else "AD013: only quest lead/direct room setup synthetic; subsequent WASD, pointer, click, SPACE and combat timers through unchanged gameplay; pause verified")
	if not capture.ok: failures.append(str(capture.get("error","capture"))); return
	var subjects: Array[Dictionary] = []
	var actors: Array[ActorPlaceholder] = [game.player_placeholder,game.companion]
	if is_instance_valid(review_guardian): actors.append(review_guardian)
	if is_instance_valid(game.guardian): actors.append(game.guardian)
	for actor: ActorPlaceholder in actors:
		var p: Vector2 = game.camera_rig.camera.unproject_position(actor.global_position+Vector3(0,.8,0))
		subjects.append({"name":str(actor.name),"feet":TestRunObservation.vector(actor.global_position),"screen":[p.x,p.y],"health":actor.state.health,"visible":actor.visible,"attack":actor.combat.attacking,"active":actor.combat.active(),"elapsed":actor.combat.elapsed,"windup":actor.combat.windup,"recovery":actor.combat.recovery,"dodge_left":actor.combat.dodge_left,"flash":actor.combat.hit_flash,"scale":TestRunObservation.vector(actor.visual_root.scale),"marker":actor.combat_marker.visible,"marker_color":str(actor.combat_marker.material_override.albedo_color)})
	capture["subjects"] = subjects; views.append(capture)

func _key(code: int,down: bool) -> void:
	var event: InputEventKey = InputEventKey.new(); event.keycode = code; event.physical_keycode = code; event.pressed = down; root.push_input(event,true)
func _pointer(point: Vector2,click: bool = false) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new(); motion.position = point; root.push_input(motion,true)
	if click:
		for down: bool in [true,false]:
			var button: InputEventMouseButton = InputEventMouseButton.new(); button.position = point; button.button_index = MOUSE_BUTTON_LEFT; button.pressed = down; root.push_input(button,true)
func _resume() -> bool:
	var result: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	if not result.ok: failures.append(str(result.error))
	return result.ok
func _input_sample() -> void:
	var lead: NpcDialogueService.Result = game.quests.apply("prototype-maris-recovery","maris-accept-lead","prototype-alderwake","npc-03-counter")
	if not lead.ok: failures.append("input synthetic lead"); return
	if not game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(): failures.append("input transition"); return
	if not (await game.world_host.transition_finished)[0]: failures.append("input arrival"); return
	game.camera_rig.set_orthographic(phase == "input-ortho"); game.ui.show_camera(game.camera_rig.description())
	await _shot(phase+"-start",true)
	if not await _resume(): return
	var start: Vector3 = game.player_placeholder.global_position
	_key(KEY_A,true); await create_timer(.20).timeout; _key(KEY_A,false)
	game._set_paused(true)
	var movement: float = start.distance_to(game.player_placeholder.global_position)
	traces.append({"keys":["A"],"requested_seconds":.20,"distance":movement,"accepted_keys":game.player_placeholder.movement_buttons.keys()})
	if movement < .1 or not game.player_placeholder.movement_buttons.is_empty(): failures.append("input movement/release"); return
	await _shot(phase+"-movement")
	if not await _resume(): return
	# Aim at clear physical floor first so the small original ring is not occluded
	# by the approaching guardian. Attack subsequently aims at the actual guardian.
	var target: Vector2 = game.camera_rig.camera.unproject_position(Vector3(-3,0,2))
	_pointer(target)
	await process_frame
	if not game.player_placeholder.aim_marker.visible: failures.append("input aim absent")
	await _live_aim()
	game._set_paused(true); await _shot(phase+"-aim")
	if not await _resume(): return
	target = game.camera_rig.camera.unproject_position(game.guardian.global_position+Vector3(0,.1,0))
	_pointer(target,true)
	await physics_frame
	if not game.player_placeholder.combat.attacking: failures.append("input click attack"); return
	game._set_paused(true); await _shot(phase+"-windup")
	if not await _resume(): return
	for frame: int in range(30):
		if game.player_placeholder.combat.active(): break
		await physics_frame
	if not game.player_placeholder.combat.active(): failures.append("input active window"); return
	game._set_paused(true); await _shot(phase+"-active")
	if not await _resume(): return
	for frame: int in range(30):
		if not game.player_placeholder.combat.active(): break
		await physics_frame
	if not game.player_placeholder.combat.busy(): failures.append("input recovery window"); return
	game._set_paused(true); await _shot(phase+"-recovery")
	if not await _resume(): return
	for frame: int in range(40):
		if not game.player_placeholder.combat.busy(): break
		await physics_frame
	_key(KEY_SPACE,true); _key(KEY_SPACE,false); await physics_frame
	if game.player_placeholder.combat.dodge_left <= 0: failures.append("input dodge"); return
	game._set_paused(true); await _shot(phase+"-dodge")
	if not await _resume(): return
	for frame: int in range(240):
		if game.guardian.combat.attacking: break
		await physics_frame
	if not game.guardian.combat.attacking: failures.append("guardian natural windup absent"); return
	game._set_paused(true); await _shot(phase+"-guardian-windup")
	if not game.player_placeholder.movement_buttons.is_empty(): failures.append("held keys at checkpoint")

func _live_aim() -> void:
	# Pausing intentionally hides aim via clear_input(). Capture its real live state,
	# separately from the pause-only manifest consumed by capture_evidence.py.
	var label: String = phase+"-live-aim"
	var checked: Dictionary = TestRunEvidence.validate(TestRunEvidence.directory(),label+".png")
	if not checked.ok: failures.append(str(checked.error)); return
	if paused or not game.window_focused or not game.player_placeholder.controls_enabled or root.gui_get_focus_owner() != null or not game.player_placeholder.aim_marker.visible:
		failures.append("live aim preflight"); return
	var began: int = Time.get_ticks_msec()
	for frame: int in range(4): await process_frame
	await RenderingServer.frame_post_draw
	if paused or not game.window_focused or not game.player_placeholder.controls_enabled or root.gui_get_focus_owner() != null or not game.player_placeholder.aim_marker.visible:
		failures.append("live aim changed during settling"); return
	var image: Image = root.get_texture().get_image()
	var aim_pixels: int = 0
	var pointer: Vector2 = game.player_placeholder.pointer_position
	for y: int in range(maxi(0,int(pointer.y)-12),mini(image.get_height(),int(pointer.y)+13)):
		for x: int in range(maxi(0,int(pointer.x)-12),mini(image.get_width(),int(pointer.x)+13)):
			var pixel: Color = image.get_pixel(x,y)
			if pixel.r < .5 and pixel.g > .8 and pixel.b > .7: aim_pixels += 1
	if aim_pixels < 3: failures.append("live aim ring occluded in actual pixels"); return
	var path: String = checked.directory.path_join(label+".png")
	if FileAccess.file_exists(path) or image.save_png(path) != OK: failures.append("live aim PNG"); return
	live_views.append({"label":label,"path":path,"kind":"debug-input","mode":"live-aim","paused":false,"window_focused":true,"controls_enabled":true,"focus":"","aim_visible":true,"aim_ring_pixels":aim_pixels,"settled_frames":4,"frame_post_draw_verified":true,"started_ticks_msec":began,"ticks_msec":Time.get_ticks_msec(),"engine_pid":OS.get_process_id(),"viewport_size":[image.get_width(),image.get_height()],"camera":TestRunObservation.camera(game),"pointer":[game.player_placeholder.pointer_position.x,game.player_placeholder.pointer_position.y],"aim_feet":TestRunObservation.vector(game.player_placeholder.aim_marker.global_position),"hero_feet":TestRunObservation.vector(game.player_placeholder.global_position),"heading":TestRunObservation.vector(game.player_placeholder.visual_root.rotation),"note":"Live ordinary pointer/aim after synthetic lead/room setup; normal combat continues for four settling frames; next caller action verifies pause"})
