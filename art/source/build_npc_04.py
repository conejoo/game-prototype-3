"""Harlan Reed's source-informed stylized dockmaster skin; existing MCP only.

Helper topology and planted clips reuse the delivered pipeline. All costume,
face, beard and hair geometry below is authored for Harlan's public references.
Creates one owned scene, preserves the artist's active scene and source file.
"""
import bpy
import math
import json
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE = 'RF-Npc04-Harlan'


def build():
    if bpy.data.scenes.get(SCENE):
        raise RuntimeError('Owned Harlan scene exists; inspect before rebuilding')
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
        root.name = 'RF_Npc04_Harlan'
        arm.name = arm.data.name = 'ARM-npc-04'
        colors = [(.065,.19,.21,1),(.54,.32,.10,1),(.67,.39,.22,1),
                  (.10,.075,.055,1),(.24,.19,.13,1),(.46,.45,.39,1),
                  (.18,.10,.045,1),(.42,.13,.055,1),(.83,.76,.59,1),
                  (.78,.80,.71,1),(.20,.16,.085,1),(.017,.013,.010,1),
                  (.20,.115,.055,1),(.27,.095,.055,1),(.48,.26,.14,1)]
        image=bpy.data.images.new('TEX-npc-04-palette',width=32,height=32)
        image.pixels=[c for y in range(32) for x in range(32) for c in colors[min(14,(y//8)*4+x//8)]]
        image.pack()
        mat=bpy.data.materials.new('MAT-npc-04-dockmaster')
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

        # Broad working vest, ivory shirt and pointed collar; no civic coat/chain.
        rings([(.85,.183,.14,0),(.98,.19,.148,0),(1.14,.215,.15,0),(1.23,.244,.132,0),(1.265,.18,.11,0),(1.29,.065,.06,0)],'spine',0)
        patch([(-.10,.156,1.27),(-.08,.165,1.10),(0,.17,1.05),(.08,.165,1.10),(.10,.156,1.27)],'spine',8)
        for s in [-1,1]:
            patch([(s*.02,.173,1.27),(s*.108,.16,1.27),(s*.085,.177,1.17)],'spine',8)
            patch([(s*.11,.165,1.265),(s*.195,.128,1.245),(s*.103,.17,1.055),(s*.07,.175,1.11)],'spine',0)
            tube([(s*.11,.173,1.26),(s*.093,.181,1.16),(s*.02,.176,1.045)],.005,'spine',4)
        # Rust neckerchief with brass slide and two shaped hanging tails.
        tube([(-.052,.035,1.30),(-.052,.08,1.27),(0,.18,1.21),(.052,.08,1.27),(.052,.035,1.30)],.022,'spine',7)
        patch([(-.018,.204,1.19),(-.047,.19,1.12),(-.023,.192,1.03),(.006,.193,1.13)],'spine',7)
        patch([(.014,.205,1.19),(.032,.20,1.10),(.018,.20,1.00),(-.008,.202,1.13)],'spine',7)
        ellipsoid((0,.204,1.188),(.025,.014,.022),'spine',1,12,6)
        for z in [.91,.976,1.042]: ellipsoid((0,.157,z),(.011,.007,.011),'spine',1,10,6)
        rings([(.835,.18,.143,0),(.877,.182,.144,0)],'hips',12)
        patch([(-.034,.15,.84),(.034,.15,.84),(.034,.15,.876),(-.034,.15,.876)],'hips',1)
        patch([(-.12,-.147,.90),(.12,-.147,.90),(.12,-.148,.96),(-.12,-.148,.96)],'spine',4)
        ellipsoid((0,-.155,.935),(.014,.005,.019),'spine',1,10,6)
        # Continuous tailored trousers blend across knees to avoid segment gaps.
        trouser_ranges=[]
        for side,s in [('L',-1),('R',1)]:
            start=len(verts)
            rings([(.12,.053,.056,0),(.25,.067,.068,0),(.47,.076,.081,0),(.70,.08,.105,0),(.866,.089,.11,0)],'thigh.'+side,6,20)
            trouser_ranges.append((side,start,len(verts)))
            for k in range(start,len(verts)): verts[k]=(verts[k][0]+s*.11,verts[k][1],verts[k][2])
        # Square jaw, full weathered cheeks, strong nose and dark deep-set eyes.
        rings([(1.28,.055,.059,.012),(1.34,.061,.066,.012)],'head',2)
        rings([(1.325,.067,.066,.014),(1.35,.095,.076,.01),(1.383,.115,.085,.005),(1.423,.118,.092,0),(1.461,.112,.083,-.008),(1.505,.103,.075,-.012),(1.536,.074,.052,-.014)],'head',2,28)
        surface([(-.015,.088,1.458),(.015,.088,1.458),(-.025,.093,1.407),(.025,.093,1.407),(0,.14,1.412),(-.031,.10,1.402),(.031,.10,1.402)],[(0,1,4),(0,4,2),(1,3,4),(2,4,5),(4,3,6),(5,4,6)],'head',2)
        for s in [-1,1]:
            ellipsoid((s*.117,-.007,1.42),(.018,.022,.034),'head',2,12,6)
            ellipsoid((s*.049,.084,1.45),(.023,.009,.009),'head',9,16,6)
            ellipsoid((s*.049,.092,1.45),(.008,.002,.007),'head',10,12,6)
            ellipsoid((s*.049,.094,1.45),(.004,.0015,.005),'head',11,10,5)
            tube([(s*.025,.092,1.459),(s*.05,.096,1.466),(s*.079,.078,1.456)],.004,'head',3)
            tube([(s*.019,.088,1.477),(s*.049,.095,1.482),(s*.082,.066,1.473)],.008,'head',3)
            tube([(s*.03,.09,1.432),(s*.055,.09,1.426),(s*.085,.065,1.429)],.002,'head',14)
            # Contoured short beard hugs cheeks/jaw; salt/pepper at chin/temples.
            tube([(s*.103,.046,1.451),(s*.108,.055,1.401),(s*.09,.077,1.375),(s*.04,.09,1.342)],.011,'head',3)
            tube([(s*.011,.105,1.399),(s*.035,.107,1.394),(s*.069,.09,1.389)],.007,'head',3)
            tube([(s*.085,.082,1.37),(s*.054,.103,1.35),(s*.012,.098,1.338)],.004,'head',5)
            tube([(s*.106,.043,1.462),(s*.114,.023,1.492)],.010,'head',5)
        rings([(1.324,.06,.068,.012),(1.34,.085,.079,.01),(1.358,.10,.082,.008),(1.369,.102,.078,.006)],'head',3,28)
        tube([(-.052,.085,1.353),(0,.096,1.34),(.052,.085,1.353)],.009,'head',5)
        tube([(-.025,.105,1.376),(0,.112,1.377),(.025,.105,1.376)],.003,'head',13)
        # Short tousled brown hair with gray temples, no braid or long coat.
        rings([(1.487,.109,.09,-.021),(1.523,.114,.089,-.022),(1.55,.095,.07,-.019),(1.57,.05,.042,-.013),(1.574,.015,.012,-.01)],'head',3,28)
        for i in range(8):
            x=-.092+i*.024
            tube([(x,.055,1.520),(x-.006,.049,1.55),(x+.01,.006,1.571),(x+.018,-.058,1.545)],.004,'head',4)
        for s in [-1,1]:
            tube([(s*.108,.034,1.491),(s*.117,-.010,1.518),(s*.099,-.066,1.536)],.010,'head',5)
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
        mesh=bpy.data.meshes.new('GEO-npc-04-Harlan'); mesh.from_pydata(verts,[],faces); mesh.update()
        obj=bpy.data.objects.new('GEO-npc-04-Harlan',mesh); scene.collection.objects.link(obj); obj.parent=arm
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
        glb=ROOT/'game/assets/models/npcs/npc-04.glb'
        bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,
            export_animations=True,export_animation_mode='NLA_TRACKS',export_force_sampling=True,export_frame_step=1,
            export_anim_slide_to_zero=True,export_cameras=False,export_lights=False,export_def_bones=True,export_skins=True)
        for track in arm.animation_data.nla_tracks: track.mute=False
        snapshot=ROOT/'art/source/npc-04.blend'; bpy.data.libraries.write(str(snapshot),{scene},fake_user=True)
        report={'npc_id':'npc-04','triangles':len(mesh.loop_triangles),'vertices':len(verts),'bones':len(arm.data.bones),
            'materials':1,'texture':[32,32],'source':str(snapshot),'glb':str(glb),'idle':'runtime fixed contact','walk':'review only',
            'preserved_scene':old.name,'references':['portraits/npc-04/official-neutral.png','reference/npc-04/npc_04_idle_sheet.png'],
            'identity':'48-year-old dockmaster, broad square bearded face, short tousled brown/gray hair, teal vest, brass buttons, rust scarf, rolled cream sleeves, brown trousers/boots'}
        (ROOT/'art/exports/npc-04.json').write_text(json.dumps(report,indent=2)+'\n'); print(json.dumps(report))
    finally: bpy.context.window.scene=old


if __name__=='__main__': build()
