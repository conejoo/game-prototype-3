class_name RoutineDefinition
extends RefCounted
## Typed detached read-only view. Canonical dictionaries never escape catalog.
## Snapshot methods intentionally return mutable copies for planners/fixtures.
enum StepKind { MOVE, WAIT, ACTION, SPEECH }
enum ConditionKind { EVENT_ACTIVE, EVENT_INACTIVE, LEARNED_FACT, FLAG_SET, FLAG_UNSET, PLAYER_EVENT }
enum DirectiveKind { RESUME, JUMP, END_FOR_DAY, ACTIVATE_EVENT, DEACTIVATE_EVENT }
const STEPS: PackedStringArray = ["move", "wait", "action", "speech"]
const CONDITIONS: PackedStringArray = ["worldEventActive", "worldEventInactive", "learnedFact", "relationshipFlagSet", "relationshipFlagUnset", "playerEvent"]
const DIRECTIVES: PackedStringArray = ["resume", "jumpToStep", "endRoutineForDay", "activateWorldEvent", "deactivateWorldEvent"]

class Step extends RefCounted:
	var _data: Dictionary
	var id: String:
		get: return _data["id"]
	var kind: StepKind:
		get: return STEPS.find(_data["kind"]) as StepKind
	var map_id: String:
		get: return _data.get("target", {}).get("mapId", "")
	var anchor_id: String:
		get: return _data.get("target", {}).get("anchorId", "")
	var duration_seconds: float:
		get: return float(_data.get("durationSeconds", 0.0))
	var action_id: String:
		get: return _data.get("actionId", "")
	var text: String:
		get: return _data.get("text", "")
	func _init(data: Dictionary) -> void:
		_data = data.duplicate(true)
		RoutineDefinition.freeze(_data)
	func snapshot() -> Dictionary: return _data.duplicate(true)

class Condition extends RefCounted:
	var _data: Dictionary
	var kind: ConditionKind:
		get: return CONDITIONS.find(_data["kind"]) as ConditionKind
	var npc_id: String:
		get: return _data.get("npcId", "")
	var event_id: String:
		get: return _data.get("eventId", "")
	var fact_id: String:
		get: return _data.get("factId", "")
	var flag_id: String:
		get: return _data.get("flagId", "")
	var event_kind: String:
		get: return _data.get("eventKind", "")
	var subject_id: Variant:
		get: return _data.get("subjectId")
	var target_id: Variant:
		get: return _data.get("targetId")
	var minimum_count: int:
		get: return int(_data.get("minimumCount", 0))
	var maximum_count: int:
		get: return -1 if _data.get("maximumCount") == null else int(_data["maximumCount"])
	var recency_seconds: float:
		get: return -1.0 if _data.get("occurredWithinActiveSeconds") == null else float(_data["occurredWithinActiveSeconds"])
	func _init(data: Dictionary) -> void:
		_data = data.duplicate(true)
		RoutineDefinition.freeze(_data)
	func snapshot() -> Dictionary: return _data.duplicate(true)

class Directive extends RefCounted:
	var _data: Dictionary
	var kind: DirectiveKind:
		get: return DIRECTIVES.find(_data["kind"]) as DirectiveKind
	var participant_id: String:
		get: return _data.get("participantId", "")
	var step_id: String:
		get: return _data.get("stepId", "")
	var event_id: String:
		get: return _data.get("eventId", "")
	func _init(data: Dictionary) -> void:
		_data = data.duplicate(true)
		RoutineDefinition.freeze(_data)
	func snapshot() -> Dictionary: return _data.duplicate(true)

var _data: Dictionary
var id: String:
	get: return _data["id"]
var priority: int:
	get: return int(_data["priority"])
var start_minute: int:
	get: return minute(_data["timeWindow"]["start"])
var end_minute: int:
	get: return minute(_data["timeWindow"]["end"])
var overnight: bool:
	get: return start_minute > end_minute
var participants: PackedStringArray:
	get: return PackedStringArray(_data["participants"])
var allow_dialogue: bool:
	get: return _data["interactionPolicy"]["allowDialogue"]
var default_dialogue_entry: String:
	get: return _data["interactionPolicy"]["defaultDialogueEntryNodeId"] if _data["interactionPolicy"]["defaultDialogueEntryNodeId"] != null else ""

func _init(data: Dictionary) -> void:
	_data = data.duplicate(true)
	freeze(_data)

func steps(participant_id: String) -> Array[Step]:
	var result: Array[Step] = []
	for plan: Dictionary in _data["participantSteps"]:
		if plan["participantId"] == participant_id:
			for step: Dictionary in plan["steps"]: result.append(Step.new(step))
	return result

func conditions() -> Array[Condition]:
	var result: Array[Condition] = []
	for condition: Dictionary in _data["conditions"]: result.append(Condition.new(condition))
	return result

func step_dialogue_entry(participant_id: String, step_id: String) -> String:
	for entry: Dictionary in _data["interactionPolicy"]["stepDialogueEntries"]:
		if entry["participantId"] == participant_id and entry["stepId"] == step_id: return entry["dialogueEntryNodeId"]
	return ""

func directive(outcome_tag: String) -> Directive:
	for binding: Dictionary in _data["interactionPolicy"]["outcomeDirectives"]:
		if binding["outcomeTag"] == outcome_tag: return Directive.new(binding["directive"])
	return null

func snapshot() -> Dictionary: return _data.duplicate(true)

static func minute(time: String) -> int:
	return time.substr(0, 2).to_int() * 60 + time.substr(3, 2).to_int()

static func freeze(value: Variant) -> void:
	if value is Dictionary:
		for child: Variant in value.values(): freeze(child)
		value.make_read_only()
	elif value is Array:
		for child: Variant in value: freeze(child)
		value.make_read_only()
