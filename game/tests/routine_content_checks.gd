extends SceneTree
## R002 synthetic data validation only; no runtime schedules, movement or saves.
var failures: Array[String] = []
var assertions: int = 0
var rejections: Array[Dictionary] = []
var npcs: NpcContentCatalog = NpcContentCatalog.new()
var catalog: RoutineContentCatalog = RoutineContentCatalog.new()
var index: Dictionary
var documents: Dictionary = {}
const ARCHIVE: String = "helena-afternoon-archive"
const FILE: String = "res://content/routines/helena-afternoon-archive.json"

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var actors: ContentCatalog = ContentCatalog.new()
	_check(actors.initialize(load("res://content/prototype_catalog.tres") as ContentManifest).is_empty(), "actor prerequisites")
	_check(npcs.initialize_path(actors).is_empty(), "current NPC graphs/declarations")
	var npc_before: Dictionary = npcs.document_snapshot()
	var errors: PackedStringArray = catalog.initialize_path(npcs)
	_check(errors.is_empty(), "all 25 load: " + "; ".join(errors))
	if not catalog.initialized:
		_finish()
		return
	index = catalog.index_snapshot()
	for id: String in catalog.routine_ids(): documents[RoutineContentCatalog._asset(id)] = catalog.document_snapshot(id)
	_check(catalog.definition_count() == 25 and catalog.routine_ids() == RoutineContentCatalog.IDS, "exact selected IDs")
	_check(catalog.get_routine("npc-05-day") == null, "excluded routines absent")
	var roster: PackedStringArray = []
	var anchors: PackedStringArray = []
	var steps_count: int = 0
	var step_kinds: PackedStringArray = []
	var condition_kinds: PackedStringArray = []
	for id: String in catalog.routine_ids():
		var routine: RoutineDefinition = catalog.get_routine(id)
		_check(routine.id == id and routine.priority >= 0 and routine.start_minute != routine.end_minute, "typed window " + id)
		_check(routine._data.is_read_only() and routine._data.participantSteps.is_read_only(), "deep read-only " + id)
		for npc_id: String in routine.participants:
			if npc_id not in roster: roster.append(npc_id)
			_check(not routine.steps(npc_id).is_empty(), "typed plan " + id + "/" + npc_id)
			for step: RoutineDefinition.Step in routine.steps(npc_id):
				steps_count += 1
				var kind: String = RoutineDefinition.STEPS[step.kind]
				if kind not in step_kinds: step_kinds.append(kind)
				_check(step._data.is_read_only(), "immutable step " + id + "/" + step.id)
				if step.kind == RoutineDefinition.StepKind.MOVE:
					_check(step.map_id.begins_with("prototype-") and not step.anchor_id.is_empty(), "qualified target " + step.id)
					var target: String = step.map_id + ":" + step.anchor_id
					if target not in anchors: anchors.append(target)
				else: _check(step.duration_seconds > 0.0 and is_finite(step.duration_seconds), "finite timing " + step.id)
		for condition: RoutineDefinition.Condition in routine.conditions():
			var kind: String = RoutineDefinition.CONDITIONS[condition.kind]
			if kind not in condition_kinds: condition_kinds.append(kind)
			_check(condition._data.is_read_only(), "immutable typed condition " + id)
		var detached: Dictionary = routine.snapshot()
		detached["priority"] = 999
		detached["participantSteps"].clear()
		var participant_copy: PackedStringArray = routine.participants
		participant_copy.clear()
		_check(not routine.steps(routine.participants[0]).is_empty() and catalog.get_routine(id).priority != 999, "detached definitions " + id)
	roster.sort()
	_check(roster == NpcContentCatalog.ROSTER and anchors.size() == 21, "eight people / 21 qualified targets")
	_check(step_kinds.size() == 4 and condition_kinds.size() == 6, "production step and condition variants")
	var refs: Dictionary = catalog.reference_snapshot()
	_check(refs.maps.size() == 3 and refs.portals.size() == 4, "three declared maps / four portals")
	for portal: Dictionary in refs.portals:
		_check(portal.sourceMapId != portal.destinationMapId and not portal.arrivalId.is_empty(), "explicit directed portal " + portal.id)
	for source: Dictionary in refs.maps:
		for destination: Dictionary in refs.maps: _check(catalog._connected(source.id, destination.id, refs), "declared chain " + source.id + " -> " + destination.id)
	var severed: Dictionary = refs.duplicate(true)
	severed.portals.clear()
	_check(not catalog._connected("prototype-alderwake", "prototype-mayor-vale-home", severed), "no invented portal chain")
	refs.maps[0].anchors.clear()
	_check(catalog.reference_snapshot().maps[0].anchors.size() == 11, "reference snapshot detached")
	_mutation_checks()
	_json_checks()
	_positive_variants()
	_check(npc_before == npcs.document_snapshot(), "NPC/social pins and activation unchanged")
	var report: Dictionary = {"task": "R002", "mode": "synthetic strict content/reference validation; no production schedule activation", "assertions": assertions, "routines": 25, "people": roster, "anchors": anchors.size(), "steps": steps_count, "rejections": rejections, "failures": failures}
	_check(TestRunEvidence.write_json("routine-content.json", report), "task-owned evidence")
	_finish()

func _mutation_checks() -> void:
	# Every actual object level: missing keys and unknown keys reject atomically.
	var paths: Array[Array] = []
	_object_paths(documents[FILE], [], paths)
	for path: Array in paths:
		var original: Dictionary = _at(documents[FILE], path)
		for key: String in original:
			var copy: Dictionary = documents.duplicate(true)
			_at(copy[FILE], path).erase(key)
			_reject(copy, index, "missing " + str(path) + "." + key)
		var copy: Dictionary = documents.duplicate(true)
		_at(copy[FILE], path)["unknownField"] = true
		_reject(copy, index, "unknown " + str(path))
	for key: String in index:
		var candidate: Dictionary = index.duplicate(true)
		candidate.erase(key)
		_reject(documents, candidate, "missing catalog." + key)
	var bad_index: Dictionary = index.duplicate(true)
	bad_index.routines[1] = bad_index.routines[0].duplicate(true)
	_reject(documents, bad_index, "duplicate index ID/asset")
	bad_index = index.duplicate(true)
	bad_index.routines[0].asset = "../source.json"
	_reject(documents, bad_index, "external/path traversal")
	bad_index = index.duplicate(true)
	bad_index.routines[0].id = "unrequested-routine"
	_reject(documents, bad_index, "unknown routine")
	bad_index = index.duplicate(true)
	bad_index.schemaVersion = 2
	_reject(documents, bad_index, "wrong catalog version")
	var copy: Dictionary = documents.duplicate(true)
	copy.erase(FILE)
	_reject(copy, index, "missing final file / no partial publish")
	copy = documents.duplicate(true)
	copy["res://content/routines/extra.json"] = documents[FILE]
	_reject(copy, index, "unindexed file")
	copy = documents.duplicate(true)
	copy[5] = documents[FILE]
	_reject(copy, index, "non-string file key")
	copy = documents.duplicate(true)
	copy[FILE][5] = true
	_reject(copy, index, "non-string object key")
	for value: Variant in [null, [], true, "", 1]:
		copy = documents.duplicate(true)
		copy[FILE] = value
		_reject(copy, index, "ill-typed routine " + str(value))
	var cases: Array[Dictionary] = [
		{"path": ["schemaVersion"], "value": 2},
		{"path": ["id"], "value": "wrong-id"},
		{"path": ["priority"], "value": true},
		{"path": ["priority"], "value": -1},
		{"path": ["priority"], "value": 1.5},
		{"path": ["timeWindow", "start"], "value": "17:00"},
		{"path": ["timeWindow", "start"], "value": "24:00"},
		{"path": ["timeWindow", "start"], "value": "8:00"},
		{"path": ["timeWindow", "start"], "value": ""},
		{"path": ["participants"], "value": []},
		{"path": ["participants"], "value": ["npc-02", "npc-02"]},
		{"path": ["participants"], "value": ["npc-05"]},
		{"path": ["participantSteps"], "value": []},
		{"path": ["participantSteps", 0, "participantId"], "value": "npc-01"},
		{"path": ["participantSteps", 0, "steps"], "value": []},
		{"path": ["participantSteps", 0, "steps", 1, "id"], "value": "leave-civic-briefing"},
		{"path": ["participantSteps", 0, "steps", 2, "kind"], "value": "attack"},
		{"path": ["participantSteps", 0, "steps", 2, "actionId"], "value": "river-fishing"},
		{"path": ["participantSteps", 0, "steps", 1, "target", "anchorId"], "value": "edric-town-square"},
		{"path": ["participantSteps", 0, "steps", 1, "target", "mapId"], "value": "prototype-tollworks"},
		{"path": ["participantSteps", 0, "steps", 3, "text"], "value": " "},
		{"path": ["conditions", 0, "kind"], "value": "unknown"},
		{"path": ["conditions", 0, "npcId"], "value": "npc-05"},
		{"path": ["conditions", 0, "flagId"], "value": "unknown"},
		{"path": ["interactionPolicy", "allowDialogue"], "value": false},
		{"path": ["interactionPolicy", "allowDialogue"], "value": 1},
		{"path": ["interactionPolicy", "defaultDialogueEntryNodeId"], "value": "npc-01-initial-conversation"},
		{"path": ["interactionPolicy", "stepDialogueEntries", 0, "participantId"], "value": "npc-01"},
		{"path": ["interactionPolicy", "stepDialogueEntries", 0, "stepId"], "value": "missing"},
		{"path": ["interactionPolicy", "stepDialogueEntries", 0, "dialogueEntryNodeId"], "value": "missing"},
		{"path": ["interactionPolicy", "outcomeDirectives", 0, "outcomeTag"], "value": "missing"},
		{"path": ["interactionPolicy", "outcomeDirectives", 2, "directive", "stepId"], "value": "missing"},
		{"path": ["interactionPolicy", "outcomeDirectives", 2, "directive", "participantId"], "value": "npc-01"},
		{"path": ["interactionPolicy", "outcomeDirectives", 0, "directive", "kind"], "value": "reward"}
	]
	for item: Dictionary in cases:
		copy = documents.duplicate(true)
		_set_at(copy[FILE], item.path, item.value)
		_reject(copy, index, "bad " + str(item.path) + "=" + str(item.value))
	for duration: Variant in [0, -1, NAN, INF, -INF, true, "5"]:
		copy = documents.duplicate(true)
		copy[FILE].participantSteps[0].steps[2].durationSeconds = duration
		_reject(copy, index, "invalid/nonfinite duration " + str(duration), "afternoon-index")
	for field: String in ["participantSteps", "conditions"]:
		copy = documents.duplicate(true)
		copy[FILE][field] = true
		_reject(copy, index, "ill-typed array " + field)
	for path: Array in [["timeWindow", "start"], ["timeWindow", "end"], ["interactionPolicy", "allowDialogue"], ["interactionPolicy", "defaultDialogueEntryNodeId"], ["participantSteps", 0, "steps", 0, "target"], ["interactionPolicy", "stepDialogueEntries", 0], ["interactionPolicy", "outcomeDirectives", 0, "directive"]]:
		for malformed: Variant in [null, 5, true, [], {}]:
			if str(path[-1]) == "allowDialogue" and malformed is bool: continue
			if str(path[-1]) == "defaultDialogueEntryNodeId" and malformed == null: continue
			copy = documents.duplicate(true)
			_set_at(copy[FILE], path, malformed)
			_reject(copy, index, "type fuzz " + str(path) + "=" + str(malformed))
	for field: String in ["stepDialogueEntries", "outcomeDirectives"]:
		copy = documents.duplicate(true)
		copy[FILE].interactionPolicy[field].append(copy[FILE].interactionPolicy[field][0].duplicate(true))
		_reject(copy, index, "duplicate " + field)
	copy = documents.duplicate(true)
	copy[FILE].participantSteps.append(copy[FILE].participantSteps[0].duplicate(true))
	_reject(copy, index, "duplicate participant plan")
	# Event/fact references are tested without inventing live gameplay history.
	for condition: Dictionary in [
		{"kind": "learnedFact", "npcId": "npc-02", "factId": "npc-01-river-fishing"},
		{"kind": "worldEventActive", "eventId": "unknown"},
		{"kind": "worldEventInactive", "eventId": "unknown"},
		{"kind": "relationshipFlagSet", "npcId": "npc-02", "flagId": "unknown"}
	]:
		copy = documents.duplicate(true)
		copy[FILE].conditions = [condition]
		_reject(copy, index, "bad reference condition " + str(condition))
	var player: Dictionary = {"kind": "playerEvent", "eventKind": "resourceGathered", "subjectId": "moonflower", "targetId": null, "minimumCount": 1, "maximumCount": null, "occurredWithinActiveSeconds": null}
	for key: String in player:
		var condition: Dictionary = player.duplicate(true)
		condition.erase(key)
		copy = documents.duplicate(true)
		copy[FILE].conditions = [condition]
		_reject(copy, index, "missing playerEvent." + key)
	for pair: Array in [["eventKind", "bad"], ["subjectId", "bad"], ["targetId", "bad"], ["minimumCount", -1], ["maximumCount", 0], ["occurredWithinActiveSeconds", INF], ["occurredWithinActiveSeconds", -1]]:
		copy = documents.duplicate(true)
		var condition: Dictionary = player.duplicate(true)
		condition[pair[0]] = pair[1]
		copy[FILE].conditions = [condition]
		_reject(copy, index, "bad playerEvent." + str(pair))
	for key: String in ["subjectId", "targetId"]:
		for malformed: Variant in [true, 5, [], {}]:
			copy = documents.duplicate(true)
			var condition: Dictionary = player.duplicate(true)
			condition.eventKind = "dialogueChoiceSelected"
			condition[key] = malformed
			copy[FILE].conditions = [condition]
			_reject(copy, index, "bad event identifier type " + key + str(malformed))
	for kind: String in ["activateWorldEvent", "deactivateWorldEvent"]:
		copy = documents.duplicate(true)
		copy[FILE].interactionPolicy.outcomeDirectives[0].directive = {"kind": kind, "eventId": "missing"}
		_reject(copy, index, "unknown directive event " + kind)
	copy = documents.duplicate(true)
	copy["res://content/routines/vale-morning-work.json"].interactionPolicy.defaultDialogueEntryNodeId = "npc-02-routine-archive-default"
	_reject(copy, index, "default must exist for every group participant")
	_check(not RoutineContentCatalog.new().initialize_documents(index, documents, null).is_empty(), "missing prerequisite rejected")

func _json_checks() -> void:
	var texts: Dictionary = {}
	for path: String in documents: texts[path] = JSON.stringify(documents[path])
	for bad: String in [
		'{"schemaVersion":1,"schemaVersion":1}',
		'{"schemaVersion":1,"schemaVersion":2}',
		'{"id":"a","\\u0069d":"b"}',
		'{"participantSteps":[{"steps":[{"id":"a","id":"b"}]}]}',
		'{"a":1,}', '[1,]', '{"a":01}', '{"a":1.}', '{"a":NaN}', '{"a":1e999}', '{"a":true} junk',
		'{"a":', '{"a":[}', '{"a":false "b":true}'
	]:
		var copy: Dictionary = texts.duplicate(true)
		copy[FILE] = bad
		var fresh: RoutineContentCatalog = RoutineContentCatalog.new()
		var errors: PackedStringArray = fresh.initialize_texts(JSON.stringify(index), copy, npcs)
		_check(not errors.is_empty() and not fresh.initialized and fresh.definition_count() == 0, "raw JSON rejection " + bad)
		_check("; ".join(errors).contains(FILE), "raw JSON file context")
		_check(not catalog.initialize_texts(JSON.stringify(index), copy, npcs).is_empty() and catalog.definition_count() == 25, "raw failure preserves accepted catalog")
		rejections.append({"fixture": "raw " + bad, "errors": Array(errors)})
	var decoded: Dictionary = RoutineJson.new().decode('{"escaped":"quote: \\"; comma: ,; braces: {}", "number":-2.5e+3, "null":null}', "valid")
	_check(decoded.errors.is_empty() and decoded.value.number == -2500, "strict JSON valid escapes/exponent")
	_check(not RoutineJson.new().decode("[".repeat(70) + "0" + "]".repeat(70), "depth").errors.is_empty(), "bounded nesting")

func _positive_variants() -> void:
	var player: Dictionary = {"kind": "playerEvent", "eventKind": "areaEntered", "subjectId": "woods", "targetId": null, "minimumCount": 0, "maximumCount": 3, "occurredWithinActiveSeconds": 0.0}
	for kind: String in NpcContentCatalog.EVENT_KINDS:
		var condition: Dictionary = player.duplicate(true)
		condition.eventKind = kind
		match kind:
			"resourceGathered": condition.subjectId = "moonflower"
			"itemGifted":
				condition.subjectId = "moonflower"
				condition.targetId = "npc-02"
			"dialogueChoiceSelected":
				condition.subjectId = "npc-02"
				condition.targetId = "npc-02-careful-research-response"
		var copy: Dictionary = documents.duplicate(true)
		copy[FILE].conditions = [condition]
		var fresh: RoutineContentCatalog = RoutineContentCatalog.new()
		_check(fresh.initialize_documents(index, copy, npcs).is_empty(), "valid synthetic " + kind)
		if fresh.initialized:
			var typed: RoutineDefinition.Condition = fresh.get_routine(ARCHIVE).conditions()[0]
			_check(typed.minimum_count == 0 and typed.maximum_count == 3 and typed.recency_seconds == 0.0, "typed bounded event query")
		condition.subjectId = null
		condition.targetId = null
		copy[FILE].conditions = [condition]
		_check(RoutineContentCatalog.new().initialize_documents(index, copy, npcs).is_empty(), "nullable event vocabulary " + kind)
	for kind: String in ["activateWorldEvent", "deactivateWorldEvent"]:
		var copy: Dictionary = documents.duplicate(true)
		copy[FILE].interactionPolicy.outcomeDirectives[0].directive = {"kind": kind, "eventId": "heavy-rain"}
		var fresh: RoutineContentCatalog = RoutineContentCatalog.new()
		_check(fresh.initialize_documents(index, copy, npcs).is_empty(), "valid fixture-only event directive " + kind)
		if fresh.initialized: _check(fresh.get_routine(ARCHIVE).directive("npc-02-resume-archive-default").event_id == "heavy-rain", "typed event directive")
	var archive: RoutineDefinition = catalog.get_routine(ARCHIVE)
	_check(archive.directive("npc-02-review-archive-ledger").kind == RoutineDefinition.DirectiveKind.JUMP and archive.directive("npc-02-review-archive-ledger").step_id == "afternoon-review-ledger", "typed real jump")
	_check(archive.directive("npc-02-end-archive-default").kind == RoutineDefinition.DirectiveKind.END_FOR_DAY, "typed real end")
	_check(archive.directive("npc-02-resume-archive-default").kind == RoutineDefinition.DirectiveKind.RESUME, "typed real resume")
	_check(archive.step_dialogue_entry("npc-02", "afternoon-index") == "npc-02-routine-archive-indexing", "typed step entry")
	_check(catalog.get_routine("vale-overnight-home").overnight, "typed overnight window")
	var copy: Dictionary = documents.duplicate(true)
	var accepted: RoutineContentCatalog = RoutineContentCatalog.new()
	_check(accepted.initialize_documents(index, copy, npcs).is_empty(), "detached caller publication")
	copy[FILE].participantSteps.clear()
	_check(not accepted.get_routine(ARCHIVE).steps("npc-02").is_empty(), "caller cannot mutate canonical")

func _reject(candidate: Dictionary, candidate_index: Dictionary, label: String, step: String = "") -> void:
	var fresh: RoutineContentCatalog = RoutineContentCatalog.new()
	var errors: PackedStringArray = fresh.initialize_documents(candidate_index, candidate, npcs)
	_check(not errors.is_empty() and not fresh.initialized and fresh.definition_count() == 0, "atomic reject " + label)
	if not step.is_empty(): _check("; ".join(errors).contains(step) and "; ".join(errors).contains(FILE), "routine/file/step context " + label)
	var before: Dictionary = catalog.document_snapshot(ARCHIVE)
	_check(not catalog.initialize_documents(candidate_index, candidate, npcs).is_empty() and catalog.definition_count() == 25 and before == catalog.document_snapshot(ARCHIVE), "failure preserves publication " + label)
	rejections.append({"fixture": label, "errors": Array(errors)})

func _object_paths(value: Variant, path: Array, paths: Array[Array]) -> void:
	if value is Dictionary:
		paths.append(path.duplicate())
		for key: String in value: _object_paths(value[key], path + [key], paths)
	elif value is Array:
		for offset: int in value.size(): _object_paths(value[offset], path + [offset], paths)

func _at(value: Variant, path: Array) -> Variant:
	var current: Variant = value
	for key: Variant in path: current = current[key]
	return current

func _set_at(value: Variant, path: Array, replacement: Variant) -> void:
	var parent: Variant = _at(value, path.slice(0, path.size() - 1))
	parent[path[-1]] = replacement

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _finish() -> void:
	for failure: String in failures: push_error("ASSERTION: " + failure)
	print("R002 routine content: %d assertions; %d rejection fixtures; %d failures" % [assertions, rejections.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)
