"""Retain first generated scenes; rebuild only our unaccepted N016 variants."""
import bpy
from pathlib import Path
root=Path('D:/development/game-dev-blender/returning-fair-prototype')
for who in ['01','02']:
    name=f'RF-N016-{who}-Actions'
    bpy.data.scenes[name].name=name+'-before-grip-refine'
p=root/'art/source/build_npc_actions.py'
exec(compile(p.read_text(),str(p),'exec'),{'__name__':'__main__'})
