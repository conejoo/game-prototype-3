extends SceneTree
## Synthetic positions/capacity/mode fixtures, actual viewport E + production commands.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var observed: Array[int] = [0]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = game.content_manifest.duplicate() as ContentManifest
	for index: int in range(20):
		var item: ItemDefinition = ItemDefinition.new()
		item.stable_id = "f005-capacity-%02d" % index
		item.display_name = "Synthetic capacity item"
		item.description = "Test-only backpack capacity fixture."
		item.source_item_id = item.stable_id
		item.category = "forage"
		item.stack_limit = 1
		manifest.definitions.append(item)
	game.content_manifest = manifest
	root.add_child(game)
	await game.world_host.transition_finished
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false)
	game.companion_ai.set_physics_process(false)
	var room: PrototypeLocation = game.world_host.current_location
	_check(room.foraging_pickups.targets.size() == 4, "four production pickups")
	for entry: Dictionary in ForagingRegistry.entries():
		var target: PrototypeInteractable = _target(entry.instance_id)
		_check(target.position == entry.foot and target.validation_errors(game.catalog).is_empty(), "typed stable runtime mapping " + entry.instance_id)
		_check(target.find_children("*", "CollisionObject3D", true, false).is_empty(), "pickup must be nonblocking")
	var flower: PrototypeInteractable = _target("moonflower-01")
	await _place(flower)
	_key(KEY_E,true)
	game._tick_foraging_hold(.599)
	_check(game.foraging_hold.active() and game.session.inventory.count("item-moonflower") == 0 and game.ui.gather_progress.visible, "flower not before600ms")
	_key(KEY_E,false)
	_check(not game.foraging_hold.active() and not game.ui.gather_progress.visible and not game.session.foraging.is_collected("moonflower-01"), "release cancels no reward")
	game._refresh_interaction()
	_check(game.foraging_feedback.begins_with("Gather cancelled") and game.ui.foraging_notice.visible and room.foraging_pickups.targets.has("moonflower-01"),"cancel feedback and visual retained")
	game._tick_foraging_hold(1)
	_check(game.session.inventory.count("item-moonflower") == 0, "released timer cannot complete")
	for mode: String in ["pause","dialogue","journal","focus","travel","loading","retry","gui","attack","dodge","dead","settings"]:
		await _place(flower)
		_key(KEY_E,true)
		game._tick_foraging_hold(.2)
		_check(game.foraging_hold.active(), "hold begins before " + mode)
		match mode:
			"pause": game._set_paused(true)
			"dialogue": game.dialogue.begin_graph(game.catalog.get_dialogue("prototype-companion-greeting"),"fixture")
			"journal": game.journal_open = true
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"travel": game.world_host.transitioning = true
			"loading": game.loading_save = true
			"retry": game.retrying = true
			"gui": game.ui.pause_button.grab_focus()
			"attack": game.player_placeholder.combat.attack(Vector3.FORWARD,true)
			"dodge": game.player_placeholder.combat.dodge(Vector3.FORWARD,true)
			"dead": game.player_placeholder.state.health = 0
			"settings":
				game._set_paused(true)
				game.ui.show_settings(true)
		game._tick_foraging_hold(1)
		_check(not game.foraging_hold.active() and game.session.inventory.count("item-moonflower") == 0, "cancel " + mode)
		match mode:
			"pause": game._set_paused(false)
			"dialogue": game._cancel_dialogue()
			"journal": game.journal_open = false
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
			"travel": game.world_host.transitioning = false
			"loading": game.loading_save = false
			"retry": game.retrying = false
			"gui": game.ui.pause_button.release_focus()
			"attack","dodge": game.player_placeholder.combat.cancel()
			"dead": game.player_placeholder.state.health = game.player_placeholder.state.max_health
			"settings":
				game.ui.show_settings(false)
				game._set_paused(false)
		game._update_controls()
		_key(KEY_E,true)
		game._tick_foraging_hold(1)
		_check(not game.foraging_hold.active(), "held press cannot rearm after " + mode)
		_key(KEY_E,false)
	for loss: String in ["range","target","los","removed","moved","action","revision"]:
		flower = _target("moonflower-01")
		await _place(flower)
		_key(KEY_E,true)
		game._tick_foraging_hold(.2)
		_check(game.foraging_hold.active(), "start target loss " + loss)
		var fixture: Node3D
		var foot: Vector3 = flower.position
		var original_id: String = flower.foraging_action.instance_id
		match loss:
			"range": game.player_placeholder.position += Vector3(5,0,0)
			"target":
				var closer: PrototypeInteractable = PrototypeInteractable.new()
				closer.instance_id = "fixture-closer"
				closer.position = game.player_placeholder.position + Vector3(.02,0,0)
				room.add_child(closer)
				fixture = closer
			"los":
				var wall: StaticBody3D = StaticBody3D.new()
				var shape: CollisionShape3D = CollisionShape3D.new()
				var box: BoxShape3D = BoxShape3D.new()
				box.size = Vector3(.25,1.5,.25)
				shape.shape = box
				wall.add_child(shape)
				room.add_child(wall)
				wall.global_position = (flower.global_position + game.player_placeholder.global_position) / 2 + Vector3.UP * .8
				fixture = wall
				await physics_frame
				await physics_frame
			"removed": flower.queue_free()
			"moved": flower.position += Vector3(.1,0,0)
			"action": flower.foraging_action.instance_id = "moonflower-02"
			"revision":
				game.session.inventory.add("f005-capacity-00")
				game.session.inventory.consume("f005-capacity-00")
		game._tick_foraging_hold(1)
		_check(not game.foraging_hold.active() and game.session.inventory.count("item-moonflower") == 0, "loss rejects reward " + loss)
		_key(KEY_E,false)
		if fixture != null: fixture.free()
		if loss == "removed":
			room.foraging_pickups.targets.erase("moonflower-01")
			await process_frame
			room.bind_foraging(game.session)
		else:
			flower.position = foot
			flower.foraging_action.instance_id = original_id
		await physics_frame
	# Real transition/retry entry hooks must cancel synchronously, not only on tick.
	flower = _target("moonflower-01")
	await _place(flower)
	_key(KEY_E,true)
	game._tick_foraging_hold(.2)
	game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
	_check(not game.foraging_hold.active(), "transition start cancels synchronously")
	await game.world_host.transition_finished
	game.world_host.request_transition("prototype-alderwake","alderwake-start")
	await game.world_host.transition_finished
	_key(KEY_E,false)
	room = game.world_host.current_location
	flower = _target("moonflower-01")
	await _place(flower)
	_key(KEY_E,true)
	game._tick_foraging_hold(.2)
	_check(not (await game.load_run()).is_empty() and not game.foraging_hold.active(), "unstable load attempt cancels without swapping")
	_key(KEY_E,false)
	_key(KEY_E,true)
	game._tick_foraging_hold(.2)
	game.player_placeholder.state.health = 0
	game.retry_encounter()
	_check(not game.foraging_hold.active(), "retry entry cancels synchronously")
	await game.world_host.transition_finished
	_key(KEY_E,false)
	room = game.world_host.current_location
	flower = _target("moonflower-01")
	await _place(flower)
	# Capacity fixtures remain test-only; production save catalog stays unchanged.
	game.session.inventory.add("item-moonflower",99)
	await _place(flower)
	_key(KEY_E,true)
	game._tick_foraging_hold(.6)
	_key(KEY_E,false)
	_check(game.session.inventory.count("item-moonflower") == 99 and not game.session.foraging.is_collected("moonflower-01") and is_instance_valid(flower) and not flower.is_queued_for_deletion(), "full stack keeps node")
	_check(game.ui.foraging_notice.text.begins_with("Backpack full") and game.ui.foraging_notice.visible,"full stack feedback")
	game.session.inventory.consume("item-moonflower",99)
	for index: int in range(20): game.session.inventory.add("f005-capacity-%02d" % index)
	_key(KEY_E,true)
	game._tick_foraging_hold(.6)
	_key(KEY_E,false)
	_check(not game.session.foraging.is_collected("moonflower-01") and game.session.inventory.count("item-moonflower") == 0 and room.foraging_pickups.targets.size() == 4, "full bag keeps counts and node")
	_check(game.ui.foraging_notice.text.begins_with("Backpack full") and game.ui.foraging_notice.visible,"full bag feedback")
	for index: int in range(20): game.session.inventory.consume("f005-capacity-%02d" % index)
	# Observable publication follows joint inventory/origin and physical removal.
	game.session.foraging.committed.connect(func(_revision: int) -> void:
		observed[0] += 1
		_check(game.session.inventory.count("item-moonflower") >= 1 and game.session.foraging.is_collected("moonflower-01"), "observer sees joint facts")
	, CONNECT_ONE_SHOT)
	_key(KEY_E,true)
	game._tick_foraging_hold(.599)
	_check(observed[0] == 0, "no early publication")
	game._tick_foraging_hold(.001)
	_check(observed[0] == 1 and game.session.inventory.count("item-moonflower") == 1 and not room.foraging_pickups.targets.has("moonflower-01"), "flower completion once/removes node")
	_check(game.ui.foraging_notice.text == "Gathered moonflower." and game.ui.foraging_notice.visible,"received feedback after success")
	game._tick_foraging_hold(1)
	_key(KEY_E,true)
	game._tick_foraging_hold(1)
	_check(observed[0] == 1 and game.session.inventory.count("item-moonflower") == 1, "holding cannot grant twice")
	# Held E crossing to immediate lamp/gate cannot trigger them.
	var lamp: PrototypeInteractable = game.world_host.current_location.town.get_node("dock-lamp-02/LightSwitch")
	await _place(lamp)
	var enabled: bool = game.session.environment.light_enabled(ForagingRegistry.LOCATION,"dock-lamp-02","lantern")
	_key(KEY_E,true)
	_check(game.session.environment.light_enabled(ForagingRegistry.LOCATION,"dock-lamp-02","lantern") == enabled, "held E cannot switch adjacent lamp")
	_key(KEY_E,false)
	_key(KEY_E,true)
	_key(KEY_E,false)
	_check(game.session.environment.light_enabled(ForagingRegistry.LOCATION,"dock-lamp-02","lantern") != enabled, "fresh E preserves immediate lamp")
	var rod: PrototypeInteractable = _target(ForagingRegistry.ROD_ORIGIN)
	await _place(rod)
	_key(KEY_E,true)
	game._tick_foraging_hold(.499)
	_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0 and game.foraging_hold.active(), "rod not before500ms")
	game._tick_foraging_hold(.001)
	_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.rod_count() == 1 and not room.foraging_pickups.targets.has(ForagingRegistry.ROD_ORIGIN), "rod completion exact conservation")
	var gate: PrototypeInteractable = room.get_node("TravelGate")
	await _place(gate)
	_key(KEY_E,true)
	_check(not game.world_host.transitioning, "held E cannot enter gate")
	_key(KEY_E,false)
	for id: String in ["moonflower-02","moonflower-03"]:
		await _place(_target(id))
		_key(KEY_E,true)
		game._tick_foraging_hold(.6)
		_key(KEY_E,false)
	_check(game.session.inventory.count("item-moonflower") == 3 and room.foraging_pickups.targets.is_empty(), "all four physically removed")
	game._set_paused(true)
	var old_session: GameSession = game.session
	_check(game.save_run().is_empty(), "isolated save")
	_check((await game.load_run()).is_empty(), "load hydrated absent wrappers")
	_check(game.world_host.current_location.foraging_pickups.targets.is_empty() and game.session.inventory.count("item-moonflower") == 3 and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and not game.foraging_hold.active(), "load exact absence/count, no hold")
	_check(old_session.foraging.get_signal_connection_list("committed").is_empty(), "old session no leaked listener")
	for destination: Array in [["prototype-tollworks","tollworks-from-alderwake"],["prototype-alderwake","alderwake-from-tollworks"]]:
		game.world_host.request_transition(destination[0],destination[1])
		await game.world_host.transition_finished
		_check(game.world_host.current_location.foraging_pickups.targets.is_empty(), "travel retains absences")
		_check(game.session.foraging.get_signal_connection_list("committed").size() == 1, "one location listener after travel")
	game.player_placeholder.state.health = 0
	game.retry_encounter()
	await game.world_host.transition_finished
	_check(game.world_host.current_location.foraging_pickups.targets.is_empty() and game.session.inventory.count("item-moonflower") == 3 and not game.foraging_hold.active(), "retry retains items without hold")
	# Synthetic saved placements hydrate one physical rod with exact saved feet.
	for fixture_kind: String in ["authored","alderwake","tollworks"]:
		game._set_paused(true)
		var candidate: GameSession = ForagingSaveFixture.make(game.catalog,fixture_kind)
		_check(game.save_repository.write(candidate,game.catalog).is_empty(), "synthetic placement save " + fixture_kind)
		_check((await game.load_run()).is_empty(), "synthetic placement physical load " + fixture_kind)
		var id: String = ForagingRegistry.ROD_ORIGIN if fixture_kind == "authored" else ForagingRegistry.DROP_ID
		var target: PrototypeInteractable = _target(id)
		var placement: WorldItemPlacement = game.session.foraging.placement(id)
		_check(game.world_host.current_location.foraging_pickups.targets.size() == 1 and target.global_position == placement.foot, "exact placement wrapper/count " + fixture_kind)
		game._set_paused(false)
		await _place(target)
		_key(KEY_E,true)
		game._tick_foraging_hold(.5)
		_key(KEY_E,false)
		_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.rod_count() == 1 and game.session.foraging.snapshot().world_item_placements.is_empty() and game.world_host.current_location.foraging_pickups.targets.is_empty(), "authored/generated physical pickup preserves rod1 " + fixture_kind)
	_check(TestRunEvidence.write_json("foraging-interaction-report.json", {"task":"F005","proof":"synthetic positions/modes/capacity, normal viewport E dispatch; no ordinary walking", "assertions":assertions+1,"failures":failures}), "write evidence")
	_key(KEY_E,false)
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F005 foraging_interaction_checks ", "PASS" if failures.is_empty() else "FAIL", "; assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _target(id: String) -> PrototypeInteractable:
	return game.world_host.current_location.foraging_pickups.targets[id]

func _place(target: PrototypeInteractable) -> void:
	for direction: Vector3 in [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]:
		game.player_placeholder.global_position = target.global_position + direction * .75
		game.companion.global_position = target.global_position + Vector3(3,0,3)
		await physics_frame
		if InteractionSelector.select(game.player_placeholder,game.world_host.current_location) == target:
			game._refresh_interaction()
			return
	_check(false,"no selected fixture approach " + target.instance_id)

func _key(code: int, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	root.push_input(event,true)

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
