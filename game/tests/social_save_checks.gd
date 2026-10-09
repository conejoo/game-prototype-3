extends SceneTree
## G003 strict social derivation; synthetic inventory/routing, no ordinary-play claim.
var failures: PackedStringArray = []
var assertions: int = 0
var rejected: PackedStringArray = []
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	for id: String in NpcContentCatalog.ROSTER:
		for positive: bool in [true, false]:
			var pair: Dictionary = SocialSaveFixture.setup()
			SocialSaveFixture.introduce(pair, id, positive)
			SocialSaveFixture.preference(pair, id)
			_check(pair.session.inventory.add("item-moonflower", 2).is_empty(), "synthetic supply")
			for count: int in [1,2]:
				SocialSaveFixture.gift(pair, id)
				var data: Dictionary = SaveCodec.snapshot(pair.session)
				var decoded: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(data,"",true,true),pair.actors,pair.catalog)
				_check(decoded.session != null and decoded.errors.is_empty(), "accepted " + id + "/" + str(positive) + "/" + str(count) + str(decoded.errors))
				if decoded.session != null: _check(SaveCodec.snapshot(decoded.session) == data,"exact all fields " + id)
				_check(data.conversations.people[id].affinity == count + (1 if positive else 0),"derived affinity")
				_check(data.conversations.people[id].level == (1 if positive and count == 2 else 0),"derived level")
				_check(data.conversations.people[id].applied_choice_ids.size() == 1,"gift is repeatable, intro once-only")
				_check(data.inventory.item_counts.get("item-moonflower",0) == 2-count,"owned quantity")
				_reject_mutations(data,pair,id)
	var pair: Dictionary = SocialSaveFixture.complete()
	var data: Dictionary = SaveCodec.snapshot(pair.session)
	_check(SaveCodec.validate(data,pair.actors,pair.catalog).session != null,"nontrivial old/new durable state")
	_check(SaveCodec.validate(data,pair.actors).session != null,"production catalog restores enabled social state")
	_boundaries(pair,data)
	await _disk_checks(pair)
	_check(TestRunEvidence.write_json("social-save.json",{"assertions":assertions,"rejections":rejected,"failures":failures,"proof":"synthetic strict save/routing plus actual repository IO"}),"report")
	for error: String in failures: push_error(error)
	print("G003 social save: ","PASS" if failures.is_empty() else "FAILED"," assertions=",assertions," rejections=",rejected.size())
	quit(0 if failures.is_empty() else 1)

func _reject_mutations(data: Dictionary, pair: Dictionary, id: String) -> void:
	for mutation: String in ["affinity","level","flag","fact","receipt","missing-gift","missing-choice","gift-total","cap","sequence","time","wrong-item","foreign-choice","deferred","gift-before-intro","missing-target","missing-preference","forged-milestone"]:
		var bad: Dictionary = data.duplicate(true)
		var person: Dictionary = bad.conversations.people[id]
		var gift: Dictionary
		var choice: Dictionary
		var intro: Dictionary
		for row: Dictionary in bad.conversations.events.facts:
			if row.kind == NpcEventMemory.GIFT and row.target_id == id: gift = row
			if row.kind == NpcEventMemory.CHOICE and row.subject_id == id:
				if not pair.catalog.get_npc(id).graph.choices[row.target_id].gift_rule_id.is_empty(): choice = row
				elif pair.catalog.get_npc(id).graph.choices[row.target_id].has_one_time_effect(): intro = row
		match mutation:
			"affinity": person.affinity += 1
			"level": person.level = 1-person.level
			"flag": person.flags.append("unknown")
			"fact": person.learned_fact_ids.append("npc-02-archive-practice")
			"receipt": person.applied_choice_ids.append(choice.target_id)
			"missing-gift": bad.conversations.events.facts.erase(gift)
			"missing-choice": bad.conversations.events.facts.erase(choice)
			"gift-total": gift.count += 1
			"cap": gift.count = 3
			"sequence": gift.first_sequence = choice.first_sequence
			"time": gift.first_active_seconds = choice.first_active_seconds - 0.01
			"wrong-item": gift.subject_id = "item-moonflower"
			"foreign-choice": choice.subject_id = "npc-99"
			"deferred": person.seen_node_ids.append("npc-14-room")
			"gift-before-intro":
				# Swap valid singleton endpoints; total/time order remains legal.
				if gift.count != 1 or choice.count != 1: continue
				var gather: Dictionary
				for row: Dictionary in bad.conversations.events.facts:
					if row.kind == NpcEventMemory.GATHER: gather = row
				var ordered: Array[Dictionary] = [gift,choice,intro]
				if not gather.is_empty(): ordered.append(gather)
				for index: int in ordered.size():
					ordered[index].first_sequence = index+1; ordered[index].last_sequence = index+1
					ordered[index].first_active_seconds = 0.0; ordered[index].last_active_seconds = 0.0
			"missing-target": person.seen_node_ids.erase(pair.catalog.get_npc(id).graph.choices[choice.target_id].target_node_id)
			"missing-preference": person.learned_fact_ids.clear()
			"forged-milestone":
				if id == "npc-01" and person.level == 1: person.flags.erase("relationshipLevel1Seen")
				else: person.flags.append("relationshipLevel1Seen")
		var decoded: SaveCodec.DecodeResult = SaveCodec.validate(bad,pair.actors,pair.catalog)
		_check(decoded.session == null and not decoded.errors.is_empty(),"reject " + mutation + "/" + id)
		rejected.append(mutation + "/" + id)
	var invalid_items: Dictionary = data.duplicate(true)
	invalid_items.inventory.item_counts["item-fishing-rod"] = 2
	_check(SaveCodec.validate(invalid_items,pair.actors,pair.catalog).session == null,"invalid item quantities")
	# A coherent third command has matching totals, valid sequence/time and rewards;
	# shared authored cap must still reject it before constructing a candidate.
	if data.conversations.events.facts.any(func(row: Dictionary) -> bool: return row.kind == NpcEventMemory.GIFT and row.target_id == id and row.count == 2):
		var bad: Dictionary = data.duplicate(true)
		var last: int = bad.conversations.events.last_sequence
		var selected: String = ""
		for row: Dictionary in bad.conversations.events.facts:
			if row.kind == NpcEventMemory.GIFT and row.target_id == id: row.count += 1; row.last_sequence = last+1; row.last_active_seconds = bad.elapsed_play_seconds
			if row.kind == NpcEventMemory.CHOICE and row.subject_id == id and not pair.catalog.get_npc(id).graph.choices[row.target_id].gift_rule_id.is_empty(): selected = row.target_id
		for row: Dictionary in bad.conversations.events.facts:
			if row.kind == NpcEventMemory.CHOICE and row.target_id == selected: row.count += 1; row.last_sequence = last+2; row.last_active_seconds = bad.elapsed_play_seconds
		bad.conversations.events.last_sequence += 2
		bad.conversations.people[id].affinity += 1
		bad.conversations.people[id].level = 1
		_check(SaveCodec.validate(bad,pair.actors,pair.catalog).session == null,"coherent matching over-cap third gift " + id)

func _boundaries(pair: Dictionary, data: Dictionary) -> void:
	var edge: Dictionary = data.duplicate(true)
	edge.elapsed_play_seconds = NpcEventMemory.MAX_ACTIVE_SECONDS
	for row: Dictionary in edge.conversations.events.facts:
		row.first_active_seconds = 1.0 - pow(2.0,-53.0)
		row.last_active_seconds = row.first_active_seconds
	var result: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(edge,"",true,true),pair.actors,pair.catalog)
	_check(result.session != null and SaveCodec.snapshot(result.session) == edge,"social exact binary64 time below1 and MAX elapsed")
	var raw: String = JSON.stringify(data,"",true,true)
	for token: String in ["1.00000000000000001","100000000000000001e-17"]:
		_check(SaveCodec.decode(raw.replace('"count":1','"count":'+token),pair.actors,pair.catalog).session == null,"social strict count lexeme " + token)
	var uninitialized: NpcContentCatalog = NpcContentCatalog.new()
	_check(SaveCodec.decode(raw,pair.actors,uninitialized).session == null,"injected catalog must be validated")
	var items: ContentCatalog = ContentCatalog.new()
	var manifest: ContentManifest = load("res://content/prototype_catalog.tres").duplicate(true)
	for definition: ContentDefinition in manifest.definitions:
		if definition is ItemDefinition and definition.stable_id == "item-moonflower": definition.giftable = false
	_check(items.initialize(manifest).is_empty(),"synthetic non-giftable catalog")
	_check(SaveCodec.validate(data,items,pair.catalog).session == null,"gift restore validates item metadata")
	# Pure source-order variants exercise skipped target and endsConversation.
	# These are explicit synthetic authoring variants, not the pinned release graph.
	var variant: Dictionary = SocialSaveFixture.setup()
	SocialSaveFixture.introduce(variant,"npc-01")
	SocialSaveFixture.preference(variant,"npc-01")
	variant.session.inventory.add("item-moonflower",2)
	SocialSaveFixture.gift(variant,"npc-01")
	# Distinct, enabled but unvisited target: crossing must replace it with milestone.
	variant.catalog._packages["npc-01"].dialogue.nodes.filter(func(node: Dictionary) -> bool: return node.id == "npc-01-follow-up-conversation")[0].choices[0].targetNodeId = "npc-01-initial-guarded-end"
	SocialSaveFixture.gift(variant,"npc-01")
	var skipped: Dictionary = SaveCodec.snapshot(variant.session)
	_check("npc-01-initial-guarded-end" not in skipped.conversations.people["npc-01"].seen_node_ids and SaveCodec.validate(skipped,variant.actors,variant.catalog).session != null,"legal milestone replacement does not require skipped target")
	var rule: Dictionary = variant.catalog._packages["npc-01"].runtime.acceptedGiftRules[0]
	rule.affinityDelta = -1
	_check(SaveCodec.validate(skipped,variant.actors,variant.catalog).session == null,"signed gift history refuses aggregate inference")
	var ended: Dictionary = SocialSaveFixture.setup()
	SocialSaveFixture.introduce(ended,"npc-01")
	SocialSaveFixture.preference(ended,"npc-01")
	ended.session.inventory.add("item-moonflower",2)
	SocialSaveFixture.gift(ended,"npc-01")
	ended.catalog._packages["npc-01"].dialogue.nodes.filter(func(node: Dictionary) -> bool: return node.id == "npc-01-follow-up-conversation")[0].choices[0].endsConversation = true
	SocialSaveFixture.gift(ended,"npc-01")
	var ended_data: Dictionary = SaveCodec.snapshot(ended.session)
	_check(ended_data.conversations.people["npc-01"].level == 1 and "relationshipLevel1Seen" not in ended_data.conversations.people["npc-01"].flags and SaveCodec.validate(ended_data,ended.actors,ended.catalog).session != null,"endsConversation precedes milestone routing")
	_check(ended.service.begin("npc-01","fixture-npc-01").ok and ended.service.snapshot().node_id == "npc-01-level-1-milestone","real later milestone entry")
	ended.service.cancel()
	_check(SaveCodec.validate(SaveCodec.snapshot(ended.session),ended.actors,ended.catalog).session != null,"later authored milestone entry derives seen flag")

func _disk_checks(pair: Dictionary) -> void:
	var repo: SaveRepository = SaveRepository.new("user://saves/g003-check.json",pair.catalog)
	_check(repo.write(pair.session,pair.actors).is_empty(),"real atomic first write")
	var raw: String = FileAccess.get_file_as_string(repo.path)
	var before: Dictionary = SaveCodec.snapshot(pair.session)
	var read: SaveRepository.ReadResult = repo.read(pair.actors)
	_check(read.session != null and SaveCodec.snapshot(read.session) == before,"exact persisted bytes round trip")
	_check(DirAccess.make_dir_absolute(repo.path + ".tmp") == OK,"owned IO obstruction")
	_check(not repo.write(pair.session,pair.actors).is_empty() and FileAccess.get_file_as_string(repo.path) == raw and FileAccess.get_file_as_string(repo.path + ".bak") == raw,"failed write preserves primary/backup/live")
	_check(DirAccess.remove_absolute(repo.path + ".tmp") == OK,"remove owned obstruction")
	_write(repo.path,"broken")
	read = repo.read(pair.actors)
	_check(read.recovered and read.session != null and SaveCodec.snapshot(read.session) == before,"backup restores exact social/old state")
	_check(FileAccess.get_file_as_string(repo.path) == "broken","recovery read-only")
	var invalid: Dictionary = before.duplicate(true); invalid.schema_version = SaveCodec.SCHEMA_VERSION + 1
	_write(repo.path,JSON.stringify(invalid,"",true,true))
	var incompatible: String = FileAccess.get_file_as_string(repo.path)
	_check(repo.read(pair.actors).status == "incompatible" and not repo.write(pair.session,pair.actors).is_empty(),"unsupported no fallback/overwrite")
	_check(FileAccess.get_file_as_string(repo.path) == incompatible and FileAccess.get_file_as_string(repo.path + ".bak") == raw and SaveCodec.snapshot(pair.session) == before,"incompatible preserves files/live")
	var malformed: Dictionary = before.duplicate(true); malformed.conversations.people["npc-01"].affinity += 1
	_write(repo.path,JSON.stringify(malformed,"",true,true)); _write(repo.path + ".bak","broken")
	_check(repo.read(pair.actors).session == null and SaveCodec.snapshot(pair.session) == before,"corrupt gift load cannot publish")

func _write(path: String, raw: String) -> void:
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	_check(file != null,"fixture IO")
	if file != null: file.store_string(raw); file.close()
func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
