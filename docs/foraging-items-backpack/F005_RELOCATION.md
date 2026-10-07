# F005 runtime anchor relocation

Historical relocation-only checkpoint; subsequent [F005 acceptance](F005_ACCEPTANCE.md)
completes activation. Pending statements below describe that earlier boundary.

User approved relocation on 2026-10-07, America/Vancouver. Geometry blocker resolved;
F005 remains **Pending** for world adapters/held interaction acceptance. This follow-up
implements the requested relocation only; no F006 or held-interaction work started.

- Rod default: (-8,0,15.75) -> **(-6.5,0,15.75)**, centre of existing east dock spur.
- Flower01 default: (26,0.25,-2) -> **(26.75,0.25,-2)**, same terrace east of cliff.
- Flower02/03, original pinned map/source records, colliders/nav and all IDs unchanged.

ForagingRegistry keeps original ROWS and exposes authored_foot separately from runtime
foot via two explicit RUNTIME_FEET overrides. Future adapters must use runtime foot.
Existing saved rod overrides/drops keep their exact feet; same collected IDs preserve
absence. Uncollected defaults adopt new positions. Schema6/content1 unchanged; no
migration/disk rewrite is needed, since default positions are not stored in saves.

Updated transaction assertions distinguish source from runtime mappings. Repurposed
foraging_anchor_checks from blocker reproduction to relocation safety; old blocker runs
and [F005_BLOCKER](F005_BLOCKER.md) remain labeled historical. Diagnostic checks all four
runtime feet with real synchronized production physics: five supported dry floor probes
at centre/+/-0.22m X/Z, normal/height gates, clear radius0.4m/height1.6m capsule, same-room
nav point and capsule-sampled arrival route, spawn/portal reservations, dock containment
for rod, clear nearby capsule and sight ray within1.5m. Original feet remain in reports.

Repository-root PowerShell7 command:

```powershell
./tools/run_checks.ps1 -Task F005 -Names foraging_anchor_checks,foraging_transaction_checks,foraging_save_checks,reference_mapping_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150
```

PASS: docs/evidence/F005/20261007-202154715-207af0c2/results.json. Parse, all four anchor
geometry/LOS probes, transaction587 assertions, save111, historical mapping4 nodes/
1,648 capsule samples and independent-process writer52/read55 exact whole-save oracle.
Final anchor report: checks/foraging_anchor_checks/anchor-relocation-report.json; all
geometry_errors/containing_blockers/los_blocker/failures empty. Full results/stdout/stderr
inspected: no diagnostics/timeouts/failed cases. No new classes; parse gate sufficient,
no import needed. Installed console4.7.2 path verified.

Command-local Get-FileHash SHA256 comparison against reference/manifest.json also PASS:
three target geography, three local reference and twenty source pins unchanged. The
historical reference_mapping check intentionally diagnoses old source feet; it must not
be used as relocation proof. New anchor check provides current runtime geometry proof.

Runner isolated APPDATA/LOCALAPPDATA/save slots under builds/testing/F005/<run>;
normal save untouched. Synthetic probes, no ordinary walking/gathering/rendered/native
proof. No scene pickups exist yet; these are production registry defaults for F005.
All runner-owned processes exited; no editor/live game or cleanup owed. Preserved prior
uncommitted blocker/state/probe work and all historical records. Reviewed intended diff,
links/status consistency; no source/map refresh, LOS bypass, installs, agents or exports.

Next eligible **F005**: blocker removed by explicit user decision and verified runtime
feet. Implement wrappers/holds with approved registry coordinates, complete remaining
F005 acceptance, then stop. F005 has not been marked Done. [CONTRACT](CONTRACT.md) owns
updated mapping authority; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.
