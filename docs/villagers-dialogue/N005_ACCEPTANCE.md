# N005 portrait conversation acceptance

Completed 2026-10-08 UTC. Exactly N005 implemented and accepted; N006-N018 remain
Pending. No commit or push during implementation; the later authorized commit
follow-up is recorded in [CURRENT_STATE](CURRENT_STATE.md). Status authority:
[CHECKLIST](CHECKLIST.md).

## Baseline and delivered behavior

Target began clean at `2efc420902f2e6a68825dfbfb6827a25f762d89f`; source began and
remains clean at `60c20eb2816e7271fb84afaba286af006ebe3ccf`. No existing user changes
were present. Godot console/editor paths specified by AGENTS exist; checks use
4.7.2.stable.mono.official.ed1daf0bf, Compatibility. Schema7/content1 remains current.

`GameRoot.dialogue` now owns one `NpcDialogueService` cursor for source NPC graphs
and existing prototype conversations. `begin(npc_id, instance_id)` selects the
ordinary source entry; `begin_graph(ConversationDefinition, instance_id)` selects
an authored finite prototype graph. Both use the same graph/node/choice machinery,
stable identity/token commands, snapshot, modal, lifecycle and save boundary.
There is no second root conversation owner or parallel line-cursor API.

`ConversationDefinition` validates typed finite JSON graphs and produces
`NpcDialogueGraph` nodes. All six original resources were converted: Maris counter,
fitting and specialist, temporary companion, recovery vessel and practice marker.
An independent comparison against HEAD verifies exact original resource identities,
speakers, line and response words/order, 15 choice IDs/labels and quest/reaction
commands across 24 nodes. The three superseded DialogueDefinition/DialogueChoice/
DialogueService scripts and UIDs are removed; game GDScript/TRES has no references.
Current callback owners verify the actual live source, current graph/node command
and focus before applying existing quest or companion effects. Callback reentry
rejects and cancellation cannot resurrect a cursor. The companion remains labeled
temporary; source NPC affinity and companion trust remain separate.

`ConversationView` presents speaker/expression, an aspect-preserving 184x184
portrait, authored formatted body, branch buttons and compact learned facts.
Body, choices and facts scroll independently; Continue/Close stay outside scroll
regions. Paired source Markdown bold markers render as bold, literal brackets stay
literal, and only current-node disclosed fact terms highlight. Facts come from
authoritative per-person learned IDs. Existing Maris recovery reads the same
person's facts without granting ordinary facts or affinity. Gifts/interior access
remain unavailable with player-facing reasons. No full journal or gift transaction.

The 48 byte-exact source portraits were already bundled by N002 and are reused.
Read-only `convert_content.py --check --source` verifies all132 pinned authority
hashes and all67 runtime outputs (48 portraits, 18 reference sheets, catalog).
Catalog SHA256 remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
No NPC source catalog, art, geometry, geographic snapshot or save-format change.

## Every acceptance criterion

| Criterion | Verified evidence |
| --- | --- |
| Current source portrait, body and fact highlights | Real eight-person introduction/revisit snapshots checked against current source nodes, texture paths, parsed authored words, revealed fact terms and exact learned IDs. Full modal captures and six contact sheets viewed; raw bold markers corrected before acceptance. |
| Long body/choices scroll; eight people and expressions undistorted | Both scrollbars exceed visible page for deliberate length fixture. Bounded panel/exits fit actual 960x640 and 1350x900 rendered captures. All48 source PNGs are512x512 and retain aspect; two enlarged portrait contact sheets inspected. |
| Keyboard/mouse navigation and exits with unavailable gifts | Enter chooses authored introduction; pointer chooses enabled source follow-up. Edric's actual unavailable-only gift node: Tab/Shift-Tab/arrows contain focus, disabled click changes nothing, pointer Close and Esc exit without effects/input lock, Enter Continue exits. |
| Only disclosed facts appear | Every selected person's fact description appears iff its ID is in authoritative learned IDs. Snapshot IDs equal memory IDs; deferred archive disclosure absent. Maris existing flow reads the same learned facts. |
| Open/change/close clear held controls and contain focus | Held W cleared on opening; movement cleared on node changes; repeated Tab stays inside panel; closing releases focus and controls, with no held-input resumption. Existing both-room interaction suite proves fresh movement/attack works afterward. |
| Block attacks/dodge/gather/drag/zoom/save/load | Actual root key/mouse/wheel input and adversarial direct commands: position/combat/camera unchanged, no hold/drag or other modal, world/debug commands reject. Save/Load reject even forced pause; no pause stacking. |
| Cancel/focus loss/unload never duplicate effects or lock input | Stale GUI token rejection preserves complete memory; Close applies no reward; reentrant callback cannot replay, canceled callback cannot restore cursor. Focus loss cancels without mutation, gain requires fresh controls. World reload cancels owner and preserves exact memories. Manual closed-dialogue Save/Load restores exact memory into inactive cursor. |
| Existing prototype outcomes and superseded engine removal | Six-resource byte/semantic audit; interaction, quest, consequence, recovery, asset and catalog suites pass. Legal recovery/reconnection/training behavior retained; synthetic fake source cannot grant a quest reward. No old class/caller references remain. |

All UI fixtures instantiate the actual root and feed viewport GUI input. NPC contact
bindings and long-text/expression selection are explicitly synthetic. Expression
review changes display only, never source memory. These tests do not prove ordinary
eight-person world access, 3D character art or a new native release; those belong
to later tasks. Window request1440x900 renders1350x900 under the current viewport
configuration; screenshot manifests record actual dimensions, not the request.

## Commands and fresh evidence

All commands run from `D:/development/game-dev-blender/returning-fair-prototype`,
PowerShell7. Shared runner creates per-run isolated appdata/localappdata beneath
`builds/testing/N005/<run>/`, per-check named slots and paired process save groups.
Normal user saves never accessed. Runner audits diagnostic logs, source fingerprints,
timeouts and owned engine processes, beyond checking exit codes.

Expanded acceptance run:

```powershell
./tools/run_checks.ps1 -Task N005 -Import -Names npc_dialogue_ui_checks,interaction_dialogue_checks,backpack_ui_checks,live_playtest_checks,content_catalog_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,quest_checks,consequence_checks,recovery_presentation_checks,application_smoke,asset_pipeline_checks,foraging_interaction_checks,world_item_placement_checks,light_interaction_checks,environment_session_checks,settings_debug_checks,map_camera_checks,map_companion_checks -ProcessScripts npc_process_checks -RenderScript npc_dialogue_ui_checks -RenderPhases check -TimeoutSeconds 180
```

Evidence `docs/evidence/N005/20261008-092317416-ddbcf325/`: all26 cases PASS/exit0,
no forbidden diagnostics, timeouts or source changes. Independent NPC production
save writer PID29640/reader PID23608 compare exact complete old/new durable state.
`conversion-audit.json` verifies six resources,24 nodes/15 choices and removed API.
Stable772-file fingerprint
`fa3661ada34c620613007acd761540c4985d71763f6f1daafe092921bdae78f4`.
Only the existing import-only SDK10.0.9 message is allowed by the unchanged runner.

After player-facing unavailable reasons/disabled contrast and one assertion changed,
required UI/regression/rule suites plus render reran:

```powershell
./tools/run_checks.ps1 -Task N005 -Names npc_dialogue_ui_checks,interaction_dialogue_checks,backpack_ui_checks,live_playtest_checks,npc_dialogue_rule_checks -RenderScript npc_dialogue_ui_checks -RenderPhases check -TimeoutSeconds 180
```

Evidence `docs/evidence/N005/20261008-092745965-d02fca8d/`: all8 cases PASS/exit0,
no diagnostics/timeouts/source changes,772 files. Fingerprint
`5be9fd51b19e0b4ea95ff38218878676ad6c26590fe138fd3b41fcb96a1558f7`.
Six `render/derived/20261008-092919-39f1c859/contact-*.png` sheets viewed, alongside
`portrait-review-1.png`, `portrait-review-2.png` (all48 actual UI portrait crops).
Full-size `npc-03-introduction.png`, `maris-counter-existing-flow.png`,
`deferred-gift-close.png`, `long-text-960.png`, `long-text-1440.png` viewed in render/.
Facts are readable, portrait framing undistorted, disabled reason legible, bold/fact
highlight matches source and fixed exits remain visible after long scrolling.

Final test-only extension closes mouse/keyboard unavailable-exit proof gaps:

```powershell
./tools/run_checks.ps1 -Task N005 -Names npc_dialogue_ui_checks -RenderScript npc_dialogue_ui_checks -RenderPhases check -TimeoutSeconds 180
```

Evidence `docs/evidence/N005/20261008-093803876-0c2316ed/`: all4 cases PASS/exit0,
no diagnostics/timeouts/source changes. Headless384/rendered452 assertions including
evidence write (JSON383/451), eight people,48 expressions,68 captures.772 files
stable with final fingerprint
`772c6550121c97b32ef69b438904f00275ea3581e8edef4278bc912ee75a76a0`.
Production bytes are identical to the8-case run; only the UI test changed.
Latest full-size gift capture and `render/derived/20261008-093941-cf4a46a7/contact-06.png`
also viewed. The shared capture helper verifies all68 dialogue modal snapshots,
focus/token/actor gating, panel fit, timing and input/renderer provenance before
building contact sheets. Its automatic status is only ready-for-visual-review;
separate `visual-review.json` records human-facing image inspection by this agent.

Bundled Python additional PASS commands (same cwd):

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/tests/capture_evidence_checks.py
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/N005/20261008-093803876-0c2316ed/render/npc-dialogue-ui.json
```

Capture helper tests cover accepted dialogue and rejected modal/focus/token/timing/
provenance mismatches without weakening existing pause/live guards. Final byte,
links, status, scope, source and owned-process audit: `final-audit.json` in latest run.

## Retained failures and limits

All earlier attempts remain under docs/evidence/N005, without overwriting reports:
090335454-e19dca00 sandbox launch denied;090409950-27cae754 overlapping root edit
triggered source guard;090549864-26128ba4 and091110542-21c2ee60 generated UIDs triggered
source guard;091132556-7cae0493 invalid focus-neighbor property/old fixture API;
091246030-3b18b7b7 strict whitespace rejection of a long-text fixture;
091940075-5541ebb3 leaked self-capturing fixture callback detected at shutdown.
These were repaired without bypassing strict validation or diagnostic/source guards.
090634000-aa311df2 import/parse smoke,091407291-28cca822 focused UI,
091436626-0b3be5a8 initial rendered UI and091647755-3e8fc985 formatted-text checks
were passing smaller runs superseded by the final runs. Initial rendered review
found raw source bold markers and technical gift text; the delivered modal fixes both.

Sandbox preflight required an approved isolated engine launch escalation. Auto-review
approved ordinary task validation; no outstanding approval or permission blocker.
All owned launcher/engine processes exited; no editor or cleanup owed. No remaining
N005 acceptance gap. No agents/chats/schedules, external messages, publication,
commit/push or successor work. Next eligible N006; N007 independently ready.
