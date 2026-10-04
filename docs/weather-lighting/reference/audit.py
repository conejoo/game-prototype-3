"""Audit retained W001 rules and pinned light identities without local evidence.
Python transcription verifies fixed vectors; it does not execute Dart or Godot.
"""
import hashlib, json, math, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
REFERENCE = OUT

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path): return json.loads(path.read_text(encoding="utf-8-sig"))

def inventory():
 layout=read(ROOT/'game/content/maps/alderwake_layout.json')
 catalog=read(ROOT/'tools/map_migration/reference/catalog.json')
 world=read(ROOT/'tools/map_migration/reference/mvp_world.json')
 defs={d['id']:d for d in catalog['objects']}
 mappings={d['definition_id']:d for d in read(ROOT/'game/assets/environment/alderwake_town_mapping.json')['mappings'] if 'definition_id' in d}
 entries=[]
 for p in layout['props']:
  d=defs[p['definition_id']]
  for light in d.get('lightSources',[]):
   path=p['source']['path']; indices=[int(i) for i in re.findall(r'\[(\d+)\]',path)]
   if path.startswith('groups'):
    group=world['groups'][indices[0]]; original=group['props'][indices[1]]
    assert group.get('quarterTurns',0)==0
    foot=[original['x']+32*group['pivotX'],original['y']+32*group['pivotY']]
   else:
    original=world['objects'][indices[0]]; foot=[original['x'],original['y']]
   assert original['id']==p['id'] and original['definitionId']==d['id']
   assert foot==p['source_foot_units']
   assert original.get('lightSourceStates',{})==p['light_source_states']
   assert p['yaw_degrees']==0
   default=p['light_source_states'].get(light['id'],light['initiallyOn'])
   assert isinstance(default,bool)
   kind='windows' if light['glowProfile']=='window' else ('dock_lamp' if d['id']=='dock-lamp' else ('waylight' if d['id']=='safeguard-waylight' else 'woven_net'))
   owner='TownFootprints' if p['tree'] is None and (p['foot_xyz_m'][0]<25 or p['id'].startswith('passenger-')) else 'ForestPopulation'
   anchor={'dock_lamp':[-.1875,1.55,-.265625], 'waylight':[0,.65,-.125], 'woven_net':[0,1.0,-.45]}.get(kind)
   row=dict(location_id='prototype-alderwake', source_map_id='alderwake', prop_id=p['id'], source_id=light['id'], definition_id=d['id'], default_enabled=default,
    definition_default_enabled=light['initiallyOn'], switchable=light['switchable'], source_path=path,
    source_foot_units=foot, foot_xyz_m=p['foot_xyz_m'], yaw_degrees=p['yaw_degrees'],
    wrapper=f'Alderwake/{owner}/{p["id"]}', anchor_node='VisualRoot/ExteriorLightAnchors/'+light['id'],
    anchor_local_xyz_m=anchor, emitter_kind='emissive_window_panes' if kind=='windows' else 'emissive_mesh_and_pooled_unshadowed_omni',
    asset_gap_owner='W005', kind=kind, source_metadata=light,
    source_sprite_origin_foot_offset_units=[light['origin']['x']-d['sprite']['worldWidth']/2, light['origin']['y']-d['sprite']['worldHeight']],
    existing_visual='ImportedExterior vertex-colored glass; no emission surface' if kind=='windows' else 'graybox collider prism/foot marker; no light consumer')
   if kind=='windows':
    row['window_surface_recipe']=dict(local_polygon_xz_m=mappings[d['id']]['local_polygon_xz_m'], edge_fractions=[.23,.77],
     center_heights_m=[.75,1.55] if d['id'] in ['lantern-rest','mayor-vale-home'] else [.77],
     half_width_fraction='min(0.075, 0.28 / edge_length)', height_offsets_m=[-.22,.24],
     outward_offset_m=.0095, preserve_mullions_at_offset_m=.010,
     note='Separate four panes around existing wood crossbars; no whole-wall emission. One logical source drives all panes.')
   else:
    radius={'dock_lamp':1.0,'waylight':.625,'woven_net':0}[kind]
    row['intended_ground_radius_m']=radius
    row['initial_omni_range_m']=round(math.hypot(anchor[1],radius)+.05,4) if radius else 0
    row['range_status']='W005 initial physical design; render-calibrate and measure, not source Y conversion'
   entries.append(row)
 entries.sort(key=lambda e:(e['location_id'],e['prop_id'],e['source_id']))
 assert len(entries)==23 and sum(e['switchable'] for e in entries)==6
 assert sum(e['kind']=='windows' for e in entries)==14
 assert sum(e['kind']=='waylight' for e in entries)==2
 assert sum(e['kind']=='woven_net' for e in entries)==1
 assert len({(e['location_id'],e['prop_id'],e['source_id']) for e in entries})==23
 assert [e['prop_id'] for e in entries if e['kind']=='windows' and not e['default_enabled']]==['dock-row-home-02-building','dock-row-home-04-building','mill-road-home-01-building','moonwood-edge-home-02-building']
 selected={e['definition_id'] for e in entries}
 return dict(snapshot_id='alderwake-f4630f9-m002',count=len(entries),entries=entries,
  absent_light_definitions=sorted(d['id'] for d in defs.values() if d.get('lightSources') and d['id'] not in selected),
  dark_structure_instances=sorted(p['id'] for p in layout['props'] if defs[p['definition_id']]['kind']=='structure' and not defs[p['definition_id']].get('lightSources')))

MASK=0xffffffff
# Literal transcription of the pinned Dart hash; arbitrary-precision arithmetic.
def mix(seed,index,salt):
 v=(seed^((index+1)*0x9e3779b9)^salt)&MASK
 v=(v^(v>>16))&MASK; v=(v*0x7feb352d)&MASK
 v=(v^(v>>15))&MASK; v=(v*0x846ca68b)&MASK
 return (v^(v>>16))&MASK
def sample(seed,minutes):
 index=0; start=0; previous=current='sunny'; end=240+mix(seed,0,0x5f356495)%241
 while minutes>=end:
  previous=current; index+=1; start=end; roll=mix(seed,index,0x9e3779b9)%100
  current={'sunny':'cloudy','cloudy':'sunny' if roll<55 else 'rainy','rainy':'cloudy' if roll<65 else 'thunderstorm','thunderstorm':'rainy' if roll<75 else 'cloudy'}[previous]
  end+=240+mix(seed,index,0x5f356495)%241
 return dict(condition=current,previous_condition=previous,period_index=index,period_start_minutes=start,period_end_minutes=end,transition_progress=1.0 if index==0 else min(1.,max(0.,(minutes-start)/15)))
def vectors():
 cases=[]
 for seed in [0,1,77,123456,0x6c8e9cf5,0xdecafbad,MASK]:
  end=sample(seed,0)['period_end_minutes']
  for minutes in [0,end-.0001,end,end+7.5,end+15,1440*37+.73125*1440,3650*1440+.999*1440]:
   cases.append(dict(seed=seed,absolute_minutes=minutes,day_index=int(minutes//1440),day_cycle_progress=(minutes%1440)/1440,expected=sample(seed,minutes)))
 products=[]
 for a in [0,1,0x7fffffff,0x80000000,0xffffffff]:
  for b in [0x9e3779b9,0x7feb352d,0x846ca68b]:
   # Safe signed-int64 port: low-16 limbs before any overflowing multiply.
   limb=((a&65535)*b+(((a>>16)*b&65535)<<16))&MASK
   assert limb==(a*b)&MASK
   products.append(dict(a=a,b=b,low32=limb))
 return dict(provenance='Python literal transcription of pinned Dart, not a claim Flutter/Dart tests ran. Pinned source is authority.',forecast=cases,low32_multiply=products,
  clock=[dict(progress=p,minute_of_day=(600+p*1440)%1440) for p in [0,1/1440,.25,.5,7/12,.75,.999]],
  advance=[dict(day_index=d,progress=p,delta_seconds=dt,expected_day_index=d+math.floor(p+dt/600),expected_progress=(p+dt/600)%1) for d,p,dt in [(0,0,600),(0,.95,60),(5,.37,1800),(2,.999,601)]])


def audit():
 manifest = read(OUT / 'source-manifest.json')
 retained = [item for item in manifest['files'] if 'retained_path' in item]
 assert len(retained) == 4
 for item in retained:
  path = OUT / item['retained_path']
  assert path.stat().st_size == item['bytes'] and sha(path) == item['sha256'], item['path']
 for item in read(ROOT / 'tools/map_migration/reference/manifest.json')['inputs']:
  assert sha(ROOT / 'tools/map_migration/reference' / item['file']) == item['sha256'], item['file']
 actual = inventory()
 drop = {'source_metadata','source_sprite_origin_foot_offset_units','existing_visual','range_status','definition_default_enabled','source_foot_units'}
 for entry in actual['entries']:
  for key in drop: entry.pop(key, None)
 assert actual == read(OUT / 'light-inventory.json'), 'Light identity/default/anchor mismatch'
 assert vectors() == read(OUT / 'rule-vectors.json'), 'Source vector mismatch'
 print('W001 reference audit PASS: 4 exact sources, 23 lights, 49 forecasts, clock/advance/uint32 vectors')

if __name__ == '__main__': audit()
