extends SceneTree
## FS002 synthetic content/inventory/current-format fixtures; no world catch claim.

const MANIFEST: String = "res://content/prototype_catalog.tres"
const FISH: PackedStringArray = ["item-bluegill", "item-river-trout", "item-golden-carp"]
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load(MANIFEST)).is_empty(), "production catalog validates")
	_check(catalog.definition_count() == 27 and catalog.fishing_areas().size() == 3, "24 authored definitions plus three adapted areas")
	_metadata(catalog)
	_rejections(catalog)
	_inventory(catalog)
	_capacity()
	_save()
	_check(TestRunEvidence.write_json("fishing-content.json", {"task":"FS002", "proof":"synthetic metadata/inventory/strict current-format fixtures", "assertions":assertions+1, "failures":failures, "schema":SaveCodec.SCHEMA_VERSION, "content":SaveCodec.CONTENT_VERSION, "world_fishing_active":false}), "write report")
	for failure: String in failures: push_error(failure)
	print("FS002 fishing content ", "PASS" if failures.is_empty() else "FAILED", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _metadata(catalog: ContentCatalog) -> void:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/rules.json"))
	for source: Dictionary in rules.items:
		var item: ItemDefinition = catalog.get_item_by_source(source.id)
		_check(item != null, "source item lookup " + source.id)
		if item == null: continue
		_check(item.stable_id == "item-" + source.id.replace("_", "-") and item.stack_limit == source.stackLimit and item.category == source.category, "exact IDs/caps/category " + source.id)
		var feature: Dictionary = source.features[0]
		if source.id == "fishing_rod":
			var rod: RodActivationDefinition = item.rod_activation
			_check(item.is_tool() and item.movable_pickup and not item.giftable and item.fishing_challenge == null, "rod conservation metadata")
			_check(rod != null and rod.activity_id == feature.activityId and rod.target_cell_size_m == feature.targetCellSize/32.0 and rod.maximum_range_m == feature.maximumRange/32.0 and rod.required_surface == feature.requiredSurface and rod.action == feature.action, "exact typed metre rod capability")
		else:
			var challenge: FishingChallengeDefinition = item.fishing_challenge
			_check(item.display_name == source.label and not item.is_tool() and not item.movable_pickup and item.giftable and item.rod_activation == null, "immutable nontool/nonpickup fish " + source.id)
			_check(challenge != null and challenge.difficulty == feature.difficulty and challenge.hook_window_seconds == feature.hookWindowSeconds and challenge.minimum_fight_seconds == feature.minimumFightSeconds and challenge.maximum_fight_seconds == feature.maximumFightSeconds, "exact challenge metadata " + source.id)
			_check(catalog.get_resource(item.stable_id) == null, "fish has no foraging origin")
	_check(SaveCodec.SCHEMA_VERSION == 7 and SaveCodec.CONTENT_VERSION == 1, "same current schema7/content1")

func _fixture() -> ContentManifest:
	var result: ContentManifest = ContentManifest.new()
	var authored: ContentManifest = load(MANIFEST)
	result.fishing_area_layout_path = authored.fishing_area_layout_path
	for definition: ContentDefinition in authored.definitions: result.definitions.append(definition.duplicate(true))
	return result

func _fish(manifest: ContentManifest) -> ItemDefinition:
	for definition: ContentDefinition in manifest.definitions:
		if definition.stable_id == FISH[0]: return definition as ItemDefinition
	return null

func _rejections(published: ContentCatalog) -> void:
	var mutations: Array[Callable] = [
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge = null,
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge.difficulty = "unknown",
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge.hook_window_seconds = NAN,
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge.minimum_fight_seconds = 0,
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge.maximum_fight_seconds = 1,
		func(m: ContentManifest) -> void: _fish(m).fishing_challenge.maximum_fight_seconds = INF,
		func(m: ContentManifest) -> void: _fish(m).category = "tool",
		func(m: ContentManifest) -> void: _fish(m).movable_pickup = true,
		func(m: ContentManifest) -> void: _fish(m).giftable = false,
		func(m: ContentManifest) -> void: _fish(m).stack_limit = 98,
		func(m: ContentManifest) -> void: _fish(m).rod_activation = RodActivationDefinition.new(),
		func(m: ContentManifest) -> void: _fish(m).source_item_id = "fishing_rod",
		func(m: ContentManifest) -> void: m.definitions.append(_fish(m).duplicate(true)),
		func(m: ContentManifest) -> void: m.definitions[18].rod_activation.maximum_range_m = NAN,
		func(m: ContentManifest) -> void: m.definitions[18].rod_activation.target_cell_size_m = 1,
		func(m: ContentManifest) -> void: m.definitions[18].rod_activation.required_surface = "land",
		func(m: ContentManifest) -> void: m.definitions[18].rod_activation = null,
		func(m: ContentManifest) -> void: m.fishing_area_layout_path = "res://content/maps/absent.json",
		func(m: ContentManifest) -> void: m.fishing_area_layout_path = "res://content/maps/../prototype_catalog.tres"
	]
	var original: ItemDefinition = published.get_item(FISH[0])
	for index: int in mutations.size():
		var fixture: ContentManifest = _fixture()
		mutations[index].call(fixture)
		var rejected: ContentCatalog = ContentCatalog.new()
		_check(not rejected.initialize(fixture).is_empty() and not rejected.initialized and rejected.definition_count() == 0, "reject metadata before publication " + str(index))
		_check(not published.initialize(fixture).is_empty() and published.get_item(FISH[0]) == original and published.definition_count() == 27, "failed replacement retains catalog " + str(index))
	_check(original.fishing_challenge.difficulty == "easy" and original.rod_activation == null, "negative fixtures preserve authored nested metadata")

func _inventory(catalog: ContentCatalog) -> void:
	var bag: InventoryState = InventoryState.new()
	_check(bag.initialize(catalog).is_empty(), "bag initializes")
	for id: String in FISH:
		_check(bag.select(id) == PackedStringArray(["missing_owned_item"]), "unowned fish selection refused")
		_check(bag.add(id, 3).is_empty() and bag.select(id).is_empty() and bag.active_tool() == null, "owned fish selects without tool capability " + id)
		var before: Dictionary = bag.snapshot().to_dictionary()
		var revision: int = bag.revision()
		for quantity: Variant in [0, -1, 0.5, 1.0, true, "1", null, NAN, INF, 9223372036854775807]:
			_check(not bag.add(id,quantity).is_empty() and not bag.consume(id,quantity).is_empty(), "invalid fish command " + str(quantity))
			_check(bag.snapshot().to_dictionary() == before and bag.revision() == revision, "failed fish command atomic")
		var snapshot: InventorySnapshot = bag.snapshot()
		snapshot.item_counts[id] = 99
		snapshot.active_item_id = null
		var detached: ItemDefinition = bag.item_definition(id)
		detached.display_name = "Edited"
		detached.fishing_challenge.hook_window_seconds = 999
		var copy: InventoryState = bag.detached_copy()
		copy.consume(id)
		_check(bag.snapshot().to_dictionary() == before and catalog.get_item(id).display_name != "Edited" and catalog.get_item(id).fishing_challenge.hook_window_seconds < 2, "detached snapshots/counts/nested metadata")
		_check(bag.consume(id, 2).is_empty() and bag.count(id) == 1 and bag.snapshot().active_item_id == id, "partial fish consume preserves selection")
		_check(bag.consume(id).is_empty() and bag.snapshot().active_item_id == null and bag.active_tool() == null, "last fish clears selection")
		var placement: WorldItemPlacement = WorldItemPlacement.new(ForagingRegistry.DROP_ID,ForagingRegistry.LOCATION,Vector3.ZERO,WorldItemPlacement.GENERATED)
		placement.item_id = id
		_check(not placement.validation_errors().is_empty(), "fish cannot masquerade as movable rod pickup")

func _capacity() -> void:
	var manifest: ContentManifest = _fixture()
	for index: int in range(18):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "capacity-%d" % index
		item.source_item_id = item.stable_id
		item.display_name = "Synthetic capacity fixture"
		item.description = "Test only."
		item.prototype_fixture = true
		manifest.definitions.append(item)
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(manifest).is_empty(), "capacity catalog")
	var bag: InventoryState = InventoryState.new()
	_check(bag.initialize(catalog).is_empty() and bag.add(FISH[0],98).is_empty() and bag.add(ForagingRegistry.ROD_ITEM).is_empty(), "real fish/rod stacks")
	for index: int in range(18): _check(bag.add("capacity-%d" % index).is_empty(), "fill slot")
	_check(bag.snapshot().item_counts.size() == 20, "twenty types full")
	var before: Dictionary = bag.snapshot().to_dictionary()
	var revision: int = bag.revision()
	_check(bag.add(FISH[1]) == PackedStringArray(["backpack_full"]) and bag.snapshot().to_dictionary() == before and bag.revision() == revision, "full bag refuses new fish atomically")
	_check(bag.can_add(FISH[0]).is_empty() and bag.snapshot().to_dictionary() == before and bag.revision() == revision, "capacity preflight read-only")
	_check(bag.add(FISH[0]).is_empty() and bag.count(FISH[0]) == 99, "full bag permits existing fish stack")
	before = bag.snapshot().to_dictionary()
	revision = bag.revision()
	_check(bag.add(FISH[0]) == PackedStringArray(["stack_full"]) and bag.add(ForagingRegistry.ROD_ITEM) == PackedStringArray(["stack_full"]), "fish99 and rod1 caps")
	_check(bag.snapshot().to_dictionary() == before and bag.revision() == revision, "cap rejection preserves all facts/revision")
	var full: Dictionary = SaveCodec.snapshot(ForagingSaveFixture.make(catalog))
	full.inventory = bag.snapshot().to_dictionary()
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(TestRunSnapshot.exact_json(full),catalog)
	_check(decoded.session != null and decoded.session.inventory.count(FISH[0]) == 99 and decoded.session.inventory.snapshot().item_counts.size() == 20, "strict full-bag fish99 save accepts")
	full = _mutable(full)
	full.inventory.item_counts[FISH[1]] = 1
	_check(SaveCodec.validate(full,catalog).session == null, "strict known twenty-first fish type rejects")
	_check(bag.consume(FISH[0],99).is_empty() and bag.add(FISH[1]).is_empty(), "consumed fish frees slot")

func _save() -> void:
	var pair: Dictionary = SocialSaveFixture.complete()
	var run: GameSession = pair.session
	var old: Dictionary = SaveCodec.snapshot(run)
	for id: String in FISH: _check(run.inventory.add(id,99).is_empty(), "synthetic fish supply " + id)
	for active: Variant in [FISH[0], FISH[1], FISH[2], null]:
		_check(run.inventory.select(active).is_empty(), "saved selection " + str(active))
		var data: Dictionary = SaveCodec.snapshot(run)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(TestRunSnapshot.exact_json(data),pair.actors,pair.catalog)
		_check(decoded.session != null and decoded.errors.is_empty(), "legitimate fish99/selection decode")
		if decoded.session != null:
			_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(decoded.session)) == TestRunSnapshot.exact_json(data) and TestRunSnapshot.weather(decoded.session.environment) == TestRunSnapshot.weather(run.environment), "exact typed full snapshot/forecast roundtrip")
			decoded.session.inventory.consume(FISH[0])
			_check(SaveCodec.snapshot(run) == data, "decoded inventory detached")
		var without_inventory: Dictionary = data.duplicate(true)
		without_inventory.inventory = old.inventory
		_check(without_inventory == old, "fish additions preserve every social/environment/quest/party/rod fact")
	var good: Dictionary = SaveCodec.snapshot(run)
	for id: String in FISH:
		for quantity: Variant in [0,-1,1.5,100,true,"1",null,NAN,INF,9223372036854775807]:
			var bad: Dictionary = _mutable(good)
			bad.inventory.item_counts[id] = quantity
			_check(SaveCodec.validate(bad,pair.actors,pair.catalog).session == null, "malformed fish count rejected " + id + "/" + str(quantity))
			# Nonfinite values are plain-data negatives only: JSON cannot represent
			# them, and asking Godot to stringify them emits a diagnostic itself.
			if not (typeof(quantity) == TYPE_FLOAT and not is_finite(quantity)):
				_check(SaveCodec.decode(TestRunSnapshot.exact_json(bad),pair.actors,pair.catalog).session == null, "raw malformed fish count rejected")
	var raw: String = TestRunSnapshot.exact_json(good)
	_check(SaveCodec.decode(raw.replace('"item-bluegill":99', '"item-bluegill":99,"item-bluegill":1'),pair.actors,pair.catalog).session == null, "duplicate JSON fish key rejected")
	for mutation: String in ["unknown", "unowned", "double-rod", "missing-rod", "fish-origin", "fish-placement", "attempt"]:
		var bad: Dictionary = _mutable(good)
		match mutation:
			"unknown": bad.inventory.item_counts["bluegill"] = 1
			"unowned": bad.inventory.item_counts.erase(FISH[0]); bad.inventory.active_item_id = FISH[0]
			"double-rod": bad.inventory.item_counts[ForagingRegistry.ROD_ITEM] = 1
			"missing-rod": bad.world_item_placements.clear()
			"fish-origin": bad.collected_resource_ids.append(FISH[0])
			"fish-placement": bad.world_item_placements[0].item_id = FISH[0]
			"attempt": bad.fishing_attempt = {"phase":"fighting"}
		_check(SaveCodec.validate(bad,pair.actors,pair.catalog).session == null and SaveCodec.snapshot(run) == good, "reject " + mutation + "; source untouched")

func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)

func _mutable(data: Dictionary) -> Dictionary:
	# Snapshot counts are typed. Hostile plain-data fixtures must avoid coercion.
	var result: Dictionary = data.duplicate(true)
	var counts: Dictionary = {}
	for id: String in data.inventory.item_counts: counts[id] = data.inventory.item_counts[id]
	result.inventory.item_counts = counts
	return result
