extends "res://tests/support/fishing_root_fixture.gd"

func _exercise() -> void:
	suite = "lifecycle"
	for phase: String in ["waiting","bite","fighting"]:
		for reason: String in ["F","right_click","Esc","pause_command","focus","modal","dialogue","retry","rod","capability","combat","ally_combat","damage","death","session"]:
			_phase(phase)
			var stable: String = _facts()
			var owner: GameSession = game.session
			var rod: RodActivationDefinition = game.catalog.get_item(ForagingRegistry.ROD_ITEM).rod_activation
			var expected: String = stable
			match reason:
				"F": _key(KEY_F)
				"right_click": _click(Vector2(500,360),MOUSE_BUTTON_RIGHT)
				"Esc": _key(KEY_ESCAPE)
				"pause_command": game._set_paused(true)
				"focus": game._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
				"modal":
					game.journal_open = true # External modal transition must cancel, too.
					game._update_controls()
				"dialogue": game._present_dialogue(game.dialogue.begin("npc-01","fs005-synthetic-contact"))
				"retry": game.retry_encounter()
				"rod":
					game.session.inventory.select(null)
					expected = _facts()
					game._tick_fishing(0)
				"capability":
					rod.action = "invalid"
					game._tick_fishing(0)
				"combat":
					game.player_placeholder.request_attack()
					game._tick_fishing(0)
				"ally_combat":
					game.companion.request_attack()
					game._tick_fishing(0)
				"damage":
					game.player_placeholder.receive_damage(1)
					expected = _facts()
					game._tick_fishing(0)
				"death":
					game.player_placeholder.receive_damage(game.player_placeholder.state.health)
					expected = _facts()
				"session":
					game.session = SaveCodec.decode(stable,game.catalog).session
					game._tick_fishing(0)
			_check(game.fishing.mode() == "idle" and not game.fishing.active() and not game.fishing_preview.visible,"cancel " + phase + "/" + reason)
			if reason not in ["dialogue","session"]: _check(_facts() == expected,"no fish/facts changed " + phase + "/" + reason)
			else: _check(game.session.inventory.count("item-bluegill") == 0,"no modal/session reward " + phase + "/" + reason)
			if reason in ["Esc","pause_command"]: _check(paused and game.ui.pause_overlay.visible,"verified pause overlay " + phase + "/" + reason)
			_check(not game.fishing.advance(60,game.session,game.world_host.current_location,game.catalog).accepted,"stale tick after cancel " + phase + "/" + reason)
			rows.append({"phase":phase,"cancel":reason,"mode":game.fishing.mode(),"pause_verified":paused and game.ui.pause_overlay.visible})
			rod.action = "castFishingLine"
			game.session = owner
			game.window_focused = true
			game.journal_open = false
			game.ui.show_journal(false,"")
			game._cancel_dialogue()
			game.player_placeholder.state.health = game.player_placeholder.state.max_health
			game.player_placeholder.combat.cancel()
			game.player_placeholder.combat.hit_flash = 0
			game.companion.combat.cancel()
			if paused: game._set_paused(false)
			_key(KEY_E,false)
			game._update_controls()
		await _rollback_and_save(phase)
	await _travel()
	_fresh_input()
	var service: FishingSessionService = game.fishing
	_phase("fighting")
	var inventory: InventoryState = game.session.inventory
	var prior: Dictionary = inventory.snapshot().to_dictionary()
	game._exit_tree() # Synchronous root teardown owner hook, actual free follows base.
	_check(service.mode() == "idle" and not service.advance(60,game.session,game.world_host.current_location,game.catalog).accepted and inventory.snapshot().to_dictionary() == prior,"root teardown invalidates stale owner")

func _rollback_and_save(phase: String) -> void:
	_phase(phase)
	var old_room: PrototypeLocation = game.world_host.current_location
	var owner: GameSession = game.session
	var stable: String = _facts()
	var errors: PackedStringArray = game.world_host.request_transition("prototype-unsafe-location","unsafe-no-floor")
	_check(errors.is_empty(),"unsafe staged transition request: " + str(errors))
	if not errors.is_empty(): return
	var arrival: Array = await game.world_host.transition_finished
	_check(not arrival[0] and game.world_host.current_location == old_room and game.session == owner and _facts() == stable,"failed physical transition rollback retains exact session/room " + phase)
	_check(game.fishing.mode() == "idle" and not game.fishing_preview.visible,"failed rollback cannot resurrect attempt " + phase)
	_key(KEY_E,false)
	game._set_paused(true)
	_check(game.save_run().is_empty(),"manual save after canceled " + phase)
	var saved: String = _facts()
	_check(not saved.contains("attempt_token") and not saved.contains("tension") and not SaveCodec.snapshot(game.session).has("fishing"),"no transient fields in save " + phase)
	_check((await game.load_run()).is_empty() and _facts() == saved,"exact manual restore " + phase)
	_check(game.fishing.mode() == "idle" and not game.fishing.active() and not game.fishing_preview.visible,"load never resurrects canceled " + phase)
	game._set_paused(false)
	game.player_placeholder.set_physics_process(false)
	_cast()
	_check(not (await game.load_run()).is_empty() and game.fishing.mode() == "idle" and not game.loading_save,"active load request cancels and blocks load")
	_key(KEY_E,false)

func _travel() -> void:
	_phase("fighting")
	var inventory: Dictionary = game.session.inventory.snapshot().to_dictionary()
	_check(game.world_host.request_transition("prototype-test-room","prototype-start").is_empty(),"actual room replacement request")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0] and game.fishing.mode() == "idle" and game.session.inventory.snapshot().to_dictionary() == inventory,"actual replacement cancels without reward")
	_key(KEY_E,false)
	_key(KEY_F)
	_check(game.fishing.mode() == "idle","indoor F rejected")
	_check(game.world_host.request_transition("prototype-alderwake","alderwake-start").is_empty(),"return request")
	arrival = await game.world_host.transition_finished
	_check(arrival[0],"return completed")

func _fresh_input() -> void:
	_cast()
	game._tick_fishing(game.fishing.snapshot().wait_seconds)
	_key(KEY_E,true)
	game.set_fishing_reel("pointer",true)
	_key(KEY_F)
	_check(game._e_consumed and not game.interact().ok,"held E gated after cancellation")
	# Recast while keyboard still held: it cannot hook at bite automatically.
	_pose(Vector3(-7,0,18))
	_key(KEY_F)
	game._fishing_rng.seed = _seed("item-bluegill",Vector3(-4.75,.015,20.25))
	_click(game.camera_rig.camera.unproject_position(Vector3(-4.75,.015,20.25)))
	_check(game.fishing.active(),"recast starts while old keyboard remains held")
	game._tick_fishing(game.fishing.snapshot().wait_seconds)
	_check(game.fishing.snapshot().phase == "bite","held-at-cast cannot auto hook")
	game.set_fishing_reel("pointer",true)
	_check(game.fishing.snapshot().phase == "bite","old pointer held gate cannot hook")
	game.set_fishing_reel("pointer",false)
	_key(KEY_E,false)
	_key(KEY_E,true)
	_check(game.fishing.snapshot().phase == "fighting","observed release/fresh press hooks recast")
	_key(KEY_ESCAPE)
	_check(paused and game.ui.pause_overlay.visible and game.player_placeholder.movement_buttons.is_empty(),"Esc clears all held controls")
	game._set_paused(false)
	_key(KEY_W,true,true)
	_check(game.player_placeholder.movement_buttons.is_empty(),"held movement echo cannot resume after exit")
	_key(KEY_W,false)
	_key(KEY_W,true)
	_check(game.player_placeholder.movement_buttons.has("move_forward"),"fresh movement works after exit")
	_key(KEY_W,false)
	_key(KEY_E,false)
