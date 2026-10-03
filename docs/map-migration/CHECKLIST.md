# Alderwake town river and forest migration checklist

Target: larger continuous 3D Alderwake with river, two working crossings,
Moonwood and current Maris recovery slice. Read [investigation](INVESTIGATION.md),
[current state](CURRENT_STATE.md) and parent [architecture](../ARCHITECTURE.md).
Use [agent prompt](AGENT_PROMPT.md) once per fresh session.

Status: M001–M002 verified complete; M003–M019 pending. `[ ]` pending; `[-]` in progress;
`[x]` verified complete. Each task depends on preceding task. One task per
session; unfinished task remains selected next time. Item may span sessions.
Repair only regressions needed for selected item; do not expand into next item.

Each completion needs changed files, exact checks/results and evidence in
CURRENT_STATE.md plus short completion record below. Proposed new paths below
are suggestions, not claims that files exist. Main P001–P014 checklist remains
separate. P014 now complete for the compact prototype; M019 must verify native
acceptance again against the resulting map build.

## [x] M001 Coordinate and compatibility contract

- Read actual map/catalog and target ownership; baseline focused application,
  travel, save and playable-slice checks. Preserve unrelated Git changes.
- Create `docs/map-migration/CONTRACT.md`: scale/origin/axes, height policy,
  coordinate types, source/runtime ID mapping, retained/inert/excluded content,
  active Tollworks gate and save compatibility. Record P014 gate as outstanding.
- Confirm proposed 1m/cell against actor footprints and crossing widths;
  define landmark tolerance and measurable route/visual/performance targets.
- Acceptance: contract includes converted spawn, Maris, bridge, ford, Moonwell,
  Tollworks and exit probes; baseline results or concrete regressions recorded.

## [x] M002 Pinned source snapshot and layout extraction

- Add target-local `tools/map_migration/` extraction command, pinned source
  inputs under `tools/map_migration/reference/`, and normalized layout under
  `game/content/maps/`. Include only inputs required for supported records.
- Read mixed layer cell sizes/defaults/paint kinds; flatten point/cell group
  transforms; resolve enabled catalog boxes/polygons and rotations. Retain
  elevation/slopes, portal destinations, zones, inert anchors and provenance.
- Acceptance: repeat extraction produces identical output; check mode detects
  stale inputs; malformed/unknown records fail or appear in explicit exclusion
  report. Validate rotated group fixture, polygon, fractional Moonwell and
  all 7 portal records. Runtime uses no source checkout path.

## [ ] M003 Runnable exterior terrain graybox

- Build isolated candidate location and focused launch harness using normalized
  layout, without selecting it as normal game's Alderwake yet.
- Create batched grass/path/sand surface preview, full bounds and safe start/
  return anchors. Resolve default paints and 0.5m/1m layer grids correctly.
- Acceptance: candidate launches; hero moves on full footprint; material regions
  align with source coordinates; boundary blocks escape. Existing game launches.
  Water and elevation are explicitly provisional until M004/M008.

## [ ] M004 River lake and basin blockers

- Add source-authored water blockers, including lake/basin where represented;
  use neutral water preview distinct from grass. Separate blocker geometry
  from render meshes and keep it out of walkable navigation surfaces.
- Acceptance: hero walking and dodge cannot enter water at four negative probes,
  seams or edges; no falling through base. Bounds/gate work; preserve authored
  crossing openings without claiming crossing completion yet.

## [ ] M005 Footbridge and sand ford traversal

- Add graybox deck/rails and ford at recorded positions, source-sized landings
  and safe clearance. No swimming/ferry implementation.
- Acceptance: physical hero crosses both routes in both directions through
  ordinary movement; nearby water stays blocked; no rail collision snags or
  accidental third route. Route probes from investigation converted by contract.

## [ ] M006 Town building and dock footprints

- Place western grouped structures and other retained town props as primitive
  wrappers; apply catalog foot-relative collision, not sprite rectangles.
- Keep streets, service approach, docks and portal landing pads usable;
  inactive destination records remain inert, with honest labels where shown.
- Acceptance: town circulation works; rotated/grouped footprint fixtures align;
  doors/Maris reserved pad remain accessible. No new interiors or NPC behaviors.

## [ ] M007 Forest population and landmark grayboxes

- Place source forest trees from pinned data with original IDs, species/size
  metadata, fractional positions and enabled trunk footprints. No reseeding.
- Add Moonwell, blocked east gate and retained trail/entrance markers. Keep
  inert routine/resource records separate from gameplay interactables.
- Acceptance: instance inventory matches retained source records; crossings,
  Moonwell approach, Tollworks approach and exit approach remain reachable;
  no duplicate props or open future exit. Label omitted content explicitly.

## [ ] M008 Physical elevation and ramps

- Build authored levels/slopes as terrain heights, ramps and cliff boundaries.
  Adapt grounding/floor snap and party safe placement only where necessary.
- Acceptance: hero ascends/descends actual slopes, cannot cut through cliffs,
  stays grounded; all arrival anchors support full party capsule/offsets.
  Crossings and Maris pad still work; document any justified height adaptation.

## [ ] M009 Navigation for complete exterior

- Replace/adapt tiny-room synchronous bake for candidate scale: use explicit
  walkable surfaces, correct radius/slope settings, and measured bake strategy.
  Keep WorldHost navigation synchronization and rollback behavior.
- Acceptance: navigable paths connect town, both crossings, Moonwell, Tollworks
  and blocked-exit approach in both directions; path samples avoid water/cliffs/
  trunks. Adjacent water negative probes stay outside usable navmesh. Measure
  loading/bake cost; scene swaps release old regions. Retain Tollworks routing.

## [ ] M010 Companion river and ramp recovery

- Exercise existing follow/repath/recovery over new map. Require traversable
  connectivity from ally to catch-up point; local floor/LOS alone insufficient.
- Acceptance: ally follows both crossings and ramps, routes around trunks,
  safely recovers from genuine stalls/incapacitation, and cannot teleport across
  blocked river/cliff or combat. Pause/dialogue/focus/travel still suspend AI.

## [ ] M011 Landscape appearance

- Replace terrain/water preview with coherent grass, paths, sand, banks and
  restrained river motion. Use source art as reference; record reused assets.
- Acceptance: town/forest/river shape readable from gameplay camera; no terrain
  cracks, water covering crossing deck, visual boundary contradicting collision,
  or missing default grass. Inspect static and moving views; gameplay unchanged.

## [ ] M012 Reusable tree art kit

- Build small reusable Blender tree kit with documented mapping for source
  species/size IDs. Save `.blend` under `art/source`, GLB under `game/assets`;
  batch repeated visuals where useful. Keep trunk gameplay wrappers unchanged.
- Acceptance: all retained tree IDs have deliberate visual mapping; height and
  canopy suit overhead camera; source positions/collisions preserved; no missing
  textures/import errors. Inspect dense forest and both crossing approaches.

## [ ] M013 Reusable town exterior art kit

- Replace primitive exterior buildings/docks with bounded modular Blender kit;
  prioritize house, shop/Chandlery, civic/inn fronts and dock modules. Variants
  reuse geometry; destination interiors remain inactive.
- Acceptance: retained structure footprints/IDs and door/service clearance stay
  fixed; town districts visibly readable. Verify GLB imports, textures and Maris
  approach. Do not turn roof/sprite bounds into new blockers.

## [ ] M014 Bridge Moonwell and gate appearance

- Replace three landmark grayboxes with small authored kit: timber footbridge,
  Moonwell, blocked east gate/sign. Add only local shoreline dressing needed
  for these views; detailed town-wide decoration remains later work.
- Acceptance: bridge rails/deck communicate walkability, Moonwell keeps exact
  mapped foot, exit reads closed. Compare reference/gameplay views; swapping
  art changes no collision, navigation, interactions or stable IDs.

## [ ] M015 Activate larger town and existing quest route

- Select candidate as `prototype-alderwake` while retaining stable production
  spawn IDs; place existing Maris counter/service at mapped Chandlery pad.
- Connect mapped forest Tollworks entrance to existing Tollworks arrival and
  return to safe exterior anchor. Retain current single-gate model unless this
  task demonstrates need for a narrow change; other source portals stay inactive.
- Replace stale north/south room hints. Reuse Maris, companion station, quest,
  guardian, vessel, trust and upgrade IDs; keep prototype labels accurate.
- Acceptance: normal fresh game accepts lead, walks forest approach with ally,
  enters Tollworks, defeats guardian, recovers vessel and returns for fitting;
  correct prompts, no duplicate interactions/party or missing service.

## [ ] M016 Camera ground aiming and canopy visibility

- Validate orthographic/perspective/zoom over full map; correct mouse-ground
  targeting on hills/ramps without allowing visual props to hijack ground aim.
- Add minimal canopy/roof occlusion treatment only where walkthrough shows
  hero, ally or interaction hidden; keep UI pointer/input arbitration intact.
- Acceptance: aim marker/facing/attacks match selected ground on slopes;
  hero/ally/Maris/gate readable; no camera jumps or canopy collision changes;
  pause, dialogue, journal, focus loss and zoom checks pass.

## [ ] M017 Save load retry and scene replacement compatibility

- Verify pre-migration schema-4 saves at both old town spawn IDs and Tollworks;
  loads use new safe arrival positions while retaining all existing progress.
- Test full-party placement, retry, failed spawn/navigation rollback, repeated
  round trips and new-process save/load. No schema bump for geography alone.
- Acceptance: quest/defeat/trust/upgrade/health preserved; no stale scene/nav
  objects, misplaced ally, duplicated reward or load into river. Invalid saves
  retain current rejection/backup semantics. Use isolated slots, never user save.

## [ ] M018 Measured map performance

- Profile town, dense forest, crossings and repeated travel on recorded machine.
  Capture frame times, draw calls, memory and navigation/load timings against
  M001 targets. Optimize measured issue within map rendering/navigation only.
- Acceptance: declared targets met with consistent measurement method; instance
  batching/culling does not lose visuals/collision; no growth across repeated
  scene swaps. If targets fail, task remains open with numbers and repair scope.

## [ ] M019 Full walkthrough and Windows build

- Run affected focused checks and rendered fresh-run journey through both
  crossings, Moonwell, closed exit, recovery quest and save/restart/revisit.
- Build Windows validation/release with existing presets; verify packaged map,
  assets and navigation work without source checkout or editor path.
- Acceptance: resulting release passes full ordinary-input walkthrough and
  restart/load; native P014 gate resolved against resulting build with evidence
  and accurate main checklist update. Debug bridge cannot substitute for native
  release acceptance. If held-input tooling unavailable, record human gate and
  leave incomplete. No publication required.

## Completion records

M001 contract and M002 extraction complete; candidate implementation starts at M003. Append one concise record per item:

```text
Mxxx — completed YYYY-MM-DD
Result:
Files:
Checks and exact exit results:
Evidence:
Decisions or retained limits:
Next eligible task:
```

M001 — completed 2026-10-03
Result: coordinate/height/ID/save/scope contract, 19 converted probes and declared route/visual/performance gates; 1m/cell fits nominal 3m crossings.
Files: docs/map-migration/CONTRACT.md, CHECKLIST.md, CURRENT_STATE.md; docs/evidence/M001/ validation, measurement script/JSON and logs.
Checks and exact exit results: isolated import exit0 with documented .NET/certificate errors; application_smoke, location_travel_checks, save_checks and playable_slice_checks PASS/exit0; source measurements and document acceptance exit0; git diff --check exit0. Initial sandbox save failure retained and repaired by isolated AppData.
Evidence: docs/evidence/M001/VALIDATION.md (exact commands, logs and acceptance mapping).
Decisions or retained limits: schema4/content1 and production IDs unchanged; six portals inert, existing Tollworks route only; physical routes/arrival pads/performance not yet verified; P014 native gate open. No runtime/source edits.
Next eligible task: M002 pinned source snapshot and layout extraction.

M002 — completed 2026-10-03
Result: target-local byte-exact snapshot, deterministic layout/extractor/check mode and explicit inert/exclusion/unused-registry report; all 468 props, 102 authored colliders, 7 portals, 472 height cells and 16 slopes retained.
Files: tools/map_migration/ command/tests/README/reference/report; game/content/maps/alderwake_layout.json; game/tests/map_layout_checks.gd plus UID; migration CONTRACT/CHECKLIST/CURRENT_STATE; docs/evidence/M002/.
Checks and exact exit results: extractor/generate-repeat/check exit0 with identical layout/report SHA256; 15 Python acceptance tests exit0 (negative CLI drift probes assert exit1); Godot import, map_layout_checks and application_smoke exit0; final review/diff check exit0. Import retains known SDK/certificate errors. Failed initial fixture serializer log retained and repaired.
Evidence: docs/evidence/M002/VALIDATION.md with commands, acceptance mapping, hashes and logs.
Decisions or retained limits: source ID namespaces preserved; default grass/explicit clears and point-versus-cell transforms retained; inert portal destinations never exterior-transformed; all routes still disabled. Snapshot matches M001 identity. Parent P014 native evidence complete for compact build, M019 must revalidate map build. No normal runtime/save/art edits or candidate/playability claim.
Next eligible task: M003 runnable exterior terrain graybox only.
