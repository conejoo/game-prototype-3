extends SceneTree
## Synthetic navigation guidance only. Does not touch the native game or its save.

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var specification: String = ""
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--route-spec="): specification = argument.trim_prefix("--route-spec=")
		if argument.begins_with("--route-output="): output = argument.trim_prefix("--route-output=")
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(specification))
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	await process_frame
	# Detached synthetic guidance for the chosen room; never drives the native PID.
	if spec.get("location", "prototype-alderwake") != game.session.current_location_id:
		var errors: PackedStringArray = game.world_host.request_transition(spec.location,spec.spawn)
		if not errors.is_empty(): push_error(str(errors)); quit(1); return
		var arrival: Array = await game.world_host.transition_finished
		if not arrival[0]: push_error("Synthetic guidance room refused"); quit(1); return
		for settle: int in range(4): await physics_frame
	var map: RID = game.world_host.current_location.get_world_3d().navigation_map
	var start: Vector3 = Vector3(spec.start[0], spec.start[1], spec.start[2])
	var routes: Array[Dictionary] = []
	for goal: Dictionary in spec.goals:
		var end: Vector3 = Vector3(goal.point[0], goal.point[1], goal.point[2])
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, start, end, true)
		if path.size() < 2 or path[-1].distance_to(end) > 0.3:
			push_error("Unreachable native guidance goal: " + goal.id)
			quit(1)
			return
		var simple: Array[Vector3] = []
		for point: Vector3 in path:
			while simple.size() >= 2:
				var a: Vector3 = simple[-2]
				var b: Vector3 = simple[-1]
				var segment: Vector3 = point - a
				var closest: Vector3 = a + segment * clampf((b-a).dot(segment)/maxf(segment.length_squared(), 0.000001), 0.0, 1.0)
				if closest.distance_to(b) > 0.001: break
				simple.pop_back()
			simple.append(point)
		var plain: Array = []
		for point: Vector3 in simple: plain.append([point.x,point.y,point.z])
		routes.append({"goal":goal.id,"path":plain,"provenance":"Synthetic nav guidance; native movement must remain physical input"})
		start = end
	var file: FileAccess = FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(routes,"\t",true,true)+"\n")
	file.close()
	game.queue_free()
	await process_frame
	quit(0)
