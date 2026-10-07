# F003 acceptance — atomic item/resource commands

Completed 2026-10-07, America/Vancouver. Exactly F003; F004 not started.
Initial target HEAD `20dfbecdbddcc21c6ea58a36bb1f5f2d99cca73a`, worktree clean.
Fresh F002 inventory prerequisite passed before marking F003 In progress.
No existing user changes overwritten; source, geography and normal save untouched.

## Criterion evidence

Final `foraging_transaction_checks`: **583 assertions**, zero failures. Both stdout
and tracked-run report agree. Fixtures exercise pure commands with injected synthetic
placement validators; they do not prove physical placement, input, walking or restart.

| Acceptance criterion | Result and evidence |
| --- | --- |
| +1 and collected origin committed together | PASS: flower gather and authored rod pickup update inventory and unique sorted collected IDs before exactly one committed signal. Observer snapshots record joint facts; no silent equip. |
| Duplicate/unknown/wrong-room/stale grants nothing | PASS: unknown/alias/source-namespace/resource mismatch, wrong operation, wrong committed/authored/generated room, duplicate origin, removed drop and queued token reject. Each rejection compares a snapshot captured BEFORE the call, checks exact revision/counts/active/facts/placements and checks zero publications. |
| Full bag/stack leaves facts unchanged | PASS: flower99 and20-type synthetic manifests retain uncollected origins and active selection. Full bag blocks authored and generated rod pickup, retaining placement. Existing flower98 grows to99 in a full20-type bag; next flower rejects. |
| Authored move replaces origin | PASS: three successive same-ID overrides create one placement, retain original uncollected identity and total rod1. Invalid subsequent move keeps prior override. Pickup removes override and marks original collected atomically. |
| Dropped pickup removes placement | PASS: generated pickup commits bag1 and removes placement while original remains collected; deterministic generated ID never enters collected set. Wrong-room/missing/duplicate pickup cannot grant a rod. |
| Repeated drop/pickup preserves rod1 | PASS: eight drop/move/pickup cycles alternating supported Alderwake/Tollworks locations, with rod_count1 asserted in every completion observer and after each command. Default/override share one authored origin; generated placement and bag are exclusive. |
| Rejected placement keeps counts/active ID | PASS: missing/unbound/malformed/rejecting capability, nonfinite coordinates, unsupported room, nonmovable item, bad identity and stale token preserve exact snapshots. Rejected generated/authored moves retain prior feet. Callback-triggered selection/travel invalidates pending placement before any command-owned consumption/world commit. |
| Successful final drop clears active | PASS: selected bag rod becomes one generated placement, bag count0/active null, original suppressed, total rod1 before observers run. |
| Structured results and post-commit publication | PASS: accepted/errors/operation/instance/item/revision/detached placement inspected. Integer-token signal avoids shared mutable payloads; each observer reads a detached snapshot. Nested commands/capability rebinding reject command_busy during validation/publication. Second observer sees intact facts after first mutates its own snapshot. Rejections emit nothing. |
| Session/capability/metadata boundary | PASS: exact four F001 feet and item/resource/location identities compared to pinned vectors; bad registry fails before session service publication. Snapshots/results/callback inputs cannot mutate owned facts. Session services isolated; WeakRef avoids session ownership cycle and orphan commands reject. |

Generic InventoryState add/consume remain F002 rule APIs. Synthetic fixtures can create
invalid bag+origin or missing-rod states; F003 rejects both as rod_ownership_conflict
rather than spawning/duplicating rods. Production rod collection/drop/move uses ForagingState.

## Delivered API and decisions

- GameSession owns InventoryState and ForagingState. ForagingRegistry pins exactly four
  authored identities/feet independently of scenes or source checkout. Registry content
  references validate before item services publish.
- ForagingState gather/pickup take location, instance, resource identity and expected
  revision; drop/move additionally use typed Godot-metre feet/item identity. Root will
  reselect/revalidate physical target in F005/F007; this task adds no input route.
- ForagingCommandResult returns accepted/errors/operation/instance_id/item_id/revision
  and optional detached WorldItemPlacement. Rejection never signals completion.
- WorldItemPlacement holds exactly contract identity/location/feet/provenance/origin
  facts; authored_override replaces origin; generated_drop uses dropped-fishing_rod.
  No aliases, arbitrary movable items or cross-room move supported.
- bind_placement_validator accepts a Callable taking detached typed candidate and
  detached full snapshot, returning PackedStringArray (empty means valid). Missing,
  freed, malformed or rejecting capability fails closed. Service validates identity,
  provenance, supported location and finite feet first. F007 owns measured geometry;
  F004 must inject strict candidate geometry validation before save/session swap.
- Revision combines world-command/capability revisions with successful inventory
  mutations and changed selection. Treat as opaque monotonic equality token, not a
  command count. World+inventory transaction may advance it twice. It is transient,
  starts0 for fresh sessions, and is excluded from persistence. Inventory snapshot
  shape remains unchanged. Callback revalidation includes committed location/token.
- committed(revision) fires only after bag, active selection, collected facts and
  placements commit. Busy guard spans validation/publication; no global bus/autoload.
  Validator must not own/mutate session facts; tests deliberately exercise stale
  callbacks to prove world-command rejection. Command does not undo unrelated callback
  mutations such as selection or travel.
- No world/UI/hold/drag/save/art/export activation. Schema5/content1 retained and
  SaveCodec still excludes inventory/collected/placements. F004 owns persistence and
  restored facts. P/M/W historical package acceptance unchanged.

## Commands and actual outcomes

All commands from `D:/development/game-dev-blender/returning-fair-prototype`.
Installed Godot console verified first:4.7.2.stable.mono.official.ed1daf0bf.
PowerShell7 runner commands:

```powershell
./tools/run_checks.ps1 -Task F003 -Names inventory_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F003 -Import -Names foraging_transaction_checks,inventory_checks,content_catalog_checks,application_smoke,save_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F003 -Names foraging_transaction_checks,inventory_checks,content_catalog_checks,application_smoke,save_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F003 -Names foraging_transaction_checks,map_activation_checks,environment_save_checks,location_travel_checks -TimeoutSeconds 150
```

- Prerequisite PASS: `../evidence/F003/20261007-182122692-f0e545dc/results.json`,
  inventory199 assertions, clean parse/diagnostics.
- First import PASS, parse FAIL: `../evidence/F003/20261007-182622044-53f5ad0e/results.json`.
  Retained `direct-parse.log` identifies extra closing parenthesis in test callback
  at then-line209. Fixed fixture syntax; no checks claimed from this failed run.
  Import generated five script UIDs and registered classes successfully; only allowed
  editor diagnostic: `ERROR: .NET Sdk not found. The required version is '10.0.9'.`
- Acceptance/regressions PASS: `../evidence/F003/20261007-182714901-8301608f/results.json`.
  Transaction573 assertions at this revision; inventory199, catalog, application
  startup and actual save IO/backup/version/atomic-restore regressions pass.
- Final refined acceptance/map/environment/travel PASS:
  `../evidence/F003/20261007-182823373-7e09f842/results.json`.
  Transaction583 assertions in `checks/foraging_transaction_checks/foraging-transaction-report.json`;
  environment codec517 assertions; production map and ten physical scene travel round
  trips with lifecycle/rollback/pause/focus/grounding/input-gate checks pass. This
  headless synthetic travel is not ordinary player-input proof.

Every runner uses fresh `builds/testing/F003/<run-id>/appdata` and `localappdata`,
`check-<run-id>` namespace, `docs/evidence/F003/<run-id>` reports. Save suites use
isolated recorded child slots. Inspected all results/stdout/stderr diagnostics,
not exit alone. Final runs have no runtime error/warning/timeout. Normal save untouched.

Bundled Python `reference/audit.py --self-test` and `--source-root
D:/development/game-prototype-2 --self-test` both PASS:20 source/3 reference/3 geography
hashes unchanged,5 offline/6 live negative controls. Source Git status clean.
Exact commands/cwd/outputs in `../evidence/F003/audit-20261007-182858-342d8acb/results.json`.
Source Flutter tests not run; no runtime dependency added.

## Review and continuation

Reviewed intended diff/new scripts/UIDs and command-local whitespace check, linked
workflow/parent docs and consistent statuses. Failed evidence retained. All owned
runner processes exited; no editor/render/native game started, cleanup none.
No installs, source refresh, package builds, commits, external messages or publication.
F005 blocked-anchor geometry constraints unchanged.

Next eligible **F004 — save compatibility and lifecycle**: F003 capabilities verified.
Implement strict schema6/candidate validation, restore/rebinding and isolated exact
process restart there. F004+ criteria unrun. Completed exactly F003; stop.
