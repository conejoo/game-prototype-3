class_name PortalRoutes
extends RefCounted
## Detached, directed metadata only. No actor, scene, clock or travel authority.

var _edges: Dictionary = {}
var _locations: PackedStringArray = []

func initialize(locations: Array[LocationDefinition]) -> PackedStringArray:
	var errors: PackedStringArray = []
	var by_id: Dictionary = {}
	var candidate: Dictionary = {}
	for location: LocationDefinition in locations:
		if location == null or by_id.has(location.stable_id):
			errors.append("duplicate/null portal location")
			continue
		by_id[location.stable_id] = location
	for location: LocationDefinition in locations:
		if location == null: continue
		var exits: Dictionary = {}
		for binding: PortalBinding in location.portals:
			if binding == null:
				errors.append("null portal in " + location.stable_id)
				continue
			for error: String in binding.validation_errors(): errors.append("%s/%s: %s" % [location.stable_id,binding.portal_id,error])
			if binding.source_location_id != location.stable_id: errors.append("portal has wrong source location")
			if exits.has(binding.portal_id): errors.append("duplicate qualified portal " + binding.portal_id)
			var destination: LocationDefinition = by_id.get(binding.destination_location_id) as LocationDefinition
			if destination == null or binding.arrival_id not in destination.spawn_ids: errors.append("portal destination/arrival is absent: " + binding.portal_id)
			exits[binding.portal_id] = binding.snapshot()
		candidate[location.stable_id] = exits
	if errors.is_empty():
		_edges = candidate
		_locations = PackedStringArray(by_id.keys())
		_locations.sort()
	return errors

func binding(source: String, portal_id: String) -> Dictionary:
	return (_edges.get(source, {}) as Dictionary).get(portal_id, {}).duplicate(true)

func route(source: String, destination: String) -> Dictionary:
	if source not in _locations or destination not in _locations:
		return {"ok":false, "error":"unknown route location", "legs":[]}
	var queue: Array[Dictionary] = [{"location":source, "legs":[]}]
	var visited: PackedStringArray = [source]
	while not queue.is_empty():
		var current: Dictionary = queue.pop_front()
		if current.location == destination: return {"ok":true, "error":"", "legs":current.legs.duplicate(true)}
		var exits: Dictionary = _edges[current.location]
		var ids: Array = exits.keys()
		ids.sort()
		for id: String in ids:
			var edge: Dictionary = exits[id]
			if edge.destination_location_id in visited: continue
			visited.append(edge.destination_location_id)
			var legs: Array = current.legs.duplicate(true)
			legs.append(edge.duplicate(true))
			queue.append({"location":edge.destination_location_id, "legs":legs})
	return {"ok":false, "error":"no directed portal route", "legs":[]}
