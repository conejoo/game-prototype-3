# Testing tools improvement acceptance

Completed 2026-10-04 (America/Vancouver), after W006. This is the user's testing
infrastructure follow-up; W007 remains Pending and no gameplay task was started.
Existing W006 code, prior evidence, normal saves and packages are preserved.

## Delivered

1. Versioned `tools/run_checks.ps1`: current-file/argument preflight before launch,
   comma-name normalization, explicit installed Godot path, unique per-run app-data
   and slot, monotonic bounded process lifetime, owned process-tree cleanup, logs
   and incremental/final JSON reports. Runtime errors/warnings fail even at exit0.
2. Project/installed Returning Fair testing skill: current API/signature preflight,
   camera-relative movement vectors, bounded short route verification and shared
   tools reference. All three skill/reference files match byte-for-byte.
3. `game/tests/support/test_run_snapshot.gd`: typed SaveCodec/disk comparison plus
   exact full-precision snapshot and reconstructed forecast strings, including the
   writer PID. W006's real two-process GUI Save/Load now uses this helper.
4. `test_run_observation.gd` and opt-in bridge: read-only clock, seed, weather bounds/
   blend/heavy-rain, detached overrides, all23 source identities/defaults/enabled
   values, actual live intensity/material/emitter output, consumer counts, camera
   movement axes/projection/zoom and independently observed pause overlay.
5. `test_run_capture.gd` and `tools/capture_evidence.py`: real-render pause gates,
   declared synthetic/debug provenance, no-overwrite PNGs, camera/pixel/engine
   metadata, source hashes and unique labelled contact sheets. Failed sources stay
   failed. PNG generation/provenance validation does not claim visual acceptance.
6. Native guard permits run children of P014 and W001-W010 only, rejects sibling/
   traversal/junction paths and duplicate/existing capture names. Exclusive PNG
   file creation prevents overwrite races. Existing exe/PID/window/desktop/focus
   checks and finally releases remain intact; embedded C# input code is unchanged.

Usage and helper contracts:
[testing tools reference](../tools/skills/returning-fair-gameplay-testing/references/testing-tools.md).
Generated Python caches remain ignored. New scripts' Godot UIDs remain versioned.

## Verification

From the prototype root with installed Godot4.7.2 Compatibility and PowerShell7:

```powershell
./tools/tests/testing_tools_checks.ps1
python tools/tests/capture_evidence_checks.py
./tools/run_checks.ps1 -Task W006 -Import `
  -Names light_interaction_checks,environment_save_checks,testing_support_checks,live_playtest_checks `
  -RenderScript light_interaction_render -RenderPhases write,read
./tools/run_checks.ps1 -Task TESTING -RenderScript testing_capture_render -RenderPhases check
python tools/capture_evidence.py <run>/render/write-index.json <run>/render/read-index.json
```

Runner/guard32 assertions pass: absent/traversal scripts and absent engine produce
reports without engine launch; comma names produce separate cases; deliberate
runtime ERROR with exit0 fails; the hanging fixture times out and exact owned
launcher/engine PIDs are gone; caller environment remains unchanged and actual
user_data is inside isolated appdata. P014/W001/W006/W010 children pass; invalid
roots/siblings/traversal/junctions fail; old capture content is preserved.
The deliberate ERROR/timeout reports are expected failed fixtures, never passes.

Support64 assertions pass: binary64 timer edges including the largest value below1,
serialized oracle round trips, strict writer-process/forecast/disk/malformed-oracle
rejection,23 live consumer observations, actual emitter energies, detached facts
and headless capture refusal. Existing live bridge and W006151/codec517 regressions
pass. Import exits0, recording only the exact existing missing .NET SDK10.0.9 editor
diagnostic; runtime logs are clean. C# compilation is not certified by that exception.

Real renderer guard passes with two960x640 captures: unpaused, missing overlay,
unsafe label/path, unsupported provenance, missing note and overwrite are refused;
world-only capture restores the overlay. Separate W006 writer/reader pass with17
actual960x640 images: ordinary startup/movement/E, synthetic phase/setup, GUI Save,
fresh GUI Load and E travel persistence. Exact full saved snapshot and forecast
match. Two new contact sheets and relevant original images inspected; helper
migration preserves lamp emission/pools, choices, UI and pause presentation.

Python evidence tests pass: unique outputs, SHA256 integrity, provenance/pause/
projection/engine/pixel/path rejection, and failed source retention. Project and
installed skill both pass skill-creator quick_validate using existing cached PyYAML;
no packages installed. Link/sync/UID/diff checks pass.

Local optional evidence: successful W006 run
`docs/evidence/W006/20261005-000635641-33fb796f` (UTC timestamp; local date Oct4),
17-image derived report `render/derived/20261005-000745-557500c5`;
final capture guard `docs/evidence/TESTING/20261005-001614044-803c0fcb`;
expected failed ERROR/timeout fixtures
`TESTING/20261005-001416408-179ea06f` and `TESTING/20261005-001418309-197e77f7`.
Earlier failed isolation assertion compared forward/backslash strings; normalized
Windows paths fix the assertion, with actual isolation verified. No saved facts
or production gates were weakened. Raw failures remain ignored and preserved.

## Limits and handoff

Native path/no-overwrite logic and PowerShell syntax are verified without driving
a stale release or user window. No new native quest/restart/performance/package
acceptance claim; historical Windows packages remain unchanged. Read-only bridge
is still opt-in/debug-only and release excludes tests. Synthetic setup retains
explicit labels. W007 weather effects remain unimplemented. All owned test engines
exited with no held input; existing user Blender/MCP work remains untouched.
