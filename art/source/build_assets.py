"""P012 original prototype art. Run inside Blender; preserves existing scenes.

Creates three isolated scenes, writes self-contained .blend sources and selected
mesh-only GLBs. Refuses to replace existing scenes; reopen source for later edits.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art/source'
EXPORT = ROOT / 'game/assets/models'
EVIDENCE = ROOT / 'docs/evidence/P012'
for folder in (SOURCE, EXPORT, EVIDENCE):
    folder.mkdir(parents=True, exist_ok=True)


def material(name, color, metal=0.0, roughness=0.7, emission=0.0):
    mat = bpy.data.materials.new('MAT-RF-' + name)
    mat.use_nodes = True
    mat.diffuse_color = (*color, 1)
    shader = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    for key, value in {'Base Color': (*color, 1), 'Metallic': metal,
                       'Roughness': roughness, 'Emission Color': (*color, 1),
                       'Emission Strength': emission}.items():
        next(i for i in shader.inputs if i.name == key).default_value = value
    return mat


def mesh_object(scene, name, vertices, faces, mat, parent=None):
    mesh = bpy.data.meshes.new('GEO-' + name)
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new('GEO-' + name, mesh)
    scene.collection.objects.link(obj)
    obj.parent = parent
    mesh.materials.append(mat)
    return obj


def box(scene, name, center, size, mat, parent, bevel=0.015, rotation=None):
    vertices = []
    for z in (-1, 1):
        for y in (-1, 1):
            for x in (-1, 1):
                v = Vector((x*size[0]/2, y*size[1]/2, z*size[2]/2))
                if rotation:
                    v = rotation @ v
                vertices.append(v + Vector(center))
    faces = [(0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4),
             (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5)]
    obj = mesh_object(scene, name, vertices, faces, mat, parent)
    if bevel:
        mod = obj.modifiers.new('Edge highlights', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
    return obj


def lathe(scene, name, profile, mat, parent, segments=16):
    vertices = [(r*math.cos(i*2*math.pi/segments),
                 r*math.sin(i*2*math.pi/segments), z)
                for r, z in profile for i in range(segments)]
    faces = []
    for row in range(len(profile)-1):
        for i in range(segments):
            j = (i+1) % segments
            faces.append((row*segments+i, row*segments+j,
                          (row+1)*segments+j, (row+1)*segments+i))
    faces += [tuple(reversed(range(segments))),
              tuple((len(profile)-1)*segments+i for i in range(segments))]
    return mesh_object(scene, name, vertices, faces, mat, parent)


def new_asset(name):
    scene_name = 'RF-' + name
    if bpy.data.scenes.get(scene_name):
        raise RuntimeError('Scene already exists: ' + scene_name)
    scene = bpy.data.scenes.new(scene_name)
    scene.unit_settings.system = 'METRIC'
    scene.unit_settings.scale_length = 1.0
    root = bpy.data.objects.new('RF_' + name, None)
    scene.collection.objects.link(root)
    root['prototype_content'] = True
    root['forward'] = 'Blender +Y -> Godot -Z'
    return scene, root


def studio(scene, height, span):
    # Studio nodes are authoring aids, excluded by selected-objects GLB export.
    world = bpy.data.worlds.new('RF-studio-' + scene.name)
    scene.world = world
    world.use_nodes = True
    background = next(n for n in world.node_tree.nodes if n.type == 'BACKGROUND')
    background.inputs[0].default_value = (0.04, 0.05, 0.065, 1)
    background.inputs[1].default_value = 0.55
    target = Vector((0, 0, height/2))
    for name, position, power, color in [
        ('key', (3, 4, 5), 700, (1, 0.86, 0.7)),
        ('fill', (-3, 2, 3), 420, (0.65, 0.83, 1)),
        ('rim', (1, -3, 4), 900, (0.55, 0.85, 1))]:
        data = bpy.data.lights.new('LGT-RF-' + scene.name + name, 'AREA')
        data.energy, data.size, data.color = power, 3, color
        obj = bpy.data.objects.new(data.name, data)
        scene.collection.objects.link(obj)
        obj.location = position
        obj.rotation_euler = (target-obj.location).to_track_quat('-Z', 'Y').to_euler()
    data = bpy.data.cameras.new('CAM-' + scene.name)
    data.type = 'ORTHO'
    data.ortho_scale = span * 1.4
    cam = bpy.data.objects.new(data.name, data)
    scene.collection.objects.link(cam)
    cam.location = (3, 4, 3.2)
    cam.rotation_euler = (target-cam.location).to_track_quat('-Z', 'Y').to_euler()
    scene.camera = cam
    scene.render.engine = bpy.context.scene.render.engine
    scene.render.resolution_x = scene.render.resolution_y = 640
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = next(
        i.identifier for i in scene.render.image_settings.bl_rna.properties['file_format'].enum_items
        if i.identifier == 'PNG')
    scene.render.filepath = str(EVIDENCE / (scene.name + '.png'))
    return cam


def save_export(scene, asset_root, filename):
    old_scene = bpy.context.window.scene
    try:
        bpy.context.window.scene = scene
        for obj in scene.objects:
            obj.select_set(obj == asset_root or obj.parent == asset_root)
        bpy.context.view_layer.objects.active = asset_root
        bpy.ops.export_scene.gltf(filepath=str(EXPORT / (filename + '.glb')),
            export_format='GLB', use_selection=True, use_active_scene=True, export_apply=True,
            export_yup=True, export_animations=False, export_cameras=False,
            export_lights=False)
        bpy.data.libraries.write(str(SOURCE / (filename + '.blend')), {scene})
        deps = bpy.context.evaluated_depsgraph_get()
        points, triangles = [], 0
        for obj in scene.objects:
            if obj.parent == asset_root and obj.type == 'MESH':
                evaluated = obj.evaluated_get(deps)
                mesh = evaluated.to_mesh()
                mesh.calc_loop_triangles()
                triangles += len(mesh.loop_triangles)
                points.extend(obj.matrix_world @ v.co for v in mesh.vertices)
                evaluated.to_mesh_clear()
        return {'asset': filename, 'triangles': triangles,
                'bounds_blender': [[min(v[i] for v in points) for i in range(3)],
                                   [max(v[i] for v in points) for i in range(3)]],
                'blend_bytes': (SOURCE / (filename + '.blend')).stat().st_size,
                'glb_bytes': (EXPORT / (filename + '.glb')).stat().st_size}
    finally:
        bpy.context.window.scene = old_scene


def build():
    global MATS
    MATS = {'stone': material('slate', (0.22, 0.30, 0.34)),
            'dark': material('dark-joints', (0.045, 0.065, 0.07)),
            'plate': material('fired-clay-plate', (0.46, 0.16, 0.055)),
            'bronze': material('bronze', (0.48, 0.28, 0.105), 1, 0.48),
            'trim': material('bright-bronze', (0.72, 0.47, 0.18), 1, 0.36),
            'core': material('recovery-teal', (0.035, 0.55, 0.42), emission=1.2)}
    original = bpy.context.window.scene
    scene, root = new_asset('RecoveryVessel')
    lathe(scene, 'vessel-core', [(0.22, 0.15), (0.26, 0.24), (0.26, 0.81), (0.20, 0.91)], MATS['core'], root)
    for name, profile in [
        ('foot', [(0.30, 0), (0.30, 0.08), (0.25, 0.16)]),
        ('base-band', [(0.275, 0.16), (0.29, 0.20), (0.29, 0.26), (0.275, 0.28)]),
        ('top-band', [(0.275, 0.77), (0.29, 0.81), (0.29, 0.87), (0.20, 0.93)]),
        ('lid', [(0.20, 0.92), (0.20, 0.98), (0.16, 1.01)])]:
        lathe(scene, 'vessel-' + name, profile, MATS['bronze'], root)
    for i in range(6):
        angle = i*math.pi/3
        box(scene, 'vessel-rib-%d' % i, (0.26*math.cos(angle), 0.26*math.sin(angle), 0.52),
            (0.075, 0.055, 0.58), MATS['trim'], root, rotation=Matrix.Rotation(angle, 3, 'Z'))
    for x in (-0.11, 0.11):
        box(scene, 'vessel-handle-post-' + str(x), (x, 0, 1.065), (0.045, 0.065, 0.13), MATS['trim'], root)
    box(scene, 'vessel-handle', (0, 0, 1.135), (0.265, 0.065, 0.05), MATS['trim'], root)
    studio(scene, 1.16, 1.16)
    records = [save_export(scene, root, 'recovery_vessel')]

    scene, root = new_asset('Guardian')
    for side in (-1, 1):
        box(scene, 'guardian-foot-' + str(side), (side*0.19, 0.025, 0.1), (0.27, 0.40, 0.2), MATS['stone'], root, 0.035)
        box(scene, 'guardian-leg-' + str(side), (side*0.18, 0, 0.37), (0.19, 0.20, 0.44), MATS['dark'], root)
        box(scene, 'guardian-knee-' + str(side), (side*0.18, 0.10, 0.42), (0.22, 0.14, 0.22), MATS['bronze'], root)
        box(scene, 'guardian-arm-' + str(side), (side*0.29, 0, 0.89), (0.14, 0.23, 0.54), MATS['dark'], root)
        box(scene, 'guardian-shoulder-' + str(side), (side*0.29, 0, 1.15), (0.16, 0.32, 0.23), MATS['plate'], root, 0.025)
        box(scene, 'guardian-fist-' + str(side), (side*0.29, 0.02, 0.69), (0.15, 0.27, 0.20), MATS['bronze'], root)
    box(scene, 'guardian-hip', (0, 0, 0.61), (0.48, 0.30, 0.18), MATS['bronze'], root, 0.025)
    box(scene, 'guardian-torso', (0, 0, 0.97), (0.48, 0.38, 0.59), MATS['plate'], root, 0.055)
    box(scene, 'guardian-chest-seal', (0, 0.21, 1.02), (0.18, 0.055, 0.22), MATS['core'], root,
        rotation=Matrix.Rotation(math.pi/4, 3, 'Y'))
    box(scene, 'guardian-neck', (0, 0, 1.29), (0.20, 0.20, 0.15), MATS['dark'], root)
    box(scene, 'guardian-head', (0, 0, 1.43), (0.40, 0.34, 0.30), MATS['stone'], root, 0.04)
    box(scene, 'guardian-visor', (0, 0.18, 1.44), (0.29, 0.045, 0.065), MATS['core'], root, 0.01)
    box(scene, 'guardian-brow', (0, 0.195, 1.51), (0.36, 0.08, 0.065), MATS['bronze'], root)
    studio(scene, 1.58, 1.65)
    records.append(save_export(scene, root, 'guardian'))

    scene, root = new_asset('TollworksPlinth')
    box(scene, 'plinth-foot', (0, 0, 0.075), (2, 2, 0.15), MATS['dark'], root, 0.025)
    box(scene, 'plinth-block', (0, 0, 0.32), (1.92, 1.92, 0.41), MATS['stone'], root, 0.055)
    box(scene, 'plinth-cap', (0, 0, 0.555), (2, 2, 0.09), MATS['bronze'], root, 0.02)
    for axis in (0, 1):
        for sign in (-1, 1):
            center = [0, 0, 0.32]
            center[axis] = sign*0.966
            size = (0.035, 0.66, 0.13) if axis == 0 else (0.66, 0.035, 0.13)
            box(scene, 'plinth-inset-%d-%d' % (axis, sign), center, size, MATS['dark'], root, 0.008)
    studio(scene, 0.6, 2.5)
    records.append(save_export(scene, root, 'tollworks_plinth'))
    assert bpy.context.window.scene == original
    (EVIDENCE / 'asset-manifest-v1.json').write_text(json.dumps(records, indent=2))
    print(json.dumps({'assets': records, 'original_scene_preserved': original.name}))


if __name__ == '__main__':
    build()
