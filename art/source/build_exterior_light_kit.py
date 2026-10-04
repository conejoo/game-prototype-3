"""W005 isolated, reproducible meter-scale light kit. Execute inside Blender.

Godot coordinates are converted (x, -z, y); glTF exporter handles Y-up.
Existing live scenes, selection, file and viewport are preserved.
"""
import bpy
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
NAME = 'RF-W005-ExteriorLightKit'
if NAME in bpy.data.scenes:
    raise RuntimeError('W005 scene already exists; inspect before replacing')
scene = bpy.data.scenes.new(NAME)
scene.unit_settings.system = 'METRIC'
scene.unit_settings.scale_length = 1
old_scene = bpy.context.window.scene
old_selected = list(bpy.context.selected_objects)
old_active = bpy.context.view_layer.objects.active

def material(name, color, palette=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*color, 1)
    bsdf.inputs['Roughness'].default_value = .78
    if palette:
        node = mat.node_tree.nodes.new('ShaderNodeVertexColor')
        node.layer_name = 'Color'
        mat.node_tree.links.new(node.outputs['Color'], bsdf.inputs['Base Color'])
    return mat

frame_mat = material('MAT-W005-weathered_palette', (.25,.21,.16), True)
core_mat = material('MAT-W005-dormant_glass', (.18,.12,.05))
verts, faces, colors = [], [], []

def reset():
    verts.clear(); faces.clear(); colors.clear()

def vertex(point):
    x,y,z = point
    verts.append((x,-z,y))
    return len(verts)-1

def box(center, size, color):
    x,y,z = center; a,b,c = [v/2 for v in size]
    ids = [vertex((x+dx*a,y+dy*b,z+dz*c)) for dx,dy,dz in
           [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
        faces.append(tuple(ids[i] for i in f)); colors.append(color)

def rod(a, b, radius, color, sides=8):
    from mathutils import Vector
    a,b = Vector(a),Vector(b); axis=(b-a).normalized()
    u=axis.cross(Vector((0,1,0)) if abs(axis.y)<.9 else Vector((1,0,0))).normalized()
    v=axis.cross(u)
    rings=[]
    for p in (a,b):
        rings.append([vertex(p+radius*(math.cos(i*math.tau/sides)*u+math.sin(i*math.tau/sides)*v)) for i in range(sides)])
    faces.append(tuple(reversed(rings[0]))); colors.append(color)
    faces.append(tuple(rings[1])); colors.append(color)
    for i in range(sides):
        j=(i+1)%sides
        faces.append((rings[0][i],rings[0][j],rings[1][j],rings[1][i])); colors.append(color)

stats=[]
def finish(name, mat):
    mesh=bpy.data.meshes.new(name)
    mesh.from_pydata(verts,[],faces); mesh.update()
    attr=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='CORNER')
    for polygon,color in zip(mesh.polygons,colors):
        for loop in polygon.loop_indices: attr.data[loop].color=(*color,1)
    obj=bpy.data.objects.new(name,mesh); scene.collection.objects.link(obj)
    mesh.materials.append(mat)
    mesh.calc_loop_triangles()
    stats.append({'mesh_name':name,'vertices':len(mesh.vertices),'triangles':len(mesh.loop_triangles)})
    reset()
    return obj

wood=(.28,.17,.09); iron=(.15,.19,.19); brass=(.56,.36,.12); rope=(.43,.36,.22)
# Lamp centre registered to existing catalog collision; bulb is 1.55m above foot.
x,z=-.1875,-.265625
box((x,.075,z),(.32,.15,.32),iron)
rod((x,.08,z),(x,1.39,z),.065,wood,10)
for y in (.22,1.24): box((x,y,z),(.15,.065,.15),iron)
box((x,1.35,z),(.38,.08,.38),brass)
box((x,1.77,z),(.43,.09,.43),iron)
box((x,1.86,z),(.27,.09,.27),iron)
for dx in (-.15,.15):
    for dz in (-.15,.15): rod((x+dx,1.37,z+dz),(x+dx,1.75,z+dz),.018,brass,6)
finish('GEO-W005-dock-lamp-frame',frame_mat)
box((x,1.55,z),(.26,.30,.26),(.20,.13,.05))
finish('GEO-W005-dock-lamp-core',core_mat)
# Compact trail waylight, shell below cap; no giant source-sprite-height conversion.
box((0,.08,-.125),(.40,.16,.40),iron)
box((0,.33,-.125),(.23,.45,.23),wood)
box((0,.52,-.125),(.36,.07,.36),brass)
box((0,.79,-.125),(.39,.08,.39),iron)
for dx in (-.135,.135):
    for dz in (-.135,.135): rod((dx,.53,-.125+dz),(dx,.78,-.125+dz),.016,brass,6)
finish('GEO-W005-waylight-frame',frame_mat)
box((0,.65,-.125),(.23,.22,.23),(.15,.22,.20))
finish('GEO-W005-waylight-core',core_mat)
# Modest nonblocking woven display. Rope grid sags through centre; knots separate.
for x in (-.7,.7): rod((x,0,-.45),(x,1.40,-.45),.045,wood)
rod((-.74,1.36,-.45),(.74,1.36,-.45),.035,wood)
def point(i,j):
    x=-.62+i*.155; y=.35+j*.125-.10*(1-(x/.62)**2)
    return (x,y,-.45)
for i in range(9):
    for j in range(8): rod(point(i,j),point(i,j+1),.007,rope,4)
for j in range(9):
    for i in range(8): rod(point(i,j),point(i+1,j),.007,rope,4)
finish('GEO-W005-woven-net-frame',frame_mat)
for i in range(1,8,2):
    for j in range(1,8,2): box(point(i,j),(.035,.035,.025),(.2,.22,.10))
finish('GEO-W005-woven-net-knots',core_mat)

try:
    bpy.context.window.scene=scene
    bpy.ops.object.select_all(action='SELECT')
    for obj in scene.objects:
        bpy.context.view_layer.objects.active=obj
        bpy.ops.object.mode_set(mode='EDIT')
        bpy.ops.mesh.select_all(action='SELECT')
        bpy.ops.mesh.normals_make_consistent(inside=False)
        bpy.ops.object.mode_set(mode='OBJECT')
    bpy.ops.export_scene.gltf(filepath=str(ROOT/'game/assets/environment/exterior_light_kit.glb'),
        export_format='GLB',use_selection=True,use_active_scene=True,export_apply=True,export_yup=True,
        export_materials='EXPORT',export_animations=False,export_cameras=False,export_lights=False)
    source_path = str(ROOT/'art/source/exterior_light_kit.blend')
    if bpy.app.background:
        bpy.context.preferences.filepaths.save_version = 0
        bpy.ops.wm.save_as_mainfile(filepath=source_path, check_existing=False)
    else:
        bpy.data.libraries.write(source_path,{scene})
finally:
    bpy.context.window.scene=old_scene
    for obj in old_selected: obj.select_set(True)
    bpy.context.view_layer.objects.active=old_active
report={'scene':NAME,'coordinate_contract':'Godot (x,y,z) -> Blender (x,-z,y); glTF Y-up',
        'meshes':stats,'anchors':{'dock_lamp':[-.1875,1.55,-.265625],'waylight':[0,.65,-.125],'woven_net':[0,1,-.45]},
        'materials':'opaque rough vertex palette frame; dormant glass overridden per source in Godot'}
(ROOT/'art/exports/exterior_light_kit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
