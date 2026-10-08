"""Read-only owned editable N016 source validation, background Blender only."""
import bpy,json,hashlib,sys
from pathlib import Path
ROOT=Path('D:/development/game-dev-blender/returning-fair-prototype')
p=Path(bpy.data.filepath).resolve()
assert p in [(ROOT/f'art/source/npc-{who}-actions.blend').resolve() for who in ['01','02']]
who=p.name.split('-')[1]; scene=bpy.context.scene
assert scene.name==f'RF-N016-{who}-Actions' and len(scene.objects)==4
arm=next(o for o in scene.objects if o.type=='ARMATURE')
body=next(o for o in scene.objects if o.name==f'GEO-npc-{who}-identity')
prop=next(o for o in scene.objects if o.name.startswith('PROP-'))
clip='action_river_fishing' if who=='01' else 'action_archive_work'
assert prop.name=='PROP-'+clip
assert len(arm.data.bones)==16 and set(t.name for t in arm.animation_data.nla_tracks)=={'idle','walk',clip}
assert len(prop.vertex_groups)==1 and prop.vertex_groups[0].name==('hand.R' if who=='01' else 'hand.L')
for o in scene.objects:
    assert o.matrix_basis==__import__('mathutils').Matrix.Identity(4)
    assert not o.constraints and not (o.animation_data and o.animation_data.drivers)
    assert not (o.data and getattr(o.data,'animation_data',None) and o.data.animation_data.drivers)
    if o.type=='MESH':
        assert len(o.modifiers)==1 and o.modifiers[0].type=='ARMATURE'
        assert len(o.data.materials)==1 and o.data.materials[0]==body.data.materials[0]
        assert o.data.uv_layers and all(len(v.groups)<=4 for v in o.data.vertices)
image=next(n.image for n in body.data.materials[0].node_tree.nodes if n.type=='TEX_IMAGE')
assert image.packed_file and list(image.size)==[32,32]
with bpy.data.libraries.load(str(ROOT/f'art/source/npc-{who}.blend'),link=False) as (src,dst): dst.scenes=[next(n for n in src.scenes if n.startswith('RF-Npc'))]
original=next(o for o in dst.scenes[0].objects if o.type=='MESH')
def geometry(o):
    return {'vertices':[tuple(v.co) for v in o.data.vertices], 'faces':[tuple(f.vertices) for f in o.data.polygons],
        'uv':[tuple(v.uv) for v in o.data.uv_layers.active.data],
        'groups':[[ (o.vertex_groups[g.group].name,g.weight) for g in v.groups] for v in o.data.vertices]}
assert geometry(body)==geometry(original),'Named body geometry/UV/weights changed'
def curves(action):
    return sorted((f.data_path,f.array_index,tuple((tuple(k.co),k.interpolation) for k in f.keyframe_points))
        for layer in action.layers for strip in layer.strips for bag in strip.channelbags for f in bag.fcurves)
oldarm=next(o for o in dst.scenes[0].objects if o.type=='ARMATURE')
for name in ['idle','walk']:
    current=next(t.strips[0].action for t in arm.animation_data.nla_tracks if t.name==name)
    old=next(t.strips[0].action for t in oldarm.animation_data.nla_tracks if t.name==name)
    assert curves(current)==curves(old),'Original authored loop changed'
report={'status':'PASS','npc_id':'npc-'+who,'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),
    'scene':scene.name,'objects':4,'bones':16,'drivers':0,'constraints':0,'identity_geometry_uv_weights_unchanged':True,
    'original_idle_walk_keys_unchanged':True,'packed_palette':[32,32],'accessory_support':prop.vertex_groups[0].name}
if '--' in sys.argv:
    output=Path(sys.argv[sys.argv.index('--')+1]); assert not output.exists() and output.resolve().is_relative_to(ROOT/'docs/evidence/N016')
    output.write_text(json.dumps(report,indent=2)+'\n')
print('N016_SOURCE '+json.dumps(report))
