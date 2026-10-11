class_name MayorValeHome
extends PrototypeLocation
## Bounded source-informed cutaway. Collision is separate from decorative art.
const DATA_PATH: String = "res://content/maps/mayor_vale_home.json"
var layout: Dictionary
var build_errors: PackedStringArray = []
var station_records: Array[Dictionary] = []

func _init() -> void:
	layout = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	location_id = "prototype-mayor-vale-home"
	var floor_body: StaticBody3D = StaticBody3D.new()
	floor_body.name = "Floor"
	floor_body.set_meta("aim_ground", true)
	add_child(floor_body)
	for rect: Array in layout.floor_rects_xz_m:
		_box(floor_body, Vector3(rect[0]+rect[2]/2.0,-0.15,rect[1]+rect[3]/2.0), Vector3(rect[2],.3,rect[3]),Color(.40,.25,.13),true)
	# Oak plank seams are art only, laid over the exact supported footprint.
	for row: int in range(26):
		_box(self,Vector3(0,.006,-11.75+row*.5),Vector3(15,.012,.018),Color(.24,.15,.08))
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
	gate.instance_id = "mayor-vale-home-exit"
	gate.kind = "travel"
	gate.portal = preload("res://content/portals/home_alderwake.tres")
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
	_label(self,"Mayor Vale home",Vector3(0,.06,-4),26)
	# Fixed warm room lights never sample exterior weather or cast exterior shadows.
	for foot: Vector3 in [Vector3(-4.5,2,-8),Vector3(4,2,-8),Vector3(-4.5,2,-1.5),Vector3(4,2,-1.5)]:
		var lamp: OmniLight3D = OmniLight3D.new()
		lamp.position = foot
		lamp.light_color = Color(1,.76,.44)
		lamp.light_energy = .55
		lamp.omni_range = 6
		lamp.shadow_enabled = false
		add_child(lamp)
	_rug(Vector3(-4.5,.02,-7),Vector3(4,.025,3),Color(.24,.35,.33))
	_rug(Vector3(4,.02,-1.5),Vector3(3,.025,3),Color(.30,.31,.40))
	# Windows, books, bed linens and work props use public source room functions.
	for x: float in [-6.5,-2.5,2.5]:
		_box(self,Vector3(x,.9,-10.95),Vector3(1.15,.8,.08),Color(.52,.68,.73))
		_box(self,Vector3(x,.9,-10.88),Vector3(.06,.8,.1),Color(.26,.15,.08))
		_box(self,Vector3(x,.9,-10.88),Vector3(1.15,.06,.1),Color(.26,.15,.08))
	_box(self,Vector3(4,.92,-1.55),Vector3(.65,.035,.42),Color(.83,.80,.63))
	_box(self,Vector3(3.65,.99,-1.5),Vector3(.08,.16,.08),Color(.10,.11,.16))

func anchors(qualified_map: String = "prototype-mayor-vale-home") -> Array[Dictionary]:
	if qualified_map != location_id: return []
	return station_records.duplicate(true)

func find_anchor(qualified_map: String, id: String) -> Dictionary:
	for record: Dictionary in anchors(qualified_map):
		if record.anchor_id == id: return record
	return {}

func prepare_navigation() -> PackedStringArray:
	if navigation_region != null: return []
	# Source hall and bed corner fit physical 0.4m capsules. 5cm voxels avoid
	# coarse exterior cells eroding their measured narrow floor clearances.
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
		# Straight perimeter walls have no navigable outer corners. Their 5cm
		# margin preserves the exact 1.03125m chair-to-west-wall passage.
		var perimeter: bool = record.id in ["wall-west","wall-east","wall-north","wall-south-west","wall-south-east"]
		var parlor_throat: bool = "armchair" in record.id or record.id == "parlor-fireplace"
		var rect: Rect2 = Rect2(r[0],r[1],r[2],r[3]).grow(.05 if perimeter or parlor_throat else .1)
		var points: PackedVector3Array = [Vector3(rect.position.x,0,rect.position.y),Vector3(rect.end.x,0,rect.position.y),Vector3(rect.end.x,0,rect.end.y),Vector3(rect.position.x,0,rect.end.y)]
		geometry.add_projected_obstruction(points,-.1,2,false)
	NavigationServer3D.bake_from_source_geometry_data(mesh,geometry)
	if mesh.get_polygon_count() == 0: return ["Mayor home has no walkable navigation"]
	navigation_region = NavigationRegion3D.new()
	navigation_region.navigation_mesh = mesh
	add_child(navigation_region)
	return []

func _build_furniture(record: Dictionary) -> void:
	var r: Array = record.rect_xz_m
	var id: String = record.id
	var wall: bool = id.begins_with("wall-")
	var height: float = .65 if wall else .85
	var color: Color = Color(.64,.58,.46) if wall else Color(.29,.17,.09)
	if "bookcase" in id or "wardrobe" in id: height = 1.55
	if "bed" == id.trim_prefix("bedroom-"): height = .48
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
	elif id == "bedroom-bed":
		_box(body,Vector3(0,.51,0),Vector3(r[2]-.12,.1,r[3]-.1),Color(.66,.71,.71))
		_box(body,Vector3(0,.59,-r[3]/2+.3),Vector3(r[2]-.2,.15,.4),Color(.88,.85,.72))
		_box(body,Vector3(0,.58,.2),Vector3(r[2]-.1,.04,r[3]*.55),Color(.28,.40,.44))
	elif "counter" in id or "island" in id:
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
	visual.material_override = preload("res://world/storybook_home_material.gd").painted(color,"MayorValeHome" if parent == self else str(parent.name),center)
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
