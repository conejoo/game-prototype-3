extends SceneTree
## Fresh ordinary camera-relative walk/E/GUI Save, separate-process Load; no teleport.
var game: Node3D
var failures: PackedStringArray = []
var views: Array[Dictionary] = []
var live_frames: Array[Dictionary] = []
var traces: Array[Dictionary] = []
var keys: Array[int] = []
var phase: String
var directory: String

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	phase = "write" if "--phase=write" in OS.get_cmdline_user_args() else "read"
	directory = TestRunEvidence.directory()
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await _pause()
	await _capture("fresh-start")
	_check(game.session.inventory.count("item-moonflower") == 0 and game.world_host.current_location.foraging_pickups.targets.size() == 4, "fresh defaults")
	var oracle_path: String = ProjectSettings.globalize_path(game.save_repository.path + ".f005-oracle")
	if phase == "write":
		await _resume()
		# Short input preflight: movement uses actual camera vectors and actor gates.
		var preflight: Vector3 = game.player_placeholder.global_position
		_key(KEY_D,true)
		for frame: int in range(15): await physics_frame
		traces.append({"label":"movement-preflight","start":TestRunObservation.vector(preflight),"actual":TestRunObservation.vector(game.player_placeholder.global_position),"accepted_keys":game.player_placeholder.movement_buttons.keys(),"controls_enabled":game.player_placeholder.controls_enabled,"window_focused":game.window_focused,"ui_focus":str(root.gui_get_focus_owner())})
		_key(KEY_D,false)
		_check(game.player_placeholder.global_position.distance_to(preflight) > .1, "normal movement preflight")
		var routes: Array[Dictionary] = [
			{"id":ForagingRegistry.ROD_ORIGIN,"approach":Vector3(-6.5,0,15)},
			{"id":"moonflower-01","approach":Vector3(27.5,.25,-2)},
			{"id":"moonflower-02","approach":Vector3(34.75,.25,7)},
			{"id":"moonflower-03","approach":Vector3(30.75,.5,-9)}]
		for route: Dictionary in routes:
			if not await _walk(route.approach,route.id): break
			game._refresh_interaction()
			_check(game.selected_interaction != null and game.selected_interaction.instance_id == route.id, "normal walking selects " + route.id)
			await _pause()
			await _capture("walk-approach-" + route.id)
			await _resume()
			if route.id == ForagingRegistry.ROD_ORIGIN:
				_key(KEY_E,true)
				await create_timer(.15).timeout
				_check(game.foraging_hold.active() and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0, "cancel attempt starts without reward")
				await _capture_live("rod-hold-progress",true)
				_key(KEY_E,false)
				_check(not game.foraging_hold.active() and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0, "release cancels actual hold")
				await _capture_live("rod-release-cancel",false)
			_key(KEY_E,true)
			await create_timer(.8).timeout
			_check(not game.foraging_hold.active() and game.session.foraging.is_collected(route.id), "normal held completion " + route.id)
			await create_timer(.2).timeout
			_key(KEY_E,false)
			await _pause()
			await _capture("walk-gathered-" + route.id)
			await _resume()
		await _pause()
		_check(game.session.inventory.count("item-moonflower") == 3 and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.world_host.current_location.foraging_pickups.targets.is_empty(), "ordinary four-node count/absence")
		var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
		_check(saved.ok,saved.get("error","GUI Save failed"))
		var oracle: Dictionary = TestRunSnapshot.oracle(game.session)
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.WRITE)
		_check(file != null,"oracle file")
		if file != null:
			file.store_var(oracle)
			file.close()
		await _capture("gui-save-confirmed",true)
	else:
		var file: FileAccess = FileAccess.open(oracle_path,FileAccess.READ)
		_check(file != null,"independent writer oracle")
		if file != null:
			var oracle: Dictionary = file.get_var(false)
			file.close()
			var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
			_check(loaded.ok,loaded.get("error","GUI Load failed"))
			var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
			if disk.session != null:
				var comparison: PackedStringArray = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
				_check(comparison.is_empty(),"exact whole-save restart: " + str(comparison))
			else: _check(false,"typed disk read failed")
			_check(game.world_host.current_location.foraging_pickups.targets.is_empty() and not game.foraging_hold.active(), "restored absence/no hold")
			await _capture("gui-load-confirmed",true)
			await _resume()
			if await _walk(Vector3(-6.5,0,15),"restored-rod-revisit"):
				_check(not game.world_host.current_location.foraging_pickups.targets.has(ForagingRegistry.ROD_ORIGIN), "rod stays absent on normal revisit")
				await _pause()
				await _capture("restored-rod-absent")
	_check(TestRunEvidence.write_json(phase + "-index.json", {"task":"F005", "phase":phase, "proof":"fresh ordinary viewport walk/E/GUI; no teleport/state fixture", "engine_pid":OS.get_process_id(), "user_data":OS.get_user_data_dir(), "engine":Engine.get_version_info()["string"], "views":views,"live_frames":live_frames,"traces":traces,"failures":failures}),"write render evidence")
	_set_keys([])
	_key(KEY_E,false)
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F005 render ",phase," ","PASS" if failures.is_empty() else "FAIL","; captures=",views.size(),"; live frames=",live_frames.size())
	quit(0 if failures.is_empty() else 1)

func _walk(goal: Vector3,label: String) -> bool:
	# Thin adapter keeps legacy scenario traces; movement belongs to shared support.
	var result: Dictionary = await TestRunJourney.walk(game,goal,label)
	traces.append(result)
	_check(result.ok,result.error)
	print("Ordinary walk ",label," ","arrived " + str(result.get("actual",[])) if result.ok else result.error)
	return result.ok

func _set_keys(next: Array[int]) -> void:
	for code: int in keys:
		if not code in next: _key(code,false)
	for code: int in next:
		if not code in keys: _key(code,true)
	keys = next.duplicate()

func _pause() -> void:
	if not paused:
		_key(KEY_ESCAPE,true)
		_key(KEY_ESCAPE,false)
	for frame: int in range(3): await process_frame
	_check(paused and game.ui.pause_overlay.visible,"pause checkpoint")

func _resume() -> void:
	var result: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	_check(result.ok,result.get("error","GUI Resume"))
	for frame: int in range(3): await process_frame

func _capture(label: String,overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game,phase + "-" + label,directory,"debug-input",overlay,"Fresh ordinary camera-relative viewport WASD/E/GUI, no placement or reward fixtures")
	_check(result.ok,result.get("error","capture"))
	if result.ok: views.append(result)

func _capture_live(label: String,expect_hold: bool) -> void:
	var result: Dictionary = await TestRunInteractionCapture.hold(game,phase + "-" + label,directory,"debug-input","Actual live E hold/release after ordinary walk; time continues during capture",expect_hold)
	_check(result.ok,result.get("error","hold capture"))
	if result.ok: live_frames.append(result)

func _key(code: int,down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	root.push_input(event,true)

func _check(condition: bool,message: String) -> void:
	if not condition: failures.append(message)
