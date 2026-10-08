"""Edric source-informed stylized character. Reuses only N007 rig/animation.

Run via existing Blender MCP. Never modifies the user's scene or calibration.
All geometry is authored here: shaped face, swept hair, beard, civic coat/chain.
Unseen back details follow the supplied idle sheet; this is a 3D adaptation.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc01-Edric'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Edric scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc01_Edric'
        arm.name = 'ARM-npc-01'
        arm.data.name = 'ARM-npc-01'
        colors = [
            (0.06,.16,.32,1), (.85,.56,.15,1), (.82,.49,.24,1),
            (.24,.11,.045,1), (.46,.29,.13,1), (.67,.61,.45,1),
            (.08,.115,.09,1), (.07,.08,.085,1), (.85,.79,.58,1),
            (.85,.9,.9,1), (.05,.27,.43,1), (.015,.025,.03,1),
            (.32,.22,.13,1), (.12,.05,.02,1), (.68,.4,.18,1)]
        image = bpy.data.images.new('TEX-npc-01-palette', width=32,height=32)
        image.pixels = [c for y in range(32) for x in range(32) for c in colors[min(len(colors)-1,(y//8)*4+x//8)]]
        image.pack()
        mat = bpy.data.materials.new('MAT-npc-01-civic')
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

        rings([(.78,.18,.125,0),(.90,.18,.13,0),(1.07,.21,.135,0),(1.24,.235,.13,0),(1.29,.18,.115,0)],'spine',0)
        rings([(.90,.155,.133,.012),(1.04,.175,.141,.01),(1.23,.155,.14,.01)],'spine',7)
        patch([(-.08,.153,1.23),(-.065,.155,1.09),(.065,.155,1.09),(.08,.153,1.23)],'spine',8)
        # Cream pointed collar and blue/gold open coat lapels.
        for sign in [-1,1]:
            patch([(sign*.02,.162,1.25),(sign*.095,.156,1.24),(sign*.078,.166,1.15)],'spine',8)
            patch([(sign*.085,.16,1.25),(sign*.165,.135,1.27),(sign*.205,.13,1.14),(sign*.13,.149,.79),(sign*.105,.155,.79)],'spine',0)
            tube([(sign*.092,.166,1.25),(sign*.109,.167,1.12),(sign*.12,.159,.79)],.008,'spine',1)
        # Coat back and split tails are separate from moving knees.
        rings([(.69,.175,.117,-.024),(.84,.19,.126,-.015),(.94,.18,.12,-.015)],'hips',0)
        tube([(-.18,-.08,.70),(0,-.145,.69),(.18,-.08,.70)],.006,'hips',1)
        rings([(.86,.17,.145,0),(.895,.17,.145,0)],'hips',3)
        patch([(-.034,.151,.858),(.034,.151,.858),(.034,.153,.898),(-.034,.153,.898)],'hips',1)
        for z in [.93,1.01,1.085]: ellipsoid((0,.158,z),(.009,.008,.009),'spine',1,8,4)
        # Anatomical head outline: jaw, cheekbones, brow, forehead (not sphere head).
        rings([(1.30,.05,.06,.015),(1.32,.055,.06,.015)],'head',2)
        rings([(1.325,.061,.066,.015),(1.35,.092,.083,.013),(1.39,.109,.088,.008),(1.435,.111,.087,0),(1.47,.104,.083,-.006),(1.50,.098,.076,-.009),(1.53,.079,.058,-.015)],'head',2,24)
        # Integrated angular bridge/tip/nostrils, temples and ears.
        surface([(-.016,.089,1.445),(.016,.089,1.445),(-.022,.092,1.40),(.022,.092,1.40),(0,.132,1.411),(-.026,.099,1.397),(.026,.099,1.397)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for sign in [-1,1]:
            ellipsoid((sign*.109,.0,1.422),(.021,.023,.037),'head',2,12,6)
            ellipsoid((sign*.121,.012,1.423),(.006,.012,.021),'head',14,10,5)
            # Almond eyes conform to cheek; blue iris dark pupil upper brow.
            ellipsoid((sign*.046,.083,1.44),(.030,.014,.013),'head',9,16,6)
            ellipsoid((sign*.046,.096,1.44),(.010,.003,.010),'head',10,12,6)
            ellipsoid((sign*.046,.099,1.44),(.004,.002,.006),'head',11,10,5)
            tube([(sign*.017,.090,1.458),(sign*.042,.099,1.464),(sign*.073,.080,1.457)],.007,'head',3)
            tube([(sign*.022,.097,1.448),(sign*.045,.101,1.451),(sign*.073,.083,1.447)],.003,'head',12)
            tube([(sign*.025,.088,1.416),(sign*.049,.085,1.411),(sign*.072,.072,1.406)],.002,'head',14)
            # Sideburns / salt-and-pepper beard, shaped jaw rather than ball.
            tube([(sign*.097,.039,1.45),(sign*.098,.049,1.4),(sign*.083,.066,1.364),(sign*.047,.081,1.348)],.015,'head',5)
            tube([(sign*.015,.093,1.395),(sign*.038,.101,1.392),(sign*.064,.086,1.386)],.009,'head',3)
        tube([(-.032,.09,1.369),(0,.103,1.35),(.032,.09,1.369)],.014,'head',5)
        tube([(-.027,.102,1.375),(0,.108,1.377),(.027,.102,1.375)],.003,'head',13)
        # Brown combed swept hair volumes with grey temples and visible strand ridges.
        rings([(1.475,.105,.089,-.012),(1.51,.113,.091,-.014),(1.545,.103,.077,-.02),(1.566,.058,.049,-.01)],'head',3,24)
        for i in range(8):
            x=-.083+i*.023
            tube([(x,.05,1.504),(x-.015,.041,1.558),(x+.020,-.003,1.58),(x+.04,-.06,1.541)],.012,'head',4)
        for sign in [-1,1]:
            tube([(sign*.100,.027,1.471),(sign*.108,-.004,1.506),(sign*.093,-.05,1.525)],.012,'head',5)
        # Civic chain: actual linked loops and central medallion, not painted label.
        for i in range(13):
            t=i/12
            x=-.19+.38*t
            z=1.22-.17*math.sin(math.pi*t)
            y=.141+.025*math.sin(math.pi*t)
            path=[(x+.010*math.cos(a*math.tau/8),y+.004*math.sin(a*math.tau/8),z+.017*math.sin(a*math.tau/8)) for a in range(9)]
            tube(path,.004,'spine',1,6)
        ellipsoid((0,.17,1.0),(.04,.009,.046),'spine',1,20,6)
        tube([(0,.183,.974),(0,.183,1.03)],.003,'spine',3,6)
        for sign in [-1,1]:
            tube([(0,.183,.986),(sign*.019,.183,1.002)],.003,'spine',3,6)
        # Tapered clothed limbs, rounded boot toes / cuffs; bind to reusable bones.
        for side,sign in [('L',-1),('R',1)]:
            for part,radius,color in [('thigh',.067,6),('shin',.058,6),('upper_arm',.065,0),('forearm',.052,0)]:
                bone=arm.data.bones[part+'.'+side]
                a,b=bone.head_local,bone.tail_local
                tube([a,b],radius,part+'.'+side,color,12)
                ellipsoid(tuple(a),(radius,radius,radius),part+'.'+side,color,12,6)
            ellipsoid((sign*.29,.015,.724),(.046,.043,.060),'hand.'+side,2,12,8)
            ellipsoid((sign*.255,.038,.746),(.022,.026,.035),'hand.'+side,2,10,6)
            tube([(sign*.29,.013,.81),(sign*.29,.015,.775)],.056,'forearm.'+side,1,12)
            # Boots use truncated rings so all sole vertices are exactly ground-zero.
            rings_local=[(.0,.065,.12,.054),(.025,.073,.14,.045),(.09,.065,.12,.03),(.12,.052,.067,0)]
            before=len(verts); rings(rings_local,'foot.'+side,3,16)
            for k in range(before,len(verts)): verts[k]=(verts[k][0]+sign*.13,verts[k][1],verts[k][2])
            bone=arm.data.bones['shin.'+side]
            tube([(sign*.13,.015,.11),(sign*.13,.035,.26)],.060,'shin.'+side,3,12)
            tube([(sign*.13,.04,.255),(sign*.13,.04,.28)],.063,'shin.'+side,4,12)
        mesh=bpy.data.meshes.new('GEO-npc-01-Edric')
        mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-01-Edric',mesh)
        scene.collection.objects.link(obj); obj.parent=arm
        mesh.materials.append(mat)
        uv=mesh.uv_layers.new(name='UVMap')
        for poly,color in zip(mesh.polygons,slots):
            poly.use_smooth=True
            for index in poly.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
        for bone in set(bones):
            group=obj.vertex_groups.new(name=bone)
            group.add([i for i,b in enumerate(bones) if b==bone],1,'REPLACE')
        mod=obj.modifiers.new('Exported skin','ARMATURE'); mod.object=arm
        mesh.calc_loop_triangles()
        assert len(mesh.loop_triangles)<=12000
        for track in arm.animation_data.nla_tracks: track.mute=True
        for bone in arm.pose.bones:
            bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
        scene.frame_set(1); bpy.context.view_layer.update()
        bpy.ops.object.select_all(action='DESELECT')
        for node in [root,arm,obj]: node.select_set(True)
        glb=ROOT/'game/assets/models/npcs/npc-01.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-01.blend'
        bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-01','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-01/official-neutral.png','reference/npc-01/npc_01_idle_sheet.png'],
            'identity':'middle-aged swept brown/grey hair, trimmed beard, blue civic coat/gold trim, cream collar, chain/leaf medallion, green trousers/brown boots'}
        (ROOT/'art/exports/npc-01.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(report))
    finally: bpy.context.window.scene=old

if __name__=='__main__': build()
