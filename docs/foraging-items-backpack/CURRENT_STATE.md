# Foraging, items and backpack current state

Updated2026-10-07, America/Vancouver. [CHECKLIST](CHECKLIST.md) owns status;
[AGENT_PROMPT](AGENT_PROMPT.md) selects work; [CONTRACT](CONTRACT.md) owns rules/mappings.

## Selection and continuation

F001-F007 Done; F008-F010 Pending. No active task. Next eligible: **F008 — art and
peaceful feedback**. F007 ordinary drop/drag/recollect, safe geometry, travel and exact
GUI restart prerequisites actually pass; read [F007 acceptance](F007_ACCEPTANCE.md).
Completed exactly F007; stop before successor. No automatic agents.

Separate tooling follow-up2026-10-07: [shared journey helper](../TESTING_JOURNEY_ACCEPTANCE.md)
complete after `eff156a`. F005/F006/F007 now use reusable TestRunJourney movement/
navigation readiness, endpoint validation and progress diagnostics. Helper35 and
support64 assertions, movement/camera regression and final F005/F007 ordinary
writer/reader journeys pass, including F007 paths beyond the old1800-frame limit.
Skill recipe copies are synchronized/validated; all owned processes exited.
This tooling request did not select F008 or change feature checklist status.

Separate native-tooling follow-up2026-10-07: [native B/bounded drag helper](../TESTING_NATIVE_INPUT_ACCEPTANCE.md)
complete. Native input accepts B and atomic client-space drag with per-step/batch
bounds, full coordinate preflight, guarded motion and explicit release failures.
F001-F010 run-child evidence routes are supported. Native dispatcher712 assertions
and exact Win32 interop compilation pass; installed skill/recipe copies match and
validate. No exported game launch or OS input claim: F010 still requires a fresh
release and ordinary native gameplay/restart acceptance. Feature status unchanged.
Combined recheck: native715/infrastructure134 assertions pass after fixing Windows
case-only capture-label collisions; concurrent runner implementation and all three
installed skill files remain intact. See the same acceptance record for evidence.

Rod(-6.5,0,15.75) and flower01(26.75,0.25,-2) use approved safe runtime defaults;
ForagingRegistry authored_foot retains pinned source provenance. Saved explicit
placements override defaults; collected IDs stay absent. Original geometry blocker
and relocation-only records below are historical; F005 acceptance supersedes their
Pending/In progress boundary. All owned processes exited; no cleanup owed.

## Baseline and preserved work

Historical F002 initial target HEAD `5f42802a2c8bf4b276b1009666c5ad9564c094a0`; worktree clean.
F003 initial target HEAD `20dfbecdbddcc21c6ea58a36bb1f5f2d99cca73a`; worktree clean.
No existing user changes overwritten. Read-only source HEAD recorded by F001:
`60c20eb2816e7271fb84afaba286af006ebe3ccf`; current20 pinned source hashes/audit PASS,
source status clean. Per-command safe.directory override only; no Git config changes.
Historical P/M/W package/release completion and F001 records preserved.

Current runtime: game/app/game_root.tscn, pinned Alderwake exterior, schema6/content1.
Catalog now21 definitions (prior17 plus4 item/resource definitions). Fresh sessions start with
empty inventories; restored sessions hydrate item/ForagingState facts. F005 activates
world wrappers/held E; backpack/active HUD delivered F006; safe ordinary drop/drag delivered F007.
SaveCodec now serializes item/collected/placement facts; F004 details and acceptance below.
Pinned geography/source/export and normal saves untouched. F005 adds held input/UI
progress and temporary visuals; historical earlier-task boundaries below retained.

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
appears in snapshot. No signal/scene/save ownership in inventory. F003 delivered related
facts/revisions/publication below; generic consume tests do not prove production rod
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
All F002 criteria evidenced. F003 delivered below; F004-F010 criteria unrun.

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

## F003 delivered state and continuation details

[Acceptance](F003_ACCEPTANCE.md) owns criterion table, commands, outcomes and limits.
Changed game/app/game_session.gd, game/features/items/inventory_state.gd; added
ForagingRegistry, ForagingState, WorldItemPlacement, ForagingCommandResult and
foraging_transaction_checks.gd with five engine-generated UIDs. Updated README,
architecture and this workflow CONTRACT/CHECKLIST/current state/acceptance.

ForagingState owns private sorted collected origins and placement index, WeakRef
session binding and injected placement Callable. Commands return structured outcomes;
integer committed signal follows joint bag/active/facts/placement mutation. Observers
query detached snapshots; nested world commands/rebinding reject command_busy.
Revision includes world/capability revisions plus successful inventory mutations and
changed selection. Treat opaque token; one transaction may advance twice. Transient,
fresh0, never serialize. Root must still revalidate physical selected target in F005+.

Registry pins four exact F001 identities/feet; resource/item namespace validated.
Authored move overrides same original ID; pickup suppresses original/removes override.
Generated drop uses dropped-fishing_rod, supported Alderwake/Tollworks, original
fishing-rod-dock-01 already collected. Drop consumes final bag rod/clears active;
generated pickup removes placement/keeps origin suppressed. Rod count1 enforced before
commands; F002 generic synthetic add/consume are not production rod transactions.
No physical resource wrapper, UI/drop route, hold/drag or geometry activation.

Placement validator receives detached typed candidate/full snapshot and returns
PackedStringArray: empty validates, errors reject. Missing/freed/malformed capability
fails closed. Service validates finite Godot metres/identity/provenance/location and
rechecks revision/current room after callback before consume/commit. It does not undo
unrelated callback changes; validator must not mutate session. F004 requires strict
restored-fact validation and geometry before swap; F007 supplies measured physical
placement. Do not mistake synthetic validators for dry/support/retrieval evidence.
No restore API or schema6 added here; SaveCodec remains schema5/content1 and ignores
inventory/new world facts. Exact process restart remains F004 work.

F003 commands from repository root, installed console verified4.7.2:

- run_checks -Task F003 -Names inventory_checks -TimeoutSeconds150 PASS,
  20261007-182122692-f0e545dc; prerequisite inventory199 assertions.
- run_checks -Task F003 -Import -Names foraging_transaction_checks,inventory_checks,
  content_catalog_checks,application_smoke,save_checks -TimeoutSeconds150:
  20261007-182622044-53f5ad0e import PASS, parse FAIL. Extra parenthesis in test callback;
  direct-parse.log retained. No engine acceptance claimed from this failure.
- Same command without Import after syntax fix PASS,
  20261007-182714901-8301608f; transaction573 assertions, F002199 and affected regressions.
- Final run_checks -Task F003 -Names foraging_transaction_checks,map_activation_checks,
  environment_save_checks,location_travel_checks -TimeoutSeconds150 PASS,
  20261007-182823373-7e09f842; tightened transaction583 assertions, codec517, ten round trips.

Inspected reports/logs; no runtime diagnostics/timeouts. Only allowed initial editor
missing .NET SDK10.0.9 diagnostic; no install. Runner evidence docs/evidence/F003/<run-id>,
isolated builds/testing/F003/<run-id>/appdata/localappdata and check namespaces;
normal save untouched. Bundled Python offline/live-source audits PASS,
audit-20261007-182858-342d8acb;20 source/3 reference/3 geography hashes unchanged,
5 offline/6 live negative controls. Source status clean; Flutter tests not run.

Reviewed intended diff/new files/UIDs, whitespace/status/link consistency. Preserved
failed runs and historical records. All owned runner processes exited; no editor,
live/render/native game started or cleanup owed. All F003 criteria evidenced;
F004-F010 criteria unrun. Next eligible F004; stop before successor.

## F004 delivered state and continuation details

[Acceptance](F004_ACCEPTANCE.md) owns full criterion table, commands/evidence and limits.
Initial target HEAD d649ca4431640adc6454fa467a4d0cbaba8c2625, clean worktree. No user
changes overwritten. Current schema6/content1; source/geography unchanged. F002/F003
schema5 descriptions above are historical delivery boundaries, superseded by F004.

Changed SaveCodec, ForagingState, GameRoot, WorldHost, PrototypeLocation and run_checks.
Added ForagingSaveData, SaveJsonFields, ForagingPlacementGeometry, test-only
ForagingSaveFixture, foraging_save_checks and foraging_process_checks with six UIDs.
Updated inherited inventory/transaction/mapping/environment/map-save assertions for
schema6 while preserving historical JSON fixtures. Parent README/architecture and
workflow CONTRACT/CHECKLIST/this state/acceptance updated. No input/art/UI/export change.

Final fields exactly inventory {item_counts,active_item_id}, collected_resource_ids,
world_item_placements plus v5 fields. Strict plain validation and fresh revision0-only
restore publish no signal. Legacy1-5 keeps original shape/default chains and empty
new facts. Duplicate escaped JSON keys and mathematically fractional quantities reject
before conversion. Existing precise environment numbers/newer protection/128KiB/
primary-backup semantics retained. Root binds restored session only after staged room
geometry accepts every current/foreign placement. Conservative footprint/support/dry/
capsule/navigation/path/arrival-portal reservations documented in acceptance; F007
owns measured search/drag semantics. Location binds one weak session/listener and
exposes detached facts/application hook; F005 must consume hook with physical wrappers.

Verification from repository root, PowerShell7, installed console4.7.2:
- Prerequisite transaction583 PASS: 20261007-183832347-675eff88.
- Broad acceptance PASS: 20261007-185011795-a73efb5b. foraging_save/transactions/
  inventory/save/environment_save/map_save/location_travel/application; independent
  foraging_process and existing save_process write/read phases via -ProcessScripts.
- Focused PASS: 20261007-185334208-1e788c99. foraging_save110, inventory199,
  reference_mapping4 nodes/1,648 capsule samples, environment_lifecycle157;
  independent-process foraging writer51/read54. Exact binary whole-save oracle compares
  four item states plus fifth foreign-room state/revisit, safe arrivals, fresh transient
  state and listener cleanup. Headless synthetic fixtures, no normal-input proof.
- Final review tightened one-time hydration: empty restored candidates/nonempty or
  observed inventories cannot hydrate again; disposed weak owners fail closed.
  Final save111/transaction583/process PASS: 20261007-185936104-3f946051.
  Final disposed-owner guard + exact process writer52/read55 PASS:
  20261007-190122906-919e912b (Names @(), ProcessScripts foraging_process_checks).
- Offline/live-source Python audits PASS: audit-20261007-185433-c302ac16;20 source/
  three reference/three geography hashes unchanged, five/six negative controls;
  source status clean. Source/Flutter tests not run.

All final reports/logs inspected; diagnostics empty, no timeouts. Import/parse PASS;
only existing editor-import missing .NET SDK10.0.9 diagnostic allowed. Isolated
builds/testing/F004/<run>/appdata/localappdata/check namespaces and recorded child slots;
normal save untouched. Raw evidence docs/evidence/F004/<run> ignored.

Retained failed F004 runs: 184233860-d1081ee6 (20261007 prefix) stale F003 schema assertion
and handled retry error log;184513386-568e4b8f typed hostile fixture;184602816-5124ecc2
variable typo;184626312-f74db9f3/184723720-04f2c01f/184926558-2f6bfb63 v5 oracle JSON
integer-type mismatch. Acceptance records repairs and final passes. Retry now shows
handled rejection feedback/ordinary logs, avoiding unexpected-engine-error diagnostics.
Tracked matching line endings preserved; intended diff, new files/UIDs, links/status
reviewed. Command-local target safe.directory/cr-at-eol check used; no Git config change.

All owned processes exited; no editor/live/render/native process or cleanup owed.
Every F004 criterion evidenced. F005-F010 checks unrun. Two F001 blocked anchors still
require F005 repair or explicit blocked decision; no map/LOS bypass. Historical P/M/W
packages remain schema5 history; F010 must produce new schema6 delivery evidence.
Next eligible F005; F006 independently eligible after F004 if F005 becomes Blocked.
Completed exactly F004; stop before successor.

## F005 blocked session and durable handoff

Initial HEAD be2b3b85e2da3794802ff004ed169973dd1bb33e; clean worktree, no user changes
superseded. Marked F005 In progress before investigation, now Blocked under CONTRACT.
Added game/tests/foraging_anchor_checks.gd and generated UID; updated CHECKLIST/this
state and added F005_BLOCKER.md. No production, geography, source, content, save schema,
input/UI/art/export changes. Runtime remains schema6/content1; pickups inert.

F005_BLOCKER owns criterion-by-criterion status and rounded/exact geometric evidence.
All implementation/rendered acceptance remains unmet/unrun. Reusable test diagnoses
production blockers synthetically; PASS does not mean held gathering implemented.
F004 save/lifecycle APIs revalidated with exact all-field independent-process oracle.
Commands from repository root via isolated run_checks:

- -Task F005 -Names foraging_save_checks,reference_mapping_checks -ProcessScripts
  foraging_process_checks -TimeoutSeconds150 PASS: 20261007-191556187-ad924655;
  save111, mapping4/1,648 capsule samples, writer52/read55.
- -Task F005 -Import -Names foraging_anchor_checks -TimeoutSeconds150 PASS:
  20261007-191707777-2d925cd8; import/parse and all four anchor probes.
- Final -Task F005 -Names foraging_anchor_checks -TimeoutSeconds150 PASS:
  20261007-191757099-44340ed6; explicit foot/sight containment, measured box bounds,
  clear nearby capsule approaches/in-range and actual LOS blocker names.

All results.json/stdout/stderr inspected. No runtime diagnostics/timeouts/failed runs;
existing allowed editor-import missing .NET SDK10.0.9 only. Installed console/editor
paths verified; no SDK installed. Runner appdata/localappdata/check slots under
builds/testing/F005/<run>, ignored raw evidence under docs/evidence/F005/<run>. Normal
save untouched. No rendered/native game/editor started; all owned runner processes
exited and no cleanup owed. Reviewed intended diff/UID/status/reference consistency.

Next eligible F006 independently; future session preserves these current changes.
F005 remains Blocked until geometry-policy decision; don't restart diagnosis unchanged
or silently bypass blockers. F005 wasn't completed; exactly one task attempted; stop.

## F005 relocation follow-up and next action

User explicitly approved moving rod/flower01; fulfilled that narrow request. Registry
RUNTIME_FEET overrides rod onto existing east dock centre(-6.5,0,15.75), flower01 onto
same terrace0.75m east of cliff(26.75,0.25,-2); original authored_foot and identity retained.
Changed registry, transaction assertions, prior anchor probe; CONTRACT/AGENT_PROMPT/
CHECKLIST/this state/F005_BLOCKER and new F005_RELOCATION updated. No map/collider/nav,
source, save schema/content or UI/input activation changes. Prior uncommitted work kept.

Repository-root run_checks -Task F005 -Names foraging_anchor_checks,
foraging_transaction_checks,foraging_save_checks,reference_mapping_checks -ProcessScripts
foraging_process_checks -TimeoutSeconds150 PASS: 20261007-202154715-207af0c2. Four safe
runtime feet/support/footprint/capsule/navigation/route/reservation/LOS probes; transaction587,
save111, historical mapping4/1,648, exact independent-process writer52/read55. Reports
and full stdout/stderr inspected; diagnostics empty/no timeouts/failed cases. Parse
preflight PASS; no new class/import required. SHA256 source20/geography3/reference3 pins
unchanged. Runner appdata/localappdata/slots isolated; normal save untouched. All owned
processes exited; no editor/live game/cleanup. Synthetic proof only, no world pickups yet.

F005_BLOCKER retained historical; approved relocation supersedes fixed-runtime-XZ
restriction and resolves it. F005 Pending/next eligible; remaining hold/wrapper/rendered
criteria unimplemented/unrun. Follow F005_RELOCATION/CONTRACT current authority.
Stopped after requested relocation; no F006 or hold implementation started.

## F005 completed handoff

Baseline HEAD be2b3b85e2da3794802ff004ed169973dd1bb33e. Preserved preceding F005
blocker/approved relocation work; no user changes overwritten. [F005_ACCEPTANCE](F005_ACCEPTANCE.md)
owns all criteria/evidence/commands, retained failures and inspection details.

Added ForagingAction, ForagingHoldController, ForagingWorldAdapter and UIDs; updated
root/interactable/location/UI and read-only bridge observations. New reusable anchor,
interaction and rendered journey checks; mapping/activation/transaction/process
checks now distinguish pinned provenance from runtime default and assert exact
physical wrappers. Updated parent README/architecture/PLAYTEST and workflow docs.

99 synthetic interaction assertions cover exact hold/cancel/latch/capacity/lifecycle,
physical saved authored/generated pickup and signal ownership. Final code interaction/
light151/dialogue PASS20261007-205238453-486e18c7. Independent process writer66/read69
PASS20261007-204632170-6b9a55f0 covers exact whole durable oracle, physical saved-placement
reconstruction/foreign revisit and transient reset. Anchor, travel10 round trips,
bridge, mapping1648, activation3226, movement/settings/save111 checks PASS in recorded
runs. Final rendered PASS20261007-205250215-6f77c16d: ordinary fresh WASD all four,
actual hold/progress/release, GUI Save, separate PID GUI Load, exact all-fact oracle
and ordinary rod revisit. Inspected full-size frames;10 writer paused/2 live hold
captures and3 reader paused captures. No teleport/state/reward setup in rendered run.

Isolated APPDATA/LOCALAPPDATA/save slots/evidence; normal saves untouched. Diagnostics
empty in passing runtimes; allowed editor-import missing SDK diagnostic retained,
no installation. Offline/live-source audit PASS audit-20261007-205145-fc1c2562, all20
source/3 local reference/3 geography hashes intact. Failed fixtures/preflight/parse
runs and HUD encoding repair documented in acceptance; final tests supersede them.
Owned processes exited. No remaining F005 criterion, no native/export/new art claim.

F006 next, verified F004 inventory/selection/save prerequisite. Stop here.

## F006 initial session record (historical)

Initial HEAD d8956b3387f9ed280207c6d25e301731d38b92f6; clean worktree.
Prerequisite inventory/save/exact independent-process checks PASS:
20261007-213213568-cd9e372d. F006 selected; implement backpack/modal/HUD only.

## F006 delivered state and continuation

[Acceptance](F006_ACCEPTANCE.md) owns full criteria, commands, outcomes and retained failures.
Initial HEAD d8956b3387f9ed280207c6d25e301731d38b92f6; clean worktree, no user work overwritten.
Added game/ui/backpack_view.gd, tests/backpack_ui_checks.gd/backpack_ui_render.gd and three
UIDs. Updated GameRoot modal/selection/lifecycle gates; InputMap B; UI header/footer layout,
active item label and snapshot rendering; bridge B/read-only observations; inherited
foraging_save_checks repository isolation after startup. Updated README/architecture/
PLAYTEST/CONTRACT/CHECKLIST/this state and F006_ACCEPTANCE.

Backpack is unpaused modal with twenty sorted slots, caps/counts, teal owned active highlight,
truthful non-tool/tool details and disabled rod-only Drop. UI renders detached snapshots;
root calls inventory.select only while current focused modal permits it. No schema/content
change, source/geography change or ordinary drop/drag implementation. Existing environment
clock keeps modal-time policy. Closing releases focus, clears stale pointer and requires
fresh world presses; held E uses existing release latch. Save/Load remain pause-only after close.

Commands from repository root through isolated run_checks F006:
- Prerequisite save111/inventory199 + independent foraging_process PASS:
  20261007-213213568-cd9e372d; import/startup PASS213515217-d12b8527.
- Final production-code backpack142/save111/dialogue/settings/smoke + rendered write/read
  PASS20261007-214630223-026c35f0. WriterPID26152/readerPID68684; normal WASD/E/B/Tab/Enter/
  pointer acquires rod/flower, selects rod and GUI Saves. Fresh process GUI Loads and compares
  every prior/item/forecast fact exactly; active highlight/HUD agree.
- Final enhanced backpack145 PASS20261007-214749916-fd20c1ad (known-unowned rejection,
  final-unit clearing, fresh movement/attack/dodge; modes/aim/zoom/focus/capacity).
- Movement/camera, foraging interaction99 and bridge regressions PASS within earlier runs
  213714822-a63ef3ab/214410243-746669a9; whole reports retain distinct fixture failures.
- Offline/live-source Python audit PASS audit-20261007-214511-1b518619,20 source/3 reference/
  3 geography hashes unchanged and5/6 negative controls. Source tests not run.

Full final results/logs and full-size empty/rod/capacity/restored images inspected. Eight
final backpack PNGs use explicit unpaused modal verification; Save/Load views use unchanged
pause capture guard. Smaller800x600 window renders800x533 aspect-preserved content. Capacity
fixture is detached display-only snapshot/catalog, never ordinary collection or saved state.
Final diagnostics empty; only initial import existing missing .NET SDK10.0.9 allowed.
Raw evidence docs/evidence/F006/<run>; isolated appdata/localappdata/check namespaces under
builds/testing/F006/<run>. Normal save untouched. All owned processes exited; no cleanup owed.

Retained failures:213714822-a63ef3ab wrong test Object/String active_tool comparison;
213942370-c3764ab1 rendered writer timeout after resize, cause unestablished; two later
full rendered writer/reader runs pass without gate bypass.214410243-746669a9 inherited save
fixture pre-ready path overwritten by runner slot, recovered earlier backup; after-startup
PID-qualified test path repair passes strict rollback111. Failed text-edit anchor wrote nothing.
No release/native/export/publication/install. Intended diff/new files/links/status and
command-local cr-at-eol whitespace review complete. Next eligible F007; F005+F006 verified.
Every F006 criterion evidenced. Stop before successor.

## F006 commit review follow-up — 2026-10-07

Pre-commit diff review found `_select_upgrade` used `not journal_open and not backpack_open`,
allowing a direct journal upgrade command while backpack was open. Restored fail-closed
`not journal_open or backpack_open` guard; synthetic earned-point regression proves modal
cannot spend a point. Backpack146 and dialogue checks PASS in20261007-220147051-41603a7b.
That run retains an independent consequence fixture failure: v1-v3 synthetic payload still
contained schema6 item fields. Fixture now removes inventory/collected/placement fields
when constructing legacy payloads; migration assertions unchanged.
Final backpack146 + consequence checks PASS20261007-220250776-080c65b1, diagnostics empty.
Prior rendered selection/restart evidence remains applicable; guard repair concerns journal
upgrade command only. No F007 work begun. Two additional necessary guard/fixture repairs
included with F006 commit; normal saves/source/geography unchanged.

## F007 delivered state and continuation details

[F007 acceptance](F007_ACCEPTANCE.md) owns complete criteria, command table, retained
failures, measured tolerances and inspected evidence. Initial HEAD
ae3eba7de2ba352f571c59f41fa2b292c5b54c62, clean worktree; no user changes overwritten.
F007 Done; F008 next eligible. Previous F006/P/M/W boundaries above are historical.
Every F007 criterion evidenced; F008-F010 art/integrated/native checks unrun.

Changed GameRoot, ForagingPlacementGeometry, BackpackView, read-only live bridge,
inherited backpack checks/renderer and independent-process fixture. Added WorldItemDrag,
world_item_placement_checks/world_item_placement_render and three generated UIDs.
README/architecture/PLAYTEST and CONTRACT/CHECKLIST/this state/acceptance updated.
Schema6/content1, pinned geography/source/registry default feet and normal save unchanged.

Drop is enabled for selected owned rod. Facing-first24-candidate search validates
full 1.0m rod clearance/dry footprint, existing restore safety and ≤1.5m local dry
hero approach before consume. Success clears active/closes bag; failure keeps facts/
modal with feedback. Pointer press within14px of projected rod segment starts nearby
reachable drag, clears controls/combat/AI/hold; preview is transient green/red ghost.
Valid release moves same authored/generated ID atomically; invalid release preserves
original. Esc cancels before pause; focus/modal/travel/load/retry/stale ownership/
target/revision cancels and consumes old pointer release. Fresh world input required.

Each successful arrival/load binds root validator qualified by weak current session.
Codec candidates still revision0; physical live token1 reflects one capability bind,
not restored command history. Independent-process fixture now asserts inventory0,
live token1, rod1 and empty drag/ghost/latch. No state/signal/save ownership moved.
Backpack open forces refresh so loaded active rod enables Drop without reselection.

Final commands from repository root via isolated run_checks (full syntax in acceptance):
-222143996-d4aa795e: all ten headless placement/backpack/transactions/save/nav/map-save/
 movement/hold/travel/bridge suites PASS; separate old process token0 fixture FAIL.
-222352948-2d6c59fa: final placement128, dialogue, lights151/settings PASS.
-222435865-2b1a1307: save111, exact independent writer71/read74 PASS.
-222237176-015ce980: ordinary rendered loop/travel/GUI Save/new-process GUI Load/exact
 every prior/item durable fact + forecast/physical recollect PASS. Writer25976,
 reader71292. Three writer/two reader paused views, two backpack/four live drag views.
All run IDs have20261007 prefix. Full final reports/logs reviewed, runtime diagnostics
empty. Earlier import/parse PASS; only existing editor-only missing .NET SDK allowed.
Runner isolates APPDATA/LOCALAPPDATA and save slots; normal slot untouched.

Full-size final green/red preview, placed-after-travel and restored-recollected images
inspected; Drop modal inspected in prior passing run. Small red ghost contrasts weakly
with brown dock, but invalid prompt is clear and final pixel evidence verifies marker;
F008 owns final feedback/art readability. Native/OS input unrun, belongs to F010.
Offline/live source audits saved in audit-20261007-222532-37ffd81f/results.json PASS:
20 source/3 reference/3 geography hashes;5/6 negative controls; source status clean.

Retained failed F007 runs listed in acceptance: asynchronous disabled-nav probe,
incorrect water-facing pose/disconnected probe sync, long-route frame limit and gate
waypoint beyond nav edge, inherited fresh-token0 assumption. Repaired fixtures/search
evidence without weakening collision/navigation/input/save gates. No runtime/source
dependency, install/export/publication/commit. Original tracked newlines preserved;
command-local cr-at-eol whitespace/intended diff/new-file/UID/link/status review complete.
All owned runner processes exited; no editor/game or cleanup owed. Exactly F007 complete;
stop. Next invocation: read F008 requirements, keep IDs/physics/wrappers separate while
improving temporary flower/rod art, icons/progress and placement feedback.
