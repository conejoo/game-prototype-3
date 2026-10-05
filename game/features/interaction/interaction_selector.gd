class_name InteractionSelector
extends RefCounted
## Nearby visible target; deterministic distance/ID order, rechecked on command.


static func select(actor: ActorPlaceholder, location: PrototypeLocation) -> PrototypeInteractable:
	if location == null or not location.is_inside_tree():
		return null
	var best: PrototypeInteractable
	var best_distance: float = INF
	for target: PrototypeInteractable in location.interactables():
		if target.is_queued_for_deletion() or not target.is_inside_tree():
			continue
		var distance: float = actor.global_position.distance_to(target.global_position)
		if distance > target.reach:
			continue
		var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			actor.global_position + Vector3.UP * 0.8, target.global_position + Vector3.UP * 0.8, 1, [actor.get_rid()])
		var hit: Dictionary = actor.get_world_3d().direct_space_state.intersect_ray(ray)
		if not hit.is_empty() and not target.accepts_sight_hit(hit.collider):
			continue
		if distance < best_distance or (is_equal_approx(distance, best_distance) and best != null and target.instance_id < best.instance_id):
			best = target
			best_distance = distance
	return best
