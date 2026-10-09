extends SceneTree
## Synthetic controlled current-map baseline versus all-eight reservations.
## Ordinary movement, UI, combat and restart are proved by the separate renderer.
var game: Node3D
var failures: PackedStringArray = []
var assertions: int = 0
var measurements: Array[Dictionary] = []

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	game=load("res://app/game_root.tscn").instantiate(); root.add_child(game)
	_check((await game.world_host.transition_finished)[0],"integrated production startup")
	game.set_process(false)
	game.player_placeholder.set_physics_process(false)
	game.companion.set_physics_process(false); game.companion_ai.set_physics_process(false)
	var compact: PrototypeLocation=load("res://tests/fixtures/compact_alderwake.tscn").instantiate()
	compact.location_id=NpcRegistry.LOCATION
	var adapter: NpcWorldAdapter=NpcWorldAdapter.new()
	_check(adapter.build(compact,NpcRegistry.ENABLED)==PackedStringArray(["NPC contacts require their pinned actual map"]),"wrong geometry fails before contact mutation")
	_check(adapter.targets.is_empty() and adapter.get_child_count()==0,"wrong geometry no partial actors")
	adapter.free(); compact.free()
	var baseline: Dictionary={}
	for enabled: bool in [false,true]:
		game.world_host.enabled_npcs=NpcRegistry.ENABLED if enabled else PackedStringArray()
		_check(game.world_host.request_transition(NpcRegistry.LOCATION,"alderwake-start").is_empty(),"controlled map transition")
		_check((await game.world_host.transition_finished)[0],"controlled map arrival")
		var room: AlderwakeExterior=game.world_host.current_location
		var ready: Dictionary=await TestRunJourney.wait_navigation(room,Vector3.ZERO)
		_check(ready.ok,ready.error)
		if not ready.ok: break
		_check(room.npc_contacts.targets.size()==(NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() if enabled else 0),"measured crowd size")
		var goals: Array[Vector3]=[Vector3(93,0,-.5),Vector3(103,0,-.5),Vector3(66,0,12.5),Vector3(75,0,12.5),Vector3(107.25,0,-1.25)]
		for contact: Dictionary in NpcRegistry.entries(NpcRegistry.LOCATION): goals.append(contact.approach)
		for index: int in goals.size():
			var samples: PackedFloat64Array=[]
			var path: PackedVector3Array=[]
			for iteration: int in range(110):
				var began: int=Time.get_ticks_usec()
				path=NavigationServer3D.map_get_path(room.get_world_3d().navigation_map,Vector3.ZERO,goals[index],true)
				if iteration>=10: samples.append(Time.get_ticks_usec()-began)
			_check(path.size()>=2 and path[-1].distance_to(goals[index])<.3,"current-map reachable endpoint "+str(index))
			var length: float=0
			for segment: int in range(1,path.size()): length+=path[segment-1].distance_to(path[segment])
			samples.sort()
			var row: Dictionary={"crowd":enabled,"goal":str(goals[index]),"path_m":length,"query_p50_usec":samples[49],"query_p95_usec":samples[94],"samples":100}
			measurements.append(row)
			if not enabled: baseline[index]=row
			else:
				_check(length<=float(baseline[index].path_m)+maxf(2.0,float(baseline[index].path_m)*.1),"crowd route detour budget "+str(index))
				# Existing M018 threshold is 5ms; retain the full paired distribution
				# instead of treating Windows scheduling noise as a 2ms product gate.
				_check(float(row.query_p95_usec)<=5000,"established map query p95 budget "+str(index))
		if enabled:
			_check(game.party.members().size()==2 and room.npc_contacts.targets["npc-03"]==room.get_node("MarisCounter"),"no duplicate villager/party wrapper")
			var excluded: Array[RID]=[game.player_placeholder.get_rid(),game.companion.get_rid()]
			_check(room.npc_contacts.placement_errors(room,excluded).is_empty(),"all eight simultaneous footprints/LOS")
	var nodes: int=0; var choices: int=0; var facts: int=0
	var deferred: Array[Dictionary]=[]
	for id: String in NpcContentCatalog.ROSTER:
		var npc: NpcDefinition=game.npc_catalog.get_npc(id)
		for node: NpcDialogueGraph.NodeDefinition in npc.graph.nodes.values():
			if node.availability.is_enabled(): nodes+=1
			else: deferred.append({"kind":"node","id":node.id,"reason":node.availability.reason})
		for choice: NpcDialogueGraph.Choice in npc.graph.choices.values():
			if choice.availability.is_enabled(): choices+=1
			else: deferred.append({"kind":"choice","id":choice.id,"reason":choice.availability.reason})
		for fact: NpcDefinition.Fact in npc.facts.values():
			if fact.availability.is_enabled(): facts+=1
			else: deferred.append({"kind":"fact","id":fact.id,"reason":fact.availability.reason})
	_check(nodes==69 and choices==53 and facts==22,"exact composed social/public-routine coverage contract")
	# Labeled synthetic service setup creates eight valid, independent memories;
	# actual root death/retry must retain all complete durable facts exactly.
	for id: String in NpcRegistry.ENABLED:
		_check(game.dialogue.begin(id,NpcRegistry.find(id).instance_id).ok,"synthetic legal memory entry "+id)
		var snap: Dictionary=game.dialogue.snapshot()
		_check(game.dialogue.choose(id,snap.instance_id,snap.node_id,snap.token,snap.choices[0].id).ok,"synthetic exclusive memory "+id)
		game.dialogue.cancel()
	var before_retry: Dictionary=SaveCodec.snapshot(game.session)
	game.player_placeholder.receive_damage(100)
	await game.retry_encounter()
	_check(SaveCodec.snapshot(game.session)==before_retry,"all-eight death/retry preserves whole healed durable state")
	_check(game.world_host.current_location.npc_contacts.targets.size()==NpcRegistry.enabled_for(NpcRegistry.LOCATION).size() and game.party.members().size()==2,"retry reconstructs exactly seven town contacts/two party actors")
	for row: Dictionary in deferred: _check(not row.reason.is_empty(),"deferred coverage explicit "+row.id)
	_check(TestRunEvidence.write_json("npc-integration-checks.json",{"task":"N017","proof":"synthetic controlled map baseline/crowd; not ordinary input","assertions":assertions,"failures":failures,"measurements":measurements,"enabled_nodes":nodes,"enabled_choices":choices,"enabled_facts":facts,"deferred":deferred}),"integration rule evidence")
	game.queue_free(); await process_frame
	for failure: String in failures: push_error(failure)
	print("N017 integration checks ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)

func _check(ok: bool,message: String) -> void:
	assertions+=1
	if not ok: failures.append(message)
