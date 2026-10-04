class_name ExteriorLightConsumer
extends Node3D
## Location wrapper-owned render consumer. Facts stay in EnvironmentState.

var prop_id: String
var source_id: String
var source_kind: String
var enabled: bool = false
var intensity: float = 0.0
var glow_material: StandardMaterial3D
var anchor: Node3D
var emitter: OmniLight3D
var glow_color: Color = Color(1.0, .65, .24)
var dormant_color: Color = Color(.16, .12, .065)
var pane_count: int = 0


func initialize(row: Dictionary, frame_mesh: Mesh, core_mesh: Mesh) -> void:
	prop_id = row.prop_id
	source_id = row.source_id
	source_kind = row.kind
	name = source_id
	glow_material = StandardMaterial3D.new()
	glow_material.roughness = .78
	glow_material.emission_enabled = true
	glow_material.emission = glow_color
	glow_material.emission_energy_multiplier = 0.0
	glow_material.albedo_color = dormant_color
	if source_kind == "waylight":
		glow_color = Color(.48, .95, .78)
		dormant_color = Color(.09, .17, .15)
	elif source_kind == "woven_net":
		glow_color = Color(.72, .91, .47)
		dormant_color = Color(.12, .17, .07)
	glow_material.emission = glow_color
	anchor = Node3D.new()
	anchor.name = "EmitterAnchor"
	if row.anchor_local_xyz_m is Array:
		var xyz: Array = row.anchor_local_xyz_m
		anchor.position = Vector3(xyz[0], xyz[1], xyz[2])
	add_child(anchor)
	if source_kind == "windows":
		_build_windows(row.window_surface_recipe)
	else:
		_add_mesh("Frame", frame_mesh)
		var core: MeshInstance3D = _add_mesh("GlowSurface", core_mesh)
		core.material_override = glow_material
		core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if float(row.get("initial_omni_range_m", 0.0)) > 0.0:
			emitter = OmniLight3D.new()
			emitter.name = "LocalIllumination"
			emitter.omni_range = float(row.initial_omni_range_m)
			emitter.omni_attenuation = .55
			emitter.light_color = glow_color
			emitter.light_energy = 0.0
			emitter.light_specular = .2
			emitter.shadow_enabled = false
			emitter.visible = false
			anchor.add_child(emitter)


func present(state: EnvironmentState, night_factor: float, focus: Vector3) -> void:
	enabled = state.light_enabled(LightSourceRegistry.LOCATION_ID, prop_id, source_id)
	intensity = night_factor if enabled else 0.0
	glow_material.albedo_color = dormant_color.lerp(glow_color * .55, intensity)
	glow_material.emission_energy_multiplier = intensity * (1.4 if source_kind == "windows" else 2.2)
	if emitter != null:
		# Fixed identities mean no pool reassignment or source-state mutation.
		# Smooth spatial selection follows the hero's visible region, not eye height.
		var offset: Vector3 = anchor.global_position - focus
		var distance: float = Vector2(offset.x, offset.z).length()
		var weight: float = 1.0 - smoothstep(12.0, 18.0, distance)
		emitter.light_energy = intensity * weight * (7.0 if source_kind == "dock_lamp" else 2.6)
		emitter.visible = emitter.light_energy > .0001


func _add_mesh(label: String, mesh: Mesh) -> MeshInstance3D:
	var visual: MeshInstance3D = MeshInstance3D.new()
	visual.name = label
	visual.mesh = mesh
	add_child(visual)
	return visual


func _build_windows(recipe: Dictionary) -> void:
	var polygon: Array = recipe.local_polygon_xz_m
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var anchor_sum: Vector3 = Vector3.ZERO
	for edge: int in range(polygon.size()):
		var a: Vector2 = Vector2(polygon[edge][0], polygon[edge][1])
		var b: Vector2 = Vector2(polygon[(edge + 1) % polygon.size()][0], polygon[(edge + 1) % polygon.size()][1])
		var direction: Vector2 = (b - a).normalized()
		var outward: Vector2 = Vector2(direction.y, -direction.x)
		var half_width: float = minf(.075 * a.distance_to(b), .28)
		for fraction: float in recipe.edge_fractions:
			var center: Vector2 = a.lerp(b, fraction) + outward * float(recipe.outward_offset_m)
			for level: float in recipe.center_heights_m:
				anchor_sum += Vector3(center.x, level, center.y)
				# Existing vertical/horizontal wood crossbars retain dark gaps.
				for horizontal: Vector2 in [Vector2(-half_width, -.025), Vector2(.025, half_width)]:
					for vertical: Vector2 in [Vector2(-.22, -.025), Vector2(.025, .24)]:
						var left: Vector2 = center + direction * horizontal.x
						var right: Vector2 = center + direction * horizontal.y
						var vertices: Array[Vector3] = [Vector3(left.x, level + vertical.x, left.y), Vector3(left.x, level + vertical.y, left.y), Vector3(right.x, level + vertical.y, right.y), Vector3(right.x, level + vertical.x, right.y)]
						for index: int in [0, 1, 2, 0, 2, 3]:
							surface.set_normal(Vector3(outward.x, 0, outward.y))
							surface.add_vertex(vertices[index])
						pane_count += 1
	anchor.position = anchor_sum / float(pane_count / 4)
	var panes: MeshInstance3D = _add_mesh("WindowPanes", surface.commit())
	panes.material_override = glow_material
	panes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Dedicated planes; original imported walls, roof and mullions never emit.
	glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
