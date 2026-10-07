class_name InventoryState
extends RefCounted
## Pure session-owned rules. No scene, signal, reward, UI or save ownership.
## Commands accept integer Variants deliberately: typed int arguments coerce fractions.

const MAX_TYPES: int = 20

var initialized: bool = false
var _catalog: ContentCatalog
var _item_counts: Dictionary[String, int] = {}
var _active_item_id: String = ""


func initialize(catalog: ContentCatalog) -> PackedStringArray:
	if initialized:
		return PackedStringArray(["inventory is already initialized"])
	if catalog == null or not catalog.initialized:
		return PackedStringArray(["inventory requires an initialized content catalog"])
	_catalog = catalog
	initialized = true
	return []


func snapshot() -> InventorySnapshot:
	return InventorySnapshot.new(_item_counts, null if _active_item_id.is_empty() else _active_item_id)


func count(item_id: String) -> int:
	return _item_counts.get(item_id, 0)


func active_tool() -> ItemDefinition:
	if not initialized or _active_item_id.is_empty():
		return null
	var definition: ItemDefinition = _catalog.get_item(_active_item_id)
	return definition if definition != null and definition.is_tool() else null


func can_add(item_id: String, quantity: Variant = 1) -> PackedStringArray:
	var errors: PackedStringArray = _validate_command(item_id, quantity)
	if not errors.is_empty():
		return errors
	var definition: ItemDefinition = _catalog.get_item(item_id)
	# Subtraction before addition prevents integer overflow for hostile quantities.
	if quantity > definition.stack_limit - count(item_id):
		return PackedStringArray(["stack_full"])
	if not _item_counts.has(item_id) and _item_counts.size() >= MAX_TYPES:
		return PackedStringArray(["backpack_full"])
	return []


func add(item_id: String, quantity: Variant = 1) -> PackedStringArray:
	var errors: PackedStringArray = can_add(item_id, quantity)
	if errors.is_empty():
		_item_counts[item_id] = count(item_id) + int(quantity)
	return errors


func consume(item_id: String, quantity: Variant = 1) -> PackedStringArray:
	var errors: PackedStringArray = _validate_command(item_id, quantity)
	if not errors.is_empty():
		return errors
	if quantity > count(item_id):
		return PackedStringArray(["insufficient_items"])
	var remaining: int = count(item_id) - int(quantity)
	if remaining == 0:
		_item_counts.erase(item_id)
		if _active_item_id == item_id:
			_active_item_id = ""
	else:
		_item_counts[item_id] = remaining
	return []


func select(item_id: Variant) -> PackedStringArray:
	if not initialized:
		return PackedStringArray(["inventory is not initialized"])
	if item_id == null:
		_active_item_id = ""
		return []
	if not item_id is String or _catalog.get_item(item_id) == null:
		return PackedStringArray(["unknown_item"])
	if count(item_id) == 0:
		return PackedStringArray(["missing_owned_item"])
	_active_item_id = item_id
	return []


func _validate_command(item_id: String, quantity: Variant) -> PackedStringArray:
	if not initialized:
		return PackedStringArray(["inventory is not initialized"])
	if _catalog.get_item(item_id) == null:
		return PackedStringArray(["unknown_item"])
	if typeof(quantity) != TYPE_INT or quantity <= 0:
		return PackedStringArray(["invalid_quantity"])
	return []
