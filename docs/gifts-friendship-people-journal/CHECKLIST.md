# Gifts, friendship and People journal migration checklist

Prepared: 2026-10-08 (America/Vancouver).
Goal: use owned Moonflowers in authored NPC conversations, see independent friendship progress and Edric's once-only Acquaintance milestone, and consult a persistent, met-only People journal.
Target repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot application: game/, entry res://app/game_root.tscn.
[CONTRACT](CONTRACT.md) owns rules/source mappings; this checklist owns task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation; [AGENT_PROMPT](AGENT_PROMPT.md) is the reusable invocation.

## Selection and completion

G001-G007 Done; G008-G009 Pending. No active task.
Resume the single In progress task first. Reassess Blocked work when its blocker changes; unresolved blockers exclude that task and its dependents, not independent branches.
Otherwise select the lowest-numbered Pending task with verified Done prerequisites. Check actual prerequisite capability/evidence, not only checkboxes. Reconcile ambiguous status with artifacts before selecting.
Complete exactly one task per invocation. Mark In progress before implementation, verify its criteria, update state even when interrupted, and stop before its successor. Done requires every criterion to have evidence; do not replace ordinary play with synthetic fixtures.
P/M/W/F/N workflows are baseline references, not selectors for this workflow. Do not change their completed task histories.

## Tasks

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| G001 | Done | Current N018/F010/W010 capabilities and source inputs | Pinned social semantics, activation allowlist and behavioral vectors |
| G002 | Done | G001 | Pure gift eligibility and atomic item/social candidate rules |
| G003 | Done | G002 | Strict save/event derivation for accepted gifts and milestones |
| G004 | Done | G003 | Source gift branches and milestone transitions operate in one conversation service |
| G005 | Done | G004 | Ordinary conversation gifting, progress and rejection feedback |
| G006 | Done | G001 | Detached met-only People projection with no disclosure side effects |
| G007 | Done | G006 | People journal integrated with existing J journal/HUD and modal lifecycle |
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

### G003 / 2026-10-08 UTC / Done

Every G003 criterion passed; [G003 acceptance](G003_ACCEPTANCE.md) maps strict
shared gift/choice counts, paired chronology, legal disclosure/milestone derivation,
item metadata, unchanged schema7/content1 and actual disk/root restart evidence.
Production social catalog/gates remain deferred; G004 owns activation/routing.
No duplicated counter, new envelope, migration, autosave or ordinary-play claim.

Full runner docs/evidence/G003/20261008-222737370-3b4c2f29/results.json passes
six suites plus social/NPC/general write/read pairs (14 cases including engine/parse).
Final test-only boundary follow-up docs/evidence/G003/20261008-223022667-288e284a/
results.json passes social842 assertions/560 malformed cases and separate-process
write2/read28 assertions. No diagnostics/timeouts/source changes; source/pin/converter,
intended diff/links/state audit pass. Failed/import/fixture attempts retained.

Next eligible G004; G006 independently ready but higher ID. Remaining
G004,G005,G006,G007,G008,G009. Every item through G009: not complete.
No blockers, live processes, commit or push. Stop after exactly G003.

G003 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G003 runtime, fixtures, acceptance and workflow state. Keep ignored raw evidence
local; no push or G004 implementation.

### G004 / 2026-10-08 UTC / Done

Every G004 criterion passed; [G004 acceptance](G004_ACCEPTANCE.md) maps approved
production activation, source transition/entry rules, all-eight positive/neutral
progression, once-only Edric milestone, shared caps, cancellation, ordinary response
crossing, Maris routing and exact production save/restart evidence.
Only27 approved availability records change;66 assets/source text/IDs/placements
and immutable pins remain unchanged. Current67 nodes/48 choices/21 facts and
schema7/content1. UI feedback/ordinary acquisition/People/native gates remain later.

Final runner docs/evidence/G004/20261008-224309617-f3c86bbd/results.json passes
all16 cases, including ten suites/social and NPC restart pairs. Zero diagnostics,
timeouts or source changes. Milestone657 assertions; gift335/transaction238,
social-save844, content432/78 malformed, original NPC rules929 covering58/38,
NPC-save568, modal384 and Maris729; quest checks pass.
Reference/source/converter/overlay and intended diff/link/state audits pass;
failed engine/import/obsolete-fixture attempts retained. Synthetic items/events/
authoring fixtures are rule proof only; no rendered/native/ordinary-play claim.

Next eligible G005; G006 independently ready but higher ID. Remaining
G005,G006,G007,G008,G009. Every item through G009: not complete.
No blockers, live processes, commit or push. Stop after exactly G004.

G004 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G004 runtime, fixtures, tooling, acceptance and workflow/discovery state. Keep
ignored raw evidence local; no push or G005 implementation.

### G005 / 2026-10-08 UTC / Done

Every G005 criterion passed; [G005 acceptance](G005_ACCEPTANCE.md) maps detached
friendship/bag snapshots, retained recipient feedback, honest preference/item/cap
reasons, stable commands/echo safety, Moonflower help, modal/lifecycle boundaries
and ordinary physical acquisition/gifting to inspected evidence. No new reward,
fact authority, save field, source text, art, geography or resource supply.

Bulk runner230634 passes all11 cases: eight suites, engine/parse and rendered
UI397 assertions/42 captures (headless355). Transaction238, milestone657, modal384,
foraging130, bag148 and Maris729 pass; quest suite passes. Ordinary230853 passes
all4 cases, consequence suite and78 assertions/15 captures: two different real
flowers, helpful Edric/two gifts/one milestone, bag/recipient equality, third
flower preserved, ordinary existing companion choice through its independent
owner. Final231032 UI355/bag148 pass after preserving old item-help fallbacks.
All accepted runs have zero diagnostics/timeouts/source changes/errors. Source/
reference/converter and intended diff/link/source audit pass. Failed attempts
retained. Six final sheets/all57 images plus full-size details inspected at actual
960x640/1350x900. Viewport proof only; fresh social restart/native remains G008/G009.

Next eligible G006: detached met-only People projection. Remaining
G006,G007,G008,G009. Every item through G009: not complete.
No blockers, owned live processes, held controls, commit or push.
Stop after exactly G005; do not begin G006.

G005 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G005 runtime, UI, fixtures, acceptance and workflow/discovery state. Keep ignored
raw evidence local; no push or G006 implementation.

### G006 / 2026-10-08 UTC / Done

Every G006 criterion passed; [G006 acceptance](G006_ACCEPTANCE.md) maps met-only
detached rows, exact public identity/fact sorting, portrait fallback, authored
progress/label, all-eight independence and current/earlier restore freshness.
No new social/met/fact authority, mutation, UI, save field or content activation.
All 934 pre-existing game/tools files, source/pins and schema7/content1 unchanged.

Final runner docs/evidence/G006/20261008-232638827-ccda0a36/results.json passes
all seven cases: engine/parse, projection960, content432/78 malformed,
social-save844/560 malformed and social write3/read29 separate-process assertions.
Zero diagnostics/timeouts/source changes/errors. Reference/current converter,
preservation and intended diff/link/state audits pass. Failed attempts retained.
All items/events/boundary fixtures explicitly synthetic; no ordinary/UI/native
claim or captures. Existing disk/root restart regressions pass with isolated saves.

Next eligible G007: current J journal/HUD People UI and root modal lifecycle.
Remaining G007,G008,G009. Every item through G009: not complete.
No blockers, owned live processes, held controls, commit or push.
Stop after exactly G006; do not begin G007.

G006 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G006 projection, fixtures, acceptance and workflow/discovery state. Keep ignored
raw evidence local; no push or G007 implementation.

### G007 / 2026-10-08 UTC / Done

Every G007 criterion passed; [G007 acceptance](G007_ACCEPTANCE.md) maps met-only
People tab/HUD, learned details/portraits/progress, empty/partial states,
mouse/keyboard/scroll/exits and root modal/lifecycle/simulation behavior.
Existing quest/trust/upgrade content and canceled-drag trailing-release guard
remain intact; no social/save/content authority, new art or resource changes.

Bulk234112 passes all10 cases: projection960, UI130, dialogue384, bag148,
foraging130, movement/camera and quest suites, engine/parse/render143/13 captures.
Final234357 passes all5 cases: UI134, placement128, render148/14 captures and
engine/parse. Accepted runs have zero diagnostics/timeouts/source changes/errors.
Final14 images/two sheets and earlier full-size details inspected at actual
960x640/1350x900, including long scroll, no-facts, Edric and night/rain.
Source/reference/current converter and strict capture-evidence checks pass.
Failed attempts retained; setup explicitly synthetic, actual viewport UI proof.
Ordinary social/restart integration and native delivery stay G008/G009.

Next eligible G008. Remaining G008,G009. Every item through G009: not complete.
No blockers, owned live processes, held controls, commit or push.
Stop after exactly G007; do not begin G008.

G007 successful-task commit follow-up authorized on 2026-10-08 UTC. Commit only
G007 journal/root/UI, fixtures, capture tooling, acceptance and workflow/discovery
state. Keep ignored raw evidence local; no push or G008 implementation.
