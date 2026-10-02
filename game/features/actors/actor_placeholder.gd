class_name ActorPlaceholder
extends CharacterBody3D
## Gameplay wrapper receives authoritative session state; visual is replaceable.

var state: ActorState
var camera_rig: PrototypeCameraRig
var ui: PrototypeUI
var controls_enabled: bool = false
var movement_buttons: Dictionary[String, bool] = {}
var trace_evidence: bool = false
var last_contacts: String = ""
var pointer_position: Vector2 = Vector2(-1, -1)

@export var move_speed: float = 4.0
@onready var visual_root: Node3D = $VisualRoot
@onready var aim_marker: Node3D = $AimMarker


func initialize(actor_state: ActorState) -> void:
	state = actor_state


func configure_controls(rig: PrototypeCameraRig, interface: PrototypeUI) -> void:
	camera_rig = rig
	ui = interface
	trace_evidence = "--p003-evidence" in OS.get_cmdline_user_args()
	set_controls_enabled(true)


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	clear_input()


func clear_input() -> void:
	movement_buttons.clear()
	velocity = Vector3.ZERO
	if is_instance_valid(aim_marker):
		aim_marker.visible = false


func _input(event: InputEvent) -> void:
	if trace_evidence and event is InputEventKey and event.pressed and not event.echo:
		print("P003 key: logical=%s physical=%s" % [event.keycode, event.physical_keycode])
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		pointer_position = event.position
	# Releases must clear an accepted press even if UI consumes the release.
	for action: String in ["move_left", "move_right", "move_forward", "move_back"]:
		if event.is_action_released(action):
			movement_buttons.erase(action)
			if trace_evidence:
				print("P003 input release %s: position=%s" % [action, global_position])


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled or get_viewport().gui_get_focus_owner() != null:
		return
	for action: String in ["move_left", "move_right", "move_forward", "move_back"]:
		if event.is_action_pressed(action) and not event.is_echo():
			movement_buttons[action] = true
			get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if camera_rig == null or not controls_enabled:
		return
	if get_viewport().gui_get_focus_owner() != null:
		clear_input()
	var axes: Vector2 = Vector2(
		float(movement_buttons.has("move_right")) - float(movement_buttons.has("move_left")),
		float(movement_buttons.has("move_back")) - float(movement_buttons.has("move_forward"))
	).limit_length(1.0)
	var direction: Vector3 = camera_rig.movement_direction(axes)
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if trace_evidence:
		_trace_contacts()


func _process(_delta: float) -> void:
	if camera_rig == null or not controls_enabled:
		return
	var mouse: Vector2 = pointer_position
	aim_marker.visible = get_viewport().gui_get_focus_owner() == null and ui.accepts_world_pointer(mouse)
	if not aim_marker.visible:
		return
	var target: Variant = camera_rig.ground_point(mouse, global_position.y)
	if target == null:
		aim_marker.visible = false
		return
	var point: Vector3 = target
	aim_marker.global_position = point + Vector3.UP * 0.03
	if global_position.distance_squared_to(point) > 0.01:
		visual_root.look_at(point, Vector3.UP)


func _trace_contacts() -> void:
	var contacts: PackedStringArray = []
	for index: int in range(get_slide_collision_count()):
		var hit: KinematicCollision3D = get_slide_collision(index)
		if absf(hit.get_normal().y) < 0.5:
			contacts.append(str(hit.get_collider().name))
	contacts.sort()
	var summary: String = ",".join(contacts)
	if summary != last_contacts and not summary.is_empty():
		print("P003 collision %s: position=%s" % [summary, global_position])
	last_contacts = summary
