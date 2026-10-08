class_name ForagingItemVisual
extends Node3D
## Editable local mesh kit. Visuals own no identity, collision, command or saved facts.
const FLOWER_ICON: Texture2D = preload("res://assets/items/moonflower.svg")
const ROD_ICON: Texture2D = preload("res://assets/items/fishing_rod.svg")

static func icon(item_id: String) -> Texture2D:
	return ROD_ICON if item_id == ForagingRegistry.ROD_ITEM else FLOWER_ICON if item_id == "item-moonflower" else null

func build(rod: bool) -> void:
	if rod: _rod()
	else: _flower()

func _material(color: Color, glow: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = .82
	material.emission_enabled = glow > 0
	material.emission = color
	material.emission_energy_multiplier = glow
	return material

func _part(label: String, mesh: Mesh, at: Vector3, material: Material, sizing: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var part: MeshInstance3D = MeshInstance3D.new()
	part.name = label
	part.mesh = mesh
	part.position = at
	part.scale = sizing
	part.material_override = material
	add_child(part)
	return part

func _ellipsoid(label: String, at: Vector3, sizing: Vector3, material: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = .5
	mesh.height = 1
	mesh.radial_segments = 12
	mesh.rings = 6
	return _part(label,mesh,at,material,sizing)

func _shaft(label: String, at: Vector3, length: float, radius: float, material: Material, horizontal: bool = false) -> void:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.height = length
	mesh.top_radius = radius * .7
	mesh.bottom_radius = radius
	mesh.radial_segments = 10
	var part: MeshInstance3D = _part(label,mesh,at,material)
	if horizontal: part.rotation.z = PI / 2

func _flower() -> void:
	var green: StandardMaterial3D = _material(Color(.18,.48,.32),.14)
	var ivory: StandardMaterial3D = _material(Color(.82,.87,1),.5)
	var heart: StandardMaterial3D = _material(Color(.98,.78,.38),.4)
	_shaft("Stem",Vector3(0,.22,0),.44,.023,green)
	for sign_value: float in [-1.0,1.0]:
		var leaf: MeshInstance3D = _ellipsoid("LeafLeft" if sign_value < 0 else "LeafRight",Vector3(sign_value * .1,.17,.02),Vector3(.24,.05,.09),green)
		leaf.rotation.z = sign_value * .45
	for index: int in range(5):
		var angle: float = TAU * index / 5.0
		var petal: MeshInstance3D = _ellipsoid("Petal%d" % index,Vector3(cos(angle)*.135,.43,sin(angle)*.135),Vector3(.29,.11,.15),ivory)
		petal.rotation.y = -angle
	_ellipsoid("MoonHeart",Vector3(0,.46,0),Vector3(.13,.09,.13),heart)

func _rod() -> void:
	var shaft: StandardMaterial3D = _material(Color(.84,.87,.78),.3)
	var cork: StandardMaterial3D = _material(Color(.72,.43,.19),.25)
	var teal: StandardMaterial3D = _material(Color(.15,.6,.57),.35)
	_shaft("RodShaft",Vector3(0,.08,0),.9,.028,shaft,true)
	_shaft("CorkGrip",Vector3(-.31,.08,0),.24,.043,cork,true)
	for index: int in range(3):
		_shaft("Binding%d" % index,Vector3(-.17 + index*.24,.08,0),.035,.033,teal,true)
	_ellipsoid("Reel",Vector3(-.23,.08,.085),Vector3(.12,.1,.065),teal)
	_shaft("ReelHandle",Vector3(-.23,.08,.135),.075,.016,cork,true)
