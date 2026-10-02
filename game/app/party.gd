class_name PrototypeParty
extends Node3D
## Persistent gameplay wrappers. Session alone owns their mutable ActorState.

var suspended: bool = false


func members() -> Array[ActorPlaceholder]:
	var result: Array[ActorPlaceholder] = []
	for child: Node in get_children():
		if child is ActorPlaceholder:
			result.append(child as ActorPlaceholder)
	return result


func suspend_for_travel() -> void:
	suspended = true
	for actor: ActorPlaceholder in members():
		actor.set_controls_enabled(false)
		actor.last_contacts = ""
	process_mode = Node.PROCESS_MODE_DISABLED


func place_at(anchor: SpawnAnchor) -> void:
	var index: int = 0
	for actor: ActorPlaceholder in members():
		actor.global_transform = anchor.global_transform
		actor.global_position += Vector3.RIGHT * index * 1.0
		actor.clear_input()
		actor.visual_root.rotation = Vector3.ZERO
		actor.reset_physics_interpolation()
		index += 1


func resume_after_travel() -> void:
	suspended = false
	process_mode = Node.PROCESS_MODE_PAUSABLE
	# GameRoot enables player input only after checking pause/window focus.
