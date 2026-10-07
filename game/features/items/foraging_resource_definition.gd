class_name ForagingResourceDefinition
extends ContentDefinition
## Definition identity is distinct from item identity and physical instance identity.

@export var source_resource_id: String = ""
@export var item_id: String = ""
@export var hold_milliseconds: int = 600


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if source_resource_id.is_empty() or source_resource_id != source_resource_id.strip_edges():
		errors.append("source_resource_id must be nonempty with no surrounding whitespace")
	if item_id.is_empty() or item_id != item_id.strip_edges():
		errors.append("resource item_id must be nonempty with no surrounding whitespace")
	if hold_milliseconds <= 0:
		errors.append("hold_milliseconds must be positive")
	return errors
