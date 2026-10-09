extends SceneTree
## Rules/lifecycle checks. Normal rendered gate travel is verified separately.

var failures: Array[String] = []
var game: Node3D
var actor: ActorPlaceholder
var host: PrototypeWorldHost
var original_actor_id: int
var original_state: ActorState


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(960, 640)
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	# Unsafe geometry is test-only content, never added to the production catalog.
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"
	unsafe.display_name = "Unsafe placement test fixture"
	unsafe.prototype_fixture = true
	unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = PackedStringArray(["unsafe-no-floor", "unsafe-blocked"])
	manifest.definitions.append(unsafe)
	game.content_manifest = manifest
	root.add_child(game)
	await _settle()
	actor = game.player_placeholder
	host = game.world_host
	original_actor_id = actor.get_instance_id()
	original_state = actor.state
	original_state.health = 37
	var companion_id: int = game.companion.get_instance_id()
	var companion_state: ActorState = game.companion.state
	companion_state.health = 43
	game.session.elapsed_play_seconds = 12.0
	_check(game.session.current_location_id == "prototype-alderwake", "Normal start must load Alderwake")
	_check(actor.is_on_floor(), "Initial spawn not grounded")
	_check(not host.current_location.can_travel(actor), "Arrival/start must be outside gate range")
	_key(KEY_E, true)
	_key(KEY_E, false)
	_check(not host.transitioning and host.transition_count == 1, "E outside gate triggered travel")
	# Named civic contacts may legitimately answer E at the fresh spawn. Restore
	# ordinary input before the rejected-travel transaction oracle below.
	if game.dialogue.active():
		_check(game.dialogue.snapshot().npc_id in NpcRegistry.ENABLED, "Outside-gate E opened an enabled ordinary contact")
		_key(KEY_ESCAPE, true)
		_key(KEY_ESCAPE, false)
		_check(not game.dialogue.active() and actor.controls_enabled, "Esc restores input after civic conversation")

	# Fail before changing any live ownership/state.
	var previous: WeakRef = weakref(host.current_location)
	var position_before: Vector3 = actor.global_position
	_check(not host.request_transition("absent-location", "start").is_empty(), "Unknown location accepted")
	_check(not host.request_transition("prototype-tollworks", "absent-spawn").is_empty(), "Unknown spawn accepted")
	_check(previous.get_ref() == host.current_location and actor.global_position == position_before and actor.controls_enabled, "Rejected command changed live scene/control")
	var malformed: PrototypeLocation = (load("res://world/alderwake.tscn") as PackedScene).instantiate()
	malformed.find_spawn("alderwake-from-tollworks").stable_id = "alderwake-start"
	var errors: PackedStringArray = malformed.validation_errors(game.catalog.get_location("prototype-alderwake"), game.catalog)
	_check("duplicate" in "; ".join(errors) and "missing" in "; ".join(errors), "Duplicate/missing physical anchors not rejected")
	malformed.destination_spawn_id = "absent"
	_check("gate destination" in "; ".join(malformed.validation_errors(game.catalog.get_location("prototype-alderwake"), game.catalog)), "Absent gate destination not rejected")
	malformed.free()

	# Physical validation after suspension must rollback to the exact old scene.
	for spawn: String in unsafe.spawn_ids:
		var request_errors: PackedStringArray = host.request_transition(unsafe.stable_id, spawn)
		_check(request_errors.is_empty(), "Unsafe fixture did not reach placement validation: " + "; ".join(request_errors))
		if not request_errors.is_empty():
			for failure: String in failures: push_error(failure)
			quit(1)
			return
		var arrival: Array = await host.transition_finished
		print("P004 expected placement rejection: ", arrival[1])
		_check(not arrival[0] and not arrival[1].is_empty(), "Unsafe spawn committed")
		await _settle()
		_check(previous.get_ref() == host.current_location, "Failed placement replaced old scene")
		_check(game.session.current_location_id == "prototype-alderwake" and game.session.current_spawn_id == "alderwake-start", "Failed placement changed session location")
		_check(actor.global_position.distance_to(position_before) < 0.01 and actor.is_on_floor(), "Failed placement lost old grounded position")
		_check(actor.controls_enabled and not game.party.suspended and host.get_child_count() == 1, "Failed placement did not restore lifecycle")
		_check(host.transition_count == 1, "Failed placement counted as travel")
		_check(game.companion.get_instance_id() == companion_id and game.companion.state == companion_state and game.companion_ai.enabled, "Rollback lost companion ownership/control")

	# Ten complete round trips, preserving node/state identity and input lock.
	for trip: int in range(10):
		for location: String in ["prototype-tollworks", "prototype-alderwake"]:
			var spawn: String = "tollworks-from-alderwake" if location == "prototype-tollworks" else "alderwake-from-tollworks"
			previous = weakref(host.current_location)
			_check(host.request_transition(location, spawn).is_empty(), "Valid travel rejected")
			_check(host.transitioning and game.party.suspended and not actor.controls_enabled and not actor.can_process(), "Transition did not synchronously suspend actors/input")
			_check(not host.request_transition(location, spawn).is_empty(), "Repeated in-flight request accepted")
			var camera_before: int = game.camera_rig.camera.projection
			var time_before: float = game.session.elapsed_play_seconds
			_key(KEY_W, true)
			_key(KEY_P, true)
			_key(KEY_E, true)
			game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			_check(not actor.controls_enabled and actor.movement_buttons.is_empty(), "Focus enabled input during travel")
			_check(game.camera_rig.camera.projection == camera_before, "Camera input leaked through travel")
			if trip == 0:
				game._set_paused(true)
			var arrival: Array = await host.transition_finished
			_check(arrival[0], "Valid arrival failed: " + str(arrival[1]))
			_check(game.session.elapsed_play_seconds == time_before, "Session simulation advanced while travelling")
			if trip == 0:
				_check(paused and not actor.controls_enabled, "Travel completion enabled input while paused")
				game._set_paused(false)
			await _settle()
			_check(previous.get_ref() == null, "Unloaded location still referenced/alive")
			_check(game.session.current_location_id == location and game.session.current_spawn_id == spawn, "Session arrival IDs wrong")
			_check(host.get_child_count() == 1 and game.party.members().size() == 2 and game.session.actors.size() == 2, "Travel duplicated location/party/state")
			_check(actor.get_instance_id() == original_actor_id and actor.state == original_state and actor.state.health == 37, "Travel recreated actor or lost mutable state")
			_check(game.companion.get_instance_id() == companion_id and game.companion.state == companion_state and companion_state.health == 43 and game.companion.is_on_floor(), "Travel lost companion identity/health/floor")
			_check(game.session.elapsed_play_seconds >= 12.0 and game.camera_rig.target == actor, "Session time/camera target lost")
			_check(actor.global_position.distance_to(host.current_location.find_spawn(spawn).global_position) < 0.01 and actor.is_on_floor(), "Arrival unsafe or held W moved after travel")
			_check(actor.movement_buttons.is_empty() and actor.velocity.length() < 0.001, "Velocity/accepted input leaked across travel")
			_check(not host.current_location.can_travel(actor), "Arrival overlaps gate activation range")
			_key(KEY_W, false)
			_key(KEY_P, false)
			_key(KEY_E, false)
		print("P004 round trip %d PASS; health=%d; actor=%d" % [trip + 1, actor.state.health, actor.get_instance_id()])
	_check(host.transition_count == 21, "Unexpected extra/missing transitions")
	# Fresh input works after held transition keys were dropped.
	var start: Vector3 = actor.global_position
	_key(KEY_D, true)
	for frame: int in range(8):
		await physics_frame
	_key(KEY_D, false)
	_check(actor.global_position.distance_to(start) > 0.2, "Fresh movement failed after travel")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P004 checks: PASS — 10 round trips, stable identity/health/time, invalid IDs/anchors/gates, unsafe floor/obstruction rollback, input/reentry lock, pause/focus, grounded arrivals, stale room release.")
	quit(0 if failures.is_empty() else 1)


func _settle() -> void:
	for frame: int in range(120):
		await process_frame
		if not game.world_host.transitioning:
			for physics: int in range(4):
				await physics_frame
			await process_frame
			return
	_check(false, "Transition did not finish within 120 frames")


func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event, true)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
