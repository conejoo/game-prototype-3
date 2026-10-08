"""Labeled actual-render contact sheets; raw frames remain full resolution."""
import json,math,argparse
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser();parser.add_argument('run',type=Path);args=parser.parse_args()
run=args.run.resolve();assert run.is_relative_to(ROOT/'docs/evidence/N016')
manifest=json.loads((run/'render/npc-action-captures.json').read_text())
assert not manifest['failures']
paths=[]
for start in range(0,len(manifest['captures']),9):
    rows=manifest['captures'][start:start+9]
    sheet=Image.new('RGB',(960,math.ceil(len(rows)/3)*237),(22,27,33));draw=ImageDraw.Draw(sheet)
    for index,row in enumerate(rows):
        path=Path(row['path']).resolve();assert path.is_relative_to(run)
        with Image.open(path) as image:
            assert image.size==(row['width'],row['height']) and row['manual_review'] and row['frame_post_draw'] and row['error']==0
            x=(index%3)*320;y=(index//3)*237
            sheet.paste(image.convert('RGB').resize((320,213)),(x,y));draw.text((x+4,y+217),row['label'],fill='white')
    output=run/f'contact-sheet-{start//9+1:02d}.png';assert not output.exists();sheet.save(output);paths.append(str(output))
(run/'contact-sheets.json').write_text(json.dumps({'frames':len(manifest['captures']),'sheets':paths,'provenance':manifest['provenance']},indent=2)+'\n')
print(json.dumps({'frames':len(manifest['captures']),'sheets':paths}))
