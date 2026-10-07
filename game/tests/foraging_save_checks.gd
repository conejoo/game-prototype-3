extends SceneTree
## Synthetic hostile facts + real staged-room rollback; no ordinary-input claim.
var failures: PackedStringArray = []
var assertions: int = 0
var rejected: Array[String] = []
var catalog: ContentCatalog = ContentCatalog.new()
var game: Node3D

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "catalog")
	for kind: String in ["bag", "alderwake", "tollworks", "authored"]:
		var run: GameSession = ForagingSaveFixture.make(catalog, kind)
		var data: Dictionary = SaveCodec.snapshot(run)
		var bytes: String = JSON.stringify(data, "", true, true)
		var decoded: SaveCodec.DecodeResult = SaveCodec.decode(bytes, catalog)
		_check(decoded.session != null and decoded.errors.is_empty() and not decoded.migrated, "round-trip " + kind)
		if decoded.session != null:
			_check(SaveCodec.snapshot(decoded.session) == data and decoded.session.foraging.revision() == 0, "exact durable facts/fresh revision " + kind)
			decoded.session.inventory.consume("item-moonflower")
			_check(SaveCodec.snapshot(run) == data, "detached candidate " + kind)
		_check(not run.foraging.restore_facts(data.inventory, PackedStringArray(data.collected_resource_ids), data.world_item_placements).is_empty(), "live hydration refused " + kind)
	var good: Dictionary = SaveCodec.snapshot(ForagingSaveFixture.make(catalog))
	for quantity: Variant in [0, -1, 1.5, 100, true, "1", null, INF, NAN]:
		var bad: Dictionary = _mutable(good)
		bad.inventory.item_counts["item-moonflower"] = quantity
		_reject(bad, "quantity " + str(quantity))
	for active: Variant in ["missing", "resource-moonflower", false, 1, ""]:
		var bad: Dictionary = _mutable(good)
		bad.inventory.active_item_id = active
		_reject(bad, "active " + str(active))
	for counts: Variant in [null, [], true, {"unknown":1}, {"resource-moonflower":1}, {"item-fishing-rod":2}]:
		var bad: Dictionary = _mutable(good)
		bad.inventory.item_counts = counts
		_reject(bad, "counts " + str(counts))
	for ids: Variant in [null, {}, true, [false], ["moonflower-99"], [ForagingRegistry.DROP_ID], ["moonflower-01", "moonflower-01"], []]:
		var bad: Dictionary = _mutable(good)
		bad.collected_resource_ids = ids
		_reject(bad, "collected " + str(ids))
	for field: String in ["inventory", "collected_resource_ids", "world_item_placements"]:
		var bad: Dictionary = _mutable(good)
		bad.erase(field)
		_reject(bad, "missing " + field)
	var world: Dictionary = SaveCodec.snapshot(ForagingSaveFixture.make(catalog, "alderwake"))
	for pair: Array in [["instance_id","alias"], ["item_id","item-moonflower"], ["origin_instance_id","moonflower-01"], ["location_id","alderwake"], ["location_id","prototype-test-room"], ["provenance","unknown"], ["foot_xyz_m",[0,0]], ["foot_xyz_m",[0,true,0]], ["foot_xyz_m",[0,INF,0]], ["foot_xyz_m",[0,0,10001]], ["item_id",null]]:
		var bad: Dictionary = _mutable(world)
		bad.world_item_placements[0][pair[0]] = pair[1]
		_reject(bad, "placement " + str(pair))
	for mutation: String in ["duplicate", "bag-and-world", "generated-unsuppressed", "authored-suppressed", "extra", "missing"]:
		var bad: Dictionary = _mutable(world)
		match mutation:
			"duplicate": bad.world_item_placements.append(bad.world_item_placements[0].duplicate(true))
			"bag-and-world": bad.inventory.item_counts[ForagingRegistry.ROD_ITEM] = 1
			"generated-unsuppressed": bad.collected_resource_ids.erase(ForagingRegistry.ROD_ORIGIN)
			"authored-suppressed": bad.world_item_placements[0].provenance = WorldItemPlacement.AUTHORED; bad.world_item_placements[0].instance_id = ForagingRegistry.ROD_ORIGIN
			"extra": bad.world_item_placements[0]["node"] = "NodePath"
			"missing": bad.world_item_placements[0].erase("item_id")
		_reject(bad, mutation)
	var raw: String = JSON.stringify(good)
	_check(SaveCodec.decode(raw.replace('"item-moonflower":3', '"item-moonflower":2,"item-moonflower":3'), catalog).session == null, "duplicate count lexeme")
	_check(SaveCodec.decode(raw.replace('"item-moonflower":3', '"item-\\u006doonflower":2,"item-moonflower":3'), catalog).session == null, "escaped duplicate count lexeme")
	for quantity_token: String in ["3.00000000000000001", "2.99999999999999999", "300000000000000001e-17"]:
		_check(SaveCodec.decode(raw.replace('"item-moonflower":3', '"item-moonflower":' + quantity_token), catalog).session == null, "rounded fraction rejected " + quantity_token)
	for quantity_token: String in ["3.0", "3e0", "30e-1"]:
		_check(SaveCodec.decode(raw.replace('"item-moonflower":3', '"item-moonflower":' + quantity_token), catalog).session != null, "whole JSON number accepted " + quantity_token)
	_check(SaveCodec.decode(" ".repeat(SaveCodec.MAX_BYTES + 1), catalog).session == null, "128KiB")
	var future: Dictionary = _mutable(good)
	future.schema_version = 7
	_check(SaveCodec.validate(future,catalog).incompatible, "newer protected")
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/environment_save_v5.json"))
	var previous: String = JSON.stringify(legacy, "", true, true)
	var migrated: SaveCodec.DecodeResult = SaveCodec.validate(legacy, catalog)
	var expected: Dictionary = legacy.duplicate(true)
	expected.schema_version = 6
	expected["inventory"] = {"item_counts":{}, "active_item_id":null}
	expected["collected_resource_ids"] = []
	expected["world_item_placements"] = []
	_check(migrated.session != null and migrated.migrated and JSON.parse_string(JSON.stringify(SaveCodec.snapshot(migrated.session),"",true,true)) == JSON.parse_string(JSON.stringify(expected,"",true,true)) and JSON.stringify(legacy,"",true,true) == previous, "v5 exact prior facts/defaults/detachment")
	_capacity_save(good)
	var empty: GameSession = GameSession.new()
	empty.initialize(catalog, ForagingRegistry.LOCATION, "alderwake-start", "prototype-hero")
	var empty_data: Dictionary = SaveCodec.snapshot(empty)
	var empty_restored: GameSession = SaveCodec.validate(empty_data,catalog).session
	_check(not empty_restored.foraging.restore_facts(empty_data.inventory, [], []).is_empty(), "empty hydrated candidate cannot hydrate twice")
	await _lifecycle(good, world)
	_check(TestRunEvidence.write_json("foraging-save-report.json", {"assertions":assertions + 1,"rejections":rejected,"failures":failures,"proof":"synthetic facts and staged production physics"}), "report")
	for failure: String in failures: push_error(failure)
	print("F004 foraging_save_checks ", "PASS" if failures.is_empty() else "FAILED", "; assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _lifecycle(good: Dictionary, world: Dictionary) -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	# Root debug slot setup runs in _ready; isolate after it completes.
	game.save_repository = SaveRepository.new("user://saves/f004-lifecycle-" + str(OS.get_process_id()) + ".json")
	game._set_paused(true)
	_write(JSON.stringify(good,"",true,true))
	_check((await game.load_run()).is_empty(), "initial item load")
	var live: GameSession = game.session
	var room: PrototypeLocation = game.world_host.current_location
	var before: Dictionary = SaveCodec.snapshot(live)
	_check(room.foraging_facts().collected_resource_ids == PackedStringArray(before.collected_resource_ids), "world-fact hydration")
	var malformed: Dictionary = _mutable(good)
	malformed.inventory.active_item_id = "missing"
	_write(JSON.stringify(malformed))
	_check(not (await game.load_run()).is_empty() and game.session == live and game.world_host.current_location == room and SaveCodec.snapshot(live) == before, "malformed rollback")
	for point: Vector3 in [Vector3(-8,0,15.75), Vector3(26,0.25,-2), Vector3(3,4,0), Vector3(999,0,999), Vector3.ZERO, Vector3(107.25,0,-1.25)]:
		var unsafe: Dictionary = _mutable(world)
		unsafe.world_item_placements[0].foot_xyz_m = [point.x,point.y,point.z]
		_write(JSON.stringify(unsafe,"",true,true))
		_check(not (await game.load_run()).is_empty(), "unsafe saved geometry " + str(point))
		_check(game.session == live and game.world_host.current_location == room and SaveCodec.snapshot(live) == before, "geometry rollback " + str(point))
		_check(paused and not game.loading_save and not game.world_host.transitioning and game.world_host.get_child_count() == 1, "geometry rollback lifecycle")
	# Foreign-room unsafe record must also fail before current room/session swap.
	var foreign: Dictionary = _mutable(world)
	foreign.location_id = "prototype-tollworks"
	foreign.spawn_id = "tollworks-from-alderwake"
	foreign.world_item_placements[0].foot_xyz_m = [-8,0,15.75]
	_write(JSON.stringify(foreign,"",true,true))
	_check(not (await game.load_run()).is_empty() and game.session == live and game.world_host.current_location == room and SaveCodec.snapshot(live) == before, "foreign geometry rollback")
	# Failed navigation/travel preserves collection as well as old session.
	var definition: LocationDefinition = game.catalog.get_location("prototype-alderwake")
	var old_path: String = definition.scene_path
	definition.scene_path = "res://tests/fixtures/map_save_retry_failure.tscn"
	_check(game.world_host.request_transition("prototype-alderwake","alderwake-start").is_empty(), "failed travel start")
	var arrival: Array = await game.world_host.transition_finished
	_check(not arrival[0] and game.session == live and game.world_host.current_location == room and SaveCodec.snapshot(live) == before, "failed travel preserves items")
	definition.scene_path = old_path
	game.player_placeholder.state.health = 0
	await game.retry_encounter()
	game._set_paused(true)
	_check(game.session == live and game.session.foraging.snapshot().inventory == before.inventory and game.session.foraging.snapshot().collected_resource_ids == PackedStringArray(before.collected_resource_ids), "retry keeps bag/selection/collection")
	_check(game.world_host.current_location != room and game.world_host.current_location.foraging_facts().collected_resource_ids == PackedStringArray(before.collected_resource_ids), "retry rehydrates facts")
	for target: Array in [["prototype-tollworks","tollworks-from-alderwake"],["prototype-alderwake","alderwake-from-tollworks"]]:
		game.world_host.request_transition(target[0],target[1])
		await game.world_host.transition_finished
		_check(game.session == live and game.session.foraging.snapshot().inventory == before.inventory, "travel retains items")
		_check(game.world_host.current_location.foraging_facts().collected_resource_ids == PackedStringArray(before.collected_resource_ids), "travel facts binding")
	game.queue_free()
	await process_frame
	paused = false

func _write(raw: String) -> void:
	DirAccess.make_dir_recursive_absolute(game.save_repository.path.get_base_dir())
	var file: FileAccess = FileAccess.open(game.save_repository.path,FileAccess.WRITE)
	file.store_string(raw)
	file.close()

func _reject(data: Dictionary, label: String) -> void:
	var result: SaveCodec.DecodeResult = SaveCodec.validate(data,catalog)
	_check(result.session == null and not result.errors.is_empty(), "reject " + label)
	rejected.append(label)

func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)


func _mutable(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key: Variant in value: result[key] = _mutable(value[key])
		return result
	if value is Array or value is PackedStringArray:
		var result: Array = []
		for element: Variant in value: result.append(_mutable(element))
		return result
	return value


func _capacity_save(good: Dictionary) -> void:
	var manifest: ContentManifest = ContentManifest.new()
	manifest.definitions.assign((load("res://content/prototype_catalog.tres") as ContentManifest).definitions)
	for index: int in range(19):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "test-only-save-item-%02d" % index
		item.source_item_id = "test-only-save-source-%02d" % index
		item.display_name = "Synthetic save capacity fixture"
		item.description = "Test-only; never production content."
		item.prototype_fixture = true
		manifest.definitions.append(item)
	var fixture_catalog: ContentCatalog = ContentCatalog.new()
	_check(fixture_catalog.initialize(manifest).is_empty(), "save capacity fixture catalog")
	var full: Dictionary = _mutable(good)
	for index: int in range(18): full.inventory.item_counts["test-only-save-item-%02d" % index] = 1
	full.inventory.item_counts["item-moonflower"] = 99
	var result: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(full,"",true,true),fixture_catalog)
	_check(result.session != null and result.session.inventory.snapshot().item_counts.size() == 20 and result.session.inventory.count("item-moonflower") == 99, "20-type cap99 save accepts")
	full.inventory.item_counts["test-only-save-item-18"] = 1
	_check(SaveCodec.validate(full,fixture_catalog).session == null, "known 21st saved type rejects")
