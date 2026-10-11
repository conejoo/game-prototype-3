extends SceneTree
## AD011 material/coverage/resource acceptance alongside unchanged physical suites.
var failures: PackedStringArray = []
var assertions: int = 0
var painted_parts: int = 0
var small_props: int = 0

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var game: Node3D = preload("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"startup")
	game._set_paused(true)
	_check(StorybookPropMaterial.ATLAS.get_size() == Vector2(1024,1024) and StorybookPropMaterial.ATLAS.get_image().has_mipmaps(),"existing shared local atlas/mips")
	var location: AlderwakeExterior = game.world_host.current_location
	for population: Node in [location.town,location.forest]:
		for wrapper: Node3D in population.get_children():
			if wrapper.get_meta("definition_id","") not in StorybookPropMaterial.SMALL_DEFINITIONS: continue
			small_props += 1
			for visual: MeshInstance3D in wrapper.get_node("VisualRoot").find_children("*","MeshInstance3D",true,false):
				_check(visual.material_override is ShaderMaterial and visual.material_override.shader == StorybookPropMaterial.SHADER,"small prop material "+str(wrapper.name))
	_check(small_props > 0,"current small prop coverage")
	_check(location.exterior_lights.consumers.size() == 23 and location.exterior_lights.emitter_count == 8,"unchanged light inventory")
	var frames: Array[Material] = []
	for consumer: ExteriorLightConsumer in location.exterior_lights.consumers.values():
		_check(consumer.glow_material is StandardMaterial3D,"dynamic light core state owner")
		if consumer.source_kind != "windows":
			var frame: MeshInstance3D = consumer.get_node("Frame")
			var material: ShaderMaterial = frame.get_active_material(0) as ShaderMaterial
			_check(material != null and material.shader == StorybookPropMaterial.SHADER and material.get_shader_parameter("vertex_palette"),"mapped frame palette coverage")
			if material != null and material not in frames: frames.append(material)
	_check(frames.size() == 1,"one immutable shared frame material across three semantic vertex palettes")
	# Repeated item visuals/previews share six materials; do not grow per-instance resources.
	var copies: Array[ForagingItemVisual] = []
	for rod: bool in [false,true,false,true]:
		var visual: ForagingItemVisual = ForagingItemVisual.new()
		visual.build(rod)
		copies.append(visual)
		_check(visual.get_child_count() == (7 if rod else 9),"original item part inventory")
	_check(ForagingItemVisual.materials.size() == 6,"six shared quiet tiny-item materials")
	for pair: Array in [[0,2],[1,3]]:
		for index: int in range(copies[pair[0]].get_child_count()):
			var a: MeshInstance3D = copies[pair[0]].get_child(index)
			var b: MeshInstance3D = copies[pair[1]].get_child(index)
			_check(a.material_override == b.material_override and a.material_override.albedo_texture == null,"shared tiny-item no unique texture")
	for visual: ForagingItemVisual in copies: visual.free()
	var frozen_material_count: int = 0
	for iteration: int in range(2):
		_check(game.world_host.request_transition("prototype-tollworks","tollworks-from-alderwake").is_empty(),"room request")
		_check((await game.world_host.transition_finished)[0],"room arrival")
		for entry: Array in [["recovery_vessel","RecoveryVessel/VisualRoot/VesselModel"],["tollworks_plinth","Plinth/VisualRoot/PlinthModel"]]:
			var raw: Node3D = load("res://assets/models/%s.glb" % entry[0]).instantiate()
			_compare(raw,game.world_host.current_location.get_node(entry[1]))
			raw.free()
		if iteration == 0: frozen_material_count = StorybookPropMaterial.materials.size()
		else: _check(StorybookPropMaterial.materials.size() == frozen_material_count,"no material growth after exterior/room rebuild")
		_check(game.world_host.request_transition("prototype-alderwake","alderwake-from-tollworks").is_empty(),"return request")
		_check((await game.world_host.transition_finished)[0],"return arrival")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1,"current strict save policy")
	_check(TestRunEvidence.write_json("props-material-audit.json",{"task":"AD011","kind":"synthetic import/presentation/resource audit; no ordinary play claim","assertions":assertions+1,"failures":failures,"small_props":small_props,"compared_recovery_meshes":painted_parts,"shared_materials":StorybookPropMaterial.materials.size(),"tiny_materials":ForagingItemVisual.materials.size(),"atlas":StorybookPropMaterial.ATLAS.resource_path}),"write evidence")
	game.queue_free(); await process_frame
	paused = false
	for failure: String in failures: push_error(failure)
	print("AD011 material audit: ",assertions," assertions; ",small_props," small props; ",painted_parts," recovery mesh comparisons; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)

func _compare(raw: Node3D, painted: Node3D) -> void:
	_check(raw.transform == painted.transform,"original import transforms "+str(raw.name))
	if raw is MeshInstance3D:
		painted_parts += 1
		_check(painted is MeshInstance3D and raw.mesh == painted.mesh,"same original geometry resource "+str(raw.name))
		for surface: int in range(raw.mesh.get_surface_count()):
			var source: StandardMaterial3D = raw.get_active_material(surface)
			var material: ShaderMaterial = painted.get_active_material(surface) as ShaderMaterial
			_check(material != null and material.shader == StorybookPropMaterial.SHADER,"recovery all-face painted material")
			if material == null: continue
			_check(material.get_shader_parameter("painted_atlas") == StorybookPropMaterial.ATLAS,"shared locally resolved atlas")
			_check(material.get_shader_parameter("base_color") == source.albedo_color and material.get_shader_parameter("metallic") == source.metallic,"original recovery semantic color/metallic")
			_check(material.get_shader_parameter("glow") == (source.emission if source.emission_enabled else Color.BLACK) and material.get_shader_parameter("glow_energy") == source.emission_energy_multiplier,"original recovery emission")
	_check(raw.get_child_count() == painted.get_child_count(),"original imported child inventory")
	for index: int in range(raw.get_child_count()): _compare(raw.get_child(index),painted.get_child(index))

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
