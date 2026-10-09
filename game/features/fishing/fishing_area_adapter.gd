class_name FishingAreaAdapter
extends RefCounted
## Strict target-local decode. Never consult source checkout or development references.

class Result:
	extends RefCounted
	var areas: Array[FishingAreaDefinition] = []
	var errors: PackedStringArray = []

static func read_layout(path: String) -> Result:
	var result: Result = Result.new()
	if not path.begins_with("res://content/maps/") or not path.ends_with(".json") or ".." in path or not FileAccess.file_exists(path):
		result.errors.append("invalid fishing layout path")
		return result
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		result.errors.append("invalid fishing layout JSON")
		return result
	return from_records(parser.data.get("activity_areas"))

static func from_records(records: Variant) -> Result:
	var result: Result = Result.new()
	if not records is Array or records.is_empty():
		result.errors.append("fishing areas must be a nonempty array")
		return result
	var candidate: Array[FishingAreaDefinition] = []
	var seen: PackedStringArray = []
	for record: Variant in records:
		var area: FishingAreaDefinition = _decode(record)
		if area == null:
			result.errors.append("malformed fishing area record")
			continue
		result.errors.append_array(area.validation_errors())
		if area.stable_id in seen: result.errors.append("duplicate fishing area ID")
		seen.append(area.stable_id)
		candidate.append(area)
	if result.errors.is_empty(): result.areas = candidate
	return result

static func _decode(record: Variant) -> FishingAreaDefinition:
	if not record is Dictionary or not _fields(record, ["id", "label", "shape", "source_profiles", "runtime_enabled"]): return null
	if not record.id is String or not record.label is String or typeof(record.runtime_enabled) != TYPE_BOOL or record.runtime_enabled: return null
	if not record.shape is Dictionary or not record.source_profiles is Array or record.source_profiles.size() != 1: return null
	var profile: Variant = record.source_profiles[0]
	if not profile is Dictionary or not _fields(profile, ["activityId", "blendWeight", "outcomes"]) or profile.activityId != "fishing" or not _number(profile.blendWeight) or not profile.outcomes is Array: return null
	var area: FishingAreaDefinition = FishingAreaDefinition.new()
	area.stable_id = record.id
	area.display_name = record.label
	area.blend_weight = float(profile.blendWeight)
	var shape: Dictionary = record.shape
	if shape.get("kind") == "rectangle":
		if not _fields(shape, ["kind", "rect_xz_m"]) or not _numbers(shape.rect_xz_m, 4): return null
		area.rectangle = Rect2(float(shape.rect_xz_m[0]), float(shape.rect_xz_m[1]), float(shape.rect_xz_m[2]), float(shape.rect_xz_m[3]))
	elif shape.get("kind") == "polygon":
		if not _fields(shape, ["kind", "vertices_xz_m"]) or not shape.vertices_xz_m is Array: return null
		area.shape_kind = "polygon"
		for vertex: Variant in shape.vertices_xz_m:
			if not _numbers(vertex, 2): return null
			area.polygon.append(Vector2(float(vertex[0]), float(vertex[1])))
	else: return null
	for outcome: Variant in profile.outcomes:
		if not outcome is Dictionary or not _fields(outcome, ["itemId", "probability"]) or not outcome.itemId is String or not _number(outcome.probability): return null
		area.outcome_source_ids.append(outcome.itemId)
		area.probabilities.append(float(outcome.probability))
	return area

static func _number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))

static func _numbers(value: Variant, size: int) -> bool:
	if not value is Array or value.size() != size: return false
	for number: Variant in value:
		if not _number(number): return false
	return true

static func _fields(value: Dictionary, fields: Array[String]) -> bool:
	if value.size() != fields.size(): return false
	for field: String in fields:
		if not value.has(field): return false
	return true
