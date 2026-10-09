extends "res://tests/world_item_placement_render.gd"
## FS007 ordinary fresh gameplay and independent actual GUI restart. No state/RNG/time setup.
var attempts: Array[Dictionary] = []
var restart_errors: PackedStringArray = []
var caught: String = ""
var sites: Array[Dictionary] = [
	{"id":"dock","foot":Vector3(-7,0,18),"target":Vector3(-4.75,.015,20.25),"areas":["fishing-dock-shallows"]},
	{"id":"channel","foot":Vector3(10,0,13),"target":Vector3(10.25,.015,17.25),"areas":["fishing-lake-channel"]},
	{"id":"reeds-west","foot":Vector3(3,0,13),"target":Vector3(3.25,.015,22.25),"areas":["fishing-dock-shallows","fishing-sunken-reeds"]},
	{"id":"reeds-east","foot":Vector3(6,0,13),"target":Vector3(6.25,.015,22.25),"areas":["fishing-lake-channel","fishing-sunken-reeds"]}]

func _run() -> void:
	phase = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"ordinary startup")
	for frame: int in range(4): await process_frame
	_check(game.session.inventory.snapshot().item_counts.is_empty() and game.fishing.mode() == "idle","fresh empty bag/no autoload/attempt")
	await _pause()
	await _capture("fresh-start",true)
	var oracle_path: String = game.save_repository.path+".fs007-gui-oracle"
	if phase == "write":
		await _resume()
		var start: Vector3 = game.player_placeholder.global_position
		_key(KEY_D,true)
		for frame: int in range(15): await physics_frame
		_key(KEY_D,false)
		_check(game.player_placeholder.global_position.distance_to(start) > .1,"camera-relative ordinary movement preflight")
		if await _walk(Vector3(-6.5,0,15),"ordinary-rod-pickup"):
			await _normal_pickup()
			_check(game.session.inventory.snapshot().active_item_id == null,"pickup does not auto-select rod")
			await _select_bag(ForagingRegistry.ROD_ITEM,"rod-selected")
		for site: Dictionary in sites:
			if not failures.is_empty() or not await _walk(site.foot,"ordinary-"+site.id): break
			await _start_cast(site.target)
			var target: FishingWaterTargetResolver.Result = FishingWaterTargetResolver.from_pointer(game.world_host.current_location,game.catalog,game.camera_rig.camera,game.camera_rig.camera.unproject_position(site.target),game.player_placeholder.global_position,true,FishingSessionService.rod(game.session))
			var area_ids: PackedStringArray = FishingActivityResolver.distribution(game.catalog,Vector2(target.point.x,target.point.z)).area_ids
			_check(area_ids == PackedStringArray(site.areas),"ordinary actual cast observes exact authored profiles " + site.id + str(area_ids))
			await _fish_capture(site.id+"-waiting","waiting")
			await _finish_live(site.id)
			await _pause()
			await _capture(site.id+"-terminal",true)
			await _resume()
		if failures.is_empty() and caught.is_empty():
			for retry: int in range(8):
				await _start_cast(sites[3].target)
				await _finish_live("bounded-recast-%d" % retry)
				if not caught.is_empty() or not failures.is_empty(): break
		_check(not caught.is_empty(),"at least one ordinary unforced-RNG landing within twelve bounded casts")
		if failures.is_empty():
			await _ordinary_negatives()
			await _select_bag(caught,"unforced-fish-selected")
			var counts: Dictionary = game.session.inventory.snapshot().item_counts.duplicate(true)
			await _ordinary_travel(counts)
			await _pause()
			var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved.") and FileAccess.file_exists(game.save_repository.path))
			_check(saved.ok,saved.get("error","GUI Save"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			_check(disk.session != null and TestRunSnapshot.exact_json(SaveCodec.snapshot(disk.session)) == TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)),"GUI Save exact complete typed slot")
			var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
			_check(file != null,"typed GUI oracle write")
			if file != null:
				file.store_var(TestRunSnapshot.oracle(game.session))
				file.close()
			await _capture("gui-save-confirmed",true)
	else:
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"independent ordinary writer oracle")
		if file != null:
			var oracle: Dictionary = file.get_var(false)
			file.close()
			var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
			_check(loaded.ok,loaded.get("error","GUI Load"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			_check(disk.session != null,"reader typed slot")
			if disk.session != null: restart_errors = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
			_check(disk.session != null and restart_errors.is_empty(),"exact typed fish/selection/all durable facts/forecast before resuming " + str(restart_errors))
			_check(game.fishing.mode() == "idle" and not game.fishing_effects.visible and not game.foraging_hold.active() and not game.item_drag.active(),"load resumes no attempt/input/effect")
			caught = str(game.session.inventory.snapshot().active_item_id)
			_check(caught in ["item-bluegill","item-river-trout","item-golden-carp"],"selected owned fish restored")
			await _capture("gui-load-exact",true)
			await _resume()
			await _select_bag(caught,"restored-fish-selected")
			var counts: Dictionary = game.session.inventory.snapshot().item_counts.duplicate(true)
			await _ordinary_travel(counts)
	await _pause()
	await _capture("final-paused",true)
	_check(TestRunEvidence.write_json(phase+"-index.json",{"task":"FS007","phase":phase,"proof":"fresh ordinary viewport WASD/E/B/GUI/F/world click and visible pointer Reel; unforced production RNG, automatic world/challenge time; no teleport, inventory grants or state setup; independent actual GUI Save/Load","engine_pid":OS.get_process_id(),"engine":Engine.get_version_info()["string"],"user_data":OS.get_user_data_dir(),"views":views,"modal_views":modal_views,"traces":traces,"attempts":attempts,"restart_errors":restart_errors,"failures":failures}),"ordinary index write")
	_key(KEY_E,false)
	for failure: String in failures: push_error(failure)
	print("FS007 ordinary ",phase," ","PASS" if failures.is_empty() else "FAIL","; catches=",game.session.inventory.snapshot().item_counts,"; attempts=",attempts.size())
	if failures.is_empty(): _tap(KEY_F10) # Normal application quit, checked in runner logs.
	else: quit(1)

func _start_cast(target: Vector3) -> void:
	_tap(KEY_F)
	_check(game.fishing.mode() == "targeting","ordinary F enters targeting")
	await _click_point(game.camera_rig.camera.unproject_position(target))
	_check(game.fishing.active() and game.fishing.snapshot().phase == "waiting","ordinary world click starts real RNG attempt " + str(game.fishing.snapshot()))

func _finish_live(label: String, cancel_fight: bool = false, miss_hook: bool = false) -> void:
	var started: int = Time.get_ticks_msec()
	var initial: Dictionary = game.fishing.snapshot()
	var before_counts: Dictionary = game.session.inventory.snapshot().item_counts.duplicate(true)
	var captured_bite: bool = false
	var captured_fight: bool = false
	var held: bool = false
	while game.fishing.active() and Time.get_ticks_msec()-started < 40000:
		var state: Dictionary = game.fishing.snapshot()
		if state.phase == "bite" and not miss_hook:
			if not captured_bite:
				await _fish_capture(label+"-bite","bite")
				captured_bite = true
			_reel_mouse(true)
			held = true
		elif state.phase == "fighting":
			if not captured_fight:
				_reel_mouse(false)
				held = false
				await _fish_capture(label+"-fighting","fighting")
				captured_fight = true
				if cancel_fight:
					await _click_point(game.ui.fishing_view.cancel_button.get_global_rect().get_center())
					break
			state = game.fishing.snapshot()
			if state.tension <= .46 and not held:
				_reel_mouse(true)
				held = true
			elif state.tension >= .54 and held:
				_reel_mouse(false)
				held = false
		await process_frame
	_reel_mouse(false)
	var terminal: Dictionary = game.fishing.snapshot()
	_check(not game.fishing.active(),"bounded ordinary terminal " + label)
	if terminal.rewarded:
		caught = terminal.item_id
		var expected: Dictionary = before_counts.duplicate(true)
		expected[caught] = int(expected.get(caught,0))+1
		_check(game.session.inventory.snapshot().item_counts == expected,"ordinary landing atomic +1 " + label)
	else: _check(game.session.inventory.snapshot().item_counts == before_counts,"ordinary failure/cancel no inventory change " + label)
	attempts.append({"label":label,"provenance":"ordinary unforced RNG, automatic time, pointer HUD feedback","initial":initial,"terminal":terminal,"elapsed_ms":Time.get_ticks_msec()-started,"counts_before":before_counts,"counts_after":game.session.inventory.snapshot().item_counts})
	print("FS007_ATTEMPT ",label," ",terminal.outcome," ",terminal.item_id)

func _ordinary_negatives() -> void:
	# All cases here use actual ordinary input. RNG misses may precede a bite;
	# synthetic suites separately guarantee each named failure deterministically.
	await _select_bag(ForagingRegistry.ROD_ITEM,"rod-negative-controls")
	_tap(KEY_F)
	await _click_point(game.camera_rig.camera.unproject_position(Vector3(6,0,13)))
	_check(game.fishing.mode() == "targeting" and not game.fishing.active(),"invalid dry cast rejected")
	await _fish_capture("invalid-dry-cast","targeting")
	_tap(KEY_F)
	await _start_cast(sites[3].target)
	_reel_mouse(true)
	_reel_mouse(false)
	_check(game.fishing.mode() == "idle" and game.fishing.snapshot().outcome == "early_reel","actual early reel rejection")
	await _fish_capture("early-reel","result")
	for retry: int in range(8):
		await _start_cast(sites[3].target)
		await _finish_live("missed-hook-%d" % retry,false,true)
		if game.fishing.snapshot().outcome == "missed_hook": break
	_check(game.fishing.snapshot().outcome == "missed_hook","actual missed-hook ordinary negative")
	for retry: int in range(8):
		await _start_cast(sites[3].target)
		await _finish_live("cancel-fight-%d" % retry,true)
		if game.fishing.snapshot().outcome == "canceled": break
	_check(game.fishing.snapshot().outcome == "canceled","actual visible Cancel during fight")
	await _start_cast(sites[3].target)
	_tap(KEY_F)
	_check(game.fishing.mode() == "idle" and not game.fishing_effects.visible,"immediate fresh recast and F cancel")
	if await _walk(Vector3(-6.5,0,15),"rod-drop-after-cancel"):
		await _select_bag(ForagingRegistry.ROD_ITEM,"rod-drop-ready")
		await _normal_drop()
		_check(game.session.foraging.rod_count() == 1 and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0,"ordinary post-cancel drop conserves rod")
		await _normal_pickup()
		_check(game.session.foraging.rod_count() == 1 and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1,"ordinary post-cancel retrieve conserves rod")

func _ordinary_travel(counts: Dictionary) -> void:
	var seconds: float = game.session.elapsed_play_seconds
	if await _walk(Vector3(107.25,0,0),phase+"-outbound-gate"):
		await _normal_gate("prototype-tollworks")
		_check(game.fishing.mode() == "idle" and game.session.inventory.snapshot().item_counts == counts,"gate travel retains fish and no attempt")
		if await _walk(Vector3(0,0,-4),phase+"-return-gate"):
			await _normal_gate(ForagingRegistry.LOCATION)
			if await _walk(sites[0].foot,phase+"-dock-revisit"):
				_check(game.session.inventory.snapshot().item_counts == counts and game.session.elapsed_play_seconds > seconds,"ordinary travel/revisit exact counts, separate monotonic time")
				_check(game.world_host.current_location.npc_contacts.targets.size() == 8 and game.party.members().size() == 2,"revisit eight villagers/two party actors")
				await _pause()
				await _capture("fish-dock-revisit")
				await _resume()

func _select_bag(id: String,label: String) -> void:
	_tap(KEY_B)
	for frame: int in range(4): await process_frame
	var index: int = game.ui.backpack.slot_ids.find(id)
	_check(index >= 0,"ordinary bag owns " + id)
	if index >= 0: await _click_bag(game.ui.backpack.slots[index])
	_check(game.session.inventory.snapshot().active_item_id == id,"actual pointer selection " + id)
	await _bag_capture(label,"debug-input","Ordinary gathered rod/unforced landed fish, actual B and pointer selection; no grants")
	_tap(KEY_B)

func _reel_mouse(down: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	event.position = game.ui.fishing_view.reel_button.get_global_rect().get_center() if down else Vector2(20,300)
	_drag_motion(event.position)
	root.push_input(event,true)

func _fish_capture(label: String,expected: String) -> void:
	var result: Dictionary = await TestRunInteractionCapture.fishing(game,phase+"-"+label,directory,"debug-input","Ordinary WASD/E/B/F/click and visible Reel; unforced production RNG and automatic time during capture.",expected)
	_check(result.ok,result.get("error",label))
	if result.ok: views.append(result)

func _capture(label: String,overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game,phase+"-"+label,directory,"debug-input",overlay,"Ordinary unforced fishing journey, verified pause; no state/pose/RNG/time fixtures. Pause cancels attempts.")
	_check(result.ok,result.get("error",label))
	if result.ok: views.append(result)
