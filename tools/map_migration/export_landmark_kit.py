"""Export validated M014 isolated scene; no user-scene/file overwrite."""
import bpy,json
from pathlib import Path
ROOT=Path('D:/development/game-dev-blender/returning-fair-prototype')
scene=bpy.data.scenes['RF-M014-LandmarkKit'];previous=bpy.context.scene;bpy.context.window.scene=scene
meshes=[o for o in scene.objects if o.type=='MESH'];positions={o.name:o.location.copy() for o in meshes}
try:
 bpy.ops.object.select_all(action='DESELECT')
 for obj in meshes:obj.location=(0,0,0);obj.select_set(True)
 bpy.ops.export_scene.gltf(filepath=str(ROOT/'game/assets/environment/alderwake_landmark_kit.glb'),export_format='GLB',use_selection=True,use_active_scene=True,export_yup=True,export_animations=False,export_cameras=False,export_lights=False)
 (ROOT/'game/assets/environment/alderwake_landmark_mapping.json').write_text(json.dumps(json.loads(scene['mapping_json']),indent=2)+'\n',encoding='utf-8')
finally:
 for obj in meshes:obj.location=positions[obj.name]
 bpy.context.window.scene=previous
print(json.dumps({'bytes':(ROOT/'game/assets/environment/alderwake_landmark_kit.glb').stat().st_size,'meshes':len(meshes)}))