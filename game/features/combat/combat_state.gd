class_name CombatState
extends RefCounted
## Transient action windows and damage rules shared by every combat actor.

var elapsed: float = 0.0
var attacking: bool = false
var dodge_left: float = 0.0
var hit_flash: float = 0.0
var hit_ids: PackedStringArray = []
var windup: float = 0.18
var active_time: float = 0.14
var recovery: float = 0.30
var damage: int = 25
var reach: float = 2.2
var direction: Vector3 = Vector3.FORWARD


func attack(facing: Vector3, alive: bool) -> bool:
	if not alive or busy():
		return false
	direction = facing.normalized()
	elapsed = 0.0
	attacking = true
	hit_ids.clear()
	return true


func dodge(facing: Vector3, alive: bool) -> bool:
	if not alive or busy():
		return false
	direction = facing.normalized()
	dodge_left = 0.30
	return true


func advance(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	dodge_left = maxf(0.0, dodge_left - delta)
	if attacking:
		elapsed += delta
		if elapsed >= windup + active_time + recovery:
			attacking = false


func busy() -> bool:
	return attacking or dodge_left > 0.0


func active() -> bool:
	return attacking and elapsed >= windup and elapsed < windup + active_time


func can_hit(id: String, offset: Vector3) -> bool:
	var flat: Vector3 = Vector3(offset.x, 0.0, offset.z)
	return active() and id not in hit_ids and flat.length() <= reach and (flat.length() < 0.1 or direction.dot(flat.normalized()) >= 0.45)


func receive(actor: ActorState, amount: int) -> bool:
	if actor == null or actor.health <= 0 or amount <= 0 or dodge_left > 0.0:
		return false
	actor.health = maxi(0, actor.health - amount)
	hit_flash = 0.18
	if actor.health == 0:
		cancel()
	return true


func cancel() -> void:
	attacking = false
	dodge_left = 0.0
	hit_ids.clear()
