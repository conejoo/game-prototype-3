extends "res://tests/art_direction_baseline_render.gd"
## AD014 labeled frozen before/after views; actual indoor contact motion uses existing mover.
const PAINT: Script = preload("res://world/storybook_home_material.gd")
var room: MayorValeHome
var motion: Array[Dictionary] = []
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD014 requires renderer"); quit(1); return
	root.size = Vector2i(960,640)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED); Engine.max_fps = 0
	game = preload("res://app/game_root.tscn").instantiate(); root.add_child(game)
	if not (await game.world_host.transition_finished)[0]: failures.append("startup")
	game._set_paused(true); DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	if not game.world_host.request_transition("prototype-mayor-vale-home","mayor-vale-home-from-alderwake").is_empty(): failures.append("home request")
	if not (await game.world_host.transition_finished)[0]: failures.append("home arrival")
	room = game.world_host.current_location
	if not TestRunRoutines.contacts_match(game): failures.append("default scheduled contacts")
	for stop: Dictionary in [{"name":"entry","feet":[0,0,-2],"ally":[1,0,-2]},{"name":"archive","feet":[2,0,0],"ally":[2.3,0,-.8]},{"name":"bedroom","feet":[-3.5,0,.25],"ally":[-2.3,0,.25]},{"name":"parlor","feet":[-3,0,-6.75],"ally":[-2.7,0,-7.7]},{"name":"kitchen","feet":[4.5,0,-6.5],"ally":[3.8,0,-8.5]}]:
		_place(stop.feet,stop.ally)
		for ortho: bool in [true,false]:
			for zoom_value: float in [.8,1.15]:
				game.camera_rig.zoom_factor = zoom_value; game.camera_rig.set_orthographic(ortho); game.ui.show_camera(game.camera_rig.description())
				var label: String = "%s-%s-%d" % [stop.name,"ortho" if ortho else "perspective",roundi(zoom_value*100)]
				await _shot(label+"-painted"); _original(true); await _shot(label+"-original"); _original(false)
	# Same paused contact/camera, clear day -> storm night. Only HUD forecast should differ.
	_place([2,0,0],[2.3,0,-.8]); game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(true); game.ui.show_camera(game.camera_rig.description())
	for night: bool in [false,true]:
		game.session.environment.day_index = 2
		game.session.environment.day_cycle_progress = .625 if night else .05
		for seed: int in range(10000):
			var weather: WeatherSchedule.Sample = WeatherSchedule.new().sample(seed,2,game.session.environment.day_cycle_progress)
			if weather.condition == (WeatherSchedule.Condition.THUNDERSTORM if night else WeatherSchedule.Condition.SUNNY) and weather.transition_progress == 1: game.session.environment.weather_seed = seed; break
		game._present_environment(); await _shot("indoor-storm-night" if night else "indoor-clear-day")
		if game.environment_presenter.profile != 0 or not room.find_children("WorldRain","",true,false).is_empty(): failures.append("indoor weather leaked")
	await _sample("home-painted-paused")
	# Diagnostic looks at existing whole cutaway from north/south and a close bookshelf.
	game.ui.visible = false; game.camera_rig.set_orthographic(true); game.camera_rig.camera.size = 23
	for angle: float in [0,90,180]:
		var target: Vector3 = Vector3(0,.3,-5)
		game.camera_rig.camera.global_position = target+Vector3(sin(deg_to_rad(angle))*18,20,cos(deg_to_rad(angle))*18)
		game.camera_rig.camera.look_at(target,Vector3.UP); await _shot("cutaway-surface-"+str(int(angle)))
	game.ui.visible = true
	await _contact_motion()
	var output: Dictionary = {"task":"AD014","views":views,"samples":samples,"motion":motion,"failures":failures,"pid":OS.get_process_id(),"engine":Engine.get_version_info(),"renderer":RenderingServer.get_current_rendering_method(),"user_data":OS.get_user_data_dir(),"kind":"synthetic direct room/feet/camera/time/seed and manual contact goal; unchanged production default contact/mover/animator. Separate routine_home_render owns ordinary public entry/return. No native/Save-Load/profile claim"}
	if not TestRunEvidence.write_json("home-painted-index.json",output): failures.append("index")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD014 home renders: ",views.size()," views; ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
func _original(on: bool) -> void:
	for visual: MeshInstance3D in room.find_children("*","MeshInstance3D",true,false):
		if visual.mesh is BoxMesh and visual.mesh.material is StandardMaterial3D:
			visual.material_override = null if on else PAINT.painted(visual.mesh.material.albedo_color,str(visual.get_parent().name),visual.position)
func _shot(label: String) -> void:
	var capture: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",false,"AD014 synthetic frozen room/feet/cameras/time/weather; original controls remove only home override; manual contact goal uses actual mover/physics. All pause checkpoints verified")
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
func _contact_motion() -> void:
	if not room.npc_contacts.targets.has("npc-02"): failures.append("actual Helena missing"); return
	_place([1.8,0,-2],[1,0,-2]); game.camera_rig.zoom_factor = 1; game.camera_rig.set_orthographic(true); game.ui.show_camera(game.camera_rig.description())
	await _shot("helena-stationary")
	game.set_process(false); game.player_placeholder.set_physics_process(false); game.companion.set_physics_process(false); game.companion_ai.set_physics_process(false)
	var adapter: NpcWorldAdapter = room.npc_contacts
	adapter.set_physics_process(false)
	adapter.presenters["npc-02"].cancel_action()
	var target: PrototypeInteractable = adapter.targets["npc-02"]
	var first: Vector3 = target.global_position
	var goal: Vector3 = room.find_anchor(room.location_id,"helena-archive-shelves").foot
	var ready: Dictionary = await TestRunJourney.wait_navigation(room,first)
	if not ready.ok or not adapter.move_to("npc-02",goal): failures.append("motion begin"); return
	for frame: int in range(160):
		game._set_paused(false)
		adapter._physics_process(1.0/60.0)
		await physics_frame
		game._set_paused(true)
		if frame in [15,35,65]:
			motion.append({"frame":frame,"foot":TestRunObservation.vector(target.global_position),"speed":adapter.movers["npc-02"].achieved_speed,"state":adapter.movers["npc-02"].state})
			await _shot("helena-motion-"+str(frame))
		if adapter.movers["npc-02"].state == RoutineMovement.State.ARRIVED: break
	if target.global_position.distance_to(first) < 1 or target.global_position.distance_to(goal) > .01: failures.append("actual achieved route endpoint")
	await _shot("helena-shelves-arrival")
