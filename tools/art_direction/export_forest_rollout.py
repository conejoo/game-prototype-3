"""AD010 background authoring: geometry-identical trees/landmarks, existing atlases."""
import bpy
import json
import struct
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/evidence/AD010/authoring-20261011'
OUT.mkdir(parents=True, exist_ok=True)

def external_image(path, uri):
    data = path.read_bytes()
    size = struct.unpack_from('<I', data, 12)[0]
    doc = json.loads(data[20:20+size]); doc['images'][0] = {'uri':uri}
    encoded = json.dumps(doc,separators=(',',':')).encode()
    encoded += b' '*((-len(encoded))%4)
    remaining = data[20+size:]
    path.write_bytes(struct.pack('<III',0x46546c67,2,20+len(encoded)+len(remaining))+
                     struct.pack('<II',len(encoded),0x4e4f534a)+encoded+remaining)

def export(kind, source, mapping_path, atlas, recipe_path, sibling):
    bpy.ops.wm.open_mainfile(filepath=str(ROOT/source), load_ui=False)
    mapping = json.loads((ROOT/mapping_path).read_text())
    regions = json.loads((ROOT/recipe_path).read_text())['regions']
    mat = bpy.data.materials.new('MAT-AD010-'+kind); mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (1,1,1,1)
    bsdf.inputs['Roughness'].default_value = .97
    bsdf.inputs['Metallic'].default_value = 0
    tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
    tex.image = bpy.data.images.load(str(ROOT/'art/source/storybook'/atlas))
    tex.image.colorspace_settings.name = 'sRGB'; tex.extension = 'EXTEND'; tex.image.pack()
    mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
    scene = bpy.data.scenes.new('RF-AD010-'+kind)
    reports = []
    for record in mapping['mappings']:
        # Already accepted oak meshes remain exactly the AD003 pilot.
        if kind == 'trees' and record['species'] == 'oak': continue
        obj = bpy.data.objects[record['mesh_name']]; mesh = obj.data
        original = [tuple(v.co) for v in mesh.vertices]
        topology = [list(p.vertices) for p in mesh.polygons]
        colors = mesh.color_attributes['Color']
        uv = mesh.uv_layers.new(name='UV-painted-forest')
        semantic = mesh.uv_layers.new(name='UV-source-family') if kind == 'trees' else None
        mesh.uv_layers.active = uv
        coverage = {}; directions = {'top':0,'bottom':0,'sides':0}; densities = []
        for poly in mesh.polygons:
            c = colors.data[poly.vertices[0]].color
            if kind == 'trees':
                # Source family hue ratios, including orange maple foliage,
                # pale birch bark, cherry blossom and rowan fruit accents.
                bark = abs(c[1]/c[0]-.46) < .03 if record['species'] != 'birch' else c[1] < c[0]
                family = 'bark' if bark else 'foliage'
                group = 0 if bark else 2 if record['species'] == 'cherry' and c[1] < c[0] else 3 if record['species'] == 'rowan' and c[1] < c[0] else 1
            else:
                # Existing original palette distinguishes blue basin/spiral,
                # neutral stone, and warm bridge/gate wood; no source redesign.
                family = ('slate' if c[2] > c[0]*1.15 else 'linen' if c[0] > .6 else 'stone') if record['module_id'] == 'moonwell' else 'stone' if max(c[:3])-min(c[:3]) < .14 else 'timber'
            coverage[family] = coverage.get(family,0)+1
            n = poly.normal.copy()
            directions['top' if n.z > .8 else 'bottom' if n.z < -.8 else 'sides'] += 1
            if family == 'bark' and abs(n.z) < .9:
                v = (Vector((0,0,1))-n*n.z).normalized(); u = v.cross(n).normalized()
            else:
                axis = Vector((1,0,0)) if abs(n.x) < .9 else Vector((0,1,0))
                u = (axis-n*axis.dot(n)).normalized(); v = n.cross(u).normalized()
                if family == 'timber':
                    pts = [mesh.vertices[i].co for i in poly.vertices]
                    u = max((b-a for a,b in zip(pts,pts[1:]+pts[:1])),key=lambda e:e.length).normalized()
                    v = n.cross(u).normalized()
            coords = [(mesh.vertices[i].co.dot(u),mesh.vertices[i].co.dot(v)) for i in poly.vertices]
            lo = [min(p[i] for p in coords) for i in range(2)]
            span = [max(p[i] for p in coords)-lo[i] for i in range(2)]
            x0,y0,x1,y1 = regions[family]['safe_pixels']
            density = min(48 if kind == 'trees' else 64,(x1-x0-4)/max(span[0],1e-8),(y1-y0-4)/max(span[1],1e-8))
            sx = x0+2+(poly.index*37 % 251)/250*(x1-x0-4-span[0]*density)
            sy = y0+2+(poly.index*59 % 601)/600*(y1-y0-4-span[1]*density)
            for li,(a,b) in zip(poly.loop_indices,coords):
                uv.data[li].uv = ((sx+(a-lo[0])*density)/1024,1-(sy+(b-lo[1])*density)/1024)
                if semantic: semantic.data[li].uv = (group,0)
            densities.append(density)
        mesh.materials.clear(); mesh.materials.append(mat)
        for p in mesh.polygons: p.material_index = 0
        assert original == [tuple(v.co) for v in mesh.vertices]
        assert topology == [list(p.vertices) for p in mesh.polygons]
        for coll in list(obj.users_collection): coll.objects.unlink(obj)
        scene.collection.objects.link(obj)
        obj.location=(0,0,0); obj.rotation_euler=(0,0,0); obj.scale=(1,1,1)
        mesh.calc_loop_triangles()
        reports.append({'mesh':obj.name,'definition':record.get('definition_id',record.get('module_id')),
                        'coverage':coverage,'directions':directions,'triangles':len(mesh.loop_triangles),
                        'density_min_max':[min(densities),max(densities)],'vertices_unchanged':True,'topology_unchanged':True})
    bpy.context.window.scene = scene
    for s in list(bpy.data.scenes):
        if s != scene: bpy.data.scenes.remove(s)
    bpy.ops.outliner.orphans_purge(do_recursive=True)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/source/storybook'/(sibling+'.blend')))
    path = ROOT/'game/assets/environment/storybook'/(sibling+'.glb')
    kwargs = dict(filepath=str(path),export_format='GLB',use_selection=True,use_active_scene=True,
                  export_yup=True,export_animations=False,export_cameras=False,export_lights=False,export_image_format='AUTO')
    props = bpy.ops.export_scene.gltf.get_rna_type().properties.keys()
    if 'export_vertex_color' in props: kwargs['export_vertex_color'] = 'NONE'
    if 'export_all_vertex_colors' in props: kwargs['export_all_vertex_colors'] = False
    bpy.ops.export_scene.gltf(**kwargs)
    external_image(path,atlas)
    return reports

trees = export('trees','art/source/moonwood_tree_kit.blend','game/assets/environment/moonwood_tree_mapping.json',
               'tree-painted-albedo.png','art/source/storybook/tree-painted-recipe.json','moonwood_tree_rollout')
landmarks = export('landmarks','art/source/alderwake_landmark_kit.blend','game/assets/environment/alderwake_landmark_mapping.json',
                   'town-painted-albedo.png','art/source/storybook/town-painted-recipe.json','alderwake_landmark_painted')
report = {'task':'AD010','blender':bpy.app.version_string,'trees':trees,'landmarks':landmarks,
          'coverage':'Every source polygon including bottom/back/side; no overlays; original oak pilot retained'}
(OUT/'surface-coverage.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
