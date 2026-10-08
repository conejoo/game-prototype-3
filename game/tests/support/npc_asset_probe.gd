class_name NpcAssetProbe
extends RefCounted
## CPU-deformed exported mesh evidence. Rest AABBs cannot prove clip bounds.

static func mesh_nodes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D: result.append(node)
	for child: Node in node.get_children(): result.append_array(mesh_nodes(child))
	return result

static func deformed_vertices(presenter: NpcVisualPresenter) -> PackedVector3Array:
	var result: PackedVector3Array = []
	var rig: Skeleton3D = presenter.skeleton
	rig.force_update_all_bone_transforms()
	for node: MeshInstance3D in mesh_nodes(presenter.model):
		for surface: int in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			for i: int in range(vertices.size()):
				var point: Vector3 = Vector3.ZERO
				for influence: int in range(4):
					var offset: int = i*4+influence
					if weights[offset] <= 0: continue
					var bind: int = bones[offset]
					var bone: int = rig.find_bone(node.skin.get_bind_name(bind))
					if bone < 0: bone = node.skin.get_bind_bone(bind)
					point += (rig.get_bone_global_pose(bone)*node.skin.get_bind_pose(bind)*vertices[i])*weights[offset]
				result.append(rig.global_transform*point)
	return result

static func bounds(vertices: PackedVector3Array) -> AABB:
	var box: AABB = AABB(vertices[0],Vector3.ZERO)
	for point: Vector3 in vertices: box = box.expand(point)
	return box

static func sample(presenter: NpcVisualPresenter, clip: String, seconds: float) -> PackedVector3Array:
	presenter.player.play(clip,0)
	presenter.player.seek(seconds,true)
	presenter.player.advance(0)
	return deformed_vertices(presenter)

static func bone_point(presenter: NpcVisualPresenter, bone: String) -> Vector3:
	return presenter.skeleton.global_transform * presenter.skeleton.get_bone_global_pose(presenter.skeleton.find_bone(bone)).origin
