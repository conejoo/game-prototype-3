class_name ActorPlaceholder
extends Node3D
## Gameplay wrapper receives authoritative session state; visual is replaceable.

var state: ActorState


func initialize(actor_state: ActorState) -> void:
	state = actor_state
