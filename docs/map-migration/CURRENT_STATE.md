# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M005 verified complete.

## Selection and next action

- Active item: none. Selected M005 completed this session.
- Completed: M001 contract, M002 extraction, M003 terrain, M004 water/gate,
  M005 bridge and sand ford traversal.
- Next eligible: M006 town building and dock footprints only. M006–M019 pending.
- Candidate remains alternate/test-only. Normal Alderwake compact until M015.
  Parent P001–P014 compact build complete; M019 must verify resulting map release.
- Acceptance/commands/evidence: [M005 validation](../evidence/M005/VALIDATION.md).

## Preparation and snapshot authority

Target D:/development/game-dev-blender/returning-fair-prototype; Godot project game/.
Initial Git clean, HEAD ee16f9c883b157f4a8cf4b7b163c3b2d698f7803 (M004).
Read workspace AGENTS, full migration prompt/investigation/checklist/state/contract,
parent architecture/state, candidate/actor/camera/party/WorldHost boundary,
pinned layout/provenance/report/bridge art rows and M004 evidence/playtest tools.
No nested target AGENTS found. First eligible M005 marked in progress before work.
Caveman and Returning Fair gameplay-testing skills used. Exactly one item;
no source writes/generators/refresh, dependencies, subagents, Blender, commit,
push, export or publication. Prior P014/M001–M004 evidence retained.
User subsequently authorized committing the completed M005 changes and evidence.

Snapshot alderwake-f4630f9-m002, source commit
f4630f9966d6637ef6579cd87623ea354758191c; five byte-exact inputs unchanged.
Runtime reads target-local layout only. Extractor --check PASS/exit0.

- Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f.
- Catalog SHA256 59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2.
- Layout SHA256 7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
- Report SHA256 66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
- [Current hashes](../evidence/M005/snapshot-hashes.json); retained468 props/455
  enabled footprints,102 colliders,31 groups,8 art layers,4 tile layers,7 portals,
  472 elevations/16 slopes,25 zones,3 activities,91 inert objects. Pending gameplay
  records remain inactive.

## M005 implementation and changed files

- game/world/map_candidate/crossings.gd plus UID: two independent wrappers,
  six floor boxes/two rails, replaceable VisualRoots. Bridge derived from18
  pinned art cells: X[95,101),Z[-2,1),6×3m.2×3m landings extend to X93/103.
  Thin0.1m rails Z[-2,-1.9),[0.9,1),height0.6m leave2.8m clear deck; no inward
  posts/end caps. Physical tops flushY0; visual topsY0.018 avoid terrain overlap.
- Source narrow middle art row deliberately expands to full authored dry corridor
  with edge rails, as contract requires. M014 owns final bridge art.
- Ford terrain cells x89–95,y29–31 map to X[67,74),Z[11,14),7×3m.1×3m
  landings extend to X66/75. moonwood-sand-ford is local candidate wrapper name
  with source-cell metadata, not a source record ID or unrelated western old-ford
  zone. Source group metadata retained for bridge. No swimming/ferry/new route.
- terrain_preview.gd composes crossings and clips rails out of explicit dry nav
  triangles; no art/blocker-top parsing. Existing provisional radius0.4m,
  height1.6m,climb0.1m,contour0.1 retained; final nav/recovery M009/M010.
- game/tests/map_crossing_checks.gd plus UID: physical registration/flush floors,
  4,032 clearance/floor probes at0.1m,104 bidirectional walk/dodge lane runs,
  4 diagonal rail-slide/end-exit runs,30,728 displacement samples, all new body
  footprints outside every authored water rectangle; safe WorldHost party pads.
- map_water_checks.gd: crossing Z inset0.5m accommodates0.1m rails, retaining
  radius0.35m capsule clearance. New focused check independently covers near-edge
  lanes. Water footprints remain unchanged; bank/nav/gate coverage retained.
- map_candidate_root.gd honest M005 HUD/readiness; alternate catalog/save and
  existing root/services/session/party/input/camera unchanged.
- tools/map_migration/CANDIDATE.md, migration CHECKLIST/this state,
  docs/evidence/M005/ updated. CONTRACT/parent architecture/state unchanged.

## Verification and rendered observations

Both installed Godot paths exist; version4.7.2.stable.mono.official.ed1daf0bf.
Exact commands/logs in M005 VALIDATION.md; all check commands exit0:

- Bundled Python -B tools/map_migration/extract_layout.py --check: PASS0.
- Godot --headless --editor --path game --import --quit: exit0; known missing
  .NET SDK10.0.9/restricted certificate diagnostics retained; not clean import.
- --headless --path game --script res://tests/map_crossing_checks.gd:
  final PASS0, counts above. Initial PASS retained; final rerun after provenance
  metadata clarification only. No failed gameplay/check this session.
- Same command map_water_checks.gd: PASS0;91 exact bodies/90 water,8,766 cells,
  4,157 edge sweeps at<=0.1m,22 hero walk/dodge cases. Fewer sweeps than M004
  because rails remove some synthetic dry-edge approaches; all water centers
  remain checked.497 nav polygons/min water-nav clearance0.430115m; no usable
  water/blocker-top nav. Full final navigation remains M009.
- map_candidate_checks.gd: PASS0;11,760 base-floor rays, start/return two-party
  pads/reload identity/save isolation, bounds/full-footprint actual movement.
- application_smoke.gd: PASS0; normal compact composition/input/pause/resume.
- Rendered Compatibility/OpenGL960×640, RTX4070 Laptop/NVIDIA581.29. Fresh
  validated return startup(107.25,0,1.25),paused0s; ordinary WASD bridge east→west,
  west→east; bridge again then western dry-bank walk to ford, west→east/east→west.
  No teleport/quest/health/session mutation. Exact inputs/timings/responses/PNGs
  retained under M005; inspected moving and paused captures.
- Bridge west end(92.42492,0.00094,-2.13370),east end(105.13141,0.00094,1.49347),
  beyond converted probes. NorthRail/SouthRail slide cleanly past ends; no step
  snag/crack/water on deck. Party readable in actual images.
- Ford east end(75.87057,0.00094,13.55596),west end(65.41253,0.00094,12.03188),
  beyond converted probes. Additional north/south walk+Space contacts
  moonwood-water-024/-025 atZ11.350943/13.649058, grounded outside water.
  No new third route: every added floor/rail avoids water; all90 authored
  footprints/8,766 occupied cells and exact collision IDs preserved.
- Each batch ends Esc/settle/capture; pause overlays inspected before reasoning
  or next input. Timers0/4/7/24/27/30/32/34s; game runs between calls until pause
  confirmed. Wall durations are not deterministic physics. Seen ally following
  is not M010 recovery acceptance; viewport inputs are not native release proof.
- Normal F10 quit via bridge, retained process handle actual exit0. No game/helper
  remains. No Save/Load used or saves written. APPDATA/LOCALAPPDATA isolated under
  builds/m005-user-data and builds/m005-local-data; named playtest-m005-crossings
  slot. Normal user save untouched.
- final_review.py/final-review.log and git diff --check: PASS/exit0; intended scope,
  whitespace/local links, hashes/logs, response/capture copies, exits/state.
- Documentation patch initially rejected duplicate file operations; corrected
  before writing. No gameplay/check failure or approval rejection occurred.

## Limits and safe next action

No M005 blocker remains.32units/m,origin(704,576),147×80m,X[-22,125),Z[-18,62)
unchanged; physicalY0 preview. Three-metre water gaps preserved; bridge clear2.8m.
Hero/ally capsule0.35m/nav0.4m, +1m X ally arrival offset and safe start/return pads
retained. M008 must recheck crossings/pads after physical slopes/heights; M009 final
nav and M010 connected recovery remain pending. Landscape/tree/town/landmark art
M011–M014 pending. Normal activation M015; no full fresh-town recovery journey,
performance/export/native resulting-map acceptance. Parent P014 compact completion
preserved; M019 must revalidate resulting build.

Select M006 only: reread prompt/contract/handoff, pinned grouped town props/catalog
foot-relative collision and current water/crossing evidence. Add primitive town
building/dock wrappers with exact boxes/polygons/rotation; preserve streets,
Maris/service reserved pad,docks and portal landing clearance. Inactive destinations
stay inert; no interiors/NPC AI. Recheck water/crossing/full-party regressions needed
for M006. No snapshot refresh,normal activation,normal save or forest/elevation/
navigation/art item work.
