# Alderwake pinned layout extraction

M002 tool, Python standard library only. Run from any working directory. This
command reads **only** `reference/`; it never opens, regenerates or updates the
Flutter checkout. No dependency installation, Dart execution or asset copying
happens during extraction. Production Godot scenes/catalog/save ownership remain
unchanged. M003 builds the isolated candidate from this data.

```powershell
$pythonExe = 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $pythonExe -B tools/map_migration/extract_layout.py
& $pythonExe -B tools/map_migration/extract_layout.py --check
& $pythonExe -B tools/map_migration/test_extract_layout.py
```

Use another installed Python 3.10+ if the bundled path changes. `--check` is
read-only: exit 1 on missing/stale layout/report, altered pinned input or invalid
data. It compares bytes, including manifest/extractor hashes. Normal generation
also refuses changed pinned hashes. Never use regeneration to bless source drift:
reconcile the contract and snapshot deliberately, then regenerate and verify.
`--reference`, `--output` and `--report` accept explicit paths for detached tests;
they do not fetch source content.

## Snapshot and registry references

`reference/manifest.json` identifies `alderwake-f4630f9-m002`, source commit and
the original relative paths/SHA-256 for five byte-exact files. Map/catalog hashes
match M001. Map, object catalog, terrain material registry, raw tile manifest and
art registry text provide all records/definitions needed to resolve this exterior.
Catalog registries retain unused entries so the original hashes remain auditable;
the report lists unused IDs and runtime output emits referenced entries only.
No source images, other maps, campaigns, navigation caches or generator scripts
are copied. Art registry Dart is pinned **reference text**, parsed for known
factory entries; it is never a runtime dependency. Its factory templates are
checked. Unsupported schema changes require a deliberate extractor update.

## Layout schema 1

Output: `game/content/maps/alderwake_layout.json`. Audit/disposition output:
`tools/map_migration/extraction_report.json`. Neither contains an absolute source
checkout path. Relative source paths and original IDs are provenance, not file
loads. Registry image paths describe source art; images are not available in the
Godot project yet. M011–M014 own appearance and deliberate art mappings.

- Coordinates use CONTRACT.md: 32 units/metre, origin (704,576), source X/Y to
  Godot X/Z, 0.25m/level. `bounds_xz_m` and every `rect_xz_m` are
  `[left_x, top_z, width, depth]`, **not** min/max corners. Feet are `[X,Y,Z]`.
- Tile layers retain source order, visibility and name. `cell` remains integer
  layer-grid coordinates; its world top-left is `origin_xz_m + cell*cell_size_m`.
  Grids are 0.5m or 1m. Absence uses `default_paint`; explicit `paint:null` clears
  only that layer. Ground has default grass with no overrides. Raw, center and
  connected material kinds stay distinct; no source connected-mask renderer is
  ported. Referenced material metadata retains animation/bank/mask asset strings.
- Art cells use 1m grid, map origin (-22,-18) and flattened cell top-lefts. IDs
  are `group-id--layer-id`. Quarter-turn cell transforms differ from point
  transforms. `default_grid_transform` retains a grouped default's source basis;
  tile images themselves are not rotated by source flattening. A default resolves
  absent cells, while a null tile explicitly clears. Current map has no defaults
  on art layers; fixtures cover transforms rather than inventing new art behavior.
- Props retain original IDs/definition IDs, exact flattened source feet, converted
  physical feet, normalized quarter turns/Godot yaw and source path/group ID.
  Optional collisionEnabled defaults true; light states default empty and source
  render-depth offset defaults zero. Light/depth values are appearance metadata,
  never physical position offsets. `tree` records species and small/standard/large
  size from the catalog identity without reseeding.
- Prop `collision` is null when disabled/none, otherwise an independent enabled
  catalog box/polygon with world X/Z vertices. Boxes include rotated bounds;
  polygons retain vertices, not bounding-box replacements. Box points rotate
  around the foot. Authored `colliders` are separate rectangles; no sprite bounds
  become blockers. Source ID namespaces are preserved: a prop/group can share an
  ID with an authored collider. Duplicates within one namespace fail.
- Elevation keeps default level 0, all 472 overrides and 16 slopes. Slope heights
  use flat low/high neighbors and preserve direction. Point feet on slope cells
  interpolate height. This is **data**, not implemented ramps or collision.
- Seven portals retain flattened rectangles and unchanged destination-map units.
  All `runtime_enabled` flags remain false. Only Tollworks has a future M015
  mapping to existing interaction/location/arrival IDs. Six others stay inert.
  No exterior origin/group transform applies to destination coordinates.
- Zones and rectangle/polygon activity areas retain geometry. 91 other object
  records retain metadata/physical feet: 78 anchors, six markers, four resources,
  three NPC placements. Maris maps to existing `npc-03-counter` later. No NPCs,
  schedules, resource economy or activity rules are instantiated.

## Failure and disposition rules

Malformed types/numbers/rectangles/polygons, unknown root/record fields, unsupported
grids/schemas/paint kinds/materials/tiles/props, duplicate records/cells and invalid
slopes fail with a record path and exit 1. Unknown gameplay is never substituted.
Source renderer-only lighting, sprite/shadow/light references, inert placements,
activities and inactive routes are retained but explicitly listed in the report
with identity/path/reason. Unreferenced catalog entries are separately inventoried.
Supported collision/default behavior is tested against detached source records,
hand-calculated rotated fixtures and independent M001 measurements.

Tests use temporary snapshot copies and outputs; no normal save is accessed.
Godot's focused `res://tests/map_layout_checks.gd` reads the runtime JSON through
`res://`, verifying data consumption without Flutter or the source checkout.
No rendered terrain, physical crossing, navigation, packaged export or larger-map
playability is claimed by M002.
