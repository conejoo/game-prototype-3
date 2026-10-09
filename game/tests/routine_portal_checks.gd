extends SceneTree
## R005 synthetic multi-exit geometry plus real production dispatch regression.

var failures: PackedStringArray = []
var assertions: int = 0
var game: Node3D

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	_rules()
	await _world()
	_check(TestRunEvidence.write_json("routine-portals.json", {"assertions":assertions,
		"failures":failures,"provenance":"synthetic three-room/multi-exit setup; production selector dispatch uses labeled direct placement; no ordinary walking/room delivery claim"}), "evidence write")
	for failure: String in failures: push_error(failure)
	print("R005 routine portal checks: %d assertions, %d failures" % [assertions,failures.size()])
	quit(0 if failures.is_empty() else 1)

func _binding(id: String, source: String, destination: String, arrival: String = "start") -> PortalBinding:
	var binding: PortalBinding = PortalBinding.new()
	binding.portal_id = id
	binding.source_location_id = source
	binding.destination_location_id = destination
	binding.arrival_id = arrival
	return binding

func _definitions() -> Array[LocationDefinition]:
	var result: Array[LocationDefinition] = []
	for id: String in ["r005-source","r005-west","r005-east"]:
		var definition: LocationDefinition = LocationDefinition.new()
		definition.stable_id = id
		definition.display_name = "R005 synthetic " + id
		definition.scene_path = "res://tests/fixtures/r005/%s.tscn" % id
		definition.spawn_ids = ["start"]
		definition.actor_ids = ["prototype-hero"]
		result.append(definition)
	result[0].portals = [_binding("west","r005-source","r005-west"), _binding("east","r005-source","r005-east")]
	result[1].portals = [_binding("return","r005-west","r005-source")]
	result[2].portals = [_binding("return","r005-east","r005-source")]
	return result

func _rules() -> void:
	var definitions: Array[LocationDefinition] = _definitions()
	var routes: PortalRoutes = PortalRoutes.new()
	_check(routes.initialize(definitions).is_empty(), "two exits and qualified duplicate return IDs validate")
	for destination: String in ["r005-west","r005-east"]:
		var route: Dictionary = routes.route("r005-source",destination)
		_check(route.ok and route.legs.size() == 1 and route.legs[0].destination_location_id == destination and route.legs[0].arrival_id == "start", "distinct explicit destination " + destination)
	var chain: Dictionary = routes.route("r005-west","r005-east")
	_check(chain.ok and chain.legs.size() == 2 and chain.legs[0].portal_id == "return" and chain.legs[1].portal_id == "east", "directed multi-hop chain")
	_check(routes.route("r005-west","r005-west").legs.is_empty(), "same-map route has zero portal legs")
	_check(not routes.route("absent","r005-east").ok and not routes.route("r005-west","absent").ok, "unknown maps reject")
	chain.legs[0].arrival_id = "corrupted"
	_check(routes.route("r005-west","r005-east").legs[0].arrival_id == "start", "query result is detached")
	var snapshot: Dictionary = routes.binding("r005-source","west")
	snapshot.destination_location_id = "corrupted"
	_check(routes.binding("r005-source","west").destination_location_id == "r005-west", "binding result detached")
	for mutation: String in ["source","arrival","destination","id","duplicate","null","self","blank"]:
		var bad: Array[LocationDefinition] = _definitions()
		match mutation:
			"source": bad[0].portals[0].source_location_id = "r005-east"
			"arrival": bad[0].portals[0].arrival_id = "absent"
			"destination": bad[0].portals[0].destination_location_id = "absent"
			"id": bad[0].portals[0].portal_id = " padded "
			"duplicate": bad[0].portals.append(bad[0].portals[0])
			"null": bad[0].portals.append(null)
			"self": bad[0].portals[0].destination_location_id = "r005-source"
			"blank": bad[0].portals[0].arrival_id = ""
		_check(not routes.initialize(bad).is_empty(), "malformed route rejected " + mutation)
		_check(routes.route("r005-west","r005-east").ok, "failed graph reload retains prior catalog " + mutation)
	definitions[0].portals[0].arrival_id = "mutated-authoring"
	_check(routes.binding("r005-source","west").arrival_id == "start", "graph detaches authored resources")
	var one_way: Array[LocationDefinition] = _definitions()
	one_way[1].portals.clear()
	_check(routes.initialize(one_way).is_empty() and not routes.route("r005-west","r005-east").ok, "no inferred reverse exit / finite cycle search")
	var catalog: ContentCatalog = ContentCatalog.new()
	var manifest: ContentManifest = load("res://content/prototype_catalog.tres").duplicate()
	manifest.definitions.append_array(_definitions())
	_check(catalog.initialize(manifest).is_empty(), "core catalog accepts qualified portals")
	var count: int = catalog.definition_count()
	var invalid: ContentManifest = manifest.duplicate()
	var invalid_location: LocationDefinition = _definitions()[0]
	invalid_location.portals[0].arrival_id = "absent"
	invalid.definitions.erase(manifest.definitions[-3])
	invalid.definitions.append(invalid_location)
	_check(not catalog.initialize(invalid).is_empty() and catalog.definition_count() == count, "catalog rejects portal refs atomically")
	var room: PrototypeLocation = load("res://tests/fixtures/r005/r005-source.tscn").instantiate()
	var definition: LocationDefinition = catalog.get_location("r005-source")
	_check(room.validation_errors(definition,catalog).is_empty(), "synthetic physical exits match declarations")
	var west: PrototypeInteractable = room.get_node("West")
	var original: PortalBinding = west.portal
	west.portal = original.duplicate()
	west.portal.source_location_id = "r005-east"
	_check(not room.validation_errors(definition,catalog).is_empty(), "wrong physical source refuses staged scene")
	west.portal = original.duplicate()
	west.portal.arrival_id = "absent"
	_check(not room.validation_errors(definition,catalog).is_empty(), "wrong physical arrival refuses staged scene")
	west.portal = original
	var duplicate: PrototypeInteractable = west.duplicate()
	duplicate.instance_id = "different-instance-same-portal"
	room.add_child(duplicate)
	_check("duplicate physical portal" in "; ".join(room.validation_errors(definition,catalog)), "duplicate physical edge refuses staged scene")
	duplicate.free()
	room.get_node("East").free()
	_check("declared portal missing" in "; ".join(room.validation_errors(definition,catalog)), "missing physical edge refuses staged scene")
	west.portal = null
	_check("explicit portal binding" in "; ".join(room.validation_errors(definition,catalog)), "unbound travel refuses staged scene")
	room.free()

func _world() -> void:
	game = load("res://app/game_root.tscn").instantiate()
	var manifest: ContentManifest = game.content_manifest.duplicate()
	manifest.definitions.append_array(_definitions())
	game.content_manifest = manifest
	root.add_child(game)
	var startup: Array = await game.world_host.transition_finished
	_check(startup[0], "real root startup")
	game._set_paused(true)
	var host: PrototypeWorldHost = game.world_host
	var durable: Dictionary = SaveCodec.snapshot(game.session)
	var party: Array[ActorPlaceholder] = game.party.members()
	var feet: Array[Vector3] = []
	for actor: ActorPlaceholder in party: feet.append(actor.global_position)
	var camera: Transform3D = game.camera_rig.global_transform
	var location: PrototypeLocation = host.current_location
	var count: int = host.transition_count
	for iteration: int in range(100):
		_check(host.npc_portal_route("prototype-alderwake","prototype-tollworks").ok, "NPC current route " + str(iteration))
		_check(host.npc_portal_route("r005-west","r005-east").legs.size() == 2, "NPC qualified chain " + str(iteration))
		_check(not host.npc_portal_route("prototype-alderwake","prototype-mayor-vale-home").ok and not host.npc_portal_route("prototype-alderwake","prototype-lantern-rest").ok, "absent rooms remain inactive " + str(iteration))
	_check(SaveCodec.snapshot(game.session) == durable and host.current_location == location and host.transition_count == count and not host.transitioning and game.party.members() == party and game.camera_rig.global_transform == camera, "NPC queries preserve player/session/camera/party ownership")
	for index: int in range(party.size()): _check(party[index].global_position == feet[index], "NPC queries preserve feet")
	var source_gate: PrototypeInteractable = location.get_node("TravelGate")
	var source_ref: WeakRef = weakref(source_gate)
	var original: PortalBinding = source_gate.portal
	for mutation: String in ["source","arrival","valid-arrival","destination","id"]:
		source_gate.portal = original.duplicate()
		match mutation:
			"source": source_gate.portal.source_location_id = "prototype-tollworks"
			"arrival": source_gate.portal.arrival_id = "absent"
			"valid-arrival": source_gate.portal.arrival_id = "tollworks-start"
			"destination": source_gate.portal.destination_location_id = "prototype-alderwake"
			"id": source_gate.portal.portal_id = "absent"
		_check(not host.request_portal(source_ref).is_empty() and host.current_location == location and not host.transitioning and SaveCodec.snapshot(game.session) == durable, "wrong active portal inert " + mutation)
	source_gate.portal = original
	var fake: PrototypeInteractable = PrototypeInteractable.new()
	fake.kind = "travel"
	fake.portal = original
	_check(not host.request_portal(weakref(fake)).is_empty() and not host.request_portal(null).is_empty(), "foreign detached/null portal rejects")
	fake.free()
	# Synthetic placement drives the actual root selector/dispatch; no walk claim.
	game._set_paused(false)
	game.player_placeholder.global_position = source_gate.global_position + Vector3(0,0,0.9)
	_check(game.interact().ok, "production selector starts explicitly bound Tollworks travel")
	var arrived: Array = await host.transition_finished
	_check(arrived[0] and game.session.current_spawn_id == "tollworks-from-alderwake", "production Tollworks arrival unchanged")
	game._set_paused(true)
	_check(not host.request_portal(source_ref).is_empty(), "freed old portal rejects safely")
	var return_gate: PrototypeInteractable = host.current_location.get_node("TravelGate")
	game._set_paused(false)
	game.player_placeholder.global_position = return_gate.global_position + Vector3(0,0,0.9)
	_check(game.interact().ok, "production selector return uses bound exit")
	arrived = await host.transition_finished
	_check(arrived[0] and game.session.current_spawn_id == "alderwake-from-tollworks", "production return arrival unchanged")
	_check(host.request_transition("r005-source","start").is_empty(), "synthetic hub starts")
	arrived = await host.transition_finished
	_check(arrived[0], "synthetic hub safe full-party arrival")
	for destination: String in ["r005-west","r005-east"]:
		var portal_name: String = "West" if destination == "r005-west" else "East"
		var exit: PrototypeInteractable = host.current_location.get_node(portal_name)
		# Deliberately incorrect single-room mirror proves dispatch never infers it.
		host.current_location.destination_id = "prototype-alderwake"
		host.current_location.destination_spawn_id = "alderwake-start"
		game.player_placeholder.global_position = exit.global_position + Vector3(0,0,0.9)
		_check(game.interact().ok, "root selects distinct synthetic exit " + destination)
		arrived = await host.transition_finished
		_check(arrived[0] and game.session.current_location_id == destination and game.session.current_spawn_id == "start", "distinct intended destination reached " + destination)
		for frame: int in range(4): await physics_frame
		_check(host.get_child_count() == 1 and NavigationServer3D.map_get_regions(host.get_world_3d().navigation_map).size() == 1 and game.party.members() == party, "one location/region and unchanged party " + destination)
		_check(game.player_placeholder.is_on_floor() and game.companion.is_on_floor(), "both synthetic arrivals grounded " + destination)
		var back: PrototypeInteractable = host.current_location.get_node("Return")
		game.player_placeholder.global_position = back.global_position + Vector3(0,0,0.9)
		_check(game.interact().ok, "synthetic reciprocal source dispatch")
		arrived = await host.transition_finished
		_check(arrived[0] and game.session.current_location_id == "r005-source", "synthetic source restored")
	game.queue_free()
	await process_frame

func _check(condition: bool, message: String) -> void:
	assertions += 1
	if not condition: failures.append(message)
