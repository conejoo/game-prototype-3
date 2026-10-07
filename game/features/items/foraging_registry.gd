class_name ForagingRegistry
extends RefCounted
## F001 pinned identities/source feet, with user-approved safe runtime relocations.

const LOCATION: String = "prototype-alderwake"
const ROD_ORIGIN: String = "fishing-rod-dock-01"
const ROD_ITEM: String = "item-fishing-rod"
const ROD_RESOURCE: String = "resource-fishing-rod"
const DROP_ID: String = "dropped-fishing_rod"
const PLACEMENT_LOCATIONS: PackedStringArray = ["prototype-alderwake", "prototype-tollworks"]
# Approved 2026-10-07: rod centred on east dock, flower east of cliff.
# Preserve pinned source geography; saved placements override these defaults.
const RUNTIME_FEET: Dictionary = {
	ROD_ORIGIN: Vector3(-6.5, 0, 15.75),
	"moonflower-01": Vector3(26.75, 0.25, -2),
}
const ROWS: Array = [
	[ROD_ORIGIN, ROD_RESOURCE, ROD_ITEM, Vector3(-8, 0, 15.75)],
	["moonflower-01", "resource-moonflower", "item-moonflower", Vector3(26, 0.25, -2)],
	["moonflower-02", "resource-moonflower", "item-moonflower", Vector3(34, 0.25, 7)],
	["moonflower-03", "resource-moonflower", "item-moonflower", Vector3(30, 0.5, -9)],
]


static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Array in ROWS:
		result.append({"instance_id": row[0], "resource_id": row[1], "item_id": row[2], "location_id": LOCATION, "authored_foot": row[3], "foot": RUNTIME_FEET.get(row[0], row[3])})
	return result


static func find(instance_id: String) -> Dictionary:
	for entry: Dictionary in entries():
		if entry.instance_id == instance_id:
			return entry
	return {}


static func validation_errors(catalog: ContentCatalog) -> PackedStringArray:
	for entry: Dictionary in entries():
		var resource: ForagingResourceDefinition = catalog.get_resource(entry.resource_id)
		if catalog.get_location(entry.location_id) == null or resource == null or resource.item_id != entry.item_id or catalog.get_item(entry.item_id) == null:
			return PackedStringArray(["foraging registry references absent/mismatched content"])
	for location: String in PLACEMENT_LOCATIONS:
		if catalog.get_location(location) == null:
			return PackedStringArray(["foraging placement location is missing"])
	return []
