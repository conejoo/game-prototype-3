extends SceneTree
## FS004 synthetic ray/camera/pose fixtures in current production geometry.

var failures: PackedStringArray = []
var assertions: int = 0
var game: Node3D
var room: AlderwakeTerrainPreview
var rod: RodActivationDefinition
var preview: FishingTargetPreview
var rows: Array[Dictionary] = []
const SITES: Array[Dictionary] = [
	{"id":"dock", "foot":Vector3(-7,0,18), "point":Vector3(-4.75,.015,20.25), "areas":["fishing-dock-shallows"]},
	{"id":"channel", "foot":Vector3(10,0,13), "point":Vector3(10.25,.015,17.25), "areas":["fishing-lake-channel"]},
	{"id":"west-overlap", "foot":Vector3(3,0,13), "point":Vector3(3.25,.015,22.25), "areas":["fishing-dock-shallows","fishing-sunken-reeds"]},
	{"id":"east-overlap", "foot":Vector3(6,0,13), "point":Vector3(6.25,.015,22.25), "areas":["fishing-lake-channel","fishing-sunken-reeds"]}]

func _initialize() -> void: _run.call_deferred()

func _startup() -> bool:
	root.size = Vector2i(960,640)
	game = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "production arrival")
	if not arrival[0]: return false
	room = game.world_host.current_location
	rod = game.catalog.get_item("item-fishing-rod").rod_activation
	preview = FishingTargetPreview.new()
	game.add_child(preview)
	game._set_paused(true)
	await physics_frame
	return true

func _run() -> void:
	if await _startup():
		var before: String = TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session))
		var topology: Array = [room.navigation_region.get_rid(), room.get_child_count(), room.water_blockers.water_cells.size(), room.water_blockers.blocked_cells.size(), room.elevation.cliffs.size()]
		await _rules()
		_check(before == TestRunSnapshot.exact_json(SaveCodec.snapshot(game.session)), "queries/presentation change no durable fact")
		_check(topology == [room.navigation_region.get_rid(), room.get_child_count(), room.water_blockers.water_cells.size(), room.water_blockers.blocked_cells.size(), room.elevation.cliffs.size()], "navigation/collision/semantic water untouched")
		_check(FileAccess.get_sha256(room.LAYOUT_PATH) == "7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be", "pinned layout exact")
		_check(TestRunEvidence.write_json("targeting-index.json", {"task":"FS004", "proof":"synthetic camera/rays/poses and solid fixtures; no gameplay casting", "assertions":assertions+1,"failures":failures,"samples":rows}), "evidence write")
	await _finish()

func _rules() -> void:
	for orthographic: bool in [true,false]:
		for zoom_value: float in [.8,1.0,1.15]:
			game.camera_rig.zoom_factor = zoom_value
			game.camera_rig.set_orthographic(orthographic)
			for site: Dictionary in SITES:
				_pose(site.foot)
				var pointer: Vector2 = game.camera_rig.camera.unproject_position(site.point)
				var result: FishingWaterTargetResolver.Result = preview.refresh(room,game.catalog,game.camera_rig.camera,pointer,site.foot,true,rod)
				_check(result.status == "eligible", "projection/zoom eligible " + site.id + " " + str([orthographic,zoom_value,result.reason,pointer]))
				_check(result.point.distance_to(site.point) < .00001 and result.area_ids == PackedStringArray(site.areas), "water height/cell/overlap " + site.id)
				_check(preview.visible and preview.global_position.distance_to(result.point) < .00001 and preview.caption.text.begins_with("Cast here"), "eligible world preview " + site.id)
				rows.append({"site":site.id, "orthographic":orthographic, "zoom":zoom_value,"pointer":pointer,"ui_allowed":game.ui.accepts_world_pointer(pointer),"target":result.snapshot()})
	var foot: Vector3 = SITES[0].foot
	var target: Vector3 = SITES[0].point
	_pose(foot)
	# Quantization is floor relative to (-22,-18), independent of hero elevation.
	for jitter: Vector3 in [Vector3(-.249,0,-.249),Vector3(.249,0,.249),Vector3.ZERO]:
		var result: FishingWaterTargetResolver.Result = _vertical(target+jitter,foot)
		_check(result.status == "eligible" and result.point.distance_to(target) < .00001, "cell interior snaps to center")
	_check(_vertical(Vector3(-5,.015,20),foot).cell == Vector2i(34,76), "exact cell left/top belongs next half-open cell")
	_check(_vertical(Vector3(-5.0001,.015,19.9999),foot).cell == Vector2i(33,75), "cell epsilon before boundary stays previous cell")
	var boundary_foot: Vector3 = target - Vector3(12, .015, 0)
	_check(_vertical(target,boundary_foot).status == "eligible", "exact 12m inclusive horizontal range")
	_check(_vertical(target,boundary_foot-Vector3(.001,0,0)).reason == "out_of_range", "range just beyond 12m rejects")
	_check(_vertical(target,foot+Vector3.UP*2).status == "eligible", "player elevation never substitutes for water height")
	for xz: Vector2 in [Vector2(125,20),Vector2(-22.001,20),Vector2(10,62),Vector2(10,-18.001)]:
		_check(_vertical(Vector3(xz.x,.015,xz.y),foot).reason == "out_of_bounds", "half-open map negative " + str(xz))
	var edge: FishingWaterTargetResolver.Result = _vertical(Vector3(-22,.015,20),Vector3(-22,0,19))
	_check(edge.reason != "out_of_bounds" and edge.cell.x == 0, "map lower edge included")
	for negative: Dictionary in [
		{"point":Vector3(-7,.015,18),"foot":foot,"reason":"dry_structure"},
		{"point":Vector3(98,.015,-.5),"foot":Vector3(94,0,-.5),"reason":"dry_structure"},
		{"point":Vector3(10,.015,13),"foot":Vector3(10,0,13),"reason":"dry_land"},
		{"point":Vector3(31.5,.015,5.5),"foot":Vector3(31.5,.5,5.5),"reason":"dry_land"}]:
		var result: FishingWaterTargetResolver.Result = _vertical(negative.point,negative.foot)
		_check(result.reason == negative.reason and not result.surface_valid, "dry deck/bridge/bank/elevation " + str(negative.point))
	var no_area: FishingWaterTargetResolver.Result = _vertical(Vector3(-12.75,.015,20.25),foot)
	_check(no_area.status == "no_area" and no_area.surface_valid and no_area.area_ids.is_empty(), "open water without area distinct from invalid/miss")
	preview.present(no_area)
	_check(preview.visible and preview.caption.text == "No fishing area", "no-area text distinct")
	var unsafe: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(target+Vector3.UP*4,target,1))
	_check(not unsafe.is_empty() and unsafe.position.y > 2.99, "real water safety top masks raw ray")
	_check(_vertical(target,foot).status == "eligible", "safety volume does not block cast")
	var underfloor: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(target+Vector3.UP*.1,target-Vector3.UP*.1,1,_water_rids()))
	_check(not underfloor.is_empty() and underfloor.position.y < .015, "underlying solid floor differs from water")
	await _occlusion(foot,target)
	for ray: Dictionary in [
		{"o":Vector3(NAN,1,1),"d":Vector3.DOWN,"length":10.0},
		{"o":target+Vector3.UP*4,"d":Vector3(INF,0,0),"length":10.0},
		{"o":target+Vector3.UP*4,"d":Vector3.ZERO,"length":10.0},
		{"o":target+Vector3.UP*4,"d":Vector3.RIGHT,"length":10.0},
		{"o":target+Vector3.UP*4,"d":Vector3.UP,"length":10.0},
		{"o":target-Vector3.UP,"d":Vector3.DOWN,"length":10.0},
		{"o":target+Vector3.UP*4,"d":Vector3.DOWN,"length":3.0},
		{"o":target+Vector3.UP*4,"d":Vector3.DOWN,"length":INF},
		{"o":target+Vector3.UP*4,"d":Vector3.DOWN,"length":0.0}]:
		_check(FishingWaterTargetResolver.from_ray(room,game.catalog,ray.o,ray.d,ray.length,foot,rod).reason == "invalid_ray", "invalid ray rejected")
	_check(_vertical(target,Vector3(NAN,0,0)).reason == "invalid_ray", "nonfinite player rejected")
	var invalid_rod: RodActivationDefinition = rod.duplicate(true)
	invalid_rod.maximum_range_m = 50
	_check(FishingWaterTargetResolver.from_ray(room,game.catalog,target+Vector3.UP*4,Vector3.DOWN,10,foot,invalid_rod).reason == "invalid_context", "invalid rod cannot enlarge range")
	_check(FishingWaterTargetResolver.from_ray(room,null,target+Vector3.UP*4,Vector3.DOWN,10,foot,rod).reason == "invalid_context", "missing catalog rejects")
	var indoor: Node3D = load("res://world/test_room.tscn").instantiate()
	root.add_child(indoor)
	_check(FishingWaterTargetResolver.from_ray(indoor,game.catalog,target+Vector3.UP*4,Vector3.DOWN,10,foot,rod).reason == "unsupported_location", "indoor room rejected")
	indoor.queue_free()
	var old_id: String = room.location_id
	room.location_id = "candidate-alderwake"
	_check(_vertical(target,foot).reason == "unsupported_location", "uncommitted preview map rejected")
	room.location_id = old_id
	await _ui_revalidation(foot,target)
	preview.clear()
	_check(not preview.visible and preview.snapshot().is_empty() and preview.caption.text.is_empty(), "teardown clears every transient visual/snapshot")

func _ui_revalidation(foot: Vector3, target: Vector3) -> void:
	game.camera_rig.zoom_factor = 1
	game.camera_rig.set_orthographic(true)
	_pose(foot)
	var camera: Camera3D = game.camera_rig.camera
	var pointer: Vector2 = camera.unproject_position(target)
	_check(FishingWaterTargetResolver.from_pointer(room,game.catalog,camera,Vector2(-1,-1),foot,true,rod).reason == "ui_pointer", "outside viewport rejected")
	_check(FishingWaterTargetResolver.from_pointer(room,game.catalog,camera,Vector2(NAN,0),foot,true,rod).reason == "invalid_ray", "invalid pointer rejected")
	_check(FishingWaterTargetResolver.from_pointer(room,game.catalog,null,pointer,foot,true,rod).reason == "invalid_ray", "missing camera rejected")
	for covered: Vector2 in [Vector2(10,10), Vector2(10,630)]:
		_check(not game.ui.accepts_world_pointer(covered), "actual header/footer owns pointer")
		_check(preview.refresh(room,game.catalog,camera,covered,foot,game.ui.accepts_world_pointer(covered),rod).reason == "ui_pointer" and not preview.visible, "UI covered preview rejects/hides")
	_check(not game.ui.accepts_world_pointer(pointer), "actual pause owns even world pointer")
	_check(preview.revalidate(room,game.catalog,camera,pointer,foot,game.ui.accepts_world_pointer(pointer),rod).reason == "ui_pointer", "cast rechecks pause UI")
	# Explicit false is authoritative for every other modal/focus owner as well.
	_check(preview.refresh(room,game.catalog,camera,pointer,foot,false,rod).reason == "ui_pointer", "caller pointer gate enforced")
	var result: FishingWaterTargetResolver.Result = preview.refresh(room,game.catalog,camera,pointer,foot,true,rod)
	_check(result.status == "eligible", "refresh before moved player")
	var detached: Dictionary = preview.snapshot()
	detached.area_ids.clear()
	detached.status = "tampered"
	result.area_ids.clear()
	_check(preview.snapshot().status == "eligible" and preview.snapshot().area_ids.size() == 1, "presentation snapshots detach caller/result arrays")
	var moved: Vector3 = foot-Vector3(20,0,0)
	_check(preview.refresh(room,game.catalog,camera,pointer,moved,true,rod).reason == "out_of_range" and preview.caption.text == "Beyond 12m", "refresh follows current player")
	preview.refresh(room,game.catalog,camera,pointer,foot,true,rod)
	_check(preview.revalidate(room,game.catalog,camera,pointer,moved,true,rod).reason == "out_of_range", "cast cannot reuse stale eligibility")
	_check(preview.revalidate(room,game.catalog,camera,camera.unproject_position(foot),foot,true,rod).reason == "dry_structure", "cast rechecks changed pointer")
	var obstacle: StaticBody3D = _box(target-camera.project_ray_normal(pointer)*.8,Vector3(.3,.3,.3))
	await physics_frame
	var fixture_hit: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.project_ray_origin(pointer),target,1,_water_rids()))
	_check(not fixture_hit.is_empty() and fixture_hit.collider == obstacle, "changed-solid fixture actually intersects oblique camera ray")
	_check(preview.revalidate(room,game.catalog,camera,pointer,foot,true,rod).reason == "solid_occlusion", "cast rechecks changed live solids")
	obstacle.queue_free()
	await physics_frame

func _occlusion(foot: Vector3, target: Vector3) -> void:
	# Camera-side occluder, then rod-side occluder, then inside-solid origin.
	for position: Vector3 in [target+Vector3.UP*2, (foot+Vector3.UP+target)/2]:
		var obstacle: StaticBody3D = _box(position,Vector3(.5,.5,.5))
		await physics_frame
		_check(_vertical(target,foot).reason == "solid_occlusion", "unmarked solid stays occluder " + str(position))
		obstacle.queue_free()
		await physics_frame
	var gate: StaticBody3D = room.water_blockers.get_node("future-exit-gate")
	var gate_origin: Vector3 = gate.global_position
	_check(FishingWaterTargetResolver.from_ray(room,game.catalog,gate_origin,target-gate_origin,200,foot,rod).reason == "solid_occlusion", "future gate never excluded even when ray starts inside")
	var cliff: StaticBody3D = room.elevation.cliffs[0].body
	var cliff_origin: Vector3 = cliff.global_position
	_check(FishingWaterTargetResolver.from_ray(room,game.catalog,cliff_origin,target-cliff_origin,200,foot,rod).reason == "solid_occlusion", "actual elevated cliff remains solid")

func _box(position: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	room.add_child(body)
	body.global_position = position
	return body

func _water_rids() -> Array[RID]:
	var result: Array[RID] = []
	for record: Dictionary in room.water_blockers.records:
		result.append((room.water_blockers.get_node(NodePath(record.id)) as StaticBody3D).get_rid())
	return result

func _vertical(point: Vector3, foot: Vector3) -> FishingWaterTargetResolver.Result:
	return FishingWaterTargetResolver.from_ray(room,game.catalog,point+Vector3.UP*4,Vector3.DOWN,10,foot,rod)

func _pose(foot: Vector3) -> void:
	# Synthetic fixture only; production has no teleport command.
	game.player_placeholder.global_position = foot
	game.camera_rig._process(0)

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _finish() -> void:
	paused = false
	if is_instance_valid(game): game.queue_free()
	await process_frame
	for failure: String in failures: push_error(failure)
	print("FS004 fishing_targeting_checks ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
