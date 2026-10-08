"""Normalize owned N016 library snapshot only, in background Blender."""
import bpy, json
from pathlib import Path
p=Path(bpy.data.filepath)
assert p.parent.name=='source' and p.name in ['npc-01-actions.blend','npc-02-actions.blend']
who=p.name.split('-')[1]
bpy.context.window.scene=bpy.data.scenes[f'RF-N016-{who}-Actions']
scene=bpy.context.scene
arm=next(o for o in scene.objects if o.type=='ARMATURE')
body=next(o for o in scene.objects if o.type=='MESH' and o.name.startswith('GEO-'))
prop=next(o for o in scene.objects if o.name.startswith('PROP-'))
root=next(o for o in scene.objects if o.type=='EMPTY')
clip='action_river_fishing' if who=='01' else 'action_archive_work'
root.name=f'RF_Npc{who}_Actions'; arm.name=f'ARM-npc-{who}-actions'
body.name=f'GEO-npc-{who}-identity'; prop.name='PROP-'+clip
body.data.name=body.name; prop.data.name=f'GEO-npc-{who}-action-prop'
for track in arm.animation_data.nla_tracks: track.mute=True
arm.animation_data.action=None
for bone in arm.pose.bones:
    bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
scene.frame_set(1); bpy.context.view_layer.update()
bpy.ops.object.select_all(action='DESELECT')
for o in scene.objects: o.select_set(True)
target=p.parents[2]/f'game/assets/models/npcs/npc-{who}-actions.glb'
bpy.ops.export_scene.gltf(filepath=str(target),export_format='GLB',use_selection=True,use_active_scene=True,
    export_yup=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,
    export_frame_step=1,export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
for track in arm.animation_data.nla_tracks: track.mute=False
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(p),check_existing=False)
print(json.dumps({'normalized':str(p),'scene':bpy.context.scene.name}))
