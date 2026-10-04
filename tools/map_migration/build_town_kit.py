"""Run in inspected live Blender; isolated editable kit, exact pinned footprints.

Shared wall/beam/window/shingle constructors deliberately adapt source sprites
to shallow overhead-friendly 3D buildings. No imported physics or new doors.
"""
import bpy, bmesh, json, math
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
layout = json.loads((ROOT/'game/content/maps/alderwake_layout.json').read_text(encoding="utf-8"))
definitions = [d for d in layout['catalog_reference'] if d['kind']=='structure']
previous = bpy.context.scene
assert 'RF-M013-TownKit' not in bpy.data.scenes, 'Inspect existing kit before rerun'
(ROOT/'builds/m013').mkdir(parents=True, exist_ok=True)
bpy.data.libraries.write(str(ROOT/'builds/m013/preserved-live-work.blend'), set(bpy.data.scenes))
scene = bpy.data.scenes.new('RF-M013-TownKit')
bpy.context.window.scene = scene
mat = bpy.data.materials.new('MAT-M013-town_vertex_palette'); mat.use_nodes=True
bsdf = next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Roughness'].default_value=.88; bsdf.inputs['Metallic'].default_value=0
attribute = mat.node_tree.nodes.new('ShaderNodeVertexColor'); attribute.layer_name='Color'
mat.node_tree.links.new(attribute.outputs['Color'], bsdf.inputs['Base Color'])
wood=(.24,.105,.043); stone=(.39,.38,.31); glass=(.72,.44,.13)
slate=(.13,.20,.29); terra=(.60,.19,.065); plaster=(.67,.55,.35)
mapping=[]

class Builder:
    def __init__(self): self.vertices=[]; self.faces=[]; self.colors=[]
    def face(self, points, color):
        start=len(self.vertices); self.vertices.extend(tuple(p) for p in points)
        self.colors.extend([tuple(color)+(1,)]*len(points)); self.faces.append(tuple(range(start,start+len(points))))
    def prism(self, poly, low, high, color):
        self.face([(x,-z,low) for x,z in reversed(poly)],color)
        self.face([(x,-z,high) for x,z in poly],color)
        for a,b in zip(poly,poly[1:]+poly[:1]):
            self.face([(a[0],-a[1],low),(b[0],-b[1],low),(b[0],-b[1],high),(a[0],-a[1],high)],color)
    def box(self,x,z,w,d,low,high,color):
        self.prism([(x,z),(x+w,z),(x+w,z+d),(x,z+d)],low,high,color)
    def patch(self,a,b,t0,t1,low,high,color,offset=.003):
        # Overlay wall detail, offset <=1cm; never a blocker.
        av,bv=Vector(a),Vector(b); delta=bv-av; normal=Vector((delta.y,-delta.x)).normalized()*offset
        p=av+delta*t0+normal;q=av+delta*t1+normal
        self.face([(p.x,-p.y,low),(q.x,-q.y,low),(q.x,-q.y,high),(p.x,-p.y,high)],color)
    def finish(self,name):
        mesh=bpy.data.meshes.new(name);mesh.from_pydata(self.vertices,[],self.faces);mesh.update()
        ca=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
        for i,c in enumerate(self.colors):ca.data[i].color=c
        bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
        obj=bpy.data.objects.new(name,mesh);scene.collection.objects.link(obj);mesh.materials.append(mat)
        mesh.calc_loop_triangles(); return obj,len(mesh.loop_triangles)

for definition in definitions:
    id=definition['id']; c=definition['collision']
    if id.startswith('dock-'): continue  # Shared unit planks, assembled from approved floor rectangles.
    if c['kind']=='box':
        x,z,w,d=[c[k]/32 for k in ['left','top','width','height']]
        poly=[(x,z),(x+w,z),(x+w,z+d),(x,z+d)]
    else: poly=[(p['x']/32,p['y']/32) for p in c['points']]
    civic=id in ['alderwake-hall','lantern-rest','mayor-vale-home']
    shop=id in ['reed-chandlery','tess-general-goods']
    wall_height=2.15 if civic else 1.55
    if id=='net-shed':wall_height=1.30
    if id=='passenger-control-shelter':wall_height=.85
    roof_height=wall_height+(.78 if civic else .68)
    roof=terra if ('terracotta' in id or id in ['alderwake-hall','mayor-vale-home','tess-general-goods']) else slate
    wall=(.17,.32,.28) if id in ['house-dockside','net-shed'] else plaster
    if id=='house-woodland-cottage':wall=(.32,.29,.14);roof=(.19,.27,.17)
    builder=Builder();builder.prism(poly,0,.19,stone);builder.prism(poly,.19,wall_height,wall)
    # Shared repeated beam/window modules follow every polygon edge, not its bbox.
    for edge,(a,b) in enumerate(zip(poly,poly[1:]+poly[:1])):
        builder.patch(a,b,0,1,.20,.30,wood);builder.patch(a,b,0,1,wall_height-.12,wall_height,wood)
        length=(Vector(b)-Vector(a)).length
        for t in [0,.5,1]:builder.patch(a,b,max(0,t-.012),min(1,t+.012),.2,wall_height,wood,.005)
        levels=[.75,1.55] if civic else [.77]
        for level in levels:
            for t in [.23,.77]:
                span=min(.075,.28/length)
                builder.patch(a,b,t-span-.012,t+span+.012,level-.27,level+.29,wood,.007)
                builder.patch(a,b,t-span,t+span,level-.22,level+.24,glass,.009)
                builder.patch(a,b,t-.009,t+.009,level-.22,level+.24,wood,.010)
                builder.patch(a,b,t-span,t+span,level-.025,level+.025,wood,.010)
    # Front door stays on south edge, never extends into reserved service/door pad.
    a,b=poly[2],poly[3]
    builder.patch(a,b,.43,.57,.19,1.24 if civic else 1.10,wood,.011)
    for t in [.445,.48,.515,.55]:builder.patch(a,b,t,t+.003,.23,1.06,(.36,.18,.07),.013)
    # Gable ridge runs east-west. Quad topology preserves skew dockside/inn bases.
    p=[Vector((x,-z,wall_height)) for x,z in poly]
    ridge0=(p[0]+p[3])/2;ridge1=(p[1]+p[2])/2;ridge0.z=roof_height;ridge1.z=roof_height
    builder.face([p[0],p[3],ridge0],wall);builder.face([p[1],ridge1,p[2]],wall)
    for quad in [[p[0],p[1],ridge1,ridge0],[p[3],p[2],ridge1,ridge0]]:
        builder.face(quad,roof)
        # Colored, individually inset tiles provide portable roof texture without images.
        columns=max(4,math.ceil((quad[1]-quad[0]).length/.35));rows=5
        for row in range(rows):
            for col in range(columns):
                pts=[]
                for u,v in [(col/columns+.002,row/rows+.009),((col+1)/columns-.002,row/rows+.009),((col+1)/columns-.002,(row+1)/rows-.009),(col/columns+.002,(row+1)/rows-.009)]:
                    q=quad[0].lerp(quad[1],u).lerp(quad[3].lerp(quad[2],u),v);q.z+=.005;pts.append(q)
                shade=.91+.14*((col+2*row)%4)/3;builder.face(pts,tuple(v*shade for v in roof))
    # Chimney stays inside footprint; civic turret likewise.
    centre=sum((Vector(p) for p in poly),Vector((0,0)))/4
    builder.box(centre.x-.18,centre.y-.18,.36,.36,wall_height,roof_height+.23,stone)
    if civic:
        builder.box(centre.x-.31,centre.y-.24,.62,.48,roof_height-.12,roof_height+.40,plaster)
        builder.box(centre.x-.33,centre.y-.26,.66,.52,roof_height+.4,roof_height+.48,roof)
    if shop:
        # Striped shop fascia entirely on existing south-facing wall.
        for n in range(12):builder.patch(a,b,n/12,(n+1)/12,1.24,1.48,(.24,.37,.22) if n%2 else (.83,.72,.48),.015)
    obj,tris=builder.finish('GEO-'+id);obj['source_definition_id']=id
    mapping.append({'definition_id':id,'mesh_name':obj.name,'local_polygon_xz_m':poly,'height_m':max(v.co.z for v in obj.data.vertices),'triangles':tris,'adaptation':'catalog-footprint gabled timber/plaster exterior; compressed height; no new collision'})

# Unit deck/quay modules reuse geometry, sized by approved physical rectangles.
for id,color in [('dock-plank-module',(.40,.22,.085)),('quay-stone-module',(.40,.43,.40))]:
    builder=Builder();builder.box(0,0,1,1,-.06,.008,color)
    for n in range(5):
        shade=.88+.05*n;builder.box(.002,n*.2+.003,.996,.194,.008,.022,tuple(v*shade for v in color))
    obj,tris=builder.finish('GEO-'+id)
    mapping.append({'module_id':id,'mesh_name':obj.name,'height_m':.022,'triangles':tris,'rect_xz_m':[0,0,1,1]})

world=bpy.data.worlds.new('M013-preview-world');world.use_nodes=True
background=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');background.inputs['Color'].default_value=(.22,.25,.28,1);background.inputs['Strength'].default_value=.7;scene.world=world
bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects:obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(ROOT/'game/assets/environment/alderwake_town_kit.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False)
(ROOT/'game/assets/environment/alderwake_town_mapping.json').write_text(json.dumps({'snapshot_id':layout['provenance']['snapshot_id'],'asset':'res://assets/environment/alderwake_town_kit.glb','mappings':mapping,'dock_definitions':['dock-straight','dock-junction'],'dock_policy':'approved M006 rectangles only; shared metre planks'},indent=2)+'\n')
for i,obj in enumerate(list(scene.objects)):obj.location=((i%4)*8,(i//4)*5,0)
camera_data=bpy.data.cameras.new('CAM-M013-gallery');camera=bpy.data.objects.new(camera_data.name,camera_data);scene.collection.objects.link(camera)
camera.location=(12,-15,26);camera.rotation_euler=(Vector((12,7,1))-camera.location).to_track_quat('-Z','Y').to_euler();camera_data.type='ORTHO';camera_data.ortho_scale=34;scene.camera=camera
for name,loc,energy in [('key',(8,-3,15),2700),('fill',(22,11,15),2200)]:
    data=bpy.data.lights.new('LGT-M013-'+name,'AREA');data.energy=energy;data.size=12;obj=bpy.data.objects.new(data.name,data);scene.collection.objects.link(obj);obj.location=loc;obj.rotation_euler=(Vector((12,6,0))-obj.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=1400;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
(ROOT/'docs/evidence/M013').mkdir(parents=True,exist_ok=True)
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'docs/evidence/M013/blender-gallery.png')
try:scene.render.engine='BLENDER_EEVEE'
except TypeError:scene.render.engine='BLENDER_EEVEE_NEXT'
bpy.data.libraries.write(str(ROOT/'art/source/alderwake_town_kit.blend'),{scene})
print(json.dumps({'scene':scene.name,'meshes':len(mapping),'triangles':sum(m['triangles'] for m in mapping),'previous_scene':previous.name,'preserved_scenes':[(s.name,len(s.objects)) for s in bpy.data.scenes if s!=scene]}))
