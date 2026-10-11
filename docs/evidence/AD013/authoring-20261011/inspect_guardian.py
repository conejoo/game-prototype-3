import bpy, json, hashlib
from pathlib import Path
root=Path.cwd()
p=root/'art/source/guardian.blend'
before=hashlib.sha256(p.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(p),load_ui=False)
r={'task':'AD013','kind':'read-only background source inspection; no save/export/live editor changes','version':bpy.app.version_string,'pid':__import__('os').getpid(),'path':str(p),'sha256':before,'scenes':[s.name for s in bpy.data.scenes],'meshes':[{'name':o.name,'vertices':len(o.data.vertices),'uv_layers':len(o.data.uv_layers)} for o in bpy.data.objects if o.type=='MESH'],'materials':[{'name':m.name,'color':list(m.diffuse_color)} for m in bpy.data.materials]}
assert hashlib.sha256(p.read_bytes()).hexdigest()==before
(root/'docs/evidence/AD013/authoring-20261011/guardian-source.json').write_text(json.dumps(r,indent=2))
