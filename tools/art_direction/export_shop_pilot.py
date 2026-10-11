"""Run in separate background Blender. Never modify live scene or original source."""
import bpy
import json
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'docs/evidence/AD002/authoring-20261011'
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/alderwake_town_kit.blend'), load_ui=False)
obj = bpy.data.objects['GEO-reed-chandlery']
mesh = obj.data
original = [tuple(v.co) for v in mesh.vertices]
topology = [list(p.vertices) for p in mesh.polygons]
recipe = json.loads((ROOT/'art/source/storybook/town-painted-recipe.json').read_text())
palette = {'plaster':(.67,.55,.35),'slate':(.13,.20,.29),'timber':(.24,.105,.043),
           'stone':(.39,.38,.31),'amber':(.72,.44,.13),'sage':(.24,.37,.22),'linen':(.83,.72,.48)}
uv = mesh.uv_layers.new(name='UV-painted-town')
colors = mesh.color_attributes['Color']
coverage = {}
densities = []
for poly in mesh.polygons:
    c = colors.data[poly.vertices[0]].color
    family = min(palette, key=lambda k:sum((c[i]-palette[k][i])**2 for i in range(3)))
    coverage[family] = coverage.get(family,0)+1
    points = [mesh.vertices[i].co for i in poly.vertices]
    # Planar orthonormal basis per physical face; roof tiles use same roof axes.
    n = poly.normal
    # Original isolated roof polygons have mixed winding. Canonical upward
    # projection keeps base roof and inset tiles sampling identical brushwork.
    if family == 'slate' and n.z < 0: n = -n
    axis = Vector((1,0,0)) if abs(n.x)<.9 else Vector((0,1,0))
    u = (axis-n*axis.dot(n)).normalized()
    v = n.cross(u).normalized()
    if family == 'timber':
        edge = max((b-a for a,b in zip(points,points[1:]+points[:1])),key=lambda e:e.length)
        u = edge.normalized(); v = n.cross(u).normalized()
    coords = [(p.dot(u),p.dot(v)) for p in points]
    # Broad wall/roof patches stay continuous across coplanar detail polygons,
    # rather than sampling the same patch center on every modeled roof tile.
    span_coords = [(vert.co.dot(u),vert.co.dot(v)) for vert in mesh.vertices] if family in ['plaster','slate'] else coords
    lo = [min(p[i] for p in span_coords) for i in range(2)]
    hi = [max(p[i] for p in span_coords) for i in range(2)]
    x0,y0,x1,y1 = recipe['regions'][family]['safe_pixels']
    density = min(64,(x1-x0-2)/max(hi[0]-lo[0],.001),(y1-y0-2)/max(hi[1]-lo[1],.001))
    densities.append(density)
    # Stable offset within patch, with no cross-region wrap/bleed.
    startx = x0+1+(x1-x0-2-(hi[0]-lo[0])*density)*.5
    starty = y0+1+(y1-y0-2-(hi[1]-lo[1])*density)*.5
    for li,(a,b) in zip(poly.loop_indices,coords):
        uv.data[li].uv = ((startx+(a-lo[0])*density)/1024,1-(starty+(b-lo[1])*density)/1024)
mat = bpy.data.materials.new('MAT-AD002-town-painted'); mat.use_nodes=True
bsdf = next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Base Color'].default_value=(1,1,1,1)
bsdf.inputs['Metallic'].default_value=0; bsdf.inputs['Roughness'].default_value=.92
tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
tex.image=bpy.data.images.load(str(ROOT/'art/source/storybook/town-painted-albedo.png'))
tex.image.colorspace_settings.name='sRGB'; tex.extension='EXTEND'; tex.image.pack()
mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
mesh.materials.clear();mesh.materials.append(mat)
for p in mesh.polygons:p.material_index=0
# Retain original color attribute for provenance, but disable exporter color output.
assert original == [tuple(v.co) for v in mesh.vertices] and topology == [list(p.vertices) for p in mesh.polygons]
scene=bpy.data.scenes.new('RF-AD002-ShopPilot')
for coll in list(obj.users_collection):coll.objects.unlink(obj)
scene.collection.objects.link(obj)
bpy.context.window.scene=scene
obj.location=(0,0,0);obj.rotation_euler=(0,0,0);obj.scale=(1,1,1)
bpy.context.view_layer.objects.active=obj;obj.select_set(True)
# Remove other scenes/data from sibling, leaving original mainfile untouched.
for s in list(bpy.data.scenes):
    if s!=scene:bpy.data.scenes.remove(s)
bpy.ops.outliner.orphans_purge(do_recursive=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/storybook/alderwake_shop_pilot.blend'))
props=bpy.ops.export_scene.gltf.get_rna_type().properties.keys()
kwargs=dict(filepath=str(ROOT/'game/assets/environment/storybook/alderwake_shop_pilot.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False,export_image_format='AUTO')
if 'export_vertex_color' in props:kwargs['export_vertex_color']='NONE'
if 'export_all_vertex_colors' in props:kwargs['export_all_vertex_colors']=False
bpy.ops.export_scene.gltf(**kwargs)
report={'task':'AD002','blender':bpy.app.version_string,'mesh':obj.name,'vertices_unchanged':True,'topology_unchanged':True,'faces':len(mesh.polygons),'coverage':coverage,'uv_density_min_max':[min(densities),max(densities)],'all_faces_image_textured':True,'source_original_unchanged':True,'note':'orthonormal planar per-face UVs, true front/back/sides/top/bottom coverage; original color retained in blend but disabled in glTF'}
(OUT/'surface_coverage_report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
