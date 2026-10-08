"""N016: extend owned named mesh copies, never regenerate or overwrite originals.
Run inside live Blender through the existing MCP. Restore the user's scene.
"""
import bpy, math, json, hashlib
from pathlib import Path
from mathutils import Vector, Matrix
ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')

def build():
    old = bpy.context.window.scene
    reports = []
    try:
        for who, clip in [('01','action_river_fishing'),('02','action_archive_work')]:
            name = f'RF-N016-{who}-Actions'
            assert name not in bpy.data.scenes, 'Open existing action source for edits; do not regenerate'
            with bpy.data.libraries.load(str(ROOT/f'art/source/npc-{who}.blend'),link=False) as (src,dst):
                dst.scenes=[next(n for n in src.scenes if n.startswith('RF-Npc'))]
            scene = dst.scenes[0]
            scene.name = name
            bpy.context.window.scene = scene
            scene.render.fps = 30
            arm = next(o for o in scene.objects if o.type == 'ARMATURE')
            body = next(o for o in scene.objects if o.type == 'MESH')
            root = next(o for o in scene.objects if o.type == 'EMPTY')
            root.name=f'RF_Npc{who}_Actions'; arm.name=f'ARM-npc-{who}-actions'
            body.name=f'GEO-npc-{who}-identity'
            for track in arm.animation_data.nla_tracks: track.mute=True
            arm.animation_data.action=None
            for bone in arm.pose.bones:
                bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
            rest = {b.name:(b.head_local.copy(),b.tail_local.copy()) for b in arm.data.bones}

            def pose(name,a,b,key=True):
                a,b=Vector(a),Vector(b)
                bone=arm.pose.bones[name]; rb=arm.data.bones[name]
                q=(rb.tail_local-rb.head_local).normalized().rotation_difference((b-a).normalized())
                bone.matrix=Matrix.Translation(a) @ q.to_matrix().to_4x4() @ rb.matrix_local.to_3x3().to_4x4()
                if key:
                    for prop in ['location','rotation_quaternion','scale']: bone.keyframe_insert(prop)

            def arm_to(side,wrist,direction,key=True):
                wrist=Vector(wrist); shoulder=rest['upper_arm.'+side][0]
                l1=(rest['upper_arm.'+side][1]-shoulder).length
                l2=(rest['forearm.'+side][1]-rest['forearm.'+side][0]).length
                delta=wrist-shoulder; distance=delta.length; axis=delta.normalized()
                assert abs(l1-l2)<distance<l1+l2
                along=(l1*l1-l2*l2+distance*distance)/(2*distance)
                hint=Vector((-1 if side=='L' else 1,-.3,-.8))
                bend=(hint-axis*hint.dot(axis)).normalized()
                elbow=shoulder+axis*along+bend*math.sqrt(l1*l1-along*along)
                pose('upper_arm.'+side,shoulder,elbow,key)
                pose('forearm.'+side,elbow,wrist,key)
                pose('hand.'+side,wrist,wrist+Vector(direction)*.1,key)

            def frame_pose(t,key=True):
                # Root, soles and torso remain planted. Closed endpoints are authored.
                for bn,(a,b) in rest.items(): pose(bn,a,b,key)
                wave=math.sin(t*math.tau/4); lift=(1-math.cos(t*math.tau/4))*.5
                if who=='01':
                    angle=-.40+1.20*lift
                    direction=Vector((0,math.cos(angle),math.sin(angle)))
                    grip=Vector((.03,.285,1.035))
                    arm_to('R',grip+direction*.05,-direction,key)
                    arm_to('L',grip-direction*.09,-direction,key)
                else:
                    arm_to('L',(-.10,.29,1.04),(0,1,0),key)
                    # Source-informed checking/stroking page; no gameplay effect.
                    arm_to('R',(.11-.08*lift,.26+.04*lift,1.12+.025*wave),(0,1,0),key)
                    a,b=rest['head']; direction=Vector((0,.10*lift,.23))
                    pose('head',a,a+direction.normalized()*(b-a).length,key)

            # Author accessories in action frame 0; inverse-bind onto supporting hand.
            frame_pose(0,False); bpy.context.view_layer.update()
            bind='hand.R' if who=='01' else 'hand.L'
            inverse=arm.data.bones[bind].matrix_local @ arm.pose.bones[bind].matrix.inverted()
            verts=[]; faces=[]; colors=[]
            def box(center,size,color):
                base=len(verts); c=Vector(center)
                for z in [-1,1]:
                    for y in [-1,1]:
                        for x in [-1,1]: verts.append(inverse @ (c+Vector((x*size[0]/2,y*size[1]/2,z*size[2]/2))))
                for f in [(0,2,3,1),(4,5,7,6),(0,1,5,4),(2,6,7,3),(0,4,6,2),(1,3,7,5)]:
                    faces.append(tuple(base+i for i in f)); colors.append(color)
            def tube(a,b,r1,r2,color,n=10):
                a,b=Vector(a),Vector(b); axis=(b-a).normalized()
                u=axis.cross(Vector((1,0,0))).normalized(); v=axis.cross(u)
                base=len(verts)
                for point,radius in [(a,r1),(b,r2)]:
                    for i in range(n): verts.append(inverse @ (point+(u*math.cos(i*math.tau/n)+v*math.sin(i*math.tau/n))*radius))
                for i in range(n): faces.append((base+i,base+(i+1)%n,base+n+(i+1)%n,base+n+i)); colors.append(color)
                faces.extend([tuple(base+i for i in reversed(range(n))),tuple(base+n+i for i in range(n))]); colors.extend([color,color])
            if who=='01':
                grip=Vector((.03,.285,1.035)); direction=Vector((0,math.cos(-.4),math.sin(-.4)))
                tube(grip-direction*.22,grip+direction*.80,.014,.004,3)
                tube(grip-direction*.21,grip-direction*.08,.022,.022,4)
                # Sheet contains rod only: no invented catch/line/reel reward.
            else:
                # Two open page blocks, raised center spine and visible ruled marks.
                for sign in [-1,1]:
                    box((sign*.084,.345,1.080),(.168,.218,.018),3)
                    box((sign*.084,.345,1.094),(.157,.205,.012),2)
                    for row in range(5): box((sign*.086,.286+row*.028,1.101),(.12,.003,.0015),7)
                box((0,.345,1.100),(.009,.218,.016),3)
            mesh=bpy.data.meshes.new(f'GEO-npc-{who}-action-prop')
            mesh.from_pydata(verts,[],faces); mesh.update()
            prop=bpy.data.objects.new('PROP-'+clip,mesh); scene.collection.objects.link(prop)
            prop.parent=arm; mesh.materials.append(body.data.materials[0])
            uv=mesh.uv_layers.new(name='UVMap')
            for polygon,color in zip(mesh.polygons,colors):
                for index in polygon.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
            group=prop.vertex_groups.new(name=bind); group.add(list(range(len(verts))),1,'REPLACE')
            modifier=prop.modifiers.new('Baked hand attachment','ARMATURE'); modifier.object=arm
            action=bpy.data.actions.new(clip); arm.animation_data.action=action
            for frame in range(121):
                scene.frame_set(frame+1); frame_pose(frame/30)
            for layer in action.layers:
                for strip in layer.strips:
                    for bag in strip.channelbags:
                        for curve in bag.fcurves:
                            for point in curve.keyframe_points: point.interpolation='LINEAR'
            track=arm.animation_data.nla_tracks.new(); track.name=clip
            strip=track.strips.new(clip,1,action); strip.action_slot=arm.animation_data.action_slot
            arm.animation_data.action=None
            for track in arm.animation_data.nla_tracks: track.mute=True
            for bone in arm.pose.bones:
                bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
            scene.frame_set(1); bpy.context.view_layer.update()
            bpy.ops.object.select_all(action='DESELECT')
            for o in scene.objects: o.select_set(True)
            glb=ROOT/f'game/assets/models/npcs/npc-{who}-actions.glb'
            bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,
                export_yup=True,export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,
                export_frame_step=1,export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
            for track in arm.animation_data.nla_tracks: track.mute=False
            snapshot=ROOT/f'art/source/npc-{who}-actions.blend'
            bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
            report={'npc_id':f'npc-{who}','clip':clip,'seconds':4,'exposure':'review only','support_bone':bind,
                'original_source_sha256':hashlib.sha256((ROOT/f'art/source/npc-{who}.blend').read_bytes()).hexdigest(),
                'glb':str(glb),'source':str(snapshot),'preserved_scene':old.name,'materials':1,'surfaces':2,'bones':16}
            reports.append(report)
        (ROOT/'art/exports/npc-actions.json').write_text(json.dumps(reports,indent=2)+'\n')
        print(json.dumps(reports))
    finally: bpy.context.window.scene=old

if __name__=='__main__': build()
