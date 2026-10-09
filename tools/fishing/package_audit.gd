extends SceneTree
## External FS008 read-only packed audit. Detached inventory fixtures are synthetic.
var failures: PackedStringArray = []
var assertions: int = 0
var files: PackedStringArray = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--audit-output="): output = argument.trim_prefix("--audit-output=")
	_scan("res://")
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "packed catalog initializes")
	var npcs: NpcContentCatalog = NpcContentCatalog.new()
	_check(npcs.initialize_path(catalog).is_empty(), "packed social catalog initializes")
	var fish: Dictionary = {}
	for spec: Array in [["bluegill","Bluegill","easy",1.2,2.0,5.0],["river_trout","River Trout","medium",.9,6.0,12.0],["golden_carp","Golden Carp","hard",.7,15.0,30.0]]:
		var item: ItemDefinition = catalog.get_item_by_source(spec[0])
		_check(item != null, "packed fish " + spec[0])
		if item == null: continue
		var challenge: FishingChallengeDefinition = item.fishing_challenge
		_check(item.stable_id == "item-"+str(spec[0]).replace("_","-") and item.display_name == spec[1] and item.category == "fish" and item.stack_limit == 99 and not item.is_tool() and not item.movable_pickup, "fish identity/capability " + spec[0])
		_check(challenge != null and challenge.difficulty == spec[2] and challenge.hook_window_seconds == spec[3] and challenge.minimum_fight_seconds == spec[4] and challenge.maximum_fight_seconds == spec[5], "species rules " + spec[0])
		var icon: Texture2D = ForagingItemVisual.icon(item.stable_id)
		_check(icon != null and icon.get_width() > 0 and icon.get_height() > 0, "packed fish icon " + spec[0])
		fish[item.stable_id] = {"name":item.display_name,"cap":item.stack_limit,"icon_size":icon.get_size() if icon != null else Vector2.ZERO}
	var rod: ItemDefinition = catalog.get_item("item-fishing-rod")
	_check(rod != null and rod.rod_activation != null and rod.rod_activation.maximum_range_m == 12.0 and rod.rod_activation.target_cell_size_m == .5, "packed rod capability")
	var areas: Array[FishingAreaDefinition] = catalog.fishing_areas()
	_check(areas.size() == 3, "three adapted packed areas")
	var profiles: Dictionary = {}
	for area: FishingAreaDefinition in areas:
		_check(area.validation_errors().is_empty(), "valid packed area " + area.stable_id)
		profiles[area.stable_id] = {"shape":area.shape_kind,"weight":area.blend_weight,"items":area.outcome_source_ids,"probabilities":area.probabilities}
	_check(FileAccess.get_sha256("res://content/maps/alderwake_layout.json") == "7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be", "exact area/geography source bytes")
	for path: String in ["res://features/fishing/fishing_challenge_controller.gd","res://features/fishing/fishing_session_service.gd","res://features/fishing/fishing_water_target_resolver.gd","res://ui/fishing_view.gd"]:
		_check(ResourceLoader.exists(path), "packed runtime " + path)
	for path: String in files:
		_check(not path.begins_with("res://tests/") and not path.begins_with("res://tools/") and not path.begins_with("res://docs/") and not path.contains("reference/manifest") and not path.contains("game-prototype-2") and not path.ends_with(".dart") and not path.ends_with(".blend"), "no test/reference-audit/source dependency " + path)
	var fresh: GameSession = GameSession.new()
	_check(fresh.initialize(catalog,"prototype-alderwake","alderwake-start","prototype-hero",null,npcs).is_empty(), "fresh packed session")
	var baseline: Dictionary = SaveCodec.snapshot(fresh)
	_check(fresh.inventory.snapshot().item_counts.is_empty() and fresh.inventory.active_tool() == null, "fresh bag empty/unselected")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1, "schema8/content1")
	var fixture: SaveCodec.DecodeResult = SaveCodec.validate(baseline,catalog,npcs)
	_check(fixture.errors.is_empty() and fixture.session != null, "detached fixture baseline")
	if fixture.session != null:
		for id: String in fish:
			_check(fixture.session.inventory.add(id,99).is_empty() and fixture.session.inventory.select(id).is_empty() and fixture.session.inventory.active_tool() == null, "synthetic packed fish count/selection " + id)
		var saved: Dictionary = SaveCodec.snapshot(fixture.session)
		var restored: SaveCodec.DecodeResult = SaveCodec.validate(saved,catalog,npcs)
		_check(restored.errors.is_empty() and restored.session != null and SaveCodec.snapshot(restored.session) == saved, "exact typed packed fish restore")
		saved.inventory = baseline.inventory
		_check(saved == baseline and SaveCodec.snapshot(fresh) == baseline, "synthetic fish fixture preserves all baseline facts/rod")
	var game: Variant = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0] and game.session.initialized and game.session.inventory.snapshot().item_counts.is_empty(), "actual packed root fresh arrival/bag")
	_check(game.fishing.snapshot().mode == "idle" and game.ui.fishing_view != null, "actual packed root fishing idle/view")
	var live: Dictionary = SaveCodec.snapshot(game.session)
	_check(not live.has("fishing_attempt") and not live.has("fishing"), "live save has no transient fishing")
	game.queue_free()
	await process_frame
	var file: FileAccess = FileAccess.open(output,FileAccess.WRITE)
	if file == null: push_error("Cannot write FS008 pack audit"); quit(1); return
	file.store_string(JSON.stringify({"task":"FS008","pid":OS.get_process_id(),"assertions":assertions,"failures":failures,"fish":fish,"areas":profiles,"fresh_live_snapshot":live,"files":files,"provenance":"Packed live startup plus explicitly synthetic detached inventory fixture; no native catch claim"},"\t",true,true)+"\n")
	file.close()
	for failure: String in failures: push_error(failure)
	print("FS008 packed fishing audit ","PASS" if failures.is_empty() else "FAILED"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _scan(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null: return
	directory.include_hidden = true
	for child: String in directory.get_directories(): _scan(path.path_join(child))
	for child: String in directory.get_files(): files.append(path.path_join(child))
