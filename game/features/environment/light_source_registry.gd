class_name LightSourceRegistry
extends RefCounted
## Pinned W001 identities/defaults. No dependency on scene nodes or source checkout.

const LOCATION_ID: String = "prototype-alderwake"
# prop instance, source, effective instance-before-definition default, switchable
const SOURCE_ROWS: Array = [
	["alder-rise-home-01-building", "windows", true, false],
	["alder-rise-home-03-building", "windows", true, false],
	["dock-lamp-01", "lantern", false, true],
	["dock-lamp-02", "lantern", false, true],
	["dock-lamp-03", "lantern", false, true],
	["dock-lamp-04", "lantern", false, true],
	["dock-lamp-05", "lantern", false, true],
	["dock-luminous-nets-01", "woven-lights", true, false],
	["dock-row-home-01-building", "windows", true, false],
	["dock-row-home-02-building", "windows", false, false],
	["dock-row-home-03-building", "windows", true, false],
	["dock-row-home-04-building", "windows", false, false],
	["dock-row-lamp-01", "lantern", true, true],
	["lantern-rest-exterior-building", "windows", true, false],
	["mayor-vale-home-building", "windows", true, false],
	["mill-road-home-01-building", "windows", false, false],
	["mill-road-home-02-building", "windows", true, false],
	["moonwood-edge-home-01-building", "windows", true, false],
	["moonwood-edge-home-02-building", "windows", false, false],
	["reed-chandlery-exterior-building", "windows", true, false],
	["safeguard-waylight-east-01", "answer-light", true, false],
	["safeguard-waylight-west-01", "answer-light", true, false],
	["tess-general-goods-exterior-building", "windows", true, false],
]


static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Array in SOURCE_ROWS:
		result.append({"location_id": LOCATION_ID, "prop_id": row[0], "source_id": row[1], "default_enabled": row[2], "switchable": row[3]})
	return result


static func find(location_id: String, prop_id: String, source_id: String) -> Dictionary:
	if location_id == LOCATION_ID:
		for row: Array in SOURCE_ROWS:
			if row[0] == prop_id and row[1] == source_id:
				return {"location_id": LOCATION_ID, "prop_id": prop_id, "source_id": source_id, "default_enabled": row[2], "switchable": row[3]}
	return {}


static func validate_overrides(records: Variant) -> PackedStringArray:
	if not records is Array:
		return PackedStringArray(["light_source_overrides must be an array"])
	var seen: Array[Array] = []
	for record: Variant in records:
		if not record is Dictionary or record.size() != 4:
			return PackedStringArray(["light override requires exactly location_id, prop_id, source_id, enabled"])
		for field: String in ["location_id", "prop_id", "source_id"]:
			if not record.get(field) is String:
				return PackedStringArray(["light override %s must be a string" % field])
		if not record.get("enabled") is bool:
			return PackedStringArray(["light override enabled must be a boolean"])
		var source: Dictionary = find(record.location_id, record.prop_id, record.source_id)
		if source.is_empty() or not source.switchable:
			return PackedStringArray(["light override must name a known switchable source: %s/%s/%s" % [record.location_id, record.prop_id, record.source_id]])
		var identity: Array = [record.location_id, record.prop_id, record.source_id]
		if identity in seen:
			return PackedStringArray(["duplicate light override: " + str(identity)])
		seen.append(identity)
	return PackedStringArray()


static func sorted_overrides(records: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = records.duplicate(true)
	# Preserve malformed input for codec rejection instead of indexing bad fields.
	if not validate_overrides(result).is_empty():
		return result
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		for field: String in ["location_id", "prop_id", "source_id"]:
			if a[field] != b[field]:
				return a[field] < b[field]
		return false)
	return result
