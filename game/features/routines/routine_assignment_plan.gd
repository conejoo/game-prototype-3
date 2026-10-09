class_name RoutineAssignmentPlan
extends RefCounted
## Transient immutable assignments/diagnostics and sampled elapsed window times.
var _data: Dictionary
var day_index: int:
	get: return _data.day_index
var minute_of_day: float:
	get: return _data.minute
func _init(day: int, minute: float, assignments: Dictionary, elapsed: Dictionary, rejections: Dictionary) -> void:
	_data = {"day_index": day, "minute": minute, "assignments": assignments.duplicate(true), "elapsed": elapsed.duplicate(true), "rejections": rejections.duplicate(true)}
	RoutineDefinition.freeze(_data)
func routine_for(npc_id: String) -> String: return _data.assignments.get(npc_id, "")
func elapsed_for(npc_id: String) -> float: return float(_data.elapsed.get(npc_id, 0.0))
func assignments() -> Dictionary: return _data.assignments.duplicate(true)
func rejections() -> Dictionary: return _data.rejections.duplicate(true)
func routine_ids() -> PackedStringArray:
	var result: PackedStringArray = []
	for id: String in _data.assignments.values():
		if id not in result: result.append(id)
	result.sort()
	return result
func snapshot() -> Dictionary: return _data.duplicate(true)
