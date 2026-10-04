class_name ExteriorLights
extends Node3D
## Explicit exterior composition; eight fixed, unshadowed local emitters maximum.

const KIT: PackedScene = preload("res://assets/environment/exterior_light_kit.glb")
const MAPPING: String = "res://assets/environment/exterior_light_mapping.json"
const MAX_LOCAL_LIGHTS: int = 8
const NIGHT_FACTORS: PackedFloat64Array = [0, 0, 0, .42, 1, 1, 1, .62, 0, 0]
var consumers: Dictionary[String, ExteriorLightConsumer] = {}
var build_errors: PackedStringArray = []
var emitter_count: int = 0


func build(location: AlderwakeTerrainPreview) -> void:
	name = "ExteriorLights"
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAPPING))
	if not parsed is Dictionary or parsed.get("snapshot_id") != location.layout.provenance.snapshot_id:
		build_errors.append("Exterior light mapping missing or wrong snapshot")
		return
	var kit: Node3D = KIT.instantiate()
	var meshes: Dictionary[String, Mesh] = {}
	for visual: MeshInstance3D in kit.find_children("*", "MeshInstance3D", true, false):
		var mesh: ArrayMesh = visual.mesh.duplicate() as ArrayMesh
		for index: int in range(mesh.get_surface_count()):
			var material: StandardMaterial3D = visual.get_active_material(index).duplicate() as StandardMaterial3D
			material.vertex_color_use_as_albedo = true
			mesh.surface_set_material(index, material)
		meshes[str(visual.name)] = mesh
	kit.free()
	for row: Dictionary in parsed.entries:
		var identity: Dictionary = LightSourceRegistry.find(location.location_id, row.prop_id, row.source_id)
		var wrapper: Node3D = location.town.get_node_or_null(NodePath(row.prop_id))
		if wrapper == null: wrapper = location.forest.get_node_or_null(NodePath(row.prop_id))
		if identity.is_empty() or wrapper == null or consumers.has(row.prop_id):
			build_errors.append("Unknown, duplicate or missing light wrapper: " + str(row.prop_id))
			continue
		var frame: Mesh
		var core: Mesh
		if row.kind != "windows":
			var asset: String = {"dock_lamp":"dock-lamp", "waylight":"waylight", "woven_net":"woven-net"}.get(row.kind, "")
			frame = meshes.get("GEO-W005-" + asset + "-frame")
			core = meshes.get("GEO-W005-" + asset + ("-knots" if row.kind == "woven_net" else "-core"))
			if frame == null or core == null:
				build_errors.append("Missing light kit mesh: " + asset)
				continue
		var visuals: Node3D = wrapper.get_node("VisualRoot")
		if row.kind != "windows":
			for old: Node in visuals.get_children(): old.free()
		var anchors: Node3D = Node3D.new()
		anchors.name = "ExteriorLightAnchors"
		visuals.add_child(anchors)
		var consumer: ExteriorLightConsumer = ExteriorLightConsumer.new()
		consumer.initialize(row, frame, core)
		anchors.add_child(consumer)
		consumers[row.prop_id] = consumer
		if consumer.emitter != null: emitter_count += 1
	if consumers.size() != LightSourceRegistry.entries().size() or emitter_count > MAX_LOCAL_LIGHTS:
		build_errors.append("Exterior consumers incomplete or local light budget exceeded")


func present(state: EnvironmentState, focus: Vector3) -> void:
	var factor: float = night_factor(state.day_cycle_progress)
	if factor < 0.0: return
	for consumer: ExteriorLightConsumer in consumers.values():
		consumer.present(state, factor, focus)


static func night_factor(progress: float) -> float:
	if not EnvironmentClock.validate(0, progress).is_empty(): return -1.0
	var right: int = 1
	while EnvironmentLighting.KNOTS[right] < progress: right += 1
	var left: int = right - 1
	var amount: float = smoothstep(EnvironmentLighting.KNOTS[left], EnvironmentLighting.KNOTS[right], progress)
	return lerpf(NIGHT_FACTORS[left], NIGHT_FACTORS[right], amount)
