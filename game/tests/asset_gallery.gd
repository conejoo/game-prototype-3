extends SceneTree
## Rendered import inspection only. No gameplay/session/objective setup.


func _initialize() -> void:
	_show.call_deferred()


func _show() -> void:
	var stage: Node3D = Node3D.new()
	root.add_child(stage)
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color(0.055, 0.075, 0.095)
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color(0.65, 0.76, 0.86)
	environment.environment.ambient_light_energy = 0.65
	stage.add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	stage.add_child(sun)
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_color = Color(1, 0.89, 0.73)
	sun.light_energy = 1.1
	for index: int in range(3):
		var asset: String = ["guardian", "recovery_vessel", "tollworks_plinth"][index]
		var model: Node3D = load("res://assets/models/%s.glb" % asset).instantiate()
		stage.add_child(model)
		model.position.x = [-1.8, -0.3, 1.65][index]
	var camera: Camera3D = Camera3D.new()
	stage.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.7
	camera.position = Vector3(3, 3.3, -7)
	camera.look_at(Vector3(0, 0.75, 0))
	camera.current = true
	var label: Label = Label.new()
	root.add_child(label)
	label.text = "P012 / Godot import inspection — prototype art, no gameplay fixture"
	label.position = Vector2(20, 20)
	for frame: int in range(10):
		await process_frame
	await RenderingServer.frame_post_draw
	var path: String = TestRunEvidence.path("godot-asset-gallery.png")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var result: Error = root.get_texture().get_image().save_png(path)
	print("P012 Godot gallery: ", path, "; save result=", result)
	quit(0 if result == OK else 1)
