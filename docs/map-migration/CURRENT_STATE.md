# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M008 verified complete.

## Selection and next action

- Active item: none. **M008 physical elevation and ramps completed** this session.
- Next eligible: **M009 navigation for complete exterior only**. Begin with the
  retained Moonwell corridor/ramp corner clearance failure; do not weaken radius,
  climb, source footprints or movement masks. M009–M019 remain pending.
- Candidate remains isolated/test-only; normal compact Alderwake selected until M015.
  Parent P001–P014 compact build complete; M019 must revalidate resulting map release.
- Acceptance: [M008 validation](../evidence/M008/VALIDATION.md). No M008 blocker remains.

## Preparation and authority

Target D:/development/game-dev-blender/returning-fair-prototype; Godot project game/.
Initial Git clean at HEAD00c9110a27a434c49c2be89c00a1e1272d49d067 (M007).
Read workspace AGENTS (no nested), full map prompt, parent architecture/state,
migration investigation/checklist/state/contract, pinned map/catalog/manifest/layout/
report, M007 evidence and actual candidate/actor/party/WorldHost/camera/input bridge.
M008 marked in progress before edits. Caveman and Returning Fair gameplay-testing
skills used. Exactly one item. No subagents, source writes/generators/snapshot
refresh, installation, Blender, commit, push, export or publication. Prior evidence preserved.

Snapshot alderwake-f4630f9-m002; source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs unchanged; runtime
reads target-local normalized layout only. [Hashes](../evidence/M008/snapshot-hashes.json).

- Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f.
- Catalog SHA256 59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2.
- Layout SHA256 7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
- Report SHA256 66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.

## M008 implementation and changed files

- game/world/map_candidate/elevation_surfaces.gd plus UID: analytical pinned height
  field, 472 raised cells/16 ramps,238 differing-profile cliff barriers,independent
  riser visuals and physical/nav input. Default floor remains original solid Y0
  base; raised/ramp concave physics avoids coplanar default contacts. Matching
  ramps/high-low joins open; all other differing profiles block both directions.
  Levels remain0.25m,maximum1.75m,ramps14.04degrees. No height/grid/scale adaptation.
- terrain_preview.gd: height-following batched surfaces, physical spawn heights,
  independent base floor,forest/town height injection and provisional height-aware
  dry nav. Six material batches/defaults/mixed grids unchanged. Nav voxel height
  now0.05m; horizontal0.2m,radius0.4m,climb0.1m unchanged. water_blockers.gd extends
  existing0.2m nav-only margin to all effective water pieces after measured river/
  lake contour cuts. Physical water masks/records,sole gate and dock cuts unchanged.
- forest_population.gd/town_footprints.gd: exact physical source feet, including
  Moonwell(31.51317596435547,0.5,4.621034622192383). prop_grayboxes.gd extends blocker
  vertical bounds to nearby terrain while preserving exact X/Z polygons/flags/yaw.
  crossings.gd/shared dock helper mark actual floor bodies for grounding queries.
  All468 props/455 catalog footprints/102 authored collider identities retained.
  Graybox art/inert records remain as M007; no new interactions/NPC behavior.
- game/features/actors/actor_placeholder.gd: optional transient floor-height
  callback after move_and_slide; normal rooms leave it empty. Candidate root sets
  snap0.04m and injects actual nearby-floor ray/full-capsule validation,normalY>=0.96,
  range0.11m. X/Z movement stays physics-authoritative;0.25m cliffs cannot be snapped
  across. No persistent field,save schema,party/service authority or normal setting change.
- game/tests/map_elevation_checks.gd plus UID: all height rays,64 bidirectional
  ramp walk/dodge cases,476 cliff casts and2,646 real walking/dodge/diagonal cases.
  Existing candidate/forest/town tests now use physical heights,exact Y metadata,
  full-map floor rays and height-aware grounding. Forest report writes M008 evidence,
  preserving M007 files. Candidate root/HUD labels physical heights/inactive routes.
- CANDIDATE/CONTRACT/CHECKLIST/this state and docs/evidence/M008/ updated. Parent
  architecture/state/P014 remain unchanged: ownership/production scope unchanged.

## Exact final checks

Both supplied engine executables exist;4.7.2.stable.mono.official.ed1daf0bf.
All commands from target root;process-local APPDATA/LOCALAPPDATA use
builds/m008-user-data and builds/m008-local-data. Normal user save untouched.
See VALIDATION.md for full commands/logs and accepted-versus-failed attempts.

- Bundled Python -B tools/map_migration/extract_layout.py --check: PASS/exit0.
- Godot --headless --editor --path game --import --quit: initial/final exit0;
  known missing SDK10.0.9/certificate diagnostics retained,no clean-import claim.
- --headless --path game --script res://tests/map_elevation_checks.gd: final
  *-ground-policy.log PASS0;4,392 height rays,64 ramp runs,476 cliff casts,2,646
  cliff runs,67,945 motion samples,max grounding error0.019152m. No tolerance raised.
- map_candidate_checks: final PASS0;11,760 physical floor rays,original1cm perimeter
  gate,both full-party pads,reload/identity/save isolation/full-width movement.
- map_crossing_checks: final PASS0;4,032 probes,94 clear walk/dodge lanes,four rail
  slides,27,780 motion samples;water/gate footprints and source cache retained.
- map_town_checks: final PASS0;37,325 polygon queries,18,290 path samples,74 physical
  routes;Maris/fitting pads,doors/quays and all three approved docks remain usable.
- map_water_checks: final PASS0;90 original records,8,766 authored/8,598 effective
  cells,seams/edge sweeps,four negatives and gate walking/dodge blocked.
- application_smoke,movement_camera_checks,location_travel_checks: final PASS0,
  normal composition/input/camera/modal/party/travel behavior preserved.
- map_forest_checks: **FAILED/exit1**,strict0.4m nav-corner clearance gate below.
  Inventory/polygon audits and16 actual hero routes finish;not a passing nav check.
- report_m008.py/final_review.py: PASS0;source hashes,accepted logs,retained24 PNGs/
  raw final-run observations,explicit M009 failure,status/links/scope review.
- git diff --check: exit0;intended files reviewed,no unrelated changes.

Accepted runtime logs have no SCRIPT ERROR;only known certificate-store diagnostic.
Parent P014 evidence and previous M001–M007 evidence stay intact.

## Rendered final evidence

Final accepted run m008-hills-d,Compatibility/OpenGL960x640,RTX4070 Laptop/NVIDIA581.29.
Fresh town start,normal viewport WASD/Space through opt-in bridge,no teleport or
actor/health/quest mutation. Bounded movement batches start/end confirmed paused;
wall time is not fixed physics. Raw responses/24 PNGs retained in M008/windowed/d/;
[per-step index](../evidence/M008/rendered-index.json). Driver uses measured physical
path waypoints and read-only actual positions; no save/load command or slot write.

Town->entry ramp->Moonwell ramp->well(31.62564087,0.5,5.27000380),paused10.15860s.
Walking/dodge contacts cliff-53-23-south/cliff-52-23-south,staysZ5.63906,Y0.5.
Ordinary reverse route observes Moonwell slopeY0.424187/0.348141/0.279863 and entry
slopeY0.191421/0.124837,then town(-0.05073712,0,-0.04928150),paused21.37805s.
Hero/ally/ramp/platform readable;moving views and pause overlays inspected.
Both party wrappers/empty quest/effects retained;no catch-up/recovery claim.
Final process normal F10 exit0;earlier a/b/c diagnostic processes also quit0.
No new game/helper remains. Named slot playtest-m008-hills.json not written.

## Repairs and remaining limits

Preliminary evidence retained. Coplanar default concave floor contacts caused
1.7cm perimeter penetration;solid default base plus raised/ramp collision repairs
original gate. Full cliff sweep exposed9.9cm wall snap;settling contacts alone
failed.4cm snap alone then missed fast downhill dodge at highest ramp. Final
actual-floor ray/full-capsule policy passes all,maximum1.92cm error. Only final
*-ground-policy.log files are accepted;earlier elevation *-accepted/*-final logs
include failures. No failing check counted as a pass.

Old Moonwell approach1m south sits near physical cliff;revalidated waypoint
(31.51317596435547,0.5,5.25) is0.629m south of unchanged well. No source placement
change. Water contour cuts repaired with existing nav-only margin. Larger cliff
margin disconnected one-metre corridor;0.1m horizontal voxel/merge/corner-buffer
experiments failed other routes and were reverted. Current physical hero routes
finish;strict0.4m nav capsule still intersects the corridor/ramp corner at12
probes nearX26.60–27.14,Z1.90–2.36. This is the next M009 repair target:
[known limit](../evidence/M008/navigation-known-limit.json),
[paths/counts](../evidence/M008/forest-report.json). Preserve0.4m radius,0.1m climb,
cliffs/footprints and gates;repair contour/erosion strategy and measure loading.

M008 complete. M009 nav/loading,M010 connected companion recovery,M011–M014 art,
M015 activation,M016 height aiming,M017–M019 saves/performance/native map release
remain. Parent P014 compact-build completion preserved;no export/performance/
full native map-build gate claimed. Next session selects M009 only.
