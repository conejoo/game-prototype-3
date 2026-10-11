"""Read-only AD012 registered gallery/capture/source audit; derived local evidence."""
from pathlib import Path
from PIL import Image, ImageChops
import json
root = Path(__file__).resolve().parents[4]
out = Path(__file__).resolve().parent
run = root / 'docs/evidence/AD012/20261011-093006695-2beeef8b'
index = json.loads((run/'render/npc-painted-index.json').read_text())
assert not index['failures'] and len(index['views']) == 152
views = {v['label']: v for v in index['views']}
pairs=[]
for id in ['01','02','03','04','06','07','08','14']:
    a=views[f'npc-{id}-original-front']; b=views[f'npc-{id}-painted-front']
    assert a['camera']==b['camera'] and a['subject_feet']==b['subject_feet'] and a['pose']==b['pose'] and a['pose_time']==b['pose_time']
    before=Image.open(a['path']).convert('RGB'); after=Image.open(b['path']).convert('RGB')
    bg=before.getpixel((0,0)); mask_a=[p!=bg for p in before.get_flattened_data()]; mask_b=[p!=bg for p in after.get_flattened_data()]
    assert mask_a==mask_b, f'gallery silhouette differs npc-{id}'
    diff=ImageChops.difference(before,after)
    pairs.append({'id':f'npc-{id}','camera_feet_pose_exact':True,'silhouette_mask_identical':True,'body_pixels':sum(mask_a),'rgb_difference_extrema':diff.getextrema()})
for loop in index['loops']: assert loop['endpoint_total_8bit_byte_delta'] <= 1
prior = json.loads((root/'docs/evidence/AD012/20261011-092729592-7cc5ed07/source-after.json').read_text())
current = json.loads((run/'source-after.json').read_text())
old = {v['path']:v for v in prior['files']}; new = {v['path']:v for v in current['files']}
changes = [p for p in old if old[p] != new.get(p)]
assert changes == ['game/tests/art_direction_npc_render.gd'], changes
report={'task':'AD012','captures':152,'pairs':pairs,'loops':index['loops'],'headless_to_final_source_changes':changes,'note':'Only final synthetic night HUD camera description changed; all production/check source bytes match the 16/16 main run. Visual inspection recorded separately.'}
(out/'pixel-audit.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'pairs':len(pairs),'silhouettes_identical':True,'captures':len(views),'source_changes':changes}))
