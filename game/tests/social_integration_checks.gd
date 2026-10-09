extends SceneTree
const SocialFixture = preload("res://tests/social_fixture.gd")
## G008 synthetic independent recipients; production services, projection and codec.
var failures: PackedStringArray = []
var assertions: int = 0

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for positive: bool in [true, false]:
		var pair: Dictionary = SocialSaveFixture.setup()
		for id: String in NpcContentCatalog.ROSTER:
			SocialSaveFixture.introduce(pair, id, positive)
			SocialSaveFixture.preference(pair, id)
			pair.session.inventory.add("item-moonflower", 3) # Explicit synthetic per-recipient supply.
			var others: Dictionary = pair.session.conversations.snapshot().people
			for count: int in [1, 2]:
				SocialSaveFixture.gift(pair, id)
				var row: Dictionary = PeopleSnapshot.person(pair.session.conversations, pair.catalog, id)
				_check(row.affinity == count + int(positive), "fresh projection matches accepted gift " + id)
				_check(row.level == int(positive and count == 2), "all-eight positive/neutral level derivation " + id)
				_check(pair.session.conversations.events().count(NpcEventMemory.GIFT, "moonflower", id) == count, "one event per accepted gift " + id)
				for other: String in NpcContentCatalog.ROSTER:
					if other != id: _check(pair.session.conversations.memory(other).snapshot(3) == others[other], "independent mixed-roster memory " + id + "/" + other)
			pair.service.cancel()
			_check(pair.service.begin(id, "g008-cap-" + id).ok, "cap reopen " + id)
			var before: Dictionary = SaveCodec.snapshot(pair.session)
			var view: Dictionary = pair.service.snapshot()
			for choice: Dictionary in view.choices:
				if not pair.catalog.get_npc(id).graph.choices[choice.id].gift_rule_id.is_empty():
					_check(not choice.available and choice.reason == "Gift acceptance cap reached.", "shared cap exposed " + id)
					_check(not SocialFixture.choose(pair.service, view, choice.id).ok, "cap command rejected " + id)
			_check(SaveCodec.snapshot(pair.session) == before, "rejected gift preserves whole state " + id)
			pair.service.cancel()
		var before: Dictionary = SaveCodec.snapshot(pair.session)
		var people: Dictionary = PeopleSnapshot.from_state(pair.session.conversations, pair.catalog)
		_check(people.people.size() == 8, "all-eight met projection")
		people.people[0].facts.clear()
		_check(SaveCodec.snapshot(pair.session) == before, "projection caller edits inert")
		var decoded: SaveCodec.DecodeResult = SaveCodec.validate(before, pair.actors)
		_check(decoded.session != null, "whole mixed-roster save validates")
		if decoded.session != null:
			_check(SaveCodec.snapshot(decoded.session) == before, "exact mixed-roster restore")
			_check(PeopleSnapshot.from_state(decoded.session.conversations, pair.catalog) == PeopleSnapshot.from_state(pair.session.conversations, pair.catalog), "People restores exact independent facts/levels")
	await _root_lifecycle()
	_check(TestRunEvidence.write_json("social-integration-checks.json", {"task":"G008", "proof":"synthetic inventory/events/damage/focus; production all-eight services/projection/codec/root retry", "assertions":assertions+1, "failures":failures}), "report")
	for failure: String in failures: push_error(failure)
	print("G008 social_integration_checks ", "PASS" if failures.is_empty() else "FAIL", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _root_lifecycle() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	_check((await game.world_host.transition_finished)[0], "root lifecycle arrival")
	game.set_process(false) # Synthetic exact state, no claim of ordinary elapsed time.
	var pair: Dictionary = {"catalog":game.npc_catalog,"session":game.session,"service":game.dialogue}
	for id: String in NpcContentCatalog.ROSTER:
		SocialSaveFixture.introduce(pair,id)
		SocialSaveFixture.preference(pair,id)
		game.session.inventory.add("item-moonflower",2)
		SocialSaveFixture.gift(pair,id); SocialSaveFixture.gift(pair,id)
	game._cancel_dialogue()
	var before: Dictionary = SaveCodec.snapshot(game.session)
	game._open_people()
	_check(game.journal_open and game.ui.people_view.rows.size() == 8,"gifted roster root journal")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not game.journal_open and not game.player_placeholder.controls_enabled and game.player_placeholder.movement_buttons.is_empty(),"focus loss closes People and clears controls")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(SaveCodec.snapshot(game.session) == before,"focus preserves gifts and all old state")
	game.player_placeholder.receive_damage(100) # Explicit synthetic death trigger.
	await game.retry_encounter()
	_check(SaveCodec.snapshot(game.session) == before,"gifted all-eight retry exact durable state")
	_check(game.party.members().size() == 2 and game.world_host.current_location.npc_contacts.targets.size() == 8,"retry reconstructs party and contacts once")
	_check(SaveCodec.validate(before,game.catalog).session != null,"lifecycle social save valid")
	game.queue_free(); await process_frame
