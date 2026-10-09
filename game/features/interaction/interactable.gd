class_name PrototypeInteractable
extends Node3D
## Gameplay identity and interaction live on wrapper, never imported visual nodes.

@export var instance_id: String = ""
@export_enum("talk", "inspect", "travel", "light", "gather", "pickup") var kind: String = "talk"
@export var prompt: String = ""
@export var dialogue_id: String = ""
@export var npc_id: String = ""
@export var light_action: LightSwitchAction
@export var foraging_action: ForagingAction
@export var portal: PortalBinding
@export_range(0.5, 3.0) var reach: float = 1.7


func validation_errors(catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	if instance_id.is_empty() or instance_id != instance_id.strip_edges():
		errors.append("interaction instance ID must be nonempty and unpadded")
	if prompt.strip_edges().is_empty():
		errors.append("interaction prompt must be nonempty")
	if kind not in ["talk", "inspect", "travel", "light", "gather", "pickup"]:
		errors.append("unknown interaction kind '%s'" % kind)
	if not is_finite(reach) or reach < 0.5 or reach > 3.0:
		errors.append("interaction reach must be 0.5..3m")
	if kind == "travel":
		if portal == null: errors.append("travel requires explicit portal binding")
		else:
			errors.append_array(portal.validation_errors())
			var destination: LocationDefinition = catalog.get_location(portal.destination_location_id)
			if destination == null or portal.arrival_id not in destination.spawn_ids: errors.append("portal destination/arrival absent")
		if light_action != null or foraging_action != null or not dialogue_id.is_empty() or not npc_id.is_empty(): errors.append("travel cannot share another action")
	elif portal != null: errors.append("portal binding requires travel kind")
	if not npc_id.is_empty() and (kind != "talk" or light_action != null or foraging_action != null):
		errors.append("NPC dialogue cannot share another action")
	if kind in ["gather", "pickup"]:
		if foraging_action == null:
			errors.append("foraging interaction requires typed action")
		else:
			errors.append_array(foraging_action.validation_errors(catalog))
			var definition: ForagingResourceDefinition = catalog.get_resource(foraging_action.resource_id)
			if instance_id != foraging_action.instance_id or (definition != null and (kind == "pickup") != catalog.get_item(definition.item_id).movable_pickup):
				errors.append("foraging wrapper operation/identity mismatch")
		if light_action != null or not dialogue_id.is_empty():
			errors.append("foraging action cannot toggle lights or start dialogue")
	elif foraging_action != null:
		errors.append("foraging action requires gather/pickup kind")
	elif kind == "light":
		if light_action == null:
			errors.append("light interaction requires a typed light action")
		else:
			errors.append_array(light_action.validation_errors())
			if instance_id != light_action.prop_id or get_parent() == null or get_parent().get_meta("source_prop_id", "") != light_action.prop_id:
				errors.append("light interaction must belong to its source prop wrapper")
		if not dialogue_id.is_empty():
			errors.append("light interaction cannot start dialogue")
	elif light_action != null:
		errors.append("light action requires light interaction kind")
	elif not npc_id.is_empty():
		var entry: Dictionary = NpcRegistry.find(npc_id)
		if kind != "talk" or entry.is_empty() or instance_id != entry.instance_id:
			errors.append("NPC contact identity mismatch")
	elif kind != "travel" and catalog.get_dialogue(dialogue_id) == null:
		errors.append("missing interaction dialogue '%s'" % dialogue_id)
	return errors


func accepts_sight_hit(collider: Node) -> bool:
	# Lamp collision is a sibling of the switch, owned by the same stable wrapper.
	var owner_node: Node = get_parent() if kind == "light" and light_action != null else self
	return owner_node != null and owner_node.is_ancestor_of(collider)


func display_prompt(state: EnvironmentState) -> String:
	if kind == "light" and light_action != null:
		return ("Turn off lamp" if state.light_enabled(light_action.location_id, light_action.prop_id, light_action.source_id) else "Turn on lamp")
	return prompt
