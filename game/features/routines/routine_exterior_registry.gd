class_name RoutineExteriorRegistry
extends RefCounted
## Qualified, detached exterior metadata. No actors, travel or routine activation.
## Source X/Z remain exact; elevations are measured on the pinned exterior.
const LOCATION: String = "prototype-alderwake"
const ROWS: Array = [
	["celia-basic-repairs-01", Vector3(-3.5,0,12), Vector3.LEFT, Vector3(-3.5,0,13), "npc-08"],
	["edric-market-rounds", Vector3(-2,0,2), Vector3.BACK, Vector3(-2,0,3.1), "npc-01"],
	["edric-rain-shelter", Vector3(4,0,-5.5), Vector3.BACK, Vector3(4,0,-4.4), "npc-01"],
	["edric-river-bank", Vector3(15,0,1.5), Vector3.RIGHT, Vector3(16.1,0,1.5), "npc-01"],
	["edric-town-square", Vector3(-0.5,0,-1.5), Vector3.BACK, Vector3(-0.5,0,-0.6), "npc-01"],
	["harlan-sluice-practice-01", Vector3(41,0,17), Vector3.BACK, Vector3(42.5,0,17), "npc-04"],
	["helena-town-square", Vector3(1.5,0,-1.5), Vector3.LEFT, Vector3(2.5,0,-1.5), "npc-02"],
	["maris-fitting-01", Vector3(-7.5,0,11), Vector3.RIGHT, Vector3(-6,0,11), "npc-03"],
	["passenger-booking-ivo-01", Vector3(36,0,20), Vector3.LEFT, Vector3(34.5,0,20), "npc-07"],
	["passenger-salvage-handoff-01", Vector3(31,0,20), Vector3.RIGHT, Vector3(32.1,0,20), "npc-07"],
	["store-service-tess-01", Vector3(7.5,0,5), Vector3.RIGHT, Vector3(9,0,5), "npc-06"],
]

static func anchors(location_id: String = LOCATION) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if location_id != LOCATION: return result
	for row: Array in ROWS:
		result.append({"location_id":LOCATION, "anchor_id":row[0], "foot":row[1],
			"facing":row[2], "player_approach":row[3], "npc_id":row[4]})
	return result

static func find(location_id: String, anchor_id: String) -> Dictionary:
	for entry: Dictionary in anchors(location_id):
		if entry.anchor_id == anchor_id: return entry
	return {}

static func entrances(location_id: String = LOCATION) -> Array[Dictionary]:
	if location_id != LOCATION: return []
	# Return from home moves 0.9m south from source (4,-5.5), clearing the
	# unchanged rain-shelter NPC capsule by 0.15m with a 0.35m hero capsule.
	return [
		{"portal_id":"mayor-vale-home-entrance", "source_location_id":LOCATION,
			"destination_location_id":"prototype-mayor-vale-home",
			"arrival_id":"mayor-vale-home-from-alderwake", "enabled":true,
			"foot":Vector3(5,0,-6.25), "facing":Vector3.FORWARD,
			"player_approach":Vector3(5,0,-5.15), "ally_approach":Vector3(5,0,-3.95),
			"return_portal_id":"mayor-vale-home-exit", "return_arrival_id":"alderwake-from-mayor-vale-home",
			"source_return_foot":Vector3(4,0,-5.5), "return_foot":Vector3(4,0,-4.6),
			"return_ally_foot":Vector3(5,0,-4.6), "return_facing":Vector3.BACK},
		{"portal_id":"lantern-rest-entrance-01", "source_location_id":LOCATION,
			"destination_location_id":"prototype-lantern-rest",
			"arrival_id":"lantern-rest-from-alderwake", "enabled":false,
			"foot":Vector3(-7,0,4.25), "facing":Vector3.FORWARD,
			"player_approach":Vector3(-7,0,5.35), "ally_approach":Vector3(-7,0,6.55),
			"return_portal_id":"lantern-rest-exit-01", "return_arrival_id":"alderwake-from-lantern-rest",
			"source_return_foot":Vector3(-11.5,0,4.5), "return_foot":Vector3(-11.5,0,4.5),
			"return_ally_foot":Vector3(-10.5,0,4.5), "return_facing":Vector3.BACK},
	]

static func entrance(location_id: String, portal_id: String) -> Dictionary:
	for entry: Dictionary in entrances(location_id):
		if entry.portal_id == portal_id: return entry
	return {}
