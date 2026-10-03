"""Render saved authoring snapshots in background Blender; never writes sources."""
import bpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
for asset in ('guardian', 'recovery_vessel', 'tollworks_plinth'):
    bpy.ops.wm.open_mainfile(filepath=str(ROOT / 'art/source' / (asset + '.blend')))
    scene = next(s for s in bpy.data.scenes if s.name.startswith('RF-'))
    bpy.context.window.scene = scene
    scene.render.filepath = str(ROOT / 'docs/evidence/P012' / (asset + '-source.png'))
    bpy.ops.render.render(write_still=True)
    print('P012 saved source rendered:', asset)
