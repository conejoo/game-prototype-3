# AD007 — Storybook day, night and weather lighting

Done, 2026-10-11 UTC. Every AD007 criterion verified; no blocker or cleanup remains. [CHECKLIST](CHECKLIST.md) owns status. Only this task implemented. Next eligible AD008; AD008-AD020 remain Pending. Every item through AD020 complete: **no**. User requested review before a separate commit instruction; nothing staged, committed or pushed.

## Selection, scope and result

Started at HEAD `68146000153cb11a668ecaaeef4711c47f8e5b93`. Starting Git status contained only unrelated untracked `art/direction/`, `docs/art-direction-storybook/AGENT_PROMPT.md`, `CONTRACT.md`, and `docs/interiors-map-migration/`. Read workspace AGENTS, prompt/checklist/handoff/contract/look/baseline, current architecture/weather contract, versioned PLAYTEST/testing skill, installed reference-look-calibration skill, current runtime/light/test owners and AD003-AD006 completion evidence. Instruction inventory found only workspace AGENTS and no applicable `.agents/skills`; supplied Godot console path exists. Opened chosen concept and current painted pilot engine pixels. No other conversation, agent, source checkout or live Blender scene used.

Outdoor presentation now uses cream daylight, softer cast-shadow opacity, restrained apricot dusk, lavender dawn, and brighter pale indigo moonlight. Neutral storm fill retains painted material groups and paths without increasing emission or adding post effects. Existing sun, weather, rain and fixed local lights remain the only owners. Indoor branch stays byte-identical.

Task paths (seven):

- `game/features/environment/environment_lighting.gd`: direct/ambient/background/shadow arrays only; original smooth interpolation, knot positions and sun rays retained.
- `game/features/environment/environment_presenter.gd`: exterior weather color/energy multipliers/floor only. Indoor branch, flash amplitude/composition ownership and shadow-weather multiplier retained.
- `game/tests/art_direction_lighting_render.gd`: reusable paired actual-engine review, derived from existing art/environment/capture support. Direct script-path loading needs no new global class/import; parse closure verifies it.
- `art/source/storybook/lighting-painted-recipe.json`: editable recipe records exact runtime arrays/composition/settings and preservation. GDScript remains runtime source of truth; recipe is not a runtime dependency.
- This acceptance, `CHECKLIST.md`, `CURRENT_STATE.md`.

No authored mesh, UV, texture, wrapper, collision, navigation, feet, light identity/override, clock/forecast/rain behavior, camera/input, scene, indoor profile or durable save/content change. No new node/material/texture/light allocation. No GI/SSR/volumetric fog/blur/renderer dependency. Current SaveCodec remains schema8/content1. Historical R016 remains incomplete; interiors expansion remains separately owned.

## Acceptance evidence

| Criterion | Actual evidence and result |
| --- | --- |
| Four phases/four weather conditions coherent | 65 before +65 after Godot PNGs. Both Maris/Dock Row projections at clear day/dusk/night/dawn; cloudy/rain/storm daytime both projections; noon; clear/storm night at Maris, forest and Moonwell; storm-night dock zoom0.8/1.15 both projections. All six final contact sheets and critical full-size frames inspected. Materials retain distinct quiet groups; dusk no longer overwhelms them with orange, roofs remain indigo and water sea green. |
| No crushed night party/routes | Cyan/purple party and paths visibly readable in both projections, dark forest/canopy cutout and rain. Fixed Maris night path luma68.69→114.19, hero body48.41→80.23, ally34.16→57.93; storm-night path65.39→96.20, hero54.13→75.86, ally37.79→55.21. Role hues remain distinct where floor/body luma overlaps. |
| No washed-out noon plaster | Roof/shaded-gable patch medians88.20/131.16, separation42.97≥35; gable p95133.99, retained brush/beam detail and no white wash. This patch is shaded, so not a claim that every lit plane meets LOOK_SPEC midtone bands. Sunlit path median212.49 is above starting guidance205; existing red-channel clipping remains (before pathR255), broad variation still visible. No additional material correction belongs to AD007. |
| No oversaturated rain | Rainy meadow HSV saturation0.60377 vs calibrated clear0.60294 (difference0.00083); storm0.61224. Muted sage/sea-green/cream groups remain readable, not a blue overlay or neon wash. Clear-night roof saturation0.92683→0.68817. These are declared fixed patch observations, not complete asset masks. |
| Lamps guide attention with cap/override semantics | Existing dock-row lamp off/on through typed `GameSession.toggle_light` in detached synthetic state; visible warm pool remains local. Pixel differences>3 are0.7977% of the310px-high world crop, an upper bound including independent river TIME variation.23 consumers/eight allocated unshadowed emitters retained; maximum active in this coverage1. Existing151-assertion light interaction check verifies E/arbitration/overrides/restore/holds. |
| Rain/lightning visible and intended effects freeze | Actual scheduled flash≥0.179, two normal paused flash views and two isolated rain/flash-only views. Full rain/flash-only PNGs byte-identical after0.5s pause; bounded0.35s resume advances actual rain phase. No rain/lightning timing/shader change.193417 weather assertions plus157 lifecycle assertions retain registration, shelter, transitions, save reconstruction, holds, disposal and recovery behavior. Existing river shader TIME remains independent, intentionally excluded from pause pixel proof. |
| Weather/clock/indoor unchanged |30053 lighting assertions pass unchanged, including10,000 cycle samples, wrap/ray sense, pause/resume, rollback/commit and shared-resource ownership. All12 before/after room captures retain exact indoor light values. Six indoor day-clear/night-storm world-crop pixel pairs per run (three rooms ×two projections) identical; no rain nodes indoors. No routine/forecast/seed/codec production file changed. |

Detailed [comparison/value report](../evidence/AD007/authoring-20261011/comparison.json) verifies52 deterministic pre-resume pairs retain exact feet, ally, camera/projection/zoom/transform, environment metadata/source states, rain/flash phase and sun direction. The bounded-resume view and subsequent room routine placements are not claimed deterministic; indoor light values are compared separately. Physical semantic/floor/all16 render-mesh fingerprints match across before/after and within each run. Nodes4067→4083 within each run as camera/weather/rain selection changes; the same counts occur before and after. Production node owners are unchanged. No physical invariant relaxed to accommodate that expected presentation count.

## Commands, exact results and provenance

All commands below run from `D:/development/game-dev-blender/returning-fair-prototype`, installed PowerShell7. Engine `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`, actual `4.7.2.stable.mono.official.ed1daf0bf`, GL Compatibility,960×640, VSync0/max_fps0; RTX4070 Laptop. Camera orthographic size18/perspective45°, zoom1 plus0.8/1.15 checks. Fixture presets are synthetic detached fully blended forecasts at day_index2 and progress0.05/0.375/0.625/0.875; noon1/12, deterministic scheduled flash search over24s. Paused frozen feet/routines, one typed lamp override and one bounded0.35s simulation resume explicitly labeled. No Save/Load, ordinary route or native input.

```powershell
./tools/run_checks.ps1 -Task AD007 -RenderOnly -RenderScript art_direction_lighting_render -RenderPhases before -TimeoutSeconds 180
```

[Accepted before run](../evidence/AD007/20261011-070114676-bddc30ed/results.json): engine/parse/render3/3 passed, exit0; source.changed=false/error=null; stable1353-file digest`c09a075947570efd2983daaa0097bbbbd6b3e0ca4b78423fd5b6e6cc69d64646`. [65-view index](../evidence/AD007/20261011-070114676-bddc30ed/render/lighting-index.json); [capture audit/sheets](../evidence/AD007/20261011-070114676-bddc30ed/render/derived/20261011-070234-469fabda/capture-report.json). Paired baseline is fresh AD007 current-painted output, not old AD001 art.

```powershell
./tools/run_checks.ps1 -Task AD007 -Names application_smoke,environment_lighting_checks,weather_presentation_checks,environment_lifecycle_checks,light_interaction_checks -RenderScript art_direction_lighting_render -RenderPhases pilot -TimeoutSeconds 180
```

[Final run](../evidence/AD007/20261011-070220411-223c996b/results.json):8/8 engine/parse/five focused checks/render passed, all exit0, no timeout/forbidden diagnostic; source.changed=false/error=null. Stable1353-file game/tools digest`d06d2e5f610727aaf3b60799ae725baac1270754e58976f7a18ebd62342873db`. Recipe/docs are separately fingerprinted in preservation audit. [65-view final index](../evidence/AD007/20261011-070220411-223c996b/render/lighting-index.json); [provenance/hash report and six inspected sheets](../evidence/AD007/20261011-070220411-223c996b/render/derived/20261011-070343-a4bc263e/capture-report.json).

For each accepted index:

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py <index-path>
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' docs/evidence/AD007/authoring-20261011/verify.py
```

Both capture audits exit0/count65/no source failures; comparison helper exit0. Inspected final sheets01-06, full-size `maris-noon-clear-ortho`, `maris-night-clear-ortho`, `maris-dusk-clear-persp`, `dock-night-storm-persp-0_8`, `dense-forest-night-thunderstorm-ortho`, `dock-storm-flash`, plus measured patch diagnostic. These are engine pixels; concept provides direction only. Before sheet01/full-size noon/current AD006 night and paired numerical metrics inspected; not claiming every baseline sheet was opened.

## Retained attempts, preservation and cleanup

- `20261011-070008150-34536268`: CIM sandbox denial at parse process observation. Runner guards unchanged; subsequent runs used reviewed escalation for existing owned-process CIM/cleanup. No automatic approval rejection occurred.
- `20261011-070027029-d880c9f4`: fixture failed because `toggle_light` expects current enabled state, not desired state, and global node count varies with selected rain batches. Corrected expected-state argument. Kept all semantic/floor/render checks exact; node counts retained as observations. No failed capture promoted to accepted baseline.
- Ignored comparison-helper attempts retained in session evidence: corrected project-root parent index and nominal1.1 vs engine float32 representation; before/after indoor values still compared exactly. Discarded an invented requirement that rain must decrease saturation relative to historical rain; task asks for coherent, non-oversaturated rain. Final declared metric compares calibrated rain to calibrated clear (≤0.02 difference), supported by direct pixel review. Corrected ad-hoc RGBA reshape diagnostic to explicit RGB conversion; accepted helper always converts to RGB.
- [Asset/source preservation audit](../evidence/AD007/authoring-20261011/preservation-audit.json) compares1478 starting paths; exactly scoped modifications/additions only. Original source/GLBs/atlases/mappings, layout hash`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`, ordinary saves, direction/interiors/user instructions unchanged. Exact final game/tools bytes match accepted runner manifest. Whitespace audit passes with repository CRLF-aware handling; no baseline regenerated or tests weakened.
- All runner groups use unique `builds/testing/AD007/<run>/appdata` and `localappdata`; review repository isolated and Save/Load disabled. No ordinary user save access. No keys held or live editor changed.
- [Owned PID audit](../evidence/AD007/authoring-20261011/cleanup-pids.json):28 exact launcher/engine/subprocess PIDs checked, none running. Final render engine11288/launcher63272 exited0; lighting/lifecycle subprocesses also exited. No process/input cleanup owed.

No full profiling, native/package/restart, routine completion or overall reference-match claim. Future AD019 still owns full budget gate, including prior AD006 quay516-draw observation. AD008 owns playable integrated Maris/Dock Row pilot and short samples. All AD007 criteria complete; stop here for review, with no staging/commit/push or successor implementation.

## Authorized commit follow-up — 2026-10-11 UTC

User supplied the separate successful-task commit instruction after review. Reverified all seven accepted task hashes,8/8 passing cases/source.changed=false/error=null,1353 game/tools manifest bytes and1474 protected starting paths before documentation-only follow-up edits. Commit scope remains exactly the seven paths listed above. Unrelated direction/prompt/contract/interiors inputs and ignored raw evidence remain excluded. AD007 stays Done; AD008-AD020 stay Pending. Exact verified commit/tree/blob/path identity, normalized line-ending comparison and final status are recorded after commit in `docs/evidence/AD007/authorized-commit-20261011/commit-audit.json`. No push or AD008 implementation.
