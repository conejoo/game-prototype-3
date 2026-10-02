extends Node
## Opt-in local developer input driver. Never modifies gameplay/session facts.

const KEYS: Dictionary[String, int] = {
	"W": KEY_W, "A": KEY_A, "S": KEY_S, "D": KEY_D,
	"P": KEY_P, "E": KEY_E, "ESC": KEY_ESCAPE, "TAB": KEY_TAB, "ENTER": KEY_ENTER,
	"+": KEY_EQUAL, "-": KEY_MINUS,
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
	var allowed: String = ProjectSettings.globalize_path("res://../builds/playtest/").simplify_path().trim_suffix("/")
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
			if absf(collision.get_normal().y) < 0.5:
				var name: String = str(collision.get_collider().name)
				if not contacts.has(name):
					contacts.append(name)
		return
	if directory.is_empty() or not FileAccess.file_exists(directory.path_join("request.json")):
		return
	var request_path: String = directory.path_join("request.json")
	var raw: String = FileAccess.get_file_as_string(request_path)
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
		"player_id": actor.state.instance_id, "location_id": game.session.current_location_id,
		"position": _vector(actor.global_position), "velocity": _vector(actor.velocity),
		"heading": _vector(-actor.visual_root.global_basis.z),
		"aim": _vector(actor.aim_marker.global_position), "aim_visible": actor.aim_marker.visible,
		"camera": rig.description(), "camera_position": _vector(rig.global_position),
		"paused": get_tree().paused, "controls_enabled": actor.controls_enabled,
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
	}


func _vector(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


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
