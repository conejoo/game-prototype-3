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
run sequentially in their own shared app-data/save group; a failed phase stops the
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
`builds/testing/<Task>/<run>/appdata` and `localappdata` group containers. Each
independent `Names` check gets a distinct slot and child app-data directories.
Each `ProcessScripts` script gets its own group shared only by its write/read
processes; `RenderScript` phases share a separate render group. Sharing is explicit,
never inferred from script names (the same script used in a check and render gets
different groups). Fixed `user://` fixture paths, backups and oracle sidecars are
therefore isolated too. APPDATA/LOCALAPPDATA apply
only to launched processes; caller environment and ordinary saves stay intact.
Schema-2 results record `save_groups` (id, kind, script, slot and directories) and
each case's `save_group`, `save_slot`, `appdata`, `localappdata`. Preflight cases
have null group/slot; top-level app-data paths are containers, not runtime save roots.
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
Atomic report replacement retries transient Windows reader locks for at most one
second; persistent publication errors still fail rather than dropping observations.

Console progress uses `CASE_START` (index, label, timeout and live log paths),
`CASE_RUNNING` every five seconds during engine execution, and `CASE_END` (status,
elapsed time and exit code). These messages do not enter the runner's boolean
case return value. `CASE_DIAGNOSTIC` exposes the first forbidden diagnostic during
execution. On failure, `CASE_FAILURE`, available `ASSERTION` and `STACK` lines,
or a bounded `LOG_TAIL`, plus `FAILURE_LOGS`, make the cause reviewable without
opening every log. `RUN_FAILURE` covers preflight/run errors too. Existing
`RUN_REPORT`, `REPORT` and `RESULT` markers remain unchanged.

Each failed case's additive schema-2 `failure_summary` includes reason/message,
available failed_assertion, the first diagnostic's context (up to 24 lines per
stream), available stack entries and the last eight lines per stream, with
one-based line numbers and stdout/stderr paths. Assertion text is extracted when
the engine/fixture labels it as an assertion; ordinary push_error failures remain
the first diagnostic rather than an invented assertion. Full logs remain authoritative
when several failures or longer stacks exceed the bounded summary. Timeout and
nonzero exits also get summaries; no error-scan allowance or exit rule changes.

## Tested source identity

The runner hashes every file under `game/` and `tools/`, including untracked source,
assets, fixture scripts, support tools and skill recipes. Directory exclusions:
`.godot`, `__pycache__`, `.git`; extension exclusions: `.pyc`, `.pyo`. Links in
the remaining source scope are refused rather than hashed through another checkout.
Evidence, staging, docs and other paths outside these two scopes are not included.
If a scenario depends on additional external inputs, retain their hashes separately.

Before dependency discovery/engine launch, `source-before.json` records sorted
project-relative paths and their SHA256 byte hashes, scope/exclusions and capture
time. Aggregate SHA256 hashes ordinal `path<TAB>hash<LF>` entries, independent of
mtime, machine path and Git state. `source-after.json` repeats this at run completion.
Results `source.before/after` point to these manifests and expose digest/file count.
`source.git` records optional HEAD/dirty/status context using command-local safe.directory;
Git absence does not prevent content hashing or alter Git configuration.

Every case records `source_before/after` and its own manifest paths. Compare each
checkpoint with the baseline: additions, removals and changed bytes produce
`SOURCE_CHANGED` messages and `source_changes` containing relative paths and old/new
hashes. The run latches `source.changed=true`, retains checkpointed changes, fails
even if the engine exited zero, and stops all subsequent checks and dependent
process/render phases. Hashing failures set `source.error` and fail closed.
Finish source edits, then rerun; never relabel changed-source evidence as a pass.
Import can generate new `.uid`/import-settings files in scope, so its first run may
invalidate itself; inspect those additions and rerun after generation settles.

These are before/after observations, not an immutable checkout or a continuous
filesystem monitor. An edit reverted entirely between checkpoints can escape
detection. Keep source stable during verification; the recorded hashes identify
observed bytes, not proof of every resource loaded at every instant.

Tool verification:

```powershell
./tools/tests/testing_runner_observation_checks.ps1
./tools/tests/testing_tools_checks.ps1
```

The observation suite temporarily creates only unique fixture sentinels, edits them
while an owned engine runs, checks invalidation/phase gating, then removes its own
files. Run it without concurrent acceptance runs; its deliberate edits must invalidate
other runs sharing this checkout too.

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

## Fixture save repositories after startup

```gdscript
root.add_child(game)
var startup: Array = await game.world_host.transition_finished
if not startup[0]:
	# Record startup errors and stop the fixture.
	return
var errors: PackedStringArray = TestRunSave.configure(game, "user://saves/my-fixture.json")
if not errors.is_empty():
	# Record errors and stop; do not keep running against the previous repository.
	return
```

Do not assign `save_repository` before startup: GameRoot `_ready()` applies the
runner's debug slot afterward. `TestRunSave.configure` requires a ready root and
completed world startup, refuses transition/load/retry, and accepts only canonical
`user://saves/*.json` paths excluding the normal `returning-fair.json` slot. It
changes the repository reference only, creates no files and never removes backups.
Use the same fixture path in paired restart processes; their shared group supplies
the same user-data root. Standalone SaveRepository codec checks can still construct
detached repositories directly. Verify this helper with `testing_save_repository_checks`.

## Ordinary movement and navigation readiness

```gdscript
var journey: Dictionary = await TestRunJourney.walk(game, Vector3(107.25,0,0), "gate-approach")
traces.append(journey) # Keep failed journeys too.
if not journey.ok:
	_check(false, journey.error)
	return
```

`game` is the current GameRoot. The helper sends viewport WASD press/release events,
selecting chords from the current camera's `movement_direction` every physics frame.
It never places the actor, changes navigation, clears focus, resumes play, or bypasses
input gates. It requires resumed/focused ordinary movement, no modal/hold/drag and
released movement keys; failures return `ok=false,reason,error`. It owns only keys
it pressed and releases them on every post-input success/failure path.
If pause/removal prevents key-up delivery, teardown also removes only its owned
transient accepted movement actions; it never clears unrelated input.

Before walking, it waits for an active world map, the current enabled region owning
the start query, and usable short local route queries across a stable server
iteration. Ownership alone can precede usable path queries; zero-length self-routes
can legitimately be empty. It verifies both the route start
and requested endpoint before sending input; an unreachable requested destination
is reported with its actual path endpoint, never silently snapped. Default arrival
tolerances are 0.16m horizontally and 0.3m vertically for navigation floor rounding.
Use an authored reachable approach, not a point beyond a gate's navigation boundary.

The physics budget derives from path length/current actor speed, allowing steering
overhead. A separate wall budget bounds slow runs. Defaults cap at 12,000 physics
frames/180,000ms; a two-second physics-time watchdog detects absence of route progress.
The optional fourth argument can tighten `max_frames`, `max_ms`, `stall_seconds`,
`goal_tolerance`, `height_tolerance`, `navigation_frames` or `navigation_ms`; unknown,
nonfinite, fractional integer limits and values above defaults fail. Set runner
`-TimeoutSeconds` for the whole scenario, including all journeys and captures.

Successful and failed movement traces retain path length/endpoint, budgets, frames,
elapsed wall time, actual position/next waypoint, accepted movement keys, collision
contacts, controls/focus and camera axes. Pre-input rejections retain the applicable
route/readiness diagnostics. Consume failure immediately; do not continue acceptance
actions at an unverified destination.

For synthetic navigation fixtures, use the same readiness barrier independently:

```gdscript
var ready: Dictionary = await TestRunJourney.wait_navigation(location, anchor.global_position)
_check(ready.ok, ready.error)
```

The region/mesh must already exist. The helper force-updates and checks exact region
ownership plus local path publication rather than sleeping a fixed frame count. Missing/disabled/empty/replaced
regions fail immediately; asynchronous registration has bounded 120-frame/3,000ms
defaults (optional limits up to 600 frames/10,000ms). It does not bake geometry or
prove destination reachability; `walk` separately checks the actual route endpoint.
Production WorldHost arrival synchronization remains authoritative for travel.
Keep synthetic map lifecycle fixtures in their own World3D. Disabling/re-enabling
the full exterior region is not a production restoration contract; an owner query
can succeed while its path queries remain unavailable. Dispose synthetic fixtures
or use actual WorldHost arrival, and consume readiness failures instead of guessing
another fixed sleep.

Verify with `./tools/run_checks.ps1 -Task TESTING -Names testing_journey_checks`.
That check labels synthetic negative fixtures separately from actual viewport
movement; headless success does not establish native input or visual acceptance.

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

FS006 adds bounded debug `F` input and `fishing` observations through the same
opt-in bridge. Observations include mode/phase/token, committed water point,
tension/progress/zone thresholds, held state, result, displayed text/effects and
Reel/Cancel rectangles. They invoke no commands or RNG/time/reward shortcuts.

`await TestRunInteractionCapture.fishing(game, label, directory, kind, note, phase)`
captures `targeting`, `waiting`, `bite`, `fighting` or `result`. It requires automatic
root processing, visible contained HUD, current binding and the phase's actual
actor/effect gates. Four live frames plus post-draw preserve session/location/item
facts and phase/token/result identity. An expired bite or changed result is refused,
with no PNG. Before/after observations and timing accompany genuine live frames;
`capture_evidence.py` validates these separately from paused screenshots. Consume
returned failures. Synthetic pose/encounter/terminal fixtures stay labeled synthetic.

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

For interactions that pause would cancel, use the separate live helper:

```gdscript
# Input and setup belong to the caller; these helpers only observe and capture.
var held: Dictionary = await TestRunInteractionCapture.hold(game, "rod-hold", directory,
	"debug-input", "Actual E held after ordinary WASD approach")
_check(held.ok, held.get("error", "hold capture"))
if held.ok: views.append(held)
# After caller sends E release: final argument false verifies no hold/E/progress.
var released: Dictionary = await TestRunInteractionCapture.hold(game, "rod-released", directory,
	"debug-input", "Actual E release canceled hold", false)
var bag: Dictionary = await TestRunInteractionCapture.backpack(game, "rod-selected", directory,
	"debug-input", "Ordinary B/Enter selects owned rod")
var drag: Dictionary = await TestRunInteractionCapture.drag(game, "rod-preview", directory,
	"debug-input", "Ordinary pointer press/motion; mouse remains held")
# Consume ok/error and append successful results for every call.
```

Helpers require a real renderer, resumed/focused game, hidden pause overlay and
stable session/location/item facts. They check on entry, after each of four process
frames and after `frame_post_draw`. Hold requires actual E ownership, current target,
range/LOS/revision and visible progress; released hold requires no E/hold/progress.
Backpack requires visible modal, focus inside it, disabled world controls and a panel
fitting the settled viewport. Drag requires live pointer ownership, current target/
revision, disabled world controls and a visible ghost mesh. Invalid red previews
are valid capture subjects: their actual errors and nullable foot are recorded.

Captures never send input, pause, stop processing, grant items, or change modal/focus.
Time continues during settling. Start an active hold capture promptly; completion,
cancellation, target disposal or input-mode change returns `ok=false,error` without
writing a PNG. Correct the scenario and start a fresh attempt; do not lengthen the
game's hold or weaken guards to obtain a picture. Use `synthetic` with an accurate
note for fixture placement/presentation; viewport helpers cannot claim `native-input`.
They share the pause helper's overlap lock and evidence path/no-overwrite guard.

Results carry `mode` (`hold`, `hold-released`, `backpack`, `drag`), verified state,
settled frame count, post-draw marker, start/end monotonic ticks, controls/focus,
engine, camera, location, position, snapshot/environment and mode-specific observations.
Put all results in `views`, or retain named `live_frames` (hold/released), `modal_views`
(backpack), and `drag_views` (drag). The contact-sheet tool validates and includes
every present array. Old paused `views` without `mode` remain supported; historical
live captures without these verified metadata must be regenerated, not relabeled.

Verify helper guards using:

```powershell
./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript testing_interaction_capture_render -RenderPhases check -ParseScripts tests/support/test_run_interaction_capture
```

```powershell
python tools/capture_evidence.py <run>/render/write-index.json <run>/render/read-index.json
```

Python validates all manifests/PNGs before creating uniquely named `derived/<UTC>-<GUID>`
contact sheets and a capture-report with source hashes. Images must stay under their
manifest run. Missing pause/provenance/projection/engine identity or mismatched pixel
sizes or failed live-state/settling guards fail. Source failures remain labeled and return failure after deriving review
sheets. Captions identify synthetic/debug/native provenance; native manifests need
actual observed pause/projection metadata. Live captions state their mode and actual
pause flag; a live capture never certifies frozen time. This tool cannot infer normal gameplay
or native hardware input from a PNG. Contact sheets aid review; inspect important
full-resolution images with `view_image` and record findings in the task handoff.
