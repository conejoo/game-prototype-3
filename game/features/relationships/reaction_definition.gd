class_name ReactionDefinition
extends ContentDefinition
## Immutable, explicitly temporary companion decision outcome.

@export var companion_id: String = "prototype-companion"
@export var decision_id: String = ""
@export var trust_delta: int = 0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if decision_id.is_empty() or decision_id != decision_id.strip_edges():
		errors.append("reaction decision ID must be nonempty and unpadded")
	if trust_delta == 0 or absi(trust_delta) > 10:
		errors.append("reaction trust delta must be nonzero within -10..10")
	return errors
