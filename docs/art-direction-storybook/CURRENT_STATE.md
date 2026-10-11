# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

AD007 Done, no active task. Every criterion verified in [AD007_ACCEPTANCE](AD007_ACCEPTANCE.md). AD001-AD006 remain Done. Remaining unfinished IDs: AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker, required unrun criterion or cleanup remains.

User supplied the separate successful-task commit instruction after review. Commit scope is exactly seven task paths: two outdoor presentation scripts, reusable lighting render fixture, editable lighting recipe, acceptance/checklist/handoff. Starting HEAD`68146000153cb11a668ecaaeef4711c47f8e5b93` is context, not checkout target. Accepted seven task hashes,8/8 checks,1353 game/tools manifest bytes and1474 protected inputs reverified before documentation-only follow-up edits. Exact verified commit identity/tree/path/blob scope and final status recorded after commit in `docs/evidence/AD007/authorized-commit-20261011/commit-audit.json`. Unrelated untracked direction/prompt/contract/interiors inputs preserved and excluded; ignored raw evidence excluded. No push or AD008 implementation.

Next eligible AD008 only. Exact next action after this commit: verify integrated playable Maris/Dock Row pilot using completed painted materials/lighting, both projections/zoom bounds/day-night-weather, required ordinary interactions/route and task-specific short performance samples. Read AD008 criteria and current APIs first. Do not start AD008 in this turn. Historical R016 stays incomplete; no older migration or interiors expansion resumed.

## Result and preservation

Outdoor sun/ambient/shadow values now supply cream daylight, softer cast shadows, restrained apricot dusk, lavender dawn, pale indigo night and neutral weather fill. Painted materials/party/routes retain detail and readable hues. Recipe: `art/source/storybook/lighting-painted-recipe.json`; runtime owners: `game/features/environment/environment_lighting.gd`, `environment_presenter.gd`. Original sun ray direction/knots/smooth interpolation, STABLE_INDOOR branch, clock/forecast/lightning/rain timing,23 source identities/overrides/eight unshadowed local emitters, camera/input/holds and schema8/content1 unchanged. No geometry/UV/texture/material/node/light/post-effect/renderer addition.

[Preservation audit](../evidence/AD007/authoring-20261011/preservation-audit.json) compares1478 starting paths and exact final game/tools bytes against accepted runner manifest. All original sources/GLBs/atlases/mappings/layout/navigation/feet and unrelated direction/interiors/user instructions preserved. Layout SHA256`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` unchanged. No `.agents/skills` applicable; installed calibration and versioned project testing skills used. No Blender scene or external source checkout used.

## Verified evidence and limits

Repository cwd; installed PowerShell7/Godot4.7.2 Mono/Compatibility960×640. [Fresh before](../evidence/AD007/20261011-070114676-bddc30ed/results.json)3/3 exit0; [final acceptance](../evidence/AD007/20261011-070220411-223c996b/results.json)8/8 exit0:

`./tools/run_checks.ps1 -Task AD007 -Names application_smoke,environment_lighting_checks,weather_presentation_checks,environment_lifecycle_checks,light_interaction_checks -RenderScript art_direction_lighting_render -RenderPhases pilot -TimeoutSeconds 180`

Stable1353-file digest`d06d2e5f610727aaf3b60799ae725baac1270754e58976f7a18ebd62342873db`; source.changed=false/error=null, no timeout/forbidden diagnostic. Lighting30053, weather193417, lifecycle157, light interaction151 assertions pass unchanged. Recipe/docs separately fingerprinted. Capture/comparison/preservation/whitespace helpers exit0.

[65 final engine views](../evidence/AD007/20261011-070220411-223c996b/render/lighting-index.json), [provenance/hash report/six inspected sheets](../evidence/AD007/20261011-070220411-223c996b/render/derived/20261011-070343-a4bc263e/capture-report.json), [paired value/pixel report](../evidence/AD007/authoring-20261011/comparison.json). All final sheets and critical full-size noon/night/dusk/forest/storm/flash frames inspected. Four phases/four conditions, both projections, dock storm-night zoom0.8/1.15, lamp off/on, scheduled real flash, rain pause/resume, three dry rooms. Setup explicitly synthetic detached forecast/feet/override; paused routines, one bounded0.35s resume. No ordinary/native route, Save/Load or full-profile claim.

52 deterministic pairs retain exact camera/feet/environment/rain-flash metadata and sun direction. Semantic/floor/all16 render fingerprints identical. Nodes4067→4083 within each run as camera/weather/rain selection changes; counts match before/after, production node owners unchanged. Night path luma68.69→114.19, storm-night65.39→96.20; party hues readable. Noon shaded-gable/roof separation42.97, plaster detail retained; sunlit path212.49 exceeds initial205 guidance and retains pre-existing red-channel clipping, without losing broad painted variation. Rainy meadow saturation0.60377 vs clear0.60294. Lamp changed-pixel upper bound0.7977% world crop including independent river TIME; active max1/allocated8/consumers23.

Paused rain/flash-only PNGs pixel-identical after0.5s; resumed rain phase advances. River TIME deliberately excluded from pause proof. Indoor before/after light values exact; all12 indoor day-clear/night-storm world-crop pairs across both runs identical, no rain nodes. No integration/overall look/native/package/restart acceptance implied. AD019 full profiling still required; prior AD006 quay516-draw observation retained.

## Attempts and cleanup

Acceptance retains CIM sandbox denial followed by reviewed owned-process escalation; fixture prior-state lamp API/node-count corrections; comparison-helper root/float32/RGBA diagnostic and noncontractual saturation-assumption corrections. No automatic approval rejection, weakened production guard or changed existing assertion. Failed runs retained under AD007; accepted baseline/final evidence distinct.

Unique runner APPDATA/LOCALAPPDATA groups under builds/testing/AD007; detached review Save/Load disabled, no Save issued or ordinary user data touched. [28 exact owned PIDs](../evidence/AD007/authoring-20261011/cleanup-pids.json) checked, none running; final engine11288/launcher63272 exited0. No keys held, live editor altered or cleanup owed. AD007 complete; authorized commit follow-up stops before AD008. No push or successor work.
