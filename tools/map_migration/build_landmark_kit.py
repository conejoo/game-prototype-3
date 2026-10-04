"""M014 isolated live Blender authoring. Physical/source wrappers remain authoritative.

Godot X/Z ground maps to Blender X/-Y; up is Blender Z. Portable vertex colors.
Inspect live scene, preserve all user scenes, refuse populated reruns.
"""
import bpy, bmesh, json, math
from pathlib import Path
from mathutils import Vector
ROOT=Path('D:/development/game-dev-blender/returning-fair-prototype')
layout=json.loads((ROOT/'game/content/maps/alderwake_layout.json').read_text(encoding='utf-8'))
previous=bpy.context.scene
assert 'RF-M014-LandmarkKit' not in bpy.data.scenes, 'Inspect existing kit before rerun'
bpy.data.libraries.write(str(ROOT/'builds/m014/preserved-live-work.blend'),set(bpy.data.scenes))
scene=bpy.data.scenes.new('RF-M014-LandmarkKit');bpy.context.window.scene=scene
mat=bpy.data.materials.new('MAT-M014-landmark_vertex_palette');mat.use_nodes=True
bsdf=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Roughness'].default_value=.88;bsdf.inputs['Metallic'].default_value=0
attribute=mat.node_tree.nodes.new('ShaderNodeVertexColor');attribute.layer_name='Color'
mat.node_tree.links.new(attribute.outputs['Color'],bsdf.inputs['Base Color'])
wood=(.36,.17,.055);dark=(.17,.075,.028);grain=(.45,.24,.08);iron=(.13,.15,.14)
stone=(.39,.43,.43);cap=(.65,.59,.39);pool=(.06,.16,.56);ripple=(.12,.46,.68)
mapping=[]
class Builder:
 def __init__(self):self.vertices=[];self.faces=[];self.colors=[]
 def face(self,points,color):
  start=len(self.vertices);self.vertices.extend(tuple(p) for p in points);self.colors.extend([tuple(color)+(1,)]*len(points));self.faces.append(tuple(range(start,start+len(points))))
 def prism(self,poly,low,high,color):
  self.face([(x,-z,low) for x,z in reversed(poly)],color);self.face([(x,-z,high) for x,z in poly],color)
  for a,b in zip(poly,poly[1:]+poly[:1]):self.face([(a[0],-a[1],low),(b[0],-b[1],low),(b[0],-b[1],high),(a[0],-a[1],high)],color)
 def box(self,x,z,w,d,low,high,color):self.prism([(x,z),(x+w,z),(x+w,z+d),(x,z+d)],low,high,color)
 def finish(self,id,policy):
  name='GEO-'+id;mesh=bpy.data.meshes.new(name);mesh.from_pydata(self.vertices,[],self.faces);mesh.update()
  ca=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
  for i,c in enumerate(self.colors):ca.data[i].color=c
  bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
  mesh.calc_loop_triangles();obj=bpy.data.objects.new(name,mesh);scene.collection.objects.link(obj);mesh.materials.append(mat)
  obj['landmark_module_id']=id;mapping.append({'module_id':id,'mesh_name':name,'triangles':len(mesh.loop_triangles),'bounds_xzy_m':[[min(v.co.x for v in mesh.vertices),min(-v.co.y for v in mesh.vertices),min(v.co.z for v in mesh.vertices)],[max(v.co.x for v in mesh.vertices),max(-v.co.y for v in mesh.vertices),max(v.co.z for v in mesh.vertices)]],'adaptation':policy});return obj
# 6x3 deck: continuous substrate and flush planks, no visual steps/new corridor.
b=Builder();b.box(0,0,6,3,-.12,.008,dark)
for n in range(24):
 x=n*.25;b.box(x+.003,0,.244,3,.008,.022,tuple(v*(.92+.025*(n%5)) for v in wood))
 for z in [.34,1.45,2.58]:b.box(x+.065,z,.115,.007,.022,.023,grain)
 for z in [.12,2.86]:b.box(x+.115,z,.025,.025,.022,.027,iron)
b.finish('bridge-deck','source six by three footprint; all three rows usable, flush top 0.022m')
# Thin 6x0.1 rails. Posts and rails stay exactly inside existing blockers/up to0.6.
b=Builder()
for n in range(7):
 x=min(n,5.90);b.box(x,0,.10,.10,0,.60,wood);b.box(x+.005,.005,.09,.09,.57,.60,grain)
for low,high in [(.19,.29),(.49,.57)]:b.box(0,.015,6,.07,low,high,grain)
b.finish('bridge-rail','edge rail 6x0.1x0.6, no inward posts or end caps; 2.8m clearance')
b=Builder();b.box(0,0,2,3,-.12,.008,dark)
for n in range(8):b.box(n*.25+.003,0,.244,3,.008,.022,tuple(v*(1.05-.02*(n%4)) for v in wood))
b.finish('bridge-landing','existing two by three flat landings only, flush planks')
# Exact eight-corner catalog base. Stone courses, inset octagonal basin, blue spiral.
d=next(d for d in layout['catalog_reference'] if d['id']=='moonwell')
poly=[(p['x']/32,p['y']/32) for p in d['collision']['points']];centre=sum((Vector(p) for p in poly),Vector((0,0)))/len(poly)
b=Builder();b.prism(poly,0,.12,stone)
for course,(low,high) in enumerate([(.12,.33),(.33,.53),(.53,.60)]):
 for a,c in zip(poly,poly[1:]+poly[:1]):
  av,cv=Vector(a),Vector(c)
  for j in range(3):
   p=av.lerp(cv,j/3+.003);q=av.lerp(cv,(j+1)/3-.003)
   ip=centre+(p-centre)*.77;iq=centre+(q-centre)*.77
   color=cap if course==2 else tuple(v*(.88+.045*((j+course)%4)) for v in stone)
   b.prism([tuple(p),tuple(q),tuple(iq),tuple(ip)],low,high,color)
inner=[tuple(centre+(Vector(p)-centre)*.765) for p in poly];b.prism(inner,.12,.305,pool)
for i in range(80):
 t0=i/80*math.pi*4.3;t1=(i+1)/80*math.pi*4.3;r0=.05+.050*t0;r1=.05+.050*t1
 def pt(t,r):return (centre.x+math.cos(t)*r,-(centre.y+math.sin(t)*r),.309)
 b.face([pt(t0,r0),pt(t1,r1),pt(t1,r1+.025),pt(t0,r0+.025)],ripple)
b.finish('moonwell','exact foot-relative octagonal base, low stone courses, inset blue spiral basin; no interaction/light/physics');mapping[-1]['local_polygon_xz_m']=poly
# Closed east barrier fills authored 2x8 footprint; west face boards and braces.
b=Builder()
for x in [0,1.84]:
 for z in [0,1.95,3.95,5.95,7.84]:
  b.box(x,z,.16,.16,0,1.42,dark);b.box(x+.015,z+.015,.13,.13,1.42,1.48,grain)
 for low in [.25,.58,.91,1.24]:
  b.box(x+.025,0,.11,8,low,low+.16,wood)
 for j in range(32):b.box(x+.025,j*.25+.005,.11,.24,.25,1.39,tuple(v*(.91+.025*(j%5)) for v in wood))
 # Angled west/east bracing stays in plane of wall; no external projection.
 for z in [0,2,4,6]:
  bx=x+.012 if x==0 else x+.148
  b.face([(bx,-z,.36),(bx,-(z+1.86),1.25),(bx,-(z+1.86),1.40),(bx,-z,.51)],grain)
# Interior transverse boards communicate entire depth as closed/barricaded.
for z in [.03,3.97,7.84]:b.box(0,z,2,.13,.56,.72,wood)
b.finish('closed-east-gate','entire independent authored two by eight blocker, longitudinal timber barricade, no source catalog collision')
scene['mapping_json']=json.dumps({'snapshot_id':layout['provenance']['snapshot_id'],'asset':'res://assets/environment/alderwake_landmark_kit.glb','mappings':mapping})
world=bpy.data.worlds.new('M014-preview-world');world.use_nodes=True
background=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');background.inputs['Color'].default_value=(.20,.24,.25,1);background.inputs['Strength'].default_value=.7;scene.world=world
# Gallery translations only. Export later resets temporarily to original module feet.
positions=[(0,0,0),(0,2,0),(7,0,0),(5,-5,0),(11,1,0)]
for obj,pos in zip(list(scene.objects),positions):obj.location=pos
camera_data=bpy.data.cameras.new('CAM-M014-gallery');camera=bpy.data.objects.new(camera_data.name,camera_data);scene.collection.objects.link(camera)
camera.location=(13,-19,22);camera.rotation_euler=(Vector((6,-2,0))-camera.location).to_track_quat('-Z','Y').to_euler();camera_data.type='ORTHO';camera_data.ortho_scale=20;scene.camera=camera
for name,loc,energy in [('key',(3,-5,15),2300),('fill',(13,5,12),1800)]:
 data=bpy.data.lights.new('LGT-M014-'+name,'AREA');data.energy=energy;data.size=10;obj=bpy.data.objects.new(data.name,data);scene.collection.objects.link(obj);obj.location=loc;obj.rotation_euler=(Vector((6,-2,0))-obj.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=1200;scene.render.resolution_y=850;scene.render.resolution_percentage=100;scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'docs/evidence/M014/blender-gallery.png')
scene.render.engine='BLENDER_EEVEE'
bpy.data.libraries.write(str(ROOT/'art/source/alderwake_landmark_kit.blend'),{scene})
print(json.dumps({'scene':scene.name,'meshes':len(mapping),'triangles':sum(m['triangles'] for m in mapping),'previous_scene':previous.name,'preserved_scenes':[(s.name,len(s.objects)) for s in bpy.data.scenes if s!=scene]}))