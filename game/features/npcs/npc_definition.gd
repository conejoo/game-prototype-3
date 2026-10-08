class_name NpcDefinition
extends RefCounted
## Detached catalog view. No scene, actor state, event memory or save authority.

class Fact extends RefCounted:
	var id: String
	var category: String
	var label: String
	var description: String
	var highlight_term: String
	var availability: NpcContentAvailability
	func _init(data: Dictionary, coverage: Dictionary) -> void:
		id = data["id"]
		category = data["category"]
		label = data["label"]
		description = data["description"]
		highlight_term = data["highlightTerm"]
		availability = NpcContentAvailability.new(coverage)

class GiftRule extends RefCounted:
	var id: String
	var item_id: String
	var required_fact_id: String
	var affinity_delta: int
	var acceptance_cap: int
	var availability: NpcContentAvailability
	func _init(data: Dictionary, coverage: Dictionary) -> void:
		id = data["id"]
		item_id = data["itemId"]
		required_fact_id = data.get("requiredFactId", "")
		affinity_delta = int(data["affinityDelta"])
		acceptance_cap = int(data["acceptanceCap"])
		availability = NpcContentAvailability.new(coverage)

class Sheet extends RefCounted:
	var id: String
	var asset_path: String
	var texture_cell: Vector2i
	var frames_per_facing: int
	var step_seconds: float
	var availability: NpcContentAvailability
	func _init(sheet_id: String, data: Dictionary, coverage: Dictionary) -> void:
		id = sheet_id
		asset_path = data["asset"]
		texture_cell = Vector2i(int(data["textureCellWidth"]), int(data["textureCellHeight"]))
		frames_per_facing = int(data["framesPerFacing"])
		step_seconds = float(data["stepSeconds"])
		availability = NpcContentAvailability.new(coverage)

var id: String
var actor_id: String
var display_name: String
var short_name: String
var title: String
var pronouns: String
var interaction_prompt: String
var level_one_affinity: int
var level_one_label: String
var milestone_node_id: String
var milestone_seen_flag_id: String
var source_hit_size: Vector2
var source_interaction_radius: float
var source_agent_profile_id: String
var source_footprint_radius: float
var source_clearance: float
var action_ids: PackedStringArray
var flag_ids: PackedStringArray
var facts: Dictionary[String, Fact] = {}
var gifts: Dictionary[String, GiftRule] = {}
var portraits: Dictionary[String, String] = {}
var portrait_availability: Dictionary[String, NpcContentAvailability] = {}
var sheets: Dictionary[String, Sheet] = {}
var source_world_cell: Vector2i
var row_order: PackedStringArray
var graph: NpcDialogueGraph

func _init(package: Dictionary) -> void:
	id = package["id"]
	actor_id = package["actor_id"]
	var runtime: Dictionary = package["runtime"]
	var coverage: Dictionary = package["coverage"]
	display_name = runtime["displayName"]
	short_name = runtime["shortName"]
	title = runtime["title"]
	pronouns = runtime["pronouns"]
	interaction_prompt = runtime["interactionPrompt"]
	var relationship: Dictionary = runtime["relationship"]
	level_one_affinity = int(relationship["levelOneAffinity"])
	level_one_label = relationship["levelOneLabel"]
	var milestone: Dictionary = relationship.get("levelOneMilestone", {})
	milestone_node_id = milestone.get("dialogueNodeId", "")
	milestone_seen_flag_id = milestone.get("seenFlagId", "")
	var dimensions: Dictionary = runtime["dimensions"]
	source_hit_size = Vector2(float(dimensions["hitWidth"]), float(dimensions["hitHeight"]))
	source_interaction_radius = float(dimensions["interactionRadius"])
	var routine: Dictionary = runtime["routine"]
	var profile: Dictionary = routine["agentProfile"]
	source_agent_profile_id = profile["id"]
	source_footprint_radius = float(profile["footprintRadius"])
	source_clearance = float(profile["clearance"])
	action_ids = PackedStringArray(routine["actionIds"])
	flag_ids = PackedStringArray(routine["relationshipFlagIds"])
	for fact: Dictionary in runtime["facts"]:
		facts[fact["id"]] = Fact.new(fact, coverage["fact"][fact["id"]])
	for gift: Dictionary in runtime["acceptedGiftRules"]:
		gifts[gift["id"]] = GiftRule.new(gift, coverage["gift_rule"][gift["id"]])
	var visuals: Dictionary = package["visuals"]
	for expression: String in visuals["portraits"]:
		portraits[expression] = visuals["portraits"][expression]
		portrait_availability[expression] = NpcContentAvailability.new(coverage["portrait"][expression])
	var world: Dictionary = visuals["world"]
	source_world_cell = Vector2i(int(world["worldCellWidth"]), int(world["worldCellHeight"]))
	row_order = PackedStringArray(world["rowOrder"])
	for sheet_id: String in ["idle", "walk"]:
		sheets[sheet_id] = Sheet.new(sheet_id, world[sheet_id], coverage["sheet"][sheet_id])
	for action_id: String in world["actions"]:
		sheets[action_id] = Sheet.new(action_id, world["actions"][action_id], coverage["sheet"][action_id])
	graph = NpcDialogueGraph.new(package["dialogue"], display_name, coverage)
