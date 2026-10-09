"""One-shot R001 public reference capture. Refuses overwrite; never writes source.

Snapshot is engineering evidence, outside game/export. Revisions are observations.
Use --source explicitly. Later tasks run reference_checks.py, not this capture.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
ROSTER = ['npc-01', 'npc-02', 'npc-03', 'npc-04', 'npc-06', 'npc-07', 'npc-08', 'npc-14']
MAPS = {'alderwake': 'mvp_world', 'mayor-vale-home': 'mayor_vale_home', 'lantern-rest': 'lantern_rest'}
ORIGINS = {'alderwake': [704, 576], 'mayor-vale-home': [256, 384], 'lantern-rest': [448, 672]}


def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False, allow_nan=False) + '\n', encoding='utf-8')


def git(root, *args):
    return subprocess.check_output(['git', '-c', f'safe.directory={root.as_posix()}', '-C', str(root), *args], text=True).strip()


def transform(x, y, group=None):
    if group:
        x, y = [(x, y), (-y, x), (-x, -y), (y, -x)][group['quarterTurns'] % 4]
        x += group['pivotX'] * 32
        y += group['pivotY'] * 32
    return [x, y]


def flat(map_data, kind):
    result = [(x, None) for x in map_data.get(kind, [])]
    for g in map_data.get('groups', []):
        result += [(x, g) for x in g.get('props' if kind == 'objects' else kind, [])]
    return result


def xz(point, map_id):
    return [(point[i] - ORIGINS[map_id][i]) / 32 for i in range(2)]


def polygon_rect(rect):
    x, z, w, h = rect
    return [[x, z], [x+w, z], [x+w, z+h], [x, z+h]]


def distance(point, polygon):
    """Signed Euclidean distance to polygon; negative inside. No route claim."""
    px, py = point
    inside, best = False, math.inf
    for i, a in enumerate(polygon):
        b = polygon[(i+1) % len(polygon)]
        ax, ay = a; bx, by = b
        if (ay > py) != (by > py) and px < (bx-ax)*(py-ay)/(by-ay)+ax:
            inside = not inside
        dx, dy = bx-ax, by-ay
        u = max(0, min(1, ((px-ax)*dx+(py-ay)*dy)/(dx*dx+dy*dy)))
        best = min(best, math.hypot(px-ax-u*dx, py-ay-u*dy))
    return -best if inside else best


def source_polygons(data, definitions):
    result = []
    for c, g in flat(data, 'colliders'):
        result.append((c['id'], [transform(*p, g) for p in polygon_rect([c['left'], c['top'], c['width'], c['height']])]))
    for o, g in flat(data, 'objects'):
        if o['type'] != 'prop' or not o.get('collisionEnabled', True):
            continue
        c = definitions[o['definitionId']].get('collision')
        if not c or c['kind'] == 'none':
            continue
        points = [[p['x'], p['y']] for p in c['points']] if c['kind'] == 'polygon' else polygon_rect([c['left'], c['top'], c['width'], c['height']])
        result.append(('prop:'+o['id'], [transform(p[0]+o['x'], p[1]+o['y'], g) for p in points]))
    return result


def height(layout, point):
    cell = [math.floor(point[0]+22), math.floor(point[1]+18)]
    for s in layout['elevation']['slopes']:
        if s['cell'] == cell:
            x, z = point[0]+22-cell[0], point[1]+18-cell[1]
            progress = {'north': 1-z, 'east': x, 'south': z, 'west': 1-x}[s['ascends_toward']]
            return s['low_height_m'] + .25 * max(0, min(1, progress))
    return next((x['height_m'] for x in layout['elevation']['cells'] if x['cell'] == cell), 0.0)


def mapping_data(routines, maps, layout, definitions, contacts):
    targets = sorted({(st['target']['mapId'], st['target']['anchorId']) for r in routines for ps in r['participantSteps'] for st in ps['steps'] if st['kind'] == 'move'})
    contact_by_anchor = {x['source_anchor_id']: x for x in contacts}
    pins = {x['id']: x for x in layout['inert_objects']}
    exterior_polys = [(p['collision']['id'], p['collision']['vertices_xz_m']) for p in layout['props'] if p['collision']]
    exterior_polys += [(c['id'], polygon_rect(c['rect_xz_m'])) for c in layout['colliders']]
    blockers = []
    for c in contacts:
        p = c['target_foot_m']; radius = .35 if c['npc_id'] == 'npc-03' else .4
        blockers.append({'id': c['target_wrapper_id'], 'npc_id': c['npc_id'], 'rect_xz_m': [p[0]-radius, p[2]-radius, 2*radius, 2*radius], 'owner': 'R009', 'repair': 'remove static actor outline/body when dynamic owner installed; retain unique identity'})
    blockers += [{'id': 'MarisBench', 'rect_xz_m': [-8.6, 11.45, 2.2, .7], 'owner': 'R009', 'repair': 'retain real furniture collision'}, {'id': 'TemporaryCompanion', 'rect_xz_m': [-2.35, -.35, .7, .7], 'owner': 'R009', 'repair': 'preserve station/party identity; query actual occupied body'}]
    anchors = []
    for map_id, anchor_id in targets:
        obj = next(o for o, _ in flat(maps[map_id], 'objects') if o['id'] == anchor_id)
        point = [obj['x'], obj['y']]
        derived = xz(point, map_id)
        proposed = derived
        adaptation = 'retain source anchor; physical clearance validation pending'
        if map_id == 'alderwake' and anchor_id in contact_by_anchor:
            c = contact_by_anchor[anchor_id]
            proposed = [c['target_foot_m'][0], c['target_foot_m'][2]]
            adaptation = c['policy']
        owner = 'R006' if map_id == 'alderwake' else ('R007' if map_id == 'mayor-vale-home' else 'R008')
        polys = exterior_polys if map_id == 'alderwake' else [(i, [xz(p, map_id) for p in poly]) for i, poly in source_polygons(maps[map_id], definitions)]
        distances = sorted((distance(proposed, poly), i) for i, poly in polys)
        near = [{'id': i, 'center_clearance_m': round(d, 6), 'capsule_margin_m': round(d-.4, 6)} for d, i in distances[:5]]
        conflicts = [i for d, i in distances if d < .45]
        actor_obstacles = [b['id'] for b in blockers if map_id == 'alderwake' and distance(proposed, polygon_rect(b['rect_xz_m'])) < .45]
        y = height(layout, proposed) if map_id == 'alderwake' else 0.0
        anchors.append({'source_map_id': map_id, 'anchor_id': anchor_id, 'runtime_location_id': 'prototype-'+map_id, 'source_foot_units': point, 'source_facing': obj.get('facing', 'south'), 'source_tags': obj.get('tags', []), 'derived_xz_m': derived, 'proposed_foot_xyz_m': [proposed[0], y, proposed[1]], 'delta_xz_m': [proposed[i]-derived[i] for i in range(2)], 'adaptation': adaptation, 'pinned_exterior_anchor': pins.get(anchor_id), 'nearest_static_geometry': near, 'static_conflicts': conflicts, 'fixed_contact_conflicts': actor_obstacles, 'owner': owner, 'validation': 'static audit only; paths/support/capsule/LOS/occupancy NOT accepted', 'repair_proposal': 'retain geography; remove retired actor bake obstacle in R009; measure minimal station/approach adaptation in '+owner if actor_obstacles or conflicts else 'validate dry support, current capsule, paths and LOS in '+owner})
    portals = []
    for map_id, data in maps.items():
        for p, g in flat(data, 'portals'):
            if p['destinationMapId'] not in MAPS:
                continue
            corners = [transform(*pt, g) for pt in polygon_rect([p['left'], p['top'], p['width'], p['height']])]
            center = transform(p['left']+p['width']/2, p['top']+p['height']/2, g)
            left, top = min(v[0] for v in corners), min(v[1] for v in corners)
            w, h = max(v[0] for v in corners)-left, max(v[1] for v in corners)-top
            destination = p['destinationMapId']
            source_xz = xz(center, map_id)
            dest_xz = xz([p['destinationX'], p['destinationY']], destination)
            portals.append({'id': p['id'], 'source_map_id': map_id, 'destination_map_id': destination, 'source_location_id': 'prototype-'+map_id, 'destination_location_id': 'prototype-'+destination, 'source_group': g, 'flattened_rect_units': [left, top, w, h], 'source_point_units': center, 'source_point_xz_m': source_xz, 'destination_units': [p['destinationX'], p['destinationY']], 'destination_point_xz_m': dest_xz, 'arrival_id': destination+'-from-'+map_id, 'owners': ['R005', 'R006' if map_id == 'alderwake' else ('R007' if map_id == 'mayor-vale-home' else 'R008')], 'physical_validation': 'unrun; source door center is not yet an accepted player/NPC approach'})
    chains = []
    for start in MAPS:
        for end in MAPS:
            queue = [(start, [])]; seen = set()
            while queue:
                node, path = queue.pop(0)
                if node == end:
                    chains.append({'source_map_id': start, 'destination_map_id': end, 'portal_ids': path}); break
                if node in seen:
                    continue
                seen.add(node)
                queue += [(p['destination_map_id'], path+[p['id']]) for p in portals if p['source_map_id'] == node]
    return {'coordinate_origins_units': ORIGINS, 'metres_per_cell': 1, 'anchors': anchors, 'portals': portals, 'directed_chains': chains, 'fixed_obstacles': blockers, 'existing_player_travel': {'source_location': 'prototype-alderwake', 'interaction_id': 'alderwake-travel-gate', 'destination_location': 'prototype-tollworks', 'arrival_id': 'tollworks-from-alderwake', 'return_arrival_id': 'alderwake-from-tollworks', 'owners': ['R005'], 'policy': 'retain existing real IDs; runtime APIs remain single destination until R005'}, 'excluded_portals': [p['id'] for p in layout['portals'] if p['destination_map_id'] not in MAPS and p['id'] != 'tollworks-entrance-01']}


def coverage(routines, packages, target_catalog, maps):
    target_packages = {p['id']: p for p in target_catalog['packages']}
    result = []
    for r in routines:
        participants, step_rows = r['participants'], []
        for ps in r['participantSteps']:
            previous = None
            for st in ps['steps']:
                kind = st['kind']
                row = {'participant_id': ps['participantId'], 'step_id': st['id'], 'kind': kind, 'definition_owner': 'R002', 'execution_owner': 'R010', 'presentation_owner': 'R012', 'source': st}
                if kind == 'move':
                    target = st['target']; map_id = target['mapId']
                    row.update(qualified_target=map_id+':'+target['anchorId'], mapping_owner='R006' if map_id == 'alderwake' else ('R007' if map_id == 'mayor-vale-home' else 'R008'), movement_owner='R009', previous_qualified_target=previous)
                    previous = row['qualified_target']
                step_rows.append(row)
        policy = r['interactionPolicy']; entries = []
        for e in policy['stepDialogueEntries']:
            entries.append({'npc_id': e['participantId'], 'node_id': e['dialogueEntryNodeId'], 'step_id': e['stepId'], 'owner': 'R011'})
        if policy['defaultDialogueEntryNodeId']:
            entries.append({'npc_id': 'npc-02', 'node_id': policy['defaultDialogueEntryNodeId'], 'step_id': None, 'owner': 'R011'})
        for e in entries:
            npc = e['npc_id']; node = next(n for n in packages[npc]['dialogue']['nodes'] if n['id'] == e['node_id'])
            e['source_node'] = node
            e['current_target_enabled'] = target_packages[npc]['coverage']['node'][e['node_id']]['status'] == 'enabled'
            e['directive_choice_ids'] = [c['id'] for c in node.get('choices', []) if c.get('outcomeTag')]
        result.append({'routine_id': r['id'], 'participants': participants, 'selector_owner': 'R003', 'activation_owner': 'R013', 'conditions': [{'source': c, 'owner': 'R003', 'durable_owner': 'existing conversation/event memory' if c['kind'] not in ('worldEventActive', 'worldEventInactive') else 'R004 authored events + existing weather service'} for c in r['conditions']], 'steps': step_rows, 'dialogue_entries': entries, 'outcomes': [{'source': d, 'owner': 'R011', 'durable_owner': 'R004' if d['directive']['kind'] in ['endRoutineForDay', 'activateWorldEvent', 'deactivateWorldEvent'] else None} for d in policy['outcomeDirectives']]})
    public = []
    for npc, p in packages.items():
        public.append({'npc_id': npc, 'runtime': p['runtime'], 'dialogue_nodes': [{'node_id': n['id'], 'choice_ids': [c['id'] for c in n.get('choices', [])], 'flag_ids': sorted(set(n.get('conditions', {}).get('requiredFlags', []) + n.get('conditions', {}).get('excludedFlags', []) + [f for c in n.get('choices', []) for f in c.get('addedFlags', [])])), 'fact_ids': n.get('revealedFactIds', []), 'outcome_tags': [c['outcomeTag'] for c in n.get('choices', []) if c.get('outcomeTag')], 'owner': 'R011', 'policy': 'compose with current social activation; preserve exact public text/IDs; deferred service/private nodes remain gated'} for n in p['dialogue']['nodes']]})
    return {'routines': result, 'public_dependencies': public, 'directive_kinds': [{'kind': k, 'owner': 'R011', 'exposure': 'real Helena choices' if k in ['resume', 'jumpToStep', 'endRoutineForDay'] else 'fixture-only; no selected production choice'} for k in ['resume', 'jumpToStep', 'endRoutineForDay', 'activateWorldEvent', 'deactivateWorldEvent']], 'actions': [{'action_id': 'river-fishing', 'npc_id': 'npc-01', 'review_asset': 'game/assets/models/npcs/npc-01-actions.glb', 'owner': 'R012', 'reward': 'none'}, {'action_id': 'archive-work', 'npc_id': 'npc-02', 'review_asset': 'game/assets/models/npcs/npc-02-actions.glb', 'owner': 'R012', 'reward': 'none'}], 'events': [{'id': 'heavy-rain', 'owner': 'R004', 'production': 'only thunderstorm derived; authored command separate/fixture-only'}, {'id': 'harbor-festival', 'owner': 'R004', 'production': 'allowlisted authored event, fixture-only for selected catalog'}]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    args = parser.parse_args(); source = args.source.resolve()
    out = ROOT/'tools/routine_migration/reference'
    if out.exists():
        raise SystemExit('Reference already exists; refuse silent refresh. Review drift explicitly.')
    source_head, target_head = git(source, 'rev-parse', 'HEAD'), git(ROOT, 'rev-parse', 'HEAD')
    catalog = read(source/'assets/data/routines/catalog.json')
    docs = [(r, read(source/r['asset'])) for r in catalog['routines']]
    selected = [(r, d) for r, d in docs if set(d['participants']) <= set(ROSTER)]
    if len(docs) != 39 or len(selected) != 25:
        raise SystemExit('Source count drift: expected 39 total and 25 selected.')
    routines = [d for r, d in selected]
    packages = {npc: {name: read(source/f'assets/data/npcs/{npc}/{name}.json') for name in ['runtime', 'dialogue', 'visuals']} for npc in ROSTER}
    maps = {m: read(source/f'assets/maps/{fn}.json') for m, fn in MAPS.items()}
    objects = read(source/'assets/data/world_objects/catalog.json')
    needed = {o['definitionId'] for m, data in maps.items() for o, _ in flat(data, 'objects') if o['type'] == 'prop' and (m != 'alderwake' or o['definitionId'] in ['mayor-vale-home', 'lantern-rest'])}
    definitions = {o['id']: o for o in objects['objects'] if o['id'] in needed}
    target_catalog = read(ROOT/'game/content/npcs/catalog.json')
    layout = read(ROOT/'game/content/maps/alderwake_layout.json')
    contacts = read(ROOT/'tools/npc_migration/reference/contact_registry.json')['contacts']
    mapping = mapping_data(routines, maps, layout, definitions, contacts)
    out.mkdir(parents=True)
    manifest = {'schema_version': 1, 'snapshot_id': 'routines-60c20eb2-r001', 'source_revision': source_head, 'target_revision': target_head, 'source_status': git(source, 'status', '--short'), 'target_baseline_status': '?? docs/day-clock-npc-routines/ (pre-existing user-authored planning files)', 'roster': ROSTER, 'selected_ids': [d['id'] for d in routines], 'source_catalog_count': 39, 'inputs': [], 'target_baseline': []}
    paths = [r['asset'] for r, d in selected]
    paths += [f'assets/data/npcs/{npc}/{name}.json' for npc in ROSTER for name in ['runtime', 'dialogue', 'visuals']]
    paths += [f'assets/maps/{fn}.json' for fn in MAPS.values()] + ['assets/maps/project.json', 'assets/data/world_events/catalog.json']
    paths += [str(p.relative_to(source)).replace('\\', '/') for p in (source/'lib/game/routines').glob('*.dart')]
    paths += ['lib/game/npc/'+n+'.dart' for n in ['npc_routine_director', 'npc_routine_executor', 'npc_component', 'world_map_npc_routine_anchor_source']]
    paths += ['lib/game/day_night/day_night_clock.dart', 'lib/game/state/runtime_game_state.dart', 'lib/game/state/runtime_game_controller.dart', 'lib/game/state/player_event_journal.dart', 'lib/game/navigation/navigation_route_follower.dart', 'lib/game/world/world_map_navigation_portal_graph.dart', 'lib/game/world/world_map_portal_component.dart', 'lib/game/world/cozy_adventure_world.dart', 'lib/game/presentation/world_portal_eligibility.dart', 'lib/world_map/world_map_flattening.dart', 'docs/npc-routine-schema.md', 'docs/npc-routines-production.md']
    paths += ['test/game/routines/'+n+'.dart' for n in ['routine_catalog_test', 'routine_resolver_test', 'routine_content_validator_test', 'production_routine_content_test']]
    paths += ['test/game/npc/'+n+'.dart' for n in ['npc_routine_director_test', 'npc_routine_executor_test', 'npc_routine_diagnostics_test']]
    paths += ['test/game/world/npc_routine_production_acceptance_test.dart']
    for relative in sorted(set(paths)):
        src = source/relative; dst = out/'source'/relative
        dst.parent.mkdir(parents=True, exist_ok=True); dst.write_bytes(src.read_bytes())
        manifest['inputs'].append({'source_path': relative, 'source_revision': source_head, 'sha256': sha(src), 'bytes': src.stat().st_size, 'snapshot_path': 'source/'+relative, 'purpose': 'selected public input / semantic authority; source tests read, NOT executed'})
    for relative in ['assets/data/routines/catalog.json', 'assets/data/world_objects/catalog.json', 'docs/returning-fair-integration-checklist.md']:
        manifest['inputs'].append({'source_path': relative, 'source_revision': source_head, 'sha256': sha(source/relative), 'bytes': (source/relative).stat().st_size, 'snapshot_path': None, 'purpose': 'authority hash; only selected derived subset retained'})
    block = (source/'docs/returning-fair-integration-checklist.md').read_text(encoding='utf-8').split('### INT-064')[1].split('\n### ')[0]
    (out/'INT-064.md').write_text(('### INT-064'+block).rstrip()+'\n', encoding='utf-8')
    write(out/'selected_catalog.json', {'schemaVersion': 1, 'routines': [r for r, d in selected]})
    write(out/'world_objects.json', {'schemaVersion': objects['schemaVersion'], 'objects': list(definitions.values()), 'policy': 'room and two exterior shell geometry only; no art/campaign import'})
    write(out/'exclusions.json', {'routine_ids': [d['id'] for r, d in docs if d['id'] not in manifest['selected_ids']], 'npc_ids': sorted({p for r, d in docs for p in d['participants']} - set(ROSTER)), 'excluded_features': ['Hall/fair/Orchard/starter-home migration', 'booking/paid room/sleep/morning campaign', 'shops/economy', 'extra cast/companions/relationships', 'private profiles/households', 'autosave', 'web/mobile', 'behavior editor'], 'map_snapshot_policy': 'full public map JSON is geographic/door authority; excluded NPC/anchor/portal records are NOT target runtime content'})
    write(out/'mappings.json', mapping)
    write(out/'coverage.json', coverage(routines, packages, target_catalog, maps))
    target_paths = ['game/content/maps/alderwake_layout.json', 'game/content/npcs/catalog.json', 'game/core/save_codec.gd', 'game/features/npcs/npc_registry.gd', 'game/features/npcs/npc_world_adapter.gd', 'game/world/alderwake_exterior.gd', 'game/world/prototype_location.gd', 'game/world/maris_counter.tscn', 'game/features/actors/companion.tscn', 'game/world/map_candidate/elevation_surfaces.gd', 'game/world/map_candidate/water_blockers.gd', 'game/world/map_candidate/town_footprints.gd', 'game/world/map_candidate/dock_surfaces.gd', 'game/world/map_candidate/terrain_preview.gd', 'tools/npc_migration/reference/manifest.json', 'tools/npc_migration/reference/contact_registry.json', 'game/features/environment/environment_clock.gd', 'game/features/environment/weather_condition_service.gd']
    for p in target_paths:
        manifest['target_baseline'].append({'path': p, 'sha256': sha(ROOT/p), 'policy': 'refuse unexplained drift; owning task must document intentional change'})
    # Hash all derived files as well. Semantic checks independently recompute them.
    manifest['derived'] = [{'path': p.relative_to(out).as_posix(), 'sha256': sha(p)} for p in sorted(out.glob('*')) if p.is_file()]
    write(out/'manifest.json', manifest)
    print(f'Pinned {len(selected)} routines, {len(mapping["anchors"])} anchors, {len(manifest["inputs"])} source inputs; source untouched.')


if __name__ == '__main__':
    main()
