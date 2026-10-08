# Save isolation and startup-safe test repositories

Requested and completed 2026-10-07 (America/Vancouver). This is a testing-tools
follow-up; feature checklist and durable gameplay state are unchanged.

## Acceptance

- [x] Independent checks receive distinct debug save slots and APPDATA/LOCALAPPDATA
  directories. Named saves, fixed fixture paths, backups and oracle sidecars cannot
  leak between checks; real filesystem fixtures pass in both check orders.
- [x] Each ProcessScripts script has one explicitly shared write/read group.
  Different restart scripts and the rendered phase group remain isolated, even
  when the same script is also used as an independent check.
- [x] Schema-2 results expose each group's id, script, kind, slot and directories,
  plus effective group/slot/directories for each case. Preflight cases have null
  group/slot. Top-level app-data paths are containers.
- [x] TestRunSave.configure rejects configuration before ready/startup completion,
  during travel/load/retry, after disposal, and for unsafe or normal-slot paths,
  without changing the existing repository. Configuration after startup persists
  across settled frames and actual save/restore, including primary and backup paths.
- [x] Existing startup-sensitive save, quest and map fixtures configure through the
  helper after startup; foraging lifecycle/process fixtures use the same helper.
  Repository and installed testing skills contain matching instructions/recipes.

## Implementation

`tools/run_checks.ps1` creates a save group per independent Names check, per
ProcessScripts restart pair, and for RenderScript phases. Each group owns both a
unique debug slot and user-data directories. Directory isolation also protects
legacy detached repositories that use fixed filenames rather than --save-slot.
Caller environment remains unchanged; failed writers still gate dependent phases.

`game/tests/support/test_run_save.gd` exposes
`TestRunSave.configure(game, path) -> PackedStringArray`. Call it after adding
GameRoot and awaiting a successful world_host.transition_finished; consume errors.
It replaces only the repository reference, creates/deletes no files, and preserves
production GameRoot's debug-slot startup behavior. Paths must be canonical
user://saves/*.json and cannot target returning-fair.json. Detached codec fixtures
may still construct SaveRepository directly.

The runner's prior top-level save_slot is removed in schema 2. Consumers should
read save_groups or the actual case's save_slot/appdata/localappdata fields.

## Verification

PowerShell 7; installed Godot 4.7.2.stable.mono.official.ed1daf0bf. UTC Oct 8 run
identifiers below correspond to local Oct 7. All retained evidence is ignored.

- `./tools/tests/testing_tools_checks.ps1`: PASS, 104 assertions. Includes disk
  sentinels for named/fixed primary, backup and oracle paths; two independent
  restart pairs and a separate rendered pair; effective arguments/directories;
  reversed check order; unchanged caller environment. Existing diagnostic,
  parsing, writer gating, timeout, PID cleanup and evidence guards still pass.
  Main isolation run: `docs/evidence/TESTING/20261008-010416415-ab6a2b20`.
- `./tools/run_checks.ps1 -Task TESTING -Names testing_save_repository_checks,save_checks,foraging_save_checks -ProcessScripts save_process_checks,quest_process_checks,foraging_process_checks -TimeoutSeconds 120`:
  PASS; helper 23 assertions, foraging save 112, foraging writer 76 / reader 79,
  strict save transactions and separate-process save/quest restoration pass.
  Run: `docs/evidence/TESTING/20261008-010517574-e4c14dda`.
- `./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript map_save_checks -RenderPhases write,read -TimeoutSeconds 120`:
  PASS; migrated historical fixture repositories retain all durable fields across
  separate processes. Run: `docs/evidence/TESTING/20261008-010613944-0425fc5d`.
- `./tools/run_checks.ps1 -Task TESTING -RenderOnly -RenderScript environment_lifecycle_render -RenderPhases write,read -TimeoutSeconds 120`:
  PASS; actual GUI Save/fresh-process GUI Load, exact durable snapshot/forecast
  and resumed travel/revisit. Inspected write-gui-save.png and read-gui-load.png:
  pause visible, correct button focused, explicit Saved/Loaded success status.
  Run: `docs/evidence/TESTING/20261008-010630778-836b1f88`.
- Project and installed SKILL.md and references/testing-tools.md match by hash.
  Git diff whitespace check passes with the project's existing CRLF tolerance.

The first helper run retained one failure: a Node-typed function argument rejected
a previously freed object before the helper's validity guard could run. Accepting
Variant and checking validity/type inside the helper fixes that refusal; the full
save run above passes. Initial import/parse succeeded in that retained failed run
(`20261008-010341756-f309fce2`). Deliberate infrastructure failures remain retained.

No production save format/input behavior, normal slot, export, source game, or
feature task status was changed. Owned verification engines exited.
