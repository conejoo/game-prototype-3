class_name FishingTargetPreview
extends Node3D
## Transient snapshot-only view. Root calls refresh while targeting and revalidate
## at cast with current context. This view never dispatches a cast or stores facts.

var marker: MeshInstance3D
var caption: Label3D
var _snapshot: Dictionary = {}
var _material: StandardMaterial3D

func _init() -> void:
	name = "FishingTargetPreview"
	visible = false
	marker = MeshInstance3D.new()
	var mesh: TorusMesh = TorusMesh.new()
	mesh.inner_radius = 0.22
	mesh.outer_radius = 0.28
	mesh.rings = 24
	mesh.ring_segments = 8
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker.mesh = mesh
	marker.material_override = _material
	marker.position.y = 0.025
	add_child(marker)
	caption = Label3D.new()
	caption.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	caption.font_size = 32
	caption.outline_size = 8
	caption.pixel_size = 0.018
	caption.position.y = 0.65
	add_child(caption)


func refresh(location: Node3D, catalog: ContentCatalog, camera: Camera3D,
		pointer: Vector2, player_foot: Vector3, pointer_allowed: bool,
		rod: RodActivationDefinition) -> FishingWaterTargetResolver.Result:
	var result: FishingWaterTargetResolver.Result = FishingWaterTargetResolver.from_pointer(location, catalog, camera, pointer, player_foot, pointer_allowed, rod)
	present(result)
	return result


func revalidate(location: Node3D, catalog: ContentCatalog, camera: Camera3D,
		pointer: Vector2, player_foot: Vector3, pointer_allowed: bool,
		rod: RodActivationDefinition) -> FishingWaterTargetResolver.Result:
	# Never authorize from a previous snapshot (player/ray/UI/world may change).
	return refresh(location, catalog, camera, pointer, player_foot, pointer_allowed, rod)


func present(result: FishingWaterTargetResolver.Result) -> void:
	if result == null:
		clear()
		return
	_snapshot = result.snapshot()
	visible = result.has_point
	if visible: global_position = result.point
	var color: Color = Color(0.95, 0.35, 0.3)
	if result.status == "eligible":
		color = Color(0.3, 1.0, 0.65)
		caption.text = "Cast here · %.1fm" % result.distance_m
	elif result.status == "no_area":
		color = Color(1.0, 0.8, 0.25)
		caption.text = "No fishing area"
	else:
		var descriptions: Dictionary = {"dry_structure":"Dry deck / bridge", "dry_land":"Aim at open water", "out_of_range":"Beyond 12m", "solid_occlusion":"Cast blocked"}
		caption.text = descriptions.get(result.reason, "Cannot cast")
	_material.albedo_color = color
	caption.modulate = color


func snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func clear() -> void:
	visible = false
	_snapshot.clear()
	caption.text = ""
