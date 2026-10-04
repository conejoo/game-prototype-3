extends SceneTree
## M018 synthetic rendered performance at recorded M016 ordinary-tour feet.
## Full production root, unpaused idle actors/AI/UI/aim/shaders; no save or quest writes.

var game: Node3D
var output: String
var warmup: float = 10.0
var duration: float = 60.0
var runs: int = 3
var failures: PackedStringArray = []
var report: Dictionary = {"views": [], "loads": [], "queries_usec": [], "lifecycle": []}

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--profile-output="): output = argument.trim_prefix("--profile-output=")
		if argument.begins_with("--profile-warmup="): warmup = float(argument.trim_prefix("--profile-warmup="))
		if argument.begins_with("--profile-duration="): duration = float(argument.trim_prefix("--profile-duration="))
		if argument.begins_with("--profile-runs="): runs = int(argument.trim_prefix("--profile-runs="))
	_run.call_deferred()

func _run() -> void:
	if output.is_empty():
		push_error("--profile-output required")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(960, 640)
	DisplayServer.window_move_to_foreground()
	var started: int = Time.get_ticks_usec()
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "Cold production arrival failed")
	DisplayServer.window_move_to_foreground()
	var location: AlderwakeTerrainPreview = game.world_host.current_location
	report["cold_arrival_ms"] = (Time.get_ticks_usec() - started) / 1000.0
	report["cold_navigation"] = location.navigation_report.duplicate()
	report["initial_inventory"] = _inventory(location)
	_check(float(location.navigation_report.generation_bake_ms) <= 5000, "Cold generation/bake exceeds 5s")
	report["settings"] = {"engine": Engine.get_version_info(), "adapter": RenderingServer.get_video_adapter_name(), "vendor": RenderingServer.get_video_adapter_vendor(), "api": RenderingServer.get_video_adapter_api_version(), "renderer": RenderingServer.get_current_rendering_method(), "viewport": [root.size.x, root.size.y], "vsync_mode": DisplayServer.window_get_vsync_mode(), "max_fps": Engine.max_fps, "warmup_seconds": warmup, "run_seconds": duration, "runs_per_view": runs, "projection": "orthographic", "zoom": 1.0, "paused": paused, "setup": "synthetic placement at M016 ordinary-tour feet; full unpaused production processing"}
	var index: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../docs/evidence/M016/rendered-index.json"))
	for view: String in ["maris", "dense-forest", "bridge-west", "ford-west"]:
		var point: Array = index.goals[view].position
		var observation: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../docs/evidence/M016/windowed-final/" + index.goals[view].response))
		var ally: Array = observation.after.companion.position
		game.player_placeholder.global_position = Vector3(point[0], point[1], point[2])
		game.companion.global_position = Vector3(ally[0], ally[1], ally[2])
		game.player_placeholder.velocity = Vector3.ZERO
		game.companion.velocity = Vector3.ZERO
		game.player_placeholder.reset_physics_interpolation()
		game.companion.reset_physics_interpolation()
		game.camera_rig._process(0)
		game.camera_rig.set_orthographic(true)
		DisplayServer.window_move_to_foreground()
		_stage("warmup-" + view)
		await create_timer(warmup).timeout
		await _attribution(location, view)
		await RenderingServer.frame_post_draw
		_check(root.get_texture().get_image().save_png(output.path_join(view + ".png")) == OK, "Capture failed " + view)
		for run: int in range(runs):
			await _sample(view, run)
		await _queries(location)
	await _lifecycle()
	report["final_inventory"] = _inventory(game.world_host.current_location)
	_check(report.initial_inventory.has("trees") and report.initial_inventory == report.final_inventory, "Art/physics inventory changed across swaps")
	report["failures"] = failures
	report["acceptance_duration"] = warmup >= 10 and duration >= 60 and runs >= 3
	_write("report.json", report)
	_stage("done")
	game.queue_free()
	await process_frame
	print("M018 profile ", "PASS" if failures.is_empty() else "FAILED", "; failures=", failures)
	quit(0 if failures.is_empty() else 1)

func _sample(view: String, run: int) -> void:
	_stage("sample-" + view + "-" + str(run))
	var frames: PackedFloat64Array = []
	var draws: PackedInt32Array = []
	var process_times: PackedFloat64Array = []
	var focused: int = 0
	var began: int = Time.get_ticks_usec()
	var previous: int = began
	while Time.get_ticks_usec() - began < int(duration * 1000000):
		await process_frame
		var now: int = Time.get_ticks_usec()
		frames.append((now - previous) / 1000.0)
		previous = now
		draws.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		process_times.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
		if game.window_focused: focused += 1
	var elapsed: float = (Time.get_ticks_usec() - began) / 1000000.0
	var sorted_frames: PackedFloat64Array = frames.duplicate()
	sorted_frames.sort()
	var sorted_draws: PackedInt32Array = draws.duplicate()
	sorted_draws.sort()
	var row: Dictionary = {"view":view, "run":run, "seconds":elapsed, "samples":frames.size(), "frame_p50_ms":_percentile(sorted_frames, 0.5), "frame_p95_ms":_percentile(sorted_frames, 0.95), "frame_p99_ms":_percentile(sorted_frames, 0.99), "frame_max_ms":sorted_frames[-1], "draw_p95":sorted_draws[ceili(draws.size() * 0.95) - 1], "focused_samples":focused, "hero":[game.player_placeholder.position.x,game.player_placeholder.position.y,game.player_placeholder.position.z], "tree_count":game.world_host.current_location.tree_art.tree_ids.size(), "tree_batches":game.world_host.current_location.tree_art.batches.size()}
	report.views.append(row)
	_check(float(row.frame_p95_ms) <= 16.67, "Frame p95 exceeds 16.67ms " + view + "/" + str(run))
	_check(float(row.frame_p99_ms) <= 25, "Frame p99 exceeds 25ms " + view + "/" + str(run))
	_check(int(row.draw_p95) <= 500, "Draw calls p95 exceeds 500 " + view + "/" + str(run))
	_check(focused == frames.size(), "Focus lost during sample " + view + "/" + str(run))
	var lines: PackedStringArray = ["frame,interval_ms,total_draw_calls,process_ms"]
	for i: int in range(frames.size()): lines.append("%d,%.6f,%d,%.6f" % [i, frames[i], draws[i], process_times[i]])
	var file: FileAccess = FileAccess.open(output.path_join("%s-%d.csv" % [view,run]), FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	_write("report.json", report)
	print("M018 SAMPLE ", row)

func _queries(location: AlderwakeTerrainPreview) -> void:
	var map: RID = location.get_world_3d().navigation_map
	var goals: Array[Vector3] = [Vector3.ZERO,Vector3(-6,0,11.5),Vector3(93,0,-0.5),Vector3(103,0,-0.5),Vector3(66,0,12.5),Vector3(75,0,12.5),Vector3(31.51317596435547,0.5,5.25),Vector3(107.25,0,1.25),Vector3(121.5,0,-7)]
	for i: int in range(30):
		var began: int = Time.get_ticks_usec()
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map,goals[i % goals.size()],goals[(i + 4) % goals.size()],true)
		report.queries_usec.append(Time.get_ticks_usec() - began)
		_check(path.size() >= 2, "Benchmark path disconnected")
	var times: Array = report.queries_usec.duplicate()
	times.sort()
	report["query_p95_usec"] = times[ceili(times.size() * 0.95) - 1]
	_check(report.query_p95_usec <= 5000, "Path query p95 exceeds 5ms")

func _lifecycle() -> void:
	var host: PrototypeWorldHost = game.world_host
	var ids: Array[int] = [game.player_placeholder.get_instance_id(),game.companion.get_instance_id()]
	var map: RID = host.get_world_3d().navigation_map
	for trip: int in range(12):
		_stage("swap-" + str(trip))
		for destination: String in ["prototype-tollworks","prototype-alderwake"]:
			var old: WeakRef = weakref(host.current_location)
			var old_region: RID = host.current_location.navigation_region.get_rid()
			var spawn: String = "tollworks-from-alderwake" if destination == "prototype-tollworks" else "alderwake-from-tollworks"
			var began: int = Time.get_ticks_usec()
			_check(host.request_transition(destination,spawn).is_empty(), "Swap request rejected")
			var result: Array = await host.transition_finished
			var ms: float = (Time.get_ticks_usec() - began) / 1000.0
			_check(result[0], "Swap failed " + str(result[1]))
			_check(ms <= 2000, "Warm arrival exceeds 2s " + destination)
			report.loads.append({"trip":trip,"destination":destination,"request_to_commit_ms":ms})
			await process_frame
			NavigationServer3D.map_force_update(map)
			_check(old.get_ref() == null, "Stale location after swap")
			_check(not old_region in NavigationServer3D.map_get_regions(map), "Stale region after swap")
			_check(NavigationServer3D.map_get_regions(map).size() == 1, "Duplicate navigation regions")
			_check(host.get_child_count() == 1 and game.party.members().size() == 2, "Duplicate world/party")
			_check(ids == [game.player_placeholder.get_instance_id(),game.companion.get_instance_id()], "Party wrappers replaced")
			_check(host._placement_errors(host.current_location.find_spawn(spawn)).is_empty(), "Unsafe party arrival")
		if trip == 1 or trip == 11:
			_stage("idle-baseline" if trip == 1 else "idle-final")
			await create_timer(10).timeout
			report.lifecycle.append({"trip":trip,"nodes":int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),"objects":int(Performance.get_monitor(Performance.OBJECT_COUNT)),"resources":int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),"orphan_nodes":int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),"static_memory_bytes":int(Performance.get_monitor(Performance.MEMORY_STATIC)),"regions":NavigationServer3D.map_get_regions(map).size(),"world_children":host.get_child_count(),"party":game.party.members().size()})
			_stage("checkpoint-baseline" if trip == 1 else "checkpoint-final")
			await create_timer(1).timeout
	_write("report.json", report)

func _percentile(values: PackedFloat64Array, fraction: float) -> float:
	return values[ceili(values.size() * fraction) - 1]

func _stage(value: String) -> void:
	_write("stage.json", {"stage":value,"ticks_usec":Time.get_ticks_usec(),"pid":OS.get_process_id()})
	print("M018 STAGE ", value)

func _write(name: String, value: Variant) -> void:
	var file: FileAccess = FileAccess.open(output.path_join(name),FileAccess.WRITE)
	file.store_string(JSON.stringify(value,"\t") + "\n")

func _check(condition: bool, message: String) -> void:
	if not condition and not failures.has(message): failures.append(message)

func _inventory(location: AlderwakeTerrainPreview) -> Dictionary:
	var art: AlderwakeTreeArt = location.tree_art
	var indices: Dictionary = {}
	for record: Dictionary in location.forest.prop_records:
		if record.tree == null: continue
		var wrapper: Node3D = location.forest.get_node(NodePath(record.id))
		var key: String = wrapper.get_meta("tree_art_batch")
		var index: int = wrapper.get_meta("tree_art_index")
		var batch: MultiMeshInstance3D = art.batches[key]
		var transform: Transform3D = batch.transform * batch.multimesh.get_instance_transform(index)
		_check(transform.origin.distance_to(wrapper.position) < 0.001 and transform.basis.is_equal_approx(wrapper.transform.basis), "Batched foot/yaw changed " + record.id)
		_check(wrapper.get_meta("source_record") == record and wrapper.has_node("Collision") == (record.collision != null), "Tree collision/metadata changed " + record.id)
		_check(not indices.has(key + ":" + str(index)), "Duplicate tree batch index")
		indices[key + ":" + str(index)] = record.id
	# Independent multiset certifies every exact former cliff face survives batching.
	var expected: Dictionary = {}
	for cliff: Dictionary in location.elevation.cliffs:
		var a: Vector2 = cliff.a
		var b: Vector2 = cliff.b
		var h: PackedFloat32Array = cliff.heights
		for point: Vector3 in [Vector3(a.x,h[0],a.y),Vector3(b.x,h[1],b.y),Vector3(b.x,h[3],b.y),Vector3(a.x,h[0],a.y),Vector3(b.x,h[3],b.y),Vector3(a.x,h[2],a.y)]:
			expected[point] = expected.get(point,0) + 1
	var actual: Dictionary = {}
	for visual: MeshInstance3D in location.elevation.riser_batches.values():
		var arrays: Array = visual.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var mesh_indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(vertices.size()))
		for index: int in mesh_indices:
			var point: Vector3 = vertices[index]
			actual[point] = actual.get(point,0) + 1
	_check(actual == expected, "Riser batching lost/changed cliff faces")
	_check(location.elevation.cliffs.size() == 238 and location.elevation.riser_surfaces.is_empty(), "Cliff bodies/buffer lifecycle changed")
	var count: int = 0
	for batch: MultiMeshInstance3D in art.batches.values(): count += batch.multimesh.instance_count
	_check(count == 395 and indices.size() == 395 and art.tree_ids.size() == 395, "Missing/extra tree instances")
	_check(location.build_errors.is_empty(), "Map construction errors")
	return {"trees":count,"variants":art.mappings.size(),"batches":art.batches.size(),"physics_nodes":location.find_children("*","CollisionObject3D",true,false).size(),"nav_polygons":location.navigation_region.navigation_mesh.get_polygon_count(),"terrain_batches":location.batch_count,"town_structures":location.town_art.structure_ids.size(),"landmark_instances":location.landmark_art.instance_count,"riser_batches":location.elevation.riser_batches.size()}
func _attribution(location: AlderwakeTerrainPreview, view: String) -> void:
	var rows: Dictionary = {}
	var risers: Array[Node] = location.elevation.find_children("*", "MeshInstance3D",true,false)
	for kind: String in ["all", "no-risers", "no-trees", "restored"]:
		for riser: MeshInstance3D in risers: riser.visible = kind != "no-risers"
		location.tree_art.visible = kind != "no-trees"
		for frame: int in range(5): await process_frame
		await RenderingServer.frame_post_draw
		rows[kind] = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	if not report.has("attribution"): report["attribution"] = {}
	report.attribution[view] = rows
	print("M018 DRAW ATTRIBUTION ", view, " ", rows)