"""Build the one-house storybook pilot inside an inspected Blender session.

Run using Blender MCP after inspecting the scene. Does not reset the file or
touch the original town kit. Geometry follows the pinned schoolhouse footprint.
Godot replaces the seven named preview materials with its own painted shaders.
"""
import bpy
import bmesh
import json
import math
import random
import hashlib
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
SCENE_NAME = 'RF-HouseReference'
OWNER = 'schoolhouse-reference-v1'
SEED = 72111
POLYGON = [(-3.3125, -1.625), (2.90625, -1.625), (2.90625, -.15625), (-3.3125, -.15625)]
X0, X1, Y0, Y1 = -3.3125, 2.90625, .15625, 1.625
CX, CY = (X0 + X1) / 2, (Y0 + Y1) / 2
WALL_TOP, RIDGE_TOP, CHIMNEY_TOP = 1.55, 2.23, 2.46
MATERIALS = [
    ('MAT-house-plaster', (.70, .59, .41, 1)),
    ('MAT-house-roof', (.12, .21, .35, 1)),
    ('MAT-house-timber', (.16, .070, .025, 1)),
    ('MAT-house-stone', (.32, .33, .30, 1)),
    ('MAT-house-glass', (.22, .13, .043, 1)),
    ('MAT-house-door', (.23, .10, .034, 1)),
    ('MAT-house-iron', (.055, .058, .045, 1)),
]
PLASTER, ROOF, TIMBER, STONE, GLASS, DOOR, IRON = range(7)


def make_scene():
    previous = bpy.context.scene
    previous_name = previous.name
    old = bpy.data.scenes.get(SCENE_NAME)
    if old:
        assert old.get('owner') == OWNER, 'Unowned scene exists; inspect before replacing.'
        assert all(o.get('owner') == OWNER for o in old.objects), 'Unowned objects added; preserve edits.'
        if bpy.context.window.scene == old:
            bpy.context.window.scene = next(s for s in bpy.data.scenes if s != old)
        for obj in list(old.objects):
            data = obj.data
            bpy.data.objects.remove(obj, do_unlink=True)
            if isinstance(data, bpy.types.Mesh) and data.users == 0:
                bpy.data.meshes.remove(data)
        bpy.data.scenes.remove(old)
    scene = bpy.data.scenes.new(SCENE_NAME)
    scene['owner'] = OWNER
    bpy.context.window.scene = scene
    return scene, previous_name


class Builder:
    def __init__(self):
        self.vertices, self.faces, self.materials, self.colors, self.uvs = [], [], [], [], []
        self.part_counts = {}
        self.rng = random.Random(SEED)

    def shade(self, spread=.065):
        return self.rng.uniform(.5 - spread, .5 + spread)

    def face(self, points, material, shade=.5, uv=None):
        points = [Vector(p) for p in points]
        start = len(self.vertices)
        self.vertices.extend(tuple(p) for p in points)
        self.faces.append(tuple(range(start, start + len(points))))
        self.materials.append(material)
        self.colors.append(max(.42, min(.58, shade)))
        if uv is None:
            # Planar metres with local origin; no scale stretching.
            u = (points[1] - points[0]).normalized()
            normal = (points[1] - points[0]).cross(points[2] - points[0]).normalized()
            v = normal.cross(u)
            uv = [((p - points[0]).dot(u), (p - points[0]).dot(v)) for p in points]
        self.uvs.append(uv)

    def prism(self, ring, bottom, top, material, shade=.5, bevel=0, part='box'):
        self.part_counts[part] = self.part_counts.get(part, 0) + 1
        self.face([(x, y, bottom) for x, y in reversed(ring)], material, shade)
        self.face([(x, y, top) for x, y in ring], material, shade)
        for a, b in zip(ring, ring[1:] + ring[:1]):
            self.face([(a[0], a[1], bottom), (b[0], b[1], bottom),
                       (b[0], b[1], top), (a[0], a[1], top)], material, shade)

    def box(self, low, high, material, shade=.5, bevel=0, part='box', wood_axis=None):
        lo, hi = Vector(low), Vector(high)
        self.part_counts[part] = self.part_counts.get(part, 0) + 1
        # Beveled masonry uses two inner XY rings and the broad centre ring.
        if bevel > 0:
            b = min(bevel, min(hi - lo) * .24)
            x0, y0, z0 = lo
            x1, y1, z1 = hi
            ring = [(x0+b,y0),(x1-b,y0),(x1,y0+b),(x1,y1-b),
                    (x1-b,y1),(x0+b,y1),(x0,y1-b),(x0,y0+b)]
            if part in ('foundation_stone', 'chimney_stone'):
                # Narrow inset blocks need chamfered corners, not hidden bevel
                # rings along their embedded upper/lower surfaces.
                self.face([(*p,z0) for p in reversed(ring)],material,shade)
                self.face([(*p,z1) for p in ring],material,shade)
                for i in range(8):
                    j=(i+1)%8
                    self.face([(*ring[i],z0),(*ring[j],z0),(*ring[j],z1),(*ring[i],z1)],material,shade)
                return
            inner = [(x0+b,y0+b),(x1-b,y0+b),(x1-b,y0+b),(x1-b,y1-b),
                     (x1-b,y1-b),(x0+b,y1-b),(x0+b,y1-b),(x0+b,y0+b)]
            self.face([(x0+b,y0+b,z0),(x0+b,y1-b,z0),(x1-b,y1-b,z0),(x1-b,y0+b,z0)],material,shade)
            self.face([(x0+b,y0+b,z1),(x1-b,y0+b,z1),(x1-b,y1-b,z1),(x0+b,y1-b,z1)],material,shade)
            for i in range(8):
                j = (i+1) % 8
                self.face([(*ring[i],z0+b),(*ring[j],z0+b),(*ring[j],z1-b),(*ring[i],z1-b)],material,shade)
                for zinner,zouter,rev in [(z0,z0+b,True),(z1,z1-b,False)]:
                    pts=[(*inner[i],zinner),(*inner[j],zinner),(*ring[j],zouter),(*ring[i],zouter)]
                    pts=list(dict.fromkeys(pts))
                    if len(pts)>=3: self.face(pts[::-1] if rev else pts,material,shade*.99)
            return
        pts=[(lo.x,lo.y,lo.z),(hi.x,lo.y,lo.z),(hi.x,hi.y,lo.z),(lo.x,hi.y,lo.z),
             (lo.x,lo.y,hi.z),(hi.x,lo.y,hi.z),(hi.x,hi.y,hi.z),(lo.x,hi.y,hi.z)]
        for indices in [(3,2,1,0),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
            face=[pts[i] for i in indices]
            uv=None
            if wood_axis is not None:
                axis=Vector(wood_axis).normalized()
                normal=(Vector(face[1])-Vector(face[0])).cross(Vector(face[2])-Vector(face[0])).normalized()
                across=normal.cross(axis)
                if across.length > .1:
                    across.normalize()
                    uv=[(Vector(p).dot(across),Vector(p).dot(axis)) for p in face]
            self.face(face,material,shade,uv)

    def beam(self, start, end, width, depth, material=TIMBER, shade=.5, part='beam'):
        a,b=Vector(start),Vector(end)
        length=(b-a).length
        along=(b-a).normalized()
        cross=along.cross(Vector((0,0,1)))
        if cross.length < .01: cross=Vector((1,0,0))
        cross.normalize()
        other=along.cross(cross).normalized()
        pts=[a+cross*x*width/2+other*y*depth/2+along*z*length
             for z in [0,1] for x,y in [(-1,-1),(1,-1),(1,1),(-1,1)]]
        self.part_counts[part]=self.part_counts.get(part,0)+1
        for ids in [(3,2,1,0),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
            face=[pts[i] for i in ids]
            uv=[((p-a).dot(cross)+(p-a).dot(other),(p-a).dot(along)) for p in face]
            self.face(face,material,shade,uv)

    def finish(self, scene):
        mesh=bpy.data.meshes.new('MESH-schoolhouse-reference-v1')
        mesh.from_pydata(self.vertices, [], self.faces)
        mesh.update()
        assert not mesh.validate(), 'Invalid mesh generated'
        ca=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='CORNER')
        uv=mesh.uv_layers.new(name='UV-metre')
        for polygon, material, color, uvs in zip(mesh.polygons,self.materials,self.colors,self.uvs):
            polygon.material_index=material
            polygon.use_smooth=False
            for loop, texcoord in zip(polygon.loop_indices,uvs):
                ca.data[loop].color=(color,color,color,1)
                uv.data[loop].uv=texcoord
        # Components are built independently; joining close vertices inside each
        # component makes outward normal recalculation well-defined.
        bm=bmesh.new();bm.from_mesh(mesh)
        bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(mesh);bm.free();mesh.update();mesh.calc_loop_triangles()
        obj=bpy.data.objects.new('GEO-schoolhouse-reference-v1',mesh)
        obj['owner']=OWNER;obj['source_definition_id']='mill-road-schoolhouse'
        obj['visual_only']=True
        scene.collection.objects.link(obj)
        for name,color in MATERIALS:
            mat=bpy.data.materials.new(name)
            # Rebuilds may retain orphan materials, but exported slot names stay stable.
            old=bpy.data.materials.get(name)
            if old != mat and old is not None and old.users == 0:
                bpy.data.materials.remove(old)
                mat.name=name
            mat.use_nodes=True;mat.diffuse_color=color
            bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
            bsdf.inputs['Base Color'].default_value=color
            bsdf.inputs['Roughness'].default_value=.92
            bsdf.inputs['Metallic'].default_value=0
            mesh.materials.append(mat)
        return obj


def facade_window(b, center, along, outward, halfwidth):
    c,d,n=Vector(center),Vector(along),Vector(outward)
    def block(u0,u1,z0,z1,offset,depth,material,shade=.5,part='window_frame'):
        # All four walls axis-aligned; assign grain along the longest member.
        points=[c+d*u+n*o+Vector((0,0,z)) for u in [u0,u1] for o in [offset,offset+depth] for z in [z0,z1]]
        lo=[min(p[i] for p in points) for i in range(3)]
        hi=[max(p[i] for p in points) for i in range(3)]
        axis=(0,0,1) if z1-z0 > u1-u0 else along
        b.box(lo,hi,material,shade,part=part,wood_axis=axis if material==TIMBER else None)
    # Dark recess under separate panes. Frames cast real local depth shadows.
    block(-halfwidth-.032,halfwidth+.032,-.25,.27,.005,.009,TIMBER,.43,'window_recess')
    for u0,u1 in [(-halfwidth,-.023),(.023,halfwidth)]:
        for z0,z1 in [(-.22,-.025),(.025,.24)]:
            block(u0,u1,z0,z1,.014,.003,GLASS,b.shade(.04),'window_pane')
    for u in [-halfwidth-.050,halfwidth+.002]:
        block(u,u+.048,-.267,.287,.012,.040,TIMBER,b.shade(.025))
    for z in [-.267,.24]:
        block(-halfwidth-.052,halfwidth+.05,z,z+.047,.012,.04,TIMBER,b.shade(.025))
    block(-.022,.022,-.22,.24,.018,.03,TIMBER,.49)
    block(-halfwidth,halfwidth,-.022,.022,.018,.030,TIMBER,.5)
    block(-halfwidth-.066,halfwidth+.066,-.295,-.255,.016,.084,TIMBER,.53,'window_sill')


def create_house(b):
    # Base stays on exact catalog polygon. Individual stones inset into that base.
    # Keep exact low contact corners, but recess the mortar core behind stones.
    # A full-height core at the outer footprint would fight their front faces.
    b.box((X0,Y0,0),(X1,Y1,.008),STONE,.42,part='foundation_footing')
    b.box((X0+.018,Y0+.018,.008),(X1-.018,Y1-.018,.22),STONE,.42,part='foundation_core')
    for row in range(2):
        z0=.013+row*.102
        for face in ['front','back']:
            step=.32; start=X0-step*.5*(row%2)
            for k in range(math.ceil((X1-start)/step)):
                lo=max(X0+.006,start+k*step+.006);hi=min(X1-.006,start+(k+1)*step-.006)
                if hi<=lo:continue
                y0,y1=(Y0,Y0+.040) if face=='front' else (Y1-.040,Y1)
                b.box((lo,y0,z0),(hi,y1,z0+.091),STONE,b.shade(.06),.008,'foundation_stone')
        for x in [X0,X1]:
            step=.29;start=Y0-step*.5*(row%2)
            for k in range(math.ceil((Y1-start)/step)):
                lo=max(Y0+.013,start+k*step+.006);hi=min(Y1-.013,start+(k+1)*step-.006)
                if hi<=lo:continue
                b.box((x if x==X0 else x-.040,lo,z0),(x+.040 if x==X0 else x,hi,z0+.091),STONE,b.shade(.06),.008,'foundation_stone')
    b.box((X0+.008,Y0+.008,.21),(X1-.008,Y1-.008,WALL_TOP),PLASTER,.51,part='plaster_body')
    # Closed gables.
    a=[(Y0+.008,WALL_TOP),(Y1-.008,WALL_TOP),(CY,RIDGE_TOP-.035)]
    for x,other in [(X0+.008,X0+.027),(X1-.008,X1-.027)]:
        b.face([(x,y,z) for y,z in a],PLASTER,.50)
        b.face([(other,y,z) for y,z in reversed(a)],PLASTER,.50)
        for (ya,za),(yb,zb) in zip(a,a[1:]+a[:1]):b.face([(x,ya,za),(x,yb,zb),(other,yb,zb),(other,ya,za)],PLASTER,.50)
    # Posts break broad cream panels at structural bays; door center retained.
    door_width=(X1-X0)*.14
    for y in [Y0,Y1]:
        postxs=[X0+.027,CX-door_width/2-.025,CX+door_width/2+.025,X1-.027]
        for x in postxs:
            b.box((x-.035,y-.024,.208),(x+.035,y+.024,1.558),TIMBER,b.shade(.018),part='timber_post',wood_axis=(0,0,1))
        b.box((X0-.005,y-.024,.218),(X1+.005,y+.024,.29),TIMBER,.48,part='lower_sill',wood_axis=(1,0,0))
        b.box((X0-.020,y-.025,1.472),(X1+.020,y+.025,1.558),TIMBER,.48,part='wall_plate',wood_axis=(1,0,0))
    for x in [X0,X1]:
        b.box((x-.023,Y0-.022,.218),(x+.023,Y1+.022,.29),TIMBER,.48,part='gable_sill',wood_axis=(0,1,0))
        b.box((x-.024,Y0-.027,1.472),(x+.024,Y1+.027,1.558),TIMBER,.48,part='gable_tie',wood_axis=(0,1,0))
        b.box((x-.026,CY-.032,1.50),(x+.026,CY+.032,RIDGE_TOP-.012),TIMBER,.48,part='gable_kingpost',wood_axis=(0,0,1))
        for edge_y in [Y0,Y1]:
            b.beam((x,edge_y,1.52),(x,CY,RIDGE_TOP-.020),.052,.068,TIMBER,.48,'gable_rake')
    # Window centers match original edge fractions and heights. End-wall panes
    # widen slightly from 0.2203 to 0.31 m, while their centers remain fixed.
    footprint=[Vector((x,-z,0)) for x,z in POLYGON]
    anchors=[]
    for edge in range(4):
        a,c=footprint[edge],footprint[(edge+1)%4]
        d=(c-a).normalized();n=Vector((-d.y,d.x,0))
        for fraction in [.23,.77]:
            center=a.lerp(c,fraction)+Vector((0,0,.77))
            halfwidth=.28 if edge in [0,2] else .155
            facade_window(b,center,d,n,halfwidth)
            anchors.append([center.x,center.z,-center.y])
    # Inset planked front door, frame proud of plaster, black latch details.
    left,right=CX-door_width/2,CX+door_width/2
    b.box((left-.045,Y0-.032,.195),(right+.045,Y0+.005,1.14),TIMBER,.43,part='door_recess',wood_axis=(0,0,1))
    for i in range(10):
        x0=left+i*door_width/10+.004;x1=left+(i+1)*door_width/10-.004
        b.box((x0,Y0-.044,.213),(x1,Y0-.033,1.095),DOOR,b.shade(.05),part='door_plank',wood_axis=(0,0,1))
    for x in [left-.054,right+.003]:
        b.box((x,Y0-.065,.199),(x+.051,Y0+.004,1.164),TIMBER,.48,part='door_jamb',wood_axis=(0,0,1))
    b.box((left-.058,Y0-.066,1.106),(right+.058,Y0+.005,1.173),TIMBER,.5,part='door_lintel',wood_axis=(1,0,0))
    for z in [.36,.90]:
        b.box((left+.065,Y0-.049,z),(left+.29,Y0-.045,z+.019),IRON,.5,part='door_strap')
    b.box((right-.13,Y0-.071,.605),(right-.105,Y0-.045,.653),IRON,.5,part='door_latch')
    b.box((left-.023,Y0-.067,.198),(right+.023,Y0+.010,.225),STONE,.51,.006,'threshold')
    # Roof is a real closed substrate plus thin overlapping staggered tiles.
    rx0,rx1=X0-.115,X1+.115
    eave_front,eave_back=Y0-.120,Y1+.120
    eave_height=1.510
    for side,ey in enumerate([eave_front,eave_back]):
        sign=1 if side==0 else -1
        origin=Vector((rx0,ey,eave_height))
        slope=Vector((0,CY-ey,RIDGE_TOP-eave_height))
        slope_length=slope.length;tangent=slope.normalized()
        normal=Vector((0,-tangent.z*sign,abs(tangent.y)))
        # Continuous dark underroof, sides included, never a gap at tile seams.
        for low in [0]:
            vertices=[Vector((x,ey,eave_height)) for x in [rx0,rx1]]+[Vector((x,CY,RIDGE_TOP)) for x in [rx1,rx0]]
            bottom=[p-Vector((0,0,.045)) for p in vertices]
            b.face(vertices,ROOF,.42);b.face(bottom[::-1],ROOF,.42)
            for i in range(4):j=(i+1)%4;b.face([bottom[i],bottom[j],vertices[j],vertices[i]],ROOF,.42)
        cols,rows=20,8
        width=(rx1-rx0)/cols
        for row in range(rows):
            start=rx0-width*.5*(row%2)
            for col in range(cols+(row%2)):
                xa=max(rx0,start+col*width+.002)
                xb=min(rx1,start+(col+1)*width-.002)
                if xb-xa<.01:continue
                s0=row/rows*slope_length
                s1=min(slope_length,(row+1)/rows*slope_length+.025)
                # A tiny corner skew removes machine-perfect roof borders.
                shift=b.rng.uniform(-.005,.005)
                tint=b.shade(.064)
                # A six-millimetre vertical lip meets an 18 mm top chamfer.
                # This keeps a raised overlapping tile silhouette without the
                # black, downward-facing 20 mm line aliasing at game zoom.
                rings=[]
                for x,skew in [(xa,0),(xb,shift)]:
                    ring=[]
                    for s,h in [(s0+skew,.010),(s1,.002),(s1,.008),
                                (s0+.018+skew,.024),(s0+skew,.016)]:
                        ring.append(origin+Vector((x-rx0,0,0))+tangent*s+normal*h)
                    rings.append(ring)
                b.face(rings[0][::-1],ROOF,tint*.98)
                b.face(rings[1],ROOF,tint*.98)
                for i in range(5):
                    j=(i+1)%5
                    pts=[rings[0][i],rings[1][i],rings[1][j],rings[0][j]]
                    uv=[(p.x,(p-origin).dot(tangent)) for p in pts]
                    b.face(pts,ROOF,tint if i in [2,3] else tint*.98,uv)
                b.part_counts['roof_tile']=b.part_counts.get('roof_tile',0)+1
        b.beam((rx0-.008,ey,eave_height-.018),(rx1+.008,ey,eave_height-.018),.065,.078,TIMBER,.45,'eave_fascia')
        for x in [rx0,rx1]:b.beam((x,ey,eave_height-.018),(x,CY,RIDGE_TOP+.005),.061,.065,TIMBER,.45,'roof_rake')
    # Ridge tile caps cover the thin seam with a quiet broken rhythm.
    for i in range(22):
        lo=rx0+i*(rx1-rx0)/22+.002;hi=rx0+(i+1)*(rx1-rx0)/22-.002
        b.box((lo,CY-.040,RIDGE_TOP+.002),(hi,CY+.040,RIDGE_TOP+.040),ROOF,b.shade(.042),0,'ridge_cap')
    # Chimney masonry stays at original center and maximum height.
    b.box((CX-.168,CY-.168,1.93),(CX+.168,CY+.168,2.437),STONE,.43,part='chimney_core')
    for row in range(4):
        low=1.94+row*.119
        for direction in [0,1]:
            for side in [-1,1]:
                y=CY+side*.169
                shift=.5*(row%2)
                for k in range(2+(row%2)):
                    lo=max(CX-.174,CX-.174+(k-shift)*.174+.003)
                    hi=min(CX+.174,CX-.174+(k+1-shift)*.174-.003)
                    if hi<=lo:continue
                    a=(lo,y-.012,low);c=(hi,y+.012,low+.111)
                    if direction:
                        a=(CX+(a[1]-CY),CY+(a[0]-CX),a[2]);c=(CX+(c[1]-CY),CY+(c[0]-CX),c[2])
                    b.box(a,c,STONE,b.shade(.053),.004,'chimney_stone')
    b.box((CX-.191,CY-.191,2.422),(CX+.191,CY+.191,CHIMNEY_TOP),STONE,.55,.009,'chimney_cap')
    return anchors


def preview(scene,obj):
    world=bpy.data.worlds.new('WRLD-house-reference')
    world.use_nodes=True
    bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND')
    bg.inputs['Color'].default_value=(.20,.23,.28,1)
    bg.inputs['Strength'].default_value=.55
    scene.world=world
    camera_data=bpy.data.cameras.new('CAM-house-reference')
    camera=bpy.data.objects.new(camera_data.name,camera_data)
    camera['owner']=OWNER;scene.collection.objects.link(camera)
    camera.location=(7,-9,7)
    camera.rotation_euler=(Vector((CX,CY,1.12))-camera.location).to_track_quat('-Z','Y').to_euler()
    camera_data.type='ORTHO';camera_data.ortho_scale=8.0;scene.camera=camera
    for name,pos,power,size in [('key',(-3,-4,8),1000,5),('fill',(4,2,6),600,4)]:
        data=bpy.data.lights.new('LGT-house-'+name,type='AREA')
        light=bpy.data.objects.new(data.name,data);light['owner']=OWNER
        scene.collection.objects.link(light)
        light.location=pos;light.rotation_euler=(Vector((CX,CY,1))-light.location).to_track_quat('-Z','Y').to_euler()
        data.energy=power;data.shape='DISK';data.size=size
    scene.render.resolution_x=1200;scene.render.resolution_y=800;scene.render.resolution_percentage=100
    obj.select_set(True);bpy.context.view_layer.objects.active=obj
    for area in bpy.context.screen.areas:
        if area.type=='VIEW_3D':
            space=area.spaces.active
            space.region_3d.view_perspective='CAMERA'
            space.shading.type='MATERIAL'
            space.shading.use_scene_lights=True;space.shading.use_scene_world=True


def build():
    scene,previous=make_scene()
    builder=Builder();anchors=create_house(builder);obj=builder.finish(scene)
    preview(scene,obj)
    mesh=obj.data
    assert len(mesh.loop_triangles)<16000
    assert all(math.isfinite(c) for v in mesh.vertices for c in v.co)
    assert all(p.area>.00000001 for p in mesh.polygons)
    low_vertices=[v.co for v in mesh.vertices if v.co.z<=.12]
    assert all(X0-.000001<=v.x<=X1+.000001 and Y0-.000001<=v.y<=Y1+.000001 for v in low_vertices)
    assert all(any((v-Vector((x,y,0))).length<.000001 for v in low_vertices) for x,y in [(X0,Y0),(X0,Y1),(X1,Y0),(X1,Y1)])
    bounds=[[min(v.co[i] for v in mesh.vertices) for i in range(3)],
            [max(v.co[i] for v in mesh.vertices) for i in range(3)]]
    assert abs(bounds[0][2])<.00001 and abs(bounds[1][2]-2.46)<.00001
    report={
        'asset': 'res://assets/environment/storybook/schoolhouse-reference-v1.glb',
        'mesh_name': obj.name, 'scene': scene.name,'seed':SEED,'previous_scene_preserved':previous,
        'target_prop_id':'mill-road-schoolhouse-exterior-building','definition_id':'mill-road-schoolhouse',
        'local_polygon_xz_m':POLYGON,'blender_bounds_xyz_m':bounds,
        'godot_bounds_xyz_m':[[bounds[0][0],bounds[0][2],-bounds[1][1]],[bounds[1][0],bounds[1][2],-bounds[0][1]]],
        'height_m':CHIMNEY_TOP,'vertices':len(mesh.vertices),'triangles':len(mesh.loop_triangles),
        'materials':[m.name for m in mesh.materials], 'part_counts':builder.part_counts,
        'roof_tile_profile':{'rows_per_slope':8,'columns':20,'overlap_m':.025,'joint_width_m':.004,'leading_lip_height_m':.006,'leading_bevel_length_m':.018,'maximum_offset_m':.024},
        'color_contract':'Color CORNER float RGB grayscale 0.42..0.58 centered at 0.50; runtime controls contrast independently',
        'uv_contract':'UV-metre: metres on every face; timber UV.y follows beam length; roof UV.x ridge direction, UV.y slope',
        'windows':{'centers_local_xyz_m':anchors,'center_policy':'all original eight centers preserved','front_back_width_m':.56,'gable_width_m':.31,'emission':'none; schoolhouse has no light mapping'},
        'door':{'center_local_xyz_m':[CX,.645,-Y0],'original_width_m':(X1-X0)*.14,'policy':'south centered door retained, no gameplay doorway change'},
        'provenance':{'reference':'C:/Users/aldoc/Downloads/artbook-style.png','reference_sha256':hashlib.sha256(Path('C:/Users/aldoc/Downloads/artbook-style.png').read_bytes()).hexdigest(),'method':'Original Blender geometry authored against supplied style reference and existing game footprint; no external models or textures'},
        'scope':'one visual mesh; no collision/navigation/terrain changes; unseen north facade uses same construction',
    }
    (ROOT/'art/source/storybook').mkdir(parents=True,exist_ok=True)
    (ROOT/'art/source/storybook/schoolhouse-reference-recipe.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report))
    return scene,obj


def export_verified():
    """Call only after checking live viewport and object bounds."""
    scene=bpy.data.scenes[SCENE_NAME]
    obj=scene.objects['GEO-schoolhouse-reference-v1']
    bpy.context.window.scene=scene
    for other in scene.objects:other.select_set(False)
    obj.select_set(True);bpy.context.view_layer.objects.active=obj
    glb=ROOT/'game/assets/environment/storybook/schoolhouse-reference-v1.glb'
    blend=ROOT/'art/source/storybook/schoolhouse-reference-v1.blend'
    bpy.ops.export_scene.gltf(filepath=str(glb),export_format='GLB',use_selection=True,use_active_scene=True,
        export_yup=True,export_animations=False,export_cameras=False,export_lights=False,
        export_materials='EXPORT',export_vertex_color='ACTIVE',export_normals=True,export_texcoords=True)
    bpy.data.libraries.write(str(blend),{scene})
    print(json.dumps({'glb':str(glb),'glb_bytes':glb.stat().st_size,'glb_sha256':hashlib.sha256(glb.read_bytes()).hexdigest(),'blend':str(blend),'blend_bytes':blend.stat().st_size}))


if __name__=='__main__':
    build()
