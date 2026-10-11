# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts each one-task invocation.

## Current selection

AD003 Done; no active task. Every criterion verified in [AD003_ACCEPTANCE](AD003_ACCEPTANCE.md). AD001/AD002 remain Done. Remaining unfinished IDs: AD004, AD005, AD006, AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist ID AD020; every item complete: no. No blocker or required decision remains.

Implementation stopped for review; user then supplied the separate successful-task commit instruction. Commit scope is exactly19 AD003 task paths, including acceptance/checklist/handoff; unrelated direction/interiors/prompt/contract inputs and ignored raw evidence remain excluded. Accepted source bytes and preservation scope verified; exact verified commit identity/tree/path/blob scope and final status recorded after commit in `docs/evidence/AD003/authorized-commit-20261011/commit-audit.json`. No push or AD004 work. Starting HEAD `9ef780588df72cdeda5bddf9974c2b5646b26910` is historical context, not a checkout target. AD001/AD002 prior authorized commit records remain in their acceptance documents/local audits.

Next eligible task: AD004 only. Exact next action after review workflow: inspect accepted town/tree atlas recipes, existing landscape_materials.gd/landscape.gdshader, semantic mask/elevation and fixed baseline views; paint meadow/dirt/elevation within AD004 bounds. Do not start AD004 here. No water/town rollout/lighting/HUD/room expansion or historical R016 work.

## Completed tree pilot and preservation

Oak family only, existing small/standard/large meshes. One1024 RGB sRGB foliage/bark atlas; white factor and disabled painted vertex tint. Other18 variants retain original COLOR palette. Shared shader samples optional atlas with linear mips/clamp while preserving main-camera party cutout and intact shadow pass. Adapter substitutes three matching meshes before unchanged32m MultiMesh grouping.395 trees/21 variants/106 batches/21 visibility materials/28298 triangles retained. No per-tree material/node creation.

Editable sources: `art/source/storybook/{moonwood_oak_pilot.blend,tree-painted-albedo.png,tree-painted-recipe.json}`. Runtime under `game/assets/environment/storybook`: pilot GLB/import, shared PNG/import, identical importer-extracted PNG/import. Sibling packs its image; GLB portable. Original tree kit .blend/GLB/mapping retained.518 source vertices/428 polygons per oak size unchanged; all2916 oak triangles match original at1e-5m. Physical face UVs48texels/m;304 foliage/124 bark faces per size including caps/sides,16px dilated gutters, broad calm dabs/vertical bark, no directional light baked.

Both images lossless/full mips, automatic3D compression disabled. Active oak materials share external atlas; portable GLB import retains identical extracted copy. Deliberate8MiB/full-mip RGB8 addition. Frozen engine texture estimate24,101,267 bytes versus AD00215,712,661.4067 nodes/443 resources unchanged across18 moving-camera samples. These observations do not accept AD019 performance/memory gates.

[Authoring geometry/image/preservation audit](../evidence/AD003/authoring-20261011/audit.json) and [coverage](../evidence/AD003/authoring-20261011/surface_coverage_report.json). All other starting pins preserved, including direction/interiors/prompt/contract/source/schema. Current engine Godot4.7.2 Mono Compatibility, schema8/content1. Original feet/yaw/IDs/species/sizes/source bodies/navigation/door/station/party/camera semantics unchanged. Prior [AD002 pilot](AD002_ACCEPTANCE.md) and [AD001 baseline](BASELINE.md) remain historical evidence.

## Verification and inspected evidence

Repository cwd, PowerShell7, workspace-specified console. [Main runner](../evidence/AD003/20261011-053341212-a75cd76b/results.json):

`./tools/run_checks.ps1 -Task AD003 -Import -Names application_smoke,map_camera_checks -RenderScript art_direction_tree_render -RenderPhases pilot -TimeoutSeconds 180`

Passed6/6 exit0. [Real-renderer tree runner](../evidence/AD003/20261011-053453086-55df92f2/results.json):

`./tools/run_checks.ps1 -Task AD003 -RenderOnly -RenderScript map_tree_art_checks -RenderPhases check -TimeoutSeconds 180`

Passed3/3 exit0. Both stable1336-file source digest`f7dc61df9873f18c4fe0161f357d1927efd6ed1672bf4ab5bb8323157de7fe16`, no source changes/timeouts/forbidden diagnostics. Existing import-only missing.NET10.0.9 allowance unchanged. Tree bounds/foot/yaw/catalog boxes/collisions/inventory verified. Camera330 physical projection samples/16 slopes/both projections/zoom bounds; max aim error0.0000076912m, modal/focus/terrain-occlusion gates pass.

[46 actual PNGs/index](../evidence/AD003/20261011-053341212-a75cd76b/render/tree-index.json), [four provenance/hash sheets](../evidence/AD003/20261011-053341212-a75cd76b/render/derived/20261011-053452-d110a07a/capture-report.json): fixed forest pair, six cutout-on/off pairs at0.8/1/1.15 both projections,18 interpolated motion frames, four shadow-only controls, six close angles/three checker views and restored final gameplay camera. All final sheets and critical full-size images inspected. Both roles readable; all12 localized hue-count samples improve with protection. Both shadow pairs have identical entire PNG pixel arrays. Animated water hidden only for shadow comparison; close diagnostics hide party/HUD to expose coverage; normal captures retain ordinary HUD/water. Every setup explicitly synthetic/frozen/interpolated; no ordinary route/native release/GUI restart/full profiling claimed.

Final enginePID60152/launcher13404 exited. [All-attempt owned PID/child audit](../evidence/AD003/authoring-20261011/cleanup-all-runs.json) reports zero remaining. Background Blender exited0; live default Blender5.2.2 LTS scene inspected read-only and unchanged. No held input/editor modification/cleanup owed. Runner isolates APPDATA/LOCALAPPDATA/save groups under builds/testing/AD003; ordinary saves untouched.

Retained failures/repairs and exact commands in acceptance: sandbox socket/CIM retry, generated imports/UID causing intended invalidation, shadow test catching animated river TIME pixels rather than ground shadows, omitted COLOR returning Nil, final close-camera/HUD restoration. Narrow diagnostics/test fixes only; production shadow equations unchanged. Original adapter/shader CRLF retained; command-local CR-at-EOL whitespace check passes. Authoring/audit/capture/role helpers exit0; existing Python base-runtime warning remains harmless.

## Changed scope and stop

19 task paths: three existing shader/adapter/tree-check files; three editable source assets; six runtime/import assets; new render fixture/UID; two authoring scripts; acceptance/checklist/handoff. Raw evidence ignored. Unrelated user direction, planning instructions and interiors workflow untouched; shared architecture/pipeline documents unchanged. Old color-only tree assertion adapted narrowly for three painted variants; physical/identity invariants retained.

No blocker, unrun required criterion or cleanup owed. R016 remains historically incomplete; separate migrations untouched. Authorized commit follow-up stops before AD004; no push.
