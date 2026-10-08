"""Read-only pinned-reference, coverage, geometry and production identity audit."""
import argparse, collections, hashlib, json, pathlib, re, struct, sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
REF=ROOT/'tools/npc_migration/reference'
ROSTER=('npc-01','npc-02','npc-03','npc-04','npc-06','npc-07','npc-08','npc-14')

def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok: raise ValueError(message)

def audit(source=None, geometry=None):
    manifest=read(REF/'manifest.json');rows=read(REF/'coverage.json')
    require(tuple(manifest['selected_ids'])==ROSTER,'fixed eight roster')
    require(manifest['source_revision']=='60c20eb2816e7271fb84afaba286af006ebe3ccf','pinned source revision')
    copied=set()
    for row in manifest['inputs']:
        require(row['source_revision']==manifest['source_revision'],'per-input revision')
        if 'snapshot_path' in row:
            path=REF/row['snapshot_path'];require(path.is_relative_to(REF),'snapshot path boundary')
            require(sha(path)==row['sha256'],'snapshot drift: '+str(path))
            require(path.stat().st_size==row['bytes'],'snapshot bytes')
            copied.add(path.relative_to(REF).as_posix())
            if path.suffix=='.png':
                data=path.read_bytes(); require(data[:8]==b'\x89PNG\r\n\x1a\n','PNG signature')
                require(list(struct.unpack('>II',data[16:24]))==row['dimensions_px'],'PNG dimensions')
        if source:
            require(sha(source/row['source_path'])==row['sha256'],'source drift: '+row['source_path'])
    for row in manifest['generated']:require(sha(REF/row['path'])==row['sha256'],'generated fixture drift: '+row['path'])
    actual={p.relative_to(REF).as_posix() for p in (REF/'assets').rglob('*') if p.is_file()}
    require(actual==copied,'no extra public/source assets')
    require(not any('docs/npcs' in p or p.endswith('.dart') for p in copied),'no private profiles/Flutter copies')
    require(all(r['status'] in ('enabled','deferred') and r['reason'].strip() for r in rows),'explicit status/reason for every row')
    catalog=read(REF/'selected_catalog.json')['npcs']; require(tuple(e['id'] for e in catalog)==ROSTER,'selected catalog')
    totals=collections.Counter()
    for entry in catalog:
        npc=entry['id'];runtime=read(REF/entry['runtime']);graph=read(REF/entry['dialogue']);visual=read(REF/entry['visuals'])
        require(runtime['id']==graph['npcId']==visual['npcId']==npc,'cross-file identity')
        nodes={n['id']:n for n in graph['nodes']};facts={f['id'] for f in runtime['facts']};flags=set(runtime['routine']['relationshipFlagIds']); gifts={g['id'] for g in runtime['acceptedGiftRules']}
        require(len(nodes)==len(graph['nodes']),'duplicate nodes'); require(len(set(graph['entryNodeIds']))==len(graph['entryNodeIds']) and set(graph['entryNodeIds'])<=set(nodes),'entry index')
        expected={'node':set(nodes),'choice':set(),'fact':facts,'gift_rule':gifts,'portrait':set(visual['portraits']),'sheet':{'idle','walk',*visual['world'].get('actions',{})},'condition':set()}
        node_rows={r['id']:r for r in rows if r['npc_id']==npc and r['kind']=='node'}
        choice_rows={r['id']:r for r in rows if r['npc_id']==npc and r['kind']=='choice'}
        edges={}
        for node in graph['nodes']:
            require(node_rows[node['id']]['source_fields']==node,'node field/text parity')
            require(node['portraitId'] in visual['portraits'],'portrait reference')
            require(set(node.get('revealedFactIds',[]))<=facts,'disclosed facts')
            targets=[]
            for choice in node.get('choices',[]):
                require(choice['id'] not in expected['choice'],'duplicate choices');expected['choice'].add(choice['id'])
                require(choice_rows[choice['id']]['source_fields']==choice,'choice field/text parity')
                require(set(choice.get('addedFlags',[]))<=flags,'declared flags')
                require(not choice.get('oneTimeRewardFlag') or choice['oneTimeRewardFlag'] in flags,'receipt flag')
                require(-1<=choice.get('affinityDelta',0)<=1,'signed choice range')
                require(bool(choice.get('targetNodeId')) != bool(choice.get('endsConversation',False)),'finite choice transition')
                if choice.get('targetNodeId'): targets.append(choice['targetNodeId'])
                if choice.get('giftRuleId'): require(choice['giftRuleId'] in gifts and choice_rows[choice['id']]['status']=='deferred','gift binding deferred')
                if choice.get('outcomeTag'): require(choice_rows[choice['id']]['status']=='deferred','routine outcome deferred')
            if node.get('continueTargetId'): targets.append(node['continueTargetId'])
            require(not (node.get('choices') and node.get('continueTargetId')),'choice/continue exclusive')
            require(set(targets)<=set(nodes),'dangling transitions');edges[node['id']]=targets
            condition=node.get('conditions',{})
            for key in condition: expected['condition'].add(node['id']+':'+key)
            require(set(condition.get('requiredFlags',[])+condition.get('excludedFlags',[]))<=flags,'condition flags')
            require(set(condition.get('requiredFactIds',[])+condition.get('unknownFactIds',[]))<=facts,'condition facts')
            require(set(condition.get('requiredSeenNodeIds',[])+condition.get('unseenNodeIds',[]))<=set(nodes),'seen references')
        def visit(node, stack):
            require(node not in stack,'cyclic graph');
            for target in edges[node]:visit(target,stack|{node})
        for node in nodes:visit(node,set())
        for kind,ids in expected.items():
            actual_rows=[r for r in rows if r['npc_id']==npc and r['kind']==kind]
            require(len(actual_rows)==len(ids) and {r['id'] for r in actual_rows}==ids,'exact '+npc+' '+kind+' coverage')
            totals[kind]+=len(ids)
        for r in [r for r in rows if r['npc_id']==npc and r['kind']=='fact']:
            disclosure=[n['id'] for n in graph['nodes'] if r['id'] in n.get('revealedFactIds',[])]
            require(r['disclosure_nodes']==disclosure,'fact disclosure trace')
            require(r['status']==('enabled' if any(node_rows[n]['status']=='enabled' for n in disclosure) else 'deferred'),'fact status')
        for r in [r for r in rows if r['npc_id']==npc and r['kind']=='portrait']:require(r['dimensions_px']==[512,512],'portrait512')
        for r in [r for r in rows if r['npc_id']==npc and r['kind']=='sheet']:
            sheet=r['source_fields']; require(r['dimensions_px']==[sheet['textureCellWidth']*sheet['framesPerFacing'],sheet['textureCellHeight']*len(r['row_order'])],'sheet cell layout')
    require(dict(totals)=={'node':70,'choice':54,'fact':24,'gift_rule':8,'portrait':48,'sheet':18,'condition':30},'observed counts')
    baseline=read(REF/'target_baseline.json')
    for row in baseline['files']:require(sha(ROOT/row['path'])==row['sha256'],'production drift: '+row['path'])
    production={p.relative_to(ROOT).as_posix() for name in ('game','art') for p in (ROOT/name).rglob('*') if p.is_file() and '.godot' not in p.parts and '__pycache__' not in p.parts}
    require(production=={r['path'] for r in baseline['files']},'production file additions/removals')
    codec=(ROOT/'game/core/save_codec.gd').read_text();require('SCHEMA_VERSION: int = 6' in codec and 'CONTENT_VERSION: int = 1' in codec,'baseline versions')
    if geometry:
        report=read(geometry);require(not report['failures'] and report['definitions']==21,'geometry status/catalog')
        require({c['npc_id'] for c in report['contacts']}==set(ROSTER) and len(report['contacts'])==8,'all physical contacts')
        for c in report['contacts']:
            require(not c['actor_support']['errors'] and not c['approach_support']['errors'] and not c['path_errors'],'physical clearance')
            require(len(c['actor_support']['support'])==9 and len(c['approach_support']['support'])==9,'full support samples')
            require(c['los'] and c['nav_distance_m']<=.3 and c['interaction_distance_m']<=1.7 and c['path_samples']>0,'access/range')
        require(len(report['negative_probes'])==3 and all(x['errors'] for x in report['negative_probes']),'water/wall negatives')
        pinned=read(REF/'contact_registry.json')
        require(len(pinned['contacts'])==8,'contact registry count')
        for c,r in zip(pinned['contacts'],report['contacts']):require(c['npc_id']==r['npc_id'] and c['target_foot_m']==r['actor_foot'] and c['player_approach_m']==r['player_approach'],'registry measured parity')
    print('N001_REFERENCE PASS '+json.dumps({'counts':dict(totals),'copied_files':len(copied),'source_inputs':len(manifest['inputs']),'production_files_unchanged':len(baseline['files']),'classification':dict(collections.Counter(r['status'] for r in rows if r['kind'] in ('node','choice')))},sort_keys=True))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--source',type=pathlib.Path);parser.add_argument('--geometry',type=pathlib.Path)
    args=parser.parse_args()
    try:audit(args.source,args.geometry)
    except (ValueError,OSError,KeyError) as error:print('N001_REFERENCE FAIL',error);sys.exit(1)
