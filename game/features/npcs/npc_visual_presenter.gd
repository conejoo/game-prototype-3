class_name NpcVisualPresenter
extends Node3D
## VisualRoot child only. Wrapper owns stable IDs, physics, travel and movement.
## Call set_locomotion with actual achieved speed, never desired input speed.
const BLEND_SECONDS: float = 0.12
const MAX_BONES: int = 32
const MAX_TRIANGLES: int = 12000
const MAX_SURFACES: int = 3
var model: Node3D
var player: AnimationPlayer
var skeleton: Skeleton3D
var reference_walk_speed: float = 0.8
var _speed: float = 0.0
var _holds: PackedStringArray = []

func mount(asset: PackedScene, walk_speed: float = 0.8) -> PackedStringArray:
	if asset == null or not is_finite(walk_speed) or walk_speed <= 0:
		return PackedStringArray(["Missing asset or invalid authored walk speed"])
	var candidate: Node = asset.instantiate()
	var errors: PackedStringArray = []
	var found: Dictionary = {"players":[], "skeletons":[], "triangles":0, "surfaces":0}
	_audit(candidate, found, errors)
	if not candidate is Node3D or not (candidate as Node3D).transform.is_equal_approx(Transform3D.IDENTITY):
		errors.append("Model root must have identity meter/foot transform")
	if found.players.size() != 1 or found.skeletons.size() != 1:
		errors.append("Model needs exactly one exported skeleton and AnimationPlayer")
	elif found.skeletons[0].get_bone_count() > MAX_BONES:
		errors.append("Skeleton exceeds eight-actor budget")
	else:
		var animation: AnimationPlayer = found.players[0]
		for clip: String in ["idle", "walk"]:
			if not animation.has_animation(clip): errors.append("Missing exported clip: " + clip)
			else:
				var data: Animation = animation.get_animation(clip)
				if data.length <= 0 or data.get_track_count() == 0 or data.loop_mode != Animation.LOOP_LINEAR:
					errors.append("Clip must contain baked keys and import as linear loop: " + clip)
	if found.triangles <= 0 or found.triangles > MAX_TRIANGLES or found.surfaces > MAX_SURFACES:
		errors.append("Mesh exceeds eight-actor budget or is empty")
	if not errors.is_empty():
		candidate.free()
		return errors
	# A rejected replacement never removes the accepted asset.
	if model != null: model.free()
	model = candidate as Node3D
	player = found.players[0]
	skeleton = found.skeletons[0]
	reference_walk_speed = walk_speed
	_speed = 0
	_holds.clear()
	add_child(model)
	player.play("idle")
	player.advance(0)
	return []

func set_locomotion(achieved_speed: float) -> bool:
	if player == null or not is_finite(achieved_speed) or achieved_speed < 0: return false
	_speed = achieved_speed
	if not _holds.is_empty(): return true
	var clip: String = "walk" if _speed > 0.001 else "idle"
	player.speed_scale = _speed / reference_walk_speed if clip == "walk" else 1.0
	if player.current_animation != clip: player.play(clip, BLEND_SECONDS)
	return true

func face_direction(direction: Vector3) -> bool:
	if not direction.is_finite() or Vector2(direction.x,direction.z).length_squared() < 0.000001: return false
	rotation.y = atan2(-direction.x,-direction.z)
	return true

func suspend(reason: String) -> bool:
	if player == null or reason.is_empty(): return false
	if reason not in _holds: _holds.append(reason)
	player.speed_scale = 0
	return true

func resume(reason: String) -> bool:
	if reason not in _holds: return false
	_holds.erase(reason)
	if _holds.is_empty(): set_locomotion(_speed)
	return true

func suspended() -> bool:
	return not _holds.is_empty()

func _audit(node: Node, found: Dictionary, errors: PackedStringArray) -> void:
	if node.get_script() != null or node is CollisionObject3D or node is CollisionShape3D or node is Camera3D or node is Light3D:
		errors.append("Imported art contains gameplay/studio nodes")
	if node is AnimationPlayer: found.players.append(node)
	if node is Skeleton3D: found.skeletons.append(node)
	if node is MeshInstance3D:
		var mesh: Mesh = node.mesh
		if mesh == null: errors.append("Empty mesh")
		else:
			found.surfaces += mesh.get_surface_count()
			for surface: int in range(mesh.get_surface_count()):
				var arrays: Array = mesh.surface_get_arrays(surface)
				found.triangles += arrays[Mesh.ARRAY_INDEX].size()/3 if arrays[Mesh.ARRAY_INDEX] != null else arrays[Mesh.ARRAY_VERTEX].size()/3
				if not mesh.surface_get_material(surface) is StandardMaterial3D: errors.append("Missing portable PBR material")
	for child: Node in node.get_children(): _audit(child, found, errors)
