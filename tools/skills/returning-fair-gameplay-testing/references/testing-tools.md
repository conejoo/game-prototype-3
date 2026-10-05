# Shared testing tools

Run from `D:/development/game-dev-blender/returning-fair-prototype` using PowerShell 7.
Godot `--path` is `game/`. These tools do not select or start a checklist task.

## Bounded runner

```powershell
./tools/run_checks.ps1 -Task W006 -Import `
  -Names light_interaction_checks,environment_save_checks,application_smoke `
  -RenderScript light_interaction_render -RenderPhases write,read -TimeoutSeconds 120
```

`Names` accepts arrays or comma-separated names without `.gd`, including test
subfolders. Every name/phase and the installed console executable must preflight
before any engine starts. Default headless check: `application_smoke`. Render phases
run sequentially in the same isolated app-data/save slot; a failed phase stops the
remaining phases, and a failed headless check prevents rendered phases. Check fixture semantics before choosing phases. No exports or
installs occur. `EnginePath` permits an explicitly chosen installed executable.

Use `-RenderOnly -RenderScript testing_capture_render -RenderPhases check` to omit
the default smoke check. `-RenderOnly` requires a renderer and rejects explicit
`-Names`; an empty `-Names ''` is also normalized to no checks. Before runtime, one
generated `--check-only` harness preloads selected scripts and recursively discovered
literal `.gd`/`.tscn` references, including runtime `load()` branches. Missing embedded
paths may be deliberate negative fixtures; explicitly requested scripts must exist.
For computed paths, add `-ParseScripts tests/environment_review,app/game_root` (paths
relative to `game/`, optionally `res://` and `.gd`). The report records `parse_scripts`.
Use `-Import` after adding scripts/classes. Import success does not replace parsing.

Each run creates `docs/evidence/<Task>/<UTC>-<GUID>/results.json` and logs, plus
`builds/testing/<Task>/<run>/appdata` and `localappdata`. APPDATA/LOCALAPPDATA apply
only to launched processes; caller environment and ordinary saves stay intact.
Results record arguments, cwd, engine version, owned launcher/observed engine PIDs,
exit code, timeout, diagnostics and failure. Unmeasured engine PIDs stay absent;
console launcher PIDs are not presented as engine PIDs. Cleanup kills only the
owned launch process tree, never a name-based list or user editor. Keep the report
and failed runs; do not overwrite or force-add ignored evidence.

`RUN_REPORT=<path>` appears immediately. Results publish atomically; stdout/stderr
flush line by line while the case runs. Inspect those files during a stall. A forbidden
diagnostic starts a short 250ms trace-drain window, then kills the owned process tree
if still running. `stopped_on_diagnostic` distinguishes early failure from timeout.
Final pipe drains retain stack traces/output even on failed checks.

Runtime `SCRIPT ERROR`, `ERROR:` and `WARNING:` fail even with exit 0. Only the exact
installed editor-import diagnostic `.NET Sdk not found...10.0.9` is recorded as an
allowed diagnostic; it is not ignored in runtime checks. This exception certifies
GDScript import only, not C# compilation. Parser failures/timeouts are failed cases.

Deliberate failure fixtures live in `game/tests/fixtures/testing_tools`: they are
excluded from release/validation exports. Verify infrastructure itself with:

```powershell
./tools/tests/testing_tools_checks.ps1
./tools/tests/evidence_writer_checks.ps1
# Use installed/bundled Python with Pillow; no new packages required.
python tools/tests/capture_evidence_checks.py
./tools/run_checks.ps1 -Task TESTING -Names testing_support_checks,testing_evidence_checks,live_playtest_checks
./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript testing_capture_render -RenderPhases check
```

## Evidence output guard

`TestRunEvidence.directory()` resolves `--report-dir`; `path(filename)` reserves a
new safe basename and creates its directory; `write_json(filename, data)` writes
full-precision JSON. It rejects task-root destinations, paths outside project evidence,
links, existing files/directories and destinations differing from the runner-owned
`RETURNING_FAIR_EVIDENCE_DIR`. Use the runner's fresh output, or a fresh task/run
subdirectory for standalone checks. Never ignore an empty path/failed write.

All legacy map/art report writers and weather renderers now use this guard. Map
activation/camera retain standalone no-report mode. The performance profiler retains
`--profile-output` as a standalone alias but requires a new directory; its progress
report/stage files may change within that reserved run. Runner source preflight rejects
known fixed historical P/M/W destinations in the discovered scripts. This is a guard
for trusted project fixtures, not an OS sandbox against arbitrary script writes.

## Verified GUI focus and outcome

`await TestRunGui.activate(game, button, outcome, max_steps=16, max_frames=600)` uses
viewport Tab/Enter press/release pairs. It requires a real renderer, verified pause
overlay, visible/enabled target inside that overlay, a valid predicate initially false
and an observed focus route. Missing focus, an excluded/cyclic route, changed pause,
disabled/hidden target or exhausted limits returns `ok=false,error`. It activates once,
then waits for the predicate; it never retries clicks or invokes callbacks directly.
Callers must fail on `ok=false` and choose a predicate establishing the intended effect.

Use `Saved.` status plus isolated file/typed disk verification for Save; `Loaded`
status and `not game.loading_save` plus the exact oracle for Load; resumed tree and
enabled controls for Resume. W008's `environment_lifecycle_render` demonstrates
separate-process Save/Load using this helper. Native release still requires native
observed input; this helper proves viewport/debug GUI integration only.

## Exact restart oracle

`game/tests/support/test_run_snapshot.gd` owns these methods:

- `oracle(session)`: writer PID, schema, full-precision sorted snapshot JSON and
  exact forecast JSON (condition/previous/period/bounds/blend/heavy-rain).
- `compare_restored(session, oracle, typed_disk_session)`: requires a different
  reader PID, exact durable snapshot matching both oracle and independently decoded
  disk, and exact forecast. Returns errors; the caller must fail on any error.
- `weather(environment)` and `exact_json(dictionary)`: detached review values and
  canonical full-precision encoding. Never compare parsed JSON number dictionaries
  to native int/float dictionaries or round timer/blend values.

Capture the oracle immediately after actual GUI Save at a stable pause checkpoint.
Start a fresh process, verify defaults before Load, invoke actual GUI Load, then
compare with `SaveRepository.read(catalog).session`. Unit fixtures may explicitly
pass `require_new_process=false`; acceptance restart evidence must keep the default.
Resumed travel advances time: assert its specific invariants separately.
W006's renderer is the working two-process example, with synthetic phase/setup
clearly labeled. Helpers do not turn synthetic setup into normal-play evidence.

## Read-only bridge observation

`observe` additionally returns `pause_overlay_visible`, `camera_controls` (projection,
zoom, size/FOV and camera-derived movement vectors), and `environment`:
clock/day/progress/display time/absolute minutes, weather seed and exact sample,
sorted detached overrides, location lighting profile, consumer/emitter counts and
all registered source IDs/defaults/switchability/effective enabled values. Presented
sources also report actual consumer intensity, material emission, emitter energy
and visibility. Indoor sources remain registered but `presented=false`, with no
invented intensity. Observation never invokes a gameplay command or changes durable
facts; forecast caching is transient. Release retains no bridge.

## Real captures and contact sheets

`await TestRunCapture.capture(game, label, directory, kind, overlay, note)` requires
a real renderer, paused tree and visible pause overlay. `kind` must be `debug-input`
or `synthetic`; `note` must describe setup/input. Safe labels, project evidence
paths and no-overwrite checks precede capture. World-only review temporarily hides
the overlay, restores it, and records the verified pause independently.
The capture changes only overlay visibility and restores prior focus; it preserves
settings/status instead of calling the UI's modal-resetting `show_paused()` method.
Concurrent captures are refused. Evidence routing uses TestRunEvidence's guard.
Metadata includes actual PNG dimensions, engine identity, camera/projection/zoom, location,
position, saved snapshot and environment. Consume `ok/error`; never discard failure.

```powershell
python tools/capture_evidence.py <run>/render/write-index.json <run>/render/read-index.json
```

Python validates all manifests/PNGs before creating uniquely named `derived/<UTC>-<GUID>`
contact sheets and a capture-report with source hashes. Images must stay under their
manifest run. Missing pause/provenance/projection/engine identity or mismatched pixel
sizes fail. Source failures remain labeled and return failure after deriving review
sheets. Captions identify synthetic/debug/native provenance; native manifests need
actual observed pause/projection metadata. This tool cannot infer normal gameplay
or native hardware input from a PNG. Contact sheets aid review; inspect important
full-resolution images with `view_image` and record findings in the task handoff.
