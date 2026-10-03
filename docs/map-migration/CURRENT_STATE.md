# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M006 verified complete.

## Selection and next action

- Active item: none. Selected M006 completed this session.
- Completed: M001 contract, M002 extraction, M003 terrain, M004 water/gate,
  M005 crossings, M006 town building and dock footprints.
- Next eligible: M007 forest population and landmark grayboxes only.
  M007–M019 pending; no M007 work started.
- Candidate remains alternate/test-only. Normal Alderwake compact until M015.
  Parent P001–P014 compact build complete; M019 must verify resulting map release.
- Acceptance/commands/evidence: [M006 validation](../evidence/M006/VALIDATION.md).

## Preparation and authority

Target D:/development/game-dev-blender/returning-fair-prototype; Godot project game/.
Initial Git clean at HEAD 03338a0de4f3b1deb33259b08ece474001ff0004 (M005).
Read workspace AGENTS (no nested target AGENTS), full map prompt, architecture,
parent state, investigation/checklist/handoff/contract, pinned layout/manifest/
report/catalog/art rows, M005 evidence and current candidate/actor/camera/party/
WorldHost boundaries. Marked M006 in progress before implementation. Caveman and
Returning Fair gameplay-testing skills used. Exactly one migration item.
No source writes/generators/refresh, dependencies, subagents, Blender, commits,
push, export or publication; previous P014/M001–M005 evidence preserved.

Snapshot alderwake-f4630f9-m002, source commit
f4630f9966d6637ef6579cd87623ea354758191c; five byte-exact inputs unchanged.
Runtime reads target-local layout only. Extractor --check PASS/exit0.

- Map SHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f.
- Catalog SHA256 59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2.
- Layout SHA256 7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
- Report SHA256 66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
- [Current hashes](../evidence/M006/snapshot-hashes.json); retained 468 props/455
  enabled footprints, 102 explicit colliders, 31 groups, 8 art layers, 4 tile
  layers, 7 portals, 472 elevations/16 slopes, 25 zones, 3 activities, 91 inert
  objects. Target cutout policy does not change normalized source data.

## M006 implementation and changed files

- game/world/map_candidate/town_footprints.gd plus UID: selects 56 non-tree props
  with foot X<25 or passenger-* ID. Includes 44 enabled catalog footprints and
  12 nonblocking/disabled records, plus all 11 remaining non-water/gate authored
  colliders. Exact feet/yaw/source metadata; no sprite blocker. Triangle prisms
  preserve polygon outlines, including concave fixture. Independent VisualRoot;
  structure rims 1m, other blockers 0.6m in flat stage. Explicit collider node
  names use collider-- prefix because prop/collider namespaces can share IDs.
- Three western dock wrappers retain source feet and IDs. Seven deck/landing
  floor surfaces, physical topY0/visualY0.022, use target-authored dock_surfaces.gd
  plus UID. 165 art-only passenger quay cells; disabled shelter stays a foot
  marker and original baffles own collision. No new ship/net/fishing behavior.
- Six inert portal pads show inactive/no-interior labels, no Interactable or
  destination. Three diagnostic Maris/fitting foot markers reserve original
  (-7.5,0,11),(-6,0,11.5),(-4.5,0,11.5); no duplicate NPC/service/counter.
- terrain_preview.gd composes town and dock masks. water_blockers.gd preserves
  90 source water records, original bounds and 8,766-cell authored union; effective
  occupancy subtracts the approved dock exception below. Split collision shapes
  stay under original water IDs. Visual/nav water use effective union.
- Provisional nav projects exact town footprints with extra0.2m margin, also
  effective southern water pieces. Existing radius0.4m,height1.6m,climb0.1m,
  cell0.2m/height0.1m/contour0.1 retained. Measured fractional Recast corner cuts
  repaired; final nav/recovery M009/M010. No actor/service/save/AI changes.
- game/tests/map_town_checks.gd plus UID: inventories, exact physical vertices,
  37,325 interior/exterior queries, four hand-calculated quarter-turn fixtures,
  concave-notch fixture, actual0.4m capsule/nav paths and hero walking at 37
  approaches in both directions; 18,036 path samples at<=0.1m, 74 physical routes.
  All six door pads, all grouped buildings, Maris pads, three dock decks and
  passenger quays/control approach pass. Three southern building approaches
  explicitly use clear sides where south fronts abut shoreline; no fake doors.
- map_water_checks.gd verifies unchanged bounds outside masks, exact remaining
  pieces and original/effective cell accounting. map_crossing_checks.gd now
  distinguishes authored union from approved southern dock exception. Candidate
  floor checks exclude independent town blocker bodies while testing base floor.
- map_candidate_root.gd honest M006 HUD; detached catalog/save, existing services,
  session/party/controls/camera preserved. CANDIDATE, CONTRACT, CHECKLIST and this
  state updated. Parent architecture/state unchanged; P014 accurately complete
  for compact build only. Evidence/report/inventory under docs/evidence/M006/.

## Deliberate dock reconciliation

Pinned western dock sprite bounds are completely inside authored southern water.
Read-only source docs/map-editor.md and visual-assets.md call them walkable;
source collision test proves only collision:none in a fixture with no explicit
water. Shipping data wins; source was not regenerated/refreshed.
User explicitly answered: "Add documented walkable dock cutouts; preserve
surrounding water." Decision, original overlaps, exact masks and affected IDs:
[dock reconciliation](../evidence/M006/dock-reconciliation.json).

Seven named deck/landing rectangles cover48m2: 42m2/168 half-metre cells previously
water plus6m2 already dry. Only south-water-01 through07 change effective shapes;
8,598 water cells remain. Original records/union, all Moonwood water, bridge/ford,
basin and closed gate unchanged. Straight5x2m bars/T junction reflect inspected
source art with safe landings; no sprite rectangles become blockers. No swimming,
ferry or third Moonwood crossing. CONTRACT records measured adaptation and
requires M008/M009/M010/M013 revalidation without silently moving/changing masks.

## Verification and rendered evidence

Both installed Godot paths exist;4.7.2.stable.mono.official.ed1daf0bf.
Exact commands/exits in M006 VALIDATION; accepted final logs have no SCRIPT ERROR
and only known certificate-store diagnostic. Import exit0 also retains pre-existing
missing .NET SDK10.0.9; not claimed diagnostic-free.

- extract_layout.py --check and report_m006.py: PASS0; five pinned hashes unchanged.
- Import initial and final: exit0; generated script UIDs retained.
- map_town_checks-final.log: PASS0, counts above, all criteria verified.
- map_water_checks-final.log: PASS0;91 water/gate wrappers,8,598 effective cell
  probes,168 approved dry cells,4,124 exposed-edge sweeps,22 actual walk/dodge
  negatives.1,193 provisional nav polygons; minimum water-center nav distance0.45m.
- map_crossing_checks-final.log: PASS0;4,032 clearance/floor probes,104 walking/
  dodge lanes,4 rail-slide runs,30,728 displacement samples. Moonwood unchanged.
- map_candidate_checks-final.log: PASS0;11,760 base-floor rays, both-party
  start/return pads, reload identity/save isolation/full-footprint bounds/movement.
- application_smoke.log: PASS0; normal compact composition/input/pause/resume.
- Rendered Compatibility/OpenGL960x640, RTX4070 Laptop/NVIDIA581.29. Fresh
  candidate start(0,0,0),paused0s. Ordinary WASD/E Hall, Market Lane, Mayor pad,
  Starter Home pad, Mill Road/Lantern Rest, Maris/fitting approach. E inert,
  effects/quest unchanged, no new AI/interiors. Maris feet(-7.82627,0.00094,10.75366),
  player-side(-6.17730,0.00094,10.72368), customer-side(-4.90310,0.00094,11.42824).
- Ordinary walk east dock(-6.88050,0.00094,17.70958),junction tip
  (-13.02728,0.00094,19.38622),west dock(-17.38750,0.00094,18.64906),then return
  east(-7.85719,0.00094,18.54306). Nearby water walk/Space contact south-water-02
  stopsZ18.64906; no deck cracks/water overlap, hero/ally visible. Headless paths
  cover shore landings/quays both ways; rendered ally follow is not M010 recovery.
- All accepted batches start/end confirmed paused; moving and pause PNGs inspected.
  Timers0/5/18/23/30/31/35s; wall time between calls not deterministic physics.
  Seven accepted observation/input batches plus normal F10 quit; raw responses
  and26 captures retained under windowed/. One33-step request rejected before
  input; shortened31-step request succeeded, both retained.
- APPDATA/LOCALAPPDATA process-local under builds/m006-user-data and
  builds/m006-local-data; slot playtest-m006-town. No Save/Load, save file writes,
  teleport, health/quest mutation. Normal user save untouched. Retained launch
  process handle normal exit0; no new game/helper remains.
- final_review.py and git diff --check: PASS/exit0, scope/hashes/logs/capture copies/
  local links/whitespace/state and source exception accounting.

Failed/unaccepted evidence retained: initial prop/collider node-ID ambiguity;
synthetic movement fixture lacked combat-enabled guard (interrupted,exit1);
nav contours cut corners; initial dock neck disconnected; typed empty ternary
arrays aborted water build (misleading PASS logs explicitly rejected; interrupted
water checks exit1); final accepted runs follow fixes. Process CIM inventory
read denied; ordinary Get-Process confirmed owned game exit. No approval-review
rejection. No failed check counted as acceptance.

## Limits and safe next action

No M006 blocker remains. Physical heights/cliffs remain M008; complete nav/load
and connected ally catch-up remain M009/M010. Final landscape/tree/town/landmark
art M011–M014, production activation/quest walkthrough M015, camera M016,
save/performance/native resulting-map release M017–M019 pending. Parent P014
compact completion preserved; no new native export/full quest/performance claim.

Select M007 only: inspect pinned deferred tree/forest/landmark inventory and
current town/water/dock exception. Instantiate original IDs/species/size/trunk
footprints, fractional Moonwell and retained trail/entrance markers; keep routine/
resource records inert. Avoid duplicate future-exit body already owned by water.
Recheck both crossings, Moonwell/Tollworks/closed-exit approaches and both-party
pads. Preserve deliberate western dock masks and source snapshot. Do not start
physical heights/final nav/art/normal activation or overwrite normal save.
