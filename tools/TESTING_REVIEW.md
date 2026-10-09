# Native testing improvements after G009

2026-10-09 UTC. User-authorized testing-tool/skill follow-up, separate from the
completed G001-G009 migration. Implementation made no new migration/task ID,
product change, commit or push. Entry HEAD8a268280d52675e4a034c0867cb08411cfc5a58a. Unrelated docs/fishing/
preserved; packages, normal saves, historical G acceptance and raw native evidence
unchanged. Project skill source updated; installed personal copy untouched.
The subsequent user-approved commit follow-up includes all eight testing tool,
regression and project guidance/review files. Unrelated fishing and ignored
builds/evidence remain excluded. No push or new migration.

## Concrete struggles and priorities

| Priority | Observed problem | Delivered improvement |
| --- | --- | --- |
| High | Native review required scenario-specific bookkeeping, GUID order obscured actual sequence, four sheets in one tool response overflowed context | tools/native_evidence.py audits request/launch/capture/cleanup provenance, sorts actual UTC timestamps, creates small sheets and supports last-N incremental review while auditing the entire input |
| High | Native skill/reference still omitted G009/N018 paths; canonical launch example relied on override alone and reused caller APPDATA | Current guarded path/standalone documentation; fresh APPDATA/LOCALAPPDATA recipe with preflight hashes, outside-checkout cwd and environment restoration on success/failure; existing phase helpers preferred |
| High | EvidenceTask=N018 made a cross-task guard test use N018 on both sides, producing the wrong refusal rather than proving mismatch | Native input checks now deliberately choose the other standalone task for each evidence scope; exercise both N018 and G009 without OS input |
| High | Enter on dialogue initially closed it; early guardian clicks hit hero/floor while camera tracking changed coordinates | Explicit fresh-focus/choice-outcome and fresh-target/short-combat-batch guidance; filenames and successful input requests never count as accepted choices/damage/pause |

The dialogue and combat mistakes were testing assumptions, not demonstrated
product defects. Native execution stayed available despite desktop disconnects;
focus/desktop permission guards were retained. The read-only final-review script
also assumed validation had override.cfg, while its archived predecessor had none;
G009 already repaired that audit to verify actual presence/absence. Its CRLF-only
documentation diff failure was likewise repaired before the successful commit.

## Current verification

- `python tools/tests/native_evidence_checks.py`:44 meaningful synthetic assertions,
  including chronological ordering despite reverse GUID names, exact owner/schema,
  contradictory launch identity, duplicate request/capture claims, bad cleanup,
  orphan/missing/corrupt images, failed requests with retained earlier captures,
  unsafe paths, no source mutation and output overwrite refusal. No OS input.
- PowerShell7 `tools/tests/native_recipe_checks.ps1`:20 assertions. Executes the
  actual documented launch block against generated files and a mock process;
  verifies fresh app-data, caller environment restored after success/failure,
  original exit/provenance contract and missing-PCK refusal before launch. No game.
- Existing `python tools/tests/capture_evidence_checks.py` passes unchanged.
- Native dispatcher/entrypoint guard tests pass729 assertions per scope for N018
  and G009 after correcting the scoped negative vector; production guards unchanged.
- New reviewer exercised against all three actual G009 native folders:1369
  requests/204 captures, zero issues. `--last 12` creates two individually inspected
  sheets; output under ignored docs/evidence/testing-tools/. Final/current review
  outputs are fresh, not replacements of accepted G009 evidence.
- Canonical skill quick validator could not run: bundled Python lacks PyYAML.
  No dependency installed. Unchanged frontmatter identity/constraints, local links,
  current helper contracts, Python/PowerShell syntax and the executed recipe are
  checked independently; this is a narrow existing-skill update, not new metadata.

The native reviewer verifies historical metadata and decoded PNG integrity only.
It cannot establish actual pause/focus, runtime state, accepted choices, native
gameplay success or visual inspection. Scenario-specific clean log, package/hash,
save/forecast/restart/conservation oracles remain required. Failed requests remain
failed even if a prior capture in that request is available for diagnosis. It
does not send input, relax native guards, add setup commands or select a task.

## Remaining recommendations

Read the versioned project skill before relying on an older installed copy.
Synchronizing the personal installation is outside this project-only follow-up;
it can be done separately under appropriate access. No blocker for the project
improvements delivered here.

A generic phase launcher or shared export/archive auditor could reduce N018/G009
duplication if another delivery actually needs them. Keep that refactor demand-led:
the current helpers worked, and touching them now would broaden risk without
fixing the observed testing delays. More native actor/camera/mode observability
would help live aiming, but needs a separate decision about permitted release
instrumentation; no bridge/runtime changes are included here. Use existing
isolated damage checks and fresh captures meanwhile.
