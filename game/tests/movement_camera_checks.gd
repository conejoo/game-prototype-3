extends SceneTree
## Physics/input regressions in the real root. Interactive comparison is separate.

var failures: Array[String] = []
var game: Node3D
var actor: ActorPlaceholder
var rig: PrototypeCameraRig


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(960, 640)
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	game.initial_location_id = "prototype-test-room"
	game.initial_spawn_id = "prototype-start"
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	actor = game.player_placeholder
	rig = game.camera_rig
	await _frames(3)
	_check(actor is CharacterBody3D and actor.is_on_floor(), "Hero must be grounded CharacterBody3D")
	_check(actor.state == game.session.actors[GameSession.PLAYER_INSTANCE_ID], "Session ownership changed")

	# Actual accepted InputMap events drive movement; camera-relative screen direction.
	var start: Vector3 = actor.global_position
	_key(KEY_W, true)
	await _frames(20)
	_key(KEY_W, false)
	var traveled: Vector3 = actor.global_position - start
	var screen_delta: Vector2 = rig.camera.unproject_position(actor.global_position) - rig.camera.unproject_position(start)
	_check(traveled.length() > 1.0, "W did not move hero")
	_check(screen_delta.y < -20.0 and absf(screen_delta.x) < 1.0, "W must move toward screen top")
	var straight_speed: float = actor.velocity.length()
	await _place(Vector3.ZERO)
	_key(KEY_W, true)
	_key(KEY_D, true)
	await _frames(5)
	_check(is_equal_approx(actor.velocity.length(), straight_speed), "Diagonal input increased movement speed")
	_key(KEY_W, false)
	_key(KEY_D, false)

	# Back/left corner: push against both solids, then reverse and escape.
	await _place(Vector3(-6.0, 0, -5.0))
	_key(KEY_W, true)
	_key(KEY_A, true)
	await _frames(100)
	print("P003 test back/left endpoint: %s velocity=%s buttons=%s" % [actor.global_position, actor.velocity, actor.movement_buttons])
	_check(actor.global_position.x >= -6.46 and actor.global_position.z >= -5.46, "Hero penetrated back/left corner")
	_check(actor.global_position.x < -6.3 and actor.global_position.z < -5.3, "Course did not reach both corner walls")
	var corner: Vector3 = actor.global_position
	_key(KEY_W, false)
	_key(KEY_A, false)
	_key(KEY_S, true)
	_key(KEY_D, true)
	await _frames(20)
	_key(KEY_S, false)
	_key(KEY_D, false)
	_check(actor.global_position.distance_to(corner) > 1.0, "Hero stuck in corner after reversal")

	await _place(Vector3(6, 0, 5))
	_key(KEY_D, true)
	_key(KEY_S, true)
	await _frames(100)
	print("P003 test front/right endpoint: ", actor.global_position)
	_key(KEY_D, false)
	_key(KEY_S, false)
	_check(actor.global_position.x <= 6.46 and actor.global_position.z <= 5.46, "Hero penetrated front/right corner")
	_check(actor.global_position.x > 6.3 and actor.global_position.z > 5.3, "Course did not reach front/right corner")

	await _place(Vector3(1, 0, -2))
	_key(KEY_D, true)
	await _frames(16)
	_key(KEY_D, false)
	_check(actor.global_position.x < 1.66, "Hero passed through beacon plinth")

	await _place(Vector3.ZERO)
	for orthographic: bool in [true, false]:
		rig.set_orthographic(orthographic)
		await process_frame
		var aim_world: Vector3 = Vector3(2, 0, 1)
		var aim_screen: Vector2 = rig.camera.unproject_position(aim_world)
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = aim_screen
		root.push_input(motion, true)
		await process_frame
		await process_frame
		var ray_hit: Variant = rig.ground_point(aim_screen, 0.0)
		print("P003 test aim: ortho=%s screen=%s hit=%s marker=%s" % [orthographic, aim_screen, ray_hit, actor.aim_marker.global_position])
		_check(ray_hit != null and (ray_hit as Vector3).distance_to(aim_world) < 0.001, "Camera projection/ray aim disagrees")
		_check(actor.aim_marker.visible, "Aim marker hidden in gameplay viewport")
		_check(actor.aim_marker.global_position.distance_to(aim_world + Vector3.UP * 0.03) < 0.01, "Pointer aim not presented at ray hit")
		_check((-actor.visual_root.global_basis.z).dot(aim_world.normalized()) > 0.999, "Visual heading does not face pointer")
		_check(actor.rotation == Vector3.ZERO, "Aiming rotated physical wrapper")
		var right_start: Vector3 = actor.global_position
		_key(KEY_D, true)
		await _frames(10)
		_key(KEY_D, false)
		var right_delta: Vector2 = rig.camera.unproject_position(actor.global_position) - rig.camera.unproject_position(right_start)
		_check(right_delta.x > 10.0 and absf(right_delta.y) < 2.0, "D must move screen right in both projections")
		await _place(Vector3.ZERO)

	for step: int in range(20):
		rig.zoom(1.0)
	_check(is_equal_approx(rig.zoom_factor, 0.8), "Zoom-in bound failed")
	for step: int in range(20):
		rig.zoom(-1.0)
	_check(is_equal_approx(rig.zoom_factor, 1.15), "Zoom-out bound failed")
	var projection_before: int = rig.camera.projection
	_key(KEY_P, true)
	_key(KEY_P, false)
	_check(rig.camera.projection != projection_before, "P binding did not switch camera projection")
	_key(KEY_EQUAL, true)
	_key(KEY_EQUAL, false)
	_check(is_equal_approx(rig.zoom_factor, 1.1), "Zoom keyboard binding failed")
	var ui_mouse: InputEventMouseMotion = InputEventMouseMotion.new()
	ui_mouse.position = Vector2(400, 40)
	root.push_input(ui_mouse, true)
	await process_frame
	_check(not actor.aim_marker.visible, "Pointer over header leaked world aiming")
	var ui_wheel: InputEventMouseButton = InputEventMouseButton.new()
	ui_wheel.position = ui_mouse.position
	ui_wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	ui_wheel.pressed = true
	root.push_input(ui_wheel, true)
	_check(is_equal_approx(rig.zoom_factor, 1.1), "Pointer over header leaked zoom")

	_key(KEY_W, true)
	await _frames(5)
	game._set_paused(true)
	var paused_position: Vector3 = actor.global_position
	var paused_camera: Vector3 = rig.global_position
	var paused_zoom: float = rig.zoom_factor
	var paused_projection: int = rig.camera.projection
	_key(KEY_D, true)
	_key(KEY_P, true)
	_key(KEY_EQUAL, true)
	await _frames(5)
	_check(actor.global_position == paused_position and rig.global_position == paused_camera, "Actor/camera moved through pause")
	_check(rig.zoom_factor == paused_zoom, "Zoom leaked through pause")
	_check(rig.camera.projection == paused_projection, "Projection toggle leaked through pause")
	game._set_paused(false)
	await _frames(5)
	_check(actor.global_position == paused_position, "Held movement leaked through resume")
	_key(KEY_W, false)
	_key(KEY_D, false)
	_key(KEY_P, false)
	_key(KEY_EQUAL, false)

	game.ui.pause_button.grab_focus()
	_key(KEY_W, true)
	await _frames(5)
	_check(actor.global_position == paused_position, "Focused UI leaked movement input")
	game.ui.pause_button.release_focus()
	await _frames(5)
	_check(actor.global_position == paused_position, "Held UI key leaked after focus release")
	_key(KEY_W, false)
	_key(KEY_W, true)
	await _frames(5)
	_key(KEY_W, false)
	_check(actor.global_position.distance_to(paused_position) > 0.2, "Fresh input did not resume after UI focus")

	_key(KEY_W, true)
	await process_frame
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var focus_position: Vector3 = actor.global_position
	await _frames(5)
	_check(actor.global_position == focus_position, "Held input leaked after application focus loss")
	_key(KEY_W, false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P003 checks: PASS — movement, equal diagonal speed, four walls/corners/plinth, both projection/aim/facing, zoom bounds, pause/UI/focus isolation.")
	quit(0 if failures.is_empty() else 1)


func _place(position: Vector3) -> void:
	actor.clear_input()
	actor.global_position = position
	actor.reset_physics_interpolation()
	await _frames(3)


func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
	await process_frame


func _key(code: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	root.push_input(event, true)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
