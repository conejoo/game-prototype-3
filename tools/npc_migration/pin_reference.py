"""Explicit N001 public snapshot. Refuses replacement; never writes source or game."""
import argparse, hashlib, json, pathlib, shutil, struct, subprocess

ROSTER = ('npc-01','npc-02','npc-03','npc-04','npc-06','npc-07','npc-08','npc-14')
ROOT = pathlib.Path(__file__).resolve().parents[2]
REF = ROOT / 'tools/npc_migration/reference'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

def png(path):
    data=path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n': raise ValueError(f'Not PNG: {path}')
    return list(struct.unpack('>II',data[16:24]))

def classification(npc, node, choice=None):
    ident=node['id']
    if '-routine-' in ident:
        return 'deferred', 'Requires archive routine entry/consumer; no preferred-entry injection, ledger jump or daily suppression.'
    if ident == 'npc-01-level-1-milestone':
        return 'deferred', 'Retain level>=1 and unseen milestone gate. Ordinary introduction gives at most1; gifts/progression unavailable.'
    if choice and choice.get('giftRuleId'):
        return 'deferred', 'Gift capability unavailable regardless of item ownership; no consume/affinity/cap event.'
    if (choice and choice['id']=='npc-14-ask-room') or ident=='npc-14-room':
        return 'deferred', 'Interior directional branch unavailable at exterior contact; no room entitlement or guessed indoor transform.'
    if '-gift-' in ident and choice is None:
        return 'deferred', 'Only incoming transitions are deferred gift transactions.'
    return 'enabled', 'Ordinary public graph; preserve all authored gates and text except explicit audited adaptation.'

def pin(source):
    if (REF/'manifest.json').exists(): raise SystemExit('Pinned manifest exists; audit drift, do not silently refresh.')
    revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=source,text=True).strip()
    status=subprocess.check_output(['git','status','--short'],cwd=source,text=True).strip()
    if status: raise SystemExit('Source dirty; reconcile before pinning: '+status)
    inputs={}; coverage=[]
    def record(rel, copy=False, purpose='public package'):
        path=source/rel
        if rel in inputs: return
        row={'source_path':rel,'source_revision':revision,'sha256':digest(path),'bytes':path.stat().st_size,'purpose':purpose}
        if copy:
            dst=REF/rel; dst.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(path,dst)
            row['snapshot_path']=rel
        if path.suffix.lower()=='.png': row['dimensions_px']=png(path)
        inputs[rel]=row
    catalog=read(source/'assets/data/npcs/catalog.json')
    record('assets/data/npcs/catalog.json',purpose='15-person authority; selected adapter retains eight only')
    selected=[x for x in catalog['npcs'] if x['id'] in ROSTER]
    if tuple(x['id'] for x in selected)!=ROSTER: raise ValueError('Unexpected catalog ordering/roster')
    write(REF/'selected_catalog.json', {'npcs':selected})
    for entry in selected:
        npc=entry['id']
        for kind in ('runtime','dialogue','visuals'): record(entry[kind],True)
        runtime=read(source/entry['runtime']); graph=read(source/entry['dialogue']); visual=read(source/entry['visuals'])
        for node in graph['nodes']:
            status,reason=classification(npc,node)
            coverage.append({'npc_id':npc,'kind':'node','id':node['id'],'status':status,'reason':reason,'source_path':entry['dialogue'],'source_fields':node,'entry_index':graph['entryNodeIds'].index(node['id']) if node['id'] in graph['entryNodeIds'] else None})
            for choice in node.get('choices',[]):
                status,reason=classification(npc,node,choice)
                coverage.append({'npc_id':npc,'kind':'choice','node_id':node['id'],'id':choice['id'],'status':status,'reason':reason,'source_path':entry['dialogue'],'source_fields':choice})
            conditions=node.get('conditions',{})
            for key,value in conditions.items():
                coverage.append({'npc_id':npc,'kind':'condition','node_id':node['id'],'id':node['id']+':'+key,'status':classification(npc,node)[0],'reason':'Evaluated conjunctively; retained even on deferred node.','source_fields':{key:value}})
        for fact in runtime['facts']:
            nodes=[n['id'] for n in graph['nodes'] if fact['id'] in n.get('revealedFactIds',[])]
            enabled=[n for n in graph['nodes'] if n['id'] in nodes and classification(npc,n)[0]=='enabled']
            coverage.append({'npc_id':npc,'kind':'fact','id':fact['id'],'status':'enabled' if enabled else 'deferred','reason':'Disclosure only on authored node entry.' if enabled else ('Only archive routine discloses this fact.' if nodes else 'Declared but no source node discloses this fact; no automatic role/action disclosure.'),'disclosure_nodes':nodes,'source_fields':fact})
        for gift in runtime.get('acceptedGiftRules',[]):
            coverage.append({'npc_id':npc,'kind':'gift_rule','id':gift['id'],'status':'deferred','reason':'Typed future gift capability; retain acceptance cap and fact gate without executing.','source_fields':gift})
        for ident,rel in visual['portraits'].items():
            record(rel,True,'approved original portrait')
            coverage.append({'npc_id':npc,'kind':'portrait','id':ident,'status':'enabled','reason':'Exact reference pixels; expressions stay available, disclosure remains graph-gated.','source_path':rel,'sha256':inputs[rel]['sha256'],'dimensions_px':inputs[rel]['dimensions_px']})
        for kind,sheet in [('idle',visual['world']['idle']),('walk',visual['world']['walk']),*visual['world'].get('actions',{}).items()]:
            rel=sheet['asset'];record(rel,True,'3D identity/motion reference only')
            coverage.append({'npc_id':npc,'kind':'sheet','id':kind,'status':'enabled','reason':'ART reference, no 3D asset or runtime animation claim.','source_fields':sheet,'dimensions_px':inputs[rel]['dimensions_px'],'row_order':visual['world']['rowOrder']})
    authority=['lib/game/dialogue/dialogue_model.dart','lib/game/dialogue/dialogue_repository.dart','lib/game/dialogue/dialogue_document_codec.dart','lib/game/dialogue/dialogue_choice_eligibility.dart','lib/game/state/runtime_game_state.dart','lib/game/state/runtime_game_controller.dart','lib/game/state/player_event_journal.dart','lib/game/npc/npc_content_validator.dart','lib/game/npc/npc_runtime_document_codec.dart','docs/towns/alderwake.md','docs/returning-fair-cast-integration.md','docs/returning-fair-integration-checklist.md','docs/visual-assets.md','assets/maps/project.json','assets/maps/mvp_world.json','assets/maps/lantern_rest.json']
    for rel in authority: record(rel,purpose='read-only semantic/canon/placement authority; hash only, not bundled')
    routines=[]
    for path in sorted((source/'assets/data/routines').glob('*.json')):
        doc=read(path)
        if set(doc.get('participants',[])) & set(ROSTER):
            rel=path.relative_to(source).as_posix(); record(rel,purpose='selected action/entry context; no schedule port')
            routines.append({'source_path':rel,'id':doc['id'],'participants':[x for x in doc['participants'] if x in ROSTER],'timeWindow':doc.get('timeWindow'),'interactionPolicy':doc.get('interactionPolicy'),'steps':[x for x in doc.get('participantSteps',[]) if x['participantId'] in ROSTER]})
    write(REF/'routine_context.json',routines)
    maps=[]
    for rel in ['assets/maps/mvp_world.json','assets/maps/lantern_rest.json']:
        doc=read(source/rel)
        wanted=('edric','helena','maris','harlan','store-service','passenger-booking','celia-basic','inn-host','inn-meal-player','inn-exit-player')
        objects=[{'source_index':i,**o} for i,o in enumerate(doc['objects']) if o.get('definitionId') in ROSTER or o.get('type')=='routineAnchor' and o['id'].startswith(wanted)]
        maps.append({'source_path':rel,'map_id':doc['mapId'],'objects':objects,'woods_zones':[z for z in doc.get('zones',[]) if z['role']=='woods'],'exterior_inn_group':[{'id':g['id'],'pivotX':g['pivotX'],'pivotY':g['pivotY'],'quarterTurns':g['quarterTurns'],'portals':g.get('portals',[]),'props':g.get('props',[])} for g in doc.get('groups',[]) if g['id']=='lantern-rest-exterior']})
    write(REF/'placement_context.json',maps)
    write(REF/'coverage.json',coverage)
    adaptations=[{'npc_id':'npc-14','node_id':'npc-14-introduction','field':'text','reason':'Public exterior contact; no accessible interior/sleep/room promise.','target_text':'Della Pike, **innkeeper** at Lantern Rest. I am meeting visitors here at the public entrance. Questions and quiet company are welcome; the inn interior is not open in this prototype.'}]
    write(REF/'adaptations.json',adaptations)
    production=[]
    for dirname in ('game','art'):
        for path in sorted((ROOT/dirname).rglob('*')):
            if path.is_file() and '.godot' not in path.parts and '__pycache__' not in path.parts:
                production.append({'path':path.relative_to(ROOT).as_posix(),'sha256':digest(path)})
    write(REF/'target_baseline.json',{'target_head':subprocess.check_output(['git','-c','safe.directory='+str(ROOT),'rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'schema_version':6,'content_version':1,'files':production})
    manifest={'schema_version':1,'snapshot_id':'villagers-60c20eb2-n001','source_revision':revision,'selected_ids':list(ROSTER),'source_catalog_count':len(catalog['npcs']),'inputs':list(inputs.values()),'generated':[],'policy':'Explicit pin; originals immutable. Runtime conversion later uses selected target-local files only. No source checkout dependency.'}
    for path in sorted(REF.glob('*.json')):
        manifest['generated'].append({'path':path.name,'sha256':digest(path)})
    write(REF/'manifest.json',manifest)
    print('Pinned',len(inputs),'source inputs;',sum('snapshot_path' in x for x in inputs.values()),'byte-exact copies;',len(production),'unchanged production files.')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--source',required=True,type=pathlib.Path)
    pin(parser.parse_args().source)
