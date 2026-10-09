class_name TestRunRoutines
extends RefCounted
## Scheduled-access oracle: real active map and one owner, never fixed duplicates.
static func loaded_ids(game: Node3D) -> PackedStringArray:
	var ids: PackedStringArray = []
	var positions: Dictionary = game.routine_execution.snapshot().positions
	for id: String in positions:
		if positions[id].map == game.session.current_location_id and id in game.world_host.enabled_npcs: ids.append(id)
	ids.sort()
	return ids

static func contacts_match(game: Node3D) -> bool:
	var adapter: NpcWorldAdapter = game.world_host.current_location.npc_contacts
	var actual: PackedStringArray = PackedStringArray(adapter.targets.keys()); actual.sort()
	if actual != loaded_ids(game) or game.party.members().size() != 2: return false
	for id: String in actual:
		var target: PrototypeInteractable = adapter.targets[id]
		if target.npc_id != id or target.instance_id != NpcRegistry.find(id).instance_id: return false
		if target.has_method("receive_damage") or target.is_in_group("combatants"): return false
		if not adapter.movers.has(id) or not adapter.presenters.has(id): return false
	return true
