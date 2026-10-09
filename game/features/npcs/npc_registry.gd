class_name NpcRegistry
extends RefCounted
## N001 measured public feet. Activation belongs to N008-N015, not this registry.
const LOCATION: String = "prototype-alderwake"
const ENABLED: PackedStringArray = ["npc-01", "npc-02", "npc-03", "npc-04", "npc-06", "npc-07", "npc-08", "npc-14"]
const VISUAL_ASSETS: Dictionary = {"npc-01":"res://assets/models/npcs/npc-01-actions.glb", "npc-02":"res://assets/models/npcs/npc-02-actions.glb", "npc-03":"res://assets/models/npcs/npc-03.glb", "npc-04":"res://assets/models/npcs/npc-04.glb", "npc-06":"res://assets/models/npcs/npc-06.glb", "npc-07":"res://assets/models/npcs/npc-07.glb", "npc-08":"res://assets/models/npcs/npc-08.glb", "npc-14":"res://assets/models/npcs/npc-14.glb"}
const ROWS: Array = [
	["npc-01", Vector3(-0.5,0,-1.5), Vector3(-0.5,0,-0.5)],
	["npc-02", Vector3(1.5,0,-1.5), Vector3(2.5,0,-1.5)],
	["npc-03", Vector3(-7.5,0,11), Vector3(-6,0,11)],
	["npc-04", Vector3(41,0,17), Vector3(42.5,0,17)],
	["npc-06", Vector3(7.5,0,5), Vector3(9,0,5)],
	["npc-07", Vector3(36,0,20), Vector3(34.5,0,20)],
	["npc-08", Vector3(-3.5,0,12), Vector3(-3.5,0,13)],
	["npc-14", Vector3(-6,0,-12), Vector3(-6,0,-10.8)],
]

static func entries(location_id: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Array in ROWS:
		var row_location: String = "prototype-lantern-rest" if row[0] == "npc-14" else LOCATION
		if not location_id.is_empty() and row_location != location_id: continue
		result.append({"npc_id":row[0], "location_id":"prototype-lantern-rest" if row[0] == "npc-14" else LOCATION, "instance_id":"npc-03-counter" if row[0] == "npc-03" else "della-inn-host-01" if row[0] == "npc-14" else "alderwake-%s-contact" % row[0], "foot":row[1], "approach":row[2], "reach":1.7})
	return result

static func find(id: String) -> Dictionary:
	for entry: Dictionary in entries():
		if entry.npc_id == id: return entry
	return {}

static func enabled_for(location_id: String) -> PackedStringArray:
	var ids: PackedStringArray = []
	for entry: Dictionary in entries(location_id):
		if entry.npc_id in ENABLED: ids.append(entry.npc_id)
	return ids
