# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M014 verified complete.

## Selection and next action

- Active item: none. M014 bridge Moonwell and gate appearance complete; no blocker.
- Next eligible: M015 activate larger town and existing quest route only. Select
  candidate as prototype-alderwake,retain production spawn IDs,move existing
  Maris/service to mapped Chandlery pad,connect forest Tollworks gate/return pad.
  Preserve interaction/quest/guardian/vessel/trust/upgrade IDs and once-only rules;
  all six other source portals stay inactive. Replace stale compact-room hints.
  Validate fresh ordinary lead->walk with ally->Tollworks fight/vessel->return
  fitting route,correct prompts/service and no duplicate party/interactions.
  Do not start M016 or claim M019 native map gate.
- Acceptance: [M014 validation](../evidence/M014/VALIDATION.md).
- Candidate isolated through this completion; normal compact Alderwake unchanged.
  Parent P001–P014 compact build complete; M019 owns resulting native map gate.

## Preparation and authority

Read workspace AGENTS(no nested),full migration prompt,parent architecture/state,
migration investigation/checklist/state/contract,pinned layout/catalog/manifest/
report,M013 evidence and actual artifacts/Git. Initial Git clean; M014 marked in
progress before edits. Exactly one item. Caveman,Returning Fair gameplay-testing,
Blender orchestration/harmonizer/modeling/materials/export/workflow skills used;
Computer Use only selected/focused actual Godot window. No subagents/source writes/
generators/refresh/install/commit/push/publication. All historical M/P014 evidence
preserved; tests restored prior M009 reports byte-exactly. Appearance only;
CONTRACT/parent ARCHITECTURE ownership unchanged.

Snapshot alderwake-f4630f9-m002;source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs/layout/report unchanged.
[Exact baseline/current hashes](../evidence/M014/audit-report.json).
Map af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
Schema4/content1/all production location/spawn/actor/quest/effect IDs fixed.

## Implementation and changed files

- tools/map_migration/build_landmark_kit.py/export_landmark_kit.py: isolated
  live-Blender authoring/export,refuse populated rerun,preserve user scenes.
- art/source/alderwake_landmark_kit.blend: standalone editable scene,five meshes,
  camera/two lights. Independent pre-work builds/m014/preserved-live-work.blend.
- game/assets/environment/alderwake_landmark_kit.glb/.import and mapping JSON:
  five reusable meshes,4,276 triangles,337,120bytes,self-contained vertex colors.
- landmark_art.gd/UID:seven imported instances beneath three existing VisualRoots,
  exact bridge floors/rails,Moonwell local foot,gate collider-bound registration;
  closed-trail label. No physics/navigation/interaction nodes or new authority.
- terrain_preview.gd:appearance owner/errors/report;map_candidate_root.gd:M014
  labels;production compact catalog untouched.
- map_landmark_art_checks.gd/UID:independent axes/bounds/feet/outline/material audit,
  live art replacement physical/node/shape/navigation invariants,read-only tour.
- CANDIDATE/CHECKLIST/this state;docs/evidence/M014/:validation,source reference/
  baseline+current hashes,Blender preservation/gallery,focused logs/reports,
  exact commands/exits,input traces/19PNGs/eight-view sheet,audit/tour helpers.

## Exact checks and results

Full commands/matrix in VALIDATION.md;seven focused scripts/args/exits recorded
in check-results.json. Godot4.7.2.stable.mono.official.ed1daf0bf/Blender5.2.2 LTS;
supplied engine paths verified. Process-local APPDATA/LOCALAPPDATA isolate
builds/m014-check-user/local-data and m014-user/local-data. Named candidate save
playtest-m014-landmarks-a.json absent;normal save untouched.

- Pinned extractor --check PASS0;independent audit verifies all baseline hashes,
  source GLB portability/materials/exact Moonwell polygon/current art hashes.
- Live Blender build/refine/export success;initial/final background gallery render
  and standalone finalize exit0. Original user scenes/counts/file path/dirty work
  and active vessel restored;only M014 scene8 added. Gallery/live viewport inspected.
- Initial/final Godot import exit0;known missing .NET SDK10.0.9 diagnostic retained.
  No new script/shader/asset errors;runtime ERROR/SCRIPT ERROR scan0.
- map_landmark_art_checks PASS0:three IDs/five meshes/seven instances,8,536 vertex
  samples,exact rail/deck/landing/well/gate registration,portable palette;replacement
  retains all816 physical node/shape identities/layers/transforms and same nav
  resource/vertex hash3458812425/6,336 polygons. No art physics/interaction.
- map_crossing_checks PASS0:94 bidirectional walk/dodge lanes,four rail slides,
  4,032 clearance-floor probes/27,780 samples,both crossings/no new water route.
- map_forest_checks PASS0:468 props/455 catalog footprints/102 authored collider
  IDs,64,178 polygon probes/18,369 path samples/16 physical approach routes.
- map_navigation_checks PASS0:336,373 radius0.4m samples,three rollback rejections/
  four round trips,cold generation/bake918.022ms,warm max1898.076ms,query p951515us.
- map_candidate_checks/application_smoke/companion_checks PASS0;normal compact
  game and existing lifecycle/service/party ownership preserved.
- Fresh ordinary WASD town->ramps->Moonwell->bridge both ways->gate approach;
  walking450ms/dodge300ms hit sole future-exit-gate,hero remainsX122.64905548.
  426 requests retained/425 accepted/one rejected focus loss;19 PNGs/eight clear
  inspected views. Paused timer equality/HP100/100/zero catch-ups/two party wrappers/
  empty effects/no saves verified. Normal F10 quit exit0;game/helper processes stopped.
- audit_m014.py PASS0,collect_views.py exit0,final intended review/git diff --check0.

## Appearance, repairs and remaining limits

Source reference20 images:Moonwell,blocked gate,18 bridge tiles/hashes inspected,
zero source image runtime reuse. Full3m usable deck adapts source's one deck-art
row;exact thin edge rails0.1m up0.6 preserve2.8m clear width. Plank topY0.022,
bolt tips0.027,physical floorY0. Stone well uses exact eight-corner base,local0.6m
rim/static blue spiral,unchanged fractional footY0.5. Gate1.48m timber boards/braces
follow authored2x8m blocker rather than disabled catalog sprite;sole physical
body/height/IDs fixed. No extra shoreline dressing required. Full960x640 views
show readable landmark/actor approaches,no wet deck/cracks/missing texture or
visual collision disagreement. General canopy/roof/contact occlusion remains M016.

Initial exact float-width test failed;is_equal_approx fixed assertion only.
Forest audit caught visual source_collider_id metadata;renamed art reference,
sole body unchanged. Failed logs/reports retained. First tour stopped on focus
loss safely paused;actual returned window reactivated,fresh pause/focus captured,
ordinary tour resumed. Rejected request excluded from acceptance. Computer Use
state capture GetCursorPos denied0x80070005;existing bridge provided captures.
Shell brace-expansion parser failure and parent-root/escalated Git failures excluded;
corrected explicit filenames/target-root review0. No hidden acceptance failures.

M014 no blocker. M015 activation,M016 camera/aim/occlusion,M017 save compatibility,
M018 frame/draw/memory budgets,M019 native packaged map walkthrough pending.
Focused nav timing is regression evidence,not full performance certification.
Parent P014 compact completion preserved;no exported map/native quest claim.
