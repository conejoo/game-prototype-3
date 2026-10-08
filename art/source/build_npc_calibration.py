"""N007 articulated calibration fixture, not a named villager or human likeness.

Run through the existing Blender MCP. Creates only RF-NpcCalibration, restores
the user's scene, and writes a scoped snapshot. Normalize that owned snapshot
with --background <snapshot> --python normalize_npc_calibration.py afterward.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector, Matrix

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-NpcCalibration'
FPS = 30
SPEED = 0.8
PERIOD = 0.8


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned calibration scene already exists; inspect before rerun')
    original = bpy.context.window.scene
    scene = bpy.data.scenes.new(SCENE)
    bpy.context.window.scene = scene
    try:
        scene.unit_settings.system = 'METRIC'
        scene.unit_settings.scale_length = 1
        scene.render.fps = FPS
        scene.frame_start, scene.frame_end = 1, 121
        root = bpy.data.objects.new('RF_NpcCalibration', None)
        scene.collection.objects.link(root)
        arm = bpy.data.objects.new('ARM-npc-calibration', bpy.data.armatures.new('ARM-npc-calibration'))
        scene.collection.objects.link(arm)
        arm.parent = root
        arm.show_in_front = True
        bpy.context.view_layer.objects.active = arm
        arm.select_set(True)
        bpy.ops.object.mode_set(mode='EDIT')
        rest = {
            'root': ((0, 0, 0), (0, 0, .1)),
            'hips': ((0, 0, .86), (0, 0, 1.00)),
            'spine': ((0, 0, 1.00), (0, 0, 1.28)),
            'head': ((0, 0, 1.32), (0, 0, 1.55)),
        }
        for side, sign in [('L', -1), ('R', 1)]:
            x = sign * .13
            rest.update({
                'thigh.' + side: ((x, 0, .86), (x, .09, .47)),
                'shin.' + side: ((x, .09, .47), (x, 0, .08)),
                'foot.' + side: ((x, 0, .08), (x, .2, .08)),
                'upper_arm.' + side: ((sign*.235, 0, 1.25), (sign*.29, 0, 1.00)),
                'forearm.' + side: ((sign*.29, 0, 1.00), (sign*.29, .015, .77)),
                'hand.' + side: ((sign*.29, .015, .77), (sign*.29, .015, .67)),
            })
        for name, (head, tail) in rest.items():
            bone = arm.data.edit_bones.new(name)
            bone.head, bone.tail = head, tail
            if name != 'root': bone.parent = arm.data.edit_bones['root']
        bpy.ops.object.mode_set(mode='OBJECT')
        # Small packed checker proves UV, sRGB base-color and GLB texture portability.
        image = bpy.data.images.new('TEX-npc-calibration-checker', width=32, height=32)
        pixels = []
        for y in range(32):
            for x in range(32):
                pixels.extend((.78, .86, .9, 1) if (x//8 + y//8) % 2 else (.26, .46, .57, 1))
        image.pixels = pixels
        image.pack()
        materials = []
        for name, color, textured in [('cloth', (.36, .65, .73, 1), True), ('joint', (.12, .17, .21, 1), False), ('marker', (.94, .56, .18, 1), False)]:
            mat = bpy.data.materials.new('MAT-npc-calibration-' + name)
            mat.diffuse_color = color
            mat.use_nodes = True
            bsdf = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
            bsdf.inputs['Base Color'].default_value = color
            bsdf.inputs['Roughness'].default_value = .8
            if textured:
                tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
                tex.image = image
                mat.node_tree.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
            materials.append(mat)
        vertices, faces, groups, slots = [], [], [], []

        def box(center, size, bone, mat, rotation=None):
            base = len(vertices)
            for z in (-1, 1):
                for y in (-1, 1):
                    for x in (-1, 1):
                        point = Vector((x*size[0]/2, y*size[1]/2, z*size[2]/2))
                        vertices.append(Vector(center) + (rotation @ point if rotation else point))
                        groups.append(bone)
            for face in [(0,2,3,1),(4,5,7,6),(0,1,5,4),(2,6,7,3),(0,4,6,2),(1,3,7,5)]:
                faces.append(tuple(base+i for i in face))
                slots.append(mat)

        def segment(bone, width, depth, mat):
            a, b = map(Vector, rest[bone])
            rotation = Vector((0, 0, 1)).rotation_difference((b-a).normalized()).to_matrix()
            box((a+b)/2, (width, depth, (b-a).length), bone, mat, rotation)

        box((0, 0, .9), (.32, .22, .16), 'hips', 1)
        box((0, 0, 1.14), (.39, .24, .28), 'spine', 0)
        box((0, 0, 1.44), (.23, .22, .23), 'head', 0)
        # Orange front marker is axis evidence; intentionally no face/identity.
        box((0, .124, 1.17), (.12, .012, .08), 'spine', 2)
        box((0, .115, 1.45), (.1, .012, .035), 'head', 2)
        for side, sign in [('L', -1), ('R', 1)]:
            segment('thigh.' + side, .13, .15, 0)
            segment('shin.' + side, .10, .12, 0)
            box((sign*.13, .04, .04), (.16, .28, .08), 'foot.' + side, 1)
            segment('upper_arm.' + side, .10, .13, 0)
            segment('forearm.' + side, .08, .10, 0)
            segment('hand.' + side, .09, .10, 2)
        mesh = bpy.data.meshes.new('GEO-npc-calibration')
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new('GEO-npc-calibration', mesh)
        scene.collection.objects.link(obj)
        obj.parent = arm
        for mat in materials: mesh.materials.append(mat)
        for poly, slot in zip(mesh.polygons, slots): poly.material_index = slot
        uv = mesh.uv_layers.new(name='UVMap')
        for poly in mesh.polygons:
            for loop, coord in zip(poly.loop_indices, [(0,0),(1,0),(1,1),(0,1)]): uv.data[loop].uv = coord
        for bone in set(groups):
            group = obj.vertex_groups.new(name=bone)
            group.add([i for i, name in enumerate(groups) if name == bone], 1, 'REPLACE')
        modifier = obj.modifiers.new('Baked skeleton only', 'ARMATURE')
        modifier.object = arm

        def pose_bone(name, a, b):
            a, b = Vector(a), Vector(b)
            bone = arm.pose.bones[name]
            rest_bone = arm.data.bones[name]
            q = (rest_bone.tail_local-rest_bone.head_local).normalized().rotation_difference((b-a).normalized())
            bone.matrix = Matrix.Translation(a) @ q.to_matrix().to_4x4() @ rest_bone.matrix_local.to_3x3().to_4x4()
            bone.keyframe_insert('location')
            bone.keyframe_insert('rotation_quaternion')
            bone.keyframe_insert('scale')

        for clip, duration in [('idle', 4.0), ('walk', PERIOD)]:
            action = bpy.data.actions.new(clip)
            arm.animation_data_create()
            arm.animation_data.action = action
            count = round(duration * FPS)
            for frame in range(count + 1):
                scene.frame_set(frame + 1)
                t = frame / FPS
                bob = .006 * math.sin(t*math.tau/4) if clip == 'idle' else .006*math.sin(t*math.tau/PERIOD*2)
                for name in ('hips', 'spine', 'head'):
                    a, b = map(Vector, rest[name])
                    pose_bone(name, a+Vector((0,0,bob)), b+Vector((0,0,bob)))
                for side, sign, phase_offset in [('L', -1, 0), ('R', 1, .5)]:
                    x = sign*.13
                    phase = (t/PERIOD + phase_offset) % 1
                    y, lift = 0, 0
                    if clip == 'walk':
                        if phase <= .5: y = .16 - SPEED * phase * PERIOD
                        else:
                            s = (phase-.5)*2
                            y = -.16 + .32*(3*s*s-2*s*s*s)
                            lift = .075*math.sin(math.pi*s)**2
                    ankle = Vector((x,y,.08+lift))
                    hip = Vector((x,0,.86+bob))
                    delta = ankle-hip
                    length = .405
                    direction = delta.normalized()
                    bend = Vector((0,1,0)) - direction*direction.dot(Vector((0,1,0)))
                    knee = (hip+ankle)/2 + bend.normalized()*math.sqrt(max(0,length**2-(delta.length/2)**2))
                    pose_bone('thigh.'+side, hip, knee)
                    pose_bone('shin.'+side, knee, ankle)
                    pose_bone('foot.'+side, ankle, ankle+Vector((0,.2,0)))
                    swing = .055*math.sin(t*math.tau/PERIOD+phase_offset*math.tau) if clip == 'walk' else .008*math.sin(t*math.tau/4)
                    shoulder = Vector((sign*.235,0,1.25+bob))
                    elbow = Vector((sign*.29,-swing,1.00+bob))
                    wrist = Vector((sign*.29,-swing*1.5+.015,.77+bob))
                    pose_bone('upper_arm.'+side, shoulder, elbow)
                    pose_bone('forearm.'+side, elbow, wrist)
                    pose_bone('hand.'+side, wrist, wrist+Vector((0,0,-.10)))
            for layer in action.layers:
                for strip in layer.strips:
                    for bag in strip.channelbags:
                        for curve in bag.fcurves:
                            for key in curve.keyframe_points: key.interpolation = 'LINEAR'
            track = arm.animation_data.nla_tracks.new()
            track.name = clip
            strip = track.strips.new(clip, 1, action)
            strip.action_slot = arm.animation_data.action_slot
            arm.animation_data.action = None
        for track in arm.animation_data.nla_tracks: track.mute = True
        for bone in arm.pose.bones:
            bone.location = (0,0,0)
            bone.rotation_quaternion = (1,0,0,0)
            bone.scale = (1,1,1)
        scene.frame_set(1)
        bpy.context.view_layer.update()
        bpy.ops.object.select_all(action='DESELECT')
        for node in (root,arm,obj): node.select_set(True)
        path = ROOT / 'game/assets/models/npcs/npc_calibration.glb'
        path.parent.mkdir(parents=True,exist_ok=True)
        bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True,
            use_active_scene=True, export_yup=True, export_animations=True,
            export_animation_mode='NLA_TRACKS', export_force_sampling=True,
            export_frame_step=1, export_anim_slide_to_zero=True, export_cameras=False, export_lights=False,
            export_def_bones=True, export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute = False
        snapshot = ROOT / 'art/source/npc_calibration.blend'
        bpy.data.libraries.write(str(snapshot), {scene}, fake_user=True)
        mesh.calc_loop_triangles()
        report = {'blender':bpy.app.version_string, 'bone_count':len(rest),
            'triangles':len(mesh.loop_triangles),'vertices':len(mesh.vertices),
            'materials':3,'texture_pixels':[32,32],'walk_speed_mps':SPEED,
            'walk_period_seconds':PERIOD,'idle_period_seconds':4.0,
            'source':str(snapshot),'glb':str(path),'glb_bytes':path.stat().st_size,
            'preserved_scene':original.name,'generic_calibration_only':True}
        (ROOT / 'art/exports/npc_calibration.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(report))
    finally:
        bpy.context.window.scene = original


if __name__ == '__main__': build()
