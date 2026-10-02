class_name PrototypeInteractable
extends Node3D
## Gameplay identity and interaction live on wrapper, never imported visual nodes.

@export var instance_id: String = ""
@export_enum("talk", "inspect", "travel") var kind: String = "talk"
@export var prompt: String = ""
@export var dialogue_id: String = ""
@export_range(0.5, 3.0) var reach: float = 1.7


func validation_errors(catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	if instance_id.is_empty() or instance_id != instance_id.strip_edges():
		errors.append("interaction instance ID must be nonempty and unpadded")
	if prompt.strip_edges().is_empty():
		errors.append("interaction prompt must be nonempty")
	if kind not in ["talk", "inspect", "travel"]:
		errors.append("unknown interaction kind '%s'" % kind)
	if not is_finite(reach) or reach < 0.5 or reach > 3.0:
		errors.append("interaction reach must be 0.5..3m")
	if kind != "travel" and catalog.get_dialogue(dialogue_id) == null:
		errors.append("missing interaction dialogue '%s'" % dialogue_id)
	return errors
