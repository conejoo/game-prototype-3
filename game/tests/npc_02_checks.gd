extends SceneTree
## N009 actual production wrapper/skin/lifecycle fixtures; ordinary proof in renderer.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var metrics: Dictionary = {}

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "production arrival")
	if not startup[0]: await _finish(); return
	var room: PrototypeLocation = game.world_host.current_location
	_check(room.npc_contacts.targets.keys() == Array(NpcRegistry.enabled_for(NpcRegistry.LOCATION)) and room.npc_contacts.presenters.keys() == Array(NpcRegistry.enabled_for(NpcRegistry.LOCATION)), "each enabled named person activated once")
	var target: PrototypeInteractable = room.npc_contacts.targets["npc-02"]
	var p: NpcVisualPresenter = room.npc_contacts.presenters["npc-02"]
	_check(target.instance_id == "alderwake-npc-02-contact" and target.prompt == "Talk to Archivist Vale" and target.global_position == Vector3(1.5,0,-1.5), "source identity/approved foot/prompt")
	_check(p.model.scene_file_path == "res://assets/models/npcs/npc-02.glb" and p.skeleton.get_bone_count() == 16, "named exported skin")
	_check(game.party.members().size() == 2 and game.session.actors.size() == 2, "noncombatant outside party")
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	# Bounds in actual deformed imported mesh, not rest AABB. Remove facing/foot.
	var previous: Transform3D = p.global_transform
	p.global_transform = Transform3D.IDENTITY
	for clip: String in ["idle","walk"]:
		var duration: float = p.player.get_animation(clip).length
		var full: AABB
		var last: PackedVector3Array
		var max_step: float = 0
		for index: int in range(ceili(duration*120)+1):
			var vertices: PackedVector3Array = NpcAssetProbe.sample(p,clip,minf(duration,float(index)/120))
			var box: AABB = NpcAssetProbe.bounds(vertices)
			full = box if index == 0 else full.merge(box)
			_check(box.position.y >= -.0001 and box.end.y <= 1.61 and maxf(absf(box.position.x),absf(box.end.x)) <= .4 and maxf(absf(box.position.z),absf(box.end.z)) <= .4, clip + " supported capsule envelope")
			if not last.is_empty():
				for i: int in range(vertices.size()): max_step = maxf(max_step,vertices[i].distance_to(last[i]))
			last = vertices
		var start: PackedVector3Array = NpcAssetProbe.sample(p,clip,0)
		var end: PackedVector3Array = NpcAssetProbe.sample(p,clip,duration)
		var seam: float = 0
		for i: int in range(start.size()): seam=maxf(seam,start[i].distance_to(end[i]))
		_check(seam < .0001 and max_step < .035, clip + " continuous exported loop")
		metrics[clip] = {"bounds_min":TestRunObservation.vector(full.position),"bounds_size":TestRunObservation.vector(full.size),"max_vertex_step":max_step,"seam":seam,"samples":ceili(duration*120)+1}
	var max_slide: float = 0
	for cycle: int in range(2):
		for side: String in ["L","R"]:
			var start_time: float = cycle*.8 + (0 if side == "L" else .4)
			var reference: Vector3
			for i: int in range(49):
				var time: float = start_time+float(i)/120
				p.position=Vector3(0,0,-time*.8)
				NpcAssetProbe.sample(p,"walk",fmod(time,.8))
				var foot: Vector3=NpcAssetProbe.bone_point(p,"foot."+side)
				if i==0: reference=foot
				max_slide=maxf(max_slide,foot.distance_to(reference))
	_check(max_slide<.001,"actual exported stance planted at .8m/s")
	metrics.stance={"samples":196,"speed":.8,"max_slide":max_slide}
	p.position=Vector3.ZERO
	NpcAssetProbe.sample(p,"idle",0)
	var previous_vertices: PackedVector3Array=NpcAssetProbe.deformed_vertices(p)
	var blend_step: float=0
	for clip: String in ["walk","idle","walk","idle"]:
		p.set_locomotion(.8 if clip=="walk" else 0)
		for i: int in range(30):
			p.player.advance(1.0/120)
			var current: PackedVector3Array=NpcAssetProbe.deformed_vertices(p)
			_check(NpcAssetProbe.bounds(current).position.y>=-.001,"actual blend never sinks sole")
			for v: int in range(current.size()): blend_step=maxf(blend_step,current[v].distance_to(previous_vertices[v]))
			previous_vertices=current
	_check(blend_step<.06,"actual named skin blends continuous")
	metrics.blend={"samples":120,"max_vertex_step":blend_step}
	p.global_transform=previous
	p.player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	p.set_locomotion(0)
	game._set_paused(true)
	_check(p.suspended(), "actual pause owner")
	var held: float = p.player.current_animation_position
	await create_timer(.05).timeout
	_check(p.player.current_animation_position == held, "pause freezes exported pose")
	game._set_paused(false)
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(p.suspended(), "actual focus owner")
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	_check(not p.suspended(), "focus resumes fixed idle")
	game.player_placeholder.global_position = NpcRegistry.find("npc-02").approach
	await physics_frame
	_check(game.interact().ok and game.dialogue.snapshot().npc_id == "npc-02" and p.suspended(), "actual dialogue owner and binding")
	game._cancel_dialogue()
	_check(not p.suspended(), "dialogue release")
	var original: WeakRef = weakref(p)
	_check(game.world_host.request_transition("prototype-test-room","prototype-start").is_empty(), "fixture travel request")
	_check((await game.world_host.transition_finished)[0] and original.get_ref() == null, "travel disposes old named presenter")
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(), "fixture return request")
	_check((await game.world_host.transition_finished)[0], "return arrival")
	_check(game.world_host.current_location.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and game.world_host.current_location.npc_contacts.presenters.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size(), "return exactly one")
	game.player_placeholder.state.health=0
	game.retry_encounter()
	_check((await game.world_host.transition_finished)[0], "retry arrival")
	_check(game.world_host.current_location.npc_contacts.targets.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and game.world_host.current_location.npc_contacts.presenters.size() == NpcRegistry.enabled_for(NpcRegistry.LOCATION).size(), "retry exactly one")
	# Synthetic source-disclosure audit, distinct from renderer ordinary route.
	var npc: NpcDefinition=game.npc_catalog.get_npc("npc-02")
	var memory: ConversationMemory=game.session.conversations.memory("npc-02")
	for id: String in ["npc-02-routine-archive-default","npc-02-routine-archive-indexing"]:
		var node: NpcDialogueGraph.NodeDefinition=npc.graph.nodes[id]
		_check(node.availability.is_enabled() and not node.availability.reason.is_empty(),"archive preferred entry requires live routine context "+id)
		for choice: NpcDialogueGraph.Choice in node.choices:
			_check(not NpcDialogueRules.choice_reason(npc,choice,memory,game.session.conversations.events(),game.session.elapsed_play_seconds).is_empty(),"routine outcome unavailable "+choice.id)
	_check(npc.facts["npc-02-archive-practice"].availability.is_enabled() and "npc-02-archive-practice" not in memory.learned_fact_ids,"archive practice unknown in ordinary public context")
	_check(game.world_host.current_location.npc_contacts.presenters["npc-02"].model.scene_file_path != "res://assets/models/npcs/npc-01.glb","Helena distinct named model")
	await _finish()

func _check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures.append(message); print("N009_ASSERTION_FAILED ",message)

func _finish() -> void:
	_check(TestRunEvidence.write_json("npc-02-checks.json",{"assertions":assertions,"metrics":metrics,"failures":failures,"proof":"synthetic production skin/lifecycle fixtures; no ordinary movement"}),"evidence write")
	paused=false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("N009 checks ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
