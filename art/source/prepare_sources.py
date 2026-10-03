"""Convert scoped library snapshots into ordinary editable .blend files.

Run in background Blender, after build/re-export. These are task-owned sources;
never run against arbitrary live files. No settings are written to preferences.
"""
import bpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
bpy.context.preferences.filepaths.save_version = 0
for asset in ('guardian', 'recovery_vessel', 'tollworks_plinth'):
    path = ROOT / 'art/source' / (asset + '.blend')
    bpy.ops.wm.open_mainfile(filepath=str(path))
    scene = next(s for s in bpy.data.scenes if s.name.startswith('RF-'))
    bpy.context.window.scene = scene
    bpy.ops.wm.save_as_mainfile(filepath=str(path), check_existing=False)
    print('P012 editable mainfile:', path, 'scene=', scene.name)
