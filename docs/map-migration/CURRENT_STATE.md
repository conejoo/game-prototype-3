# Current map migration state

Updated 2026-10-03, America/Vancouver. M001–M012 verified complete.

## Selection and next action

- Active item: none. M012 reusable tree art kit complete; no blocker.
- Next eligible: M013 reusable town exterior art kit only. Preserve pinned
  structure footprints/IDs, Maris/fitting reservations and approved M006 dock
  floors/cutouts. Inspect live Blender and preserve user scenes. Save new sources
  under art/source and GLB under game/assets; verify imports, district appearance
  and door/service clearance in actual gameplay. Do not start M014.
- Acceptance: [M012 validation](../evidence/M012/VALIDATION.md).
- Candidate isolated until M015; normal compact Alderwake unchanged. Parent
  P001–P014 compact build complete; M019 still owns resulting native map gate.

## Preparation and authority

Read workspace AGENTS (no nested), full migration prompt, parent architecture/state,
migration investigation/checklist/state/contract, pinned layout/catalog/provenance,
M011 evidence and actual forest/graybox/terrain/root/navigation/bridge/tests.
Initial Git clean at dc3f1cb760934dc021f216d089d9d8184e920e9b; HEAD unchanged.
M012 marked in progress before work, resumed after user enabled workspace writes.
Exactly one item. Caveman, Returning Fair gameplay-testing and applicable Blender
orchestration/harmonizer/modeling/materials/export/workflow skills used. No
subagents, source writes/generators/refresh, installation, commit, push or publication.
Historical M/P014 evidence preserved. No production ownership or contract change.

Snapshot alderwake-f4630f9-m002; source commit
f4630f9966d6637ef6579cd87623ea354758191c. Five pinned inputs/layout/report unchanged.
[Hashes](../evidence/M012/snapshot-asset-hashes.json).
Map af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be;
report66b17789874f382f9e3c3ba6f95927dca8c90d24e2328bdabb6771480360b0e9.
Schema4/content1 and production location/spawn/actor/quest/effect IDs unchanged.

## Implementation and changed files

- tools/map_migration/build_tree_kit.py: isolated live-Blender authored branched,
  lobed/tiered/drooping meshes, deterministic palette and editable gallery.
  Preserved existing scenes/backup; populated kit refuses accidental rerun.
- art/source/moonwood_tree_kit.blend: ordinary editable source with21 variants,
  gallery camera/two lights, portable matte vertex-color PBR; only kit scene.
- game/assets/environment/moonwood_tree_kit.glb/.import and mapping JSON:
  nine species/21 actual definition IDs/all three sizes; single-scene21-mesh,
  28,298 triangles,2,077,816bytes,zero external textures/buffers.
- tree_art.gd/UID:395 original feet/yaws in106 definition/spatial32m batches.
  Transfer imported active materials to local mesh resources; enable COLOR_0.
  Wrapper/VisualRoot metadata links batch/index/mesh to source ID. Remove only
  old tree visual children; wrappers/sibling source collision bodies remain.
- terrain_preview.gd: candidate tree-art owner/errors/report composition.
  map_candidate_root.gd: M012 labels; normal catalog/room unchanged.
- map_tree_art_checks.gd/UID: actual GPU transforms,unique indexes,imported
  colors/materials/up-axis/heights,bole-base registration,source records,
  absent art physics/duplicate graybox art. Requires Compatibility renderer;
  dummy headless RenderingServer returns identity MultiMesh transforms.
- CANDIDATE.md,CHECKLIST,this state; docs/evidence/M012/validation,accepted/failed
  logs,tree/navigation reports,source/gallery/hash sheets,audit/index scripts,
  two contact sheets,48 PNGs,ordinary-input requests/responses,route/runtime/exit.

## Exact checks and results

Full commands/acceptance matrix in VALIDATION.md. Godot console/editor paths
verified;4.7.2.stable.mono.official.ed1daf0bf. Blender5.2.2 LTS/addon1.7 verified.
Process-local APPDATA/LOCALAPPDATA isolate builds/m012-check-user/local-data and
m012-user/local-data. Fresh playtest-m012-tree-a.json absent; normal save untouched.

- reference_art.py and pinned extractor --check: PASS/exit0; nine read-only
  source sprite references/hashes,zero runtime source image copies/dependencies.
- Live Blender MCP build/re-export success; background gallery render and
  finalize_blend.py exit0. Gallery/live viewport and scene inventories inspected.
  User active vessel restored,original scenes preserved. No live reload/save over
  user file; path remained empty/dirty. Backup builds/m012/preserved-live-work.blend.
- Initial/final imports exit0; known missing .NET SDK10.0.9/certificate diagnostics.
  Zero new asset/script/shader/nav errors in accepted logs; no clean-import claim.
- Actual Compatibility map_tree_art_checks PASS0:395 instances/21 variants/106
  batches/28,298 triangles;feet/yaw within0.001m,heights within0.005m of mapping,
  bole-base bounds within0.10m of pinned physical boxes; art owns no physics.
- map_candidate_checks,map_crossing_checks,map_navigation_checks,application_smoke,
  companion_checks PASS0.11,760 floor rays/safe party pads;94 crossing walk/dodge
  lanes/four rail slides/27,780 movement samples;336,373 nav capsule samples/
  required routes/water/gate negatives/lifecycle/rollback. Physics scripts unchanged.
  Existing nav test writes M009 report; result copied to M012 and historical M009
  bytes restored from initially clean HEAD. Mesh6,336 polygons/6,151 vertices.
- audit_m012.py PASS0:tree-only21-node self-contained GLB,exact retained definition
  set,accepted exits,23 clear captures/25 paused/focused requests,all hashes,
  before/previous-after timer equality,HP100/100,zero catch-ups,save absent,
  normal F10 exit0. Final git diff --check/source/UID/evidence review exit0.

Fresh nav regression observations:generation/bake864.895ms,query-p95980us,
exterior commits1,218.037–1,390.261ms. Not M018 certification; frame/draw-call/
memory/native packaged map measurements remain pending.

## Appearance and rendered evidence

Deliberate adaptation:alder green lobes,birch pale bark/narrow light crown,cherry
pink blossom clusters,maple amber,oak broad olive,pine four dark tiers,rowan red
berries,spruce five narrow dark tiers,willow yellow-green curtains. Six species
have small/standard/large source definitions; alder,rowan,spruce standard only.
Do not invent27 source definitions. Nominal crown2.55/3.15/3.70m policies with
measured2.5–4.3m bounds deliberately compress source6m screen height for existing
18m overhead camera. Bole roots follow catalog boxes at original bottom-centre
feet/north offset; exporter converts Blender Z-up/-Y south to Godot Y-up/+Z south.
Physical prism heights/polygons/flags,elevation,crossings,water,nav/IDs unchanged.

Fresh960×640 Compatibility/OpenGL3.3,RTX4070 Laptop/NVIDIA581.29,orthographic
zoom1.00. Ordinary WASD:town->dense north/west-bank forest->ford east->ford west->
dense west-bank forest->bridge west->bridge east->bridge west. All23 clear views
inspected through two sheets;dense ford/bridge full frames separately. Species/
canopy forms readable;hero/ally visible,no cracks/wet decks/missing grass or
trunk registration disagreement seen. No teleport/session/health/quest mutation.
Every movement batch starts/ends paused/focused. Final hero
(92.9644470214844,0,-0.512378871440887),ally
(94.5116424560547,0,-0.383173048496246),time50.1927379697056s,93 repaths,zero
catch-ups,HP100/100,two original wrappers,empty quest/effects. Normal F10 exit0;
game/helper stopped. [Rendered index](../evidence/M012/rendered-index.json).

## Repairs and remaining limits

Initial nonexistent catalog variant StopIteration,cross-scene GLB selection,
dummy renderer transform readback,disabled imported vertex colors repaired;
failed logs/observations retained in validation. No tolerance weakening,user
object deletion/movement or source refresh. Isolated library source converted to
ordinary main .blend. Live RF-RecoveryVessel21 active again;other scenes preserved.

M012 no blocker. M013 town art,M014 landmarks,M015 activation,M016 camera/aim/
canopy occlusion,M017 saves,M018 performance,M019 native release pending. Candidate
art only; normal compact game/P014 completion and normal save remain accurate.
