class_name RoutineOccupancy
extends RefCounted
## Scene-local live bodies and exclusive stations; no durable state or navigation bake.
const CLEARANCE: float = 0.02
var _bodies: Dictionary = {}
var _stations: Dictionary = {}

func bind(id: String, body: CharacterBody3D, radius: float) -> bool:
	if id.is_empty() or not is_instance_valid(body) or not is_finite(radius) or radius <= 0: return false
	if _bodies.has(id) and _bodies[id].body.get_ref() != body: return false
	_bodies[id] = {"body":weakref(body), "radius":radius}
	return true

func release(id: String) -> void:
	_stations.erase(id)

func unbind(id: String) -> void:
	release(id)
	_bodies.erase(id)

func reserve(id: String, foot: Vector3, radius: float) -> bool:
	_prune()
	if not _bodies.has(id) or not foot.is_finite() or not is_finite(radius) or radius <= 0: return false
	for other: String in _stations:
		if other != id and _distance(foot,_stations[other].foot) < radius+_stations[other].radius+CLEARANCE: return false
	_stations[id] = {"foot":foot,"radius":radius}
	return true

func blocked(id: String, start: Vector3, end: Vector3, radius: float) -> String:
	_prune()
	var ids: Array = _bodies.keys()
	ids.sort()
	for other: String in ids:
		if other == id: continue
		var body: CharacterBody3D = _bodies[other].body.get_ref()
		var point: Vector2 = Vector2(body.global_position.x,body.global_position.z)
		var nearest: Vector2 = Geometry2D.get_closest_point_to_segment(point,Vector2(start.x,start.z),Vector2(end.x,end.z))
		if point.distance_to(nearest) < radius+_bodies[other].radius+CLEARANCE and absf(body.global_position.y-start.y) < 1.6: return other
	return ""

func snapshot() -> Dictionary:
	_prune()
	return {"bodies":_bodies.size(),"reservations":_stations.duplicate(true)}

func footprint(id: String) -> Dictionary:
	_prune()
	if not _bodies.has(id): return {}
	var body: CharacterBody3D = _bodies[id].body.get_ref()
	return {"foot":body.global_position,"radius":_bodies[id].radius,"moving":body.get_meta("routine_moving",false)}

func clear() -> void:
	_bodies.clear()
	_stations.clear()

func _prune() -> void:
	for id: String in _bodies.keys():
		var body: Variant = _bodies[id].body.get_ref()
		if not is_instance_valid(body) or not body.is_inside_tree() or body.is_queued_for_deletion(): unbind(id)

static func _distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x-b.x,a.z-b.z).length()
