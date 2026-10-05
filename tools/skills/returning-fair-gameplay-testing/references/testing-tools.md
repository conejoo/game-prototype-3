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
remaining phases. Check fixture semantics before choosing phases. No exports or
installs occur. `EnginePath` permits an explicitly chosen installed executable.

Each run creates `docs/evidence/<Task>/<UTC>-<GUID>/results.json` and logs, plus
`builds/testing/<Task>/<run>/appdata` and `localappdata`. APPDATA/LOCALAPPDATA apply
only to launched processes; caller environment and ordinary saves stay intact.
Results record arguments, cwd, engine version, owned launcher/observed engine PIDs,
exit code, timeout, diagnostics and failure. Unmeasured engine PIDs stay absent;
console launcher PIDs are not presented as engine PIDs. Cleanup kills only the
owned launch process tree, never a name-based list or user editor. Keep the report
and failed runs; do not overwrite or force-add ignored evidence.

Runtime `SCRIPT ERROR`, `ERROR:` and `WARNING:` fail even with exit 0. Only the exact
installed editor-import diagnostic `.NET Sdk not found...10.0.9` is recorded as an
allowed diagnostic; it is not ignored in runtime checks. This exception certifies
GDScript import only, not C# compilation. Parser failures/timeouts are failed cases.

Deliberate failure fixtures live in `game/tests/fixtures/testing_tools`: they are
excluded from release/validation exports. Verify infrastructure itself with:

```powershell
./tools/tests/testing_tools_checks.ps1
# Use installed/bundled Python with Pillow; no new packages required.
python tools/tests/capture_evidence_checks.py
./tools/run_checks.ps1 -Task TESTING -Names testing_support_checks,live_playtest_checks
./tools/run_checks.ps1 -Task TESTING -RenderScript testing_capture_render -RenderPhases check
```

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
the overlay, restores it, and records the verified pause independently. Metadata
includes actual PNG dimensions, engine identity, camera/projection/zoom, location,
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
