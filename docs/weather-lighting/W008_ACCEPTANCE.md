# W008 acceptance

Completed 2026-10-04 (America/Vancouver). Only W008 selected and implemented.
W007 verified against current source, retained acceptance and a fresh 193,417
weather assertions. Initial Git tree was clean. No next W task was started.

## Criteria

| Criterion | Verified evidence |
| --- | --- |
| Startup and restore hydration | One GameRoot presenter writes HUD, sun, weather and location lights synchronously at committed arrival. The gate requires matching WorldHost session and location identity. Startup shows 10:00 AM / Clear; restoring the saved storm shows the exact saved clock/condition before the next frame. Headless lifecycle assertions and real startup/GUI Load captures pass. |
| Failed travel/load retains state | Two unsafe physical anchors reject both travel and detached save candidates. Exact snapshot, session/location identity, HUD, profile, sun energy, rain phase, overcast and flash remain unchanged. Targets/feedback clear at transition start. Existing save/backup/input locks and affected regressions pass. |
| Retry retains durable facts | Synthetic death/retry restores health through the existing safe arrival transaction. Clock remains monotonic, seed/day and independent lamp overrides survive; retry/load gaps explicitly freeze root advancement. No alternate timer or persistent retry fact. |
| Repeated replacement and teardown | Five paused outdoor/indoor round trips retain exact clock/seed/overrides, one presenter and one committed room. Old room/rain nodes and per-owner mesh/material WeakRefs expire. Indoors has zero rain owners; every outdoor arrival immediately hydrates rain. Root teardown frees presenter/location/review owner. Existing ten-round-trip travel checks also pass. These are lifecycle counts, not performance measurements. |
| Compact HUD and light feedback | Header displays source-format time and Clear/Cloudy/Rain/Thunderstorm. Active play seconds remain a tooltip. Actual E lamp action shows Lamp on / Turn off with the normal prompt. Startup, storm, lamp feedback, Save/Load, Tollworks and return captures are readable at 960x640. Indoor HUD reports global weather while indoor appearance stays stable and rain-free. |
| Developer isolation | Debug-only --environment-review=<safe-namespace> loads a controller under tests/, excluded from Windows Desktop exports. It validates an independent session clone before actor/service/WorldHost binding, starts paused and uses user://environment-review/<namespace>/disabled.json. Both root Save/Load and repository writes refuse review sessions; GUI Save/Load disable while Resume remains usable. Actual CLI subprocess, unsafe namespace rejection, all 16 phase/condition combinations, focus/active-play rejection and no-file assertions pass. Normal startup composes no controller. Release gating is current source/export-policy evidence; packages remain W010. |
| Read-only condition service | GameSession owns a query bound to its EnvironmentState; restore gets a new correctly bound service. Returned samples are detached. Only thunderstorm yields heavy-rain; ordinary rain/unknown IDs do not. No routine, authored event, save field or second forecast authority was added. |

## Commands and isolation

Cwd: D:/development/game-dev-blender/returning-fair-prototype.
Godot console: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe,
4.7.2.stable.mono.official.ed1daf0bf. GPU captures use GL Compatibility,
NVIDIA RTX 4070 Laptop driver 581.29, 960x640. Python is the existing bundled
C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.

All engine launches use the bounded shared runner's process-local APPDATA and
LOCALAPPDATA under builds/testing/W008/<unique-run>/. This existing runner
convention required no additional builds/weather-lighting staging or packages.
Actual user_data is APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Debug main slot is user://saves/playtest-check-<run-id>.json; extra lifecycle/oracle
slots are w008-lifecycle.json and w008-oracle.json. The actual CLI child uses
review namespace w008-cli. Normal save remains untouched; nothing is autosaved.

| Command / retained run | Result |
| --- | --- |
| ./tools/run_checks.ps1 -Task W008 -Import -Names weather_presentation_checks,environment_lifecycle_checks,settings_debug_checks -TimeoutSeconds 150; run 20261005-015751766-01786604 | W007 193,417 and settings/debug pass. Import exits 0 with only known missing .NET SDK 10.0.9 diagnostic. Initial W008 review parse error timed out; retained and repaired. |
| ./tools/run_checks.ps1 -Task W008 -Names environment_save_checks,environment_session_checks,light_interaction_checks,location_travel_checks,application_smoke -RenderScript environment_lifecycle_render -RenderPhases write,read,review -TimeoutSeconds 120; run 20261005-020221068-a4c8edba | All five named checks pass: codec 517, session gates, switches 151, ten travel cycles and startup. Initial mouse-GUI writer fails; dependent phases correctly do not run. |
| ./tools/run_checks.ps1 -Task W008 -Names save_checks,environment_lighting_checks,map_activation_checks,map_camera_checks,interaction_dialogue_checks -RenderScript map_save_checks -RenderPhases write,read -TimeoutSeconds 120; run 20261005-020530341-8b9d922e | Save, lighting 30,053, camera 330, dialogue and five historical save fixtures in each of two processes pass. Stale three-interaction map assertion fails; repaired without weakening identities. Historical save writer/reader engine PIDs 39748/62108. |
| ./tools/run_checks.ps1 -Task W008 -Names map_activation_checks,map_camera_checks -RenderScript environment_lifecycle_render -RenderPhases write,read,review -TimeoutSeconds 120; run 20261005-021017335-0da5a9df | Every case exits 0, scans clean. Map identities/routes and camera pass. Actual GUI writer PID 41032 / fresh reader 58688 restore exact full snapshot and forecast via TestRunSnapshot, including independent lamps, then E travel/return. Four writer + five reader captures inspected. Five initial review captures also inspected. |
| ./tools/run_checks.ps1 -Task W008 -Names environment_lifecycle_checks -RenderScript environment_lifecycle_render -RenderPhases review -TimeoutSeconds 120; run 20261005-021211619-0c4da461 | Lifecycle 157 assertions, actual CLI child PID 38980 and review renderer PID 4500 pass, all exits 0/scans clean. Final lifecycle engine PID 17824. |
| ./tools/run_checks.ps1 -Task W008 -RenderScript environment_lifecycle_render -RenderPhases review -TimeoutSeconds 120; run 20261005-021412163-61bb7717 | Final modal-layering repair: startup and five review captures pass. Final review images inspected; no overlap with gameplay or modal text. |
| Python tools/capture_evidence.py with the write/read/review indexes from 021017335 and review indexes from 021211619 and 021412163 | Integrity/provenance/pause checks pass. Two initial sheets plus repaired review sheet and important full-size lamp/indoor/review images inspected. Final accepted set is nine production/GUI views plus five final review views. |
| ./tools/tests/testing_tools_checks.ps1 | 32 assertions pass, including isolation, timeout cleanup, error scanning, failed-writer sequencing and path guards after runner report-path change. Expected fixture failures remain under docs/evidence/TESTING/. |
| Python docs/weather-lighting/reference/audit.py; git diff --check; document link/UID/status audit (cr-at-eol for retained Windows line endings) | Pass. Four source hashes, 23 lights and 49 forecasts unchanged. W008 Done; W009 Pending and next. |

All exact arguments, actual engine PIDs, exits, diagnostic scans and isolated
paths remain in each ignored run's results.json. No engine process or held input
remains from this session. No user editor/Blender was opened or modified.

## Repairs and retained limits

Failures retained: namespace was a reserved GDScript parameter name; mouse GUI
activation did not fire (acceptance now uses real Tab/Enter focus navigation);
an over-broad review busy flag initially disabled Resume; the generalized gate
placement drifted out of selection after unpause (restored the previously verified
0.8m gate approach); review banner initially overlapped gameplay/modal text
(separate bottom panel, drawn beneath modals). Empty -Names was rejected before
any engine launch in run 20261005-021401505-f1dc713f; final run uses normal startup
preflight. All required final checks pass; no W008 criterion remains failed/unrun.

Legacy map tests had fixed M015/M016 report paths. First regression rerun wrote
those paths before this was noticed. Camera report/guide and town guide match
retained M018 hashes byte-for-byte. Changed M015 activation report was recovered
from the retained M019/M015-activation-report.json copy (SHA256
5d298a840f690651619f7ae0e4546bc500c25e46f00b4248df940aec3052963d).
The overwritten W008 report is preserved under report-recovery-5bafcb979d9446a587083aab42233dc3.
Historical logs/captures/completion summaries were untouched. Map checks now
write only when --report-dir is supplied; runner supplies fresh per-check W paths.
Default map-check invocations no longer rewrite historical reports. The recovered
copy is historical evidence, not a new W008 performance claim.

Setup clocks/seeds, review states and remote gate placements are synthetic.
Viewport E/Tab/Enter and actual GPU captures prove integration, not physical native
controls or a full quest journey. Schema5/content1, pinned geography, renderer,
art/collision/navigation/IDs and existing settings behavior remain intact.
No package export, full W009 matrix/benchmark, NPC schedules, audio or wetness
mechanics was attempted. W009 is next; W010 still owns native packages/acceptance.
