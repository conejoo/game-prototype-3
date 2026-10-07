class_name ForagingCommandResult
extends RefCounted
## Detached structured outcome; failures publish no completion signal.

var accepted: bool = false
var errors: PackedStringArray = []
var revision: int = 0
var operation: String = ""
var instance_id: String = ""
var item_id: String = ""
var placement: WorldItemPlacement


func _init(kind: String, id: String, item: String, token: int, problems: PackedStringArray = [], placed: WorldItemPlacement = null) -> void:
	operation = kind
	instance_id = id
	item_id = item
	revision = token
	errors = problems.duplicate()
	accepted = errors.is_empty()
	placement = placed.detached() if placed != null else null
