"""Static R001 geometry audit from local pins. Never labels a route safe.

--check compares committed audit bytes; default refuses an existing audit.
Signed distances use exact pinned polygons/colliders. Straight legs diagnose
required detours only; no navmesh, swept capsule, LOS or native proof is implied.
"""
import argparse
import json
import math
from pathlib import Path

import pin_reference as pin

REF = pin.ROOT/'tools/routine_migration/reference'


def build():
    mapping = pin.read(REF/'mappings.json')
    routines = [pin.read(REF/'source'/r['asset']) for r in pin.read(REF/'selected_catalog.json')['routines']]
    maps = {m:pin.read(REF/f'source/assets/maps/{fn}.json') for m,fn in pin.MAPS.items()}
    definitions = {o['id']:o for o in pin.read(REF/'world_objects.json')['objects']}
    layout = pin.read(pin.ROOT/'game/content/maps/alderwake_layout.json')
    polygons = {'alderwake': [(p['collision']['id'],p['collision']['vertices_xz_m']) for p in layout['props'] if p['collision']] + [(c['id'],pin.polygon_rect(c['rect_xz_m'])) for c in layout['colliders']]}
    polygons.update({m:[(i,[pin.xz(p,m) for p in poly]) for i,poly in pin.source_polygons(data,definitions)] for m,data in maps.items() if m!='alderwake'})
    anchors = {(a['source_map_id'],a['anchor_id']):a for a in mapping['anchors']}
    legs = []
    for r in routines:
        for ps in r['participantSteps']:
            previous = None
            for st in ps['steps']:
                if st['kind'] != 'move':
                    continue
                target = st['target']; key = (target['mapId'],target['anchorId']); current = anchors[key]
                if previous:
                    source = previous['source_map_id']; dest = current['source_map_id']
                    row = {'routine_id':r['id'],'participant_id':ps['participantId'],'step_id':st['id'],'source':source+':'+previous['anchor_id'],'destination':dest+':'+current['anchor_id'],'validation':'NOT route proof; static candidate audit only','owner':'R009' if source==dest else 'R010'}
                    if source!=dest:
                        row['required_chain'] = next(c['portal_ids'] for c in mapping['directed_chains'] if c['source_map_id']==source and c['destination_map_id']==dest)
                    else:
                        a,b = previous['proposed_foot_xyz_m'], current['proposed_foot_xyz_m']; delta = [b[0]-a[0],b[2]-a[2]]
                        length = math.hypot(*delta); count=max(1,math.ceil(length/.1))
                        row['straight_distance_m'] = length
                        row['intersected_static_geometry'] = sorted({i for sample in range(count+1) for i,poly in polygons[source] if pin.distance([a[0]+delta[0]*sample/count,a[2]+delta[1]*sample/count],poly)<.4})
                        row['sample_spacing_max_m'] = .1
                        row['repair'] = 'actual navmesh detour required for any intersected static body; preserve furniture/terrain; prove continuous capsule route in owner task'
                    legs.append(row)
                previous = current
    rooms = []
    for m in ['mayor-vale-home','lantern-rest']:
        d=maps[m]; o=pin.ORIGINS[m]
        required=[a for a in mapping['anchors'] if a['source_map_id']==m]
        rooms.append({'map_id':m,'runtime_id':'prototype-'+m,'local_origin_units':o,'bounds_xz_m':[-o[0]/32,-o[1]/32,d['columns']-o[0]/32,d['rows']-o[1]/32], 'source_columns_rows':[d['columns'],d['rows']],'source_collider_count':len(d['colliders']),'required_anchor_count':len(required),'lighting':d['lighting'],'source_floor_policy':'preserve explicit cleared tiles/door threshold; map rectangle is NOT collision floor proof','proposed_player_arrival_xyz_m':[0,0,0],'proposed_ally_arrival_xyz_m':[0,0,-1.2],'arrival_status':'proposal only; validate both bodies/support/reachability/camera and rollback in room task','owner':'R007' if m=='mayor-vale-home' else 'R008'})
    doors = []
    for p in mapping['portals']:
        m = p['source_map_id']; pt = p['source_point_xz_m']
        nearest = sorted((pin.distance(pt,poly),i) for i,poly in polygons[m])[:3]
        doors.append({'portal_id':p['id'],'source_map_id':m,'rect_units':p['flattened_rect_units'],'portal_trigger_width_m':p['flattened_rect_units'][2]/32,'center_xz_m':pt,'nearest_static_geometry':[{'id':i,'center_clearance_m':round(d,6),'capsule_margin_m':round(d-.4,6)} for d,i in nearest],'destination_xz_m':p['destination_point_xz_m'],'status':'unrun dry support/nav/LOS/party approach; trigger width is NOT wall clearance','owners':p['owners']})
    conflicts = [
        {'id':'fixed-contact-bake','owners':['R009'],'measured':'seven 0.8m actor squares plus Maris 0.7m body square; grow(0.2) projected obstruction before nav erosion; these cover their own routine endpoints','proposal':'replace actor-only static bodies/outlines with transient occupancy; preserve 2.2x0.7m Maris bench, authored worktop and TemporaryCompanion station/party identity'},
        {'id':'home-hall-opposing-capsules','owners':['R007','R009'],'source_wall_inner_faces_units':[232,280],'clear_width_m':1.5,'required_two_npc_width_with_0_1m_gap':1.7,'deficit_m':.2,'proposal':'retain hall; single-file reservations and deterministic yield at room pockets. If physical tests require width repair, propose bounded target-local wall adaptation <=0.3m with before/after evidence; source stays read-only'},
        {'id':'home-rest-bed-corner','owners':['R007'],'center_clearance_m':0.450694,'npc_radius_m':.4,'physical_margin_m':.050694,'current_exterior_nav_obstruction_margin_m':.2,'proposal':'verify exact room nav/capsules/feet at both rest anchors. If conservative bake removes access, measure target furniture clearance repair (estimated deficit to 0.6m center clearance 0.149306m); no silent anchor shift or accepted route claim'},
        {'id':'single-destination-player-travel','owners':['R005'],'measured':'PrototypeLocation.destination_id/destination_spawn_id dispatch cannot distinguish several room exits','proposal':'explicit qualified per-portal source/destination/arrival IDs; separate NPC query API; preserve Tollworks IDs, party/camera/rollback'},
        {'id':'Della-map-ownership','owners':['R008','R013'],'before_xyz_m':[-9,0,3.5],'after_location':'prototype-lantern-rest','after_xyz_m':[-6,0,-12],'proposal':'retire exactly one exterior Della and move same identity to actual indoor host; no booking/sleep activation'},
        {'id':'INT-064-unknown-enum','owners':['R010'],'source_report':'Pending; vale-overnight-home/settle-for-night failed, hidden Edric town (704,528), absent home rest (80,392); exact enum unconfirmed','proposal':'capture initialMapId/currentMapId/origin/occupancy/qualified route diagnostics before repair; regress ordinary transition separately from seek/fresh-start/load at 22:00/00:00/06:00'},
        {'id':'source-executor-adaptations','owners':['R009','R010','R003'],'measured':'source unloaded same-map snap and cross-map goal snap; cancel does not release registration directly; director increments resolution each replan; update uses steps.length+1024 transitions','proposal':'root owns safe finite reconstruction/arrival registration and release on cancel/unload/rollback; retain loaded feet; suppress unchanged reassignment; no visible snap or elapsed reward replay'}
    ]
    return {'audit_kind':'static source/target geometry and capability audit; no gameplay launched','rooms':rooms,'doors':doors,'consecutive_move_legs':legs,'conflicts_and_repairs':conflicts,'envelopes':{'source_town_adult_radius_units':10,'source_radius_m':.3125,'target_npc_radius_m':.4,'target_npc_height_m':1.6,'target_hero_ally_radius_m':.35,'target_hero_ally_height_m':1.6,'Maris_current_radius_m':.35,'nav_agent_radius_m':.4,'nav_agent_height_m':1.6,'nav_cell_m':.2,'nav_climb_m':.1,'nav_slope_degrees':20},'unrun':['all route/capsule/swept physics/terrain support and LOS acceptance','two room construction/render/projections/zoom','ordinary door travel/full party','source Dart suites and native source INT-064 reproduction','moving-NPC performance and max-clock reconstruction'], 'owners':{'exterior_physics':'R006','home_physics':'R007','inn_physics':'R008','moving_capsules':'R009','night_regression':'R010','presentation':'R012','full_day':'R015','native_packages':'R016'}}


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    path=REF/'geometry_audit.json';data=build()
    if args.check:
        if pin.read(path)!=data: raise SystemExit('Geometry audit drift; review actual inputs/decisions, do not refresh silently.')
    else:
        if path.exists(): raise SystemExit('Geometry audit exists; refuse silent overwrite.')
        pin.write(path,data)
    print(f'PASS static audit: 2 rooms, 4 doors, {len(data["consecutive_move_legs"])} legs, 7 bounded repair records. Routes remain unaccepted.')


if __name__=='__main__':
    main()
