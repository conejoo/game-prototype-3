# G004 source gift and milestone integration acceptance

Completed 2026-10-08 UTC. Exactly G004; [checklist](CHECKLIST.md),
[contract](CONTRACT.md), [continuation](CURRENT_STATE.md).
Entry HEAD `84a4dfb7ca01b1d009099c98a27e95682ff6ed40`, clean worktree,
no nested instructions or unrelated user changes. Read-only source remains clean
at `60c20eb2816e7271fb84afaba286af006ebe3ccf`.

## Delivered behavior

The production catalog enables exactly eight gift rules, ten gift choices,
eight response nodes and Edric's milestone. Current availability is 67 nodes,
48 choices and 21 disclosable facts. Three room/routine nodes, six choices and
three undisclosed facts retain their original deferred records. Authored IDs,
text, source transitions, portraits, visual assets and contacts are unchanged.
Schema7/content1 and the existing envelope remain current.

NpcDialogueRules.transition applies source endsConversation precedence, then an
unseen level crossing milestone, then the authored target. Gift staging applies
choice effects and signed/clamped gift delta before querying that transition;
ordinary responses share it. NpcDialogueRules.enter records source facts, seen
node and milestone flag on actual entry. Begin, Continue and accepted responses
use the same entry helper. The single existing service retains atomic bag/person/
event publication and stable cursor/revision commands.

The converter defaults to approved social output, retaining an explicit --social
alias and read-only --baseline --check policy. Complete pin/hash/semantic guards
still run. Overlay tooling proves exactly27 availability changes and unchanged66
assets, text/adaptations and deferred records. No runtime dependency on reference
files/source/tools, new social store, event bus, reward or gift button.

SocialSaveFixture now uses production content and real service routing; milestone
history injection was removed. Original zero-gift NPC save fixtures explicitly
skip gifts rather than consuming their synthetic gathered supply on revisits.
Existing UI rejection fixtures now expect the honest missing-item reason.
Items/events and boundary authoring variants in tests remain synthetic. Ordinary
gathering/gifting UI, progress feedback, People and native social delivery remain
G005-G009. Headless UI fixtures generated no captures; no images were inspected
or claimed, and no ordinary-play/native/export acceptance is asserted here.

## Criteria and evidence

| Required criterion | Passing evidence |
| --- | --- |
| Helpful Edric + two gifts reaches affinity3/Acquaintance; milestone once and entry flag | social_milestone_checks uses real production introductions, preference disclosure and authored hint/follow-up commands. Before-observer snapshots verify each one-unit consume/delta/target and relationshipLevel1Seen on actual second-gift milestone entry. Reopen and default production restore cannot replay it. |
| Neutral Edric + two gifts stays affinity2/level0; other seven have no invented scenes | Both introduction paths for all eight recipients are tested independently. The new suite covers all ten gift choices and all nine activated nodes, derived thresholds, absence of foreign milestone flags, shared caps, other-person and old-system equality. These are synthetic rule fixtures, not finite-supply ordinary play. |
| Source transition/effect/event order and atomic publication | Shared transition helpers cover gifts and ordinary responses. New suite checks gift sequence immediately before choice at identical time, complete bag/person/entry flag/cursor before observers, stale rejection, source ends precedence, later normal milestone entry, Continue entry and seen-flag suppression after synthetic decline/re-cross. G002 suites retain signed deltas, fact/item/cap gates, exhaustion, invalid targets, foreign ownership, reentrancy and exact atomic rejection. |
| Ordinary non-gift responses use correct milestone rules | Synthetic below-threshold ordinary introduction crosses to milestone without gift events/item consumption; invalid milestone rejects the entire response/cursor; endsConversation closes before entry. Original NPC suite exercises all58 prior nodes/38 prior choices and existing receipt, priority, event, cancellation and owner rules. |
| Close/cancel cannot grant gifts; deliberate second gifts remain possible | New suite compares complete durable state after unselected Close/cancel; intentional second commands work, stale tokens cannot repeat, and third gifts reject with shared cap reason. Transaction suite preserves command guard and complete publication. |
| Maris chat/counter/service identity and old systems remain intact | npc_03_checks exercises production npc-03-counter, Chat/Recovery switching, stale/foreign/unfocused/distant route rejection, one wrapper, physical counter/bench, travel and retry. quest_checks and modal UI fixtures preserve recovery/source gates and controls. Old-system equality holds through all-eight gift fixtures. |
| Conversion activates only approved content without repin/art/placement changes | Final reference/converter/overlay audits validate source HEAD/status/hashes, all immutable NPC/social pins, exact27 changes,67 nodes48 choices21 facts8 rules, unchanged66 assets and four malformed policy rejections. Loader checks432 assertions/78 malformed candidates, including disabled approved rules/choices/response/milestone rejection and retained deferred routines/rooms/facts. Historical baseline write request rejects before mutation. |
| Save/reopen durability under actual production routing | social_save_checks844 assertions/560 malformed cases; npc_save_checks568 assertions/510 cases. Real default-catalog restore and disk fixtures retain corrupt/incompatible/failed-write/rollback protection. Social writer3/reader29 and NPC writer2/reader9 run in separate processes with exact whole-state oracles, paused re-save, inert reopen, backups and actual root restoration. |

## Commands, isolation and source bytes

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Shell: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`.
Installed console path checked before launch:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`,
version `4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
./tools/run_checks.ps1 -Task G004 -Names social_milestone_checks,social_gift_checks,social_transaction_checks,social_save_checks,npc_content_checks,npc_dialogue_rule_checks,npc_save_checks,quest_checks,npc_dialogue_ui_checks,npc_03_checks -ProcessScripts social_process_checks,npc_process_checks -TimeoutSeconds 150
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/overlay_checks.py --source D:/development/game-prototype-2 --evidence docs/evidence/G004/20261008-224415-reference-final/overlay
git diff --check
```

Final runner: `docs/evidence/G004/20261008-224309617-f3c86bbd/results.json`.
All16 cases pass: engine/parse, ten suites and two separate-process pairs.
There are zero diagnostics (including allowed diagnostics), timeouts, source
changes or source/run errors. New milestone657, gift335, transaction238,
social-save844, content432, original rules929, NPC-save568, modal384 and
Maris729 assertions pass; quest checks also pass. Original public coverage58/38
and added social coverage9/10 together exercise current67/48.

Stable930-file game/tools digest before/after:
`bc39309a5f9a1dd3020f9b56219e997e5c81dc3612812c4befa6c371114bbb4b`.
The runner records exact commands, manifests, PIDs and per-check APPDATA,
LOCALAPPDATA and slots under `builds/testing/G004/<run>/`. Writer/reader pairs
share only their own isolated group. Normal saves were never accessed.

Final read-only tooling evidence: `docs/evidence/G004/20261008-224415-reference-final/`.
Reference/converter/overlay exit0; expected historical-write rejection exits1.
Current catalog SHA256:
`efb76e8a42796a92fab80fa5815885adc7abdfd565ee7cfe036a7d165409e1d3`.
Historical baseline SHA256 remains
`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Overlay report preserves its historical production_sha256 field for the baseline;
preview_sha256 is current production, and its proof explicitly checks G004.
Final intended diff, links, status/dependencies, UTF-8, source identity and checks
are recorded under `docs/evidence/G004/final-review/`.

## Retained attempts and cleanup

223850 sandbox engine launch Access denied was escalated and approved for the
same isolated runner.223902 import generated the new script UID; source guard
correctly rejected that run. The existing editor-only missing .NET SDK warning
used the runner's import allowance; no install/C# build was needed.
223930 run exposed four fixture assumptions: other-six response suffixes were
gift-end, old coverage included new gift nodes, prior zero-gift save fixture could
auto-select an available gift, and UI expected the obsolete global unavailability
notice. These were repaired before the final run; all failed attempts are retained.
Final diff review also caught CRLF on inserted lines in the existing mixed-ending
README/architecture files. Only inserted spans were corrected to LF; original
bytes were preserved. The last whitespace diagnostic is retained in final-review.

No required criterion remains failed/unrun. All owned runner/engine processes
exited; no held input or cleanup owed. No read-only source-checkout mutation, export/publication,
external message, commit/push or successor. G004 Done; next eligible G005,
G006 independently ready. Remaining G005,G006,G007,G008,G009.
Every item through G009 is not complete. Stop after exactly G004.
