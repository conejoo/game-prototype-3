class_name PrototypeLocation
extends Node3D
## Compact location presentation. One prototype travel gate; no quest authority.

@export var location_id: String = ""
@export var destination_id: String = ""
@export var destination_spawn_id: String = ""
@export var gate_label: String = ""
const GATE_RADIUS: float = 1.6
var navigation_region: NavigationRegion3D


func _ready() -> void:
	# Compact rooms explicitly identify their floor; props remain blockers only.
	var floor_body: StaticBody3D = get_node_or_null("Floor") as StaticBody3D
	if floor_body != null:
		floor_body.set_meta("aim_ground", true)


func prepare_navigation() -> PackedStringArray:
	# Tiny grayboxes bake from gameplay collision, never from replaceable art.
	if navigation_region != null:
		return PackedStringArray()
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_collision_mask = 1
	mesh.cell_size = 0.2
	mesh.cell_height = 0.1
	mesh.agent_radius = 0.4
	mesh.agent_height = 1.6
	mesh.agent_max_climb = 0.1
	var geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, geometry, self)
	NavigationServer3D.bake_from_source_geometry_data(mesh, geometry)
	if mesh.get_polygon_count() == 0:
		return PackedStringArray(["location '%s' has no walkable navigation" % location_id])
	navigation_region = NavigationRegion3D.new()
	navigation_region.navigation_mesh = mesh
	add_child(navigation_region)
	return PackedStringArray()


func find_spawn(id: String) -> SpawnAnchor:
	for child: Node in $Spawns.get_children():
		if child is SpawnAnchor and child.stable_id == id:
			return child as SpawnAnchor
	return null


func validation_errors(definition: LocationDefinition, catalog: ContentCatalog) -> PackedStringArray:
	var errors: PackedStringArray = []
	if location_id != definition.stable_id:
		errors.append("scene location ID differs from definition '%s'" % definition.stable_id)
	if not has_node("Spawns"):
		return PackedStringArray(["location '%s' has no Spawns container" % location_id])
	var seen: PackedStringArray = []
	for child: Node in $Spawns.get_children():
		if not child is SpawnAnchor:
			errors.append("Spawns children must be SpawnAnchor")
			continue
		var anchor: SpawnAnchor = child as SpawnAnchor
		if anchor.stable_id.is_empty() or anchor.stable_id in seen or not anchor.stable_id in definition.spawn_ids:
			errors.append("invalid, duplicate or undeclared spawn '%s'" % anchor.stable_id)
		seen.append(anchor.stable_id)
	for id: String in definition.spawn_ids:
		if not id in seen:
			errors.append("declared spawn '%s' missing from scene" % id)
	if not destination_id.is_empty():
		var destination: LocationDefinition = catalog.get_location(destination_id)
		if destination == null or not destination_spawn_id in destination.spawn_ids:
			errors.append("gate destination '%s/%s' is absent" % [destination_id, destination_spawn_id])
		if not has_node("TravelGate"):
			errors.append("travel gate marker missing")
	var interactions_seen: PackedStringArray = []
	for target: PrototypeInteractable in interactables():
		if target.light_action != null and target.light_action.location_id != location_id:
			errors.append("light action location differs from owning location")
		for error: String in target.validation_errors(catalog):
			errors.append("interaction '%s': %s" % [target.instance_id, error])
		if target.instance_id in interactions_seen:
			errors.append("duplicate interaction instance '%s'" % target.instance_id)
		interactions_seen.append(target.instance_id)
	return errors


func interactables() -> Array[PrototypeInteractable]:
	var targets: Array[PrototypeInteractable] = []
	_collect_interactables(self, targets)
	return targets


func _collect_interactables(parent: Node, targets: Array[PrototypeInteractable]) -> void:
	for child: Node in parent.get_children():
		if child is PrototypeInteractable:
			targets.append(child as PrototypeInteractable)
		_collect_interactables(child, targets)


func can_travel(actor: ActorPlaceholder) -> bool:
	return not destination_id.is_empty() and actor.global_position.distance_to($TravelGate.global_position) <= GATE_RADIUS
