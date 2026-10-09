"""Native metadata review regressions; generated files, no OS input or game state."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
from PIL import Image

spec=importlib.util.spec_from_file_location('native_evidence',Path(__file__).resolve().parents[1]/'native_evidence.py')
module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
assertions=0
def check(value):
    global assertions
    assertions+=1
    assert value

with tempfile.TemporaryDirectory(prefix='returning-fair-native-review-') as temporary:
    evidence=Path(temporary); phase=evidence/'writer'; phase.mkdir()
    exe='C:/owned/ReturningFair.exe'
    (phase/'launch.json').write_text(json.dumps({'pid':42,'exe':exe}))
    (phase/'request-input.json').write_text(json.dumps({'steps':[{'op':'capture','label':'first'}]}))
    Image.new('RGB',(960,640),'green').save(phase/'first.png')
    Image.new('RGB',(1350,900),'blue').save(phase/'second.png')
    def fixture(identifier,label,stamp):
        return {'id':identifier,'schema_version':2,'target_pid':42,'executable':exe,'ok':True,
                'cleanup_errors':[],'unreleased_keys':[],'mouse_unreleased':False,'failed_step':None,
                'steps':[{'index':0,'ok':True,'step':{'op':'capture','label':label},'completed_utc':stamp}]}
    # Reverse GUID ordering reproduces why filename sorting was poor review guidance.
    first=fixture('f'*32,'first','2026-10-09T00:00:00.0000000Z')
    second=fixture('0'*32,'second','2026-10-09T00:00:01+00:00')
    def write(rows=None):
        for row in rows or (first,second):
            (phase/(row['id']+'.json')).write_text(json.dumps(row))
    def audit(): return module.collect([phase],evidence)
    write(); original=audit()
    check(original['status']=='passed' and len(original['requests'])==2)
    check([row['label'] for row in original['captures']]==['first','second'])
    check([row['size'] for row in original['captures']]==[[960,640],[1350,900]])
    check(all(len(row['sha256'])==64 for row in original['captures']))
    try: module.collect([phase],evidence,pid=99,executable=exe)
    except ValueError: check(True)
    else: raise AssertionError('Explicit contradictory owner admitted')
    duplicate=evidence/'duplicate'; duplicate.mkdir()
    (duplicate/'launch.json').write_text(json.dumps({'pid':42,'exe':exe}))
    (duplicate/(first['id']+'.json')).write_text(json.dumps(first))
    Image.new('RGB',(960,640),'green').save(duplicate/'first.png')
    check(any('reused across' in row['error'] for row in module.collect([phase,duplicate],evidence)['failures']))
    source_hashes={p.name:module.hashlib.sha256(p.read_bytes()).hexdigest() for p in phase.iterdir()}
    reviewed=module.build(original,evidence/'review-one',evidence,last=1)
    check(reviewed['selected_count']==1 and len(reviewed['sheets'])==1)
    check('Required separately' in reviewed['visual_review'])
    check(source_hashes=={p.name:module.hashlib.sha256(p.read_bytes()).hexdigest() for p in phase.iterdir()})
    try: module.build(original,evidence/'review-one',evidence)
    except FileExistsError: check(True)
    else: raise AssertionError('Review output overwritten')
    for change in ({'target_pid':43},{'target_pid':True},{'executable':'C:/foreign.exe'},
                   {'schema_version':True},{'schema_version':1},{'ok':'true'},
                   {'cleanup_errors':['release failed']},{'unreleased_keys':['W']},
                   {'mouse_unreleased':True},{'mouse_unreleased':None},{'steps':None},
                   {'error':'contradictory failure'},{'failed_step':0}):
        bad={**copy.deepcopy(first),**change}; write([bad,second]); check(audit()['status']=='failed')
    for change in ({'index':True},{'index':1},{'ok':False},{'ok':1},
                   {'completed_utc':'missing'},{'completed_utc':'2026-10-09T00:00:00'},
                   {'step':{'op':'capture','label':'../escaped'}},{'step':{'op':'teleport'}}):
        bad=copy.deepcopy(first); bad['steps'][0].update(change)
        write([bad,second]); check(audit()['status']=='failed')
    bad=copy.deepcopy(first); bad['steps'].append(copy.deepcopy(bad['steps'][0])); bad['steps'][1]['index']=1
    write([bad,second]); check(any('claimed twice' in row['error'] for row in audit()['failures']))
    bad=copy.deepcopy(first); bad['ok']=False; bad['error']='foreground lost'; bad['failed_step']=1
    bad['steps'].append({'index':1,'ok':False,'step':{'op':'wait','duration_ms':50}})
    write([bad,second]); partial=audit()
    check(partial['status']=='failed' and len(partial['captures'])==2)
    check(partial['captures'][0]['request_ok'] is False) # retain pre-failure pixels without accepting request
    write(); (phase/'first.png').unlink(); check(audit()['status']=='failed')
    Image.new('RGB',(960,640),'green').save(phase/'first.png')
    Image.new('RGB',(20,20),'red').save(phase/'orphan.png')
    check(any('Orphan PNG' in row['error'] for row in audit()['failures']))
    (phase/'orphan.png').unlink()
    (phase/(first['id']+'.json')).write_text('{"ok":true,"ok":false}')
    check(any('Duplicate JSON' in row['error'] for row in audit()['failures']))
    write(); (phase/'first.png').write_bytes(b'invalid image')
    check(audit()['status']=='failed')
    Image.new('RGB',(960,640),'green').save(phase/'first.png')
    write(); (phase/'launch.json').unlink()
    try: audit()
    except ValueError: check(True)
    else: raise AssertionError('Missing owner admitted')
    check(module.collect([phase],evidence,pid=42,executable=exe)['status']=='passed')
    for folder in (evidence,evidence.parent,evidence/'..'/'outside'):
        try: module.guarded(folder,evidence)
        except ValueError: check(True)
        else: raise AssertionError('Unsafe path admitted')
    try: module.collect([phase,phase],evidence,pid=42,executable=exe)
    except ValueError: check(True)
    else: raise AssertionError('Duplicate folders admitted')
print(f'Native evidence review: PASS assertions={assertions}; synthetic pixels/metadata only, no OS input')
