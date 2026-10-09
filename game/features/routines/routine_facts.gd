class_name RoutineFacts
extends RefCounted
## Durable authored facts only. Suppression belongs to the saved environment day.
## Weather-derived conditions never enter this store; all public queries detach.
const EVENT_IDS: PackedStringArray = ["harbor-festival", "heavy-rain"]
var _events: PackedStringArray = []
var _suppressed: PackedStringArray = []

class Result extends RefCounted:
	var state: RoutineFacts
	var errors: PackedStringArray = []

func authored_events() -> PackedStringArray: return _events.duplicate()
func suppressed_ids() -> PackedStringArray: return _suppressed.duplicate()
func event_active(id: String) -> bool: return id in _events
func suppressed(id: String) -> bool: return id in _suppressed
func snapshot() -> Dictionary:
	return {"authored_event_ids": Array(_events), "suppressed_routine_ids": Array(_suppressed)}

static func restore(data: Variant) -> Result:
	var result: Result = Result.new()
	if not data is Dictionary or not SaveCodec._exact_fields(data, ["authored_event_ids", "suppressed_routine_ids"]):
		result.errors.append("routine_facts requires exactly authored_event_ids/suppressed_routine_ids")
		return result
	for field: String in ["authored_event_ids", "suppressed_routine_ids"]:
		var allowed: PackedStringArray = EVENT_IDS if field == "authored_event_ids" else RoutineContentCatalog.IDS
		var values: Variant = data[field]
		if not values is Array or values.size() > allowed.size():
			result.errors.append("routine_facts." + field + " requires bounded ID array")
			return result
		var seen: PackedStringArray = []
		for value: Variant in values:
			if not value is String or value not in allowed or value in seen:
				result.errors.append("routine_facts." + field + " has unknown/duplicate/non-string ID")
				return result
			seen.append(value)
	# Shared arrays are not independent facts, even when empty.
	if is_same(data.authored_event_ids, data.suppressed_routine_ids):
		result.errors.append("routine_facts arrays must be independent")
		return result
	var candidate: RoutineFacts = RoutineFacts.new()
	candidate._events = PackedStringArray(data.authored_event_ids)
	candidate._suppressed = PackedStringArray(data.suppressed_routine_ids)
	candidate._events.sort()
	candidate._suppressed.sort()
	result.state = candidate
	return result

func with_event(id: String, enabled: bool) -> RoutineFacts:
	var candidate: RoutineFacts = _copy()
	if enabled: candidate._events.append(id)
	else: candidate._events.erase(id)
	candidate._events.sort()
	return candidate

func with_suppression(id: String) -> RoutineFacts:
	var candidate: RoutineFacts = _copy()
	candidate._suppressed.append(id)
	candidate._suppressed.sort()
	return candidate

func without_suppression() -> RoutineFacts:
	var candidate: RoutineFacts = _copy()
	candidate._suppressed.clear()
	return candidate

func _copy() -> RoutineFacts:
	var candidate: RoutineFacts = RoutineFacts.new()
	candidate._events = _events.duplicate()
	candidate._suppressed = _suppressed.duplicate()
	return candidate
