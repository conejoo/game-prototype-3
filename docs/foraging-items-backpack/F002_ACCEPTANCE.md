# F002 acceptance — content and backpack rules

Completed 2026-10-07, America/Vancouver. Exactly F002; F003 not started.
Initial target HEAD `5f42802a2c8bf4b276b1009666c5ad9564c094a0`, worktree clean.
F001 reference audit and fresh production mapping verified before implementation.
Read-only source worktree remains clean; no source, geography or normal save writes.

## Acceptance evidence

| Criterion | Result and actual evidence |
| --- | --- |
| 20 types accepted / 21st rejected | PASS: detached manifest adds 19 labeled test-only items; bag holds flower, rod and 18 synthetic types; next type returns backpack_full with exact snapshot unchanged; consuming a stack frees its slot |
| Existing stack grows in full bag | PASS: flower98 -> 99 while all20 slots occupied; can_add is read-only |
| 100th flower / second rod rejected | PASS: stack_full, counts and active ID unchanged; largest signed integer quantity rejects before addition/overflow |
| Invalid quantities/IDs reject atomically | PASS: add/consume reject zero, negative, fractions, float1.0, NaN, infinity, bool, string and null; unknown/empty/resource/actor/source IDs reject; insufficient consume and invalid/missing selections preserve exact snapshot |
| Final active unit clears selection | PASS: final rod and flower consumption remove stack and set active null; partial consume retains selection; explicit select(null) keeps counts; no silent pickup selection |
| Distinct resource/item namespaces resolve | PASS: typed item/resource lookups, source IDs, caps99/1, forage/tool and600/500ms holds; wrong-kind lookups reject; resource references must resolve ItemDefinition and matching source provenance |
| Bad catalog init publishes no partial index | PASS: new invalid candidates expose zero definitions/null typed lookups; bad replacement retains all21 published definitions and exact prior item/resource references; caps/category/provenance/holds/references/global-ID collisions tested |
| Resources unchanged across two detached sessions | PASS: separate session inventories, first/second mutations independent, snapshot/plain-copy edits cannot affect live state, every authored item/resource property remains equal to baseline |
| No world/UI activation | PASS: production map activation and mapping retain four inert records, exact feet/geography and known blocked anchors; root controls unchanged; schema5/content1 snapshot still excludes inventory |

Final `inventory_checks`: **199 assertions**, no failures; report and stdout agree.
Fixtures are synthetic rule checks, not gathering, walking, rendering or native input proof.

## Delivered code and API decisions

- `ItemDefinition`, `ForagingResourceDefinition`: authored Resources treated as immutable
  under existing catalog convention. Four local `.tres` definitions added to manifest;
  total21 = prior17 + two items + two resources. No definition/instance ID conflation.
- `InventoryState`: session-owned RefCounted with private typed counts, max20 types,
  one stack each; initialize/can_add/add/consume/select return PackedStringArray errors.
  No scene/signal ownership. F003 owns joint world-fact commits and notifications.
- Command quantities require positive GDScript integers. Variant arguments deliberately
  reject coercion of fractions/bools and integer-valued floats. F004 must validate JSON
  numeric integers before converting to int; it must not blindly reuse typed coercion.
- `InventorySnapshot`: detached sorted Dictionary[String,int] plus nullable active ID;
  `to_dictionary()` returns another detached counts copy. Internally empty string is
  selection sentinel, externally null. active_tool() derives selected owned tool metadata;
  selecting forage is valid for inspection but never claims tool capability.
- GameSession publishes fresh inventory only after session preconditions validate.
  Resources never store quantities/selection. Generic consume tests are not valid
  production rod-save fixtures; F003/F004 must enforce world+bag rod conservation.
- No SaveCodec/UI/input/placement/geography/art/export changes. Schema5/content1 and
  historical P/M/W package acceptance retained; schema6 remains F004 work.

## Commands, outcomes and isolation

All engine/audit commands from `D:/development/game-dev-blender/returning-fair-prototype`.
Installed console verified before runs; engine4.7.2.stable.mono.official.ed1daf0bf.
PowerShell7 runner:

```powershell
./tools/run_checks.ps1 -Task F002 -Names reference_mapping_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F002 -Import -Names inventory_checks,content_catalog_checks,application_smoke,environment_save_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F002 -Names inventory_checks,reference_mapping_checks,map_activation_checks,save_checks -TimeoutSeconds 150
```

All PASS. Inspected results.json and stdout/stderr diagnostics, not exit code alone.
- Prerequisite: `../evidence/F002/20261007-173618317-6c5fef72/results.json` (3 cases).
- Import/rules/regressions: `../evidence/F002/20261007-174145567-2ef98c9b/results.json`
  (7 cases); inventory199 total assertions, environment codec517 assertions.
  First inventory JSON excluded its final evidence-write assertion (198); stdout199.
- Final targeted run: `../evidence/F002/20261007-174326531-6f771cc0/results.json`
  (6 cases); final `checks/inventory_checks/inventory-report.json` reports199;
  mapping four nodes/1,648 capsule samples; actual production map activation and
  save IO/backup/version/atomic restore/unsafe spawn rollback regressions PASS.

Each runner has fresh `builds/testing/F002/<run-id>/appdata` and `localappdata`,
`check-<run-id>` namespace, and fresh `docs/evidence/F002/<run-id>` report directory.
Save suites record their own isolated child slots. Normal user save untouched.
No runtime warning/error/timeout. Only previously allowed editor import diagnostic:
`ERROR: .NET Sdk not found. The required version is '10.0.9'.` No SDK installed.

Bundled Python auditor:

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' docs/foraging-items-backpack/reference/audit.py --self-test
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' docs/foraging-items-backpack/reference/audit.py --source-root D:/development/game-prototype-2 --self-test
```

Both PASS;20 source/3 reference/3 geography inputs,5 offline/6 live-source negative
controls. [Audit output](../evidence/F002/audit-20261007-175049-e9aad353/results.json) retains exact commands,
cwd/stdout/stderr/exit status and clean source status. Initial live-source audit also
passed before selection. Source Flutter tests read as F001 references, not run.

## Review and boundaries

Preserved original tracked-file newline conventions. New scripts/content use LF.
Reviewed intended diff, all new files/UIDs, docs links and status consistency.
CRLF baseline files require `git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check`;
this is command-local, no global Git settings changed. No F002 failed engine run.
Historical F001 failed geometry evidence remains intact; neither blocked anchor fixed.
No live editor/game or rendered/native input started; all runner processes exited.

Next eligible: **F003 — atomic item/resource commands**. F002 prerequisite rules now
verified; add collected facts/placements and commit/publication discipline there.
F004+ persistence/world/UI/drop/art/export acceptance remains unrun. Stop before F003.
