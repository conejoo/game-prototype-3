# Gifts, friendship and People journal migration checklist

Prepared: 2026-10-08 (America/Vancouver).
Goal: use owned Moonflowers in authored NPC conversations, see independent friendship progress and Edric's once-only Acquaintance milestone, and consult a persistent, met-only People journal.
Target repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot application: game/, entry res://app/game_root.tscn.
[CONTRACT](CONTRACT.md) owns rules/source mappings; this checklist owns task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation; [AGENT_PROMPT](AGENT_PROMPT.md) is the reusable invocation.

## Selection and completion

G001-G002 Done; G003-G009 Pending. No active task.
Resume the single In progress task first. Reassess Blocked work when its blocker changes; unresolved blockers exclude that task and its dependents, not independent branches.
Otherwise select the lowest-numbered Pending task with verified Done prerequisites. Check actual prerequisite capability/evidence, not only checkboxes. Reconcile ambiguous status with artifacts before selecting.
Complete exactly one task per invocation. Mark In progress before implementation, verify its criteria, update state even when interrupted, and stop before its successor. Done requires every criterion to have evidence; do not replace ordinary play with synthetic fixtures.
P/M/W/F/N workflows are baseline references, not selectors for this workflow. Do not change their completed task histories.

## Tasks

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| G001 | Done | Current N018/F010/W010 capabilities and source inputs | Pinned social semantics, activation allowlist and behavioral vectors |
| G002 | Done | G001 | Pure gift eligibility and atomic item/social candidate rules |
| G003 | Pending | G002 | Strict save/event derivation for accepted gifts and milestones |
| G004 | Pending | G003 | Source gift branches and milestone transitions operate in one conversation service |
| G005 | Pending | G004 | Ordinary conversation gifting, progress and rejection feedback |
| G006 | Pending | G001 | Detached met-only People projection with no disclosure side effects |
| G007 | Pending | G006 | People journal integrated with existing J journal/HUD and modal lifecycle |
| G008 | Pending | G005, G007 | Integrated ordinary social loop, cross-system regression and restart proof |
| G009 | Pending | G008 | Fresh local Windows packages and native social/restart acceptance |

G006 is independent of gift implementation after G001: its source of truth is existing per-person memories. It may be selected when an earlier gift branch is blocked. Shared files still require sequential execution; these dependencies do not request agent spawning.

## G001 — Audit and pin the social reference contract

- Inputs: CONTRACT source/target references; N018/F010/W010 acceptance and actual current artifacts; existing immutable tools/npc_migration/reference manifest, packages, coverage and contact registry; source resolver/eligibility/People code and relevant source tests.
- Outputs: tools/social_migration/reference/ manifest, bounded source snapshots, social_activation.json and behavior_vectors.json; G001_ACCEPTANCE.md here; verified version/behavior decisions in CONTRACT.
- Scope: read-only audit of source and production; only this workflow's reference/docs/checker. Reuse existing NPC public pins without changing them. Record live source HEAD, local hashes and any differences, and refuse silent repins. No new people or private profiles.
- Acceptance: exactly eight selected NPCs; inspect all eight gift rules, ten gift choices, nine gift/milestone nodes and every outgoing transition; classify remaining deferred routine/room nodes, choices and undisclosed facts. Record source event keys/order, shared caps, repeatability, threshold/entry/endsConversation behavior, and ordinary vs synthetic test paths. Confirm current target schema, item IDs, finite three-flower supply, current introduced/fact/affinity behavior and modal/save owners.
- Verification: local reference/hash/link/coverage checks and source-test inspection; tools/social_migration/social_reference_checks.py checks this reference/bounded historical baseline, not immutable production after later tasks. No unrelated gameplay suite needed for reference-only work. Record reviewed evidence, not a fresh gameplay-pass claim.

## G002 — Implement gift rules and atomic candidate publication

- Inputs: G001 vectors/activation policy; InventoryState, ItemDefinition, ConversationMemory, NpcConversationState, NpcEventMemory and NpcDialogueRules.
- Outputs: proposed pure gift eligibility/transaction collaborator under game/features/npcs/; minimal detached inventory support and explicit item giftability metadata; source Moonflower -> item-moonflower mapping. Add proposed social_gift_checks.gd and social_transaction_checks.gd.
- Scope: reuse current per-person memory and inventory ownership; no second affinity store, gift-count authority, event bus or new autoload. Build tested detached candidates; keep ordinary production gifts unavailable until G004. Historical NPC reference hashes stay immutable. Specify a deterministic feature activation overlay consumed by conversion/check tooling rather than manually editing generated content.
- Acceptance: fact/item/cap/condition gates; one accepted gift consumes exactly one owned Moonflower, clears active selection only when its last item is consumed, applies choice and gift deltas/flags once for that command, and stages both source events. Same-NPC two entry choices share one item/NPC cap. Repeatable gift choices permit deliberate second gifts but stale/double-click tokens cannot repeat a command.
- Acceptance: missing/unknown/non-giftable item, missing fact, cap reached, foreign NPC/node/instance, changed inventory revision, event exhaustion, reentrancy or invalid target causes no partial inventory/memory/event publication. All eight recipients, sessions and existing companion trust remain independent. Reader callbacks never observe half a transaction.
- Verification: new pure/candidate suites plus existing inventory_checks, npc_dialogue_rule_checks and consequence_checks where affected. Test exact before/after snapshots and atomic rejection. Artificial full inventories/events are labeled synthetic.

## G003 — Persist gifts and validate relationship derivation

- Inputs: G002 candidates/events; current SaveCodec/NpcSaveData/NpcEventMemory, repository/backup semantics, NPC schema policy and G001 vectors.
- Outputs: strict social event/save support; proposed social_save_checks.gd and social_process_checks.gd with isolated write/read phases; recorded supported schema/content versions. Update changed existing fixtures deliberately.
- Scope: prefer existing itemGifted aggregates for caps, retain current envelope when possible, and extend derivation instead of duplicating gift counters. Follow CONTRACT version policy. No Flutter-save import, inferred gifts from missing flowers, autosave, normal-save access or old-format migration.
- Acceptance: saved gift count equals counts of the authored gift-choice events for the same source item/NPC; caps apply across both Edric/Helena choices. Affinity, level, flags, facts and receipts derive from allowed real choices/gifts/node disclosure and authored milestone entry. Reject mismatched totals, foreign/deferred keys, impossible chronology, forged affinity/milestone, over-cap gifts and invalid item data before live swap.
- Acceptance: repeatable gifts remain saveable without weakening mutually exclusive introductions/once-only receipts. Source milestone can replace a gift's authored response target; restoration understands that legal transition instead of requiring a skipped node. Preserve full-precision timers, strict numeric/container limits, unsupported-version rejection, backup protection and load/travel rollback.
- Verification: new save/process suites plus npc_save_checks, npc_process_checks, foraging_save_checks, save_checks and save_process_checks as affected. Exact current-format round trips and separate processes; corrupt/incompatible/failed-write fixtures preserve live state and files. No acceptance based on only an in-memory dictionary round trip.

## G004 — Integrate source gifts and once-only milestones

- Inputs: G003 durable rules; existing NpcDialogueService/Rules, catalog converter and G001 activation policy.
- Outputs: one conversation command path supporting gifts; deterministic current content activation; milestone selection/entry behavior and proposed social_milestone_checks.gd. Extend conversion/check tooling while retaining source pin verification.
- Scope: enable only eight gift rules, ten gift choices, eight response nodes and Edric's milestone node from the approved social allowlist. Retain remaining routine/room gates and undisclosed facts. No generic free gift button bypassing authored choice/fact gates.
- Acceptance: helpful Edric introduction (+1), two accepted gifts (+1 each) reach affinity3/Acquaintance; authored milestone displays once and records relationshipLevel1Seen on entry. Later dialogue/load/reopen cannot replay it. Neutral introduction plus two gifts yields affinity2/level0. No invented milestone scenes for the other seven.
- Acceptance: mirror source transition order: choice effects, gift delta, level check, endsConversation precedence, milestone-or-authored-next, entry facts/seen/flag; gift event then choice event, committed together. Ordinary non-gift responses also use correct source milestone logic. Close/cancel cannot grant a gift. Maris ordinary chat and existing counter/service routing retain the same real npc-03.
- Verification: G002/G003 suites, new milestone suite and existing npc_content_checks, npc_dialogue_rule_checks, npc_save_checks, quest_checks. Conversion/check must prove only approved availability changes; source text/IDs/portraits/placements remain unchanged. Synthetic all-eight level crossings are rule proof only.

## G005 — Make gifting usable through ordinary conversations

- Inputs: G004 service/current content; ConversationView, GameRoot, backpack/HUD and existing command generation/input arbitration.
- Outputs: authored gift choices with current availability/clear rejection reason; immediate item/friendship feedback and affinity-to-threshold display; proposed social_gift_ui_checks.gd and social_gift_ui_render.gd.
- Scope: UI displays snapshots and submits stable commands; it cannot consume items or choose gift rules. Root arbitrates cursor/input and refreshes backpack/HUD only after full publication. Update Moonflower description/help now that gifting is available; keep rod non-giftable.
- Acceptance: source preference disclosure unlocks correct choice, accepted gift visibly decrements bag and updates recipient only, cap/missing-item reasons are honest, and current feedback survives node change. Mouse/Tab/Enter, long choices, Continue/Close work at 960x640 and a larger measured viewport.
- Acceptance: stale/double-click/input repeat cannot double-consume; reopening after first gift permits second intentional command where source allows. Dialogue blocks movement/attack/dodge/hold/drag/aim/zoom/save/load; focus loss/unload releases controls. Existing Maris recovery/specialist routes, companion choices and backpack behavior remain usable.
- Verification: new UI suites/renders plus npc_dialogue_ui_checks, foraging_interaction_checks and backpack_ui_checks where affected. Inspect actual captures; at least one ordinary gathered-item gift through production interaction. Fixture inventory tests do not prove ordinary acquisition.

## G006 — Create the met-only People projection

- Inputs: G001 source PeopleSnapshot/overlay behavior; current catalog, ConversationMemory and facts.
- Outputs: proposed detached PeopleSnapshot/query under game/features/npcs/; proposed people_snapshot_checks.gd.
- Scope: read-only projection over current session memory. No new met/known-fact store, social mutation, gift activation, authored facts or UI yet. This task can use current schema7 baseline before G003.
- Acceptance: empty initially; only NPCs with actually entered dialogue nodes appear. Name sorting, primary portrait fallback, pronouns, derived affinity/level label and progress use authored data. Facts are only persisted learned IDs, sorted by category then label; no disclosure merely from actor proximity, role/title, journal opening or giftability.
- Acceptance: eight people remain independent, unknown IDs fail safely, detached caller changes cannot mutate memory/catalog, and a fresh projection reflects valid choice/gift/load changes without stale cached facts. No private profiles or deferred facts appear.
- Verification: new projection suite with met/unmet/partial facts/threshold/boundary/load cases. Use current NPC source fixtures and strict content rules; do not fabricate ordinary-play claims.

## G007 — Add People to the existing journal

- Inputs: G006 projection; PrototypeUI/GameRoot/J journal lifecycle, existing conversation portraits and modal/input rules.
- Outputs: People tab in current J journal, HUD People entry opening that tab, selected-person detail/list/empty state and proposed people_journal_checks.gd / people_journal_render.gd.
- Scope: preserve existing quest, upgrade and companion-trust journal content. Reuse J/Esc/Close/Tab/mouse; no conflict with P projection or B backpack. People selection is transient and never a relationship command.
- Acceptance: met-only list, learned category/fact details, portrait, Acquaintance progress and empty hint work at 960x640 and a larger actual viewport, with scroll/focus and exits always reachable. Opening/selecting/reopening grants no facts, affinity, gifts or milestone receipt.
- Acceptance: journal is a root-owned modal; blocks gameplay/save/load, cancels holds/drag and clears held controls. Dialogue/backpack/pause/travel/death/focus transitions cannot overlap panels or strand control; world simulation follows current journal policy. Current quest/upgrade buttons still work.
- Verification: new projection/UI checks and inspected renders plus existing movement_camera_checks, npc_dialogue_ui_checks, backpack_ui_checks and quest_checks where affected. No new character models or source art required.

## G008 — Prove the integrated social slice and restart

- Inputs: G005/G007 accepted capabilities; source reference vectors, current production root, shared test runner/journey/GUI/save helpers.
- Outputs: proposed social_integration_checks.gd / social_integration_render.gd; concise G008_ACCEPTANCE.md mapping required criteria to hashes, actual inputs, save oracle and inspected captures.
- Scope: only fixes needed for this slice and affected regressions. Keep geography, scarcity, eight contacts and existing recovery. Do not add resources/respawn, fish, shops, daily gifts or relationship level2.
- Acceptance: fresh ordinary input meets Edric, learns preference from real gathering, obtains two different existing flowers and gives twice; one milestone, bag/affinity/journal accurate. Remaining third flower can test another recipient (prefer Maris) without inventing more supply. Another fresh neutral Edric run yields affinity2/no milestone. All eight met/fact/People entries remain accessible.
- Acceptance: isolated fixture/separate-fresh-run coverage proves all-eight gift branches/fact gates/caps and other-seven level derivation; ordinary route claims stay separate. Revisit, travel, retry, modal/focus handling and full shortened Maris recovery preserve gifts, item conservation, party/trust/upgrades/environment and prior effects.
- Acceptance: GUI Save, normal quit, new-process GUI Load restores exact supported social/inventory/old state; opening People/reopening conversations cannot duplicate rewards or remove facts. Re-saving while paused has exact durable equality; separately identify legitimate time/area events after walking.
- Verification: affected existing NPC/foraging/save/quest/companion/environment/modal suites plus G suites, write/read process tests and rendered ordinary walkthrough. Shared runner errors/timeouts/source changes fail evidence even if engine exits0. Inspect all acceptance captures via contact sheets/full-size details; preserve failed attempts. No packaged/native acceptance claim yet.

## G009 — Deliver fresh Windows packages and native acceptance

- Inputs: G008 exact accepted production bytes; export_presets.cfg; current local standard4.7.2 templates and N018 delivery/native helper contracts.
- Outputs: new local validation/release packages and pack audit; proposed tools/social_migration/ delivery/native provenance helpers as needed; G009_ACCEPTANCE.md and current discovery/delivery docs.
- Scope: archive exact prior local packages before any canonical replacement, preserve override.cfg save isolation, and follow current package ownership checks. No deployment/publication, installer, commit/push, source rewrite or test bridge in release.
- Acceptance: pack contains current gift policy/content, existing NPC rigs/portraits, People UI, supported save format and prior game assets; excludes tests/bridges/reference snapshots/private profiles/Flutter/Blender sources. New release starts outside source checkout.
- Acceptance: ordinary guarded native controls complete fresh Edric positive/two-gift/milestone/People loop, a second-recipient gift where finite supply permits, and Maris recovery integration; GUI Save/quit/separate-process Load and physical revisit preserve exact state. Separate fresh neutral flow reaches affinity2, not Acquaintance. No item/fact/time/quest setup, teleport or debug bridge substitutes for release gameplay.
- Verification: appropriate pre-export G/existing checks; package hashes/resources/supported version, native input guard tests when helpers change, isolated APPDATA/LOCALAPPDATA, clean logs, inspected frames/pauses and read-only save oracle. All owned keys/processes/helpers cleaned. Unavailable native input/desktop access leaves this gate incomplete with exact next action, never inferred from debug evidence.

## Completion records

### G001 / 2026-10-08 UTC / Done

Every G001 criterion passed; [G001 acceptance](G001_ACCEPTANCE.md) maps the reviewed
source/baseline evidence, commands, hashes and retained attempts. Added only
tools/social_migration/ reference/checker/README/attributes and this workflow's
acceptance/state/contract/status updates. Preserved existing planning prompt,
all 720 game files and all 100 historical NPC reference files. No runtime activation.

Repository-root bundled Python commands:
`tools/social_migration/social_reference_checks.py --source D:/development/game-prototype-2 --check-g001-baseline`,
target-local `tools/social_migration/social_reference_checks.py`, and
`tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2`
all pass exit0/empty stderr. Four isolated malformed references reject correctly.
Git diff/byte preservation and documentation review pass. Exact executable, cwd
and isolated APPDATA/LOCALAPPDATA recorded in acceptance/raw evidence.

Evidence: docs/evidence/G001/20261008-214756-0b0d757f/. No captures or visual/gameplay
claim; source tests inspected, not freshly executed. Source clean at60c20eb2;
schema7/content1 stays current. Policy schema1/social-60c20eb2-g001 pins 8 rules,
10 choices, 9 nodes and preserves 3 nodes/6 choices/3 undisclosed facts. Full hashes
in acceptance. 17 raw-HEAD differences are verified pre-existing CRLF/LF only;
all working game bytes remain identical before/after.

Next eligible: G002; implement tested pure gift eligibility/atomic candidates,
explicit item giftability and deterministic activation-overlay tooling while
ordinary gifts remain unavailable until G004. G006 is also ready after G001 but
has higher ID. Stop after this one task. No commit/push; no blocker or live process.
Remaining: G002-G009. Final task: G009. Whole checklist incomplete.

G001 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
this workflow and its social reference tooling; keep raw ignored evidence local.
No push or G002 implementation.

### G002 / 2026-10-08 UTC / Done

Every G002 criterion passed; [G002 acceptance](G002_ACCEPTANCE.md) maps detached
rules/publication, all-eight recipients/shared caps, rejection boundaries and
the deterministic overlay to actual evidence. Inventory has detached copy/query
support; Moonflowers explicitly giftable, rod explicitly excluded. One existing
conversation owner stages and publishes inventory/person/events before observers,
guards tokens with bag revision/owner identity and rejects notification reentry.
Production catalog and strict activation gates remain unchanged; no ordinary
gift, milestone routing, save support or People/UI acceptance claimed.

Final runner: docs/evidence/G002/20261008-220842855-d4b8a199/results.json.
All seven selected suites plus engine/parse gates pass with empty diagnostics,
no timeout or source change. New suites: 335 pure and 238 transaction assertions.
Existing inventory199, NPC rules977, content423/75 malformed candidates,
foraging587 and consequence checks pass. Source/pin/converter/overlay/diff/link
audit passes; raw evidence and failed launch/import attempts retained.

Next eligible G003: strict gift/save derivation and separate-process verification.
G006 independently ready but higher ID. Remaining G003,G004,G005,G006,G007,G008,G009.
Every item through G009: not complete. No blockers, live processes, commit or push.
Stop after exactly this task.

G002 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G002 runtime, fixtures, tooling, acceptance and workflow state. Keep ignored raw
evidence local; no push or G003 implementation.
