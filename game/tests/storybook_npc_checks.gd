extends SceneTree
## AD012 exact source-resource, shared surface finish and animation preservation.
var failures: PackedStringArray = []
var assertions: int = 0
var inventory: Array[Dictionary] = []
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	_check(StorybookNpcMaterial.ATLAS.get_size() == Vector2(1024,1024) and StorybookNpcMaterial.ATLAS.get_image().has_mipmaps(), "existing mipmapped shared atlas")
	for path: String in StorybookNpcMaterial.ASSETS:
		var asset: PackedScene = load(path)
		var raw: Node3D = asset.instantiate()
		var p: NpcVisualPresenter = NpcVisualPresenter.new()
		root.add_child(p)
		_check(p.mount(asset).is_empty(), "mount " + path)
		_compare(raw,p.model)
		var raw_player: AnimationPlayer = raw.find_children("*","AnimationPlayer",true,false)[0]
		for clip: String in p.player.get_animation_list():
			_check(p.player.get_animation(clip) == raw_player.get_animation(clip), "exact original clip resource " + clip)
		p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		for clip: String in p.player.get_animation_list():
			if clip == "RESET": continue
			var start: PackedVector3Array = NpcAssetProbe.sample(p,clip,0)
			var end: PackedVector3Array = NpcAssetProbe.sample(p,clip,p.player.get_animation(clip).length)
			_check(start.size() == end.size(), "same sampled vertices")
			var seam: float = 0
			for i: int in range(start.size()): seam = maxf(seam,start[i].distance_to(end[i]))
			_check(seam < .0001,"unchanged closed skin loop " + clip)
		inventory.append({"path":path,"bones":p.skeleton.get_bone_count(),"clips":Array(p.player.get_animation_list()),"surfaces":NpcAssetProbe.mesh_nodes(p.model).size()})
		var count: int = StorybookNpcMaterial.materials.size()
		_check(p.mount(asset).is_empty() and StorybookNpcMaterial.materials.size() == count,"no material growth on remount")
		raw.free(); p.free()
	var calibration: NpcVisualPresenter = NpcVisualPresenter.new(); root.add_child(calibration)
	_check(calibration.mount(load("res://assets/models/npcs/npc_calibration.glb")).is_empty(),"calibration mount")
	for mesh: MeshInstance3D in NpcAssetProbe.mesh_nodes(calibration.model):
		for surface: int in range(mesh.mesh.get_surface_count()): _check(mesh.get_surface_override_material(surface) == null,"unrelated calibration unchanged")
	calibration.free()
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1,"strict save versions")
	_check(TestRunEvidence.write_json("npc-painted-audit.json",{"assertions":assertions+1,"failures":failures,"inventory":inventory,"shared_materials":StorybookNpcMaterial.materials.size(),"new_texture_bytes":0,"source":"original portable assets; shared town brush atlas"}),"write")
	for failure: String in failures: push_error(failure)
	print("AD012 surface audit: ",assertions," assertions; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
func _compare(raw: Node, painted: Node) -> void:
	_check(raw.get_class() == painted.get_class() and raw.name == painted.name,"same imported node")
	if raw is Node3D: _check(raw.transform == painted.transform,"same original feet/bounds transform")
	if raw is Skeleton3D:
		_check(raw.get_bone_count() == painted.get_bone_count(),"same skeleton count")
		for i: int in range(raw.get_bone_count()):
			_check(raw.get_bone_name(i) == painted.get_bone_name(i) and raw.get_bone_parent(i) == painted.get_bone_parent(i) and raw.get_bone_rest(i) == painted.get_bone_rest(i),"same bone name/parent/rest")
	if raw is MeshInstance3D:
		_check(raw.mesh == painted.mesh and raw.skin == painted.skin,"exact original mesh/UV/weights/skin")
		for surface: int in range(raw.mesh.get_surface_count()):
			var source: StandardMaterial3D = raw.get_active_material(surface)
			_check(source.cull_mode == BaseMaterial3D.CULL_DISABLED and source.metallic == 0 and not source.emission_enabled,"source double-sided nonmetal/nonemitting finish retained")
			var material: ShaderMaterial = painted.get_active_material(surface) as ShaderMaterial
			_check(material != null and material.shader == StorybookNpcMaterial.SHADER,"all body/accessory surfaces painted")
			if material == null: continue
			_check(material.get_shader_parameter("palette") == source.albedo_texture and source.albedo_texture != null,"exact source palette")
			_check(material.get_shader_parameter("base_color") == source.albedo_color and material.get_shader_parameter("vertex_palette") == source.vertex_color_use_as_albedo,"same source palette multipliers")
			_check(material.get_shader_parameter("painted_atlas") == StorybookNpcMaterial.ATLAS,"shared local brush atlas")
			_check(source.albedo_texture.get_width() <= 1024 and source.albedo_texture.get_height() <= 1024,"palette within per-person budget")
	_check(raw.get_child_count() == painted.get_child_count(),"same imported inventory")
	for i: int in range(raw.get_child_count()): _compare(raw.get_child(i),painted.get_child(i))
func _check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok: failures.append(label)
