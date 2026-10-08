extends "res://tests/backpack_ui_render.gd"
## Ordinary WASD/E/backpack Drop/pointer drag/gate travel; separate GUI restart.
var drag_views: Array[Dictionary] = []

func _run() -> void:
	phase = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	var oracle_path: String = ProjectSettings.globalize_path(game.save_repository.path + ".f007-oracle")
	_check(game.session.foraging.rod_count() == 1 and not game.item_drag.active(),"fresh rod/transient defaults")
	if phase == "write":
		var start: Vector3 = game.player_placeholder.position
		_key(KEY_D,true)
		for frame: int in range(15): await physics_frame
		_key(KEY_D,false)
		_check(game.player_placeholder.position.distance_to(start) > .1,"ordinary movement preflight")
		if await _walk(Vector3(-6.5,0,15),"rod-drop-route"):
			await _normal_drag(ForagingRegistry.ROD_ORIGIN,Vector3(-6.5,0,15.55),"authored-green",true)
			_check(game.session.foraging.placement(ForagingRegistry.ROD_ORIGIN) != null and game.session.foraging.rod_count() == 1,"ordinary authored override unique")
			await _normal_pickup()
			await _normal_drop()
			_check(not game.backpack_open and game.session.inventory.snapshot().active_item_id == null and game.session.foraging.rod_count() == 1,"ordinary drop clears active/one rod")
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-8,0,15.75),"water-red",false)
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-6.5,0,15.65),"generated-green",true)
			await _normal_pickup()
			_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.placement(ForagingRegistry.DROP_ID) == null,"ordinary full pickup/activate/drop/drag/pickup loop")
			await _normal_drop()
			await _normal_drag(ForagingRegistry.DROP_ID,Vector3(-6.5,0,15.6),"saved-green",true)
			await _pause()
			await _capture("placed-rod-before-travel")
			await _resume()
			var placed: Vector3 = game.session.foraging.placement(ForagingRegistry.DROP_ID).foot
			if await _walk(Vector3(107.25,0,0),"rod-travel-to-gate"):
				await _normal_gate("prototype-tollworks")
				_check(game.world_host.current_location.foraging_pickups.targets.is_empty() and game.session.foraging.rod_count() == 1,"foreign placed rod persists once")
				if await _walk(Vector3(0,0,-4),"rod-return-to-gate"):
					await _normal_gate(ForagingRegistry.LOCATION)
					if await _walk(Vector3(-6.5,0,15),"rod-after-travel-revisit"):
						var pickup: PrototypeInteractable = game.world_host.current_location.foraging_pickups.targets.get(ForagingRegistry.DROP_ID)
						_check(pickup != null and pickup.global_position.is_equal_approx(placed) and game._reachable_rod(pickup),"normal travel/revisit rod remains reachable at exact foot")
						await _pause()
						await _capture("placed-rod-after-travel")
		await _pause()
		var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
		_check(saved.ok,saved.get("error","GUI Save"))
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		_check(file != null,"write whole-save exact oracle")
		if file != null:
			file.store_var(TestRunSnapshot.oracle(game.session))
			file.close()
		await _capture("placed-rod-gui-save",true)
	else:
		await _pause()
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"independent writer oracle exists")
		if file != null:
			var oracle: Dictionary = file.get_var(false)
			file.close()
			var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
			_check(loaded.ok,loaded.get("error","GUI Load"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			_check(disk.session != null,"typed disk oracle")
			if disk.session != null:
				var comparison: PackedStringArray = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
				_check(comparison.is_empty(),"exact every prior/item fact restart: " + str(comparison))
			_check(not game.item_drag.active() and game.drag_preview == null and not game.foraging_hold.active() and game.session.foraging.rod_count() == 1,"fresh transients and unique restored rod")
			_check(game.session.foraging.is_collected(ForagingRegistry.ROD_ORIGIN) and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0,"restored origin suppressed/world ownership")
			await _capture("placed-rod-gui-load",true)
			await _resume()
			if await _walk(Vector3(-6.5,0,15),"restored-placed-rod-revisit"):
				await _normal_pickup()
				_check(game.session.foraging.rod_count() == 1 and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and not game.world_host.current_location.foraging_pickups.targets.has(ForagingRegistry.DROP_ID) and not game.world_host.current_location.foraging_pickups.targets.has(ForagingRegistry.ROD_ORIGIN),"physical pickup at restored committed position")
				await _pause()
				await _capture("restored-rod-recollected")
	_check(TestRunEvidence.write_json(phase + "-index.json",{"task":"F007","phase":phase,"proof":"ordinary viewport WASD/E/B/Enter/Drop/pointer drag/gate travel/GUI Save/new-process GUI Load; no teleport or fact fixture","engine_pid":OS.get_process_id(),"engine":Engine.get_version_info()["string"],"user_data":OS.get_user_data_dir(),"views":views,"modal_views":modal_views,"drag_views":drag_views,"traces":traces,"failures":failures}),"write render evidence")
	_set_keys([])
	_key(KEY_E,false)
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F007 rod render ",phase," ","PASS" if failures.is_empty() else "FAIL","; drag views=",drag_views.size())
	quit(0 if failures.is_empty() else 1)

func _normal_pickup() -> void:
	_key(KEY_E,true)
	await create_timer(.75).timeout
	_key(KEY_E,false)
	_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and not game.foraging_hold.active(),"ordinary physical held pickup")

func _normal_drop() -> void:
	_tap(KEY_B)
	_tap(KEY_ENTER)
	_check(game.backpack_open and game.session.inventory.snapshot().active_item_id == ForagingRegistry.ROD_ITEM and not game.ui.backpack.drop_button.disabled,"ordinary B/Enter activates rod")
	await _bag_capture("drop-ready-%d" % modal_views.size(),"debug-input","Rod acquired through ordinary E; B/Enter selects owned rod; safe Drop enabled")
	await _click_bag(game.ui.backpack.drop_button)
	_check(not game.backpack_open and game.session.foraging.placement(ForagingRegistry.DROP_ID) != null,"ordinary pointer Drop committed")
	for frame: int in range(3): await process_frame

func _normal_drag(id: String,foot: Vector3,label: String,valid: bool) -> void:
	var target: PrototypeInteractable = game.world_host.current_location.foraging_pickups.targets.get(id)
	_check(target != null,"rod wrapper before drag " + label)
	if target == null: return
	var before: String = _item_facts()
	var start_point: Vector2 = game.camera_rig.camera.unproject_position(target.global_position + Vector3.UP * .08)
	_drag_motion(start_point)
	_drag_mouse(start_point,true)
	_check(game.item_drag.active() and not game.player_placeholder.combat.busy(),"pointer drag suppresses attack " + label)
	var end_point: Vector2 = game.camera_rig.camera.unproject_position(foot)
	_drag_motion(end_point)
	_check(game.item_drag.errors.is_empty() == valid and _item_facts() == before,"detached preview validation " + label + str(game.item_drag.errors))
	var captured: Dictionary = await TestRunInteractionCapture.drag(game,phase + "-" + label,directory,"debug-input","Ordinary pointer drag after normal WASD approach; actual unpaused preview; no durable setup")
	_check(captured.ok,captured.get("error","drag capture"))
	if captured.ok: drag_views.append(captured)
	_drag_mouse(end_point,false)
	_check(not game.item_drag.active() and game.session.foraging.rod_count() == 1,"release ends preview/conserves rod " + label)
	if valid:
		var placed: WorldItemPlacement = game.session.foraging.placement(id)
		_check(placed != null and placed.foot.distance_to(foot) < .01,"ordinary release placement " + label)
	else:
		_check(_item_facts() == before,"invalid ordinary release exact rollback")
	for frame: int in range(3): await process_frame

func _normal_gate(destination: String) -> void:
	game._refresh_interaction()
	_check(game.selected_interaction != null and game.selected_interaction.kind == "travel","ordinary gate selected")
	_tap(KEY_E)
	_check(game.world_host.transitioning,"E initiates gate travel")
	if game.world_host.transitioning:
		var arrival: Array = await game.world_host.transition_finished
		_check(arrival[0] and game.session.current_location_id == destination,"gate arrival " + destination)
	for frame: int in range(4): await process_frame

func _item_facts() -> String:
	var facts: Dictionary = game.session.foraging.snapshot()
	facts.erase("revision")
	return TestRunSnapshot.exact_json(facts)

func _drag_motion(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	root.push_input(event,true)

func _drag_mouse(point: Vector2,down: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event,true)
