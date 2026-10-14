"""Extend the accepted schoolhouse construction to the remaining town buildings.

Run build() inside the inspected live Blender session, inspect the viewport,
then call export_verified(). Original assets and scenes are never overwritten.
All dimensions come from the pinned town kit rather than generic house sizes.
"""
import bpy
import bmesh
import hashlib
import importlib.util
import json
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE_NAME = 'RF-HousesReference'
OWNER = 'houses-reference-v1'
BASE_PATH = ROOT / 'tools/art_direction/build_schoolhouse_reference.py'
spec = importlib.util.spec_from_file_location('approved_schoolhouse', BASE_PATH)
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
PLASTER, ROOF, TIMBER, STONE, GLASS, DOOR, IRON = range(7)
CIVIC = {'alderwake-hall', 'lantern-rest', 'mayor-vale-home'}
SHOPS = {'reed-chandlery', 'tess-general-goods'}
APPROVED_FILES = [BASE_PATH,
    ROOT/'game/assets/environment/storybook/schoolhouse-reference-v1.glb',
    ROOT/'art/source/storybook/schoolhouse-reference-v1.blend',
    ROOT/'art/source/storybook/schoolhouse-reference-recipe.json']


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def offset_polygon(poly, amount):
    """Offset clockwise Blender XY polygon; positive points outward."""
    result = []
    for i, p in enumerate(poly):
        d0 = (p-poly[i-1]).normalized()
        d1 = (poly[(i+1)%len(poly)]-p).normalized()
        n0, n1 = Vector((-d0.y,d0.x,0)), Vector((-d1.y,d1.x,0))
        bisector = n0+n1
        result.append(p+bisector*(amount/bisector.dot(n0)))
    return result


def inside(poly, p, tolerance=1e-6):
    return all((b.x-a.x)*(p.y-a.y)-(b.y-a.y)*(p.x-a.x) <= tolerance
               for a,b in zip(poly,poly[1:]+poly[:1]))


class Builder(base.Builder):
    def __init__(self, definition):
        super().__init__()
        self.definition = definition
        self.rng.seed(int(hashlib.sha256(definition.encode()).hexdigest()[:8],16))

    def oriented_box(self, center, along, outward, low, high, material,
                     shade=.5, bevel=0, part='box', wood_axis=None):
        """True orthogonal facade prism, including both skew catalog quads."""
        first = len(self.vertices)
        self.box(low, high, material, shade, bevel, part, wood_axis)
        c,d,n = Vector(center), Vector(along), Vector(outward)
        for i in range(first,len(self.vertices)):
            x,y,z = self.vertices[i]
            self.vertices[i] = tuple(c+d*x+n*y+Vector((0,0,z)))

    def finish(self, scene):
        name = 'GEO-house-reference-'+self.definition
        mesh = bpy.data.meshes.new('MESH-'+name[4:])
        mesh.from_pydata(self.vertices, [], self.faces)
        mesh.update()
        assert not mesh.validate(), 'Invalid generated mesh '+name
        ca = mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='CORNER')
        uv = mesh.uv_layers.new(name='UV-metre')
        for polygon, material, color, uvs in zip(mesh.polygons,self.materials,self.colors,self.uvs):
            polygon.material_index = material
            polygon.use_smooth = False
            for loop, texcoord in zip(polygon.loop_indices,uvs):
                ca.data[loop].color = (color,color,color,1)
                uv.data[loop].uv = texcoord
        bm = bmesh.new()
        bm.from_mesh(mesh)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(mesh)
        bm.free()
        mesh.update()
        mesh.calc_loop_triangles()
        # Reuse accepted preview materials without editing them. Each exported
        # definition has its own mesh slots; Godot assigns per-house palettes.
        for matname,color in base.MATERIALS:
            mat = bpy.data.materials.get(matname)
            if mat is None:
                mat = bpy.data.materials.new(matname)
                mat.use_nodes=True
                mat.diffuse_color=color
                bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
                bsdf.inputs['Base Color'].default_value=color
                bsdf.inputs['Roughness'].default_value=.92
            mesh.materials.append(mat)
        obj=bpy.data.objects.new(name,mesh)
        obj['owner']=OWNER
        obj['source_definition_id']=self.definition
        obj['visual_only']=True
        scene.collection.objects.link(obj)
        return obj


def window(b, center, d, n, halfwidth, height_scale=1):
    def block(u0,u1,z0,z1,offset,depth,material,shade=.5,part='window_frame'):
        z0*=height_scale;z1*=height_scale
        axis=(0,0,1) if z1-z0>u1-u0 else (1,0,0)
        b.oriented_box(center,d,n,(u0,offset,z0),(u1,offset+depth,z1),material,
                       shade,part=part,wood_axis=axis if material==TIMBER else None)
    # Existing night-pane overlays sit at .0095m from the catalog facade.
    # Keep recess/glass behind them; preserve their exact clear rectangle.
    block(-halfwidth-.032,halfwidth+.032,-.25,.27,.001,.004,TIMBER,.43,'window_recess')
    for u0,u1 in [(-halfwidth,-.025),(.025,halfwidth)]:
        for z0,z1 in [(-.22,-.025),(.025,.24)]:
            block(u0,u1,z0,z1,.006,.002,GLASS,b.shade(.04),'window_pane')
    for u in [-halfwidth-.050,halfwidth+.002]:
        block(u,u+.048,-.267,.287,.012,.040,TIMBER,b.shade(.025))
    for z in [-.267,.24]:
        block(-halfwidth-.052,halfwidth+.05,z,z+.047,.012,.04,TIMBER,b.shade(.025))
    block(-.025,.025,-.22,.24,.018,.03,TIMBER,.49)
    block(-halfwidth,halfwidth,-.025,.025,.018,.030,TIMBER,.5)
    block(-halfwidth-.066,halfwidth+.066,-.295,-.255,.016,.084,TIMBER,.53,'window_sill')


def masonry_base(b,p):
    b.prism([(v.x,v.y) for v in p],0,.008,STONE,.42,part='foundation_footing')
    inset=offset_polygon(p,-.018)
    b.prism([(v.x,v.y) for v in inset],.008,.22,STONE,.42,part='foundation_core')
    for a,c in zip(p,p[1:]+p[:1]):
        d=(c-a).normalized();n=Vector((-d.y,d.x,0));length=(c-a).length
        # Stones inset from the exact perimeter and clipped short at corners.
        # With skew corners, this prevents a .04m-deep end escaping its quad.
        margin=.05
        for row in range(2):
            step=.32;start=-step*.5*(row%2);z=.013+row*.102
            for k in range(math.ceil((length-start)/step)):
                lo=max(margin,start+k*step+.006)
                hi=min(length-margin,start+(k+1)*step-.006)
                if hi<=lo: continue
                # Tiny clipped end stones keep a simple closed cap; chamfering
                # a 2-3mm fragment produces subpixel sliver triangles on import.
                bevel=.008 if hi-lo>=.012 else 0
                b.oriented_box(a,d,n,(lo,-.04,z),(hi,0,z+.091),STONE,
                               b.shade(.06),bevel,'foundation_stone')


def roof(b,p,wall,ridge):
    # Acute skew corners amplify an offset; cap corner travel before adding
    # the narrow fascia so the approved 16cm upper overhang always holds.
    trial=offset_polygon(p,.108)
    greatest=max(abs(q[i]-v[i]) for q,v in zip(trial,p) for i in [0,1])
    eave_offset=.108*min(1,.118/greatest)
    corners=offset_polygon(p,eave_offset)
    for v in corners:v.z=wall-.04
    r0=(p[0]+p[3])/2;r1=(p[1]+p[2])/2;r0.z=r1.z=ridge
    # Extend ridge ends by the same small distance as eaves.
    along=(r1-r0).normalized();r0-=along*eave_offset;r1+=along*eave_offset
    profiles=[]
    for q in [[corners[0],corners[1],r1,r0],[corners[3],corners[2],r1,r0]]:
        width=(q[1]-q[0]).length
        slope0=q[3]-q[0];slope1=q[2]-q[1]
        slope_length=(slope0.length+slope1.length)/2
        cols=max(4,math.ceil(width/.325));rows=max(6,min(16,round(slope_length/.14)))
        normal=(q[1]-q[0]).cross(q[3]-q[0]).normalized()
        if normal.z<0:normal=-normal
        def point(u,s,h=0):return q[0].lerp(q[1],u).lerp(q[3].lerp(q[2],u),s)+normal*h
        bottom=[v-Vector((0,0,.045)) for v in q]
        b.face(q,ROOF,.42);b.face(bottom[::-1],ROOF,.42)
        for i in range(4):
            j=(i+1)%4;b.face([bottom[i],bottom[j],q[j],q[i]],ROOF,.42)
        for row in range(rows):
            start=-.5*(row%2)
            for col in range(cols+(row%2)):
                ua=max(0,(start+col)/cols+.002/width)
                ub=min(1,(start+col+1)/cols-.002/width)
                if (ub-ua)*width<.01:continue
                s0=row/rows;s1=min(1,(row+1)/rows+.025/slope_length)
                shift=b.rng.uniform(-.005,.005)/slope_length;tint=b.shade(.064)
                rings=[]
                for u,skew in [(ua,0),(ub,shift)]:
                    rings.append([point(u,s,h) for s,h in [(s0+skew,.010),(s1,.002),
                        (s1,.008),(s0+.018/slope_length+skew,.024),(s0+skew,.016)]])
                b.face(rings[0][::-1],ROOF,tint*.98);b.face(rings[1],ROOF,tint*.98)
                for i in range(5):
                    j=(i+1)%5
                    pts=[rings[0][i],rings[1][i],rings[1][j],rings[0][j]]
                    ridge_axis=(q[1]-q[0]).normalized();slope_axis=(slope0+slope1).normalized()
                    uv=[((v-q[0]).dot(ridge_axis),(v-q[0]).dot(slope_axis)) for v in pts]
                    b.face(pts,ROOF,tint if i in [2,3] else tint*.98,uv)
                b.part_counts['roof_tile']=b.part_counts.get('roof_tile',0)+1
        b.beam(q[0]-Vector((0,0,.018)),q[1]-Vector((0,0,.018)),.060,.072,TIMBER,.45,'eave_fascia')
        for i,j in [(0,3),(1,2)]:
            b.beam(q[i]-Vector((0,0,.018)),q[j]+Vector((0,0,.005)),.056,.060,TIMBER,.45,'roof_rake')
        profiles.append({'columns':cols,'rows':rows})
    count=max(4,math.ceil((r1-r0).length/.30))
    ridge_d=(r1-r0).normalized();ridge_n=Vector((-ridge_d.y,ridge_d.x,0))
    for i in range(count):
        lo=i*(r1-r0).length/count+.002;hi=(i+1)*(r1-r0).length/count-.002
        b.oriented_box(r0,ridge_d,ridge_n,(lo,-.04,.002),(hi,.04,.04),ROOF,b.shade(.042),part='ridge_cap')
    return profiles


def create_house(b,mapping):
    id=b.definition;p=[Vector((x,-z,0)) for x,z in mapping['local_polygon_xz_m']]
    civic=id in CIVIC;wall=2.15 if civic else 1.55
    if id=='net-shed':wall=1.30
    if id=='passenger-control-shelter':wall=.85
    ridge=wall+(.78 if civic else .68)
    centre=sum(p,Vector())/4
    masonry_base(b,p)
    inset=offset_polygon(p,-.008)
    b.prism([(v.x,v.y) for v in inset],.21,wall,PLASTER,.51,part='plaster_body')
    # Closed gable wedges conform to each original side, including skew.
    for i,j in [(0,3),(1,2)]:
        a,c=p[i],p[j];d=(c-a).normalized()
        n=(a-centre);n.z=0;n.normalize()
        triangle=[a+Vector((0,0,wall)),c+Vector((0,0,wall)),(a+c)/2+Vector((0,0,ridge-.035))]
        back=[v-n*.025 for v in triangle]
        b.face(triangle,PLASTER,.5);b.face(back[::-1],PLASTER,.5)
        for k in range(3):
            l=(k+1)%3;b.face([triangle[k],triangle[l],back[l],back[k]],PLASTER,.5)
        b.beam(a+Vector((0,0,wall-.07)),c+Vector((0,0,wall-.07)),.064,.070,TIMBER,.48,'gable_tie')
        mid=(a+c)/2
        b.beam(mid+Vector((0,0,wall-.03)),mid+Vector((0,0,ridge-.012)),.06,.06,TIMBER,.48,'gable_kingpost')
        for end in [a,c]:b.beam(end+Vector((0,0,wall-.03)),mid+Vector((0,0,ridge-.02)),.052,.068,TIMBER,.48,'gable_rake')
    anchors=[]
    for edge,(a,c) in enumerate(zip(p,p[1:]+p[:1])):
        d=(c-a).normalized();n=Vector((-d.y,d.x,0));length=(c-a).length
        for fraction in [.005,.42,.58,.995]:
            x=length*fraction
            b.oriented_box(a,d,n,(x-.035,-.024,.208),(x+.035,.024,wall+.008),TIMBER,
                           b.shade(.018),part='timber_post',wood_axis=(0,0,1))
        for z,height,part in [(.218,.072,'lower_sill'),(wall-.078,.086,'wall_plate')]:
            b.oriented_box(a,d,n,(0,-.024,z),(length,.024,z+height),TIMBER,.48,part=part,wood_axis=(1,0,0))
        if civic:
            b.oriented_box(a,d,n,(0,-.024,1.13),(length,.024,1.19),TIMBER,.48,part='upper_floor_beam',wood_axis=(1,0,0))
        levels=[.75,1.55] if civic else [.52] if id=='passenger-control-shelter' else [.77]
        for level in levels:
            for fraction in [.23,.77]:
                center=a.lerp(c,fraction)+Vector((0,0,level));halfwidth=min(.075*length,.28)
                window(b,center,d,n,halfwidth,.55 if id=='passenger-control-shelter' else 1)
                anchors.append({'edge':edge,'fraction':fraction,'center_local_xyz_m':[center.x,center.z,-center.y],
                                'half_width_m':halfwidth,'glass_front_offset_m':.008})
    # Original south-edge door midpoint, width and top. No new portal pad.
    a,c=p[2],p[3];d=(c-a).normalized();n=Vector((-d.y,d.x,0));mid=(a+c)/2
    door_width=(c-a).length*.14;left=-door_width/2;right=door_width/2
    top=1.24 if civic else .75 if id=='passenger-control-shelter' else 1.10
    def doorbox(lo,hi,mat,shade=.5,part='door',bevel=0):
        b.oriented_box(mid,d,n,lo,hi,mat,shade,bevel,part,(0,0,1) if mat in [DOOR,TIMBER] else None)
    doorbox((left-.045,-.005,.195),(right+.045,.032,top+.04),TIMBER,.43,'door_recess')
    planks=max(5,round(door_width/.09))
    for i in range(planks):
        doorbox((left+i*door_width/planks+.004,.033,.213),
                (left+(i+1)*door_width/planks-.004,.044,top-.005),DOOR,b.shade(.05),'door_plank')
    for x in [left-.054,right+.003]:
        doorbox((x,-.004,.199),(x+.051,.065,top+.064),TIMBER,.48,'door_jamb')
    doorbox((left-.058,-.005,top+.006),(right+.058,.066,top+.073),TIMBER,.5,'door_lintel')
    for z in [.36,top-.20]:
        doorbox((left+.05,.045,z),(left+min(.26,door_width*.38),.049,z+.019),IRON,.5,'door_strap')
    doorbox((right-.13,.045,.605),(right-.105,.071,.653),IRON,.5,'door_latch')
    doorbox((left-.023,-.010,.198),(right+.023,.067,.225),STONE,.51,'threshold',.006)
    profiles=roof(b,p,wall,ridge)
    # Existing civic turret stays distinct; ordinary houses retain chimney.
    cx,cy=centre.x,centre.y;maximum=mapping['height_m']
    if civic:
        b.box((cx-.30,cy-.23,ridge-.12),(cx+.30,cy+.23,ridge+.40),PLASTER,.51,part='civic_turret')
        for x in [cx-.30,cx+.30]:
            b.box((x-.018,cy-.238,ridge-.12),(x+.018,cy+.238,ridge+.405),TIMBER,.48,part='turret_corner',wood_axis=(0,0,1))
        b.box((cx-.33,cy-.26,ridge+.40),(cx+.33,cy+.26,maximum),ROOF,.52,.018,'turret_cap')
    else:
        low=ridge-.29
        b.box((cx-.168,cy-.168,low),(cx+.168,cy+.168,maximum-.023),STONE,.43,part='chimney_core')
        for row in range(4):
            z=low+.01+row*.119
            for direction in [0,1]:
                for side in [-1,1]:
                    shift=.5*(row%2)
                    for k in range(2+(row%2)):
                        lo=max(-.174,-.174+(k-shift)*.174+.003)
                        hi=min(.174,-.174+(k+1-shift)*.174-.003)
                        if hi<=lo:continue
                        d=Vector((1,0,0)) if direction==0 else Vector((0,1,0))
                        n=Vector((0,1,0)) if direction==0 else Vector((1,0,0))
                        b.oriented_box(centre,d,n,(lo,side*.169-.012,z),(hi,side*.169+.012,z+.111),STONE,b.shade(.053),.004,'chimney_stone')
        b.box((cx-.191,cy-.191,maximum-.038),(cx+.191,cy+.191,maximum),STONE,.55,.009,'chimney_cap')
    # Shops retain their facade bands with timber framing; alternating vertex
    # tones keep stripe rhythm without introducing an eighth runtime material.
    if id in SHOPS:
        length=(c-a).length
        along=(c-a).normalized();outward=Vector((-along.y,along.x,0))
        for i in range(12):
            b.oriented_box(a,along,outward,
                           (i*length/12,.028,1.24),((i+1)*length/12,.037,1.43),PLASTER,.44 if i%2 else .57,part='shop_fascia')
    return {'wall_height_m':wall,'ridge_height_m':ridge,'roof_slopes':profiles,
            'windows':anchors,'door':{'center_local_xyz_m':[mid.x,(top+.19)/2,-mid.y],'width_m':door_width,'top_m':top},
            'civic_turret':civic,'polygon':p,
            'service_shelter_exception':'Unlit shelter windows lowered .77 to .52m and scaled vertically .55; door top lowered 1.10 to .75m so trim fits below .83m. Original horizontal centers and widths retained.' if id=='passenger-control-shelter' else None}


def make_scene():
    old=bpy.data.scenes.get(SCENE_NAME)
    previous=bpy.context.scene.name
    if old:
        assert old.get('owner')==OWNER
        assert all(o.get('owner')==OWNER for o in old.objects), 'Unowned edits need preserving'
        if bpy.context.window.scene==old:
            bpy.context.window.scene=next(s for s in bpy.data.scenes if s!=old)
        for obj in list(old.objects):
            data=obj.data;bpy.data.objects.remove(obj,do_unlink=True)
            if isinstance(data,bpy.types.Mesh) and data.users==0:bpy.data.meshes.remove(data)
        bpy.data.scenes.remove(old)
    scene=bpy.data.scenes.new(SCENE_NAME);scene['owner']=OWNER
    bpy.context.window.scene=scene
    return scene,previous


def inspect_house(definition):
    scene=bpy.data.scenes[SCENE_NAME]
    obj=scene.objects['GEO-house-reference-'+definition]
    for other in scene.objects:
        if other.type=='MESH':other.hide_set(other!=obj)
    centre=sum((Vector(c) for c in obj.bound_box),Vector())/8
    camera=scene.camera
    camera.location=centre+Vector((7,-9,7))
    camera.rotation_euler=(centre-camera.location).to_track_quat('-Z','Y').to_euler()
    camera.data.ortho_scale=max(obj.dimensions.x,obj.dimensions.y)*1.35+1
    for area in bpy.context.screen.areas:
        if area.type=='VIEW_3D':
            area.spaces.active.region_3d.view_perspective='CAMERA'
            area.spaces.active.region_3d.view_camera_zoom=24
            area.spaces.active.shading.type='MATERIAL'
            area.spaces.active.shading.use_scene_lights=True
            area.spaces.active.shading.use_scene_world=True
    print(json.dumps({'preview':definition,'bounds':[list(v) for v in obj.bound_box]}))


def build():
    hashes={str(f.relative_to(ROOT)):sha(f) for f in APPROVED_FILES}
    mappings=json.loads((ROOT/'game/assets/environment/alderwake_town_mapping.json').read_text())['mappings']
    mappings=[m for m in mappings if 'definition_id' in m and m['definition_id']!='mill-road-schoolhouse']
    scene,previous=make_scene();reports=[]
    for mapping in mappings:
        b=Builder(mapping['definition_id']);details=create_house(b,mapping);obj=b.finish(scene);mesh=obj.data
        p=details.pop('polygon')
        assert all(math.isfinite(c) for v in mesh.vertices for c in v.co)
        assert all(face.area>1e-8 for face in mesh.polygons), obj.name+' degenerate face'
        assert all(triangle.area>=5e-7 for triangle in mesh.loop_triangles), obj.name+' sliver triangle'
        low=[v.co for v in mesh.vertices if v.co.z<=.12]
        assert all(inside(p,v,2e-6) for v in low), obj.name+' low footprint escape'
        assert all(any((v-c).length<1e-6 for v in low) for c in p), obj.name+' missing corner'
        bounds=[[min(v.co[i] for v in mesh.vertices) for i in range(3)],
                [max(v.co[i] for v in mesh.vertices) for i in range(3)]]
        assert abs(bounds[0][2])<1e-6 and abs(bounds[1][2]-mapping['height_m'])<1e-5, obj.name+' height'
        for axis in [0,1]:
            assert bounds[0][axis]>=min(v[axis] for v in p)-.16, obj.name+' minimum overhang'
            assert bounds[1][axis]<=max(v[axis] for v in p)+.16, obj.name+' maximum overhang'
        assert len(mesh.loop_triangles)<22000, obj.name+' triangle budget'
        reports.append({'definition_id':b.definition,'mesh_name':obj.name,'local_polygon_xz_m':mapping['local_polygon_xz_m'],
            'height_m':mapping['height_m'],'triangles':len(mesh.loop_triangles),'vertices':len(mesh.vertices),
            'blender_bounds_xyz_m':bounds,'godot_bounds_xyz_m':[[bounds[0][0],bounds[0][2],-bounds[1][1]],[bounds[1][0],bounds[1][2],-bounds[0][1]]],
            'part_counts':b.part_counts,**details})
    world=bpy.data.worlds.new('WRLD-houses-reference');world.use_nodes=True
    bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND')
    bg.inputs['Color'].default_value=(.20,.23,.28,1);bg.inputs['Strength'].default_value=.55;scene.world=world
    camera_data=bpy.data.cameras.new('CAM-houses-reference');camera=bpy.data.objects.new(camera_data.name,camera_data)
    camera['owner']=OWNER;scene.collection.objects.link(camera);camera_data.type='ORTHO';scene.camera=camera
    for name,pos,power,size in [('key',(-3,-4,8),1000,5),('fill',(4,2,6),600,4)]:
        data=bpy.data.lights.new('LGT-houses-'+name,type='AREA');light=bpy.data.objects.new(data.name,data)
        light['owner']=OWNER;scene.collection.objects.link(light);light.location=pos
        light.rotation_euler=(Vector((0,1,1))-light.location).to_track_quat('-Z','Y').to_euler()
        data.energy=power;data.shape='DISK';data.size=size
    scene.render.resolution_x=1200;scene.render.resolution_y=800;scene.render.resolution_percentage=100
    inspect_house('house-plaster-slate')
    report={'asset':'res://assets/environment/storybook/houses-reference-v1.glb','scene':SCENE_NAME,
        'definition_count':len(reports),'triangles':sum(r['triangles'] for r in reports),'mappings':reports,
        'materials':[name for name,_ in base.MATERIALS],
        'color_contract':'Color CORNER float grayscale .42..58 centered at .50; runtime controls palette and contrast',
        'uv_contract':'Metres; timber UV.y follows grain, roof UV.x ridge and UV.y slope',
        'roof_profile':{'leading_lip_height_m':.006,'leading_bevel_length_m':.018,'joint_width_m':.004,'overlap_m':.025},
        'night_pane_contract':'Original glass half-widths/centers retained; panes at .008m, behind original emissive overlays at .0095m',
        'approved_schoolhouse_sha256':hashes,'previous_scene_preserved':previous,
        'reference':'C:/Users/aldoc/Downloads/artbook-style.png','reference_sha256':sha(Path('C:/Users/aldoc/Downloads/artbook-style.png')),
        'scope':'Thirteen visual meshes; exact original ground footprints/heights. No collision/navigation/portal/terrain changes.'}
    (ROOT/'art/source/storybook/houses-reference-recipe.json').write_text(json.dumps(report,indent=2)+'\n')
    assert hashes=={str(f.relative_to(ROOT)):sha(f) for f in APPROVED_FILES}
    print(json.dumps({'scene':SCENE_NAME,'definitions':len(reports),'triangles':report['triangles'],
                      'per_definition':[(r['definition_id'],r['triangles']) for r in reports]}))
    return report


def export_verified():
    """Call after viewport checks of ordinary, skew, civic and service houses."""
    scene=bpy.data.scenes[SCENE_NAME];bpy.context.window.scene=scene
    for obj in scene.objects:
        obj.hide_set(False);obj.select_set(obj.type=='MESH')
    bpy.context.view_layer.objects.active=next(o for o in scene.objects if o.type=='MESH')
    glb=ROOT/'game/assets/environment/storybook/houses-reference-v1.glb'
    blend=ROOT/'art/source/storybook/houses-reference-v1.blend'
    bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,
        export_yup=True,export_animations=False,export_cameras=False,export_lights=False,
        export_materials='EXPORT',export_vertex_color='ACTIVE',export_normals=True,export_texcoords=True)
    assert glb.stat().st_size<15*1024*1024
    inspect_house('house-plaster-slate')
    bpy.data.libraries.write(str(blend),{scene})
    report=json.loads((ROOT/'art/source/storybook/houses-reference-recipe.json').read_text())
    assert report['approved_schoolhouse_sha256']=={str(f.relative_to(ROOT)):sha(f) for f in APPROVED_FILES}
    print(json.dumps({'glb_bytes':glb.stat().st_size,'glb_sha256':sha(glb),'blend_bytes':blend.stat().st_size,'approved_schoolhouse_unchanged':True}))


if __name__=='__main__':build()
