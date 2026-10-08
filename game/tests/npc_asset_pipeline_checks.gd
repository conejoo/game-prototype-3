extends SceneTree
## N007 calibration/rule fixtures only, no ordinary villager route claim.
var failures: PackedStringArray = []
var assertions: int = 0
var measurements: Dictionary = {}
const ASSET: String = "res://assets/models/npcs/npc_calibration.glb"

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var presenter: NpcVisualPresenter = NpcVisualPresenter.new()
	root.add_child(presenter)
	var errors: PackedStringArray = presenter.mount(load(ASSET))
	_check(errors.is_empty(),"Real GLB mount: " + str(errors))
	if errors.is_empty():
		presenter.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		_check(presenter.model.transform == Transform3D.IDENTITY and presenter.transform == Transform3D.IDENTITY,"identity origin and axes")
		_check(presenter.skeleton.get_bone_count() == 16,"exported 16-bone calibration skeleton")
		var sizes: AABB = NpcAssetProbe.bounds(NpcAssetProbe.sample(presenter,"idle",0))
		_check(absf(sizes.position.y) < 0.001 and absf(sizes.end.y-1.555) < 0.015,"meter height and ground soles: " + str(sizes))
		_check(sizes.size.x < .7 and sizes.size.z < .5,"fits approved contact capsule envelope")
		_materials(presenter)
		for clip: String in ["idle","walk"]: _clip(presenter,clip)
		_motion(presenter)
		_lifecycle(presenter)
		_budget(presenter)
		var accepted: Node3D = presenter.model
		_check(not presenter.mount(null).is_empty() and presenter.model == accepted,"rejected missing replacement preserves accepted model")
		var bad: PackedScene = PackedScene.new()
		var studio: Camera3D = Camera3D.new()
		bad.pack(studio)
		studio.free()
		_check(not presenter.mount(bad).is_empty() and presenter.model == accepted,"studio/rigless replacement rejected atomically")
		_check(not presenter.mount(load(ASSET),NAN).is_empty(),"NaN authored speed rejects")
		_check(presenter.mount(load(ASSET)).is_empty() and presenter.get_child_count() == 1,"valid replacement remains single model")
		await _wrappers()
	presenter.queue_free()
	await process_frame
	_check(TestRunEvidence.write_json("npc-asset-pipeline.json",{"assertions":assertions,"failures":failures,"measurements":measurements,"fixture":"exported calibration only"}),"write evidence")
	for failure: String in failures: push_error(failure)
	print("N007 pipeline checks: ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _materials(presenter: NpcVisualPresenter) -> void:
	var texture_count: int = 0
	for node: MeshInstance3D in NpcAssetProbe.mesh_nodes(presenter.model):
		_check(node.skin != null,"real skinned mesh")
		for surface: int in range(node.mesh.get_surface_count()):
			var material: StandardMaterial3D = node.mesh.surface_get_material(surface)
			_check(material != null and material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED,"Compatibility opaque PBR material")
			if material.albedo_texture != null:
				texture_count += 1
				_check(material.albedo_texture.get_width() == 32 and material.albedo_texture.get_height() == 32,"embedded checker texture decodes")
				_check(node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_TEX_UV].size() > 0,"exported UVs")
	_check(texture_count == 1,"one portable textured material")

func _clip(p: NpcVisualPresenter, clip: String) -> void:
	var animation: Animation = p.player.get_animation(clip)
	_check(is_equal_approx(animation.length,4.0 if clip == "idle" else .8),"authored duration " + clip)
	for track: int in range(animation.get_track_count()):
		_check(animation.track_get_type(track) in [Animation.TYPE_POSITION_3D,Animation.TYPE_ROTATION_3D,Animation.TYPE_SCALE_3D],"baked transform tracks only " + clip)
		var count: int = animation.track_get_key_count(track)
		var begin: Variant = animation.track_get_key_value(track,0)
		var end: Variant = animation.track_get_key_value(track,count-1)
		_check(begin.is_equal_approx(end),"authored endpoint values close, independent of loop wrapping " + clip)
	var first: PackedVector3Array = NpcAssetProbe.sample(p,clip,0)
	var last: PackedVector3Array = NpcAssetProbe.sample(p,clip,animation.length)
	var seam: float = 0
	for i: int in range(first.size()): seam = maxf(seam,first[i].distance_to(last[i]))
	_check(seam < .0005,"loop closes all deformed vertices " + clip)
	var envelope: AABB = NpcAssetProbe.bounds(first)
	var max_delta: float = 0
	var previous: PackedVector3Array = first
	var frames: int = roundi(animation.length*120)
	for frame: int in range(1,frames+1):
		var current: PackedVector3Array = NpcAssetProbe.sample(p,clip,float(frame)/120)
		var box: AABB = NpcAssetProbe.bounds(current)
		envelope = envelope.merge(box)
		_check(box.position.y >= -.001 and box.end.y < 1.58,"no ground penetration/head spikes " + clip)
		for i: int in range(current.size()):
			max_delta = maxf(max_delta,current[i].distance_to(previous[i]))
		previous = current
	_check(max_delta < .035,"continuous exported poses " + clip)
	_check(envelope.size.x < .7 and envelope.size.z < .7,"clip stays inside measured contact visual envelope " + clip)
	measurements[clip] = {"length":animation.length,"tracks":animation.get_track_count(),"loop_seam_m":seam,"max_120hz_delta_m":max_delta,"deformed_bounds":str(envelope)}

func _motion(p: NpcVisualPresenter) -> void:
	var max_slide: float = 0
	var max_sole_error: float = 0
	# Actual exported foot poses + wrapper travel, both sides over two cycles.
	for cycle: int in range(2):
		for side: String in ["L","R"]:
			var start: float = cycle*.8 + (0 if side == "L" else .4)
			var reference: Vector3
			for i: int in range(49):
				var time: float = start + float(i)/120
				p.position = Vector3(0,0,-time*.8)
				NpcAssetProbe.sample(p,"walk",fmod(time,.8))
				var foot: Vector3 = NpcAssetProbe.bone_point(p,"foot." + side)
				if i == 0: reference = foot
				max_slide = maxf(max_slide,foot.distance_to(reference))
				max_sole_error = maxf(max_sole_error,absf(foot.y-.08))
	_check(max_slide < .001 and max_sole_error < .001,"world stance feet planted at authored .8m/s: " + str(max_slide))
	p.position = Vector3.ZERO
	_check(p.set_locomotion(.4) and is_equal_approx(p.player.speed_scale,.5),"achieved half speed scales exported walk")
	_check(not p.set_locomotion(NAN) and not p.set_locomotion(-1),"invalid motion rejects")
	var old: Transform3D = p.transform
	_check(not p.face_direction(Vector3.ZERO) and p.transform == old,"zero facing preserves transform")
	_check(p.face_direction(Vector3.RIGHT) and (-p.basis.z).is_equal_approx(Vector3.RIGHT),"visual-only -Z facing")
	p.rotation = Vector3.ZERO
	measurements.stance = {"speed_mps":.8,"samples":196,"max_slide_m":max_slide,"max_sole_error_m":max_sole_error}

func _lifecycle(p: NpcVisualPresenter) -> void:
	NpcAssetProbe.sample(p,"idle",0)
	_check(p.set_locomotion(.8),"begin walking")
	var previous: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
	var max_step: float = 0
	for clip: String in ["walk","idle","walk","idle"]:
		p.set_locomotion(.8 if clip == "walk" else 0)
		for i: int in range(30):
			p.player.advance(1.0/120)
			var current: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
			for v: int in range(current.size()): max_step = maxf(max_step,current[v].distance_to(previous[v]))
			_check(NpcAssetProbe.bounds(current).position.y >= -.001,"blended transitions never sink soles")
			previous = current
	_check(max_step < .06,"idle/walk blends continuous: " + str(max_step))
	p.set_locomotion(.8)
	_check(p.suspend("dialogue") and p.suspend("pause") and p.suspend("focus") and p.suspend("travel"),"nested suspension gates")
	var frozen: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
	p.player.advance(2)
	_check(NpcAssetProbe.deformed_vertices(p) == frozen,"suspension freezes real exported pose")
	_check(p.resume("pause") and p.resume("dialogue") and p.resume("focus") and p.suspended(),"one remaining travel hold prevents resume")
	_check(p.resume("travel") and not p.suspended() and is_equal_approx(p.player.speed_scale,1),"last hold resumes achieved speed")
	_check(not p.resume("travel"),"stale resume rejects")
	measurements.transition_max_step_m = max_step

func _budget(p: NpcVisualPresenter) -> void:
	var triangles: int = 0
	var surfaces: int = 0
	for node: MeshInstance3D in NpcAssetProbe.mesh_nodes(p.model):
		for surface: int in range(node.mesh.get_surface_count()):
			surfaces += 1
			triangles += node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX].size()/3
	_check(triangles == 204 and surfaces == 3,"measured exported budget")
	measurements.budget = {"one_triangles":triangles,"eight_triangles":triangles*8,"eight_bones":p.skeleton.get_bone_count()*8,"eight_surface_draws":surfaces*8,"maximum_eight_triangles":NpcVisualPresenter.MAX_TRIANGLES*8,"maximum_eight_bones":NpcVisualPresenter.MAX_BONES*8}

func _wrappers() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	await game.world_host.transition_finished
	_check(game.world_host.current_location.npc_contacts.targets.is_empty() and NpcRegistry.ENABLED.is_empty(),"production activates no generic villager")
	game.world_host.enabled_npcs = PackedStringArray(["npc-01"])
	game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start")
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0],"synthetic contact wrapper arrival")
	if arrival[0]:
		var target: PrototypeInteractable = game.world_host.current_location.npc_contacts.targets["npc-01"]
		var body: StaticBody3D = target.get_node("ContactBody")
		var before: Transform3D = body.global_transform
		var p: NpcVisualPresenter = NpcVisualPresenter.new()
		target.get_node("VisualRoot").add_child(p)
		_check(p.mount(load(ASSET)).is_empty(),"replaceable VisualRoot mounts shared presenter")
		p.face_direction(Vector3.RIGHT)
		p.set_locomotion(.8)
		_check(target.instance_id == "alderwake-npc-01-contact" and target.npc_id == "npc-01" and body.global_transform == before,"visual clip/facing keeps wrapper IDs/collision")
		var shape: CapsuleShape3D = (body.get_child(0) as CollisionShape3D).shape
		_check(is_equal_approx(shape.radius,.4) and is_equal_approx(shape.height,1.6),"wrapper capsule remains independent")
		var weak: WeakRef = weakref(p)
		game.world_host.request_transition("prototype-test-room","prototype-start")
		await game.world_host.transition_finished
		await process_frame
		_check(weak.get_ref() == null,"travel disposes presenter with scene owner")
	game.queue_free()
	await process_frame

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok:
		failures.append(message)
		print("N007_ASSERTION_FAILED ",message)
