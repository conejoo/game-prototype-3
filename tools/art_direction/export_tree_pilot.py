"""AD003 background Blender only: preserve original kit, paint oak family sibling."""
import bpy
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'docs/evidence/AD003/authoring-20261011'
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/moonwood_tree_kit.blend'), load_ui=False)
recipe = json.loads((ROOT/'art/source/storybook/tree-painted-recipe.json').read_text())
objects = [bpy.data.objects['GEO-oak-'+size] for size in ['small','standard','large']]
inspection = {'blender':bpy.app.version_string,'scene':bpy.context.scene.name,'meshes':[
    {'name':obj.name,'vertices':len(obj.data.vertices),'faces':len(obj.data.polygons),
     'uv_layers':list(obj.data.uv_layers.keys()),'materials':[m.name for m in obj.data.materials],
     'transform':str(obj.matrix_world)} for obj in objects]}
(OUT/'source-inspection.json').write_text(json.dumps(inspection,indent=2)+'\n')
mat = bpy.data.materials.new('MAT-AD003-oak-painted'); mat.use_nodes=True
bsdf = next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Base Color'].default_value=(1,1,1,1)
bsdf.inputs['Metallic'].default_value=0; bsdf.inputs['Roughness'].default_value=.92
tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
tex.image=bpy.data.images.load(str(ROOT/'art/source/storybook/tree-painted-albedo.png'))
tex.image.colorspace_settings.name='sRGB'; tex.extension='EXTEND'; tex.image.pack()
mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
reports=[]
scene=bpy.data.scenes.new('RF-AD003-OakPilot')
for obj in objects:
    mesh=obj.data
    original=[tuple(v.co) for v in mesh.vertices]; topology=[list(p.vertices) for p in mesh.polygons]
    colors=mesh.color_attributes['Color']; uv=mesh.uv_layers.new(name='UV-painted-tree')
    counts={'foliage':0,'bark':0}; normals={'top':0,'bottom':0,'sides':0}
    for poly in mesh.polygons:
        # Original authored POINT color reliably distinguishes wood from foliage.
        color=colors.data[poly.vertices[0]].color
        family='bark' if color[0]>color[1] else 'foliage'
        counts[family]+=1
        normal=poly.normal
        normals['top' if normal.z>.8 else 'bottom' if normal.z<-.8 else 'sides']+=1
        # Orthonormal physical face coordinates avoid projection collapse on caps.
        if family=='bark' and abs(normal.z)<.9:
            v=(Vector((0,0,1))-normal*normal.z).normalized(); u=v.cross(normal).normalized()
        else:
            axis=Vector((1,0,0)) if abs(normal.x)<.9 else Vector((0,1,0))
            u=(axis-normal*axis.dot(normal)).normalized(); v=normal.cross(u).normalized()
        points=[mesh.vertices[i].co for i in poly.vertices]
        coords=[(p.dot(u),p.dot(v)) for p in points]
        lo=[min(p[i] for p in coords) for i in range(2)]
        hi=[max(p[i] for p in coords) for i in range(2)]
        x0,y0,x1,y1=recipe['regions'][family]['safe_pixels']
        # Vary patch center per physical face, keep all loops inside safe rectangle.
        sx=x0+24+(poly.index*37) % 250; sy=y0+24+(poly.index*59) % 600
        assert sx+(hi[0]-lo[0])*48<x1 and sy+(hi[1]-lo[1])*48<y1
        for li,(a,b) in zip(poly.loop_indices,coords):
            uv.data[li].uv=((sx+(a-lo[0])*48)/1024,1-(sy+(b-lo[1])*48)/1024)
    mesh.materials.clear();mesh.materials.append(mat)
    for poly in mesh.polygons:poly.material_index=0
    assert original==[tuple(v.co) for v in mesh.vertices] and topology==[list(p.vertices) for p in mesh.polygons]
    for coll in list(obj.users_collection):coll.objects.unlink(obj)
    scene.collection.objects.link(obj)
    obj.location=(0,0,0);obj.rotation_euler=(0,0,0);obj.scale=(1,1,1)
    mesh.calc_loop_triangles()
    reports.append({'mesh':obj.name,'coverage':counts,'surface_directions':normals,'triangles':len(mesh.loop_triangles),
                    'vertices_unchanged':True,'topology_unchanged':True,'density_texels_per_m':48,'all_faces_image_textured':True})
bpy.context.window.scene=scene
for s in list(bpy.data.scenes):
    if s!=scene:bpy.data.scenes.remove(s)
bpy.ops.outliner.orphans_purge(do_recursive=True)
bpy.ops.object.select_all(action='SELECT')
bpy.context.view_layer.objects.active=objects[0]
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/storybook/moonwood_oak_pilot.blend'))
kwargs=dict(filepath=str(ROOT/'game/assets/environment/storybook/moonwood_oak_pilot.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False,export_image_format='AUTO')
props=bpy.ops.export_scene.gltf.get_rna_type().properties.keys()
if 'export_vertex_color' in props:kwargs['export_vertex_color']='NONE'
if 'export_all_vertex_colors' in props:kwargs['export_all_vertex_colors']=False
bpy.ops.export_scene.gltf(**kwargs)
(OUT/'surface_coverage_report.json').write_text(json.dumps({'task':'AD003','blender':bpy.app.version_string,'meshes':reports},indent=2)+'\n')
print(json.dumps(reports))
