# W002 acceptance

Completed 2026-10-04 (America/Vancouver). W001 retained audit verified before
implementation. Initial Git tree clean; no unrelated work, normal saves, source
checkout, map snapshot, renderer or old P/M evidence changed. No next task started.

## Criteria and evidence

| Criterion | Verified evidence |
| --- | --- |
| Typed rules/state; single timer authority | EnvironmentClock/WeatherSchedule/EnvironmentState are RefCounted; GameSession.advance atomically publishes environment and existing elapsed time; GameRoot gate unchanged. Root/session test observes active, paused, resumed and travelling frames. |
| 600-second day, 10 AM origin, midnight distinct | Pinned clock/advance vectors, 600-second cycle, midnight at active second 350 without day increment, next 10 AM at second 600 increments day. Source display flooring retained. |
| No lost days on large delta | Fixed advance cases plus 3,600-day delta preserve day/progress; invalid/overflow/cap deltas leave clock and elapsed state intact. |
| Seed lifetime and determinism | Fresh initialization generates uint32 once; failed initialization/reinitialization never replaces initialized seed; advancement/travel keep seed. All 49 pinned forecasts and detached reconstructions match exactly for conditions/periods, blend tolerance1e-6. |
| Uint32 arithmetic | All 15 pinned low32 products match including high-bit/max seeds; 49 forecast cases match pinned hash behavior. Limb multiplication avoids signed int64 overflow. |
| Conditions/duration/transitions/blends | All 100 transition roll values prove 55/45,65/35,75/25 thresholds and sunny->cloudy. 8,192 periods remain within 240..480 inclusive with both endpoints observed. First sunny blend 1; exact period entry blend 0, 7.5-minute blend 0.5, 15-minute blend 1. 1,200 normalized clock boundaries tested alongside each preceding 0.0001-minute sample. |
| Derived condition | Sample.has_rain includes rain/storm; only current thunderstorm yields is_heavy_rain. Fixed vectors cover all four conditions. |
| Invalid input rejection | Negative/out-of-bound days/seeds, progress outside [0,1), NaN/Inf, negative/huge deltas, uninitialized session all reject; no partial mutation/cursor changes. |
| Cached/bounded forecast | Forward queries compute only crossed periods; backward seek/seed changes reconstruct. Returned sample mutation cannot corrupt cache. Seven seeds at day 3650/progress 0.999999999 reconstruct in 42-56 ms in final run; maximum 55.897 ms. 1,000 repeated samples per seed compute no additional periods (maximum 6.327 ms total). Absolute upper bound 21,906 transitions. Actual measured engine PID 28944. These are headless rule costs, not W009 frame benchmarks. |
| Contract gates | environment_session_checks observes real root frames: pause/resume, paused load lock, focus loss clears input while advancing, journal/dialogue advance, travel freezes, Tollworks active play advances, exterior return keeps same state/seed. Application/interaction/travel regressions pass; travel includes 10 round trips and unsafe-placement rollback. Synthetic setup; no native input/rendered evidence claimed. |

## Commands and results

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Engine: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
`4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Before every engine command set process-local APPDATA to
`D:/development/game-dev-blender/returning-fair-prototype/builds/weather-lighting/W002/appdata`.
Confirmed user_data: that path plus `Godot/app_userdata/Returning Fair — Prototype`.
Each debug root receives its explicit W002 save slot below. Normal saves untouched.
Logs under ignored `docs/evidence/W002/run-20261004-01/`.

| Executable/arguments | Exit/result | Log |
| --- | --- | --- |
| Python `docs/weather-lighting/reference/audit.py` | 0; 4 source hashes, pinned map, 23 lights, 49 forecasts/clock/advance/products | reference-audit.log |
| Godot `--headless --editor --path game --import --quit` | 0; scripts imported; known pre-existing .NET SDK 10.0.9 diagnostic, no GDScript parse/runtime errors | import.log |
| Godot `--headless --path game --script res://tests/environment_rule_checks.gd -- --save-slot=w002-rules` | Initial exit 1 (boundary drift); diagnostic exit 1; final exit 0, 12,792 assertions; final runtime/error scan clean | environment-rule-checks.log; environment-rule-diagnostic.log; environment-rule-final.log |
| Godot `--headless --path game --script res://tests/environment_session_checks.gd -- --save-slot=w002-session` | 0; root gates/state/seed; PID 71988; scan clean | environment-session.log |
| Godot `--headless --path game --script res://tests/application_smoke.gd -- --save-slot=w002-app` | 0; composition/input/pause/resume; scan clean | application-smoke.log |
| Godot `--headless --path game --script res://tests/interaction_dialogue_checks.gd -- --save-slot=w002-interaction` | 0; both-room E/GUI/input/modal/save boundaries; scan clean | interaction-dialogue.log |
| Godot `--headless --path game --script res://tests/location_travel_checks.gd -- --save-slot=w002-travel` | 0; ten round trips, rejected IDs/anchors/placement, rollback/input/identity; scan clean | location-travel.log |
| Python `builds/weather-lighting/W002/handoff_audit.py`; Git `-c safe.directory=D:/development/game-dev-blender/returning-fair-prototype diff --check` | 0; fixture bytes match reference; local links and workflow statuses agree; no whitespace errors | handoff-audit-pass.log; diff-check-pass.log |

Fixture `game/tests/fixtures/environment_rule_vectors.json` is byte-exact W001
reference/rule-vectors.json, SHA256 `901900aa699be2609e206ca49fa60a017a3dee06657c9b07bd633b0b7c77690e`. It is target-local test input;
production/export code has no source checkout or reference-Dart dependency.

## Repairs and limits

Initial rule failure exposed `369/1440*1440 = 368.99999999999994` in installed
Godot and Python. CONTRACT records forecast-only absolute 1e-9-minute integer
normalization, tested without changing hashes/vectors or visible transition edges.
Both failed rule logs retained; no condition/period assertion was relaxed.
Initial disposable audit helper failed (missing json import/default Git resolution);
fixed import; Python file/link/status audit passes. Elevated Git uses a
command-scoped safe.directory for this repository (sandbox/elevated ownership
differs); direct whitespace check passes, no global Git config changed. Failed
audit-helper/ownership logs retained.

All W002 acceptance criteria pass. Environment serialization/legacy migration is
W003: existing schema4 saves preserve old facts but reset the new environment on
load and currently initialize a fresh candidate seed. W003 must hydrate the fixed
migration seed/zero clock for v1-v4 and exact v5 state before publishing candidates.
Rendering/lighting remains fixed; visuals/performance/native acceptance unrun as
later-task scope. No required W002 visual/native criterion exists.
No live test process/editor or held input remains. W003 is next eligible task.
