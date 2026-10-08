# Villagers and richer dialogue migration checklist

Goal: eight recognizable villagers, ordinary branching conversations with portraits, remembered choices/public facts, and source-informed 3D character/action presentation.
Target: D:/development/game-dev-blender/returning-fair-prototype.
Read-only source: D:/development/game-prototype-2.
Status authority: this checklist. Rules/mappings: [CONTRACT](CONTRACT.md).
Preparation and invocation: [AGENT_PROMPT](AGENT_PROMPT.md).
Detailed continuation: [CURRENT_STATE](CURRENT_STATE.md).

N001-N008 Done: reference/content/rules/persistence/portrait UI, contact/events, animated pipeline and Edric's ordinary named character slice. N009-N018 remain Pending.
Existing P/M/W/F workflows remain delivered baseline history.

## Selection and completion

Resume the single In progress task first. Reassess Blocked work only when its recorded blocker changes. Otherwise select the lowest-numbered Pending task whose prerequisites are verified Done. An unresolved blocker excludes its task and dependents, not independent ready branches such as N007.
Resolve inconsistent status/artifacts before selecting; record an exact conflict when unresolved. No ready task: record unmet dependency/next safe action. All Done: report completion and stop.

Complete exactly one task per invocation. Mark In progress before implementation; finish required validation and necessary repairs, then stop before the next task. Done requires every acceptance criterion to have evidence. Update CURRENT_STATE after completed and incomplete sessions. Preserve stable IDs/completion records when refining pending work.

## Task index

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| N001 | Done | None; inspect actual delivered baseline | Pinned eight-person references, exact scope/placement/coverage contract. |
| N002 | Done | N001 | Validated typed NPC/graph catalogs; all selected source content classified. |
| N003 | Done | N002 | Pure dialogue selection, memory and atomic choice rules. |
| N004 | Done | N003 | Strict current-schema saves and persistent conversation/event memory. |
| N005 | Done | N004 | Multi-node portrait dialogue and known-facts UI integrated with existing gameplay. |
| N006 | Done | N005 | Safe scene-owned town contacts and real event adapters. |
| N007 | Done | N001, N002 | Reusable exported 3D rig/animation/presenter pipeline. |
| N008 | Done | N006, N007 | Edric complete and reachable; first real villager vertical slice. |
| N009 | Pending | N008 | Helena complete and reachable. |
| N010 | Pending | N008 | Maris ordinary dialogue/character integrated with existing recovery counter. |
| N011 | Pending | N008 | Harlan complete and reachable. |
| N012 | Pending | N008 | Tess complete and reachable. |
| N013 | Pending | N008 | Ivo complete and reachable. |
| N014 | Pending | N008 | Celia complete and reachable. |
| N015 | Pending | N008 | Della complete at documented public inn-entry adaptation. |
| N016 | Pending | N008, N009, N007 | Edric/Helena semantic action art exported and inspected. |
| N017 | Pending | N010, N011, N012, N013, N014, N015, N016 | Fresh integrated eight-person route, persistence and existing-game regression proof. |
| N018 | Pending | N017 | Fresh Windows packages and native all-eight restart acceptance. |

NPC tasks N009-N015 are independent after the first integration slice; no artificial chain between characters. They share catalogs/scenes, so this workflow still executes one at a time. N016 can proceed after Edric/Helena without waiting for the other people. Do not launch agents as a side effect of task selection.

## Verification profiles and evidence

DOC: inspect bytes/references and executable paths, hashes/dimensions/coverage, source/target Git status and intended documentation diff. No unrun runtime claim.
RULE: meaningful pure/content/save assertions with actual source definitions; malformed input, stale/repeated/hidden command rejection and cross-person isolation.
UI: real root/viewport interactions, portrait/body/choice/fact readability, Tab/Enter/Esc/focus containment and world input exclusion; viewed screenshots.
WORLD: full capsule/support/LOS/reachable player approach, collision/navigation/interaction arbitration, travel/reload/disposal/rollback and no duplicate actor.
ART: editable source, GLB import/rig/clips/materials, reference identity, feet/scale/framing, day/night/rain and transition contact sheets inspected.
PLAY: ordinary bounded movement/interaction/UI from fresh state, confirmed pause between analysis gaps, isolated saves and separate-process restart. Teleport/forced flags prove fixture rules only.
PACK: new package audit, standalone execution outside checkout, native OS input, captures/logs/exits, exact saved-state comparison. A debug bridge or previous F010 executable cannot prove a new release.

Existing reusable checks are listed per task below. They exist but are not certified against future changes. New check filenames are explicitly proposed; their owning task creates them. Use the shared runner from tools/run_checks.ps1 and task-specific fresh evidence directories; see the prompt and contract. Run focused checks and affected regressions, expanding only when changes/failures justify it.

For every task retain commands/cwd, isolated data paths, exact outcomes, source/asset IDs and hashes, inspected capture paths and residual limits. Record failed/unrun checks. Useful acceptance summaries live in this workflow; raw runs use docs/evidence/<N-ID>/<fresh-run>/ under current repository evidence policy. Synthetic and normal-play evidence must be distinguished.

## N001 - Pin scope, source semantics and safe placement policy

- Inputs: current target architecture and P/M/W/F artifacts, CONTRACT authority list, source eight packages/resolvers/visual references/canon, current pinned Godot geometry and save format.
- Deliverables: proposed tools/npc_migration/reference/ manifest and selected public input snapshots, exact source hashes, node/choice/condition/outcome/portrait/action coverage table, and source-to-target contact registry specification. Update CONTRACT with measured decisions and source identity; no NPC activation.
- Scope: documentation/reference audit only. Source read-only; preserve both repositories' existing changes, pinned geometry and all prior workflow statuses. Pin eight requested IDs despite source's larger roster.
- Acceptance: all 70 observed nodes, 24 facts and 48 portraits either match current bytes or have a documented drift correction; each node/choice is enabled or explicitly deferred; rule/tie/once-only/event behavior traceable to source. All eight source and target contact policies distinguish canonical feet from public adaptations; no guessed interior transform. Confirm tooling paths and current baseline/version dependencies. Missing visual capability is recorded as a future ART-task blocker, not a fabricated asset.
- Verification: DOC; hashes/asset dimensions/local link/coverage audit using read-only scripts (proposed npc_reference_checks.py). Inspect existing evidence for baseline capability; no unrelated suites merely to pin a plan. Snapshot runtime consumers must later be target-local.
- Completion evidence: reference manifest, coverage/placement audit and exact next eligible task.

## N002 - Typed NPC and graph definitions with full validation

- Inputs: N001 pinned public packages/coverage, current ContentManifest/ContentCatalog/ActorDefinition and legacy dialogue validation.
- Deliverables: proposed immutable NpcDefinition/DialogueGraph/Node/Conditions Resources or equivalent strict typed loader, selected converted content, identity/portrait/fact/action indexes, and proposed npc_content_checks.gd.
- Scope: selected catalog/definitions/conversion only; no actor activation, save bump or replacement of existing legacy dialogue. Reuse existing npc-03 actor identity; never add a conflicting definition.
- Acceptance: all eight graphs and their declared references convert deterministically; source IDs/text/entry ordering/expressions preserved except audited location adaptation. Deferred gift/routine nodes remain typed and reported. Candidate publication is atomic; malformed keys/types, duplicate IDs, dangling/cross-person links, missing portraits/facts, invalid finite transitions and unsupported conditions fail visibly.
- Verification: RULE; new content checks plus content_catalog_checks and application_smoke. Repeated conversion cannot accumulate definitions or pull seven unrequested packages. Runtime inputs are bundled target files, not absolute source paths.

## N003 - Per-person memory and deterministic dialogue rules

- Inputs: N002 definitions; source resolver, choice application, relationship and event-journal semantics pinned by N001.
- Deliverables: proposed ConversationMemory and bounded event-memory service, graph selection/eligibility/choice transaction/query services, detached snapshots and npc_dialogue_rule_checks.gd.
- Scope: node-independent rules and session ownership; preserve companion RelationshipState/trust and QuestService. No gifts, scheduling, UI or implicit quest rewards.
- Acceptance: real source introductions/revisits and fact/event gates select correct nodes; priorities/ties/source defaults verified. Entry records only authored facts/seen nodes; accepted responses atomically apply flags, choice receipts and bounded affinity. Opposite introduction reward cannot replay; two people/sessions remain independent. Hidden/stale/unknown/wrong-speaker/deferred commands mutate nothing. Close applies no unselected reward. Empty/unavailable choices have a valid exit; finite graph continuation cannot soft-lock.
- Verification: RULE; new rule checks use real eight-person graphs plus deliberate malformed fixtures. Reuse consequence_checks and quest_checks to detect authority overlap. Keep current line/terminal-choice gameplay working until N005 converts its content and callers to the new conversation flow.

## N004 - Persist memory in the current save format

- Inputs: N003 authoritative state, current SaveCodec/SaveRepository/rebind/rollback rules and actual current schema (planning baseline 6).
- Deliverables: documented next schema/version policy, strict per-person/event serialization, save/session restoration, proposed npc_save_checks.gd and two-phase npc_process_checks.gd.
- Scope: one additive schema change, provisionally 7/content1; reconcile version drift first. Preserve manual save boundaries/arrival restoration. Support only the resulting current save format; no older-format migration. No imported Flutter saves, auto-load or mid-dialogue cursor persistence.
- Acceptance: current-schema round trip/restart restores independent memories/event aggregates and all existing durable facts exactly. Reject schema6 and every other noncurrent format without defaults or migration. Malformed/foreign/newer IDs, numeric bounds, mismatched derived values and shared mutable collections reject before live swap. Backup/recovery/failure and unsafe placement retain existing behavior. Do not infer past events from possessions; dialogue remains unsaveable until closed.
- Verification: RULE and independent process phases; new checks plus save_checks, save_process_checks, foraging_save_checks, environment_save_checks, map_save_checks and consequence_checks. Exact oracle includes new state and all existing party/quest/trust/upgrade/environment/lights/items/placements. Use isolated appdata only.

## N005 - Portrait dialogue, branches and known-facts presentation

- Inputs: N004 durable services, existing PrototypeUI/GameRoot/DialogueService and pinned portraits.
- Deliverables: graph-aware conversation snapshot/router integration, speaker/expression portrait, authored formatted text, selectable branch/Continue/Close, compact learned-facts view, copied verified portrait assets and proposed npc_dialogue_ui_checks.gd.
- Scope: UI/root composition and assets; convert Maris/companion/vessel/practice dialogue and callers into the current conversation flow, preserving quest/reaction outcomes. Remove superseded formats/services when no callers remain; no parallel legacy API or engine. No full People journal or gift UI transactions.
- Acceptance: source portrait/body/fact highlights match current node; long text/choices scroll and all eight expressions render without distortion. Keyboard/mouse navigation and close work when optional gift choices unavailable. Facts view shows only actually disclosed facts. Opening/closing/changing node clears held controls; dialogue blocks attacks/dodge/foraging/drag/zoom/save/load and contains focus. Cancel/focus loss/unload cannot duplicate effects or leave input locked.
- Verification: UI plus RULE; new UI checks, interaction_dialogue_checks, backpack_ui_checks and live_playtest_checks. Inspect full-size 960x640 captures, plus a larger viewport, using fixtures explicitly labeled UI evidence. No claim of normal NPC routes yet.

## N006 - Scene-owned contacts and actual event adapters

- Inputs: N005 runtime/modal integration, N001 exact placement policy and current exterior/WorldHost/navigation/foraging owners.
- Deliverables: proposed NpcRegistry/world adapter/wrapper, safe placement and real dialogue identity binding, woods-entry/committed-foraging/dialogue-choice event adapters, lifecycle cleanup and npc_world_checks.gd. Character activation remains controlled by its owning N008-N015 task.
- Scope: additive contacts and small owner hooks; pinned terrain/water/structures/portals/navigation contracts retained. Villagers are noncombatants outside Party. No daily/global routine simulator.
- Acceptance: registered actor/player contact footprints fit ground and navigation with LOS; nearest interaction arbitration stays deterministic near lamps/resources/Maris. No crowd blocker removes an existing critical route. Woods entry counts once per actual crossing, not per frame or save/load; only committed real foraging generates gather events. Travel/retry/load/reset of transient wrappers disconnects old owners and restores one actor per identity; invalid placement rolls back. Optional local walks suspend safely; fixed contacts make no schedule claim.
- Verification: WORLD/RULE; new world checks plus map_navigation_checks, map_activation_checks, location_travel_checks, companion_checks, foraging_interaction_checks and light_interaction_checks. Check physically reachable approach/obstruction cases before declaring placement safe. Sources newer than pinned geography are registry additions, not map refreshes.

## N007 - Reusable 3D rig and Godot animation pipeline

- Inputs: N001 source visuals/canon/asset inventory, N002 action/visual contracts, current art export pipeline and actual Blender capability.
- Deliverables: measured NPC rig/unit/axis/foot/material/clip contract, reusable model/presenter workflow, editable calibration asset with exported GLB, labeled review scene and proposed npc_asset_pipeline_checks.gd.
- Scope: shared asset pipeline and replaceable VisualRoot presenter only. No completed named character claim from a generic calibration body; no player/ally redesign, dependency installation or unrelated scene edits.
- Acceptance: real GLB imports with correct identity transform/ground foot, skeleton/idle/walk clip names/loops, material/texture portability and stable transitions; Godot animations are exported clips rather than Blender-only drivers. Wrappers own collision and IDs. Demonstrate measured actor scale/clip bounds/no foot sliding and compatibility in current renderer; exact budgets grounded in an eight-actor scene estimate. Confirm production tool availability; if absent, preserve work and record precise blocker.
- Verification: ART; new pipeline check, existing asset_pipeline_checks and actual viewed Godot clip/transition captures. Blender preview alone is insufficient. Update pipeline document by extension, preserving historical static-asset rules.

## Common acceptance for each N008-N015 villager

Each task produces one complete person: authored/converted public runtime graph, six source portraits, distinct editable 3D .blend/GLB, idle/walk/facing presentation, source-to-target identity/placement mapping, one live noncombatant wrapper and actor-specific regression assertions. Paths use the actual source ID; proposed per-person check is npc_<source-ID with underscores>_checks.gd or one parameterized suite with equivalent evidence.

Use N001 pin/coverage, source package/canon and N005-N007 owners. Changes are limited to that package, registration/placement, tests/assets and necessary narrow shared fixes. Preserve other villagers, geometry, existing game state and conversation routes. One person never imports the extra source roster or creates another npc-03.

Acceptance: normal fresh player physically walks to contact, opens actual ordinary graph, tries one introduction and follow-up, learns authored public facts and exits/reopens. A separate isolated run tests alternative introduction; replay cannot grant both one-time effects. Portrait/expression/face/clothing/age/silhouette correspond to source; viewed day/night/rain captures and idle/walk transitions have stable feet/no clipping. Plain text labels/capsules/recolored generic meshes do not complete ART. All enabled graph branches get rule coverage, all deferred ones honest status. Save/reload retains this person's memory and all prior state; wrapper exists once after travel/retry. Native package acceptance remains N018.

Verification: actor-specific RULE/UI/WORLD/ART/PLAY evidence, npc_content_checks, npc_dialogue_rule_checks, npc_save_checks and affected existing interaction/quest/foraging/light/travel checks. Synthetic branch setup is rule proof only; at least one introduction/fact/revisit follows ordinary controls in actual root. Record which walk/action clips are runtime versus review-only.

## N008 - Edric first complete vertical slice

- Prerequisites: N006 and N007 Done; public civic contact and full common acceptance above.
- Specific inputs: npc-01 runtime/dialogue/visuals, ordinary entry order, woods first/repeat and moonflower hint conditions.
- Outputs/scope: first actual named character establishes repeatable package/activation pattern. River-fishing special clip belongs to N016; no fish rewards or gifts.
- Specific acceptance: helpful versus neutral introductions remain mutually exclusive; physical woods crossings and actual gathering select appropriate remembered lines, including exactly-once fact disclosure. Level-one/gift nodes retain proper deferred conditions, never artificial unlock.
- Evidence: common profile plus ordinary civic-to-woods return; record source-ID/event-subject mapping and working package template.

## N009 - Helena public dialogue and archive identity

- Prerequisite: N008 Done; source npc-02 package, public civic foot and common acceptance.
- Scope/output: real Helena character with normal entry/fact branches; archive-only preferred entries/outcome tags remain explicitly deferred until their actual consumer exists.
- Acceptance: archive practice fact appears only through source-sanctioned enabled disclosure; no private household/story reveal, daily suppression, ledger jump or fake work action. Ordinary actor and source portraits remain distinct from Edric; archive-work clip belongs to N016.
- Evidence: common profile plus ordinary public contact/fact/revisit and unavailable routine-entry assertions.

## N010 - Maris and recovery counter coexistence

- Prerequisite: N008 Done; source npc-03 package, existing counter, recovery dialogues/quest/effects.
- Scope/output: replace Maris appearance under the existing wrapper and add ordinary graph route without a duplicate person/counter or renamed interaction identity.
- Acceptance: fresh ordinary conversation, accept lead, actual guardian/vessel recovery, returned fitting, cancellation and specialist inspection remain legal and in order. Per-NPC memory stays separate from quest effects/companion trust; ordinary dialogue never restores service. Existing helper labels remain honest.
- Evidence: common profile plus quest_checks, recovery_presentation_checks and ordinary recovery-route regression or task-bounded segment with existing prerequisite state clearly labeled. Final fresh whole-route proof is N017/N018, not a substitute for immediate integration correctness.

## N011 - Harlan public dock contact

- Prerequisite: N008 Done; source npc-04 package and dock/control-hut references.
- Scope/output: real dockmaster character/contact without ship stage changes, sluice controls or travel service.
- Acceptance: safe dry player/NPC feet and dialogue approach avoid water/quay obstruction; ordinary public facts/introduction/revisit do not disclose future accident/private testimony or enable later campaign.
- Evidence: common profile plus physical dock route/water-negative clearance and existing lamp/rod contact arbitration.

## N012 - Tess store contact

- Prerequisite: N008 Done; source npc-06 package/store contact references.
- Scope/output: real Tess ordinary conversation at existing store neighborhood; no commerce/menu/wallet or supply grant.
- Acceptance: finite public shopkeeper/help/boundary branches and remembered choices work at zero affinity; text must not advertise functioning purchases. No changed neighboring shop geometry or blocked lane.
- Evidence: common profile plus ordinary store approach and unchanged item/quest state after dialogue.

## N013 - Ivo booking-neighborhood contact

- Prerequisite: N008 Done; source npc-07 package and passenger-booking/dry-shore anchors.
- Scope/output: real Ivo actor/ordinary graph; no booked trip, customer scene sequence, salvaging work or payouts.
- Acceptance: ordinary introduction/public facts reachable on dry shore; no second-city passage, hull repair or departure. Existing prototype helper stays labeled rather than silently claimed as completed Ivo scene integration.
- Evidence: common profile plus quay route/collision/return and unchanged gates/ship/quest facts.

## N014 - Celia repair-neighborhood contact

- Prerequisite: N008 Done; source npc-08 package and ordinary repairs station.
- Scope/output: real Celia ordinary graph/character; no new boat ride, service transactions, memory recovery or morning cutscene.
- Acceptance: authored public role/boundaries/hobby branches disclose only permitted facts, with original source portrait identity. Existing repair/dock lane stays passable.
- Evidence: common profile plus ordinary repair approach, repeat conversation and no unintended reward/stage changes.

## N015 - Della at public Lantern Rest entry

- Prerequisite: N008 Done; source npc-14 package, lantern-rest:inn-host-01 and N001 documented public entry adaptation.
- Scope/output: real innkeeper at safe public exterior threshold; preserve NPC identity and public lines. No new inn interior, home ownership, guest-room/sleep entitlement or mandatory morning event.
- Acceptance: target foot/player approach are measured and reachable, distinct from source interior coordinates; UI/records label prototype placement adaptation where necessary. Branches/facts do not grant a room or leak records/history. Inn door/future portal pad and routes remain unobstructed.
- Evidence: common profile plus measured source/target placement report and ordinary town-to-inn contact; future interior migration can reuse stable identity.

## N016 - Authored semantic action presentation

- Prerequisites: N008/N009/N007 Done; actual Edric river-fishing and Helena archive-work references.
- Deliverables: exported 3D action clips/accessories and presenter transitions, explicit ordinary-versus-review exposure inventory, proposed npc_action_checks.gd and contact sheets.
- Scope: only these two source actions. No fishing minigame, archive scene director, daily routine outcomes, profession rewards or invented actions for six other villagers.
- Acceptance: identity/feet/accessory alignment preserved through idle/walk/action/interrupt; dialogue/pause/focus/travel cancels or freezes safely and resumes appropriately. Review scene shows both real assets; ordinary ambient use occurs only where approved placement supports it. Clip-only review is reported honestly. No leaked Blender drivers or gameplay attached to art.
- Verification: ART/UI/lifecycle; new action checks, npc_asset_pipeline_checks, interaction_dialogue_checks and viewed Godot transitions in day/night. Exported clip names/materials available without source checkout.

## N017 - Integrated town, dialogue persistence and regression

- Prerequisites: all character tasks and N016 Done through declared dependencies; inspect their actual capability/evidence.
- Deliverables: proposed npc_integration_checks.gd, ordinary eight-contact writer/reader journey, exact restart oracle, viewed visual survey and consolidated coverage/remaining-deferred report.
- Scope: necessary integration fixes only; no new actor, story system or expansion of deferred migrations.
- Acceptance: fresh ordinary player reaches all eight safely, sees correct portraits/branches, learns public facts, reopens remembered conversations, traverses existing woods/crossings and completes shortened recovery. Alternative mutually exclusive branches covered in separate fresh sessions. GUI Save/quit/new-process GUI Load/revisit preserves new memory and all previous facts exactly; no duplicate wrappers/rewards. All enabled graph paths covered; deferred capabilities and source/target placement differences remain explicit. Day/night/rain, long text, focus/cancel/travel/death/retry checked; contact actor crowd does not introduce a measured frame/navigation regression against current map baseline.
- Verification: RULE/UI/WORLD/ART/PLAY; all new NPC suites and affected existing application/content/save/quest/recovery/combat/companion/map/foraging/backpack/environment/light checks. Use current runner, actual ordinary input and inspected captures; do not claim native release here.

## N018 - Fresh Windows delivery and native acceptance

- Prerequisite: N017 Done, actual existing export presets/templates and owned native input tooling available.
- Deliverables: fresh Windows validation/release packages in separate task staging, pack audit/hashes, standalone native writer/reader all-eight walkthrough, concise delivery/limits documentation and updated parent discovery/architecture where needed.
- Scope: preserve/archive existing known-good local packages before any deliberate promotion; never overwrite unrelated artifacts or normal saves. No public upload, deployment, release-store flow or source writes.
- Acceptance: new .exe/.pck pair starts outside checkout and source reference tree; portraits/models/clips/public graphs all bundled and resolve. Private profiles/Flutter files/tests/bridge absent from release. Native public controls reach all eight, exercise real branches/facts/Maris route, GUI Save/quit/new-process Load/revisit and exact prior/new-state comparison with clean logs/normal exits. Synthetic setup, validation build input bridge or N017 development runs cannot substitute for release acceptance. If native focus/input or another required gate fails, retain incomplete status and precise safe retry.
- Verification: PACK/PLAY plus affected focused pre-export checks; executable/resource audit, inspected native captures/contact sheets and command/isolation/PID provenance. Final report identifies runtime versus review-only clips and deferred gifts/routines/interiors. Workflow ends here.

## Completion records

Append a new completion record only after all selected criteria pass:

```text
ID and completion date:
Result and files changed:
Verified prerequisites and source/asset IDs:
Commands, cwd, isolation and exact outcomes:
Evidence paths and inspected images/artifacts:
Decisions/version/placement changes and retained limitations:
Next eligible task:
```

### N001 â€” 2026-10-07, America/Vancouver

Result: pinned exactly eight selected public packages,90 byte-exact copies/132 source
hashes;70 nodes/54 choices/24 facts/48 portraits/18 sheets classified. Measured eight
safe public contact specifications, including source indoor versus Della exterior
adaptation. Source resolver/receipts/affinity/events/caps and deferred disclosure
boundaries traced. No NPC activation or save/runtime/art change.

Files: tools/npc_migration/{pin_reference.py,npc_reference_checks.py,measure_contacts.gd,
README.md,reference/}; this checklist, CONTRACT, CURRENT_STATE and
[N001 acceptance](N001_ACCEPTANCE.md). Preexisting README discovery edit retained.
Target/source HEADs remain d95f548eff72dbd72664656f39cc82f8918ee3a6 /
60c20eb2816e7271fb84afaba286af006ebe3ccf; source clean, all462 production files exact.

Verification from target root with installed console/bundled Python: final reference
checker PASS with optional source drift and placement report; all8 simultaneous
reserved routes/2,008 samples/three negatives PASS, exit0 and clean final log.
PNG decode48 portraits/18 sheets PASS; portrait inventory viewed. Godot version/paths
and Blender read-only scene connection confirmed. Historical F010 results inspected;
no unrelated suites rerun. Final bootstrap/link/status/diff audit PASS. Evidence:
docs/evidence/N001/20261007-reference/, successful placement-attempt-4; failed1-3
retained. Isolated builds/testing/N001/20261007-reference appdata/localappdata;
normal saves untouched, all owned probes exited, no editor/agents/chats/schedules.

Retained limits: enabled classifications are future migration scope, not runtime
access. Gifts/archive routines/three undisclosed facts/Edric milestone/Della indoor
directions remain deferred; N007 animation pipeline and character art unverified.
Exact criteria/commands/failed attempts and inspected image in N001 acceptance.
Next eligible: N002 typed NPC/graph definitions and validation. Stop after N001.

### N002 â€” 2026-10-07, America/Vancouver

Result: strict typed selected catalog, deterministic conversion, atomic publication
and detached definitions for eight people/70 nodes/54 choices/24 facts/48 portraits/
18 reference sheets. Deferred 12 nodes/16 choices/three facts/eight gifts retain authored
fields and reasons. Existing npc-03 and 21-definition core catalog remain unchanged;
root validates separate NPC definitions before startup. No actors activated.

Files: game/features/npcs/*.gd with UIDs; game/content/npcs/catalog.json/.gitattributes;
game/assets/npcs PNGs/import records; npc_content_checks.gd/UID; narrow root/export/
application_smoke additions; tools/npc_migration/convert_content.py and scoped .gitattributes; workflow handoff,
contract/README/architecture discovery and [N002 acceptance](N002_ACCEPTANCE.md).

Prerequisite: N001 source/pin/coverage/contact audit PASS before edits. Source remains
60c20eb2816e7271fb84afaba286af006ebe3ccf, clean; target began clean at 71b087ab.
Conversion check protects all 132 source hashes/67 outputs and repeat determinism.
Godot shared runner import/parse/npc_content_checks/content_catalog_checks/
application_smoke PASS, exit 0; 423 assertions/75 malformed candidates, no runtime
errors or source changes. Final evidence docs/evidence/N002/20261008-063748469-bd2b5f8b/;
fresh builds/testing/N002 matching appdata/localappdata and named slots. Two failed
attempts retained: generated import metadata changed initial source; StringName fixture
keys prevented seven intended tests until corrected to actual JSON String keys.

Catalog hash 9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9.
All 66 PNGs byte-exact; 459 of 462 original production files unchanged, three narrow
changes, 144 owned additions/no removals. Schema6/content1 and pinned geography retained.
Final diff/links/status/dependencies/source audit PASS. No new UI/ordinary route/art/
release claim or save access; all owned processes exited, no cleanup owed.
Next eligible N003. Independently ready N007 not started. Exactly N002 completed.

### N003 — 2026-10-08, America/Vancouver

Result: session-owned independent per-person/event memory, pure deterministic entry/
condition queries and atomic choice/cursor publication. All 58 enabled nodes/38 choices
of the real eight graphs exercised, both introduction alternatives in fresh sessions.
No actor/UI activation, implicit quest/trust rewards or save schema change.

Actual modules: ConversationMemory, NpcEventMemory, NpcConversationState,
NpcDialogueRules, NpcDialogueService and owning npc_dialogue_rule_checks with UIDs;
narrow GameSession/GameRoot startup/restoration binding. Forty exact supported event
keys, signed affinity clamp, source threshold/ties/disclosure/once-only rules and
owner tokens documented in [N003 acceptance](N003_ACCEPTANCE.md).

Final shared runner import/parse/new rules/consequence/quest/legacy interaction/smoke
PASS all eight cases, exit0, 977 assertions/135 rejection commands, zero runtime
failures/source drift/timeouts. Evidence docs/evidence/N003/20261008-074106073-ccf87fae/;
fresh isolated matching builds/testing appdata/localappdata and separate slots.
Actual root manual schema6 Save/Load rebinding passes; no normal saves accessed.
Two failed import attempts retained for generated UIDs; smaller earlier passing run
superseded by final expanded acceptance. Read-only source clean/pinned hashes exact.

Checklist/contract/current state/README/architecture updated; final byte/link/diff/
status audit recorded. All owned processes exited, no cleanup owed. N004 next eligible;
independent N007 unstarted. Exactly N003 complete; stop before successor.

### N004 - 2026-10-08, UTC

Result: schema7/content1 strictly persists eight independent memories and <=40
exact bounded event aggregates. All existing durable fields remain exact. No
old-format migration, missing-field default, inventory inference or cursor save.
Active dialogue blocks manual Save/Load; successful physical restore binds durable
memory to a fresh inactive cursor. Malformed state/unsafe placement rolls back.

Actual additions: NpcSaveData, npc_save_checks, npc_process_checks and NpcSaveFixture
with UIDs. Narrow GameSession/GameRoot/SaveCodec/SaveJsonFields/SaveNumber changes;
six authored fixtures explicitly updated to schema7, environment fixture renamed v7.
Prior fixture facts unchanged; affected hard-coded version/path assertions updated.
Full interface/acceptance/failure history in [N004 acceptance](N004_ACCEPTANCE.md).

Final shared runner import/parse/new saves plus required save/foraging/environment/
map/consequence/rule/startup and affected inventory/reference/testing-support suites,
both independent-process save suites PASS: all19 cases exit0, zero forbidden
diagnostics/timeouts/source changes. 567 NPC-save assertions including evidence write,
509 malformed inputs, exact complete restart oracle. Evidence:
docs/evidence/N004/20261008-083758961-2874c9d4/; fresh matching builds/testing isolation.
Earlier failures retained; no guard/criterion bypass. Source pins/catalog/art bytes
and normal user saves unchanged. Final source/byte/link/diff/status audit recorded.

Exactly N004 completed. No owned live process/editor/cleanup, blocker or unrun
N004 criterion. No agents/chats/schedules/commit/publication. Remaining N005-N018;
N005 next eligible, N007 independently ready. All through N018 are not complete.

### N005 - 2026-10-08, UTC

Result: one GameRoot.dialogue/NpcDialogueService finite cursor drives current source
NPC and converted prototype graphs. ConversationView renders source portraits,
formatted node text, current-node fact highlights, only learned facts, scrolling
branches/body/facts and fixed Continue/Close with contained focus. Existing six
prototype resources preserve exact IDs/words/commands across24 nodes/15 choices;
old DialogueDefinition/DialogueChoice/DialogueService scripts/UIDs removed.
Maris recovery reads the same person's facts; legal quest/companion outcomes retained.
Schema7/content1, source catalog/art and pinned geometry unchanged.

Every criterion verified: actual root GUI branches, stale/reentrant command rejection,
48 source expressions/eight people, 960x640 and actual1350x900 captures, long scrolling,
unavailable gift pointer Close/Esc/Enter Continue/Tab/Shift-Tab/arrows, input exclusion,
focus loss/unload/held controls and exact manual isolated save restore. UI fixtures
are explicitly synthetic, with no ordinary eight-person route/art/native release claim.
Full commands, evidence/inspection and retained failures: [N005 acceptance](N005_ACCEPTANCE.md).

Shared runner expanded26 cases PASS (092317416-ddbcf325); final UI/rule/required
regression8 cases PASS (092745965-d02fca8d); final test-only pointer/focus extension4
cases PASS (093803876-0c2316ed). No forbidden diagnostics/timeouts/source changes.
Latest headless384/rendered452 assertions,68 captures; Python provenance/strict guards
and read-only pinned conversion pass.772 game/tools files stable. Owned processes
exited; no editor/cleanup, remaining N005 acceptance, blocker or commit/push.

Exactly N005 completed; stop. Remaining N006-N018; N006 next eligible, N007
independently ready. All checklist items through N018 are not complete.

### N006 - 2026-10-08, UTC

Result: scene-owned registry/wrappers, exact source dialogue identity binding,
physical placement/navigation/LOS gates and real woods/committed-gather event hooks.
Production activation remains empty; N008-N015 own characters. Existing Maris counter
reused, NPCs outside Party, fixed contacts without schedules. Old listeners disconnect;
load/travel/retry rebuild once; unsafe NPC placement rolls back with exact live facts.
Schema7/content1 and pinned geometry/source/catalog/art remain unchanged.

Files: NpcRegistry/NpcWorldAdapter/NpcWorldEvents with UIDs; narrow PrototypeLocation,
WorldHost, GameRoot, PrototypeInteractable and ForagingState hooks; npc_world_checks
with UID and foraging_interaction_checks event assertions; workflow/discovery docs.
Prerequisites N001 measured eight contacts/N002 content/N005 integration verified.
Target began clean at8b9da9cdcbbbf3a00f88934a042139409a9ffbc4; source remains clean/pinned
at60c20eb2816e7271fb84afaba286af006ebe3ccf. Read-only converter132 hashes/67 outputs PASS.

Expanded shared runner all18 cases PASS, including required map/navigation/activation/
travel/companion/foraging/light, affected NPC rules/save/transactions/dialogue/startup,
independent NPC writer/reader. Final test-only extension all4 cases PASS; production
bytes unchanged. World10,253 assertions/10,131 physical route samples, foraging130
viewport assertions. Zero forbidden diagnostics/timeouts/source changes; isolated
fresh appdata/localappdata/slots. All-eight physical fixtures include ten existing
light/resource contacts, source choices, exact manual load and unsafe-contact rollback.

Evidence docs/evidence/N006/20261008-100827014-f14056aa/ and final
20261008-101212326-dd2a2f3c/; results/logs/JSON and final source/byte/link/process audit
inspected. Full criterion/commands/interfaces/failure history in
[N006 acceptance](N006_ACCEPTANCE.md). No ordinary character/art/native claim; no
remaining N006 criterion or blocker. All owned checks exited; no editor/cleanup,
commit/push, agents/chats/schedules or normal save access. Exactly N006 completed.
Remaining N007-N018; next eligible N007. All through N018 are not complete. Stop.
### N007 - 2026-10-08, UTC

Result: editable generic16-bone/204-triangle calibration .blend/GLB, actual baked
idle4s/walk.8s loops with packed texture, transactional VisualRoot presenter,
labeled eight-rig review and explicit animated extension of static P012 pipeline.
No named villager activation/art/action claim; NpcRegistry.ENABLED remains empty.

Prerequisites N001/N002 pins and actual N006 wrappers inspected; target began clean
at737c0cb45ff5abda47f9d0b6b0dd8f61950a6e33. Source remains clean/pinned at
60c20eb2816e7271fb84afaba286af006ebe3ccf; converter132 hashes/67 outputs PASS.
Source, schema7/content1, catalog/portraits, pinned geometry and existing runtime
unchanged. Files/interfaces/commands/failures in [N007 acceptance](N007_ACCEPTANCE.md).

Final shared runner version/parse/new pipeline/static asset/startup/render all6
cases PASS/exit0,832 assertions including evidence write,25 actual960x640
Compatibility captures inspected. Raw GLB/normalized editable-source audits PASS.
Stable795 runtime/tool files, zero forbidden diagnostics/timeouts/source changes.
Evidence docs/evidence/N007/20261008-103647902-04ca9996/; fresh matching isolated
appdata/localappdata/named slots. Steady stance drift1.1920929e-7m; clip bounds,
raw/imported loop endpoints, blends/holds, wrapper IDs/capsule and travel disposal
verified. Exact eight-actor budgets/review timing documented; full-map proof N017.

GLB SHA256bf0cd0135c4f9401b62496699690377981cb82e5ab5f74ea2c0ba49249b89eee;
.blend SHA256b2d97e827bdd39ba676a9f332b7164aca6f3b69f63d4b3e941d5430843061d39.
Failed metadata/offset/fixture/cropping attempts retained and repaired. No remaining
N007 criterion/blocker or owned process. Preexisting Blender/source scene preserved;
calibration scene remains available in memory. No normal saves, commit/push,
agents/chats/schedules/installation/publication. Exactly N007 completed; stop.
Remaining N008-N018; next eligible N008. All through N018 are not complete.

### N008 - 2026-10-08, UTC

Result: Mayor Edric Vale/npc-01 at pinned public civic foot(-.5,0,-1.5), real source
graph/six portraits, custom editable 3D .blend/GLB, actual idle/facing lifecycle.
Ordinary helpful/neutral introductions, first/repeat physical woods returns, real
Moonflower gather/preference once-only, disabled gifts and exact independent GUI
Save/Load/revisit verified. Walk review-only; river-fishing stays N016.

Prerequisites N006/N007 actual placement/rig evidence and N001/N002 pins inspected.
Target began clean at6c8c15031a5b37a32b5fb6cbf9a0f70fd9b40d85; source remains clean
at60c20eb2816e7271fb84afaba286af006ebe3ccf, all132 hashes/67 outputs exact. Catalog,
portraits, schema7/content1, pinned geometry, other people and prior features retained.

Files: named asset/authoring/audit/import package, narrow registry/adapter/root holds,
actor checks/render/UIDs, historical activation/travel fixture updates, package notes,
workflow/README/architecture. Every criterion/command/failure/limit in
[N008 acceptance](N008_ACCEPTANCE.md). No commit/push or successor implementation.

Required content/world/pipeline/interaction/quest/foraging/light/startup PASS in
111157041-06433481; expanded run FAILED stale travel assumption. After real Esc
fixture repair, focused111537969-95b2a472 all12 cases PASS, including10 travel
round trips, named skin/rules/save, synthetic process pair and ordinary writer/read.
WriterPID8056/readerPID8560 exact whole-state/forecast GUI restart; zero forbidden
diagnostics/timeouts/source changes. Fresh isolated per-suite appdata/slots only.
Separate neutral111802387-2f19dc1a all3 cases PASS; final contact/art/weather/default
distance112104670-8bbb2263 all4 cases PASS. No production change between these runs.

722 skin assertions/120Hz loops,196 stance/120 blend samples: soles0/seams0,
stance drift2.3841858e-7m, blend max vertex step.0127691m. 7,614 triangles/16 bones/
one packed32x32 palette material.53 selected captures inspected; final rain is real,
synthetic studio/seeded weather separated from ordinary gameplay input.
GLB4aeb9d211342f15bef34b3466035a90172a4146d94a82e12f550ce7b1c5bb41a;
.blend8175368c4291b449b3fec38f7f2c152a09fbd5b4da55370d2c18cd31a952d647.

Final source/diff/link/status/process audits retained. All owned checks/helpers exited;
live Blender original scene/file preserved, owned Edric scene available. No cleanup,
blocker or remaining N008 criterion; normal saves untouched. Exactly N008 completed.
Remaining N009,N010,N011,N012,N013,N014,N015,N016,N017,N018. Next eligible N009;
all through N018 are not complete. Stop.

### N008 authorized commit follow-up - 2026-10-08 UTC

User authorized committing the successful N008 task. Named implementation/art,
reusable checks, N008_ACCEPTANCE.md, package documentation and durable workflow/
discovery updates are the commit scope. Accepted runtime/art bytes and all status
rows stay unchanged. Raw evidence remains ignored under existing policy. Commit
identity/tree/status audits stay in the latest local N008 run; resulting identity
is available in Git history and follow-up report. No unrelated work, push or N009
implementation.
