class_name ActorDefinition
extends ContentDefinition
## Starting health is authored; current health belongs to ActorState.

@export var max_health: int = 100


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if max_health <= 0:
		errors.append("max_health must be positive")
	return errors
