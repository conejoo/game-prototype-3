"""Maris source-informed stylized character. Reuses only N007 rig/animation.

Run via existing Blender MCP. Never modifies the user's scene or calibration.
Maris geometry: mature warm face, brown low braid/gray streak, blue vest, work apron/rope loop.
Unseen back details follow the supplied idle sheet; this is a 3D adaptation.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc03-Maris'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Maris scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc03_Maris'
        arm.name = 'ARM-npc-03'
        arm.data.name = 'ARM-npc-03'
        colors = [
            (.08,.14,.24,1), (.65,.38,.10,1), (.65,.36,.19,1),
            (.12,.06,.03,1), (.27,.15,.07,1), (.65,.63,.54,1),
            (.18,.115,.06,1), (.69,.45,.13,1), (.86,.79,.63,1),
            (.84,.79,.62,1), (.28,.15,.05,1), (.018,.016,.012,1),
            (.18,.105,.045,1), (.40,.13,.08,1), (.43,.24,.12,1)]
        image = bpy.data.images.new('TEX-npc-03-palette', width=32,height=32)
        image.pixels = [c for y in range(32) for x in range(32) for c in colors[min(len(colors)-1,(y//8)*4+x//8)]]
        image.pack()
        mat = bpy.data.materials.new('MAT-npc-03-civic')
        mat.use_nodes = True
        bsdf = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
        bsdf.inputs['Roughness'].default_value = .78
        tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
        tex.image = image
        tex.interpolation = 'Closest'
        mat.node_tree.links.new(tex.outputs['Color'],bsdf.inputs['Base Color'])
        verts, faces, bones, slots = [], [], [], []

        def surface(points, polygons, bone, color):
            offset = len(verts)
            verts.extend(points)
            bones.extend([bone]*len(points))
            faces.extend([tuple(offset+i for i in f) for f in polygons])
            slots.extend([color]*len(polygons))

        def rings(rows, bone, color, count=20):
            # Each row: z, halfwidth, front-depth, center-y. Connected sculpt rings.
            points = [(rx*math.cos(t*math.tau/count),cy+ry*math.sin(t*math.tau/count),z)
                      for z,rx,ry,cy in rows for t in range(count)]
            polygons = [tuple(reversed(range(count)))]
            for row in range(len(rows)-1):
                for i in range(count):
                    polygons.append((row*count+i,row*count+(i+1)%count,(row+1)*count+(i+1)%count,(row+1)*count+i))
            polygons.append(tuple((len(rows)-1)*count+i for i in range(count)))
            surface(points,polygons,bone,color)

        def ellipsoid(center, scale, bone, color, segments=16, latitudes=8):
            # Closed rounded detail with shared poles and coherent normals.
            points=[(center[0],center[1],center[2]-scale[2])]
            for j in range(1,latitudes):
                phi=-math.pi/2+math.pi*j/latitudes
                for i in range(segments):
                    theta=math.tau*i/segments
                    points.append((center[0]+scale[0]*math.cos(phi)*math.cos(theta),center[1]+scale[1]*math.cos(phi)*math.sin(theta),center[2]+scale[2]*math.sin(phi)))
            top=len(points); points.append((center[0],center[1],center[2]+scale[2]))
            polygons=[(0,1+(i+1)%segments,1+i) for i in range(segments)]
            for j in range(latitudes-2):
                for i in range(segments):
                    a=1+j*segments+i; b=1+j*segments+(i+1)%segments
                    polygons.append((a,b,b+segments,a+segments))
            polygons.extend([(top,1+(latitudes-2)*segments+i,1+(latitudes-2)*segments+(i+1)%segments) for i in range(segments)])
            surface(points,polygons,bone,color)

        def tube(path,radius,bone,color,count=8):
            points=[]
            for i,point in enumerate(path):
                direction=Vector(path[min(i+1,len(path)-1)])-Vector(path[max(0,i-1)])
                u=direction.normalized().cross(Vector((0,1,0))).normalized()
                if u.length < .01: u=Vector((1,0,0))
                v=direction.normalized().cross(u).normalized()
                points.extend([Vector(point)+radius*(u*math.cos(j*math.tau/count)+v*math.sin(j*math.tau/count)) for j in range(count)])
            polygons=[tuple(reversed(range(count)))]
            polygons.extend([(i*count+j,i*count+(j+1)%count,(i+1)*count+(j+1)%count,(i+1)*count+j) for i in range(len(path)-1) for j in range(count)])
            polygons.append(tuple((len(path)-1)*count+j for j in range(count)))
            surface(points,polygons,bone,color)

        def patch(points,bone,color):
            # Draped clothing/facial patch, deliberately slightly forward of skin.
            surface(points,[tuple(range(len(points)))],bone,color)

        # Broad work vest with cream open collar and ochre apron bib.
        rings([(.85,.16,.13,0),(.98,.17,.14,0),(1.12,.20,.145,0),(1.23,.247,.128,0),(1.27,.24,.1,0),(1.30,.06,.06,0)],'spine',0)
        patch([(-.077,.151,1.26),(-.05,.16,1.13),(0,.167,1.08),(.05,.16,1.13),(.077,.151,1.26)],'spine',8)
        for sign in [-1,1]:
            patch([(sign*.005,.168,1.264),(sign*.08,.158,1.25),(sign*.085,.17,1.17)],'spine',8)
            tube([(sign*.15,.124,1.23),(sign*.12,.16,1.11),(sign*.115,.161,.91)],.015,'spine',7)
            ellipsoid((sign*.12,.173,1.1),(.014,.005,.016),'spine',1,10,6)
            tube([(sign*.17,-.10,1.25),(-sign*.07,-.142,1.04),(-sign*.15,-.12,.86)],.012,'spine',7)
        patch([(-.122,.17,1.10),(.122,.17,1.10),(.14,.17,.89),(-.14,.17,.89)],'spine',7)
        rings([(.845,.167,.14,0),(.888,.17,.141,0)],'hips',7)
        trouser_ranges = []
        # Trouser legs and short split work-apron tails follow thighs.
        for side,sign in [('L',-1),('R',1)]:
            before=len(verts)
            rings([(.12,.053,.056,0),(.25,.064,.065,0),(.47,.072,.078,0),(.7,.078,.10,0),(.865,.082,.105,0)],'thigh.'+side,6,18)
            trouser_ranges.append((side, before, len(verts)))
            for k in range(before,len(verts)): verts[k]=(verts[k][0]+sign*.11,verts[k][1],verts[k][2])
            patch([(sign*.006,.16,.85),(sign*.155,.16,.85),(sign*.20,.16,.54),(sign*.008,.16,.54)],'thigh.'+side,7)
            tube([(sign*.015,.17,.55),(sign*.177,.17,.55)],.004,'thigh.'+side,1)
        patch([(-.055,.183,.74),(.055,.183,.74),(.055,.183,.65),(-.055,.183,.65)],'hips',7)
        tube([(-.055,.188,.739),(.055,.188,.739)],.004,'hips',1)
        # Rope loop at hip, shaped strands and knot, source-visible identity cue.
        for offset in [-.004,.004]:
            tube([(.154,.158,.87),(.19+offset,.174,.81),(.19+offset,.178,.70),(.16+offset,.178,.65),(.135+offset,.178,.70),(.13+offset,.174,.81),(.154,.158,.87)],.006,'hips',8,8)
        ellipsoid((.154,.178,.863),(.014,.008,.021),'hips',8,10,6)
        # Mature warm face: fuller cheeks, broad nose and small deep-set eyes.
        rings([(1.276,.049,.053,.01),(1.325,.054,.059,.012)],'head',2)
        rings([(1.319,.052,.059,.012),(1.344,.072,.07,.008),(1.375,.095,.082,.002),(1.41,.106,.088,-.002),(1.451,.101,.084,-.008),(1.489,.095,.074,-.015),(1.521,.067,.052,-.019)],'head',2,28)
        surface([(-.012,.088,1.45),(.012,.088,1.45),(-.022,.087,1.403),(.022,.087,1.403),(0,.127,1.411),(-.027,.091,1.399),(.027,.091,1.399)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for sign in [-1,1]:
            ellipsoid((sign*.104,-.007,1.415),(.014,.019,.031),'head',2,12,6)
            ellipsoid((sign*.045,.079,1.438),(.024,.009,.010),'head',9,16,6)
            ellipsoid((sign*.045,.087,1.438),(.009,.003,.008),'head',10,12,6)
            ellipsoid((sign*.045,.090,1.438),(.004,.0015,.005),'head',11,10,5)
            tube([(sign*.022,.088,1.444),(sign*.044,.092,1.449),(sign*.067,.078,1.443)],.004,'head',4)
            tube([(sign*.022,.086,1.459),(sign*.046,.088,1.469),(sign*.076,.061,1.46)],.005,'head',3)
            tube([(sign*.027,.084,1.427),(sign*.046,.085,1.422),(sign*.068,.072,1.429)],.002,'head',14)
            tube([(sign*.024,.095,1.395),(sign*.043,.083,1.376)],.002,'head',14)
        tube([(-.03,.085,1.38),(-.012,.094,1.383),(0,.095,1.38),(.012,.094,1.383),(.03,.085,1.38)],.003,'head',13)
        tube([(-.022,.085,1.376),(0,.09,1.372),(.022,.085,1.376)],.003,'head',14)
        # Wavy side-parted brown hair, gray streak, low coiled braid.
        rings([(1.474,.103,.083,-.025),(1.50,.108,.084,-.023),(1.53,.09,.069,-.025),(1.548,.06,.048,-.025),(1.555,.022,.019,-.025)],'head',3,28)
        ellipsoid((0,-.095,1.398),(.079,.053,.07),'head',3,20,10)
        for i in range(7):
            t=i/6
            tube([(.022,.064-.04*t,1.52+.025*t),(-.028,.081-.035*t,1.52+.024*t),(-.078,.062-.025*t,1.49+.025*t),(-.108,.03-.027*t,1.466+.02*t),(-.105,-.035,1.435+.015*t)],.007,'head',4)
        for i in range(4):
            t=i/3
            tube([(.026,.06-.07*t,1.525+.023*t),(.07,.05-.045*t,1.506+.02*t),(.106,.017,1.471+.018*t),(.103,-.044,1.436)],.006,'head',5 if i<2 else 4)
        for sign in [-1,1]:
            tube([(sign*.082,.056,1.48),(sign*.108,.024,1.448),(sign*.104,-.028,1.406),(sign*.07,-.091,1.355)],.01,'head',3)
            for i in range(4):
                tube([(sign*(.012+i*.015),-.125,1.445),(sign*(.03+i*.012),-.15,1.406),(sign*(.009+i*.014),-.123,1.349)],.008,'head',4)
        # Rolled cream sleeves, exposed work forearms, cuffs/hands and boots.
        for side,sign in [('L',-1),('R',1)]:
            bone=arm.data.bones['upper_arm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.067,'upper_arm.'+side,8,16)
            ellipsoid(tuple(a),(.074,.074,.074),'upper_arm.'+side,8,16,8)
            mid=(a+b)/2; ellipsoid(tuple(mid),(.074,.074,.09),'upper_arm.'+side,8,16,8)
            bone=arm.data.bones['forearm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.044,'forearm.'+side,2,16)
            ellipsoid(tuple(a),(.053,.052,.033),'forearm.'+side,8,16,8)
            ellipsoid((sign*.29,.005,.778),(.034,.039,.027),'hand.'+side,2,12,8)
            ellipsoid((sign*.29,.015,.724),(.036,.035,.05),'hand.'+side,2,12,8)
            ellipsoid((sign*.261,.036,.746),(.017,.021,.028),'hand.'+side,2,10,6)
            before=len(verts)
            rings([(.0,.057,.105,.047),(.025,.065,.12,.045),(.09,.059,.101,.024),(.18,.048,.056,0)],'foot.'+side,12,16)
            for k in range(before,len(verts)): verts[k]=(verts[k][0]+sign*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-03-Maris')
        mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-03-Maris',mesh)
        scene.collection.objects.link(obj); obj.parent=arm
        mesh.materials.append(mat)
        uv=mesh.uv_layers.new(name='UVMap')
        for poly,color in zip(mesh.polygons,slots):
            poly.use_smooth=True
            for index in poly.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
        for bone in set(bones):
            group=obj.vertex_groups.new(name=bone)
            group.add([i for i,b in enumerate(bones) if b==bone],1,'REPLACE')
        # Continuous trouser skin follows knee/shin; boots retain foot weights.
        for side, start, stop in trouser_ranges:
            thigh=obj.vertex_groups['thigh.'+side]
            shin=obj.vertex_groups.get('shin.'+side) or obj.vertex_groups.new(name='shin.'+side)
            for i in range(start,stop):
                lower=max(0,min(1,(.57-verts[i][2])/.18))
                if lower>0:
                    thigh.remove([i])
                    if lower<1: thigh.add([i],1-lower,'REPLACE')
                    shin.add([i],lower,'REPLACE')
        mod=obj.modifiers.new('Exported skin','ARMATURE'); mod.object=arm
        mesh.calc_loop_triangles()
        assert len(mesh.loop_triangles)<=12000
        for track in arm.animation_data.nla_tracks: track.mute=True
        for bone in arm.pose.bones:
            bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
        scene.frame_set(1); bpy.context.view_layer.update()
        bpy.ops.object.select_all(action='DESELECT')
        for node in [root,arm,obj]: node.select_set(True)
        glb=ROOT/'game/assets/models/npcs/npc-03.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-03.blend'
        bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-03','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-03/official-neutral.png','reference/npc-03/npc_03_idle_sheet.png'],
            'identity':'Mature chandlery supplier, full warm face, brown low braid/gray streak, blue vest, cream rolled sleeves, ochre apron/rope loop, brown trousers/boots'}
        (ROOT/'art/exports/npc-03.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(report))
    finally: bpy.context.window.scene=old

if __name__=='__main__': build()
