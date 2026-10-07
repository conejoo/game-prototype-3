# Foraging, items and backpack current state

Updated2026-10-07, America/Vancouver. [CHECKLIST](CHECKLIST.md) owns status;
[AGENT_PROMPT](AGENT_PROMPT.md) selects work; [CONTRACT](CONTRACT.md) owns rules/mappings.

## Selection and continuation

F001/F002 Done; F003-F010 Pending. Active task: none.
This session completed exactly F002. Stop before successor.
Next eligible: **F003 — atomic item/resource commands**.
Next action: inspect user changes and F002 APIs/tests/acceptance, revalidate prerequisites,
mark F003 In progress before editing; implement session-owned collected facts/typed
placements and joint commit/publication. No automatic next chat/agent/schedule.

## Baseline and preserved work

Initial target HEAD `5f42802a2c8bf4b276b1009666c5ad9564c094a0`; worktree clean.
No existing user changes overwritten. Read-only source HEAD recorded by F001:
`60c20eb2816e7271fb84afaba286af006ebe3ccf`; current20 pinned source hashes/audit PASS,
source status clean. Per-command safe.directory override only; no Git config changes.
Historical P/M/W package/release completion and F001 records preserved.

Current runtime: game/app/game_root.tscn, pinned Alderwake exterior, schema5/content1.
Catalog now21 definitions (prior17 plus4 item/resource definitions). Sessions own fresh
empty inventories; world nodes remain inert and no backpack/holds/drop route activated.
SaveCodec unchanged and does not serialize F002 inventory; F004 owns schema6.
No geography/source/art/input/UI/export changes or normal-save access.

## F002 delivered files and decisions

[Acceptance](F002_ACCEPTANCE.md) owns criterion-by-criterion evidence.
New game/features/items/ItemDefinition, ForagingResourceDefinition, InventoryState,
InventorySnapshot scripts and generated UIDs; game/content/items and resources each
contain moonflower/fishing_rod.tres. Manifest adds four Resources. Updated
ContentCatalog typed lookup/reference validation, GameSession fresh inventory ownership,
content_catalog_checks expected21, new inventory_checks.gd + UID. Updated parent
README/architecture and workflow CONTRACT/CHECKLIST/current state/acceptance.

InventoryState methods initialize/can_add/add/consume/select return PackedStringArray
errors; count and active_tool query facts/capability. Max20 distinct IDs, one stack/type,
flower99/rod1; positive integer Variant quantities only (fractions, float1.0, bool,
nonfinite/string/null reject). Subtraction validates cap before potentially overflowing
addition. No silent equip. select(null) clears; only owned IDs select; tool derives from
immutable metadata. Final consume erases stack/clears matching selection.

snapshot() yields detached, item-ID-sorted Dictionary[String,int] with nullable active
ID; to_dictionary copies counts again. Internal empty-string selection sentinel never
appears in snapshot. No signal/scene/save ownership in inventory. F003 owns related
facts/revisions/publication; generic consume tests do not prove production rod
conservation. F004 must validate numeric JSON integers before converting to command ints.
All authored Resources remain immutable by existing convention; no per-session counts
or active IDs stored in content. Invalid catalog replacement leaves old full index intact.

## Verification, evidence and isolation

All commands from D:/development/game-dev-blender/returning-fair-prototype, PowerShell7:

```powershell
./tools/run_checks.ps1 -Task F002 -Names reference_mapping_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F002 -Import -Names inventory_checks,content_catalog_checks,application_smoke,environment_save_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F002 -Names inventory_checks,reference_mapping_checks,map_activation_checks,save_checks -TimeoutSeconds 150
```

All PASS, respectively docs/evidence/F002/20261007-173618317-6c5fef72/results.json,
20261007-174145567-2ef98c9b/results.json,20261007-174326531-6f771cc0/results.json.
Final inventory199 assertions/failures empty; environment codec517 assertions;
production mapping four nodes/1,648 synthetic capsule samples; map activation and
legacy-save IO/backup/atomic restore/unsafe-spawn rollback all PASS.
Initial inventory JSON reported198 before counting evidence-write assertion; stdout199.
Final report corrected to199. Results and full diagnostic logs inspected.

Installed Godot console/editor paths verified; engine4.7.2.stable.mono.official.ed1daf0bf.
Runner isolated APPDATA/LOCALAPPDATA under builds/testing/F002/<run-id>, check slots and
fresh docs/evidence/F002 directories; save suites use recorded isolated child slots.
Normal save untouched. No runtime errors/warnings/timeouts; only allowed editor import
missing .NET SDK10.0.9 diagnostic. No SDK/install action.

Bundled Python reference/audit.py --self-test and --source-root
D:/development/game-prototype-2 --self-test both PASS after edits.20 source/3 reference/
3 geography hashes,5 offline/6 live negative controls. Initial live audit also PASS.
Exact command/output/source clean status: docs/evidence/F002/audit-20261007-175049-e9aad353/results.json.
Source tests not executed; no source/runtime dependency added.

No F002 failed engine run. Preserved original tracked-file line endings; new files LF.
Reviewed intended diff/all new files/UIDs, links/status consistency, command-local
cr-at-eol whitespace check (historical tracked catalog files use CRLF).
Parent-doc newline repair first failed before writing because elevated Git user differed
from checkout owner; command-local target safe.directory override resolved it. No
global config change; no effect on engine checks.
All runner processes exited; no editor/live game/render/native input or cleanup owed.
All F002 criteria evidenced; F003-F010 criteria unrun.

## F001 historical evidence and activation constraints

[F001 acceptance](F001_ACCEPTANCE.md), [reference guide](reference/README.md), manifest,
behavior vectors, source excerpts, geometry baseline and auditor remain unchanged.
They pin20 source files, three geography files, resolved item/resource namespaces,
exact four authored feet,600/500ms holds and proposed schema6/provenance shape.
Historical target baseline had17 definitions/no inventory; F002 intentional scripts
supersede only historical target observations, never pinned source/geography hashes.

F001 accepted runs20261005-072246477-fde37221,20261005-073211388-5575def8 and
audit-20261005-073430-9fcda68c remain documented. Failed geometry runs
20261005-072900870-3e922a72/20261005-073026478-4a95c991 retained.

All four underlying terrain heights match authored feet. Nearby synthetic dry routes:
rod(-7,0,15.75), flower01(26.75,0.25,-2), flower02(34.75,0.25,7),
flower03(30.75,0.5,-9). Flower02/03 clear LOS. Exact rod(-8,0,15.75) lies inside
south-water-06; flower01(26,0.25,-2) overlaps cliff-47-15-east/cliff-47-16-east.
Nearby dry route does not make blocked origin usable. F005 must repair adapter/visual/
LOS placement under fixed authored XZ/map authority or record exact design conflict
and Block F005. No LOS bypass, collider removal, map refresh or rebake authorized.
This does not block F003/F004/F006. No source save import, fishing, tutorial side
effects, autosave, economy/gifting, new NPC/campaign or combat redesign in scope.
