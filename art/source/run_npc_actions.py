from pathlib import Path
p=Path('D:/development/game-dev-blender/returning-fair-prototype/art/source/build_npc_actions.py')
exec(compile(p.read_text(),str(p),'exec'),{'__name__':'__main__'})
