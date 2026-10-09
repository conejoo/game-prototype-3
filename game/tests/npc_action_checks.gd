extends SceneTree
## N016 synthetic imported-art and actual root lifecycle proof; no ambient route claim.
const ASSETS: PackedStringArray = ["res://assets/models/npcs/npc-01-actions.glb", "res://assets/models/npcs/npc-02-actions.glb"]
const CLIPS: PackedStringArray = ["action_river_fishing", "action_archive_work"]
var assertions: int = 0
var failures: PackedStringArray = []
var metrics: Dictionary = {}

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	for index: int in range(2): await _asset(index)
	await _owners()
	_check(TestRunEvidence.write_json("npc-actions.json", {"assertions":assertions,"failures":failures,"metrics":metrics,"scope":"synthetic review variants; ordinary assets unchanged"}), "evidence write")
	for failure: String in failures: push_error(failure)
	print("N016 action checks: ", "PASS" if failures.is_empty() else "FAIL", " assertions=", assertions)
	quit(0 if failures.is_empty() else 1)

func _asset(index: int) -> void:
	var p: NpcVisualPresenter = NpcVisualPresenter.new()
	root.add_child(p)
	var errors: PackedStringArray = p.mount(load(ASSETS[index]))
	_check(errors.is_empty(), "action variant mount " + str(errors))
	if not errors.is_empty(): p.free(); return
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var prop: MeshInstance3D
	for mesh: MeshInstance3D in NpcAssetProbe.mesh_nodes(p.model):
		_check(mesh.skin != null, "portable skinned body/accessory")
		if str(mesh.name).begins_with("PROP-"): prop = mesh
	_check(prop != null and not prop.visible, "accessory hidden on initial idle")
	_check(not p.set_action(CLIPS[1-index]) and not p.set_action("walk") and not p.set_action("unknown"), "wrong-person and unknown actions inert")
	_check(p.set_action(CLIPS[index]) and prop.visible, "explicit action shows source accessory")
	var support: String = "hand.R" if index == 0 else "hand.L"
	for surface: int in range(prop.mesh.get_surface_count()):
		var arrays: Array = prop.mesh.surface_get_arrays(surface)
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		for i: int in range(weights.size()):
			if weights[i] > 0:
				_check(is_equal_approx(weights[i],1) and str(prop.skin.get_bind_name(bones[i])) == support, "accessory rigidly follows authored support hand")
	var action: String = CLIPS[index]
	var animation: Animation = p.player.get_animation(action)
	_check(is_equal_approx(animation.length,4) and animation.loop_mode == Animation.LOOP_LINEAR, "4-second imported linear action loop")
	var full: AABB
	var last: PackedVector3Array
	var max_step: float = 0
	var feet: Dictionary = {}
	var max_foot: float = 0
	for frame: int in range(481):
		var points: PackedVector3Array = NpcAssetProbe.sample(p,action,float(frame)/120)
		var box: AABB = NpcAssetProbe.bounds(points)
		full = box if frame == 0 else full.merge(box)
		_check(box.position.y >= -.001 and box.end.y < 1.8, "action no ground penetration or head spike")
		for side: String in ["L","R"]:
			var foot: Vector3 = NpcAssetProbe.bone_point(p,"foot."+side)
			if frame == 0: feet[side] = foot
			max_foot = maxf(max_foot,foot.distance_to(feet[side]))
		if not last.is_empty():
			for i: int in range(points.size()): max_step = maxf(max_step,points[i].distance_to(last[i]))
		last = points
	var begin: PackedVector3Array = NpcAssetProbe.sample(p,action,0)
	var end: PackedVector3Array = NpcAssetProbe.sample(p,action,4)
	var seam: float = 0
	for i: int in range(begin.size()): seam=maxf(seam,begin[i].distance_to(end[i]))
	_check(seam < .0001 and max_step < .04 and max_foot < .0001, "closed continuous action with planted feet")
	# Blend actual player; sample() cannot prove transition continuity.
	p.cancel_action(); NpcAssetProbe.sample(p,"idle",0)
	last=NpcAssetProbe.deformed_vertices(p)
	var blend_max: float = 0
	for state: String in [action,"walk",action,"idle"]:
		if state == action:
			p.set_locomotion(0); _check(p.set_action(action), "idle-to-action transition")
		else:
			p.cancel_action(); p.set_locomotion(.8 if state == "walk" else 0)
		for frame: int in range(36):
			p.player.advance(1.0/120)
			var points: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
			_check(NpcAssetProbe.bounds(points).position.y >= -.001, "transition soles remain above ground")
			for i: int in range(points.size()): blend_max=maxf(blend_max,points[i].distance_to(last[i]))
			last=points
	_check(blend_max < .20, "bounded 0.12s accessory/body blend")
	_check(not prop.visible and p.active_action().is_empty(), "cancel hides accessory and ends action")
	p.set_action(action)
	for frame: int in range(36): p.player.advance(1.0/120)
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	var held: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
	var held_time: float = p.player.current_animation_position
	p.suspend("pause"); p.suspend("focus")
	# Observe real automatic processing. Calling private AnimationPlayer.advance
	# forcibly evaluates its mixer even while paused, bypassing owner suspension.
	await create_timer(.05).timeout
	var frozen: PackedVector3Array = NpcAssetProbe.deformed_vertices(p)
	var freeze_drift: float = 0
	for i: int in range(held.size()): freeze_drift=maxf(freeze_drift,held[i].distance_to(frozen[i]))
	var freeze_time_equal: bool = p.player.current_animation_position == held_time
	_check(freeze_drift < .000001 and freeze_time_equal and not p.set_action(action), "overlapping holds freeze pose/time and reject new action; drift="+str(freeze_drift))
	p.resume("pause"); _check(p.suspended() and p.active_action() == action, "one hold cannot release another")
	p.resume("focus")
	await create_timer(.05).timeout
	_check(not p.suspended() and p.active_action() == action and NpcAssetProbe.deformed_vertices(p) != held, "last hold resumes action")
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for reason: String in ["dialogue","travel","modal","death"]:
		p.suspend(reason)
		_check(p.active_action().is_empty() and not prop.visible and not p.set_action(action), "unsafe context cancels/rejects action " + reason)
		p.resume(reason)
		_check(p.player.current_animation == "idle", "unsafe context resumes idle " + reason)
		p.set_action(action)
	p.set_locomotion(.8)
	_check(p.active_action().is_empty() and not prop.visible and not p.set_action(action), "achieved walking cancels action and prevents moving start")
	# Interrupt before the blend completes, using the same automatic owner path.
	p.set_locomotion(0); p.set_action(action)
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	await create_timer(.025).timeout
	var blend_held: PackedVector3Array=NpcAssetProbe.deformed_vertices(p)
	var blend_time: float=p.player.current_animation_position
	p.suspend("focus")
	await create_timer(.05).timeout
	_check(NpcAssetProbe.deformed_vertices(p)==blend_held and p.player.current_animation_position==blend_time, "focus freezes pending real blend without snapping accessory")
	p.resume("focus")
	await create_timer(.15).timeout
	_check(p.active_action()==action and p.player.current_animation_position>blend_time, "pending blend resumes without restarting action")
	var accepted: Node3D = p.model
	_check(not p.mount(null).is_empty() and p.model == accepted, "invalid replacement retains accepted variant")
	metrics[action]={"samples":481,"bounds_min":TestRunObservation.vector(full.position),"bounds_size":TestRunObservation.vector(full.size),"max_120hz_step":max_step,"seam":seam,"planted_foot_drift":max_foot,"blend_max_step":blend_max,"hold_vertex_drift":freeze_drift,"hold_position_unchanged":freeze_time_equal}
	p.free()

func _owners() -> void:
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	_check((await game.world_host.transition_finished)[0], "actual startup")
	var memories: String = TestRunSnapshot.exact_json(game.session.conversations.snapshot())
	var refs: Array[WeakRef] = []
	for index: int in range(2):
		var id: String = "npc-0%d" % (index+1)
		var p: NpcVisualPresenter = game.world_host.current_location.npc_contacts.presenters[id]
		memories = TestRunSnapshot.exact_json(game.session.conversations.snapshot())
		var target: PrototypeInteractable=game.world_host.current_location.npc_contacts.targets[id]
		var wrapper_transform: Transform3D=target.global_transform
		_check(p.model.scene_file_path == NpcRegistry.VISUAL_ASSETS[id] and p.active_action().is_empty() and p.player.has_animation(CLIPS[index]), "promoted civic asset starts idle without ambient action " + id)
		# Synthetic replacement exercises real production owner hooks, not ordinary access.
		_check(p.mount(load(ASSETS[index])).is_empty() and p.set_action(CLIPS[index]), "synthetic action mount in scene-owned contact")
		refs.append(weakref(p))
		game._set_paused(true)
		var held: float = p.player.current_animation_position
		await create_timer(.05).timeout
		_check(p.suspended() and p.player.current_animation_position == held and p.active_action() == CLIPS[index], "actual pause freezes action")
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		game._set_paused(false)
		_check(p.suspended(), "actual focus hold survives pause release")
		game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		_check(not p.suspended() and p.active_action() == CLIPS[index], "actual focus resumes action")
		_check(TestRunSnapshot.exact_json(game.session.conversations.snapshot()) == memories, "art/holds change no facts/receipts/affinity/events")
		game.player_placeholder.global_position=NpcRegistry.find(id).approach
		await physics_frame
		_check(game.interact().ok and p.suspended() and p.active_action().is_empty(), "actual dialogue cancels action")
		game._cancel_dialogue()
		_check(not p.suspended() and p.player.current_animation == "idle", "dialogue close resumes idle")
		_check(target.global_transform==wrapper_transform and target.instance_id==NpcRegistry.find(id).instance_id, "action/turn/interrupt preserves scene identity and fixed feet")
		p.set_action(CLIPS[index])
	memories = TestRunSnapshot.exact_json(game.session.conversations.snapshot())
	_check(game.world_host.request_transition("prototype-test-room","prototype-start").is_empty(), "actual travel starts")
	_check((await game.world_host.transition_finished)[0], "actual travel arrives")
	for ref: WeakRef in refs: _check(ref.get_ref() == null, "travel disposes action presenter/accessory")
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(), "return starts")
	_check((await game.world_host.transition_finished)[0], "return arrives")
	_check(TestRunSnapshot.exact_json(game.session.conversations.snapshot()) == memories, "action disposal/reconstruction adds no dialogue history")
	for index: int in range(2):
		var id: String="npc-0%d" % (index+1)
		var p: NpcVisualPresenter=game.world_host.current_location.npc_contacts.presenters[id]
		_check(p.model.scene_file_path == NpcRegistry.VISUAL_ASSETS[id] and p.active_action().is_empty(), "reconstruction restores ordinary asset without saved pose")
	_check(game.world_host.current_location.npc_contacts.presenters.size()==NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and game.party.members().size()==2, "eight contacts and original party retained")
	game.queue_free(); await process_frame

func _check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures.append(message)
