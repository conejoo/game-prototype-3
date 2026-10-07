# F006 — Backpack modal and active item HUD acceptance

Completed 2026-10-07, America/Vancouver. Exactly F006 completed; F007-F010 Pending.
Baseline HEAD `d8956b3387f9ed280207c6d25e301731d38b92f6`, clean target worktree.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns behavior.

## Observable result and ownership

B or header Bag opens a centered twenty-slot 5x4 backpack. Sorted owned stacks show
name/count/cap; empty slots cannot select. Teal pressed style marks active selection;
white focus outline remains distinct. Details and footer identify selected non-tool
versus active tool, explicitly state unavailable direct use/fishing. Nullable selection
can be cleared. Rod-only Drop remains visible/disabled until F007 provides safe placement.

BackpackView receives detached snapshots and emits selection/close requests only.
GameRoot owns mode, validates current ownership/focus/lifecycle on every command and
uses existing InventoryState.select. No new durable field, controller, save service,
world item command or fishing behavior. Opening cancels holds, clears actor controls,
disables combat/AI and blocks world pointer/projection/zoom/input. B/Esc/Close release
focus without opening Pause; old pointer and held movement stay cleared. E's existing
release latch requires a fresh press after backpack cancellation. Session time follows
existing modal policy and can advance while backpack is open; backpack is not global pause.

Pause/dialogue/journal/travel/load/retry/focus/combat reject conflicting opening or
selection. All keyboard focus neighbors cycle through available slots/Clear/Close.
Background pointer input cannot activate another modal. Travel/retry close backpack;
load is allowed only after close at the existing stable pause boundary. Bridge adds B
and detached read-only modal/slot/detail/HUD observations; no inventory mutation command.

## Criterion evidence

| F006 criterion | Fresh evidence and outcome |
| --- | --- |
| Empty and occupied twenty slots/counts/caps at960x640 and smaller supported window | backpack_ui_checks verifies all20 slots and per-slot bounds/counts at960x640/800x600. Final renderer captures empty/rod/capacity at both sizes, all inspected where noted below. PASS. |
| Mouse/Tab/Enter selection agrees with HUD/save | Actual viewport Enter selects ordinary gathered rod; Tab/Enter selects ordinary flower; pointer reselects rod before GUI Save. Separate-process GUI Load uses exact whole-save oracle and verifies owned selection/highlight/HUD. PASS. |
| Missing selection rejects; non-tool does not claim use | Known-unowned rod and unknown ID reject without selection mutation; flower active_tool null and selected-item/no-direct-use labels. Rendered flower details inspected. PASS. |
| B/Esc/Close works | Headless and rendered B/escape/HUD/pointer Close paths; no accidental pause, released GUI focus. PASS. |
| Modal clears held controls and blocks movement/attack/dodge/interact/aim/zoom; contains focus |145 final headless assertions include cleared accepted D, zero velocity, disabled combat/AI, stationary actor/facing/camera, hidden aim, E/Space/click/wheel/P/+/-/J/R/F6 rejection and contained focus cycles. Ordinary rod hold canceled by B before reward. PASS. |
| Fresh world input after close | Continued held D and old pointer cannot resume; fresh D moves, fresh pointer attacks, fresh Space dodges. Ordinary held E cannot gather after close until release/new press; fresh E acquires rod. PASS. |
| Pause/dialogue/journal conflicts do not leak commands | Dedicated pause/journal/dialogue/loading/travel/retry/focus/attack fixture matrix plus inherited settings_debug/interaction_dialogue/movement_camera/foraging_interaction/live_playtest suites. No command facts leaked. PASS. |

Last-active-unit fixture additionally proves HUD/detail clearing and stack becoming empty.
Synthetic extra item definitions are confined to test manifests; no production catalog
or saved item IDs added. Detached render-capacity fixture changes presentation only,
asserts actual session inventory unchanged, and is never offered as ordinary gathering.

## Commands and outcomes

All commands from `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7,
installed console4.7.2.stable.mono.official.ed1daf0bf. Full results.json and stdout/stderr
reviewed, not exit status alone. Each runner invocation uses fresh evidence/appdata/
localappdata/check slot under docs/evidence/F006 and builds/testing/F006. Normal save untouched.

| Run | run_checks.ps1 arguments | Actual outcome |
| --- | --- | --- |
|20261007-213213568-cd9e372d| -Task F006 -Names foraging_save_checks,inventory_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150 | PASS prerequisite: save111/inventory199; independent-process exact durable/physical oracle. |
|20261007-213515217-d12b8527| -Task F006 -Import -Names application_smoke -TimeoutSeconds 150 | PASS new-class import/parse/startup. Existing editor-only missing .NET SDK10.0.9 allowed; no install. |
|20261007-213714822-a63ef3ab| -Task F006 -Import -Names backpack_ui_checks,settings_debug_checks,interaction_dialogue_checks,movement_camera_checks,foraging_interaction_checks,live_playtest_checks -TimeoutSeconds 150 | Backpack fixture failed wrong API comparison (Object versus String); all five affected regressions PASS. Failure retained. |
|20261007-213942370-c3764ab1| -Task F006 -Import -Names backpack_ui_checks -RenderScript backpack_ui_render -RenderPhases write,read -TimeoutSeconds 150 | Headless140 PASS; rendered writer timeout after empty resize captures. No runtime diagnostic. Retained; no acceptance from this writer. |
|20261007-214234081-ae9915ec| -Task F006 -RenderOnly -RenderScript backpack_ui_render -RenderPhases write,read -TimeoutSeconds 150 | PASS ordinary writer/reader; stage logs added, no gameplay gate changed. |
|20261007-214410243-746669a9| -Task F006 -Names backpack_ui_checks,settings_debug_checks,interaction_dialogue_checks,movement_camera_checks,foraging_interaction_checks,live_playtest_checks,foraging_save_checks -RenderScript backpack_ui_render -RenderPhases write,read -TimeoutSeconds 150 | Backpack142 and all input regressions PASS; inherited save fixture FAIL due shared-slot backup recovery. Render intentionally not started. |
|20261007-214630223-026c35f0| -Task F006 -Names backpack_ui_checks,foraging_save_checks,interaction_dialogue_checks,settings_debug_checks,application_smoke -RenderScript backpack_ui_render -RenderPhases write,read -TimeoutSeconds 150 | PASS final production code: backpack142/save111/dialogue/settings/smoke, ordinary writer7 modal images+Save and independent reader1 modal image+Load. Exact prior/item/forecast oracle PASS. |
|20261007-214749916-fd20c1ad| -Task F006 -Names backpack_ui_checks -TimeoutSeconds 150 | PASS final expanded145 assertions including known-unowned rejection/fresh attack/dodge. |

Final successful runtime diagnostics empty; no runtime warnings/errors/timeouts. Only
pre-existing import-only SDK diagnostic allowed. No native/export/install/publication.
Raw evidence ignored; reusable checks/scripts/UIDs tracked. All owned processes exited.

Offline and live-source audits PASS in `audit-20261007-214511-1b518619` via bundled Python:
`docs/foraging-items-backpack/reference/audit.py --self-test` and `--source-root D:/development/game-prototype-2 --self-test`.
Twenty source inputs,3 local reference and3 geography hashes unchanged;5 offline/6 live
in-memory negative controls. Source tests read, not run. No source runtime dependency.

## Render provenance and inspection

Final writer enginePID26152; readerPID68684. Actual normal viewport WASD follows camera
vectors/navigation routes from fresh spawn to rod/flower; E goes through production hold.
Bag selection uses B/Tab/Enter and viewport pointer events, without teleport/fact grant.
Save/Load use unchanged pause-gated TestRunGui, exact TestRunSnapshot oracle and independent
SaveRepository decode. Writer saves rod1/flower1 with active rod and both collected origins
plus every prior durable fact/forecast. Reader starts fresh and proves exact restoration.

Backpack screenshots are explicitly unpaused modal captures in `modal_views`, guarded by
backpack visibility, disabled world controls and focus inside backpack. They report actual
paused=false, viewport/window dimensions, enginePID/version, camera, actual inventory,
display slots/details and setup provenance. They do not weaken TestRunCapture's pause guard.
Save/Load images in `views` use the existing pause capture helper. At requested800x600 window,
Godot's aspect-preserving content texture is800x533; metadata records both actual sizes.

Full-size final empty960, selected rod800, capacity800 and restored selected rod960 PNGs
inspected. Teal active slot, counts/caps, wrapped details, disabled Drop, Close and all20
capacity entries readable and contained. Earlier passing flower960/empty800 images also
inspected; later selected styling leaves same layout. Capacity fixture is detached synthetic
presentation (18 extra display items, flower99/rod1); actual session/save remain rod1/flower1.

## Retained failures and necessary repairs

Initial test compared InventoryState.active_tool (ItemDefinition) to ID String. Corrected
fixture to actual catalog definition. First rendered timeout cause was not established;
stage logging plus subsequent two full writer/reader runs pass, with no focus/input bypass.
The timeout and partial images remain retained, not described as passed.

Inherited foraging_save_checks assigned repository before root _ready; runner --save-slot
replaced it. Running after other Save checks exposed existing backup recovery and wrong
rollback oracle. Fixture now assigns PID-qualified test repository after initial arrival.
Strict malformed/geometry rollback criteria unchanged; repaired111 assertions pass.
An initial text-edit anchor failed before writing; retried preserving original newlines.

Changes: new BackpackView/backpack_ui_checks/backpack_ui_render and three UIDs; root/input/
UI scene and bridge integration; save fixture isolation repair; README/architecture/PLAYTEST
and workflow docs. Diff/new-file/whitespace/link/status review complete. Schema6/content1,
pinned geography/source and historical P/M/W packages unchanged. F007 is next eligible:
F005 physical pickup and F006 modal prerequisites verified. Stop before drop/drag implementation.

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
