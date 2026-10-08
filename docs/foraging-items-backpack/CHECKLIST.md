# Foraging, items and backpack execution checklist

Goal: peaceful gather/backpack/rod loop in existing 3D Returning Fair prototype.
Target: `D:/development/game-dev-blender/returning-fair-prototype`.
Prepared 2026-10-04, America/Vancouver. F001 completed2026-10-05; F002 completed2026-10-07; F003 completed2026-10-07; F004 completed2026-10-07; F005 completed2026-10-07 after approved relocation; F006 completed2026-10-07; F007 completed2026-10-07; F008 completed2026-10-07; F009-F010 Pending.
Authority: workspace AGENTS.md, [architecture](../ARCHITECTURE.md),
[CONTRACT.md](CONTRACT.md), actual source/current user work.
This file owns status; [CURRENT_STATE.md](CURRENT_STATE.md) owns continuation.
[AGENT_PROMPT.md](AGENT_PROMPT.md) selects this workflow only.

## Selection/completion

Resume single In progress task first. Reassess Blocked when blocker changes;
unresolved blocker excludes task/dependents, not independent ready work. Otherwise
choose first Pending with verified Done prerequisite capabilities/evidence.
F005/F006 independent after F004; F006 may proceed if F005 blocked. Reconcile
conflicting statuses/artifacts before selection. Exactly one task per invocation;
no automatic agents/schedules/successor. Done requires every criterion evidenced.
Update state after incomplete sessions too. Proposed filenames/checks below must
first be created; refine names deliberately and update references together.

| ID | Status | Dependencies | Outcome |
| --- | --- | --- | --- |
| F001 | Done | inspected P/M/W baseline | pinned behavior and node mapping |
| F002 | Done | F001 | content and20-slot inventory rules |
| F003 | Done | F002 | atomic gather/pickup/drop/move |
| F004 | Done | F003 | versioned saves and session rebinding |
| F005 | Done | F004 | four pickups and cancellable hold E |
| F006 | Done | F004 | backpack modal and active item HUD |
| F007 | Done | F005, F006 | safe rod drop/reposition |
| F008 | Done | F007 | readable item art/progress/feedback |
| F009 | Pending | F008 | integrated play/restart acceptance |
| F010 | Pending | F009 | fresh Windows/native acceptance |

## F001 — Pin source behavior and runtime mapping

Inputs: CONTRACT source/hash table; target layout/pinned manifest; source catalog,
state/controller/hold/fishing/UI/placement/save and related tests; target root,
session/catalog/codec/interactions. Prerequisite: verify actual production root,
schema5/content1, current worktree and M/W capabilities, not historical checkbox alone.
Work: proposed reference/README.md, minimal behavioral excerpts/vectors/hash manifest
in this folder and reference/audit.py. Inventory four nodes/support/approach and
source/runtime namespaces. Fix concrete definition mappings, placement provenance,
planned save shape in CONTRACT. No gameplay activation/map refresh.
Acceptance: reproducible audit detects drift; four exact IDs/feet mapped; durations,
limits, slot/fishing inspiration reproducible; no runtime source dependency or
unresolved design prerequisite for F002. Record geometry discrepancy/repair boundary.
Checks: existing application_smoke, content_catalog_checks, map_activation_checks,
environment_save_checks via bounded runner; proposed audit first created. Record
hashes/commands/results in tracked F001 acceptance. Ray/approach probes synthetic.

## F002 — Content and backpack rules

Inputs: F001 vectors/mappings, ContentCatalog/ContentManifest, CONTRACT behavior.
Prerequisite: verified F001 mapping/source baseline.
Work: typed immutable item/resource definitions and validated catalog references;
local moonflower/rod content; typed inventory/snapshots and add/consume/select.
Cap20 types, one stack each, caps99/1, nullable owned active item. No world/UI activation.
Acceptance:20 types accepted/21st rejected; existing stack grows with full bag;
100th flower/second rod rejected; invalid quantities/IDs reject without partial
change; final active unit consumption clears selection. Distinct resource/item
IDs resolve correctly; bad catalog init publishes no partial index. Resources
unchanged across two detached sessions.
Checks: proposed inventory_checks.gd with synthetic extra types for capacity;
existing content_catalog_checks/application_smoke. Label test-only definitions.

## F003 — Atomic item/resource commands

Inputs: F002 state/content; source controller and placement semantics.
Prerequisite: inventory invariants actually pass.
Work: session-owned collected facts/typed placements; structured gather/pickup,
drop/move command results and publication after commit. Inject validated placement
capability without scene ownership; resolve location/authored IDs/provenance;
stale/duplicate guards. No physical pointer integration yet.
Acceptance:+1 and collected origin committed together; duplicate/unknown/wrong-room/
stale requests grant nothing; full bag/stack leaves facts unchanged. Authored move
replaces origin; dropped pickup removes placement; repeated drop/pickup preserves
rod count1. Rejected placement keeps counts/active ID; successful final drop clears active.
Checks: proposed foraging_transaction_checks.gd with conservation/rejection/observer
cases; F002 checks. Placement fixtures prove service boundary, not F007 geometry.

## F004 — Save compatibility and lifecycle

Inputs: F003 state, SaveCodec/SaveRepository, root load/travel/retry, existing fixtures.
Prerequisite: transaction invariants verified.
Work: schema6 strict candidate validation/legacy migration; root session rebinding
and world-fact application hooks. Preserve v1-v5 chain, existing facts, primary/
backup/128KiB boundary and last-arrival restore. Record final fields in CONTRACT.
Acceptance: exact round-trip inventory/active/collected/placement; legacy new fields
empty with existing facts retained. Reject fractional/zero/overcap/unknown IDs,
duplicates/bad provenance/location/geometry/newer/oversized data before live swap.
Failed load/travel preserves old facts; retry retains collection. Isolated process
restart restores facts without transient hold/drag. Normal save untouched.
Checks: proposed foraging_save_checks.gd/foraging_process_checks.gd with isolated
write/read processes/exact snapshot oracle. Existing save_checks, save_process_checks,
environment_save_checks, map_save_checks, location_travel_checks. Runner-supported
evidence paths; inspect existing multi-process phase routing before reuse.

## F005 — World resources and held interaction

Inputs: F004 rebinding, four mapped records, InteractionSelector/PrototypeInteractable/
PrototypeLocation, GameRoot dispatch/gates. Prerequisite: saved facts apply correctly.
Work: production adapter consumes selected inert identities using approved ForagingRegistry runtime feet, without pinned-layout
changes; four stable nonblocking wrappers/simple initial visuals; typed gather/
pickup actions, hold controller/progress. Immediate lamps/dialogue/travel preserved.
Read-only bridge fields only as needed; no mutation shortcuts.
Acceptance: three flowers/rod at supported mapped feet/reachable approaches;
E0.6s/0.5s commits once. Release/target/LOS/range/removal and every modal/focus/
travel/load/retry gate cancels. Fresh press after completion/cancel; held E cannot
trigger adjacent lamp/gate. Full bag/stack keeps node. Lifecycle reconstructs exact
absence/count without leaked signals; existing four interaction kinds work.
Checks: proposed foraging_interaction_checks.gd and rendered hold scenario; existing
interaction_dialogue_checks, light_interaction_checks, location_travel_checks,
live_playtest_checks. Inspect progress/cancel frames and normal walking approach;
label synthetic fixtures. Basic correctness belongs here, not deferred to F009.

## F006 — Backpack modal and active item HUD

Inputs: F004 saved inventory, current HUD/pause/journal/focus, source overlays.
Prerequisite: snapshot/active ID round-trip verified.
Work: B action/HUD entry,20 slots/counts/caps/highlight/details/Close; active tool
label. Rod Drop control disabled until F007 safe path available. Bridge B allowlist/
read-only modal/inventory observations as needed.
Acceptance: empty/occupied slots accurate960x640 and smaller supported window;
mouse/Tab/Enter selection matches HUD/save; missing selection rejected/non-tool
does not claim direct use. B/Esc/Close works; modal clears held controls/blocks
movement/attack/dodge/interact/aim/zoom/contains focus; fresh world input after close.
Pause/dialogue/journal conflicts do not leak commands.
Checks: proposed backpack_ui_checks.gd/rendered keyboard-pointer flow; existing
settings_debug_checks, interaction_dialogue_checks, movement_camera_checks.
Inspect empty/selected rod/capacity fixture captures with provenance.

## F007 — Safe rod drop and reposition

Inputs: F005 wrappers, F006 modal/Drop, F003 commands; source validator/drag;
target floor/nav/blocker/water/portal contracts. Prerequisite: both branches verified.
Work: nearby drop search/facing alternatives; geometry validator; nearby rod pointer
drag ground-ray preview/commit/cancel; wire Drop and preview lifecycle/provenance.
Acceptance: normal pickup→activate→drop→drag→pickup; total rod1 across bag/world/
origin/reload. Authored/dropped move no duplicate. Water/blocked/outside/steep/
unsupported/unreachable/reserved release rolls back; no-space drop keeps bag/active.
Attack/aim conflicts blocked; Esc/focus/pause/travel/load/retry cancels no mutation.
Both projections/zoom bounds correct; rod retrievable after placement and travel.
Checks: proposed world_item_placement_checks.gd/rendered rod scenario; existing
map_navigation_checks, map_save_checks, movement_camera_checks plus F003/F004.
Boundary fixtures and actual physical pickup at committed position both needed.

## F008 — Art and peaceful feedback

Inputs: F007 loop, world visual separation/lighting/weather/camera, source resource/UI.
Prerequisite: physical behavior verified before replacing temporary visuals.
Work: small reusable stylized3D moonflower/rod assets/local icons, restrained progress,
received/full/cancel/invalid-placement feedback. Blender work uses applicable skills,
editable art/source and runtime assets; wrappers/IDs/physics stay separate.
Acceptance: three flowers/rod readable at normal zoom; progress/errors readable
day/night/rain/both projections; art removed only after success; invalid preview
clear; no clipping/hovering/foliage-obscured prompt/UI overlap. No Flame dependency.
Checks: F005-F007 suites; existing map_camera_checks, environment_lighting_checks,
weather_presentation_checks. Inspect close/wide node/backpack captures; relevant
asset checks only. No town-art redesign or mandatory new animation framework.

## F009 — Integrated gameplay and restart

Inputs: F008 runtime/art; new checks/existing PLAYTEST/support. Prerequisite: prior
capabilities have acceptance evidence and no unresolved failing gate.
Work: ordinary walk spawn→rod→each flower; hold/cancel/backpack/drop/drag/recollect,
Tollworks round-trip, GUI Save/quit/separate-process GUI Load/physical revisit.
Exercise modes/focus/combat/retry; labeled capacity/bad placement/save fixtures.
Repair feature scope; update production README/architecture/control descriptions.
Acceptance: all CONTRACT behavior observed; exact paused restart snapshot matches;
origins remain absent/rod unique/no stale input. Existing recovery/companion/lamps/
environment work. New suites/affected regressions pass; no runtime errors/warnings;
fresh visuals inspected. Fixtures not called ordinary-route proof. Measure new
frame cost against representative map/weather baseline if unresolved concern.
Checks: new feature suites; application_smoke, playable_slice_checks,
recovery_presentation_checks, combat_checks, companion_checks, light_interaction_checks,
environment_lifecycle_checks, map_activation_checks, location_travel_checks,
settings_debug_checks. Reuse bridge/TestRunSnapshot/TestRunGui/capture manifests;
proposed integrated harness only as needed. Tracked F009 acceptance records exact results.

## F010 — Fresh Windows/native delivery

Inputs: F009 accepted code/content, export_presets.cfg, existing package/native tools;
W010 acceptance procedure only. Prerequisite: F009 final-code evidence passes.
Work: fresh local release/validation packages with installed templates; inspect packed
content/assets/schema and test/debug exclusions. Launch outside checkout with isolated
appdata; bounded native ordinary gather/backpack/drop/drag/recollect and GUI Save/
restart/Load/revisit. Existing lamp/quest/travel/party behavior usable.
Acceptance: feature works standalone/source checkout not required; exact native
restart facts, both packages clean startup/quit, hashes recorded. No bridge/fixture/
mutation substituted for native proof. Fresh controls documented; no publication.
Checks: review tools/weather_lighting/build_packages.py/package_audit.gd for W-specific
assumptions before reuse; extend local audit for items. Native helper explicitly
supports B/bounded drag before use; never weaken focus/pause/provenance guards.
Tooling support is implemented and checked in [native helper acceptance](../TESTING_NATIVE_INPUT_ACCEPTANCE.md);
F010 must still verify it in the fresh release and complete all native gameplay criteria.
Tracked F010 acceptance; parent README/state completion links updated.

## Completion records

Append only after selected criteria pass:
ID/date/timezone; observable result/changed files; commands/cwd/isolation/actual
outcomes/evidence paths; decisions/retained failures/inspected artifacts; next
eligible task with verified prerequisites. Stop before starting it.
### F001 — completed2026-10-05, America/Vancouver

Pinned20 source-file hashes, catalog/behavior excerpts and vectors, distinct
item/resource namespace mapping, exact four authored feet and schema6/provenance plan.
Created offline/source auditor and synthetic production geometry check; runtime unchanged.
[Acceptance](F001_ACCEPTANCE.md) and [reference](reference/README.md) own details.

Repository-root commands: run_checks F001 with Import and application_smoke,
content_catalog_checks,map_activation_checks,environment_save_checks PASS
(20261005-072246477-fde37221); Import + reference_mapping_checks PASS
(20261005-073211388-5575def8; four nodes,1,648 capsule samples); Python audit offline
and --source-root D:/development/game-prototype-2 --self-test PASS
(audit-20261005-073430-9fcda68c). Runner isolated APPDATA/LOCALAPPDATA/check save slots;
normal save untouched; no runtime diagnostics. Allowed editor-only missing .NET SDK
diagnostic retained. Source tests read, not run. Source/map bytes and user work preserved.

Retained failed geometry runs20261005-072900870-3e922a72 and
20261005-073026478-4a95c991 revealed rod's water blocker and flower01's cliff overlap.
Final check pins these deficiencies; F005 must repair or block before activation.
Synthetic dry routes do not prove ordinary walking or usable blocked origins.
No editor/live process owned. Next eligible F002: mapping/rules prerequisite verified.
Stop before successor.

### F002 — completed2026-10-07, America/Vancouver

Added two immutable item/two resource definitions, validated distinct catalog keys and
source references, session-owned20-type inventory and detached sorted snapshots.
Caps99/1, atomic add/consume/select rejection, nullable owned selection/tool derivation,
final-unit clearing and cross-session/resource isolation verified.
[Acceptance](F002_ACCEPTANCE.md) records every criterion and API decisions.

Repository-root run_checks F002: prerequisite reference_mapping PASS
(20261007-173618317-6c5fef72); Import + inventory/content_catalog/application_smoke/
environment_save PASS (20261007-174145567-2ef98c9b); final inventory/reference_mapping/
map_activation/save PASS (20261007-174326531-6f771cc0). Inventory199 assertions;
environment codec517; mapping four nodes/1,648 capsule samples. Offline/live-source
Python audits PASS (audit-20261007-175049-e9aad353). Isolated APPDATA/LOCALAPPDATA/slots;
normal save/source untouched; runtime diagnostics empty. Existing import-only missing
.NET SDK diagnostic allowed. No failed F002 engine runs or owned live process.

Schema5/content1 retained; four world records remain inert. F005 blocked-anchor repair
boundary and all historical P/M/W/F001 evidence preserved. No UI/input/save/placement/
art/export activation. Next eligible F003; prerequisite F002 actual rules pass.
Completed exactly F002; stop before successor.

### F003 — completed2026-10-07, America/Vancouver

Added pinned four-node registry, session-owned collected facts/typed placements,
structured gather/pickup/drop/move results and post-commit signal. Revision and
committed-location guards, fail-closed injected placement capability, detached
observations and reentry rejection preserve atomic outcomes and rod1 conservation.
[Acceptance](F003_ACCEPTANCE.md) records every criterion and API boundary.

Repository-root run_checks F003: inventory prerequisite PASS
(20261007-182122692-f0e545dc); Import PASS but test parse typo FAIL retained
(20261007-182622044-53f5ad0e); corrected transaction/inventory/catalog/application/save
PASS (20261007-182714901-8301608f); final transaction/map/environment/travel PASS
(20261007-182823373-7e09f842). Final transaction583 assertions, inventory199,
environment codec517; ten travel round trips. Runtime diagnostics empty; existing
import-only missing .NET SDK diagnostic allowed. Isolated APPDATA/LOCALAPPDATA/slots;
normal save untouched. Offline/live-source audits PASS
(audit-20261007-182858-342d8acb); source/geography hashes and clean source preserved.

Placement fixtures prove service boundary only; F007 physical geometry remains
pending. Schema5/content1, inert physical nodes/UI and P/M/W release history retained.
No live process/editor or cleanup owed. Next eligible F004; F003 command invariants
actually pass. Completed exactly F003; stop before successor.

### F004 — completed2026-10-07, America/Vancouver

Added schema6 strict detached fact hydration/legacy defaults, duplicate-key/exact
quantity guards, conservative staged current/foreign-room geometry rollback, root
session rebinding and one-listener world-fact hooks. Exact binary whole-save oracle
verifies four item states plus foreign-room saved rod/revisit in independent processes.
[Acceptance](F004_ACCEPTANCE.md) records every criterion, final fields and limits.

Prerequisite transactions PASS (20261007-183832347-675eff88). Broad save/item/map/travel/
application and both independent process suites PASS (20261007-185011795-a73efb5b).
Focused save110/inventory199/mapping4 nodes1,648 samples/environment lifecycle157/
process writer51-reader54 PASS (20261007-185334208-1e788c99). Final hydration guard
save111/transactions583/process PASS (20261007-185936104-3f946051); final disposed-owner
guard/exact restart writer52-reader55 PASS (20261007-190122906-919e912b). Final runtime diagnostics
empty; existing import-only missing .NET SDK diagnostic allowed. Retained failed runs
and their repairs recorded in acceptance. Isolated APPDATA/LOCALAPPDATA/slots/evidence;
normal save untouched. Offline/live-source audits PASS (audit-20261007-185433-c302ac16),
pinned source/geography bytes unchanged and source clean.

Physical nodes/UI remain inert; F005/F007 gameplay geometry and F009/F010 ordinary/native
acceptance remain Pending. Original F001 anchor blockers preserved. Historical P/M/W
packages remain schema5 evidence; no new export claim. No editor/live process or cleanup
owed. Next eligible F005 with F004 actual prerequisites verified. Exactly F004 done; stop.

### F005 — blocked2026-10-07, America/Vancouver

Selected F005 with clean HEAD be2b3b85e2da3794802ff004ed169973dd1bb33e;
marked In progress before investigation. Fresh production diagnosis confirms rod
foot/sight inside south-water-06 and flower01 inside two cliff bodies. Fixed authored
XZ, supported feet, unchanged map and no LOS bypass cannot all be satisfied. Followed
CONTRACT explicit blocked boundary; no world/hold activation or Done claim.
[Blocker decision](F005_BLOCKER.md) records every acceptance criterion, exact bounds,
retry decision and reusable foraging_anchor_checks.gd/UID.

Repository-root run_checks F005 prerequisite save111/mapping4 nodes/1,648 capsule
samples/independent-process writer52-reader55 PASS (20261007-191556187-ad924655).
Import/parse/anchor diagnosis PASS (20261007-191707777-2d925cd8); strengthened final
foot/sight containment diagnostic PASS (20261007-191757099-44340ed6). Reports/logs
inspected; runtime diagnostics empty; only existing allowed import .NET SDK diagnostic.
Isolated appdata/check slots; normal save/source/geography/runtime unchanged. No
rendered/native proof or remaining F005 criteria claimed. All owned processes exited.

F005 needs explicit anchor-policy/map-repair authorization before retry. F006 next
eligible independently after freshly verified F004; F007 remains blocked by F005.
Exactly F005 attempted; stop before successor.

### F005 relocation follow-up — 2026-10-07, America/Vancouver

User explicitly authorized rod/flower01 relocation. Geometry blocker resolved; F005
returned to Pending for remaining world/hold implementation, not Done. Registry keeps
pinned source feet and stable IDs; rod default now (-6.5,0,15.75), flower01 default
(26.75,0.25,-2). Source/map/colliders/navigation unchanged; saved placements and
collected facts retain exact semantics. [Relocation record](F005_RELOCATION.md) records
all decisions/evidence; CONTRACT now owns approved exception to prior fixed XZ.

Fresh F005 run20261007-202154715-207af0c2 PASS: parse, four safe supported/nav/LOS anchors,
transaction587, save111, historical mapping4/1,648 samples, exact independent writer52/
reader55. Diagnostics empty; source20/geography3/reference3 hashes unchanged. Normal
save untouched; no live process/cleanup. Preserved prior blocker work/history.
Requested relocation finished; no held-interaction/successor activation. Next F005.

### F005 - completed2026-10-07, America/Vancouver

Four typed nonblocking runtime wrappers activate approved registry feet; root-owned
weak hold controller commits flowers600ms/rod500ms once, cancels every mode/target/
LOS/range/removal gate, and consumes E until release. Full capacity keeps nodes.
Saved authored/generated/foreign-room placements, load/travel/retry absence/count and
one-listener ownership verified. [Acceptance](F005_ACCEPTANCE.md) owns every criterion,
commands, inspected images, isolated evidence and retained failures.

Final interaction99/light151/dialogue PASS (20261007-205238453-486e18c7); enhanced
independent process writer66/read69 PASS (20261007-204632170-6b9a55f0). Anchor/map/
travel/bridge/movement/settings/save affected regressions PASS as recorded. Final
ordinary rendered four-node walking/hold/release/GUI Save/new-process GUI Load/exact
oracle/rod revisit PASS (20261007-205250215-6f77c16d);10 paused writer/2 live hold frames,
3 paused reader frames. Offline/live-source audit PASS (audit-20261007-205145-fc1c2562).
Runtime diagnostics empty; existing import-only SDK diagnostic allowed. Pinned source/
map/colliders/nav and normal saves preserved; all owned processes exited.

Exactly F005 completed. Next eligible F006; F004 inventory/save prerequisite verified.
Backpack/drop/drag/art/native/export successors unstarted. Stop before successor.

### F006 — completed2026-10-07, America/Vancouver

B/HUD twenty-slot backpack, truthful count/cap/details/active tool HUD, nullable selection,
teal active highlight, contained keyboard/pointer focus and B/Esc/Close. Root modal gates
cancel holds/clear input/block world actions; Drop remains disabled until F007.
[Acceptance](F006_ACCEPTANCE.md) records every criterion and provenance.

Prerequisite save/inventory/exact process oracle PASS20261007-213213568-cd9e372d;
import/smoke PASS213515217-d12b8527. Final production-code save111/backpack142/dialogue/
settings/smoke plus ordinary rendered GUI Save/new-process exact GUI Load PASS
20261007-214630223-026c35f0; final expanded145 backpack assertions PASS214749916-fd20c1ad.
Movement/camera, foraging interaction and bridge regressions PASS213714822-a63ef3ab and
214410243-746669a9 (those full runs retain separate fixture failures described in acceptance).
Offline/live-source audit PASS audit-20261007-214511-1b518619. Normal save untouched;
runner appdata/localappdata/slots isolated. Runtime diagnostics empty in final passing runs;
existing import-only missing .NET SDK allowed. No install/native/export claim.

Retained initial wrong active_tool fixture, unexplained first rendered timeout, and
inherited shared-save backup fixture failure. Save fixture now sets isolated repository
after root startup; strict rollback tests pass. Final images inspected at normal/smaller
window; capacity uses detached synthetic display fixture. All owned processes exited,
no cleanup owed. Next eligible F007 with verified F005/F006 prerequisites. Exactly F006
completed; stop before successor.

F006 pre-commit review: restored journal-only upgrade guard; earned-point modal regression
PASS146 + consequence checks in20261007-220250776-080c65b1. Legacy consequence fixture
now omits v6-only item facts for v1-v3 tests. Acceptance/state retain failed fixture run.

### F007 — completed2026-10-07, America/Vancouver

Enabled nearby facing/alternative rod Drop and pointer ground-ray preview/move;
full rod footprint/capsule/dry approach/nav/reservations validate before atomic commit.
No-space/invalid/cancel keeps exact item facts. Authored/generated IDs stay unique;
transient drag, weak ownership, old-pointer release latch and lifecycle guards own no
saved facts. [Acceptance](F007_ACCEPTANCE.md) records every criterion and limits.

Repository-root run_checks F007: prerequisite hold/backpack PASS220518849-11e36ba1;
Import/startup/anchors PASS220843828-6ce5b7f4. Broad ten headless suites PASS in
20261007-222143996-d4aa795e (separate inherited process token assertion failure retained).
Final placement128/dialogue/light151/settings PASS222352948-2d6c59fa; strict save111/
exact independent-process writer71/read74 PASS222435865-2b1a1307. Ordinary rendered
pickup/activate/drop/drag/pickup, Tollworks round trip, normal revisit, GUI Save/new
process GUI Load/exact whole-save oracle and physical recollect PASS
20261007-222237176-015ce980. Final full-size preview/placed/recollected PNGs inspected.
All times above have20261007 prefix; raw evidence/appdata/slots isolated under F007.
Final runtime diagnostics empty; prior import-only missing .NET SDK allowed.

Offline/live-source audit PASS audit-20261007-222532-37ffd81f; source/geography hashes
and clean source unchanged. Failed fixture/nav-sync/walk runs retained in acceptance.
No normal-save/source/map change, native/export/install/publication or owned process
cleanup owed. Final diff/new files/UIDs/status/links reviewed. Next eligible F008,
with F007 physical prerequisite verified. Exactly F007 completed; stop before successor.

### F008 — completed2026-10-07, America/Vancouver

Delivered editable local Godot moonflower/rod mesh kit, matching SVG backpack icons,
night-readable outlined names, restrained progress, separate received/full/cancel/error
feedback rows and safe modal layering. Wrapper IDs/physics/transactions/schema unchanged.
[Acceptance](F008_ACCEPTANCE.md) records every criterion, retained failures and review.

Final F008 runs:023604025-07197561 (20261008 UTC prefix) seven headless suites plus
ordinary rod loop/travel/exact GUI restart PASS;023932515-6c0a4fcc art880 assertions/
96 captures PASS;023952938-ee775a1c ordinary backpack/icon/small-window/exact restart
PASS;024024303-277571c5 ordinary four-node gather/cancel/exact restart/absence PASS.
All share490-file source SHA25687580ae010b1da7fc06c0928afeddbdad257fe0aef2cbec1c821641cdd72112b;
no runtime diagnostics/timeouts/source drift. APPDATA/LOCALAPPDATA/slots isolated;
normal saves/source/geography unchanged. Capture provenance checked and full-size images
inspected; synthetic matrix/capacity remains distinct from ordinary viewport journeys.
All owned processes exited. Next eligible F009; F008 actual criteria verified.
Completed exactly F008; stop before successor.
