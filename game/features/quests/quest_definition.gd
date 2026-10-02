class_name QuestDefinition
extends ContentDefinition
## Immutable shortened adaptation. No mutable progress in Resources.

@export var steps: Array[QuestStep] = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if steps.is_empty():
		errors.append("quest requires ordered steps")
	var ids: PackedStringArray = []
	var actions: PackedStringArray = []
	var effects: PackedStringArray = []
	for step: QuestStep in steps:
		if step == null:
			errors.append("quest step is null")
			continue
		errors.append_array(step.validation_errors())
		if step.stable_id in ids or step.action_id in actions or step.effect_id in effects:
			errors.append("duplicate quest step/action/effect ID")
		ids.append(step.stable_id)
		actions.append(step.action_id)
		effects.append(step.effect_id)
	return errors
