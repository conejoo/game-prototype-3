class_name NpcDialogueGraph
extends RefCounted
## Detached typed view of a validated finite graph. IDs/order/text stay authored.

class EventCondition extends RefCounted:
	enum Kind { AREA_ENTERED, RESOURCE_GATHERED, ITEM_GIFTED, DIALOGUE_CHOICE_SELECTED }
	var kind: Kind
	# Null is an exact event key component, not a wildcard.
	var subject_id: Variant
	var target_id: Variant
	var minimum_count: int
	var maximum_count: int = -1
	var occurred_within_active_seconds: float = -1.0
	func _init(data: Dictionary) -> void:
		kind = ["areaEntered", "resourceGathered", "itemGifted", "dialogueChoiceSelected"].find(data["kind"]) as Kind
		subject_id = data.get("subjectId")
		target_id = data.get("targetId")
		minimum_count = int(data.get("minimumCount", 1))
		maximum_count = int(data["maximumCount"]) if data.has("maximumCount") else -1
		occurred_within_active_seconds = float(data.get("occurredWithinActiveSeconds", -1.0))

class Conditions extends RefCounted:
	var required_flags: PackedStringArray
	var excluded_flags: PackedStringArray
	var required_fact_ids: PackedStringArray
	var unknown_fact_ids: PackedStringArray
	var required_seen_node_ids: PackedStringArray
	var unseen_node_ids: PackedStringArray
	var minimum_affinity: int = -1
	var maximum_affinity: int = -1
	var minimum_relationship_level: int = 0
	var events: Array[EventCondition] = []
	func _init(data: Dictionary) -> void:
		required_flags = PackedStringArray(data.get("requiredFlags", []))
		excluded_flags = PackedStringArray(data.get("excludedFlags", []))
		required_fact_ids = PackedStringArray(data.get("requiredFactIds", []))
		unknown_fact_ids = PackedStringArray(data.get("unknownFactIds", []))
		required_seen_node_ids = PackedStringArray(data.get("requiredSeenNodeIds", []))
		unseen_node_ids = PackedStringArray(data.get("unseenNodeIds", []))
		minimum_affinity = int(data.get("minimumAffinity", -1))
		maximum_affinity = int(data.get("maximumAffinity", -1))
		minimum_relationship_level = int(data.get("minimumRelationshipLevel", 0))
		for event: Dictionary in data.get("events", []):
			events.append(EventCondition.new(event))

class Choice extends RefCounted:
	var id: String
	var text: String
	var target_node_id: String
	var ends_conversation: bool
	var affinity_delta: int
	var one_time: bool
	var one_time_reward_flag: String
	var added_flags: PackedStringArray
	var outcome_tag: String
	var gift_rule_id: String
	var conditions: Conditions
	var availability: NpcContentAvailability
	var command: Dictionary = {}
	func _init(data: Dictionary, coverage: Dictionary) -> void:
		id = data["id"]
		text = data["text"]
		target_node_id = data.get("targetNodeId", "")
		ends_conversation = data.get("endsConversation", false)
		affinity_delta = int(data.get("affinityDelta", 0))
		one_time = data.get("oneTime", false)
		one_time_reward_flag = data.get("oneTimeRewardFlag", "")
		added_flags = PackedStringArray(data.get("addedFlags", []))
		outcome_tag = data.get("outcomeTag", "")
		gift_rule_id = data.get("giftRuleId", "")
		conditions = Conditions.new(data.get("conditions", {}))
		availability = NpcContentAvailability.new(coverage)
		command = data.get("command", {}).duplicate(true)
	func has_one_time_effect() -> bool:
		return one_time or not one_time_reward_flag.is_empty()

class NodeDefinition extends RefCounted:
	var id: String
	var npc_id: String
	var speaker: String
	var text: String
	var priority: int
	var portrait_id: String
	var conditions: Conditions
	var revealed_fact_ids: PackedStringArray
	var choices: Array[Choice] = []
	var continue_target_id: String
	var presentation_index: int = 0
	var availability: NpcContentAvailability
	func _init(data: Dictionary, owner_id: String, owner_name: String, coverage: Dictionary) -> void:
		id = data["id"]
		npc_id = owner_id
		speaker = owner_name
		text = data["text"]
		priority = int(data.get("priority", 0))
		portrait_id = data.get("portraitId", "official-neutral")
		conditions = Conditions.new(data.get("conditions", {}))
		revealed_fact_ids = PackedStringArray(data.get("revealedFactIds", []))
		continue_target_id = data.get("continueTargetId", "")
		presentation_index = int(data.get("presentationIndex", 0))
		availability = NpcContentAvailability.new(coverage["node"][id])
		for choice: Dictionary in data.get("choices", []):
			choices.append(Choice.new(choice, coverage["choice"][choice["id"]]))
	func is_terminal() -> bool:
		return choices.is_empty() and continue_target_id.is_empty()

var npc_id: String
var entry_node_ids: PackedStringArray
var nodes: Dictionary[String, NodeDefinition] = {}
var choices: Dictionary[String, Choice] = {}

func _init(data: Dictionary, speaker: String, coverage: Dictionary) -> void:
	npc_id = data["npcId"]
	entry_node_ids = PackedStringArray(data["entryNodeIds"])
	for row: Dictionary in data["nodes"]:
		var node: NodeDefinition = NodeDefinition.new(row, npc_id, speaker, coverage)
		nodes[node.id] = node
		for choice: Choice in node.choices:
			choices[choice.id] = choice
