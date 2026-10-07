# F004 — Save compatibility and lifecycle acceptance

Completed 2026-10-07, America/Vancouver. Exactly F004 completed; F005-F010 remain
Pending. Initial target HEAD `d649ca4431640adc6454fa467a4d0cbaba8c2625`; worktree clean.
Installed console verified `4.7.2.stable.mono.official.ed1daf0bf` at the workspace
AGENTS path. No source/geography, art, input, UI activation, package or user-save edits.

## Implemented boundary

SaveCodec now writes schema6/content1: exact v5 fields plus `inventory` with
`item_counts` and nullable owned `active_item_id`, `collected_resource_ids`, and
`world_item_placements`. Sorted detached snapshots retain Godot-metre feet and the
existing six-field placement shape. Versions1-5 validate their original fields first;
all receive empty new facts. Existing companion/quest/consequence/environment migration
rules and SaveNumber precision repair remain unchanged. Explicit Load never rewrites
legacy files; explicit Save publishes v6 using existing staged primary/backup policy.

ForagingSaveData validates all plain facts before hydrating a fresh detached session.
Restoration accepts only revision0 fresh state, rejects repeated hydration (even empty),
nonempty/observed live inventories and disposed weak owners, publishes no command signal, retains
one rod across unsuppressed default/override origin, bag and generated placement, and
resets transient revisions. Unknown/duplicate origins, malformed fields, caps, selection,
placement identities/provenance and contradictory ownership fail without publication.
SaveJsonFields rejects duplicate decoded JSON keys, including escaped aliases, and
checks exact quantity lexemes so fractions rounded by JSON to integers still fail.
Whole numeric spellings such as `3.0`, `3e0` and `30e-1` remain valid JSON quantities.
Future schema/content protection still precedes duplicate/numeric guards.

WorldHost receives the detached restored run separately from live ownership. Before
arrival/session swap, ForagingPlacementGeometry proves each override/drop against
synchronized production collision/navigation. A foreign-room probe is hidden, pausable,
disposed and synchronized away before the arrival room is staged. Rejection reinstates
old room/navigation/party/session. Root only rebinds on successful transition.
PrototypeLocation binds one weak session reference and one committed-facts listener;
its detached location-filtered observation and overridable application hook support
F005 reconstruction without activating physical pickups. Freed scenes leave no stale
listeners. Handled retry failures now present UI feedback and ordinary rejection logs,
keeping engine diagnostics for unexpected failures.

## Criterion evidence

| Criterion | Evidence and result |
| --- | --- |
| Exact inventory/active/collected/placement round-trip | `foraging_save_checks`: bag, generated Alderwake/Tollworks drops and authored override; detached codec candidates and fresh revision0. PASS. |
| Legacy defaults retain prior facts | Existing save/environment/map suites retain v1-v4 fixture bytes and migration chains; new v5 all-field expected envelope adds only schema6/empty facts. Environment517 assertions and five historical map fixtures PASS. |
| Reject invalid quantities/IDs/duplicates/provenance/location/newer/oversized data before swap | New hostile-save suite covers zero/negative/fractional/overcap/bool/string/null/nonfinite quantities, rounded fractions, missing owned selection, resource namespace misuse, unknown/duplicate collected origins, duplicate placement/JSON aliases, malformed feet/fields, wrong item/origin/location/provenance, contradictory rod facts and schema7/128KiB overflow. Synthetic known-type catalog accepts20 types/cap99 and rejects21st. PASS. |
| Reject unsafe saved geometry before swap | Actual staged production queries reject dock water, flower cliff, unsupported height, outside map, arrival and portal reservations, plus unsafe foreign-room rod. Old exact snapshot/session/room/locks retained, one child remains. PASS. |
| Failed load/travel preserve facts; retry retains collection | New lifecycle test verifies malformed and physical load rollback, failed navigation travel, retry bag/active/collection hydration and both-room travel. Map suite additionally verifies five retry cases and rollback of unsafe loads. PASS. |
| Isolated separate-process restart; no transient continuation | Runner `ProcessScripts` executes dependent headless write/read OS processes sharing only isolated appdata/evidence. Binary oracle independently compares every SaveCodec snapshot field, including exact prior timers/facts, for four item states; a fifth foreign-room oracle and revisit prove persistence/filtering. Fresh empty reader startup, distinct PIDs, safe arrival, zero velocity/revision, paused controls/no selected interaction, one current listener/no old listener and rod1 PASS. Hold/drag controllers are not yet implemented and no such fields are saved. |
| Primary/backup/newer/128KiB/last-arrival behavior retained; normal save untouched | Existing save_checks/save_process_checks, environment codec, map24 round trips and location10 round trips PASS. Runner isolates APPDATA/LOCALAPPDATA and save-slot namespaces; explicit fixture child slots remain inside isolated appdata. Normal slot/source never accessed. |

## Commands and evidence

All engine commands from `D:/development/game-dev-blender/returning-fair-prototype`,
PowerShell7, installed console. Runner creates fresh ignored `docs/evidence/F004/<run>`
and `builds/testing/F004/<run>/appdata`/`localappdata`; console processes are bounded
at150 seconds, logs captured, diagnostics inspected rather than relying on exit alone.

```powershell
./tools/run_checks.ps1 -Task F004 -Names foraging_transaction_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F004 -Names foraging_save_checks,foraging_transaction_checks,inventory_checks,save_checks,environment_save_checks,map_save_checks,location_travel_checks,application_smoke -ProcessScripts foraging_process_checks,save_process_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F004 -Names foraging_save_checks,inventory_checks,reference_mapping_checks,environment_lifecycle_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150
```

- Prerequisite PASS: `20261007-183832347-675eff88`; transaction583 assertions.
- Broad acceptance PASS: `20261007-185011795-a73efb5b/results.json`; all eight suites,
  new write/read and existing save write/read. Map five historical fixtures,24 round
  trips,five rejections/five retries; environment517; inventory199; transactions583.
- Focused acceptance PASS: `20261007-185334208-1e788c99/results.json`; final
  save110 assertions, inventory199, four-node mapping/1,648 synthetic capsule samples,
  environment lifecycle157, independent-process writer51/reader54 assertions.
  New reports in `checks/foraging_save_checks/foraging-save-report.json` and
  `process/foraging_process_checks/write-report.json`/`read-report.json` record facts,
  PIDs and actual isolated paths. Every final case diagnostics array empty.
- Final hydration-review acceptance PASS: `20261007-185936104-3f946051/results.json`;
  one-time empty-restored guard, save111 and transaction583 assertions plus process phases.
- Final disposed-owner guard and exact restart PASS: `20261007-190122906-919e912b/results.json`;
  writer52/reader55 assertions, all diagnostics empty. Process-only invocation:
  `./tools/run_checks.ps1 -Task F004 -Names @() -ProcessScripts foraging_process_checks -TimeoutSeconds 150`.
  Hydration-review invocation: `./tools/run_checks.ps1 -Task F004 -Names foraging_save_checks,foraging_transaction_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150`.
- New classes/UIDs imported and parse preflight PASS. Only existing editor-import
  `.NET Sdk not found. The required version is '10.0.9'.` diagnostic allowed; no SDK installed.
- Bundled Python `docs/foraging-items-backpack/reference/audit.py --self-test` and
  `docs/foraging-items-backpack/reference/audit.py --source-root D:/development/game-prototype-2 --self-test` both PASS: `audit-20261007-185433-c302ac16`.
  Twenty source,three reference,three geography hashes unchanged; five offline/six
  live negative controls; source worktree clean. Source/Flutter tests not run.

Retained failures: `20261007-184233860-d1081ee6` exposed obsolete F003 no-persistence
assertion and handled retry engine-error logging; `184513386-568e4b8f` (same20261007
prefix) exposed typed hostile-fixture assignment; `184602816-5124ecc2` exposed test
variable typo; `184626312-f74db9f3`, `184723720-04f2c01f`, `184926558-2f6bfb63` exposed
JSON integer-type mismatch in the v5 oracle. These runs remain failed evidence; repaired
checks passed above. Original matching tracked-file line endings preserved. Initial
shell diff check lacked command-local safe.directory; explicit safe.directory plus
cr-at-eol check passes, without changing Git config.

## Limits and handoff

Service fixtures/staged headless physics are synthetic; no ordinary gathering,
GUI backpack, held E, pointer drag, render/native-input or fresh export claim.
F005 must still repair two blocked authored anchors under fixed source XZ/colliders.
F007 owns drop search, drag, final measured placement semantics and retrieval gameplay;
the conservative restore gate may be reused or refined without weakening validation.
No full fishing, autosave, source runtime dependency, geography refresh or installs.
Historical P/M/W package evidence remains valid history, not schema6 release evidence.
All owned processes exited; no editor/live process or cleanup owed. Reviewed intended
diff, new scripts/UIDs, status/reference consistency and diagnostic reports.

Next eligible F005: F004 save/lifecycle prerequisites verified. Read PLAYTEST and
project-local gameplay-testing skill before physical/rendered work. Stop before F005.
