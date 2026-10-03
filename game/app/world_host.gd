class_name PrototypeWorldHost
extends Node3D
## Owns replaceable location only; commands preserve session and party identity.

signal transition_started
signal transition_finished(success: bool, errors: PackedStringArray)

var catalog: ContentCatalog
var session: GameSession
var party: PrototypeParty
var current_location: PrototypeLocation
var transitioning: bool = false
var transition_count: int = 0
var developer_fixtures: bool = false


func initialize(content: ContentCatalog, run: GameSession, persistent_party: PrototypeParty) -> void:
	catalog = content
	session = run
	party = persistent_party


func request_transition(location_id: String, spawn_id: String) -> PackedStringArray:
	if transitioning:
		return PackedStringArray(["transition already in progress"])
	var definition: LocationDefinition = catalog.get_location(location_id)
	if definition == null or not spawn_id in definition.spawn_ids:
		return PackedStringArray(["unknown location/spawn '%s/%s'" % [location_id, spawn_id]])
	var packed: PackedScene = load(definition.scene_path) as PackedScene
	var candidate_node: Node = packed.instantiate() if packed != null else null
	if not candidate_node is PrototypeLocation:
		if candidate_node != null:
			candidate_node.free()
		return PackedStringArray(["location scene requires PrototypeLocation"])
	var candidate: PrototypeLocation = candidate_node as PrototypeLocation
	# Remove test props before validation/navigation/placement. Dialogue station
	# remains normal prototype content; it provides the active ally's choice.
	if not developer_fixtures:
		for child: Node in candidate.get_children():
			if child.is_in_group("developer_fixture"):
				child.free()
	var errors: PackedStringArray = candidate.validation_errors(definition, catalog)
	if not errors.is_empty():
		candidate.free()
		return errors
	# Lock synchronously: a second request/input cannot race the deferred load.
	transitioning = true
	party.suspend_for_travel()
	transition_started.emit()
	_replace_location.call_deferred(candidate, location_id, spawn_id)
	return PackedStringArray()


func _replace_location(candidate: PrototypeLocation, location_id: String, spawn_id: String) -> void:
	var previous: PrototypeLocation = current_location
	if previous != null:
		remove_child(previous)
	candidate.visible = false
	# Keep collision bodies active for safety queries; disable only room logic.
	candidate.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(candidate)
	candidate.set_process(false)
	candidate.set_physics_process(false)
	# Let old collision/navigation leave the world and new geometry synchronize.
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var navigation_errors: PackedStringArray = candidate.prepare_navigation()
	NavigationServer3D.map_force_update(get_world_3d().navigation_map)
	var anchor: SpawnAnchor = candidate.find_spawn(spawn_id)
	var errors: PackedStringArray = _placement_errors(anchor)
	errors.append_array(navigation_errors)
	if not errors.is_empty():
		remove_child(candidate)
		candidate.free()
		if previous != null:
			add_child(previous)
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().process_frame
		NavigationServer3D.map_force_update(get_world_3d().navigation_map)
		party.resume_after_travel()
		transitioning = false
		transition_finished.emit(false, errors)
		return
	party.place_at(anchor)
	await get_tree().physics_frame
	await get_tree().process_frame
	if previous != null:
		previous.free()
	current_location = candidate
	session.current_location_id = location_id
	session.current_spawn_id = spawn_id
	candidate.visible = true
	candidate.process_mode = Node.PROCESS_MODE_INHERIT
	candidate.set_process(true)
	party.resume_after_travel()
	transition_count += 1
	transitioning = false
	print("P004: arrived %s/%s; party=%d; transition=%d" % [location_id, spawn_id, party.members().size(), transition_count])
	transition_finished.emit(true, PackedStringArray())


func _placement_errors(anchor: SpawnAnchor) -> PackedStringArray:
	var errors: PackedStringArray = []
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var excluded: Array[RID] = []
	for actor: ActorPlaceholder in party.members():
		excluded.append(actor.get_rid())
	var index: int = 0
	for actor: ActorPlaceholder in party.members():
		var feet: Vector3 = anchor.global_position + Vector3.RIGHT * index * 1.0
		var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(feet + Vector3.UP * 0.2, feet + Vector3.DOWN * 0.2, 1, excluded)
		var floor_hit: Dictionary = space.intersect_ray(ray)
		if floor_hit.is_empty() or (floor_hit["normal"] as Vector3).y < 0.9:
			errors.append("spawn '%s' has no safe floor for '%s'" % [anchor.stable_id, actor.state.instance_id])
		var collider: CollisionShape3D = actor.get_node("CollisionShape3D") as CollisionShape3D
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = collider.shape
		query.transform = anchor.global_transform
		# Raise 2cm so a touching floor is not counted as an obstruction.
		query.transform.origin = feet + collider.position + Vector3.UP * 0.02
		query.collision_mask = 1
		query.exclude = excluded
		if not space.intersect_shape(query).is_empty():
			errors.append("spawn '%s' is obstructed for '%s'" % [anchor.stable_id, actor.state.instance_id])
		index += 1
	return errors
