extends "res://tests/art_direction_baseline_render.gd"
## AD015 labeled frozen before/after views; default scheduled host remains present.
const PAINT: Script = preload("res://world/storybook_inn_material.gd")
var room: LanternRest
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD015 requires renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED); Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate(); root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	game._set_paused(true); DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	if not game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(): failures.append("inn request")
	if not (await game.world_host.transition_finished)[0]: failures.append("inn arrival")
	room = game.world_host.current_location
	if not TestRunRoutines.contacts_match(game): failures.append("default scheduled contacts")
	for stop: Dictionary in [{"name":"entry","feet":[0,0,0],"ally":[1,0,0]},{"name":"host-meals","feet":[-6,0,-10.8],"ally":[-4.8,0,-10.5]},{"name":"lounge","feet":[-7,0,-5],"ally":[-5.8,0,-4]},{"name":"breakfast","feet":[6,0,-4],"ally":[7.2,0,-3]},{"name":"guest-desk","feet":[4,0,-12],"ally":[5,0,-11.8]},{"name":"kitchen","feet":[-8,0,-16],"ally":[-7,0,-16]},{"name":"guest-bed","feet":[5.3,0,-15],"ally":[5.3,0,-16.2]}]:
		_place(stop.feet,stop.ally)
		for ortho: bool in [true,false]:
			for zoom_value: float in [.8,1.15]:
				game.camera_rig.zoom_factor = zoom_value; game.camera_rig.set_orthographic(ortho); game.ui.show_camera(game.camera_rig.description())
				var label: String = "%s-%s-%d" % [stop.name,"ortho" if ortho else "perspective",roundi(zoom_value*100)]
				await _shot(label+"-painted"); _original(true); await _shot(label+"-original"); _original(false)
	# Same paused contact/camera, clear day -> storm night. Only HUD forecast should differ.
	_place([-6,0,-10.8],[-4.8,0,-10.5]); game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(true); game.ui.show_camera(game.camera_rig.description())
	for night: bool in [false,true]:
		game.session.environment.day_index = 2
		game.session.environment.day_cycle_progress = .625 if night else .05
		for seed: int in range(10000):
			var weather: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed,2,game.session.environment.day_cycle_progress)
			if weather.condition == (WeatherSchedule.Condition.THUNDERSTORM if night else WeatherSchedule.Condition.SUNNY) and weather.transition_progress == 1: game.session.environment.weather_seed = seed; break
		game._present_environment(); await _shot("indoor-storm-night" if night else "indoor-clear-day")
		if game.environment_presenter.profile != 0 or not room.find_children("WorldRain","",true,false).is_empty(): failures.append("indoor weather leaked")
	await _sample("inn-painted-paused")
	# Diagnostic looks at existing whole cutaway from north/south and guest furniture.
	game.ui.visible = false; game.camera_rig.set_orthographic(true); game.camera_rig.camera.size = 32
	for angle: float in [0,90,180]:
		var target: Vector3 = Vector3(0,.3,-10)
		game.camera_rig.camera.global_position = target+Vector3(sin(deg_to_rad(angle))*18,20,cos(deg_to_rad(angle))*18)
		game.camera_rig.camera.look_at(target,Vector3.UP); await _shot("cutaway-surface-"+str(int(angle)))
	game.ui.visible = true
	var output: Dictionary = {"task":"AD015","views":views,"samples":samples,"failures":failures,"pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"kind":"synthetic direct room/feet/camera/time/seed; unchanged production default contact/mover/animator. Separate art_direction_inn_journey_render owns ordinary public entry/return. No native/Save-Load/profile claim"}
	if not TestRunEvidence.write_json("inn-painted-index.json",output): failures.append("index")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD015 inn renders: ",views.size()," views; ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
func _original(on: bool) -> void:
	for visual: MeshInstance3D in room.find_children("*","MeshInstance3D",true,false):
		if visual.mesh is BoxMesh and visual.mesh.material is StandardMaterial3D:
			visual.material_override = null if on else PAINT.painted(visual.mesh.material.albedo_color,str(visual.get_parent().name),visual.position)
func _shot(label: String) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"AD015 synthetic frozen room/feet/cameras/time/weather; original controls remove only inn override. All pause checkpoints verified")
	if not capture.ok: failures.append(str(capture.get("error","capture"))); return
	capture["ally"] = TestRunObservation.vector(game.companion.global_position)
	capture["camera_transform"] = str(game.camera_rig.camera.global_transform)
	capture["sun"] = {"transform":str(game.get_node("Sun").transform),"energy":game.get_node("Sun").light_energy}
	capture["contacts"] = {}
	for id: String in room.npc_contacts.targets:
		var target: PrototypeInteractable = room.npc_contacts.targets[id]
		var screen: Vector2 = game.camera_rig.camera.unproject_position(target.global_position+Vector3(0,.8,0))
		capture.contacts[id] = {"foot":TestRunObservation.vector(target.global_position),"screen":[screen.x,screen.y],"clip":room.npc_contacts.presenters[id].player.assigned_animation,"cursor":room.npc_contacts.presenters[id].player.current_animation_position,"speed":room.npc_contacts.movers[id].achieved_speed}
	views.append(capture)
