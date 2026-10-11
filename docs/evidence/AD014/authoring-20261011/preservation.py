from pathlib import Path
import hashlib, json, subprocess, sys
ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
def snapshot():
    result = subprocess.run(['git','-c',f'safe.directory={ROOT.as_posix()}','ls-files','--cached','--others','--exclude-standard','-z'],cwd=ROOT,check=True,capture_output=True)
    return {p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sorted(set(result.stdout.decode().strip('\0').split('\0'))) if (ROOT/p).is_file()}
if sys.argv[1]=='start':
    (OUT/'starting-files.json').write_text(json.dumps(snapshot(),indent=2)+'\n')
    print('starting snapshot',len(snapshot()))
else:
    before=json.loads((OUT/'starting-files.json').read_text()); after=snapshot()
    allowed=set(json.loads((OUT/'task-scope.json').read_text()))
    unexpected=[p for p in before if p not in allowed and before[p]!=after.get(p)]
    added=[p for p in after if p not in before and p not in allowed]
    result={'starting':len(before),'protected':len(set(before)-allowed),'unexpected':unexpected,'unexpected_added':added,'task_hashes':{p:after.get(p) for p in sorted(allowed)}}
    (OUT/'preservation.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result)); assert not unexpected and not added
