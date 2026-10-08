extends SceneTree
## Synthetic failure fixtures plus real viewport WASD. No native-input claim.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var traces: Array[Dictionary] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	var actor: ActorPlaceholder = game.player_placeholder
	var room: PrototypeLocation = game.world_host.current_location
	var start: Vector3 = actor.global_position
	var ready: Dictionary = await TestRunJourney.wait_navigation(room,start)
	_check(ready.ok and ready.owner_matches and ready.iteration > 0,"current exact region ready")
	ready = await TestRunJourney.wait_navigation(room,start,0)
	_check(not ready.ok,"invalid readiness budget rejected")
	await _navigation_probe(room,start)
	var result: Dictionary = await _walk(Vector3(107.25,0,-2),"unreachable-gate-edge")
	_check(not result.ok and result.reason == "unreachable_goal" and result.frames == 0 and result.error.contains("path ends"),"F007 outside gate goal rejected before movement")
	_check(actor.global_position.is_equal_approx(start) and actor.movement_buttons.is_empty(),"unreachable goal sends no keys")
	for options: Dictionary in [{"max_frames":12001},{"max_frames":1.5},{"max_ms":0},{"stall_seconds":INF},{"unknown":1}]:
		result = await _walk(start,"invalid-options",options)
		_check(not result.ok and result.reason == "invalid_options","bounded options rejected " + str(options))
	result = await _walk(Vector3(INF,0,0),"nonfinite-goal")
	_check(not result.ok and result.reason == "invalid_goal","nonfinite goal rejected")
	paused = true
	result = await _walk(start,"paused")
	_check(not result.ok and result.reason == "input_mode","paused walk rejected")
	paused = false
	game.ui.backpack.open(game.session.inventory.snapshot(),game.catalog)
	game.backpack_open = true
	result = await _walk(start,"modal-focus")
	_check(not result.ok and result.reason == "input_mode","modal/focus walk rejected")
	game.backpack_open = false
	game.ui.backpack.close()
	_key(KEY_D,true)
	result = await _walk(start,"foreign-held-input")
	_check(not result.ok and result.reason == "input_owned" and actor.movement_buttons.has("move_right"),"preexisting input rejected without clearing caller's key")
	_key(KEY_D,false)
	result = await _walk(start,"already-arrived")
	_check(result.ok and result.frames == 0 and actor.movement_buttons.is_empty(),"already at goal releases no foreign input")
	# Positive journeys use actual current camera axes and viewport input only.
	var goal: Vector3 = start + Vector3(2,0,0)
	result = await _walk(goal,"camera-relative-out")
	_check(result.ok and result.accepted_keys.size() > 0 and actor.global_position.distance_to(start) > 1.7,"ordinary WASD reaches goal: " + result.error)
	_check(actor.movement_buttons.is_empty(),"arrival releases accepted keys")
	var camera_basis: Basis = game.camera_rig.camera.global_basis
	game.camera_rig.camera.global_basis = Basis(Vector3.UP,PI/2) * camera_basis
	result = await _walk(start,"rotated-camera-return")
	_check(result.ok and result.frames > 0,"rotated camera uses live movement axes: " + result.error)
	game.camera_rig.camera.global_basis = camera_basis
	result = await _walk(goal,"explicit-frame-cap",{"max_frames":1})
	_check(not result.ok and result.reason == "budget_exhausted" and result.frames == 1,"explicit frame cap honored")
	_check(actor.movement_buttons.is_empty(),"frame cap releases keys")
	result = await _walk(goal,"explicit-wall-cap",{"max_ms":1})
	_check(not result.ok and result.reason == "budget_exhausted" and result.elapsed_ms >= 1,"explicit wall cap honored")
	_check(actor.movement_buttons.is_empty(),"wall cap releases keys")
	actor.set_physics_process(false) # Labeled synthetic immobile actor; controls remain normal.
	result = await _walk(goal,"immobile-stall",{"stall_seconds":0.1})
	_check(not result.ok and result.reason == "stalled" and result.frames <= 7 and result.accepted_keys.size() > 0,"watchdog catches accepted input with no progress")
	_check(result.error.contains("actual=") and result.error.contains("next=") and result.error.contains("contacts=") and result.has("camera"),"stall retains actionable diagnostics")
	_check(actor.movement_buttons.is_empty(),"stall releases keys")
	actor.set_physics_process(true)
	_interrupt.call_deferred("focus")
	result = await _walk(goal,"lost-focus")
	_check(not result.ok and result.reason == "input_mode" and actor.movement_buttons.is_empty(),"mid-walk lost focus stops and releases")
	game.window_focused = true
	var original_region: NavigationRegion3D = room.navigation_region
	_interrupt.call_deferred("region-replacement")
	result = await _walk(goal,"replaced-navigation")
	_check(not result.ok and result.reason == "navigation_changed" and actor.movement_buttons.is_empty(),"mid-walk replaced navigation region stops and releases")
	room.navigation_region = original_region
	_interrupt.call_deferred("pause")
	result = await _walk(goal,"pause-during-walk")
	_check(not result.ok and result.reason == "input_mode" and actor.movement_buttons.is_empty(),"mid-walk pause releases accepted keys")
	paused = false
	result = await _walk(goal,"after-failure-recovery")
	_check(result.ok and actor.movement_buttons.is_empty(),"new journey succeeds after failures: " + result.error)
	# Do not disable/re-enable a production region as fixture restoration: arrival
	# owns production navigation lifecycle. Check cancellation last, then dispose.
	_interrupt.call_deferred("navigation")
	result = await _walk(start,"lost-navigation")
	_check(not result.ok and result.reason == "navigation_changed" and actor.movement_buttons.is_empty(),"mid-walk disabled navigation stops and releases")
	_check(TestRunEvidence.write_json("journey-checks.json",{"assertions":assertions,"traces":traces,"failures":failures,"proof":"Synthetic readiness/failure fixtures; positive movement uses viewport WASD"}),"write isolated evidence")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("Testing journey: %s assertions=%d" % ["PASS" if failures.is_empty() else "FAIL",assertions])
	quit(0 if failures.is_empty() else 1)

func _walk(goal: Vector3,label: String,options: Dictionary = {}) -> Dictionary:
	var result: Dictionary = await TestRunJourney.walk(game,goal,label,options)
	traces.append(result)
	return result

func _interrupt(kind: String) -> void:
	# Interrupt accepted input, not an arbitrary frame of asynchronous preflight.
	for frame: int in range(240):
		if not game.player_placeholder.movement_buttons.is_empty(): break
		await physics_frame
	if game.player_placeholder.movement_buttons.is_empty(): return
	await physics_frame
	if kind == "focus": game.window_focused = false
	elif kind == "navigation": game.world_host.current_location.navigation_region.enabled = false
	elif kind == "region-replacement": game.world_host.current_location.navigation_region = null
	else: paused = true

func _key(code: int,down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	root.push_input(event,true)

func _navigation_probe(room: PrototypeLocation,start: Vector3) -> void:
	# Keep synthetic region/map lifecycle independent of production navigation.
	var isolated: SubViewport = SubViewport.new()
	isolated.own_world_3d = true
	isolated.size = Vector2i(32,32)
	root.add_child(isolated)
	var probe: PrototypeLocation = PrototypeLocation.new()
	probe.position = Vector3(2000,0,0)
	probe.navigation_region = NavigationRegion3D.new()
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.cell_size = 0.01
	mesh.cell_height = 0.01
	mesh.vertices = PackedVector3Array([Vector3(-2,0,-2),Vector3(-2,0,2),Vector3(2,0,2),Vector3(2,0,-2),Vector3(8,0,-2),Vector3(8,0,2),Vector3(12,0,2),Vector3(12,0,-2)])
	mesh.add_polygon(PackedInt32Array([0,1,2,3]))
	mesh.add_polygon(PackedInt32Array([4,5,6,7]))
	probe.navigation_region.navigation_mesh = mesh
	probe.add_child(probe.navigation_region)
	isolated.add_child(probe)
	var isolated_map: RID = probe.get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(isolated_map,0.01)
	NavigationServer3D.map_set_cell_height(isolated_map,0.01)
	NavigationServer3D.map_set_active(isolated_map,true)
	var foreign_map: RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_active(foreign_map,true)
	probe.navigation_region.set_navigation_map(foreign_map)
	await physics_frame
	await process_frame
	var ready: Dictionary = await TestRunJourney.wait_navigation(probe,probe.global_position,3)
	traces.append({"label":"wrong-map-readiness","ready":ready})
	_check(not ready.ok and ready.error.contains("did not synchronize"),"wrong map times out with readiness diagnostics")
	_bind_probe.call_deferred(probe)
	ready = await TestRunJourney.wait_navigation(probe,probe.global_position)
	traces.append({"label":"delayed-map-readiness","ready":ready})
	_check(ready.ok and ready.frames >= 2,"readiness waits for delayed exact-region registration")
	NavigationServer3D.free_rid(foreign_map)
	# Disconnected islands share one region; nearest-owner alone is insufficient.
	game.world_host.current_location = probe
	game.player_placeholder.global_position = probe.global_position
	game.player_placeholder.set_physics_process(false)
	var result: Dictionary = await _walk(probe.global_position+Vector3(10,0,0),"disconnected-island")
	_check(not result.ok and result.reason == "unreachable_goal" and result.frames == 0,"disconnected path endpoint rejected before movement")
	probe.navigation_region.enabled = false
	ready = await TestRunJourney.wait_navigation(probe,probe.global_position)
	_check(not ready.ok and ready.error.contains("disabled") and ready.frames == 0,"disabled region fails immediately")
	game.player_placeholder.global_position = start
	game.player_placeholder.set_physics_process(true)
	game.world_host.current_location = room
	isolated.queue_free()
	await physics_frame
	_check((await TestRunJourney.wait_navigation(room,start)).ok,"original region ready after probe disposal")

func _bind_probe(probe: PrototypeLocation) -> void:
	for frame: int in range(3): await physics_frame
	if is_instance_valid(probe): probe.navigation_region.set_navigation_map(probe.get_world_3d().navigation_map)

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		print("Journey check failed: ",message)
