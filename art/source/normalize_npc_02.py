"""Normalize only the owned Helena library snapshot in a background process."""
import bpy
from pathlib import Path
path = Path('D:/development/game-dev-blender/returning-fair-prototype/art/source/npc-02.blend')
assert Path(bpy.data.filepath).resolve() == path.resolve()
bpy.context.preferences.filepaths.save_version = 0
bpy.context.window.scene = bpy.data.scenes['RF-Npc02-Helena']
bpy.ops.wm.save_as_mainfile(filepath=str(path),check_existing=False)
print('N009 editable mainfile:',path)
