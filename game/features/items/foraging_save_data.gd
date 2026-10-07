class_name ForagingSaveData
extends RefCounted
## Strict plain facts; geometry is separately proved against staged rooms before swap.

static func validate(inventory: Variant, collected: Variant, placements: Variant, catalog: ContentCatalog) -> PackedStringArray:
	if not inventory is Dictionary or not SaveCodec._exact_fields(inventory, ["item_counts", "active_item_id"]):
		return PackedStringArray(["invalid inventory fields"])
	if not inventory.item_counts is Dictionary or inventory.item_counts.size() > InventoryState.MAX_TYPES:
		return PackedStringArray(["invalid inventory counts"])
	for id: Variant in inventory.item_counts:
		if not id is String:
			return PackedStringArray(["invalid item ID"])
		var item: ItemDefinition = catalog.get_item(id)
		if item == null or not SaveCodec._integer(inventory.item_counts[id], 1, item.stack_limit):
			return PackedStringArray(["unknown item or invalid quantity"])
	var active: Variant = inventory.active_item_id
	if active != null and (not active is String or not inventory.item_counts.has(active)):
		return PackedStringArray(["active item must be owned or null"])
	if not collected is Array and not collected is PackedStringArray:
		return PackedStringArray(["collected IDs must be an array"])
	var seen: PackedStringArray = []
	for id: Variant in collected:
		if not id is String or id in seen or ForagingRegistry.find(id).is_empty():
			return PackedStringArray(["unknown or duplicate collected origin"])
		seen.append(id)
	if not placements is Array or placements.size() > 1:
		return PackedStringArray(["placements must contain at most one rod"])
	var rod: int = int(inventory.item_counts.get(ForagingRegistry.ROD_ITEM, 0))
	if not ForagingRegistry.ROD_ORIGIN in seen:
		rod += 1
	for record: Variant in placements:
		if not record is Dictionary or not SaveCodec._exact_fields(record, ["instance_id", "item_id", "location_id", "foot_xyz_m", "provenance", "origin_instance_id"]):
			return PackedStringArray(["invalid placement fields"])
		for key: String in ["instance_id", "item_id", "location_id", "provenance", "origin_instance_id"]:
			if not record[key] is String:
				return PackedStringArray(["placement identity must be strings"])
		if not record.foot_xyz_m is Array or record.foot_xyz_m.size() != 3:
			return PackedStringArray(["foot must contain three metre numbers"])
		for value: Variant in record.foot_xyz_m:
			if not (value is int or value is float) or not is_finite(float(value)) or absf(float(value)) > 10000.0:
				return PackedStringArray(["invalid foot number"])
		var placement: WorldItemPlacement = from_record(record)
		var errors: PackedStringArray = placement.validation_errors()
		if not errors.is_empty(): return errors
		if placement.provenance == WorldItemPlacement.AUTHORED:
			if ForagingRegistry.ROD_ORIGIN in seen:
				return PackedStringArray(["collected origin has authored override"])
		else:
			if not ForagingRegistry.ROD_ORIGIN in seen:
				return PackedStringArray(["generated drop requires suppressed origin"])
			rod += 1
	if rod != 1:
		return PackedStringArray(["rod ownership must total exactly one"])
	return []

static func from_record(record: Dictionary) -> WorldItemPlacement:
	var foot: Array = record.foot_xyz_m
	var result: WorldItemPlacement = WorldItemPlacement.new(record.instance_id, record.location_id, Vector3(foot[0], foot[1], foot[2]), record.provenance)
	result.item_id = record.item_id
	result.origin_instance_id = record.origin_instance_id
	return result

static func restore(candidate: GameSession, inventory: Dictionary, collected: Variant, placements: Array, catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = validate(inventory, collected, placements, catalog)
	if not errors.is_empty(): return errors
	return candidate.foraging.restore_facts(inventory, PackedStringArray(collected), placements)
