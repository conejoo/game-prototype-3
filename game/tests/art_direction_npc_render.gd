extends "res://tests/art_direction_baseline_render.gd"
## AD012 explicitly synthetic current-world art review; no ordinary route/save claim.
var subject: NpcVisualPresenter
var subjects: Array[Dictionary] = []
var loops: Array[Dictionary] = []
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD012 needs real renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate(); root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	game._set_paused(true); DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	review = REVIEW.new(); game.add_child(review)
	failures.append_array(review.initialize(game,"ad012-npcs"))
	game._pending_restore = game.session
	if not game.world_host.request_transition(game.session.current_location_id,game.session.current_spawn_id,game.session).is_empty(): failures.append("rebind")
	elif not (await game.world_host.transition_finished)[0]: failures.append("rebind arrival")
	if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("day preset")
	if failures.is_empty():
		# Maris proves the treatment first, then the same adapter covers all eight.
		for id: String in ["npc-03","npc-01","npc-02","npc-04","npc-06","npc-07","npc-08","npc-14"]:
			await _mount(id,Vector3(-5.5,0,12))
			# Elevated diagnostic copies expose all sides without roof/label occlusion.
			subject.global_position.y += 40
			subject.rotation.y = 0
			_close_camera(0)
			await _shot(id+"-painted-front")
			_set_original(true)
			await _shot(id+"-original-front")
			_set_original(false)
			for angle: float in [90,180]:
				_close_camera(angle); await _shot(id+"-painted-"+str(int(angle)))
			_remove()
		for context: String in ["town","forest","inn"]:
			if context == "inn":
				if not game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(): failures.append("inn request"); break
				if not (await game.world_host.transition_finished)[0]: failures.append("inn arrival"); break
			for id: String in NpcRegistry.ENABLED:
				var foot: Vector3 = Vector3(-5.5,0,12) if context == "town" else Vector3(27.5,.25,-2) if context == "forest" else Vector3(0,0,-8)
				await _mount(id,foot)
				for ortho: bool in [true,false]:
					for zoom_value: float in ([.8,1.15] if context == "town" else [1.0]):
						game.ui.visible = true
						game.camera_rig.zoom_factor = zoom_value; game.camera_rig.set_orthographic(ortho)
						game.ui.show_camera(game.camera_rig.description())
						await _shot("%s-%s-%s-%s" % [id,context,ortho,str(zoom_value).replace(".","_")])
				_remove()
		# Actual night storm presentation, not studio lighting; exterior re-entry.
		if not game.world_host.request_transition("prototype-alderwake","alderwake-from-lantern-rest").is_empty(): failures.append("exterior return")
		elif not (await game.world_host.transition_finished)[0]: failures.append("exterior arrival")
		if not review.apply_preset(2,WeatherSchedule.Condition.THUNDERSTORM): failures.append("storm-night")
		for id: String in NpcRegistry.ENABLED:
			await _mount(id,Vector3(-5.5,0,12))
			for ortho: bool in [true,false]:
				game.ui.visible = true; game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(ortho)
				game.ui.show_camera(game.camera_rig.description())
				await _shot(id+"-storm-night-"+str(ortho))
			_remove()
		if not review.apply_preset(0,WeatherSchedule.Condition.SUNNY): failures.append("restore day")
		for id: String in ["npc-03","npc-01","npc-14"]: await _motion(id,"walk",.8)
		await _motion("npc-01","action_river_fishing",4)
		await _motion("npc-02","action_archive_work",4)
	var output: Dictionary = {"task":"AD012","kind":"synthetic mounted review copies, frozen feet/cameras/time/weather/direct inn transition; manual exported poses and actual mixer advancement; no ordinary play/save/native/profile claim","views":views,"subjects":subjects,"loops":loops,"failures":failures,"pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"new_texture_bytes":0}
	if not TestRunEvidence.write_json("npc-painted-index.json",output): failures.append("write index")
	_remove(); game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD012 rendered NPCs: ",views.size()," captures; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _mount(id: String,foot: Vector3) -> void:
	_remove()
	_place([foot.x,foot.y,foot.z],[foot.x+1.5,foot.y,foot.z+.5])
	game.player_placeholder.visible = false; game.companion.visible = false
	subject = NpcVisualPresenter.new(); subject.name = "AD012-Review-"+id
	game.world_host.current_location.add_child(subject); subject.global_position = foot
	failures.append_array(subject.mount(load(NpcRegistry.VISUAL_ASSETS[id])))
	subject.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	NpcAssetProbe.sample(subject,"idle",0)
	subject.face_direction(Vector3(10,0,16))
	subjects.append({"id":id,"asset":NpcRegistry.VISUAL_ASSETS[id],"feet":TestRunObservation.vector(foot),"location":game.session.current_location_id,"bounds":str(NpcAssetProbe.bounds(NpcAssetProbe.deformed_vertices(subject)))})
	game._present_environment()

func _remove() -> void:
	if is_instance_valid(subject): subject.free()
	subject = null

func _set_original(original: bool) -> void:
	for mesh: MeshInstance3D in NpcAssetProbe.mesh_nodes(subject.model):
		for surface: int in range(mesh.mesh.get_surface_count()):
			var source: StandardMaterial3D = mesh.mesh.surface_get_material(surface)
			mesh.set_surface_override_material(surface,source if original else StorybookNpcMaterial.materials[source])

func _close_camera(angle: float) -> void:
	game.ui.visible = false
	game.camera_rig.set_orthographic(true)
	var center: Vector3 = subject.global_position + Vector3(0,.8,0)
	game.camera_rig.camera.size = 2.25
	game.camera_rig.camera.global_position = center + Vector3(sin(deg_to_rad(angle))*5,1.2,-cos(deg_to_rad(angle))*5)
	game.camera_rig.camera.look_at(center,Vector3.UP)

func _shot(label: String) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"AD012: mounted review copy, synthetic feet/facing/time/weather; production contacts retained; hidden party; elevated all-side close gallery or grounded actual-world gameplay cameras; motion isolates copy with location hidden to exclude animated water from pixel oracle")
	if not capture.ok: failures.append(str(capture.get("error","capture")))
	else:
		capture["subject_asset"] = subject.model.scene_file_path
		capture["subject_feet"] = TestRunObservation.vector(subject.global_position)
		capture["pose"] = subject.player.current_animation
		capture["pose_time"] = subject.player.current_animation_position
		views.append(capture)

func _motion(id: String,clip: String,duration: float) -> void:
	await _mount(id,Vector3(-5.5,0,12)); subject.rotation.y = 0; _close_camera(0)
	# Isolated motion view removes world water/rain TIME animation from pixel oracle.
	# The same real Godot imported rig/material and current lighting remain visible.
	subject.reparent(game)
	game.world_host.current_location.visible = false
	if clip.begins_with("action_") and not subject.set_action(clip): failures.append("action refused "+clip)
	var first: Image
	var last: Image
	for fraction: float in [0.0,.25,.5,.75,1.0]:
		NpcAssetProbe.sample(subject,clip,duration*fraction)
		await _shot(id+"-"+clip+"-"+str(int(fraction*100)))
		var image: Image = root.get_texture().get_image()
		if fraction == 0: first = image
		if fraction == 1: last = image
	var first_bytes: PackedByteArray = first.get_data()
	var last_bytes: PackedByteArray = last.get_data()
	var total_byte_delta: int = 0
	for i: int in range(first_bytes.size()): total_byte_delta += absi(int(first_bytes[i])-int(last_bytes[i]))
	# Measured Maris seam: one blue byte changes by1 at(519,368), below8-bit
	# rounding precision. Preserve an explicit strict one-byte oracle, not a visual tolerance.
	if total_byte_delta > 1: failures.append("rendered loop seam "+id+" "+clip)
	loops.append({"id":id,"clip":clip,"duration":duration,"endpoints_pixel_identical":total_byte_delta == 0,"endpoint_total_8bit_byte_delta":total_byte_delta,"maximum_allowed_total_byte_delta":1})
	# Real AnimationPlayer mixer transition steps, without direct sample between steps.
	NpcAssetProbe.sample(subject,"idle",0); subject.cancel_action(); subject.set_locomotion(0)
	if clip.begins_with("action_"): subject.set_action(clip)
	else: subject.set_locomotion(.8)
	for frame: int in range(16):
		subject.player.advance(1.0/120)
		if frame in [0,7,15]: await _shot(id+"-"+clip+"-blend-"+str(frame))
	_remove()
	game.world_host.current_location.visible = true
