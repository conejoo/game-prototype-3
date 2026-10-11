"""Separate background Blender; immutable original kit. Two existing modules only."""
from pathlib import Path
import json
import hashlib
import bpy
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'docs/evidence/AD006/authoring-20261011'
source=ROOT/'art/source/alderwake_town_kit.blend'
pin=hashlib.sha256(source.read_bytes()).hexdigest()
bpy.ops.wm.open_mainfile(filepath=str(source),load_ui=False)
recipe=json.loads((ROOT/'art/source/storybook/dock-painted-recipe.json').read_text())
mat=bpy.data.materials.new('MAT-AD006-dock-stone-painted');mat.use_nodes=True
bsdf=mat.node_tree.nodes.get('Principled BSDF')
bsdf.inputs['Base Color'].default_value=(1,1,1,1)
bsdf.inputs['Roughness'].default_value=.97;bsdf.inputs['Metallic'].default_value=0
tex=mat.node_tree.nodes.new('ShaderNodeTexImage')
tex.image=bpy.data.images.load(str(ROOT/'art/source/storybook/dock-painted-albedo.png'))
tex.image.colorspace_settings.name='sRGB';tex.extension='EXTEND';tex.image.pack()
mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
scene=bpy.data.scenes.new('RF-AD006-DockPilot')
reports=[]
for name,family in [('GEO-dock-plank-module','dock'),('GEO-quay-stone-module','plaza')]:
    obj=bpy.data.objects[name];mesh=obj.data
    original=[tuple(v.co) for v in mesh.vertices];topology=[list(p.vertices) for p in mesh.polygons]
    uv=mesh.uv_layers.new(name='UV-painted-dock')
    x0,y0,x1,y1=recipe['regions'][family]['safe_pixels']
    for poly in mesh.polygons:
        n=poly.normal.copy()
        # Opposite winding on original coplanar faces must sample same brush.
        dominant=max(range(3),key=lambda i:abs(n[i]))
        if n[dominant]<0:n=-n
        axis=Vector((1,0,0)) if abs(n.x)<.9 else Vector((0,1,0))
        u=(axis-n*axis.dot(n)).normalized();v=n.cross(u).normalized()
        # Coordinates span entire module, preserving matching metres on each face.
        projected=[(vert.co.dot(u),vert.co.dot(v)) for vert in mesh.vertices]
        lo=[min(p[i] for p in projected) for i in range(2)]
        hi=[max(p[i] for p in projected) for i in range(2)]
        density=64
        startx=x0+(x1-x0-(hi[0]-lo[0])*density)*.5
        starty=y0+(y1-y0-(hi[1]-lo[1])*density)*.5
        for li in poly.loop_indices:
            point=mesh.vertices[mesh.loops[li].vertex_index].co
            uv.data[li].uv=((startx+(point.dot(u)-lo[0])*density)/1024,1-(starty+(point.dot(v)-lo[1])*density)/1024)
    mesh.materials.clear();mesh.materials.append(mat)
    for p in mesh.polygons:p.material_index=0
    assert original==[tuple(v.co) for v in mesh.vertices] and topology==[list(p.vertices) for p in mesh.polygons]
    for coll in list(obj.users_collection):coll.objects.unlink(obj)
    scene.collection.objects.link(obj)
    obj.location=(0,0,0);obj.rotation_euler=(0,0,0);obj.scale=(1,1,1)
    reports.append({'mesh':name,'vertices_unchanged':True,'topology_unchanged':True,'faces':len(mesh.polygons),'density':64,'coverage':'every top/back/bottom/side face','family':family})
bpy.context.window.scene=scene
for s in list(bpy.data.scenes):
    if s!=scene:bpy.data.scenes.remove(s)
bpy.ops.outliner.orphans_purge(do_recursive=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/storybook/alderwake_dock_pilot.blend'))
props=bpy.ops.export_scene.gltf.get_rna_type().properties.keys()
kwargs=dict(filepath=str(ROOT/'game/assets/environment/storybook/alderwake_dock_pilot.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False,export_image_format='AUTO')
if 'export_vertex_color' in props:kwargs['export_vertex_color']='NONE'
if 'export_all_vertex_colors' in props:kwargs['export_all_vertex_colors']=False
bpy.ops.export_scene.gltf(**kwargs)
assert hashlib.sha256(source.read_bytes()).hexdigest()==pin
report={'task':'AD006','blender':bpy.app.version_string,'original_sha256':pin,'source_unchanged':True,'modules':reports,'shared_materials':1,'images':1}
(OUT/'surface-coverage.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
