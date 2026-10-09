extends "res://tests/support/fishing_root_fixture.gd"
## FS007 explicitly synthetic rich social/quest/environment baseline and encounters.

func _exercise() -> void:
	task = "FS007"
	suite = "integration"
	await _rich_baseline()
	for id: String in FISH:
		var before: Dictionary = SaveCodec.snapshot(game.session)
		_cast(id)
		_land()
		var expected: Dictionary = before.duplicate(true)
		expected.inventory.item_counts[id] = int(before.inventory.item_counts.get(id,0))+1
		_check(TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)) == TestRunSnapshot.exact_json(expected),"rich all-fact baseline changes only +1 " + id)
		_check(game.world_host.current_location.npc_contacts.targets.size() == 8 and game.party.members().size() == 2,"all-eight/two-party wrappers survive " + id)
	await _failed_save()
	for phase: String in ["waiting","bite","fighting"]:
		_phase(phase)
		var before: String = _facts()
		_key(KEY_ESCAPE)
		_check(paused and game.ui.pause_overlay.visible and game.fishing.mode() == "idle" and _facts() == before,"cancel/save checkpoint " + phase)
		_check(game.save_run().is_empty(),"save canceled " + phase)
		_check((await game.load_run()).is_empty() and _facts() == before and game.fishing.mode() == "idle" and not game.fishing_effects.visible,"load canceled " + phase + " preserves rich facts, no attempt/effects")
		game.player_placeholder.set_physics_process(false)
		game.companion.set_physics_process(false)
		game.companion_ai.set_physics_process(false)
		game._set_paused(false)
		_key(KEY_E,false)
		_cast()
		_check(game.fishing.active(),"immediate fresh recast after " + phase)
		game._cancel_fishing("fixture reset")
	rows.append({"proof":"synthetic complete social/quest/environment plus deterministic three species","snapshot":SaveCodec.snapshot(game.session)})

func _rich_baseline() -> void:
	var pair: Dictionary = SocialSaveFixture.complete()
	var run: GameSession = pair.session
	# Shared legal cast fixture starts healthy; normalize this synthetic baseline
	# before recording it so its full-fact oracle includes the actual starting health.
	run.actors[GameSession.PLAYER_INSTANCE_ID].health = run.actors[GameSession.PLAYER_INSTANCE_ID].max_health
	_check(run.foraging.pickup("prototype-tollworks",ForagingRegistry.DROP_ID,ForagingRegistry.ROD_RESOURCE,run.foraging.revision()).accepted,"synthetic legal rich-baseline rod retrieval")
	_check(run.inventory.select(ForagingRegistry.ROD_ITEM).is_empty(),"synthetic rich rod selection")
	run.current_location_id = ForagingRegistry.LOCATION
	run.current_spawn_id = "alderwake-start"
	game.npc_catalog = pair.catalog
	game.save_repository.npc_catalog = pair.catalog
	_check(game.save_repository.write(run,game.catalog).is_empty(),"rich fixture stage")
	game._set_paused(true)
	_check((await game.load_run()).is_empty(),"rich baseline through production load/rebinding")
	_check(_facts() == TestRunSnapshot.exact_json(SaveCodec.snapshot(run)),"rich baseline exact typed restore")
	game._set_paused(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)

func _failed_save() -> void:
	game._set_paused(true)
	_check(game.save_run().is_empty(),"successful rich fish save before failure")
	var path: String = game.save_repository.path
	var primary: String = FileAccess.get_file_as_string(path)
	var backup: String = FileAccess.get_file_as_string(path+".bak")
	var stable: String = _facts()
	_check(DirAccess.make_dir_absolute(path+".tmp") == OK,"owned isolated temporary obstruction")
	_check(not game.save_run().is_empty(),"root save reports real IO failure")
	_check(_facts() == stable and FileAccess.get_file_as_string(path) == primary and FileAccess.get_file_as_string(path+".bak") == backup,"failed write preserves prior slot/backup and every fish/fact")
	_check(game.save_repository.read(game.catalog).session != null,"previous slot still validates after failed write")
	_check(DirAccess.remove_absolute(path+".tmp") == OK,"remove only owned isolated obstruction")
	_check(game.save_run().is_empty() and _facts() == stable,"save retry cannot issue fish reward")
	game._set_paused(false)
