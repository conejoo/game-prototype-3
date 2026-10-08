# G001 social reference contract acceptance

Status: Done, 2026-10-08 UTC. Exactly G001 completed. Every G001 criterion has
reviewed reference evidence and passing read-only checks below. No gift,
milestone or People runtime implementation belongs to this task.

## Authority and bounded outputs

Target HEAD `a0f5d7bba6be42885d7e528146d9742436ebf6c5`; the four pre-existing
planning documents in this workflow were untracked on entry. No tracked user
changes. No nested AGENTS.md found. Source HEAD
`60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean. All existing NPC authority
inputs match their immutable hashes. N018/F010/W010 handoffs, acceptance records
and actual conversation/inventory/clock/save owners were inspected; their native
proof remains historical, not a new G001 gameplay pass.

New [manifest](../../tools/social_migration/reference/manifest.json) pins 17
public implementation/test inputs by full original SHA256, byte length and
revision, with bounded LF excerpts retaining inclusive source line numbers.
The resolver and `npc_content.dart` excerpts additionally pin priority/tie order
and public threshold/label/milestone parsing. Existing NPC packages, portraits,
coverage, adaptation and contacts are reused; all 100 existing reference files
retain their hashes. No additional people or private profiles were imported.

[Activation policy](../../tools/social_migration/reference/social_activation.json)
schema1 / `social-60c20eb2-g001` describes a future G004 overlay on current generated
availability. Its recipient-qualified `enable` lists are exact. `recipients`
contains complete gift/intro/disclosure fields, incoming edges and every outgoing
transition; `preserve_deferred` retains original reasons and fields. G001 leaves
production availability unchanged. Converter consumption is a later G002/G004
output, not claimed here.

## Acceptance mapping

| Criterion | Inspected evidence and result |
| --- | --- |
| Exactly eight rules / ten choices / nine nodes and all transitions | Activation lists npc-01/02/03/04/06/07/08/14. Edric and Helena each have hint/follow-up choices; other six have one return gift choice. Each binds its one source rule. Eight authored response nodes and Edric milestone have no outgoing choice or continue edge: ordinary Close ends them. Incoming choices, entry index and milestone injection are recorded. |
| Fact/item/cap/condition gates and repeatability | Every rule accepts `moonflower`, requires its listed learned fact, adds 1 and has recipient/item cap 2. All ten choices have default affinityDelta 0, no flags/one-time receipt/extra condition/endsConversation; they remain repeatable. Conditions, rule, giftable metadata, inventory, fact, then cap are evaluated in source order. Hint nodes require real gather history plus completed introduction and unknown preference. Other six disclose preference on authored hobby entry. |
| Event keys/order and atomic publication | Gift source `itemGifted(moonflower,npc-ID)` then `dialogueChoiceSelected(npc-ID,choice-ID)`, same active time and consecutive sequence numbers. Choice effects precede gift delta, level check and transition entry. Detached inventory/relationship/journal are published before selector observers and quest callbacks. Shared caps do not reset by day or choice. |
| Threshold / milestone / entry / endsConversation | All eight threshold 3, label Acquaintance. Only Edric defines `npc-01-level-1-milestone` / `relationshipLevel1Seen`. Candidate requires level increase0→1 and absent flag. `endsConversation` takes precedence, so candidate alone does not mark entry. Ordinary entry also adds flag/seen/facts. Reopen/load/re-cross cannot replay flagged milestone. Positive intro 1 + two gifts reaches 3/level1; neutral 0 + two gifts reaches 2/level0. |
| Remaining deferred boundaries | Helena `npc-02-routine-archive-default` / `npc-02-routine-archive-indexing` and their five outcome choices remain routine-only; Della `npc-14-room` / `npc-14-ask-room` remain interior-only. Edric `npc-01-public-role` / `npc-01-river-fishing` have no disclosure node; Helena `npc-02-archive-practice` is disclosed only by deferred archive routine. No automatic role/art/People disclosure. After future activation: 67 enabled nodes, 48 choices, 21 facts. |
| People projection semantics | Seen node required, names sorted by authored displayName, only learned authored facts sorted category then label, pronouns/public portrait shown. Portrait official-neutral else first valid authored fallback. Level0 label null; level1 Acquaintance; progress affinity/3 without level2. Opening/selection only changes transient view selection. |
| Target versions / scarcity / state and modal owners | Historical bounded target baseline confirms schema7/content1, 58 enabled nodes / 38 choices / 21 facts / 0 gift rules,40 allowed event keys. Exactly two authored item types; 20 is slot capacity. Three finite flowers, stack 99; rod cap 1 and movable tool. GameSession owns inventory/conversations; companion trust independent. Entered nodes disclose facts, accepted choices derive affinity/flags/receipts, memories and event queries detach. Gift execution/milestone injection/People projection absent. GameRoot owns one dialogue, J journal, bag and manual save/load. Journal blocks controls/save/load while elapsed/environment simulation continues under existing unpaused/nontransition/nonload/nonretry policy. |
| Read-only checks and source-test inspection | Source fixtures listed below reviewed; no Dart/Flutter execution claim. Local checker validates hashes, exact coverage/overlay/vector derivation, bounded baseline, source order anchors and links. Optional G001 baseline comparison is explicitly historical. Converter independently proves unchanged current content/pin. Final commands/results below. |

## Source tests reviewed and limits

All six named test inputs are pinned in manifest with bounded excerpts:

- `dialogue_choice_eligibility_test.dart:10-67`: conjunctive flags/facts/seen,
  affinity bounds and event conditions. This file has one generic test, not
  exhaustive gift-rejection tests.
- `runtime_game_controller_test.dart:676-778`: injected two-flower inventory and
  learned preference; direct helpful response and two `giveGift` calls yield
  affinity1→2→3, one milestone flag, third rejection and selector edge changes.
  Direct repeated calls are not target stale-token/double-click proof.
- `runtime_game_state_test.dart:79-149,272-302`: threshold/derived level, signed
  clamp/decline/recover, mismatched-level rejection, immutable consume and last
  selected-item clearing.
- `player_event_journal_test.dart`: repeated-key aggregates, exact first/latest
  sequence/time, inclusive recency boundary, unknown timestamp exclusion.
- `presentation_snapshots_test.dart:1-125,163-241`: HUD displayed values and
  inventory snapshot equality/detachment. No People snapshot test occurs here.
- `people_journal_overlay_test.dart:18-125`: synthetic small/wide widget surfaces,
  HUD/J lock/focus/close, direct collection/dialogue calls, learned Edric preference
  while undisclosed facts stay hidden, Helena primary portrait. No ordinary Godot
  viewport or native-input claim.

[Behavior vectors](../../tools/social_migration/reference/behavior_vectors.json)
are reviewed expectations for downstream fixtures, not runtime test results.
They cover 16 positive/neutral recipient sequences, two shared-choice cap cases,
eligibility/event/transition order, selection and signed/milestone/People bounds.
Target command-token/revision/event exhaustion/reentrancy/save strictness is
separately labeled strengthening required by this migration. Source callback
tutorial/quest effects are inspected but excluded from target rewards; no event
bus or unrelated source tutorial is authorized.

Ordinary production proof belongs to G005/G008/G009. One fresh game can supply two
Edric gifts plus one other gift; all-eight cap coverage needs synthetic fixtures
or separate fresh runs. Source/giftable fish metadata grants no selected fish
rule. Rod remains excluded.

## Verification commands and evidence

Working directory: `D:/development/game-dev-blender/returning-fair-prototype`.
Installed bundled Python and Godot console/editor paths checked present. No engine
run is needed for this reference-only task.

Fresh evidence: `docs/evidence/G001/20261008-214756-0b0d757f/`.
All checker subprocesses use isolated APPDATA/LOCALAPPDATA under that directory;
no save operation, slot or normal save access. Results and byte preservation
oracle are stored there. No captures required/created or images inspected.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2 --check-g001-baseline
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/social_migration/social_reference_checks.py
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
git diff --check
```

Results PASS, exit0 with empty stderr: live-source/bounded-baseline audit and
target-local audit, each covering 17 source inputs, 8 rules, 10 choices, 9 nodes,
16 recipient sequences and retained3/6/3 boundaries. Four isolated malformed
fixtures reject: extra person, unauthorized deferred fact activation, wrong
affinity vector and corrupt excerpt. Hash fields in those fixture manifests were
deliberately updated, proving semantic rejection beyond the outer file hash.
Python syntax passes. Converter independently matches all 132 source inputs,
67 outputs, 48 portraits and 18 sheets; current catalog hash below.

All 720 game files retain exact before/after bytes; `git diff --exit-code HEAD --
game` passes. Raw Git blob comparison found 17 pre-existing checkout CRLF/LF
differences, each proven line-ending-only and unchanged during G001. That first
overstrict raw-HEAD comparison is retained in evidence; it does not imply a code
change. All 100 historical NPC reference hashes pass; source remains clean.
Final Markdown links/status/dependencies, new-file UTF-8/trailing-whitespace and
Git diff review pass. No required G001 criterion remains unrun or blocked.

Key evidence files: `checks.json`, `final-checks.json`,
`final-rejection-results.json`, `game-before.json`, `game-after.json`,
`preservation.json`, `preconditions.json`, `retained-attempts.json` and final
`handoff-review.json`. Earlier attempts/logs/negative fixtures remain intact.

Final SHA256:

| Artifact | SHA256 |
| --- | --- |
| Social manifest | `82e90e070cc4b459e0325b364366090f02f1a68b8c7fb311abe14b1a033673e0` |
| Activation policy | `05347622812a8795cd984e6594e2dc8ca425fa79622e5565b8a4679613e1276f` |
| Behavior vectors | `d7c310f250a5428373b3a38a88a1630778ed9508be44eab8cb03c3b121a2f0b2` |
| Historical bounded target baseline | `dabe281c42823d63c5d4a1a38014ffa59ad1c2448ae70d2d0bd9776d2101cc23` |
| Current NPC catalog | `9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9` |

Retained failure: initial excerpt capture requested line 244 in a 241-line snapshot
test. Corrected to 241, checked existing partial excerpt bytes identical, then
completed manifest. Read-only path/search misses are recorded with fallback.
No partial runtime publication or source change occurred.

Next eligible task: G002. G006 is also dependency-ready but G002
has lower ID. Final task remains G009. Stop after G001; no commit/push or successor.
Whole checklist incomplete: G002-G009 Pending. Blockers: none. No live owned
processes, held keys or cleanup owed; only bounded read-only Python/Git processes
ran. No gameplay checks, native packages, captures or normal saves were used.

Successful G001 commit authorized in the separate 2026-10-08 UTC follow-up.
This concise acceptance is committed; raw evidence retains the existing ignored
local policy. No push or successor work.
