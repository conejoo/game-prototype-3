class_name LocationDefinition
extends ContentDefinition
## Authored scene and identities. Physical anchors are validated by WorldHost.

@export_file("*.tscn") var scene_path: String = ""
@export var spawn_ids: PackedStringArray = []
@export var actor_ids: PackedStringArray = []


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = super.validation_errors()
	if not scene_path.begins_with("res://") or not scene_path.ends_with(".tscn"):
		errors.append("scene_path must be a res:// .tscn path")
	elif not ResourceLoader.exists(scene_path, "PackedScene"):
		errors.append("scene_path does not reference an existing PackedScene: %s" % scene_path)
	if spawn_ids.is_empty():
		errors.append("spawn_ids must contain at least one stable spawn ID")
	var seen: Dictionary[String, bool] = {}
	for spawn_id: String in spawn_ids:
		if spawn_id.is_empty() or spawn_id != spawn_id.strip_edges():
			errors.append("spawn_ids contains an empty or whitespace-padded ID")
		elif seen.has(spawn_id):
			errors.append("duplicate spawn ID '%s'" % spawn_id)
		seen[spawn_id] = true
	return errors
