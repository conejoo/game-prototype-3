"""Tess Reed's source-informed stylized shopkeeper skin; existing MCP only.

Helper topology and planted clips reuse the delivered pipeline. All costume,
face, apron and hair geometry below is authored for Tess's public references.
Creates one owned scene, preserves the artist's active scene and source file.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc06-Tess'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Tess scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc06_Tess'
        arm.name = arm.data.name = 'ARM-npc-06'
        colors = [(.22,.29,.16,1),(.56,.36,.12,1),(.70,.42,.24,1),
                  (.19,.095,.045,1),(.36,.20,.095,1),(.48,.30,.15,1),
                  (.25,.15,.075,1),(.50,.19,.095,1),(.86,.80,.65,1),
                  (.85,.86,.76,1),(.27,.14,.055,1),(.02,.014,.008,1),
                  (.22,.12,.055,1),(.49,.21,.13,1),(.56,.30,.18,1)]
        image=bpy.data.images.new('TEX-npc-06-palette',width=32,height=32)
        image.pixels=[c for y in range(32) for x in range(32) for c in colors[min(14,(y//8)*4+x//8)]]
        image.pack()
        mat=bpy.data.materials.new('MAT-npc-06-shopkeeper')
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

        # Shaped green waistcoat over open cream collar, broad rust apron.
        vest_rows=[(.85,.165,.12,0),(.98,.174,.13,0),(1.12,.191,.144,0),(1.22,.222,.132,0),(1.26,.166,.103,0),(1.29,.061,.06,0)]
        rings(vest_rows,'spine',0)
        def vest_front(x,z,lift=.007):
            low,high=next((a,b) for a,b in zip(vest_rows,vest_rows[1:]) if a[0]<=z<=b[0])
            t=(z-low[0])/(high[0]-low[0])
            rx=low[1]*(1-t)+high[1]*t; ry=low[2]*(1-t)+high[2]*t
            return (x,ry*math.sqrt(max(0,1-(x/rx)**2))+lift,z)
        # Tessellated shirt follows curved torso; large flat decal polygons would
        # sink through its convex surface despite correctly fitted boundary points.
        shirt_rows=[(1.108,.003),(1.15,.034),(1.19,.056),(1.23,.077),(1.26,.086),(1.276,.055)]
        shirt_points=[vest_front(w*t,z) for z,w in shirt_rows for t in [-1,-.5,0,.5,1]]
        shirt_faces=[(row*5+i,row*5+i+1,(row+1)*5+i+1,(row+1)*5+i) for row in range(len(shirt_rows)-1) for i in range(4)]
        surface(shirt_points,shirt_faces,'spine',8)
        for sign in [-1,1]:
            tube([vest_front(sign*.085,1.26,.01),vest_front(sign*.060,1.21,.01),vest_front(sign*.025,1.14,.01)],.004,'spine',0)
            tube([(sign*.127,.069,1.26),(sign*.143,.116,1.16),(sign*.131,.114,1.04)],.012,'spine',7)
        ellipsoid((0,.152,1.106),(.011,.006,.012),'spine',1,12,6)
        # Apron is fitted separate mesh surface with finite thick side/back hem.
        rings([(.70,.153,.137,.011),(.78,.178,.148,.006),(.93,.175,.146,.006),(1.01,.166,.144,.006)],'hips',7,28)
        patch([(-.135,.148,1.045),(.135,.148,1.045),(.15,.150,.91),(-.15,.150,.91)],'spine',7)
        patch([(.04,.158,1.015),(.117,.158,1.015),(.12,.158,.942),(.044,.158,.942)],'spine',13)
        tube([(.077,.163,.986),(.087,.163,1.04)],.0035,'spine',11)
        tube([(.094,.163,.986),(.104,.163,1.035)],.003,'spine',1)
        tube([(-.16,-.13,.975),(0,-.155,.968),(.16,-.13,.975)],.008,'hips',7)
        for sign in [-1,1]:
            patch([(0,-.16,.975),(sign*.046,-.17,.99),(sign*.042,-.17,.955)],'hips',7)
            tube([(sign*.01,-.162,.97),(sign*.032,-.17,.91),(sign*.025,-.17,.865)],.009,'hips',7)
        # Continuous tapered trousers preserve knee blending.
        trouser_ranges=[]
        for side,s in [('L',-1),('R',1)]:
            start=len(verts)
            rings([(.12,.053,.056,0),(.25,.067,.068,0),(.47,.076,.081,0),(.70,.08,.105,0),(.866,.089,.11,0)],'thigh.'+side,6,20)
            trouser_ranges.append((side,start,len(verts)))
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.11,verts[k][1],verts[k][2])
        # Mature oval face, cheek planes, shaped nose and conforming eye/lid layers.
        rings([(1.28,.052,.057,.01),(1.345,.054,.062,.008)],'head',2)
        rings([(1.325,.051,.058,.01),(1.35,.074,.068,.006),(1.387,.105,.078,0),(1.43,.113,.084,-.006),(1.467,.107,.078,-.011),(1.509,.093,.071,-.014),(1.54,.069,.05,-.015)],'head',2,28)
        surface([(-.012,.08,1.46),(.012,.08,1.46),(-.020,.085,1.406),(.020,.085,1.406),(0,.119,1.418),(-.026,.089,1.403),(.026,.089,1.403)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for sign in [-1,1]:
            ellipsoid((sign*.112,-.004,1.427),(.017,.018,.030),'head',2,12,6)
            ellipsoid((sign*.045,.078,1.448),(.023,.008,.010),'head',9,16,6)
            ellipsoid((sign*.045,.085,1.448),(.008,.002,.008),'head',10,12,6)
            ellipsoid((sign*.045,.087,1.448),(.004,.001,.006),'head',11,10,5)
            tube([(sign*.022,.086,1.452),(sign*.044,.089,1.46),(sign*.068,.079,1.451)],.004,'head',3)
            tube([(sign*.023,.083,1.474),(sign*.048,.086,1.481),(sign*.075,.067,1.473)],.006,'head',3)
            tube([(sign*.024,.086,1.434),(sign*.047,.086,1.43),(sign*.073,.065,1.432)],.0018,'head',14)
        tube([(-.026,.088,1.382),(0,.094,1.377),(.026,.088,1.386)],.004,'head',13)
        # Wavy chin-length chestnut bob. Forehead part and layered curls vary by side.
        rings([(1.492,.114,.092,-.026),(1.525,.117,.083,-.026),(1.557,.085,.065,-.024),(1.569,.035,.03,-.021)],'head',3,28)
        for sign in [-1,1]:
            for j in range(5):
                cy=-.085+j*.025
                x=sign*(.078+.023*math.sin(j*.65))
                tube([(x,cy,1.515),(x+sign*.023,cy,1.477),(x+sign*.016,cy+.008,1.435),(x+sign*.026,cy+.011,1.402),(x+sign*.012,cy+.004,1.367)],.023,'head',3,10)
                tube([(x,cy+.02,1.505),(x+sign*.026,cy+.025,1.474),(x+sign*.018,cy+.03,1.431),(x+sign*.026,cy+.03,1.39)],.003,'head',5,8)
        for i in range(6):
            x=-.084+i*.034
            tube([(x,.05,1.52),(x-.020,.033,1.54),(x-.010,-.01,1.551),(x+.012,-.062,1.521),(x+.019,-.087,1.43),(x+.005,-.095,1.374)],.007,'head',4,10)
        # Swept asymmetrical fringe, hugging cap rather than floating strands.
        tube([(.042,.053,1.545),(-.014,.073,1.535),(-.069,.083,1.502),(-.099,.079,1.476)],.020,'head',3,10)
        tube([(.043,.067,1.548),(-.014,.085,1.536),(-.07,.096,1.504),(-.103,.09,1.473)],.004,'head',5,8)
        for side,s in [('L',-1),('R',1)]:
            bone=arm.data.bones['upper_arm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.070,'upper_arm.'+side,8,16)
            ellipsoid(tuple(a),(.070,.071,.068),'upper_arm.'+side,8,16,8)
            mid=(a+b)/2; ellipsoid(tuple(mid),(.078,.078,.09),'upper_arm.'+side,8,16,8)
            bone=arm.data.bones['forearm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.047,'forearm.'+side,2,16)
            ellipsoid(tuple(a),(.057,.055,.037),'forearm.'+side,8,16,8)
            ellipsoid((s*.29,.005,.778),(.037,.041,.029),'hand.'+side,2,12,8)
            ellipsoid((s*.29,.015,.723),(.04,.038,.054),'hand.'+side,2,12,8)
            ellipsoid((s*.257,.038,.746),(.019,.023,.029),'hand.'+side,2,10,6)
            start=len(verts)
            rings([(.0,.061,.11,.047),(.025,.069,.126,.045),(.09,.063,.105,.024),(.18,.049,.058,0)],'foot.'+side,12,16)
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-06-Tess'); mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-06-Tess',mesh); scene.collection.objects.link(obj); obj.parent=arm
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
        glb=ROOT/'game/assets/models/npcs/npc-06.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-06.blend'; bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-06','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-06/official-neutral.png','reference/npc-06/npc_06_idle_sheet.png'],
            'identity':'41-year-old store owner, oval mature face, wavy chestnut bob, green waistcoat, rust apron with pocket/pencils/back ties, cream puff sleeves, brown trousers/boots'}
        (ROOT/'art/exports/npc-06.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report))
    finally: bpy.context.window.scene=old


if __name__=='__main__': build()
