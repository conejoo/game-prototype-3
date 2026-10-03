# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M002 verified complete.

## Selection and next action

- Active migration item: none. Selected M002 completed this session.
- Completed: M001 coordinate/compatibility contract; M002 pinned snapshot/extraction.
- Next eligible: M003 runnable exterior terrain graybox only.
- M003–M019 pending. No candidate scene or larger-map runtime implementation begun.
- Parent P001–P014 now complete for the compact prototype. Migration M001 memory
  predated P014 native completion. Existing evidence at
  [P014 native validation](../evidence/P014/native-holds/VALIDATION.md) and parent
  CURRENT_STATE/CHECKLIST verified and preserved. M019 must revalidate the resulting
  larger-map build with ordinary native inputs; older compact-build evidence does
  not complete that migration gate.

## Workspace, source and pinned identity

Target: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot project: `game/`. Workspace parent is not Git repository.
Inspected target HEAD: `2729d4a5063e34c1f79777760cb373c5bb18a045`; initial Git clean.
Prior P014 evidence, gameplay/art and parent implementation/state preserved.
No source edits/generators, dependency installs, subagents, commits, pushes or
publication. Personal gameplay-testing skill read for context; selected item is
pure data, so no interactive gameplay or new native input was needed.

Read-only source: `D:/development/game-prototype-2`.
Observed source HEAD unchanged: `f4630f9966d6637ef6579cd87623ea354758191c`.
M001 map/catalog hashes compared before copying; both match:

- Map `assets/maps/mvp_world.json`, SHA256
  `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
- Catalog `assets/data/world_objects/catalog.json`, SHA256
  `59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.

Pinned snapshot `alderwake-f4630f9-m002` now exists under
`tools/map_migration/reference/`. [Manifest](../../tools/map_migration/reference/manifest.json)
records original relative paths/byte-exact SHA256 for map, catalog, terrain
material registry, raw tile manifest and art catalog reference text. Only these
inputs copied; no images/interiors/campaign/cache/generator imported. Registry
files contain unused entries to retain original hash identity; exclusion report
lists unreferenced IDs, normalized runtime layout retains used definitions only.
Pinned snapshot is authority. Do not auto-refresh from source drift.

## M002 result and changed files

- `tools/map_migration/extract_layout.py`: standard-library offline extraction,
  explicit schema/record/reference validation, point/cell transforms, catalog
  collision resolution, default/clear semantics, height metadata, inert records,
  deterministic bytes and read-only `--check` with pinned/manifest/tool hashes.
- `tools/map_migration/test_extract_layout.py`: 15 acceptance cases using temporary
  snapshot copies; real source inventories and independent M001 probes plus
  hand-calculated rotated/height fixtures and malformed/stale negative probes.
- `tools/map_migration/reference/`: five raw inputs plus manifest.
- `tools/map_migration/extraction_report.json`: per-record inert/exclusion reasons,
  unused registry inventory, counts and provenance. `.gitignore` ignores Python
  bytecode; README documents commands/schema/disposition and remaining limits.
- `game/content/maps/alderwake_layout.json`: schema1 target-local candidate data.
- `game/tests/map_layout_checks.gd` plus Godot-generated UID: typed JSON-consumption
  check, with no runtime scene/ownership changes.
- `docs/evidence/M002/`: validation, exact commands/logs/hashes, retained initial
  test failure and final intended-file/state/link/whitespace review.
- Migration CHECKLIST/CONTRACT/this state: completion, snapshot and accurate P014
  handoff. No parent architecture update: production scope/ownership unchanged.
- Commit preparation: root `.gitattributes` preserves raw reference bytes and LF
  extractor/generated outputs despite Windows core.autocrlf. Staged Git blobs
  checked against working bytes; snapshot/output hashes remain unchanged.

## Verified layout and contract decisions

Retains 468 props (443 standalone/25 grouped), 455 enabled catalog footprints,
102 authored colliders, 31 groups, eight flattened art layers, four tile layers,
seven portals, 25 zones, three activities, 472 elevation overrides and 16 slopes.
91 inert objects: 78 routine anchors, six markers, four resources and three NPCs.
All tree IDs/species/size/feet retained; no reseeding or duplication.

32 units/metre, origin (704,576), source X/Y -> Godot X/Z; bounds rectangle
[-22,-18,147,80] is left/top/width/depth, equivalent to X[-22,125),Z[-18,62).
Terrain grids 0.5m, decor/art/gameplay 1m. Empty ground overrides preserve default
grass. Explicit null paint clears only its layer. Paint kinds/art references stay
semantic metadata; source sprites/connected-mask/lighting runtime is not ported.
Groups use gameplay-cell pivots, normalized quarter turns, distinct point/cell
rotation; catalog boxes/polygon vertices rotate around each foot.
Source namespaces allow `passenger-broken-piling-01` as prop and collider, and
`passenger-basin-south-wall-01` as group and collider. Preserve IDs; duplicates
inside a namespace fail. No design/scale/height adaptation made.

Moonwell exact foot [31.51317596435547,0.5,4.621034622192383] and eight vertices
retained. Chandlery box [-9.8125,7.75,5.28125,2.125] verified, no sprite blockers.
Gate art collision-disabled; authoritative future-exit-gate rectangle preserved.
Heights 0.25m/level, max1.75m; slope low/high neighbors/directions retained and
point heights interpolate. Physical ramps/cliffs remain M008 work.

All portals have runtime_enabled=false. Only source `tollworks-entrance-01`
carries deferred M015 mapping to existing alderwake-travel-gate ->
prototype-tollworks/tollworks-from-alderwake at [0,0,-2.5]. Original destination
units retained without exterior transform. Six other destinations remain inert.
Maris source placement maps to existing npc-03-counter later; no duplicate NPC.
Production location/spawn/party/quest/effect/reaction/upgrade IDs and
schema4/content1 unchanged. Candidate data never enters normal catalog/save.

## Verification and evidence

[Full M002 acceptance](../evidence/M002/VALIDATION.md) records exact commands,
per-criterion evidence and failed attempts. Commands from target root:

- Bundled Python `-B tools/map_migration/test_extract_layout.py`: 15 tests PASS,
  exit0, 28.907s; detached CLI negative drift probes assert exit1 and no repairs.
- `-B tools/map_migration/extract_layout.py`, repeated command, then `--check`:
  each exit0; identical layout/report SHA256 across actual reruns.
- Godot `--headless --editor --path game --import --quit`: exit0, existing missing
  .NET SDK10.0.9/certificate errors retained; not an error-free import claim.
- `--headless --path game --script res://tests/map_layout_checks.gd`: PASS/exit0;
  final regenerated layout rechecked once, exit0.
- `--headless --path game --script res://tests/application_smoke.gd`: PASS/exit0;
  normal root composition/InputMap/state/pause/resume intact. Both runtime logs
  retain restricted certificate-store error but no GDScript errors.
- `git diff --check` and final-review.ps1: exit0, intended scopes, data hashes,
  local links/state and new non-snapshot text whitespace reviewed.

Godot console/editor supplied paths verified; engine ed1daf0bf. Process-local
APPDATA=`<target>/builds/m002-user-data` and LOCALAPPDATA=`<target>/builds/m002-local-data`
isolate engine writes; no normal user save accessed. Python temporary fixtures
clean themselves. No source tests, rendered scene, physics/nav/performance or
packaged-export checks run because M002 implements data only.

Final layout SHA256:
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
Final report SHA256:
`66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9`.

Initial extractor failures (registry template then global ID uniqueness) repaired
without source edits. Initial Infinity-negative fixture failed in its serializer,
exit1; retained extractor-tests-initial.log. Corrected test serialization; strict
production writer still forbids nonfinite data, extractor rejects numeric field.
Final suite includes additional four-direction slope cases and passes.

## Unresolved limits and next-session preparation

No M002 blocker. Runtime layout stores appearance references; source images are
not packaged Godot assets. Source art/light/depth/shadow and inert gameplay have
explicit dispositions. JSON is data only: no candidate scene, physical water,
crossings, buildings/trees, ramps/navigation, companion connectivity, canopy
visibility, route timing or larger-map save/export acceptance yet. Normal room
remains runnable. All subsequent acceptance gates stay pending.

Select M003 only. Read full agent prompt, current contract/extractor README,
normalized layout/provenance and Git changes. Use pinned inputs; run --check
before building isolated candidate location/harness. Resolve layer defaults and
mixed grids into batched grass/path/sand preview over full footprint, safe
candidate start/return anchors and perimeter. Keep flat water/elevation explicitly
provisional, candidate outside normal catalog and normal save slot. Verify actual
rendered candidate movement/material registration/bounds plus existing startup.
Do not begin M004 in that session.
