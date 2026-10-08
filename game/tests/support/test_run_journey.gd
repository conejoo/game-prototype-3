class_name TestRunJourney
extends RefCounted
## Ordinary viewport input only. Failures are returned, never hidden or teleported.

const OPTIONS: Dictionary = {
	"goal_tolerance": 0.16, "height_tolerance": 0.3,
	"navigation_frames": 120, "navigation_ms": 3000,
	"max_frames": 12000, "max_ms": 180000, "stall_seconds": 2.0,
}
const DIRECTIONS: Array[Dictionary] = [
	{"axes":Vector2(1,0),"keys":[KEY_D]}, {"axes":Vector2(-1,0),"keys":[KEY_A]},
	{"axes":Vector2(0,-1),"keys":[KEY_W]}, {"axes":Vector2(0,1),"keys":[KEY_S]},
	{"axes":Vector2(1,-1),"keys":[KEY_D,KEY_W]}, {"axes":Vector2(1,1),"keys":[KEY_D,KEY_S]},
	{"axes":Vector2(-1,-1),"keys":[KEY_A,KEY_W]}, {"axes":Vector2(-1,1),"keys":[KEY_A,KEY_S]},
]
const MOVEMENT_ACTIONS: Dictionary = {KEY_W:"move_forward",KEY_A:"move_left",KEY_S:"move_back",KEY_D:"move_right"}


static func wait_navigation(location: PrototypeLocation, point: Vector3, max_frames: int = 120, max_ms: int = 3000) -> Dictionary:
	var result: Dictionary = {"ok":false,"error":"","frames":0,"elapsed_ms":0,"iteration":0,"owner_matches":false,"query_ready":false}
	if max_frames < 1 or max_frames > 600 or max_ms < 1 or max_ms > 10000 or not point.is_finite():
		result.error = "navigation requires finite point and bounded limits"
		return result
	if not is_instance_valid(location) or not location.is_inside_tree():
		result.error = "navigation location unavailable"
		return result
	var tree: SceneTree = location.get_tree()
	var region: NavigationRegion3D = location.navigation_region
	var map: RID = location.get_world_3d().navigation_map
	var begun: int = Time.get_ticks_msec()
	var previous_iteration: int = -1
	var stable_queries: int = 0
	for frame: int in range(max_frames):
		result.frames = frame
		result.elapsed_ms = Time.get_ticks_msec() - begun
		if not is_instance_valid(location) or not location.is_inside_tree() or not is_instance_valid(region) or location.navigation_region != region or not region.is_inside_tree() or not region.enabled or region.navigation_mesh == null or region.navigation_mesh.get_polygon_count() == 0:
			result.error = "navigation region missing, disabled, empty or replaced"
			return result
		if not map.is_valid() or not NavigationServer3D.map_is_active(map):
			result.error = "navigation map unavailable or inactive"
			return result
		NavigationServer3D.map_force_update(map)
		result.iteration = NavigationServer3D.map_get_iteration_id(map)
		result.owner_matches = NavigationServer3D.map_get_closest_point_owner(map, point) == region.get_rid()
		# Ownership can precede path publication. Probe a short local route: a
		# zero-length self-route may legitimately be optimized to an empty path.
		result.query_ready = result.iteration > 0 and result.owner_matches and (not NavigationServer3D.map_get_path(map,point,point+Vector3(0.1,0,0),true).is_empty() or not NavigationServer3D.map_get_path(map,point,point+Vector3(0,0,0.1),true).is_empty())
		stable_queries = stable_queries + 1 if result.query_ready and result.iteration == previous_iteration else 0
		previous_iteration = result.iteration
		if stable_queries >= 2 and region.get_navigation_map() == map:
			result.ok = true
			return result
		if result.elapsed_ms >= max_ms: break
		await tree.physics_frame
	result.elapsed_ms = Time.get_ticks_msec() - begun
	result.error = "navigation did not synchronize with expected region at %s (frames=%d, elapsed_ms=%d, iteration=%d, owner_matches=%s, query_ready=%s)" % [point,result.frames,result.elapsed_ms,result.iteration,result.owner_matches,result.query_ready]
	return result


static func walk(game: Node3D, goal: Vector3, label: String, overrides: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"ok":false,"error":"","reason":"","label":label,"goal":TestRunObservation.vector(goal),"frames":0,"elapsed_ms":0,"path_length":0.0}
	var options: Dictionary = OPTIONS.duplicate()
	for key: Variant in overrides:
		if not options.has(key) or not (overrides[key] is int or overrides[key] is float) or not is_finite(float(overrides[key])) or float(overrides[key]) <= 0 or float(overrides[key]) > float(OPTIONS[key]):
			return _fail(result,"invalid_options","unknown, nonfinite or unbounded journey option: " + str(key))
		if key in ["navigation_frames","navigation_ms","max_frames","max_ms"] and not overrides[key] is int:
			return _fail(result,"invalid_options","journey frame/millisecond limits must be integers: " + str(key))
		options[key] = overrides[key]
	if not goal.is_finite(): return _fail(result,"invalid_goal","journey goal must be finite")
	var mode: String = _mode_error(game)
	if not mode.is_empty(): return _fail(result,"input_mode",mode)
	var actor: ActorPlaceholder = game.player_placeholder
	if not actor.movement_buttons.is_empty(): return _fail(result,"input_owned","journey requires released movement input")
	var tree: SceneTree = game.get_tree()
	var viewport: Viewport = game.get_viewport()
	var location: PrototypeLocation = game.world_host.current_location
	var start: Vector3 = actor.global_position
	result.start = TestRunObservation.vector(start)
	result.navigation = await wait_navigation(location,start,int(options.navigation_frames),int(options.navigation_ms))
	mode = _mode_error(game)
	if not mode.is_empty() or game.world_host.current_location != location:
		return _fail(result,"input_mode","journey context changed while waiting for navigation: " + mode)
	if not result.navigation.ok: return _fail(result,"navigation_unready",result.navigation.error)
	var map: RID = location.get_world_3d().navigation_map
	var region: NavigationRegion3D = location.navigation_region
	var path: PackedVector3Array = NavigationServer3D.map_get_path(map,start,goal,true)
	if path.is_empty(): return _fail(result,"unreachable_goal","navigation returned no path to requested goal " + str(goal))
	result.path_endpoint = TestRunObservation.vector(path[-1])
	if not _near(path[-1],goal,options) or NavigationServer3D.map_get_closest_point_owner(map,goal) != location.navigation_region.get_rid():
		return _fail(result,"unreachable_goal","requested goal %s is unreachable; path ends at %s (horizontal gap=%.3fm)" % [goal,path[-1],_flat_distance(path[-1],goal)])
	if _flat_distance(path[0],start) > 0.6 or absf(path[0].y-start.y) > float(options.height_tolerance):
		return _fail(result,"unreachable_start","actor is outside navigation; path starts at " + str(path[0]))
	if not is_finite(actor.move_speed) or actor.move_speed <= 0:
		return _fail(result,"invalid_speed","journey requires positive finite actor move_speed")
	for index: int in range(1,path.size()): result.path_length += path[index-1].distance_to(path[index])
	# Allow steering/terrain overhead, but retain caller/hard limits. No fixed 30s route ceiling.
	var seconds: float = float(result.path_length) / actor.move_speed * 2.0 + 3.0
	var frame_budget: int = mini(int(options.max_frames),ceili(seconds * Engine.physics_ticks_per_second))
	var wall_budget: int = mini(int(options.max_ms),ceili(seconds * 2000.0 + 5000.0))
	var stall_frames: int = maxi(1,ceili(float(options.stall_seconds) * Engine.physics_ticks_per_second))
	result.frame_budget = frame_budget
	result.wall_budget_ms = wall_budget
	var held: Array[int] = []
	var next: int = mini(1,path.size()-1)
	var best_remaining: float = INF
	var last_progress: int = 0
	var begun: int = Time.get_ticks_msec()
	for frame: int in range(frame_budget + 1):
		result.frames = frame
		result.elapsed_ms = Time.get_ticks_msec() - begun
		mode = _mode_error(game)
		if not mode.is_empty() or game.world_host.current_location != location:
			_fail(result,"input_mode","journey context changed: " + mode)
			break
		if not is_instance_valid(region) or location.navigation_region != region or not region.enabled or region.get_navigation_map() != map or not NavigationServer3D.map_is_active(map) or NavigationServer3D.map_get_closest_point_owner(map,actor.global_position) != region.get_rid():
			_fail(result,"navigation_changed","journey navigation owner changed or disabled")
			break
		var position: Vector3 = actor.global_position
		if _near(position,goal,options):
			result.ok = true
			break
		while next < path.size()-1 and _flat_distance(position,path[next]) < 0.2: next += 1
		var remaining: float = _flat_distance(position,path[next])
		for index: int in range(next+1,path.size()): remaining += _flat_distance(path[index-1],path[index])
		if remaining < best_remaining - 0.05:
			best_remaining = remaining
			last_progress = frame
		if frame-last_progress >= stall_frames:
			_fail(result,"stalled","no route progress for %.2fs; actual=%s next=%s accepted_keys=%s controls=%s focus=%s contacts=%s" % [float(options.stall_seconds),position,path[next],actor.movement_buttons.keys(),actor.controls_enabled,viewport.gui_get_focus_owner(),_contacts(actor)])
			break
		if frame == frame_budget or result.elapsed_ms >= wall_budget:
			_fail(result,"budget_exhausted","journey budget exhausted (path=%.2fm, frames=%d/%d, elapsed_ms=%d/%d); actual=%s next=%s" % [result.path_length,frame,frame_budget,result.elapsed_ms,wall_budget,position,path[next]])
			break
		var direction: Vector3 = path[next]-position
		direction.y = 0
		var best_dot: float = -INF
		var choice: Array[int] = []
		for option: Dictionary in DIRECTIONS:
			var dot: float = direction.normalized().dot(game.camera_rig.movement_direction(option.axes).normalized())
			if dot > best_dot:
				best_dot = dot
				choice.assign(option.keys)
		_set_keys(viewport,held,choice)
		held = choice
		await tree.physics_frame
	# Every post-input exit reaches cleanup, including focus/pause/location changes.
	if is_instance_valid(actor):
		result.accepted_keys = actor.movement_buttons.keys()
		result.actual = TestRunObservation.vector(actor.global_position)
		result.contacts = _contacts(actor)
	result.next_waypoint = TestRunObservation.vector(path[next])
	_set_keys(viewport,held,[])
	# A newly paused/removed actor may not receive viewport key-up. Teardown only
	# the transient accepted actions owned by this journey; never clear caller input.
	if is_instance_valid(actor):
		for code: int in held: actor.movement_buttons.erase(MOVEMENT_ACTIONS[code])
	if is_instance_valid(game):
		result.controls_enabled = actor.controls_enabled if is_instance_valid(actor) else false
		result.window_focused = game.window_focused
		result.ui_focus = str(viewport.gui_get_focus_owner())
		if is_instance_valid(game.camera_rig) and is_instance_valid(game.camera_rig.camera):
			result.camera = TestRunObservation.camera(game)
	if result.ok:
		for settle: int in range(3): await tree.physics_frame
		if not is_instance_valid(actor) or not _near(actor.global_position,goal,options):
			_fail(result,"arrival_changed","actor left requested goal while settling released input")
		elif not _mode_error(game).is_empty() or game.world_host.current_location != location:
			_fail(result,"input_mode","journey context changed while settling arrival")
		else: result.actual = TestRunObservation.vector(actor.global_position)
	result.elapsed_ms = Time.get_ticks_msec() - begun
	return result


static func _mode_error(game: Node3D) -> String:
	if not is_instance_valid(game) or not game.is_inside_tree(): return "journey game unavailable"
	if not is_instance_valid(game.player_placeholder) or not is_instance_valid(game.camera_rig) or not is_instance_valid(game.world_host.current_location): return "journey actor/camera/location unavailable"
	if game.get_tree().paused or game.world_host.transitioning or game.loading_save or game.retrying or not game.window_focused or not game.player_placeholder.controls_enabled or game.player_placeholder.state.health <= 0 or game.dialogue.active() or game.journal_open or game.backpack_open or game.foraging_hold.active() or game.item_drag.active() or game.get_viewport().gui_get_focus_owner() != null:
		return "journey requires resumed, focused ordinary movement (paused=%s, controls=%s, window_focused=%s, ui_focus=%s)" % [game.get_tree().paused,game.player_placeholder.controls_enabled,game.window_focused,game.get_viewport().gui_get_focus_owner()]
	return ""


static func _fail(result: Dictionary, reason: String, error: String) -> Dictionary:
	result.ok = false
	result.reason = reason
	result.error = "%s: %s" % [result.label,error]
	return result


static func _near(a: Vector3, b: Vector3, options: Dictionary) -> bool:
	return _flat_distance(a,b) <= float(options.goal_tolerance) and absf(a.y-b.y) <= float(options.height_tolerance)


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x-b.x,a.z-b.z).length()


static func _contacts(actor: ActorPlaceholder) -> PackedStringArray:
	var contacts: PackedStringArray = []
	for index: int in range(actor.get_slide_collision_count()):
		contacts.append(str(actor.get_slide_collision(index).get_collider()))
	return contacts


static func _set_keys(viewport: Viewport, previous: Array[int], next: Array[int]) -> void:
	if not is_instance_valid(viewport): return
	for code: int in previous:
		if not next.has(code): _key(viewport,code,false)
	for code: int in next:
		if not previous.has(code): _key(viewport,code,true)


static func _key(viewport: Viewport, code: int, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = down
	viewport.push_input(event,true)
