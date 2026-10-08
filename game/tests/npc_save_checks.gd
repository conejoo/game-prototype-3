extends SceneTree
## N004 strict malformed envelopes, real root rollback, exact current-format facts.
var failures: PackedStringArray = []
var assertions: int = 0
var rejected: PackedStringArray = []
var catalog: ContentCatalog = ContentCatalog.new()
var npcs: NpcContentCatalog = NpcContentCatalog.new()
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	_check(catalog.initialize(load("res://content/prototype_catalog.tres")).is_empty(), "core")
	_check(npcs.initialize_path(catalog).is_empty(), "npc catalog")
	var run: GameSession = ForagingSaveFixture.make(catalog, "tollworks")
	failures.append_array(NpcSaveFixture.populate(run, npcs))
	var data: Dictionary = SaveCodec.snapshot(run)
	var decoded: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(data, "", true, true), catalog)
	_check(decoded.session != null and decoded.errors.is_empty(), "nontrivial all-eight exact round trip")
	if decoded.session == null: _finish(); return
	_check(SaveCodec.snapshot(decoded.session) == data, "all prior/new facts exactly equal")
	var old: Dictionary = data.duplicate(true)
	data.conversations.people["npc-01"].flags.append("foreign")
	_check(SaveCodec.snapshot(decoded.session) == old and SaveCodec.snapshot(run) == old, "candidate/snapshot/source collections detached")
	data = old
	var memory: ConversationMemory = decoded.session.conversations.memory("npc-01")
	memory.flags.append("foreign")
	var events: NpcEventMemory = decoded.session.conversations.events()
	events._facts.clear()
	_check(SaveCodec.snapshot(decoded.session) == data, "query collections detached")
	for id: String in npcs.npc_ids():
		var person: Dictionary = data.conversations.people[id]
		_check(person.affinity in [0,1] and person.applied_choice_ids.size() == 1 and person.seen_node_ids.size() >= 3, "independent intro/revisit " + id)
		for field: String in person:
			var bad: Dictionary = data.duplicate(true); bad.conversations.people[id].erase(field)
			_reject(bad, "missing " + id + "/" + field)
		for field: String in ["flags", "learned_fact_ids", "seen_node_ids", "applied_choice_ids"]:
			for value: Variant in [null, true, {}, "set", [false], ["unknown"], ["npc-99-future"], person[field] + person[field]]:
				if value is Array and value.is_empty(): continue
				var bad: Dictionary = data.duplicate(true); bad.conversations.people[id][field] = value
				_reject(bad, "malformed/foreign/duplicate " + id + "/" + field + " " + str(value))
		for pair: Array in [["npc_id","npc-99"],["npc_id",false],["affinity",true],["affinity",-1],["affinity",0.5],["affinity",2147483648],["affinity",INF],["affinity",NAN],["affinity",2147483647],["level",1],["level",false],["level",-1],["level",2],["level",0.5]]:
			var bad: Dictionary = data.duplicate(true); bad.conversations.people[id][pair[0]] = pair[1]
			_reject(bad, "identity/numeric/derived " + id + " " + str(pair))
	for field: String in ["people", "events"]:
		var bad: Dictionary = data.duplicate(true); bad.conversations.erase(field); _reject(bad, "missing " + field)
	for value: Variant in [null, true, [], {}, {"people":{},"events":{}}]:
		var bad: Dictionary = data.duplicate(true); bad.conversations = value; _reject(bad, "invalid conversation envelope")
	for mutation: String in ["extra-person", "missing-person", "extra-field", "deferred-node", "deferred-fact", "cross-person-node", "opposite-receipt"]:
		var bad: Dictionary = data.duplicate(true)
		match mutation:
			"extra-person": bad.conversations.people["npc-99"] = bad.conversations.people["npc-01"].duplicate(true)
			"missing-person": bad.conversations.people.erase("npc-01")
			"extra-field": bad.conversations.people["npc-01"]["cursor"] = "transient"
			"deferred-node": bad.conversations.people["npc-01"].seen_node_ids.append("npc-01-level-one-milestone")
			"deferred-fact": bad.conversations.people["npc-02"].learned_fact_ids.append("npc-02-archive-practice")
			"cross-person-node": bad.conversations.people["npc-01"].seen_node_ids.append("npc-14-introduction")
			"opposite-receipt": bad.conversations.people["npc-01"].applied_choice_ids.append("npc-01-neutral-response")
		_reject(bad, mutation)
	var row: Dictionary = data.conversations.events.facts[0]
	for field: String in row:
		var bad: Dictionary = data.duplicate(true); bad.conversations.events.facts[0].erase(field); _reject(bad, "missing event " + field)
	for field: String in ["count", "first_sequence", "last_sequence", "first_active_seconds", "last_active_seconds"]:
		for value: Variant in [null, true, "1", [], {}, -1, INF, NAN, 2147483648]:
			var bad: Dictionary = data.duplicate(true); bad.conversations.events.facts[0][field] = value; _reject(bad, "event bounds " + field + "=" + str(value))
	for mutation: String in ["unknown-kind", "foreign-subject", "null-subject", "wrong-target", "extra-field", "duplicate", "total", "fraction-total", "huge-total", "missing-total", "missing-facts", "empty-facts", "shared-sequence", "backwards-time", "future-time", "repeated-receipt", "oversize"]:
		var bad: Dictionary = data.duplicate(true)
		var facts: Array = bad.conversations.events.facts
		match mutation:
			"unknown-kind": facts[0].kind = "itemGifted"
			"foreign-subject": facts[0].subject_id = "npc-99"
			"null-subject": facts[0].subject_id = null
			"wrong-target": facts[0].target_id = "foreign"
			"extra-field": facts[0]["last_time"] = 0
			"duplicate": facts.append(facts[0].duplicate(true))
			"total": bad.conversations.events.last_sequence += 1
			"fraction-total": bad.conversations.events.last_sequence = 0.5
			"huge-total": bad.conversations.events.last_sequence = 2147483648
			"missing-total": bad.conversations.events.erase("last_sequence")
			"missing-facts": bad.conversations.events.erase("facts")
			"empty-facts": facts.clear()
			"shared-sequence": facts[1].first_sequence = facts[0].first_sequence
			"backwards-time": facts[0].first_active_seconds = facts[0].last_active_seconds + 1
			"future-time": facts[0].last_active_seconds = data.elapsed_play_seconds + 1
			"repeated-receipt":
				for fact: Dictionary in facts:
					if fact.kind == NpcEventMemory.CHOICE and "response" in fact.target_id: fact.count = 2; break
			"oversize":
				for index: int in range(41): facts.append(facts[0].duplicate(true))
		_reject(bad, mutation)
	var bytes: String = JSON.stringify(data, "", true, true)
	for token: String in ["1.00000000000000001", "0.99999999999999999", "100000000000000001e-17"]:
		_check(SaveCodec.decode(bytes.replace('"affinity":1', '"affinity":' + token), catalog).session == null, "fraction lexeme affinity " + token)
		_check(SaveCodec.decode(bytes.replace('"count":1', '"count":' + token), catalog).session == null, "fraction lexeme event count " + token)
	_check(SaveCodec.decode(bytes.replace('"affinity":1', '"affinity":0,"affinity":1'), catalog).session == null,"duplicate memory numeric field")
	_check(SaveCodec.decode(bytes.replace('"count":1', '"count":0,"co\\u0075nt":1'), catalog).session == null,"escaped duplicate event field")
	for version: int in [1,2,3,4,5,6,8,99,2147483647]:
		var bad: Dictionary = data.duplicate(true); bad.schema_version = version; bad.erase("conversations")
		var rejected_version: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(bad), catalog)
		_check(rejected_version.session == null and rejected_version.incompatible, "version rejects without default/migration " + str(version))
	# Exact binary64 event times: parser rounding must not weaken upper/sequence gates.
	var edge: GameSession = GameSession.new(); edge.initialize(catalog,"prototype-alderwake","alderwake-start","prototype-hero")
	edge.elapsed_play_seconds = NpcEventMemory.MAX_ACTIVE_SECONDS
	var edge_events: NpcEventMemory = edge.conversations.events().record(NpcEventMemory.AREA,"woods",null,1.0 - pow(2.0,-53.0))
	edge_events = edge_events.record(NpcEventMemory.AREA,"woods",null,NpcEventMemory.MAX_ACTIVE_SECONDS)
	edge.conversations = edge.conversations.with_events(edge_events)
	var edge_data: Dictionary = SaveCodec.snapshot(edge)
	var edge_result: SaveCodec.DecodeResult = SaveCodec.decode(JSON.stringify(edge_data,"",true,true), catalog)
	_check(edge_result.session != null and SaveCodec.snapshot(edge_result.session) == edge_data, "exact event timestamp boundary binary64")
	var shared: Dictionary = edge_data.duplicate(true)
	shared.conversations.people["npc-01"].flags = shared.conversations.people["npc-02"].flags
	_reject(shared, "shared empty mutable memory sets")
	var saturated: Dictionary = edge_data.duplicate(true)
	saturated.conversations.events.last_sequence = NpcEventMemory.MAX_SEQUENCE
	saturated.conversations.events.facts[0].count = NpcEventMemory.MAX_SEQUENCE
	saturated.conversations.events.facts[0].first_sequence = 1
	saturated.conversations.events.facts[0].last_sequence = NpcEventMemory.MAX_SEQUENCE
	var full: NpcSaveData.Result = NpcSaveData.restore(saturated.conversations,npcs,edge.elapsed_play_seconds)
	_check(full.state != null and full.errors.is_empty(), "maximum count/sequence restore without per-event iteration")
	if full.state != null: _check(full.state.events().record(NpcEventMemory.AREA,"woods",null,edge.elapsed_play_seconds) == null,"restored exhaustion remains bounded")
	var impossible: Dictionary = edge_data.duplicate(true)
	impossible.conversations.events = {"last_sequence":4,"facts":[
		{"kind":NpcEventMemory.AREA,"subject_id":"woods","target_id":null,"count":3,"first_sequence":1,"last_sequence":3,"first_active_seconds":0.0,"last_active_seconds":0.0},
		{"kind":NpcEventMemory.GATHER,"subject_id":"moonflower","target_id":null,"count":1,"first_sequence":4,"last_sequence":4,"first_active_seconds":0.0,"last_active_seconds":0.0}]}
	_check(NpcSaveData.restore(impossible.conversations,npcs,edge.elapsed_play_seconds).state != null,"interior aggregate allocation valid")
	impossible.conversations.events.facts[1].first_sequence = 2
	impossible.conversations.events.facts[1].last_sequence = 2
	_reject(impossible,"missing latest sequence")
	_check(not NpcSaveData._feasible_counts([
		{"count":4,"first_sequence":1,"last_sequence":4},
		{"count":2,"first_sequence":2,"last_sequence":3},
		{"count":2,"first_sequence":5,"last_sequence":8}], [1,2,3,4,5,8]), "interior overlapping aggregate counts impossible")
	await _root_checks(run)
	_finish()

func _root_checks(run: GameSession) -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = ContentManifest.new(); manifest.definitions.assign(game.content_manifest.definitions)
	var unsafe: LocationDefinition = LocationDefinition.new()
	unsafe.stable_id = "prototype-unsafe-location"; unsafe.display_name = "N004 test"
	unsafe.prototype_fixture = true; unsafe.scene_path = "res://tests/fixtures/unsafe_location.tscn"
	unsafe.spawn_ids = ["unsafe-no-floor", "unsafe-blocked"]; manifest.definitions.append(unsafe); game.content_manifest = manifest
	root.add_child(game); await game.world_host.transition_finished
	failures.append_array(TestRunSave.configure(game,"user://saves/n004-root.json")); game._set_paused(true)
	failures.append_array(game.save_repository.write(run,game.catalog)); failures.append_array(await game.load_run())
	var before: Dictionary = SaveCodec.snapshot(game.session)
	_check(before == SaveCodec.snapshot(run), "actual root all-state binding")
	var live: GameSession = game.session; var room: PrototypeLocation = game.world_host.current_location
	var foot: Vector3 = game.player_placeholder.global_position
	var raw: String = FileAccess.get_file_as_string(game.save_repository.path)
	_check(DirAccess.make_dir_absolute(game.save_repository.path + ".tmp") == OK,"temporary obstruction")
	_check(not game.save_run().is_empty() and FileAccess.get_file_as_string(game.save_repository.path) == raw and FileAccess.get_file_as_string(game.save_repository.path + ".bak") == raw,"failed stage preserves complete memory/save bytes")
	_check(DirAccess.remove_absolute(game.save_repository.path + ".tmp") == OK,"remove owned obstruction")
	var malformed: Dictionary = before.duplicate(true); malformed.conversations.people["npc-01"].affinity = 99
	_write(game.save_repository.path,JSON.stringify(malformed,"",true,true)); _write(game.save_repository.path + ".bak","broken backup")
	_check(not (await game.load_run()).is_empty() and game.session == live and game.dialogue._session == live and SaveCodec.snapshot(live) == before,"malformed NPC candidate cannot swap live owners/facts")
	_write(game.save_repository.path,raw); _write(game.save_repository.path + ".bak",raw)
	_check(game.dialogue.begin("npc-14","fixture-contact").ok, "conversation open")
	_check(not game.save_run().is_empty() and not (await game.load_run()).is_empty(), "active NPC dialogue blocks manual Save/Load")
	game.dialogue.cancel()
	before = SaveCodec.snapshot(live)
	for spawn: String in unsafe.spawn_ids:
		var bad: Dictionary = before.duplicate(true); bad.location_id = unsafe.stable_id; bad.spawn_id = spawn
		_write(game.save_repository.path,JSON.stringify(bad,"",true,true))
		_check(not (await game.load_run()).is_empty(), "unsafe placement rejected " + spawn)
		_check(game.session == live and game.world_host.current_location == room and game.dialogue._session == live and SaveCodec.snapshot(live) == before and game.player_placeholder.global_position == foot, "unsafe restore preserves all new/old state " + spawn)
	_write(game.save_repository.path,"broken")
	_check((await game.load_run()).is_empty() and "Recovered backup" in game.ui.save_status.text, "backup recovers complete NPC state")
	_check(SaveCodec.snapshot(game.session) == SaveCodec.snapshot(run) and FileAccess.get_file_as_string(game.save_repository.path) == "broken", "backup exact/restoration read-only")
	_check(raw == FileAccess.get_file_as_string(game.save_repository.path + ".bak"), "backup bytes preserved")
	game._set_paused(false); game.queue_free(); await process_frame

func _write(path: String, bytes: String) -> void:
	var file: FileAccess = FileAccess.open(path,FileAccess.WRITE)
	_check(file != null,"fixture IO")
	if file != null: file.store_string(bytes); file.close()
func _reject(data: Dictionary, label: String) -> void:
	# Pure production boundary takes already validated immutable content. Outer
	# envelope/disk/root integration is checked separately; do not re-read 66 PNGs
	# for every deliberately malformed inner field.
	var result: NpcSaveData.Result = NpcSaveData.restore(data.conversations,npcs,float(data.elapsed_play_seconds))
	_check(result.state == null and not result.errors.is_empty(),"reject " + label); rejected.append(label)
func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)
func _finish() -> void:
	_check(TestRunEvidence.write_json("npc-save.json",{"assertions":assertions,"rejections":rejected,"failures":failures,"proof":"synthetic rules / production root restore"}),"report")
	for error: String in failures: push_error(error)
	print("N004 save: ", "PASS" if failures.is_empty() else "FAILED", " assertions=",assertions," rejections=",rejected.size())
	quit(0 if failures.is_empty() else 1)
