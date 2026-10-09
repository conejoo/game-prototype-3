extends "res://tests/npc_integration_render.gd"
## G008 ordinary viewport input. No position, item, fact, quest or timer setup.
var invariants: Dictionary = {}
var resumed_changes: Dictionary = {}

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--phase="): phase = arg.trim_prefix("--phase=")
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "fresh production startup")
	if startup[0]:
		if phase == "read": await _read_social()
		else: await _write_social()
	_check(TestRunEvidence.write_json(phase+"-social-integration.json", {"task":"G008", "phase":phase, "pid":OS.get_process_id(), "assertions":assertions+1, "failures":failures, "views":captures, "traces":traces, "combat":combat_traces, "nodes":visited, "choices":chosen, "resumed_changes":resumed_changes, "snapshot":SaveCodec.snapshot(game.session), "proof":"ordinary viewport WASD/E/mouse/Tab/Enter/F10; no progress or physical setup"}), "evidence write")
	for failure: String in failures: push_error(failure)
	print("G008 social_integration_render ", phase, " ", "PASS" if failures.is_empty() else "FAIL", " assertions=", assertions, " captures=", captures.size())
	if failures.is_empty():
		_key(KEY_F10,true); _key(KEY_F10,false) # Production normal quit, preserving paused save.
	else:
		paused = false
		game.queue_free(); await process_frame
		quit(1)

func _write_social() -> void:
	await _pause(); await _capture("fresh",true); await _resume()
	if not await _walk(NpcRegistry.find("npc-01").approach,"edric-introduction"): return
	if not await _open_person("npc-01","intro-npc-01"): return
	if not await _choose(game.dialogue.snapshot().choices[1 if phase == "neutral" else 0].id,"edric-intro-accepted"): return
	_close()
	for index: int in [1,2]:
		if not await _gather(index): return
		if not await _walk(NpcRegistry.find("npc-01").approach,"edric-gift-"+str(index)): return
		if not await _gift_entry("npc-01"): return
		if not await _gift("npc-01",index): return
		await _people("edric-after-"+str(index),"npc-01",1)
	_check(game.session.conversations.memory("npc-01").affinity == (2 if phase == "neutral" else 3), "two gifts plus exclusive introduction")
	_check(game.session.conversations.memory("npc-01").seen_node_ids.count("npc-01-level-1-milestone") == (0 if phase == "neutral" else 1), "exact milestone entry count")
	if phase == "neutral":
		_check("relationshipLevel1Seen" not in game.session.conversations.memory("npc-01").flags, "neutral no milestone flag")
		await _pause(); await _capture("neutral-complete",true); return
	# Meet other seven, visit every enabled public fact branch without gifting.
	for id: String in TOUR:
		if id == "npc-01": continue
		if not await _walk(NpcRegistry.find(id).approach,"meet-"+id): return
		if not await _open_person(id,"intro-"+id): return
		if not await _choose(game.dialogue.snapshot().choices[0].id,"intro-accepted-"+id): return
		_close()
		if not await _public_social(id): return
	for id: String in TOUR:
		_check(game.session.conversations.memory(id).learned_fact_ids.size() == (1 if id == "npc-01" else 2 if id == "npc-02" else 3), "all21 public facts accessible " + id)
	await _people("all-eight-met","npc-03",8)
	if not await _gather(3): return
	if not await _walk(NpcRegistry.find("npc-03").approach,"maris-third-flower"): return
	if not await _gift_entry("npc-03"): return
	if not await _gift("npc-03",1): return
	_check(game.session.inventory.count("item-moonflower") == 0 and SaveCodec.snapshot(game.session).collected_resource_ids.size() == 3, "three finite flowers conserved")
	await _people("maris-gift","npc-03",8)
	invariants = _social_invariants()
	# Recovery route includes normal lead, preparation, gates, combat, vessel, fitting.
	if not await _recovery_route(): return
	_check(_social_invariants() == invariants, "full recovery/travel/combat preserves gifts/items/people")
	_check(game.session.progression.upgrade_ids.size() == 1, "ordinary preparation retained")
	await _people("recovery-complete","npc-01",8)
	await _pause()
	var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","GUI Save"))
	var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
	_check(disk.session != null and SaveCodec.snapshot(disk.session) == SaveCodec.snapshot(game.session), "GUI save typed whole-state equality")
	var file: FileAccess = FileAccess.open(game.save_repository.path+".g008-oracle",FileAccess.WRITE)
	_check(file != null,"writer oracle")
	if file != null: file.store_var(TestRunSnapshot.oracle(game.session)); file.close()
	await _capture("save-confirmed",true)

func _gather(index: int) -> bool:
	var id: String = "moonflower-%02d" % index
	var foot: Vector3 = ForagingRegistry.find(id).foot
	if not await _walk(Vector3(27.5,.25,-2) if index == 1 else foot+Vector3(-.5,0,0),"gather-"+id): return false
	game._refresh_interaction()
	_check(game.selected_interaction != null and game.selected_interaction.instance_id == id, "physical finite flower selected " + id)
	if game.selected_interaction == null or game.selected_interaction.instance_id != id: return false
	_key(KEY_E,true); await create_timer(.8).timeout; _key(KEY_E,false)
	_check(game.session.foraging.is_collected(id) and game.session.inventory.count("item-moonflower") == 1,"ordinary gathered owned unit " + id)
	return failures.is_empty()

func _gift_entry(id: String) -> bool:
	for attempt: int in range(5):
		if not await _open_person(id,"gift-entry-"+id+"-"+str(attempt)): return false
		for row: Dictionary in game.dialogue.snapshot().choices:
			if not game.npc_catalog.get_npc(id).graph.choices[row.id].gift_rule_id.is_empty(): return true
		_close()
	_check(false,"ordinary gift entry unavailable " + id)
	return false

func _gift(id: String, count: int) -> bool:
	var old: Dictionary = game.dialogue.snapshot()
	var choice_id: String = ""
	for row: Dictionary in old.choices:
		if not game.npc_catalog.get_npc(id).graph.choices[row.id].gift_rule_id.is_empty(): choice_id = row.id; break
	if not await _choose(choice_id,"gift-accepted-"+id+"-"+str(count)): return false
	_check(game.session.inventory.count("item-moonflower") == 0, "exactly one owned unit consumed")
	_check(game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower",id) == count,"only deliberate gift count " + id)
	var before: Dictionary = game.session.conversations.snapshot()
	_check(not game._choose_dialogue(choice_id,old).ok and game.session.conversations.snapshot() == before, "stale UI command inert")
	_close()
	return failures.is_empty()

func _public_social(id: String) -> bool:
	# Gather-priority hint may precede the ordinary return menu for Helena.
	for attempt: int in range(3):
		if not await _open_person(id,"public-"+id+"-"+str(attempt)): return false
		if not String(game.dialogue.snapshot().node_id).ends_with("moonflower-hint"): break
		_close()
	var choices: Array = game.dialogue.snapshot().choices.duplicate(true)
	for row: Dictionary in choices:
		var choice: NpcDialogueGraph.Choice = game.npc_catalog.get_npc(id).graph.choices[row.id]
		if not choice.gift_rule_id.is_empty(): continue
		if row.available:
			if not await _choose(row.id,"public-fact-"+row.id): return false
			_close()
			if not await _open_person(id,"public-reopen-"+row.id): return false
	_close()
	return failures.is_empty()

func _people(label: String, id: String, expected: int) -> void:
	var before: Dictionary = _social_invariants()
	for frame: int in range(4): await process_frame # Settle root HUD after dialogue removal.
	await _click(game.ui.people_button.get_global_rect().get_center())
	print("G008_PEOPLE ",label," open=",game.journal_open," controls=",game.player_placeholder.controls_enabled," button=",game.ui.people_button.get_global_rect()," focus=",root.gui_get_focus_owner())
	_check(game.journal_open and game.ui.people_view.rows.size() == expected, "ordinary met-only People " + label)
	if not await _select_person(id): return
	_check(game.ui.people_view.selected_id == id,"ordinary People selection " + id)
	var person: Dictionary = PeopleSnapshot.person(game.session.conversations,game.npc_catalog,id)
	_check(game.ui.people_view.relationship.text.contains("%d / 3" % person.affinity), "People accurate progress")
	for fact: Dictionary in person.facts: _check(game.ui.people_view.facts.text.contains(fact.description), "People learned description " + fact.id)
	var capture: Dictionary = await TestRunInteractionCapture.journal(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input","G008 ordinary gathered-item gifts, met-only People via HUD/mouse; no synthetic setup")
	_check(capture.ok,capture.get("error","journal capture"))
	if capture.ok: captures.append(capture)
	if label == "all-eight-met":
		# Actual Tab/Enter reaches every ordinary learned entry, including scroll.
		for row: Button in game.ui.people_view.rows:
			if not await _select_person(String(row.name)): return
			var selected: Dictionary = PeopleSnapshot.person(game.session.conversations,game.npc_catalog,String(row.name))
			for fact: Dictionary in selected.facts:
				_check(game.ui.people_view.facts.text.contains(fact.description),"ordinary all-eight learned entry " + fact.id)
			capture = await TestRunInteractionCapture.journal(game,phase+"-people-entry-"+String(row.name),TestRunEvidence.directory(),"debug-input","G008 ordinary meetings/public fact branches; HUD and contained Tab/Enter reach every People row, including list scroll")
			_check(capture.ok,capture.get("error","all-eight journal capture"))
			if capture.ok: captures.append(capture)
	_key(KEY_W,true); _key(KEY_W,false); _key(KEY_E,true); _key(KEY_E,false)
	_check(game.player_placeholder.movement_buttons.is_empty() and game.journal_open and not game.dialogue.active(), "People blocks held world input")
	_close()
	_check(_social_invariants() == before,"People opening/selection/reopening inert")

func _select_person(id: String) -> bool:
	var button: Button
	for row: Button in game.ui.people_view.rows:
		if String(row.name) == id: button = row; break
	_check(button != null,"met person row exists " + id)
	if button == null: return false
	for step: int in range(16):
		if root.gui_get_focus_owner() == button: break
		_key(KEY_TAB,true); _key(KEY_TAB,false); await process_frame
	_check(root.gui_get_focus_owner() == button,"ordinary Tab reaches People " + id)
	if root.gui_get_focus_owner() != button: return false
	for frame: int in range(4): await process_frame
	_check(game.ui.people_view.list_scroll.get_global_rect().encloses(button.get_global_rect()),"focused People row scrolls into view " + id)
	_key(KEY_ENTER,true); _key(KEY_ENTER,false); await process_frame
	_check(game.ui.people_view.selected_id == id,"ordinary Enter selects People " + id)
	return failures.is_empty()

func _social_invariants() -> Dictionary:
	var snap: Dictionary = SaveCodec.snapshot(game.session)
	return {"people":snap.conversations.people, "gift01":game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-01"), "gift03":game.session.conversations.events().count(NpcEventMemory.GIFT,"moonflower","npc-03"), "inventory":snap.inventory, "collected":snap.collected_resource_ids, "placements":snap.world_item_placements}

func _read_social() -> void:
	await _pause(); await _capture("fresh-reader",true)
	_check(game.session.conversations.events().snapshot().last_sequence == 0 and game.session.inventory.count("item-moonflower") == 0, "new-process defaults before GUI Load")
	var file: FileAccess = FileAccess.open(game.save_repository.path+".g008-oracle",FileAccess.READ)
	_check(file != null,"writer oracle exists")
	if file == null: return
	var oracle: Dictionary = file.get_var(false); file.close()
	var loaded: Dictionary = await TestRunGui.activate(game,game.ui.load_button,func() -> bool: return game.ui.save_status.text.begins_with("Loaded") and not game.loading_save)
	_check(loaded.ok,loaded.get("error","GUI Load"))
	var disk: SaveRepository.ReadResult = game.save_repository.read(game.catalog)
	var errors: PackedStringArray = TestRunSnapshot.compare_restored(game.session,oracle,disk.session)
	_check(errors.is_empty(),"different process exact social/inventory/old state and forecast: "+str(errors))
	var raw: String = FileAccess.get_file_as_string(game.save_repository.path)
	var saved: Dictionary = await TestRunGui.activate(game,game.ui.save_button,func() -> bool: return game.ui.save_status.text.begins_with("Saved."))
	_check(saved.ok,saved.get("error","paused GUI re-save"))
	_check(FileAccess.get_file_as_string(game.save_repository.path) == raw and TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == oracle.snapshot_json, "paused re-save exact durable bytes/state")
	await _capture("load-resave-exact",true)
	invariants = _social_invariants()
	await _resume()
	await _people("loaded-people","npc-01",8)
	for id: String in TOUR:
		if not await _walk(NpcRegistry.find(id).approach,"physical-loaded-revisit-"+id): return
		# Maris source chat is behind the restored specialist route.
		if not await _open_person(id,"loaded-"+id): return
		_close()
	_check(_social_invariants() == invariants,"physical revisits keep all gifts/facts/milestone/items")
	_check(game.session.completed_effect_ids.size() == 6 and game.party.members().size() == 2,"old recovery and party retained")
	_check(game.session.elapsed_play_seconds > disk.session.elapsed_play_seconds,"walking legitimately advances session/environment time")
	var restored: Dictionary = SaveCodec.snapshot(disk.session)
	var walked: Dictionary = SaveCodec.snapshot(game.session)
	for field: String in ["quests","completed_effect_ids","relationship","progression","party_member_ids","actors","light_source_overrides","location_id","spawn_id","schema_version","content_version"]:
		_check(walked[field] == restored[field],"walking preserves old durable field " + field)
	resumed_changes = {"saved_seconds":disk.session.elapsed_play_seconds,"walked_seconds":game.session.elapsed_play_seconds,"saved_weather":TestRunSnapshot.weather(disk.session.environment),"walked_weather":TestRunSnapshot.weather(game.session.environment),"saved_events":disk.session.conversations.events().snapshot(),"walked_events":game.session.conversations.events().snapshot()}
	await _people("loaded-all-eight","npc-03",8)
	await _pause(); await _capture("restart-complete",true)

func _dialogue_capture(label: String) -> void:
	var result: Dictionary = await TestRunInteractionCapture.dialogue(game,phase+"-%03d-" % captures.size()+label,TestRunEvidence.directory(),"debug-input","G008 ordinary production WASD/E/GUI at selected contact; authored source branch, no setup")
	_check(result.ok,result.get("error","dialogue capture"))
	if result.ok: captures.append(result)

func _capture(label: String, overlay: bool = false) -> void:
	var result: Dictionary = await TestRunCapture.capture(game,phase+"-"+label,TestRunEvidence.directory(),"debug-input",overlay,"G008 ordinary production WASD/E/GUI; verified pause checkpoint, no state setup")
	_check(result.ok,result.get("error","pause capture"))
	if result.ok: captures.append(result)
