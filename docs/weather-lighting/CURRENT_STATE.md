# Current weather and lighting state

Updated 2026-10-04 (America/Vancouver). W001-W008 Done; W009-W010 Pending.
Only W008 selected and completed this session. No In progress or Blocked W task.
Next eligible: W009 visual matrix/regressions/measured performance; not started.
Read CHECKLIST, CONTRACT, AGENT_PROMPT and [W008 acceptance](W008_ACCEPTANCE.md).

GameSession remains the durable clock/seed/forecast/light authority. One root
presenter and compact time/condition HUD hydrate only a matching committed
WorldHost session/location. Startup, paused restore, unsafe travel/load rollback,
retry, focus, repeated replacement and teardown are verified. Existing session
clock/modal/focus/indoor policies, schema5/content1 and manual save boundaries
remain intact. Active play seconds remain a HUD tooltip. Existing E feedback
shows independent lamp choices and daylight readiness.

GameSession now exposes WeatherConditionService: detached forecast samples,
condition ID/query and thunderstorm-only derived heavy-rain. It owns no scene,
timer, authored event or NPC routine. Restore creates the correct new binding.

Explicit debug --environment-review=<safe-name> loads a tests-only controller,
validates a detached run clone before actor/service binding and starts paused.
Paused focused F7/F8 selects four phases/four real seeded conditions. The synthetic
marker sits above the footer and beneath modals. Save/Load buttons and root
commands reject review; SaveRepository also refuses writes. Namespace is
user://environment-review/<safe-name>/disabled.json. Resume remains usable.
Restart without the flag for normal play. Release does not load the controller
and Windows Desktop excludes tests/. No new save field or forced forecast exists.

Retained W001-W007: 600-second10AM clock, exact v1-v4 migrations, moving outdoor
sun/stable indoor profile, all23 sources/eight local emitters/six independent E
switches, smooth clouds/fixed-world terrain-and-roof-excluded rain/lightning.
Pinned map/art/collision/navigation/IDs and existing settings/F6 behavior remain.
Historical P001-P014/M001-M019 completion records/packages are not new weather
acceptance. Only W009/W010 remain within this workflow.

## W008 changed files

- game/app/game_root.gd, game/app/game_session.gd
- game/core/save_repository.gd
- game/ui/prototype_ui.gd, prototype_ui.tscn
- game/features/environment/weather_condition_service.gd/.gd.uid (new)
- game/tests/environment_review.gd/.gd.uid (new)
- game/tests/environment_lifecycle_checks.gd/.gd.uid (new)
- game/tests/environment_lifecycle_render.gd/.gd.uid (new)
- game/tests/environment_review_flag_checks.gd/.gd.uid (new)
- game/tests/map_activation_checks.gd, map_camera_checks.gd
- tools/run_checks.ps1
- docs/weather-lighting/CHECKLIST.md, CURRENT_STATE.md, CONTRACT.md, W008_ACCEPTANCE.md
- docs/ARCHITECTURE.md, docs/CURRENT_STATE.md, README.md

Map regression expectation now verifies exact nine interactions (three prior
wrappers plus six lamps). Runner supplies fresh per-check --report-dir; these
map checks no longer write fixed historical report paths by default.

## Verification and evidence

W008 lifecycle157 assertions and actual CLI child pass. Startup/load hydration,
exact unsafe rollback, five paused round trips, old rain mesh/material release,
retry facts, focus advancing policy, root teardown, all16 review presets, unsafe
namespace/no-write/focus/active-play rejection and normal-startup isolation pass.
W007193,417, lighting30,053, codec517, switches151 and affected session/save/
dialogue/startup/map-camera/map-activation/ten-travel checks pass. Five retained
historical v4 fixtures migrate/restore in separate writer/reader processes.
Runner guard32 assertions, reference/hash/local-link/UID/status/diff audits pass.
All final runtime exits0 and diagnostic scans clean. Import exits0 with only
known missing .NET SDK10.0.9 editor diagnostic; no C# compilation claim.

Cwd target root; installed Godot4.7.2 ed1daf0bf Compatibility/NVIDIA581.29 at960x640.
Exact commands and criterion mapping: [acceptance](W008_ACCEPTANCE.md).
Raw ignored W008 runs (UTC identifiers; completion date above uses Vancouver):
- prerequisites/import/settings: 20261005-015751766-01786604 (initial parse timeout)
- repaired lifecycle: 20261005-020058372-21931378 (mouse GUI writer failure)
- environment/input/travel regressions: 20261005-020221068-a4c8edba (named checks pass)
- first passing GPU lifecycle: 20261005-020404787-23f8cd24
- save/lighting/dialogue/historical-save regressions: 20261005-020530341-8b9d922e
- final import/lifecycle157/actual CLI: 20261005-020658305-bbb4762f (gate fixture failure)
- repaired map checks and accepted GUI writer/reader: 20261005-021017335-0da5a9df
- final lifecycle157/CLI/layout: 20261005-021211619-0c4da461
- empty-name preflight refusal: 20261005-021401505-f1dc713f (no engine launched)
- final modal layering/startup/five review captures: 20261005-021412163-61bb7717

GUI writer PID41032 and fresh reader58688 restore exact complete snapshot and
forecast, then actual E travel/return. Nine production/GUI images plus five final
review images inspected; initial/repaired sheets and full-size lamp/indoor/review
views show readable HUD/feedback, stable indoor appearance and clear review marker.
Final lifecycle engine17824 and actual flag child38980 exit0; all owned engines
exited, input released. No user editor/Blender was started or modified.

Every runner uses process-local APPDATA/LOCALAPPDATA in builds/testing/W008/<run>/.
Actual user_data: APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Debug main: user://saves/playtest-check-<run>.json; lifecycle/oracle:
user://saves/w008-lifecycle.json and w008-oracle.json. Review disabled slots under
user://environment-review/w008-synthetic, w008-cli or w008-matrix. Normal saves
untouched. Existing runner convention needed no separate build/package staging.

## Repairs, historical evidence and remaining limits

All failed required checks repaired and rerun; no W008 criterion remains unrun
or failed. Reserved parameter, missed mouse-GUI activation, disabled review Resume,
unstable gate fixture and overlapping banner are documented in acceptance; no
input gate or criterion weakened. GUI evidence now uses actual Tab/Enter and E.

First map regression invocation wrote legacy M015/M016 report paths. Camera
report/guide and town guide match retained M018 hashes byte-for-byte. Changed
M015 activation report restored from retained M019/M015-activation-report.json;
SHA2565d298a840f690651619f7ae0e4546bc500c25e46f00b4248df940aec3052963d.
Overwritten W008 output kept in report-recovery-5bafcb979d9446a587083aab42233dc3.
Historical logs/captures/completion summaries untouched. Fresh report paths now
prevent recurrence; recovered historical timings are not new performance evidence.

Clocks/seeds/presets and remote gate placement are synthetic. GPU/viewport GUI
input proves integration, not physical native controls or full quest journey.
No full W009 phase/weather matrix, benchmark, package export, native feature
journey, NPC schedules, audio or wetness mechanics claimed. No subagents, reset,
commit, push, install, source/generator/renderer or unrelated art changes.
Next safe action: select W009 only, verify W008 from current source/acceptance,
then implement its full matrix/regressions/declared measured-performance gates.

Earlier W001-W007 concise acceptance and references remain linked in CHECKLIST.
Prior user-requested testing and settings work remains complete; see parent state
and [tooling acceptance](../TESTING_TOOLS_ACCEPTANCE.md). Raw archives are optional;
future agents need current source/contracts/acceptance, not all historical logs.
