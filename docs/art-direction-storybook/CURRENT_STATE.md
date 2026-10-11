# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) is status authority; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts each one-task invocation.

## Current selection

AD002 Done; no active task. Every criterion verified in [AD002_ACCEPTANCE](AD002_ACCEPTANCE.md). AD001 remains Done. Remaining unfinished IDs: AD003, AD004, AD005, AD006, AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist ID AD020; every item complete: no. No blocker or required decision remains.

Implementation stopped for review; user then supplied the separate instruction authorizing the successful AD002 task commit. Commit scope is exactly20 task paths: pilot authoring/runtime assets and import metadata, material wiring/checks/render fixture and UIDs, authoring scripts, acceptance/checklist/handoff. Raw evidence and unrelated direction/interiors/prompt/contract inputs remain excluded. Exact post-commit hash/tree/status and byte/scope/preservation verification are recorded locally in `docs/evidence/AD002/authorized-commit-20261011/commit-audit.json`. No push or AD003 work. Implementation starting HEAD `9d8d847ee24e76fee3ece03078054961ccf59602` is historical context, not a checkout target.

Next eligible task after review/commit workflow: AD003 only. Exact next action: read accepted atlas/material recipe and current tree source/mapping/MultiMesh/canopy shader, inspect final Maris pilot and original tree evidence, then paint one tree family and integrate texture sampling while preserving party cutout/shadows/batching. Do not start AD003 during this stopped AD002 turn. No rollout/terrain/light/HUD/room expansion or historical R016 work.

## Completed pilot and source boundaries

One reusable1024 painted plaster/timber/slate atlas with four subordinate accents. Reed Chandlery appearance swaps only `GEO-reed-chandlery` via sibling GLB; original town .blend/GLB and mappings remain unchanged. Counter bench, supplies and existing fitting/specialist gear use three shared-region materials. Active shop/counter materials share external atlas; imported packed GLB retains an identical extracted texture copy, deliberate8MiB total mipmapped RGB8 addition. Pilot one mesh/one surface/one material; no per-instance material generation or node added. Principal density64texels/m; foundation/accent minimum42.04 deliberately uses smaller regions. Calibrated warm plaster/indigo/timber colors; no shared lighting change.

Editable sources: `art/source/storybook/{alderwake_shop_pilot.blend,town-painted-albedo.png,town-painted-recipe.json}`. Runtime: matching pilot GLB/import and shared PNG/import under `game/assets/environment/storybook`, plus importer-extracted PNG/import. Portable GLB embeds exact atlas; sibling .blend packs image. Shader/runtime textures local, sRGB, lossless, full mips, clamp and linear mip filtering. Original palette applies only to15 unpainted town meshes; pilot vertex tint disabled and albedo white.

All500 exported shop triangles match original geometry at1e-5m; source vertices/topology unchanged.48 original source/runtime/preservation pins verified; counter nonmaterial content unchanged. Current engine Godot4.7.2 Mono Compatibility, schema8/content1. Original IDs/feet/body dimensions/door anchors/source outlines/heights/navigation retained. Existing NPC world adapter pins furniture as top-level world transforms; fixture now validates those global feet with float tolerance.

## Verification and inspected evidence

Repository cwd, PowerShell7, workspace-specified Godot console. [Final runner](../evidence/AD002/20261011-050946355-a0b97d26/results.json):

`./tools/run_checks.ps1 -Task AD002 -Import -Names application_smoke,map_town_art_checks,recovery_presentation_checks -RenderScript art_direction_shop_render -RenderPhases pilot -TimeoutSeconds 180`

Passed7/7 exit0: version/import/parse, three focused checks and rendered pilot; no timeout or forbidden diagnostic. Existing editor-only missing.NET10.0.9 allowance retained. Source1326 files/digest `b7366860625c020db2a2a978b3c94a8012c59f0681248da149948d585ddc4618` unchanged throughout accepted run. Separate isolated app-data/save groups; ordinary saves untouched.

[20 actual PNGs/index](../evidence/AD002/20261011-050946355-a0b97d26/render/shop-index.json): both projections at0.8/1/1.15; clear11:12AM baseline feet/settings; night1:00AM thunderstorm; six front/back/side close angles; three checker views; three counter states. Synthetic frozen pose/time/weather and injected presentation stages explicitly labeled. Ordinary HUD visible at gameplay zoom, hidden only for close diagnostics. Two provenance/hash contact sheets and critical full-size day/close/night images inspected. Painted surfaces, full UV fill and supplies readable, no missing texture/double tint/atlas bleed. Original modeled roof joints remain. Manual close patch roof/plaster luma separation70.68; shaded wall brightness remains existing lighting behavior.

[Geometry/pin/embedded-image audit](../evidence/AD002/authoring-20261011/audit.json), [surface coverage](../evidence/AD002/authoring-20261011/surface_coverage_report.json). Existing town guarantees24 structures/16 meshes/6110 triangles/168 exact base samples/48m2 dock area/215 modules/165 quay cells passed. Counter lifecycle/dialogue/travel/synthetic bidirectional restore passed. Final engine texture estimate15,712,661 bytes and433 resources are frozen review observations, not AD019 process-memory/performance acceptance.

Retained failures/corrections and exact commands/hashes in acceptance: sandbox socket/CIM retry, Blender image enum, generated import metadata invalidation, fixture local/world/float mismatch, brighter first palette, initial redundant UV-audit V flip. All corrected; sole accepted run above. Raw evidence and prior pilot backup remain ignored. No native route/input/release/new-process GUI Load/full profiling claimed or required here.

Live Blender read-only probe verified5.2.2 LTS/default Scene; all authoring used separate background process. Final enginePID20844/launcher21568 exited. [Owned PID audit for every attempt](../evidence/AD002/authoring-20261011/cleanup-all-runs.json): zero remaining processes/children. No held input, altered user editor/live scene or cleanup owed.

## Changed scope and preserved work

Changed: this folder's CHECKLIST/CURRENT_STATE and new AD002_ACCEPTANCE; `game/world/map_candidate/town_art.gd`, `game/world/maris_counter.tscn`, `game/tests/map_town_art_checks.gd`; new storybook source/runtime files, `tools/art_direction/{paint_shop_atlas,export_shop_pilot}.py`, `game/tests/art_direction_shop_render.gd`/`.uid`. Import generated prerequisite `art_direction_baseline_render.gd.uid`; AD001 fixture content unchanged. Raw evidence excluded by existing ignore/export rules.

Original art/direction, AGENT_PROMPT/CONTRACT, docs/interiors-map-migration and all unrelated production source retained. [AD001 baseline](BASELINE.md)/[acceptance](AD001_ACCEPTANCE.md) remain immutable historical context; prior authorized commit audit still under `docs/evidence/AD001/authorized-commit-20261011/commit-audit.json`. Shared architecture/pipeline policy documents unchanged; narrow painted policy captured in AD002 test/acceptance only. AD001 inventories every family; AD002 does not imply town rollout or reference-wide completion.

R016 remains historically Blocked/incomplete after user stop; no status or missing native gates changed. Separate interiors workflow untouched. No blocker, no remaining AD002 criterion. Authorized commit follow-up stops before successor; no push.
