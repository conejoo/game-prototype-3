extends SceneTree
## Physical projection checks use labeled synthetic placement; normal tour is separate.

var failures: PackedStringArray = []
var game: Node3D
var samples: int = 0
var maximum_error: float = 0.0
var old_plane_error: float = 0.0
var report: Dictionary = {}
var hidden_samples: int = 0
var observations: Array[Dictionary] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(960, 640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await physics_frame
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var actor: ActorPlaceholder = game.player_placeholder
	var rig: PrototypeCameraRig = game.camera_rig
	actor.set_physics_process(false)
	game.companion_ai.enabled = false
	game.companion.set_physics_process(false)
	var targets: Array[Vector3] = []
	for slope: Dictionary in location.layout.elevation.slopes:
		for fraction: float in [0.2, 0.5, 0.8]:
			var xz: Vector2 = Vector2(slope.cell[0] - 22 + fraction, slope.cell[1] - 18 + fraction)
			targets.append(Vector3(xz.x, location.elevation.height_at(xz), xz.y))
	for point: Vector3 in [Vector3.ZERO, Vector3(-6, 0, 10.6), Vector3(31.513175964, 0.5, 5.25), Vector3(96, 0, -0.5), Vector3(70.5, 0, 12.5), Vector3(107.25, 0, -1.25), Vector3(121.5, 0, -7)]:
		targets.append(point)
	for orthographic: bool in [true, false]:
		for zoom_value: float in [0.8, 1.0, 1.15]:
			rig.zoom_factor = zoom_value
			rig.set_orthographic(orthographic)
			for point: Vector3 in targets:
				actor.global_position = point - Vector3(1.2, 0, 1.0)
				actor.global_position.y = location.elevation.height_at(Vector2(actor.global_position.x, actor.global_position.z))
				rig._process(0)
				var screen: Vector2 = rig.camera.unproject_position(point)
				# Independent authored triangle intersection identifies the visible
				# floor, including a near terrace occluding a farther ramp sample.
				var intended: Vector3 = point
				var nearest_distance: float = INF
				for offset: Vector2 in [Vector2.ZERO, Vector2(0.02, 0.01), Vector2(-0.02, -0.01)]:
					var authored: Vector3 = _authored_hit(location, rig.camera.project_ray_origin(screen + offset), rig.camera.project_ray_normal(screen + offset))
					var distance: float = (authored - rig.camera.project_ray_origin(screen)).dot(rig.camera.project_ray_normal(screen))
					if distance < nearest_distance:
						point = authored
						nearest_distance = distance
				_check(is_finite(point.x), "Authored floor intersection missing")
				if intended.distance_to(point) > 0.15: hidden_samples += 1
				var hit: Variant = rig.ground_point(screen, actor.global_position.y)
				_check(hit != null, "Missing physical floor " + str(point))
				if hit == null:
					continue
				var error: float = (hit as Vector3).distance_to(point)
				maximum_error = maxf(maximum_error, error)
				_check(error <= 0.15, "Slope/landmark aim error " + str(error))
				var old: Variant = Plane(Vector3.UP, actor.global_position.y).intersects_ray(rig.camera.project_ray_origin(screen), rig.camera.project_ray_normal(screen))
				if old != null:
					old_plane_error = maxf(old_plane_error, (old as Vector3).distance_to(point))
				actor.pointer_position = screen
				actor._update_aim()
				_check(actor.aim_marker.visible and actor.aim_marker.global_position.distance_to(point + Vector3.UP * 0.03) <= 0.15, "Marker disagrees with physical floor")
				var expected: Vector3 = Vector3(point.x - actor.global_position.x, 0, point.z - actor.global_position.z).normalized()
				_check((-actor.visual_root.global_basis.z).dot(expected) > 0.999 and absf(actor.visual_root.global_basis.z.y) < 0.001, "Facing pitched on slope")
				actor.combat.cancel()
				_check(actor.request_attack() and actor.combat.direction.dot(expected) > 0.999 and absf(actor.combat.direction.y) < 0.001, "Attack disagrees with ground direction")
				actor.combat.cancel()
				var camera_before: Transform3D = rig.camera.global_transform
				rig._process(0)
				_check(rig.camera.global_transform.is_equal_approx(camera_before), "Camera jumps without movement")
				observations.append({"orthographic":orthographic,"zoom":zoom_value,"intended":[intended.x,intended.y,intended.z],"selected":[point.x,point.y,point.z],"hit":[hit.x,hit.y,hit.z],"error_m":error})
				samples += 1
	# Exact rendered camera/pointer regression on the entry terrace.
	actor.global_position = Vector3(26.9980220794678, 0.25, 5.18308258056641)
	rig.zoom_factor = 0.8
	for orthographic: bool in [true, false]:
		rig.set_orthographic(orthographic)
		rig._process(0)
		var live_hit: Variant = rig.ground_point(Vector2(550, 340), actor.global_position.y)
		_check(live_hit == null, "Cliff-side pointer exposed hidden support below terrace")
	# A tall physical prop between camera and target cannot supply aim height.
	actor.global_position = Vector3.ZERO
	rig.zoom_factor = 1
	rig.set_orthographic(true)
	rig._process(0)
	var ground: Vector3 = Vector3(2, 0, 1)
	var screen: Vector2 = rig.camera.unproject_position(ground)
	var ray: Vector3 = rig.camera.project_ray_normal(screen)
	var obstacle: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3.ONE
	shape.shape = box
	obstacle.add_child(shape)
	location.add_child(obstacle)
	obstacle.global_position = ground - ray * 4
	await physics_frame
	var raw: Dictionary = location.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(rig.camera.project_ray_origin(screen), ground - ray * -1, 1))
	_check(not raw.is_empty() and raw.collider == obstacle, "Prop hijack fixture failed to intersect")
	var protected: Variant = rig.ground_point(screen, 0)
	_check(protected != null and (protected as Vector3).distance_to(ground) < 0.01, "Prop top hijacked ground")
	obstacle.queue_free()
	await physics_frame
	_check(rig.ground_point(rig.camera.unproject_position(Vector3(-50, 0, -50)), 0) == null, "Outside map fabricated flat-plane hit")
	# Root modal/focus gates remain authoritative over camera, marker and attack.
	for mode: String in ["pause", "journal", "dialogue", "focus"]:
		actor.pointer_position = screen
		if mode == "pause": game._set_paused(true)
		elif mode == "journal": game._toggle_journal()
		elif mode == "dialogue":
			game.dialogue.begin(game.catalog.get_dialogue("prototype-maris-counter"), "npc-03-counter")
			game._update_controls()
		else: game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		var projection: int = rig.camera.projection
		var zoom_before: float = rig.zoom_factor
		var event: InputEventKey = InputEventKey.new()
		event.keycode = KEY_P
		event.pressed = true
		root.push_input(event, true)
		actor._update_aim()
		_check(not actor.controls_enabled and not actor.aim_marker.visible and not actor.request_attack(), mode + " leaked aim/attack")
		_check(rig.camera.projection == projection and rig.zoom_factor == zoom_before, mode + " leaked camera")
		if mode == "pause": game._set_paused(false)
		elif mode == "journal": game._toggle_journal()
		elif mode == "dialogue": game._cancel_dialogue()
		else: game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	# Read-only nav guide for ordinary-input rendered tour. No live teleport API.
	var guide: Array[Dictionary] = []
	var start: Vector3 = Vector3.ZERO
	for entry: Dictionary in [{"goal":"maris", "point":Vector3(-6,0,10.6)}, {"goal":"entry-ramp", "point":Vector3(27,0.25,5.25)}, {"goal":"moonwell", "point":Vector3(31.513175964,0.5,5.25)}, {"goal":"ford-west", "point":Vector3(66,0,12.5)}, {"goal":"ford-east", "point":Vector3(75,0,12.5)}, {"goal":"bridge-west", "point":Vector3(93,0,-0.5)}, {"goal":"bridge-east", "point":Vector3(103,0,-0.5)}, {"goal":"tollworks", "point":Vector3(107.25,0,0.1)}, {"goal":"closed-exit", "point":Vector3(121.5,0,-7)}, {"goal":"dense-forest", "point":Vector3(82,0,35)}]:
		if entry.goal == "dense-forest": entry.point = NavigationServer3D.map_get_closest_point(location.navigation_region.get_navigation_map(), entry.point)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(location.navigation_region.get_navigation_map(), start, entry.point, true)
		_check(path.size() >= 2 and path[-1].distance_to(entry.point) < 0.25, "Tour guide disconnected " + entry.goal)
		var values: Array = []
		for point: Vector3 in path: values.append([point.x, point.y, point.z])
		guide.append({"goal":entry.goal, "path":values})
		start = entry.point
	var directory: String = ProjectSettings.globalize_path("res://../docs/evidence/M016")
	DirAccess.make_dir_recursive_absolute(directory)
	var guide_file: FileAccess = FileAccess.open(directory.path_join("camera-tour-guide.json"), FileAccess.WRITE)
	guide_file.store_string(JSON.stringify(guide, "	") + "\n")
	report = {"projection_samples": samples, "terrain_occluded_samples":hidden_samples,"observations":observations, "maximum_aim_error_m":maximum_error, "old_plane_maximum_error_m":old_plane_error, "slope_count":16, "projections":2, "zoom_factors":[0.8,1,1.15], "failures":Array(failures)}
	var file: FileAccess = FileAccess.open(directory.path_join("camera-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "	") + "\n")
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("M016 camera: samples=",samples," error=",maximum_error," old_plane=",old_plane_error," terrain_occluded=",hidden_samples," failures=",failures)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

func _authored_hit(location: AlderwakeTerrainPreview, origin: Vector3, direction: Vector3) -> Vector3:
	var best: Vector3 = Vector3.INF
	var distance: float = INF
	var faces: PackedVector3Array = location.elevation.floor_faces
	for index: int in range(0, faces.size(), 3):
		var hit: Variant = Geometry3D.ray_intersects_triangle(origin, direction, faces[index], faces[index + 1], faces[index + 2])
		if hit != null and origin.distance_squared_to(hit) < distance:
			distance = origin.distance_squared_to(hit)
			best = hit
	var base: Variant = Plane(Vector3.UP, 0).intersects_ray(origin, direction)
	if base != null and location.bounds.has_point(Vector2(base.x, base.z)) and origin.distance_squared_to(base) < distance:
		best = base
	return best
