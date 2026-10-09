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
var enabled_npcs: PackedStringArray = NpcRegistry.ENABLED
var routine_execution: RoutineExecutionDirector


func initialize(content: ContentCatalog, run: GameSession, persistent_party: PrototypeParty) -> void:
	catalog = content
	session = run
	party = persistent_party


func request_transition(location_id: String, spawn_id: String, restored_run: GameSession = null) -> PackedStringArray:
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
	var facts_run: GameSession = restored_run if restored_run != null else session
	var routine_stage: Dictionary = {}
	if routine_execution != null:
		routine_stage = routine_execution.stage(facts_run)
		if not routine_stage.ok:
			candidate.free()
			return [routine_stage.error]
	var errors: PackedStringArray = candidate.prepare_npcs(enabled_npcs,routine_execution.placements(routine_stage,location_id) if routine_execution != null else {},routine_execution != null)
	errors.append_array(candidate.validation_errors(definition, catalog))
	if not errors.is_empty():
		candidate.free()
		return errors
	# Lock synchronously: a second request/input cannot race the deferred load.
	transitioning = true
	party.suspend_for_travel()
	transition_started.emit()
	_replace_location.call_deferred(candidate, location_id, spawn_id, facts_run, routine_stage)
	return PackedStringArray()


func npc_portal_route(source: String, destination: String) -> Dictionary:
	var routes: PortalRoutes = PortalRoutes.new()
	var errors: PackedStringArray = routes.initialize(catalog.location_definitions())
	if not errors.is_empty(): return {"ok":false, "error":"; ".join(errors), "legs":[]}
	return routes.route(source, destination)


func request_portal(contact: WeakRef) -> PackedStringArray:
	if transitioning: return PackedStringArray(["transition already in progress"])
	var target: PrototypeInteractable = contact.get_ref() as PrototypeInteractable if contact != null else null
	if current_location == null or not is_instance_valid(target) or target.is_queued_for_deletion() or not current_location.is_ancestor_of(target) or target not in current_location.interactables():
		return PackedStringArray(["stale/foreign portal interaction"])
	if target.kind != "travel" or target.portal == null: return PackedStringArray(["explicit travel portal required"])
	var errors: PackedStringArray = target.validation_errors(catalog)
	var routes: PortalRoutes = PortalRoutes.new()
	errors.append_array(routes.initialize(catalog.location_definitions()))
	if target.portal.source_location_id != current_location.location_id or target.portal.source_location_id != session.current_location_id:
		errors.append("portal source differs from active location")
	if routes.binding(current_location.location_id, target.portal.portal_id) != target.portal.snapshot(): errors.append("portal binding differs from authored route")
	if not errors.is_empty(): return errors
	return request_transition(target.portal.destination_location_id, target.portal.arrival_id)


func _replace_location(candidate: PrototypeLocation, location_id: String, spawn_id: String, facts_run: GameSession, routine_stage: Dictionary = {}) -> void:
	var previous: PrototypeLocation = current_location
	if previous != null:
		remove_child(previous)
	# At most one rod placement. Validate foreign-room geometry while old room is
	# detached; synchronize/dispose the probe before candidate arrival geometry.
	var fact_errors: PackedStringArray = []
	for record: Dictionary in facts_run.foraging.snapshot().world_item_placements:
		if record.location_id != location_id:
			fact_errors.append_array(await _foreign_placement_errors(ForagingSaveData.from_record(record)))
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
	if navigation_errors.is_empty():
		navigation_errors.append_array(await _synchronize_navigation(candidate, anchor))
	var errors: PackedStringArray = _placement_errors(anchor)
	errors.append_array(navigation_errors)
	errors.append_array(fact_errors)
	if errors.is_empty():
		var excluded: Array[RID] = []
		for actor: ActorPlaceholder in party.members(): excluded.append(actor.get_rid())
		errors.append_array(candidate.npc_contacts.placement_errors(candidate, excluded))
	if errors.is_empty():
		for record: Dictionary in facts_run.foraging.snapshot().world_item_placements:
			if record.location_id == location_id:
				errors.append_array(ForagingPlacementGeometry.validate(candidate, ForagingSaveData.from_record(record)))
	if not errors.is_empty():
		remove_child(candidate)
		candidate.free()
		if previous != null:
			add_child(previous)
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().process_frame
		NavigationServer3D.map_force_update(get_world_3d().navigation_map)
		if previous != null:
			await _synchronize_navigation(previous, previous.find_spawn(session.current_spawn_id))
		party.resume_after_travel()
		transitioning = false
		if routine_execution != null and previous != null: routine_execution.bind_location(previous)
		transition_finished.emit(false, errors)
		return
	party.place_at(anchor)
	await get_tree().physics_frame
	await get_tree().process_frame
	if previous != null:
		previous.free()
	current_location = candidate
	facts_run.current_location_id = location_id
	facts_run.current_spawn_id = spawn_id
	candidate.visible = true
	candidate.process_mode = Node.PROCESS_MODE_INHERIT
	candidate.set_process(true)
	party.resume_after_travel()
	transition_count += 1
	transitioning = false
	if routine_execution != null: routine_execution.commit(routine_stage,facts_run,candidate)
	print("P004: arrived %s/%s; party=%d; transition=%d" % [location_id, spawn_id, party.members().size(), transition_count])
	transition_finished.emit(true, PackedStringArray())


func _synchronize_navigation(location: PrototypeLocation, anchor: SpawnAnchor) -> PackedStringArray:
	# A force-update request alone does not mean an asynchronous full-map region
	# is queryable. Keep the party suspended until this exact region owns the
	# anchor query. Apply the same barrier when restoring the previous scene.
	var map: RID = get_world_3d().navigation_map
	if location.navigation_region == null or anchor == null:
		return PackedStringArray(["location navigation/anchor unavailable"])
	for attempt: int in range(120):
		NavigationServer3D.map_force_update(map)
		if NavigationServer3D.map_get_iteration_id(map) > 0 and NavigationServer3D.map_get_closest_point_owner(map, anchor.global_position) == location.navigation_region.get_rid():
			return PackedStringArray()
		await get_tree().physics_frame
	return PackedStringArray(["location '%s' navigation did not synchronize" % location.location_id])


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


func _foreign_placement_errors(placed: WorldItemPlacement) -> PackedStringArray:
	var definition: LocationDefinition = catalog.get_location(placed.location_id)
	var packed: PackedScene = load(definition.scene_path) as PackedScene
	var probe: PrototypeLocation = packed.instantiate() as PrototypeLocation if packed != null else null
	if probe == null: return PackedStringArray(["placement room unavailable"])
	if not developer_fixtures:
		for child: Node in probe.get_children():
			if child.is_in_group("developer_fixture"): child.free()
	probe.visible = false
	# Foreign placement audit is a bounded probe, never an NPC simulation world.
	var npc_errors: PackedStringArray = probe.prepare_npcs([] if routine_execution != null else enabled_npcs)
	probe.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(probe)
	probe.set_process(false)
	probe.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var errors: PackedStringArray = npc_errors
	errors.append_array(probe.validation_errors(definition, catalog))
	if errors.is_empty(): errors.append_array(probe.prepare_navigation())
	if errors.is_empty(): errors.append_array(await _synchronize_navigation(probe, probe.find_spawn(definition.spawn_ids[0])))
	if errors.is_empty(): errors.append_array(ForagingPlacementGeometry.validate(probe, placed))
	remove_child(probe)
	probe.free()
	await get_tree().physics_frame
	await get_tree().physics_frame
	return errors
