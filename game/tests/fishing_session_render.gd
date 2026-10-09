extends "res://tests/support/fishing_root_fixture.gd"
## FS005 provisional root feedback, live-phase provenance and actual GUI save/load.
var views: Array[Dictionary] = []

func _exercise() -> void:
	suite = "session-render"
	_check(DisplayServer.get_name() != "headless","actual renderer")
	_cast()
	game.set_process(true) # Real elapsed world time throughout all active captures.
	await _live_capture("waiting","waiting")
	var deadline: int = Time.get_ticks_msec()+5000
	while game.fishing.active() and game.fishing.snapshot().phase == "waiting" and Time.get_ticks_msec() < deadline:
		await process_frame
	_check(game.fishing.snapshot().phase == "bite","live wait reaches bite")
	await _live_capture("bite","bite")
	_key(KEY_E,true)
	_check(game.fishing.snapshot().phase == "fighting","actual fresh viewport E hooks live bite")
	await _live_capture("fight","fighting")
	_key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible and game.fishing.mode() == "idle","Esc cancels live fight and verifies pause")
	await _pause_capture("canceled-pause","Actual viewport F/click/E/Esc with synthetic pose and ordinary seeded encounter. Esc canceled live fight before verified pause.")
	var resumed: Dictionary = await TestRunGui.activate(game,game.ui.resume_button,func() -> bool: return not paused and game.player_placeholder.controls_enabled)
	_check(resumed.ok,resumed.get("error","GUI resume"))
	game.set_process(false) # Legal deterministic synthetic timing for reward proof.
	_cast()
	_land()
	game.set_process(true)
	_key(KEY_B)
	game._select_inventory_item("item-bluegill")
	var bag: Dictionary = await TestRunInteractionCapture.backpack(game,"fish-in-bag",TestRunEvidence.directory(),"synthetic","FS005 legal synthetic feedback trajectory landed one bluegill; actual B opens existing bag. No ordinary unforced catch claim.")
	_check(bag.ok,bag.get("error","bag capture"))
	if bag.ok: views.append(bag)
	_key(KEY_B)
	_key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible,"stable GUI Save checkpoint")
	var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved.") and FileAccess.file_exists(game.save_repository.path))
	_check(saved.ok,saved.get("error","GUI Save"))
	var oracle: String = _facts()
	await _pause_capture("saved-fish","Actual paused GUI Save of synthetic landed fish and selected fish; no fishing phase in durable snapshot.")
	game.session.inventory.consume("item-bluegill") # Isolated restoration witness only.
	game.ui.show_save_status("Load fixture witness.")
	var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save and _facts() == oracle)
	_check(loaded.ok,loaded.get("error","GUI Load"))
	_check(game.fishing.mode() == "idle" and game.session.inventory.count("item-bluegill") == 1 and game.session.inventory.snapshot().active_item_id == "item-bluegill","GUI Load exact fish/selection; no attempt resumes")
	await _pause_capture("loaded-fish","Actual same-process GUI Load matches complete exact typed saved state. Independent-process and ordinary routes remain FS007.")
	_check(TestRunEvidence.write_json("session-render-index.json",{"task":"FS005","proof":"synthetic pose/RNG and reward timing; actual root viewport controls, genuinely live waiting/bite/fight captures, GUI Save/Load; no ordinary or native catch claim","views":views,"assertions":assertions+1,"failures":failures}),"render index")

func _pause_capture(label: String, note: String) -> void:
	var captured: Dictionary = await TestRunCapture.capture(game,label,TestRunEvidence.directory(),"synthetic",true,note)
	_check(captured.ok,captured.get("error",label))
	if captured.ok: views.append(captured)

func _live_capture(label: String, expected: String) -> void:
	# Local read-only live capture until FS006 extends shared observations. Never
	# pause an attempt or freeze timing for a screenshot; check phase after drawing.
	var before: Dictionary = game.fishing.snapshot()
	var owner: GameSession = game.session
	var location: PrototypeLocation = game.world_host.current_location
	var started: int = Time.get_ticks_msec()
	var stable: bool = not paused and not game.ui.pause_overlay.visible and before.phase == expected
	for frame: int in range(4):
		await process_frame
		stable = stable and game.fishing.active() and game.fishing.snapshot().token == before.token and game.fishing.snapshot().phase == expected and game.session == owner and game.world_host.current_location == location and not paused
	await RenderingServer.frame_post_draw
	var after: Dictionary = game.fishing.snapshot()
	stable = stable and after.phase == expected and after.token == before.token and game.fishing.active() and not paused and not game.ui.pause_overlay.visible
	_check(stable,"live capture phase/token provenance " + label)
	if not stable: return
	var path: String = TestRunEvidence.path(label+".png")
	_check(not path.is_empty(),"live capture owned output path")
	if path.is_empty(): return
	var image: Image = root.get_texture().get_image()
	_check(image.save_png(path) == OK,"save live PNG " + label)
	views.append({"label":label,"path":ProjectSettings.globalize_path(path),"kind":"synthetic","overlay":false,"paused":false,"note":"Actual live root phase under synthetic pose/RNG; automatic world/challenge time continues while settling/drawing.","phase_before":before,"phase_after":after,"elapsed_ms":Time.get_ticks_msec()-started,"dimensions":[image.get_width(),image.get_height()],"engine":Engine.get_version_info(),"session_seconds":game.session.elapsed_play_seconds})
