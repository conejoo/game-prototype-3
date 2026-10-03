# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M007 verified complete.

## Selection and next action

- Active item: none. Selected M007 completed this session.
- Next eligible: **M008 physical elevation and ramps only**. M008–M019 pending;
  no physical elevation, final navigation or subsequent item started.
- Candidate remains isolated/test-only; normal compact Alderwake unchanged until M015.
  Parent P001–P014 compact build complete; M019 must revalidate resulting map release.
- Acceptance and exact evidence: [M007 validation](../evidence/M007/VALIDATION.md).

## Preparation and authority

Target D:/development/game-dev-blender/returning-fair-prototype; Godot project game/.
Initial Git clean at HEAD 9584875ba195f9260978f355ec0ddbddab54583d (M006).
Read workspace AGENTS (no nested AGENTS), full map prompt, parent architecture/state,
migration investigation/checklist/state/contract, pinned layout/catalog/manifest/report,
M006 evidence, actual candidate/actor/camera/WorldHost/party and playtest bridge.
Marked M007 in progress before implementation. Caveman and Returning Fair gameplay
skills used. Exactly one item. No subagents, source writes/generators/snapshot refresh,
Blender, installation, commit, push, export or publication. Prior evidence preserved.

Snapshot alderwake-f4630f9-m002; source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs unchanged; runtime
reads target-local normalized layout only. [Current hashes](../evidence/M007/snapshot-hashes.json).

- Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f.
- Catalog SHA256 59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2.
- Layout SHA256 7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
- Report SHA256 66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.

## M007 implementation and changed files

- game/world/map_candidate/forest_population.gd plus UID: 412 original deferred
  props, including 395 trees and 17 other props. All 468 map props now have exactly
  one wrapper (56 town + 412 forest), with 455 enabled catalog collision bodies
  (44 town + 411 forest), and all 102 independent authored collider identities.
  Exact fractional X/Z, yaw/group provenance, source collision flags, tree metadata,
  original height/light/depth metadata and complete source records retained.
- Trees: alder70, birch37, cherry22, maple36, oak38, pine48, rowan36, spruce60,
  willow48. Sizes small65/standard266/large64. Diagnostic colored polygon prisms
  at heights0.9/1.4/1.8m use exact enabled trunk outlines; no reseeding, sprite
  blockers, source rendering behavior or final canopy/art claim.
- Moonwell eight-corner polygon remains exact at X31.51317596435547,
  Z4.621034622192383; preview Y0, source Y0.5 retained for M008. Disabled gate
  prop has replaceable art matching unchanged authored body; water_blockers.gd
  removes its duplicate preview mesh, keeping sole future-exit-gate collision.
- Six source markers and Tollworks entrance retain IDs/feet/provenance with inert
  labels, no collisions/interactions. Other85 routine/resource/NPC records remain
  data only. Seven portals inactive;25 zones/three activities retained data only.
  [Inventory and omitted-content disposition](../evidence/M007/inventory.json).
- prop_grayboxes.gd plus UID: extracted unchanged shared polygon/prism/wrapper/nav
  utilities from town_footprints.gd. Town/dock geometry and approved water cutouts
  unchanged; art still owns no physics. Terrain composes forest and reports limits.
  Existing0.2m nav-only outline margin also applies to forest and thin bridge rails.
  Tree detours exposed rail contour cuts; projected rail margin repairs them while
  physical source/rail outlines stay fixed. Final height/nav remains M008/M009.
- game/tests/map_forest_checks.gd plus UID: inventory/provenance/null flags, exact
  physical polygon vertices and interior/exterior queries, actual0.4m capsule
  path clearance at<=0.1m,16 bidirectional real hero capsule routes, party pads,
  sole gate walking/dodge negatives and beyond-gate obstruction.
- Updated existing town/water checks to wait for expected asynchronous nav region
  before queries. Candidate floor rays exclude forest blockers; old straight depth
  fixture now checks authentic tree stop, while M007 routes prove real approaches.
  Crossing checks explicitly account for pinned supply-cache overlap on northwest
  landing; do not start actors inside source collision.94 clear walk/dodge lanes
  plus four rail-slide runs remain, source center routes pass in both directions.
- Candidate root HUD, CANDIDATE, CONTRACT, CHECKLIST and this state updated.
  Evidence scripts/logs/inventory/routes/input JSON/raw responses/captures under
  docs/evidence/M007/. Parent architecture/state and normal production files unchanged.

## Exact checks and results

Both supplied engine executables exist;4.7.2.stable.mono.official.ed1daf0bf.
Commands run from target root. Process-local APPDATA/LOCALAPPDATA point to
builds/m007-user-data and builds/m007-local-data; normal save untouched.
Exact commands and logs in VALIDATION.md; accepted runtime logs have no SCRIPT
ERROR and only pre-existing certificate-store diagnostic. Import exit0 retains
known missing .NET SDK10.0.9 diagnostics; no diagnostic-free import claim.

- Bundled Python -B tools/map_migration/extract_layout.py --check: PASS/exit0.
- Godot --headless --editor --path game --import --quit: initial/final exit0.
- --headless --path game --script res://tests/map_forest_checks.gd: PASS0;
  64,178 polygon physics probes,16,728 path samples,16 physical routes,
  5,563 provisional nav polygons. Paths/lengths in physics-report.json.
- map_town_checks: PASS0;37,325 polygon queries,18,316 path samples,74 physical
  routes; all doors/Maris/quays/western docks and rotated/concave fixtures.
- map_water_checks: PASS0; original90 records/8,766 authored cells,8,598 effective
  cells/168 approved dock cuts; exposed edges/seams,water negatives,gate/nav.
- map_crossing_checks: PASS0;4,032 floor/clearance probes,94 clear walking/dodge
  lanes,4 rail slides,27,780 displacement samples. Named supply-cache overlap
  stays blocked; no movement-mask exception or third river crossing.
- map_candidate_checks: PASS0;11,760 base-floor rays,both party pads,reload/identity,
  candidate save isolation,bounds/full-width traversal and authored trunk stop.
- application_smoke: PASS0; normal compact startup/input/pause/resume.
- report_m007.py and final_review.py: PASS0; snapshot hashes,full dispositions,
  captured ordinary-input evidence,accepted-log/state/link/scope checks.
- git diff --check: exit0; intended diff reviewed, no unrelated files changed.

## Rendered evidence

Compatibility/OpenGL960x640,RTX4070 Laptop/NVIDIA581.29; ordinary viewport inputs
through opt-in bridge, no actor/session mutation or teleport. Retained driver
windowed/drive_route.py selects bounded WASD chords from measured path waypoints
and actual read-only observations. Every batch starts/ends confirmed paused;
wall time and input duration are not deterministic physics. Moving and pause
captures inspected. Raw responses/captures/index retained under M007/windowed/.

Run a: fresh town start -> Moonwell approach(31.53853,0.00094,5.63327), return
(-0.02962,0.00094,0.04154), ordinary route through dense forest -> ford east
(74.90612,0.00094,12.49661), cross back west(65.97948,0.00094,12.51687).
Hero/ally visible,clear sand/dry approach,water remains distinct. Timer0->44.919s.
Run b: fresh --candidate-return pad(107.25,0,1.25), walk bridge east->west
(92.93686,0.00094,-0.45661), west->east->Tollworks approach
(107.29085,0.00094,-1.25632), E inert, walk closed-exit approach
(121.50024,0.00094,-7.02414), walk+Space dodge+E contact future-exit-gate,
stopX122.64906,Z-5.68997. Timer0->14.941s. Gate reads closed; no prompt/transition.
Both preserve empty quest/effects and two party wrappers; no catch-up needed in
these rendered routes (not M010 recovery proof). Both normal F10 quits exit0.
No Save/Load or save-slot write. Named slot playtest-m007-forest.json isolated.

## Failed attempts and remaining limits

Retained initial/second/nav diagnostic logs: null Node metadata is omitted by
Godot (full source record now retained), authored collider identity lives on town
wrapper rather than body (inventory now scans correct owners), asynchronous map
iteration initially empty (checks now wait for expected region). Invalid reverse
gate fixture started inside body; removed, west walk/dodge plus beyond-gate query
used instead. Gate reaches eastern perimeter; no safe east-side start exists.
Third forest run exposed thin bridge rail path cuts; nav-only margin repaired.
Initial prior-check logs retained: stale nav queries,old straight depth fixture
now encountering source tree,and old landing lanes overlapping pinned supply
cache. All final runs pass after focused repairs; no failure counted as acceptance.

No M007 blocker remains. Heights/cliffs/ramps M008,complete physical nav/loading
M009,connected ally catch-up/recovery M010,final art M011–M014,normal activation
M015,camera M016,save/performance/native map-build release M017–M019 remain.
Parent P014 compact completion preserved. No new export/full quest/performance gate.

Select M008 only. Build472 authored elevation cells/16 slopes with0.25m levels;
keep exact prop X/Z,place wrappers on real surfaces,implement cliffs/grounding,
validate both party pads,all crossings/Maris approaches and seven approved dock
surfaces. Preserve exact footprints,sole gate,snapshot,schema4/content1,existing
ownership and isolated saves. Reuse M007 inventory/routes as evidence targets;
do not silently refresh snapshot or widen movement masks.

Final review initially rejected Windows CP1252/newline output; new handoff files
normalized to UTF-8/LF. Failed encoding/newline review logs retained; final review
passes after repair. No game behavior or source snapshot change.
