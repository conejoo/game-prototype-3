# Testing tools follow-up

2026-10-07 follow-up: [native backpack and bounded rod drag](TESTING_NATIVE_INPUT_ACCEPTANCE.md)
adds B, atomic client-space drag, full coordinate preflight, explicit release-failure
reports and F001-F010 run evidence routes. Dispatcher715 and infrastructure134
assertions pass; fresh exported gameplay remains F010 work.

2026-10-07 follow-up: [runner diagnostics and source fingerprints](TESTING_RUNNER_OBSERVATION_ACCEPTANCE.md)
adds case progress, bounded failure/stack summaries and per-case source manifests.
Observed source changes invalidate evidence and stop subsequent checks/phases.

2026-10-07 follow-up: [save isolation and startup-safe repositories](TESTING_SAVE_ISOLATION_ACCEPTANCE.md)
gives independent checks their own save groups and keeps restart phases explicitly shared.

Separate2026-10-07 follow-up: [live interaction captures](TESTING_INTERACTION_CAPTURE_ACCEPTANCE.md)
adds guarded hold/release, backpack and drag helpers, migrates the existing viewport
scenarios, and includes their verified images in contact sheets. Pause guards remain
unchanged. This testing work does not select F008.

Separate2026-10-07 follow-up: [shared journey helper](TESTING_JOURNEY_ACCEPTANCE.md)
extracts camera-relative viewport walking, bounded navigation/path readiness,
endpoint validation and stall diagnostics from the F005 scenario. It is tooling
work after F007; it does not select F008 or alter historical W task statuses.

Completed 2026-10-04 (America/Vancouver), after W008 commit `b28dcea`, at the
user's request. This improves testing infrastructure and guidance; no W009 work
was selected. W001-W008 remain Done and W009 remains next.

## Implemented behavior

- Evidence: TestRunEvidence guards run directories, runner ownership, filenames,
  links and existing outputs. Legacy map/art reports and weather renderers use it.
  Runner rejects known fixed historical destinations before launch. The profiler
  requires a new directory before changing its own report/stage progress files.
- Diagnostics: independent asynchronous stdout/stderr drains flush live logs.
  Atomic results and immediate RUN_REPORT allow observation during a run. A fatal
  diagnostic preserves a short trace drain, then stops only the owned process tree.
  Exit-zero diagnostics still fail; early diagnostic stops differ from timeouts.
- Parsing: a single check-only preload harness compiles selected scripts and their
  literal script/scene dependency closure before executing any fixture. This covers
  runtime-only loads; ParseScripts covers computed paths. Import is a separate gate.
- GUI: TestRunGui uses bounded observed focus and Tab/Enter input, requires a new
  observable outcome and rejects unavailable targets, stale outcomes and failed
  completion. W008 Save/Load/Resume use it. Captures preserve settings/status/focus
  and refuse overlapping captures instead of resetting pause UI.
- Render-only: RenderOnly skips default smoke, requires RenderScript and rejects
  explicit Names. Blank Names normalize predictably. Failed headless checks prevent
  rendered dependent work; failed render phases prevent later phases.

Project and installed gameplay skills carry the same updated entrypoint/reference.
Use [shared testing tools](../tools/skills/returning-fair-gameplay-testing/references/testing-tools.md)
for the maintained commands and API contracts.

## Verification

PowerShell7, cwd `D:/development/game-dev-blender/returning-fair-prototype`.
Installed Godot console `4.7.2.stable.mono.official.ed1daf0bf`; Compatibility for
rendered checks. Runner records arguments, real owned/observed PIDs, exit/scans,
separate APPDATA/LOCALAPPDATA, unique save slot and logs in each results.json.

- `./tools/tests/testing_tools_checks.ps1`: 50 assertions pass, including live
  output before exit, exit-zero error detection, early error-plus-hang stop,
  timeout cleanup, parser/runtime-load/explicit-path rejection before execution,
  renderer phase gating, render-only, environment isolation and a real Windows
  junction rejected by both PowerShell and Godot evidence guards.
- `./tools/run_checks.ps1 -Task TESTING -Import -Names testing_support_checks,testing_evidence_checks -RenderScript testing_capture_render -RenderPhases check -TimeoutSeconds 60`:
  support64 and evidence15 assertions pass, plus actual GPU capture/GUI guards,
  modal/focus restoration, Save/Resume outcomes and three inspected960x640 images.
- `./tools/tests/evidence_writer_checks.ps1`: 11 map writers pass with fresh JSON
  reports. Nine headless checks, rendered tree check and separate save writer/reader
  processes preserve all17 historical paths byte-for-byte or absent.
- `./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript environment_lifecycle_render -RenderPhases write,read -TimeoutSeconds 120`:
  actual GUI Save/new-process Load, exact snapshot/forecast oracle, HUD and E travel
  pass with nine inspected960x640 images. Save and Load retain observed button focus
  and explicit success status. Capture sheets pass manifest/hash/provenance guards.
- ParseScripts validation of asset_gallery, companion_checks, environment_lighting_render,
  exterior_light_render, light_interaction_render, weather_presentation_render,
  settings_debug_checks, map_camera_render and map_performance_profile passes.
  These additional render/performance scenarios were compiled, not rerun as acceptance.
- Project and installed skill copies pass skill-creator quick_validate with existing
  cached PyYAML and match byte-for-byte. No packages installed.

Successful optional archives under `docs/evidence/TESTING/`:
`20261005-024511521-99434f3b` (support/evidence/capture),
`20261005-024705759-748de8ed` (GUI restart),
`20261005-025019678-f05c3d05` (nine writers),
`20261005-025140535-2ab47de3` (tree),
`20261005-025146397-5e029b5d` (save write/read),
`20261005-025032120-6618af55` (additional parse paths).
UTC Oct5 run IDs correspond to local Oct4. Raw runs remain ignored.

## Repairs and limits

Failure fixtures and intermediate failures remain retained. Tests caught an async
drain return value escaping PowerShell's boolean result; suppressing that value
restored the failed-writer gate. Initial writer-suite selection incorrectly ran
tree checks headless and the historical save checks phase containing a deliberately
logged retry failure. Correct renderer/write-read selection passes without allowing
those runtime diagnostics or changing production behavior. A rejected-path fixture
was separated from the fixed-destination source guard before it could launch.

The source-routing guard protects trusted project fixtures; it is not an OS sandbox
against arbitrary scripts. Computed resource paths require ParseScripts. Native
release, full legacy visual matrices and performance benchmarks were not rerun.
No normal save, production input gate, renderer setting or W task status changed.
All owned test engines exited. Next agent may select W009 through the normal prompt.
