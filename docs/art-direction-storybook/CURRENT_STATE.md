# Painted coastal storybook current state

Updated: 2026-10-11 UTC. [CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts one-task invocations.

## Current selection and stop

AD008 Done; no active task. Every criterion verified in [AD008_ACCEPTANCE](AD008_ACCEPTANCE.md). AD001-AD007 remain Done. Unfinished IDs: AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist AD020; every item complete: no. No blocker, required unrun criterion or cleanup remains.

The user supplied the separate successful-task commit instruction after review. Commit scope is exactly five paths: integrated pilot fixture, reusable integration recipe, acceptance/checklist/handoff. Starting HEAD `cebbceb08db65dc666e0a9e7ca2c7ff3954b83d7` is context, not checkout target. All five accepted task hashes,9/9 checks,1354 game/tools bytes and1609 protected starting inputs reverified before documentation-only follow-up edits. Exact verified commit/tree/blob/path identity and final status are recorded after commit in `docs/evidence/AD008/authorized-commit-20261011/commit-audit.json`. Unrelated untracked direction/prompt/contract/interiors and ignored raw evidence preserved and excluded. No push or AD009 implementation. Prior AD007 commit remains recorded in its acceptance/completion and `docs/evidence/AD007/authorized-commit-20261011/commit-audit.json`.

Next eligible AD009 only after this commit: extend accepted atlas through remaining current town building definitions, keeping original silhouettes/footprints/heights/IDs. Read AD009/current mappings/source and reuse `art/source/storybook/pilot-integration-recipe.json`. Do not implement successor here. Historical R016 stays Blocked/incomplete; interiors expansion separately owned.

## Accepted pilot and preservation

Running Maris/Dock Row combines warm plaster/timber/counter, indigo roofs, sage ground/apricot paths, matte dock/plaza/low walls, sea-green water and calibrated weather lighting. Brush variation remains coherent at gameplay zoom. No additional production repair needed. Current capsules/villagers, other unpainted building/tree families and HUD remain later-task scope. Concept remains appearance authority only.

New `game/tests/art_direction_pilot_render.gd` reuses existing inventory/capture/journey methods with separate ordinary/synthetic processes. New `art/source/storybook/pilot-integration-recipe.json` records exact six component hashes, editable/runtime paths and shared atlas/import/preservation rules. No runtime code/scene/material/mesh/UV/texture/light/input change. SaveCodec8/content1 retained.

[Preservation audit](../evidence/AD008/authoring-20261011/preservation-audit.json):1611 starting paths, exact accepted1354-file game/tools manifest, five-path task scope. All original assets/source/mappings/layout/anchor/collision/navigation/identity/instruction bytes preserved. Layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`. No agent/conversation, external source or Blender editor used. No applicable `.agents/skills` found; workspace caveman/versioned testing skill followed.

## Verification and limits

Repository cwd; installed PowerShell7/Godot4.7.2 Mono/GL Compatibility960x640. [Final runner](../evidence/AD008/20261011-072126312-3325f131/results.json)9/9 exit0:

```powershell
./tools/run_checks.ps1 -Task AD008 -Names application_smoke,map_town_art_checks,map_camera_checks,map_water_checks,interaction_dialogue_checks -RenderScript art_direction_pilot_render -RenderPhases pilot,journey -TimeoutSeconds 180
```

Stable1354-file digest `5b8ed4e5d7ef81ad019de9b56242ebff30542927a72d78d79a05a4babe910917`; source.changed=false/error=null, no timeout/forbidden diagnostic. Town inventory/material,330 camera samples, water physics/nav and dialogue/modal/LOS/lifecycle guarantees pass unchanged. Immutable semantic/floor/all16 terrain-water-riser and town triangle/transform fingerprints exact.

[49 captures/five inspected sheets](../evidence/AD008/20261011-072126312-3325f131/render/derived/20261011-072317-331e1892/capture-report.json):40 frozen synthetic Maris/dock day/night/rain/storm/both projections/zoom0.8-1.15/canopy controls; nine ordinary input views. D preflight/six normal guarded WASD routes/actual Maris selection/E dialogue/modal W refusal/Esc release/dock-return/P perspective pass. No ordinary-process feet/time/weather/fact setup. Two-member party retained; no Save/Load/native/release/restart claim.

[Day comparison](../evidence/AD008/authoring-20261011/comparison-day-clear.png), [storm comparison](../evidence/AD008/authoring-20261011/comparison-night-storm.png), [paired report](../evidence/AD008/authoring-20261011/comparison.json):six exact camera/feet/clock/weather pairs from AD001 Maris/AD006 prepaint dock. Roof/shaded-plaster separation41.71; meadow173.97→126.68 luma, storm-night path52.18→96.20. Both-role visibility improves in four canopy pairs. Sunlit path215.57 remains above initial205 guidance; broad variation retained. Existing shore highlights/HUD density visible; no pixel-perfect/town-wide acceptance claim.

Five paused120+120-frame samples: p95/p99 1.437-2.297/2.212-3.048ms; draws134-284, matched273/284/134 unchanged. Texture32,489,873 bytes matches AD006; AD001 delta25,165,818 explained by three existing twice-resident RGB atlases/mips.457 resources stable; known weather-selected rain nodes4067-4082. Engine static134,380,611-137,822,075 bytes are engine counters, not process working set. No new AD008 runtime allocation. AD019 full active/travel-growth gate and prior AD006 quay516 draws remain. Historical lower cadence is not attributed to art speedup.

## Attempts and cleanup

Retained sandbox CIM failure then reviewed owned-process escalation; fixture fixed-node assumption corrected using AD007 weather-selection distinction, retaining every immutable fingerprint. Comparison helper corrected invalid purple threshold to AD003 lit-role ratio. No auto-review rejection, original guard change or failed-run promotion. Capture/comparison/preservation/whitespace helpers exit0.

Unique APPDATA/LOCALAPPDATA/named slots under builds/testing/AD008; synthetic Save/Load disabled, ordinary phase no Save. [34 owned PIDs](../evidence/AD008/authoring-20261011/cleanup-pids.json) all exited; final visual24028/launcher13444, ordinary14640/launcher39616 exit0. Inputs released, no editor/process cleanup owed. AD008 complete; authorized commit follow-up stops before AD009. No push.
