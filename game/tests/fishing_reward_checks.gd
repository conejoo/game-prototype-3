extends "res://tests/support/fishing_root_fixture.gd"

func _exercise() -> void:
	suite = "reward"
	for id: String in FISH:
		var baseline: Dictionary = SaveCodec.snapshot(game.session)
		var revision: int = game.session.inventory.revision()
		_cast(id)
		var landed: Dictionary = _land()
		var after: Dictionary = SaveCodec.snapshot(game.session)
		var expected: Dictionary = baseline.duplicate(true)
		expected.inventory.item_counts[id] = int(baseline.inventory.item_counts.get(id,0))+1
		_check(TestRunSnapshot.exact_json(after) == TestRunSnapshot.exact_json(expected),"only +1 fish changed across exact full facts " + id)
		_check(game.session.inventory.revision() == revision+1,"one inventory command " + id)
		var replay: FishingChallengeController.Resolution = FishingChallengeController.Resolution.new()
		replay.attempt_token = landed.token
		replay.outcome = "landed"
		replay.fish_item_id = id
		replay.reward_eligible = true
		var stable: String = _facts()
		_check(not game.fishing.complete(replay,game.session,game.world_host.current_location,game.catalog).accepted and _facts() == stable,"fabricated/replayed result inert " + id)
		_check(not game.fishing.advance(60,game.session,game.world_host.current_location,game.catalog).accepted and _facts() == stable,"terminal cannot repeat reward")
	_cast()
	var stable: String = _facts()
	var bogus: FishingChallengeController.Resolution = FishingChallengeController.Resolution.new()
	bogus.attempt_token = game.fishing.snapshot().token
	bogus.outcome = "landed"
	bogus.fish_item_id = "item-bluegill"
	bogus.reward_eligible = true
	for malformed: FishingChallengeController.Resolution in [null,bogus]:
		_check(not game.fishing.complete(malformed,game.session,game.world_host.current_location,game.catalog).accepted and _facts() == stable and game.fishing.active(),"unverified/malformed active result cannot commit")
	game.fishing._committing = true # Isolated reentrant guard fixture; no callback API exists.
	_check(not game.fishing.complete(bogus,game.session,game.world_host.current_location,game.catalog).accepted and _facts() == stable,"reentrant result rejected")
	game.fishing._committing = false
	game._cancel_fishing("fixture reset")
	_capacity()
	await _landing_revalidation()

func _capacity() -> void:
	var inv: InventoryState = game.session.inventory
	inv.add("item-bluegill",99-inv.count("item-bluegill"))
	var stable: String = _facts()
	_cast_capacity("item-bluegill")
	_check(game.fishing.mode() == "targeting" and game._fishing_feedback.contains("full") and _facts() == stable,"selected species at cap rejected before wait")
	game._cancel_fishing("fixture reset")
	inv.consume("item-bluegill",inv.count("item-bluegill"))
	inv.consume("item-river-trout",inv.count("item-river-trout"))
	inv.consume("item-golden-carp",inv.count("item-golden-carp"))
	for index: int in range(19): inv.add("fs005-capacity-%02d" % index)
	stable = _facts()
	_cast_capacity("item-bluegill")
	_check(game.fishing.mode() == "targeting" and _facts() == stable,"full bag rejects new selected fish atomically")
	game._cancel_fishing("fixture reset")
	inv.consume("fs005-capacity-18")
	inv.add("item-bluegill",98)
	_check(inv.snapshot().item_counts.size() == 20,"full twenty-type bag fixture")
	_cast()
	_land()
	_check(inv.count("item-bluegill") == 99 and inv.snapshot().item_counts.size() == 20,"full bag allows existing stack to cap")
	for index: int in range(18): inv.consume("fs005-capacity-%02d" % index)
	inv.consume("item-bluegill",99)
	_cast()
	inv.add("item-bluegill",99) # Capacity disappears during legal fight.
	stable = _facts()
	_finish_trajectory()
	_check(game.fishing.mode() == "idle" and game._fishing_feedback.contains("full") and _facts() == stable,"landing capacity loss terminal without reward")
	_check(not game.fishing.snapshot().rewarded,"capacity failure cannot publish success")
	inv.consume("item-bluegill",99)

func _cast_capacity(id: String) -> void:
	_pose(Vector3(-7,0,18))
	var target: Vector3 = Vector3(-4.75,.015,20.25)
	game._fishing_rng.seed = _seed(id,target)
	_key(KEY_F)
	_click(game.camera_rig.camera.unproject_position(target))

func _finish_trajectory() -> void:
	game._tick_fishing(game.fishing.snapshot().wait_seconds)
	_key(KEY_E,true)
	for step: int in range(1500):
		if not game.fishing.active(): break
		var state: Dictionary = game.fishing.snapshot()
		if state.tension <= .48 and not game._e_down: _key(KEY_E,true)
		elif state.tension >= .52 and game._e_down: _key(KEY_E,false)
		game._tick_fishing(.005)
	_key(KEY_E,false)

func _landing_revalidation() -> void:
	# Pause private terminal dispatch only in isolated fixture, then change each
	# binding before calling the exact verified result. No runtime forcing command.
	for changed: String in ["session","map","rod","capability","capacity","inventory"]:
		_cast()
		var service: FishingSessionService = game.fishing
		var ctrl: FishingChallengeController = service._controller
		ctrl.update(ctrl.snapshot().wait_seconds,false,service._generation,ctrl.snapshot().attempt_token)
		var generation: int = service._generation+1
		ctrl.update(0,true,generation,ctrl.snapshot().attempt_token)
		var held: bool = true
		var resolution: FishingChallengeController.Resolution
		for step: int in range(1500):
			var state: FishingChallengeController.Snapshot = ctrl.snapshot()
			var next: bool = state.tension <= .48 or (held and state.tension < .52)
			if next and not held: generation += 1
			held = next
			var update: FishingChallengeController.CommandResult = ctrl.update(.005,held,generation,state.attempt_token)
			if update.resolution != null:
				resolution = update.resolution
				break
		_check(resolution != null and resolution.outcome == "landed","actual controller verified landing fixture " + changed)
		service._pending = resolution
		var current_session: GameSession = game.session
		var current_room: PrototypeLocation = game.world_host.current_location
		var original_inventory: InventoryState = game.session.inventory
		var rod: RodActivationDefinition = game.catalog.get_item(ForagingRegistry.ROD_ITEM).rod_activation
		if changed == "session": current_session = SocialSaveFixture.complete().session
		elif changed == "map": current_room = PrototypeLocation.new()
		elif changed == "rod": game.session.inventory.select(null)
		elif changed == "capability": rod.action = "invalid"
		elif changed == "capacity": game.session.inventory.add("item-bluegill",99)
		elif changed == "inventory": game.session.inventory = original_inventory.detached_copy()
		var stable: String = _facts()
		var result: FishingSessionService.Result = service.complete(resolution,current_session,current_room,game.catalog)
		_check(result.accepted and not result.rewarded and result.outcome in ["stale_reward","capacity"] and _facts() == stable,"commit revalidates " + changed)
		_check(not service.complete(resolution,game.session,game.world_host.current_location,game.catalog).accepted and _facts() == stable,"exact actual result replay rejected " + changed)
		if changed == "map": current_room.free()
		rod.action = "castFishingLine"
		game.session.inventory = original_inventory
		if changed == "capacity": game.session.inventory.consume("item-bluegill",99)
		game.session.inventory.select(ForagingRegistry.ROD_ITEM)
		game._update_controls()
