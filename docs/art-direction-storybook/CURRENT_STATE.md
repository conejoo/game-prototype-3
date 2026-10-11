# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

AD006 Done, no active task. Every criterion verified in [AD006_ACCEPTANCE](AD006_ACCEPTANCE.md). AD001-AD005 remain Done. Remaining unfinished IDs: AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker, unrun required criterion or cleanup remains.

User supplied the separate successful-task commit instruction after review. Commit scope is exactly22 task paths listed in acceptance: editable source/atlas/recipe; portable GLB/import/images; town adapter/wall shader/semantic plaza wiring; narrow town-art checks/render fixture; two authoring scripts; acceptance/checklist/handoff. Starting HEAD65cfcca3d8f5b8d62fe911dd7aee2bf700c46232 is context, not checkout target. Accepted source bytes and unrelated-file preservation verified before documentation-only follow-up edits. Exact verified commit identity/tree/path/blob scope and final status recorded after commit in `docs/evidence/AD006/authorized-commit-20261011/commit-audit.json`. Unrelated inputs and ignored raw evidence stay excluded. No push or AD007 implementation.

Next eligible AD007 only. Exact next action after this commit: inspect current sun/weather/environment/pooled-light owners and completed Maris/Dock Row material pilot; calibrate day/night/weather against LOOK_SPEC, preserving clocks, light cap, camera/input and indoor overrides. Do not start AD007 here. Historical R016 stays incomplete; no interiors expansion or older migration restart.

## Painted result and preservation

One shared RGB1024 atlas supplies warm boards, muted plaza stone and low-wall mortar/brush regions. Packed sibling Blender5.2.2 source/portable GLB retain original144 triangles and full-face padded UVs.64texels/m on full/fractional module faces; one shared UV-crop mesh handles four half-metre edge pieces. Full-precision UV import is deliberate: compressed attributes failed thin-face density checks. Existing semantic cobblestone uses world-metre atlas sampling; six town garden-wall prisms/four passenger basin-quay walls share one world-plane material. Source shapes/grooves, deck heights, collision, station feet/IDs, dry support/nav and other visual owners unchanged; no new geometry/alpha/reflection/displacement/emission/node/per-instance material.

[1592-path asset/pin audit](../evidence/AD006/authoring-20261011/asset-preservation-audit.json) verifies original kit/mappings/source assets and unrelated direction/interiors/instructions. Layout hash7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be preserved. Schema8/content1, seven dock rectangles/48m²,215 modules/165 quay cells, terrain/water/elevation and all gameplay owners retained. No applicable .agents/skills present; installed UV/export and versioned project testing skills used. AD007 owns lighting.

## Verified evidence and limits

Repository cwd, installed PowerShell7/Godot4.7.2 Mono/Compatibility960x640. [Before](../evidence/AD006/20261011-062651202-81a1fbfc/results.json)3/3 exit0; [full-precision import/density](../evidence/AD006/20261011-064303716-f48cf80e/results.json)4/4 exit0; [final acceptance](../evidence/AD006/20261011-064336010-9cef4899/results.json)8/8 exit0:

`./tools/run_checks.ps1 -Task AD006 -Names application_smoke,map_town_art_checks,map_town_checks,map_crossing_checks -RenderScript art_direction_dock_render -RenderPhases pilot,approach -TimeoutSeconds 180`

Stable1352-file digestc296990f309b3b790f229675b009da71c38300451206ffbabcfdb12541698284; source.changed=false/error=null, no timeout/forbidden diagnostic. Town37325 probes/18325 path samples/74 physical routes; crossings4032 probes/94 walk-dodge lanes/four rail slides. All exact inventory/footprint/height/material/UV/opaque/mip/shared-resource checks pass.

[45 synthetic views](../evidence/AD006/20261011-064336010-9cef4899/render/dock-index.json), [five ordinary-input views/four successful routes](../evidence/AD006/20261011-064336010-9cef4899/render/dock-approach-index.json), [50-frame provenance/hash report/five inspected sheets](../evidence/AD006/20261011-064336010-9cef4899/render/derived/20261011-064446-4636c1ea/capture-report.json). Both projections/zoom bounds/day-night/street-river-plaza-quay/close/checker/repeat covered. All sheets and required full-size frames inspected.35 paired views retain camera/feet/environment. [Comparison](../evidence/AD006/authoring-20261011/comparison.json): semantic/floor/all16 terrain-water-riser fingerprints identical, final town geometry/transforms stable, dock/wall repeat crops pixel-identical. Plaza fine pixel delta6.021 to2.359; roles/white rod/routes remain readable. Fresh D preflight and unchanged TestRunJourney guards prove ordinary viewport WASD dock approach/return without position/fact/weather/session setup. No native/export/GUI Save/Load/restart claim.

Short paused quay before/final p95=2.852/2.742ms, p99=3.420/3.346ms; draw516/nodes4067 unchanged, resources445 to454. Texture bytes24,101,267 to32,489,873(+8,388,606 for embedded/shared RGB8 atlas copies), buffers19,910,476 to19,929,628. Ultra9 185H/RTX4070 Laptop/NVIDIA581.29. Pre-existing quay516 draws exceeds future AD019500 target; no full profiling/process-memory/travel-growth acceptance here.

## Retained attempts and cleanup

Acceptance records CIM sandbox failure/generated imports, nil index/reused phase output/unreachable counter-side waypoints/crop/palette/coplanar UV/fractional density/full-precision import/helper corrections. Guards and production navigation unchanged; failed runs retained. Import-only.NET10.0.9 and nonfatal Python warnings recorded. Final authoring/asset/capture/comparison/preservation/whitespace helpers exit0.

Unique runner appdata/localappdata/save groups under builds/testing/AD006; no Save issued or ordinary user saves touched. Final pilot engine36984/launcher62024 and ordinary approach22200/launcher23056, plus every owned attempt process, exited; [PID audit](../evidence/AD006/authoring-20261011/cleanup-pids.json). Background Blender exited; read-only MCP preflight terminated without scene edits. No keys held, live editor changed or cleanup owed. AD006 complete; authorized commit follow-up stops before AD007. No push.
