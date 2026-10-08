extends Node3D
## Labeled generic calibration review, isolated from GameRoot and NPC activation.
var presenters: Array[NpcVisualPresenter] = []
var camera: Camera3D
var sun: DirectionalLight3D
var world: WorldEnvironment
var title: Label
var errors: PackedStringArray = []

func _ready() -> void:
	world = WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	add_child(world)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55,-30,0)
	sun.shadow_enabled = true
	add_child(sun)
	var floor: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(20,12)
	floor.mesh = plane
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(.18,.22,.24)
	material.roughness = .9
	floor.material_override = material
	add_child(floor)
	for i: int in range(8):
		var wrapper: Node3D = Node3D.new()
		wrapper.name = "ReviewOnly%d" % i
		wrapper.position = Vector3((i%4-1.5)*1.5,0,(i/4)*2.2)
		add_child(wrapper)
		var p: NpcVisualPresenter = NpcVisualPresenter.new()
		p.name = "VisualRoot"
		wrapper.add_child(p)
		errors.append_array(p.mount(load("res://assets/models/npcs/npc_calibration.glb")))
		if p.player != null: p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		presenters.append(p)
		var mark: MeshInstance3D = MeshInstance3D.new()
		var circle: CylinderMesh = CylinderMesh.new()
		circle.top_radius = .4
		circle.bottom_radius = .4
		circle.height = .005
		mark.mesh = circle
		mark.position.y = .0025
		var marker: StandardMaterial3D = StandardMaterial3D.new()
		marker.albedo_color = Color(.34,.41,.43)
		mark.material_override = marker
		wrapper.add_child(mark)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.current = true
	add_child(camera)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	title = Label.new()
	title.position = Vector2(16,16)
	title.add_theme_color_override("font_color",Color.WHITE)
	title.add_theme_color_override("font_shadow_color",Color.BLACK)
	title.add_theme_constant_override("shadow_offset_x",2)
	title.add_theme_constant_override("shadow_offset_y",2)
	layer.add_child(title)
	set_light("day")
	set_view("front")
	set_sample("idle",0)

func set_light(mode: String) -> void:
	var day: bool = mode == "day"
	world.environment.background_color = Color(.09,.12,.15) if day else Color(.025,.035,.065)
	world.environment.ambient_light_color = Color(.72,.78,.85) if day else Color(.35,.44,.66)
	world.environment.ambient_light_energy = .65 if day else .45
	sun.light_color = Color(1,.88,.72) if day else Color(.48,.62,1)
	sun.light_energy = 1.0 if day else .45

func set_view(view: String) -> void:
	for i: int in range(presenters.size()):
		presenters[i].get_parent().visible = view not in ["profile","close"] or i == 0
	if view == "overhead":
		camera.size = PrototypeCameraRig.DEFAULT_SIZE
		camera.position = PrototypeCameraRig.OFFSET + Vector3(0,0,1.1)
		camera.look_at(Vector3(0,0,1.1))
	elif view == "profile":
		camera.size = 3.7
		camera.position = Vector3(-6,1.3,-.5)
		camera.look_at(Vector3(-2.25,.8,0))
	elif view == "close":
		camera.size = 3.7
		camera.position = Vector3(-2.25,1.3,-5)
		camera.look_at(Vector3(-2.25,.8,0))
	else:
		camera.size = 8.5
		camera.position = Vector3(1.5,3,-7)
		camera.look_at(Vector3(0,.7,1))

func set_sample(clip: String, time: float) -> void:
	for p: NpcVisualPresenter in presenters:
		NpcAssetProbe.sample(p,clip,time)

func label_frame(note: String) -> void:
	title.text = "N007 / GENERIC RIG CALIBRATION / Compatibility\n" + note + "\nReview fixture only. No named villager, ordinary route or profession action."
