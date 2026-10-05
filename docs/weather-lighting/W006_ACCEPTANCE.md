# W006 acceptance

Completed 2026-10-04 (America/Vancouver). W006 was the only selected task.
Initial Git tree was clean. W005 prerequisites verified from current registry,
consumer/asset source, retained acceptance, reference audit and current 13,289
consumer assertions. P/M records, pinned geography and all existing work preserved.

## Criteria and evidence

| Criterion | Verified result |
| --- | --- |
| Typed light action and existing interaction ownership | LightSwitchAction Resource identifies location/prop/source. Six LightSwitch children belong to existing source wrappers, outside VisualRoot, at their existing lantern X/Z anchors with 1.7m reach. Location/interactable validation checks registry switchability, owner identity, location, kind and absence of dialogue. No collision/nav/art/ID or save-schema change. |
| Only marked switchable sources toggle | All six lantern actions pass; all seventeen automatic sources reject commands. Unknown source rejects. GameSession validates committed location and registry before changing EnvironmentState; existing codec rejects automatic overrides. |
| One command produces one change; independent lamps | Real viewport E press/release changes each lamp once. Echo E does not repeat. Expected-enabled compare rejects stale retries. Every prior lamp choice remains unchanged while subsequent lamps toggle. Consumers read session facts with independent materials; 13,289 W005 checks remain passing. |
| Stale/unloaded targets and range/visibility | Root holds WeakRef transient targets, dereferences/reselects immediately and rejects queued, freed, foreign-room, out-of-range and obstructed targets. A real physics wall blocks LOS; lamp-owned sibling collision remains selectable without ignoring another wrapper's blockers. Two headless town/Tollworks round trips rehydrate all six choices without stale targets. |
| Input and combat locks | E and direct interaction commands reject pause, dialogue, journal, application-focus-out, travel, loading, GUI focus, attack, dodge and death. Existing dialogue/quest checks and ten-round-trip travel regression pass. Renderer separately proves pause E cannot change choices. |
| Prompts, feedback and daytime readiness | Turn on/Turn off derives from enabled fact. Real normal movement from fresh start selects lamp02; E arms it with 'Lamp on — ready for dusk.' It stays dark in daylight and emits at forced dusk/night. E disables Dock Row; it remains dark at forced night/dusk while lamp02 stays on. Feedback lasts 2.5 active seconds, belongs to its selected target and clears on travel/load. All images inspected. |
| Explicit GUI Save -> process restart -> GUI Load | Writer PID50060 uses actual pause-menu Save, exits0; reader PID33532 starts fresh with defaults, uses actual GUI Load and restores every snapshot fact exactly against typed repository decoding. Saved day0/progress0.625/seed83464738 and two choices (lamp02 true, Dock Row false) restore exactly. Forecast's exact full-precision JSON string matches across processes: previous cloudy/current rainy, period2, bounds718..1053 authored minutes, blend1. This proves deterministic rules, not rendered rain. |
| Town/Tollworks persistence | Reader uses actual E at synthetically approached gates, visits Tollworks and returns through existing WorldHost transactions. Choices/seed/day retained; progress advances by active play only and is neither reset nor rerolled. Restored on/off consumers visibly match on return. Headless paused round trips additionally preserve exact clock/seed and all six independent choices. |

## Commands and isolation

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Engine: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
`4.7.2.stable.mono.official.ed1daf0bf`.
All Godot runs use process-local APPDATA=`<cwd>/builds/weather-lighting/W006/appdata`
and LOCALAPPDATA=`<cwd>/builds/weather-lighting/W006/localappdata`.
Actual user_data: APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Normal saves untouched. Debug slots begin w006; codec/legacy test directories
also remain inside that isolated APPDATA. Primary render slot:
`user://saves/playtest-w006-render.json`; forecast oracle is task-local test data.

| Command | Result |
| --- | --- |
| Python `docs/weather-lighting/reference/audit.py` | Exit0: four exact sources,23 registry entries,49 forecasts and uint32/clock vectors; pinned geography intact. |
| Godot `--headless --editor --path game --import --quit` | Exit0; GDScript parsing/UID registration clean. Known missing .NET SDK10.0.9 editor diagnostic remains. |
| Godot `--headless --path game --script res://tests/<name>.gd -- --save-slot=w006-<name>` | Seven checks each exit0, runtime ERROR/SCRIPT ERROR/WARNING scans clean: light_interaction_checks, exterior_light_checks, environment_save_checks, interaction_dialogue_checks, quest_checks, location_travel_checks, application_smoke. |
| Focused final `light_interaction_checks` after feedback refinement | Exit0;151 assertions; engine PID19316. Consumers13,289/codec517 and quest/dialogue/ten travel cycles passed before the presentation-only refinement. |
| Godot `--path game --script res://tests/light_interaction_render.gd -- --save-slot=w006-render --phase=write --report-dir=res://../docs/evidence/W006/run-20261004-01/render-162734203` | Exit0; writer PID50060;9 captures, actual E/GUI Save, clean runtime scan. |
| Same renderer command with `--phase=read` | Exit0; reader PID33532;8 captures, separate-process GUI Load/E travel/pause rejection, clean runtime scan. |
| Python `builds/weather-lighting/W006/capture_audit.py <render-dir>` | Exit0;17 actual960x640 images, all verified paused, three contact sheets. All sheets and original day/off/load images inspected. |
| Git `diff --check`, intended diff and local-link/status/UID audit | Pass; records consistent, W006 Done/W007 Pending, only task-owned edits. |

Raw evidence remains ignored under `docs/evidence/W006/run-20261004-01`.
Seven-check metadata: `results-161443605.json` (its initial renderer failed and is
not acceptance). Final focused/renderer metadata: `results-162734203.json`.
Final captures/indexes/sheets: `render-162734203`. Earlier `render-` and
`render-162115724`/`render-162320032` and all failed logs remain intact.
Ignored runner: `builds/weather-lighting/W006/run_checks.ps1 -Import/-Render -Names ...`;
it splits comma-separated names and records exact cwd/arguments/paths/exits/scans.

## Repairs, cleanup and limits

First fixture called nonexistent CombatState.begin_attack; corrected to existing
attack/dodge APIs. Initial runner received comma-separated names as one argument;
split now explicit. No absent-script invocation is counted as a pass.
Freed typed Node arguments failed Godot's argument check before the command guard;
WeakRef now permits safe rejection and is verified after actual room disposal.
Initial normal-movement timing treated D/S as world axes; corrected for current
camera-relative controls, without teleporting the normal startup lamp approach.
Initial forecast oracle compared parsed JSON float-valued dictionaries to typed
integer dictionaries; exact forecast-string comparison now avoids type coercion
and verifies full-precision reconstruction. Save snapshot equality still uses
actual typed decoding. Visual review scoped feedback to the selected lamp.
These are focused repairs; no criterion or input gate was weakened.

Viewport input proves E/GUI integration. Forced review phases and remote gate/lamp
approaches are explicitly synthetic; they do not certify ordinary full-world
movement, OS hardware focus/input, packaged release or weather effects. W007-W010
retain those feature/weather/performance/native gates. Historical packages remain
unchanged. No failed/unrun W006 acceptance criterion remains.

All owned Godot processes exited and keys/buttons were released. Earlier stalled
checks were stopped by exact owned PIDs; their logs/results remain. Existing live
Blender PID2664 and its MCP helpers remain running, untouched this session.
No commit/push/subagent/install/source-generator/renderer change occurred.
Next eligible task: W007 only; not started.
