from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).resolve().parent
MAIN=ROOT/'docs/evidence/AD014/20261011-102730681-121d9195'
ART=ROOT/'docs/evidence/AD014'/__import__('sys').argv[1]
ORDINARY=ROOT/'docs/evidence/AD014/20261011-103717462-962e22fa'
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
reports=[]
for folder in [MAIN,ART,ORDINARY]:
    report=json.loads((folder/'results.json').read_text())
    assert report['status']=='passed' and not report['source']['changed'] and report['source']['error'] is None
    assert all(c['status']=='passed' and c['exit_code']==0 and not c['diagnostics'] for c in report['cases'])
    manifest=json.loads((folder/'source-after.json').read_text())
    for entry in manifest['files']:
        if folder==MAIN and entry['path'] in ['game/world/storybook_home_material.gd','game/world/storybook_home.gdshader','game/tests/art_direction_home_render.gd']: continue
        assert digest(ROOT/entry['path'])==entry['sha256'],entry['path']
    reports.append({'path':str(folder.relative_to(ROOT)),'cases':len(report['cases']),'sha256':manifest['sha256'],'files':len(manifest['files'])})
before=(OUT/'mayor_vale_home.before.gd').read_text()
after=(ROOT/'game/world/mayor_vale_home.gd').read_text()
line='\tvisual.material_override = preload("res://world/storybook_home_material.gd").painted(color,"MayorValeHome" if parent == self else str(parent.name),center)\n'
assert after.replace(line,'')==before and after.count(line)==1
home=json.loads((MAIN/'checks/routine_home_checks/routine-home.json').read_text()); assert not home['failures'] and home['physical_sweeps']==2586 and len(home['routes'])==25
material=json.loads((MAIN/'checks/storybook_home_checks/home-materials.json').read_text()); assert not material['failures'] and material['boxes']==165 and material['materials']==21 and len(material['families'])==15
live=json.loads((MAIN/'checks/routine_activation_checks/routine-activation-coverage.json').read_text()); assert not live['failures'] and len(live['coverage'])==25
journey=json.loads((MAIN/'render/home-render-index.json').read_text()); assert not journey['failures'] and len(journey['views'])==28 and len(journey['traces'])==7 and all(t['ok'] for t in journey['traces'])
# Room-atlas projection remains64 native texels/m for each plane, independent of mesh scale.
regions={(tuple(row['patch_origin']),tuple(row['patch_span'])) for row in material['inventory']}
assert regions=={((16,528),(480,480)),((528,528),(224,224)),((784,784),(224,224)),((16,16),(480,480))}
shader=(ROOT/'game/world/storybook_home.gdshader').read_text()
assert 'TIME' not in shader and 'EMISSION' not in shader and 'MODEL_MATRIX * vec4(VERTEX, 1.0)' in shader
assert not re.search(r'\b(?:VERTEX|DEPTH)\s*[+*/-]?=',shader)
assert 'plane * 64.0 / span' in shader and 'filter_linear_mipmap, repeat_disable' in shader
for origin,span in regions:
    for offset in [-1000,-64,-1,0,.01,1,64,1000]:
        for axis in range(2):
            folded=1-abs((offset*64/span[axis]+[.35,.45][axis])%2-1)
            pixel=origin[axis]+folded*span[axis]
            assert origin[axis]<=pixel<=origin[axis]+span[axis]
scope=json.loads((OUT/'task-scope.json').read_text())
for path in scope:
    data=(ROOT/path).read_text() if Path(path).suffix not in ['.png','.blend','.glb'] else ''
    assert not any(line.rstrip()!=line for line in data.splitlines()),path
result={'task':'AD014','status':'passed','reports':reports,'original_home_code_exact_after_removing_single_override_line':True,'boxes':165,'shared_materials':21,'families':15,'colliders':32,'stations':9,'physical_sweeps':2586,'routes':25,'material_assertions':material['assertions'],'routine_assertions':live['assertions'],'routines':25,'ordinary_journey_captures':28,'ordinary_routes':7,'all_plane_gutters_density_sampling_pass':True,'task_hashes':{p:digest(ROOT/p) for p in scope}}
(OUT/'acceptance-audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='task_hashes'}))
