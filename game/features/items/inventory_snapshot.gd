class_name InventorySnapshot
extends RefCounted
## Detached observation. Editing this object cannot change a session or authored data.

var item_counts: Dictionary[String, int] = {}
var active_item_id: Variant = null


func _init(counts: Dictionary[String, int] = {}, active_id: Variant = null) -> void:
	var ids: Array[String] = counts.keys()
	ids.sort()
	for id: String in ids:
		item_counts[id] = counts[id]
	active_item_id = active_id


func to_dictionary() -> Dictionary:
	return {"item_counts": item_counts.duplicate(), "active_item_id": active_item_id}
