class_name RoutineDialogueContext
extends RefCounted
## Unforgeable by identity: only director's currently registered lease is authority.
var _owner: WeakRef
var _data: Dictionary = {}
var _cursors: Dictionary = {}
var _targets: Dictionary = {}
var _closed: bool = false

func valid() -> bool:
	var owner: RoutineExecutionDirector = _owner.get_ref() if _owner != null else null
	return not _closed and owner != null and owner.valid_lease(self)

func entries() -> PackedStringArray:
	if not valid(): return []
	var cursor: RoutineExecutor = _cursors[_data.speaker]
	var step: RoutineDefinition.Step = cursor.current_step()
	return [cursor.routine.step_dialogue_entry(_data.speaker,step.id if step != null else ""),cursor.routine.default_dialogue_entry]

func stage(tag: String) -> Dictionary:
	if not valid(): return {"ok":false,"reason":"Stale routine dialogue context."}
	var cursor: RoutineExecutor = _cursors[_data.speaker]
	var directive: RoutineDefinition.Directive = cursor.routine.directive(tag)
	if directive == null or not tag.begins_with(_data.speaker+"-"): return {"ok":false,"reason":"Outcome has no bound speaker directive."}
	var result: Dictionary = {"ok":true,"reason":"","tag":tag,"directive":directive,"command":null,"jump_index":-1}
	var owner: RoutineExecutionDirector = _owner.get_ref()
	match directive.kind:
		RoutineDefinition.DirectiveKind.JUMP:
			var target: RoutineExecutor = _cursors.get(directive.participant_id)
			if target == null: return {"ok":false,"reason":"Jump participant is outside leased group."}
			for index: int in target.steps.size():
				if target.steps[index].id == directive.step_id: result.jump_index = index
			if result.jump_index < 0: return {"ok":false,"reason":"Jump step is outside participant plan."}
		RoutineDefinition.DirectiveKind.END_FOR_DAY:
			result.command = RoutineFactCommand.suppress_for_day(owner._session,cursor.routine.id)
		RoutineDefinition.DirectiveKind.ACTIVATE_EVENT, RoutineDefinition.DirectiveKind.DEACTIVATE_EVENT:
			result.command = RoutineFactCommand.set_event(owner._session,directive.event_id,directive.kind == RoutineDefinition.DirectiveKind.ACTIVATE_EVENT)
	if result.command != null:
		var errors: PackedStringArray = result.command.validation_errors(owner._session)
		if not errors.is_empty(): return {"ok":false,"reason":"; ".join(errors)}
	return result

func commit_transient(staged: Dictionary) -> void:
	# Called only after service/session validation, before any publication notification.
	var owner: RoutineExecutionDirector = _owner.get_ref()
	var directive: RoutineDefinition.Directive = staged.directive
	owner.directives.append({"kind":directive.kind,"speaker":_data.speaker,"instance":_data.instance,"routine":_data.routine,"step":_data.steps[_data.speaker],"leased":owner._lease == self,"participant":directive.participant_id,"target_step":directive.step_id})
	if owner.directives.size() > 64: owner.directives.pop_front()
	if directive.kind == RoutineDefinition.DirectiveKind.JUMP:
		var cursor: RoutineExecutor = _cursors[directive.participant_id]
		var location: PrototypeLocation = owner._live_location()
		if location != null: location.npc_contacts.cancel_move(cursor.npc_id)
		cursor.index = staged.jump_index; cursor.remaining = 0; cursor.phase = ""; cursor.arrival_wait = 0
		cursor.state = RoutineExecutor.State.READY
		owner._night_lane.clear()

func close() -> void:
	if _closed: return
	_closed = true
	var owner: RoutineExecutionDirector = _owner.get_ref() if _owner != null else null
	if owner != null: owner.release_lease(self)

func valid_staged(staged: Dictionary) -> bool:
	if not valid() or staged.size() != 6 or not staged.get("ok",false) or not staged.get("tag") is String or not staged.get("directive") is RoutineDefinition.Directive: return false
	var expected: Dictionary = stage(staged.tag)
	if not expected.ok or expected.directive.snapshot() != staged.directive.snapshot() or expected.jump_index != staged.get("jump_index"): return false
	if expected.command == null: return staged.get("command") == null
	return staged.get("command") is RoutineFactCommand and expected.command._data == staged.command._data and staged.command.validation_errors(_data.session).is_empty()
