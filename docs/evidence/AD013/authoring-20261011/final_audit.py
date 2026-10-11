from pathlib import Path
import json,hashlib,re,subprocess
root=Path.cwd(); out=root/'docs/evidence/AD013/authoring-20261011'; run=root/'docs/evidence/AD013/20261011-100230613-9ce2eb69'
paths=['game/features/actors/actor_placeholder.gd','game/features/actors/storybook_actor_material.gd','game/features/actors/storybook_actor.gdshader','game/tests/storybook_actor_checks.gd','game/tests/art_direction_actor_render.gd','art/source/storybook/actors-painted-recipe.json','docs/art-direction-storybook/AD013_ACCEPTANCE.md','docs/art-direction-storybook/CHECKLIST.md','docs/art-direction-storybook/CURRENT_STATE.md']
rows=[{'path':p,'sha256':hashlib.sha256((root/p).read_bytes()).hexdigest()} for p in paths]
(out/'task-scope.json').write_text(json.dumps({'task':'AD013','paths':rows,'count':len(rows),'staging_commit_push':False},indent=2))
base=run/'render'; sheets=[str(base/f'derived/20261011-100317-f2bed91f/contact-{n:02d}.png') for n in range(1,7)]; full=[str(base/(n+'.png')) for n in ['input-ortho-live-aim','input-perspective-live-aim','Guardian-close-180-painted','shore-night-perspective-1_0-painted']]
(out/'pixel-review.json').write_text(json.dumps({'task':'AD013','run':run.name,'status':'accepted','paused_images_reviewed':72,'live_images_reviewed':2,'contact_sheets_opened':sheets,'full_size_opened':full,'observations':['Cyan/purple roles separate from olive grass and dark water in both projections and storm-night','Guardian copper/slate silhouette and teal core retained; all surface angles covered without obvious seam','Gold/red/cyan/white combat meanings and flattened death readable','Live aim rings directly visible on unobstructed floor, 63/71 cyan pixels; original pause intentionally hides them','No hero/ally humanoid replacement claim'],'limitations':['Synthetic art feet/time/weather/gallery/feedback','Input sample after synthetic lead/direct room only','No native input, ordinary route, GUI save/restart, package or performance acceptance']},indent=2))
checklist=(root/'docs/art-direction-storybook/CHECKLIST.md').read_text()
rows_status=re.findall(r'^\| (AD\d{3}) \| (Done|Pending|In progress|Blocked) \|',checklist,re.M)
assert len(rows_status)==20 and rows_status[-1][0]=='AD020'
assert rows_status==[(f'AD{i:03d}','Done' if i<=13 else 'Pending') for i in range(1,21)]
whitespace=[]
for p in paths:
    if (root/p).suffix!='.json':
        for n,line in enumerate((root/p).read_text().splitlines(),1):
            if line!=line.rstrip(' \t'): whitespace.append([p,n])
assert not whitespace,whitespace
for p in paths[-3:]:
    text=(root/p).read_text()
    for target in re.findall(r'\]\(([^)]+)\)',text):
        if not target.startswith(('https:','http:','#')):
            assert ((root/p).parent/target.split('#')[0]).exists(),(p,target)
cleanup=json.loads((out/'cleanup-pids.json').read_text(encoding='utf-8-sig')); assert not any(r['running'] for r in cleanup)
source=json.loads((run/'source-after.json').read_text()); assert all(hashlib.sha256((root/r['path']).read_bytes()).hexdigest()==r['sha256'] for r in source['files'])
final={'task':'AD013','status':'passed','task_path_count':len(paths),'statuses':dict(rows_status),'last_id':'AD020','all_complete':False,'remaining':[x for x,s in rows_status if s!='Done'],'next_eligible':'AD014','whitespace_errors':whitespace,'document_links':'all present','source_sha256':source['sha256'],'source_file_count':source['file_count'],'owned_processes_exited':len(cleanup),'blockers':[],'required_unrun':[],'commit_performed':False}
(out/'final-audit.json').write_text(json.dumps(final,indent=2)); print(json.dumps(final))
