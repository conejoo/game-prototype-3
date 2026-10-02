class_name ActorState
extends RefCounted
## One physical instance's mutable state; copies scalars, retains no Resource.

var instance_id: String
var definition_id: String
var max_health: int
var health: int


func _init(id: String, definition: ActorDefinition) -> void:
	instance_id = id
	definition_id = definition.stable_id
	max_health = definition.max_health
	health = max_health
