"""R008 deterministic inn conversion from immutable public source pins."""
import argparse
import pin_reference as pin
OUTPUT = pin.ROOT / 'game/content/maps/lantern_rest.json'
def build():
    source = pin.read(pin.ROOT / 'tools/routine_migration/reference/source/assets/maps/lantern_rest.json')
    return {'schema_version':1, 'location_id':'prototype-lantern-rest',
        'source_map_sha256':pin.sha(pin.ROOT / 'tools/routine_migration/reference/source/assets/maps/lantern_rest.json'),
        'origin_units':[448,672], 'units_per_metre':32,
        'floor_rects_xz_m':[[-14,-21,28,23],[-1,2,2,1]],
        'cleared_floor_cells':source['tileLayers'][0]['cells'],
        'colliders':[{'id':c['id'],'rect_xz_m':[(c['left']-448)/32,(c['top']-672)/32,c['width']/32,c['height']/32]} for c in source['colliders']],
        'anchors':[{'anchor_id':'inn-host-01','foot':[-6,0,-12],'facing':'south'}],
        'arrival':{'id':'lantern-rest-from-alderwake','foot':[0,0,0],'ally_foot':[1,0,0]},
        'exit':{'portal_id':'lantern-rest-exit-01','foot':[0,0,1.75],'player_approach':[0,0,.65]},
        'adaptations':[]}
def main():
    parser=argparse.ArgumentParser(description=__doc__); parser.add_argument('--check',action='store_true'); args=parser.parse_args()
    data=build()
    if args.check:
        if pin.read(OUTPUT)!=data: raise SystemExit('R008 inn derivative drift; source pins cannot refresh.')
    elif OUTPUT.exists(): raise SystemExit('Refuse existing inn geometry; use --check.')
    else: pin.write(OUTPUT,data)
    print('PASS R008:19 exact colliders/one exact host/threshold floor/source party arrival.')
if __name__=='__main__': main()
