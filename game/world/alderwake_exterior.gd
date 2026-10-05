class_name AlderwakeExterior
extends AlderwakeTerrainPreview
## Production composition of the pinned exterior and existing recovery slice.

var service_outlines: Array[Rect2] = []
var exterior_lights: ExteriorLights
var world_rain: WorldRain


func _init() -> void:
	super()
	location_id = "prototype-alderwake"
	exterior_lights = ExteriorLights.new()
	add_child(exterior_lights)
	exterior_lights.build(self)
	build_errors.append_array(exterior_lights.build_errors)
	world_rain = WorldRain.new()
	add_child(world_rain)
	world_rain.build(self)
	_build_light_switches()
	destination_id = "prototype-tollworks"
	destination_spawn_id = "tollworks-from-alderwake"
	gate_label = "Enter Tollworks"
	# Existing scene resources retain their identities, presentation and rules.
	var counter: MarisCounter = preload("res://world/maris_counter.tscn").instantiate()
	counter.name = "MarisCounter"
	counter.position = Vector3(-7.5, 0, 11)
	counter.set_meta("source_instance_id", "maris-chandlery-01")
	add_child(counter)
	service_outlines.append(Rect2(-7.85, 10.65, 0.7, 0.7))
	service_outlines.append(Rect2(-8.6, 11.45, 2.2, 0.7))
	var station: PrototypeInteractable = preload("res://features/interaction/npc_interaction.tscn").instantiate()
	station.name = "TemporaryCompanion"
	station.instance_id = "alderwake-temporary-companion"
	station.position = Vector3(-2, 0, 0)
	add_child(station)
	service_outlines.append(Rect2(-2.35, -0.35, 0.7, 0.7))
	var gate: PrototypeInteractable = PrototypeInteractable.new()
	gate.name = "TravelGate"
	gate.instance_id = "alderwake-travel-gate"
	gate.kind = "travel"
	gate.prompt = gate_label
	gate.reach = 1.6
	gate.position = Vector3(107.25, 0, -1.25)
	gate.set_meta("source_portal_id", "tollworks-entrance-01")
	add_child(gate)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.8
	torus.outer_radius = 1.0
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.9, 0.8)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	torus.material = material
	ring.mesh = torus
	ring.position.y = 0.03
	gate.add_child(ring)
	var label: Label3D = Label3D.new()
	label.text = "Enter Tollworks\n[E] nearby · recovery slice"
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position.y = 1.5
	label.pixel_size = 0.012
	label.font_size = 28
	gate.add_child(label)
	# Remove obsolete reservations/inactive label, retaining pinned provenance.
	town.get_node("MarisReservedPad").free()
	forest.get_node("tollworks-entrance-01/VisualRoot").visible = false
	forest.get_node("tollworks-entrance-01").set_meta("runtime_enabled", true)
	for anchor: Node in get_node("Spawns").get_children():
		for child: Node in anchor.get_children():
			if child is Label3D:
				child.text = "ALDERWAKE · TOWN START" if anchor.stable_id == "alderwake-start" else "MOONWOOD · TOLLWORKS RETURN"
	preview_report["limits"] = "Recovery slice active; six other portals inactive; routines/resources/other NPCs data only."


func add_service_navigation_obstructions(geometry: NavigationMeshSourceGeometryData3D) -> void:
	for rect: Rect2 in service_outlines:
		var points: PackedVector3Array = []
		for point: Vector2 in AlderwakePropGrayboxes._rectangle(rect.grow(0.2)):
			points.append(Vector3(point.x, 0, point.y))
		geometry.add_projected_obstruction(points, -0.2, 2.0, false)


func _build_light_switches() -> void:
	for source: Dictionary in LightSourceRegistry.entries():
		if not source.switchable:
			continue
		var wrapper: Node3D = town.get_node(NodePath(source.prop_id))
		var consumer: ExteriorLightConsumer = exterior_lights.consumers[source.prop_id]
		var target: PrototypeInteractable = PrototypeInteractable.new()
		target.name = "LightSwitch"
		target.instance_id = source.prop_id
		target.kind = "light"
		target.prompt = "Turn on lamp"
		target.reach = 1.7
		target.position = Vector3(consumer.anchor.position.x, 0, consumer.anchor.position.z)
		target.light_action = LightSwitchAction.new()
		target.light_action.location_id = source.location_id
		target.light_action.prop_id = source.prop_id
		target.light_action.source_id = source.source_id
		wrapper.add_child(target)
