extends Node
## Opt-in local developer input driver. Never modifies gameplay/session facts.

const KEYS: Dictionary[String, int] = {
	"W": KEY_W, "A": KEY_A, "S": KEY_S, "D": KEY_D,
	"P": KEY_P, "E": KEY_E, "J": KEY_J, "B": KEY_B, "ESC": KEY_ESCAPE, "TAB": KEY_TAB, "ENTER": KEY_ENTER,
	"+": KEY_EQUAL, "-": KEY_MINUS,
	"SPACE": KEY_SPACE, "R": KEY_R,
}
var game: Node3D
var directory: String
var boot_id: String
var busy: bool = false
var held: Dictionary[String, bool] = {}
var mouse_held: bool = false
var mouse_position: Vector2 = Vector2.ZERO
var contacts: PackedStringArray = []


func start(root_game: Node3D, output_directory: String) -> void:
	game = root_game
	directory = output_directory.simplify_path().trim_suffix("/")
	# Exported validation executables live in builds/windows-validation; their
	# adjacent playtest directory remains inside the project's ignored builds.
	var allowed: String = ProjectSettings.globalize_path("res://../builds/playtest/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("../playtest/")
	allowed = allowed.replace("\\", "/").simplify_path().trim_suffix("/")
	if not directory.begins_with(allowed + "/") or directory == allowed:
		push_error("Playtest directory must be a child of builds/playtest")
		queue_free()
		return
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		push_error("Cannot create playtest directory: " + directory)
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	boot_id = str(Time.get_unix_time_from_system()) + "-" + str(OS.get_process_id())
	_write_json("ready.json", {"boot_id": boot_id, "pid": OS.get_process_id(), "protocol": 1})
	print("P003 live playtest bridge ready: ", directory)


func _process(_delta: float) -> void:
	if busy:
		for index: int in range(game.player_placeholder.get_slide_collision_count()):
			var collision: KinematicCollision3D = game.player_placeholder.get_slide_collision(index)
			var collider: Object = collision.get_collider()
			if is_instance_valid(collider) and absf(collision.get_normal().y) < 0.5:
				var name: String = str(collider.name)
				if not contacts.has(name):
					contacts.append(name)
		return
	if directory.is_empty() or not FileAccess.file_exists(directory.path_join("request.json")):
		return
	var request_path: String = directory.path_join("request.json")
	# Windows publication can briefly deny a read while the sender's rename
	# handle closes. Never delete a command whose bytes were not actually read.
	var request_file: FileAccess = FileAccess.open(request_path, FileAccess.READ)
	if request_file == null:
		return
	var raw: String = request_file.get_as_text()
	var read_error: Error = request_file.get_error()
	request_file.close()
	if read_error != OK and read_error != ERR_FILE_EOF:
		return
	if DirAccess.remove_absolute(request_path) != OK:
		push_error("Cannot consume playtest request")
		return
	var parsed: Variant = JSON.parse_string(raw) if raw.length() <= 16384 else null
	if not parsed is Dictionary:
		push_error("Playtest request must be a JSON object <=16KiB")
		return
	var request: Dictionary = parsed
	var id: String = str(request.get("id", ""))
	var valid_id: RegEx = RegEx.create_from_string("^[A-Za-z0-9_-]{1,64}$")
	if valid_id.search(id) == null:
		push_error("Playtest request requires a safe id")
		return
	if FileAccess.file_exists(directory.path_join(id + ".json")):
		return # Idempotent request IDs never replay input.
	var error: String = _validate(request)
	if not error.is_empty():
		_write_json(id + ".json", {"id": id, "ok": false, "error": error})
		return
	busy = true
	_execute(request)


func _validate(request: Dictionary) -> String:
	if request.get("boot_id") != boot_id:
		return "stale or missing boot_id"
	var steps: Variant = request.get("steps")
	if not steps is Array or steps.is_empty() or steps.size() > 32:
		return "steps must contain 1..32 operations"
	var total_ms: float = 0.0
	var step_index: int = 0
	for step: Variant in steps:
		if not step is Dictionary:
			return "step must be an object"
		var op: String = str(step.get("op", ""))
		if op in ["hold", "key_down", "key_up"]:
			var keys: Variant = step.get("keys")
			if not keys is Array or keys.is_empty() or keys.size() > 8:
				return "keys must contain 1..8 supported key names"
			for key: Variant in keys:
				if not key is String or not KEYS.has(key):
					return "unsupported key: " + str(key)
		elif op in ["pointer", "click", "mouse_down", "mouse_up"]:
			for axis: String in ["x", "y"]:
				if not step.get(axis) is float and not step.get(axis) is int:
					return "pointer requires numeric x/y viewport coordinates"
				if not is_finite(float(step[axis])) or absf(float(step[axis])) > 8192:
					return "pointer coordinate out of range"
		elif op == "quit":
			if step_index != steps.size() - 1:
				return "quit must be the last operation"
		elif op not in ["wait", "observe", "capture"]:
			return "unsupported operation: " + op
		if op in ["hold", "wait"]:
			var duration: Variant = step.get("duration_ms")
			if not duration is int and not duration is float:
				return "hold/wait requires duration_ms"
			if not is_finite(float(duration)) or float(duration) < 16 or float(duration) > 5000:
				return "duration_ms must be 16..5000"
			total_ms += float(duration)
		step_index += 1
	if total_ms > 30000:
		return "request duration exceeds 30 seconds"
	return ""


func _execute(request: Dictionary) -> void:
	var id: String = request["id"]
	var result: Dictionary = {"id": id, "boot_id": boot_id, "ok": true, "before": _observe(), "steps": []}
	var index: int = 0
	for step: Dictionary in request["steps"]:
		contacts.clear()
		var started: int = Time.get_ticks_msec()
		var op: String = step["op"]
		match op:
			"hold", "key_down":
				for key: String in step["keys"]:
					_send_key(key, true)
				if op == "hold":
					await _wait_milliseconds(int(ceil(float(step["duration_ms"]))))
					for key: String in step["keys"]:
						_send_key(key, false)
			"key_up":
				for key: String in step["keys"]:
					_send_key(key, false)
			"wait":
				await _wait_milliseconds(int(ceil(float(step["duration_ms"]))))
			"pointer", "click", "mouse_down", "mouse_up":
				mouse_position = Vector2(float(step["x"]), float(step["y"]))
				var event: InputEventMouseMotion = InputEventMouseMotion.new()
				event.position = mouse_position
				get_viewport().push_input(event, true)
				if op in ["click", "mouse_down"]:
					_send_mouse(true)
				if op in ["click", "mouse_up"]:
					_send_mouse(false)
		await get_tree().process_frame
		await get_tree().process_frame
		var observation: Dictionary = _observe()
		observation["op"] = op
		observation["elapsed_ms"] = Time.get_ticks_msec() - started
		observation["contacts_during_step"] = Array(contacts)
		if op == "capture":
			if DisplayServer.get_name() == "headless":
				result["ok"] = false
				result["error"] = "capture requires a rendered window"
			else:
				var image: Image = get_viewport().get_texture().get_image()
				var image_path: String = directory.path_join("%s-%02d.png" % [id, index])
				if image == null or image.is_empty() or image.save_png(image_path) != OK:
					result["ok"] = false
					result["error"] = "viewport capture failed"
				else:
					observation["image_path"] = image_path
		result["steps"].append(observation)
		index += 1
	# Prevent interrupted/client-forgotten key sequences from leaving keys held.
	for key: String in held.keys():
		_send_key(key, false)
	if mouse_held:
		_send_mouse(false)
	result["after"] = _observe()
	_write_json(id + ".json", result)
	busy = false
	if request["steps"][-1]["op"] == "quit":
		# Publish the response before requesting normal application shutdown.
		var event: InputEventKey = InputEventKey.new()
		event.keycode = KEY_F10
		event.physical_keycode = KEY_F10
		event.pressed = true
		get_viewport().push_input(event, true)


func _send_key(key: String, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEYS[key]
	event.physical_keycode = KEYS[key]
	event.pressed = pressed
	if pressed:
		held[key] = true
	else:
		held.erase(key)
	get_viewport().push_input(event, true)


func _wait_milliseconds(duration_ms: int) -> void:
	# Timers consume the frame delta that preceded their creation. Use a monotonic
	# deadline so a slow capture frame cannot shorten a requested key hold.
	var deadline: int = Time.get_ticks_msec() + duration_ms
	while Time.get_ticks_msec() < deadline:
		await get_tree().process_frame


func _send_mouse(pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = mouse_position
	event.global_position = mouse_position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	mouse_held = pressed
	get_viewport().push_input(event, true)


func _observe() -> Dictionary:
	var actor: ActorPlaceholder = game.player_placeholder
	var rig: PrototypeCameraRig = game.camera_rig
	var focus: Control = get_viewport().gui_get_focus_owner()
	return {
		"combat_direction": _vector(actor.combat.direction), "combat_attacking": actor.combat.attacking, "combat_elapsed": actor.combat.elapsed,
		"dodge_left": actor.combat.dodge_left,
		"guardian": {"health": game.guardian.state.health, "position": _vector(game.guardian.global_position), "screen": _point(rig.camera.unproject_position(game.guardian.global_position)), "attacking": game.guardian.combat.attacking, "elapsed": game.guardian.combat.elapsed, "hit_ids": Array(game.guardian.combat.hit_ids)} if is_instance_valid(game.guardian) and game.guardian.is_inside_tree() else {},
		"player_screen": _point(rig.camera.unproject_position(actor.global_position)),
		"companion": {"health": game.companion.state.health, "position": _vector(game.companion.global_position), "screen": _point(rig.camera.unproject_position(game.companion.global_position)), "mode": game.companion_ai.mode, "attacking": game.companion.combat.attacking, "hit_ids": Array(game.companion.combat.hit_ids), "repaths": game.companion_ai.repaths, "catchups": game.companion_ai.catchups, "recoveries": game.companion_ai.recoveries, "route": Array(game.companion_ai.route), "enabled": game.companion_ai.enabled, "object_id": game.companion.get_instance_id()},
		"player_id": actor.state.instance_id, "location_id": game.session.current_location_id,
		"position": _vector(actor.global_position), "velocity": _vector(actor.velocity),
		"heading": _vector(-actor.visual_root.global_basis.z),
		"aim": _vector(actor.aim_marker.global_position), "aim_visible": actor.aim_marker.visible,
		"camera": rig.description(), "camera_position": _vector(rig.global_position), "camera_controls": TestRunObservation.camera(game),
		"paused": get_tree().paused, "pause_overlay_visible": game.ui.pause_overlay.visible, "controls_enabled": actor.controls_enabled,
		"window_focused": game.window_focused, "retrying": game.retrying,
		"accepted_keys": actor.movement_buttons.keys(), "ui_focus": str(focus.name) if focus != null else "",
		"play_seconds": game.session.elapsed_play_seconds,
		"health": actor.state.health, "spawn_id": game.session.current_spawn_id,
		"transitioning": game.world_host.transitioning,
		"transition_count": game.world_host.transition_count,
		"world_children": game.world_host.get_child_count(), "party_children": game.party.get_child_count(),
		"party_suspended": game.party.suspended,
		"actor_object_id": actor.get_instance_id(),
		"loading_save": game.loading_save, "save_status": game.ui.save_status.text,
		"save_path": ProjectSettings.globalize_path(game.save_repository.path),
		"party_member_ids": Array(game.session.party_member_ids),
		"interaction_id": game.selected_interaction.instance_id if is_instance_valid(game.selected_interaction) else "",
		"interaction_prompt": game.ui.travel_label.text,
		"dialogue_active": game.dialogue.active(),
		"dialogue_id": game.dialogue.snapshot().get("graph_id", "") if game.dialogue.active() else "",
		"dialogue_source_id": game.dialogue.snapshot().get("instance_id", ""),
		"dialogue_text": game.ui.dialogue_text.text if game.dialogue.active() else "",
		"dialogue_choice_id": game.dialogue.snapshot().get("selected_choice_id", ""),
		"dialogue_result": game.conversation_result.message,
		"dialogue_action_id": game.conversation_result.action_id,
		"dialogue_line_index": game.dialogue.snapshot().get("presentation_index", 0),
		"dialogue_next_screen": _point(game.ui.dialogue_next.get_global_rect().get_center()),
		"dialogue_choices": _choice_positions(),
		"counter": _counter_observation(),
		"relationship": SaveCodec.snapshot(game.session).relationship,
		"progression": SaveCodec.snapshot(game.session).progression,
		"hero_damage": actor.combat.damage, "upgrade_points": game.progression.available_points(),
		"upgrade_screen": _point(game.ui.upgrade_button.get_global_rect().get_center()),
		"quest_snapshot": SaveCodec.snapshot(game.session).quests,
		"completed_effect_ids": Array(game.session.completed_effect_ids),
		"backpack_open":game.backpack_open, "backpack_details":game.ui.backpack.details.text, "active_item_label":game.ui.active_item_label.text, "backpack_slots":game.ui.backpack.slot_ids.duplicate(), "journal_open": game.journal_open, "journal_text": game.ui.journal_text.text,
		"quest_objective": game.ui.objective_label.text,
		"environment": TestRunObservation.environment(game),
		"world_pickups":_pickup_observation(),
		"inventory":game.session.inventory.snapshot().to_dictionary(),
		"foraging":game.session.foraging.snapshot(),
		"item_drag":{"active":game.item_drag.active(),"instance_id":game.item_drag.instance_id,"preview_foot":TestRunObservation.vector(game.item_drag.preview_foot) if game.item_drag.preview_foot != null else null,"errors":game.item_drag.errors.duplicate()},
		"hold":{ "active":game.foraging_hold.active(), "progress":game.foraging_hold.progress(), "elapsed":game.foraging_hold.elapsed, "duration":game.foraging_hold.duration, "cancel":game.foraging_hold.last_cancel },
	}


func _vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _choice_positions() -> Dictionary:
	var positions: Dictionary = {}
	for child: Node in game.ui.dialogue_choices.get_children():
		if child is Button:
			positions[str(child.name)] = _point((child as Button).get_global_rect().get_center())
	return positions


func _counter_observation() -> Dictionary:
	if game.world_host.current_location == null or not game.world_host.current_location.has_node("MarisCounter"):
		return {}
	var counter: MarisCounter = game.world_host.current_location.get_node("MarisCounter") as MarisCounter
	return {"instance_id": counter.instance_id, "presentation": counter.presentation, "dialogue_id": counter.dialogue_id, "sign": counter.get_node("Sign").text, "service_board": counter.get_node("VisualRoot/ServiceBoard").text, "basic_visible": counter.get_node("VisualRoot/BasicSupplies").visible, "specialist_visible": counter.get_node("VisualRoot/SpecialistGear").visible}


func _point(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _write_json(name: String, value: Dictionary) -> void:
	var path: String = directory.path_join(name)
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		push_error("Cannot write playtest response: " + path)
		return
	file.store_string(JSON.stringify(value, "\t"))
	var error: Error = file.get_error()
	file.close()
	if error != OK or DirAccess.rename_absolute(path + ".tmp", path) != OK:
		push_error("Cannot finish playtest response: " + path)


func _exit_tree() -> void:
	if not directory.is_empty() and FileAccess.file_exists(directory.path_join("ready.json")):
		var ready: Variant = JSON.parse_string(FileAccess.get_file_as_string(directory.path_join("ready.json")))
		if ready is Dictionary and ready.get("boot_id") == boot_id:
			DirAccess.remove_absolute(directory.path_join("ready.json"))


func _pickup_observation() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var location: PrototypeLocation = game.world_host.current_location
	if location == null or location.foraging_pickups == null: return result
	var ids: Array[String] = []
	ids.assign(location.foraging_pickups.targets.keys())
	ids.sort()
	for id: String in ids:
		var target: PrototypeInteractable = location.foraging_pickups.targets[id]
		if not is_instance_valid(target) or not target.is_inside_tree() or target.is_queued_for_deletion(): continue
		result.append({"instance_id":id,"resource_id":target.foraging_action.resource_id,
			"kind":target.kind,"foot_xyz_m":_vector(target.global_position),
			"screen":_point(game.camera_rig.camera.unproject_position(target.global_position))})
	return result
