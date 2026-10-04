# W003 acceptance

Completed 2026-10-04 (America/Vancouver). Selected only W003; existing uncommitted
W002 files preserved. No source checkout, pinned map, normal save, historical
fixture/provenance, old P/M evidence, renderer or live user editor was changed.

## Criteria and evidence

| Criterion | Evidence |
| --- | --- |
| Exact v5 round trip | environment_save_checks: exact clock/progress/uint32 seed, all six real lantern overrides and nonzero prior health/quest/effects/trust/upgrade/time facts; detached candidates and tuple sorting without caller mutation. |
| Actual light registry | All 23 identities/effective defaults/switchability match compact W001-derived oracle, independently audited against reference inventory. Six switchable lantern keys only; automatic windows/net/waylights remain pinned defaults. |
| Strict validation | Missing/extra envelope/environment/record fields, wrong types, NaN/Inf, negative/out-of-bound/fractional days/seeds, progress1, unknown/map/source IDs, automatic sources and agreeing/conflicting duplicate tuples reject. Numeric uint32/day edges pass. Malformed runtime overrides refuse save without changing good bytes. |
| Exact numeric persistence | 305 Python repr/struct/Decimal binary64 vectors, including signed zero, subnormals, random clocks/elapsed times and ties-even. Last supported clock double at day3650 survives real filesystem/backup. Escaped timer keys work; duplicate timer lexemes fail. |
| Deterministic v1-v4 migration | Four exact independent legacy shapes decode twice identically, preserve every previously available fact, add only documented defaults/ally/consequences as appropriate. V4 retains trust/reactions/upgrades. Existing five historical v4 fixtures load through real root/physical placement; checked-in bytes unchanged. |
| No reroll / additive content1 | Decode supplies validated EnvironmentState before candidate initialization; only fresh successful initialization generates seed. All prior content IDs/definitions/spawns unchanged; strict schema5 adds only environment/overrides. |
| Read never rewrites | Each legacy primary/backup byte string unchanged after read; explicit Save publishes validated v5. Corrupt primary recovers backup without rewrite. Newer primary/backup cannot be overwritten or silently replaced by older backup, including a newer envelope with duplicate clock tokens. |
| Physical restore rollback | save_checks gives live and candidate different clock/seed/override facts; both unsafe arrivals leave live environment object/facts/forecast, session/world/wrapper bindings, positions, pause/input gates intact. map_save_checks retains nav/ally-placement rollback, locks, arrival anchors and lifecycle. |
| Separate process | Writer PID28244 and reader PID18380 use same isolated debug slot; reader starts fresh in Alderwake, pause/Load restores Tollworks, health37/43, elapsed42.5, day146/progress0.6180339887498948/seed4294967295, all six overrides and identical reconstructed forecast. Synthetic setup; no native/manual journey claim. |
| Affected regressions | Environment rules/session gates, application startup, save IO/backup/version/rollback, quest, companion legacy/party restore, consequence/40-damage tests pass. Map check: five historical fixtures, 24 room replacements, five rejections and five retries. |

## Commands, isolation and results

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
`4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Before engine commands, process-local APPDATA=`<cwd>/builds/weather-lighting/W003/appdata`
and LOCALAPPDATA=`<cwd>/builds/weather-lighting/W003/localappdata`.
Confirmed user_data=`APPDATA/Godot/app_userdata/Returning Fair — Prototype`.
No global environment variable/config change. Final engine checks ran outside
sandbox after its Windows certificate/editor-cache diagnostics, using these same
isolated paths. All test processes exited; no GUI input/held keys occurred.
Raw logs stay ignored at `docs/evidence/W003/run-20261004-01/`.

| Command/arguments | Exit/result | Final log |
| --- | --- | --- |
| Python `docs/weather-lighting/reference/audit.py` | 0; 4 exact sources, pinned map, 23 lights, 49 forecasts/rule vectors | reference-audit.log |
| Godot `--headless --editor --path game --import --quit` | 0; scripts/UIDs imported; only known missing .NET SDK10.0.9 editor diagnostic | import-final.log |
| Godot `--headless --path game --script res://tests/environment_save_checks.gd -- --save-slot=w003-environment_save_checks` | 0; 517 assertions; PID38484; runtime scan clean | environment_save_checks-complete.log |
| Godot `--headless --path game --script res://tests/environment_rule_checks.gd -- --save-slot=w003-environment_rule_checks` | 0; 12,792 assertions / all49 forecast vectors; scan clean | environment_rule_checks.log |
| Godot `--headless --path game --script res://tests/environment_session_checks.gd -- --save-slot=w003-environment_session_checks` | 0; active/modal/focus/pause/travel/indoor gates; scan clean | environment_session_checks.log |
| Godot `--headless --path game --script res://tests/save_checks.gd -- --save-slot=w003-save_checks` | 0; IO/backups/version locks/root restore/physical environment rollback; scan clean | save_checks-complete.log |
| Godot `--headless --path game --script res://tests/quest_checks.gd -- --save-slot=w003-quest_checks` | 0; exact v1 and quest/effect/restore; scan clean | quest_checks-final.log |
| Godot `--headless --path game --script res://tests/consequence_checks.gd -- --save-slot=w003-consequence_checks` | 0; trust/upgrades/exact legacy/physical40 damage; scan clean | consequence_checks-final.log |
| Godot `--headless --path game --script res://tests/companion_checks.gd -- --save-slot=w003-companion_checks` | 0; migration/party/navigation/combat/restore; scan clean | companion_checks-acceptance.log |
| Godot `--headless --path game --script res://tests/application_smoke.gd -- --save-slot=w003-application_smoke` | 0; composition/input/pause; scan clean | application_smoke-acceptance.log |
| Godot `--headless --path game --script res://tests/save_process_checks.gd -- --phase=write --save-slot=w003-process` | 0; PID28244; isolated `saves/playtest-w003-process.json`; scan clean | process-write.log |
| Same script/slot with `--phase=read` | 0; independent PID18380; exact facts/forecast/party/arrival; scan clean | process-read.log |
| Godot `--headless --path game --script res://tests/map_save_checks.gd -- --save-slot=w003-map --report-dir=res://../docs/evidence/W003/run-20261004-01/map` | 0; fixtures5/replacements24/rejections5/retries5; only expected synthetic retry diagnostic below | map-save.log; map/checks-report.json |
| Python `builds/weather-lighting/W003/handoff_audit.py`; Git `diff --check` | 0; links/statuses/registry/fixtures/clean runtime scans; whitespace clean | handoff-audit.log; diff-check.log |

## Repairs, failed runs and limitations

Initial codec assertions exposed default JSON output rounding, then the installed
reader's rounding of the last double before1. Both failures and arithmetic/literal
diagnostics remain in local logs; no time bound or exactness assertion was relaxed.
SaveRepository uses full_precision for primary/backup; SaveNumber performs bounded
precise timer decoding. One test mismatch was JSON float/int dictionary comparison;
tests normalize JSON numeric types while comparing exact clock values/bits directly.
Independent oracle found signed-zero constant folding; zero now constructs from
integer0. [Contract](CONTRACT.md) records numeric token/exponent spelling limits
and version-protection ordering. Final 517 assertions pass, including all305 vectors.

Initial sandbox imports reported cache/settings write and certificate errors;
LOCALAPPDATA isolation and outside-sandbox rerun removed them. Import still reports
the existing missing .NET SDK10.0.9; no GDScript parse/runtime failure remains.
Map test intentionally emits exactly `ERROR: Retry placement failed: M009 expected
navigation bake rejection` while proving failed retry cannot heal/replace party;
this is an expected synthetic diagnostic, not a native or production failure.

All W003 criteria pass. Rendering remains fixed; no E switching/presentation,
render matrix, new frame benchmark, rebuilt packages or native acceptance claimed.
Old packaged schema4 builds are historical and need rebuilding for later work.
W004 moving sun/location profiles is next eligible task; not started.
