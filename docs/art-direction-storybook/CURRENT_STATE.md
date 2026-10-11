# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

AD009 Done; no active task. Every criterion verified in [AD009_ACCEPTANCE](AD009_ACCEPTANCE.md). AD001-AD008 remain Done. Unfinished IDs: AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker, required unrun criterion or cleanup remains.

User supplied the separate successful-task commit instruction after review. Commit scope is exactly seventeen paths: sibling Blender/recipe/exporter, runtime GLB/import, shared building shader/UID, town adapter/two narrowly adapted existing checks, render fixture/UID/two generated prerequisite UIDs, acceptance/checklist/handoff. Starting HEAD `b514149fa2dc7a3672590677ebdcbf8dbaf8af10` is context, not checkout target. All17 accepted task hashes,1363 game/tools bytes,9/9 results and1610 protected inputs reverified before documentation-only follow-up edits/staging. Exact verified commit/tree/path/blob identity and final status are recorded after commit in `docs/evidence/AD009/authorized-commit-20261011/commit-audit.json`. Unrelated untracked direction/prompt/contract/interiors and ignored evidence preserved/excluded. No push or AD010 implementation. AD008 authorized commit audit remains `docs/evidence/AD008/authorized-commit-20261011/commit-audit.json`.

Next eligible AD010: extend accepted oak treatment through all current tree variants and existing landmarks, keeping MultiMesh/canopy protection/source geometry/bridge and gate pins. Read its current mappings/source/task criteria before selection. Do not implement it here. Historical R016 stays Blocked/incomplete; interiors expansion separately owned.

## Accepted town and preservation

All14 current building definitions covered: unchanged AD002 shop plus13 geometry-identical painted UV exports. Five shared groups distinguish slate/plaster, terracotta, teal dockside/net shed, civic linen and woodland timber/olive. Full-face UVs/two-sided source coverage; existing1024RGB atlas reused. No new texture/node/per-instance material or gameplay change. [Recipe](../../art/source/storybook/town-rollout-recipe.json) names every definition, source/runtime/import/palette/density rule.

[Asset audit](../evidence/AD009/authoring-20261011/asset-audit.json): all5466 rollout triangles match original at1e-5m, every UV triangle inside one16px padded region/nonzero area, density34.32-64.005texels/m. Original skewed dockside polygons have maximum0.6437% anisotropy, others<=0.014%. Broad paint covers rear/side facades and roofs without obvious stretching. Original source vertices/topology/colors retained; packed image in sibling Blender. GLB uses existing sibling PNG, avoiding duplicated imported image resource; recipe owns calibrated runtime variants over neutral authoring texture material. Full-precision mesh/UV import, root_scale1/Y-up; no camera/light/skin/animation export.

[Preservation audit](../evidence/AD009/authoring-20261011/preservation-audit.json):1484 starting/1479 protected paths; only five existing code/workflow paths allowed to change. Original kit/mapping/layout/atlas/light registrations/feet/collision/portal/navigation/identity/schema8/content1 bytes preserved; semantic/floor/all16 terrain-water-riser fingerprints exactly AD008. Layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`. No other agent/conversation/external source read. Applicable `.agents/skills` absent; workspace caveman/versioned testing and installed Blender UV/export guidance followed.

## Verification and limits

Repository cwd; PowerShell7/installed Godot4.7.2 Mono/GL Compatibility960x640. [Final runner](../evidence/AD009/20261011-074511870-5b3461de/results.json)9/9 exit0:

```powershell
./tools/run_checks.ps1 -Task AD009 -Names application_smoke,map_town_art_checks,map_town_checks,light_interaction_checks,exterior_light_checks,routine_portal_checks -RenderScript art_direction_town_render -RenderPhases pilot -TimeoutSeconds 180
```

Stable1363-file game/tools digest `e919d310219c3ac9bfec301344e04d8b7e3d75531ffa366d250ac2ceb6e1afb9`; source.changed=false/error=null. Town37325 physical probes/18325 navigation samples/74 routes,151 lamp/13289 exterior-light/364 routine-portal assertions. Stable import separately passed earlier; no final forbidden diagnostics/timeout. Narrow tests retain physical/identity/non-emitting whole-building guarantees and original window plane/state/pool lifecycle checks.

[92 engine captures/eight inspected sheets](../evidence/AD009/20261011-074511870-5b3461de/render/derived/20261011-074617-23734823/capture-report.json):12 both-projection street/river/civic/rear/woodland/quay, four zoom bounds, six night,56 four-angle building diagnostic and14 checker views. Four critical full-size images inspected. All14 window consumers recorded, ten on/four off, original32/64 panes,23 sources/eight emitters. All setup explicitly synthetic frozen feet/day-night/environment/camera; close gallery uses actual imported mesh copies at y40/HUD hidden. No ordinary journey/native/Save/Load/restart/package claim.

Two paused120+120-frame observations: street p95/p99 2.675/2.931ms draw270; river1.926/2.360ms draw236. Texture32,489,873bytes exactly AD008, nodes4067/resources482;25 additional resources reflect imported UV/group resources, no new runtime node/texture. Full active/process-memory/travel-growth performance remains AD019; prior AD006 quay516 draws remains. HUD/world-label polish remains AD017.

## Attempts and cleanup

Retained initial sandbox socket/CIM failures, approved read-only connection/scoped runner retry, two self-invalidating generated import/UID runs, obsolete StandardMaterial-only light assertion failure and narrow adaptation. Initial numerically passing render rejected visually for hidden backfaces and excessive palette ratios; two-sided shader and restrained Compatibility ratios repaired, accepted fresh92-frame final run. Offline0.2% anisotropy assumption diagnosed against preserved source skew, measured0.6437% and bounded at1%; geometry unchanged. No existing physics/identity/input guard weakened. All authoring/asset/capture/preservation/whitespace audits exit0.

Live read-only MCP verified Blender5.2.2 LTS/protocol11/default Cube/Light/Camera; scene untouched. Background exporters exited. Unique APPDATA/LOCALAPPDATA/named slots under builds/testing/AD009; no ordinary save access or synthetic Save. [59 recorded owned Godot PIDs](../evidence/AD009/authoring-20261011/cleanup-pids.json) all exited, final engine30244/launcher11624 exit0. No input/editor/process cleanup owed. AD009 complete; authorized commit follow-up stops before AD010. No push.
