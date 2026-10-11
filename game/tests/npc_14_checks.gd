extends SceneTree
## N015 actual production wrapper/skin/lifecycle fixtures; ordinary proof in renderer.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var metrics: Dictionary = {}

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	# AD012: explicit historical fixed-contact fixture; current routines verified separately.
	game.routine_execution = null
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "production arrival")
	if not startup[0]: await _finish(); return
	_check(not game.world_host.current_location.npc_contacts.targets.has("npc-14"),"no invisible or duplicate town Della")
	_check(game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(),"zero-affinity inn access")
	var arrived: Array = await game.world_host.transition_finished
	_check(arrived[0],"actual inn arrival")
	if not arrived[0]: await _finish(); return
	var room: PrototypeLocation = game.world_host.current_location
	_check(room is LanternRest and room.npc_contacts.targets.keys() == ["npc-14"] and room.npc_contacts.presenters.keys() == ["npc-14"],"one real host on her actual map")
	var target: PrototypeInteractable = room.npc_contacts.targets["npc-14"]
	var p: NpcVisualPresenter = room.npc_contacts.presenters["npc-14"]
	_check(target.instance_id == "della-inn-host-01" and target.prompt == "Talk to Della Pike" and target.global_position == Vector3(-6,0,-12),"exact source indoor host identity/foot/prompt")
	_check(p.model.scene_file_path == "res://assets/models/npcs/npc-14.glb" and p.skeleton.get_bone_count() == 16, "named exported skin")
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
	game.player_placeholder.global_position = NpcRegistry.find("npc-14").approach
	await physics_frame
	_check(game.interact().ok and game.dialogue.snapshot().npc_id == "npc-14" and p.suspended(), "actual dialogue owner and binding")
	var direction: Vector3=game.player_placeholder.global_position-target.global_position
	_check(is_equal_approx(p.rotation.y,atan2(-direction.x,-direction.z)) and target.global_position==Vector3(-6,0,-12),"speaking faces actual player without moving contact")
	game._cancel_dialogue()
	_check(not p.suspended(), "dialogue release")
	var original: WeakRef = weakref(p)
	var learned: Dictionary = game.session.conversations.snapshot()
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-from-lantern-rest").is_empty(),"real town return request")
	_check((await game.world_host.transition_finished)[0] and original.get_ref() == null,"return disposes old host presenter")
	_check(not game.world_host.current_location.npc_contacts.targets.has("npc-14") and game.world_host.current_location.npc_contacts.targets.size() == 7,"town retains seven contacts and no Della")
	_check(game.world_host.request_transition("prototype-lantern-rest","lantern-rest-from-alderwake").is_empty(),"real inn revisit")
	_check((await game.world_host.transition_finished)[0],"real revisit arrives")
	_check(game.world_host.current_location.npc_contacts.targets.keys() == ["npc-14"] and game.session.conversations.snapshot() == learned,"one rebound host/exact social facts")
	game.player_placeholder.state.health=0
	game.retry_encounter()
	_check((await game.world_host.transition_finished)[0],"inn retry arrival")
	_check(game.world_host.current_location.npc_contacts.targets.keys() == ["npc-14"],"retry exactly one real host")
	var live: PrototypeLocation=game.world_host.current_location
	var excluded: Array[RID]=[]
	for actor: CharacterBody3D in game.party.members(): excluded.append(actor.get_rid())
	_check(live.npc_contacts.placement_errors(live,excluded).is_empty(),"actual indoor host full support/navigation/LOS valid")
	var npc: NpcDefinition=game.npc_catalog.get_npc("npc-14")
	_check(npc.facts.size()==3 and npc.graph.nodes.size()==10,"exact source public graph IDs")
	_check(npc.graph.nodes["npc-14-gift-end"].availability.is_enabled(),"existing authored gift target retained")
	_check(not npc.graph.nodes["npc-14-room"].availability.is_enabled(),"paid room branch still deferred")
	game.player_placeholder.global_position=NpcRegistry.find("npc-14").approach
	await physics_frame
	_check(game.interact().ok,"actual indoor host interaction")
	var intro: Dictionary=game.dialogue.snapshot()
	_check(game._choose_dialogue("npc-14-careful-response",intro).ok,"source introduction choice")
	game._cancel_dialogue()
	_check(game.interact().ok,"actual indoor return dialogue")
	var choices: Dictionary=game.dialogue.snapshot()
	game.set_process(false)
	var before_reject: Dictionary=SaveCodec.snapshot(game.session)
	_check(not game._choose_dialogue("npc-14-ask-room",choices).ok and SaveCodec.snapshot(game.session)==before_reject,"deferred room command cannot grant entitlement")
	_check(not game._choose_dialogue("npc-14-gift-moonflower",choices).ok and SaveCodec.snapshot(game.session)==before_reject,"unowned undisclosed gift inert")
	_check(not game.ui.dialogue_view.body.get_parsed_text().contains("interior is not open") and game.ui.dialogue_view.status.text.contains("Paid rooms"),"obsolete location wording removed; services stay explicit")
	game._cancel_dialogue()
	_check(game.session.completed_effect_ids.is_empty() and game.session.relationship.trust==0 and game.session.inventory.count("item-moonflower")==0,"no item/quest/trust/service reward")
	metrics.placement={"source_map":"lantern-rest","source_placement":"della-inn-host-01","source_anchor":"inn-host-01","source_units":[256,288],"target_foot":[-6,0,-12],"approach":[-6,0,-10.8],"policy":"exact indoor transform; no duplicate exterior actor"}
	await _finish()

func _check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures.append(message); print("N015_ASSERTION_FAILED ",message)

func _finish() -> void:
	_check(TestRunEvidence.write_json("npc-14-checks.json",{"assertions":assertions,"metrics":metrics,"failures":failures,"proof":"synthetic production skin/lifecycle fixtures; no ordinary movement"}),"evidence write")
	paused=false
	game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("N015 checks ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
