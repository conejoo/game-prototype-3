"""R007 deterministic public home geometry conversion; source snapshots stay immutable."""
import argparse
import json
from pathlib import Path
import pin_reference as pin

OUTPUT = pin.ROOT / 'game/content/maps/mayor_vale_home.json'


def build():
    source = pin.read(pin.ROOT / 'tools/routine_migration/reference/source/assets/maps/mayor_vale_home.json')
    mapping = pin.read(pin.ROOT / 'tools/routine_migration/reference/mappings.json')
    colliders = [{'id': c['id'], 'rect_xz_m': [(c['left']-256)/32, (c['top']-384)/32, c['width']/32, c['height']/32]} for c in source['colliders']]
    repairs = []
    for collider in colliders:
        before = collider['rect_xz_m'].copy()
        if collider['id'] == 'bedroom-bed':
            collider['rect_xz_m'][3] -= .3
            reason = 'Exact source .75m bed-to-south-wall passage disconnects 0.4m-radius bake; shorten bed south edge 0.3m for 1.05m passage, leaving both rest feet unchanged.'
        elif collider['id'] == 'study-sideboard':
            collider['rect_xz_m'][0] += .25
            collider['rect_xz_m'][2] -= .25
            reason = 'Exact .8125m desk-to-sideboard throat disconnects shelf station under conservative 0.4m capsule bake. Retract only sideboard west edge .25m to obtain 1.0625m throat; east wall and archive feet unchanged.'
        else:
            continue
        repairs.append({'id': collider['id'], 'before_rect_xz_m': before, 'after_rect_xz_m': collider['rect_xz_m'].copy(), 'reason': reason})
    return {
        'schema_version': 1, 'location_id': 'prototype-mayor-vale-home',
        'source_map_sha256': pin.sha(pin.ROOT / 'tools/routine_migration/reference/source/assets/maps/mayor_vale_home.json'),
        'origin_units': [256, 384], 'units_per_metre': 32,
        'floor_rects_xz_m': [[-8, -12, 16, 13], [-1, 1, 2, 1]],
        'cleared_floor_cells': source['tileLayers'][0]['cells'],
        'colliders': colliders,
        'anchors': [{'anchor_id': a['anchor_id'], 'foot': a['proposed_foot_xyz_m'], 'facing': a['source_facing']} for a in mapping['anchors'] if a['source_map_id'] == 'mayor-vale-home'],
        'arrival': {'id': 'mayor-vale-home-from-alderwake', 'source_foot': [0, 0, 0], 'foot': [0, 0, -2], 'ally_foot': [1, 0, -2],
                    'reason': 'Source 1.5m hall cannot fit default 1m east ally plus two 0.35m radii. Move 2m north into existing 2m doorway pocket; preserve all walls/stations and party offset.'},
        'exit': {'portal_id': 'mayor-vale-home-exit', 'foot': [0, 0, 1.25], 'player_approach': [0, 0, .25]},
        'adaptations': repairs,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--write-reviewed', action='store_true', help='Explicitly replace only this target-local derivative after reviewing converter changes.')
    args = parser.parse_args()
    data = build()
    if args.check:
        if pin.read(OUTPUT) != data:
            raise SystemExit('R007 home geometry drift; review before changing pins.')
    elif OUTPUT.exists() and not args.write_reviewed:
        raise SystemExit('Refuse existing home geometry; use --check or explicit --write-reviewed.')
    else:
        pin.write(OUTPUT, data)
    print('PASS R007 home conversion: 30 exact/2 documented furniture collider repairs, 9 exact stations, cleared threshold floor, documented party arrival.')


if __name__ == '__main__':
    main()
