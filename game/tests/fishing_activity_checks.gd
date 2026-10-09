extends SceneTree
## FS002 frozen exact vectors plus hostile authoring. No world/RNG/reward setup.

const MANIFEST: String = "res://content/prototype_catalog.tres"
var assertions: int = 0
var failures: PackedStringArray = []
var catalog: ContentCatalog = ContentCatalog.new()
var records: Array

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	_check(catalog.initialize(load(MANIFEST)).is_empty(), "catalog")
	records = JSON.parse_string(FileAccess.get_file_as_string("res://content/maps/alderwake_layout.json")).activity_areas
	var vectors: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/behavior_vectors.json"))
	for row: Dictionary in vectors.membership:
		for area: FishingAreaDefinition in catalog.fishing_areas():
			if area.stable_id == row.area: _check(area.contains(Vector2(row.point[0],row.point[1])) == row.inside, "closed membership " + row.label)
	for row: Dictionary in vectors.distributions:
		var result: FishingActivityResolver.Result = FishingActivityResolver.distribution(catalog,Vector2(row.point[0],row.point[1]))
		_check(result.probabilities.keys() == row.probabilities.keys(), "sorted source IDs " + row.label)
		for id: String in row.probabilities: _check(absf(result.probabilities[id]-row.probabilities[id]) <= 1e-14, "weighted probability " + row.label + "/" + id)
		_check(absf(result.miss_probability-row.miss) <= 1e-14, "preserved miss " + row.label)
		_check(result.status == ("no_area" if row.probabilities.is_empty() else "eligible"), "distinct no-area " + row.label)
	for row: Dictionary in vectors.rolls:
		var result: FishingActivityResolver.Result = FishingActivityResolver.resolve(catalog,Vector2(row.point[0],row.point[1]),row.roll)
		var actual: String = result.source_item_id if result.status == "fish" else result.status
		_check(actual == row.expected, "exact interval " + row.label + ": " + actual)
		_check(result.item_id == ("item-" + actual.replace("_","-") if result.status == "fish" else ""), "stable reward identity only")
	for roll: Variant in [-1,1,1.00001,NAN,INF,true,"0",null,{},[]]:
		_check(FishingActivityResolver.resolve(catalog,Vector2(6.25,22.25),roll).status == "invalid", "invalid RNG " + str(roll))
		_check(FishingActivityResolver.resolve(catalog,Vector2(-12.75,20.25),roll).status == "invalid", "invalid RNG also rejects at no-area")
	for point: Vector2 in [Vector2(INF,0),Vector2(0,NAN)]: _check(FishingActivityResolver.distribution(catalog,point).status == "invalid", "invalid point")
	_check(FishingActivityResolver.distribution(null,Vector2.ZERO).status == "invalid", "null catalog")
	_check(FishingActivityResolver.distribution(ContentCatalog.new(),Vector2.ZERO).status == "invalid", "uninitialized catalog")
	_check(FishingActivityResolver.distribution(catalog,Vector2.ZERO,"absent").status == "invalid", "unknown location")
	_check(FishingActivityResolver.resolve(catalog,Vector2(6.25,22.25),0,"prototype-tollworks").status == "no_area", "indoor location has no area")
	_hostile()
	_pure()
	_check(TestRunEvidence.write_json("fishing-activity.json", {"task":"FS002", "proof":"synthetic exact frozen intervals/boundaries/strict authoring/pure query", "assertions":assertions+1, "failures":failures}), "write report")
	for failure: String in failures: push_error(failure)
	print("FS002 fishing activity ", "PASS" if failures.is_empty() else "FAILED", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _manifest(areas: Array[FishingAreaDefinition]) -> ContentManifest:
	var result: ContentManifest = ContentManifest.new()
	for definition: ContentDefinition in (load(MANIFEST) as ContentManifest).definitions: result.definitions.append(definition.duplicate(true))
	for area: FishingAreaDefinition in areas: result.definitions.append(area.duplicate(true))
	return result

func _hostile() -> void:
	var mutations: Array[Callable] = [
		func(r: Array) -> void: r[0].id = " ",
		func(r: Array) -> void: r[0].label = "",
		func(r: Array) -> void: r.append(r[0].duplicate(true)),
		func(r: Array) -> void: r[0].shape.kind = "circle",
		func(r: Array) -> void: r[0].shape.rect_xz_m[2] = 0,
		func(r: Array) -> void: r[0].shape.rect_xz_m[3] = -1,
		func(r: Array) -> void: r[0].shape.rect_xz_m[0] = INF,
		func(r: Array) -> void: r[0].shape.rect_xz_m[0] = true,
		func(r: Array) -> void: r[1].shape.vertices_xz_m = [[0,0],[1,1],[2,2]],
		func(r: Array) -> void: r[1].shape.vertices_xz_m = [[0,0],[2,2],[0,2],[2,0]],
		func(r: Array) -> void: r[1].shape.vertices_xz_m = [[0,0],[1,0]],
		func(r: Array) -> void: r[1].shape.vertices_xz_m[0] = ["0",0],
		func(r: Array) -> void: r[1].shape.vertices_xz_m[0] = [NAN,0],
		func(r: Array) -> void: r[0].source_profiles[0].blendWeight = 0,
		func(r: Array) -> void: r[0].source_profiles[0].blendWeight = -1,
		func(r: Array) -> void: r[0].source_profiles[0].blendWeight = INF,
		func(r: Array) -> void: r[0].source_profiles[0].blendWeight = true,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = NAN,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = INF,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = -0.1,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = 1.01,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = true,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].probability = 0.95,
		func(r: Array) -> void: r[0].source_profiles[0].outcomes.append(r[0].source_profiles[0].outcomes[0].duplicate(true)),
		func(r: Array) -> void: r[0].source_profiles[0].outcomes[0].itemId = " ",
		func(r: Array) -> void: r[0].source_profiles[0].activityId = "foraging",
		func(r: Array) -> void: r[0].source_profiles.append(r[0].source_profiles[0].duplicate(true)),
		func(r: Array) -> void: r[0].runtime_enabled = true,
		func(r: Array) -> void: r[0].extra = 1
	]
	for index: int in mutations.size():
		var changed: Array = records.duplicate(true)
		mutations[index].call(changed)
		var adapted: FishingAreaAdapter.Result = FishingAreaAdapter.from_records(changed)
		_check(not adapted.errors.is_empty() and adapted.areas.is_empty(), "malformed area publishes nothing " + str(index))
	for value: Variant in [null,{},[],true]: _check(not FishingAreaAdapter.from_records(value).errors.is_empty(), "invalid records container")
	for source_id: String in ["absent", "fishing_rod", "moonflower"]:
		var changed: Array = records.duplicate(true)
		changed[0].source_profiles[0].outcomes[0].itemId = source_id
		var adapted: FishingAreaAdapter.Result = FishingAreaAdapter.from_records(changed)
		_check(adapted.errors.is_empty(), "structural adapter leaves identity validation to existing catalog")
		var rejected: ContentCatalog = ContentCatalog.new()
		_check(not rejected.initialize(_manifest(adapted.areas)).is_empty() and rejected.definition_count() == 0 and not rejected.initialized, "unknown/nonfish reference fails catalog before publication")
	var areas: Array[FishingAreaDefinition] = FishingAreaAdapter.from_records(records).areas
	for mutation: String in ["duplicate", "unknown-location", "overflow", "unknown-definition"]:
		var fixture: ContentManifest = _manifest(areas)
		match mutation:
			"duplicate": fixture.definitions.append(areas[0].duplicate(true))
			"unknown-location": (fixture.definitions[-1] as FishingAreaDefinition).location_id = "absent"
			"overflow":
				for definition: ContentDefinition in fixture.definitions:
					if definition is FishingAreaDefinition: (definition as FishingAreaDefinition).blend_weight = 1e308
			"unknown-definition": fixture.definitions.append(ContentDefinition.new())
		var rejected: ContentCatalog = ContentCatalog.new()
		_check(not rejected.initialize(fixture).is_empty() and rejected.definition_count() == 0, "catalog rejects " + mutation)
		var before: Array[FishingAreaDefinition] = catalog.fishing_areas()
		_check(not catalog.initialize(fixture).is_empty() and catalog.fishing_areas() == before and catalog.definition_count() == 27, "rejected area replacement preserves published catalog")
	# A legitimate matching profile with zero mass is still miss, never no-area.
	var zero: ContentManifest = _manifest(areas)
	for definition: ContentDefinition in zero.definitions:
		if definition is FishingAreaDefinition:
			var area: FishingAreaDefinition = definition
			for index: int in area.probabilities.size(): area.probabilities[index] = 0.0
	var zero_catalog: ContentCatalog = ContentCatalog.new()
	_check(zero_catalog.initialize(zero).is_empty() and FishingActivityResolver.resolve(zero_catalog,Vector2(6.25,22.25),0).status == "miss", "zero mass preserves match/miss distinction")

func _pure() -> void:
	var run: GameSession = ForagingSaveFixture.make(catalog)
	var before: Dictionary = SaveCodec.snapshot(run)
	var revision: int = run.inventory.revision()
	for roll: float in [0.0,0.12,0.3,0.99]: FishingActivityResolver.resolve(catalog,Vector2(6.25,22.25),roll)
	_check(SaveCodec.snapshot(run) == before and run.inventory.revision() == revision, "resolver grants no reward and changes no session facts")
	var detached: FishingActivityResolver.Result = FishingActivityResolver.distribution(catalog,Vector2(6.25,22.25))
	detached.probabilities.clear()
	detached.area_ids.clear()
	_check(FishingActivityResolver.distribution(catalog,Vector2(6.25,22.25)).probabilities.size() == 3, "query observations detached")
	var reversed: Array[FishingAreaDefinition] = FishingAreaAdapter.from_records(records).areas
	reversed.reverse()
	for area: FishingAreaDefinition in reversed:
		area.outcome_source_ids.reverse()
		area.probabilities.reverse()
	var other: ContentCatalog = ContentCatalog.new()
	_check(other.initialize(_manifest(reversed)).is_empty(), "reordered authoring validates")
	var first: FishingActivityResolver.Result = FishingActivityResolver.distribution(catalog,Vector2(5,25))
	var second: FishingActivityResolver.Result = FishingActivityResolver.distribution(other,Vector2(5,25))
	_check(first.area_ids.size() == 3 and first.area_ids == second.area_ids and first.probabilities == second.probabilities, "three-way boundary blend independent of authoring order")

func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
