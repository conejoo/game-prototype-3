# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

AD005 Done, no active task. Every criterion verified in [AD005_ACCEPTANCE](AD005_ACCEPTANCE.md). AD001-AD004 remain Done. Remaining unfinished IDs: AD006, AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker, required decision, unrun criterion or cleanup remains.

Implementation stopped for review; user then supplied the separate successful-task commit instruction. Commit scope is exactly nine AD005 task paths: three production river/landscape shader/material files; editable river recipe; render fixture/UID; acceptance/checklist/handoff. Starting HEAD d13581808a83020bfa723dfbb0eb9762e016d1f5 is context, not checkout target. Unrelated direction/interiors/prompt/contract inputs and original source assets remain byte-identical; [preservation audit](../evidence/AD005/authoring-20261011/preservation-audit-final.json). Raw evidence stays ignored. Exact verified commit identity/tree/path/blob scope and final status are recorded after commit in `docs/evidence/AD005/authorized-commit-20261011/commit-audit.json`. No push or AD006 work. Historical R016 remains incomplete.

Next eligible task: AD006 only. Exact next action after this task's review/commit workflow: inspect existing dock/plaza/low-wall module source kit/mapping, town_art.gd and dock_surfaces.gd; apply shared painted timber/stone within pinned footprints, deck heights and navigation. Do not start AD006 here. No town rollout, lighting, rooms/HUD, interiors expansion or historical migration restart.

## Completed river and preservation

Existing opaque water now has calibrated sea-green broad wash, sparse soft elongated strokes drifting0.02826m/s, derivative filtering and low-contrast olive/mint edge accents inside its fixed union mesh. Existing semantic kind5 wet shoreline receives muted painted dabs. [Editable recipe](../../art/source/storybook/river-painted-recipe.json) records authoring sRGB swatches, explicit linear parameter conversion, shader paths and world scales. Procedural method needs no atlas/Blender export; no new textures, transparency, reflection pass, displacement, geometry or shared-material/node expansion. Existing sand paths/dock/plaza colors remain AD006 ownership; lighting stays AD007.

Original layout SHA2567477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be preserved. Paired semantic/floor/all16 render-mesh hashes identical. Six terrain/nine riser batches;472 levels/16 slopes/238 cliffs;8766 authored/8598 effective wet cells;168 dock-cutout cells/seven rectangles unchanged. Water blockers, crossings, dry supports/nav/physical feet, stable IDs/stations, fishing reach, tree cutout/batching, original source assets and schema8/content1 untouched. No assertions/process/evidence guards weakened. No .agents/skills in checked workspace/repository/ancestors; versioned testing skill and art contract used.

## Verified engine evidence

Repository cwd, PowerShell7, workspace Godot4.7.2 Mono console/Compatibility960x640. Fresh [before](../evidence/AD005/20261011-060927664-d098d602/results.json) passes3/3 exit0. [Focused production run](../evidence/AD005/20261011-061250513-4a7e0af6/results.json) passes7/7 exit0:

`./tools/run_checks.ps1 -Task AD005 -Names application_smoke,map_water_checks,map_crossing_checks,fishing_targeting_checks -RenderScript art_direction_river_render -RenderPhases pilot -TimeoutSeconds 180`

Water:91 blockers/90 source-water records,4027 exposed-edge sweeps and actual synthetic walking/dodge negatives. Crossing:8 bodies/4032 floor-clearance probes,94 walking/dodge lanes/4 rail slides/27780 displacement samples. Fishing targeting135 assertions; application startup passes. Stable1340-file digest589ebb95ecc6a0f007fa66e69a5f0653d1ced79c355b2369ed0f8654419b95b5.

Final fixture close-HUD projection-label correction [render](../evidence/AD005/20261011-061519012-8b094469/results.json) passes3/3 exit0, stable1340-file digest3f75c8bf4cebb1654c34159aff5e95fd1aa44cfcf51af1822d232f3c131c4217:

`./tools/run_checks.ps1 -Task AD005 -RenderOnly -RenderScript art_direction_river_render -RenderPhases pilot -TimeoutSeconds 180`

Production bytes match preceding seven-case manifest; only fixture camera-description refresh differs. Both accepted runs source.changed=false/error=null, no timeout/forbidden diagnostic. [Final83 actual PNGs/index](../evidence/AD005/20261011-061519012-8b094469/render/river-index.json), [seven inspected provenance/hash sheets](../evidence/AD005/20261011-061519012-8b094469/render/derived/20261011-061603-578e6264/capture-report.json), [comparison/animation report](../evidence/AD005/20261011-061519012-8b094469/render/river-comparison.json). Both projections, zoom bounds, day/night, both bridge/ford landings, dock close,24 actual water-TIME frames,16 translated-camera frames and6 synthetic production fishing-cue frames covered. All final sheets and critical full-size same-material dock/crossing/fishing/close frames inspected. Every83 paired view retains exact camera/feet/environment; independent shader phases are declared. Water sequences span2.275-2.364s with>=400ms intervals, no conspicuous shimmer/repeating bands/false crossing. Target/ripple/bobber/line/bite colors readable. Derived GIFs/paired PNGs and all commands in acceptance.

Short paused120-warmup/120-frame dock sample before/final p95=2.070/1.885ms, p99=2.646/3.221ms; draw240,4067 nodes/444 resources,24,101,267 texture/19,910,476 buffer bytes unchanged. Hardware Ultra9 185H/RTX4070 Laptop/OpenGL3.3 NVIDIA581.29. These are observations, not AD019 full profiling/process-memory/travel-growth acceptance. Synthetic feet, clock/weather/rebind, paused routines and fishing presentation do not prove ordinary casting/route/native Save/Load/restart/release.

## Retained attempts and cleanup

Sandbox CIM failure retained; guarded escalated runners allowed. New fixture import generated UID and properly invalidated source identity, then stable rerun. Existing import-only.NET10.0.9 SDK warning retained. Initial rendered run passes7/7, but local helper caught395/398ms timer rounding against declared400ms; monotonic fixture deadline fixes this without relaxing the bound. Later full-size inspection caught stale close HUD projection label; final fixture refresh/render fixes it. Python base-runtime/Pillow warnings nonfatal; evidence/comparison/preservation/CRLF whitespace helpers exit0.

Final enginePID51324/launcher24120 and every owned attempt process exited; [all-run PID audit](../evidence/AD005/authoring-20261011/cleanup-all-runs-final.json) has zero remaining. Runner isolates test data/saves under builds/testing/AD005. No input held, live editor altered, Blender process started or cleanup owed. Shared architecture/pipeline docs and other workflows unchanged. AD005 complete. Authorized commit follow-up stops before AD006; no push.
