# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M011 verified complete.

## Selection and next action

- Active item: none. M011 landscape appearance complete.
- Next eligible: M012 reusable tree art kit only. Read applicable Blender skills,
  inspect live scene, preserve user work; deliberately map all nine source species
  and three size IDs without changing trunk wrappers, source feet or collisions.
  Save .blend under art/source, GLB under game/assets; verify imports, textures,
  dense-forest and crossing views. Do not start M013 in that session.
- M011 acceptance: [validation](../evidence/M011/VALIDATION.md). No M011 blocker.
- Candidate remains isolated/test-only; normal compact Alderwake until M015.
  Parent P001–P014 compact build complete; M019 must verify native map build.

## Preparation and authority

Read workspace AGENTS (no nested), full migration prompt, parent architecture/state,
migration investigation/checklist/state/contract, target-local layout/provenance,
M010 evidence and actual terrain/water/elevation/crossing/root/camera/bridge/tests.
Git clean at 84f814660ee8fe48756336f71b6e8129ac852ee6; HEAD unchanged. M011 marked
in progress before work; exactly one item. Caveman and Returning Fair gameplay-
testing skills used. No subagents, source writes/generators/refresh, installation,
Blender, commit, push, publication or export. P014 and historical M evidence intact.

Snapshot alderwake-f4630f9-m002; source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs unchanged; runtime
reads only normalized target layout. [Hashes](../evidence/M011/snapshot-hashes.json).
Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
Schema4/content1, production location/spawn/actor/quest/effect IDs unchanged.

## Implementation and changed files

- landscape_materials.gd/UID: appearance-only nearest 294x160 semantic texture
  resolves pinned terrain/default/clears plus effective water occupancy; shared
  world-space palette/material factories. Texture never used by physics/nav.
- landscape.gdshader/UID: matte grass variation, warm paths, sand, irregular
  cobbles, narrow dry grass shoulders, shoreline patches and generic ground
  flecks. Original 183 raw IDs/positions remain; no individual 2D sprite-fidelity
  claim for flowers/reeds/rocks/driftwood/lilies. Six source swatches inspected as
  reference, hashes recorded; zero source images reused at runtime.
- river.gdshader/UID: opaque teal, shallow edge and wet earth inside exact union;
  slow fragment-only flow. No vertex movement, transparency/depth reads, new
  collision or geometry. Cosmetic shader TIME continues under pause.
- terrain_preview.gd: build effective water before appearance mask and assign
  six terrain materials/one water material; original triangles, layer offsets,
  source grids, physical risers/heights, floors, nav inputs/settings/IDs intact.
- map_candidate_root.gd: M011 labels only. Normal scene/catalog/save unchanged.
- map_landscape_checks.gd/UID: exhaustive actual mesh/default/mask/water/deck
  registration and height checks, plus two query routes for input-tour planning.
- tools/map_migration/CANDIDATE.md, CHECKLIST, this state; no ownership/contract
  design change needing parent ARCHITECTURE or CONTRACT edits.
- docs/evidence/M011/: VALIDATION, logs/exits, landscape report, source-art
  reference/hash sheet, snapshot hashes, audit script/log, rendered-index,
  five contact sheets, exact ordinary-input commands/raw responses, runtime/
  driver logs and 74 copied PNGs. Prior evidence files untouched.

## Exact checks and results

Full commands in VALIDATION.md, run from target root. Both supplied engine paths
exist; engine4.7.2.stable.mono.official.ed1daf0bf. Process-local APPDATA/LOCALAPPDATA
isolate builds/m011-user-data,m011-local-data and m011-check counterparts. Both
fresh named playtest-m011-landscape-a.json / playtest-m011-town-b.json absent.

- reference_art.py: exit0; six read-only source swatches inspected. Source paths
  come from pinned registry; current image hashes reference only, not refreshed
  snapshot. No source runtime image copies or dependencies added.
- Pinned extractor --check: PASS/exit0, input/layout/report hashes unchanged.
- Initial/final imports: exit0, tracked new GDScript/shader UIDs. Known missing
  .NET SDK10.0.9/certificate diagnostics retained; no clean-import claim.
- Final map_landscape_checks: PASS0; 26,600 terrain quads, each vertex within
  0.0001m of physical cell height plus unchanged lift; exactly one grass coverage
  per 47,040 half-metre samples,47,040 independent semantic probes,8,598 exact
  rendered water cells. No water triangles over bridge/ford/seven approved docks.
  Two fresh navigation-query endpoints connect to Tollworks/closed exit.
- map_candidate_checks,map_water_checks,map_crossing_checks,application_smoke,
  companion_checks: PASS0. 11,760 floor rays, safe full-party pads, water negative
  probes/edges/seams/gate/walk/dodge,94 bidirectional crossing lanes/four rail
  slides/27,780 motion samples. Compact companion/combat/save/recovery unchanged.
- audit_m011.py: PASS0; five focused exits, final landscape report, five snapshot
  hashes/layout/report,74 retained captures/36 clear views,32 tour movement batches
  plus one town movement batch; stationary camera/hero water motion crop; both
  normal process exits0/no save. Every response starts/ends paused/focused and
  play time matches previous after across inspection/helper gaps.
- Runtime/check logs: no SCRIPT ERROR,shader compilation or nav errors; known
  certificate-store diagnostic only. Final source/UID/diff/evidence review and
  git diff --check exit0. Nothing committed.

## Rendered observations

Fresh Compatibility/OpenGL3.3,960x640,RTX4070 Laptop/NVIDIA581.29; default overhead
orthographic camera zoom1.00. Ordinary WASD only; no position/health/quest mutation.
Tour: town->Moonwell->town,town->ford east,ford west,west-bank forest->bridge west,
bridge east,Tollworks approach,closed exit. Second fresh process supplies stationary
and moving town views. All36 clear views inspected through five contact sheets;
full town/Moonwell/ford/bridge/gate frames and pause checkpoints inspected separately.
Grass/cobbles/warm paths/sand/teal water/banks readable, party visible, no terrain
cracks, water over crossing decks or visual collision disagreement seen. Authored
brown risers deliberately retain cliff height edges; tree/building/gate grayboxes
are still expected until their individual art items.

Stationary river frames2.144253999998199s apart with identical camera/hero feet:
crop(600,175,800,195),mean RGB delta2.5729166666666665/255,max channel13/255.
Fragment color changes subtly, exact mesh outline fixed. Cosmetic flow during
pause does not affect simulation. Not an M018 frame-time/performance measurement.

Final tour hero(121.635177612305,0,-7.0754542350769),ally
(120.200263977051,0,-6.48665809631348),time78.0782083333386s;HP100/100,138 repaths,
zero catch-ups,two original wrappers,empty quest/effects. Both normal F10 exits0;
no game/helper left running. [Rendered index](../evidence/M011/rendered-index.json)
retains hashes, response references, observations and exact motion measurements.

## Repairs and remaining limits

Initial inline Python reference-sheet command failed shell quoting before source
reads; standalone script fixed it. First audit assumed nested observation fields,
failed KeyError; bridge uses flat step fields. Corrected audit passes, and movement
count now includes batches010/011. No game/visual failure or weakened acceptance.

M011 no blocker. M012 tree art next; M013 town art,M014 landmarks,M015 activation,
M016 aiming/canopies,M017 saves,M018 performance and M019 native release pending.
Source masks/heights/props/IDs/nav/approved docks/schema/normal save unchanged.
Parent P014 compact completion preserved. No full source-sprite recreation,
new tree/town/landmark kit, performance benchmark or packaged/native map claim.
