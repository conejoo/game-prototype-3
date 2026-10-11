# AD008 - Playable Maris and Dock Row pilot

Done, 2026-10-11 UTC. Every AD008 criterion verified; no blocker, required unrun check or cleanup remains. Exactly one task completed. AD001-AD008 Done; AD009-AD020 Pending. Next eligible AD009 only. Every checklist item through AD020 complete: **no**. No staging, commit or push; user requested a separate post-review commit instruction.

## Scope and result

Running pilot combines warm painted shop/counter plaster/timber, indigo slate, calm sage ground/apricot paths, matte dock/plaza/stone, sea-green river and calibrated day/night/weather lighting. Broad variation survives gameplay zoom without an obvious atlas seam, missing face, doubled palette tint or distracting water repetition. Cyan/purple party, Maris counter and equipment remain identifiable in both projections and rain/night. Existing capsules, villagers, nearby unpainted building/species families and prototype HUD retain their later-task owners. Concept guides appearance, not coordinates/silhouettes. No additional production repair was needed after integrated inspection.

Starting HEAD `cebbceb08db65dc666e0a9e7ca2c7ff3954b83d7` is context, not checkout target. Initial Git status contained only unrelated untracked direction, AGENT_PROMPT/CONTRACT and interiors-workflow inputs. Read applicable workspace instructions, active prompt/checklist/handoff/contract/look/baseline, architecture, AD002-AD007 acceptance/evidence, PLAYTEST and versioned gameplay-testing skill. No applicable `.agents/skills` or additional repository AGENTS found. Opened chosen reference, painted atlas, current material/recipe owners and actual engine images. No other conversation, delegation, live Blender editor, external source checkout or ordinary user save used.

Five task paths:

- `game/tests/art_direction_pilot_render.gd`: reusable engine review, inheriting existing baseline/ground/dock inventory/sample methods; separate fresh ordinary journey and synthetic visual processes. No new global class/import required.
- `art/source/storybook/pilot-integration-recipe.json`: exact six prerequisite recipe hashes, editable source/runtime paths, three atlas densities/import rules, preservation boundaries and reproduction settings. Original sibling .blend/texture sources unchanged. Authoring documentation, not runtime dependency.
- This acceptance, `CHECKLIST.md`, `CURRENT_STATE.md`.

No production code/scene/mesh/UV/material/texture/light/input or geometry changes. Original source files, assets, mappings, layout, navigation, wrapper feet/colliders, station/door anchors and identities/portraits remain byte-preserved. Current SaveCodec schema8/content1 unchanged. Historical R016 remains Blocked/incomplete; no interiors expansion or older migration resumed.

## Verified criteria

| Criterion | Evidence and result |
| --- | --- |
| Painted look in actual engine | 40 synthetic frozen Godot views plus nine fresh ordinary-input views. All five provenance sheets and critical full-size frames inspected. Shop/counter/path/dock/river groups form one scene; painted oak/canopy diagnostic links tree recipe to shared ground/lighting. No Blender/imagegen output substituted for engine pixels. |
| Concise same-pose comparison | [Day comparison](../evidence/AD008/authoring-20261011/comparison-day-clear.png), [storm comparison](../evidence/AD008/authoring-20261011/comparison-night-storm.png), [metrics](../evidence/AD008/authoring-20261011/comparison.json). Four Maris AD001-to-AD008 and two dock AD006-before-to-AD008 pairs retain exact hero/ally feet, camera transform/projection/zoom, location/resolution and clock/forecast/weather/override metadata. Lighting/materials intentionally differ; shader TIME/NPC startup placements are not pixel-deterministic claims. |
| Projections/zoom/day/night/rain | Maris and dock clear day/storm-night at both projections and0.8/1/1.15; clear night/day rain at both projections/zoom1. Four canopy-on/off pairs at both extreme zooms/projections. Normal size18/FOV45 cameras and ordinary HUD. Detached day11:12/night01:00 presets explicitly synthetic/paused. |
| Walking/contextual Maris interaction | Fresh production startup, no feet/time/weather/fact setup. D preflight moves >0.1m and releases keys. Six `TestRunJourney.walk` routes succeed with unchanged navigation/focus/arrival/stall/owned-release guards. Actual `npc-03-counter` selection, E authored dialogue, live dialogue capture with suspended controls, W refused during dialogue, Esc close/restored fresh controls, WASD dock/return and normal P perspective all pass. Two-member party/Alderwake retained. No choices/rewards, Save/Load/native/release claim. |
| Party occlusion | Four exact feet/camera canopy controls; both central role hue counts improve with protection in every pair. Ortho0.8 cyan/purple1543/1748 vs722/1512; ortho1.15 764/857 vs342/747; perspective0.8 1454/1682 vs533/1459; perspective1.15 658/786 vs260/682. Body visibility inspected. Established AD003 lit-role ratio method, not whole silhouette segmentation.395 trees/106 batches/21 shared materials retained; original shader/shadow bytes unchanged. |
| Samples show no unexplained regression | Five paused120-warmup/120-measured samples below. Matched AD001 Maris day/storm/forest draws unchanged273/284/134. Textures equal AD006 total32,489,873 bytes. AD001 delta25,165,818 bytes exactly matches three existing shared atlas families with two RGB8/mipped resident copies each. AD008 adds no runtime texture/material/node.457 resources constant; prior AD006 fixture454, with new script/GUI/live-dialogue helper references accounting for fixture overhead (inference). Nodes4067-4082 reflect known paused weather-selected rain batches, not geometry changes. No full AD019/process-memory/travel-growth acceptance. |

Fixed orthographic Maris sRGB luma observations: roof50.91→90.06, shaded gable83.33→131.77, final separation41.71; meadow173.97→126.68; storm-night path52.18→96.20, hero54.13→75.86, ally37.79→55.21. Sunlit path215.57 remains above initial205 guidance, as observed in AD007; broad painted variation/role cues remain readable. Bands are representative-midtone guidance, not clipping thresholds. Existing shore highlights/HUD density remain visible limitations; no pixel-perfect concept or town-wide completion claim.

Godot4.7.2 Mono/GL Compatibility960x640, VSync0/max_fps0, orthographic zoom1, ordinary HUD/review banner; pause overlay hidden while sampling. Intel Core Ultra9 185H, RTX4070 Laptop, OpenGL3.3 NVIDIA581.29.

| Frozen view | Frame p95 / p99 ms | Draw p95 | Engine static bytes | Nodes / resources |
| --- | --- | --- | --- | --- |
| Maris clear day | 2.297 / 2.598 | 273 | 134380611 | 4067 / 457 |
| Dock clear day | 2.014 / 2.637 | 236 | 134699003 | 4067 / 457 |
| Maris storm night | 2.275 / 2.993 | 284 | 137131090 | 4079 / 457 |
| Dock storm night | 2.261 / 3.048 | 256 | 137813723 | 4082 / 457 |
| Forest clear day after weather review | 1.437 / 2.212 | 134 | 137822075 | 4082 / 457 |

Nearest-rank paused cadence; engine counters are not process working set. Different historical scheduling prevents attributing lower cadence to an art speedup. Forest retains allocated paused rain batches from earlier coverage. AD019 still owns full active profiling/process memory/travel growth; prior AD006 quay516-draw observation retained for that future gate.

## Commands and provenance

Repository cwd `D:/development/game-dev-blender/returning-fair-prototype`, installed PowerShell7; supplied Godot console exists. [Final runner](../evidence/AD008/20261011-072126312-3325f131/results.json) **9/9 passed**, every exit0, no timeout/forbidden diagnostic; source.changed=false/error=null. Stable1354-file game/tools SHA256 `5b8ed4e5d7ef81ad019de9b56242ebff30542927a72d78d79a05a4babe910917`.

```powershell
./tools/run_checks.ps1 -Task AD008 -Names application_smoke,map_town_art_checks,map_camera_checks,map_water_checks,interaction_dialogue_checks -RenderScript art_direction_pilot_render -RenderPhases pilot,journey -TimeoutSeconds 180
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/AD008/20261011-072126312-3325f131/render/pilot-index.json docs/evidence/AD008/20261011-072126312-3325f131/render/pilot-journey-index.json
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' docs/evidence/AD008/authoring-20261011/verify.py 20261011-072126312-3325f131
```

Engine/version/parse, application, town materials/inventory, camera, water and dialogue gates pass. Town24 structures/16 kit meshes/6110 kit triangles/215 deck modules/165 quay cells/exact168 base samples preserved. Camera330 samples/max error0.0000076912m; water capsule/edge/seam/negative walk-dodge/floor/bounds/dry-nav/party and dialogue/LOS/modal/cancel/save-boundary/unload checks pass unchanged. Capture/comparison helpers exit0; no original test assertions/runner guards changed.

[Synthetic index](../evidence/AD008/20261011-072126312-3325f131/render/pilot-index.json), [ordinary journey](../evidence/AD008/20261011-072126312-3325f131/render/pilot-journey-index.json), [capture provenance/hash report/five sheets](../evidence/AD008/20261011-072126312-3325f131/render/derived/20261011-072317-331e1892/capture-report.json). All49 PNGs inspected through sheets01-05; full-size Maris day/zoom1, storm-night perspective0.8, dock day orthographic0.8, canopy perspective0.8, actual dialogue/return and both comparison sheets inspected. Immutable semantic/floor/all16 terrain-water-riser and every named town triangle/transform fingerprint retained. Recipe resolves all editable/runtime paths and exact component/atlas bytes.

## Attempts, preservation and cleanup

- `20261011-071940361-0daac7b0`: sandbox CIM unavailable at parse preflight. Existing runner retried with reviewed owned-process observation/cleanup escalation. No auto-review rejection/guard bypass.
- `20261011-072000152-9d64a160`: focused checks passed, visual phase rejected fixture's invented constant global node assertion. Existing paused rain varies by camera/weather. Adopted prior AD007 distinction: retain node observations and exact immutable fingerprints. No production/test guard changed or failed-run acceptance.
- Comparison helper first incorrectly required purple red-minus-green >20. Observed shaded purple RGB68/63/162; corrected to AD003 established lit blue-purple ratios, still requiring both-role improvement in every pair. Retained raw attempts.
- [Preservation audit](../evidence/AD008/authoring-20261011/preservation-audit.json):1611 starting paths; only checklist/handoff changed among pre-existing files, exactly three task additions. Accepted game/tools and recipe hashes retained. All original assets/source/mappings/schema8/content1, layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`, user direction/interiors/instructions preserved. CRLF-aware whitespace check passes.
- Unique APPDATA/LOCALAPPDATA/named slots under builds/testing/AD008 for each check/render group. Synthetic review Save/Load disabled; ordinary phase issues no Save. Rule checks use isolated fixture repositories. Ordinary user save directories untouched.
- [Owned PID audit](../evidence/AD008/authoring-20261011/cleanup-pids.json):34 exact launcher/engine PIDs across all attempts, none running. Final visual24028/launcher13444 and journey14640/launcher39616 exit0. Inputs released; no live editor/Blender/process cleanup owed.

Every AD008 criterion complete; no blockers. Unfinished IDs AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020. Implementation stopped before AD009 and commit/push.

## Authorized commit follow-up - 2026-10-11 UTC

The user supplied the separate successful-task commit instruction after review. Reverified all five accepted task hashes,9/9 passing cases/source.changed=false/error=null,1354 game/tools manifest bytes and1609 protected starting paths before documentation-only follow-up edits. Commit scope remains exactly the five task paths listed above. The durable acceptance record, checklist and handoff are included; unrelated direction/prompt/contract/interiors inputs and ignored raw evidence remain excluded. AD008 stays Done; AD009-AD020 stay Pending. Exact verified commit/tree/blob/path identity, normalized line-ending comparison and final working-tree status are recorded after commit in `docs/evidence/AD008/authorized-commit-20261011/commit-audit.json`. No push or AD009 implementation.
