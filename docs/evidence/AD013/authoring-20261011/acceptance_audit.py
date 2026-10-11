from pathlib import Path
import json,hashlib,subprocess,sys
import numpy as np
from PIL import Image,ImageDraw
root=Path.cwd(); run=root/'docs/evidence/AD013'/sys.argv[1]; evidence=root/'docs/evidence/AD013/authoring-20261011'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
report=json.loads((run/'results.json').read_text(encoding='utf-8-sig'))
assert report['status']=='passed' and not report['source']['changed'] and report['source']['error'] is None
assert len(report['cases'])==5 and all(c['status']=='passed' and c['exit_code']==0 for c in report['cases'])
manifest=json.loads(Path(report['source']['after']['manifest']).read_text(encoding='utf-8-sig'))
main=json.loads((root/'docs/evidence/AD013/20261011-095704650-94a74121/results.json').read_text())
assert main['status']=='passed' and len(main['cases'])==11 and not main['source']['changed']
main_files={r['path']:r['sha256'] for r in json.loads(Path(main['source']['after']['manifest']).read_text())['files']}
final_files={r['path']:r['sha256'] for r in json.loads(Path(report['source']['after']['manifest']).read_text())['files']}
assert [p for p in main_files if main_files[p]!=final_files[p]]==['game/tests/art_direction_actor_render.gd']
# Actual bytes must still match the green runner snapshot.
assert all(sha(root/r['path'])==r['sha256'] for r in manifest['files'])
indexes=[json.loads((run/f'render/actors-{p}-index.json').read_text()) for p in ['pilot','input-ortho','input-perspective']]
assert all(not i['failures'] for i in indexes)
views={v['label']:v for v in indexes[0]['views']}; pairs=[]; silhouettes=[]
for name,v in views.items():
    if name.endswith('-painted') and name[:-8]+'-original' in views:
        original=views[name[:-8]+'-original']
        assert v['camera']==original['camera'] and v['position']==original['position'] and v['subjects']==original['subjects']
        pairs.append({'painted':name,'original':original['label'],'camera_feet_feedback_exact':True})
assert len(pairs)==19
for name in ['PlayerPlaceholder','Companion','Guardian']:
    a=np.asarray(Image.open(views[name+'-close-0-painted']['path']).convert('RGB'))
    b=np.asarray(Image.open(views[name+'-close-0-original']['path']).convert('RGB'))
    am=np.any(a!=a[0,0],axis=2); bm=np.any(b!=b[0,0],axis=2)
    difference=int(np.count_nonzero(am!=bm)); assert difference==0
    silhouettes.append({'subject':name,'differing_silhouette_pixels':difference,'painted_pixels':int(am.sum())})
for projection in ['ortho','perspective']:
    for cue in ['windup','active','recovery','dodge','damage','death']:
        v=views[f'tollworks-{projection}-{cue}']; h=v['subjects'][0]
        if cue=='active': assert h['active'] and h['elapsed']==.18
        if cue=='dodge': assert h['dodge_left']==.3
        if cue=='damage': assert h['health']==75 and h['flash']==.18
        if cue=='death': assert h['health']==0 and abs(h['scale'][1]-.18)<1e-6 and not h['marker']
# Verify live frames separately: shared contact tool remains strictly pause-gated.
live=[]
for i in indexes[1:]:
    assert len(i['views'])==8 and len(i['live_views'])==1
    assert i['traces'][0]['distance']>=.1 and not i['traces'][0]['accepted_keys']
    v=i['live_views'][0]; assert v['mode']=='live-aim' and v['paused'] is False and v['window_focused'] and v['controls_enabled'] and v['aim_visible'] and v['focus']=='' and v['settled_frames']==4 and v['frame_post_draw_verified'] and v['ticks_msec']>=v['started_ticks_msec']
    assert v['engine_pid']==i['pid'] and v['viewport_size']==[960,640]
    live.append(v)
    # Next ordinary pause capture verifies return from bounded live sample.
    assert next(x for x in i['views'] if x['label'].endswith('-aim'))['paused']
# Broad actual atlas paint range in linear sampling space.
a=np.asarray(Image.open(root/'game/assets/environment/storybook/town-painted-albedo.png').convert('RGB'))[16:497,16:497]/255
linear=np.where(a<=.04045,a/12.92,((a+.055)/1.055)**2.4)
stroke=np.clip(1+((linear@np.array([.2126,.7152,.0722]))-.6)*.65,.9,1.08)
assert float(stroke.max()-stroke.min())>.05
starting=json.loads((evidence/'starting-manifest.json').read_text(encoding='utf-8-sig'))
allowed={'game/features/actors/actor_placeholder.gd','docs/art-direction-storybook/CHECKLIST.md','docs/art-direction-storybook/CURRENT_STATE.md'}
protected=[r for r in starting['files'] if r['path'] not in allowed]
changed=[r['path'] for r in protected if not (root/r['path']).exists() or sha(root/r['path'])!=r['sha256']]
assert not changed,changed
original=subprocess.check_output(['git','-c','safe.directory='+root.as_posix(),'show','HEAD:game/features/actors/actor_placeholder.gd']).decode().replace('\r\n','\n')
current=(root/'game/features/actors/actor_placeholder.gd').read_text().replace('\r\n','\n')
assert current==original.replace('func _ready() -> void:\n','func _ready() -> void:\n\tpreload("res://features/actors/storybook_actor_material.gd").apply(self)\n')
result={'task':'AD013','run':run.name,'status':'passed','registered_pairs':pairs,'gallery_silhouettes':silhouettes,'paused_frames':sum(len(i['views']) for i in indexes),'live_aim_frames':len(live),'live_views':live,'movement_distances':[i['traces'][0]['distance'] for i in indexes[1:]],'atlas_stroke_min':float(stroke.min()),'atlas_stroke_max':float(stroke.max()),'render_texture_bytes':indexes[0]['texture_bytes'],'protected_starting_files':len(protected),'starting_files':len(starting['files']),'unexpected_changes':changed,'source_digest':report['source']['after']['sha256'],'source_file_count':report['source']['after']['file_count']}
(evidence/'acceptance-audit.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if k not in ['registered_pairs','live_views']}))
