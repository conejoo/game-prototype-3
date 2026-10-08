class_name TestRunSave
extends RefCounted
## Configure synthetic fixture repositories only after GameRoot startup.
## Runner save groups own user://; this helper never creates or changes disk files.

static func configure(game: Variant, path: String) -> PackedStringArray:
	if not is_instance_valid(game) or not game is Node or not game.is_inside_tree() or not game.is_node_ready():
		return PackedStringArray(["fixture repository requires a ready GameRoot"])
	var host: PrototypeWorldHost = game.get("world_host") as PrototypeWorldHost
	if not is_instance_valid(host) or host.transitioning or not is_instance_valid(host.current_location) or game.get("loading_save") == true or game.get("retrying") == true:
		return PackedStringArray(["fixture repository requires completed startup and no transition/load/retry"])
	if not path.begins_with("user://saves/") or not path.ends_with(".json") or path != path.simplify_path() or "\\" in path or path.trim_prefix("user://saves/").is_empty():
		return PackedStringArray(["fixture repository requires a canonical user://saves/*.json path"])
	if path == "user://saves/returning-fair.json":
		return PackedStringArray(["fixture repository cannot target the normal save slot"])
	game.set("save_repository", SaveRepository.new(path))
	return PackedStringArray()
