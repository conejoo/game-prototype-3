# Native backpack and bounded rod drag tooling

Requested and completed 2026-10-07 (America/Vancouver). This is a testing-tools
follow-up, not selection or completion of F008/F009/F010.

## Acceptance

- [x] Native key allowlist includes B, delivered through the existing guarded
  scan-code path with matching release.
- [x] Atomic drag accepts integer client endpoints and duration16-5000ms. It
  validates every request coordinate before acquiring input, interpolates a
  straight path with bounded samples, settles press/final preview while held,
  and releases before the next step or request.
- [x] Requested hold/wait/drag time plus fixed50ms click/quit waits cannot exceed
  30000ms. Requests are 1-32 steps; malformed fields/types/coordinates, duplicate
  keys/labels and nonfinal quit are refused before input.
- [x] Existing executable/PID/window/default desktop/foreground guards remain.
  Native left-button acquisition also refuses a human-held button. Pointer bounds
  and foreground are rechecked during motion/waits.
- [x] Cleanup releases only acquired inputs, attempts all releases despite errors,
  retries failures at request end, stops subsequent steps and reports failed step,
  cleanup errors and remaining owned inputs. OS rejection/forced termination cannot
  be guaranteed to release input; these are explicit limits, not silent success.
- [x] Native output supports fresh run children under F001-F010 as well as existing
  P014/W001-W010. Task roots, unknown IDs, sibling prefixes, escapes, reparse-point
  ancestors and capture overwrites remain rejected.
- [x] Versioned and installed gameplay testing skills match and carry the native
  schema, B/drag recipe, pause checks, cleanup interpretation and evidence limits.

## Implementation

`tools/native_input_commands.ps1` separates pure schema validation and bounded
dispatch from Windows interop. `tools/native_input.ps1` supplies the production
adapter; there is no public mock/bypass option in that entrypoint. The same
dispatcher runs deterministic failure tests in `tools/tests/native_input_checks.ps1`.
Failed steps now appear in exclusive schema-2 GUID reports, alongside
requested_duration_ms, failed_step, cleanup_errors, unreleased_keys and
mouse_unreleased. A malformed prelaunch request throws; client preflight failure
after Attach produces a report with no executed steps.

## Verification

PowerShell7, cwd `D:/development/game-dev-blender/returning-fair-prototype`:

- `./tools/tests/native_input_checks.ps1`: PASS, 712 assertions. Covers real JSON
  types, B down/up, exact duration sums, min/max/reverse drag endpoints and every
  sampled client coordinate, all-client preflight before earlier input, focus/input
  failure during drag/hold, partial key acquisition, refusal to release human-held
  inputs, transient mouse release retry, persistent key release failure with other
  keys still released, click/quit regression and F-route acceptance/rejection.
  Compiles the exact production Win32 interop without sending OS input. Fresh-shell
  entrypoint tests refuse the test's PowerShell PID and F010 task-root output before
  creating the output directory. Fixtures:
  `docs/evidence/F010/native-guards-8362ee9f0f1c4258aed16c2eb0f74aba`
  (final entrypoint report-budget revision; earlier passing fixture retained).
- Both skill copies pass skill-creator quick_validate using existing cached PyYAML;
  entrypoint and native reference match byte-for-byte. No dependency installed.
- Intended native/helper/skill diff passes `git -c core.whitespace=cr-at-eol diff --check`.

- `./tools/tests/testing_tools_checks.ps1`: PASS, 134 assertions, including F
  evidence paths, real Windows junction and overwrite refusals, plus existing
  parser/runtime/timeout/save-isolation/phase-gating checks. Retained diagnostic
  fixtures: `docs/evidence/TESTING/20261008-015130349-d6274c5c/results.json` and
  `20261008-015202534-1b4e5a5c/results.json`. UTC Oct8 IDs correspond to local Oct7.
  Initial attempt overlapped separate source-fingerprint tool edits and failed
  before completing the suite; the stable rerun passes. These infrastructure
  results do not establish native gameplay.

## Limits and continuation

No current release was rebuilt or launched, no native gameplay input was sent,
and no normal or release save was touched. The existing Windows package is
historical evidence, not proof of current backpack/drag gameplay. F010 must use a
fresh intended export, native client captures and ordinary gather/backpack/Drop/
drag/recollect plus its exact GUI restart oracle. Atomic drag captures occur after
release; they cannot prove an in-progress preview. Full preview evidence remains
the rendered interaction capture helper's responsibility.

Concurrent runner/source-observation changes belong to separate work and are
preserved. Native helper tests launched no game process; no native cleanup owed.

## Combined implementation recheck, 2026-10-07

Reviewed the current native entrypoint, shared dispatcher, path guards, historical
native caller, merged runner tests and all three repository/installed skill files.
Native B/drag code and concurrent runner guidance are present together; skill files
match byte-for-byte. No overlapping edit erased either implementation.

Found and fixed a missed Windows edge case: capture labels `Shot` and `shot` were
accepted as distinct even though they map to the same Windows filename. Both native
schema validation and the shared capture path guard now compare labels without case.
Added regression checks for schema rejection, shared guard rejection and refusal
before an earlier B press. This defect was in the initial native implementation.

- Native checks: PASS, 715 assertions; exact production Win32 interop compiles.
  Fresh refusal fixtures: `docs/evidence/F010/native-guards-565595dcf765433b8cd0e3f7e1d0887a`.
- Combined infrastructure suite: PASS, 134 assertions. Diagnostic fixture:
  `docs/evidence/TESTING/20261008-021734162-3064e0f5/results.json`; timeout fixture:
  `20261008-021800303-985c8ac0/results.json`. Current suite records stable source;
  deliberate diagnostic/timeout failures remain expected fixture outcomes.
- All native PowerShell files parse; combined tracked whitespace checks pass.
- Concurrent runner observation suite: PASS, 30 assertions, run sequentially after
  infrastructure tests because it intentionally creates/edits owned source sentinels.
  Assertion fixture: `docs/evidence/TESTING/20261008-021921904-75a60ef2/results.json`;
  changed-source rejection: `20261008-021926925-b8fe9764/results.json`. Sentinels
  removed and owned test processes exited. Final combined source still matches the
  stable infrastructure suite's recorded fingerprint.

No OS input or fresh exported gameplay verification added by this recheck. F010
remains pending. Concurrent runner files are preserved.
