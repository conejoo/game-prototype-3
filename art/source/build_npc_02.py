"""Helena source-informed stylized character. Reuses only N007 rig/animation.

Run via existing Blender MCP. Never modifies the user's scene or calibration.
Helena geometry: mature face, pinned auburn hair, green vest/skirt, key pendant.
Unseen back details follow the supplied idle sheet; this is a 3D adaptation.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc02-Helena'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Helena scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc02_Helena'
        arm.name = 'ARM-npc-02'
        arm.data.name = 'ARM-npc-02'
        colors = [
            (.065,.19,.13,1), (.65,.38,.10,1), (.84,.52,.29,1),
            (.27,.095,.025,1), (.49,.23,.06,1), (.72,.67,.49,1),
            (.095,.20,.12,1), (.055,.065,.06,1), (.89,.81,.62,1),
            (.86,.88,.79,1), (.23,.31,.13,1), (.02,.025,.02,1),
            (.34,.19,.07,1), (.35,.095,.045,1), (.61,.33,.17,1)]
        image = bpy.data.images.new('TEX-npc-02-palette', width=32,height=32)
        image.pixels = [c for y in range(32) for x in range(32) for c in colors[min(len(colors)-1,(y//8)*4+x//8)]]
        image.pack()
        mat = bpy.data.materials.new('MAT-npc-02-civic')
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

        # Fitted green waistcoat, shaped shoulder/waist, cream blouse collar.
        rings([(.85,.14,.12,0),(.94,.145,.125,0),(1.08,.18,.14,0),(1.22,.235,.13,0),(1.26,.23,.10,0),(1.28,.065,.065,0)],'spine',0)
        patch([(-.075,.151,1.25),(-.052,.162,1.11),(0,.161,1.03),(.052,.162,1.11),(.075,.151,1.25)],'spine',8)
        for sign in [-1,1]:
            patch([(sign*.01,.164,1.265),(sign*.076,.163,1.25),(sign*.071,.174,1.18)],'spine',8)
            tube([(sign*.09,.156,1.26),(sign*.10,.163,1.15),(sign*.014,.159,.94)],.006,'spine',1)
            tube([(sign*.183,.09,1.23),(sign*.197,.01,1.27),(sign*.181,-.09,1.23)],.006,'spine',1)
        for z in [1.12,1.18]: ellipsoid((0,.165,z),(.006,.006,.007),'spine',1,8,4)
        rings([(.84,.155,.128,0),(.88,.155,.128,0)],'hips',12)
        patch([(-.029,.136,.844),(.029,.136,.844),(.029,.137,.881),(-.029,.137,.881)],'hips',1)
        # Split tailored skirt panels each follow thigh, not rigid skirt over knees.
        for side,sign in [('L',-1),('R',1)]:
            before=len(verts)
            rings([(.17,.11,.13,0),(.25,.115,.14,0),(.49,.105,.13,0),(.72,.09,.12,0),(.86,.08,.12,0)],'thigh.'+side,6,20)
            for k in range(before,len(verts)): verts[k]=(verts[k][0]+sign*.105,verts[k][1],verts[k][2])
            tube([(sign*.16,.106,.2),(sign*.159,.117,.45),(sign*.134,.117,.69),(sign*.11,.119,.84)],.004,'thigh.'+side,1)
            tube([(sign*.04,.112,.2),(sign*.04,.13,.46),(sign*.04,.115,.8)],.003,'thigh.'+side,0)
        # Narrow jaw, angular cheeks, long nose, mature brow/lids, no beard.
        rings([(1.275,.047,.052,.01),(1.325,.05,.056,.01)],'head',2)
        rings([(1.32,.048,.052,.014),(1.345,.063,.066,.015),(1.375,.084,.076,.009),(1.41,.102,.083,0),(1.455,.098,.079,-.005),(1.49,.089,.071,-.01),(1.525,.066,.05,-.015)],'head',2,28)
        surface([(-.011,.083,1.451),(.011,.083,1.451),(-.017,.083,1.405),(.017,.083,1.405),(0,.12,1.41),(-.023,.086,1.401),(.023,.086,1.401)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for sign in [-1,1]:
            ellipsoid((sign*.1,0,1.419),(.015,.019,.031),'head',2,12,6)
            ellipsoid((sign*.105,.01,1.419),(.005,.009,.017),'head',14,10,5)
            ellipsoid((sign*.043,.077,1.44),(.027,.012,.011),'head',9,16,6)
            ellipsoid((sign*.043,.088,1.44),(.009,.003,.009),'head',10,12,6)
            ellipsoid((sign*.043,.091,1.44),(.004,.002,.005),'head',11,10,5)
            tube([(sign*.019,.087,1.446),(sign*.043,.092,1.452),(sign*.068,.075,1.447)],.004,'head',12)
            tube([(sign*.019,.082,1.459),(sign*.043,.086,1.469),(sign*.071,.068,1.463)],.005,'head',3)
            tube([(sign*.025,.083,1.43),(sign*.045,.085,1.425),(sign*.068,.072,1.43)],.002,'head',14)
            tube([(sign*.066,.049,1.4),(sign*.052,.069,1.382)],.0015,'head',14)
        tube([(-.027,.083,1.382),(-.009,.091,1.385),(0,.092,1.381),(.009,.091,1.385),(.027,.083,1.382)],.003,'head',13)
        tube([(-.021,.083,1.378),(0,.088,1.375),(.021,.083,1.378)],.003,'head',14)
        # Hair cap follows skull, swept part and low pinned braided bun.
        rings([(1.47,.1,.082,-.021),(1.50,.105,.082,-.018),(1.528,.095,.073,-.018),(1.55,.066,.05,-.02),(1.558,.028,.023,-.019)],'head',3,28)
        ellipsoid((0,-.086,1.424),(.086,.054,.061),'head',3,20,10)
        # Asymmetric side part: swept curved locks conform to cap, no upright comb.
        for i in range(7):
            t=i/6
            tube([(.024,.058-.038*t,1.523+.024*t),(-.022,.078-.035*t,1.52+.025*t),(-.073,.06-.03*t,1.498+.029*t),(-.102,.025-.028*t,1.48+.021*t),(-.096,-.034,1.454+.016*t)],.007,'head',4)
        for i in range(5):
            t=i/4
            tube([(.028,.05-.06*t,1.526+.025*t),(.067,.05-.068*t,1.524+.012*t),(.1,.016-.043*t,1.489+.015*t),(.092,-.05,1.468)],.006,'head',4)
        for sign in [-1,1]:
            tube([(sign*.073,.067,1.49),(sign*.098,.041,1.471),(sign*.105,.019,1.447),(sign*.096,-.019,1.411),(sign*.074,-.071,1.397)],.011,'head',3)
            tube([(sign*.082,.045,1.474),(sign*.113,.015,1.423),(sign*.101,.053,1.397)],.004,'head',4)
            for i in range(4):
                tube([(sign*(.015+i*.017),-.126,1.467),(sign*(.029+i*.014),-.14,1.434),(sign*(.008+i*.019),-.116,1.401)],.008,'head',4)
        tube([(-.045,-.139,1.441),(.045,-.139,1.451)],.004,'head',1)
        # Source key pendant: lobed bow, shaft and two teeth. No work prop/action.
        tube([(-.1,.167,1.22),(0,.181,1.036),(.1,.167,1.22)],.003,'spine',1)
        for sign in [-1,1]:
            path=[(sign*.012+.012*math.cos(i*math.tau/12),.181,1.022+.012*math.sin(i*math.tau/12)) for i in range(13)]
            tube(path,.003,'spine',1,6)
        tube([(0,.181,1.018),(0,.181,.942),(.025,.181,.942)],.004,'spine',1,6)
        tube([(0,.181,.958),(.017,.181,.958)],.004,'spine',1,6)
        # Cream puff sleeves, dark fitted cross-stitched bracers, bare hands/boots.
        for side,sign in [('L',-1),('R',1)]:
            for part,radius,color in [('upper_arm',.072,8),('forearm',.047,7)]:
                bone=arm.data.bones[part+'.'+side]
                a,b=bone.head_local,bone.tail_local
                tube([a,b],radius,part+'.'+side,color,16)
                ellipsoid(tuple(a),(radius,radius,radius),part+'.'+side,color,16,8)
            bone=arm.data.bones['upper_arm.'+side]
            mid=(bone.head_local+bone.tail_local)/2
            ellipsoid(tuple(mid),(.078,.079,.105),'upper_arm.'+side,8,16,8)
            for z in [.815,.85,.9]:
                tube([(sign*.265,.027,z),(sign*.30,.054,z+.035)],.003,'forearm.'+side,12,6)
                tube([(sign*.3,.027,z),(sign*.265,.054,z+.035)],.003,'forearm.'+side,12,6)
            ellipsoid((sign*.29,.015,.724),(.036,.035,.05),'hand.'+side,2,12,8)
            ellipsoid((sign*.261,.036,.746),(.017,.021,.028),'hand.'+side,2,10,6)
            before=len(verts)
            rings([(.0,.057,.105,.047),(.025,.065,.12,.045),(.09,.059,.101,.024),(.14,.046,.054,0)],'foot.'+side,12,16)
            for k in range(before,len(verts)): verts[k]=(verts[k][0]+sign*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-02-Helena')
        mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-02-Helena',mesh)
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
        glb=ROOT/'game/assets/models/npcs/npc-02.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-02.blend'
        bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-02','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-02/official-neutral.png','reference/npc-02/npc_02_idle_sheet.png'],
            'identity':'50-year-old archivist, angular mature face, auburn pinned hair/bun, fitted green vest/split skirt, cream puff sleeves, dark stitched bracers, key pendant/brown boots'}
        (ROOT/'art/exports/npc-02.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(report))
    finally: bpy.context.window.scene=old

if __name__=='__main__': build()
