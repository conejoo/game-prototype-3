extends SceneTree
## FS001 synthetic rule/geometry audit. Ordinary movement lives in the render check.
var failures: PackedStringArray = []
var assertions: int = 0
var rows: Array[Dictionary] = []
var rules: Dictionary
var vectors: Dictionary
var room: AlderwakeTerrainPreview

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	_read_reference()
	var game: Node3D = load("res://app/game_root.tscn").instantiate()
	root.add_child(game)
	var arrival: Array = await game.world_host.transition_finished
	_check(arrival[0], "production arrival")
	if arrival[0]:
		room = game.world_host.current_location
		game._set_paused(true)
		await physics_frame
		await _geometry(game)
	_check(TestRunEvidence.write_json("fishing-reference.json", {"task":"FS001", "proof":"synthetic geometry and frozen behavior vectors; no ordinary walking claim", "assertions":assertions+1,"failures":failures,"sites":rows}), "evidence write")
	paused = false
	game.queue_free()
	await process_frame
	_finish()

func _read_reference() -> void:
	rules = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/rules.json"))
	vectors = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/behavior_vectors.json"))
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/fishing/reference/manifest.json"))
	for record: Dictionary in manifest.local_artifacts:
		_check(FileAccess.get_sha256("res://../" + record.path) == record.sha256, "frozen bytes " + record.path)
	for row: Dictionary in vectors.membership:
		var area: Dictionary = _area(row.area)
		_check(_contains(area.shape, Vector2(row.point[0],row.point[1])) == row.inside, "closed membership " + row.label)
	for row: Dictionary in vectors.rolls:
		_check(_resolve(Vector2(row.point[0],row.point[1]),row.roll) == row.expected, "weighted interval " + row.label)
	for row: Dictionary in vectors.waits:
		_check(is_equal_approx(1.5 + 1.5 * row.roll,row.seconds), "independent wait mapping")

func _area(id: String) -> Dictionary:
	for a: Dictionary in rules.areas:
		if a.id == id: return a
	return {}

func _contains(shape: Dictionary, point: Vector2) -> bool:
	if shape.kind == "rectangle":
		var r: Array = shape.rect_xz_m
		return point.x >= r[0] and point.x <= r[0]+r[2] and point.y >= r[1] and point.y <= r[1]+r[3]
	# Source-unit edge predicate preserves source epsilon rather than using
	# Geometry2D's unspecified boundary tolerance or Rect2's half-open end.
	point = point * 32 + Vector2(704,576)
	var vertices: Array = shape.vertices_xz_m
	var inside: bool = false
	for i: int in range(vertices.size()):
		var raw_a: Array = vertices[i]
		var raw_b: Array = vertices[(i+1)%vertices.size()]
		var a: Vector2 = Vector2(raw_a[0],raw_a[1])*32+Vector2(704,576)
		var b: Vector2 = Vector2(raw_b[0],raw_b[1])*32+Vector2(704,576)
		var cross: float = (point.x-a.x)*(b.y-a.y)-(point.y-a.y)*(b.x-a.x)
		if absf(cross) <= 0.000001 and point.x >= minf(a.x,b.x)-0.000001 and point.x <= maxf(a.x,b.x)+0.000001 and point.y >= minf(a.y,b.y)-0.000001 and point.y <= maxf(a.y,b.y)+0.000001: return true
		if (b.y > point.y) != (a.y > point.y) and point.x < (a.x-b.x)*(point.y-b.y)/(a.y-b.y)+b.x: inside = not inside
	return inside

func _probabilities(point: Vector2) -> Dictionary:
	var probabilities: Dictionary = {}
	var weight: float = 0
	for a: Dictionary in rules.areas:
		if not _contains(a.shape,point): continue
		for profile: Dictionary in a.source_profiles:
			if profile.activityId != "fishing": continue
			weight += profile.blendWeight
			for outcome: Dictionary in profile.outcomes:
				probabilities[outcome.itemId] = probabilities.get(outcome.itemId,0.0)+outcome.probability*profile.blendWeight
	for id: String in probabilities: probabilities[id] /= weight
	return probabilities

func _resolve(point: Vector2, roll: float) -> String:
	if not is_finite(roll) or roll < 0 or roll >= 1: return "invalid_roll"
	var probabilities: Dictionary = _probabilities(point)
	if probabilities.is_empty(): return "no_area"
	var ids: Array = probabilities.keys()
	ids.sort()
	var threshold: float = 0
	for id: String in ids:
		threshold += probabilities[id]
		if roll < threshold: return id
	return "miss"

func _geometry(game: Node3D) -> void:
	_check(room.location_id == "prototype-alderwake" and room.layout.activity_areas == rules.areas, "pinned production area records")
	_check(SaveCodec.SCHEMA_VERSION == 8 and SaveCodec.CONTENT_VERSION == 1, "current save policy")
	_check(game.catalog.get_item("item-fishing-rod").stack_limit == 1 and InventoryState.MAX_TYPES == 20, "F010 rod/capacity capability")
	# FS002 already delivered these species; retain identity/conservation coverage
	# against current content rather than the obsolete FS001 reserved-ID absence.
	for source: Dictionary in rules.items:
		if source.id == "fishing_rod": continue
		var item: ItemDefinition = game.catalog.get_item_by_source(source.id)
		_check(item != null and item.stable_id == "item-" + source.id.replace("_", "-") and item.stack_limit == source.stackLimit and item.category == source.category and item.fishing_challenge != null and not item.movable_pickup, "existing fish identity/capability " + source.id)
	_check(room.water_blockers.records.size() == 90 and room.water_blockers.water_cells.size() == 8598, "preserved effective water/blockers")
	var mesh: Mesh = room.water_blockers.get_node("WaterVisuals/AuthoredWaterPreview").mesh
	var vertices: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var low: float = INF
	var high: float = -INF
	for vertex: Vector3 in vertices:
		low = minf(low,vertex.y); high = maxf(high,vertex.y)
	_check(absf(low-.015) < .000001 and absf(high-.015) < .000001, "actual water plane Y=.015, shader undisplaced")
	var readiness: Dictionary = await TestRunJourney.wait_navigation(room,Vector3.ZERO)
	_check(readiness.ok,readiness.error)
	if not readiness.ok: return
	var nav: RID = room.get_world_3d().navigation_map
	var golden_sites: int = 0
	for site: Dictionary in vectors.sites:
		var foot: Vector3 = _v3(site.foot)
		var target: Vector3 = _v3(site.target)
		var point: Vector2 = Vector2(target.x,target.z)
		var cell: Vector2i = Vector2i((point-room.bounds.position)/.5)
		var center: Vector2 = room.bounds.position+Vector2(cell)*.5+Vector2(.25,.25)
		_check(center.distance_to(point) < .000001 and room.water_blockers.water_cells.has(cell) and not room.water_blockers.on_dock(point), "cell-centered open water " + site.id)
		var range_m: float = Vector2(foot.x,foot.z).distance_to(point)
		_check(range_m <= 12, "in range " + site.id)
		var matches: Array[String] = []
		for a: Dictionary in rules.areas:
			if _contains(a.shape,point): matches.append(a.id)
		_check(matches == Array(site.areas,TYPE_STRING,"",null), "expected area overlap " + site.id)
		var floor_hit: Dictionary = _solid_ray(game,foot+Vector3.UP*.15,foot-Vector3.UP*.15)
		_check(not floor_hit.is_empty() and absf(floor_hit.position.y-foot.y) < .01 and floor_hit.normal.y > .99, "dry foot support " + site.id)
		var shape: CapsuleShape3D = CapsuleShape3D.new()
		shape.radius = .4; shape.height = 1.6
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = shape; query.collision_mask = 1
		query.transform.origin = foot+Vector3.UP*.82
		query.exclude = [game.player_placeholder.get_rid(),game.companion.get_rid()]
		_check(room.get_world_3d().direct_space_state.intersect_shape(query).is_empty(), "dry capsule clearance " + site.id)
		var path: PackedVector3Array = NavigationServer3D.map_get_path(nav,Vector3.ZERO,foot,true)
		_check(not path.is_empty() and path[-1].distance_to(foot) < .2, "synthetic navigation approach " + site.id)
		var occlusion: Dictionary = _solid_ray(game,foot+Vector3.UP,target)
		_check(occlusion.is_empty(), "solid occlusion from rod to water " + site.id + ": " + str(occlusion.get("collider","none")))
		var raw_hit: Dictionary = room.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(target+Vector3.UP*4,target,1))
		_check(not raw_hit.is_empty() and raw_hit.collider.get_parent() == room.water_blockers and absf(raw_hit.position.y-3) < .001, "safety volume differs from water plane " + site.id)
		var underlying: Dictionary = _solid_ray(game,target+Vector3.UP*.2,target-Vector3.UP*.1)
		_check(not underlying.is_empty() and underlying.position.y < .015, "underwater base floor is not water query " + site.id)
		var probabilities: Dictionary = _probabilities(point)
		if probabilities.get("golden_carp",0) > 0: golden_sites += 1
		rows.append({"id":site.id,"foot":site.foot,"target":site.target,"range_m":range_m,"areas":matches,"probabilities":probabilities,"navigation_points":path.size(),"water_y":low,"safety_top_y":raw_hit.get("position",Vector3.ZERO).y})
	_check(golden_sites == 3, "golden-carp channel and both reeds overlaps")
	for negative: Dictionary in vectors.negative_points:
		var p: Vector2 = Vector2(negative.point[0],negative.point[1])
		var water: bool = room.water_blockers.water_cells.has(Vector2i((p-room.bounds.position)/.5))
		if negative.kind == "no_area": _check(water and _resolve(p,0) == "no_area", "open water no-area distinct from miss")
		elif negative.kind == "out_of_map": _check(not room.bounds.has_point(p), "half-open map boundary")
		else: _check(not water, "dry negative " + negative.label)
		if negative.kind == "deck": _check(room.water_blockers.on_dock(p), "deck beats authored underlying water")
		if negative.kind == "bridge": _check(room.crossings.bridge_rect.has_point(p), "bridge beats painted water")
	_check(not room.elevation.cliffs.is_empty(), "existing cliff blockers retained")
	var cliff: Dictionary = room.elevation.cliffs[0]
	var body: StaticBody3D = cliff.body
	var normal: Vector3 = Vector3.RIGHT if cliff.id.ends_with("east") else Vector3.BACK
	var hit: Dictionary = _solid_ray(game,body.global_position-normal*.2,body.global_position+normal*.2)
	_check(not hit.is_empty() and hit.collider == body, "solid cliff negative occlusion")
	_check(_resolve(Vector2(10.25,17.25),1) == "invalid_roll" and _resolve(Vector2(10.25,17.25),NAN) == "invalid_roll", "strict RNG domain")
	print("FS001 sites ", JSON.stringify(rows), " cliff=",cliff.id)

func _solid_ray(game: Node3D, from: Vector3, to: Vector3) -> Dictionary:
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from,to,1)
	# Physics query's exclude getter returns a copy. Build locally then assign;
	# mutating query.exclude directly leaves safety volumes in the ray query.
	var excluded: Array[RID] = [game.player_placeholder.get_rid(),game.companion.get_rid()]
	for body: Node in room.water_blockers.get_children():
		if body is StaticBody3D and body.name != "future-exit-gate": excluded.append(body.get_rid())
	query.exclude = excluded
	return room.get_world_3d().direct_space_state.intersect_ray(query)

func _v3(raw: Array) -> Vector3: return Vector3(raw[0],raw[1],raw[2])

func _check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures.append(message)

func _finish() -> void:
	for failure: String in failures: push_error(failure)
	print("FS001 fishing_reference_checks ","PASS" if failures.is_empty() else "FAIL"," assertions=",assertions)
	quit(0 if failures.is_empty() else 1)
