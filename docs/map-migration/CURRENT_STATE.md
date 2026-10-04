# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M013 verified complete.

## Selection and next action

- Active item: none. M013 reusable town exterior art kit complete; no blocker.
- Next eligible: M014 bridge Moonwell and gate appearance only. Inspect live
  Blender/user scenes; preserve current art sources. Replace landmark graybox
  art under independent VisualRoots, without changing rails/deck/collision/nav,
  exact fractional Moonwell foot or closed-east-gate physics/IDs. Save sources
  under art/source and GLB under game/assets. Compare reference/gameplay views.
  Do not activate candidate or start M015.
- Acceptance: [M013 validation](../evidence/M013/VALIDATION.md).
- Candidate isolated until M015; normal compact Alderwake unchanged. Parent
  P001–P014 compact build complete; M019 owns resulting native map gate.

## Preparation and authority

Read workspace AGENTS (no nested), full migration prompt, parent architecture/state,
migration investigation/checklist/state/contract, pinned layout/catalog/manifest/
report and M012 evidence/artifacts; actual town/props/dock/terrain/tree/root/tests.
Initial Git clean; M013 marked in progress before edits. Exactly one item. Caveman,
Returning Fair gameplay-testing and Blender orchestration/harmonizer/modeling/
materials/export/workflow skills used. No subagents, source writes/generators/
refresh, installation, commit, push or publication. Historical M/P014 evidence
preserved. Candidate presentation only; no ownership or contract change.

Snapshot alderwake-f4630f9-m002; source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs/layout/report unchanged.
[Exact hashes](../evidence/M013/audit-report.json).
Map af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
Schema4/content1 and all production location/spawn/actor/quest/effect IDs unchanged.

## Implementation and changed files

- tools/map_migration/build_town_kit.py: isolated live-Blender authoring with
  reusable wall/beam/window/door/shingle constructors, exact catalog box/skew
  polygon bases; portable vertex-color matte palette. Populated kit refuses rerun.
- art/source/alderwake_town_kit.blend: standalone editable one-scene gallery,
  14 building variants/two deck modules/camera/two lights. Source reference16
  sprites/hashes inspected; zero source/runtime image reuse or external textures.
- game/assets/environment/alderwake_town_kit.glb/.import and mapping JSON:
  one scene/16 meshes,6,110 triangles,490,396bytes,self-contained.
- town_art.gd/UID:24 original source structure wrappers use imported mesh resources.
  Exact original feet/yaw/IDs/collision flags preserved. Only VisualRoot children
  replaced; physical bodies/navigation remain existing owners.50 plank modules
  cover seven approved48m2 floor rectangles;165 quay cells use stone modules.
  Godot material transfer explicitly enables imported COLOR_0. Repeated resources
  shared; no roof/sprite blocker, new floor, route, interior or interaction.
- terrain_preview.gd: candidate art owner/errors/report; map_candidate_root.gd:
  M013 labels; production compact catalog unchanged.
- map_town_art_checks.gd/UID:imports/materials/base outlines/height/IDs/transforms/
  module coverage/art-physics audit,read-only guide for rendered ordinary inputs.
- CANDIDATE/CHECKLIST/this state; docs/evidence/M013/validation,reference/gallery,
  independent GLB/catalog/hash/timer/health/save audit,art/guide reports,two contact
  sheets,36 PNGs,486 requests/raw responses,driver/route/helpers,accepted logs.

## Exact checks and results

Full commands/acceptance matrix in VALIDATION.md. Supplied Godot paths verified;
4.7.2.stable.mono.official.ed1daf0bf. Blender5.2.2 LTS/addon1.7 verified. Process-local
APPDATA/LOCALAPPDATA isolate builds/m013-check-user/local-data and m013-user/
local-data. Candidate named playtest-m013-town-a.json absent; normal save untouched.

- Pinned extractor --check PASS/exit0; audit verifies all five input hashes plus
  current layout/report/source/GLB/mapping hashes.
- Live Blender build/export success; background gallery render/finalize exit0.
  Gallery/live viewport inspected. Original user scenes preserved and active
  RF-RecoveryVessel21 restored,empty user file path/dirty work retained. Independent
  pre-work backup builds/m013/preserved-live-work.blend. Source file is standalone.
- Initial/final imports exit0; known missing .NET SDK10.0.9/certificate diagnostics
  retained. No new script/shader/asset errors in accepted logs.
- map_town_art_checks PASS0:24 original structures/16 meshes/6,110 triangles,
  168 exact imported base-corner samples,correct up-axis/height/palette/transforms,
  source feet/yaw within0.001m,art bounds within0.02m of footprint,zero art physics,
  no duplicate grayboxes,48m2 exact dock coverage/165 quay cells.
- map_town_checks,map_candidate_checks,map_water_checks,application_smoke,
  companion_checks PASS0.37,325 physical polygon queries/74 bidirectional town
  routes/18,325 <=0.1m path samples;rotated/grouped fixtures,doors,Maris/fitting,
  docks/quays,full-party pads;8,598 effective water cells/4,027 edge sweeps/four
  negatives and walking/dodge/seams/floor/bounds/gate. Physics scripts unchanged.
- Fresh ordinary WASD tour:17 clear inspected views/36 PNGs/486 retained requests;
  every pulse begins/ends paused/focused,timer equality across gaps;HP100/100,
  zero catch-ups,two party wrappers,empty effects,no save written;normal F10 exit0.
- audit_m013.py PASS0,collect_views.py exit0;final intended-file review/git diff
  --check exit0. Game/helper processes stopped. No rejected acceptance hidden.

## Appearance and rendered evidence

Deliberate adaptation:timber/plaster gabled fronts,slate/terracotta tile roofs,
teal dockside/shed walls,green woodland cottage,civic/inn/mayor taller fronts and
striped shops. Exact shallow catalog footprints determine 3D depth rather than
large sprite rectangles. Heights1.76–3.41m compressed for overhead camera; facade
wall overlays <=0.015m,roofs remain over original physical footprint. Colored
inset tiles add portable surface detail,no procedural texture dependency.
Approved M006 straight bars/T junction/landings get wood planks atY0.022;
physical floors remainY0,48m2 movement mask unchanged. Quay1m cells remain exact.
Other decorations/ship/service reservation/inactive destination pads stay honest
existing grayboxes. No authored building/collision/interaction/source-ID adaptation.

Fresh960×640 Compatibility/OpenGL3.3,RTX4070 Laptop/NVIDIA581.29,orthographic
zoom1.00. Ordinary WASD town start->Maris reservation->all three docks out-and-back
->Mill Road schoolhouse->inn->hall->Alder Rise->mayor->General Goods->woodland
cottage->control shelter->west/east passenger quays.17 clear views inspected in two
sheets;full Maris/west-dock/quay frames separately. Buildings/district palettes,
hero/ally and inactive labels readable;no missing textures,wet deck or visual
collision disagreement seen. Actual Maris service remains M015. Guidance is
read-only nav data,never teleport/actor/health/quest mutation. Nominal guide back
approaches may snap to nearby valid nav; exact observed endpoints retained.
Final hero(44.4059181213379,0,26.9354648590088),ally
(44.0049438476563,0,25.4343166351318),time149.419661249106s,146 repaths,zero
catch-ups,HP100/100. Normal quit0. [Views/hash/timer index](../evidence/M013/audit-report.json).

## Remaining limits

M013 no blocker. M014 landmarks,M015 activation,M016 camera/ground aim/roof-canopy
occlusion,M017 save compatibility,M018 performance,M019 native packaged release
pending.215 deck mesh instances share resources;M018 still measures full frame/
draw/memory/loading budgets. No performance certification or full native quest
journey here. Known SDK/certificate diagnostics remain. Initial unsuffixed gallery
image lookup failed;actual Blender frame-suffixed PNG inspected. Source/candidate
physics/nav/save/production scope and parent P014 compact completion preserved.

Final review repaired locale-decoded checklist punctuation from clean HEAD, keeping
only intended M013 updates; new helper reads explicit UTF-8. Final audit/diff check0.
