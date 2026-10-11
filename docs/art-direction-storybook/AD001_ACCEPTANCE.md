# AD001 acceptance - current art baseline and measurable look brief

2026-10-11 UTC. Status: Done. Selected lowest-numbered eligible task AD001; no AD prerequisites. Final checklist ID is AD020. AD002-AD020 remain Pending; every item complete: no. Stop before AD002. Commit is explicitly deferred to the user's separate instruction after review; no push.

## Criteria and evidence

| AD001 criterion | Verified outcome |
| --- | --- |
| Brief translates selected look into palette/value hierarchy, brush scale, texture/texel-density rules and real-time budgets | [LOOK_SPEC](LOOK_SPEC.md): interpreted sRGB swatches; rendered luma/contrast guidance; metre/screen-pixel brush scales; density by family;1024 shared-atlas/mip/gutter/color-space rules; exact CONTRACT runtime/NPC/light/performance caps. Targets are future implementation guidance, not claims of achieved painting. Reference file SHA verified and pixels inspected. |
| Every affected asset family has current owner/path | [BASELINE](BASELINE.md) names source/runtime/material/UV owners for town/modules, trees, landscape/elevation/water, landmarks, lamps/windows, Maris supplies/gear, eight current NPCs/actions/identity inputs, party/guardian/recovery, forage/rod/fish, all three current interiors and HUD. Actual18 GLBs parsed and18 .blend sources opened read-only; current registry names and material pathways checked. |
| Before/after views reproducible with resolution, camera/zoom, pose, time/weather and HUD mode | Controlled18-frame [baseline index](../evidence/AD001/20261011-044429132-895e7a0f/render/baseline-index.json) records actual960x640, both projections/zoom1, both feet/full camera transform, day2/progress/seed/forecast, HUD/time/profile/sun, engine/PID and detached snapshot. Task-scoped fixture reuses existing pose/review/capture helpers. Actual day11:12 clear and night1:00 thunderstorm pixels agree with metadata; rooms use stable indoor profile. Synthetic placement/restore/quest prerequisite, paused simulation and review banner disclosed. |
| Baseline frame/draw/memory samples are observations, not substitute for full profiling | Six120-frame frozen-scene samples after120-frame warmup; hardware/settings/nearest-rank method, static/texture/buffer counters and node/resource counts retained in BASELINE/index. Explicitly excludes process working-set/travel-growth/full active AD019 acceptance. |
| Reuse existing rendered camera/environment tools and inspect pixels | Existing map_camera_render produced66 PNGs; camera-pose JSON and environment_review reused by controlled fixture. Existing capture_evidence validated/hash-indexed18 controlled PNGs, generating two sheets; both sheets inspected plus full-size final Maris day/night/Tollworks and secondary Maris/forest zoom-bound frames. |
| Preservation and bounded scope | No tracked production/art/source/import/map/physics/UI/gameplay/save file changed. Original sources/mappings/layouts/IDs/feet/colliders and unrelated art/interiors work retained. New test is excluded by both current presets' `tests/*`; no package/export change. R016 remains incomplete historically. |

## Exact execution and outcomes

Cwd for every command below: `D:/development/game-dev-blender/returning-fair-prototype`. Shell: PowerShell7.6.5. Console path verified before launch: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.

```powershell
./tools/run_checks.ps1 -Task AD001 -RenderOnly -RenderScript art_direction_baseline_render -RenderPhases baseline -TimeoutSeconds 180
./tools/run_checks.ps1 -Task AD001 -RenderOnly -RenderScript map_camera_render -RenderPhases baseline -TimeoutSeconds 180
& 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe' tools/art_direction/baseline_inventory.py --output docs/evidence/AD001/source-audit-20261011/inventory.json
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --factory-startup --python tools/art_direction/baseline_inventory.py -- --blend-source-audit --output docs/evidence/AD001/source-audit-20261011/blend-sources.json
& 'C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe' tools/capture_evidence.py docs/evidence/AD001/20261011-044429132-895e7a0f/render/baseline-index.json
```

Final controlled runner: [results](../evidence/AD001/20261011-044429132-895e7a0f/results.json), statuspassed, engine-version/parse-preflight/render-baseline3/3 passed, each exit0, no runtime diagnostics, no timeout, source.changed=false/error=null. Render enginePID24404, launcher67304; actual Compatibility renderer/hardware/isolated user-data provenance in index. Source digest `6aa3a331654ccd7712512d04b5dee6c04ca09ff54f51ffbd14724777e7040f19`, files1315, unchanged before/after. Render phase28.01s includes captures/samples/room setup, not benchmark duration.

Existing camera survey: [results](../evidence/AD001/20261011-044217805-f44d2253/results.json), statuspassed,3/3 phases exit0, no diagnostics/timeouts/source changes; enginePID52048, launcher2256. Source digest `9077f09fbf292254902941172e98fee8e9a8280904ce99b906162ef6ed4d11ee` is the earlier task-fixture version; only task-local fixture/helper changed afterward, not surveyed production camera/art. Survey's live advancing clock is explicitly excluded from fixed-time material comparison; no ordinary tour/motion claim.

Both runners create fresh ignored `docs/evidence/AD001/<run>` and `builds/testing/AD001/<run>`. Per-render APPDATA/LOCALAPPDATA and named save slots are in results.save_groups; no ordinary user saves touched. Controlled run initializes review-only session and disabled review save repository; no Save/Load operation performed. Capture helper requires observed pause overlay, preserves focus/settings, waits fourframes/frame_post_draw and uniquely writes PNGs. No OS native input or held keys/buttons used.

GLB/source inventory commands each exit0,18 rows. Blender version `5.2.2 LTS`, build `d13f752e3b9c`; separate background process ended with `Blender quit`, never saved/exported sources or altered a live editor. Blender emitted `Material.use_nodes` deprecation warning; installed Python emitted a location-resolution warning about bundled Blender Python but still executed successfully. These are recorded authoring-tool diagnostics, not suppressed Godot errors. No installation/change to MCP/preferences. The text-to-blender runtime skill supplied installed tool paths; no live MCP capability is claimed.

Capture evidence command exit0:18 provenance-valid views, no source failures, status `ready-for-visual-review`; two actual sheets subsequently inspected. [Derived report](../evidence/AD001/20261011-044429132-895e7a0f/render/derived/20261011-044525-3937487d/capture-report.json) contains PNG hashes/source manifests. Art acceptance is based on inspected pixels, not that helper status alone.

## Retained attempts and deliberate fixture adaptations

- `20261011-043919322-21b66bb7`: initial sandbox runner failed parse-phase bookkeeping because read-only CIM child-process provenance was unavailable; exit1. Retried authorized runner with reviewed escalation, retaining isolation/ownership guards.
- `20261011-044000983-f2b15ee8`: parse gate caught task fixture's nonexistent `Condition.STORM`; exit1. Corrected to current `THUNDERSTORM`; no production enum/test weakened.
- `20261011-044036726-cf63f380`: engine/parse/render initially passed,18 images/six samples; pixel inspection found old10:00/clear HUD despite new preset metadata, guardian absent. Excluded from final controlled baseline. `environment_review.initialize` detached session after startup while current root owners still referenced old session. Corrected only task fixture through existing same-map restore/rebind lifecycle; added actual HUD-time agreement check and sun/profile/guardian observations. No production helper/root modification.
- `python` PATH alias could not launch; used verified existing skill Python3.13.13. Workspace dependency lookup was unavailable for this delegated task; no dependency install required.

Unrun by scope: unrelated gameplay suites, ordinary door/input/native Save/Load/restart, natural routine/day replay, full profiling, painted asset creation and exports. None is an AD001 acceptance requirement. AD019/AD020 and historical R016 retain their separate required gates. No AD001 criterion remains unrun or blocked.

## Changed paths, cleanup and continuation

Task changes: `docs/art-direction-storybook/{LOOK_SPEC,BASELINE,AD001_ACCEPTANCE,CHECKLIST,CURRENT_STATE}.md`; new `game/tests/art_direction_baseline_render.gd`; new `tools/art_direction/baseline_inventory.py`. Existing AGENT_PROMPT/CONTRACT, all task definitions, art/direction and interiors plan remain byte-preserved. Raw captures/logs/inventories/app-data remain ignored under established evidence/build locations.

Runner-owned processes exited0; final Godot/Blender process inventory showed none. No live editor, input, temporary standalone package or cleanup owed. Final read-only audit PASS: all31 preservation pins plus18 GLB hashes (49), selected SHA, source stability, exactly one Done task,20 rows/final AD020 and61 local document links. `docs/evidence/AD001/source-audit-20261011/final-audit.json` records results; final current game/tools source snapshot still matches `6aa3a331654ccd7712512d04b5dee6c04ca09ff54f51ffbd14724777e7040f19`/1315 files; `git diff --exit-code` returned0. Commit not performed; separate post-review instruction owns it.

Next eligible ID AD002. Exact next action: read LOOK_SPEC/BASELINE and controlled Maris captures, inspect existing town source/import/vertex-color multiplication, then implement only painted Maris shop/counter pilot while retaining source outlines/heights/bench bodies/interaction ownership. No successor work started here.

## Authorized commit follow-up - 2026-10-11 UTC

After reviewing successful AD001, the user separately instructed committing its task changes, acceptance report, checklist and handoff. The earlier no-commit statements describe the implementation-turn boundary, now satisfied. Stage only the five changed Markdown files listed above, `game/tests/art_direction_baseline_render.gd` and `tools/art_direction/baseline_inventory.py`. Preserve and exclude untouched `AGENT_PROMPT.md`, `CONTRACT.md`, `art/direction/` and `docs/interiors-map-migration/`. Raw generated evidence/build data remain local under the established ignore policy; this durable acceptance report carries their reviewed outcomes and paths.

Verify exact staged scope/bytes, preservation hashes and tested game/tools source identity before committing. Post-commit exact hash/tree/status and verified file bytes are recorded in ignored `docs/evidence/AD001/authorized-commit-20261011/commit-audit.json`, avoiding a self-referential hash edit. No push, production edits or AD002 implementation are authorized by this follow-up.
