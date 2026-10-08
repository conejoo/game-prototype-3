# Runner diagnostics and source fingerprints

Requested and completed 2026-10-07 (America/Vancouver). This is a testing-tools follow-up;
feature checklist and gameplay durable state remain unchanged.

## Acceptance

- [x] Live console shows case start, periodic progress, case result and log paths.
- [x] Failed cases expose their first diagnostic, available failed assertion/stack,
  bounded log context/tail and retained full log paths in console and results.
  Preflight failures and timeouts receive actionable summaries too.
- [x] SHA256 manifests identify source bytes before/after the run and every case,
  including untracked game/tools source and excluding generated caches. Relative
  paths, additions, removals, modifications and old/new hashes are recorded.
- [x] Observed source changes invalidate exit-zero evidence and stop later checks,
  restart pairs and rendered phases. Hash verification failures fail closed.
- [x] Existing parsing, runtime error scans, import-only diagnostic allowance,
  save isolation, live logs, timeout cleanup and dependent-phase gating still pass.
- [x] Project and installed skill recipes match and explain source scope, source
  stability requirements, checkpoint limitations and summary interpretation.

## Implementation

`tools/testing_runner_observation.ps1` owns source fingerprinting, optional read-only
Git context, bounded log/stack extraction and console failure summaries.
`tools/run_checks.ps1` adds those observations to existing schema-2 results without
removing fields, weakening diagnostic rules or changing production game behavior.
Run/case manifests retain all scoped file hashes, not just Git HEAD. Changes are
compared with the run baseline at case start/end and run end; the changed flag
latches even if a later checkpoint returns to the baseline.

The source scope is game/tools, excluding .godot/__pycache__/.git and pyc/pyo files.
Docs, ignored evidence/staging and external inputs are outside scope. Checkpoints
are not atomic snapshots or a continuous monitor: an edit reverted between them
can escape detection. New UID/import-setting generation requires a stable rerun.
Full logs remain authoritative when summaries truncate long/repeated diagnostics.

## Verification

PowerShell 7, repository cwd, installed Godot console
4.7.2.stable.mono.official.ed1daf0bf. UTC Oct 8 identifiers correspond to local Oct 7.
Evidence remains ignored under docs/evidence/TESTING; reusable fixtures are versioned.

- `./tools/tests/testing_runner_observation_checks.ps1`: PASS, 30 assertions.
  Covers stable byte hashes despite timestamps/cache writes, add/remove/modify and
  case-only rename deltas, real Godot assertion/stack output, generic failures
  not mislabeled as assertions, and linked-source refusal before any launch.
  Real live source mutation records three sentinel deltas, invalidates an exit-zero
  case, stops the later independent check/process pair/renderer, and exits owned PIDs.
  Assertion run: `20261008-015416725-640716e5`; deliberate changed-source run:
  `20261008-015421855-3f2078a1`. Unique source sentinels and junction are removed
  by their owning fixture; temporary scratch/evidence stays in ignored paths.
- `./tools/tests/testing_tools_checks.ps1`: PASS, 134 assertions after final code
  changes. Covers console case boundaries/stacks/log paths, per-case source
  manifests, stable run identity, timeout explanation, five-second running heartbeat,
  existing isolation/environment guards, actual Windows junction rejection, failed
  writer/render gating, parser/runtime-load gates, live pipe drains and cleanup.
  Retained deliberate runtime-error run: `20261008-015515115-3ad8af92`;
  timeout run: `20261008-015541593-b27e3ebb`; final stream heartbeat run:
  `20261008-015631129-530ca69d`.
- `./tools/run_checks.ps1 -Task TESTING -Import -Names application_smoke,testing_support_checks -ProcessScripts foraging_process_checks -RenderScript testing_capture_render -RenderPhases check -TimeoutSeconds 120`:
  PASS, all eight cases. Support 64 assertions; separate-process foraging writer 76
  / reader 79; actual rendered capture/focus/GUI guards pass with three 960x640 PNGs.
  Run: `20261008-015513555-fb8b7f43`. All case before/after and run fingerprints
  match: `abc9dad32b350cc2671b8e630a9242f2941a71a47ecc47af773c3cf92a7f915c`
  over 481 files. No source changes or source-verification error; only the existing
  exact editor-import missing .NET SDK diagnostic is allowed.
- Bundled Python `-B tools/capture_evidence.py <run>/render/check-index.json`:
  validates all three capture manifests/PNG identities and derives a contact sheet
  under `render/derived/20261008-015617-b4e34356`. Inspected all three original PNGs:
  visible pause overlay/Resume focus, stable world frame, settings-preserving world
  capture. Existing capture/pause guarantees remain intact.
- Repository and installed SKILL.md/references/testing-tools.md match by SHA256.
  PowerShell syntax parsing and targeted Git whitespace checks pass (existing CRLF
  tolerance). Skill frontmatter is unchanged; optional skill-creator quick_validate
  could not run because bundled Python lacks PyYAML. No packages installed.

## Retained failures and limits

The first observation run detected a real concurrent native-tool source addition
(`20261008-014706321-d7ac5ad2`), correctly stopped at parse preflight, and therefore
could not reach its intended live mutation fixture. Those unrelated edits were
preserved; the stable reruns above pass. This demonstrates that shared-checkout edits
from another chat invalidate evidence too. This change owns runner observations,
its fixtures and skill recipes, not the concurrent native-input implementation.

A subsequent attempt exposed Windows Get-Content briefly holding results.json
without delete sharing during atomic replacement. Publication now retries the same
staged bytes for at most one second, preserving atomicity; persistent errors still
fail. The final live-reader fixtures pass without weakening source checks.

First import generated assertion_error.gd.uid, correctly invalidating its own run
(`20261008-015027374-bb5df2a6`) despite exit zero. The generated UID is retained as
source; subsequent import and all final runs are stable. Earlier focused/broad passes
were repeated after ordinal path comparison and source-error latching were tightened.

These checks prove checkpointed source identity, not continuous mutation monitoring.
External inputs outside game/tools need their own hashes. Long/multiple diagnostics
may exceed the bounded summary; follow the retained full logs. No feature task,
production save/input format, normal save, export or read-only source game changed
by this follow-up. Owned verification engines exited.

## Reverification after concurrent native-tool work

At the user's request, rechecked the combined workspace on 2026-10-07
(America/Vancouver). No implementation repair was needed. Runner/helper/tests,
native entrypoint/dispatcher, shared path guards and both skill additions match the
last successful source manifest. Reviewed the shared diff: native F evidence-route
support and runner diagnostic assertions are both present; neither overwrote the other.

- `./tools/tests/testing_runner_observation_checks.ps1`: PASS, 30 assertions.
  Fresh real assertion evidence: `20261008-020031608-571beb09`; intentional
  live-source mutation rejection: `20261008-020037055-1efafa4a`. Sentinels cleaned.
- `./tools/tests/testing_tools_checks.ps1`: PASS, 134 assertions, against the
  combined implementation. Deliberate error fixture: `20261008-020123090-9bb75531`;
  timeout fixture: `20261008-020149576-19353ac9`. Diagnostics, stack output,
  progress, isolation, parsing, failure gating and owned-process cleanup pass.
- `./tools/tests/native_input_checks.ps1`: PASS, 712 assertions; exact production
  Win32 interop compiles and entrypoint refusals pass without OS input. Evidence:
  `docs/evidence/F010/native-guards-e15b3ad4c0fa44fea7516d2a66809bff`.
- `./tools/run_checks.ps1 -Task TESTING -Names application_smoke,testing_support_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 120`:
  PASS, six cases; support 64, foraging writer 76 / reader 79 assertions.
  Run: `20261008-020114802-b17cfc04`. Every case/run fingerprint and current
  481-file source still match the recorded
  `abc9dad32b350cc2671b8e630a9242f2941a71a47ecc47af773c3cf92a7f915c`.
  No source changes/errors or owned project processes left running.
- All three repository/installed skill files match: SKILL.md, testing-tools.md
  and native-commands.md. Both skill copies now pass quick_validate using cached
  PyYAML at `C:/Users/aldoc/AppData/Local/uv/cache/archive-v0/yLWQbF3WBl8-3IUO`
  via temporary PYTHONPATH and Python `-B`; the original variable is restored.
  This resolves the earlier optional-validator limitation without installing anything.
  PowerShell syntax and combined tracked whitespace checks also pass.

This is combined source/tool verification, not a new native gameplay or export
acceptance claim. No feature status or production behavior changed during this review.
