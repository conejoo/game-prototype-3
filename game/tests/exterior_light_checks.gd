extends SceneTree
## W005 consumer/asset/default/anchor/budget verification. Isolated synthetic setup.

var failures: Array[String] = []
var assertions: int = 0
var game: Node3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("W005 engine=%s pid=%d user_data=%s" % [Engine.get_version_info()["string"], OS.get_process_id(), OS.get_user_data_dir()])
	for bad: float in [-.1, 1.0, INF, NAN]: _check(ExteriorLights.night_factor(bad) == -1.0, "invalid phase")
	var previous: float = 0.0
	for index: int in range(10001):
		var factor: float = ExteriorLights.night_factor(float(index) / 10001)
		_check(factor >= 0 and factor <= 1 and absf(factor - previous) < .004, "phase factor discontinuity")
		previous = factor
	_check(ExteriorLights.night_factor(0) == 0 and ExteriorLights.night_factor(.625) == 1, "day/night bounds")
	_check(is_equal_approx(ExteriorLights.night_factor(.375), .42) and is_equal_approx(ExteriorLights.night_factor(.875), .62), "source dusk/dawn factors")
	game = (load("res://app/game_root.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	game._set_paused(true)
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	var lights: ExteriorLights = location.get("exterior_lights") as ExteriorLights
	_check(location.build_errors.is_empty(), "location light build errors " + str(location.build_errors))
	_check(lights.consumers.size() == 23 and lights.emitter_count == 8, "23 sources/eight emitters")
	_check(location.find_children("*", "OmniLight3D", true, false).size() == 8, "actual local node budget")
	var inventory: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../docs/weather-lighting/reference/light-inventory.json"))
	var materials: Array[int] = []
	var body_count: int = location.find_children("*", "CollisionObject3D", true, false).size()
	var nav_count: int = location.find_children("*", "NavigationRegion3D", true, false).size()
	game.session.environment.day_cycle_progress = .625
	game._present_environment()
	for entry: Dictionary in inventory.entries:
		var consumer: ExteriorLightConsumer = lights.consumers.get(entry.prop_id)
		_check(consumer != null and consumer.source_id == entry.source_id, "identity " + entry.prop_id)
		if consumer == null: continue
		var wrapper: Node3D = location.get_node(NodePath(entry.wrapper.trim_prefix("Alderwake/")))
		var expected: Array = entry.foot_xyz_m
		_check(wrapper.position.distance_to(Vector3(expected[0], expected[1], expected[2])) < .00001 and is_equal_approx(wrapper.rotation_degrees.y, entry.yaw_degrees), "wrapper foot/yaw changed " + entry.prop_id)
		_check(wrapper.get_node(NodePath(entry.anchor_node)) == consumer, "explicit anchor binding " + entry.prop_id)
		_check(consumer.enabled == entry.default_enabled and consumer.intensity == (1.0 if entry.default_enabled else 0.0), "pinned default " + entry.prop_id)
		var material_id: int = consumer.glow_material.get_instance_id()
		_check(material_id not in materials, "shared source glow material")
		materials.append(material_id)
		_check(consumer.find_children("*", "CollisionObject3D", true, false).is_empty() and consumer.find_children("*", "NavigationRegion3D", true, false).is_empty(), "visual adds physics/nav")
		if entry.kind == "windows":
			var original: MeshInstance3D = wrapper.get_node("VisualRoot/ImportedExterior")
			_check(not (original.get_active_material(0) as StandardMaterial3D).emission_enabled, "whole building emits")
			var pane_mesh: Mesh = (consumer.get_node("WindowPanes") as MeshInstance3D).mesh
			var vertices: PackedVector3Array = pane_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
			var recipe: Dictionary = entry.window_surface_recipe
			_check(consumer.pane_count == recipe.center_heights_m.size() * 32 and vertices.size() == consumer.pane_count * 6, "pane count " + entry.prop_id)
			var polygon: Array = recipe.local_polygon_xz_m
			for vertex: Vector3 in vertices:
				var registered: bool = false
				for edge: int in range(polygon.size()):
					var a: Vector2 = Vector2(polygon[edge][0], polygon[edge][1])
					var b: Vector2 = Vector2(polygon[(edge + 1) % polygon.size()][0], polygon[(edge + 1) % polygon.size()][1])
					var direction: Vector2 = (b - a).normalized()
					var outward: Vector2 = Vector2(direction.y, -direction.x)
					var point: Vector2 = Vector2(vertex.x, vertex.z)
					if absf((point - a).dot(outward) - float(recipe.outward_offset_m)) < .000002:
						for fraction: float in recipe.edge_fractions:
							var x: float = (point - a.lerp(b, fraction)).dot(direction)
							for level: float in recipe.center_heights_m:
								if absf(x) <= .28001 and absf(x) >= .02499 and vertex.y >= level - .22001 and vertex.y <= level + .24001 and absf(vertex.y - level) >= .02499: registered = true
				_check(registered, "pane outside original glass/mullion gap " + entry.prop_id)
		else:
			var xyz: Array = entry.anchor_local_xyz_m
			_check(consumer.anchor.position.distance_to(Vector3(xyz[0], xyz[1], xyz[2])) < .000001, "physical core anchor " + entry.prop_id)
			if entry.kind == "woven_net":
				_check(consumer.emitter == null and wrapper.find_children("*", "CollisionObject3D", true, false).is_empty(), "net must be nonblocking/emission only")
			else:
				_check(consumer.emitter != null and not consumer.emitter.shadow_enabled and is_equal_approx(consumer.emitter.omni_range, entry.initial_omni_range_m), "physical emitter range/shadows")
				_check(consumer.emitter.omni_range > sqrt(pow(consumer.anchor.position.y, 2) + pow(entry.intended_ground_radius_m, 2)), "physical range misses intended floor")
	var lamp: ExteriorLightConsumer = lights.consumers["dock-lamp-01"]
	var row_lamp: ExteriorLightConsumer = lights.consumers["dock-row-lamp-01"]
	var state_before: Array[Dictionary] = game.session.environment.light_source_overrides.duplicate(true)
	_check(game.session.environment.set_light_enabled(LightSourceRegistry.LOCATION_ID, lamp.prop_id, lamp.source_id, true).is_empty(), "synthetic on override")
	game._present_environment()
	_check(lamp.intensity == 1 and row_lamp.intensity == 1, "independent armed states")
	game.session.environment.set_light_enabled(LightSourceRegistry.LOCATION_ID, row_lamp.prop_id, row_lamp.source_id, false)
	game._present_environment()
	_check(lamp.intensity == 1 and row_lamp.intensity == 0 and row_lamp.emitter.light_energy == 0, "one lamp changes another")
	game.session.environment.day_cycle_progress = 0
	game._present_environment()
	_check(lamp.enabled and lamp.intensity == 0 and lamp.emitter.light_energy == 0, "daytime readiness")
	game.session.environment.day_cycle_progress = .625
	var facts: Array[Dictionary] = game.session.environment.light_source_overrides.duplicate(true)
	lights.present(game.session.environment, lamp.anchor.global_position)
	_check(lamp.emitter.visible and lamp.emitter.light_energy > 0, "near illumination")
	var near_energy: float = lamp.emitter.light_energy
	lights.present(game.session.environment, lamp.anchor.global_position + Vector3(15,0,0))
	_check(is_equal_approx(lamp.emitter.light_energy, near_energy * .5), "smooth middle distance fade")
	lights.present(game.session.environment, lamp.anchor.global_position + Vector3(19,0,0))
	_check(lamp.enabled and lamp.intensity == 1 and not lamp.emitter.visible and game.session.environment.light_source_overrides == facts, "render selection mutated state/emission")
	game.session.environment.light_source_overrides = state_before
	game._present_environment()
	var frozen: float = row_lamp.glow_material.emission_energy_multiplier
	for frame: int in range(6): await process_frame
	_check(paused and row_lamp.glow_material.emission_energy_multiplier == frozen, "paused light changes")
	_check(location.find_children("*", "CollisionObject3D", true, false).size() == body_count and location.find_children("*", "NavigationRegion3D", true, false).size() == nav_count, "state changes physics/nav")
	# Old consumer lifetime follows its location, and return reconstructs consumers.
	var weak: WeakRef = weakref(lights)
	lamp = null
	row_lamp = null
	location = null
	lights = null
	for destination: Array in [["prototype-tollworks","tollworks-from-alderwake"],["prototype-alderwake","alderwake-from-tollworks"]]:
		var errors: PackedStringArray = game.world_host.request_transition(destination[0], destination[1])
		_check(errors.is_empty(), "light replacement request")
		if errors.is_empty():
			var result: Array = await game.world_host.transition_finished
			_check(result[0], "light replacement commit")
	_check(weak.get_ref() == null, "stale location light owner retained")
	lights = game.world_host.current_location.get("exterior_lights") as ExteriorLights
	_check(lights.consumers.size() == 23 and lights.emitter_count == 8 and lights.consumers["dock-row-lamp-01"].intensity == 1, "return hydration")
	game.queue_free()
	await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("W005 exterior lights %s: %d assertions" % ["PASS" if failures.is_empty() else "FAIL", assertions])
	quit(0 if failures.is_empty() else 1)


func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
