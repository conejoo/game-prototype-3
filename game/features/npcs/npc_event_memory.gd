class_name NpcEventMemory
extends RefCounted
## Exact keys, fixed allowlist and bounded aggregates; no inventory-derived history.
const MAX_SEQUENCE: int = 2147483647
const MAX_ACTIVE_SECONDS: float = 2190600.0 # 3651 days * existing 600-second day
const AREA: String = "areaEntered"
const GATHER: String = "resourceGathered"
const CHOICE: String = "dialogueChoiceSelected"
var _allowed: Dictionary[String, bool] = {}
var _facts: Dictionary[String, Dictionary] = {}
var _last_sequence: int = 0
var _last_active_seconds: float = 0.0

func initialize(catalog: NpcContentCatalog) -> void:
	_allowed.clear()
	_facts.clear()
	_last_sequence = 0
	_last_active_seconds = 0.0
	_allowed[key(AREA, "woods", null)] = true
	_allowed[key(GATHER, "moonflower", null)] = true
	for id: String in catalog.npc_ids():
		for choice: NpcDialogueGraph.Choice in catalog.get_npc(id).graph.choices.values():
			if choice.availability.is_enabled(): _allowed[key(CHOICE, id, choice.id)] = true

static func key(kind: String, subject: Variant, target: Variant) -> String:
	return JSON.stringify([kind, subject, target])

func record(kind: String, subject: Variant, target: Variant, seconds: float) -> NpcEventMemory:
	var encoded: String = key(kind, subject, target)
	if not _allowed.has(encoded) or not valid_time(seconds) or seconds < _last_active_seconds or _last_sequence >= MAX_SEQUENCE:
		return null
	var result: NpcEventMemory = detached_copy()
	result._last_sequence += 1
	result._last_active_seconds = seconds
	var previous: Dictionary = _facts.get(encoded, {})
	result._facts[encoded] = {"kind": kind, "subject_id": subject, "target_id": target, "count": int(previous.get("count", 0)) + 1, "first_sequence": int(previous.get("first_sequence", result._last_sequence)), "last_sequence": result._last_sequence, "first_active_seconds": float(previous.get("first_active_seconds", seconds)), "last_active_seconds": seconds}
	return result

static func valid_time(seconds: float) -> bool:
	return is_finite(seconds) and seconds >= 0.0 and seconds <= MAX_ACTIVE_SECONDS

func count(kind: String, subject: Variant, target: Variant) -> int:
	return int(_facts.get(key(kind, subject, target), {}).get("count", 0))

func matches(condition: NpcDialogueGraph.EventCondition, seconds: float) -> bool:
	if not valid_time(seconds): return false
	var kind: String = NpcContentCatalog.EVENT_KINDS[condition.kind]
	var fact: Dictionary = _facts.get(key(kind, condition.subject_id, condition.target_id), {})
	var observed: int = int(fact.get("count", 0))
	if observed < condition.minimum_count or (condition.maximum_count >= 0 and observed > condition.maximum_count): return false
	if condition.occurred_within_active_seconds < 0.0: return true
	# Source latest-event window is inclusive; null never means wildcard.
	return not fact.is_empty() and seconds - float(fact["last_active_seconds"]) <= condition.occurred_within_active_seconds

func detached_copy() -> NpcEventMemory:
	var result: NpcEventMemory = NpcEventMemory.new()
	result._allowed = _allowed.duplicate()
	result._facts = _facts.duplicate(true)
	result._last_sequence = _last_sequence
	result._last_active_seconds = _last_active_seconds
	return result

func snapshot() -> Dictionary:
	var rows: Array[Dictionary] = []
	var keys: Array[String] = []
	keys.assign(_facts.keys())
	keys.sort()
	for encoded: String in keys: rows.append(_facts[encoded].duplicate(true))
	return {"last_sequence": _last_sequence, "facts": rows}

func supported_key_count() -> int:
	return _allowed.size()
