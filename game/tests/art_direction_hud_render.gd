extends "res://tests/support/fishing_root_fixture.gd"
## AD017: synthetic feet, inventory/encounter seed and dialogue binding; actual viewport input.
var captures: Array[Dictionary] = []
var geometry: Array[Dictionary] = []
const NOTE: String = "AD017 synthetic registered feet, rod pickup/seed and speaker binding; real viewport keys/buttons, live modal/fishing guards. No ordinary route/native/save/profile claim."
func _run() -> void:
	if DisplayServer.get_name() == "headless": push_error("AD017 requires renderer"); quit(1); return
	game = load("res://app/game_root.tscn").instantiate(); root.add_child(game)
	_check((await game.world_host.transition_finished)[0], "startup")
	DisplayServer.window_move_to_foreground()
	for frame: int in range(5): await process_frame
	var pickup: ForagingCommandResult = game.session.foraging.pickup(ForagingRegistry.LOCATION,ForagingRegistry.ROD_ORIGIN,ForagingRegistry.ROD_RESOURCE,game.session.foraging.revision())
	_check(pickup.accepted,"synthetic rod pickup")
	for dimensions: Vector2i in [Vector2i(960,640),Vector2i(1872,872)]:
		game.ui.show_foraging_progress(0,false)
		root.content_scale_size = dimensions
		root.size = dimensions
		var prefix: String = str(dimensions.x)
		for frame: int in range(5): await process_frame
		_check(root.get_visible_rect().size == Vector2(dimensions),prefix+" actual viewport dimensions")
		for ortho: bool in [true,false]:
			game.camera_rig.set_orthographic(ortho)
			_pose(Vector3(-5.996,0,10.58)); game.companion.global_position = Vector3(-4.484,0,10.284)
			game._refresh_interaction()
			for frame: int in range(10): await process_frame
			await _live(prefix+("-ortho" if ortho else "-perspective"),"world")
			_layout(prefix)
			_check(not game.ui.accepts_world_pointer(game.ui.pause_button.get_global_rect().get_center()),"header pointer owned")
			_check(not game.ui.accepts_world_pointer(game.ui.active_item_label.get_global_rect().get_center()),"footer pointer owned")
			_check(game.ui.accepts_world_pointer(Vector2(20,300)),"world pointer available")
			for point: Vector2 in [game.ui.objective_label.get_global_rect().get_center(), game.ui.travel_label.get_global_rect().get_center(), Vector2(15,20), game.ui.active_item_label.get_global_rect().get_center()]:
				_check(not game.ui.accepts_world_pointer(point),"visible HUD pointer owned")
				_click(point)
				await physics_frame
				_check(not game.player_placeholder.combat.busy(),"HUD click does not start attack")
			_key(KEY_ESCAPE)
			_check(paused and game.ui.pause_overlay.visible,"actual Esc pause")
			await _paused(prefix+("-ortho" if ortho else "-perspective")+"-pause")
			var settings: Dictionary = await TestRunGui.activate(game,game.ui.settings_button,func() -> bool: return game.ui.settings_open())
			_check(settings.ok,"keyboard settings outcome")
			await _paused(prefix+("-ortho" if ortho else "-perspective")+"-settings")
			_click(game.ui.debug_toggle.get_global_rect().get_center())
			for frame: int in range(5): await process_frame
			_check(game.debug_shortcuts_enabled and game.ui.camera_label.visible,"mouse debug enables existing diagnostics")
			_key(KEY_ESCAPE); _key(KEY_ESCAPE)
			_check(not paused,"settings Back then resume")
			await _live(prefix+("-ortho" if ortho else "-perspective")+"-debug","world")
			game._set_debug_shortcuts_enabled(false)
		_key(KEY_B)
		_check(game.backpack_open,"B opens actual bag")
		await _live(prefix+"-bag","backpack")
		_check(not game.ui.accepts_world_pointer(Vector2(20,300)),"bag blocks world pointer")
		game.ui.backpack.close_button.grab_focus(); _key(KEY_ENTER)
		_check(not game.backpack_open,"Enter closes bag")
		_key(KEY_J); await _live(prefix+"-journal","journal")
		_click(game.ui.people_tab.get_global_rect().get_center())
		await _live(prefix+"-people","journal")
		_check(game.ui.journal_tab == "people" and not game.ui.accepts_world_pointer(Vector2(20,300)),"mouse people tab and world gate")
		_key(KEY_ESCAPE)
		_pose(Vector3(-5.996,0,10.58)); game._refresh_interaction()
		_key(KEY_E)
		_check(game.dialogue.active(),"actual E opens selected live Maris contact")
		await _live(prefix+"-dialogue","dialogue")
		_check(not game.ui.accepts_world_pointer(Vector2(20,300)),"dialogue blocks world pointer")
		if game.ui.dialogue_choices.get_child_count() > 0:
			var choice: Button = game.ui.dialogue_choices.get_child(0)
			choice.grab_focus(); _key(KEY_ENTER)
			await _live(prefix+"-choice","dialogue")
		_key(KEY_ESCAPE)
		_cast(); await _live(prefix+"-fishing-waiting","waiting")
		_check(not game.ui.accepts_world_pointer(game.ui.fishing_view.reel_button.get_global_rect().get_center()),"fishing owns pointer")
		game._cancel_fishing("fixture reset")
		_phase("fighting"); await _live(prefix+"-fishing-fighting","fighting")
		_check(game.ui.combat_label.is_visible_in_tree() and game.ui.companion_label.is_visible_in_tree(),"health retained while fishing")
		_check(game.ui.fishing_view.panel.get_global_rect().end.y < game.ui.get_node("Screen/Footer").get_global_rect().position.y,"fishing panel above health bar")
		_key(KEY_F)
		_key(KEY_E,false)
		_check(not game.fishing.active() and not game.ui.fishing_view._pointer_held,"F releases fishing")
		_key(KEY_ESCAPE)
		_check(paused and game.ui.pause_overlay.visible,"final safe checkpoint")
		_key(KEY_ESCAPE)
		game.session.environment.day_index = 2
		game.session.environment.day_cycle_progress = .625
		game.session.environment.weather_seed = 30
		game._present_environment()
		_pose(Vector3(-5.996,0,10.58))
		for frame: int in range(12): await process_frame
		await _live(prefix+"-night","world")
		game.session.environment.day_cycle_progress = .05
		game.session.environment.weather_seed = 6
		game._present_environment()
	game._set_paused(true)
	_check(TestRunEvidence.write_json("hud-index.json",{"task":"AD017","assertions":assertions,"failures":failures,"views":captures,"geometry":geometry,"pid":OS.get_process_id(),"note":NOTE}),"report")
	game.queue_free(); await process_frame; paused = false
	for failure: String in failures: push_error(failure)
	print("AD017 HUD captures=",captures.size()," assertions=",assertions," failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _live(label: String, mode: String) -> void:
	var result: Dictionary
	match mode:
		"backpack": result = await TestRunInteractionCapture.backpack(game,label,TestRunEvidence.directory(),"synthetic",NOTE)
		"dialogue": result = await TestRunInteractionCapture.dialogue(game,label,TestRunEvidence.directory(),"synthetic",NOTE)
		"journal": result = await TestRunInteractionCapture.journal(game,label,TestRunEvidence.directory(),"synthetic",NOTE)
		"world": result = await TestRunInteractionCapture.hold(game,label,TestRunEvidence.directory(),"synthetic",NOTE,false)
		_: result = await TestRunInteractionCapture.fishing(game,label,TestRunEvidence.directory(),"synthetic",NOTE,mode)
	_check(result.ok,label+": "+str(result.get("error","")))
	if result.ok: captures.append(result)

func _paused(label: String) -> void:
	_check(not game.ui.accepts_world_pointer(Vector2(20,300)),label+" world blocked")
	var result: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",true,NOTE)
	_check(result.ok,label+": "+str(result.get("error","")))
	if result.ok: captures.append(result)

func _layout(label: String) -> void:
	var rect: Rect2 = root.get_visible_rect()
	var header: Rect2 = game.ui.get_node("Screen/Header").get_global_rect()
	var footer: Rect2 = game.ui.get_node("Screen/Footer").get_global_rect()
	var objective: Rect2 = game.ui.objective_label.get_global_rect()
	_check(rect.encloses(header) and rect.encloses(footer) and rect.encloses(objective),label+" persistent panels fit")
	_check(header.end.y <= objective.position.y and objective.end.y < footer.position.y,label+" persistent panels do not overlap")
	_check(header.size.y + footer.size.y <= rect.size.y * .25,label+" persistent bars <=25% height")
	for button: Button in [game.ui.pause_button,game.ui.journal_button,game.ui.people_button,game.ui.backpack_button]:
		_check(header.encloses(button.get_global_rect()),label+" header button fits")
	_check(game.ui.objective_label.text.length() > 8 and not game.ui.time_label.text.is_empty(),label+" quest/time available")
	var visible_labels: int = 0
	for entry: Dictionary in game.ui.storybook.labels:
		if is_instance_valid(entry.node) and entry.node.visible: visible_labels += 1
	_check(visible_labels <= 1,label+" at most one static world label")
	geometry.append({"label":label,"viewport":str(rect),"header":str(header),"footer":str(footer),"quest":str(objective),"prompt":game.ui.travel_label.text,"prompt_visible":game.ui.travel_label.visible,"combat":game.ui.combat_label.text,"labels":game.ui.storybook.labels.size()})
