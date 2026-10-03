class_name AlderwakeTownFootprints
extends AlderwakePropGrayboxes
## M006 town/dock grayboxes. Pinned world polygons own physics; art is replaceable.

var prop_records: Array[Dictionary] = []
var collider_records: Array[Dictionary] = []
var portal_pads: Dictionary[String, Vector3] = {}
var dock_decks: Dictionary[String, PackedVector2Array] = {}


static func retains_prop(record: Dictionary) -> bool:
	# Trees, including town trees, belong to M007. Passenger basin is a town dock.
	return record.tree == null and (float(record.foot_xyz_m[0]) < 25.0 or str(record.id).begins_with("passenger-"))


func build(layout: Dictionary) -> void:
	name = "TownFootprints"
	var definitions: Dictionary = {}
	for definition: Dictionary in layout.catalog_reference:
		definitions[definition.id] = definition
	for record: Dictionary in layout.props:
		if not retains_prop(record):
			continue
		prop_records.append(record)
		var foot: Vector3 = Vector3(record.foot_xyz_m[0], record.foot_xyz_m[1], record.foot_xyz_m[2])
		var wrapper: Node3D = _wrapper(record.id, foot)
		wrapper.rotation.y = deg_to_rad(float(record.yaw_degrees))
		wrapper.set_meta("source_prop_id", record.id)
		wrapper.set_meta("definition_id", record.definition_id)
		wrapper.set_meta("source", record.source)
		wrapper.set_meta("quarter_turns", record.quarter_turns)
		wrapper.set_meta("collision_enabled", record.collision_enabled)
		var definition: Dictionary = definitions[record.definition_id]
		if record.collision != null:
			var outline: PackedVector2Array = _outline(record.collision.vertices_xz_m)
			footprints.append(outline)
			var local: PackedVector2Array = _local_outline(wrapper, outline)
			var height: float = 1.0 if definition.kind == "structure" else 0.6
			_add_prism(wrapper, record.collision.id, local, height, true,
				Color(0.53, 0.43, 0.34) if definition.kind == "structure" else Color(0.39, 0.42, 0.38))
		elif record.definition_id in ["dock-junction", "dock-straight"]:
			# Named, user-approved floor/cutout geometry. Never a sprite blocker.
			# Art adaptation follows straight bars / T junction, with safe landings.
			var index: int = 0
			for rect: Rect2 in AlderwakeDockSurfaces.SURFACES[record.id]:
				var deck: PackedVector2Array = _rectangle(rect)
				_add_prism(wrapper, "DeckPreview%d" % index, _local_outline(wrapper, deck), 0.022, false, Color(0.56, 0.42, 0.28))
				_add_dock_floor(wrapper, rect, index)
				index += 1
			dock_decks[record.id] = _rectangle(AlderwakeDockSurfaces.SURFACES[record.id][0])
			_label(wrapper.get_node("VisualRoot"), "DOCK GRAYBOX\nAUTHORED WALKABLE CUTOUT", Vector3(0, 0.5, -1))
		else:
			# Nonblocking/disabled props stay honest small foot markers. No roof,
			# screen-depth lift, source lights, extra support or behavior inferred.
			_add_prism(wrapper, "NonblockingFoot", _rectangle(Rect2(-0.12, -0.12, 0.24, 0.24)), 0.06, false, Color(0.68, 0.60, 0.39))
		if definition.kind == "structure" and record.definition_id not in ["dock-junction", "dock-straight"]:
			_label(wrapper.get_node("VisualRoot"), definition.label + "\nEXTERIOR GRAYBOX", Vector3(0, 1.15, 0))
	for record: Dictionary in layout.colliders:
		if str(record.id).contains("water") or record.id == "future-exit-gate":
			continue # Independent M004 owner; never duplicate a source collider.
		collider_records.append(record)
		# Prop and authored-collider namespaces can legally share source IDs.
		var wrapper: Node3D = _wrapper("collider--" + record.id, Vector3.ZERO)
		wrapper.set_meta("source_collider_id", record.id)
		wrapper.set_meta("source", record.source)
		var r: Array = record.rect_xz_m
		var outline: PackedVector2Array = _rectangle(Rect2(r[0], r[1], r[2], r[3]))
		footprints.append(outline)
		_add_prism(wrapper, "AuthoredCollider", outline, 0.6, true, Color(0.37, 0.34, 0.29))
	# Quay tile placements remain art-only, independently of authored edge bodies.
	var quays: Node3D = _wrapper("QuayArtPreview", Vector3.ZERO)
	for layer: Dictionary in layout.art_layers:
		if not str(layer.id).begins_with("passenger-") or not str(layer.id).ends_with("--quay-deck") or not layer.visible:
			continue
		for cell: Dictionary in layer.cells:
			if cell.tile_id == null:
				continue
			var rect: Rect2 = Rect2(float(cell.cell[0]) - 22, float(cell.cell[1]) - 18, 1, 1)
			_add_prism(quays, "%s-%s-%s" % [layer.id, cell.cell[0], cell.cell[1]], _rectangle(rect), 0.022, false, Color(0.48, 0.49, 0.43))
	for record: Dictionary in layout.portals:
		if record.phase_role != "inert":
			continue
		var r: Array = record.rect_xz_m
		var pad: Vector3 = Vector3(float(r[0]) + float(r[2]) / 2, 0, float(r[1]) + float(r[3]) / 2)
		portal_pads[record.id] = pad
		var wrapper: Node3D = _wrapper(record.id, pad)
		wrapper.set_meta("source_portal_id", record.id)
		wrapper.set_meta("runtime_enabled", false)
		_add_prism(wrapper, "InertPad", _rectangle(Rect2(-0.3, -0.3, 0.6, 0.6)), 0.027, false, Color(0.47, 0.60, 0.61))
		_label(wrapper.get_node("VisualRoot"), record.label + "\nINACTIVE · NO INTERIOR", Vector3(0, 0.4, 0))
	var service: Node3D = _wrapper("MarisReservedPad", Vector3.ZERO)
	for point: Vector3 in [Vector3(-7.5, 0, 11), Vector3(-6, 0, 11.5), Vector3(-4.5, 0, 11.5)]:
		_add_prism(service, "Pad%d" % service.get_node("VisualRoot").get_child_count(), _rectangle(Rect2(point.x - 0.2, point.z - 0.2, 0.4, 0.4)), 0.027, false, Color(0.71, 0.65, 0.35))
	_label(service.get_node("VisualRoot"), "MARIS / FITTING PAD\nRESERVED · INTERACTION M015", Vector3(-6, 0.7, 11.5))
