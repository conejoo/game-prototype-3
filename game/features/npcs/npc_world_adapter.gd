class_name NpcWorldAdapter
extends Node3D
## Scene-owned noncombatant wrappers. VisualRoot is replaced by character tasks.
var targets: Dictionary[String, PrototypeInteractable] = {}
var presenters: Dictionary[String, NpcVisualPresenter] = {}

func build(location: PrototypeLocation, enabled: PackedStringArray) -> PackedStringArray:
	if not targets.is_empty(): return PackedStringArray(["NPC contacts already built"])
	if location.location_id != NpcRegistry.LOCATION: return []
	var seen: PackedStringArray = []
	for id: String in enabled:
		if NpcRegistry.find(id).is_empty() or id in seen: return PackedStringArray(["Unknown or duplicate NPC contact"])
		if id == "npc-03" and not location.get_node_or_null("MarisCounter") is PrototypeInteractable:
			return PackedStringArray(["Existing Maris counter missing"])
		seen.append(id)
	for id: String in enabled:
		var entry: Dictionary = NpcRegistry.find(id)
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
			var body: StaticBody3D = StaticBody3D.new()
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
			(location as AlderwakeExterior).service_outlines.append(Rect2(entry.foot.x-0.4,entry.foot.z-0.4,0.8,0.8))
		target.npc_id = id
		targets[id] = target
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
	return []

func sync_visuals(holds: Dictionary, speaker: String, player_foot: Vector3) -> void:
	for id: String in presenters:
		var presenter: NpcVisualPresenter = presenters[id]
		for reason: String in holds:
			if holds[reason]: presenter.suspend(reason)
			else: presenter.resume(reason)
		# Fixed public contacts do not acquire routes or fabricated achieved motion.
		presenter.set_locomotion(0)
		if speaker == id: presenter.face_direction(player_foot-targets[id].global_position)

func placement_errors(location: PrototypeLocation, excluded: Array[RID]) -> PackedStringArray:
	var errors: PackedStringArray = []
	var map: RID = location.get_world_3d().navigation_map
	for id: String in targets:
		var target: PrototypeInteractable = targets[id]
		var entry: Dictionary = NpcRegistry.find(id)
		var own: Array[RID] = excluded.duplicate()
		if target.global_position != entry.foot: errors.append("NPC foot differs from approved fixed contact: " + id)
		var body: StaticBody3D = target.get_node("Body" if id == "npc-03" else "ContactBody")
		own.append(body.get_rid())
		errors.append_array(foot_errors(location, target.global_position, own))
		errors.append_array(foot_errors(location, entry.approach, excluded))
		var nearest: Vector3 = NavigationServer3D.map_get_closest_point(map, entry.approach)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(map, location.find_spawn("alderwake-start").global_position, entry.approach, true)
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
