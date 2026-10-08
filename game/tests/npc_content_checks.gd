extends SceneTree
## N002 content/rule evidence only. No ordinary NPC access or character art claim.

var failures: Array[String] = []
var assertions: int = 0
var rejections: Array[Dictionary] = []
var actors: ContentCatalog = ContentCatalog.new()
var catalog: NpcContentCatalog = NpcContentCatalog.new()
var canonical: Dictionary

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_check(actors.initialize(load("res://content/prototype_catalog.tres") as ContentManifest).is_empty(), "Legacy catalog must initialize")
	_check(catalog.initialize_path(actors).is_empty(), "Bundled NPC catalog must initialize")
	if not catalog.initialized:
		push_error("NPC catalog failed: " + "; ".join(catalog.initialize_path(actors)))
		quit(1)
		return
	canonical = catalog.document_snapshot()
	_check(catalog.npc_ids() == NpcContentCatalog.ROSTER and catalog.definition_count() == 8, "Exact selected roster")
	_check(actors.definition_count() == 21 and actors.get_actor("npc-03").display_name == "Maris", "Legacy actor catalog/Maris unchanged")
	_check(catalog.get_npc("npc-05") == null and catalog.get_npc("prototype-companion") == null, "Unrequested people excluded")
	var totals: Dictionary = {"nodes": 0, "choices": 0, "facts": 0, "portraits": 0, "sheets": 0, "deferred_nodes": 0, "deferred_choices": 0, "gifts": 0}
	for id: String in catalog.npc_ids():
		var npc: NpcDefinition = catalog.get_npc(id)
		_check(npc.id == id and npc.actor_id == id and npc.graph.npc_id == id, "Person/actor/graph identity " + id)
		_check(npc.level_one_affinity == 3 and npc.source_hit_size == Vector2(32, 32), "Source numeric definition " + id)
		_check(npc.row_order == PackedStringArray(["south", "north", "west", "east"]), "Facing order " + id)
		totals.facts += npc.facts.size()
		totals.portraits += npc.portraits.size()
		totals.sheets += npc.sheets.size()
		totals.gifts += npc.gifts.size()
		for gift: NpcDefinition.GiftRule in npc.gifts.values():
			_check(gift.availability.is_enabled() and gift.acceptance_cap == 2 and gift.item_id == "moonflower", "Typed approved gift " + gift.id)
		for node: NpcDialogueGraph.NodeDefinition in npc.graph.nodes.values():
			totals.nodes += 1
			_check(node.speaker == npc.display_name and node.npc_id == npc.id, "Source speaker " + node.id)
			_check(npc.portraits.has(node.portrait_id), "Typed expression " + node.id)
			if not node.availability.is_enabled(): totals.deferred_nodes += 1
			for choice: NpcDialogueGraph.Choice in node.choices:
				totals.choices += 1
				if not choice.availability.is_enabled(): totals.deferred_choices += 1
	_check(totals == {"nodes": 70, "choices": 54, "facts": 24, "portraits": 48, "sheets": 18, "deferred_nodes": 3, "deferred_choices": 6, "gifts": 8}, "Full enabled/deferred coverage counts")
	var edric: NpcDefinition = catalog.get_npc("npc-01")
	_check(edric.graph.entry_node_ids[0] == "npc-01-level-1-milestone" and edric.graph.entry_node_ids[4] == "npc-01-initial-conversation", "Authored entry order")
	_check(edric.graph.nodes["npc-01-initial-conversation"].choices[0].has_one_time_effect(), "Once-only metadata")
	var event: NpcDialogueGraph.EventCondition = edric.graph.nodes["npc-01-woods-first"].conditions.events[0]
	_check(event.kind == NpcDialogueGraph.EventCondition.Kind.AREA_ENTERED and event.subject_id == "woods" and event.target_id == null and event.maximum_count == 1, "Typed exact-key event")
	_check(not edric.facts["npc-01-public-role"].availability.is_enabled() and not edric.facts["npc-01-river-fishing"].availability.is_enabled(), "No fabricated Edric disclosure")
	_check(not catalog.get_npc("npc-02").facts["npc-02-archive-practice"].availability.is_enabled(), "Archive practice remains routine-only")
	_check(catalog.get_npc("npc-14").graph.nodes["npc-14-introduction"].text.contains("public entrance"), "Audited Della adaptation")
	_check(not catalog.get_npc("npc-14").graph.choices["npc-14-ask-room"].availability.is_enabled(), "Della room branch unavailable")
	_check(edric.sheets.has("river-fishing") and catalog.get_npc("npc-02").sheets.has("archive-work"), "Source action indexes")
	# Mutating input, exported snapshots or nested typed views cannot alter publication.
	var input: Dictionary = canonical.duplicate(true)
	_check(catalog.initialize_document(input, actors).is_empty(), "Repeated full publication")
	input.packages[0].dialogue.nodes[0]["text"] = "caller mutation"
	var snapshot: Dictionary = catalog.document_snapshot()
	snapshot.packages.clear()
	edric.graph.nodes["npc-01-initial-conversation"].text = "typed view mutation"
	edric.graph.entry_node_ids.clear()
	edric.facts["npc-01-public-role"].description = "nested mutation"
	edric.portraits.clear()
	_check(catalog.document_snapshot() == canonical and catalog.definition_count() == 8, "Canonical catalog is detached")
	_check(catalog.get_npc("npc-01").graph.nodes["npc-01-initial-conversation"].text != "typed view mutation", "Independent typed lookup")
	for repeat: int in 3:
		_check(catalog.initialize_path(actors).is_empty() and catalog.definition_count() == 8, "Reload does not accumulate definitions")
	# Valid finite Continue and supported optional source conditions, absent in pin.
	var fixture: Dictionary = canonical.duplicate(true)
	fixture.packages[0].dialogue.nodes[1]["continueTargetId"] = "npc-01-initial-guarded-end"
	fixture.packages[0].dialogue.nodes[1]["conditions"] = {
		"requiredFactIds": ["npc-01-public-role"], "requiredSeenNodeIds": ["npc-01-initial-guarded-end"],
		"minimumAffinity": 0, "maximumAffinity": 3, "minimumRelationshipLevel": 0,
		"events": [{"kind": "dialogueChoiceSelected", "subjectId": "npc-01", "targetId": "npc-01-helpful-response", "minimumCount": 0, "maximumCount": 1, "occurredWithinActiveSeconds": 0.5}]
	}
	var finite: NpcContentCatalog = NpcContentCatalog.new()
	_check(finite.initialize_document(fixture, actors).is_empty(), "Valid finite Continue and optional conditions")
	if finite.initialized:
		var node: NpcDialogueGraph.NodeDefinition = finite.get_npc("npc-01").graph.nodes["npc-01-initial-helpful-end"]
		_check(not node.is_terminal() and node.continue_target_id == "npc-01-initial-guarded-end" and node.conditions.events[0].occurred_within_active_seconds == 0.5, "Optional conditions/Continue typed without loss")
	_reject_value(null, "must be object")
	_reject_value([], "must be object")
	_reject("missing key", func(d: Dictionary) -> void: d.erase("packages"))
	_reject("unsupported key", func(d: Dictionary) -> void: d["extra"] = true)
	_reject("must be integer", func(d: Dictionary) -> void: d["format_version"] = true)
	_reject("source_revision", func(d: Dictionary) -> void: d["source_revision"] = "foreign")
	_reject("must be array", func(d: Dictionary) -> void: d["packages"] = {})
	_reject("exactly eight", func(d: Dictionary) -> void: d.packages.pop_back())
	_reject("duplicate NPC ID", func(d: Dictionary) -> void: d.packages[1] = d.packages[0].duplicate(true))
	_reject("unrequested NPC", func(d: Dictionary) -> void: d.packages[0]["id"] = "npc-05")
	_reject("illegal actor identity", func(d: Dictionary) -> void: d.packages[2]["actor_id"] = "npc-03-copy")
	_reject("cross-person runtime", func(d: Dictionary) -> void: d.packages[0].runtime["id"] = "npc-02")
	_reject("cross-person graph", func(d: Dictionary) -> void: d.packages[0].dialogue["npcId"] = "npc-02")
	_reject("cross-person visual", func(d: Dictionary) -> void: d.packages[0].visuals["npcId"] = "npc-02")
	_reject("nonempty string", func(d: Dictionary) -> void: d.packages[0].runtime["displayName"] = 3)
	_reject("unsupported key", func(d: Dictionary) -> void: d.packages[0].runtime.relationship["hidden"] = true)
	_reject("must be integer", func(d: Dictionary) -> void: d.packages[0].runtime.relationship["levelOneAffinity"] = 0)
	_reject("must be finite", func(d: Dictionary) -> void: d.packages[0].runtime.dimensions["hitWidth"] = NAN)
	_reject("must be finite", func(d: Dictionary) -> void: d.packages[0].runtime.dimensions["hitHeight"] = INF)
	_reject("duplicate ID", func(d: Dictionary) -> void: d.packages[0].runtime.routine.relationshipFlagIds.append(d.packages[0].runtime.routine.relationshipFlagIds[0]))
	_reject("cross-person flag", func(d: Dictionary) -> void: d.packages[0].runtime.routine.relationshipFlagIds.append("npc-02-flag"))
	_reject("duplicate ID", func(d: Dictionary) -> void: d.packages[0].runtime.facts.append(d.packages[0].runtime.facts[0].duplicate(true)))
	_reject("cross-person ID", func(d: Dictionary) -> void: d.packages[0].runtime.facts[0]["id"] = "npc-02-public-role")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].runtime.acceptedGiftRules[0]["requiredFactId"] = "npc-02-public-role")
	_reject("unsupported gift item", func(d: Dictionary) -> void: d.packages[0].runtime.acceptedGiftRules[0]["itemId"] = "unknown")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].runtime.relationship.levelOneMilestone["dialogueNodeId"] = "absent")
	_reject("duplicate ID", func(d: Dictionary) -> void: d.packages[0].dialogue.entryNodeIds.append(d.packages[0].dialogue.entryNodeIds[0]))
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.entryNodeIds[0] = "absent")
	_reject("duplicate ID", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes.append(d.packages[0].dialogue.nodes[0].duplicate(true)))
	_reject("nonempty string", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["text"] = " ")
	_reject("must be integer", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["priority"] = 1.5)
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["portraitId"] = "absent")
	_reject("missing image", func(d: Dictionary) -> void: d.packages[0].visuals.portraits["skeptical"] = "res://assets/npcs/portraits/npc-01/absent.png")
	_reject("owned target-local", func(d: Dictionary) -> void: d.packages[0].visuals.portraits["skeptical"] = d.packages[1].visuals.portraits.skeptical)
	_reject("owned target-local", func(d: Dictionary) -> void: d.packages[0].visuals.portraits["skeptical"] = "D:/development/game-prototype-2/portrait.png")
	_reject("requires six portraits", func(d: Dictionary) -> void: d.packages[0].visuals.portraits.erase("skeptical"))
	_reject("invalid image dimensions", func(d: Dictionary) -> void: d.packages[0].visuals.world.idle["framesPerFacing"] = 3)
	_reject("missing declared action", func(d: Dictionary) -> void: d.packages[0].visuals.world.actions.clear())
	_reject("unsupported facing", func(d: Dictionary) -> void: d.packages[0].visuals.world.rowOrder.reverse())
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["revealedFactIds"] = ["npc-02-public-role"])
	_reject("unsupported key", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions["questComplete"] = true)
	_reject("must be object", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["conditions"] = null)
	_reject("must be array", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions["excludedFlags"] = "flag")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions["excludedFlags"] = ["npc-02-flag"])
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions["requiredSeenNodeIds"] = ["absent"])
	_reject("inverted affinity", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions.merge({"minimumAffinity": 3, "maximumAffinity": 2}))
	_reject("contradictory conditions", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].conditions["requiredFlags"] = d.packages[0].dialogue.nodes[0].conditions.excludedFlags.duplicate())
	_reject("unsupported event", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[3].conditions.events[0]["kind"] = "invented")
	_reject("must be integer", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[3].conditions.events[0]["maximumCount"] = 0)
	_reject("must be integer", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[3].conditions.events[0]["minimumCount"] = true)
	_reject("must be finite", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[3].conditions.events[0]["occurredWithinActiveSeconds"] = -1)
	_reject("duplicate ID", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices.append(d.packages[0].dialogue.nodes[0].choices[0].duplicate(true)))
	_reject("duplicate global choice", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[1]["choices"] = [d.packages[0].dialogue.nodes[0].choices[0].duplicate(true)])
	_reject("missing key text", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0].erase("text"))
	_reject("must be boolean", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["oneTime"] = 1)
	_reject("must be integer", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["affinityDelta"] = 2)
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["targetNodeId"] = "npc-02-initial-careful-end")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["oneTimeRewardFlag"] = "absent")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["addedFlags"] = ["absent"])
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[5].choices[0]["giftRuleId"] = "absent")
	_reject("exactly target or end", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0].erase("targetNodeId"))
	_reject("exactly target or end", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0].choices[0]["endsConversation"] = true)
	_reject("choices and continue", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[0]["continueTargetId"] = "npc-01-initial-helpful-end")
	_reject("cyclic finite", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[1]["continueTargetId"] = "npc-01-initial-conversation")
	_reject("missing/cross-person reference", func(d: Dictionary) -> void: d.packages[0].dialogue.nodes[1]["continueTargetId"] = "absent")
	_reject("unsupported key", func(d: Dictionary) -> void: d.packages[0].coverage["extra"] = {})
	_reject("missing coverage ID", func(d: Dictionary) -> void: d.packages[0].coverage.node.erase("npc-01-initial-conversation"))
	_reject("unsupported availability", func(d: Dictionary) -> void: d.packages[0].coverage.node["npc-01-initial-conversation"]["status"] = "hidden")
	_reject("nonempty string", func(d: Dictionary) -> void: d.packages[0].coverage.node["npc-01-initial-conversation"]["reason"] = "")
	_reject("must be enabled", func(d: Dictionary) -> void: d.packages[0].coverage.choice["npc-01-gift-moonflower-from-hint"]["status"] = "deferred")
	_reject("must be enabled", func(d: Dictionary) -> void: d.packages[0].coverage.gift_rule["npc-01-moonflower-gift"]["status"] = "deferred")
	_reject("must be enabled", func(d: Dictionary) -> void: d.packages[0].coverage.node["npc-01-gift-response"]["status"] = "deferred")
	_reject("must be enabled", func(d: Dictionary) -> void: d.packages[0].coverage.node["npc-01-level-1-milestone"]["status"] = "deferred")
	_reject("must stay deferred", func(d: Dictionary) -> void: d.packages[1].coverage.node["npc-02-routine-archive-indexing"]["status"] = "enabled")
	_reject("fact disclosure classification", func(d: Dictionary) -> void: d.packages[1].coverage.fact["npc-02-archive-practice"]["status"] = "enabled")
	_reject("must stay deferred", func(d: Dictionary) -> void: d.packages[7].coverage.choice["npc-14-ask-room"]["status"] = "enabled")
	_reject("enabled continue targets deferred", func(d: Dictionary) -> void: d.packages[7].dialogue.nodes[1]["continueTargetId"] = "npc-14-room")
	_reject("owned target-local", func(d: Dictionary) -> void: d.packages[0].visuals.portraits["skeptical"] = "res://assets/npcs/portraits/npc-01/../npc-02/skeptical.png")
	var empty: NpcContentCatalog = NpcContentCatalog.new()
	_check(not empty.initialize_document(canonical, ContentCatalog.new()).is_empty() and empty.definition_count() == 0, "Unvalidated legacy catalog rejected")
	_check(not catalog.initialize_path(actors, "res://content/npcs/absent.json").is_empty() and catalog.document_snapshot() == canonical, "Missing catalog preserves publication")
	_check(not catalog.initialize_path(actors, "D:/external.json").is_empty(), "Absolute runtime source path rejected")
	var evidence: Dictionary = {"task": "N002", "profile": "RULE/content", "assertions": assertions, "totals": totals, "rejections": rejections, "failures": failures, "source_revision": NpcContentCatalog.SOURCE_REVISION, "runtime_catalog_sha256": FileAccess.get_sha256(NpcContentCatalog.PATH)}
	_check(TestRunEvidence.write_json("npc-content.json", evidence), "Evidence publication")
	if failures.is_empty():
		print("N002 NPC content PASS: %d assertions, %d malformed candidates, exact eight graphs and detached atomic publication." % [assertions, rejections.size()])
	else:
		for failure: String in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _reject(expected: String, mutate: Callable) -> void:
	var fixture: Dictionary = canonical.duplicate(true)
	mutate.call(fixture)
	_reject_value(fixture, expected)

func _reject_value(value: Variant, expected: String) -> void:
	var before: Dictionary = catalog.document_snapshot()
	var errors: PackedStringArray = catalog.initialize_document(value, actors)
	_check(expected in "\n".join(errors), "Useful rejection '%s', got %s" % [expected, errors])
	_check(catalog.initialized and catalog.document_snapshot() == before, "Rejected replacement must preserve every prior byte")
	var empty: NpcContentCatalog = NpcContentCatalog.new()
	_check(not empty.initialize_document(value, actors).is_empty() and not empty.initialized and empty.definition_count() == 0, "No partial initial publication")
	rejections.append({"expected": expected, "errors": Array(errors)})

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
