extends SceneTree
## External read-only R016 audit against the exported virtual filesystem.
var files: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
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
	if SaveCodec.SCHEMA_VERSION != 8: failures.append("Current schema8 absent")
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
	if social != {"nodes":69,"choices":53,"facts":22,"gift_rules":8}: failures.append("Current social activation differs")
	if FileAccess.get_sha256(NpcContentCatalog.PATH) != "9a3a59fcce470d356e13f492cd1364e942b110c8e93d54d535a363218766bdd7": failures.append("R016 catalog bytes differ")
	for path: String in ["res://features/npcs/npc_gift_rules.gd", "res://features/npcs/people_snapshot.gd", "res://ui/people_journal_view.gd"]:
		if not ResourceLoader.exists(path): failures.append("Social resource absent: " + path)
	for id: String in ["npc-01","npc-02"]:
		var presenter: NpcVisualPresenter = NpcVisualPresenter.new()
		var path: String = "res://assets/models/npcs/" + id + "-actions.glb"
		failures.append_array(presenter.mount(load(path)))
		var clip: String = "action_river_fishing" if id == "npc-01" else "action_archive_work"
		if presenter.player == null or not presenter.player.has_animation(clip): failures.append("Review action absent: " + id)
		actions[id] = {"asset":path,"clip":clip,"runtime":true}
		presenter.free()
	var routines: RoutineContentCatalog = RoutineContentCatalog.new()
	failures.append_array(routines.initialize_path(npcs))
	if routines.routine_ids() != RoutineContentCatalog.IDS or routines.definition_count() != 25: failures.append("Exact 25 packed routines absent")
	var routine_inventory: Dictionary = {}
	for id: String in routines.routine_ids():
		var path: String = "res://content/routines/" + id + ".json"
		routine_inventory[id] = {"sha256":FileAccess.get_sha256(path),"definition":routines.document_snapshot(id)}
	var rooms: Dictionary = {}
	for id: String in ["prototype-mayor-vale-home","prototype-lantern-rest"]:
		var location: LocationDefinition = catalog.get_location(id)
		if location == null: failures.append("Packed room definition absent: " + id); continue
		var scene: PackedScene = load(location.scene_path)
		if scene == null: failures.append("Packed room scene absent: " + id); continue
		var room: Node = scene.instantiate()
		rooms[id] = {"scene":location.scene_path,"spawns":location.spawn_ids,"portals":location.portals.size(),"nodes":room.get_child_count()}
		room.free()
	for path: String in ["res://features/routines/routine_execution_director.gd","res://features/routines/routine_presentation.gd","res://features/routines/routine_content_catalog.gd"]:
		if not ResourceLoader.exists(path): failures.append("Packed routine owner absent: " + path)
	var tests: PackedStringArray = []
	for path: String in files:
		if path.begins_with("res://tests/"): tests.append(path)
		if path.begins_with("res://tools/") or path.begins_with("res://docs/") or path.contains("playtest_bridge") or path.ends_with(".blend") or path.ends_with(".dart") or path.contains("art/source") or path.contains("game-prototype-2") or path.contains("docs/npcs") or path.contains("reference/manifest"):
			failures.append("Private/authoring/source file bundled: " + path)
	if not tests.is_empty(): failures.append("R016 package includes tests/bridge")
	for path: String in tests:
		if path.contains("_checks") or path.contains("fixtures/"): failures.append("Check/fixture included: " + path)
	var fresh: GameSession = GameSession.new()
	failures.append_array(fresh.initialize(catalog,"prototype-alderwake","alderwake-start","prototype-hero"))
	var snapshot: Dictionary = SaveCodec.snapshot(fresh)
	if not snapshot.has("conversations") or not snapshot.conversations.has("events") or snapshot.conversations.people.size() != 8: failures.append("NPC durable fields missing")
	if not PeopleSnapshot.from_state(fresh.conversations,npcs).people.is_empty(): failures.append("Fresh People reveals unmet entries")
	var game: Variant = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	if not arrival[0] or game.routine_execution == null or game.world_host.routine_execution != game.routine_execution or game.dialogue.routine_owner != game.routine_execution: failures.append("Packed default root routine owner/arrival failed")
	var live: Dictionary = SaveCodec.snapshot(game.session)
	if not live.has("routine_facts"): failures.append("Packed durable routine facts absent")
	var execution: Dictionary = game.routine_execution.snapshot()
	if execution.actors.size() != 8 or not execution.error.is_empty(): failures.append("Packed eight assignments absent/errored")
	game.queue_free()
	await process_frame
	var result: Dictionary = {"routine_inventory":routine_inventory,"rooms":rooms,"execution":execution,"fresh_snapshot":live,"content_version":SaveCodec.CONTENT_VERSION,"task":"R016","mode":mode,"pid":OS.get_process_id(),"layout_sha256":layout,"catalog_sha256":FileAccess.get_sha256(NpcContentCatalog.PATH),"schema":SaveCodec.SCHEMA_VERSION,"social":social,"people":people,"actions":actions,"tests":tests,"files":files,"failures":failures}
	var file: FileAccess = FileAccess.open(output,FileAccess.WRITE)
	if file == null:
		push_error("Cannot write R016 pack audit")
		quit(1)
		return
	file.store_string(JSON.stringify(result,"\t",true,true)+"\n")
	file.close()
	print("R016 package audit: ","PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)

func _scan(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null: return
	directory.include_hidden = true
	for child: String in directory.get_directories(): _scan(path.path_join(child))
	for child: String in directory.get_files(): files.append(path.path_join(child))
