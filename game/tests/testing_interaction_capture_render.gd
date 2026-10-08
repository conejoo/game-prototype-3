extends SceneTree
## Synthetic tool-contract fixtures using real game input and actual viewport PNGs.
var game: Node3D
var failures: PackedStringArray = []
var views: Array[Dictionary] = []
var checks: int = 0
var directory: String
const NOTE: String = "Synthetic tool-contract fixture: actor placed near authored rod; real viewport E/B/pointer input; no normal-play claim"

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960,640)
	directory = TestRunEvidence.directory()
	if DisplayServer.get_name() == "headless" or directory.is_empty():
		push_error("interaction capture checks require renderer and report-dir")
		quit(1)
		return
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	await _deny("missing-hold", "hold")
	await _deny("missing-backpack", "backpack")
	await _deny("missing-drag", "drag")
	var pickup: PrototypeInteractable = game.world_host.current_location.foraging_pickups.targets[ForagingRegistry.ROD_ORIGIN]
	game.player_placeholder.global_position = pickup.global_position + Vector3(0,0,.8)
	for frame: int in range(12): await physics_frame
	var items: String = TestRunSnapshot.exact_json(game.session.foraging.snapshot())
	_key(KEY_E,true)
	_check(game.foraging_hold.active(), "actual E starts hold fixture")
	var denied: Dictionary = await TestRunInteractionCapture.hold(game,"bad-note",directory,"synthetic","")
	_check(not denied.ok, "missing provenance refused")
	denied = await TestRunInteractionCapture.hold(game,"bad-kind",directory,"native-input",NOTE)
	_check(not denied.ok, "viewport helper refuses native claim")
	denied = await TestRunInteractionCapture.hold(game,"../unsafe",directory,"synthetic",NOTE)
	_check(not denied.ok, "unsafe label refused")
	denied = await TestRunInteractionCapture.hold(game,"outside",ProjectSettings.globalize_path("res://../builds/testing/outside"),"synthetic",NOTE)
	_check(not denied.ok, "outside route refused")
	game.foraging_hold.expected_revision += 1
	await _deny("stale-hold", "hold")
	game.foraging_hold.expected_revision -= 1
	game.ui.gather_progress.hide()
	await _deny("hidden-hold", "hold")
	game.ui.gather_progress.show()
	game.window_focused = false
	await _deny("unfocused-hold", "hold")
	game.window_focused = true
	var before: float = game.foraging_hold.elapsed
	_during_capture.call_deferred()
	await _record("active-hold", "hold")
	_check(game.foraging_hold.active() and game._e_down and game.foraging_hold.elapsed > before and not paused, "capture keeps hold/input active and advances time")
	await _deny("active-as-released", "hold-released")
	_key(KEY_E,false)
	await _record("released-hold", "hold-released")
	_check(not game.foraging_hold.active() and not game._e_down, "released checkpoint preserved")
	_key(KEY_E,true)
	game._cancel_foraging_hold.call_deferred("capture cancellation fixture")
	await _deny("cancel-during-settle", "hold")
	_key(KEY_E,false)
	# Completion must fail active-state capture, never silently become a released image.
	_key(KEY_E,true)
	game.foraging_hold.elapsed = game.foraging_hold.duration - .001
	await _deny("complete-during-settle", "hold")
	_key(KEY_E,false)
	_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1, "completion fixture actually commits")
	# Restore a fresh synthetic session via actual GUI-free root restart, not capture mutation.
	game.queue_free()
	await process_frame
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	_key(KEY_B,true)
	_key(KEY_B,false)
	var focus: Control = root.gui_get_focus_owner()
	await _record("backpack-960", "backpack")
	_check(game.backpack_open and root.gui_get_focus_owner() == focus and not game.player_placeholder.controls_enabled, "modal capture preserves focus and controls")
	root.size = Vector2i(800,600)
	await _record("backpack-800", "backpack")
	root.size = Vector2i(960,640)
	game.player_placeholder.controls_enabled = true
	await _deny("enabled-backpack", "backpack")
	game.player_placeholder.controls_enabled = false
	focus.release_focus()
	await _deny("focusless-backpack", "backpack")
	focus.grab_focus()
	game.ui.backpack.hide()
	await _deny("hidden-backpack", "backpack")
	game.ui.backpack.show()
	game._close_backpack.call_deferred()
	await _deny("closed-during-settle", "backpack")
	# Real mouse press holds the authored rod; capture must leave it untouched.
	pickup = game.world_host.current_location.foraging_pickups.targets[ForagingRegistry.ROD_ORIGIN]
	game.player_placeholder.global_position = pickup.global_position + Vector3(0,0,.8)
	for frame: int in range(12): await physics_frame
	var point: Vector2 = game.camera_rig.camera.unproject_position(pickup.global_position + Vector3.UP * .08)
	_mouse(point,true)
	_check(game.item_drag.active(), "actual mouse starts drag fixture")
	game.item_drag.expected_revision += 1
	await _deny("stale-drag", "drag")
	game.item_drag.expected_revision -= 1
	game.drag_preview.hide()
	await _deny("hidden-drag", "drag")
	game.drag_preview.show()
	game.drag_preview.get_child(0).hide()
	await _deny("hidden-drag-mesh", "drag")
	game.drag_preview.get_child(0).show()
	game.player_placeholder.controls_enabled = true
	await _deny("enabled-drag", "drag")
	game.player_placeholder.controls_enabled = false
	await _record("live-drag", "drag")
	_check(game.item_drag.active() and game._drag_mouse_owned and not paused and TestRunSnapshot.exact_json(game.session.foraging.snapshot()) == items, "drag capture cannot commit/cancel/freeze")
	game._cancel_item_drag.call_deferred()
	await _deny("cancelled-drag", "drag")
	_mouse(point,false)
	game._set_paused(true)
	await _deny("paused-live", "hold-released")
	game.ui.pause_overlay.hide()
	await _deny("paused-hidden-overlay", "hold-released")
	game.ui.pause_overlay.show()
	var captured: Dictionary = await TestRunCapture.capture(game,"pause-intact",directory,"synthetic",true,NOTE)
	_check(captured.ok and paused and game.ui.pause_overlay.visible, "existing pause capture still works")
	if captured.ok: views.append(captured)
	game._set_paused(false)
	game.ui.pause_overlay.show()
	await _deny("overlay-with-resumed-tree", "hold-released")
	game.ui.pause_overlay.hide()
	await _record("released-after-failures", "hold-released")
	_check(not TestRunCapture._capturing, "capture lock released after failures")
	game.queue_free.call_deferred()
	await _deny("game-freed-during-settle", "hold-released")
	_check(not TestRunCapture._capturing, "freed game releases capture lock")
	_check(TestRunEvidence.write_json("check-index.json", {"views":views,"failures":failures,"checks":checks,"proof":NOTE}), "write evidence")
	for failure: String in failures: push_error(failure)
	print("Interaction capture render: %s checks=%d captures=%d" % ["PASS" if failures.is_empty() else "FAIL",checks,views.size()])
	if is_instance_valid(game): game.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _during_capture() -> void:
	var refused: Dictionary = await TestRunCapture.capture(game,"concurrent-pause",directory,"synthetic",false,NOTE)
	_check(not refused.ok and refused.error == "capture already in progress", "pause/live captures share lock")
	refused = await TestRunInteractionCapture.hold(game,"concurrent-live",directory,"synthetic",NOTE)
	_check(not refused.ok and refused.error == "capture already in progress", "overlapping live capture refused")

func _capture(label: String, mode: String) -> Dictionary:
	match mode:
		"backpack": return await TestRunInteractionCapture.backpack(game,label,directory,"synthetic",NOTE)
		"drag": return await TestRunInteractionCapture.drag(game,label,directory,"synthetic",NOTE)
	return await TestRunInteractionCapture.hold(game,label,directory,"synthetic",NOTE,mode == "hold")

func _record(label: String, mode: String) -> void:
	var result: Dictionary = await _capture(label,mode)
	_check(result.ok,result.get("error","capture " + label))
	if not result.ok: return
	views.append(result)
	_check(result.settled_frames == 4 and result.frame_post_draw_verified and result.state_verified and result.ticks_msec >= result.started_ticks_msec, "settled frame/timing metadata " + label)
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(result.path)
	var denied: Dictionary = await _capture(label,mode)
	_check(not denied.ok and FileAccess.get_file_as_bytes(result.path) == bytes, "overwrite refused " + label)

func _deny(label: String, mode: String) -> void:
	var denied: Dictionary = await _capture(label,mode)
	_check(not denied.ok and not FileAccess.file_exists(directory.path_join(label + ".png")), "refusal produced image: " + label)

func _key(code: int, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	root.push_input(event,true)

func _mouse(point: Vector2, down: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event,true)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)
