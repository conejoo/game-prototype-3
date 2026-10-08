"""Normalize only N007's owned scoped snapshot, never the live user's file."""
import bpy
from pathlib import Path
path = Path('D:/development/game-dev-blender/returning-fair-prototype/art/source/npc_calibration.blend')
assert Path(bpy.data.filepath).resolve() == path.resolve()
bpy.context.preferences.filepaths.save_version = 0
bpy.context.window.scene = bpy.data.scenes['RF-NpcCalibration']
bpy.ops.wm.save_as_mainfile(filepath=str(path),check_existing=False)
print('N007 editable mainfile:',path)
