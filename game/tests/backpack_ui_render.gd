extends "res://tests/foraging_interaction_render.gd"
## Ordinary rod/flower gather + viewport backpack GUI, exact independent restart.
var modal_views: Array[Dictionary] = []

func _run() -> void:
	phase = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	var oracle_path: String = ProjectSettings.globalize_path(game.save_repository.path + ".f006-oracle")
	_check(not game.backpack_open and game.session.inventory.snapshot().active_item_id == null,"fresh modal/selection defaults")
	if phase == "write":
		_tap(KEY_B)
		await _bag_capture("empty-960","debug-input","Fresh normal session, B opens empty backpack")
		root.size = Vector2i(800,600)
		await _bag_capture("empty-800","debug-input","Same empty backpack at smaller 800x600 window")
		_tap(KEY_ESCAPE)
		_check(not paused and not game.backpack_open,"Esc closes backpack before pause")
		root.size = Vector2i(960,640)
		await _click_bag(game.ui.backpack_button)
		_check(game.backpack_open,"HUD entry opens backpack")
		await _click_bag(game.ui.backpack.close_button)
		_check(not game.backpack_open,"pointer Close restores world")
		print("F006 HUD flow complete; paused=",paused," backpack=",game.backpack_open," controls=",game.player_placeholder.controls_enabled," focus=",root.gui_get_focus_owner())
		var before: Vector3 = game.player_placeholder.position
		_key(KEY_D,true)
		for frame: int in range(15): await physics_frame
		_key(KEY_D,false)
		_check(game.player_placeholder.position.distance_to(before) > .1,"ordinary movement preflight")
		if await _walk(Vector3(-6.5,0,15),"rod-backpack-route"):
			_key(KEY_E,true)
			await create_timer(.15).timeout
			_check(game.foraging_hold.active(),"ordinary E hold begins")
			_tap(KEY_B)
			_check(game.backpack_open and not game.foraging_hold.active(),"B cancels hold synchronously")
			_tap(KEY_B)
			await create_timer(.7).timeout
			_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0 and not game.foraging_hold.active(),"held E cannot resume after backpack")
			_key(KEY_E,false)
			_key(KEY_E,true)
			await create_timer(.75).timeout
			_key(KEY_E,false)
			_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1,"fresh E gathers rod")
		_tap(KEY_B)
		_tap(KEY_ENTER)
		_check(game.session.inventory.snapshot().active_item_id == ForagingRegistry.ROD_ITEM and game.ui.backpack.drop_button.disabled,"keyboard selects rod; Drop unavailable")
		await _bag_capture("rod-selected-960","debug-input","Rod acquired by ordinary walk/E; Enter selects owned rod")
		root.size = Vector2i(800,600)
		await _bag_capture("rod-selected-800","debug-input","Selected rod, counts/cap/details at 800x600")
		root.size = Vector2i(960,640)
		var modal_position: Vector3 = game.player_placeholder.position
		var zoom: float = game.camera_rig.zoom_factor
		for code: int in [KEY_W,KEY_SPACE,KEY_E,KEY_P,KEY_EQUAL,KEY_J]: _tap(code)
		await _click_point(Vector2(10,330))
		await create_timer(.25).timeout
		_check(game.player_placeholder.position.is_equal_approx(modal_position) and not game.player_placeholder.combat.busy() and not game.foraging_hold.active() and not game.journal_open and game.camera_rig.zoom_factor == zoom,"rendered modal rejects world commands")
		for step: int in range(8):
			_tap(KEY_TAB)
			_check(game.ui.backpack.is_ancestor_of(root.gui_get_focus_owner()),"rendered focus contained")
		_tap(KEY_B)
		if await _walk(Vector3(27.5,.25,-2),"flower-backpack-route"):
			_key(KEY_E,true)
			await create_timer(.8).timeout
			_key(KEY_E,false)
			_check(game.session.inventory.count("item-moonflower") == 1,"ordinary flower gathered")
		_tap(KEY_B)
		_tap(KEY_TAB)
		_tap(KEY_ENTER)
		_check(game.session.inventory.snapshot().active_item_id == "item-moonflower" and game.ui.active_item_label.text.begins_with("Selected item") and not game.ui.backpack.drop_button.visible,"keyboard selects non-tool honestly")
		await _bag_capture("flower-selected","debug-input","Ordinary flower acquisition; Tab/Enter selects flower; no direct use")
		await _click_bag(game.ui.backpack.slots[0])
		_check(game.session.inventory.snapshot().active_item_id == ForagingRegistry.ROD_ITEM,"pointer selects rod for save")
		await _click_bag(game.ui.backpack.close_button)
		await _pause()
		var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
		_check(saved.ok,saved.get("error","GUI Save"))
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		_check(file != null,"write exact oracle")
		if file != null:
			file.store_var(TestRunSnapshot.oracle(game.session))
			file.close()
		await _capture("selected-rod-gui-save",true)
		await _resume()
		_tap(KEY_B)
		await _capacity_views()
		_tap(KEY_B)
		await _pause()
	else:
		await _pause()
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"separate writer oracle exists")
		if file != null:
			var oracle: Dictionary = file.get_var(false)
			file.close()
			var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
			_check(loaded.ok,loaded.get("error","GUI Load"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			_check(disk.session != null,"typed disk restore")
			if disk.session != null:
				var comparison: PackedStringArray = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
				_check(comparison.is_empty(),"exact prior/item/selection restart: " + str(comparison))
			_check(not game.backpack_open and not game.foraging_hold.active(),"restart transient defaults")
			await _capture("selected-rod-gui-load",true)
			await _resume()
			_tap(KEY_B)
			_check(game.session.inventory.snapshot().active_item_id == ForagingRegistry.ROD_ITEM and game.ui.backpack.slots[0].button_pressed and game.ui.active_item_label.text.begins_with("Active tool: Fishing rod"),"restored bag/highlight/HUD agree")
			await _bag_capture("restored-selected-rod","debug-input","Separate-process GUI Load; exact oracle passed; B shows saved owned selection")
			_tap(KEY_ESCAPE)
			await _pause()
	_check(TestRunEvidence.write_json(phase + "-index.json",{"task":"F006","phase":phase,"proof":"ordinary viewport WASD/E/B/Tab/Enter/pointer and GUI Save/Load; detached capacity presentation explicitly synthetic","engine_pid":OS.get_process_id(),"engine":Engine.get_version_info()["string"],"user_data":OS.get_user_data_dir(),"views":views,"modal_views":modal_views,"traces":traces,"failures":failures}),"write render evidence")
	_set_keys([])
	_key(KEY_E,false)
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F006 backpack render ",phase," ","PASS" if failures.is_empty() else "FAIL","; modal captures=",modal_views.size())
	quit(0 if failures.is_empty() else 1)

func _tap(code: int) -> void:
	_key(code,true)
	_key(code,false)

func _click_bag(button: Button) -> void:
	for frame: int in range(4): await process_frame
	print("F006 click ",button.name," rect=",button.get_global_rect()," paused=",paused)
	await _click_point(button.get_global_rect().get_center())
	print("F006 click done ",button.name," paused=",paused," backpack=",game.backpack_open)

func _click_point(point: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	root.push_input(motion,true)
	for down: bool in [true,false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		root.push_input(event,true)
	for frame: int in range(4): await process_frame

func _bag_capture(label: String,kind: String,note: String) -> void:
	for frame: int in range(5): await process_frame
	await RenderingServer.frame_post_draw
	print("F006 modal capture ",label," paused=",paused," backpack=",game.backpack_open," viewport=",root.size)
	var focus: Control = root.gui_get_focus_owner()
	var verified: bool = game.backpack_open and game.ui.backpack.visible and not game.player_placeholder.controls_enabled and focus != null and game.ui.backpack.is_ancestor_of(focus)
	_check(verified,"backpack checkpoint " + label)
	_check(root.get_visible_rect().encloses(game.ui.backpack.panel.get_global_rect()),"rendered panel fits " + label)
	if not verified: return
	var path: String = TestRunEvidence.path(phase + "-" + label + ".png")
	var picture: Image = root.get_texture().get_image()
	_check(picture.save_png(path) == OK,"backpack PNG " + label)
	modal_views.append({"label":label,"path":path,"kind":kind,"note":note,"paused":paused,"backpack_modal_verified":verified,"controls_enabled":game.player_placeholder.controls_enabled,"focus":str(focus.get_path()),"engine_pid":OS.get_process_id(),"engine":Engine.get_version_info()["string"],"window_size":[root.size.x,root.size.y],"viewport_size":[picture.get_width(),picture.get_height()],"camera":TestRunObservation.camera(game),"inventory":game.session.inventory.snapshot().to_dictionary(),"display_slot_ids":game.ui.backpack.slot_ids.duplicate(),"details":game.ui.backpack.details.text,"position":TestRunObservation.vector(game.player_placeholder.global_position)})

func _capacity_views() -> void:
	var before: String = TestRunSnapshot.exact_json(game.session.inventory.snapshot().to_dictionary())
	var manifest: ContentManifest = game.content_manifest.duplicate()
	var counts: Dictionary[String,int] = {ForagingRegistry.ROD_ITEM:1,"item-moonflower":99}
	for index: int in range(18):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "f006-capacity-%02d" % index
		item.display_name = "Sample %02d" % (index + 1)
		item.description = "Detached test-only capacity presentation."
		item.source_item_id = item.stable_id
		manifest.definitions.append(item)
		counts[item.stable_id] = 99
	var catalog_fixture: ContentCatalog = ContentCatalog.new()
	_check(catalog_fixture.initialize(manifest).is_empty(),"capacity display catalog")
	var snapshot: InventorySnapshot = InventorySnapshot.new(counts,ForagingRegistry.ROD_ITEM)
	game.set_process(false)
	game.ui.backpack.open(snapshot,catalog_fixture)
	await _bag_capture("capacity-960","synthetic","Detached20-type snapshot/catalog; actual session untouched; root presentation refresh suspended for capture only")
	root.size = Vector2i(800,600)
	await _bag_capture("capacity-800","synthetic","Same detached twenty-slot/max-stack display at 800x600; no reward/save fixture")
	root.size = Vector2i(960,640)
	game.ui.backpack.present(game.session.inventory.snapshot(),game.catalog,true)
	game.set_process(true)
	_check(TestRunSnapshot.exact_json(game.session.inventory.snapshot().to_dictionary()) == before,"capacity fixture cannot mutate session")
