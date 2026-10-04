extends SceneTree
## M015 production composition/navigation checks. Synthetic placements labeled.
var failures: PackedStringArray = []
var guide: Array[Dictionary] = []
var game: Node3D

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "Production startup rejected")
	var room: AlderwakeTerrainPreview = game.world_host.current_location
	_check(room.location_id == "prototype-alderwake" and room.bounds.size == Vector2(147, 80), "Larger exterior not selected")
	_check(game.party.members().size() == 2 and game.session.completed_effect_ids.is_empty(), "Fresh party/progress incorrect")
	_check(room.find_spawn("alderwake-start").position == Vector3.ZERO and room.find_spawn("alderwake-from-tollworks").position == Vector3(107.25, 0, 1.25), "Stable spawn mapping changed")
	var ids: PackedStringArray = []
	for target: PrototypeInteractable in room.interactables():
		ids.append(target.instance_id)
	_check(ids.size() == 3 and "npc-03-counter" in ids and "alderwake-temporary-companion" in ids and "alderwake-travel-gate" in ids, "Duplicated/missing/inactive interactions")
	_check(room.get_node("MarisCounter").position == Vector3(-7.5, 0, 11), "Maris source foot changed")
	_check(room.get_node("TravelGate").position == Vector3(107.25, 0, -1.25) and room.destination_id == "prototype-tollworks" and room.destination_spawn_id == "tollworks-from-alderwake", "Single mapped gate wrong")
	for pad: Vector3 in room.town.portal_pads.values():
		for target: PrototypeInteractable in room.interactables():
			_check(target.kind != "travel" or target.position.distance_to(pad) > 1.6, "Inactive source route became travel")
	game._set_paused(true)
	# Synthetic debug observer regression: detached live wrapper has no global transform.
	var observer: Node = preload("res://tests/live_playtest_bridge.gd").new()
	observer.game = game
	root.add_child(observer)
	observer.set_process(false)
	var fixture: ActorPlaceholder = preload("res://features/combat/guardian.tscn").instantiate()
	fixture.initialize(ActorState.new("tollworks-guardian-01",game.catalog.get_actor("prototype-guardian")))
	room.add_child(fixture)
	game.guardian = fixture
	_check(not observer._observe().guardian.is_empty(), "Attached guardian missing from debug observation")
	room.remove_child(fixture)
	_check(observer._observe().guardian.is_empty(), "Detached guardian transform observed")
	game.guardian = null
	fixture.free()
	observer.free()
	var map: RID = room.get_world_3d().navigation_map
	var goals: Array[Dictionary] = [
		{"goal":"station", "start":Vector3.ZERO, "end":Vector3(-0.8,0,0)},
		{"goal":"maris-lead", "start":Vector3(-0.8,0,0), "end":Vector3(-6,0,10.6)},
		{"goal":"bridge-west", "start":Vector3(-6,0,10.6), "end":Vector3(93,0,-0.5)},
		{"goal":"bridge-east", "start":Vector3(93,0,-0.5), "end":Vector3(103,0,-0.5)},
		{"goal":"tollworks", "start":Vector3(103,0,-0.5), "end":Vector3(107.25,0,-1.25)},
		{"goal":"return-bridge-east", "start":Vector3(107.25,0,1.25), "end":Vector3(103,0,-0.5)},
		{"goal":"return-bridge-west", "start":Vector3(103,0,-0.5), "end":Vector3(93,0,-0.5)},
		{"goal":"maris-fitting", "start":Vector3(93,0,-0.5), "end":Vector3(-6,0,10.6)}]
	var samples: int = 0
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	for goal: Dictionary in goals:
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, goal.start, goal.end, true)
		_check(path.size() >= 2 and path[-1].distance_to(goal.end) < 0.3, "Unreachable approach: " + goal.goal)
		var plain: Array = []
		for point: Vector3 in path:
			plain.append([point.x,point.y,point.z])
		guide.append({"goal":goal.goal,"path":plain})
		for index: int in range(path.size()-1):
			var count: int = ceili(path[index].distance_to(path[index+1])/0.1)
			for step: int in range(count+1):
				var point: Vector3 = path[index].lerp(path[index+1],float(step)/maxi(1,count))
				point.y = room.elevation.height_at(Vector2(point.x,point.z)) + 0.82
				var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
				query.shape = capsule
				query.transform.origin = point
				query.collision_mask = 1
				_check(room.get_world_3d().direct_space_state.intersect_shape(query).is_empty(), "Physical capsule route blocked: " + goal.goal + str(point))
				samples += 1
	# Synthetic selection proves geometry/LOS, not ordinary walking.
	game.player_placeholder.global_position = Vector3(-6,0,10.6)
	_check(InteractionSelector.select(game.player_placeholder,room).instance_id == "npc-03-counter", "Mapped service not selectable")
	game.player_placeholder.global_position = Vector3(107.25,0,1.25)
	_check(not room.can_travel(game.player_placeholder), "Return arrival overlaps gate")
	_check(is_equal_approx(game.player_placeholder.floor_snap_length, 0.04) and game.player_placeholder.floor_contact_height.is_valid(), "Exterior grounding not configured")
	var nav_report: Dictionary = room.navigation_report.duplicate()
	game._set_paused(false)
	game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake")
	await game.world_host.transition_finished
	_check(is_equal_approx(game.player_placeholder.floor_snap_length, 0.1) and not game.player_placeholder.floor_contact_height.is_valid(), "Exterior grounding leaked into Tollworks")
	_check(game.world_host.current_location.destination_id == "prototype-alderwake" and game.world_host.current_location.destination_spawn_id == "alderwake-from-tollworks", "Return mapping lost")
	game.world_host.request_transition("prototype-alderwake","alderwake-from-tollworks")
	await game.world_host.transition_finished
	_check(game.party.members().size() == 2 and game.world_host.get_child_count() == 1 and game.session.completed_effect_ids.is_empty(), "Travel duplicates actors or grants progress")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../docs/evidence/M015"))
	var output: FileAccess = FileAccess.open("res://../docs/evidence/M015/tour-guide.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(guide,"\t")+"\n")
	output.close()
	output = FileAccess.open("res://../docs/evidence/M015/activation-report.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"failures":failures,"capsule_samples":samples,"interactions":ids,"navigation":nav_report},"\t")+"\n")
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	print("M015 activation ", "PASS" if failures.is_empty() else "FAILED", "; capsule samples=",samples)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool,message: String) -> void:
	if not condition:
		failures.append(message)
