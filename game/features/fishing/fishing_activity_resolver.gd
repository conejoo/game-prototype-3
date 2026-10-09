class_name FishingActivityResolver
extends RefCounted
## Pure weighted activity query. No inventory, scene, RNG generation or reward authority.

class Result:
	extends RefCounted
	var status: String = "invalid"
	var errors: PackedStringArray = []
	var area_ids: PackedStringArray = []
	var probabilities: Dictionary[String, float] = {}
	var miss_probability: float = 1.0
	var source_item_id: String = ""
	var item_id: String = ""

static func distribution(catalog: ContentCatalog, point: Vector2, location_id: String = "prototype-alderwake") -> Result:
	var result: Result = Result.new()
	if catalog == null or not catalog.initialized or not point.is_finite() or catalog.get_location(location_id) == null:
		result.errors.append("invalid fishing query")
		return result
	var matches: Array[FishingAreaDefinition] = []
	var weight: float = 0.0
	var ids: PackedStringArray = []
	for area: FishingAreaDefinition in catalog.fishing_areas():
		if area.location_id != location_id or not area.contains(point): continue
		matches.append(area)
		result.area_ids.append(area.stable_id)
		weight += area.blend_weight
		for id: String in area.outcome_source_ids:
			if id not in ids: ids.append(id)
	if matches.is_empty():
		result.status = "no_area"
		return result
	ids.sort()
	var mass: float = 0.0
	for id: String in ids:
		var weighted: float = 0.0
		for area: FishingAreaDefinition in matches:
			var index: int = area.outcome_source_ids.find(id)
			if index >= 0: weighted += area.blend_weight * area.probabilities[index]
		var probability: float = weighted / weight
		result.probabilities[id] = probability
		mass += probability
	result.miss_probability = maxf(0.0, 1.0 - mass)
	result.status = "eligible"
	return result

static func resolve(catalog: ContentCatalog, point: Vector2, roll: Variant, location_id: String = "prototype-alderwake") -> Result:
	var result: Result = distribution(catalog, point, location_id)
	if not FishingAreaAdapter._number(roll) or float(roll) < 0.0 or float(roll) >= 1.0:
		result.status = "invalid"
		result.errors.append("encounter roll must be finite in [0,1)")
		return result
	if result.status != "eligible": return result
	var threshold: float = 0.0
	for id: String in result.probabilities:
		threshold += result.probabilities[id]
		if float(roll) < threshold:
			result.status = "fish"
			result.source_item_id = id
			result.item_id = catalog.get_item_by_source(id).stable_id
			return result
	result.status = "miss"
	return result
