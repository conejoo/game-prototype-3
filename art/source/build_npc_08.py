"""Celia Oran's source-informed stylized boatwright skin; existing MCP only.

Helper topology and planted clips reuse the delivered pipeline. All costume,
face, apron and hair geometry below is authored for Celia's public references.
Creates one owned scene, preserves the artist's active scene and source file.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc08-Celia'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Celia scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc08_Celia'
        arm.name = arm.data.name = 'ARM-npc-08'
        colors = [(.52,.19,.105,1),(.53,.34,.10,1),(.67,.385,.20,1),
                  (.075,.043,.022,1),(.14,.08,.042,1),(.26,.15,.075,1),
                  (.24,.13,.062,1),(.55,.34,.105,1),(.58,.225,.13,1),
                  (.85,.85,.73,1),(.23,.115,.04,1),(.015,.010,.007,1),
                  (.16,.085,.038,1),(.40,.16,.095,1),(.245,.33,.26,1)]
        image=bpy.data.images.new('TEX-npc-08-palette',width=32,height=32)
        image.pixels=[c for y in range(32) for x in range(32) for c in colors[min(14,(y//8)*4+x//8)]]
        image.pack()
        mat=bpy.data.materials.new('MAT-npc-08-boatwright')
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

        def patch(points,bone,color):
            polygon=list(range(len(points)))
            normal=(Vector(points[1])-Vector(points[0])).cross(Vector(points[2])-Vector(points[0]))
            if normal.y*sum(p[1] for p in points)<0: polygon.reverse()
            surface(points,[tuple(polygon)],bone,color)

        # Celia's collared rust work shirt, shaped shoulders and open neckline.
        shirt_rows=[(.84,.166,.126,0),(.97,.176,.138,0),(1.12,.199,.15,0),(1.23,.242,.134,0),(1.264,.205,.111,0),(1.29,.06,.06,0)]
        rings(shirt_rows,'spine',0)
        def shirt_front(x,z,lift=.009):
            low,high=next((a,b) for a,b in zip(shirt_rows,shirt_rows[1:]) if a[0]<=z<=b[0])
            t=(z-low[0])/(high[0]-low[0]); rx=low[1]*(1-t)+high[1]*t; ry=low[2]*(1-t)+high[2]*t
            return (x,ry*math.sqrt(max(0,1-(x/rx)**2))+lift,z)
        for s in [-1,1]:
            patch([shirt_front(s*.026,1.27),shirt_front(s*.107,1.257),shirt_front(s*.087,1.195),shirt_front(s*.047,1.23)],'spine',8)
            tube([shirt_front(s*.114,1.257,.018),shirt_front(s*.137,1.16,.020),shirt_front(s*.13,1.05,.021)],.012,'spine',7)
            for z in [1.216,1.239]: ellipsoid(shirt_front(s*.128,z,.021),(.015,.005,.015),'spine',1,12,6)
        # Broad ochre apron, fitted curved bib, stitched front pocket/tool loops.
        # One continuous front cloth surface, including waist, avoids hips/spine
        # cracks. Shorter floating hem clears actual upper-thigh walk envelope.
        apron_start=len(verts)
        bib_rows=[(.76,.148),(.84,.159),(.94,.143),(1.015,.136),(1.075,.119),(1.124,.112)]
        points=[]
        for z,w in bib_rows:
            for t in [-1,-.5,0,.5,1]:
                x=w*t
                points.append((x,.195-.018*t*t,z) if z<.94 else shirt_front(x,z,.024))
        polys=[(r*5+i,(r+1)*5+i,(r+1)*5+i+1,r*5+i+1) for r in range(len(bib_rows)-1) for i in range(4)]
        surface(points,polys,'spine',7)
        apron_stop=len(verts)
        # Rear skirt is separate from front bib and ends above moving thighs.
        back_points=[(w*t,-.169+.015*t*t,z) for z,w in [(.78,.145),(.87,.157),(.94,.16)] for t in [-1,-.5,0,.5,1]]
        back_faces=[(r*5+i,r*5+i+1,(r+1)*5+i+1,(r+1)*5+i) for r in range(2) for i in range(4)]
        surface(back_points,back_faces,'hips',7)
        tube([(-.12,.15,1.123),(0,.172,1.125),(.12,.15,1.123)],.003,'spine',1)
        patch([(-.067,.198,.94),(.068,.198,.94),(.068,.204,.866),(-.067,.204,.866)],'hips',1)
        tube([(-.067,.206,.936),(0,.209,.933),(.068,.206,.936)],.003,'hips',7)
        for x,z in [(.105,1.026),(.123,1.038)]:
            tube([(x,.161,.921),(x,.168,z)],.009,'spine',5,10)
            tube([(x,.176,.91),(x+.008,.176,.979)],.004,'spine',1,8)
        tube([(-.16,-.13,.95),(0,-.154,.948),(.16,-.13,.95)],.009,'hips',7)
        for s in [-1,1]:
            patch([(0,-.16,.95),(s*.043,-.17,.963),(s*.04,-.17,.93)],'hips',7)
            tube([(s*.01,-.163,.948),(s*.027,-.17,.88),(s*.02,-.168,.82)],.009,'hips',7)
        # Sage neck scarf tied below open collar; no profession gameplay prop.
        tube([(-.047,-.018,1.301),(-.056,.059,1.282),(0,.15,1.245),(.056,.059,1.282),(.047,-.018,1.301)],.018,'spine',14,12)
        ellipsoid((0,.18,1.227),(.021,.015,.021),'spine',14,12,6)
        patch([(-.012,.191,1.214),(-.044,.19,1.133),(-.014,.194,1.155),(.009,.191,1.207)],'spine',14)
        patch([(.013,.192,1.213),(.046,.185,1.151),(.016,.196,1.169),(-.008,.192,1.204)],'spine',14)
        # Continuous tapered trousers preserve knee blending.
        trouser_ranges=[]
        for side,s in [('L',-1),('R',1)]:
            start=len(verts)
            rings([(.12,.053,.056,0),(.25,.067,.068,0),(.47,.076,.081,0),(.70,.08,.105,0),(.866,.089,.11,0)],'thigh.'+side,6,20)
            trouser_ranges.append((side,start,len(verts)))
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.11,verts[k][1],verts[k][2])
        # Celia's angular warm face, higher cheek/jaw planes, strong brows.
        rings([(1.28,.053,.057,.01),(1.347,.056,.063,.008)],'head',2)
        rings([(1.327,.049,.058,.01),(1.349,.079,.070,.005),(1.382,.108,.080,0),(1.423,.117,.086,-.006),(1.468,.107,.079,-.011),(1.513,.095,.071,-.014),(1.543,.069,.05,-.015)],'head',2,28)
        surface([(-.011,.08,1.46),(.011,.08,1.46),(-.020,.086,1.412),(.020,.086,1.412),(0,.128,1.415),(-.025,.09,1.4),(.025,.09,1.4)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for s in [-1,1]:
            ellipsoid((s*.113,-.007,1.427),(.018,.020,.031),'head',2,12,6)
            ellipsoid((s*.046,.081,1.451),(.024,.007,.009),'head',9,16,6)
            ellipsoid((s*.046,.087,1.451),(.008,.002,.007),'head',10,12,6)
            ellipsoid((s*.046,.089,1.451),(.004,.001,.005),'head',11,10,5)
            tube([(s*.022,.086,1.458),(s*.045,.092,1.464),(s*.07,.079,1.456)],.004,'head',3)
            tube([(s*.023,.085,1.475),(s*.048,.087,1.482),(s*.08,.066,1.472)],.008,'head',3)
        tube([(-.026,.089,1.379),(0,.098,1.378),(.027,.088,1.382)],.004,'head',13)
        # Swept dark crown and loose temple wisps, thick interleaved back braid.
        rings([(1.49,.115,.092,-.028),(1.524,.117,.083,-.028),(1.556,.086,.066,-.026),(1.571,.034,.03,-.023)],'head',3,28)
        for s in [-1,1]:
            for j in range(3):
                cy=-.068+j*.033; x=s*(.086+.016*math.sin(j))
                tube([(x,cy,1.524),(x+s*.019,cy,1.491),(x+s*.008,cy+.006,1.454),(x+s*.013,cy,1.421)],.017,'head',3,10)
            tube([(s*.095,.021,1.475),(s*.117,.043,1.441),(s*.11,.047,1.411),(s*.126,.039,1.386)],.006,'head',3,10)
        for i in range(5):
            x=-.073+i*.036
            tube([(x,.055,1.529),(x-.015,.034,1.552),(x+.008,-.016,1.562),(x+.016,-.082,1.524),(x*.4,-.10,1.475)],.008,'head',4,10)
        tube([(.041,.06,1.545),(-.012,.075,1.539),(-.072,.085,1.51),(-.104,.078,1.48)],.018,'head',3,10)
        # Braid curves down center-back, follows head above neck, spine below.
        for i in range(7):
            z=1.47-i*.038; y=-.105-.017*math.sin(i*.4)
            for s in [-1,1]:
                ellipsoid((s*.016,y,z),(.027,.023,.034),'head' if z>1.31 else 'spine',3,12,6)
                tube([(s*.032,y+.004,z+.018),(0,y-.025,z),(s*-.024,y-.01,z-.025)],.004,'head' if z>1.31 else 'spine',5,8)
        tube([(-.022,-.124,1.224),(0,-.141,1.217),(.022,-.124,1.224)],.005,'spine',7)
        ellipsoid((0,-.13,1.19),(.018,.018,.035),'spine',3,12,6)
        for side,s in [('L',-1),('R',1)]:
            bone=arm.data.bones['upper_arm.'+side]; a,b=bone.head_local,bone.tail_local
            ellipsoid((s*.202,0,1.242),(.055,.061,.046),'spine',0,16,8)
            direction=(b-a).normalized(); u=direction.cross(Vector((0,1,0))).normalized(); v=direction.cross(u).normalized()
            rows=[(-.024,.033),(0,.070),(.07,.073),(.16,.067),(.245,.058),(.269,.058)]
            sleeve=[a+direction*d+radius*(u*math.cos(j*math.tau/20)+v*math.sin(j*math.tau/20)) for d,radius in rows for j in range(20)]
            sleeve_faces=[tuple(reversed(range(20)))]+[(r*20+j,r*20+(j+1)%20,(r+1)*20+(j+1)%20,(r+1)*20+j) for r in range(len(rows)-1) for j in range(20)]+[tuple((len(rows)-1)*20+j for j in range(20))]
            surface(sleeve,sleeve_faces,'upper_arm.'+side,0)
            bone=arm.data.bones['forearm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.047,'forearm.'+side,2,16)
            ellipsoid(tuple(a),(.057,.055,.037),'forearm.'+side,8,16,8)
            ellipsoid((s*.29,.005,.778),(.037,.041,.029),'hand.'+side,2,12,8)
            ellipsoid((s*.29,.015,.723),(.04,.038,.054),'hand.'+side,2,12,8)
            ellipsoid((s*.257,.038,.746),(.019,.023,.029),'hand.'+side,2,10,6)
            start=len(verts)
            rings([(.0,.061,.11,.047),(.025,.069,.126,.045),(.09,.063,.105,.024),(.18,.049,.058,0)],'foot.'+side,12,16)
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-08-Celia'); mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-08-Celia',mesh); scene.collection.objects.link(obj); obj.parent=arm
        mesh.materials.append(mat); uv=mesh.uv_layers.new(name='UVMap')
        for poly,color in zip(mesh.polygons,slots):
            poly.use_smooth=True
            for index in poly.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
        for bone in set(bones):
            group=obj.vertex_groups.new(name=bone); group.add([i for i,b in enumerate(bones) if b==bone],1,'REPLACE')
        for i in range(apron_start,apron_stop):
            hip=max(0,min(1,(1.065-verts[i][2])/.15))
            if hip>0:
                obj.vertex_groups['spine'].remove([i])
                if hip<1: obj.vertex_groups['spine'].add([i],1-hip,'REPLACE')
                obj.vertex_groups['hips'].add([i],hip,'REPLACE')
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
        glb=ROOT/'game/assets/models/npcs/npc-08.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-08.blend'; bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-08','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-08/official-neutral.png','actors/npcs/npc_08_idle_sheet.png'],
            'identity':'37-year-old boatwright, angular warm face, dark swept hair and back braid, rust collared rolled-sleeve shirt, ochre fitted apron/pocket/tool loops/back ties, sage knotted scarf, brown trousers/boots'}
        (ROOT/'art/exports/npc-08.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report))
    finally: bpy.context.window.scene=old


if __name__=='__main__': build()
