extends SceneTree
## F002 synthetic rule fixtures, not world collection, UI, persistence or route proof.
## Extra item types exist only in detached test manifests.

const MANIFEST: String = "res://content/prototype_catalog.tres"
const FLOWER: String = "item-moonflower"
const ROD: String = "item-fishing-rod"
var failures: PackedStringArray = []
var assertions: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(load(MANIFEST) as ContentManifest).is_empty(), "production catalog validates")
	_check(catalog.definition_count() == 27, "21 prior + 3 fish + 3 adapted areas")
	_definitions(catalog)
	_invalid_catalogs(catalog)
	_capacity()
	_selection_and_quantities(catalog)
	_detachment(catalog)
	_check(TestRunEvidence.write_json("inventory-report.json", {
		"task": "F002", "proof": "synthetic detached rule fixtures",
		"assertions": assertions + 1, "failures": failures,
		"production_definitions": catalog.definition_count(), "maximum_types": InventoryState.MAX_TYPES,
		"world_ui_activation": false, "save_schema_version": SaveCodec.SCHEMA_VERSION
	}), "write acceptance evidence")
	for failure: String in failures:
		push_error(failure)
	print("F002 inventory_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)


func _definitions(catalog: ContentCatalog) -> void:
	var flower: ItemDefinition = catalog.get_item(FLOWER)
	var rod: ItemDefinition = catalog.get_item(ROD)
	_check(flower != null and rod != null, "typed item lookups")
	if flower == null or rod == null:
		return
	_check(flower.source_item_id == "moonflower" and flower.category == "forage" and flower.stack_limit == 99 and not flower.movable_pickup, "flower source behavior")
	_check(rod.source_item_id == "fishing_rod" and rod.is_tool() and rod.stack_limit == 1 and rod.movable_pickup, "rod source behavior")
	_check("unavailable" in rod.description, "no working fishing claim")
	for mapping: Dictionary in [
		{"resource": "resource-moonflower", "item": FLOWER, "source": "moonflower", "hold": 600},
		{"resource": "resource-fishing-rod", "item": ROD, "source": "fishing_rod", "hold": 500}
	]:
		var resource: ForagingResourceDefinition = catalog.get_resource(mapping.resource)
		_check(resource != null and resource.item_id == mapping.item and resource.source_resource_id == mapping.source and resource.hold_milliseconds == mapping.hold, "distinct resource/item resolution: " + mapping.resource)
		_check(catalog.get_item(mapping.resource) == null and catalog.get_resource(mapping.item) == null, "wrong namespace lookup rejects")
	_check(catalog.get_item("moonflower") == null and catalog.get_resource("fishing_rod") == null, "source provenance is not a duplicate key")


func _invalid_catalogs(catalog: ContentCatalog) -> void:
	var bad: ContentManifest = _fixture()
	(bad.definitions[17] as ItemDefinition).stack_limit = 0
	_reject(bad, "stack_limit")
	bad = _fixture()
	(bad.definitions[17] as ItemDefinition).stack_limit = 100
	_reject(bad, "stack_limit")
	bad = _fixture()
	(bad.definitions[17] as ItemDefinition).category = "invalid"
	_reject(bad, "item category")
	bad = _fixture()
	(bad.definitions[17] as ItemDefinition).movable_pickup = true
	_reject(bad, "movable pickup must be a tool")
	bad = _fixture()
	(bad.definitions[17] as ItemDefinition).source_item_id = " "
	_reject(bad, "source_item_id")
	bad = _fixture()
	(bad.definitions[17] as ItemDefinition).description = " "
	_reject(bad, "item description")
	bad = _fixture()
	(bad.definitions[18] as ItemDefinition).source_item_id = "moonflower"
	_reject(bad, "duplicate source item ID")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).item_id = "absent-item"
	_reject(bad, "absent/wrong item")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).item_id = "prototype-hero"
	_reject(bad, "absent/wrong item")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).item_id = "resource-fishing-rod"
	_reject(bad, "absent/wrong item")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).source_resource_id = "fishing_rod"
	_reject(bad, "source IDs must match")
	_reject(bad, "duplicate source resource ID")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).source_resource_id = " "
	_reject(bad, "source_resource_id")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).hold_milliseconds = 0
	_reject(bad, "hold_milliseconds")
	bad = _fixture()
	(bad.definitions[19] as ForagingResourceDefinition).item_id = " "
	_reject(bad, "resource item_id")
	bad = _fixture()
	bad.definitions[19].stable_id = FLOWER
	_reject(bad, "duplicate stable ID")
	var prior_item: ItemDefinition = catalog.get_item(FLOWER)
	var prior_resource: ForagingResourceDefinition = catalog.get_resource("resource-moonflower")
	_check(not catalog.initialize(bad).is_empty(), "bad replacement rejected")
	_check(catalog.initialized and catalog.definition_count() == 27 and catalog.get_item(FLOWER) == prior_item and catalog.get_resource("resource-moonflower") == prior_resource, "bad replacement retains all published item/resource indexes")


func _capacity() -> void:
	var fixture: ContentManifest = _fixture()
	for index: int in range(19):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "test-only-item-%02d" % index
		item.display_name = "Synthetic capacity item %02d" % index
		item.source_item_id = "test-only-source-%02d" % index
		item.prototype_fixture = true
		item.description = "Detached F002 capacity fixture; never production content."
		fixture.definitions.append(item)
	var catalog: ContentCatalog = ContentCatalog.new()
	_check(catalog.initialize(fixture).is_empty(), "detached capacity manifest validates")
	var bag: InventoryState = _bag(catalog)
	_check(bag.add(FLOWER, 98).is_empty() and bag.add(ROD).is_empty(), "fill real stacks")
	# Reverse insertion deliberately exercises stable snapshot ordering.
	for index: int in range(17, -1, -1):
		_check(bag.add("test-only-item-%02d" % index).is_empty(), "accept distinct type %d" % (20 - index))
	_check(bag.snapshot().item_counts.size() == 20, "accept exactly 20 types")
	_check(bag.select(ROD).is_empty(), "select full-bag rod")
	var before: Dictionary = bag.snapshot().to_dictionary()
	_check(bag.add("test-only-item-18") == PackedStringArray(["backpack_full"]), "reject 21st type")
	_same(bag, before, "21st type rejection")
	_check(bag.can_add(FLOWER).is_empty(), "preflight existing stack in full bag")
	_same(bag, before, "preflight is read-only")
	_check(bag.add(FLOWER).is_empty() and bag.count(FLOWER) == 99 and bag.snapshot().item_counts.size() == 20, "existing stack grows in full bag")
	before = bag.snapshot().to_dictionary()
	_check(bag.add(FLOWER) == PackedStringArray(["stack_full"]), "reject 100th flower")
	_same(bag, before, "flower cap rejection")
	_check(bag.add(ROD) == PackedStringArray(["stack_full"]), "reject second rod")
	_same(bag, before, "rod cap rejection")
	_check(bag.add(FLOWER, 9223372036854775807) == PackedStringArray(["stack_full"]), "reject integer overflow without addition")
	_same(bag, before, "huge quantity rejection")
	var ids: Array[String] = bag.snapshot().item_counts.keys()
	var sorted_ids: Array[String] = ids.duplicate()
	sorted_ids.sort()
	_check(ids == sorted_ids, "snapshot stable item-ID ordering")
	_check(bag.consume("test-only-item-00").is_empty() and bag.add("test-only-item-18").is_empty(), "consumed stack frees capacity")
	_check(bag.snapshot().item_counts.size() == 20, "capacity after slot reuse")


func _selection_and_quantities(catalog: ContentCatalog) -> void:
	var bag: InventoryState = _bag(catalog)
	_check(bag.snapshot().item_counts.is_empty() and bag.snapshot().active_item_id == null, "fresh inventory empty and nullable selection")
	var before: Dictionary = bag.snapshot().to_dictionary()
	_check(bag.select(ROD) == PackedStringArray(["missing_owned_item"]), "selection requires ownership")
	_same(bag, before, "missing selection rejection")
	_check(bag.add(FLOWER, 3).is_empty() and bag.add(ROD).is_empty(), "add without auto-equip")
	_check(bag.snapshot().active_item_id == null and bag.active_tool() == null, "pickup never silently activates a tool")
	_check(bag.select(ROD).is_empty() and bag.active_tool() == catalog.get_item(ROD), "owned rod derives active tool from definition")
	for quantity: Variant in [0, -1, 0.5, 1.5, 1.0, NAN, INF, true, "1", null]:
		before = bag.snapshot().to_dictionary()
		_check(bag.add(FLOWER, quantity) == PackedStringArray(["invalid_quantity"]), "reject invalid add quantity " + str(quantity))
		_same(bag, before, "invalid add quantity")
		_check(bag.consume(ROD, quantity) == PackedStringArray(["invalid_quantity"]), "reject invalid consume quantity " + str(quantity))
		_same(bag, before, "invalid consume quantity")
	for id: String in ["", "absent", "resource-moonflower", "prototype-hero", "moonflower"]:
		before = bag.snapshot().to_dictionary()
		_check(bag.add(id) == PackedStringArray(["unknown_item"]), "unknown add ID " + id)
		_same(bag, before, "unknown add")
		_check(bag.consume(id) == PackedStringArray(["unknown_item"]), "unknown consume ID " + id)
		_same(bag, before, "unknown consume")
		_check(bag.select(id) == PackedStringArray(["unknown_item"]), "unknown selection ID " + id)
		_same(bag, before, "unknown selection")
	for id: Variant in [true, 1, 1.5, {}]:
		before = bag.snapshot().to_dictionary()
		_check(bag.select(id) == PackedStringArray(["unknown_item"]), "non-string selection rejection")
		_same(bag, before, "invalid selection type")
	before = bag.snapshot().to_dictionary()
	_check(bag.consume(ROD, 2) == PackedStringArray(["insufficient_items"]), "consume over owned count")
	_same(bag, before, "insufficient consumption retains active")
	_check(bag.consume(ROD).is_empty() and bag.count(ROD) == 0 and bag.snapshot().active_item_id == null and bag.active_tool() == null, "last active rod consumption clears selection")
	before = bag.snapshot().to_dictionary()
	_check(bag.consume(ROD) == PackedStringArray(["insufficient_items"]), "consume missing item")
	_same(bag, before, "missing consume")
	_check(bag.select(FLOWER).is_empty() and bag.active_tool() == null, "forage selection never claims tool use")
	_check(bag.consume(FLOWER, 2).is_empty() and bag.snapshot().active_item_id == FLOWER, "partial consumption retains selection")
	_check(bag.select(null).is_empty() and bag.snapshot().active_item_id == null and bag.count(FLOWER) == 1, "explicit nullable deselection preserves counts")
	_check(bag.select(FLOWER).is_empty() and bag.consume(FLOWER).is_empty(), "consume last selected forage")
	_check(bag.snapshot().item_counts.is_empty() and bag.snapshot().active_item_id == null, "final active flower clears selection and stack")
	before = bag.snapshot().to_dictionary()
	_check(not bag.initialize(catalog).is_empty(), "inventory reinitialization rejected")
	_same(bag, before, "reinitialization preserves state")
	var unready: InventoryState = InventoryState.new()
	_check(not unready.initialize(null).is_empty() and not unready.initialize(ContentCatalog.new()).is_empty() and not unready.initialized, "inventory init atomic when catalog absent/unready")
	_check(not unready.add(FLOWER).is_empty() and not unready.consume(ROD).is_empty() and not unready.select(null).is_empty(), "unready inventory commands reject")
	_check(unready.snapshot().item_counts.is_empty() and unready.snapshot().active_item_id == null, "failed initialization leaves empty facts")


func _detachment(catalog: ContentCatalog) -> void:
	var before_content: Array[Dictionary] = _authored_facts(catalog)
	var first: GameSession = GameSession.new()
	var second: GameSession = GameSession.new()
	_check(first.initialize(catalog, "prototype-test-room", "prototype-start", "prototype-hero").is_empty(), "first session init")
	_check(second.initialize(catalog, "prototype-test-room", "prototype-start", "prototype-hero").is_empty(), "second session init")
	_check(first.inventory != second.inventory, "sessions own different inventories")
	_check(first.inventory.add(FLOWER, 5).is_empty() and first.inventory.add(ROD).is_empty() and first.inventory.select(ROD).is_empty(), "first session changes")
	_check(second.inventory.snapshot().item_counts.is_empty() and second.inventory.snapshot().active_item_id == null, "first cannot alter second session")
	var before: Dictionary = first.inventory.snapshot().to_dictionary()
	var detached: InventorySnapshot = first.inventory.snapshot()
	detached.item_counts[FLOWER] = 99
	detached.item_counts.erase(ROD)
	detached.active_item_id = FLOWER
	_same(first.inventory, before, "mutated snapshot is detached")
	var plain: Dictionary = first.inventory.snapshot().to_dictionary()
	plain.item_counts.clear()
	plain.active_item_id = null
	_same(first.inventory, before, "mutated plain snapshot is detached")
	_check(second.inventory.add(FLOWER).is_empty() and second.inventory.select(FLOWER).is_empty(), "second independent changes")
	_same(first.inventory, before, "second cannot alter first session")
	_check(first.inventory.consume(ROD).is_empty(), "first generic consume")
	_check(second.inventory.count(FLOWER) == 1 and second.inventory.snapshot().active_item_id == FLOWER, "first consume cannot alter second")
	_check(_authored_facts(catalog) == before_content, "authored item/resource metadata unchanged across two sessions")
	_check(catalog.get_item(FLOWER) == (load("res://content/items/moonflower.tres") as ItemDefinition), "cached authored item still shared immutable data")
	var invalid: GameSession = GameSession.new()
	_check(not invalid.initialize(catalog, "absent-location", "prototype-start", "prototype-hero").is_empty(), "bad session rejects before inventory publication")
	_check(not invalid.initialized and not invalid.inventory.initialized and invalid.inventory.snapshot().item_counts.is_empty(), "bad session has no partial inventory")
	_check(SaveCodec.SCHEMA_VERSION == 7 and SaveCodec.snapshot(first).inventory == first.inventory.snapshot().to_dictionary(), "F004 serializes detached inventory")


func _authored_facts(catalog: ContentCatalog) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: String in [FLOWER, ROD]:
		var item: ItemDefinition = catalog.get_item(id)
		result.append({"id": item.stable_id, "name": item.display_name, "fixture": item.prototype_fixture, "source": item.source_item_id, "category": item.category, "cap": item.stack_limit, "movable": item.movable_pickup, "description": item.description})
	for id: String in ["resource-moonflower", "resource-fishing-rod"]:
		var resource: ForagingResourceDefinition = catalog.get_resource(id)
		result.append({"id": resource.stable_id, "name": resource.display_name, "fixture": resource.prototype_fixture, "source": resource.source_resource_id, "item": resource.item_id, "hold": resource.hold_milliseconds})
	return result


func _fixture() -> ContentManifest:
	var result: ContentManifest = ContentManifest.new()
	result.fishing_area_layout_path = (load(MANIFEST) as ContentManifest).fishing_area_layout_path
	for definition: ContentDefinition in (load(MANIFEST) as ContentManifest).definitions:
		result.definitions.append(definition.duplicate(true) as ContentDefinition)
	return result


func _bag(catalog: ContentCatalog) -> InventoryState:
	var result: InventoryState = InventoryState.new()
	_check(result.initialize(catalog).is_empty(), "inventory init")
	return result


func _reject(manifest: ContentManifest, expected: String) -> void:
	var catalog: ContentCatalog = ContentCatalog.new()
	var errors: PackedStringArray = catalog.initialize(manifest)
	_check(expected in "; ".join(errors), "catalog rejection includes " + expected)
	_check(not catalog.initialized and catalog.definition_count() == 0 and catalog.get_item(FLOWER) == null and catalog.get_resource("resource-moonflower") == null, "invalid catalog publishes no partial index")


func _same(bag: InventoryState, before: Dictionary, label: String) -> void:
	_check(bag.snapshot().to_dictionary() == before, "atomic/detached state: " + label)


func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
