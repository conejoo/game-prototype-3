class_name TestRunGui
extends RefCounted
## Bounded real viewport focus/input. Never emit pressed or invoke button callbacks.

static func activate(game: Node3D, button: Button, outcome: Callable, max_steps: int = 16, max_frames: int = 600) -> Dictionary:
	var tree: SceneTree = game.get_tree()
	if DisplayServer.get_name() == "headless": return {"ok":false, "error":"GUI activation requires real renderer"}
	if not tree.paused or not game.ui.pause_overlay.visible:
		return {"ok":false, "error":"GUI activation lacks verified pause overlay"}
	if button == null or button.disabled or not button.is_visible_in_tree() or not game.ui.pause_overlay.is_ancestor_of(button):
		return {"ok":false, "error":"GUI target unavailable"}
	if not outcome.is_valid() or max_steps < 1 or max_steps > 64 or max_frames < 1 or max_frames > 600:
		return {"ok":false, "error":"GUI activation requires outcome and bounded limits"}
	if outcome.call(): return {"ok":false, "error":"GUI outcome already true before activation"}
	var visited: Array[Control] = []
	for step: int in range(max_steps):
		if not tree.paused or not game.ui.pause_overlay.visible:
			return {"ok":false, "error":"GUI pause changed during focus navigation"}
		var focus: Control = tree.root.gui_get_focus_owner()
		if focus == button: break
		if focus == null or not game.ui.pause_overlay.is_ancestor_of(focus) or visited.has(focus):
			return {"ok":false, "error":"GUI focus absent or cycle excludes target"}
		visited.append(focus)
		_key(tree.root, KEY_TAB)
		await tree.process_frame
	if tree.root.gui_get_focus_owner() != button:
		return {"ok":false, "error":"GUI focus budget exhausted"}
	if button.disabled or not button.is_visible_in_tree() or not tree.paused:
		return {"ok":false, "error":"GUI target changed before activation"}
	_key(tree.root, KEY_ENTER)
	for frame: int in range(max_frames):
		await tree.process_frame
		if outcome.call(): return {"ok":true, "frames":frame + 1, "focus_steps":visited.size()}
	return {"ok":false, "error":"GUI input completed without expected outcome"}


static func _key(viewport: Viewport, code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.pressed = pressed
		viewport.push_input(event)
