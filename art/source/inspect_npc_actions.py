import bpy, json
from pathlib import Path
root = Path('D:/development/game-dev-blender/returning-fair-prototype')
print(json.dumps({'file':bpy.data.filepath,'scene':bpy.context.scene.name,'scenes':[s.name for s in bpy.data.scenes]}))
for who in ['01','02']:
    with bpy.data.libraries.load(str(root / f'art/source/npc-{who}.blend'),link=False) as (src,dst):
        dst.scenes=[src.scenes[0]]
    scene=dst.scenes[0]
    arm=next(o for o in scene.objects if o.type=='ARMATURE')
    print(json.dumps({'npc':who,'scene':scene.name,'objects':[o.name for o in scene.objects],
      'bones':{b.name:[list(b.head_local),list(b.tail_local)] for b in arm.data.bones},
      'tracks':[t.name for t in arm.animation_data.nla_tracks]}))
    scene.name=f'RF-N016-inspect-{who}'
