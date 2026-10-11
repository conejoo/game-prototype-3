extends SceneTree
## AD020 read-only audit of the exported virtual filesystem, never native play.
var files: PackedStringArray = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var output: String = ""
	var mode: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audit-output="): output = argument.trim_prefix("--audit-output=")
		if argument.begins_with("--audit-mode="): mode = argument.trim_prefix("--audit-mode=")
	_scan("res://")
	files.sort()
	var failures: PackedStringArray = []
	var inventory: Dictionary = {}
	var catalog: ContentCatalog = ContentCatalog.new()
	failures.append_array(catalog.initialize(load("res://content/prototype_catalog.tres")))
	var npcs: NpcContentCatalog = NpcContentCatalog.new()
	failures.append_array(npcs.initialize_path(catalog))
	var rejections: Dictionary = {}
	if npcs.initialized:
		for mutation: String in ["dimensions", "unknown_sheet", "cross_person"]:
			var document: Dictionary = npcs.document_snapshot()
			var sheet: Dictionary = document.packages[0].visuals.world.idle
			if mutation == "dimensions": sheet.textureCellWidth += 1
			if mutation == "unknown_sheet": sheet.asset = "res://assets/npcs/reference/npc-01/unknown.png"
			if mutation == "cross_person": sheet.asset = document.packages[1].visuals.world.idle.asset
			var candidate: NpcContentCatalog = NpcContentCatalog.new()
			var errors: PackedStringArray = candidate.initialize_document(document, catalog)
			rejections[mutation] = errors
			if errors.is_empty() or candidate.initialized: failures.append("Packed reference guard admitted " + mutation)
	for path: String in files:
		if path.begins_with("res://tests/") or path.begins_with("res://tools/") or path.begins_with("res://docs/") or path.contains("/reference/") or path.contains("npc_calibration") or path.contains("art/source") or path.contains("art/direction") or path.contains("playtest_bridge") or path.ends_with(".blend") or path.ends_with(".psd"):
			failures.append("Private/authoring/reference/evidence resource bundled: " + path)
		if path.begins_with("res://assets/environment/storybook/") and (path.ends_with(".png.import") or path.ends_with(".glb.import")):
			var resource_path: String = path.trim_suffix(".import")
			var resource: Resource = load(resource_path)
			if resource == null:
				failures.append("Painted resource unresolved: " + resource_path)
				continue
			inventory[resource_path] = {"type":resource.get_class()}
			if resource is Texture2D:
				inventory[resource_path]["size"] = [resource.get_width(),resource.get_height()]
				if resource.get_width() != 1024 or resource.get_height() != 1024: failures.append("Painted atlas dimensions changed: " + resource_path)
	if inventory.size() != 12: failures.append("Expected six painted atlases and six GLBs: " + str(inventory.size()))
	for path: String in ["res://world/map_candidate/landscape.gdshader","res://world/map_candidate/river.gdshader","res://world/map_candidate/canopy_visibility.gdshader","res://ui/storybook_hud.gd"]:
		if not ResourceLoader.exists(path): failures.append("Painted presentation resource absent: " + path)
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility": failures.append("Renderer changed")
	if SaveCodec.SCHEMA_VERSION != 8 or SaveCodec.CONTENT_VERSION != 1: failures.append("Save contract changed")
	var result: Dictionary = {"task":"AD020","mode":mode,"pid":OS.get_process_id(),"renderer":ProjectSettings.get_setting("rendering/renderer/rendering_method"),"schema":SaveCodec.SCHEMA_VERSION,"content":SaveCodec.CONTENT_VERSION,"painted_inventory":inventory,"reference_guard_rejections":rejections,"files":files,"failures":failures,"provenance":"Read-only exported pack audit and detached malformed-reference probes; not native input evidence"}
	var file: FileAccess = FileAccess.open(output,FileAccess.WRITE)
	if file == null:
		push_error("Cannot write AD020 package audit")
		quit(1)
		return
	file.store_string(JSON.stringify(result,"\t",true,true)+"\n")
	file.close()
	print("AD020 package audit: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _scan(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null: return
	directory.include_hidden = true
	for child: String in directory.get_directories(): _scan(path.path_join(child))
	for child: String in directory.get_files(): files.append(path.path_join(child))
