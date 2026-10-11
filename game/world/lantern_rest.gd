class_name LanternRest
extends PrototypeLocation
## R008 bounded public inn. No room entitlement, sleep or routine activation.
const DATA_PATH: String = "res://content/maps/lantern_rest.json"
var layout: Dictionary
var station_records: Array[Dictionary] = []

func _init() -> void:
	layout = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	location_id = "prototype-lantern-rest"
	var floor_body: StaticBody3D = StaticBody3D.new()
	floor_body.name = "Floor"
	floor_body.set_meta("aim_ground", true)
	add_child(floor_body)
	for rect: Array in layout.floor_rects_xz_m:
		_box(floor_body, Vector3(rect[0]+rect[2]/2.0,-0.15,rect[1]+rect[3]/2.0), Vector3(rect[2],.3,rect[3]),Color(.40,.25,.13),true)
	# Oak plank seams are art only, laid over the exact supported footprint.
	for row: int in range(46):
		_box(self,Vector3(0,.006,-20.75+row*.5),Vector3(27,.012,.018),Color(.24,.15,.08))
	for collider: Dictionary in layout.colliders:
		_build_furniture(collider)
	var stations: Node3D = Node3D.new()
	stations.name = "RoutineAnchors"
	add_child(stations)
	var facing: Dictionary = {"north":Vector3.FORWARD,"south":Vector3.BACK,"east":Vector3.RIGHT,"west":Vector3.LEFT}
	for row: Dictionary in layout.anchors:
		var marker: Marker3D = Marker3D.new()
		marker.name = row.anchor_id
		marker.position = _v(row.foot)
		marker.set_meta("anchor_id",row.anchor_id)
		marker.set_meta("facing",facing[row.facing])
		stations.add_child(marker)
		station_records.append({"location_id":location_id,"anchor_id":row.anchor_id,"foot":marker.position,"facing":facing[row.facing]})
	var spawns: Node3D = Node3D.new()
	spawns.name = "Spawns"
	add_child(spawns)
	var arrival: SpawnAnchor = SpawnAnchor.new()
	arrival.name = "TownArrival"
	arrival.stable_id = layout.arrival.id
	arrival.position = _v(layout.arrival.foot)
	spawns.add_child(arrival)
	var gate: PrototypeInteractable = PrototypeInteractable.new()
	gate.name = "TravelGate"
	gate.instance_id = "lantern-rest-exit-01"
	gate.kind = "travel"
	gate.portal = preload("res://content/portals/inn_alderwake.tres")
	gate.prompt = "Return to Alderwake"
	gate.position = _v(layout.exit.foot)
	gate.reach = 1.6
	add_child(gate)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(.72,.53,.25)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = .65
	torus.outer_radius = .72
	torus.material = mat
	ring.mesh = torus
	ring.position.y = .03
	gate.add_child(ring)
	_label(self,"Lantern Rest",Vector3(0,.06,-3),26)
	# Interior lights do not sample global outdoor forecast/shadows.
	for foot: Vector3 in [Vector3(-7,2,-15),Vector3(7,2,-15),Vector3(-7,2,-6),Vector3(7,2,-6)]:
		var lamp: OmniLight3D = OmniLight3D.new()
		lamp.position = foot
		lamp.light_color = Color(1,.75,.40)
		lamp.light_energy = .65
		lamp.omni_range = 10
		lamp.shadow_enabled = false
		add_child(lamp)
	_rug(Vector3(6.5,.02,-4.5),Vector3(5,.025,4),Color(.25,.32,.42))
	_rug(Vector3(-7,.02,-5),Vector3(5,.025,3),Color(.43,.27,.19))
	_label(self,"Host / meals",Vector3(-6,.06,-10.5),28)
	_label(self,"Quiet lounge",Vector3(-7,.06,-3.5),24)
	_label(self,"Breakfast",Vector3(6.5,.06,-2.7),24)
	for x: float in [-8,0,8]:
		_box(self,Vector3(x,.95,-19.95),Vector3(2,1,.08),Color(.53,.70,.76))
		_box(self,Vector3(x,.95,-19.88),Vector3(.08,1,.1),Color(.24,.14,.07))
		_box(self,Vector3(x,.95,-19.88),Vector3(2,.08,.1),Color(.24,.14,.07))
	for collider: Dictionary in layout.colliders:
		if "table" in collider.id:
			var r: Array = collider.rect_xz_m
			_box(self,Vector3(r[0]+r[2]/2,.96,r[1]+r[3]/2),Vector3(.35,.04,.3),Color(.86,.80,.63))
			_box(self,Vector3(r[0]+r[2]/2+.22,1.02,r[1]+r[3]/2),Vector3(.1,.14,.1),Color(.66,.71,.60))

func anchors(qualified_map: String = "prototype-lantern-rest") -> Array[Dictionary]:
	if qualified_map != location_id: return []
	return station_records.duplicate(true)

func find_anchor(qualified_map: String, id: String) -> Dictionary:
	for record: Dictionary in anchors(qualified_map):
		if record.anchor_id == id: return record
	return {}

func prepare_navigation() -> PackedStringArray:
	if navigation_region != null: return []
	var mesh: NavigationMesh = NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_collision_mask = 1
	mesh.cell_size = .05
	mesh.cell_height = .05
	mesh.agent_radius = .4
	mesh.agent_height = 1.6
	mesh.agent_max_climb = .1
	mesh.agent_max_slope = 20
	mesh.edge_max_error = .1
	var geometry: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh,geometry,self)
	# Cutaway walls and low furniture remain full-body navigation obstacles;
	# their visible tops are not alternate floors. Include 10cm physics margin
	# to absorb bake simplification and the kinematic safe margin at corners.
	for record: Dictionary in layout.colliders:
		var r: Array = record.rect_xz_m
		var rect: Rect2 = Rect2(r[0],r[1],r[2],r[3]).grow(.1)
		var points: PackedVector3Array = [Vector3(rect.position.x,0,rect.position.y),Vector3(rect.end.x,0,rect.position.y),Vector3(rect.end.x,0,rect.end.y),Vector3(rect.position.x,0,rect.end.y)]
		geometry.add_projected_obstruction(points,-.1,2,false)
	NavigationServer3D.bake_from_source_geometry_data(mesh,geometry)
	if mesh.get_polygon_count() == 0: return ["Lantern Rest has no walkable navigation"]
	navigation_region = NavigationRegion3D.new()
	navigation_region.navigation_mesh = mesh
	add_child(navigation_region)
	return []

func _build_furniture(record: Dictionary) -> void:
	var r: Array = record.rect_xz_m
	var id: String = record.id
	var wall: bool = "wall-" in id
	var height: float = .65 if wall else .85
	var color: Color = Color(.64,.58,.46) if wall else Color(.29,.17,.09)
	if "bookcase" in id or "wardrobe" in id: height = 1.55
	if "bed-" in id: height = .48
	if "armchair" in id or "sofa" in id: height = .55; color = Color(.24,.40,.40)
	if "fireplace" in id: height = 1.15; color = Color(.36,.32,.28)
	var body: StaticBody3D = StaticBody3D.new()
	body.name = id
	body.position = Vector3(r[0]+r[2]/2.0,0,r[1]+r[3]/2.0)
	body.set_meta("source_collider_id",id)
	body.set_meta("runtime_rect_xz_m",r.duplicate())
	var source_rect: Array = r.duplicate()
	for adaptation: Dictionary in layout.adaptations:
		if adaptation.id == id: source_rect = adaptation.before_rect_xz_m.duplicate()
	body.set_meta("source_rect_xz_m",source_rect)
	add_child(body)
	_box(body,Vector3(0,height/2,0),Vector3(r[2],height,r[3]),color,true)
	if wall:
		_box(body,Vector3(0,height+.035,0),Vector3(r[2]+.025,.07,r[3]+.025),Color(.30,.21,.13))
	elif "bookcase" in id:
		for shelf: int in range(3):
			_box(body,Vector3(0,.32+shelf*.43,r[3]/2+.015),Vector3(r[2],.055,.045),Color(.58,.36,.16))
			for book: int in range(7):
				_box(body,Vector3(-r[2]/2+.14+book*(r[2]-.28)/7,.49+shelf*.43,r[3]/2+.025),Vector3(.1,.27,.045),Color(.30+.08*(book%3),.22+.07*(book%4),.19+.10*(book%2)))
	elif "bed-" in id:
		_box(body,Vector3(0,.51,0),Vector3(r[2]-.12,.1,r[3]-.1),Color(.66,.71,.71))
		_box(body,Vector3(0,.59,-r[3]/2+.3),Vector3(r[2]-.2,.15,.4),Color(.88,.85,.72))
		_box(body,Vector3(0,.58,.2),Vector3(r[2]-.1,.04,r[3]*.55),Color(.28,.40,.44))
	elif "worktop" in id or "stove" in id or "table" in id:
		_box(body,Vector3(0,.88,0),Vector3(r[2]+.025,.08,r[3]+.025),Color(.65,.61,.47))
		for panel: int in range(maxi(1,int(r[2]/.7))):
			_box(body,Vector3(-r[2]/2+.3+panel*.7,.42,r[3]/2+.015),Vector3(.5,.62,.02),Color(.42,.29,.16))
	elif "armchair" in id or "sofa" in id:
		_box(body,Vector3(0,.72,-r[3]/2+.08),Vector3(r[2],.35,.16),color.lightened(.1))
		_box(body,Vector3(0,.59,0),Vector3(r[2]-.1,.08,r[3]-.1),color.lightened(.15))
	elif "fireplace" in id:
		_box(body,Vector3(0,.35,r[3]/2+.012),Vector3(r[2]*.6,.55,.025),Color(.09,.065,.04))
		_box(body,Vector3(0,.16,r[3]/2+.035),Vector3(.7,.15,.03),Color(.85,.34,.07))

func _rug(center: Vector3, size: Vector3, color: Color) -> void:
	_box(self,center,size,color)
	_box(self,center+Vector3.UP*.015,Vector3(size.x-.18,.014,size.z-.18),color.lightened(.12))

func _box(parent: Node3D, center: Vector3, size: Vector3, color: Color, collision: bool = false) -> void:
	var visual: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = .9
	mesh.material = material
	visual.mesh = mesh
	visual.material_override = preload("res://world/storybook_inn_material.gd").painted(color,"LanternRest" if parent == self else str(parent.name),center)
	visual.position = center
	parent.add_child(visual)
	if collision:
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = size
		shape.shape = box
		shape.position = center
		parent.add_child(shape)

func _label(parent: Node3D, text: String, foot: Vector3, size: int) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.position = foot
	label.rotation_degrees.x = -90
	label.font_size = size
	label.pixel_size = .008
	parent.add_child(label)

func _v(a: Array) -> Vector3: return Vector3(a[0],a[1],a[2])
