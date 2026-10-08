"""Background Blender read-only audit of N012's normalized editable mainfile."""
import bpy
import json
from pathlib import Path
root = Path('D:/development/game-dev-blender/returning-fair-prototype')
assert Path(bpy.data.filepath).resolve() == (root/'art/source/npc-06.blend').resolve()
assert bpy.context.scene.name == 'RF-Npc06-Tess', 'Source must open as an ordinary active mainfile'
scene = bpy.context.scene
assert len(scene.objects) == 3
assert {o.type for o in scene.objects} == {'EMPTY','ARMATURE','MESH'}
for obj in scene.objects:
    assert all(abs(v) < 1e-6 for v in obj.location)
    assert all(abs(v) < 1e-6 for v in obj.rotation_euler)
    assert all(abs(v-1) < 1e-6 for v in obj.scale)
    assert not obj.constraints
    if obj.animation_data: assert not obj.animation_data.drivers
arm = bpy.data.objects['ARM-npc-06']
assert len(arm.data.bones) == 16
assert {t.name for t in arm.animation_data.nla_tracks} == {'idle','walk'}
assert not any(b.constraints for b in arm.pose.bones)
assert any(i.packed_file for i in bpy.data.images if i.name == 'TEX-npc-06-palette')
report = {'status':'PASS','active_scene':scene.name,'objects':3,'bones':16,'clips':['idle','walk'],'packed_image':True,'drivers':0,'constraints':0,'source_saved':False}
print('N012_EDITABLE_SOURCE '+json.dumps(report))
