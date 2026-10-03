class_name AlderwakeForestPopulation
extends AlderwakePropGrayboxes
## M007 pinned population. Flat Y preview; exact X/Z, IDs and trunk polygons.

const SPECIES_COLORS: Dictionary[String, Color] = {
	"alder": Color(0.34, 0.47, 0.29), "birch": Color(0.56, 0.62, 0.41),
	"cherry": Color(0.63, 0.44, 0.48), "maple": Color(0.52, 0.48, 0.26),
	"oak": Color(0.37, 0.43, 0.23), "pine": Color(0.22, 0.38, 0.31),
	"rowan": Color(0.48, 0.39, 0.27), "spruce": Color(0.25, 0.35, 0.29),
	"willow": Color(0.43, 0.55, 0.35),
}
const SIZE_HEIGHTS: Dictionary[String, float] = {"small": 0.9, "standard": 1.4, "large": 1.8}
var prop_records: Array[Dictionary] = []
var marker_records: Array[Dictionary] = []
var inert_records: Array[Dictionary] = []
var species_counts: Dictionary[String, int] = {}
var size_counts: Dictionary[String, int] = {}


func build(layout: Dictionary) -> void:
	name = "ForestPopulation"
	for record: Dictionary in layout.props:
		if AlderwakeTownFootprints.retains_prop(record):
			continue
		prop_records.append(record)
		var wrapper: Node3D = _wrapper(record.id, _flat_foot(record))
		wrapper.rotation.y = deg_to_rad(float(record.yaw_degrees))
		for field: String in ["definition_id", "source", "quarter_turns", "collision_enabled", "tree", "foot_xyz_m", "light_source_states", "render_depth_offset_units"]:
			wrapper.set_meta(field, record[field])
		wrapper.set_meta("source_prop_id", record.id)
		wrapper.set_meta("source_record", record)
		var height: float = 0.6
		var color: Color = Color(0.41, 0.44, 0.42)
		if record.tree != null:
			var species: String = record.tree.species
			var size: String = record.tree.size
			if not SPECIES_COLORS.has(species) or not SIZE_HEIGHTS.has(size):
				build_errors.append("unsupported tree metadata: " + record.id)
				continue
			species_counts[species] = species_counts.get(species, 0) + 1
			size_counts[size] = size_counts.get(size, 0) + 1
			height = SIZE_HEIGHTS[size]
			color = SPECIES_COLORS[species]
		if record.collision != null:
			var outline: PackedVector2Array = _outline(record.collision.vertices_xz_m)
			footprints.append(outline)
			_add_prism(wrapper, record.collision.id, _local_outline(wrapper, outline), height, true, color)
		else:
			_add_prism(wrapper, "NonblockingFoot", _rectangle(Rect2(-0.12, -0.12, 0.24, 0.24)), 0.06, false, color)
		if record.id == "moonwell-prop":
			_label(wrapper.get_node("VisualRoot"), "MOONWELL GRAYBOX\nPHYSICAL HEIGHT M008", Vector3(0, 1.0, -0.6))
		elif record.id == "future-exit-gate-prop":
			# Disabled catalog art uses the existing source-authored collider's
			# footprint, adding no second body or sprite-sized collision.
			for collider: Dictionary in layout.colliders:
				if collider.id == "future-exit-gate":
					var r: Array = collider.rect_xz_m
					_add_prism(wrapper, "ClosedGateArt", _local_outline(wrapper, _rectangle(Rect2(r[0], r[1], r[2], r[3]))), 0.6, false, Color(0.48, 0.32, 0.23))
			_label(wrapper.get_node("VisualRoot"), "EAST TRAIL CLOSED\nNO DESTINATION", Vector3(-0.5, 1.1, 0))
	for record: Dictionary in layout.inert_objects:
		if record.kind == "marker":
			marker_records.append(record)
			var wrapper: Node3D = _wrapper(record.id, _flat_foot(record))
			wrapper.set_meta("source_marker_id", record.id)
			wrapper.set_meta("source_record", record)
			wrapper.set_meta("runtime_enabled", false)
			_add_prism(wrapper, "MarkerFoot", _rectangle(Rect2(-0.1, -0.1, 0.2, 0.2)), 0.15, false, Color(0.73, 0.65, 0.42))
			_label(wrapper.get_node("VisualRoot"), record.metadata.label, Vector3(0, 0.7, 0))
		else:
			# Routines/resources/NPCs are data only, never colliders, AI or prompts.
			inert_records.append(record)
	var entrance: Dictionary = {}
	for portal: Dictionary in layout.portals:
		if portal.id == "tollworks-entrance-01":
			entrance = portal
	if entrance.is_empty():
		build_errors.append("missing pinned Tollworks entrance")
		return
	var rect: Array = entrance.rect_xz_m
	var pad: Node3D = _wrapper(entrance.id, Vector3(float(rect[0]) + float(rect[2]) / 2, 0, float(rect[1]) + float(rect[3]) / 2))
	pad.set_meta("source_portal_id", entrance.id)
	pad.set_meta("source_record", entrance)
	pad.set_meta("runtime_enabled", false)
	_add_prism(pad, "EntrancePad", _rectangle(Rect2(-0.3, -0.3, 0.6, 0.6)), 0.027, false, Color(0.47, 0.60, 0.61))
	_label(pad.get_node("VisualRoot"), "TOLLWORKS ENTRANCE\nINACTIVE CANDIDATE · M015", Vector3(0, 0.7, 0))


static func _flat_foot(record: Dictionary) -> Vector3:
	return Vector3(record.foot_xyz_m[0], 0, record.foot_xyz_m[2])
