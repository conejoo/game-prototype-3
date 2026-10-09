extends "res://tests/support/fishing_root_fixture.gd"
## FS006 labeled synthetic poses/encounters/weather. Real live timers and GUI controls.
var views: Array[Dictionary] = []

func _exercise() -> void:
	task = "FS006"
	suite = "ui-render"
	_check(DisplayServer.get_name() != "headless","actual renderer")
	for dimensions: Vector2i in [Vector2i(960,640),Vector2i(1350,900)]:
		root.size = dimensions
		DisplayServer.window_set_size(dimensions)
		await process_frame
		for orthographic: bool in [true,false]:
			game.camera_rig.set_orthographic(orthographic)
			game.ui.show_camera(game.camera_rig.description())
			for lighting: String in ["day","night","rain"]:
				_weather(lighting)
				var prefix: String = "%d-%s-%s" % [dimensions.x,"ortho" if orthographic else "perspective",lighting]
				game.set_process(false)
				_cast()
				game.set_process(true)
				game._present_fishing()
				await _capture(prefix+"-waiting","waiting")
				if not failures.is_empty(): return
				var deadline: int = Time.get_ticks_msec()+6000
				while game.fishing.active() and game.fishing.snapshot().phase == "waiting" and Time.get_ticks_msec() < deadline: await process_frame
				_check(game.fishing.snapshot().phase == "bite","live automatic BITE " + prefix)
				await _capture(prefix+"-bite","bite")
				# Actual pointer button hook (no service callback invocation).
				_mouse(true,game.ui.fishing_view.reel_button)
				_check(game.fishing.snapshot().phase == "fighting","actual pointer fresh hook " + prefix)
				_mouse(false,null)
				await _capture(prefix+"-fight","fighting")
				if not failures.is_empty(): return
				_pointer(game.ui.fishing_view.cancel_button.get_global_rect().get_center())
				_click(game.ui.fishing_view.cancel_button.get_global_rect().get_center())
				_check(game.fishing.mode() == "idle" and not game.fishing_effects.visible,"actual pointer Cancel " + prefix)
				_key(KEY_ESCAPE)
				_check(paused and game.ui.pause_overlay.visible,"verified pause before scenario reset " + prefix)
				var resumed: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
				_check(resumed.ok,resumed.get("error","GUI Resume"))
	root.size = Vector2i(960,640)
	DisplayServer.window_set_size(root.size)
	game.camera_rig.set_orthographic(true)
	game.ui.show_camera(game.camera_rig.description())
	_weather("day")
	game.set_process(false)
	_phase("fighting")
	game._tick_fishing(.2)
	game.set_process(true)
	await _capture("warning-tight","fighting")
	_check(game.ui.fishing_view.tension_text.text.contains("WARNING"),"captured warning zone is still warning")
	game.set_process(false)
	_phase("fighting")
	game._tick_fishing(.6)
	game.set_process(true)
	await _capture("danger-tight","fighting")
	_check(game.ui.fishing_view.tension_text.text.contains("DANGER"),"captured danger zone")
	game._cancel_fishing("explicit")
	await _capture("result-canceled","result")
	if not failures.is_empty(): return
	for outcome: String in ["no_bite","early_reel","missed_hook","line_slack","line_snapped","exhausted","landed"]:
		game.set_process(false)
		_cast()
		if outcome == "no_bite":
			game._cancel_fishing("fixture miss")
			var target: Vector3 = Vector3(-4.75,.015,20.25)
			game._fishing_rng.seed = _seed("",target)
			_key(KEY_F)
			_click(game.camera_rig.camera.unproject_position(target))
			game._tick_fishing(game.fishing.snapshot().wait_seconds)
		elif outcome == "early_reel":
			_mouse(true,game.ui.fishing_view.reel_button)
			_mouse(false,null)
		elif outcome == "missed_hook": game._tick_fishing(game.fishing.snapshot().wait_seconds+1.2)
		elif outcome == "landed": _land()
		else:
			game._tick_fishing(game.fishing.snapshot().wait_seconds)
			_key(KEY_E,true)
			if outcome == "line_slack": _key(KEY_E,false)
			if outcome == "exhausted":
				_key(KEY_E,false)
				for step: int in range(1100):
					if not game.fishing.active(): break
					var tension: float = game.fishing.snapshot().tension
					if tension <= .23 and not game._e_down: _key(KEY_E,true)
					elif tension >= .25 and game._e_down: _key(KEY_E,false)
					game._tick_fishing(.005)
			else: game._tick_fishing(3)
		_key(KEY_E,false)
		_check(game.fishing.snapshot().outcome == outcome,"real terminal provenance " + outcome + " " + str(game.fishing.snapshot()))
		game.set_process(true)
		game._present_fishing()
		await _capture("result-"+outcome,"result")
		if not failures.is_empty(): return
	for outcome: String in ["capacity","stale_reward"]:
		game.set_process(false)
		_commit_rejection(outcome)
		game.set_process(true)
		await _capture("result-"+outcome,"result")
		if not failures.is_empty(): return
	game.session.inventory.consume("item-bluegill",game.session.inventory.count("item-bluegill"))
	# Species readability and selection in the existing bag (labeled legal fixtures).
	for id: String in FISH:
		game.set_process(false)
		_cast(id)
		_land()
		game.set_process(true)
		_key(KEY_B)
		game._select_inventory_item(id)
		var bag: Dictionary = await TestRunInteractionCapture.backpack(game,"bag-"+id,TestRunEvidence.directory(),"synthetic","Legal deterministic encounter/feedback landed fish; actual B bag with existing selection. No ordinary RNG or native claim.")
		_check(bag.ok,bag.get("error","bag"))
		if bag.ok: views.append(bag)
		else: return
		_key(KEY_B)
	game.set_process(false)
	_cast()
	game._cancel_fishing("fixture capacity")
	game.session.inventory.add("item-bluegill",99-game.session.inventory.count("item-bluegill"))
	var target: Vector3 = Vector3(-4.75,.015,20.25)
	game._fishing_rng.seed = _seed("item-bluegill",target)
	_key(KEY_F)
	_click(game.camera_rig.camera.unproject_position(target))
	_check(game.fishing.snapshot().outcome == "capacity" and not game.fishing.active(),"real pre-cast capacity feedback")
	game.set_process(true)
	await _capture("capacity-not-started","targeting")
	game._cancel_fishing("fixture invalid")
	_key(KEY_F)
	_click(game.camera_rig.camera.unproject_position(Vector3(-7,0,18)))
	await _capture("invalid-dry-cast","targeting")
	game._cancel_fishing("fixture no area")
	_pose(Vector3(-7,0,18))
	_key(KEY_F)
	_click(game.camera_rig.camera.unproject_position(Vector3(-12.75,.015,20.25)))
	_check(game.fishing.mode() == "targeting" and game._fishing_feedback.contains("No fishing area"),"audited no-area target does not start an attempt")
	await _capture("no-area-feedback","targeting")
	if not failures.is_empty(): return
	game._cancel_fishing("entry failure fixture")
	game.session.inventory.select(null)
	_key(KEY_F)
	_check(game.fishing.snapshot().outcome == "rod_required","actual F without selected rod")
	await _capture("rod-required","result")
	game.session.inventory.select(ForagingRegistry.ROD_ITEM)
	var errors: PackedStringArray = game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
	_check(errors.is_empty(),"legal synthetic room transition for unsupported-map feedback")
	if not errors.is_empty(): return
	var arrived: Array = await game.world_host.transition_finished
	_check(arrived[0],"actual Tollworks arrival")
	await physics_frame
	_key(KEY_F)
	_check(game.fishing.snapshot().outcome == "invalid_map" and game.fishing.mode() == "idle","actual F rejects indoor map")
	await _capture("invalid-map","result")
	errors = game.world_host.request_transition("prototype-alderwake","alderwake-from-tollworks")
	_check(errors.is_empty(),"legal synthetic return")
	if not errors.is_empty(): return
	arrived = await game.world_host.transition_finished
	_check(arrived[0],"actual exterior return")
	await physics_frame
	# Shared live capture must refuse a bite which expires while four frames settle.
	game.set_process(false)
	game._cancel_fishing("late bite fixture")
	game.session.inventory.consume("item-bluegill",game.session.inventory.count("item-bluegill"))
	_phase("bite")
	game._tick_fishing(1.19)
	game.set_process(true)
	game._present_fishing()
	var denied: Dictionary = await TestRunInteractionCapture.fishing(game,"expired-bite-refused",TestRunEvidence.directory(),"synthetic","Negative: legal synthetic bite at 1.19s must expire during automatic capture settling.","bite")
	_check(not denied.ok and not FileAccess.file_exists(TestRunEvidence.directory().path_join("expired-bite-refused.png")),"expired live phase refused without PNG")
	rows.append({"negative":"expired bite capture","result":denied})
	_key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible and not game.ui.fishing_view.visible and not game.fishing_effects.visible,"final verified pause hides all fishing effects/HUD")
	var final: Dictionary = await TestRunCapture.capture(game,"final-paused",TestRunEvidence.directory(),"synthetic",true,"Actual Esc canceled targeting and verified pause; no active-phase claim.")
	_check(final.ok,final.get("error","final pause"))
	if final.ok: views.append(final)
	_check(TestRunEvidence.write_json("fishing-ui-render-index.json",{"task":"FS006","proof":"synthetic encounter/pose/weather fixtures; actual public pointer controls and automatically advancing live phases/results; no ordinary/native catch claim","views":views,"failures":failures,"assertions":assertions+1}),"render index")

func _capture(label: String, phase: String) -> void:
	game._present_fishing()
	var captured: Dictionary = await TestRunInteractionCapture.fishing(game,label,TestRunEvidence.directory(),"synthetic","Synthetic pose/seed/weather or legal terminal trajectory; real root phase with automatic world/challenge time during capture, no pause/time freeze.",phase)
	_check(captured.ok,captured.get("error",label))
	if captured.ok: views.append(captured)

func _commit_rejection(outcome: String) -> void:
	# Isolated dispatch fixture: legal private controller trajectory, then actual
	# binding/capacity invalidation before consuming its verified result. No runtime
	# forcing API and no invented presentation snapshot; same FS005 commit boundary.
	_cast()
	var service: FishingSessionService = game.fishing
	var ctrl: FishingChallengeController = service._controller
	var state: FishingChallengeController.Snapshot = ctrl.snapshot()
	ctrl.update(state.wait_seconds,false,service._generation,state.attempt_token)
	var generation: int = service._generation+1
	ctrl.update(0,true,generation,state.attempt_token)
	var held: bool = true
	var resolution: FishingChallengeController.Resolution
	for step: int in range(1500):
		state = ctrl.snapshot()
		var next: bool = state.tension <= .48 or (held and state.tension < .52)
		if next and not held: generation += 1
		held = next
		var updated: FishingChallengeController.CommandResult = ctrl.update(.005,held,generation,state.attempt_token)
		if updated.resolution != null:
			resolution = updated.resolution
			break
	_check(resolution != null and resolution.outcome == "landed","legal verified rejection trajectory")
	if resolution == null: return
	service._pending = resolution
	if outcome == "capacity": game.session.inventory.add("item-bluegill",99-game.session.inventory.count("item-bluegill"))
	else: game.session.inventory.select(null)
	var facts: String = _facts()
	var result: FishingSessionService.Result = service.complete(resolution,game.session,game.world_host.current_location,game.catalog)
	game._publish_fishing(result)
	_check(result.accepted and result.outcome == outcome and not result.rewarded and _facts() == facts,"actual rejection terminal " + outcome)
	game.session.inventory.consume("item-bluegill",game.session.inventory.count("item-bluegill"))
	game.session.inventory.select(ForagingRegistry.ROD_ITEM)
	game._update_controls()

func _weather(lighting: String) -> void:
	game.session.environment.day_index = 1 if lighting == "rain" else 0
	game.session.environment.day_cycle_progress = .625 if lighting == "night" else .25
	# Search only weather fixture identity, never fishing luck.
	for seed_value: int in range(10000):
		game.session.environment.weather_seed = seed_value
		var sample: WeatherSchedule.Sample = game.session.environment.weather_sample()
		if (sample.has_rain()) == (lighting == "rain"): break
	game._present_environment()
	_check((game.session.environment.weather_sample().has_rain()) == (lighting == "rain"),"synthetic weather " + lighting)

func _mouse(down: bool, button: Button) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = button.get_global_rect().get_center() if button != null else Vector2(30,300)
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	_pointer(event.position)
	root.push_input(event,true)
