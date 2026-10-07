extends SceneTree
## Synthetic positions/boundaries and lifecycle fixtures; actual viewport drag inputs.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var boundaries: Array[Dictionary] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	for frame: int in range(4): await process_frame
	var room: PrototypeLocation = game.world_host.current_location
	await _position(Vector3(-6.5,0,15))
	for row: Dictionary in [
		{"label":"water","foot":Vector3(-8,0,15.75)},
		{"label":"cliff-blocked","foot":Vector3(26,.25,-2)},
		{"label":"outside/unsupported","foot":Vector3(1000,0,1000)},
		{"label":"unsupported height","foot":Vector3(-6.5,2,15.75)},
		{"label":"arrival reservation","foot":room.get_node("Spawns").get_child(0).global_position},
		{"label":"portal reservation","foot":room.get_node("TravelGate").global_position},
		{"label":"nonfinite","foot":Vector3(INF,0,0)}]:
		var errors: PackedStringArray = ForagingPlacementGeometry.validate(room,_placement(row.foot))
		_check(not errors.is_empty(),"reject " + row.label)
		boundaries.append({"label":row.label,"errors":errors})
	var steep: StaticBody3D = _box(Vector3(3,2,0),Vector3(3,.2,3),true)
	steep.rotation.z = PI / 6
	await physics_frame
	var steep_errors: PackedStringArray = ForagingPlacementGeometry.validate(room,_placement(Vector3(3,2.0866,0)))
	_check(not steep_errors.is_empty(),"steep supported test slope rejected")
	boundaries.append({"label":"synthetic steep slope","errors":steep_errors})
	steep.queue_free()
	await physics_frame
	var navigation: NavigationRegion3D = room.navigation_region
	room.navigation_region = null
	var nav_errors: PackedStringArray = ForagingPlacementGeometry.validate(room,_placement(Vector3(-6.5,0,15.75)))
	_check(not nav_errors.is_empty(),"missing navigation fails closed")
	boundaries.append({"label":"synthetic missing navigation capability","errors":nav_errors})
	room.navigation_region = navigation
	await _disconnected_probe()
	var baseline: PackedStringArray = ForagingPlacementGeometry.validate_nearby(room,_placement(Vector3(-6.5,0,15.75)),game.player_placeholder)
	_check(baseline.is_empty(),"baseline safe nearby foot: " + str(baseline) + " hero=" + str(game.player_placeholder.position))
	var tip_blocker: StaticBody3D = _box(Vector3(-6.01,.6,15.75),Vector3(.02,1.2,.06))
	await physics_frame
	var tip_errors: PackedStringArray = ForagingPlacementGeometry.validate(room,_placement(Vector3(-6.5,0,15.75)))
	_check(tip_errors.has("placement rod footprint obstructed"),"narrow endpoint collider cannot embed rod")
	boundaries.append({"label":"synthetic tall narrow endpoint blocker","errors":tip_errors})
	tip_blocker.queue_free()
	await physics_frame
	_check(not ForagingPlacementGeometry.validate_nearby(room,_placement(Vector3(3,0,0)),game.player_placeholder).is_empty(),"remote supported foot rejected")
	# A thin blocker crosses local approach but does not touch endpoint footprint.
	var wall: StaticBody3D = _box(Vector3(-6.5,.8,15.1),Vector3(1,1.6,.04))
	await physics_frame
	_check(not ForagingPlacementGeometry.validate_nearby(room,_placement(Vector3(-6.5,0,16)),game.player_placeholder).is_empty(),"local approach cannot cross blocker")
	wall.queue_free()
	await physics_frame
	# Default authored drag replaces origin under same identity, never duplicates.
	await _drag(ForagingRegistry.ROD_ORIGIN,Vector3(-6.5,0,15.5))
	_check(game.session.foraging.placement(ForagingRegistry.ROD_ORIGIN) != null and game.session.foraging.rod_count() == 1 and room.foraging_pickups.targets.size() == 4,"authored move overrides one origin")
	var authored: PrototypeInteractable = room.foraging_pickups.targets[ForagingRegistry.ROD_ORIGIN]
	for orthographic: bool in [true,false]:
		game.camera_rig.set_orthographic(orthographic)
		for zoom: float in [.8,1.15]:
			game.camera_rig.zoom_factor = zoom
			game.camera_rig._apply_zoom()
			for frame: int in range(3): await process_frame
			var ground: Vector3 = Vector3(-6.5,0,15.6)
			var point: Vector2 = game.camera_rig.camera.unproject_position(ground)
			var ray: Variant = game.camera_rig.ground_point(point,0)
			_check(ray != null and (ray as Vector3).distance_to(ground) < .01,"ground projection/zoom roundtrip")
			await _start(authored)
			_check(game.item_drag.active(),"projected rod selectable at both zoom bounds")
			var before: String = _facts()
			_motion(point)
			_check(game.item_drag.errors.is_empty() and _facts() == before,"preview valid and detached")
			_key(KEY_ESCAPE)
			_mouse(point,false)
			_check(not game.item_drag.active() and not paused and _facts() == before,"Esc cancels without opening pause/mutation")
	game.camera_rig.set_orthographic(true)
	game.camera_rig.zoom_factor = 1
	game.camera_rig._apply_zoom()
	for mode: String in ["focus","pause","backpack","journal","dialogue","gui-focus","travel","load","retry","load-entry","retry-entry","revision","owner","target-position","removal"]:
		var target: PrototypeInteractable = room.foraging_pickups.targets[ForagingRegistry.ROD_ORIGIN]
		await _start(target)
		_check(game.item_drag.active(),"begin cancellation fixture " + mode)
		var before: String = _facts()
		match mode:
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
			"pause": game._set_paused(true)
			"backpack": _key(KEY_B)
			"journal": _key(KEY_J)
			"dialogue": game.dialogue.begin(game.catalog.get_dialogue("prototype-companion-greeting"),"fixture"); game._update_controls()
			"gui-focus": game.ui.pause_button.grab_focus(); game._tick_item_drag()
			"travel": game.world_host.transitioning = true; game._tick_item_drag()
			"load": game.loading_save = true; game._tick_item_drag()
			"retry": game.retrying = true; game._tick_item_drag()
			"load-entry": await game.load_run()
			"retry-entry": game.retry_encounter()
			"revision": game.session.foraging.bind_placement_validator(game._validate_live_placement.bind(weakref(game.session))); game._tick_item_drag()
			"owner": game.item_drag._owner = weakref(GameSession.new()); game._tick_item_drag()
			"target-position": target.position.x += .1; game._tick_item_drag(); target.position.x -= .1
			"removal": room.foraging_pickups.remove_child(target); game._tick_item_drag(); room.foraging_pickups.add_child(target)
		_check(not game.item_drag.active() and game.drag_preview == null,"cancel/dispose " + mode)
		# Revision fixture changes only transient capability, not durable facts.
		_check(_facts() == before,"cancel preserves durable item facts " + mode)
		game.world_host.transitioning = false
		game.loading_save = false
		game.retrying = false
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		if paused: game._set_paused(false)
		if game.backpack_open: game._close_backpack()
		if game.journal_open: game._toggle_journal()
		if game.dialogue.active(): game._cancel_dialogue()
		if root.gui_get_focus_owner() != null: root.gui_get_focus_owner().release_focus()
		_mouse(_screen(target.global_position),false)
		game._update_controls()
		_check(game.player_placeholder.pointer_position == Vector2(-1,-1),"cancel consumes old pointer release " + mode)
	# Invalid physical release leaves exact authored placement; no reward/publish.
	for foot: Vector3 in [Vector3(-8,0,15.75),Vector3(26,.25,-2),Vector3(1000,0,1000),room.get_node("Spawns").get_child(0).global_position,room.get_node("TravelGate").global_position]:
		await _start(authored)
		var original: String = _facts()
		var invalid: Vector2 = _screen(foot)
		_motion(invalid)
		_check(not game.item_drag.errors.is_empty(),"invalid preview " + str(foot))
		_mouse(invalid,false)
		_check(_facts() == original and game.session.foraging.rod_count() == 1,"invalid release exact rollback " + str(foot))
	await _start(authored)
	var position: Vector3 = game.player_placeholder.position
	var basis: Basis = game.player_placeholder.visual_root.basis
	var camera: Dictionary = TestRunObservation.camera(game)
	for key: int in [KEY_W,KEY_SPACE,KEY_E,KEY_P,KEY_EQUAL,KEY_MINUS]: _key(key)
	for frame: int in range(6): await physics_frame
	_check(not game.player_placeholder.combat.busy() and not game.foraging_hold.active() and game.player_placeholder.position.is_equal_approx(position),"drag blocks combat/gather/movement")
	_check(game.player_placeholder.visual_root.basis == basis and not game.player_placeholder.aim_marker.visible and TestRunObservation.camera(game) == camera,"drag blocks aim/zoom/projection")
	_check(not game.interact().ok and not game.switch_light(null,false).ok,"direct world interaction commands reject drag mode")
	_key(KEY_ESCAPE)
	_mouse(_screen(authored.global_position),false)
	_key(KEY_E,true)
	game._tick_foraging_hold(.5)
	_key(KEY_E,false)
	_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.rod_count() == 1,"physical held pickup after authored move")
	# Facing water forces alternative search; successful drop clears selection.
	await _position(Vector3(-6.5,0,15.75))
	game.player_placeholder.face_direction(Vector3.LEFT)
	_key(KEY_B)
	game._select_inventory_item(ForagingRegistry.ROD_ITEM)
	var first: Vector3 = game.player_placeholder.global_position + Vector3.LEFT * .85
	game._drop_active_rod()
	var dropped: WorldItemPlacement = game.session.foraging.placement(ForagingRegistry.DROP_ID)
	_check(dropped != null and not game.backpack_open and game.session.inventory.snapshot().active_item_id == null and game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 0,"drop consumes bag/active after validation")
	if dropped != null:
		_check(dropped.foot.distance_to(first) > .1,"blocked facing tries alternatives")
		await _drag(ForagingRegistry.DROP_ID,Vector3(-6.5,0,15.7))
		_check(game.session.foraging.rod_count() == 1 and not room.foraging_pickups.targets.has(ForagingRegistry.ROD_ORIGIN),"generated move replaces drop/origin suppressed")
		_key(KEY_E,true)
		game._tick_foraging_hold(.5)
		_key(KEY_E,false)
		_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.placement(ForagingRegistry.DROP_ID) == null,"held pickup at committed generated foot")
	await _position(room.get_node("Spawns").get_child(0).global_position)
	_key(KEY_B)
	game._select_inventory_item(ForagingRegistry.ROD_ITEM)
	var full: String = _facts()
	game._drop_active_rod()
	_check(game.backpack_open and _facts() == full and not game.ui.backpack.feedback.text.is_empty(),"no-space reservation retains bag/active/modal with feedback")
	game._close_backpack()
	# Production capability rebinds on both room branches; placed rod stays in its
	# own room across travel and remains physically retrievable on revisit.
	_check(game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(),"synthetic travel to indoor room")
	var indoor_arrival: Array = await game.world_host.transition_finished
	_check(indoor_arrival[0],"indoor arrival")
	await _position(Vector3(4,0,1))
	game.player_placeholder.face_direction(Vector3.FORWARD)
	_key(KEY_B)
	_check(not game.ui.backpack.drop_button.disabled,"saved active selection opens with enabled Drop")
	game._drop_active_rod()
	var indoor_drop: WorldItemPlacement = game.session.foraging.placement(ForagingRegistry.DROP_ID)
	_check(indoor_drop != null and not game.backpack_open and game.session.foraging.rod_count() == 1,"indoor drop bound to production geometry")
	if indoor_drop != null:
		_check(game.world_host.request_transition(ForagingRegistry.LOCATION,"alderwake-from-tollworks").is_empty(),"synthetic travel with foreign rod")
		await game.world_host.transition_finished
		_check(not game.world_host.current_location.foraging_pickups.targets.has(ForagingRegistry.DROP_ID) and game.session.foraging.rod_count() == 1,"foreign placement remains one/no wrong-room wrapper")
		game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
		await game.world_host.transition_finished
		var restored_target: PrototypeInteractable = game.world_host.current_location.foraging_pickups.targets.get(ForagingRegistry.DROP_ID)
		_check(restored_target != null and restored_target.global_position.is_equal_approx(indoor_drop.foot),"indoor travel reconstructs exact foot")
		await _position(indoor_drop.foot + Vector3.LEFT * .65)
		_key(KEY_E,true)
		game._tick_foraging_hold(.5)
		_key(KEY_E,false)
		_check(game.session.inventory.count(ForagingRegistry.ROD_ITEM) == 1 and game.session.foraging.rod_count() == 1 and game.session.foraging.placement(ForagingRegistry.DROP_ID) == null,"indoor physical pickup after travel")
	_mouse(Vector2(100,330),true)
	_mouse(Vector2(100,330),false)
	_check(game.player_placeholder.combat.busy(),"fresh world pointer can attack after drag/travel/recollect")
	_check(TestRunEvidence.write_json("placement-report.json",{"task":"F007","proof":"synthetic production positions/boundaries; viewport drag/hold commands; ordinary route separate renderer","assertions":assertions,"boundaries":boundaries,"failures":failures}),"write evidence")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("F007 world_item_placement_checks ","PASS" if failures.is_empty() else "FAIL","; assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _placement(foot: Vector3) -> WorldItemPlacement:
	return WorldItemPlacement.new(ForagingRegistry.DROP_ID,game.session.current_location_id,foot,WorldItemPlacement.GENERATED)

func _disconnected_probe() -> void:
	var probe: PrototypeLocation = PrototypeLocation.new()
	probe.location_id = ForagingRegistry.LOCATION
	probe.position = Vector3(2000,0,0)
	var spawns: Node3D = Node3D.new()
	spawns.name = "Spawns"
	var anchor: SpawnAnchor = SpawnAnchor.new()
	spawns.add_child(anchor)
	probe.add_child(spawns)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "Floor"
	body.position = Vector3(5,-.1,0)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(30,.2,6)
	shape.shape = box
	body.add_child(shape)
	probe.add_child(body)
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.cell_size = 0.01
	mesh.cell_height = 0.01
	mesh.vertices = PackedVector3Array([Vector3(-2,0,-2),Vector3(-2,0,2),Vector3(2,0,2),Vector3(2,0,-2),Vector3(8,0,-2),Vector3(8,0,2),Vector3(12,0,2),Vector3(12,0,-2)])
	mesh.add_polygon(PackedInt32Array([0,1,2,3]))
	mesh.add_polygon(PackedInt32Array([4,5,6,7]))
	probe.navigation_region = NavigationRegion3D.new()
	probe.navigation_region.navigation_mesh = mesh
	probe.add_child(probe.navigation_region)
	game.add_child(probe)
	var synchronized: PackedStringArray = await game.world_host._synchronize_navigation(probe,anchor)
	_check(synchronized.is_empty(),"disconnected probe navigation synchronized")
	var placed: WorldItemPlacement = WorldItemPlacement.new(ForagingRegistry.DROP_ID,probe.location_id,Vector3(2010,0,0),WorldItemPlacement.GENERATED)
	var errors: PackedStringArray = ForagingPlacementGeometry.validate(probe,placed)
	_check(errors.has("placement has no arrival route"),"supported disconnected island cannot be placed: " + str(errors))
	boundaries.append({"label":"synthetic supported disconnected island","errors":errors})
	probe.queue_free()
	for frame: int in range(3): await physics_frame
	var room: PrototypeLocation = game.world_host.current_location
	_check((await game.world_host._synchronize_navigation(room,room.get_node("Spawns").get_child(0))).is_empty(),"production map synchronized after probe")

func _position(point: Vector3) -> void:
	game.player_placeholder.position = point
	game.player_placeholder.clear_input()
	for frame: int in range(4): await process_frame

func _facts() -> String:
	var facts: Dictionary = game.session.foraging.snapshot()
	facts.erase("revision")
	return TestRunSnapshot.exact_json(facts)

func _box(point: Vector3,size: Vector3,floor_body: bool = false) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = point
	body.collision_layer = 1
	if floor_body: body.set_meta("aim_ground",true)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	game.world_host.current_location.add_child(body)
	return body

func _screen(point: Vector3) -> Vector2:
	return game.camera_rig.camera.unproject_position(point)

func _start(target: PrototypeInteractable) -> void:
	for frame: int in range(2): await process_frame
	var point: Vector2 = _screen(target.global_position + Vector3.UP * .08)
	_motion(point)
	_mouse(point,true)

func _drag(id: String,foot: Vector3) -> void:
	await _start(game.world_host.current_location.foraging_pickups.targets[id])
	_check(game.item_drag.active(),"pointer starts drag " + id)
	_motion(_screen(foot))
	_check(game.item_drag.errors.is_empty(),"valid preview " + id + str(game.item_drag.errors))
	_mouse(_screen(foot),false)
	var placement: WorldItemPlacement = game.session.foraging.placement(id)
	_check(placement != null and placement.foot.distance_to(foot) < .01,"release commits " + id)

func _motion(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	root.push_input(event,true)

func _mouse(point: Vector2,down: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = down
	root.push_input(event,true)

func _key(code: int,held: bool = false) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event,true)
	if not held:
		event = event.duplicate()
		event.pressed = false
		root.push_input(event,true)

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
