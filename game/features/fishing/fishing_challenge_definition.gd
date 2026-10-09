class_name FishingChallengeDefinition
extends Resource
## Immutable species rules. Challenge progress/timers are never Resource fields.

@export_enum("easy", "medium", "hard") var difficulty: String = "easy"
@export var hook_window_seconds: float = 1.2
@export var minimum_fight_seconds: float = 2.0
@export var maximum_fight_seconds: float = 5.0

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if difficulty not in ["easy", "medium", "hard"]:
		errors.append("unknown fishing difficulty")
	for value: float in [hook_window_seconds, minimum_fight_seconds, maximum_fight_seconds]:
		if not is_finite(value) or value <= 0.0:
			errors.append("fishing challenge times must be finite and positive")
	if maximum_fight_seconds < minimum_fight_seconds:
		errors.append("maximum fight must be at least minimum fight")
	return errors
