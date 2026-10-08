extends Node3D
## Explicit synthetic art review. No GameRoot, state owner, rewards or ordinary route.
var presenters: Array[NpcVisualPresenter] = []
var errors: PackedStringArray = []
var camera: Camera3D
var sun: DirectionalLight3D
var world: WorldEnvironment
var title: Label
const ASSETS: PackedStringArray = ["res://assets/models/npcs/npc-01-actions.glb","res://assets/models/npcs/npc-02-actions.glb"]
const ACTIONS: PackedStringArray = ["action_river_fishing","action_archive_work"]

func _ready() -> void:
	world=WorldEnvironment.new(); world.environment=Environment.new()
	world.environment.background_mode=Environment.BG_COLOR
	world.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	add_child(world)
	sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-55,-30,0); sun.shadow_enabled=true; add_child(sun)
	var floor: MeshInstance3D=MeshInstance3D.new()
	var plane: PlaneMesh=PlaneMesh.new(); plane.size=Vector2(8,8); floor.mesh=plane
	var mat: StandardMaterial3D=StandardMaterial3D.new(); mat.albedo_color=Color(.18,.22,.24); mat.roughness=.9
	floor.material_override=mat; add_child(floor)
	for index: int in range(2):
		var wrapper: Node3D=Node3D.new(); wrapper.position.x=-.75 if index==0 else .75
		add_child(wrapper)
		var p: NpcVisualPresenter=NpcVisualPresenter.new(); wrapper.add_child(p)
		errors.append_array(p.mount(load(ASSETS[index])))
		presenters.append(p)
	camera=Camera3D.new(); camera.projection=Camera3D.PROJECTION_ORTHOGONAL; camera.current=true; add_child(camera)
	var layer: CanvasLayer=CanvasLayer.new(); add_child(layer)
	title=Label.new(); title.position=Vector2(16,16); title.add_theme_color_override("font_color",Color.WHITE)
	title.add_theme_color_override("font_shadow_color",Color.BLACK); title.add_theme_constant_override("shadow_offset_x",2); title.add_theme_constant_override("shadow_offset_y",2); layer.add_child(title)
	var row: HBoxContainer=HBoxContainer.new(); row.position=Vector2(16,590); layer.add_child(row)
	for mode: String in ["idle","walk","action","pause","resume"]:
		var button: Button=Button.new(); button.text=mode.capitalize(); button.pressed.connect(_choose.bind(mode)); row.add_child(button)
	set_light("day"); set_view("front"); label_frame("Idle / buttons select visual modes; pause preserves pose")

func _choose(mode: String) -> void:
	for index: int in range(presenters.size()):
		var p: NpcVisualPresenter=presenters[index]
		if mode=="pause": p.suspend("pause")
		elif mode=="resume": p.resume("pause")
		elif mode=="action": p.set_locomotion(0); p.set_action(ACTIONS[index])
		else: p.cancel_action(); p.set_locomotion(.8 if mode=="walk" else 0)
	label_frame(mode)

func set_light(mode: String) -> void:
	var day: bool=mode=="day"
	world.environment.background_color=Color(.09,.12,.15) if day else Color(.025,.035,.065)
	world.environment.ambient_light_color=Color(.72,.78,.85) if day else Color(.35,.44,.66)
	world.environment.ambient_light_energy=.65 if day else .45
	sun.light_color=Color(1,.88,.72) if day else Color(.48,.62,1); sun.light_energy=1 if day else .45

func set_view(mode: String) -> void:
	camera.size=3.4
	if mode=="profile": camera.position=Vector3(-4,1.9,-2)
	elif mode=="back": camera.position=Vector3(0,2.1,4)
	elif mode=="overhead": camera.size=PrototypeCameraRig.DEFAULT_SIZE; camera.position=PrototypeCameraRig.OFFSET
	else: camera.position=Vector3(0,2.1,-4)
	camera.look_at(Vector3(0,.82,0))

func set_sample(mode: String,time: float) -> void:
	for index: int in range(presenters.size()):
		var p: NpcVisualPresenter=presenters[index]
		p.resume("pause"); p.cancel_action(); p.set_locomotion(0)
		if mode=="action": p.set_action(ACTIONS[index])
		NpcAssetProbe.sample(p,ACTIONS[index] if mode=="action" else mode,time)

func label_frame(note: String) -> void:
	title.text="N016 / Edric: river-fishing / Helena: archive-work\n"+note+"\nART REVIEW ONLY. Civic contacts stay idle; no routine, fact or reward."
