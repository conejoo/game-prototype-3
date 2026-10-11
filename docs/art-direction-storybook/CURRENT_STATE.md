# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts each one-task invocation.

## Current selection

AD004 Done, no active task. Every criterion verified in [AD004_ACCEPTANCE](AD004_ACCEPTANCE.md). AD001-AD003 remain Done. Remaining unfinished IDs: AD005, AD006, AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker or required decision remains.

Implementation stopped for review; user then supplied the separate successful-task commit instruction. Commit scope is exactly nine AD004 paths, including acceptance/checklist/handoff; unrelated direction/interiors/prompt/contract inputs and ignored raw evidence remain excluded. Accepted source bytes and preservation scope verified; exact verified commit identity/tree/path/blob scope and final status recorded after commit in `docs/evidence/AD004/authorized-commit-20261011/commit-audit.json`. No push or AD005 work. Starting HEAD `d315e3749fc0fc145862cf55ac18e643e15d469a` is historical context, not a checkout target. Prior authorized AD001-AD003 commits remain in their acceptance/local audits.

Next eligible task: AD005 only. Exact next action after this task's review/commit workflow: inspect river.gdshader and current semantic shore/wet-mask owners, accepted ground recipe and fixed bridge/ford views; paint river/shore transitions within AD005 bounds. Do not start it here. No town rollout, lighting, HUD, rooms, interiors expansion or historical R016 work.

## Completed ground and preservation

World-aligned quiet sage meadow/apricot dirt plus painted stone on existing elevation risers. Editable [ground recipe](../../art/source/storybook/ground-painted-recipe.json) points to three production sources: landscape_materials.gd, landscape.gdshader, elevation_surfaces.gd. No Blender export or extra texture required by this measured procedural method. Shared material/batch structure retained; six terrain/nine riser batches. Low-frequency dabs0.4×0.588m, wash3.125m, meadow pools5.882m; filtered by pixel derivatives, no TIME/periodic UV/cell reset. Painted swatches calibrated under existing warm light, explicit linear shader parameters, roughness0.97. Dirt keeps existing0.065m semantic shoulder with matching meadow; sand/cobble/wet-shoreline/raw-marker/water retain previous shading policy.

Original layout SHA256`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` preserved. Runtime semantic/floor/all16 ground-riser-water mesh fingerprints match before;472 levels/16 slopes/238 cliffs/8598 wet cells unchanged. No body/nav/feet/station/identity/door/source geometry or gameplay changes. Schema8/content1 retained. [Preservation audit](../evidence/AD004/authoring-20261011/preservation-audit-final.json) records scoped changed paths and byte-identical unrelated source/user planning/direction/interiors assets. Original town/tree sources and accepted pilots untouched. Workspace/repository/checked ancestors have no `.agents/skills`; project versioned testing skill used. No user instructions changed.

## Verification and inspected evidence

Repository cwd, PowerShell7, workspace console Godot4.7.2 Mono Compatibility. [Fresh paired before](../evidence/AD004/20261011-054933078-b64923b9/results.json) passes3/3; [final stable-byte runner](../evidence/AD004/20261011-055745162-bd79f882/results.json) passes7/7 exit0:

`./tools/run_checks.ps1 -Task AD004 -Names application_smoke,map_landscape_checks,map_layout_checks,map_camera_checks -RenderScript art_direction_ground_render -RenderPhases pilot -TimeoutSeconds 180`

Stable1338-file game/tools digest`cf12cbf582e5d301822b15cf2b79981c26740456c22ecca0ba436ff1dbcd5dfd`, source.changed=false/error=null. No timeouts/forbidden diagnostics.47040 semantic/default grass samples, exact river/crossing/dock occupancy, surface/physical height and two navigation routes pass; layout pins/defaults/mixed grids/heights/inert portals pass. Camera330 physical projection samples/16 slopes, both projections/zoom bounds, max aim error0.0000076912m, occlusion/modal/focus gates pass.

[50 real Godot frames/index](../evidence/AD004/20261011-055745162-bd79f882/render/ground-index.json), [five inspected provenance/hash sheets](../evidence/AD004/20261011-055745162-bd79f882/render/derived/20261011-055840-8858214a/capture-report.json), [paired comparison/local pixel measurements](../evidence/AD004/20261011-055745162-bd79f882/render/ground-comparison-final.json). Clear Maris/ramp/forest both projections at0.8/1/1.15; Moonwell/overcast four poses both projections at1;20 five-frame interpolated camera-motion samples at both zoom bounds; close ramp/static repeat.48 shared before/after frames have identical feet/camera/environment. All final sheets and critical full-size final clear/cloudy/forest/close frames inspected; actor hues/white moonflowers remain clear, consistent world scale, no visible shimmer/periodic repeat. Static100×80 ground crop pixel-identical. Local meadow luma170.11→124.10/pixel delta1.036→0.320; dirt191.09→204.91/delta0.975→0.254. Original lighting, water animation, bright shore and existing HUD overlap remain owned by later tasks.

Zero extra texture/node/draw surfaces. Paired frozen samples retain273/134 draw p95,4067 nodes/443 resources,24,101,267 texture bytes. Final town cadence p95/p99=1.881/3.233ms, forest1.719/2.073ms; exact before/after/buffer estimates/hardware in acceptance. These short frozen observations do not accept AD019. Synthetic placements/weather/session rebinding/motion are explicit; no ordinary route, natural day, native GUI Save/Load/restart or package claim.

## Cleanup, changes and stop

Final owned enginePID70684/launcher35580 exited. [All-attempt PID audit](../evidence/AD004/authoring-20261011/cleanup-all-runs-final.json): zero remaining. No held input, live editor change or cleanup owed. Runner isolates APPDATA/LOCALAPPDATA/save groups under builds/testing/AD004; ordinary saves untouched. No Blender process started. Retained sandbox CIM failure/generated UID invalidation/initial bright palette/close HUD label/incorrect first diagnostic crop and exact corrections in acceptance; no guard/assertion weakened. Existing import-only.NET/venv base-runtime warnings retained, helpers exit0. Existing source CRLF preserved; whitespace audit passes.

Nine task paths: three production material/shader/riser files; one editable recipe; render fixture/UID; acceptance/checklist/handoff. Raw evidence ignored. Shared architecture/pipeline docs unchanged. No blocker/unrun AD004 criterion. R016 remains historically incomplete. Authorized commit follow-up stops before AD005; no push.
