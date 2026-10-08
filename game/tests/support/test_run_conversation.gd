class_name TestRunConversation
extends RefCounted
## Fixture commands always carry the current finite graph identity/token.
static func choose(service: NpcDialogueService, id: String) -> NpcDialogueService.Result:
	var view: Dictionary = service.snapshot()
	if view.is_empty(): return NpcDialogueService.Result.new(false, "No conversation.")
	return service.choose(view.npc_id, view.instance_id, view.node_id, view.token, id)

static func advance(service: NpcDialogueService) -> NpcDialogueService.Result:
	var view: Dictionary = service.snapshot()
	if view.is_empty(): return NpcDialogueService.Result.new(false, "No conversation.")
	return service.advance(view.npc_id, view.instance_id, view.node_id, view.token)

static func mutate(content: ConversationDefinition, change: Callable) -> void:
	var data: Dictionary = content.document()
	change.call(data)
	content.graph_json = JSON.stringify(data)
