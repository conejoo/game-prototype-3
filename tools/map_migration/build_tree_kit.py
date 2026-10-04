"""Run inside inspected Blender. New isolated scene; never clear user work.

Authored stylized meshes, pinned catalog trunk bases, portable vertex-color PBR.
Blender Z-up -> glTF Y-up; source local south becomes Blender -Y.
"""
import bpy, bmesh, json, math
from pathlib import Path
from mathutils import Vector

ROOT = Path('D:/development/game-dev-blender/returning-fair-prototype')
catalog = json.loads((ROOT/'tools/map_migration/reference/catalog.json').read_text())
species = ['alder','birch','cherry','maple','oak','pine','rowan','spruce','willow']
palette = {'alder':(.24,.43,.12),'birch':(.46,.57,.20),'cherry':(.27,.49,.15),
           'maple':(.67,.22,.045),'oak':(.29,.41,.12),'pine':(.12,.31,.18),
           'rowan':(.43,.46,.11),'spruce':(.10,.28,.19),'willow':(.47,.52,.14)}
sizes={'small':(.78,2.55),'standard':(1.0,3.15),'large':(1.18,3.70)}
previous=bpy.context.scene
if previous.name == 'RF-M012-TreeKit':
    assert len(previous.objects) == 0, 'Inspect existing populated kit before replacing'
    bpy.context.window.scene=bpy.data.scenes['RF-RecoveryVessel']
    bpy.data.scenes.remove(previous)
    previous=bpy.context.scene
(ROOT/'art/source').mkdir(parents=True,exist_ok=True)
(ROOT/'game/assets/environment').mkdir(parents=True,exist_ok=True)
(ROOT/'builds/m012').mkdir(parents=True,exist_ok=True)
if not (ROOT/'builds/m012/preserved-live-work.blend').exists():
    bpy.data.libraries.write(str(ROOT/'builds/m012/preserved-live-work.blend'),set(bpy.data.scenes))
scene=bpy.data.scenes.new('RF-M012-TreeKit'); bpy.context.window.scene=scene
material=bpy.data.materials.new('MAT-M012-tree_vertex_palette'); material.use_nodes=True
bsdf=next(n for n in material.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
bsdf.inputs['Roughness'].default_value=.92
bsdf.inputs['Metallic'].default_value=0
attribute=material.node_tree.nodes.new('ShaderNodeVertexColor'); attribute.layer_name='Color'
material.node_tree.links.new(attribute.outputs['Color'],bsdf.inputs['Base Color'])
mapping=[]
for species_index,name in enumerate(species):
    for size,(spread,height) in sizes.items():
        definition=name+'-tree'+('' if size=='standard' else '-'+size)
        entry=next((r for r in catalog['objects'] if r['id']==definition),None)
        if entry is None:
            continue
        c=entry['collision']; left=c['left']/32; south=c['top']/32; width=c['width']/32; depth=c['height']/32
        centre=Vector((left+width/2,-south-depth/2,0))
        vertices=[]; faces=[]; colors=[]
        def ring_form(points,radii,color,sides=9,phase=0,scallop=0):
            start=len(vertices)
            for ring,(point,radius) in enumerate(zip(points,radii)):
                for k in range(sides):
                    angle=2*math.pi*k/sides+phase
                    variation=1+scallop*math.sin(k*2.7+ring*.85)
                    vertices.append((point[0]+radius[0]*math.cos(angle)*variation,point[1]+radius[1]*math.sin(angle)*variation,point[2]))
                    shade=.90+.12*math.sin(k*2.3+ring*.9)
                    colors.append(tuple(min(1,v*shade) for v in color)+(1,))
            faces.append(tuple(start+k for k in reversed(range(sides))))
            for ring in range(len(points)-1):
                for k in range(sides):
                    a=start+ring*sides+k; b=start+ring*sides+(k+1)%sides
                    faces.append((a,b,b+sides,a+sides))
            faces.append(tuple(start+(len(points)-1)*sides+k for k in range(sides)))
        bark=(.59,.57,.43) if name=='birch' else (.28,.13,.055)
        # Base exactly spans the source box; upper bole tapers into branches.
        ring_form([centre,centre+Vector((.02,0,.28)),centre+Vector((-.05,.03,1.25)),centre+Vector((.04,0,height*.77))],
                  [(width/2,depth/2),(width*.25,depth*.28),(.13,.11),(.055,.05)],bark,sides=8,phase=math.pi/4)
        def crown(x,y,z,rx,ry,rz,color):
            ring_form([(x,y,z-rz),(x,y,z-rz*.55),(x,y,z),(x,y,z+rz*.65),(x,y,z+rz)],
                      [(rx*.12,ry*.12),(rx*.78,ry*.78),(rx,ry),(rx*.70,ry*.70),(rx*.08,ry*.08)],color,scallop=.10)
        if name in ['pine','spruce']:
            layers=5 if name=='spruce' else 4
            for k in range(layers):
                z=1.55+k*(height-1.55)/layers; radius=(.94 if name=='spruce' else 1.02)*spread*(1-k/(layers+1))
                ring_form([centre+Vector((0,0,z-.13)),centre+Vector((0,0,z)),centre+Vector((0,0,z+.29)),centre+Vector((0,0,z+.68))],
                          [(radius*.68,radius*.68),(radius,radius),(.66*radius,.66*radius),(.03,.03)],palette[name],sides=11,phase=k*.31,scallop=.10)
        else:
            count={'alder':7,'birch':6,'cherry':7,'maple':7,'oak':7,'rowan':6,'willow':7}[name]
            for k in range(count):
                angle=k*2*math.pi/count+.23; reach=(.50 if name=='birch' else .64)*spread
                x=centre.x+math.cos(angle)*reach; y=centre.y+math.sin(angle)*reach
                z=height-.63+(.19 if k%2 else -.16)
                ring_form([centre+Vector((0,0,1.05)),Vector((x*.6+centre.x*.4,y*.6+centre.y*.4,z-.28)),Vector((x,y,z))],[(.09,.075),(.065,.05),(.025,.022)],bark,sides=6)
                rx=(.45 if name=='birch' else .60)*spread
                rz=.79 if name=='willow' else .48
                crown(x,y,z-(.25 if name=='willow' else 0),rx,rx*.90,rz,palette[name])
                if name=='willow':
                    for j in range(2):
                        crown(x+(.20 if j else -.20),y-.10,z-.71,.17*spread,.19*spread,.60,palette[name])
                if name in ['cherry','rowan']:
                    accent=(.91,.56,.57) if name=='cherry' else (.71,.11,.025)
                    for j in range(3):
                        t=angle+j*1.8; crown(x+math.cos(t)*rx*.65,y+math.sin(t)*rx*.65,z+.22,.115,.10,.09,accent)
            crown(centre.x+.06,centre.y, height-.34,.59*spread,.55*spread,.35,palette[name])
        mesh=bpy.data.meshes.new('GEO-'+name+'-'+size); mesh.from_pydata(vertices,[],faces); mesh.update()
        color=mesh.color_attributes.new(name='Color',type='FLOAT_COLOR',domain='POINT')
        for i,rgba in enumerate(colors):color.data[i].color=rgba
        bm=bmesh.new(); bm.from_mesh(mesh); bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(mesh); bm.free()
        obj=bpy.data.objects.new(mesh.name,mesh); scene.collection.objects.link(obj); mesh.materials.append(material)
        obj['source_definition_id']=definition; obj['species']=name; obj['size']=size
        mesh.calc_loop_triangles()
        mapping.append({'definition_id':definition,'species':name,'size':size,'mesh_name':obj.name,'height_m':max(v.co.z for v in mesh.vertices),'triangles':len(mesh.loop_triangles),'source_base_box_xz_m':[left,south,width,depth]})
world=bpy.data.worlds.new('M012-preview-world'); world.use_nodes=True
next(n for n in world.node_tree.nodes if n.type=='BACKGROUND').inputs['Color'].default_value=(.22,.25,.28,1)
next(n for n in world.node_tree.nodes if n.type=='BACKGROUND').inputs['Strength'].default_value=.65
scene.world=world
# Portable export: only actual catalog variants, all at their local feet.
bpy.ops.object.select_all(action='DESELECT')
for obj in scene.objects:obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(ROOT/'game/assets/environment/moonwood_tree_kit.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False)
(ROOT/'game/assets/environment/moonwood_tree_mapping.json').write_text(json.dumps({'snapshot_id':'alderwake-f4630f9-m002','asset':'res://assets/environment/moonwood_tree_kit.glb','mappings':mapping},indent=2)+'\n')
# Arrange the editable source as an inspection gallery, after export.
for obj in list(scene.objects):
    record=next(r for r in mapping if r['mesh_name']==obj.name)
    obj.location=(species.index(record['species'])*3.15,list(sizes).index(record['size'])*3.7,0)
camera_data=bpy.data.cameras.new('CAM-M012-gallery'); camera=bpy.data.objects.new(camera_data.name,camera_data);scene.collection.objects.link(camera)
camera.location=(13,-16,16); camera.rotation_euler=(Vector((13,3.6,1.3))-camera.location).to_track_quat('-Z','Y').to_euler()
camera_data.type='ORTHO'; camera_data.ortho_scale=32; scene.camera=camera
for label,location,energy in [('key',(9,-4,12),2200),('fill',(22,8,10),1700)]:
    light_data=bpy.data.lights.new('LGT-M012-'+label,'AREA');light_data.energy=energy;light_data.shape='DISK';light_data.size=10
    light=bpy.data.objects.new(light_data.name,light_data);scene.collection.objects.link(light);light.location=location
    light.rotation_euler=(Vector((13,3,1))-light.location).to_track_quat('-Z','Y').to_euler()
scene.render.resolution_x=1400;scene.render.resolution_y=700;scene.render.resolution_percentage=100
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(ROOT/'docs/evidence/M012/blender-gallery.png')
try:scene.render.engine='BLENDER_EEVEE'
except TypeError:scene.render.engine='BLENDER_EEVEE_NEXT'
bpy.data.libraries.write(str(ROOT/'art/source/moonwood_tree_kit.blend'),{scene})
print(json.dumps({'created_scene':scene.name,'previous_scene':previous.name,'objects':len(scene.objects),'meshes':len(mapping),'triangles':sum(r['triangles'] for r in mapping),'blend':str(ROOT/'art/source/moonwood_tree_kit.blend'),'glb':str(ROOT/'game/assets/environment/moonwood_tree_kit.glb')}))
