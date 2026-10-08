"""Ivo Oran's source-informed stylized captain skin; existing MCP only.

Helper topology and planted clips reuse the delivered pipeline. All costume,
face, beanie and hair geometry below is authored for Ivo's public references.
Creates one owned scene, preserves the artist's active scene and source file.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc07-Ivo'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Ivo scene exists; inspect before rebuilding')
    old = bpy.context.window.scene
    with bpy.data.libraries.load(str(ROOT/'art/source/npc_calibration.blend')) as (src, dst):
        dst.scenes = ['RF-NpcCalibration']
    scene = dst.scenes[0]
    scene.name = SCENE
    bpy.context.window.scene = scene
    try:
        root = next(o for o in scene.objects if o.type == 'EMPTY')
        arm = next(o for o in scene.objects if o.type == 'ARMATURE')
        for obj in list(scene.objects):
            if obj.type == 'MESH': bpy.data.objects.remove(obj, do_unlink=True)
        root.name = 'RF_Npc07_Ivo'
        arm.name = arm.data.name = 'ARM-npc-07'
        colors = [(.06,.095,.16,1),(.58,.37,.13,1),(.71,.40,.20,1),
                  (.07,.045,.026,1),(.19,.14,.08,1),(.12,.17,.24,1),
                  (.21,.105,.05,1),(.07,.23,.24,1),(.82,.58,.23,1),
                  (.81,.81,.69,1),(.22,.14,.05,1),(.012,.009,.007,1),
                  (.17,.075,.035,1),(.38,.16,.09,1),(.53,.28,.12,1)]
        image=bpy.data.images.new('TEX-npc-07-palette',width=32,height=32)
        image.pixels=[c for y in range(32) for x in range(32) for c in colors[min(14,(y//8)*4+x//8)]]
        image.pack()
        mat=bpy.data.materials.new('MAT-npc-07-captain')
        mat.use_nodes=True
        bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
        bsdf.inputs['Roughness'].default_value=.82
        tex=mat.node_tree.nodes.new('ShaderNodeTexImage'); tex.image=image; tex.interpolation='Closest'
        mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
        verts,faces,bones,slots=[],[],[],[]

        def surface(points,polygons,bone,color):
            offset=len(verts); verts.extend(points); bones.extend([bone]*len(points))
            faces.extend([tuple(offset+i for i in f) for f in polygons]); slots.extend([color]*len(polygons))

        def rings(rows,bone,color,count=24):
            points=[(rx*math.cos(t*math.tau/count),cy+ry*math.sin(t*math.tau/count),z)
                    for z,rx,ry,cy in rows for t in range(count)]
            polygons=[tuple(reversed(range(count)))]
            polygons.extend([(r*count+i,r*count+(i+1)%count,(r+1)*count+(i+1)%count,(r+1)*count+i)
                             for r in range(len(rows)-1) for i in range(count)])
            polygons.append(tuple((len(rows)-1)*count+i for i in range(count)))
            surface(points,polygons,bone,color)

        def ellipsoid(center,scale,bone,color,segments=16,latitudes=8):
            points=[(center[0],center[1],center[2]-scale[2])]
            for j in range(1,latitudes):
                phi=-math.pi/2+math.pi*j/latitudes
                for i in range(segments):
                    theta=math.tau*i/segments
                    points.append((center[0]+scale[0]*math.cos(phi)*math.cos(theta),center[1]+scale[1]*math.cos(phi)*math.sin(theta),center[2]+scale[2]*math.sin(phi)))
            top=len(points); points.append((center[0],center[1],center[2]+scale[2]))
            polygons=[(0,1+(i+1)%segments,1+i) for i in range(segments)]
            polygons.extend([(1+j*segments+i,1+j*segments+(i+1)%segments,1+(j+1)*segments+(i+1)%segments,1+(j+1)*segments+i)
                             for j in range(latitudes-2) for i in range(segments)])
            polygons.extend([(top,1+(latitudes-2)*segments+i,1+(latitudes-2)*segments+(i+1)%segments) for i in range(segments)])
            surface(points,polygons,bone,color)

        def tube(path,radius,bone,color,count=8):
            points=[]
            for i,point in enumerate(path):
                direction=Vector(path[min(i+1,len(path)-1)])-Vector(path[max(0,i-1)])
                u=direction.normalized().cross(Vector((0,1,0))).normalized()
                if u.length<.01: u=Vector((1,0,0))
                v=direction.normalized().cross(u).normalized()
                points.extend([Vector(point)+radius*(u*math.cos(j*math.tau/count)+v*math.sin(j*math.tau/count)) for j in range(count)])
            polygons=[tuple(reversed(range(count)))]
            polygons.extend([(i*count+j,i*count+(j+1)%count,(i+1)*count+(j+1)%count,(i+1)*count+j) for i in range(len(path)-1) for j in range(count)])
            polygons.append(tuple((len(path)-1)*count+j for j in range(count)))
            surface(points,polygons,bone,color)

        def patch(points,bone,color): surface(points,[tuple(range(len(points)))],bone,color)

        # Tailored navy waistcoat over ochre open-neck shirt, source split lapels.
        rings([(.84,.171,.132,0),(.96,.175,.142,0),(1.13,.199,.15,0),(1.23,.223,.132,0),(1.263,.17,.11,0),(1.29,.063,.060,0)],'spine',0)
        patch([(-.1,.152,1.269),(-.075,.163,1.11),(0,.17,1.075),(.075,.163,1.11),(.1,.152,1.269)],'spine',8)
        for s in [-1,1]:
            patch([(s*.024,.176,1.27),(s*.108,.155,1.27),(s*.088,.18,1.16)],'spine',8)
            patch([(s*.105,.166,1.26),(s*.18,.135,1.245),(s*.10,.174,1.07),(s*.069,.181,1.13)],'spine',0)
            tube([(s*.1,.174,1.25),(s*.083,.186,1.17),(s*.015,.183,1.07)],.004,'spine',5)
        # Teal knotted neckerchief, deliberately distinct from Harlan's scarf.
        tube([(-.054,.036,1.30),(-.059,.09,1.273),(0,.184,1.225),(.059,.09,1.273),(.054,.036,1.30)],.022,'spine',7)
        ellipsoid((0,.206,1.217),(.024,.014,.020),'spine',7,12,6)
        patch([(-.016,.215,1.21),(-.051,.201,1.13),(-.027,.209,1.03),(.007,.211,1.135)],'spine',7)
        patch([(.016,.216,1.21),(.043,.207,1.12),(.027,.208,1.00),(-.009,.212,1.135)],'spine',7)
        for z in [.90,.966,1.032]: ellipsoid((0,.151,z),(.010,.007,.010),'spine',1,10,6)
        rings([(.832,.17,.136,0),(.866,.173,.14,0)],'hips',12)
        patch([(-.027,.146,.836),(.027,.146,.836),(.027,.147,.862),(-.027,.147,.862)],'hips',1)
        # Rear adjustable waistcoat strap visible in original north-facing sheet.
        patch([(-.116,-.143,.91),(.116,-.143,.91),(.116,-.145,.951),(-.116,-.145,.951)],'spine',5)
        ellipsoid((0,-.151,.932),(.016,.004,.013),'spine',1,10,6)
        # Continuous tailored trousers blend across knees to avoid segment gaps.
        trouser_ranges=[]
        for side,s in [('L',-1),('R',1)]:
            start=len(verts)
            rings([(.12,.053,.056,0),(.25,.067,.068,0),(.47,.076,.081,0),(.70,.08,.105,0),(.866,.089,.11,0)],'thigh.'+side,6,20)
            trouser_ranges.append((side,start,len(verts)))
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.11,verts[k][1],verts[k][2])
        # Ivo's lean clean-shaven warm face, prominent nose, swept dark curls.
        rings([(1.28,.054,.058,.009),(1.34,.058,.064,.01)],'head',2)
        rings([(1.32,.052,.06,.014),(1.348,.077,.075,.012),(1.38,.101,.083,.006),(1.422,.112,.092,0),(1.465,.106,.085,-.007),(1.507,.10,.077,-.012),(1.542,.069,.05,-.012)],'head',2,28)
        surface([(-.013,.09,1.466),(.013,.09,1.466),(-.023,.101,1.412),(.023,.101,1.412),(0,.143,1.416),(-.026,.11,1.401),(.026,.11,1.401)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for s in [-1,1]:
            ellipsoid((s*.11,-.005,1.422),(.019,.023,.034),'head',2,12,6)
            ellipsoid((s*.115,.005,1.421),(.009,.013,.023),'head',14,12,6)
            ellipsoid((s*.047,.086,1.453),(.023,.007,.009),'head',9,16,6)
            ellipsoid((s*.047,.092,1.453),(.008,.002,.007),'head',10,12,6)
            ellipsoid((s*.047,.094,1.453),(.004,.0015,.005),'head',11,10,5)
            tube([(s*.023,.093,1.463),(s*.046,.097,1.469),(s*.076,.08,1.459)],.004,'head',3)
            tube([(s*.019,.095,1.48),(s*.047,.098,1.485),(s*.079,.067,1.477)],.007,'head',3)
            tube([(s*.026,.1,1.435),(s*.049,.094,1.429),(s*.078,.069,1.432)],.002,'head',14)
            tube([(s*.103,.023,1.47),(s*.111,-.005,1.504),(s*.096,-.052,1.526)],.008,'head',3)
        tube([(-.033,.086,1.377),(0,.097,1.375),(.033,.086,1.379)],.003,'head',13)
        # Beanie has rounded crown, thick folded ribbed brim; curls emerge at front.
        rings([(1.509,.113,.089,-.017),(1.541,.115,.092,-.017),(1.57,.099,.084,-.016),(1.593,.07,.062,-.014),(1.604,.022,.02,-.014)],'head',0,32)
        rings([(1.499,.113,.089,-.016),(1.509,.119,.095,-.016),(1.539,.118,.094,-.016),(1.545,.112,.089,-.016)],'head',5,32)
        for i in range(32):
            a=math.tau*i/32
            tube([(.119*math.cos(a),-.016+.095*math.sin(a),1.508),(.118*math.cos(a),-.016+.094*math.sin(a),1.539)],.0018,'head',0,6)
        for x,z in [(-.075,1.505),(-.045,1.519),(-.012,1.515),(.02,1.509)]:
            tube([(x+.015,.073,z+.012),(x,.091,z),(x-.006,.086,z-.016)],.008,'head',3,10)
        for side,s in [('L',-1),('R',1)]:
            # Continuous ochre shoulder yoke overlaps both torso and sleeve cap.
            ellipsoid((s*.204,0,1.24),(.085,.075,.061),'spine',8,16,8)
            bone=arm.data.bones['upper_arm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.070,'upper_arm.'+side,8,16)
            ellipsoid(tuple(a),(.066,.068,.064),'upper_arm.'+side,8,16,8)
            mid=(a+b)/2; ellipsoid(tuple(mid),(.071,.072,.083),'upper_arm.'+side,8,16,8)
            bone=arm.data.bones['forearm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.047,'forearm.'+side,2,16)
            ellipsoid(tuple(a),(.057,.055,.037),'forearm.'+side,8,16,8)
            ellipsoid((s*.29,.005,.778),(.037,.041,.029),'hand.'+side,2,12,8)
            ellipsoid((s*.29,.015,.723),(.04,.038,.054),'hand.'+side,2,12,8)
            ellipsoid((s*.257,.038,.746),(.019,.023,.029),'hand.'+side,2,10,6)
            start=len(verts)
            rings([(.0,.061,.11,.047),(.025,.069,.126,.045),(.09,.063,.105,.024),(.18,.049,.058,0)],'foot.'+side,12,16)
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-07-Ivo'); mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-07-Ivo',mesh); scene.collection.objects.link(obj); obj.parent=arm
        mesh.materials.append(mat); uv=mesh.uv_layers.new(name='UVMap')
        for poly,color in zip(mesh.polygons,slots):
            poly.use_smooth=True
            for index in poly.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
        for bone in set(bones):
            group=obj.vertex_groups.new(name=bone); group.add([i for i,b in enumerate(bones) if b==bone],1,'REPLACE')
        for side,start,stop in trouser_ranges:
            thigh=obj.vertex_groups['thigh.'+side]
            shin=obj.vertex_groups.get('shin.'+side) or obj.vertex_groups.new(name='shin.'+side)
            for i in range(start,stop):
                lower=max(0,min(1,(.57-verts[i][2])/.18))
                if lower>0:
                    thigh.remove([i])
                    if lower<1: thigh.add([i],1-lower,'REPLACE')
                    shin.add([i],lower,'REPLACE')
        mod=obj.modifiers.new('Exported skin','ARMATURE'); mod.object=arm
        mesh.calc_loop_triangles(); assert 4000<=len(mesh.loop_triangles)<=12000
        for track in arm.animation_data.nla_tracks: track.mute=True
        for bone in arm.pose.bones:
            bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
        scene.frame_set(1); bpy.context.view_layer.update(); bpy.ops.object.select_all(action='DESELECT')
        for node in [root,arm,obj]: node.select_set(True)
        glb=ROOT/'game/assets/models/npcs/npc-07.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-07.blend'; bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-07','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-07/official-neutral.png','reference/npc-07/npc_07_idle_sheet.png'],
            'identity':'39-year-old river-run captain, lean clean-shaven face, swept dark curls/navy ribbed beanie, navy tailored waistcoat, teal knotted scarf, rolled ochre shirt, brown trousers/boots'}
        (ROOT/'art/exports/npc-07.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report))
    finally: bpy.context.window.scene=old


if __name__=='__main__': build()
