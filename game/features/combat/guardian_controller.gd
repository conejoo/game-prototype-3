class_name GuardianController
extends Node
## One prototype behavior: approach, telegraph, strike, recover. No quest authority.

var actor: ActorPlaceholder
var target: ActorPlaceholder
var enabled: bool = false
var engaged: bool = false
var party_targets: Array[ActorPlaceholder] = []


func _physics_process(_delta: float) -> void:
	# Both allies can be attacked. Preserve the locked swing once windup starts.
	if enabled and not actor.combat.busy():
		var nearest: ActorPlaceholder
		for member: ActorPlaceholder in party_targets:
			if is_instance_valid(member) and member.state.health > 0 and (nearest == null or actor.global_position.distance_squared_to(member.global_position) < actor.global_position.distance_squared_to(nearest.global_position)):
				nearest = member
		target = nearest
	if not enabled or not is_instance_valid(target) or actor.state.health <= 0 or target.state.health <= 0:
		engaged = false
		actor.move_direction(Vector3.ZERO)
		return
	var offset: Vector3 = target.global_position - actor.global_position
	offset.y = 0.0
	engaged = offset.length() < 5.0
	if not engaged or actor.combat.busy():
		actor.move_direction(Vector3.ZERO)
		return
	actor.face_direction(offset)
	if offset.length() > 1.65:
		actor.move_direction(offset.normalized())
	else:
		actor.move_direction(Vector3.ZERO)
		actor.request_attack()
