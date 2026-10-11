from pathlib import Path
import json,re,subprocess
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
folder=ROOT/'docs/art-direction-storybook'
checklist=(folder/'CHECKLIST.md').read_text()
rows=re.findall(r'^\| (AD\d{3}) \| (Pending|In progress|Blocked|Done) \|',checklist,re.M)
assert len(rows)==20 and [r[0] for r in rows]==[f'AD{i:03}' for i in range(1,21)]
assert all(status==('Done' if int(id[2:])<=14 else 'Pending') for id,status in rows)
assert len(re.findall(r'^## AD\d{3} - ',checklist,re.M))==20
links=[]
for path in [folder/'AD014_ACCEPTANCE.md',folder/'CURRENT_STATE.md']:
    text=path.read_text()
    assert text.endswith('\n') and not any(line.rstrip()!=line for line in text.splitlines())
    for target in re.findall(r'\]\(([^)]+)\)',text):
        if target.startswith(('http:','https:','#')): continue
        resolved=(path.parent/target.split('#')[0]).resolve()
        assert resolved.exists(),(path.name,target)
        links.append({'file':str(path.relative_to(ROOT)),'target':target})
    assert 'Blockers:none' in text and 'AD015' in text and 'AD020' in text
head=subprocess.check_output(['git','-c',f'safe.directory={ROOT.as_posix()}','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
assert head=='03a6e9894e36c59647bb4301450a4378e4f53fdf'
assert not subprocess.check_output(['git','-c',f'safe.directory={ROOT.as_posix()}','diff','--cached','--name-only'],cwd=ROOT,text=True).strip()
cleanup=json.loads((OUT/'cleanup-pids.json').read_text()); assert not cleanup['active_recorded'] and not cleanup['live_godot']
review={'task':'AD014','final_images_inspected':78,'synthetic_sheets':[str(p.relative_to(ROOT)) for p in (ROOT/'docs/evidence/AD014/20261011-103551439-374cfd54/render/derived/20261011-103720-1a938290').glob('contact-*.png')],'ordinary_sheets':[str(p.relative_to(ROOT)) for p in (ROOT/'docs/evidence/AD014/20261011-103717462-962e22fa/render/derived/20261011-103954-24cae236').glob('contact-*.png')],'critical_full_size_views':['final parlor-perspective-80-painted: coincident face speckles removed','painted/archive/control pairs: exact composition and role visibility','ordinary archive/bedroom/parlor/kitchen and town return','actual Helena walk/shelf frames'],'findings':'Warm coherent rooms, broad brush texture and clear routes/contact feet. No new seam/density/contact problem. Original cutaway crop and small ground label remain unchanged. Final white partition speckles eliminated.'}
(OUT/'pixel-review.json').write_text(json.dumps(review,indent=2)+'\n')
result={'task':'AD014','rows':rows,'all_through_AD020_complete':False,'remaining':[id for id,status in rows if status!='Done'],'next_eligible':'AD015','links_verified':len(links),'links':links,'head_unchanged':head,'staged':False,'cleanup_owned_pids':len(cleanup['recorded_pids']),'blockers':[]}
(OUT/'document-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['rows','links']}))
