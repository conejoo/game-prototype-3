extends SceneTree
## N015 actual production wrapper/skin/lifecycle fixtures; ordinary proof in renderer.
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
	_check(room.npc_contacts.targets.keys() == Array(NpcRegistry.ENABLED) and room.npc_contacts.presenters.keys() == Array(NpcRegistry.ENABLED), "each enabled named person activated once")
	var target: PrototypeInteractable = room.npc_contacts.targets["npc-14"]
	var p: NpcVisualPresenter = room.npc_contacts.presenters["npc-14"]
	_check(target.instance_id == "alderwake-npc-14-contact" and target.prompt == "Talk to Della Pike" and target.global_position == Vector3(-9,0,3.5), "source identity/approved foot/prompt")
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
	_check(is_equal_approx(p.rotation.y,atan2(-direction.x,-direction.z)) and target.global_position==Vector3(-9,0,3.5),"speaking faces actual player without moving contact")
	game._cancel_dialogue()
	_check(not p.suspended(), "dialogue release")
	var original: WeakRef = weakref(p)
	_check(game.world_host.request_transition("prototype-test-room","prototype-start").is_empty(), "fixture travel request")
	_check((await game.world_host.transition_finished)[0] and original.get_ref() == null, "travel disposes old named presenter")
	_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(), "fixture return request")
	_check((await game.world_host.transition_finished)[0], "return arrival")
	_check(game.world_host.current_location.npc_contacts.targets.size() == NpcRegistry.ENABLED.size() and game.world_host.current_location.npc_contacts.presenters.size() == NpcRegistry.ENABLED.size(), "return exactly one")
	game.player_placeholder.state.health=0
	game.retry_encounter()
	_check((await game.world_host.transition_finished)[0], "retry arrival")
	_check(game.world_host.current_location.npc_contacts.targets.size() == NpcRegistry.ENABLED.size() and game.world_host.current_location.npc_contacts.presenters.size() == NpcRegistry.ENABLED.size(), "retry exactly one")
	# Production inn-entry/dock full-footprint support and neighboring lane (synthetic).
	var live: PrototypeLocation=game.world_host.current_location
	var excluded: Array[RID]=[]
	for actor: CharacterBody3D in game.party.members(): excluded.append(actor.get_rid())
	_check(live.npc_contacts.placement_errors(live,excluded).is_empty(),"all eight full support/navigation/LOS contacts valid")
	var lane_goal: Vector3=Vector3(-7,0,4.25)
	var lane: PackedVector3Array=NavigationServer3D.map_get_path(live.get_world_3d().navigation_map,NpcRegistry.find("npc-14").approach,lane_goal,true)
	_check(lane.size()>=2 and lane[-1].distance_to(lane_goal)<.3 and NpcWorldAdapter.foot_errors(live,lane_goal,excluded).is_empty(),"inn-entry/dock lane remains navigable and supports full player footprint")
	metrics.inn_entry_lane=Array(lane)
	for i: int in range(lane.size()-1):
		var samples: int=ceili(lane[i].distance_to(lane[i+1])/.25)
		for sample: int in range(samples+1):
			var foot: Vector3=lane[i].lerp(lane[i+1],float(sample)/maxi(samples,1))
			_check(NpcWorldAdapter.foot_errors(live,foot,excluded).is_empty(),"inn-entry lane full player footprint "+str(foot))
	for water: Vector3 in [Vector3(35,0,25),Vector3(38,0,25),Vector3(41,0,24)]:
		_check(not NpcWorldAdapter.foot_errors(live,water,excluded).is_empty(),"water/quay full-footprint rejection "+str(water))
	_check(live.npc_contacts.presenters["npc-14"].model.scene_file_path != live.npc_contacts.presenters["npc-03"].model.scene_file_path,"distinct Della skin rather than Maris reuse")
	var npc: NpcDefinition=game.npc_catalog.get_npc("npc-14")
	_check(npc.facts.size()==3 and npc.graph.nodes.size()==10,"exact source public graph")
	_check(not npc.graph.nodes["npc-14-gift-end"].availability.is_enabled(),"gift target deferred")
	_check(game.session.completed_effect_ids.is_empty() and game.session.relationship.trust==0 and game.session.inventory.count("item-moonflower")==0,"conversation no item/quest/trust/service reward")
	# Exact pinned inert future portal, never synthesized from indoor coordinates.
	var portal: Rect2=Rect2(-8,3.5,2,1.5)
	var body_rect: Rect2=Rect2(-9.4,3.1,.8,.8)
	_check(not portal.intersects(body_rect),"Della full capsule stays outside future portal pad")
	metrics.placement={"source_map":"lantern-rest","source_placement":"della-inn-host-01","source_anchor":"inn-host-01","source_interior_units":[256,288],"target_foot":[-9,0,3.5],"approach":[-9,0,4.5],"policy":"public exterior adaptation; no interior transform","portal_rect":[-8,3.5,2,1.5]}
	for z: float in [3.9,4.25,4.6]:
		for x: float in [-7.6,-7,-6.4]:
			_check(NpcWorldAdapter.foot_errors(live,Vector3(x,0,z),excluded).is_empty(),"future door pad full footprint remains clear "+str(Vector3(x,0,z)))
	_check(not npc.graph.nodes["npc-14-room"].availability.is_enabled(),"indoor directions deferred")
	game.player_placeholder.global_position=NpcRegistry.find("npc-14").approach
	await physics_frame
	_check(game.interact().ok,"bound public Della route")
	var intro: Dictionary=game.dialogue.snapshot()
	_check(game._choose_dialogue("npc-14-careful-response",intro).ok,"source introduction choice")
	game._cancel_dialogue()
	_check(game.interact().ok,"public Della return")
	var choices: Dictionary=game.dialogue.snapshot()
	var before_reject: Dictionary=SaveCodec.snapshot(game.session)
	_check(not game._choose_dialogue("npc-14-ask-room",choices).ok and SaveCodec.snapshot(game.session)==before_reject,"hidden indoor command cannot grant room or leak directions")
	_check(not game._choose_dialogue("npc-14-gift-moonflower",choices).ok and SaveCodec.snapshot(game.session)==before_reject,"gift command inert")
	_check(not game.ui.dialogue_view.body.get_parsed_text().contains("guest room is on the right"),"no indoor directions leaked")
	game._cancel_dialogue()

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
