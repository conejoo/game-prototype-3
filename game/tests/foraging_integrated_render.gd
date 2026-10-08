extends "res://tests/world_item_placement_render.gd"
## F009 ordinary integrated journey; no pose, reward, environment or save setup.
var restart_errors: PackedStringArray = []

func _run() -> void:
	phase = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	var oracle_path: String = ProjectSettings.globalize_path(game.save_repository.path + ".f009-oracle")
	_check(game.session.inventory.snapshot().item_counts.is_empty() and game.world_host.current_location.foraging_pickups.targets.size() == 4,"fresh four origins/empty bag")
	await _pause()
	await _capture("fresh-start",true)
	if phase == "write":
		await _resume()
		var start: Vector3 = game.player_placeholder.position
		_key(KEY_D,true)
		for frame: int in range(15): await physics_frame
		_key(KEY_D,false)
		_check(game.player_placeholder.position.distance_to(start) > .1,"ordinary movement preflight")
		if await _walk(Vector3(-6.5,0,15),"integrated-rod"):
			_key(KEY_E,true)
			await create_timer(.12).timeout
			await _capture_live("rod-held",true)
			_tap(KEY_B)
			_check(game.backpack_open and not game.foraging_hold.active(),"ordinary backpack cancels held attempt")
			await _bag_capture("empty-cancelled","debug-input","Ordinary E then B cancellation at rod; no reward")
			_tap(KEY_B)
			await create_timer(.65).timeout
			_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0 and not game.foraging_hold.active(),"held E cannot restart after modal")
			_key(KEY_E,false)
			await _normal_pickup()
			_check(game.session.inventory.snapshot().active_item_id == null,"pickup does not auto-equip")
		for route: Dictionary in _flower_routes():
			if not await _walk(route.approach,"integrated-" + route.id): break
			game._refresh_interaction()
			_check(game.selected_interaction != null and game.selected_interaction.instance_id == route.id,"ordinary flower selection " + route.id)
			await _pause()
			await _capture("approach-" + route.id)
			await _resume()
			_key(KEY_E,true)
			await create_timer(.8).timeout
			_check(game.session.foraging.is_collected(route.id) and not game.foraging_hold.active(),"single held gather " + route.id)
			await create_timer(.15).timeout
			_key(KEY_E,false)
		_check(game.session.inventory.count("item-moonflower") == 3 and game.world_host.current_location.foraging_pickups.targets.is_empty(),"all four ordinary origins collected/absent")
		_tap(KEY_B)
		_tap(KEY_TAB)
		_tap(KEY_ENTER)
		_check(game.session.inventory.snapshot().active_item_id == "item-moonflower" and game.ui.active_item_label.text.begins_with("Selected item"),"non-tool selection honest")
		await _bag_capture("all-items-flower-selected","debug-input","All four items acquired by ordinary walk/E; Tab/Enter selects flower")
		await _click_bag(game.ui.backpack.slots[0])
		_check(game.session.inventory.snapshot().active_item_id == ForagingRegistry.ROD_ITEM,"pointer selects owned rod")
		await _click_bag(game.ui.backpack.close_button)
		if await _walk(Vector3(-6.5,0,15),"integrated-drop-return"):
			await _normal_drop()
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-8,0,15.75),"water-invalid",false)
			_tap(KEY_P)
			_check(game.camera_rig.camera.projection == Camera3D.PROJECTION_PERSPECTIVE,"ordinary P perspective")
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-6.5,0,15.6),"perspective-valid",true)
			await _normal_pickup()
			_tap(KEY_P)
			_check(game.camera_rig.camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"ordinary P orthographic")
			await _normal_drop()
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-6.5,0,15.6),"saved-world-rod",true)
		await _lamp_round_trip()
		if await _walk(Vector3(107.25,0,0),"integrated-outbound-gate"):
			await _normal_gate("prototype-tollworks")
			_check(game.world_host.current_location.foraging_pickups.targets.is_empty() and game.session.foraging.rod_count() == 1,"indoor foreign rod unique")
			await _pause()
			await _capture("tollworks-arrival")
			await _resume()
			if await _walk(Vector3(0,0,-4),"integrated-return-gate"):
				await _normal_gate(ForagingRegistry.LOCATION)
		_check_origins()
		await _pause()
		var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
		_check(saved.ok,saved.get("error","GUI Save"))
		var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
		_check(disk.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(disk.session)) == TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)),"GUI Save exact typed disk facts")
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		_check(file != null,"writer exact oracle")
		if file != null:
			file.store_var(TestRunSnapshot.oracle(game.session))
			file.close()
		await _capture("gui-save-confirmed",true)
	else:
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"independent writer oracle exists")
		if file != null:
			var oracle: Dictionary = file.get_var(false)
			file.close()
			var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
			_check(loaded.ok,loaded.get("error","GUI Load"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			restart_errors = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
			_check(restart_errors.is_empty(),"exact all prior/item facts and forecast new-process restart: " + str(restart_errors))
			_check_origins()
			_check(not game.foraging_hold.active() and not game.item_drag.active() and game.drag_preview == null and not game.backpack_open,"no restored transient input")
			await _capture("gui-load-exact",true)
			await _resume()
			for route: Dictionary in _flower_routes():
				if not await _walk(route.approach,"restored-revisit-" + route.id): break
				_check_origins()
				await _pause()
				await _capture("absent-" + route.id)
				await _resume()
			if await _walk(Vector3(-6.5,0,15),"restored-world-rod"):
				await _normal_pickup()
				_check(game.session.foraging.rod_count() == 1 and game.session.foraging.placement(ForagingRegistry.DROP_ID) == null,"physical restored recollect conserves rod")
				_tap(KEY_B)
				_tap(KEY_ENTER)
				await _bag_capture("restored-recollected-rod","debug-input","Exact independent GUI Load then ordinary all-three revisit and physical rod recollection; Enter activates rod")
				_tap(KEY_ESCAPE)
				await _pause()
				await _capture("restored-origin-still-absent")
	_check(TestRunEvidence.write_json(phase + "-index.json",{"task":"F009","phase":phase,"proof":"ordinary viewport WASD/E/B/Tab/Enter/pointer/P/lamp/gate/GUI Save and separate-process GUI Load; no pose, reward or fact setup","engine_pid":OS.get_process_id(),"engine":Engine.get_version_info()["string"],"user_data":OS.get_user_data_dir(),"views":views,"live_frames":live_frames,"modal_views":modal_views,"drag_views":drag_views,"traces":traces,"restart_errors":restart_errors,"failures":failures}),"write integrated evidence")
	_set_keys([])
	_key(KEY_E,false)
	for failure: String in failures: push_error(failure)
	print("F009 integrated ",phase," ","PASS" if failures.is_empty() else "FAIL")
	if failures.is_empty():
		# Exercise the production quit action, including from a paused GUI boundary.
		_tap(KEY_F10)
	else:
		game.queue_free()
		await process_frame
		paused = false
		quit(1)

func _flower_routes() -> Array[Dictionary]:
	return [{"id":"moonflower-01","approach":Vector3(27.5,.25,-2)},{"id":"moonflower-02","approach":Vector3(34.75,.25,7)},{"id":"moonflower-03","approach":Vector3(30.75,.5,-9)}]

func _check_origins() -> void:
	var targets: Dictionary = game.world_host.current_location.foraging_pickups.targets
	for id: String in [ForagingRegistry.ROD_ORIGIN,"moonflower-01","moonflower-02","moonflower-03"]:
		_check(game.session.foraging.is_collected(id) and not targets.has(id),"persistent collected origin absent " + id)
	_check(game.session.inventory.count("item-moonflower") == 3 and game.session.foraging.rod_count() == 1,"persistent flowers3/rod1")

func _lamp_round_trip() -> void:
	var lamp: PrototypeInteractable = game.world_host.current_location.town.get_node("dock-lamp-02/LightSwitch")
	_check(lamp != null and lamp.instance_id == "dock-lamp-02","lamp wrapper available")
	if lamp == null or lamp.instance_id != "dock-lamp-02": return
	if not await _walk(lamp.global_position + Vector3(0,0,-1),"integrated-lamp"): return
	game._refresh_interaction()
	_check(game.selected_interaction == lamp,"ordinary walking selects lamp")
	var before: bool = game.session.environment.light_enabled(ForagingRegistry.LOCATION,"dock-lamp-02","lantern")
	_tap(KEY_E)
	_check(game.session.environment.light_enabled(ForagingRegistry.LOCATION,"dock-lamp-02","lantern") != before,"immediate E lamp after held gather")
	await _pause()
	await _capture("ordinary-lamp-switched")
	await _resume()
