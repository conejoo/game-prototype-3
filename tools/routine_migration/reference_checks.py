"""R001 offline pin/count/coverage/semantic gate. No Godot, saves or source writes.

Default verifies target-local snapshots and baseline bytes, allowing only exact
reviewed before/after hashes in adaptations.json. Source pins never change. Optional --source
refuses any live source input/revision drift. --self-test exercises fail-closed
hash, allowlist, exclusion, traversal and mapping refusals in isolated TEMP copies.
This is reference evidence, not target gameplay/route or source Dart test proof.
"""
from __future__ import annotations

import argparse
import copy
import json
import math
from pathlib import Path
import shutil
import tempfile
import time

import pin_reference as pin

REFERENCE = pin.ROOT/'tools/routine_migration/reference'
ADAPTATIONS = pin.ROOT/'tools/routine_migration/adaptations.json'
EXPECTED_IDS = sorted('celia-repairs-day celia-repairs-evening della-inn-day della-inn-evening edric-afternoon-river-notes edric-afternoon-rounds edric-evening-fishing edric-evening-rain-shelter harlan-docks-day harlan-docks-evening helena-afternoon-archive helena-afternoon-ledger-review helena-afternoon-moonflower-records helena-evening-archive ivo-docks-day ivo-docks-evening maris-chandlery-day maris-chandlery-evening tess-store-day tess-store-evening vale-breakfast vale-evening-home vale-midday-briefing vale-morning-work vale-overnight-home'.split())
SERVICES = ['celia-repairs', 'della-inn', 'harlan-docks', 'ivo-docks', 'maris-chandlery', 'tess-store']


def require(condition, message):
    if not condition:
        raise ValueError(message)


def child(root, relative):
    path = (root/relative).resolve()
    require(path.is_relative_to(root.resolve()) and not Path(relative).is_absolute(), f'Unsafe relative pin path: {relative}')
    return path


def minute(value):
    hour, minutes = map(int, value.split(':'))
    require(0 <= hour < 24 and 0 <= minutes < 60, 'Invalid clock time')
    return hour*60+minutes


def inside(window, now):
    start, end = minute(window['start']), minute(window['end'])
    require(start != end, 'Equal window rejected')
    return start <= now < end if start < end else now >= start or now < end


def matches(c, snapshot):
    kind = c['kind']; npc = c.get('npcId')
    if kind == 'worldEventActive':
        return c['eventId'] in snapshot.get('effective_events', [])
    if kind == 'worldEventInactive':
        return c['eventId'] not in snapshot.get('effective_events', [])
    if kind == 'learnedFact':
        return c['factId'] in snapshot.get('facts', {}).get(npc, [])
    if kind == 'relationshipFlagSet':
        return c['flagId'] in snapshot.get('flags', {}).get(npc, [])
    if kind == 'relationshipFlagUnset':
        return c['flagId'] not in snapshot.get('flags', {}).get(npc, [])
    require(kind == 'playerEvent', f'Unsupported condition {kind}')
    key = (c['eventKind'], c['subjectId'], c['targetId'])
    event = next((e for e in snapshot.get('events', []) if (e['kind'], e['subject_id'], e['target_id']) == key), None)
    count = event['count'] if event else 0
    if count < c['minimumCount'] or (c['maximumCount'] is not None and count > c['maximumCount']):
        return False
    recency = c['occurredWithinActiveSeconds']
    return recency is None or (event is not None and snapshot['active_seconds']-event['last_active_seconds'] <= recency)


def resolve(routines, snapshot):
    candidates, reasons, assignments = [], {}, {}
    for r in routines:
        reason = ('suppressedForDay' if r['id'] in snapshot.get('suppressed', []) else
                  'outsideWindow' if not inside(r['timeWindow'], minute(snapshot['time'])) else
                  'conditionNotMet' if not all(matches(c, snapshot) for c in r['conditions']) else None)
        if reason:
            reasons[r['id']] = reason
        else:
            candidates.append(r)
    for r in sorted(candidates, key=lambda r: (-r['priority'], r['id'])):
        if set(r['participants']) & assignments.keys():
            reasons[r['id']] = 'participantConflict'
        else:
            assignments.update({npc: r['id'] for npc in r['participants']})
    return assignments, reasons


def semantics(routines, vectors):
    assertions = 0; selected = set()
    by_id = {r['id']: r for r in routines}
    for v in vectors['selection_cases']:
        state = dict(v)
        state['effective_events'] = set(v.get('authored_events', [])) | ({'heavy-rain'} if v.get('weather') == 'thunderstorm' else set())
        state['events'] = [{'kind': 'resourceGathered', 'subject_id': 'moonflower', 'target_id': None, 'count': v.get('gather_count', 0), 'last_active_seconds': 0}]
        expected_ids = v['vale'] + [service+'-'+v['service_suffix'] for service in SERVICES]
        expected = {npc: rid for rid in expected_ids for npc in by_id[rid]['participants']}
        actual, _ = resolve(routines, state)
        require(actual == expected, f'Selection vector {v["id"]}: {actual} != {expected}')
        selected.update(actual.values()); assertions += 1
    require(selected == set(EXPECTED_IDS), 'Vectors do not select every one of 25 IDs'); assertions += 1
    for r in routines:
        state = {'time': r['timeWindow']['start'], 'effective_events': [], 'events': [], 'facts': {}, 'flags': {}}
        for c in r['conditions']:
            if c['kind'] == 'worldEventActive': state['effective_events'].append(c['eventId'])
            elif c['kind'] == 'learnedFact': state['facts'].setdefault(c['npcId'], []).append(c['factId'])
            elif c['kind'] == 'relationshipFlagSet': state['flags'].setdefault(c['npcId'], []).append(c['flagId'])
            elif c['kind'] == 'playerEvent': state['events'].append({'kind': c['eventKind'], 'subject_id': c['subjectId'], 'target_id': c['targetId'], 'count': c['minimumCount'], 'last_active_seconds': 0})
        require(bool(resolve([r], state)[0]), 'Inclusive start '+r['id'])
        state['time'] = r['timeWindow']['end']; require(not resolve([r], state)[0], 'Exclusive end '+r['id'])
        end = (minute(state['time'])-1) % 1440; state['time'] = f'{end//60:02}:{end%60:02}'
        require(bool(resolve([r], state)[0]), 'Last minute '+r['id']); assertions += 3
    fixture = lambda rid, priority, participants: {'id': rid, 'priority': priority, 'participants': participants, 'timeWindow': {'start': '00:00', 'end': '23:59'}, 'conditions': []}
    rows = [fixture('b-group', 100, ['npc-01','npc-02']), fixture('a-solo', 100, ['npc-01']), fixture('c-solo', 0, ['npc-02'])]
    actual, reasons = resolve(rows, {'time':'10:00'})
    require(actual == {'npc-01':'a-solo','npc-02':'c-solo'} and reasons['b-group'] == 'participantConflict', 'Tie ordering / atomic group rejection'); assertions += 1
    r = by_id['edric-afternoon-river-notes']
    require(resolve([r], {'time':'10:00','suppressed':[r['id']]})[1][r['id']] == 'suppressedForDay', 'Suppression precedence')
    require(resolve([r], {'time':'10:00'})[1][r['id']] == 'outsideWindow', 'Window precedence')
    require(resolve([r], {'time':'14:00'})[1][r['id']] == 'conditionNotMet', 'Condition precedence'); assertions += 3
    c = {'kind':'playerEvent','eventKind':'resourceGathered','subjectId':'moonflower','targetId':None,'minimumCount':1,'maximumCount':2,'occurredWithinActiveSeconds':120}
    e = {'kind':'resourceGathered','subject_id':'moonflower','target_id':None,'count':1,'last_active_seconds':30}
    for count, now, expect in [(0,150,False),(1,150,True),(2,150,True),(3,150,False),(1,150.001,False)]:
        event = dict(e, count=count); require(matches(c, {'events':[event], 'active_seconds':now}) == expect, 'Count/recency boundary'); assertions += 1
    require(not matches(c, {'events':[dict(e,target_id='other')], 'active_seconds':150}), 'Exact event query'); assertions += 1
    for v in vectors['clock_cases']:
        actual = (600+v['progress']*1440) % 1440
        require(math.isclose(actual, v['minute'], abs_tol=1e-9), 'Clock vector '+v['id']); assertions += 1
    for v in vectors['reconstruction_cases']:
        elapsed = (minute(v['time'])-minute(by_id[v['routine']]['timeWindow']['start'])) % 1440 / 1440 * 600
        require(math.isclose(elapsed, v['elapsed_seconds']), 'Elapsed-window vector'); assertions += 1
    authored = {'heavy-rain'}; derived = {'heavy-rain'}; authored.remove('heavy-rain')
    require(authored | derived == {'heavy-rain'}, 'Authored removal cannot clear derived storm'); assertions += 1
    # Source suppressions expire at the authoritative cycle wrap, not clock midnight.
    require(math.floor(7/12+.001) == 0 and math.floor(.999+.0011) == 1, 'Midnight/day wrap distinction'); assertions += 1
    return assertions


def adaptations(reference, path):
    """Owning-task records explain bounded target changes without replacing pins."""
    if not path.exists():
        return {}
    data = pin.read(path)
    require(set(data) == {'schema_version', 'changes'} and data['schema_version'] == 1 and isinstance(data['changes'], list), 'Invalid adaptation envelope')
    baseline = {e['path']: e['sha256'] for e in pin.read(reference/'preservation_baseline.json')['files']}
    baseline.update({e['path']: e['sha256'] for e in pin.read(reference/'manifest.json')['target_baseline']})
    result = {}
    for row in data['changes']:
        require(isinstance(row, dict) and set(row) == {'path', 'after_path', 'before_sha256', 'after_sha256', 'owner', 'reason'}, 'Invalid adaptation record')
        name = row['path']
        require(name in baseline and name not in result and row['before_sha256'] == baseline[name], 'Foreign/duplicate/mismatched adaptation baseline')
        require(row['owner'] in {'R004', 'R005', 'R006', 'R007', 'R008', 'R009', 'R010', 'R011', 'R012', 'R013', 'R014', 'R015'} and isinstance(row['reason'], str) and bool(row['reason'].strip()), 'Undocumented adaptation owner/reason')
        after = child(pin.ROOT, row['after_path'])
        require(after.is_file() and not after.is_symlink() and pin.sha(after) == row['after_sha256'], 'Adapted target hash drift: '+name)
        if row['after_path'] != name:
            require(name == 'game/tests/fixtures/environment_save_v7.json' and row['after_path'] == 'game/tests/fixtures/environment_save_v8.json' and not child(pin.ROOT, name).exists(), 'Unexplained target relocation')
        result[name] = row
    return result


def target_unchanged_or_adapted(entry, changes):
    if entry['path'] in changes:
        require(entry['sha256'] == changes[entry['path']]['before_sha256'], 'Adaptation cannot override pin: '+entry['path'])
    else:
        require(pin.sha(child(pin.ROOT, entry['path'])) == entry['sha256'], 'Unexplained target baseline drift: '+entry['path'])


def validate(reference=REFERENCE, source=None, adaptation_path=ADAPTATIONS):
    manifest = pin.read(reference/'manifest.json'); assertions = 0
    changes = adaptations(reference, adaptation_path)
    require(manifest['selected_ids'] == EXPECTED_IDS and manifest['roster'] == pin.ROSTER, 'Exact selected allowlist/roster drift'); assertions += 1
    require(manifest['source_catalog_count'] == 39, 'Source catalog count drift'); assertions += 1
    snapshot_paths = [e['snapshot_path'] for e in manifest['inputs'] if e['snapshot_path']]
    require(len(snapshot_paths)==len(set(snapshot_paths)), 'Duplicate pin paths')
    actual_paths = {p.relative_to(reference).as_posix() for p in (reference/'source').rglob('*') if p.is_file()}
    require(set(snapshot_paths)==actual_paths, 'Unmanifested snapshot files / missing pins')
    require(sorted(p.stem for p in (reference/'source/assets/data/routines').glob('*.json')) == EXPECTED_IDS, 'Excluded/extra routine snapshot')
    require(sorted(p.name for p in (reference/'source/assets/data/npcs').iterdir()) == pin.ROSTER, 'Excluded/extra NPC snapshot'); assertions += 4
    for entry in manifest['inputs']:
        if entry['snapshot_path']:
            require(pin.sha(child(reference, entry['snapshot_path'])) == entry['sha256'], 'Snapshot hash drift: '+entry['source_path']); assertions += 1
        if source:
            require(pin.sha(child(source, entry['source_path'])) == entry['sha256'], 'Live source hash drift: '+entry['source_path']); assertions += 1
    if source:
        require(pin.git(source, 'rev-parse', 'HEAD') == manifest['source_revision'], 'Source revision drift'); assertions += 1
    for entry in manifest['derived']:
        require(pin.sha(child(reference, entry['path'])) == entry['sha256'], 'Derived hash drift: '+entry['path']); assertions += 1
    for entry in manifest['target_baseline']:
        target_unchanged_or_adapted(entry, changes); assertions += 1
    catalog = pin.read(reference/'selected_catalog.json')
    require([e['id'] for e in catalog['routines']] == EXPECTED_IDS, 'Selected catalog allowlist drift'); assertions += 1
    routines = [pin.read(child(reference, 'source/'+e['asset'])) for e in catalog['routines']]
    require([r['id'] for r in routines] == EXPECTED_IDS and all(set(r['participants']) <= set(pin.ROSTER) for r in routines), 'Routine IDs/participants drift'); assertions += 1
    excluded = pin.read(reference/'exclusions.json')
    require(len(excluded['routine_ids']) == 14 and len(set(excluded['routine_ids'])) == 14 and not set(excluded['routine_ids']) & set(EXPECTED_IDS), 'Exact 14 exclusions drift')
    require(len(excluded['npc_ids']) == 7 and not set(excluded['npc_ids']) & set(pin.ROSTER), 'Seven excluded people drift'); assertions += 2
    targets = {(st['target']['mapId'],st['target']['anchorId']) for r in routines for ps in r['participantSteps'] for st in ps['steps'] if st['kind']=='move'}
    mapping = pin.read(reference/'mappings.json'); anchors = mapping['anchors']
    require(len(anchors) == 21 and {(a['source_map_id'],a['anchor_id']) for a in anchors} == targets, 'Exact 21 anchor mapping coverage')
    require([sum(a['source_map_id']==m for a in anchors) for m in ['alderwake','mayor-vale-home','lantern-rest']] == [11,9,1], '11/9/1 map coverage'); assertions += 2
    maps = {m: pin.read(reference/f'source/assets/maps/{name}.json') for m,name in pin.MAPS.items()}
    packages = {npc: {name:pin.read(reference/f'source/assets/data/npcs/{npc}/{name}.json') for name in ['runtime','dialogue','visuals']} for npc in pin.ROSTER}
    definitions = {o['id']:o for o in pin.read(reference/'world_objects.json')['objects']}
    layout = pin.read(pin.ROOT/'game/content/maps/alderwake_layout.json')
    contacts = pin.read(pin.ROOT/'tools/npc_migration/reference/contact_registry.json')['contacts']
    require(mapping == pin.mapping_data(routines,maps,layout,definitions,contacts), 'Anchor geometry/portal mapping differs from pinned source/target'); assertions += 1
    coverage = pin.read(reference/'coverage.json')
    target_catalog = pin.read(pin.ROOT/'game/content/npcs/catalog.json')
    expected_coverage = copy.deepcopy(coverage)
    # R001 coverage is immutable historical truth. Only this reviewed R011 public
    # activation changes current_target_enabled; every source field/owner stays exact.
    if changes.get('game/content/npcs/catalog.json', {}).get('owner') == 'R011':
        helena = next(p for p in target_catalog['packages'] if p['id'] == 'npc-02')
        enabled = {'node': ['npc-02-routine-archive-default', 'npc-02-routine-archive-indexing'],
                   'choice': ['npc-02-resume-archive-default-choice', 'npc-02-end-archive-default-choice', 'npc-02-resume-archive-indexing-choice', 'npc-02-review-archive-ledger-choice', 'npc-02-end-archive-indexing-choice'],
                   'fact': ['npc-02-archive-practice']}
        require(all(helena['coverage'][kind][identity]['status'] == 'enabled' for kind, ids in enabled.items() for identity in ids), 'R011 public archive activation incomplete'); assertions += 1
        for row in expected_coverage['routines']:
            for entry in row['dialogue_entries']:
                if entry['npc_id'] == 'npc-02' and entry['node_id'] in enabled['node']:
                    require(entry['owner'] == 'R011' and entry['current_target_enabled'] is False, 'Historical archive ownership/activation drift')
                    entry['current_target_enabled'] = True
        assertions += 1
    require(expected_coverage == pin.coverage(routines, packages, target_catalog, maps), 'Routine/step/dialogue/outcome ownership drift'); assertions += 1
    tags = {c['outcomeTag'] for p in packages.values() for n in p['dialogue']['nodes'] for c in n.get('choices',[]) if c.get('outcomeTag')}
    for r in routines:
        for d in r['interactionPolicy']['outcomeDirectives']:
            require(d['outcomeTag'] in tags, 'Dangling outcome '+d['outcomeTag']); assertions += 1
            if d['directive']['kind']=='jumpToStep':
                cmd = d['directive']; ids = [st['id'] for ps in r['participantSteps'] if ps['participantId']==cmd['participantId'] for st in ps['steps']]
                require(cmd['stepId'] in ids, 'Dangling participant jump'); assertions += 1
        for c in r['conditions']:
            if c['kind'] in ['learnedFact','relationshipFlagSet','relationshipFlagUnset']:
                runtime = packages[c['npcId']]['runtime']
                declared = [f['id'] for f in runtime['facts']] if c['kind']=='learnedFact' else runtime['routine']['relationshipFlagIds']
                require(c.get('factId',c.get('flagId')) in declared, 'Undeclared fact/flag'); assertions += 1
    for p in mapping['portals']:
        if p['source_map_id']=='alderwake':
            target = next(x for x in layout['portals'] if x['id']==p['id'])
            require(target['destination_map_id'] == p['destination_map_id'], 'Door destination drift')
            rect = p['flattened_rect_units']; left,top=pin.xz(rect[:2],'alderwake')
            require(target['rect_xz_m'] == [left,top,rect[2]/32,rect[3]/32], 'Grouped portal transform drift'); assertions += 2
    require(len(mapping['directed_chains']) == 9 and len(mapping['portals']) == 4, 'Qualified three-map chain coverage'); assertions += 1
    for x,y,q,expected in [(1,2,0,[65,98]),(1,2,1,[62,97]),(1,2,2,[63,94]),(1,2,3,[66,95])]:
        require(pin.transform(x,y,{'quarterTurns':q,'pivotX':2,'pivotY':3}) == expected,'Synthetic group rotation'); assertions += 1
    component = (reference/'source/lib/game/npc/npc_component.dart').read_text(encoding='utf-8')
    require(all(x in component for x in ['routineMovementSpeed = 64.0','routineBlockedWaitSeconds = 0.5','routineMaximumRepathAttempts = 2']), 'Movement constants drift'); assertions += 1
    executor = (reference/'source/lib/game/npc/npc_routine_executor.dart').read_text(encoding='utf-8')
    require('steps.length + 1024' in executor and '_snapToMoveTarget' in executor and 'initialOccupancyBlocked' in executor, 'Source reconstruction/occupancy pin drift'); assertions += 1
    adapter = (reference/'source/lib/game/world/cozy_adventure_world.dart').read_text(encoding='utf-8')
    require(all(s in adapter for s in ['origin.mapId','npc.occupancyRegistration.release();','npc.restoreRoutineOrigin(origin.point);','npc.advanceRoutine(directed.elapsedWindowSeconds);','reconstruct: false','reconstruct: true']), 'Source startup/load/ordinary reconstruction consumer drift'); assertions += 1
    require('**Status:** Pending' in (reference/'INT-064.md').read_text(encoding='utf-8'), 'Source INT-064 authority changed'); assertions += 1
    baseline = pin.read(reference/'preservation_baseline.json')
    for f in baseline['files']:
        target_unchanged_or_adapted(f, changes); assertions += 1
    budgets = pin.read(reference/'budgets.json')
    require(budgets['declared_before_runtime_implementation'] and budgets['targets']['scheduler_plus_eight_loaded_npc_p95_ms']==2 and budgets['targets']['path_query_p95_ms']==5 and budgets['targets']['ten_cycle_working_set_growth_mib']==64, 'Declared budgets missing/drift'); assertions += 1
    import audit_geometry
    require(pin.read(reference/'geometry_audit.json') == audit_geometry.build(), 'Static geometry audit drift'); assertions += 1
    assertions += semantics(routines, pin.read(reference/'vectors.json'))
    return {'status':'passed','assertions':assertions,'routines':25,'anchors':21,'source_inputs':len(manifest['inputs']),'source_revision':manifest['source_revision'],'target_revision':manifest['target_revision'],'target_adaptations':len(changes),'mode':'offline reference audit with exact target adaptations; no gameplay, source Dart tests, physical route or save claims'}


def self_test():
    cases = [
        ('snapshot-byte-drift', lambda p: (p/'source/assets/data/routines/vale-overnight-home.json').write_text('{}')),
        ('allowlist-drift', lambda p: mutate(p/'manifest.json', lambda d: d['selected_ids'].__setitem__(0,'asha-herb-day'))),
        ('excluded-cast', lambda p: forged_derived(p,'exclusions.json', lambda d: d['npc_ids'].append('npc-01'))),
        ('unsafe-pin-path', lambda p: mutate(p/'manifest.json', lambda d: d['inputs'][0].__setitem__('snapshot_path','../outside.json'))),
        ('qualified-anchor-drift', lambda p: forged_derived(p,'mappings.json', lambda d: d['anchors'][0].__setitem__('anchor_id','wrong-anchor'))),
        ('source-hash-expectation-drift', lambda p: mutate(p/'manifest.json', lambda d: d['inputs'][0].__setitem__('sha256','0'*64)))
    ]
    failures = []
    with tempfile.TemporaryDirectory(prefix='returning-fair-R001-') as scratch:
        root = Path(scratch)
        for name, change in cases:
            dst = root/name; shutil.copytree(REFERENCE,dst); change(dst)
            try:
                validate(dst)
            except (ValueError, FileNotFoundError) as e:
                failures.append({'case':name,'status':'correctly refused','reason':str(e)})
            else:
                raise ValueError('Negative fixture incorrectly accepted: '+name)
        if ADAPTATIONS.exists():
            for name, change in [
                ('adaptation-after-drift', lambda d: d['changes'][0].__setitem__('after_sha256', '0'*64)),
                ('adaptation-before-drift', lambda d: d['changes'][0].__setitem__('before_sha256', '0'*64)),
                ('adaptation-foreign-path', lambda d: d['changes'][0].__setitem__('path', '../outside')),
                ('adaptation-duplicate', lambda d: d['changes'].append(dict(d['changes'][0])))
            ]:
                ledger = root/(name+'.json'); shutil.copyfile(ADAPTATIONS, ledger); mutate(ledger, change)
                try:
                    validate(adaptation_path=ledger)
                except (ValueError, FileNotFoundError) as error:
                    failures.append({'case':name,'status':'correctly refused','reason':str(error)})
                else:
                    raise ValueError('Negative adaptation incorrectly accepted: '+name)
    return failures


def mutate(path, action):
    data = pin.read(path); action(data); pin.write(path,data)


def forged_derived(root, name, action):
    mutate(root/name,action)
    # Recompute fixture hash to exercise independent semantic refusal too.
    mutate(root/'manifest.json',lambda m: next(x for x in m['derived'] if x['path']==name).__setitem__('sha256',pin.sha(root/name)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path)
    parser.add_argument('--self-test',action='store_true')
    parser.add_argument('--report',type=Path)
    args = parser.parse_args(); started = time.perf_counter()
    try:
        report = validate(source=args.source.resolve() if args.source else None)
        report['negative_fixtures'] = self_test() if args.self_test else []
    except Exception as error:
        report = {'status':'failed','error':str(error)}
    report['elapsed_ms'] = (time.perf_counter()-started)*1000
    if args.report:
        pin.write(args.report,report)
    print(json.dumps(report,indent=2))
    return 0 if report['status']=='passed' else 1


if __name__ == '__main__':
    raise SystemExit(main())
