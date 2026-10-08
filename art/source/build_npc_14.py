"""Della Pike's source-informed stylized innkeeper skin; existing MCP only.

Helper topology and planted clips reuse the delivered pipeline. All costume,
face, apron and hair geometry below is authored for Della's public references.
Creates one owned scene, preserves the artist's active scene and source file.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc14-Della'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Della scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc14_Della'
        arm.name = arm.data.name = 'ARM-npc-14'
        colors = [(.245,.074,.14,1),(.78,.67,.48,1),(.68,.40,.23,1),
                  (.45,.42,.36,1),(.64,.61,.53,1),(.32,.30,.25,1),
                  (.21,.062,.11,1),(.82,.74,.59,1),(.32,.13,.20,1),
                  (.91,.87,.73,1),(.23,.15,.065,1),(.022,.014,.008,1),
                  (.15,.072,.04,1),(.39,.17,.125,1),(.21,.23,.10,1)]
        image=bpy.data.images.new('TEX-npc-14-palette',width=32,height=32)
        image.pixels=[c for y in range(32) for x in range(32) for c in colors[min(14,(y//8)*4+x//8)]]
        image.pack()
        mat=bpy.data.materials.new('MAT-npc-14-innkeeper')
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

        # Della's full plum gown; broad mature torso, gathered neckline.
        rings([(.83,.176,.146,0),(.97,.204,.163,0),(1.12,.227,.178,0),
               (1.23,.245,.15,0),(1.268,.205,.123,0),(1.293,.068,.06,0)],'spine',0)
        for x in [-.065,-.033,0,.033,.065]:
            tube([(x,.121,1.266),(x*1.1,.148,1.24),(x*1.15,.161,1.218)],.003,'spine',8)
        ellipsoid((.016,.171,1.229),(.007,.006,.009),'spine',10,10,6)
        # Continuous gathered gown and apron. A shared deformation field closes
        # waist and center seams through planted clips; no detached skirt halves.
        cloth_start=len(verts)
        rings([(.205,.245,.165,0),(.35,.249,.172,0),(.55,.233,.175,0),
               (.72,.213,.171,0),(.866,.188,.154,0),(.97,.204,.163,0)],'hips',6,32)
        points=[]
        for z,w,depth in [(.265,.212,.177),(.45,.207,.187),(.68,.186,.190),
                          (.866,.174,.167),(.97,.166,.184),(1.065,.152,.196),(1.167,.145,.185)]:
            for t in [-1,-.75,-.5,-.25,0,.25,.5,.75,1]:
                points.append((w*t,depth-.024*t*t,z))
        surface(points,[(r*9+i,(r+1)*9+i,(r+1)*9+i+1,r*9+i+1) for r in range(6) for i in range(8)],'hips',7)
        for s in [-1,1]:
            tube([(s*.209,.158,.265),(s*.204,.163,.45),(s*.183,.169,.68),(s*.172,.143,.866)],.003,'hips',1)
            tube([(s*.139,.159,1.168),(s*.15,.103,1.237),(s*.145,-.037,1.267),(s*.14,-.135,1.174)],.013,'hips',1,10)
            patch([(0,-.177,.872),(s*.047,-.186,.898),(s*.044,-.186,.85)],'hips',1)
            tube([(s*.008,-.18,.87),(s*.024,-.19,.76),(s*.036,-.187,.662)],.012,'hips',1)
        rings([(.85,.197,.18,0),(.887,.199,.181,0)],'hips',1,32)
        cloth_stop=len(verts)
        # Olive shoulder shawl wraps back, leaves cream bib visible in front.
        for s in [-1,1]:
            pts=[(s*x,y,z) for x,y,z in [(.05,-.025,1.304),(.135,-.015,1.302),(.218,-.022,1.281),
                                       (.07,.072,1.278),(.17,.109,1.256),(.256,.073,1.213),
                                       (.125,.163,1.225),(.205,.147,1.195),(.265,.085,1.13)]]
            surface(pts,[(0,1,4,3),(1,2,5,4),(3,4,7,6),(4,5,8,7)],'spine',14)
            for i in range(9):
                t=i/8; x=s*(.125+.14*t); y=.163-.078*t; z=1.225-.095*t
                tube([(x,y,z),(x,y+.003,z-.038)],.003,'spine',14,6)
        points=[(w*t,-depth+.027*t*t,z) for z,w,depth in [(1.293,.09,.10),(1.23,.228,.177),(1.125,.244,.177)] for t in [-1,-.5,0,.5,1]]
        surface(points,[(r*5+i,r*5+i+1,(r+1)*5+i+1,(r+1)*5+i) for r in range(2) for i in range(4)],'spine',14)
        for i in range(15):
            x=-.23+i*.032
            tube([(x,-.17+.027*(x/.244)**2,1.126),(x,-.17+.027*(x/.244)**2,1.075)],.003,'spine',14,6)
        ellipsoid((-.184,.128,1.217),(.018,.006,.018),'spine',10,16,8)
        # Round mature face, fuller cheeks/chin, lined lids and warm nose.
        rings([(1.282,.061,.061,.01),(1.352,.065,.072,.008)],'head',2)
        rings([(1.327,.052,.061,.013),(1.350,.085,.078,.008),(1.384,.117,.09,0),
               (1.423,.126,.098,-.005),(1.47,.115,.083,-.01),(1.51,.101,.076,-.012),(1.545,.072,.051,-.014)],'head',2,28)
        surface([(-.013,.085,1.459),(.013,.085,1.459),(-.022,.095,1.411),(.022,.095,1.411),(0,.135,1.416),(-.027,.101,1.399),(.027,.101,1.399)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for s in [-1,1]:
            ellipsoid((s*.124,-.008,1.426),(.018,.023,.032),'head',2,12,6)
            ellipsoid((s*.048,.088,1.449),(.023,.006,.008),'head',9,16,6)
            ellipsoid((s*.048,.094,1.449),(.008,.002,.006),'head',10,12,6)
            ellipsoid((s*.048,.096,1.449),(.004,.001,.004),'head',11,10,5)
            tube([(s*.025,.091,1.455),(s*.048,.099,1.46),(s*.071,.09,1.455)],.004,'head',2)
            tube([(s*.025,.093,1.433),(s*.048,.101,1.431),(s*.077,.08,1.435)],.002,'head',13,6)
            tube([(s*.025,.086,1.478),(s*.052,.091,1.484),(s*.083,.065,1.474)],.007,'head',5)
        tube([(-.029,.096,1.379),(0,.109,1.381),(.029,.096,1.385)],.004,'head',13)
        # Silver swept waves/high bun, curled wisps; distinct from Helena braid.
        rings([(1.485,.122,.092,-.028),(1.525,.122,.088,-.029),(1.557,.085,.064,-.029),(1.575,.04,.033,-.025)],'head',3,28)
        ellipsoid((0,-.092,1.531),(.070,.059,.064),'head',3,20,10)
        for i in range(7):
            x=-.10+i*.032
            tube([(x,.033,1.53),(x-.019,.05,1.552),(x*.75,-.005,1.574),(x*.64,-.07,1.56),(x*.48,-.14,1.529)],.009,'head',4,10)
        for s in [-1,1]:
            for j in range(3):
                y=-.066+j*.034
                tube([(s*.092,y,1.527),(s*.122,y,1.491),(s*.127,y+.014,1.45),(s*.112,y+.02,1.42)],.014,'head',4 if j%2 else 3,10)
            tube([(s*.100,.035,1.495),(s*.119,.058,1.453),(s*.129,.063,1.41),(s*.111,.072,1.384),(s*.13,.07,1.363)],.005,'head',4,10)
        # Plum gathered sleeves, rolled cuff, bare lower arms, sensible boots.
        for side,s in [('L',-1),('R',1)]:
            bone=arm.data.bones['upper_arm.'+side]; a,b=bone.head_local,bone.tail_local
            ellipsoid((s*.213,0,1.243),(.061,.063,.047),'spine',0,16,8)
            direction=(b-a).normalized(); u=direction.cross(Vector((0,1,0))).normalized(); v=direction.cross(u).normalized()
            rows=[(-.022,.037),(0,.069),(.06,.076),(.14,.073),(.25,.061),(.274,.060)]
            pts=[a+direction*d+r*(u*math.cos(j*math.tau/20)+v*math.sin(j*math.tau/20)) for d,r in rows for j in range(20)]
            polygons=[tuple(reversed(range(20)))]+[(r*20+j,r*20+(j+1)%20,(r+1)*20+(j+1)%20,(r+1)*20+j) for r in range(len(rows)-1) for j in range(20)]+[tuple((len(rows)-1)*20+j for j in range(20))]
            surface(pts,polygons,'upper_arm.'+side,0)
            bone=arm.data.bones['forearm.'+side]; a,b=bone.head_local,bone.tail_local
            tube([a,b],.047,'forearm.'+side,2,16)
            ellipsoid(tuple(a),(.062,.059,.04),'forearm.'+side,8,16,8)
            ellipsoid((s*.29,.005,.778),(.038,.041,.029),'hand.'+side,2,12,8)
            ellipsoid((s*.29,.015,.723),(.041,.039,.054),'hand.'+side,2,12,8)
            ellipsoid((s*.257,.038,.746),(.019,.023,.029),'hand.'+side,2,10,6)
            start=len(verts)
            rings([(.0,.061,.11,.047),(.025,.069,.126,.045),(.09,.063,.105,.024),(.20,.049,.058,0)],'foot.'+side,12,16)
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.13,verts[k][1],verts[k][2])
        mesh=bpy.data.meshes.new('GEO-npc-14-Della'); mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-14-Della',mesh); scene.collection.objects.link(obj); obj.parent=arm
        mesh.materials.append(mat); uv=mesh.uv_layers.new(name='UVMap')
        for poly,color in zip(mesh.polygons,slots):
            poly.use_smooth=True
            for index in poly.loop_indices: uv.data[index].uv=((color%4+.5)/4,(color//4+.5)/4)
        for bone in set(bones):
            group=obj.vertex_groups.new(name=bone); group.add([i for i,b in enumerate(bones) if b==bone],1,'REPLACE')
        # Blend cloth with the actual exported root-relative rig. Top follows
        # chest; waist follows hips; left/right hem follows corresponding thigh.
        for i in range(cloth_start,cloth_stop):
            x,y,z=verts[i]
            spine=max(0,min(1,(z-.91)/.16))
            thigh=max(0,min(1,(.88-z)/.18))
            left=max(0,min(1,(.06-x)/.12))
            obj.vertex_groups['hips'].remove([i])
            weights={'spine':spine,'hips':1-spine-thigh,'thigh.L':thigh*left,'thigh.R':thigh*(1-left)}
            for bone,weight in weights.items():
                if weight>0:
                    group=obj.vertex_groups.get(bone) or obj.vertex_groups.new(name=bone)
                    group.add([i],weight,'REPLACE')
        mod=obj.modifiers.new('Exported skin','ARMATURE'); mod.object=arm
        mesh.calc_loop_triangles(); assert 4000<=len(mesh.loop_triangles)<=12000
        for track in arm.animation_data.nla_tracks: track.mute=True
        for bone in arm.pose.bones:
            bone.location=(0,0,0); bone.rotation_quaternion=(1,0,0,0); bone.scale=(1,1,1)
        scene.frame_set(1); bpy.context.view_layer.update(); bpy.ops.object.select_all(action='DESELECT')
        for node in [root,arm,obj]: node.select_set(True)
        glb=ROOT/'game/assets/models/npcs/npc-14.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-14.blend'; bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-14','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['game/assets/npcs/portraits/npc-14/official-neutral.png','game/assets/npcs/reference/npc-14/npc_14_idle_sheet.png'],
            'identity':'58-year-old innkeeper, full mature face, silver swept waves/high bun/wisps, plum gathered gown/sleeves, cream bib/apron/back ties, olive fringed shoulder shawl/brass brooch, brown boots'}
        (ROOT/'art/exports/npc-14.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report))
    finally: bpy.context.window.scene=old


if __name__=='__main__': build()
