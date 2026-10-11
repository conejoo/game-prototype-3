"""AD009: preserve source geometry; paint thirteen remaining building definitions."""
import bpy
import json
import struct
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/evidence/AD009/authoring-20261011'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(ROOT/'art/source/alderwake_town_kit.blend'), load_ui=False)
recipe = json.loads((ROOT/'art/source/storybook/town-painted-recipe.json').read_text())
palette = {'plaster':(.67,.55,.35),'slate':(.13,.20,.29),'terracotta':(.6,.19,.065),
           'olive_roof':(.19,.27,.17),'teal':(.17,.32,.28),'olive_wall':(.32,.29,.14),
           'timber':(.24,.105,.043),'wood':(.36,.18,.07),'stone':(.39,.38,.31),
           'amber':(.72,.44,.13),'sage':(.24,.37,.22),'linen':(.83,.72,.48)}
aliases = {'terracotta':'slate','olive_roof':'slate','teal':'plaster','olive_wall':'timber','wood':'timber'}
material = bpy.data.materials.new('MAT-AD009-town-painted'); material.use_nodes = True
bsdf = next(n for n in material.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
bsdf.inputs['Roughness'].default_value = .92
bsdf.inputs['Metallic'].default_value = 0
image_node = material.node_tree.nodes.new('ShaderNodeTexImage')
image_node.image = bpy.data.images.load(str(ROOT/'art/source/storybook/town-painted-albedo.png'))
image_node.image.colorspace_settings.name = 'sRGB'; image_node.extension = 'EXTEND'; image_node.image.pack()
material.node_tree.links.new(image_node.outputs['Color'], bsdf.inputs['Base Color'])
mapping = json.loads((ROOT/'game/assets/environment/alderwake_town_mapping.json').read_text())
scene = bpy.data.scenes.new('RF-AD009-TownRollout')
rows = []
for record in mapping['mappings']:
    if 'definition_id' not in record or record['definition_id'] == 'reed-chandlery': continue
    obj = bpy.data.objects[record['mesh_name']]; mesh = obj.data
    original = [tuple(v.co) for v in mesh.vertices]; topology = [list(p.vertices) for p in mesh.polygons]
    uv = mesh.uv_layers.new(name='UV-painted-town'); colors = mesh.color_attributes['Color']
    densities = []; coverage = {}
    for poly in mesh.polygons:
        c = colors.data[poly.vertices[0]].color
        source_family = min(palette, key=lambda k:sum((c[i]-palette[k][i])**2 for i in range(3)))
        family = aliases.get(source_family, source_family)
        # Existing timber-home group receives broad timber facade, preserving geometry.
        if record['definition_id'].startswith('house-timber') and family == 'plaster': family = 'timber'
        if record['definition_id'] in ['alderwake-hall','mayor-vale-home'] and family == 'plaster': family = 'linen'
        coverage[family] = coverage.get(family, 0) + 1
        points = [mesh.vertices[i].co for i in poly.vertices]
        n = poly.normal.copy()
        if family == 'slate' and n.z < 0: n = -n
        axis = Vector((1,0,0)) if abs(n.x) < .9 else Vector((0,1,0))
        u = (axis-n*axis.dot(n)).normalized(); v = n.cross(u).normalized()
        if family == 'timber':
            u = max((b-a for a,b in zip(points,points[1:]+points[:1])), key=lambda e:e.length).normalized()
            v = n.cross(u).normalized()
        coords = [(p.dot(u), p.dot(v)) for p in points]
        span = [(vert.co.dot(u),vert.co.dot(v)) for vert in mesh.vertices] if family in ['plaster','slate','linen'] else coords
        lo = [min(p[i] for p in span) for i in range(2)]; hi = [max(p[i] for p in span) for i in range(2)]
        x0,y0,x1,y1 = recipe['regions'][family]['safe_pixels']
        density = min(64,(x1-x0-2)/max(hi[0]-lo[0],.001),(y1-y0-2)/max(hi[1]-lo[1],.001))
        densities.append(density)
        startx = x0+1+(x1-x0-2-(hi[0]-lo[0])*density)*.5
        starty = y0+1+(y1-y0-2-(hi[1]-lo[1])*density)*.5
        for li,(a,b) in zip(poly.loop_indices,coords):
            uv.data[li].uv = ((startx+(a-lo[0])*density)/1024,1-(starty+(b-lo[1])*density)/1024)
    mesh.materials.clear(); mesh.materials.append(material)
    for p in mesh.polygons: p.material_index = 0
    assert original == [tuple(v.co) for v in mesh.vertices] and topology == [list(p.vertices) for p in mesh.polygons]
    for coll in list(obj.users_collection): coll.objects.unlink(obj)
    scene.collection.objects.link(obj)
    obj.location=(0,0,0); obj.rotation_euler=(0,0,0); obj.scale=(1,1,1)
    rows.append({'definition':record['definition_id'],'mesh':obj.name,'faces':len(mesh.polygons),
                 'coverage':coverage,'density_min_max':[min(densities),max(densities)],'geometry_unchanged':True})
bpy.context.window.scene = scene
for s in list(bpy.data.scenes):
    if s != scene: bpy.data.scenes.remove(s)
bpy.ops.outliner.orphans_purge(do_recursive=True)
for obj in scene.objects: obj.select_set(True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/storybook/alderwake_town_rollout.blend'))
bpy.ops.export_scene.gltf(filepath=str(ROOT/'game/assets/environment/storybook/alderwake_town_rollout.glb'),
    export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,
    export_cameras=False,export_lights=False,export_image_format='AUTO',export_vertex_color='NONE',export_all_vertex_colors=False)
# Portable local bundle resolves the existing sibling PNG, avoiding another
# imported embedded-image resource. Editable Blender source still packs its image.
glb_path = ROOT/'game/assets/environment/storybook/alderwake_town_rollout.glb'
data = glb_path.read_bytes(); size = struct.unpack_from('<I', data, 12)[0]
document = json.loads(data[20:20+size]); document['images'][0] = {'uri':'town-painted-albedo.png'}
encoded = json.dumps(document,separators=(',',':')).encode(); encoded += b' '*((-len(encoded))%4)
remaining = data[20+size:]
glb_path.write_bytes(struct.pack('<III',0x46546c67,2,20+len(encoded)+len(remaining))+struct.pack('<II',len(encoded),0x4e4f534a)+encoded+remaining)
report={'task':'AD009','blender':bpy.app.version_string,'definitions':rows,'atlas':'town-painted-albedo.png',
        'note':'13 new definitions plus unchanged AD002 shop; isotropic orthonormal face projection; all polygon loops covered; runtime palette remap shares existing atlas'}
(OUT/'surface-coverage.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
