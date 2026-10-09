class_name ItemDefinition
extends ContentDefinition
## Immutable authored item metadata; ownership and selection belong to InventoryState.

@export var source_item_id: String = ""
@export_enum("forage", "tool", "fish") var category: String = "forage"
@export var stack_limit: int = 99
@export var movable_pickup: bool = false
@export var giftable: bool = false
@export_multiline var description: String = ""
@export var fishing_challenge: FishingChallengeDefinition
@export var rod_activation: RodActivationDefinition


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if source_item_id.is_empty() or source_item_id != source_item_id.strip_edges():
		errors.append("source_item_id must be nonempty with no surrounding whitespace")
	if category not in ["forage", "tool", "fish"]:
		errors.append("item category must be forage, tool or fish")
	if stack_limit < 1 or stack_limit > 99:
		errors.append("stack_limit must be in 1..99")
	if movable_pickup and category != "tool":
		errors.append("movable pickup must be a tool")
	if description.strip_edges().is_empty():
		errors.append("item description must be nonempty")
	if category == "fish":
		if fishing_challenge == null:
			errors.append("fish requires challenge metadata")
		if stack_limit != 99 or movable_pickup or not giftable or rod_activation != null:
			errors.append("fish must be giftable cap99, nonmovable and not an active tool")
	elif fishing_challenge != null:
		errors.append("only fish may have challenge metadata")
	if fishing_challenge != null: errors.append_array(fishing_challenge.validation_errors())
	if rod_activation != null:
		if category != "tool" or source_item_id != "fishing_rod" or stack_limit != 1 or not movable_pickup or giftable:
			errors.append("rod activation requires the movable nongiftable cap1 rod")
		errors.append_array(rod_activation.validation_errors())
	elif source_item_id == "fishing_rod":
		errors.append("fishing rod requires activation metadata")
	return errors


func is_tool() -> bool:
	return category == "tool"
