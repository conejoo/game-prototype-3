extends "res://tests/backpack_ui_render.gd"
## Synthetic paused pose/clock/presentation matrix. Ordinary routes run separately.
var assertions: int = 0
const APPROACHES: Dictionary = {"fishing-rod-dock-01":Vector3(-6.5,0,15),"moonflower-01":Vector3(27.5,.25,-2),"moonflower-02":Vector3(34.75,.25,7),"moonflower-03":Vector3(30.75,.5,-9)}

func _run() -> void:
	phase = "art"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await _pause()
	var room: PrototypeLocation = game.world_host.current_location
	for id: String in APPROACHES:
		var pickup: PrototypeInteractable = room.foraging_pickups.targets[id]
		var visual: ForagingItemVisual = pickup.get_node("VisualRoot")
		_check(visual.find_children("*","CollisionObject3D",true,false).is_empty(),"visual nonblocking " + id)
		var bottom: float = INF
		var top: float = -INF
		for part: Node in visual.get_children():
			if not part is MeshInstance3D: continue
			var mesh_part: MeshInstance3D = part as MeshInstance3D
			var box: AABB = mesh_part.get_aabb()
			for index: int in range(8):
				var point: Vector3 = mesh_part.transform * box.get_endpoint(index)
				bottom = minf(bottom,point.y)
				top = maxf(top,point.y)
				if pickup.kind == "pickup": _check(absf(point.x) <= .5 and absf(point.z) <= .22 and point.y >= .0299 and point.y <= .1701,"rod inside validated clearance " + part.name)
		_check(bottom >= -.001 and bottom <= .04,"grounded visual " + id)
		_check(top >= .1299 and top <= .51,"bounded height " + id)
		_check(visual.has_node("Petal4") if pickup.kind == "gather" else visual.has_node("Reel"),"recognizable parts " + id)
		game.player_placeholder.global_position = APPROACHES[id]
		game.companion.global_position = APPROACHES[id] + Vector3(2,0,2)
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		game.camera_rig._process(0)
		for ortho: bool in [true,false]:
			for zoom_value: float in [1.0,1.15,.8]:
				game.camera_rig.zoom_factor = zoom_value
				game.camera_rig.set_orthographic(ortho)
				game.ui.show_camera(game.camera_rig.description())
				for condition: String in ["day","night","rain"]:
					_force_condition(2 if condition == "rain" else 0,.625 if condition == "night" else 0.0)
					game._refresh_interaction()
					_check(game.selected_interaction == pickup,"unobscured reachable prompt " + id)
					game.ui.travel_label.visible = true
					game.ui.show_foraging_progress(.45,true)
					# Explicit paused presentation samples, never claims active live hold/error.
					game.ui.foraging_notice.text = "Backpack full — pickup kept in place." if condition == "rain" else "Gather cancelled · Pickup stays in place. Press E again to retry." if condition == "night" else "Gathered moonflower." if pickup.kind == "gather" else "Picked up fishing rod."
					game.ui.foraging_notice.visible = true
					var label: String = "%s-%s-%s-zoom%s" % [id,condition,"ortho" if ortho else "perspective",str(zoom_value).replace(".","-")]
					var capture: Dictionary = await TestRunCapture.capture(game,label,directory,"synthetic",false,"F008 paused clock/seed/pose fixture with progress/feedback presentation samples; ordinary routes tested separately")
					_check(capture.ok,capture.get("error","art capture"))
					if capture.ok:
						capture["item_id"] = id
						capture["feedback_sample"] = game.ui.foraging_notice.text
						capture["progress_sample"] = game.ui.gather_progress.value
						capture["screen_item"] = TestRunObservation.vector(pickup.global_position)
						views.append(capture)
					var viewport: Rect2 = root.get_visible_rect()
					for control: Control in [game.ui.travel_label,game.ui.foraging_notice,game.ui.gather_progress]:
						_check(viewport.encloses(control.get_global_rect()),"UI in viewport " + label)
					_check(not game.ui.travel_label.get_global_rect().intersects(game.ui.foraging_notice.get_global_rect()),"prompt/feedback separate " + label)
					_check(not game.ui.gather_progress.get_global_rect().intersects(game.ui.get_node("Screen/Footer").get_global_rect()),"progress/footer separate " + label)
					_check(not game.ui.travel_label.get_global_rect().intersects(game.ui.combat_label.get_global_rect()) and not game.ui.foraging_notice.get_global_rect().intersects(game.ui.combat_label.get_global_rect()),"health/prompt/feedback separate " + label)
					var screen: Vector2 = game.camera_rig.camera.unproject_position(pickup.global_position + Vector3.UP*.3)
					_check(viewport.has_point(screen) and not game.ui.foraging_notice.get_global_rect().has_point(screen) and not game.ui.travel_label.get_global_rect().has_point(screen),"item outside UI " + label)
	game.ui.show_foraging_progress(0,false)
	game.ui.show_foraging_feedback("")
	await _live_matrix()
	_check(ForagingItemVisual.icon(ForagingRegistry.ROD_ITEM).get_size() == Vector2(40,40) and ForagingItemVisual.icon("item-moonflower").get_size() == Vector2(40,40),"local icon imports")
	_check(ForagingItemVisual.icon("unknown") == null,"test-only types no misleading icon")
	_check(TestRunEvidence.write_json("art-index.json",{"task":"F008","kind":"synthetic pose/clock fixtures: paused art/presentation samples plus actual live hold/cancel/drag; no ordinary-route claim","assertions":assertions+1,"views":views,"failures":failures}),"write art evidence")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F008 art matrix ","PASS" if failures.is_empty() else "FAIL","; assertions=",assertions,"; captures=",views.size())
	quit(0 if failures.is_empty() else 1)

func _force_condition(condition: int, progress: float) -> void:
	_check(paused and game.ui.pause_overlay.visible,"synthetic setup at pause")
	game.session.environment.day_index = 2
	game.session.environment.day_cycle_progress = progress
	for seed: int in range(10000):
		var schedule: WeatherSchedule = WeatherSchedule.new()
		var forecast: WeatherSchedule.Sample = schedule.sample(seed,2,progress)
		if forecast.condition == condition and forecast.transition_progress == 1.0:
			game.session.environment.weather_seed = seed
			game._present_environment()
			return
	_check(false,"condition seed unavailable")

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)

func _live_matrix() -> void:
	var rod: PrototypeInteractable = game.world_host.current_location.foraging_pickups.targets[ForagingRegistry.ROD_ORIGIN]
	for ortho: bool in [true,false]:
		for condition: String in ["day","night","rain"]:
			game.player_placeholder.global_position = APPROACHES[ForagingRegistry.ROD_ORIGIN]
			game.companion.global_position = Vector3(-5.5,0,14)
			game.player_placeholder.reset_physics_interpolation()
			game.companion.reset_physics_interpolation()
			game.camera_rig._process(0)
			game.camera_rig.zoom_factor = 1.0
			game.camera_rig.set_orthographic(ortho)
			game.ui.show_camera(game.camera_rig.description())
			_force_condition(2 if condition == "rain" else 0,.625 if condition == "night" else 0.0)
			var before: String = TestRunSnapshot.exact_json(game.session.foraging.snapshot())
			await _resume()
			game._refresh_interaction()
			var prefix: String = "live-%s-%s" % [condition,"ortho" if ortho else "perspective"]
			_key(KEY_E,true)
			await create_timer(.08).timeout
			var capture: Dictionary = await TestRunInteractionCapture.hold(game,prefix + "-hold",directory,"synthetic","Actual live viewport E hold; synthetic preceding dock pose/seed/clock; no reward setup")
			_check(capture.ok,capture.get("error","live hold capture"))
			if capture.ok: views.append(capture)
			_key(KEY_E,false)
			capture = await TestRunInteractionCapture.hold(game,prefix + "-cancel",directory,"synthetic","Actual E release cancels hold; synthetic preceding dock pose/seed/clock",false)
			_check(capture.ok,capture.get("error","live cancel capture"))
			if capture.ok: views.append(capture)
			_check(game.ui.foraging_notice.visible and game.ui.foraging_notice.text.begins_with("Gather cancelled"),"live cancel feedback " + prefix)
			for valid: bool in [true,false]:
				var start: Vector2 = game.camera_rig.camera.unproject_position(rod.global_position + Vector3.UP*.08)
				_mouse(start,true)
				var destination: Vector3 = Vector3(-6.5,0,15.55) if valid else Vector3(-8,0,15.75)
				var end: Vector2 = game.camera_rig.camera.unproject_position(destination)
				_motion(end)
				_check(game.item_drag.active() and game.item_drag.errors.is_empty() == valid,"live preview validity " + prefix)
				capture = await TestRunInteractionCapture.drag(game,prefix + ("-green" if valid else "-red"),directory,"synthetic","Actual live pointer preview; synthetic preceding dock pose/seed/clock; original unchanged")
				_check(capture.ok,capture.get("error","live drag capture"))
				if capture.ok: views.append(capture)
				_check(game.ui.travel_label.text.begins_with("Place rod" if valid else "Cannot place here"),"color-independent preview text " + prefix)
				if valid:
					_key(KEY_ESCAPE,true)
					_key(KEY_ESCAPE,false)
				_mouse(end,false)
				_check(TestRunSnapshot.exact_json(game.session.foraging.snapshot()) == before,"cancel/invalid release retains exact item facts " + prefix)
			await _pause()

func _motion(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	root.push_input(event,true)

func _mouse(point: Vector2,down: bool) -> void:
	_motion(point)
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event,true)
