class_name RoutineExecutionWorld
extends RefCounted
## Qualified public metadata only. Never instantiate an unloaded physics world.
const TOWN: String = "prototype-alderwake"
const HOME: String = "prototype-mayor-vale-home"
const INN: String = "prototype-lantern-rest"
var routes: PortalRoutes = PortalRoutes.new()
var _anchors: Dictionary = {}
var _doors: Dictionary = {}
var _arrivals: Dictionary = {}

func initialize(content: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = routes.initialize(content.location_definitions())
	if not errors.is_empty(): return errors
	for row: Dictionary in RoutineExteriorRegistry.anchors():
		_anchors[TOWN+"/"+row.anchor_id] = row.duplicate(true)
	for site: Dictionary in RoutineExteriorRegistry.entrances():
		_doors[TOWN+"/"+site.portal_id] = site.player_approach
		_arrivals[TOWN+"/"+site.return_arrival_id] = site.return_foot
	for pair: Array in [[HOME,"mayor_vale_home"],[INN,"lantern_rest"]]:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/maps/"+pair[1]+".json"))
		for row: Dictionary in data.anchors:
			_anchors[pair[0]+"/"+row.anchor_id] = {"location_id":pair[0],"anchor_id":row.anchor_id,"foot":_v(row.foot),"facing":_facing(row.facing)}
		_doors[pair[0]+"/"+data.exit.portal_id] = _v(data.exit.player_approach)
		_arrivals[pair[0]+"/"+data.arrival.id] = _v(data.arrival.foot)
	return []

func anchor(map_id: String, id: String) -> Dictionary:
	return _anchors.get(map_id+"/"+id,{}).duplicate(true)

func chain(source: String, destination: String) -> Dictionary:
	var result: Dictionary = routes.route(source,destination)
	if not result.ok: return result
	for edge: Dictionary in result.legs:
		if not _doors.has(edge.source_location_id+"/"+edge.portal_id) or not _arrivals.has(edge.destination_location_id+"/"+edge.arrival_id):
			return {"ok":false,"error":"NPC portal has no measured door/arrival","legs":[]}
	return result

func door(edge: Dictionary) -> Vector3:
	return _doors.get(edge.source_location_id+"/"+edge.portal_id,Vector3.INF)

func arrival(edge: Dictionary) -> Vector3:
	return _arrivals.get(edge.destination_location_id+"/"+edge.arrival_id,Vector3.INF)

func origin(routine_id: String, npc_id: String) -> Dictionary:
	# Latest guaranteed predecessor station, rather than coordinates borrowed from
	# whichever room happens to be loaded. No day-by-day historical replay.
	var previous: String = ""
	if npc_id in ["npc-01","npc-02"]:
		var prefix: String = "edric" if npc_id == "npc-01" else "helena"
		match routine_id:
			"vale-overnight-home": previous = prefix+"-evening-seat"
			"vale-breakfast": previous = prefix+"-rest"
			"vale-morning-work": previous = prefix+"-breakfast"
			"vale-evening-home":
				if npc_id == "npc-02": previous = "helena-archive-desk"
			"helena-afternoon-archive", "helena-afternoon-ledger-review", "helena-afternoon-moonflower-records", "helena-evening-archive": previous = "helena-archive-desk"
		if not previous.is_empty():
			var row: Dictionary = anchor(HOME,previous)
			return {"map":HOME,"foot":row.foot}
	var record: Dictionary = NpcRegistry.find(npc_id)
	return {"map":record.location_id,"foot":record.foot}

static func _v(value: Array) -> Vector3: return Vector3(value[0],value[1],value[2])
static func _facing(value: String) -> Vector3:
	return {"north":Vector3.FORWARD,"south":Vector3.BACK,"east":Vector3.RIGHT,"west":Vector3.LEFT}[value]
