"""Normalize only the owned Ivo library snapshot in a background process."""
import bpy
from pathlib import Path
path = Path('D:/development/game-dev-blender/returning-fair-prototype/art/source/npc-07.blend')
assert Path(bpy.data.filepath).resolve() == path.resolve()
bpy.context.preferences.filepaths.save_version = 0
bpy.context.window.scene = bpy.data.scenes['RF-Npc07-Ivo']
# A scoped library snapshot can retain Blender's numeric suffixes after repair.
# Normalize only this mainfile's three asset objects/dependencies and re-export.
scene=bpy.context.scene
skin=next(o for o in scene.objects if o.type=='MESH')
skin.name='GEO-npc-07-Ivo'
skin.data.name='GEO-npc-07-Ivo'
arm=next(o for o in scene.objects if o.type=='ARMATURE')
arm.name='ARM-npc-07'
arm.data.name='ARM-npc-07'
next(o for o in scene.objects if o.type=='EMPTY').name='RF_Npc07_Ivo'
material=skin.data.materials[0]
material.name='MAT-npc-07-captain'
image=next(n.image for n in material.node_tree.nodes if n.type=='TEX_IMAGE')
image.name='TEX-npc-07-palette'
for track in arm.animation_data.nla_tracks: track.mute=True
for bone in arm.pose.bones:
    bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
scene.frame_set(1); bpy.context.view_layer.update()
bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects: obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(path.parents[2]/'game/assets/models/npcs/npc-07.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
    export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
    export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
for track in arm.animation_data.nla_tracks: track.mute=False
bpy.ops.wm.save_as_mainfile(filepath=str(path),check_existing=False)
print('N013 editable mainfile:',path)
