extends SceneTree
## Read-only audit loaded externally against an exported pack, never a game owner.

var files: PackedStringArray = []

func _initialize() -> void:
	_scan("res://")
	files.sort()
	var failures: PackedStringArray = []
	var mode: String = "release"
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audit-mode="): mode = argument.trim_prefix("--audit-mode=")
		if argument.begins_with("--audit-output="): output = argument.trim_prefix("--audit-output=")
	var catalog: ContentCatalog = ContentCatalog.new()
	failures.append_array(catalog.initialize(load("res://content/prototype_catalog.tres")))
	var layout_hash: String = FileAccess.get_sha256("res://content/maps/alderwake_layout.json")
	if layout_hash != "7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be": failures.append("Pinned layout changed")
	if LightSourceRegistry.entries().size() != 23: failures.append("Exterior registry count changed")
	if SaveCodec.SCHEMA_VERSION != 6: failures.append("Item save schema absent")
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility": failures.append("Renderer changed")
	var assets: Dictionary = {}
	for name: String in ["moonwood_tree_kit", "alderwake_town_kit", "alderwake_landmark_kit", "exterior_light_kit"]:
		var path: String = "res://assets/environment/" + name + ".glb"
		var scene: PackedScene = load(path)
		assets[name] = scene != null and scene.can_instantiate()
		if not assets[name]: failures.append("Missing imported asset: " + path)
	var test_files: PackedStringArray = []
	for path: String in files:
		if path.begins_with("res://tests/"): test_files.append(path)
		if path.ends_with(".blend") or path.contains("art/source") or path.contains("game-prototype-2"): failures.append("Authoring/source file in pack: " + path)
	if mode == "release" and not test_files.is_empty(): failures.append("Tests leaked into release")
	failures.append_array(ForagingRegistry.validation_errors(catalog))
	if ForagingRegistry.entries().size() != 4: failures.append("Foraging registry count changed")
	for item_id: String in ["item-moonflower", "item-fishing-rod"]:
		if catalog.get_item(item_id) == null: failures.append("Missing packed item: " + item_id)
		if ForagingItemVisual.icon(item_id) == null: failures.append("Missing packed icon: " + item_id)
	for rod: bool in [false, true]:
		var visual: ForagingItemVisual = ForagingItemVisual.new()
		visual.build(rod)
		if visual.get_child_count() == 0: failures.append("Packed item mesh kit empty")
		visual.free()
	var fresh: GameSession = GameSession.new()
	failures.append_array(fresh.initialize(catalog, "prototype-alderwake", "alderwake-start", "prototype-hero"))
	var snapshot: Dictionary = SaveCodec.snapshot(fresh)
	if not snapshot.has("inventory") or not snapshot.has("collected_resource_ids") or not snapshot.has("world_item_placements"): failures.append("Packed save omits item fields")
	if not snapshot.inventory.item_counts.is_empty() or snapshot.inventory.active_item_id != null: failures.append("Packed fresh bag differs")
	if mode == "validation":
		for path: String in test_files:
			if path.begins_with("res://tests/fixtures/") or path.contains("_checks") or path.contains("application_smoke") or path.contains("asset_gallery"): failures.append("Excluded test fixture in validation: " + path)
	var result: Dictionary = {"mode":mode, "engine_pid":OS.get_process_id(), "debug_build":OS.is_debug_build(), "layout_sha256":layout_hash, "schema_version":SaveCodec.SCHEMA_VERSION, "item_registry":ForagingRegistry.entries().size(), "fresh_snapshot":snapshot, "assets":assets, "tests":test_files, "files":files, "failures":failures}
	var file: FileAccess = FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write fresh package audit")
		quit(1)
		return
	file.store_string(JSON.stringify(result, "\t", true, true) + "\n")
	file.close()
	print("F010 package audit: ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _scan(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null: return
	directory.include_hidden = true
	for child: String in directory.get_directories(): _scan(path.path_join(child))
	for child: String in directory.get_files(): files.append(path.path_join(child))
