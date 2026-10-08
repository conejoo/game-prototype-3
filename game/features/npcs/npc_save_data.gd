class_name NpcSaveData
extends RefCounted
## Schema7 strict plain-data restore. Never infer history from inventory or actors.
class Result extends RefCounted:
	var state: NpcConversationState
	var errors: PackedStringArray = []

static func restore(data: Variant, catalog: NpcContentCatalog, seconds: float, items: ContentCatalog = null) -> Result:
	var result: Result = Result.new()
	if catalog == null or not catalog.initialized or not data is Dictionary or not SaveCodec._exact_fields(data, ["people", "events"]):
		return _fail(result, "conversations requires exactly people/events and validated catalog")
	if not _independent_containers(data): return _fail(result, "shared/cyclic mutable save containers")
	var people_ids: Array[String] = []; people_ids.assign(catalog.npc_ids())
	if not data.people is Dictionary or not SaveCodec._exact_fields(data.people, people_ids):
		return _fail(result, "conversations requires exactly the eight pinned people")
	var state: NpcConversationState = NpcConversationState.new()
	state.initialize(catalog)
	var events: NpcEventMemory = state.events()
	var raw: Variant = data.events
	if not raw is Dictionary or not SaveCodec._exact_fields(raw, ["last_sequence", "facts"]) or not SaveCodec._integer(raw.last_sequence, 0, NpcEventMemory.MAX_SEQUENCE) or not raw.facts is Array or raw.facts.size() > events.supported_key_count():
		return _fail(result, "invalid bounded event envelope")
	var total: int = 0
	var endpoints: Dictionary[int, float] = {}
	for value: Variant in raw.facts:
		if not value is Dictionary or not SaveCodec._exact_fields(value, ["kind", "subject_id", "target_id", "count", "first_sequence", "last_sequence", "first_active_seconds", "last_active_seconds"]):
			return _fail(result, "invalid event fields")
		var row: Dictionary = value
		if not row.kind is String or not row.subject_id is String or not (row.target_id == null or row.target_id is String):
			return _fail(result, "invalid event identity types")
		var key: String = NpcEventMemory.key(row.kind, row.subject_id, row.target_id)
		if not events._allowed.has(key) or events._facts.has(key): return _fail(result, "foreign/deferred/duplicate event key")
		for field: String in ["count", "first_sequence", "last_sequence"]:
			if not SaveCodec._integer(row[field], 1, int(raw.last_sequence)): return _fail(result, "event count/sequence out of range")
		var first: int = int(row.first_sequence)
		var last: int = int(row.last_sequence)
		var count: int = int(row.count)
		if last < first or count > last - first + 1 or ((count == 1) != (first == last)):
			return _fail(result, "event count/span mismatch")
		for field: String in ["first_active_seconds", "last_active_seconds"]:
			if not (row[field] is int or row[field] is float) or not NpcEventMemory.valid_time(float(row[field])) or float(row[field]) > seconds:
				return _fail(result, "event time out of active-session range")
		if float(row.first_active_seconds) > float(row.last_active_seconds) or (first == last and row.first_active_seconds != row.last_active_seconds):
			return _fail(result, "event time ordering mismatch")
		if endpoints.has(first) or (last != first and endpoints.has(last)): return _fail(result, "shared event sequence")
		endpoints[first] = float(row.first_active_seconds)
		endpoints[last] = float(row.last_active_seconds)
		total += count
		var saved: Dictionary = row.duplicate(true)
		for field: String in ["count", "first_sequence", "last_sequence"]: saved[field] = int(row[field])
		for field: String in ["first_active_seconds", "last_active_seconds"]: saved[field] = float(row[field])
		events._facts[key] = saved
	if total != int(raw.last_sequence) or (total > 0 and (not endpoints.has(1) or not endpoints.has(total))):
		return _fail(result, "event total/first/latest sequence mismatch")
	var ordered: Array = endpoints.keys(); ordered.sort()
	if not _feasible_counts(events._facts.values(), ordered): return _fail(result, "event spans cannot contain their declared counts")
	var latest: float = 0.0
	for sequence: int in ordered:
		if endpoints[sequence] < latest: return _fail(result, "global event time order mismatch")
		latest = endpoints[sequence]
	events._last_sequence = total
	events._last_active_seconds = latest
	state = state.with_events(events)
	for id: String in catalog.npc_ids():
		var npc: NpcDefinition = catalog.get_npc(id)
		var person: Variant = data.people[id]
		if not person is Dictionary or not SaveCodec._exact_fields(person, ["npc_id", "affinity", "level", "flags", "learned_fact_ids", "seen_node_ids", "applied_choice_ids"]) or not person.npc_id is String or person.npc_id != id:
			return _fail(result, "invalid memory identity/fields for " + id)
		if not SaveCodec._integer(person.affinity, 0, ConversationMemory.MAX_AFFINITY) or not SaveCodec._integer(person.level, 0, 1):
			return _fail(result, "invalid memory affinity/level")
		for field: String in ["flags", "learned_fact_ids", "seen_node_ids", "applied_choice_ids"]:
			if not _unique_strings(person[field]): return _fail(result, "invalid independent memory set " + field)
		var expected_facts: PackedStringArray = []
		for node_id: String in person.seen_node_ids:
			var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes.get(node_id)
			if node == null or not node.availability.is_enabled(): return _fail(result, "foreign/deferred seen node")
			for fact_id: String in node.revealed_fact_ids: ConversationMemory._add_unique(expected_facts, fact_id)
		var social: bool = false
		for rule: NpcDefinition.GiftRule in npc.gifts.values():
			var gift_count: int = events.count(NpcEventMemory.GIFT, rule.item_id, id)
			var choice_count: int = 0
			for choice: NpcDialogueGraph.Choice in npc.graph.choices.values():
				if choice.gift_rule_id == rule.id: choice_count += events.count(NpcEventMemory.CHOICE, id, choice.id)
			if gift_count != choice_count or gift_count > rule.acceptance_cap:
				return _fail(result, "gift/authored-choice total or shared cap mismatch")
			if gift_count > 0: social = true
		var expected_flags: PackedStringArray = []
		var expected_receipts: PackedStringArray = []
		var expected_affinity: int = 0
		for choice: NpcDialogueGraph.Choice in npc.graph.choices.values():
			var count: int = events.count(NpcEventMemory.CHOICE, id, choice.id)
			if count == 0: continue
			if choice.has_one_time_effect():
				if count != 1: return _fail(result, "one-time choice repeated")
				ConversationMemory._add_unique(expected_receipts, choice.id)
			for flag: String in choice.added_flags: ConversationMemory._add_unique(expected_flags, flag)
			if not choice.one_time_reward_flag.is_empty(): ConversationMemory._add_unique(expected_flags, choice.one_time_reward_flag)
			expected_affinity += choice.affinity_delta * count
			if not choice.gift_rule_id.is_empty():
				var rule: NpcDefinition.GiftRule = npc.gifts.get(choice.gift_rule_id)
				if rule == null or not rule.availability.is_enabled() or rule.affinity_delta < 0:
					return _fail(result, "invalid gift rule or ordered signed persistence required")
				expected_affinity += rule.affinity_delta * count
			# Current pin has only nonnegative deltas; reject drift rather than invent order.
			if choice.affinity_delta < 0: return _fail(result, "signed affinity requires ordered persistence policy")
			var owner_node: NpcDialogueGraph.NodeDefinition
			for node: NpcDialogueGraph.NodeDefinition in npc.graph.nodes.values():
				if choice in node.choices: owner_node = node
			if owner_node == null or owner_node.id not in person.seen_node_ids or (not social and not choice.ends_conversation and not choice.target_node_id.is_empty() and choice.target_node_id not in person.seen_node_ids):
				return _fail(result, "choice event missing authored entry/target")
		if not npc.milestone_node_id.is_empty() and npc.milestone_node_id in person.seen_node_ids:
			social = true
			ConversationMemory._add_unique(expected_flags, npc.milestone_seen_flag_id)
		# Pinned ordinary introductions are mutually exclusive, even neutral rewards.
		if expected_receipts.size() > 1: return _fail(result, "opposite introduction receipts")
		if not _same_set(person.learned_fact_ids, expected_facts) or not _same_set(person.flags, expected_flags) or not _same_set(person.applied_choice_ids, expected_receipts) or int(person.affinity) != clampi(expected_affinity, 0, ConversationMemory.MAX_AFFINITY):
			return _fail(result, "memory disclosure/reward/event derivation mismatch")
		if social:
			var error: String = _social_history(npc, person, events, seconds, items)
			if not error.is_empty(): return _fail(result, error)
		var memory: ConversationMemory = ConversationMemory.new(id)
		memory.affinity = int(person.affinity)
		if memory.level(npc.level_one_affinity) != int(person.level): return _fail(result, "derived relationship level mismatch")
		memory.flags = PackedStringArray(person.flags); memory.flags.sort()
		memory.learned_fact_ids = PackedStringArray(person.learned_fact_ids); memory.learned_fact_ids.sort()
		memory.seen_node_ids = PackedStringArray(person.seen_node_ids); memory.seen_node_ids.sort()
		memory.applied_choice_ids = PackedStringArray(person.applied_choice_ids); memory.applied_choice_ids.sort()
		state = state.with_person(memory)
	result.state = state
	return result

static func _social_history(npc: NpcDefinition, saved: Dictionary, events: NpcEventMemory, seconds: float, items: ContentCatalog) -> String:
	# Current authored caps are <=2, so first/last endpoints encode every gift.
	# Ordinary repeatable zero-effect choices need only their bounded endpoints.
	# Never expand arbitrary area/gather aggregates into per-event arrays.
	var gift_pairs: Dictionary[int, Dictionary] = {}
	for rule: NpcDefinition.GiftRule in npc.gifts.values():
		var gift: Dictionary = events._facts.get(NpcEventMemory.key(NpcEventMemory.GIFT, rule.item_id, npc.id), {})
		if gift.is_empty(): continue
		var item_id: String = NpcGiftRules.ITEM_MAPPING.get(rule.item_id, "")
		var item: ItemDefinition = items.get_item(item_id) if items != null else null
		if item == null or not item.giftable or item.source_item_id != rule.item_id or rule.acceptance_cap > 2:
			return "gift item/pinned aggregate policy unavailable"
		for occurrence: Array in _occurrences(gift): gift_pairs[int(occurrence[0]) + 1] = {"time":occurrence[1], "rule":rule.id}
	var actions: Array[Dictionary] = []
	for row: Dictionary in events._facts.values():
		if row.kind != NpcEventMemory.CHOICE or row.subject_id != npc.id:
			for occurrence: Array in _occurrences(row): actions.append({"sequence":occurrence[0], "time":occurrence[1]})
			continue
		var choice: NpcDialogueGraph.Choice = npc.graph.choices[row.target_id]
		if choice.gift_rule_id.is_empty() and row.count > 1 and (choice.affinity_delta != 0 or not choice.added_flags.is_empty()):
			return "repeated effect requires ordered persistence policy"
		for occurrence: Array in _occurrences(row):
			if not choice.gift_rule_id.is_empty():
				var pair: Dictionary = gift_pairs.get(int(occurrence[0]), {})
				if pair.is_empty() or pair.rule != choice.gift_rule_id or pair.time != occurrence[1]: return "gift/choice adjacency or timestamp mismatch"
				gift_pairs.erase(int(occurrence[0]))
			actions.append({"sequence":occurrence[0], "time":occurrence[1], "choice":choice})
	if not gift_pairs.is_empty(): return "gift missing adjacent authored choice"
	actions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.sequence < b.sequence)
	var memory: ConversationMemory = ConversationMemory.new(npc.id)
	for action: Dictionary in actions:
		var prefix: NpcEventMemory = _prefix(events, int(action.sequence) - 1)
		_enter_possible(npc, saved.seen_node_ids, memory, prefix, float(action.time))
		if not action.has("choice"):
			_enter_possible(npc, saved.seen_node_ids, memory, _prefix(events, int(action.sequence)), float(action.time))
			continue
		var choice: NpcDialogueGraph.Choice = action.choice
		var owner: NpcDialogueGraph.NodeDefinition
		for node: NpcDialogueGraph.NodeDefinition in npc.graph.nodes.values():
			if choice in node.choices: owner = node
		if owner == null or owner.id not in memory.seen_node_ids or memory.consumed(choice) or not NpcDialogueRules.matches(choice.conditions, memory, prefix, float(action.time), npc.level_one_affinity):
			return "choice prerequisite/chronology mismatch"
		var old_level: int = memory.level(npc.level_one_affinity)
		memory = memory.responded(choice)
		if not choice.gift_rule_id.is_empty():
			var rule: NpcDefinition.GiftRule = npc.gifts[choice.gift_rule_id]
			if not rule.required_fact_id.is_empty() and rule.required_fact_id not in memory.learned_fact_ids: return "gift precedes learned preference"
			memory.affinity = clampi(memory.affinity + rule.affinity_delta, 0, ConversationMemory.MAX_AFFINITY)
		var target: String = choice.target_node_id
		if not choice.ends_conversation and memory.level(npc.level_one_affinity) > old_level and not npc.milestone_node_id.is_empty() and npc.milestone_seen_flag_id not in memory.flags:
			var milestone: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[npc.milestone_node_id]
			if milestone.availability.is_enabled(): target = milestone.id
		if not choice.ends_conversation and not target.is_empty():
			if target not in saved.seen_node_ids: return "choice missing legal response/milestone entry"
			memory = _entered(npc, memory, npc.graph.nodes[target])
	_enter_possible(npc, saved.seen_node_ids, memory, events, seconds)
	if not _same_set(saved.seen_node_ids, memory.seen_node_ids) or not _same_set(saved.flags, memory.flags) or not _same_set(saved.learned_fact_ids, memory.learned_fact_ids): return "unreachable disclosure/milestone history"
	return ""

static func _occurrences(row: Dictionary) -> Array[Array]:
	var result: Array[Array] = [[int(row.first_sequence), float(row.first_active_seconds)]]
	if row.count > 1: result.append([int(row.last_sequence), float(row.last_active_seconds)])
	return result

static func _prefix(events: NpcEventMemory, sequence: int) -> NpcEventMemory:
	var prefix: NpcEventMemory = events.detached_copy()
	prefix._facts.clear()
	for key: String in events._facts:
		var row: Dictionary = events._facts[key]
		if row.first_sequence > sequence: continue
		var value: Dictionary = row.duplicate(true)
		if row.last_sequence > sequence:
			# At least first occurrence exists. All pinned preference gates require1;
			# other entry gates are checked separately at their available endpoints.
			value.count = 1
			value.last_sequence = row.first_sequence
			value.last_active_seconds = row.first_active_seconds
		prefix._facts[key] = value
	return prefix

static func _entered(npc: NpcDefinition, memory: ConversationMemory, node: NpcDialogueGraph.NodeDefinition) -> ConversationMemory:
	var result: ConversationMemory = memory.entered(node)
	if node.id == npc.milestone_node_id: ConversationMemory._add_unique(result.flags, npc.milestone_seen_flag_id)
	return result

static func _enter_possible(npc: NpcDefinition, seen: Array, memory: ConversationMemory, events: NpcEventMemory, seconds: float) -> void:
	# Saved entry nodes may have been opened/cancelled without a choice event.
	# Iterate disclosure dependencies; never grant a node absent from saved history.
	var changed: bool = true
	while changed:
		changed = false
		for id: String in seen:
			if id in memory.seen_node_ids: continue
			var node: NpcDialogueGraph.NodeDefinition = npc.graph.nodes[id]
			var allowed: bool = id in npc.graph.entry_node_ids and NpcDialogueRules.matches(node.conditions, memory, events, seconds, npc.level_one_affinity)
			for previous_id: String in memory.seen_node_ids:
				if npc.graph.nodes[previous_id].continue_target_id == id: allowed = true
			if not allowed: continue
			var entered: ConversationMemory = _entered(npc, memory, node)
			memory.seen_node_ids = entered.seen_node_ids
			memory.learned_fact_ids = entered.learned_fact_ids
			memory.flags = entered.flags
			changed = true

static func _unique_strings(value: Variant) -> bool:
	if not value is Array or value.size() > 128: return false
	var seen: Dictionary[String, bool] = {}
	for id: Variant in value:
		if not id is String or id.is_empty() or seen.has(id): return false
		seen[id] = true
	return true

static func _independent_containers(data: Dictionary) -> bool:
	var pending: Array = [data]
	var seen: Array = []
	while not pending.is_empty():
		var value: Variant = pending.pop_back()
		if not (value is Dictionary or value is Array): continue
		for previous: Variant in seen:
			if is_same(previous, value): return false
		seen.append(value)
		if seen.size() > 4096: return false
		if value is Dictionary: pending.append_array(value.values())
		else: pending.append_array(value)
	return true

static func _feasible_counts(rows: Array, endpoints: Array) -> bool:
	# Allocate unobserved occurrences into free sequence intervals, earliest deadline
	# first. Bounded by <=40 records; never loop over a potentially 2^31 sequence.
	var gaps: Array[Dictionary] = []
	for index: int in range(1, endpoints.size()):
		if endpoints[index] > endpoints[index - 1] + 1:
			gaps.append({"first":endpoints[index - 1] + 1, "last":endpoints[index] - 1})
	var jobs: Array = rows.duplicate(true)
	jobs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.last_sequence < b.last_sequence)
	for row: Dictionary in jobs:
		var required: int = int(row.count) - (1 if row.first_sequence == row.last_sequence else 2)
		for gap: Dictionary in gaps:
			var start: int = maxi(int(gap.first), int(row.first_sequence) + 1)
			var end: int = mini(int(gap.last), int(row.last_sequence) - 1)
			if start > end: continue
			var taken: int = mini(required, end - start + 1)
			# Earliest-deadline jobs cannot leave usable earlier slots stranded:
			# retain the unused prefix when a later release starts within this gap.
			if taken > 0:
				if start > int(gap.first): gaps.append({"first":gap.first,"last":start - 1})
				gap.first = start + taken
				required -= taken
			if required == 0: break
		if required > 0: return false
		gaps.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.first < b.first)
	return true

static func _same_set(value: Array, expected: PackedStringArray) -> bool:
	var actual: PackedStringArray = PackedStringArray(value); actual.sort()
	return actual == expected

static func _fail(result: Result, message: String) -> Result:
	result.errors.append(message)
	return result
