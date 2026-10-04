# Alderwake town river and forest migration checklist

Target: larger continuous 3D Alderwake with river, two working crossings,
Moonwood and current Maris recovery slice. Read [investigation](INVESTIGATION.md),
[current state](CURRENT_STATE.md) and parent [architecture](../ARCHITECTURE.md).
Use [agent prompt](AGENT_PROMPT.md) once per fresh session.

Status: M001–M017 verified complete; M018–M019 pending. `[ ]` pending; `[-]` in progress;
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

## [x] M003 Runnable exterior terrain graybox

- Build isolated candidate location and focused launch harness using normalized
  layout, without selecting it as normal game's Alderwake yet.
- Create batched grass/path/sand surface preview, full bounds and safe start/
  return anchors. Resolve default paints and 0.5m/1m layer grids correctly.
- Acceptance: candidate launches; hero moves on full footprint; material regions
  align with source coordinates; boundary blocks escape. Existing game launches.
  Water and elevation are explicitly provisional until M004/M008.

## [x] M004 River lake and basin blockers

- Add source-authored water blockers, including lake/basin where represented;
  use neutral water preview distinct from grass. Separate blocker geometry
  from render meshes and keep it out of walkable navigation surfaces.
- Acceptance: hero walking and dodge cannot enter water at four negative probes,
  seams or edges; no falling through base. Bounds/gate work; preserve authored
  crossing openings without claiming crossing completion yet.

## [x] M005 Footbridge and sand ford traversal

- Add graybox deck/rails and ford at recorded positions, source-sized landings
  and safe clearance. No swimming/ferry implementation.
- Acceptance: physical hero crosses both routes in both directions through
  ordinary movement; nearby water stays blocked; no rail collision snags or
  accidental third route. Route probes from investigation converted by contract.

## [x] M006 Town building and dock footprints

- Place western grouped structures and other retained town props as primitive
  wrappers; apply catalog foot-relative collision, not sprite rectangles.
- Keep streets, service approach, docks and portal landing pads usable;
  inactive destination records remain inert, with honest labels where shown.
- Acceptance: town circulation works; rotated/grouped footprint fixtures align;
  doors/Maris reserved pad remain accessible. No new interiors or NPC behaviors.

## [x] M007 Forest population and landmark grayboxes

- Place source forest trees from pinned data with original IDs, species/size
  metadata, fractional positions and enabled trunk footprints. No reseeding.
- Add Moonwell, blocked east gate and retained trail/entrance markers. Keep
  inert routine/resource records separate from gameplay interactables.
- Acceptance: instance inventory matches retained source records; crossings,
  Moonwell approach, Tollworks approach and exit approach remain reachable;
  no duplicate props or open future exit. Label omitted content explicitly.

## [x] M008 Physical elevation and ramps

- Build authored levels/slopes as terrain heights, ramps and cliff boundaries.
  Adapt grounding/floor snap and party safe placement only where necessary.
- Acceptance: hero ascends/descends actual slopes, cannot cut through cliffs,
  stays grounded; all arrival anchors support full party capsule/offsets.
  Crossings and Maris pad still work; document any justified height adaptation.

## [x] M009 Navigation for complete exterior

- Replace/adapt tiny-room synchronous bake for candidate scale: use explicit
  walkable surfaces, correct radius/slope settings, and measured bake strategy.
  Keep WorldHost navigation synchronization and rollback behavior.
- Acceptance: navigable paths connect town, both crossings, Moonwell, Tollworks
  and blocked-exit approach in both directions; path samples avoid water/cliffs/
  trunks. Adjacent water negative probes stay outside usable navmesh. Measure
  loading/bake cost; scene swaps release old regions. Retain Tollworks routing.

## [x] M010 Companion river and ramp recovery

- Exercise existing follow/repath/recovery over new map. Require traversable
  connectivity from ally to catch-up point; local floor/LOS alone insufficient.
- Acceptance: ally follows both crossings and ramps, routes around trunks,
  safely recovers from genuine stalls/incapacitation, and cannot teleport across
  blocked river/cliff or combat. Pause/dialogue/focus/travel still suspend AI.

## [x] M011 Landscape appearance

- Replace terrain/water preview with coherent grass, paths, sand, banks and
  restrained river motion. Use source art as reference; record reused assets.
- Acceptance: town/forest/river shape readable from gameplay camera; no terrain
  cracks, water covering crossing deck, visual boundary contradicting collision,
  or missing default grass. Inspect static and moving views; gameplay unchanged.

## [x] M012 Reusable tree art kit

- Build small reusable Blender tree kit with documented mapping for source
  species/size IDs. Save `.blend` under `art/source`, GLB under `game/assets`;
  batch repeated visuals where useful. Keep trunk gameplay wrappers unchanged.
- Acceptance: all retained tree IDs have deliberate visual mapping; height and
  canopy suit overhead camera; source positions/collisions preserved; no missing
  textures/import errors. Inspect dense forest and both crossing approaches.

## [x] M013 Reusable town exterior art kit

- Replace primitive exterior buildings/docks with bounded modular Blender kit;
  prioritize house, shop/Chandlery, civic/inn fronts and dock modules. Variants
  reuse geometry; destination interiors remain inactive.
- Acceptance: retained structure footprints/IDs and door/service clearance stay
  fixed; town districts visibly readable. Verify GLB imports, textures and Maris
  approach. Do not turn roof/sprite bounds into new blockers.

## [x] M014 Bridge Moonwell and gate appearance

- Replace three landmark grayboxes with small authored kit: timber footbridge,
  Moonwell, blocked east gate/sign. Add only local shoreline dressing needed
  for these views; detailed town-wide decoration remains later work.
- Acceptance: bridge rails/deck communicate walkability, Moonwell keeps exact
  mapped foot, exit reads closed. Compare reference/gameplay views; swapping
  art changes no collision, navigation, interactions or stable IDs.

## [x] M015 Activate larger town and existing quest route

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

## [x] M016 Camera ground aiming and canopy visibility

- Validate orthographic/perspective/zoom over full map; correct mouse-ground
  targeting on hills/ramps without allowing visual props to hijack ground aim.
- Add minimal canopy/roof occlusion treatment only where walkthrough shows
  hero, ally or interaction hidden; keep UI pointer/input arbitration intact.
- Acceptance: aim marker/facing/attacks match selected ground on slopes;
  hero/ally/Maris/gate readable; no camera jumps or canopy collision changes;
  pause, dialogue, journal, focus loss and zoom checks pass.

## [x] M017 Save load retry and scene replacement compatibility

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

M001–M017 complete. Append one concise record per item:

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

M003 — completed 2026-10-03
Result: isolated runnable 147×80m flat terrain candidate, seven batched material/grid-marker meshes, separate floor/perimeter and safe two-party start/return pads; normal compact game unchanged.
Files: game/world/map_candidate/; game/tests/map_candidate.tscn, map_candidate_root.gd, map_candidate_checks.gd and UIDs, fixtures/map_candidate_location.tres; tools/map_migration/CANDIDATE.md; migration CHECKLIST/CURRENT_STATE; docs/evidence/M003/.
Checks and exact exit results: pinned extractor --check exit0; import exit0 with known SDK/certificate diagnostics; map_candidate_checks PASS/exit0; application_smoke PASS/exit0. Rendered bridge commands exit0 and inspected 960×640 captures; ordinary movement from start through forest material regions to return pad/east wall, dodge blocked. Final return-start and normal-startup processes quit through F10, exit0. git diff --check exit0.
Evidence: docs/evidence/M003/VALIDATION.md, focused logs, exact command JSONs/raw bridge responses, observations and inspected PNGs.
Decisions or retained limits: source snapshot unchanged; candidate-only catalog and named test save, no normal user save; flat water walkable until M004, heights M008, provisional flat nav M009. Raw decorations are explicit source-grid dots, not sprites; no portals, quests, prop/art blockers or production activation. Parent P014 compact-build completion preserved; M019 still owes map-build gate. Initial readiness race and overly strict 1mm contact assertion retained/repaired; perimeter visuals lowered for party readability without changing collider.
Next eligible task: M004 river lake and basin blockers only.

M004 — completed 2026-10-03
Result: all90 authored river/lake/south-shore/basin water blockers plus closed-exit collider, independent blue union preview, intact base floor/bounds/party pads and dry-only provisional nav; both crossing openings preserved.
Files: game/world/map_candidate/water_blockers.gd plus UID, terrain_preview.gd; game/tests/map_water_checks.gd plus UID, map_candidate_checks.gd, map_candidate_root.gd; tools/map_migration/CANDIDATE.md; migration CHECKLIST/CURRENT_STATE; docs/evidence/M004/.
Checks and exact exit results: pinned extractor --check PASS0; import exit0 with known SDK/certificate diagnostics; final map_water_checks/map_candidate_checks/application_smoke PASS0;90 water/91 total bodies,8,766 occupied-cell probes,4,195 capsule edge sweeps,22 hero walk/dodge cases,11,760 base-floor probes; synchronized water/nav clearance min0.430115m. Rendered ordinary WASD/Space on four crossing banks and final closed gate, inspected pause/contact captures; two normal F10 quits exit0. git diff --check/final review exit0.
Evidence: docs/evidence/M004/VALIDATION.md, exact command JSONs/raw responses, inspected PNGs, observations/hash records and accepted/failed logs.
Decisions or retained limits: source snapshot/schema4/content1/production IDs unchanged; candidate only, no normal save. Water paint inventoried but diagnostic mesh follows authored occupied union. Tightened provisional Recast contour error0.1 to prevent bank-corner cuts; final nav/height/companion recovery remain M009/M008/M010. Gate collision needed for M004; M007/M014 still own wrapper/art. Wrong winding/fixture rays/base-floor query/nav corner and rendered steering failures retained and repaired. No crossing construction or completion, production activation, export or native map-build gate claimed; parent P014 compact completion preserved.
Next eligible task: M005 footbridge and sand ford traversal only.

M005 — completed 2026-10-03
Result: source-registered6×3m bridge with flush deck/2×3m landings/thin edge rails (2.8m clear),7×3m ford with1×3m landings; ordinary rendered hero walking both directions on both routes; adjacent water blocked,no rail-end snags or new water route.
Files: game/world/map_candidate/crossings.gd plus UID,terrain_preview.gd; game/tests/map_crossing_checks.gd plus UID,map_water_checks.gd,map_candidate_root.gd; tools/map_migration/CANDIDATE.md; migration CHECKLIST/CURRENT_STATE; docs/evidence/M005/.
Checks and exact exit results: extractor --check PASS0; import exit0 with known SDK/certificate diagnostics; final map_crossing_checks/map_water_checks/map_candidate_checks/application_smoke PASS0;4,032 clearance/floor probes,104 bidirectional walk/dodge runs,4 rail-slide runs,30,728 displacement samples;91 water/gate bodies,8,766 cells,4,157 edge sweeps,22 blocker cases,11,760 floor probes; nav clearance min0.430115m. Rendered commands exit0,inspected960×640 moving/paused captures,normal F10 process exit0; final review/diff check exit0.
Evidence: docs/evidence/M005/VALIDATION.md,exact command JSONs/raw responses,inspected PNGs,observation/hash records and logs.
Decisions or retained limits: snapshot/schema4/content1/production IDs unchanged; candidate only,no saves. Edge rails preserve source movement corridor; ford local name is not source ID/western old-ford. VisualRoot separate from physics; provisional dry nav clips rails. Heights/art/nav/recovery/activation/native map-build gate remain later; parent P014 compact completion preserved. No source refresh,Blender,commit,export or next item started.
Next eligible task: M006 town building and dock footprints only.

M006 — completed 2026-10-03
Result: 56 retained town/passenger props with exact catalog polygons/feet/yaw, 11 authored colliders, three walkable docks and quays, six inactive door pads and clear Maris/fitting reservations. Normal compact game unchanged.
Files: town_footprints.gd, dock_surfaces.gd and UIDs; terrain_preview.gd/water_blockers.gd; map_town_checks.gd and UID; focused candidate/water/crossing checks and candidate root; CONTRACT/CHECKLIST/CURRENT_STATE/CANDIDATE; docs/evidence/M006/.
Checks and exact exit results: extractor --check/report/import exit0; accepted town/water/crossing/candidate/application smoke checks PASS0 with no script errors; 37,325 polygon queries, 74 bidirectional physical town routes, 18,036 path samples at<=0.1m; 8,598 effective water-cell probes, 4,124 edge sweeps, 22 water/gate walk/dodge cases; 104 crossing runs/4 rail-slide runs/30,728 displacement samples; 11,760 base-floor rays. Rendered normal WASD/E town and docks both directions, Space blocked by nearby water; inspected 960x640 captures and confirmed pause batches; normal F10 process exit0. Final evidence review/git diff --check exit0.
Evidence: docs/evidence/M006/VALIDATION.md, dock-reconciliation/inventory/hash JSON, accepted and failed logs, exact bridge commands/responses and inspected PNGs.
Decisions or retained limits: user approved named dock cutouts after all three source dock art bounds measured fully inside authored water. Seven target-only floor/landing rectangles remove exactly42m2/168 cells from south-water-01 through07; source records/8,766 authored cells/snapshot unchanged. Town and southern-water nav-only0.2m margin repairs measured Recast corner cuts; physics polygons exact. Heights/nav/recovery/final art/activation/native map-release gates remain later. Shared prop/collider node namespace, synthetic movement setup, typed empty array, nav corners/dock neck and a rejected33-step bridge request repaired; failed/unaccepted evidence retained. No source write/refresh, normal save, Blender, commit, export or next item started.
Next eligible task: M007 forest population and landmark grayboxes only.

M007 — completed 2026-10-03
Result: all395 pinned trees/nine species/three sizes plus17 deferred props, fractional Moonwell, six inert markers and Tollworks entrance;468 unique prop wrappers/455 catalog footprints/102 authored collider IDs, sole closed gate.
Files: forest_population.gd/prop_grayboxes.gd and UIDs; terrain/town/water candidate scripts; candidate root; map_forest_checks.gd/UID and focused existing checks; CANDIDATE/CONTRACT/CHECKLIST/CURRENT_STATE; docs/evidence/M007/.
Checks and exact exit results: pinned extractor/report/final review PASS0; import exit0 with known SDK/certificate diagnostics; forest/town/water/crossing/candidate/application checks PASS0;64,178 forest polygon probes,16,728 path samples,16 bidirectional physical approach routes;74 town routes;94 clear crossing walking/dodge lanes plus4 rail slides; rendered Moonwell round trip,ford/bridge both directions,Tollworks approach,E inert,closed gate walk/dodge; two normal F10 quits0;git diff --check0.
Evidence: docs/evidence/M007/VALIDATION.md,inventory/hashes/physics report,accepted and failed logs,raw ordinary-input commands/responses and inspected PNGs.
Decisions or retained limits: flat Y preview/source heights retained; tree prisms diagnostic only; source supply cache retained on northwest bridge landing;0.2m nav-only margin includes forest/rails; checks wait for asynchronous region readiness; routines/resources/NPCs/zones/activities data only; schema4/content1/production/save/source snapshot unchanged. Parent P014 compact completion preserved; M019 owes map release.
Next eligible task: M008 physical elevation and ramps only.

M008 — completed 2026-10-03
Result: 472 physical height cells, 16 directional ramps, 238 bidirectional cliff barriers and matching batched terrain; physical prop feet restored, candidate-only ray/capsule-validated grounding. Heights remain 0.25m per level.
Files: elevation_surfaces.gd/map_elevation_checks.gd and UIDs; actor optional floor callback; candidate root/terrain/props/crossings/water and focused existing checks; CANDIDATE/CONTRACT/CHECKLIST/CURRENT_STATE; docs/evidence/M008/.
Checks and exact exit results: final eight focused elevation/candidate/crossing/town/water/application/movement-camera/travel checks PASS/exit0; extractor/report/final-review/diff-check exit0; import exit0 with known SDK/certificate diagnostics. 4,392 height rays,11,760 full-map floor rays,64 ramp runs,476 cliff casts,2,646 cliff walking/dodge/diagonal runs,67,945 motion samples,max grounding error0.019152m;94 crossing lanes/four rail slides;74 town routes. Final rendered fresh town->ramps->Moonwell,cliff walk/dodge,descent->town with24 retained captures,normal F10 exit0.
Evidence: docs/evidence/M008/VALIDATION.md,elevation/forest reports,known-nav-limit/hashes/rendered-index,accepted and failed logs,ordinary input commands/raw responses/PNG captures.
Decisions or retained limits: solid default base plus raised/ramp collision; exact prop X/Z/flags/IDs preserved,vertical graybox bounds cover terrain. Candidate snap0.04m plus optional actual-floor callback prevents measured wall-snap/downhill artifacts; normal callback empty. Moonwell evidence approach moves toZ5.25 within0.629m of unchanged foot. Strict forest nav check remains FAILED/exit1 on12 radius0.4m ramp-corner probes while16 hero routes walk; M009 must repair without weakening gates. Schema4/content1,snapshot,normal save/production selection and parent P014 compact completion unchanged. No M009 implementation/performance/export/native map gate claimed.
Next eligible task: M009 navigation for complete exterior only, beginning with retained Moonwell contour/erosion failure.

M009 — completed 2026-10-03
Result: complete physical exterior navigation with exact cliff/gate/perimeter centre clipping, strict whole-mesh clearance and query-ready transactional arrivals; normal compact game remains selected.
Files: terrain_preview.gd/elevation_surfaces.gd; WorldHost; candidate root/forest check; map_navigation_checks.gd and failure fixtures/UIDs; CONTRACT/CHECKLIST/CURRENT_STATE/CANDIDATE/ARCHITECTURE; docs/evidence/M009/.
Checks and exact exit results: final navigation/forest/town/water/candidate/application/travel/companion checks PASS0; pinned extractor/import/evidence audit/diff check exit0. Import retains known SDK/certificate diagnostics.336373 radius0.4m samples;6336 polygons;18 required paths+4 crossing paths;16 physical forest/74 town routes;three rollback rejections/four complete round trips.Cold generation797.363ms,warm exterior max1315.746ms,30-query p95718us;18 inspected retained rendered captures,fresh Moonwell round trip,normal F10 exit0.
Evidence: docs/evidence/M009/VALIDATION.md,navigation/forest reports,snapshot hashes,rendered index/contact sheet,raw commands/responses,accepted and failed logs.
Decisions or retained limits: radius0.4m/height1.6m/climb0.1m/source geometry unchanged;0.44m nav-only exclusions and centimetre vertex/merge raster repair corner aliases;shared WorldHost waits for nonzero queryable region on commit/rollback.Single synchronous bake meets budgets;no cache/background task required.M010 connected recovery and M011–M019 remaining scope not certified.Schema4/content1,pinned snapshot,normal save and P014 compact completion preserved.No agent commit/export/source write.
Next eligible task: M010 companion river and ramp recovery only.

M010 — completed 2026-10-03
Result: shared ally follow requires similar height/clear sight before stopping; catch-up/recovery requires complete nav endpoints and physical path/direct capsule-floor corridors, preventing river/cliff/disconnected/stale/combat shortcuts. Normal compact game retained.
Files: companion_controller.gd; map_companion_checks.gd/UID; companion_checks.gd; candidate root labels; CONTRACT/CHECKLIST/CURRENT_STATE/CANDIDATE/ARCHITECTURE; docs/evidence/M010/.
Checks and exact exit results: final map/compact companion/application/movement-camera/travel/dialogue checks PASS0; extractor/import/evidence audit/diff check exit0. Import retains known SDK/certificate diagnostics.14 physical AI routes/19,808 samples/max grounding error0.00000025332m;five placement rejections,five suspension gates,true curb stall then catch-up after removal,3s recovery. Fresh rendered Moonwell round trip,both crossings both ways and forest approach:64 retained PNGs/31 inspected moving views,132 repaths,zero teleports,normal F10 exit0.
Evidence: docs/evidence/M010/VALIDATION.md,companion report/snapshot hashes,exact exits,accepted and failed logs,ordinary-input commands/raw responses/captures/rendered index/four contact sheets.
Decisions or retained limits: direct corridor required even if distant crossing connects banks;unsafe ally stays stalled/down until safe placement. Nav-floor0.35m tolerance preserves compact0.25m/candidate0.05m offsets,changes no geometry. Northern terrace internal ramp synthetic only. Schema4/content1,pinned snapshot,normal save/production IDs/selection unchanged. No AI-all16-lanes/art/activation/native map release claim;P014 compact completion preserved,M019 owns native map gate. Early fixture/tolerance/sync failures retained/repaired.No next item started.
Next eligible task: M011 landscape appearance only.

M011 — completed 2026-10-03
Result: world-space meadow/path/sand/cobble materials, exact masked wet banks and restrained fragment-only teal river flow; six registered terrain batches/default grass preserved, candidate isolated.
Files: landscape_materials.gd, landscape.gdshader, river.gdshader and UIDs; terrain_preview.gd/candidate root; map_landscape_checks.gd/UID; CANDIDATE/CHECKLIST/CURRENT_STATE; docs/evidence/M011/.
Checks and exact exit results: extractor/import/final import/landscape/candidate/water/crossing/application/companion/audit/diff check PASS0; known SDK/certificate diagnostics retained.26,600 height-registered quads,47,040 default/semantic samples,8,598 exact water samples;94 crossing walk/dodge lanes/four rail slides.74 retained captures/36 inspected clear views/five sheets;fresh ordinary town/Moonwell/ford both ways/bridge/Tollworks/closed-exit tour,HP100/100,138 repaths,zero catch-ups;two normal F10 exits0,no saves.
Evidence: docs/evidence/M011/VALIDATION.md,landscape report,source-art reference/hash sheet,snapshot hashes,rendered-index/contact sheets,exact input JSON/raw responses/runtime/driver logs/copied PNGs.
Decisions or retained limits: six source swatches reference only,zero source images/runtime assets copied;3D shader adaptation/generic raw ground flecks explicit. Water flow colors only,exact fixed union/no displacement,continues cosmetically under pause. Physics/nav/IDs/schema4/content1/pinned snapshot/normal compact selection unchanged;prop/landmark art M012-M014,activation M015,aim/performance/native gates later.P014 compact completion preserved.No next item started.
Next eligible task: M012 reusable tree art kit only.

M012 — completed 2026-10-03
Result: reusable authored Blender tree kit,all395 exact source trees/nine species/21 actual catalog variants/all three sizes,106 spatial visual batches; source trunk physics unchanged.
Files: art/source/moonwood_tree_kit.blend; game/assets/environment/GLB/import/mapping; tree_art.gd/UID,terrain_preview.gd,map_candidate_root.gd,map_tree_art_checks.gd/UID; tools/map_migration/build_tree_kit.py,CANDIDATE.md; migration CHECKLIST/CURRENT_STATE; docs/evidence/M012/.
Checks and exact exit results: pinned extractor/reference/audit PASS0; initial/final imports0 with known SDK/certificate diagnostics; actual Compatibility GPU art audit PASS0; candidate/crossing/navigation/application/companion PASS0;336,373 nav capsule samples,94 crossing walk/dodge lanes/four rail slides; rendered dense-forest/both crossings both ways,23 clear inspected frames,zero catch-ups,normal F10 exit0; final review/git diff --check0.
Evidence: docs/evidence/M012/VALIDATION.md,tree/navigation reports,source/gallery/two contact sheets,48 PNGs,exact bridge requests/raw responses,accepted/failed logs,hash/index/audit records.
Decisions or retained limits: deliberately compressed species canopies,portable vertex colors/zero external textures; feet/yaws/IDs/collision/elevation/water/nav/schema4/content1 unchanged. Live Blender scenes preserved/vessel restored,snapshot unchanged,normal save absent. Camera/performance/activation/native gates remain later; P014 compact completion preserved. No subagent,source write/refresh,installation,commit,push,publication or next item started.
Next eligible task: M013 reusable town exterior art kit only.

M013 — completed 2026-10-03
Result: reusable footprint-sized town exterior Blender kit,14 building variants/two shared deck modules,all24 original structures plus approved docks/165 quay cells; normal compact game retained.
Files: art/source/alderwake_town_kit.blend; game/assets/environment/GLB/import/mapping; town_art.gd/UID,terrain_preview.gd,candidate root,map_town_art_checks.gd/UID; tools/map_migration/build_town_kit.py,CANDIDATE; migration CHECKLIST/CURRENT_STATE; docs/evidence/M013/.
Checks and exact exit results: pinned extractor/Blender render/finalize/initial-final imports/art/town/water/candidate/application/companion/audit/collect-views/diff check PASS0; known SDK/certificate diagnostics retained.24 source placements,168 exact base corners,48m2 approved dock art,6,110 triangles;37,325 polygon queries/74 physical town routes/18,325 path samples;8,598 water cells/4,027 edge sweeps.17 clear inspected rendered views/36 PNGs,ordinary town/all three docks out-and-back/passenger quays,HP100/100,146 repaths,zero catch-ups,normal F10 exit0.
Evidence: docs/evidence/M013/VALIDATION.md,town-art/tour/audit/hash/reference reports,gallery/two contact sheets,exact requests/raw responses/PNG captures,accepted logs.
Decisions or retained limits: deliberate shallow catalog-footprint gabled fronts,compressed1.76–3.41m heights,vertex-color surface detail/no external textures; source feet/yaws/IDs/collisions/nav/elevation/water/dock masks/schema4/content1 unchanged. Live Blender user scenes preserved/vessel restored,normal save absent,snapshot unchanged. Candidate isolated; M014 landmarks/M015 activation/M016 camera/M017 saves/M018 performance/M019 native map gate pending; parent P014 compact completion preserved. No subagent/source write/refresh/installation/commit/push/publication/next item started.
Next eligible task: M014 bridge Moonwell and gate appearance only.

M014 — completed 2026-10-03
Result: reusable Blender bridge/deck/rail/landing,exact-foot Moonwell and closed east barricade art;five meshes/seven appearance instances,normal compact game retained.
Files: art/source/alderwake_landmark_kit.blend;game/assets/environment/GLB/import/mapping;landmark_art.gd/UID,terrain_preview.gd,candidate labels,map_landmark_art_checks.gd/UID;tools/map_migration/build/export_landmark_kit.py,CANDIDATE;CHECKLIST/CURRENT_STATE;docs/evidence/M014/.
Checks and exact exits: extractor/live Blender authoring-export/background render-finalize/initial-final imports/seven focused art-crossing-forest-nav-candidate-application-companion checks/audit/contact sheet/diff check PASS0.8,536 art vertex samples,816 physical nodes and6,336 nav polygons unchanged;94 crossing lanes/four rail slides;64,178 forest probes/16 physical routes;336,373 nav samples/three rollbacks/four round trips.426 retained requests/one rejected focus loss,19PNGs/eight inspected clear views;ordinary bridge both ways/gate walk-dodge contact,HP100/100,zero catch-ups,no saves,normal F10 exit0.
Evidence: docs/evidence/M014/VALIDATION.md,art/nav/forest/audit/hash/source/preservation reports,gallery/contact sheet,exact input commands/raw responses/captures,accepted and retained failed logs.
Decisions/limits: source one-row bridge art expands to existing3m corridor,thin0.1m rails preserve2.8m clearance;well exact octagon/static blue spiral,gate boards follow sole authored2x8m blocker. Vertex colors/no external textures;source feet/yaws/IDs/physics/nav/schema4/content1/snapshot/normal save fixed. User Blender scenes/vessel restored. Candidate isolated until M015;M016–M019 gates pending,parent P014 compact complete. No source write/refresh/install/subagent/commit/push/publication/next item.
Next eligible task: M015 activate larger town and existing quest route only.


M015 — completed 2026-10-03
Result: production 147x80m exterior,exact Chandlery counter/single forest Tollworks gate,existing full recovery route and service;all stable IDs/schema4/content1 retained.
Files: alderwake_exterior.gd/UID,alderwake.tscn,terrain nav hook,root grounding/hints,quest/dialogue content;activation test/UID,geography-sensitive tests,compact fixtures,debug observer;README/ARCHITECTURE/parent scope note/CONTRACT/CANDIDATE/CHECKLIST/CURRENT_STATE;docs/evidence/M015/.
Checks and exact exits: extractor/initial-final imports/ten focused checks/post-repair observer/audit/diff PASS0;known SDK diagnostic retained.3,226 production route capsule samples,336,373 inherited nav samples,three rollbacks/four nav round trips/ten production round trips.628 accepted full-journey responses,44.016s outbound hold-step movement,HP100/50,187 repaths,zero catch-ups,six effects once,service restored,normal F10 exits0;fresh final-code labels inspected.
Evidence: docs/evidence/M015/VALIDATION.md,activation/nav/audit/source-drift reports,views/index,exact request/response JSON and copied PNGs,runtime/accepted/failed logs.
Decisions/limits: three service nav outlines,existing grounding generalized across arrivals;single destination API retained,six other portals inert. Source map added three NPCs externally; pinned snapshot unchanged,extras deliberately outside scope. Two detached-guardian observer errors retained/repaired with regression;no gameplay authority change. No Blender/source write/refresh/install/subagent/commit/push/publication. P014 compact completion preserved;M016-M019 pending;no next item started.
Next eligible task: M016 camera ground aiming and canopy visibility only.

M016 — completed 2026-10-03
Result: physics-floor targeting with seam/hidden-base protection, level aim/attacks and minimal party canopy cutout at evidenced dense-forest occlusion; camera bounds/input gates retained.
Files: camera_rig/game_root/actor, compact/candidate floor tags, tree_art/canopy_visibility shader, camera checks/render harness, tree audit/bridge observation, migration checklist/state, docs/evidence/M016.
Checks and exact exit results: final six focused headless checks PASS0; actual tree audit PASS0(395 trees/21 variants/106 batches); extractor/import0(known SDK diagnostic);330 aim samples max0.000007691208m; ordinary10-site106-capture tour normal quit0; final60 static+6 recorded moving-pose renders0/no errors; git diff --check0.
Evidence: docs/evidence/M016/VALIDATION.md, camera-report.json, final-check-results.json, survey-final/audit.json, inspected final sheets, exact input/response arrays and retained failures.
Decisions or retained limits: tree-only cutout preserves shadows/geometry/physics/nav/IDs. Final visual survey replays recorded feet, not ordinary quest flow. No roof treatment where service approach clear. Snapshot/schema4/content1 unchanged; M018 ray/shader costs and M019 larger-map native gate still pending. P014 compact completion preserved.
Next eligible task: M017 save load retry and scene replacement compatibility only.

M017 — completed 2026-10-03
Result: historical schema4 town/Tollworks save compatibility, immediate paused actor/corpse collision/presentation, safe full-party restore/retry/rollback and replacement lifecycle.
Files: actor_placeholder/game_root; map_save_checks/UID; historical save/provenance and two rejection fixtures; detached compact companion test; CHECKLIST/CURRENT_STATE; docs/evidence/M017/.
Checks and exact exits: final import/extractor/audit0; five-fixture writer/reader/checks PASS0 in separate PIDs; save/combat/companion/recovery-presentation/application PASS0;24 swaps/four failed loads/five retry cases;three actual GUI save/restart/load processes normal F10 exits0,no runtime errors;git diff --check0.
Evidence: docs/evidence/M017/VALIDATION.md,checks/write/read reports,process/final results,audit.json,14 exact request/response pairs and14PNG captures,GUI saved envelopes/launches/exits,accepted and retained failed logs.
Decisions/limits: four byte-exact pre-map saves plus labeled synthetic downed-ally/Tollworks-start fixture;JSON comparisons normalized numeric types. P009 original obstacle assertions use detached compact fixture. Source snapshot/schema4/content1/IDs/authority unchanged;normal save untouched. Synthetic headless and historical-seeded GUI restore prove compatibility,not full fresh/native journey. Parent P014 compact complete;M018/M019 gates pending. No next item started.
Next eligible task: M018 measured map performance only.