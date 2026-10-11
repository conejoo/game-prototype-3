extends SceneTree
## AD014 material inventory, shared-cache reload, and stable indoor resource contract.
const PAINT: Script = preload("res://world/storybook_home_material.gd")
var failures: PackedStringArray = []
var assertions: int = 0
var inventory: Array[Dictionary] = []
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var room: MayorValeHome = load("res://world/mayor_vale_home.tscn").instantiate()
	root.add_child(room)
	var families: Dictionary = {}
	for node: Node in room.find_children("*","MeshInstance3D",true,false):
		if not node.mesh is BoxMesh: continue
		var material: ShaderMaterial = node.material_override
		var source: StandardMaterial3D = node.mesh.material
		_check(material != null and material.shader == PAINT.SHADER,"all box faces painted "+str(node.get_path()))
		_check(source != null and source.albedo_texture == null,"recoverable original source material")
		_check(material.get_shader_parameter("painted_atlas") == PAINT.ATLAS,"same existing town atlas")
		_check(PAINT.painted(source.albedo_color,str(node.get_parent().name),node.position) == material,"equivalent semantic palette cached")
		var origin: Vector2 = material.get_shader_parameter("patch_origin")
		var span: Vector2 = material.get_shader_parameter("patch_span")
		_check(origin.x >= 16 and origin.y >= 16 and origin.x+span.x <= 1008 and origin.y+span.y <= 1008,"16px outer gutter")
		_check(span in [Vector2(480,480),Vector2(224,224)],"known family safe region span")
		var kind: String = material.get_meta("storybook_family")
		families[kind] = int(families.get(kind,0))+1
		inventory.append({"path":str(room.get_path_to(node)),"size":TestRunObservation.vector(node.mesh.size),"center":TestRunObservation.vector(node.position),"family":kind,"source_color":str(source.albedo_color),"paint_color":str(material.get_shader_parameter("base_color")),"patch_origin":[origin.x,origin.y],"patch_span":[span.x,span.y]})
	_check(families.size() == 15,"all15 bounded semantic families present")
	_check(room.layout.colliders.size() == 32 and room.anchors().size() == 9,"original32 colliders/nine stations")
	_check(room.get_node("Floor").get_child_count() == 4,"original two floor boxes and colliders")
	var lamps: Array[Node] = room.find_children("*","OmniLight3D",true,false)
	_check(lamps.size() == 4,"only original four indoor lamps")
	for lamp: OmniLight3D in lamps:
		_check(lamp.light_color == Color(1,.76,.44) and is_equal_approx(lamp.light_energy,.55) and lamp.omni_range == 6 and not lamp.shadow_enabled,"original stable lamp state")
	var cue: MeshInstance3D = room.get_node("TravelGate").get_child(0)
	_check(cue.mesh is TorusMesh and cue.material_override == null,"original travel cue untouched")
	var cache_count: int = PAINT.materials.size()
	var duplicate: MayorValeHome = load("res://world/mayor_vale_home.tscn").instantiate()
	_check(PAINT.materials.size() == cache_count,"room reconstruction reuses shared immutable cache")
	_check(cache_count <= 24,"bounded semantic material count")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1,"strict save/content versions")
	duplicate.free(); room.queue_free(); await process_frame
	if not TestRunEvidence.write_json("home-materials.json",{"task":"AD014","assertions":assertions,"failures":failures,"families":families,"materials":cache_count,"boxes":inventory.size(),"inventory":inventory,"atlas_bytes":PAINT.ATLAS.get_image().get_data_size(),"kind":"synthetic scene/material inventory; existing home checks own physical route sweeps"}): failures.append("report")
	for failure: String in failures: push_error(failure)
	print("AD014 home materials: ",assertions," assertions; ",inventory.size()," boxes; ",cache_count," materials; ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
func _check(ok: bool,label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
