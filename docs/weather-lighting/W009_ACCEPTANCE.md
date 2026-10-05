# W009 visual regressions and measured performance

Completed 2026-10-04, America/Vancouver. **Done.** Exactly W009 selected after
current W008 prerequisites passed. W010 remains Pending and was not started.

## Criterion-to-evidence report

Only review/measurement tools and workflow documents change. Production runtime,
schema5/content1, renderer, geography, collision/navigation, assets and normal
save behavior remain as verified by W001-W008. No production optimization needed.
Prior P/M evidence and user work preserved.

| Requirement | Verified result |
| --- | --- |
| Four phases × four conditions at town/forest/bridge/ford, both projections/zoom endpoints | 256 labeled Compatibility captures: four views × two projections × zoom0.8/1.15 × four phases × four conditions. Day/dusk/navy night/dawn and clear/cloudy/rain/thunderstorm distinct. No observed seams, floating/below-ground rain or lost actors. |
| Indoor exclusion; night combat/aim/canopy readable | All64 indoor combinations assert stable sun energy/no rain owner. Four indoor guardian and eight exterior night-storm combat images show readable gold windup, cyan hero, purple ally and turquoise aim. Ground aim tolerance0.15m passes throughout; canopy preserves actors at both endpoints/projections. |
| Six defaults, independent toggles, aligned windows/waylights | Eight source close views cover all six lamps/two waylights; five lamps dark, Dock Row lit. Dedicated window panes aligned, whole walls non-emissive. Consumer13,289/switch151 assertions verify defaults, all identities, independent choices and command/input locks. GUI writer/reader preserves lamp01/02 on and Dock Row off independently. |
| Pause/travel/rollback/new-process persistence | Rain-only frames0.5s apart byte-identical; existing river shader TIME excluded from that narrow test. Unsafe no-floor travel rejects with exact snapshot/location/profile/rain phase retained; paired pixels stable. Actual GUI Tab/Enter Save -> writer exit -> new reader GUI Load restores exact full snapshot/forecast/HUD; actual E indoor/return passes. Setup facts/positions synthetic. |
| Focused environment/save/input plus existing regressions | Lifecycle157/weather193,417 prerequisites and nineteen environment/rule/session/codec/lighting/consumer/input/save/dialogue/combat/companion/quest/consequence/camera/map/slice/travel checks pass; final exits0, runtime scans empty. |
| Full M018 performance method, each run within gates | Independently audited24 unique60s windows, three per view/condition,10s warm-up;341,144 raw frames, exact focus coverage. Same hardware/settings. Worst p95=6.805ms,p99=9.188ms,draw p95=280; every run passes16.67/25/500. Failed focus windows excluded and replaced, never accepted. |
| Repeated travel without accumulating resources/effects | Fresh clean final engine31936 executes12 round trips/24 commits: two warm-up plus ten further,10s idle at each matching checkpoint. Nodes3836/objects7573/resources305/orphans0/nav1/world1/party2 exact stable. One presenter/rain owner,23 consumers/eight emitters/12 rain batches stable. Map inventory unchanged. |
| Memory, raw audit/capture index and durable handoff | Final peak442.33MiB, growth4.08MiB; all contributing engine peaks<=2GiB. Independent corrected raw audit exit0/no errors, CSV hashes/coverage/focus/settings/weather/lifecycle/memory verified. Matrix/GUI289 captures/25 sheets, benchmark24/two sheets, repaired smoke4/one sheet all inspected. Workflow/links/UID/diff consistency verified. |

Reusable [matrix](../../game/tests/weather_visual_matrix.gd),
[profiler](../../game/tests/weather_performance_profile.gd),
[launcher](../../tools/weather_lighting/profile_weather.py) and
[raw auditor](../../tools/weather_lighting/audit_profile.py). Both GDScripts have
UID companions. No normal/native journey or package claim.

## Machine and measurement

Windows11 Home10.0.26200, Core Ultra9 185H,33,736,015,872 RAM bytes,
RTX4070 Laptop driver32.0.15.8129 (581.29); Intel Arc also installed.
Actual renderer is NVIDIA OpenGL3.3 Compatibility,960x640, orthographic zoom1,
VSync0/max_fps0, Godot4.7.2 stable Mono ed1daf0bf. Same declared M018 baseline.

Each view/condition warms10s then receives three60s windows. The profiler inherits
M018 raw monotonic process-frame cadence, total draws including shadows/UI,
navigation queries, map inventory and repeated travel. Full root, actors/AI/UI,
shadows, eight emitters and weather process normally unpaused. Clear-day uses
lamp defaults; storm/night enables all six lamps. Real fully blended seeds have
enough period remaining. Facts reset only between samples; production clock and
weather advance naturally inside each window. Five render frames publish setup
before sampling. Actual window focus is required for every measured frame.

Nearest-rank p95/p99 and draw p95 gates apply to every run, not averages across
runs. Table entries are the worst of three runs in that case. Raw cadence/draw/
process samples, exact frame sequence, duration/focus, forecast stability and
hashes retained. No threshold, renderer, required effect or light removed.

| View | Condition | Runs | Worst p95 ms | Worst p99 ms | Worst draw p95 |
| --- | --- | --- | --- | --- | --- |
| Town/maris | Clear day | 3 | 5.133 | 7.824 | 250 |
| Dense forest | Clear day | 3 | 5.180 | 7.767 | 137 |
| Bridge west | Clear day | 3 | 5.125 | 7.790 | 131 |
| Ford west | Clear day | 3 | 5.218 | 7.760 | 115 |
| Town/maris | Storm night/all lamps | 3 | 6.805 | 9.188 | 280 |
| Dense forest | Storm night/all lamps | 3 | 6.191 | 8.163 | 152 |
| Bridge west | Storm night/all lamps | 3 | 6.337 | 8.341 | 140 |
| Ford west | Storm night/all lamps | 3 | 6.357 | 7.836 | 123 |

Accepted windows compose12 clear-day rows from engine13472, nine town/forest/
bridge storm rows from23152, three fresh ford storm rows from31936. Original
failed records remain intact. Auditor requires those exact24 unique cases,
identical machine/settings, full focus for each chosen row, original faults
exclusively focus in replaced rows, and clean final runtime/lifecycle/memory.
No invalid storm row contributes to the table or accepted capture selection.

Win32 working/peak set samples actual engine PID every0.25s. Final baseline
416,374,784bytes, final420,651,008bytes, growth4,276,224bytes (4.078125MiB);
peak463,818,752bytes (442.33203125MiB). Earlier contributing processes peak
466,026,496bytes and428,232,704bytes, also below2GiB. Original full attempt's
travel/memory also passed; incomplete storm attempt has no lifecycle claim.
Matching final checkpoint inventories:395 trees/21 variants/106 batches,
818 physics nodes,6352 nav polygons,24 structures, seven landmarks,
six terrain/nine riser batches. Navigation query p95=986us; maximum warm
request-to-commit=910.9ms. Final root/party/region identities and disposal checks pass.

## Commands, isolation and evidence

Cwd D:/development/game-dev-blender/returning-fair-prototype. Engine console:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Python is C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe;
$weatherPythonExe below denotes this exact executable.

    ./tools/run_checks.ps1 -Task W009 -Names environment_lifecycle_checks,weather_presentation_checks -TimeoutSeconds 150
    ./tools/run_checks.ps1 -Task W009 -Import -RenderOnly -RenderScript weather_visual_matrix -RenderPhases matrix -ParseScripts tests/weather_performance_profile -TimeoutSeconds 180
    ./tools/run_checks.ps1 -Task W009 -Names environment_rule_checks,environment_session_checks,environment_save_checks,environment_lighting_checks,exterior_light_checks,light_interaction_checks,save_checks,interaction_dialogue_checks,combat_checks,companion_checks,quest_checks,consequence_checks,movement_camera_checks,map_camera_checks,map_activation_checks,map_navigation_checks,map_companion_checks,playable_slice_checks,location_travel_checks -RenderScript weather_visual_matrix -RenderPhases matrix -ParseScripts tests/weather_performance_profile -TimeoutSeconds 180
    ./tools/run_checks.ps1 -Task W009 -RenderOnly -RenderScript environment_lifecycle_render -RenderPhases write,read -ParseScripts tests/weather_performance_profile -TimeoutSeconds 150
    ./tools/run_checks.ps1 -Task W009 -RenderOnly -RenderScript weather_visual_matrix -RenderPhases matrix -ParseScripts tests/weather_performance_profile -TimeoutSeconds 180
    & $weatherPythonExe tools/weather_lighting/profile_weather.py --smoke
    & $weatherPythonExe tools/weather_lighting/profile_weather.py
    & $weatherPythonExe tools/weather_lighting/profile_weather.py --smoke --storm-only
    & $weatherPythonExe tools/weather_lighting/profile_weather.py --storm-only
    & $weatherPythonExe tools/weather_lighting/profile_weather.py --storm-only --ford-only
    & $weatherPythonExe tools/weather_lighting/audit_profile.py docs/evidence/W009/profile-20261005-040811-81ffc9f7 --baseline docs/evidence/W009/profile-20261005-032449-6a0141ed --storm-baseline docs/evidence/W009/profile-20261005-035447-6983ec4f --name raw-audit-corrected.json
    & $weatherPythonExe docs/weather-lighting/reference/audit.py

Raw suffixes below are under ignored docs/evidence/W009/. Runner results retain
exact child argv/cwd/APPDATA/LOCALAPPDATA, PIDs, exits and scans. Profile launch/
hardware/process-results/runtime/working-set/report/CSVs retain equivalent facts.
Future agents need this concise record and reusable fixtures, not raw archives.

| Run suffix | Outcome |
| --- | --- |
| 20261005-031009181-10dec3f8 | Lifecycle157/weather193,417 pass, exits0/clean scans. |
| 20261005-031513405-5c633711 | Import/parse pass; initial matrix exact float32 energy comparison fails after268 captures. Retained. |
| 20261005-031640259-eea41aea | All19 checks/repaired280 matrix pass, exits0/clean scans; matrix engine64328. |
| 20261005-031947535-5c1cc700 | GUI writer45068/reader49544 pass, exits0/clean scans; nine captures. |
| 20261005-032242594-6360b369 | Final280 matrix pass, engine72304 exit0/clean scans. |
| profile-20261005-031959-51da7123 | Initial smoke41880 passes; no full-duration claim. |
| profile-20261005-032449-6a0141ed | Full engine13472 exit1, ten storm focus failures.12 clear-day windows used; all invalid storm rows excluded. Original failed raw audit retained. |
| profile-20261005-035243-0a1da62e | Focus/caption smoke66824 exit0/clean scan, four short storm views/12 trips pass; four captures inspected. |
| profile-20261005-035447-6983ec4f | Engine23152 fail-fast exit1 on ford0 focus loss; nine fully focused storm windows used; failed ford0 excluded. |
| profile-20261005-040811-81ffc9f7 | Engine31936/launcher37988 exit0/clean scan, all three ford windows/full travel/memory pass; corrected combined audit exit0/errors empty. |

Runner appdata: builds/testing/W009/<run>/appdata and localappdata; actual Godot
suffix Godot/app_userdata/Returning Fair — Prototype. GUI isolated slot
user://saves/playtest-check-<run>.json plus w008-oracle.json. Matrix/profiler use
detached user://environment-review/w009-matrix or w009-profile/disabled.json;
Save prohibited and absence checked. Profile appdata:
builds/weather-lighting/W009/<profile-stamp>/appdata and localappdata.
Normal saves untouched; no dependency installs, commits/pushes, source generators,
renderer changes, exports or W010 work.

Matrix/GUI derivation uses tools/capture_evidence.py with final matrix
render/matrix-index.json and GUI render/write-index.json/read-index.json:
final matrix render/derived/20261005-032503-86d500c6,289 captures/25 inspected sheets.
Benchmark derivation uses accepted-local-capture-index.json inside each of the
three contributing original render directories, then passes all three to the same
capture tool: original full render/derived/20261005-041528-fae64c74,24 captures/
two inspected sheets. Repaired smoke derived/20261005-035435-0bf804d1 is also
inspected. Important originals include forest/bridge night combat, Dock Row,
indoor telegraph, GUI feedback and accepted final ford storm. All317 selected
images are real960x640 pixels with verified pause and explicit synthetic provenance.

## Repairs, final audits and limits

Exact literal1.1 equality fails against engine float32 sun energy; approximate
comparison repairs the test without weakening indoor weather exclusion. Close
source camera fixture's stale caption repaired and all280 images rerun. Profiler
banner similarly refreshed to actual phase/condition before later runs.

Ten original storm windows and one later ford window fail real focus coverage.
Foreground requests/checks now precede warm-up/sample, and first invalid sample
stops the attempt. Complete affected three-run case sets are retested; every
invalid row and diagnostic remains retained. Desktop probe was inconclusive;
no security/lock setting or production focus gate changed.

Initial combined audit correctly passed numbers but wrote a file-object string
as source metadata due to a CSV variable alias. Capture selection caught it.
Auditor variable corrected; full audit rerun to fresh raw-audit-corrected.json,
passed again with correct source directories/hashes; previous audit retained.
Capture tool rejected a mixed-directory manifest by design. Per-run local
selected manifests respect its guard; original mixed manifest remains retained.
No capture moved/overwritten or guard relaxed.

Reference audit freshly passes four exact sources,23 lights,49 forecasts and
clock/advance/uint32 vectors. Local links, UID/status consistency and intended
diff verified. CRLF-aware git diff --check uses core.whitespace=cr-at-eol because
existing tracked workflow documents already use CRLF; no repository/global
configuration or historical line endings changed.

Import retains known missing .NET SDK10.0.9; final GDScript runtime scans clean.
No failed/unrun W009 criterion remains. Native Windows packages, ordinary release
controls/quest/save journey and outside-checkout startup remain W010 scope.
All owned Godot processes exited; user Blender2664/MCP helpers preserved.
Next eligible task: W010 only, not started.
