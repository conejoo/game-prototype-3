# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

**AD010 Done**; every criterion verified in [AD010_ACCEPTANCE](AD010_ACCEPTANCE.md). AD001–AD010 Done, no active task. Unfinished IDs: AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: **no**. No AD010 blocker, required unrun criterion or cleanup owed.

Exactly 18 task paths ready for review: two sibling Blender sources/recipe/exporter, two GLBs/imports, tree and landmark adapters/canopy shader, two narrow existing art-check adaptations, render fixture/UID, acceptance/checklist/handoff. [Reviewed implementation hashes](../evidence/AD010/authoring-20261011/task-scope.json) record the accepted scope. Starting HEAD `05e49a53f24fb6e9328c3d1d127911214d1c7566` is context, not checkout target. User supplied the separate successful-task commit instruction after review. All18 accepted task hashes,1370 validated source files,9/9 main and3/3 tree results,1619 protected inputs and678 local evidence files reverified before documentation-only follow-up updates/staging. Exact commit/tree/path/blob identity and final status are recorded after commit in [commit audit](../evidence/AD010/authorized-commit-20261011/commit-audit.json). Unrelated untracked direction/prompt/contract/interiors and ignored raw evidence remain preserved/excluded. No push or AD011 implementation. Prior AD009 commit audit remains `docs/evidence/AD009/authorized-commit-20261011/commit-audit.json`.

Next eligible **AD011**: unify existing small props/lights/collectible visuals from current source mappings and shared recipes, preserving resource/interaction/light contracts. Do not implement it in this invocation. Historical R016 remains Blocked/incomplete; interiors expansion separately owned.

## Accepted forest and preservation

All nine species/21 size variants painted: three accepted oak variants untouched, 18 remaining variants UV-exported. Five existing landmark definitions/seven placements painted. Existing tree/town atlases reused with source-semantic UV2 groups for bark/canopy/cherry blossoms/rowan berries and restrained species ratios; no new texture or per-tree materials. Original 395 tree placements, 106 32m batches/21 materials, 28,298 tree/4,276 landmark triangles, canopy cutout/shadow math, Moonwell/bridge/ford/gate/physics/navigation remain pinned. Geometry-identical siblings retain authoring colors/packed textures; full-face UVs with 16px gutters, portable GLBs/full-precision imports. [Recipe](../../art/source/storybook/forest-painted-recipe.json) owns density/palette/import policy.

[Preservation](../evidence/AD010/authoring-20261011/preservation-audit.json): 1,627 starting/1,619 protected paths, zero unexpected changes. Original kits/mappings/layout/atlases, terrain/water/riser fingerprints, actors/services/schema8/content1 and unrelated direction/interiors/user instructions unchanged. Exporter created before starting hash snapshot is explicitly task-owned. No other agent conversation or source refresh.

## Verification and limits

Repository cwd, PowerShell7, installed Godot4.7.2 Mono/GL Compatibility960×640. [Final main](../evidence/AD010/20261011-080833167-0da4cde7/results.json) **9/9 exit0**, [windowed tree audit](../evidence/AD010/20261011-081053568-044e512d/results.json) **3/3 exit0**:

```powershell
./tools/run_checks.ps1 -Task AD010 -Names application_smoke,map_landmark_art_checks,map_forest_checks,map_camera_checks,map_crossing_checks -RenderScript art_direction_forest_render -RenderPhases pilot,journey -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD010 -RenderOnly -RenderScript map_tree_art_checks -RenderPhases check -TimeoutSeconds 180
```

Stable 1,370-file game/tools digest `1e8144f64be6933666985bc10fab9e235bc0631d82f2bae2fb16e935ac1a7f32`, source.changed=false/error=null; [final bytes](../evidence/AD010/authoring-20261011/accepted-source-audit.json) unchanged. Forest 64,178 probes/18,369 path samples/16 walked routes; camera330 samples; crossings4,032 probes/94 walk-dodge runs/four slides. Asset/coverage/capture/preservation/whitespace audits pass.

All **165 final Godot frames/15 sheets** inspected: 148 explicit synthetic day/night/both-projection/zoom/cutout/shadow/three-angle/checker views and17 fresh ordinary input frames. Six actual guarded routes cover Moonwell/ford/bridge/forest; ten successive input-motion frames cover both projections, observed pause/released input. 32 before/after camera/feet/physical fingerprints exact. All eight localized party hue diagnostics improve with protection; both shadow-only pairs pixel-identical. Forage/Moonwell/route cues legible; original HUD remains AD017 scope. No native OS input, Save/Load/restart/package claim.

Two paused120+120 samples: day p95/p99 **1.251/1.372ms**, draw134; night **2.124/2.255ms**, draw131. Nodes4067/resources522 stable after gallery; matched before484 resources. Texture32,489,873 bytes exactly before/AD009, buffers26,228,764 bytes. Engine counters/frozen samples cannot pass full AD019 process-memory/travel-growth/performance acceptance. Prior AD006 quay516 draws retained.

## Attempts, known limitation and cleanup

Detailed acceptance retains initial sandbox/CIM/socket failures, scoped approved retries, generated UID/import invalidations, wrong atlas-partition audit and original nonplanar-quad density diagnostic corrections. Final passes use stable current source; no physics/input/identity guard weakened.

Supplemental forage check reports only `fishing-rod-dock-01` arrival route obstructed. All three forest moonflower anchors pass. A stable isolated `git archive HEAD game tools` prepaint snapshot repeats the identical rod-only failure: [baseline result](../../builds/testing/AD010/prepaint-snapshot/docs/evidence/AD010/20261011-081013682-11d26aaf/results.json). Pre-existing dock fixture limitation, not an AD010 blocker; test/gameplay untouched.

[92 recorded owned PIDs](../evidence/AD010/authoring-20261011/cleanup-pids.json) exited; final pilot59348/17836, journey26824/33624, tree3420/33844 exit0. Stalled task-owned MCP helpers stopped after identity checks; live Blender17436/default Cube/Light/Camera unchanged, read-only probe5.2.2 LTS/protocol11. Background exporters exited; backups retained in ignored evidence. No input/editor/process cleanup owed. AD010 authorized commit follow-up stops before AD011. No push.
