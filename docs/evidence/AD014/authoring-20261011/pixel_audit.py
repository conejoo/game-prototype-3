from pathlib import Path
import hashlib,json,sys
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
RUN=ROOT/'docs/evidence/AD014'/sys.argv[1]
index=json.loads((RUN/'render/home-painted-index.json').read_text())
views={v['label']:v for v in index['views']}
pairs=[]
for label,paint in views.items():
    if not label.endswith('-painted'): continue
    original=views[label[:-8]+'-original']
    fields=['position','ally','camera','camera_transform','location','environment','sun','contacts','viewport_size']
    assert all(paint[f]==original[f] for f in fields),label
    a=np.asarray(Image.open(paint['path']).convert('RGB'))
    b=np.asarray(Image.open(original['path']).convert('RGB'))
    changed=int(np.any(a[160:510]!=b[160:510],axis=2).sum())
    assert changed>1000,label
    pairs.append({'label':label,'registration_exact':True,'world_changed_pixels':changed})
a=np.asarray(Image.open(views['indoor-clear-day']['path']).convert('RGB'))
b=np.asarray(Image.open(views['indoor-storm-night']['path']).convert('RGB'))
weather_diff=int(np.any(a[160:510]!=b[160:510],axis=2).sum())
assert weather_diff==0,weather_diff
assert views['indoor-clear-day']['sun']==views['indoor-storm-night']['sun']
moving=[v for v in index['views'] if v['label'].startswith('helena-motion')]
assert len(moving)==3 and all(v['contacts']['npc-02']['speed']>1.99 for v in moving)
assert all(v['contacts']['npc-02']['clip']=='walk' for v in moving)
assert len({v['contacts']['npc-02']['cursor'] for v in moving})==3
endpoint=views['helena-shelves-arrival']['contacts']['npc-02']['foot']
assert np.linalg.norm(np.array(endpoint)-[6,0,-1.5])<1e-5
assert not index['failures']
result={'task':'AD014','run':sys.argv[1],'paired_views':pairs,'world_roi':[0,160,960,510],'weather_world_pixel_difference':weather_diff,'weather_sun_exact':True,'moving_contacts':len(moving),'endpoint':endpoint,'samples':index['samples'],'files':{str(Path(v['path']).relative_to(ROOT)):hashlib.sha256(Path(v['path']).read_bytes()).hexdigest() for v in index['views']},'visual_review_required':True}
(OUT/'pixel-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['task','run','weather_world_pixel_difference','weather_sun_exact','moving_contacts','endpoint']}))
