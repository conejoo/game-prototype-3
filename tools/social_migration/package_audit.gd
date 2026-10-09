extends SceneTree
## External read-only G009 audit against the exported virtual filesystem.
var files: PackedStringArray = []

func _initialize() -> void:
	var mode: String = "release"
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audit-mode="): mode = argument.trim_prefix("--audit-mode=")
		if argument.begins_with("--audit-output="): output = argument.trim_prefix("--audit-output=")
	_scan("res://")
	files.sort()
	var failures: PackedStringArray = []
	var catalog: ContentCatalog = ContentCatalog.new()
	failures.append_array(catalog.initialize(load("res://content/prototype_catalog.tres")))
	var npcs: NpcContentCatalog = NpcContentCatalog.new()
	failures.append_array(npcs.initialize_path(catalog))
	if NpcRegistry.ENABLED != NpcContentCatalog.ROSTER: failures.append("Eight contact roster differs")
	if SaveCodec.SCHEMA_VERSION != 7: failures.append("Current schema7 absent")
	if ProjectSettings.get_setting("rendering/renderer/rendering_method") != "gl_compatibility": failures.append("Renderer changed")
	var layout: String = FileAccess.get_sha256("res://content/maps/alderwake_layout.json")
	if layout != "7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be": failures.append("Pinned geography differs")
	var people: Dictionary = {}
	for id: String in npcs.npc_ids():
		var definition: NpcDefinition = npcs.get_npc(id)
		var portraits: Dictionary = {}
		for expression: String in definition.portraits:
			var path: String = definition.portraits[expression]
			var texture: Texture2D = load(path)
			if texture == null or texture.get_size() != Vector2(512,512): failures.append("Portrait unresolved: " + path)
			portraits[expression] = {"path":path,"size":texture.get_size() if texture != null else Vector2.ZERO}
		var presenter: NpcVisualPresenter = NpcVisualPresenter.new()
		var asset_path: String = NpcRegistry.VISUAL_ASSETS[id]
		var errors: PackedStringArray = presenter.mount(load(asset_path))
		failures.append_array(errors)
		var clips: PackedStringArray = presenter.player.get_animation_list() if presenter.player != null else PackedStringArray()
		people[id] = {"name":definition.display_name,"portraits":portraits,"asset":asset_path,"clips":clips,"failures":errors}
		presenter.free()
	var actions: Dictionary = {}
	var social: Dictionary = {"nodes":0,"choices":0,"facts":0,"gift_rules":0}
	for package: Dictionary in npcs.document_snapshot().packages:
		for kind: String in ["node", "choice", "fact", "gift_rule"]:
			var key: String = {"node":"nodes","choice":"choices","fact":"facts","gift_rule":"gift_rules"}[kind]
			for entry: Dictionary in package.coverage[kind].values():
				if entry.status == "enabled": social[key] += 1
	if social != {"nodes":67,"choices":48,"facts":21,"gift_rules":8}: failures.append("Current social activation differs")
	if FileAccess.get_sha256(NpcContentCatalog.PATH) != "efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3": failures.append("G008 catalog bytes differ")
	for path: String in ["res://features/npcs/npc_gift_rules.gd", "res://features/npcs/people_snapshot.gd", "res://ui/people_journal_view.gd"]:
		if not ResourceLoader.exists(path): failures.append("Social resource absent: " + path)
	for id: String in ["npc-01","npc-02"]:
		var presenter: NpcVisualPresenter = NpcVisualPresenter.new()
		var path: String = "res://assets/models/npcs/" + id + "-actions.glb"
		failures.append_array(presenter.mount(load(path)))
		var clip: String = "action_river_fishing" if id == "npc-01" else "action_archive_work"
		if presenter.player == null or not presenter.player.has_animation(clip): failures.append("Review action absent: " + id)
		actions[id] = {"asset":path,"clip":clip,"runtime":false}
		presenter.free()
	var tests: PackedStringArray = []
	for path: String in files:
		if path.begins_with("res://tests/"): tests.append(path)
		if path.ends_with(".blend") or path.ends_with(".dart") or path.contains("art/source") or path.contains("game-prototype-2") or path.contains("docs/npcs") or path.contains("reference/manifest"):
			failures.append("Private/authoring/source file bundled: " + path)
	if not tests.is_empty(): failures.append("G009 package includes tests/bridge")
	for path: String in tests:
		if path.contains("_checks") or path.contains("fixtures/"): failures.append("Check/fixture included: " + path)
	var fresh: GameSession = GameSession.new()
	failures.append_array(fresh.initialize(catalog,"prototype-alderwake","alderwake-start","prototype-hero"))
	var snapshot: Dictionary = SaveCodec.snapshot(fresh)
	if not snapshot.has("conversations") or not snapshot.conversations.has("events") or snapshot.conversations.people.size() != 8: failures.append("NPC durable fields missing")
	if not PeopleSnapshot.from_state(fresh.conversations,npcs).people.is_empty(): failures.append("Fresh People reveals unmet entries")
	var result: Dictionary = {"task":"G009","mode":mode,"pid":OS.get_process_id(),"layout_sha256":layout,"catalog_sha256":FileAccess.get_sha256(NpcContentCatalog.PATH),"schema":SaveCodec.SCHEMA_VERSION,"social":social,"people":people,"actions":actions,"tests":tests,"files":files,"failures":failures}
	var file: FileAccess = FileAccess.open(output,FileAccess.WRITE)
	if file == null:
		push_error("Cannot write G009 pack audit")
		quit(1)
		return
	file.store_string(JSON.stringify(result,"\t",true,true)+"\n")
	file.close()
	print("G009 package audit: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _scan(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null: return
	directory.include_hidden = true
	for child: String in directory.get_directories(): _scan(path.path_join(child))
	for child: String in directory.get_files(): files.append(path.path_join(child))
