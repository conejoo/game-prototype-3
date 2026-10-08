# Gifts, friendship and People journal migration contract

Prepared: 2026-10-08 (America/Vancouver).
Target repository: D:/development/game-dev-blender/returning-fair-prototype.
Application: game/, res://app/game_root.tscn.
Reference source (read-only): D:/development/game-prototype-2.
[CHECKLIST](CHECKLIST.md) owns G task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.

## Outcome and scope

Extend the already delivered eight-villager conversation system with authored Moonflower gifting, per-person Acquaintance progress, Edric's once-only milestone and a met-only People journal. Existing affinity, learned facts, seen nodes, portraits and remembered introductions are implemented baseline, not work to recreate.

Roster remains npc-01 Edric, npc-02 Helena, npc-03 Maris, npc-04 Harlan, npc-06 Tess, npc-07 Ivo, npc-08 Celia and npc-14 Della. The source catalog has fifteen packages; do not import the other seven automatically.

Included: activation of existing authored gift choices/response nodes; item giftability; atomic inventory/social command; capped gift events; milestone routing/entry flag; strict save derivation; relationship feedback and People list/details; isolated ordinary/packaged Windows verification.
Excluded: new residents/facts/dialogue rewards, level2, romance or household changes, daily/resetting caps, resource respawn, shops, fishing gameplay/fish gifts, routines/interiors, full campaign, autosave/startup resume, Flutter save import, player/character remodel, mobile/web release and bespoke authoring tools.

The old source phrase "fish are giftable" is item metadata, not a recipient rule. Every selected public NPC currently accepts Moonflowers only. Do not invent fish acceptance or gift rod/tool inventory.

## Baseline and authority

Planning target HEAD: a0f5d7bba6be42885d7e528146d9742436ebf6c5, worktree clean before this documentation.
Live source HEAD: 60c20eb2816e7271fb84afaba286af006ebe3ccf, read-only worktree clean.
Existing NPC pin: villagers-60c20eb2-n001 under [NPC reference](../../tools/npc_migration/reference/manifest.json).
These are inspected identities, not instructions to reset either checkout.

N001-N018, F001-F010 and W001-W010 are recorded Done in their latest handoffs; N018 reports fresh native Windows all-eight/recovery/restart acceptance. Older paragraphs in parent/workflow documents can describe older stages. Current code plus current top handoff governs; source presence is not new playtest evidence.

Current target facts:
- SaveCodec schema7/content1; strict current-format-only policy in [architecture](../ARCHITECTURE.md).
- GameSession.conversations owns eight independent ConversationMemory records and bounded event aggregates; companion RelationshipState/trust is separate.
- Eight ordinary public contacts; 58 enabled nodes, 38 enabled choices, 21 disclosable facts; full imported pin retains 70 nodes/54 choices/24 facts and deferred gifts/routines.
- Inventory has two authored item types and capacity for 20 occupied item-type slots, item-moonflower cap99, item-fishing-rod cap1, pure add/consume/select rules and stable revisions. Source IDs map to target item IDs; source moonflower is not itself target item-moonflower.
- Three finite Moonflower nodes plus one rod in ForagingRegistry; collected nodes never respawn. Safe approved feet and saved rod placements are already implemented.
- Source gift rules/milestone metadata are already typed in NpcDefinition but unavailable. NpcDialogueRules unconditionally rejects gifts; NpcDialogueService skips milestone injection; current NpcSaveData derives only original enabled choice deltas.
- Known-facts conversation panel exists; a full People journal does not. Manual Save/Load and arrival-anchor restore remain current behavior.

Authority order: direct user scope/applicable AGENTS; current target architecture and completed feature contracts; pinned selected public source packages and source rule behavior; source public canon/disclosure boundaries. Geography and actor/contact/quest identities remain target-owned. Do not infer disclosure from private profiles or sprite art.

## Source reading and pin policy

Reuse immutable public runtime/dialogue/visual data and portraits already pinned under tools/npc_migration/reference/assets/data/npcs/<selected-ID>/ and the existing manifest/coverage/adaptations/contact_registry. Runtime current content is game/content/npcs/catalog.json.
G001 adds only missing social implementation/test references in its own proposed tools/social_migration/reference/ set:
- source lib/game/dialogue/dialogue_choice_eligibility.dart and dialogue_model.dart;
- lib/game/state/runtime_game_controller.dart, runtime_game_state.dart, player_event_journal.dart and people_snapshot.dart;
- lib/ui/people_journal_overlay.dart and dialogue_overlay.dart;
- assets/data/gameplay/catalog.json;
- relevant test/game/dialogue/dialogue_choice_eligibility_test.dart, test/game/state/runtime_game_controller_test.dart, runtime_game_state_test.dart, presentation_snapshots_test.dart, player_event_journal_test.dart and test/ui/people_journal_overlay_test.dart.

Pin only necessary public semantics with source path/revision/hash and bounded readable vectors. Existing historical pin/coverage stays immutable. A new deterministic social activation overlay changes current generated availability, not source snapshots/text/portrait hashes. Update converter/check expectations deliberately for current feature; never weaken reference hash checks or relabel old N acceptance as social acceptance. Runtime/export must not depend on source checkout, tools/reference, Dart, private data or test fixtures.

Current inspected activation scope: eight gift rules, ten gift choices, eight gift-response/end nodes and Edric's one milestone node. G001 proves exact IDs and their transitions. The three other deferred nodes, six other deferred choices and three undisclosed source facts remain deferred. Expected totals after this bounded activation are 67 enabled nodes/48 choices/21 disclosable facts, subject to G001 exact audit rather than blind count matching.

## Source gift and friendship rules

Each selected NPC has one rule <npc-ID>-moonflower-gift, item moonflower, affinityDelta+1 and acceptanceCap2. Required learned facts:

| NPC | Required fact |
| --- | --- |
| npc-01 | npc-01-moonflower-preference |
| npc-02 | npc-02-moonflower-pressing |
| npc-03 | npc-03-decorative-knots |
| npc-04 | npc-04-shore-birds |
| npc-06 | npc-06-pressed-flowers |
| npc-07 | npc-07-knotwork |
| npc-08 | npc-08-woodcarving |
| npc-14 | npc-14-quilting |

Choice conditions, required fact, giftable item definition, actual owned quantity and recipient cap all apply at commit time. Source cap counts itemGifted with subjectId=moonflower and targetId=npc-ID; it is not per choice or per day. Edric and Helena each have hint/follow-up gift choices sharing that cap. The other six each have one return gift choice.

Gift choices are repeatable until cap; do not mark them once-only merely to stop duplicate UI commands. Use command generation/cursor/owner checks for stale requests. Successful source order is choice effects, gift-rule affinity delta, level crossing selection, authored endsConversation precedence, then milestone or authored response entry. Record itemGifted first, dialogueChoiceSelected second, at the same valid active time. Both belong to one accepted transaction. Honor generic source signed/clamped deltas; the current selected pin has nonnegative deltas and +1 gift rules. Do not infer ordered negative-delta histories from aggregate-only saves if a later pin changes that assumption.

All eight define levelOneAffinity3 and levelOneLabel Acquaintance. Only Edric defines levelOneMilestone: node npc-01-level-1-milestone, seen flag relationshipLevel1Seen. Crossing level0 to1 can select that authored node if unseen; entering it marks its source flag, even through normal entry resolution. After the milestone flag is recorded it cannot replay on revisit/reload or decline/re-cross. The other seven may reach level1 but receive no invented milestone scene/reward.

First positive introduction gives+1; neutral gives0. Positive plus two gifts reaches3; neutral plus two reaches2. Existing introduction flags/once-only receipts must remain mutually exclusive. Source affinity affects social progression only: no new gates for Maris recovery, specialist service, travel or supplies; no grant of companion trust, training points or coins from friendship.

## Atomic state and ownership

Extend current services; no parallel conversation engine/affinity dictionary.
GameSession owns inventory/conversations and old durable state. A pure gift collaborator stages detached inventory, memory and bounded event candidates. NpcDialogueService/root routing validates active NPC/instance/node/generation and current inventory revision, then publishes every affected value before any observer runs. The single command guard covers reentrancy and stale replay.

Validate target node/milestone/event capacity before consumption. Failed/canceled/stale/hidden/foreign/unsupported/capped commands publish nothing. Clear active item only if its last owned unit is consumed; preserve unrelated bag, placements, collected nodes, other people and old state. Foraging's binding/revision and UI listeners must follow the published inventory without stale references. Current inventory is signal-free; root refreshes displays after transaction. Current save policy remains manual: session-atomic acceptance does not add an automatic disk save.

UI receives current snapshots and submits IDs/token; it never chooses rewards, consumes items or updates facts. Keep physical selector/range/LOS, root modal/lifecycle arbitration, existing Maris counter routing and one actor per source NPC. Prototype companion remains unnamed and separate.

## Event and save policy

Prefer existing bounded aggregates, including itemGifted and enabled gift-choice keys, as cap/derivation authority. Do not serialize transient cursor, selected People row, modal state, actor/path positions or separate duplicated gift totals.
Restore must cross-check gift count against sum of matching authored gift-choice counts, cap, expected positive gift deltas, source node-entry facts, introduction flags/receipts, milestone seen flag and derived level. Two choices sharing a rule cannot evade cap. Legal milestone replacement need not visit the skipped authored gift target; correct current source routing must restore. Reject foreign/deferred/duplicate keys, impossible sequence/time/count structure, partial gift/choice evidence, forged memory or unsupported delta-order assumptions before swapping live state.

Current policy supports only the declared current schema/content pair. Default: keep schema7/content1 if the exact plain-data envelope is unchanged and new allowed event keys can be strictly validated. G003 records its actual final format decision; if a format change is necessary, deliberately declare the next format, update fixtures/docs and reject other formats without rewriting/deleting them. There is no authorized old-format migration, missing-field default, legacy ID mapping or inference of prior gifts.
Preserve128KiB bound, strict numeric/container checks, full-precision elapsed/environment timers, atomic save/temp-write/backup behavior, incompatible-file preservation and load rollback. Existing schema7 zero-gift saves must either validate under an unchanged envelope or remain explicitly incompatible under a deliberate new format; no fabricated gift history.

## People presentation and input

Source People view is met-only: at least one seen dialogue node. Sort people by authored display name; sort learned facts by category then label. Display public name/pronouns, official-neutral portrait or valid source fallback, derived level label, affinity/threshold progress and only learned fact descriptions. Do not reveal facts by proximity, occupation labels, journal access or gift metadata. No additional persisted met/fact store.

Add People tab to existing J journal and HUD People entry that opens it. Preserve current quest/trust/upgrade content; no new shortcut competing with P camera or B bag. Detail selection/tab UI is transient. Empty view says to meet someone. Opening People must not trigger milestone entry or any social mutation. Show threshold progress clearly without claiming level2 after affinity3.

Reuse existing journal simulation policy and root input ownership. J/Esc/Close return control, Tab/Shift-Tab/Enter/mouse reach visible controls; long list/details scroll. Block world movement/attack/dodge/forage/drag/aim/zoom and Save/Load during journal, clear held input, and avoid overlap with dialogue/backpack/pause/death/travel/focus loss. Inspect960x640 and a larger actually observed viewport, including night/weather portrait readability.

## Verification and delivery

Each G task includes its own correctness and affected regressions; final integration is not an excuse to defer basic verification.
Existing baseline checks include npc_content_checks, npc_dialogue_rule_checks, npc_save_checks, npc_process_checks, npc_dialogue_ui_checks, npc_world_checks, npc_integration_checks, inventory_checks, foraging_transaction_checks, foraging_save_checks, foraging_process_checks, backpack_ui_checks, quest_checks, consequence_checks, companion_checks, environment_save_checks, movement_camera_checks, save_checks, save_process_checks and application_smoke. Select only affected checks; extend their obsolete no-gifts assumptions deliberately and preserve unaffected assertions. Proposed G checks/tools are named in CHECKLIST and do not yet exist.

Read [playtest tools](../../tools/PLAYTEST.md) and [project gameplay skill](../../tools/skills/returning-fair-gameplay-testing/SKILL.md) before live runs. Shared bounded runner/journey/GUI oracle/evidence/native recipes remain owners. Fresh isolated APPDATA/LOCALAPPDATA and slots only; normal user saves must never be opened. Raw logs/captures/saves/packages stay ignored under docs/evidence/Gxxx and builds; track reusable fixtures and concise Gxxx_ACCEPTANCE.md here.

Three flowers are finite. Ordinary positive Edric two-gift milestone plus one second-recipient gift is possible; all-eight/two-gifts-each in one fresh game is not. Use labeled rule fixtures or independent ordinary fresh sessions for complete recipient coverage. Never add nodes/respawn or inject inventory and call it ordinary play. Separate fresh neutral proof must remain affinity2. Group all other old-field equality correctly; legitimate time/woods events can change during physical revisits, not while confirmed paused.

G009 proves newly exported local Windows release via native input outside checkout with explicit executable/PCK/override ownership and preserved old-package archive. Debug root/bridge, fixture state, exports alone and historical N018 proof do not pass this gate. No publication/deployment, external messages, automatic agents/chats/schedules, installation, commit/push or unrelated cleanup is authorized by this plan.

## G001 verified reference decisions (2026-10-08 UTC)

[Acceptance](G001_ACCEPTANCE.md), [social manifest](../../tools/social_migration/reference/manifest.json),
[activation policy](../../tools/social_migration/reference/social_activation.json) and
[behavior vectors](../../tools/social_migration/reference/behavior_vectors.json) are
now the bounded social audit. Policy schema1 / `social-60c20eb2-g001` references
the unchanged `villagers-60c20eb2-n001` pin and source revision above. Its exact
recipient-qualified enable lists are future G004 activation inputs; G001 changes
no runtime availability. The converter overlay consumer remains G002/G004 work.

All ten gift choices have default delta0, no flags/one-time effects/extra conditions
and an authored response target; the eight gift rules each add1 with cap2. All
nine activated nodes are terminal with no outgoing choice/continue edge. Edric's
milestone is an entry candidate with priority300 and minimum level1/excluded seen
flag. The source resolver uses highest priority then lexicographically smallest
node ID; node entry, not candidate selection, records the milestone flag.

Remaining deferred nodes are Helena's two archive routine nodes and Della's room
node. Their five archive outcome choices and one room choice stay deferred.
Remaining undisclosed facts are Edric's public-role/river-fishing facts and
Helena's archive-practice fact. Exact IDs/fields/reasons are in preserve_deferred.
People displayName/title text is public presentation and never grants role facts.

Source gift publication also updates its tutorial selector and invokes quest
callbacks after publishing state. Those source tutorial/quest rewards are outside
this target feature; retain only the approved item/social changes and source event
order. Stale command/revision/reentrancy/exhaustion and strict-save assertions are
target requirements, not proof supplied by source direct-controller tests.

Current journal is modal for controls and manual save/load, while elapsed time and
environment simulation continue whenever the tree is unpaused and no transition,
load or retry is active. G007 must preserve that current policy.

The read-only social checker validates the immutable reference and historical
bounded baseline by default. Its optional `--check-g001-baseline` compares 18
current owner/content hashes only for G001; never freeze later authorized game
changes with that option. Source excerpts are LF UTF-8 with original inclusive
line numbers, full original-file byte lengths/hashes and revision. Seventeen public
inputs include the additional bounded resolver and relationship-metadata excerpts.
No private profiles, additional NPCs or runtime reference dependencies exist.

## G002 delivered rules and activation interface (2026-10-08 UTC)

NpcGiftRules is a pure collaborator under game/features/npcs/. `stage(npc,
node_id, choice_id, state, inventory, expected_revision, seconds)` returns a
detached Candidate with reason/inventory/conversations/next_node_id; a rejected
candidate has no publishable inventory or conversations. `eligibility` is the
shared availability query. Source item mapping remains exactly moonflower to
item-moonflower. ItemDefinition.giftable is explicit (flower true, rod false).
InventoryState.detached_copy retains monotonic revision and detached counts/
selection; item_definition returns detached metadata. No runtime reference/tool
dependency or extra persistent authority was added.

Existing NpcDialogueService keeps command API and owns sole publication. Its
token contains inventory revision; bag identity and conversation identity guards
also reject stale owners. Gift acceptance swaps signal-free inventory and
conversations, updates cursor, then emits one guarded changed notification.
Reentrant commands/owner replacement/events during that notification reject.
Foraging reads the session's current bag through its existing weak owner.

NpcEventMemory admits gift keys only for enabled authored rules and choice keys
only for enabled choices: current production retains40 keys; synthetic full social
coverage has58. Shared caps use itemGifted(source item,NPC), never receipt counts.
Staging checks prospective unseen milestone availability on a level crossing;
selection, source entry flag and legal save transition remain G004/G003 work.
Current schema7/content1, strict content gates and generated catalog unchanged.

Converter `expected_outputs(source=None, social=False)` and CLI `--social` consume
the exact immutable G001 policy through tools/social_migration/activation_overlay.py.
Only approved availability status/reason fields change; reference coverage/text/
adaptations/assets stay exact. Default conversion remains pre-activation through
G003. `overlay_checks.py --source <source> --evidence <fresh G002 child>` verifies
determinism/exact27 changes/67 nodes48 choices21 facts8 rules without writing game
content. G004 must deliberately activate output and update catalog/check gates;
do not activate it merely because the converter interface exists.
