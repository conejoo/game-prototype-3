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
var combat: CombatState = CombatState.new()
var combat_targets: Array[ActorPlaceholder] = []
var requested_direction: Vector3 = Vector3.ZERO
var team: String = "hero"
var combat_enabled: bool = false
var _death_reported: bool = false
signal defeated(actor: ActorPlaceholder)
@export var player_controlled: bool = true
@onready var combat_marker: MeshInstance3D = get_node_or_null("CombatMarker")

@export var move_speed: float = 4.0
@onready var visual_root: Node3D = $VisualRoot
@onready var aim_marker: Node3D = $AimMarker


func _ready() -> void:
	if combat_marker != null:
		combat_marker.material_override = combat_marker.material_override.duplicate()


func initialize(actor_state: ActorState) -> void:
	state = actor_state
	combat.cancel()
	_death_reported = false


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
	requested_direction = Vector3.ZERO
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
	if not player_controlled or not controls_enabled or state.health <= 0 or get_viewport().gui_get_focus_owner() != null:
		return
	if event is InputEventMouseButton and not ui.accepts_world_pointer(event.position):
		return
	if event.is_action_pressed("attack") and not event.is_echo():
		_update_aim()
		request_attack()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("dodge") and not event.is_echo():
		var axes: Vector2 = Vector2(float(movement_buttons.has("move_right")) - float(movement_buttons.has("move_left")), float(movement_buttons.has("move_back")) - float(movement_buttons.has("move_forward")))
		var direction: Vector3 = camera_rig.movement_direction(axes)
		request_dodge(direction if direction.length() > 0.1 else -visual_root.global_basis.z)
		get_viewport().set_input_as_handled()
	for action: String in ["move_left", "move_right", "move_forward", "move_back"]:
		if event.is_action_pressed(action) and not event.is_echo():
			movement_buttons[action] = true
			get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if state == null:
		return
	if combat_enabled:
		combat.advance(delta)
		_resolve_hits()
	_update_feedback()
	if state.health <= 0 or (player_controlled and (camera_rig == null or not controls_enabled)) or (not player_controlled and not combat_enabled):
		return
	if player_controlled and get_viewport().gui_get_focus_owner() != null:
		clear_input()
	var axes: Vector2 = Vector2(
		float(movement_buttons.has("move_right")) - float(movement_buttons.has("move_left")),
		float(movement_buttons.has("move_back")) - float(movement_buttons.has("move_forward"))
	).limit_length(1.0)
	var direction: Vector3 = camera_rig.movement_direction(axes) if player_controlled else requested_direction
	if combat.dodge_left > 0.0:
		direction = combat.direction * 2.5
	elif combat.attacking:
		direction *= 0.25
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
	_update_aim()


func _update_aim() -> void:
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
	if not combat.busy() and state.health > 0 and global_position.distance_squared_to(point) > 0.01:
		visual_root.look_at(point, Vector3.UP)


func move_direction(direction: Vector3) -> void:
	requested_direction = direction.limit_length(1.0)


func face_direction(direction: Vector3) -> void:
	if direction.length() > 0.01 and not combat.busy():
		visual_root.look_at(global_position + direction, Vector3.UP)


func request_attack() -> bool:
	return combat_enabled and combat.attack(-visual_root.global_basis.z, state.health > 0)


func request_dodge(direction: Vector3) -> bool:
	return combat_enabled and combat.dodge(direction, state.health > 0)


func receive_damage(amount: int) -> bool:
	if not combat_enabled or not combat.receive(state, amount):
		return false
	if state.health == 0 and not _death_reported:
		_death_reported = true
		clear_input()
		defeated.emit(self)
	return true


func _resolve_hits() -> void:
	for target: ActorPlaceholder in combat_targets:
		if not is_instance_valid(target) or target.team == team or target.state.health <= 0:
			continue
		if not combat.can_hit(target.state.instance_id, target.global_position - global_position):
			continue
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.3, target.global_position + Vector3.UP * 0.3, 1, [get_rid(), target.get_rid()])
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			continue
		# Consume contact even when dodge rejects damage: one attempt per target/swing.
		combat.hit_ids.append(target.state.instance_id)
		target.receive_damage(combat.damage)


func _update_feedback() -> void:
	collision_layer = 0 if state.health == 0 else 2
	if combat_marker != null:
		combat_marker.visible = (combat.busy() or combat.hit_flash > 0.0) and state.health > 0
		combat_marker.position = combat.direction * 0.9 + Vector3.UP * 0.05
		var material: StandardMaterial3D = combat_marker.material_override
		material.albedo_color = Color.WHITE if combat.hit_flash > 0.0 else (Color(0.2, 0.8, 1) if combat.dodge_left > 0.0 else (Color(1, 0.2, 0.12) if combat.active() else Color(1, 0.72, 0.1)))
	visual_root.scale = Vector3(1.0, 0.18 if state.health == 0 else (0.8 if combat.hit_flash > 0.0 else 1.0), 1.0)


func _trace_contacts() -> void:
	var contacts: PackedStringArray = []
	for index: int in range(get_slide_collision_count()):
		var hit: KinematicCollision3D = get_slide_collision(index)
		var collider: Object = hit.get_collider()
		if is_instance_valid(collider) and absf(hit.get_normal().y) < 0.5:
			contacts.append(str(collider.name))
	contacts.sort()
	var summary: String = ",".join(contacts)
	if summary != last_contacts and not summary.is_empty():
		print("P003 collision %s: position=%s" % [summary, global_position])
	last_contacts = summary
