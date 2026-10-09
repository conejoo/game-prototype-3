class_name NpcWorldAdapter
extends Node3D
## Scene-owned noncombatant wrappers. VisualRoot is replaced by character tasks.
var targets: Dictionary[String, PrototypeInteractable] = {}
var presenters: Dictionary[String, NpcVisualPresenter] = {}
var movers: Dictionary[String, RoutineMovement] = {}
var occupancy: RoutineOccupancy = RoutineOccupancy.new()
var _holds: Dictionary = {}
var contact_records: Dictionary = {}
var scheduled: bool = false
var dialogue_leased: PackedStringArray = []

func _init() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _ready() -> void:
	_pin_counter_furniture()

func _enter_tree() -> void:
	# Rollback reattaches the same location after _exit_tree disposed weak bindings.
	# Rebind real bodies; execution owner reissues unfinished legs from real feet.
	for id: String in movers:
		var body: CharacterBody3D = targets[id].get_node("Body" if id == "npc-03" else "ContactBody")
		movers[id].configure(id,targets[id],body,get_parent() as PrototypeLocation,occupancy,.35 if id == "npc-03" else .4)

func _pin_counter_furniture() -> void:
	if not targets.has("npc-03"): return
	# Staging builds contacts before location enters the tree. Pin furniture
	# only once world transforms are available, before any physics motion.
	for path: String in ["BenchBody","VisualRoot/Bench","VisualRoot/BasicSupplies","VisualRoot/FittingGear","VisualRoot/SpecialistGear","VisualRoot/ServiceBoard"]:
		var furnishing: Node3D = targets["npc-03"].get_node(path)
		var fixed_transform: Transform3D = furnishing.global_transform
		furnishing.set_as_top_level(true)
		furnishing.global_transform = fixed_transform

func _physics_process(delta: float) -> void:
	var held: bool = false
	for reason: String in _holds:
		held = held or _holds[reason]
	var ids: Array = movers.keys()
	ids.sort()
	for id: String in ids:
		movers[id].step(delta,held or id in dialogue_leased)
		if presenters.has(id):
			presenters[id].set_locomotion(movers[id].achieved_speed)
			if movers[id].achieved_speed > .001:
				presenters[id].face_direction(movers[id].achieved_direction)

func _exit_tree() -> void:
	for mover: RoutineMovement in movers.values(): mover.dispose()
	occupancy.clear()

func move_to(id: String, foot: Vector3) -> bool:
	return movers.has(id) and movers[id].begin(foot)

func cancel_move(id: String) -> void:
	if movers.has(id): movers[id].cancel()

func build(location: PrototypeLocation, enabled: PackedStringArray, placements: Dictionary = {}, append: bool = false) -> PackedStringArray:
	if not targets.is_empty() and not append: return PackedStringArray(["NPC contacts already built"])
	if location.location_id not in [NpcRegistry.LOCATION,"prototype-lantern-rest","prototype-mayor-vale-home"]: return []
	if not enabled.is_empty() and not (location is AlderwakeExterior if location.location_id == NpcRegistry.LOCATION else location is LanternRest if location.location_id == "prototype-lantern-rest" else location is MayorValeHome):
		return PackedStringArray(["NPC contacts require their pinned actual map"])
	var seen: PackedStringArray = []
	for id: String in enabled:
		if NpcRegistry.find(id).is_empty() or id in seen: return PackedStringArray(["Unknown or duplicate NPC contact"])
		seen.append(id)
		if id in targets: return ["duplicate live NPC contact: "+id]
		if placements.is_empty() and NpcRegistry.find(id).location_id != location.location_id: continue
		if not placements.is_empty() and not placements.has(id): continue
		if id == "npc-03" and not location.get_node_or_null("MarisCounter") is PrototypeInteractable:
			return PackedStringArray(["Existing Maris counter missing"])
	for id: String in enabled:
		var entry: Dictionary = NpcRegistry.find(id)
		if scheduled or not placements.is_empty():
			if not placements.has(id): continue
			entry.location_id = location.location_id
			entry.foot = placements[id].foot
			entry.approach = entry.foot+placements[id].facing*1.1
			entry.facing = placements[id].facing
		elif entry.location_id != location.location_id: continue
		contact_records[id] = entry.duplicate(true)
		var target: PrototypeInteractable
		if id == "npc-03":
			target = location.get_node_or_null("MarisCounter") as PrototypeInteractable
			if target == null: return PackedStringArray(["Existing Maris counter missing"])
		else:
			target = PrototypeInteractable.new()
			target.name = entry.instance_id
			target.instance_id = entry.instance_id
			target.prompt = "Talk"
			target.position = entry.foot
			target.reach = entry.reach
			add_child(target)
			var body: CharacterBody3D = CharacterBody3D.new()
			body.name = "ContactBody"
			var shape: CollisionShape3D = CollisionShape3D.new()
			var capsule: CapsuleShape3D = CapsuleShape3D.new()
			capsule.radius = 0.4
			capsule.height = 1.6
			shape.shape = capsule
			shape.position.y = 0.8
			body.add_child(shape)
			target.add_child(body)
			var visual: Node3D = Node3D.new()
			visual.name = "VisualRoot"
			target.add_child(visual)
		target.npc_id = id
		if id == "npc-03" and scheduled: target.position = entry.foot
		targets[id] = target
		var body: CharacterBody3D = target.get_node("Body" if id == "npc-03" else "ContactBody")
		var mover: RoutineMovement = RoutineMovement.new()
		if not mover.configure(id,target,body,location,occupancy,.35 if id == "npc-03" else .4): return ["NPC movement binding rejected: "+id]
		movers[id] = mover
		if NpcRegistry.VISUAL_ASSETS.has(id):
			var presenter: NpcVisualPresenter = NpcVisualPresenter.new()
			presenter.name = "Presenter"
			target.get_node("VisualRoot").add_child(presenter)
			var errors: PackedStringArray = presenter.mount(load(NpcRegistry.VISUAL_ASSETS[id]) as PackedScene)
			if not errors.is_empty(): return errors
			presenter.face_direction(entry.approach-entry.foot)
			presenters[id] = presenter
			if id == "npc-03": target.get_node("VisualRoot/Maris").visible = false
			if id == "npc-01": target.prompt = "Talk to Mayor Vale"
			if id == "npc-02": target.prompt = "Talk to Archivist Vale"
			if id == "npc-04": target.prompt = "Talk to Harlan Reed"
			if id == "npc-06": target.prompt = "Talk to Tess Reed"
			if id == "npc-07": target.prompt = "Talk to Ivo Oran"
			if id == "npc-08": target.prompt = "Talk to Celia Oran"
			if id == "npc-14": target.prompt = "Talk to Della Pike"
	if is_inside_tree(): _pin_counter_furniture()
	return []

func materialize(location: PrototypeLocation, id: String, foot: Vector3, facing: Vector3) -> PackedStringArray:
	if targets.has(id): return ["NPC already materialized"]
	var errors: PackedStringArray = foot_errors(location,foot,[])
	if not occupancy.blocked(id,foot,foot,.4).is_empty(): errors.append("NPC arrival occupied")
	for claim: Dictionary in occupancy.snapshot().reservations.values():
		if Vector2(foot.x-claim.foot.x,foot.z-claim.foot.z).length() < .4+claim.radius+RoutineOccupancy.CLEARANCE: errors.append("NPC arrival reserved")
	var nearest: Vector3 = NavigationServer3D.map_get_closest_point(location.get_world_3d().navigation_map,foot)
	if nearest.distance_to(foot) > .3: errors.append("NPC arrival outside navigation")
	if not errors.is_empty(): return errors
	errors = build(location,[id],{id:{"foot":foot,"facing":facing}},true)
	if not errors.is_empty():
		dematerialize(id)
		return errors
	if not occupancy.reserve(id,foot,.4):
		dematerialize(id)
		return ["NPC arrival reservation refused"]
	return []

func dematerialize(id: String) -> void:
	if not targets.has(id): return
	if movers.has(id): movers[id].dispose(); movers.erase(id)
	presenters.erase(id); contact_records.erase(id)
	var target: PrototypeInteractable = targets[id]
	targets.erase(id)
	# Remove interaction and collision synchronously before another arrival query.
	if target.get_parent() != null: target.get_parent().remove_child(target)
	target.free()

func sync_visuals(holds: Dictionary, speaker: String, player_foot: Vector3, blockers: Array[CharacterBody3D] = []) -> void:
	_holds = holds.duplicate()
	for index: int in range(blockers.size()):
		occupancy.bind("party-%d" % index,blockers[index],.35)
	for id: String in presenters:
		var presenter: NpcVisualPresenter = presenters[id]
		for reason: String in holds:
			if holds[reason]: presenter.suspend(reason)
			else: presenter.resume(reason)
		presenter.set_locomotion(movers[id].achieved_speed)
		if speaker == id: presenter.face_direction(player_foot-targets[id].global_position)

func placement_errors(location: PrototypeLocation, excluded: Array[RID]) -> PackedStringArray:
	var errors: PackedStringArray = []
	var map: RID = location.get_world_3d().navigation_map
	for id: String in targets:
		var target: PrototypeInteractable = targets[id]
		var entry: Dictionary = contact_records[id]
		var own: Array[RID] = excluded.duplicate()
		if target.global_position != entry.foot: errors.append("NPC foot differs from approved map-qualified contact: " + id)
		var body: CharacterBody3D = target.get_node("Body" if id == "npc-03" else "ContactBody")
		own.append(body.get_rid())
		errors.append_array(foot_errors(location, target.global_position, own))
		if scheduled:
			if NavigationServer3D.map_get_closest_point(map,target.global_position).distance_to(target.global_position) > .3: errors.append("Scheduled NPC outside navigation: "+id)
			continue
		errors.append_array(foot_errors(location, entry.approach, excluded))
		var nearest: Vector3 = NavigationServer3D.map_get_closest_point(map, entry.approach)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, location.get_node("Spawns").get_child(0).global_position, entry.approach, true)
		if nearest.distance_to(entry.approach) > 0.3 or path.size() < 2 or path[-1].distance_to(entry.approach) > 0.3:
			errors.append("NPC approach unreachable: " + id)
		var hit: Dictionary = location.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(entry.approach+Vector3.UP*0.8,target.global_position+Vector3.UP*0.8,1,excluded))
		if not hit.is_empty() and not target.accepts_sight_hit(hit.collider): errors.append("NPC approach sight blocked: " + id)
	return errors

static func foot_errors(location: PrototypeLocation, foot: Vector3, excluded: Array[RID]) -> PackedStringArray:
	var errors: PackedStringArray = []
	if not foot.is_finite(): return PackedStringArray(["NPC foot must be finite"])
	var space: PhysicsDirectSpaceState3D = location.get_world_3d().direct_space_state
	for offset: Vector3 in [Vector3.ZERO,Vector3(0.4,0,0),Vector3(-0.4,0,0),Vector3(0,0,0.4),Vector3(0,0,-0.4),Vector3(0.28,0,0.28),Vector3(-0.28,0,0.28),Vector3(0.28,0,-0.28),Vector3(-0.28,0,-0.28)]:
		var point: Vector3 = foot+offset
		var hit: Dictionary = space.intersect_ray(PhysicsRayQueryParameters3D.create(point+Vector3.UP*0.3,point-Vector3.UP*0.3,1,excluded))
		if hit.is_empty() or hit.normal.y < 0.9 or absf(hit.position.y-foot.y) > 0.06:
			errors.append("Unsupported NPC/contact foot")
		elif not hit.collider.get_meta("candidate_walkable_floor",false) and not hit.collider.get_meta("aim_ground",false): errors.append("NPC/contact foot is not dry ground")
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform.origin = foot+Vector3.UP*0.82
	query.collision_mask = 1
	query.exclude = excluded
	if not space.intersect_shape(query).is_empty(): errors.append("NPC/contact capsule obstructed")
	return errors
