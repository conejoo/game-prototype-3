class_name ItemDefinition
extends ContentDefinition
## Immutable authored item metadata; ownership and selection belong to InventoryState.

@export var source_item_id: String = ""
@export_enum("forage", "tool") var category: String = "forage"
@export var stack_limit: int = 99
@export var movable_pickup: bool = false
@export var giftable: bool = false
@export_multiline var description: String = ""


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if source_item_id.is_empty() or source_item_id != source_item_id.strip_edges():
		errors.append("source_item_id must be nonempty with no surrounding whitespace")
	if category not in ["forage", "tool"]:
		errors.append("item category must be forage or tool")
	if stack_limit < 1 or stack_limit > 99:
		errors.append("stack_limit must be in 1..99")
	if movable_pickup and category != "tool":
		errors.append("movable pickup must be a tool")
	if description.strip_edges().is_empty():
		errors.append("item description must be nonempty")
	return errors


func is_tool() -> bool:
	return category == "tool"
