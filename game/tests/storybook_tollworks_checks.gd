extends SceneTree
## AD016 resource/coverage/cache contract; original suites own combat/travel rules.
const PAINT: Script = preload("res://world/storybook_tollworks_material.gd")
const OWNERS: PackedStringArray = ["Floor","BackWall","SideWall","FrontWall","RightWall"]
var failures: PackedStringArray = []
var assertions: int = 0
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var room: PrototypeLocation = preload("res://world/tollworks.tscn").instantiate()
	root.add_child(room)
	var inventory: Array[Dictionary] = []
	var sizes: Array[Vector3] = [Vector3(14,.4,12),Vector3(14,1.5,.4),Vector3(.4,1.5,12),Vector3(14,.6,.4),Vector3(.4,.6,12)]
	var centers: Array[Vector3] = [Vector3(0,-.2,0),Vector3(0,.75,-6),Vector3(-7,.75,0),Vector3(0,.3,6),Vector3(7,.3,0)]
	for index: int in range(OWNERS.size()):
		var body: StaticBody3D = room.get_node(OWNERS[index])
		var visual: MeshInstance3D = body.get_node("Mesh")
		var source: StandardMaterial3D = visual.mesh.material
		var material: ShaderMaterial = visual.material_override
		_check(visual.mesh is BoxMesh and visual.mesh.size.is_equal_approx(sizes[index]),"original room box size")
		_check(body.position.is_equal_approx(centers[index]) and visual.transform == Transform3D.IDENTITY,"original body/visual transform")
		_check(body.get_node("CollisionShape3D").shape.size.is_equal_approx(sizes[index]),"original collider")
		_check(not body.get_node("CollisionShape3D").disabled and body.collision_layer == 1,"physical room layer retained")
		_check(source != null and source.albedo_texture == null,"original flat material recoverable")
		_check(source.albedo_color.is_equal_approx(Color(.18,.24,.29) if index == 0 else Color(.42,.46,.47)),"original palette pin")
		_check(material != null and material.shader == PAINT.SHADER,"all box faces use accepted brush shader")
		_check(material == PAINT.painted(OWNERS[index]) and material.get_shader_parameter("painted_atlas") == PAINT.ATLAS,"shared immutable family/atlas")
		_check(material.get_shader_parameter("patch_origin") == Vector2(528,528) and material.get_shader_parameter("patch_span") == Vector2(224,224),"safe stone patch inside16px gutters")
		_check(is_equal_approx(material.get_shader_parameter("stroke_strength"),.70),"quiet brush contrast")
		inventory.append({"owner":OWNERS[index],"size":TestRunObservation.vector(visual.mesh.size),"center":TestRunObservation.vector(body.position),"family":material.get_meta("storybook_family"),"paint_color":str(material.get_shader_parameter("base_color"))})
	_check(PAINT.materials.size() == 2,"two semantic resources only")
	var duplicate: PrototypeLocation = preload("res://world/tollworks.tscn").instantiate(); root.add_child(duplicate)
	_check(PAINT.materials.size() == 2 and duplicate.get_node("Floor/Mesh").material_override == room.get_node("Floor/Mesh").material_override,"reload shares cache")
	_check(room.find_children("*","Light3D",true,false).is_empty(),"no new indoor emitter")
	_check(room.get_node("Plinth/CollisionShape3D").shape.size == Vector3(2,.6,2),"plinth original collision")
	_check(room.find_spawn("tollworks-from-alderwake").position == Vector3(0,0,-2.5),"arrival anchor unchanged")
	_check(room.get_node("TravelGate").position == Vector3(0,0,-5) and room.get_node("TravelGate/Ring").material_override == null,"exit anchor/cue unchanged")
	_check(room.get_node("RecoveryVessel").position == Vector3(4,0,3) and room.get_node("RecoveryVessel").instance_id == "maris-recovery-vessel","recovery identity/foot unchanged")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1,"strict schema8/content1")
	duplicate.queue_free(); room.queue_free(); await process_frame
	if not TestRunEvidence.write_json("tollworks-materials.json",{"task":"AD016","assertions":assertions,"failures":failures,"inventory":inventory,"materials":PAINT.materials.size(),"atlas_bytes":PAINT.ATLAS.get_image().get_data_size(),"kind":"synthetic material/scene inventory; original asset/combat/recovery/travel checks retain behavioral pins"}): failures.append("report")
	for failure: String in failures: push_error(failure)
	print("AD016 Tollworks materials: ",assertions," assertions; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
func _check(ok: bool,label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
