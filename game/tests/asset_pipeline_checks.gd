extends SceneTree
## Import and wrapper contract checks. Positioned/defeated actors are synthetic
## fixtures; rendered normal-input evidence is recorded separately for P012.

const QUEST: String = "prototype-maris-recovery"
var failures: PackedStringArray = []
var mesh_count: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for entry: Array in [["recovery_vessel", Vector3(0.6, 1.16, 0.6)], ["guardian", Vector3(0.74, 1.58, 0.43)], ["tollworks_plinth", Vector3(2, 0.6, 2)]]:
		var model: Node3D = load("res://assets/models/%s.glb" % entry[0]).instantiate()
		root.add_child(model)
		mesh_count = 0
		_audit(model)
		_check(mesh_count > 0, "Imported asset has no meshes: " + entry[0])
		var bounds: AABB = _bounds(model)
		_check(bounds.size.is_equal_approx(entry[1]) or bounds.size.distance_to(entry[1]) < 0.01, "Wrong meter scale/axis: %s %s" % [entry[0], bounds])
		_check(absf(bounds.position.y) < 0.001, "Asset origin is not ground level: " + entry[0])
		print("P012 import: ", entry[0], "; meshes=", mesh_count, "; bounds=", bounds)
		if entry[0] == "guardian":
			var visor: Node3D = _find_fragment(model, "visor")
			_check(visor != null and (visor as MeshInstance3D).get_aabb().get_center().z < -0.15, "Blender +Y did not become actor -Z forward")
		model.queue_free()
	await process_frame
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	_check(game.quests.apply(QUEST, "maris-accept-lead", "prototype-alderwake", "npc-03-counter").ok, "Lead rejected")
	game.world_host.request_transition("prototype-tollworks", "tollworks-from-alderwake")
	await game.world_host.transition_finished
	await physics_frame
	await physics_frame
	var location: PrototypeLocation = game.world_host.current_location
	var vessel: PrototypeInteractable = location.get_node("RecoveryVessel")
	var plinth: StaticBody3D = location.get_node("Plinth")
	_check(vessel.instance_id == "maris-recovery-vessel" and vessel.dialogue_id == "prototype-maris-vessel" and vessel.kind == "inspect", "Vessel stable command identity changed")
	_check(vessel.get_script() == load("res://features/interaction/interactable.gd"), "Vessel script attached to wrong owner")
	_check(game.guardian.get_script() == load("res://features/actors/actor_placeholder.gd") and game.guardian.state.instance_id == "tollworks-guardian-01", "Guardian wrapper/script/ID changed")
	_check(vessel.has_node("VisualRoot/VesselModel") and game.guardian.has_node("VisualRoot/GuardianModel") and plinth.has_node("VisualRoot/PlinthModel"), "Visuals not inside wrappers")
	var vessel_shape: BoxShape3D = vessel.get_node("Body/Collision").shape
	var plinth_shape: BoxShape3D = plinth.get_node("CollisionShape3D").shape
	var guardian_shape: CapsuleShape3D = game.guardian.get_node("CollisionShape3D").shape
	_check(vessel_shape.size == Vector3(0.7, 1.2, 0.7) and plinth_shape.size == Vector3(2, 0.6, 2), "Prop collision changed with visual import")
	_check(is_equal_approx(guardian_shape.radius, 0.35) and is_equal_approx(guardian_shape.height, 1.6), "Guardian capsule changed")
	_check(_ray_collider(game, Vector3(0, 0.3, -2), Vector3(5, 0.3, -2)) == plinth, "Plinth no longer blocks physical ray")
	_check(_ray_collider(game, Vector3(4, 0.6, 5), Vector3(4, 0.6, 2)) == vessel.get_node("Body"), "Vessel collision missing")
	_check(location.navigation_region.navigation_mesh.geometry_parsed_geometry_type == NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS, "Navigation started using imported art")
	_check(location.navigation_region.navigation_mesh.get_polygon_count() > 0, "Navigation empty")
	_check(not game.quests.apply(QUEST, "maris-open-return-path", "prototype-tollworks", vessel.instance_id).ok, "Import bypassed guardian prerequisite")
	# Synthetic death through the real actor API verifies the wrapper still routes
	# its durable source and acknowledges duplicate callbacks exactly once.
	game.guardian.receive_damage(100)
	_check(game.session.completed_effect_ids.size() == 3, "Defeat source no longer advances quest")
	game._on_guardian_defeated(game.guardian)
	_check(game.session.completed_effect_ids.size() == 3, "Defeat replay duplicated effects")
	game.player_placeholder.global_position = Vector3(2.9, 0, 2.5)
	await physics_frame
	await physics_frame
	_check(game.interact().ok and game.dialogue.definition.stable_id == "prototype-maris-vessel", "Vessel normal selector/dialogue disconnected")
	_check(game.dialogue.choose("maris-vessel-choice").ok, "Vessel choice rejected after guardian defeat")
	game._cancel_dialogue()
	_check(game.session.completed_effect_ids.size() == 4, "Recovery did not commit exactly one effect")
	game.quests.apply(QUEST, "maris-open-return-path", "prototype-tollworks", vessel.instance_id)
	_check(game.session.completed_effect_ids.size() == 4, "Recovery replay duplicated effects")
	game._set_paused(true)
	game.save_repository = SaveRepository.new("user://saves/p012-contract-%d.json" % OS.get_process_id())
	_check(game.save_run().is_empty(), "Asset-equipped boundary save failed")
	_check((await game.load_run()).is_empty(), "Asset-equipped save restore failed")
	_check(game.session.completed_effect_ids.size() == 4 and game.guardian.state.health == 0, "Restore lost progress/defeated guardian")
	game._set_paused(false)
	game.queue_free()
	await process_frame
	for failure: String in failures:
		push_error(failure)
	if failures.is_empty():
		print("P012 checks: PASS — GLB-only visuals, meter/ground/forward/material contracts, wrapper IDs/scripts, collision/nav, selector, once-only quest effects and save restore")
	quit(0 if failures.is_empty() else 1)


func _audit(node: Node) -> void:
	_check(not node is CollisionObject3D and not node is CollisionShape3D and not node is Camera3D and not node is Light3D and node.get_script() == null, "Imported model contains gameplay or studio nodes")
	if node is MeshInstance3D:
		mesh_count += 1
		for surface: int in range(node.mesh.get_surface_count()):
			_check(node.mesh.surface_get_material(surface) is StandardMaterial3D, "Missing exported PBR material")
	for child: Node in node.get_children():
		_audit(child)


func _bounds(node: Node) -> AABB:
	var result: AABB = AABB()
	if node is MeshInstance3D:
		result = node.global_transform * node.get_aabb()
	for child: Node in node.get_children():
		var child_bounds: AABB = _bounds(child)
		if child_bounds.has_volume():
			result = child_bounds if not result.has_volume() else result.merge(child_bounds)
	return result


func _find_fragment(node: Node, fragment: String) -> Node3D:
	if fragment in str(node.name).to_lower():
		return node as Node3D
	for child: Node in node.get_children():
		var found: Node3D = _find_fragment(child, fragment)
		if found != null:
			return found
	return null


func _ray_collider(game: Node3D, start: Vector3, end: Vector3) -> Object:
	var hit: Dictionary = game.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(start, end, 1))
	return hit.get("collider")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
