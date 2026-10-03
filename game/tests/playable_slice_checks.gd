extends SceneTree
## Presentation/lifecycle checks only; full normal-input slice is tested windowed.

var failures: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	_check(not game.has_node("LivePlaytestBridge"), "Normal startup enabled developer bridge")
	_check(game.session.completed_effect_ids.is_empty() and game.session.relationship.reaction_ids.is_empty(), "Normal startup contains setup progress")
	_check(game.player_placeholder.combat.damage == 25 and game.session.party_member_ids.size() == 2, "Normal party/damage defaults changed")
	_check("companion choice" in game.ui.objective_label.text, "Optional reaction not discoverable")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	_check(game.session.completed_effect_ids.is_empty() and not is_instance_valid(game.guardian), "Early travel supplied quest setup")
	_check("travel to Alderwake" in game.ui.objective_label.text, "Wrong-room lead objective strands player")
	game.world_host.request_transition("prototype-alderwake", "alderwake-from-tollworks")
	await game.world_host.transition_finished
	# Explicit rule fixture verifies hints update from their authoritative services.
	game.quests.apply("prototype-maris-recovery", "maris-accept-lead", "prototype-alderwake", "npc-03-counter")
	_check("spend preparation point" in game.ui.objective_label.text, "Earned upgrade not discoverable")
	game.relationships.apply("prototype-shared-plan")
	game._toggle_journal()
	game._select_upgrade()
	_check("Preparation complete" in game.ui.upgrade_status.text or "selected" in game.ui.upgrade_status.text, "Selected upgrade hint misleading")
	game._toggle_journal()
	_check("companion choice" not in game.ui.objective_label.text and "spend preparation point" not in game.ui.objective_label.text, "Optional hints remain after completion")
	game._set_paused(true)
	_check("No autosave" in game.ui.save_status.text and not game.ui.save_button.disabled, "Stable pause save guidance incorrect")
	game._set_paused(false)
	for enabled: bool in [false, true, false]:
		game.world_host.developer_fixtures = enabled
		for location: String in ["prototype-tollworks", "prototype-alderwake"]:
			var spawn: String = "tollworks-from-alderwake" if location == "prototype-tollworks" else "alderwake-from-tollworks"
			_check(game.world_host.request_transition(location, spawn).is_empty(), "Fixture mode transition rejected")
			await game.world_host.transition_finished
			var room: PrototypeLocation = game.world_host.current_location
			_check(room.has_node("PracticeMarker") == enabled and room.has_node("TestBeacon") == enabled, "Developer props leak or disappear in wrong mode")
			_check(room.has_node("TemporaryCompanion") and room.has_node("TravelGate"), "Playable interactions removed")
			_check(room.navigation_region != null and game.party.members().size() == 2, "Fixture mode broke navigation/party")
			_check("Recovery slice" in game.ui.location_label.text, "Stale development-stage HUD")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P013 checks: PASS — fresh normal run, optional guidance, explicit save boundary, developer isolation/repeated travel, party/navigation; synthetic rules only")
	quit(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
