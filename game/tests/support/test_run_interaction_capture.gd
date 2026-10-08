class_name TestRunInteractionCapture
extends RefCounted
## Read-only live viewport evidence. Never pauses, freezes time, or sends input.
const SETTLE_FRAMES: int = 4

static func hold(game: Node3D, label: String, directory: String, kind: String, note: String, active: bool = true) -> Dictionary:
	return await _capture(game, label, directory, kind, note, "hold" if active else "hold-released")

static func backpack(game: Node3D, label: String, directory: String, kind: String, note: String) -> Dictionary:
	return await _capture(game, label, directory, kind, note, "backpack")

static func drag(game: Node3D, label: String, directory: String, kind: String, note: String) -> Dictionary:
	return await _capture(game, label, directory, kind, note, "drag")

static func dialogue(game: Node3D, label: String, directory: String, kind: String, note: String) -> Dictionary:
	return await _capture(game, label, directory, kind, note, "dialogue")

static func journal(game: Node3D, label: String, directory: String, kind: String, note: String) -> Dictionary:
	return await _capture(game, label, directory, kind, note, "journal")

static func _capture(game: Node3D, label: String, directory: String, kind: String, note: String, mode: String) -> Dictionary:
	if DisplayServer.get_name() == "headless": return _failure("capture requires real renderer")
	# Share pause capture's lock: a hidden pause overlay cannot masquerade as live play.
	if TestRunCapture._capturing: return _failure("capture already in progress")
	if kind not in ["debug-input", "synthetic"] or note.strip_edges().is_empty():
		return _failure("capture requires explicit provenance and note")
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[A-Za-z0-9_-]{1,96}$")
	if pattern.search(label) == null: return _failure("invalid capture label")
	var checked: Dictionary = TestRunEvidence.validate(directory, label + ".png")
	if not checked.ok: return checked
	var error: String = _guard(game, mode)
	if not error.is_empty(): return _failure(error)
	var tree: SceneTree = game.get_tree()
	var owner: GameSession = game.session
	var location_id: int = game.world_host.current_location.get_instance_id()
	var target: PrototypeInteractable = game.foraging_hold.target() if mode == "hold" else game.item_drag.target() if mode == "drag" else null
	var target_id: int = target.get_instance_id() if target != null else 0
	var items: String = _items(game)
	var conversation_token: String = game.dialogue.snapshot().get("token", "")
	var started: int = Time.get_ticks_msec()
	TestRunCapture._capturing = true
	for frame: int in range(SETTLE_FRAMES):
		await tree.process_frame
		error = _stable_guard(game, mode, owner, location_id, target_id, items)
		if mode == "dialogue" and game.dialogue.snapshot().get("token", "") != conversation_token: error = "conversation changed while settling"
		if not error.is_empty():
			TestRunCapture._capturing = false
			return _failure(error)
	await RenderingServer.frame_post_draw
	error = _stable_guard(game, mode, owner, location_id, target_id, items)
	if mode == "dialogue" and game.dialogue.snapshot().get("token", "") != conversation_token: error = "conversation changed while settling"
	if error.is_empty() and mode == "backpack" and not tree.root.get_visible_rect().encloses(game.ui.backpack.panel.get_global_rect()):
		error = "backpack panel exceeds viewport"
	# Revalidate path after awaits (including ownership, links, and no overwrite).
	checked = TestRunEvidence.validate(directory, label + ".png")
	if not checked.ok: error = checked.error
	if not error.is_empty():
		TestRunCapture._capturing = false
		return _failure(error)
	if DirAccess.make_dir_recursive_absolute(checked.directory) != OK:
		TestRunCapture._capturing = false
		return _failure("cannot create capture directory")
	var picture: Image = tree.root.get_texture().get_image()
	var saved: Error = picture.save_png(checked.path)
	TestRunCapture._capturing = false
	if saved != OK: return _failure("PNG failed: " + str(saved))
	var focus: Control = tree.root.gui_get_focus_owner()
	var result: Dictionary = {"ok":true, "mode":mode, "state_verified":true,
		"label":label, "path":checked.path, "kind":kind, "note":note,
		"paused":false, "pause_overlay_verified":false, "overlay":mode in ["backpack", "dialogue", "journal"],
		"settled_frames":SETTLE_FRAMES, "frame_post_draw_verified":true,
		"started_ticks_msec":started, "ticks_msec":Time.get_ticks_msec(),
		"controls_enabled":game.player_placeholder.controls_enabled, "window_focused":game.window_focused,
		"focus":str(focus.get_path()) if focus != null else "",
		"engine_pid":OS.get_process_id(), "engine":Engine.get_version_info()["string"],
		"viewport_size":[picture.get_width(), picture.get_height()], "camera":TestRunObservation.camera(game),
		"position":TestRunObservation.vector(game.player_placeholder.global_position),
		"location":game.session.current_location_id, "snapshot":SaveCodec.snapshot(game.session),
		"environment":TestRunObservation.environment(game), "prompt":game.ui.travel_label.text,
		"inventory":game.session.inventory.snapshot().to_dictionary()}
	if mode in ["hold", "hold-released"]:
		result.merge({"hold_active":game.foraging_hold.active(), "hold_progress":game.foraging_hold.progress(),
			"progress_visible":game.ui.gather_progress.is_visible_in_tree(), "e_down":game._e_down,
			"hold_verified":true, "instance_id":target.instance_id if target != null else ""})
	elif mode == "backpack":
		result.merge({"backpack_modal_verified":true, "panel_fits":true,
			"display_slot_ids":game.ui.backpack.slot_ids.duplicate(), "details":game.ui.backpack.details.text})
	elif mode == "dialogue":
		result.merge({"dialogue_modal_verified":true, "panel_fits":true,
			"conversation":game.dialogue.snapshot(), "display":game.ui.dialogue_view._snapshot.duplicate(true)})
	elif mode == "journal":
		result.merge({"journal_modal_verified":true, "panel_fits":true,
			"tab":game.ui.journal_tab, "selected_id":game.ui.people_view.selected_id})
	else:
		result.merge({"drag_verified":true, "instance_id":target.instance_id, "preview_visible":true,
			"preview_errors":game.item_drag.errors.duplicate(),
			"preview_foot":TestRunObservation.vector(game.item_drag.preview_foot) if game.item_drag.preview_foot != null else null})
	return result

static func _stable_guard(game: Variant, mode: String, owner: GameSession, location_id: int, target_id: int, items: String) -> String:
	var error: String = _guard(game, mode)
	if not error.is_empty(): return error
	if game.session != owner or game.world_host.current_location.get_instance_id() != location_id or _items(game) != items:
		return "capture owner/location/item facts changed while settling"
	if mode == "hold" and game.foraging_hold.target().get_instance_id() != target_id: return "hold target changed while settling"
	if mode == "drag" and game.item_drag.target().get_instance_id() != target_id: return "drag target changed while settling"
	return ""

static func _guard(game: Variant, mode: String) -> String:
	if not is_instance_valid(game) or game.is_queued_for_deletion() or not game.is_inside_tree(): return "capture game unavailable"
	if game.get_tree().paused or game.ui.pause_overlay.visible: return "live capture requires resumed tree and hidden pause overlay"
	if mode == "journal":
		if not game.window_focused or game.world_host.transitioning or game.loading_save or game.retrying or game.dialogue.active() or game.backpack_open or game.foraging_hold.active() or game.item_drag.active() or game.player_placeholder.state.health <= 0: return "journal capture input mode unavailable"
		if not game.journal_open or not game.ui.journal_overlay.is_visible_in_tree() or game.player_placeholder.controls_enabled or game.companion_ai.enabled: return "journal capture requires visible modal and blocked actors"
		var journal_focus: Control = game.get_viewport().gui_get_focus_owner()
		if journal_focus == null or not journal_focus.is_visible_in_tree() or not game.ui.journal_panel.is_ancestor_of(journal_focus): return "journal focus outside modal"
		if not game.get_viewport().get_visible_rect().encloses(game.ui.journal_panel.get_global_rect()): return "journal panel exceeds viewport"
		return ""
	if mode == "dialogue":
		if not game.window_focused or game.world_host.transitioning or game.loading_save or game.retrying or game.journal_open or game.backpack_open or game.foraging_hold.active() or game.item_drag.active(): return "dialogue capture input mode unavailable"
		if not game.dialogue.active() or not game.ui.dialogue_overlay.is_visible_in_tree() or game.player_placeholder.controls_enabled or game.companion_ai.enabled: return "dialogue capture requires visible modal and blocked actors"
		var modal_focus: Control = game.get_viewport().gui_get_focus_owner()
		if modal_focus == null or not game.ui.dialogue_panel.is_ancestor_of(modal_focus) or not modal_focus.is_visible_in_tree(): return "dialogue focus outside modal"
		if not game.get_viewport().get_visible_rect().encloses(game.ui.dialogue_panel.get_global_rect()): return "dialogue panel exceeds viewport"
		if game.ui.dialogue_view._snapshot.get("token", "") != game.dialogue.snapshot().get("token", ""): return "display cursor stale"
		return ""
	if not game.window_focused or game.world_host.transitioning or game.loading_save or game.retrying or game.dialogue.active() or game.journal_open or game.ui.settings_open() or game.player_placeholder.state.health <= 0:
		return "live capture input mode unavailable"
	if game.world_host.session != game.session or not is_instance_valid(game.world_host.current_location): return "capture world owner unavailable"
	var focus: Control = game.get_viewport().gui_get_focus_owner()
	if mode == "backpack":
		if not game.backpack_open or not game.ui.backpack.is_visible_in_tree() or game.player_placeholder.controls_enabled or game.foraging_hold.active() or game.item_drag.active():
			return "backpack capture requires visible modal and blocked world controls"
		if focus == null or not focus.is_visible_in_tree() or not game.ui.backpack.is_ancestor_of(focus): return "backpack focus outside modal"
		return ""
	if game.backpack_open or game.ui.backpack.visible or focus != null: return "live world capture blocked by modal/focus"
	if mode == "drag":
		var drag_state: WorldItemDrag = game.item_drag
		var pickup: PrototypeInteractable = drag_state.target()
		if not drag_state.active() or game.player_placeholder.controls_enabled or game.foraging_hold.active() or not game._drag_mouse_owned or not game._drag_input_allowed():
			return "drag capture requires active pointer ownership and blocked world controls"
		if drag_state.owner() != game.session or drag_state.expected_revision != game.session.foraging.revision() or drag_state.location_id != game.session.current_location_id or not game._reachable_rod(pickup) or pickup.instance_id != drag_state.instance_id or not pickup.global_position.is_equal_approx(drag_state.original_foot):
			return "drag target/owner/revision stale"
		if not is_instance_valid(game.drag_preview) or not game.drag_preview.is_inside_tree() or not game.drag_preview.is_visible_in_tree() or game.drag_preview.get_child_count() == 0: return "drag preview missing"
		var mesh: MeshInstance3D = game.drag_preview.get_child(0) as MeshInstance3D
		if mesh == null or mesh.mesh == null or not mesh.is_visible_in_tree(): return "drag preview mesh missing"
		return ""
	if not game.player_placeholder.controls_enabled or game.item_drag.active() or not game._foraging_input_allowed(): return "hold capture input unavailable"
	var hold_state: ForagingHoldController = game.foraging_hold
	if mode == "hold-released":
		return "released hold still active/pressed/visible" if hold_state.active() or game._e_down or game.ui.gather_progress.is_visible_in_tree() else ""
	var pickup: PrototypeInteractable = hold_state.target()
	if not hold_state.active() or not game._e_down or not game.ui.gather_progress.is_visible_in_tree(): return "hold capture requires pressed E, active hold and visible progress"
	if hold_state.owner() != game.session or hold_state.expected_revision != game.session.foraging.revision() or not is_instance_valid(pickup) or pickup.is_queued_for_deletion() or not pickup.is_inside_tree() or not game.world_host.current_location.is_ancestor_of(pickup): return "hold target/owner/revision stale"
	if not pickup.global_position.is_equal_approx(hold_state.target_position) or InteractionSelector.select(game.player_placeholder, game.world_host.current_location) != pickup or not pickup.validation_errors(game.catalog).is_empty(): return "hold target/range/LOS changed"
	if pickup.foraging_action == null or hold_state.action.location_id != game.session.current_location_id or hold_state.action.instance_id != pickup.instance_id or hold_state.action.resource_id != pickup.foraging_action.resource_id or hold_state.duration <= 0 or hold_state.elapsed >= hold_state.duration: return "hold identity/progress stale"
	return ""

static func _items(game: Node3D) -> String:
	return TestRunSnapshot.exact_json({"inventory":game.session.inventory.snapshot().to_dictionary(), "foraging":game.session.foraging.snapshot()})

static func _failure(error: String) -> Dictionary:
	return {"ok":false, "error":error}
