# W004 acceptance

Completed 2026-10-04 (America/Vancouver). Only W004 selected/implemented.
W003 prerequisites verified from actual artifacts, retained source audit, current
environment codec/rule checks and durable acceptance. Initial Git tree was clean.
No source/map snapshot, historical P/M evidence, normal save or user editor changed.

## Criteria and evidence

| Criterion | Evidence |
| --- | --- |
| One composed presenter / simulation authority | GameRoot explicitly creates one EnvironmentPresenter, injects existing Sun/WorldEnvironment, presents after gated advancement and committed rebinding. Presenter has no timer/session/listener; each root duplicates its Environment. Sampling and repeated replacement checks prove detached samples/resources and stable owner identity. |
| Authored outdoor/indoor profiles / fixture defaults | LocationDefinition validates LightingProfile. Alderwake explicitly OUTDOOR_CYCLE; Tollworks/test room explicitly STABLE_INDOOR; new fixtures default stable. Invalid profile99 fails catalog-definition validation. All current catalog consumers/regressions pass. |
| Coherent 600-second cycle and sun direction | Existing clock12,792 checks verify600-second advance,10 AM origin, wraps and pause/travel gates. Lighting30,053 assertions sample10,001 cycle positions: continuity, wrap seam, downward unit rays, southward cast, evening east/morning west and night/day contrast. Retained source knots/smoothstep and physical adaptation documented in CONTRACT. Actual light basis follows the sampled ray. |
| Smooth daylight/evening/navy night/dawn | Pure sampled color/direct/ambient/background/shadow values interpolate with cubic smoothstep. Both projections viewed at day0,dusk.375,night.625,dawn.875; town, dense forest and Moonwell show distinct warm dusk/navy night/lilac dawn with readable floor/actors. No full-screen tint or competing shadow system. |
| Actors, interaction labels, ground aiming, canopy, guardian telegraphs readable | Inspected all32 phase/room images via eight labeled contact sheets. Maris selected interaction/prompt and cyan floor aim remain legible; hero/ally remain visible under dense-forest canopy treatment and Moonwell elevation in both projections. Eight Tollworks captures show unchanged stable room, readable gold guardian windup and vessel/portal labels. Existing camera ground-aim and combat regressions pass. |
| Stable Tollworks while global clock advances | Three round trips assert exact historical indoor colors/energies/background/rotation/shadow setting; active indoor frames advance the durable clock while light basis remains stable. Four phase captures per projection retain indoor appearance. |
| No flash or abandoned owner during changes | Tests observe profile unchanged before commit; synchronous transition completion already has new committed profile/basis. Failed physical arrival retains original session/room/outdoor presentation. Three round trips retain the same presenter/environment and one location; second PackedScene resource stays independent. Real first committed indoor and return draw captured without settle frames; correct stable/day profile visible around pause overlay. Ten-round-trip regression releases stale rooms and preserves party/health/input gates. |
| Pause/resume | Actual root pause freezes clock and sun basis; resume advances both. Inspected startup pause, night before travel, first committed indoor, first returned night and resumed-then-paused images. Renderer captures use confirmed paused simulation; synthetic review hides overlay only for phase sheets. |

## Commands and isolation

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
installed `4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Before engine runs, process-local APPDATA=`<cwd>/builds/weather-lighting/W004/appdata`
and LOCALAPPDATA=`<cwd>/builds/weather-lighting/W004/localappdata`.
Observed Godot user data beneath that APPDATA at
`Godot/app_userdata/Returning Fair — Prototype`. Named debug slots begin w004;
code-created W003 codec/P005 test directories also remain there. Normal saves
untouched. All processes exited; no held input, live game or editor remains.

Raw evidence: ignored `docs/evidence/W004/run-20261004-01/`.
Rendered run: Compatibility/OpenGL3.3, NVIDIA RTX4070 Laptop driver581.29,
960x640, zoom1, both projections. This is visual review, not a frame benchmark.

| Command / arguments | Exit / result | Local evidence |
| --- | --- | --- |
| Python `docs/weather-lighting/reference/audit.py` | 0; four exact sources,23 lights,49 forecasts/pinned map | reference-audit.log |
| Godot `--headless --editor --path game --import --quit` | 0; GDScript/import clean, known missing .NET SDK10.0.9 editor diagnostic | import-tests.log |
| Godot `--headless --path game --script res://tests/environment_lighting_checks.gd -- --save-slot=w004-lighting` | 0;30,053 assertions; engine PID2624; runtime scan clean | lighting-acceptance.log |
| Godot `--path game --script res://tests/environment_lighting_render.gd -- --save-slot=w004-render --report-dir=res://../docs/evidence/W004/run-20261004-01/render-verified` | 0;37 captures; actual engine PID33540; runtime scan clean | render-verified.log; render-verified/index.json; eight sheet PNGs |
| Eight headless tests below | Each exit0, no runtime errors | regression-results.json and per-test .log |
| Python W004 handoff audit; Git `diff --check` | 0; links/statuses/UIDs/renderer evidence/runtime scans/whitespace | handoff-audit.log; diff-check.log |

Regression invocation for each name:
`--headless --path game --script res://tests/<name>.gd -- --save-slot=w004-<name>`.
Names: environment_rule_checks (12,792), environment_save_checks (517),
environment_session_checks, application_smoke, save_checks,
location_travel_checks (ten round trips plus failed placement), map_camera_checks,
combat_checks. Ignored scoped runner `builds/weather-lighting/W004/run_checks.ps1`
records exact cwd/arguments/isolated paths/exits/scans in regression-results.json.

## Repairs and limits

Initial headless test stalled because its synthetic definition used an ID different
from its physical unsafe fixture. Both owned PIDs49496/50456 were stopped; fixture
ID corrected. Subsequent assertions exposed exact double-vs-engine-float32
property comparisons, including repeated Euler basis representation; tests now
use engine-precision approximate comparisons for those properties, while session
clock/ownership/freeze assertions remain exact. Failed logs retained as
lighting-initial.log and lighting-final.log; final lighting-acceptance.log passes.

Initial renderer produced37 images but rejected one Moonwell aim probe placed
beyond safe floor; no floor hit is correct there. Review now searches nearby
visible floor offsets through the same physical camera query. Corrected run
passes in a separate render-verified folder; original render/log remains untouched.
No camera/floor/aim production policy or acceptance gate was weakened.

Final review caught the pre-travel image still sampling dawn despite its night
label. Review now sets progress0.625 explicitly before that capture and defaults
to a fresh PID/time output directory for future runs. The intermediate render-final
folder/log is preserved; final verified run PID33540 uses render-verified and
passes37 captures with correct pre-travel night metadata and inspected pixels.

Initial sandbox import hit Windows certificate-store access. Outside-sandbox
isolated import/runs removed it; import still reports the known missing .NET
SDK10.0.9. Typed GDScript does not depend on that SDK. No runtime SCRIPT ERROR
or unexpected diagnostic remains in final runtime logs.

Captures force clock phases/party poses and a quest-service lead/guardian windup
in a standalone test process. They prove appearance/profile/pause integration;
they do not prove ordinary movement, full recovery flow, native controls or
process-restart feature persistence. All W004 criteria pass. W005 exterior light
consumers, W006 E switching, W007 weather, W008 HUD/lifecycle review controls,
W009 performance matrix and W010 packages/native acceptance remain unstarted.
Historical schema4 packages unchanged. Next eligible task: W005 only.
