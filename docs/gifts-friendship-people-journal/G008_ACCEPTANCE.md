# G008 integrated social and restart acceptance

Completed 2026-10-09 UTC. Exactly G008; [checklist](CHECKLIST.md),
[contract](CONTRACT.md), [continuation](CURRENT_STATE.md).
Entry HEAD `d9751d5ae9ec126eaf11a0e3432cabddb277fbba`, clean worktree, no nested
instructions or unrelated changes. Read-only source remains clean at
`60c20eb2816e7271fb84afaba286af006ebe3ccf`.

## Delivered verification

New [integration checks](../../game/tests/social_integration_checks.gd) and
[ordinary renderer](../../game/tests/social_integration_render.gd), with UIDs,
reuse production services and shared journey, GUI, capture and restart helpers.
The renderer inherits existing N017 physical navigation/recovery/combat helpers;
its accepted routes send ordinary viewport WASD/E/mouse/Tab/Enter/F10. It performs
no position, item, fact, quest or timer setup. A direct rejected stale-command
assertion is negative rule proof, not an ordinary accepted action.

The headless fixture explicitly supplies synthetic inventory/events and damage/
focus notifications. It verifies independent mixed-roster progression, People,
codec, cap rejection, focus loss and real root retry. Existing NPC integration's
obsolete enabled counts are updated from58/38 to the approved67/48, retaining its
navigation, crowd and retry assertions. No production runtime change was needed.
All943 other pre-existing game/tools files remain byte-identical. Content, art,
pins, geography, three flowers, rod placement, packages and schema7/content1 stay
unchanged. No native or packaged acceptance is claimed.

## Acceptance mapping

| Criterion | Evidence |
| --- | --- |
| Fresh helpful Edric, real preference and two gifts | Final writer physically approaches Edric, chooses the helpful introduction, gathers moonflower-01 and moonflower-02 independently with held E, enters the source gathering hint/woods detour, then gives through authored GUI choices. Bag1 becomes0 each time; affinity1 becomes2 then3. Exactly one milestone seen ID and its entry flag persist. Conversation feedback and People show reached3/3. Ordinary stale rejection cannot repeat effects. |
| Third finite flower and all-eight accessibility | Writer meets the other seven at their actual contacts, uses every enabled public fact branch, and verifies all21 learned facts. HUD People plus contained Tab/Enter selects every sorted row, including scrolling to Tess; eight inspected entry captures show authored portraits/progress/learned details. Only then moonflower-03 is physically gathered and gifted to Maris: affinity2, no invented milestone. Exactly three collected flowers, three gifts, zero remaining units; no additional supply. |
| Fresh neutral Edric stays below threshold | Independent empty-save/app-data neutral run chooses the guarded introduction and physically gathers/gives two distinct flowers. Affinity2, zero milestone entries/no seen flag, People2/3, other people absent. Separate normal F10 quit succeeds. The neutral phase in the final paired group is additional corroboration; independent run is primary isolation proof. |
| All-eight branches/fact gates/caps and other-seven levels | Integration402 synthetic assertions plus gift335, transaction238, milestone657, strict social-save844/560 malformed cases, UI355 and projection960 pass. Existing suites cover all ten gift choices, all nine response/milestone nodes, shared Edric/Helena caps, missing facts/items, stale/reentrant commands and independent positive3/neutral2 level derivation. Artificial full-roster supply is never described as ordinary gathering. |
| Revisit/travel/retry/modal/focus and old systems | Ordinary writer completes the entire shortened recovery: legal lead, J preparation upgrade/damage40, physical east gate, actual guardian combat, vessel, return gate/ford, fitting and reconnection. Six effects/specialist, two party members and eight contacts remain; exact social/item/collected/placement invariants survive. Synthetic gifted all-eight root focus loss and death/retry preserve the whole healed durable snapshot. NPC/modal/foraging/bag/placement/quest/consequence/companion/environment/movement regressions pass. Companion trust remains independently owned. |
| Actual GUI Save/quit/new-process GUI Load | Writer GUI Save matches independently typed disk state and writes TestRunSnapshot oracle; normal F10 quit exits0. Reader PID37312 differs from writer5756, starts with default empty memory/inventory, activates GUI Load, and matches every supported durable field plus exact reconstructed forecast. GUI re-save while confirmed paused preserves exact16549 primary bytes and full snapshot. Current format remains schema7/content1. |
| Restored People/conversations cannot duplicate rewards or remove facts | Reader opens People using HUD/Tab/Enter and physically revisits all eight source chats, including restored Maris specialist/chat routing. Exact people, gift counts2/1, inventory, collected IDs and placements persist. Edric shows remembered follow-up, not milestone replay. Quest/effect/trust/upgrade/party/health/override/location/spawn/version fields remain equal to typed saved state. Walking legitimately changes elapsed177.359679751747 to241.566684418399 and woods count5 to6; these are recorded separately in resumed_changes, never tolerated at the paused restart boundary. |
| Evidence integrity and preservation | All accepted runner cases have zero diagnostics/timeouts/source changes/errors. Reference and current converter audits pass exit0/empty stderr; no repin. Capture validator verifies hashes, modes, paused/live provenance, focus and actual960x640 dimensions. All135 final images/13 sheets and full-size details are inspected. Failed attempts and earlier evidence remain local. |

## Commands and exact evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`.
Installed console checked first:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
version `4.7.2.stable.mono.official.ed1daf0bf`.
Bundled PowerShell7:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.
Bundled Python:
`C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
./tools/run_checks.ps1 -Task G008 -Names social_integration_checks,social_gift_checks,social_transaction_checks,social_milestone_checks,social_save_checks,social_gift_ui_checks,people_snapshot_checks,people_journal_checks,npc_integration_checks,npc_world_checks,npc_dialogue_ui_checks,foraging_transaction_checks,foraging_save_checks,foraging_interaction_checks,backpack_ui_checks,world_item_placement_checks,inventory_checks,quest_checks,consequence_checks,companion_checks,environment_save_checks,save_checks,movement_camera_checks,npc_03_checks -ProcessScripts social_process_checks,foraging_process_checks,save_process_checks -RenderScript social_integration_render -RenderPhases write,read -TimeoutSeconds 600
./tools/run_checks.ps1 -Task G008 -RenderOnly -RenderScript social_integration_render -RenderPhases write,read,neutral -TimeoutSeconds 600
./tools/run_checks.ps1 -Task G008 -RenderOnly -RenderScript social_integration_render -RenderPhases neutral -TimeoutSeconds 150
```

- [Bulk results](../evidence/G008/20261008-235752905-d991f487/results.json): all34
  cases pass, including24 headless suites, three write/read pairs, engine/parse
  and initial ordinary writer/read. Digest
  `d87eff1cdaeeb78c64030f713c73072917ca3b37e329146721ccfb6488738786`.
  Initial rendered proof is superseded by final stronger keyboard/old-state proof.
- [Final rendered results](../evidence/G008/20261009-000811061-dde318b2/results.json):
  all5 cases pass; writer540/100 captures, reader84/13, neutral78/11. Only renderer
  changed since bulk: replace direct UI focus assignment with actual contained
  Tab/Enter, capture every ordinary People entry, strengthen post-walk equality.
  Final948-file digest
  `7bf51aec36d9c8afb9065dca63dd15c6da964a0e7a8bdde8e84c160ece8cb530`.
- [Independent fresh neutral results](../evidence/G008/20261009-001331279-279274fa/results.json):
  all3 cases pass,78 assertions/11 captures; same final digest, separate empty
  app-data/save group, default fresh state and normal quit.
- [Reference/converter logs](../evidence/G008/reference-20261008-2356/): both exit0,
  empty stderr; current catalog SHA256
  `efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`.

Every suite/process pair/render group uses distinct runner-owned APPDATA/
LOCALAPPDATA/slots under builds/testing/G008/<run>. Final paired render slot is
`check-20261009-000811061-dde318b2-000`, group render-000; only its write/read pair
loads the writer file. Supported primary save16549 bytes, SHA256
`3052be6ab3b153fb94544365c960049efaea9fce7c5d778c779331e33361d1b1`.
Normal saves are untouched. Exact arguments, cwd, group paths, observed PIDs and
exit results live in runner reports; elapsed/environment continue in live modals.

Validated/inspected final image reports:
[writer100](../evidence/G008/20261009-000811061-dde318b2/render/derived/20261009-001132-7360f9c0/capture-report.json),
[reader13](../evidence/G008/20261009-000811061-dde318b2/render/derived/20261009-001318-a3d025a4/capture-report.json),
[paired-neutral11](../evidence/G008/20261009-000811061-dde318b2/render/derived/20261009-001354-4ee564b6/capture-report.json),
[independent-neutral11](../evidence/G008/20261009-001331279-279274fa/render/derived/20261009-001440-3c07768e/capture-report.json).
All13 sheets reviewed; full-size milestone/bag feedback, third-recipient People,
Tess scroll, paused saved status and independent neutral2/3 also inspected.
Detail text clipping within its visible scroll area is intentional and scrollable;
fixed exits remain reachable. Earlier neutral11/sheet/full-size were also inspected.

## Retained attempts and stop

235407 sandbox console launch Access denied, then reviewed isolated escalation;
235427 import generated two UIDs and correctly failed source guard (existing
editor-only missing .NET SDK allowance, no install);235443 wrong fixture NODE
constant corrected to existing seen-node memory;235509 HUD click occurred before
its normal per-frame disabled state settled after dialogue close, repaired with
four rendered frames. No runtime input gate was bypassed. Early235623 neutral
passes402 synthetic/70 ordinary assertions and11 captures; final keyboard proof
supersedes its focus setup. All failures remain failed and retained.

Final diff/link/status/dependency/source/process review is retained under
docs/evidence/G008/final-review. No required criterion remains failed/unrun.
No blocker, owned live process, held input or cleanup owed. No commit, push,
export, publication, external message or successor implementation.
G008 Done. Next/remaining G009. Every item through G009: incomplete. Stop here.
