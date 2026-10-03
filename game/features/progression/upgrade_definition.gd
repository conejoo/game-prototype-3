class_name UpgradeDefinition
extends ContentDefinition
## Immutable prototype training reward and combat modifier.

@export var earned_effect_id: String = ""
@export var damage_bonus: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if earned_effect_id.is_empty():
		errors.append("upgrade requires earned quest effect ID")
	if damage_bonus <= 0 or damage_bonus > 100:
		errors.append("upgrade damage bonus must be 1..100")
	return errors
