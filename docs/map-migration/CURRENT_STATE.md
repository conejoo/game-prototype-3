# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M004 verified complete.

## Selection and next action

- Active migration item: none. Selected M004 completed this session.
- Completed: M001 contract, M002 pinned extraction, M003 terrain candidate,
  M004 river/lake/basin blockers and closed-exit collision.
- Next eligible: M005 footbridge and sand ford traversal only. M005–M019 pending.
- Normal Alderwake remains compact; explicit alternate candidate scene only.
  Production activation M015. Parent P001–P014 compact-build completion preserved;
  M019 must verify the resulting map build with ordinary native inputs.
- Full acceptance/commands/failures: [M004 validation](../evidence/M004/VALIDATION.md).

## Preparation, workspace and authority

Target D:/development/game-dev-blender/returning-fair-prototype, Godot project game/.
Initial Git clean, HEAD8a05a8d (M003). Read applicable workspace AGENTS, parent
architecture/state, full migration prompt/investigation/checklist/state/contract,
pinned layout/provenance/extractor and candidate implementation/evidence/playtest
instructions. M003 artifacts/checks inspected before selecting M004; marked in
progress before edits. Used caveman and Returning Fair gameplay-testing skills.
No source edits/generators, refresh, dependencies, subagents, Blender, exports,
commit, push or publication. Prior P014/M001–M003 evidence preserved.
User subsequently authorized committing the completed M004 changes and evidence.

Pinned authority remains snapshot `alderwake-f4630f9-m002`, source commit
`f4630f9966d6637ef6579cd87623ea354758191c`. Source checkout read-only; runtime reads
only target-local layout. Manifest retains five byte-exact map/catalog/material/
raw-tile/art-registry inputs. Extractor --check PASS0, no refresh.

- Map SHA256 `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
- Catalog SHA256 `59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.
- Layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
- Extraction report SHA256 `66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9`.
- [Current hashes](../evidence/M004/snapshot-hashes.json); M002 data acceptance
  retains468 props/455 enabled footprints,102 authored colliders,31 groups,
  8 art layers,4 tile layers,7 portals,472 elevations/16 slopes,25 zones,
  3 activities and91 inert records. No new gameplay records enabled.

## M004 changed files and implementation

- `game/world/map_candidate/water_blockers.gd` plus UID:90 water rectangles and
  `future-exit-gate`, exact source IDs/X/Z bounds, independent layer1 static boxes
  spanning Y[-0.2,3]. Select only moonwood-water-*, south-water-* and passenger-
  basin-water-01; other authored/catalog blockers remain pending.
- `terrain_preview.gd`: composes water builder; six dry terrain/marker batches
  plus one water union. Tile water inventory remains unchanged, but diagnostic
  water visual follows authored occupancy so bridge/dock openings remain dry.
  Independent base floor/perimeter remain; no physics from art.
- Separate blue union mesh atY0.015 covers8,766 half-metre cells/2,191.5m²,
  including river/lake, southern shore and passenger basin. Gate diagnostic rim
  only0.6m; M007/M014 still own landmark wrapper/art.
- Provisional nav bakes explicit dry-only row triangles, excludes water/gate,
  never parses art/blocker tops/full base floor. Radius0.4m/height1.6m/climb0.1m;
  cell0.2m/height0.1m, contour error0.1. Final497 polygons, Recast rasterY0.2
  versus physicalY0. M009 owns complete physical-surface nav/routes/timings.
- `game/tests/map_water_checks.gd` plus UID: actual body inventory/registration,
  every occupied cell, radius-aware exposed-edge sweeps, synchronized nav audit,
  dry pad positives/river/lake/basin/shore/gate negatives, opening clearance,
  real hero walk/dodge at probes/seams/edges/gate with <=0.1m displacement samples.
- `map_candidate_checks.gd`: six terrain batches+water; base-floor rays exclude
  only new blocker bodies, keep existing party/save/bounds/full-footprint checks.
- `map_candidate_root.gd`: honest M004 HUD/readiness labels. Existing alternate
  catalog/root/services/party/camera controls unchanged.
- `tools/map_migration/CANDIDATE.md`, migration CHECKLIST/this state and
  `docs/evidence/M004/` updated. CONTRACT and parent production files unchanged.

## Verification and actual rendered observations

Both installed Godot paths exist; version4.7.2.stable.mono.official.ed1daf0bf.
Exact commands from target root and logs in M004 VALIDATION.md:

- Bundled Python -B tools/map_migration/extract_layout.py --check: PASS/exit0.
- Godot --headless --editor --path game --import --quit: exit0. Known missing
  .NET SDK10.0.9/certificate diagnostics retained; no clean-import claim.
- Godot --headless --path game --script res://tests/map_water_checks.gd:
  final PASS/exit0;91 bodies/90 water,8,766 occupied cells,4,195 capsule edge
  sweeps at<=0.1m;22 hero walking/dodge cases grounded and blocked. All8,766
  water centers >=0.430115m horizontal distance from synchronized nav; positive
  dry start/return nearest points validated, no blocker-top navigation.
- Same command for map_candidate_checks.gd: final PASS/exit0;11,760 actual
  base-floor probes, both WorldHost party pads and reload identity/save isolation,
  all four bounds/corner and full-width/depth actual capsule movement.
- Same command for application_smoke.gd: PASS/exit0, normal compact composition,
  input/pause/resume. Accepted runtime logs only known certificate diagnostic.
- Rendered A: alternate return spawn, inspected paused0s; ordinary viewport
  WASD/Space on bridge north/south contacts moonwood-water-014/-015; ordinary
  dry-bank walk to ford, north/south contacts -024/-025. GroundedY<0.001m,
  no water entry. No teleports/state mutations or Save/Load. Inspected960×640
  contact and pause captures; exact commands/raw responses/timings retained.
- A north end(100.0956,0.000942,-1.65558); south(98.3586,0.000940,0.649058);
  ford north(71.1788,0.000942,11.35094); south(69.8146,0.000405,13.64906).
- Rendered B after final nav refinement: return placement, ordinary north/east
  walk+Space blocked by future-exit-gate at(122.6491,0.000941,-3.92174), before
  colliderX123. Hero/ally readable; final inspected pause. Both A/B normal F10
  quit with retained process handles, exit0. These are debug viewport-input
  checks, not native hardware/export/full-quest evidence.
- Process-local APPDATA=builds/m004-user-data, LOCALAPPDATA=builds/m004-local-data;
  named candidate slots playtest-m004-water-a/playtest-m004-gate-b. No saves written.
- git diff --check exit0; final-review.log verifies intended files, text whitespace,
  local documentation links, hashes, headless results, raw commands/PNGs and exits.

## Failures retained and repaired

Wrong navigation face winding initially produced no dry nav (exit1); corrected
clockwise faces. Initial water rays started inside boxes and sweep capsules touched
floor (exit1); corrected ray origin/2cm lift without changing collision. Old M003
floor test hit new blockers (exit1); exclude those bodies for base-floor coverage.
Broader synchronized nav audit found10 bank-corner water centers below0.4m under
default contour simplification (exit1); set edge_max_error0.1, keep radius0.4,
final minimum0.430115m. Failed logs remain; earlier narrow nav checks not accepted
as final proof. First rendered bridge-south chord moved east; retained as steering
failure, corrected A+S and rechecked. Initial final-review used Windows default
codec for UTF-8 state (exit1); fixed explicit UTF-8 read, final PASS0. No blocker remains.

## Contract, timing and limits for next session

Coordinates unchanged:32units/m, origin(704,576), X[-22,125),Z[-18,62),147×80m,
physicalY0 preview. Both3m crossing gaps preserved: bridgeZ[-2,1), fordZ[11,14).
Real radius0.35m capsule clearance queries at0.1m over0.4m-inset opening grids
pass. No bridge deck/rail construction or bidirectional traversal completion.
Both start(0,0,0)/return(107.25,0,1.25) full-party pads safe after water; retain
existing+1m X ally offset and revalidate after later props/heights.

Normal catalog/main scene/production location and spawn IDs, schema4/content1,
quest/once-only services, imported art and normal user save untouched. Candidate
remains detached/test-only. Heights/ramps/cliffs M008, complete nav M009,
connected companion recovery M010, landscape M011, trees/town/landmark art and
normal activation M015 pending. Six unused routes remain inactive. No larger-map
performance/save/export/native release claim. Parent P014 compact-build complete;
M019 must reverify resulting map build.

Pause overlays inspected after every input batch before reasoning. Game runs
between tool calls until confirmed paused; duration is wall-driven, not physics
stepping. Brief pause during unfinished dodge can keep save locked until resumed
cooldown finishes; later batches settle before pause. A+S points roughly south,
D+W north, D+S east, A+W west for current camera; use observed coordinates rather
than assuming global WASD axes. No helper/game process left running.

Select M005 only: read full prompt/contract, this state, pinned bridge art/ford
records and M004 blockers/tests/evidence. Add graybox deck/edge rails/landings and
ford treatment; prove ordinary movement both directions, adjacent water blocked,
no snags/third route. Keep all90 water footprints and source gap boundaries;
recheck pad/bounds/nav exclusion after changes. Do not activate normal exterior,
refresh source snapshot, use normal save or start forest/elevation/navigation item.
