class_name NpcSaveFixture
extends RefCounted
## Synthetic real-service choices/events layered over complete prior durable facts.
static func populate(run: GameSession, catalog: NpcContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	var service: NpcDialogueService = NpcDialogueService.new()
	errors.append_array(service.initialize(catalog, run))
	var index: int = 0
	for id: String in catalog.npc_ids():
		run.elapsed_play_seconds += 0.6180339887498948
		if not service.begin(id, "fixture-" + id).ok: errors.append("fixture introduction " + id); continue
		var view: Dictionary = service.snapshot()
		var choices: Array = view.choices
		if choices.size() < 2: errors.append("fixture introduction choices " + id); service.cancel(); continue
		var selected: String = choices[index % 2].id
		if not service.choose(id, view.instance_id, view.node_id, view.token, selected).ok: errors.append("fixture response " + id)
		service.cancel()
		if not service.begin(id, "fixture-" + id).ok: errors.append("fixture revisit " + id)
		view = service.snapshot()
		# Follow first available authored public-fact branch when one exists.
		for choice: Dictionary in view.get("choices", []):
			if choice.available:
				if not service.choose(id, view.instance_id, view.node_id, view.token, choice.id).ok: errors.append("fixture fact branch " + id)
				break
		service.cancel()
		index += 1
	for kind: String in [NpcEventMemory.AREA, NpcEventMemory.GATHER, NpcEventMemory.AREA]:
		run.elapsed_play_seconds += 0.1234567890123456
		if not service.record_event(kind, "woods" if kind == NpcEventMemory.AREA else "moonflower", null).ok: errors.append("fixture event " + kind)
	return errors
