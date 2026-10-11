class_name FishingEffects
extends Node3D
## Small unshaded water-anchored visual cues. No bodies, navigation or rules.
var line: MeshInstance3D
var bobber: MeshInstance3D
var ripple: MeshInstance3D
var _mesh: ImmediateMesh = ImmediateMesh.new()
var _material: StandardMaterial3D

func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = Color("eadfba")
	line = MeshInstance3D.new()
	line.mesh = _mesh
	line.material_override = _material
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(line)
	bobber = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = .11
	sphere.height = .22
	bobber.mesh = sphere
	bobber.material_override = _material
	add_child(bobber)
	ripple = MeshInstance3D.new()
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = .24
	ring.outer_radius = .28
	ring.rings = 24
	ring.ring_segments = 6
	ripple.mesh = ring
	ripple.material_override = _material
	add_child(ripple)
	for part: MeshInstance3D in [bobber,ripple]: part.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	clear()

func present(view: Dictionary, foot: Vector3) -> void:
	if view.get("mode") != "attempt" or view.get("phase") not in ["waiting","bite","fighting"]:
		clear()
		return
	show()
	var point: Vector3 = view.point
	var elapsed: float = view.phase_seconds
	var bite: bool = view.phase == "bite"
	_material.albedo_color = Color("edbb60") if bite else Color("eadfba")
	bobber.position = point + Vector3(0,.1 + sin(elapsed*5)*.025,0)
	ripple.position = point + Vector3(0,.035,0)
	ripple.scale = Vector3.ONE * (1.4 + sin(elapsed*12)*.35 if bite else 1.0 + sin(elapsed*4)*.1)
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_mesh.surface_add_vertex(foot + Vector3(0,.65,0))
	_mesh.surface_add_vertex(bobber.position)
	_mesh.surface_end()

func clear() -> void:
	hide()
	_mesh.clear_surfaces()
