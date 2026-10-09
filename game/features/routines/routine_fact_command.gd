class_name RoutineFactCommand
extends RefCounted
## Internal typed command. R011 must separately authorize speaker/routine context.
## No public UI/debug event activation or routine execution is enabled here.
enum Kind { SET_EVENT, SUPPRESS_FOR_DAY }
var _owner: WeakRef
var _data: Dictionary = {}

static func set_event(session: GameSession, id: String, enabled: bool) -> RoutineFactCommand:
	return _make(session, Kind.SET_EVENT, id, enabled)

static func suppress_for_day(session: GameSession, id: String) -> RoutineFactCommand:
	return _make(session, Kind.SUPPRESS_FOR_DAY, id, true)

static func _make(session: GameSession, kind: Kind, id: String, enabled: bool) -> RoutineFactCommand:
	var command: RoutineFactCommand = RoutineFactCommand.new()
	if session == null or not session.initialized: return command
	command._owner = weakref(session)
	command._data = {"kind": kind, "id": id, "enabled": enabled,
		"day": session.environment.day_index, "revision": session.routine_revision,
		"expected": session.routines.event_active(id) if kind == Kind.SET_EVENT else session.routines.suppressed(id)}
	command._data.make_read_only()
	return command

func validation_errors(session: GameSession) -> PackedStringArray:
	if session == null or _owner == null or _owner.get_ref() != session or _data.is_empty():
		return PackedStringArray(["routine command has no matching live session"])
	if _data.day != session.environment.day_index or _data.revision != session.routine_revision:
		return PackedStringArray(["routine command is stale"])
	var id: String = _data.id
	match int(_data.kind):
		Kind.SET_EVENT:
			if id not in RoutineFacts.EVENT_IDS: return PackedStringArray(["unknown authored routine event"])
			if _data.expected != session.routines.event_active(id) or _data.enabled == _data.expected:
				return PackedStringArray(["routine event command is stale or unchanged"])
		Kind.SUPPRESS_FOR_DAY:
			if id not in RoutineContentCatalog.IDS: return PackedStringArray(["unknown suppressed routine"])
			if _data.expected or session.routines.suppressed(id): return PackedStringArray(["routine already suppressed"])
		_: return PackedStringArray(["unknown routine command kind"])
	return []

func candidate(current: RoutineFacts) -> RoutineFacts:
	if int(_data.kind) == Kind.SET_EVENT: return current.with_event(_data.id, _data.enabled)
	return current.with_suppression(_data.id)
