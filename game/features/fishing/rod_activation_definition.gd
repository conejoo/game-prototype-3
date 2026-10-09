class_name RodActivationDefinition
extends Resource
## Authored capability only; activation input and target validation belong to later tasks.

@export var activity_id: String = "fishing"
@export var target_cell_size_m: float = 0.5
@export var maximum_range_m: float = 12.0
@export var required_surface: String = "water"
@export var action: String = "castFishingLine"

func validation_errors() -> PackedStringArray:
	if activity_id != "fishing" or required_surface != "water" or action != "castFishingLine":
		return PackedStringArray(["invalid fishing rod activation identity"])
	if not is_finite(target_cell_size_m) or not is_finite(maximum_range_m) or target_cell_size_m != 0.5 or maximum_range_m != 12.0:
		return PackedStringArray(["fishing rod requires 0.5m cells and 12m range"])
	return []
