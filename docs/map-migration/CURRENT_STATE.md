# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M003 verified complete.

## Selection and next action

- Active migration item: none. Selected M003 completed this session.
- Completed: M001 coordinate/compatibility contract; M002 pinned extraction;
  M003 isolated runnable exterior terrain graybox.
- Next eligible: M004 river lake and basin blockers only. M004–M019 pending.
- Normal Alderwake remains the compact prototype; candidate requires explicit
  alternate scene launch. Production activation is M015.
- Parent P001–P014 complete for compact prototype; [native P014 evidence](../evidence/P014/native-holds/VALIDATION.md)
  and parent state preserved. M019 must revalidate the resulting larger-map build
  with ordinary native inputs. Candidate evidence does not complete that gate.

## Workspace and source authority

Target `D:/development/game-dev-blender/returning-fair-prototype`; Godot project
`game/`. Workspace parent is not Git repository. Initial Git clean; inspected
HEAD `b0982e93ef35331d8f5a6a54b017fbe2446ba239`. Existing parent implementation,
art and P014/M001/M002 evidence preserved. No source edits/generators, snapshot
refresh, installs, subagents, pushes, exports or publication. User subsequently
authorized committing the completed M003 implementation and evidence.

Read-only source `D:/development/game-prototype-2`; pinned authority remains
snapshot `alderwake-f4630f9-m002`, source commit
`f4630f9966d6637ef6579cd87623ea354758191c`. Do not refresh automatically.
[Manifest](../../tools/map_migration/reference/manifest.json) retains five byte-exact
map/catalog/material/raw-tile/art-registry inputs. Source images not imported.

- Map SHA256 `af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.
- Catalog SHA256 `59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2`.
- Layout `game/content/maps/alderwake_layout.json` SHA256
  `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.
- Extraction report SHA256
  `66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9`.

M003 reran pinned extractor `--check` before work, exit0. Layout/report unchanged.
M002 [validation](../evidence/M002/VALIDATION.md) remains authority for 15 extraction
tests, transforms, fractional Moonwell/polygon, enabled catalog footprints and
inventories:468 props/455 enabled catalog footprints,102 authored colliders,
31 groups,8 art layers,4 tile layers,7 portals,472 elevations/16 slopes,
25 zones/3 activities,91 inert records. Runtime reads only target-local JSON.

## M003 implementation and changed files

- `game/world/map_candidate/terrain_preview.gd` plus UID and
  `alderwake_candidate.tscn`: typed PrototypeLocation subclass, seven batched
  material/diagnostic-marker meshes, independent flat floor and four perimeter
  bodies, safe start/return anchors, provisional flat nav polygon.
- `game/tests/map_candidate.tscn`, `map_candidate_root.gd` plus UID,
  `fixtures/map_candidate_location.tres`: explicit alternate root inherits normal
  GameRoot, appends one location to detached manifest, reuses session/services/
  WorldHost/persistent party/camera/UI. Candidate HUD labels limitations; no journal
  or gameplay interactions. Optional `--candidate-return` selects safe return
  arrival; `--candidate-paused` provides a verified initial playtest checkpoint.
- `game/tests/map_candidate_checks.gd` plus UID: meaningful data/actual emitted
  mesh registration/default/clear/grid checks, all-floor coverage, real WorldHost
  two-party placement/identity, normal-catalog/save rejection, synthetic physical
  edge/dodge and full-width/depth traversal. Synthetic placements are labeled.
- `tools/map_migration/CANDIDATE.md`: launch commands, preview dispositions,
  save isolation and handoff boundaries. Migration CHECKLIST/this state updated.
- `docs/evidence/M003/`: full validation, exact command JSONs/summaries/raw bridge
  responses, observed PNGs, headless/import/runtime logs, hashes/final review.

No normal game/service/save/art files changed. Parent architecture and CONTRACT
unchanged: this is the already-authorized provisional stage, not production scope.

## Terrain, collision and candidate isolation

Contract scale/origin/axes unchanged:32 units/metre, source origin(704,576), source
X/Y -> Godot X/Z; full bounds X[-22,125),Z[-18,62),147×80m. Physical Y=0 preview.
Floor/collision never comes from render meshes or source sprite rectangles.

Each layer preserves source order/visibility/origin and 0.5m/1m grid. Absent cells
resolve layer default; explicit null suppresses only its layer. Grass default
fills47,040 subcells with zero ground overrides. Terrain counts: cobblestone1,113,
dirt2,851,sand1,140,water8,374; shoreline156. Same-material row runs produce1,156
rectangles and seven render batches, not thousands of scripted tile nodes.
Center/connected materials preview solid semantic colors; masks/variants/animation
remain M011. All183 raw decorations get explicit0.12m dots at their1m cell centers;
source tile IDs stay in unchanged layout/report. These dots are not source artwork.

Four3m perimeter colliders sit outside logical bounds;0.6m visible rims keep hero/
ally readable. No jumping exists. Surface offsets0.003m per layer are visual only.
Start(0,0,0) and return(107.25,0,1.25) use existing +1m X ally offset. Real floor/
capsule safety passes for both party members; revalidate when new blockers arrive.
Single0.4m-inset flat navigation polygon is provisional lifecycle support only;
M009 must replace it using complete physical surfaces.

Candidate ID `candidate-alderwake` exists only in detached catalog. Normal main
scene/catalog and stable production IDs remain unchanged, schema4/content1.
Default test save `user://saves/playtest-map-candidate.json`; debug named test slots
remain `playtest-*.json`. Normal catalog rejects candidate saves. No Save/Load
invoked in rendered checks. Process-local APPDATA=`<target>/builds/m003-user-data`,
LOCALAPPDATA=`<target>/builds/m003-local-data`; no normal user save touched.

## Verification and evidence

[M003 validation](../evidence/M003/VALIDATION.md) records commands/exits, acceptance
mapping, failed attempts, raw inputs, actual observations and durable PNG links.
Godot supplied paths verified; engine4.7.2.stable.mono.official.ed1daf0bf.

- Bundled Python `-B tools/map_migration/extract_layout.py --check`: PASS/exit0.
- Godot `--headless --editor --path game --import --quit`: exit0. Known missing
  .NET SDK10.0.9/certificate-store diagnostics retained; no clean-import claim.
- `--headless --path game res://tests/map_candidate.tscn --quit-after 180`: exit0,
  candidate root ready, two-party safe arrival,18 definitions; normal catalog17.
- `--headless --path game --script res://tests/map_candidate_checks.gd`: PASS/exit0
  after final visual-rim change.11,760 floor probes; actual capsule crosses full
  width/depth; four edges and northwest corner block walking/dodge. Both anchor
  placements and same party wrappers verified, meshes registered to source cells.
- `--headless --path game --script res://tests/application_smoke.gd`: PASS/exit0,
  normal composition/input/pause/resume. Rendered default startup also inspected.
- Windowed bridge A: ordinary viewport WASD from(0,0,0) through town/forest/sand
  to return pad(107.13,0,1.21), then east perimeter. No teleport/state mutations.
  Walking/dodge contact BoundaryEast; X124.6491, groundedY0.000944. Confirmed pause
  checkpoints between batches. Captures960×640 show registered terrain/materials.
- Final windowed C: starts at exact return anchor; inspected party arrival and
  walking/dodge against low visual rim, hero/ally visible. Normal F10 quit exit0.
- Windowed B: normal compact Alderwake with Maris/station/gate/objective and two
  party members unchanged; pause/F10 quit exit0. No quest/Save/Load actions.
- Accepted runtime logs have only known certificate diagnostic, no GDScript error.
- `git diff --check` and untracked text/local-link/state/intended-file review exit0.

Initial A renderer not ready after2s: failed sender executed no input; launcher
shell exit1. Same process reobserved once ready. A normal F10 quit logged, exact
child exit unavailable; final B/C process handles captured exit0. Initial focused
test exit1 used overly strict1mm boundary-contact tolerance; observed7mm recovery
remained contained, repaired test to1cm margin without weakening collision. Both
failures retained. Initial tall perimeter visuals hid hero; lowered visual only,
final rendered C and focused check pass after correction.

## Remaining limits and next-session preparation

No M003 blocker. Water remains visibly labeled **walkable preview** until M004;
elevation/ramps/cliffs flat until M008. No authored water/prop/catalog blockers,
bridge/deck, buildings/trees, Moonwell/closed-exit wrappers, art layers, portals,
NPCs/routines/resources/zones/activities or production quests activated. All records
remain in pinned data. No crossing, complete nav/companion recovery, height/aim,
landscape/art, larger-map save compatibility, performance, export or native release
acceptance claimed. Preserve parent P014 compact-build status.

Select M004 only. Read full prompt, contract, this state, layout/colliders and M003
candidate README/checks/evidence. Add source-authored river/lake/basin blockers and
distinct neutral water preview, retaining openings for M005. Separate water render
from physical blockers/navigation. Test real walk/dodge at four negative probes,
seams/edges and perimeter; do not implement crossings/forest/elevation/activation
yet. Recheck both party pads. Existing base floor must prevent falling; water must
leave provisional nav before any complete-navigation acceptance. M009 owns final
route/nav strategy. Never use normal save or refresh pinned source automatically.
