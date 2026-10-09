# Day clock and NPC routines execution checklist

Goal: deliver the 25 routines for the eight existing villagers, with physical movement, condition reactions, group dialogue and two required interiors, reusing the delivered clock/weather.
Target: D:/development/game-dev-blender/returning-fair-prototype; application game/.
[CONTRACT](CONTRACT.md) owns stable scope/behavior/source authority. This checklist owns status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation; [AGENT_PROMPT](AGENT_PROMPT.md) supplies invocation.

## Selection and completion

All tasks start Pending; planning is not implementation. Resume the single In progress task first. Reassess Blocked work when its recorded blocker changes; unresolved blocked tasks exclude their dependents, not independent branches. Otherwise select the lowest-numbered Pending task with verified Done prerequisites. Reconcile conflicting artifacts/status before selecting; stop if selection stays ambiguous. A checkbox alone does not prove a capability.

Mark the selected task In progress before implementation. Complete exactly one task, including its own correctness/integration checks and necessary repairs, then stop before its successor. Done requires evidence for every criterion. Update status/handoff after incomplete sessions too; append completion records only for Done. No automatic agents/chats/schedules/commit/push/publication.

## Dependency table

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| R001 | Done | Current target/source read access | Pinned 25-routine inventory, mappings, vectors and declared gates |
| R002 | Done | R001 | Strict immutable routine content/reference validation |
| R003 | Done | R002 | Deterministic assignments from existing clock/conditions |
| R004 | Done | R003 | Durable routine commands/current-schema persistence |
| R005 | Done | R001 | Qualified multi-portal routing, existing travel preserved |
| R006 | Pending | R002, R005 | Safe exterior anchors/door approaches on pinned geometry |
| R007 | Pending | R005, R006 | Mayor Vale home and its nine required anchors |
| R008 | Pending | R005, R006 | Lantern Rest and Della's real station |
| R009 | Pending | R002, R006 | Physical same-map movement/bounded occupancy |
| R010 | Pending | R003, R004, R007, R008, R009 | Group/cross-map execution and safe night reconstruction |
| R011 | Pending | R004, R010 | Routine dialogue, group leases and directives |
| R012 | Pending | R009, R010 | Readable walk/actions/speech under lifecycle holds |
| R013 | Pending | R011, R012 | All 25 routines active in ordinary play |
| R014 | Pending | R013 | Integrated restart/rollback/retry and measured runtime bounds |
| R015 | Pending | R014 | Ordinary full-day/social/recovery rendered walkthrough |
| R016 | Pending | R015 | Fresh Windows packages/native restart/travel acceptance |

R005-R008 do not depend on selector/save implementation; R007/R008 are sibling rooms, and R009 needs neither room. Ordered selection does not make these a single dependency chain. Shared-file ownership stays sequential; no parallel execution is started by this plan.

## R001 - Pin source, mappings and acceptance

- Inputs/prerequisites: CONTRACT source list, current source/target bytes, N/G/F/FS/W/map handoffs and pins. Recheck Git/user changes, schema and relevant installed tools.
- Outputs/allowed changes: proposed tools/routine_migration/reference/ with hashed selected public inputs, exact 25-ID allowlist, 21 qualified targets/portal chains, rule vectors and exclusions/adaptations; finalize source/coordinate/performance sections of this workflow.
- Preserve: no runtime activation, source writes, exterior regeneration, extra people or old-workflow fixes. Snapshot necessary dependencies deliberately, not all 39 routines/private profiles.
- Acceptance: every routine/anchor/dialogue/outcome/flag/event/action has a mapping and downstream owner. Audit both room geometries/doors, fixed-contact bake obstacles, actual capsules and source INT-064. Record physical conflicts with bounded repair proposals; do not label untested routes safe. Pin movement 64 source units/s, blocked wait/repath and source selection/reconstruction behavior; declare numeric budgets before implementation.
- Checks/evidence: create proposed tools/routine_migration/reference_checks.py for counts, exclusions, hashes/drift refusal and source-semantic vectors. Record exact source identities, target readiness/baseline timings, mappings, proposed adaptations and unrun checks. Source tests read are not tests run.

## R002 - Validate immutable routine content

- Inputs/prerequisites: R001 pins/mappings, current NPC graphs/declarations and selected source schema.
- Outputs/allowed changes: proposed game/features/routines/ typed definitions/strict detached loader; game/content/routines/ selected converted content and reference indexes. Validate windows/conditions/participants/step IDs/actions/dialogue/outcomes and qualified map/anchor/portal declarations.
- Preserve: no production schedule activation or overwriting existing NPC/social pins. Planned rooms may pass declared-reference validation only; physical routes await R007/R008.
- Acceptance: all 25 valid definitions load immutably; malformed/unknown/duplicate keys/IDs, nonfinite durations, empty/equal windows, missing participants/flags/events/actions, dangling entries/jumps and unsupported references reject atomically with routine/file/step context. Partial catalog never publishes.
- Checks/evidence: create proposed routine_content_checks.gd with invalid/reference fixtures; reuse npc_content_checks and content_catalog_checks. Record data-only exposure and exact outcomes.

## R003 - Select from clock and actual conditions

- Inputs/prerequisites: R002 catalog, R001 vectors and current EnvironmentClock/WeatherConditionService/conversation/event snapshots.
- Outputs/allowed changes: pure selector and transient assignment plan/director with source precedence, whole-group conflict rejection, elapsed-window calculation and meaningful change detection.
- Preserve: no second clock, scene-owned durable truth, fabricated events or movement. R004 separately supplies durable commands.
- Acceptance: cover all 25 routine selections, inclusive/exclusive/overnight boundaries, midnight versus 10 AM wrap, priority/ties/groups, fact/flag/count/recency branches and rain versus thunderstorm. Unchanged plans do not restart each frame; window/recency expiry still triggers reevaluation without player action.
- Checks/evidence: create proposed routine_resolver_checks.gd and routine_clock_checks.gd using pinned vectors and invariant cases; reuse environment_rule_checks/environment_session_checks. Pure suppression fixture inputs are not saved-state delivery.

## R004 - Persist durable routine facts

- Inputs/prerequisites: R003 rules and then-current save architecture/code. Planning baseline is schema7/content1; recheck before selecting the next version.
- Outputs/allowed changes: minimal session-owned authored events/current-day suppression, validated atomic commands, strict current-schema change, complete current fixtures and detached restore/rebinding. Reuse existing environment/social/event truth and manual save ownership.
- Preserve: no legacy migration/defaulting, transient NPC position/path/cursor serialization, autosave or normal-save access. Preserve backup/write/restore rollback semantics.
- Acceptance: writer/reader retains events/suppression and all prior facts; suppression expires on day-index rollover only. Wrong/stale commands and bad saves are inert; old/newer/malformed envelopes reject before live swap. Authored event removal cannot clear derived storm or mutate forecast. Failed save/restore does not half-publish.
- Checks/evidence: create proposed routine_save_checks.gd and routine_process_checks.gd with isolated writer/reader phases; reuse save_checks, environment_save_checks, npc_save_checks, social_save_checks and foraging_save_checks. Document actual new supported format and update its consumers together.

## R005 - Route qualified portals

- Inputs/prerequisites: R001 portal inventory, PrototypeLocation/WorldHost, actual interactables and safe party arrivals.
- Outputs/allowed changes: explicit per-portal source/destination/arrival contract, directed route metadata and narrow player dispatch integration. Existing exterior/Tollworks gates use explicit bindings; expose NPC route queries separately from player travel.
- Preserve: no absent-room/future-gate activation, party travel from NPC commands or lost rollback. Do not infer every exit from a room's single destination.
- Acceptance: two synthetic exits reach their distinct intended destinations; stale/wrong source/arrival rejects. NPC queries leave player location/camera/party unchanged. Existing arrival IDs/Tollworks round trips/unsafe-spawn rollback work; replaced navigation leaves no duplicate region.
- Checks/evidence: create proposed routine_portal_checks.gd with multi-exit fixtures; reuse location_travel_checks, map_activation_checks and save_checks. Fixture proof is not production room delivery.

## R006 - Map safe exterior anchors and entrances

- Inputs/prerequisites: R002 declarations, R005 routes, R001 11 exterior targets and pinned geography/transform.
- Outputs/allowed changes: additive qualified exterior anchor/portal registry with physical Y/facing/player approaches, current capsule/path validation and explicit adaptations for absent/newer source targets. Prepare Mayor-home/inn door sites without enabling absent destinations.
- Preserve: river/crossings/building shells/geography pins, current station/foraging/light identities. Do not silently shift anchors to mask bugs or bake future dynamic bodies as fixed geometry.
- Acceptance: all 11 targets and door/party approaches have dry support, correct elevation, clearance, reachable paths and dialogue LOS where required. No overlap with arrivals/resources/ally/lamps; each exception has measured minimal adaptation and bounded owner. Unresolved physical conflict leaves acceptance unfinished.
- Checks/evidence: create proposed routine_anchor_checks.gd with routes/capsules/negative-water probes; reuse map_navigation_checks, map_crossing_checks, npc_world_checks and world_item_placement_checks. Record source/runtime feet separately; direct placement is not route proof.

## R007 - Deliver Mayor Vale home

- Inputs/prerequisites: R005 routing/R006 measured doorway, R001 pinned home map/catalog and nine required anchors.
- Outputs/allowed changes: bounded source-informed 3D room/resource, reciprocal door, safe hero/ally arrivals, floor/furniture/action stations, camera/occlusion, indoor lighting and qualified archive/breakfast/seat/rest anchors. Reuse asset pipeline; new art only for this readable room.
- Preserve: no exterior-origin transform indoors, new private/household facts, sleep/home ownership/campaign or full interior-system expansion. Existing rooms/party identities stay valid.
- Acceptance: ordinary zero-affinity entrance/return works; full party and both Vale bodies fit; all nine anchors and consecutive source legs are navigable. Rain/exterior shadows absent indoors while global time advances; failed travel rolls back. Inspect actual room in both projections/allowed zoom.
- Checks/evidence: create proposed routine_home_checks.gd and rendered room acceptance; reuse location_travel_checks, environment_lifecycle_checks and map_camera_checks. Walk actual door/return with public controls; label any setup separately.

## R008 - Deliver Lantern Rest and Della's station

- Inputs/prerequisites: R005/R006 routing/doorway, R001 inn map/catalog and existing Della graph/rig/adaptation record.
- Outputs/allowed changes: bounded source-informed 3D inn/resource, safe door/returns/party arrivals, camera/nav/indoor lighting and lantern-rest:inn-host-01 mapping. Narrowly correct obsolete exterior/interior dialogue wording.
- Preserve: no paid room/booking/sleep/morning scene or duplicate exterior Della. Enterable building does not enable deferred entitlement choices. Whole schedules wait for R013; room acceptance may place the single existing contact indoors.
- Acceptance: ordinary zero-affinity player can enter, reach/talk/gift/close with Della, then return. Exactly one Della on her actual map, no invisible town contact. Full-party/host lanes clear; global clock/weather/social persistence unchanged.
- Checks/evidence: create proposed routine_inn_checks.gd and rendered public route inspection; reuse npc_14_checks, social_gift_ui_checks, people_journal_checks, location_travel_checks and environment_lifecycle_checks. Replace fixed-contact assertions with genuine indoor access checks.

## R009 - Move noncombatant NPCs safely

- Inputs/prerequisites: R002 definitions, R006 exterior targets, current rigs/capsules/nav and R001 movement/wait/repath constants.
- Outputs/allowed changes: physical movement wrapper, injected occupancy/navigation, bounded wait/repath/cancel/failure states, actual-position interaction targets and achieved-speed presentation. Replace obsolete fixed-contact bake obstacles with dynamic occupancy; preserve real counter/furniture collision.
- Preserve: no companion catch-up teleport, attacks, ghosting, infinite repath, visible snaps or duplicate Maris/person/counter. No full schedule activation yet.
- Acceptance: actual-world walks reach targets without terrain/capsule penetration; opposing movers/player/ally blockers produce deterministic bounded outcomes and typed no-path failure. Pause/modal/focus/death stop motion; cancellation/unload releases reservations. Selector/LOS follows actual feet, not retired registry feet.
- Checks/evidence: create proposed routine_movement_checks.gd and routine_occupancy_checks.gd with physical barrier/door/blocked-path fixtures; reuse movement_camera_checks, companion_checks, interaction_dialogue_checks and npc_world_checks. Animation reflects achieved motion; synthetic setup stays labeled.

## R010 - Execute groups and cross-map reconstruction

- Inputs/prerequisites: R003 plans, R004 durable state, R007/R008 real rooms, R009 physical wrappers, R001 source INT-064 context.
- Outputs/allowed changes: root-owned transient executor/director, move/wait/action/speech cursor contract, atomic groups, loaded/offscreen portal legs, bounded deterministic startup/load reconstruction and rollback/rebinding.
- Preserve: no unloaded scene-physics farms, split groups, NPC-driven player travel, saved cursors, visible catch-up teleport or rewards from elapsed-step replay.
- Acceptance: loaded actor walks to source door; offscreen legs require valid directed chain; active arrival creates one safe wrapper/reservation. Separate ordinary night transition from seek/fresh-start/load at 22:00/midnight/06:00. Diagnose and regress Edric hidden overnight failure; prove home rest and morning return. Max-clock/large-delta reconstruction terminates; failed transfer/scene replacement restores consistent ownership without stale regions/bodies. Same-map reassignments start at real feet.
- Checks/evidence: create proposed routine_executor_checks.gd, routine_cross_map_checks.gd and routine_reconstruction_checks.gd with max-clock/rollback/invalid-chain/overnight cases; reuse location_travel_checks/companion_checks. Inspect rendered departure/arrival; retain failed-case diagnostics before repair, never teleport to pass.

## R011 - Bind routine dialogue and directives

- Inputs/prerequisites: R004 atomic commands/save, R010 contexts/groups and current NPC/social router; R001 source entry/outcome classifications.
- Outputs/allowed changes: step/default/ordinary entry order, interaction policy, group leases, typed directive routing and narrowly restored/activated public routine graph nodes. Compose with current gift/milestone activation instead of overwriting its catalog.
- Preserve: private disclosures, reward/event exactly-once rules, Maris ordinary/recovery route switching and current save/modal exclusions. Invalid context cannot create a fresh authority token.
- Acceptance: ineligible preferred entries fall through; allowDialogue=false blocks; loaded group holds until closure. Cancel resumes. Every tagged resume/jump/end/event directive validates current speaker/instance/routine/step, applies while leased, then reconciles once. Invalid/stale/reentrant command is inert. Helena real flag/fact outcomes and gifts publish atomically; no duplicated rewards across schedule/day boundaries during dialogue.
- Checks/evidence: create proposed routine_dialogue_checks.gd and routine_directive_checks.gd; use real Helena resume/jump/end choices and labeled fixtures for event directives without production choices. Reuse npc_dialogue_rule_checks, npc_dialogue_ui_checks, social_transaction_checks, social_gift_checks and recovery_presentation_checks.

## R012 - Present actions and timed speech

- Inputs/prerequisites: R009 achieved movement, R010 step lifecycle, N016 action variants/presenter. R011 is not a development prerequisite; its leases integrate in R013.
- Outputs/allowed changes: explicit production clip mapping for Edric fishing/Helena archive, appropriate facing, finite world speech and active wait/action timing with common holds/cancel. Reuse existing rigs/portraits and validate accessories.
- Preserve: no fish/fact/item/income/quest reward from presentation; no invented sheets/extra actors, per-frame rig replacement, walking in place or private diagnostic text.
- Acceptance: inspect movement/idle/action transitions, planted feet/slopes/props, speech readability/expiry and pause/focus/modal/unload holds at gameplay scale. No stale labels/accessories or input obstruction. Missing optional declared action has documented idle fallback; baseline character identity stays intact.
- Checks/evidence: create proposed routine_presentation_checks.gd plus rendered sequence/contact-sheet inspection; reuse npc_action_checks, npc_asset_pipeline_checks and map_camera_checks. Asset-review/setup is labeled, not ordinary schedule proof.

## R013 - Activate the complete 25-routine catalog

- Inputs/prerequisites: R011 dialogue/directives and R012 presentation, including all transitive prerequisites.
- Outputs/allowed changes: production root wiring, one NPC owner per actual map, live availability/anchor/portal bindings, truthful UI room/contact hints and updated scheduled-access assertions.
- Preserve: eight-person/25-routine scope, single indoor Della/Maris identity, existing quest/gift/party behavior and still-closed future gates. No invisible duplicates to satisfy old tests.
- Acceptance: every selected ID has coverage for selector/conditions/steps/locations/dialogue/art. Baseline/fact/real gather/flag/thunderstorm variants select correctly; Ivo station circuit and Vale group departures/returns work. Ordinary talk/gift and met-only People entries work where people actually are; no duplicate villagers/party or attackable townsfolk.
- Checks/evidence: create proposed routine_activation_checks.gd and exact coverage report; reuse npc_integration_checks, social_integration_checks, fishing_integration_checks, playable_slice_checks and recovery_presentation_checks. Use actual root; synthetic branches remain explicitly distinguished from earned facts/weather.

## R014 - Stress persistence/lifecycle and measure runtime

- Inputs/prerequisites: R013 active routines, R001 declared numeric targets and current isolated test runner/save infrastructure.
- Outputs/allowed changes: complete-root restart/rollback/retry/scene replacement tests and measured scheduling/path/occupancy/reconstruction/memory evidence; necessary bounded repairs.
- Preserve: no new feature scope/historical evidence rewrites. Earlier tasks already require basic correctness; this is full integration stress.
- Acceptance: current-schema writer/reader reconstructs without duplicate events/gifts/quest effects; suppression/events/clock/social/items persist while cursors remain absent from JSON. Failed travel/load restores bindings; retry retains durable facts. Ten town/home/inn cycles leave one room/region and no wrapper/reservation/listener growth. Pass declared p95/path/memory/max-clock budgets; retain failures and machine/settings/method.
- Checks/evidence: create proposed routine_lifecycle_checks.gd, routine_integration_process_checks.gd and routine_performance_profile.gd. Reuse save_checks, social_process_checks, fishing_process_checks, environment_lifecycle_checks, combat_checks, map_companion_checks and testing_support_checks. Synthetic probes never touch normal saves or prove public walking.

## R015 - Walk a real full day and recovery loop

- Inputs/prerequisites: R014 accepted integration, actual rendered/nav readiness and bounded input/capture/journey helpers.
- Outputs/allowed changes: task-owned ordinary rendered journey, concise criterion/coverage record and bounded repairs required to finish it.
- Preserve: no forced time/weather/state/health/affinity or teleport presented as ordinary play. Random thunderstorm is not a completion gate; earlier deterministic weather/path checks cover it.
- Acceptance: observe >=600 active seconds without acceleration, including night/rest/morning and solo/group transitions. Walk town/both interiors/returns, encounter Della/Vale family, observe Ivo movement/actions/speech, earn actual facts/gather/gift changes and exercise Helena routine choices. Complete Maris lead/Tollworks combat/vessel/fitting with ally and both crossings. Inspect rendering, Save/restart/revisit and cleanup.
- Checks/evidence: reuse public input and game/tests/support/ TestRunJourney/TestRunInteractionCapture helpers; create a proposed routine journey driver only if needed. Record viewed captures, actor IDs/location/context, confirmed pause/modal checkpoints, active versus inspection time, failures/runtime errors and owned-process cleanup. Rerun affected checks after repairs; no unrelated suite loops.

## R016 - Build fresh Windows packages and test native release

- Inputs/prerequisites: R015 accepted current gameplay and installed export/native guards; existing packages are historical only.
- Outputs/allowed changes: fresh Windows Desktop/Windows Validation, task-owned pack audit and isolated native writer/reader. Reuse/refactor current build/native tools; preserve previous packages/override by verified task-specific archive before local promotion.
- Preserve: no publication/deployment/installations, normal saves, source-checkout dependency or debug bridge standing in for native input. Release excludes tests/private profiles/Flutter/editable Blender.
- Acceptance: package audits cover rooms/25 routines/rig actions/current schema/exclusions; both start outside checkout. Native ordinary town/home/inn routes, a natural solo/group transition, talk/gift and Maris recovery pass; GUI Save/quit/new PID GUI Load/physical revisit retain exact durable oracle. R015 full-day and deterministic branch matrices complement native evidence; do not repeat luck-based species/weather requirements. Failed/unrun native criteria keep task unfinished.
- Checks/evidence: existing presets and explicit console engine; record hashes/schema/catalog/room/action inventory, APPDATA/LOCALAPPDATA/save/override isolation, PIDs/guard requests/viewed captures/exits. Adapt tools/native_input.ps1, native_evidence.py and recent tools/fishing/ or tools/social_migration/ package/native patterns; new routine tools remain proposed until created. Review final intended diff and update architecture/README only for delivered behavior.

## Completion records

R001-R004 completed; R005-R016 remain Pending. Final task ID: R016.
Next eligible: R005 (R001 prerequisite and pins verified).
Whole checklist complete: no. No current blocker.
[R001 acceptance](R001_ACCEPTANCE.md), [R002 acceptance](R002_ACCEPTANCE.md) and
[R003 acceptance](R003_ACCEPTANCE.md) and [R004 acceptance](R004_ACCEPTANCE.md) own evidence.
Append only after every selected criterion passes:

```text
ID - Done YYYY-MM-DD (America/Vancouver)
Result and changed files:
Verified prerequisites and preserved user changes:
Commands/cwd/isolation and actual outcomes:
Evidence and inspected captures/artifacts:
Decisions/compatibility changes/retained limits:
Next eligible ID and exact next action:
```

R001 - Done 2026-10-09 (America/Vancouver and UTC)
Result and changed files: tools/routine_migration/ public pins, mappings, vectors,
static geometry audit, budgets and fail-closed checks; this workflow's contract,
checklist/handoff and R001_ACCEPTANCE.md. No runtime activation.
Verified prerequisites and preserved user changes: target e10d13ed/source60c20eb2,
clean source; four pre-existing untracked planning docs at baseline. All1238
tracked files unchanged; AGENT_PROMPT/user workspace instructions preserved.
Commands/cwd/isolation and actual outcomes: repository cwd, bundled Python3.12.14,
reference_checks.py --source D:/development/game-prototype-2 --self-test --report
docs/evidence/R001/20261009-reference-final/results.json PASS1624 assertions/six
negative refusals; audit_geometry.py --check PASS2 rooms/4 doors/21 legs. TEMP-only
negative copies cleaned; no saves/appdata/game or gameplay runner used for R001.
Evidence and inspected artifacts: all25 selections,21 anchors,88 source input hashes,
actual room/door/capsule/static-body audit, source world reconstruction consumer,
GLB action metadata and historical N017 performance baseline. Failed attempts
retained and repaired; no gameplay/capture proof claimed.
Decisions/compatibility changes/limits: source/schema7/content1/exterior pins unchanged;
indoor origins/numeric budgets finalized. Physical routes/room rendering/moving budgets
and source INT-064 remain explicit downstream gates.
Next eligible ID and exact next action: R002; read R001 pins/coverage then implement
strict detached immutable content and actual content checks. Stop before R002.

R002 - Done 2026-10-09 (America/Vancouver and UTC)
Result and changed files: game/features/routines/ typed read-only definitions,
strict bounded JSON and complete atomic catalog loader; game/content/routines/
25 converted routines, catalog/declarations/provenance and stable-byte attributes;
game/tests/routine_content_checks.gd; tools/routine_migration/convert_content.py;
CHECKLIST/CURRENT_STATE/R002_ACCEPTANCE. Data-only exposure; no root activation.
Verified prerequisites and preserved user changes: target fc049516/source60c20eb2,
clean baseline; R001 live-source audit PASS1624. Existing NPC/social source pins,
all pre-existing game/tool tracked bytes, save7/content1 and geography unchanged.
AGENT_PROMPT/workspace instructions/source preserved; unrelated Blender2664 untouched.
Commands/cwd/isolation and actual outcomes: repository cwd; converter --check
PASS28 documents/offline1535 assertions. run_checks.ps1 -Task R002 -Names
routine_content_checks,npc_content_checks,content_catalog_checks,application_smoke
-ParseScripts features/routines/routine_content_catalog,features/routines/routine_definition,features/routines/routine_json
-TimeoutSeconds150 PASS6 cases, stable source and no diagnostics. Routine check
PASS848 assertions/228 rejection fixtures/25 routines/104 steps/21 anchors.
Import passed in earlier retained run. Distinct R002 check-000..003 save groups
and APPDATA/LOCALAPPDATA; data-only checks never load/write primary or backup saves.
Evidence and inspected artifacts: docs/evidence/R002/20261009-085202820-ad2f415e/
results.json, strict-content report/logs/source manifests and all converted content;
R002_ACCEPTANCE maps every criterion. Failed UID/malformed-type/numeric/fixture
attempts retained, repaired and rerun. No captures/gameplay/physical-route claims.
Decisions/compatibility changes/retained limits: source mapId -> prototype-mapId
only; all other authored values exact. Declared rooms/portals do not certify
physical routes. Deferred graph entries remain deferred; action art unchanged.
No schema/source/private cast/save/runtime ownership change; no commit/push.
Next eligible ID and exact next action: R003; consume immutable catalog/R001 vectors,
implement pure clock/condition selector and its checks. Stop before R003.

R003 - Done 2026-10-09 (America/Vancouver and UTC)
Result and changed files: four new game/features/routines/ context/plan/resolver/
director scripts and UIDs; routine_resolver_checks.gd/routine_clock_checks.gd and
UIDs; CHECKLIST/CURRENT_STATE/R003_ACCEPTANCE. Transient data only; no root wiring.
Verified prerequisites and preserved user changes: clean target2f0d60f/source60c20eb2;
R001 live-source audit PASS1624; actual R002 catalog PASS848/228 invalid fixtures.
All pre-existing game/tools/content bytes, source pins, schema7/content1, geography,
AGENT_PROMPT/user instructions and unrelated Blender2664 preserved.
Commands/cwd/isolation and actual outcomes: repository cwd; run_checks.ps1 -Task
R003 -Names routine_resolver_checks,routine_clock_checks -ParseScripts the four
new routine components -TimeoutSeconds150 PASS4 cases, stable source/no diagnostics.
New checks PASS13310/301 assertions. Earlier stable run passed import/parse,
routine_content_checks, environment_rule_checks12792 and environment_session_checks;
its two new weather-fixture failures repaired and affected checks rerun. Distinct
task check groups/APPDATA/LOCALAPPDATA/slots; no primary or backup save access.
Evidence and inspected artifacts: docs/evidence/R003/20261009-091213986-0fcf01c2/
results.json and two detailed rule reports; prerequisite cases in091034 run;
reference-preflight/results.json. All25 IDs selected in18 pinned vectors,1440-minute
roster/group sweep, exact boundaries/elapsed, precedence, recency/window expiry,
unchanged-frame stability, day suppression and actual seeded weather union.
Decisions/compatibility changes/retained limits: narrow existing weather epsilon
normalizes clock round trips; later-day weather fixtures explicitly synthetic.
Director samples caller-owned truth without effects/new clock/durable suppression;
R004 owns persistence, R013 owns activation. No movement/gameplay/native claim.
Import-generated six UID additions invalidated first run as expected; failure
reports retained. Owned Godot processes exited; no input/editor/cleanup owed.
Next eligible ID and exact next action: R004; recheck current save architecture,
implement minimal durable events/current-day suppression and required isolated
save/restart/atomicity checks. Stop before R004; no commit/push.

R004 - Done 2026-10-09 (America/Vancouver and UTC)
Result and changed files: RoutineFacts/RoutineFactCommand and UIDs; GameSession
atomic commands/rollover, strict SaveCodec8 and session-to-selector sampling;
routine_save_checks/routine_process_checks and UIDs; six complete current fixtures,
their version/path/provenance consumers and current package/native audit constants;
exact target adaptation ledger/gate, README/current architecture, this handoff and
R004_ACCEPTANCE. No schedule activation or execution/cursor fields.
Verified prerequisites and preserved user changes: clean target6c8b09d/source60c20eb2;
R002 catalog848 and R003 clock301 actual passing cases. R001 final live-source
audit PASS1624/ten negative refusals;30 intentional target adaptations with exact
before/after hashes, historical source/derived pins unchanged. No baseline user
changes; AGENT_PROMPT/workspace instructions/unrelated Blender2664 preserved.
Commands/cwd/isolation and actual outcomes: repository cwd; required persistence
checks and affected consumers each pass in stable-source cases across093524 and
093842 runs. Superseded whole runs FAILED for repaired fixture assumptions, not
relabeled. Final -Task R004 -Names fishing_reference_checks -ProcessScripts
routine_process_checks,save_process_checks -ParseScripts routine facts/command/context
-TimeoutSeconds 150 PASS7 cases at docs/evidence/R004/20261009-094110226-c4b0055b/.
Final source.changed=false/error=null, all exits0/diagnostics empty; fingerprint
637278940925301b2936119dbf634b7d02e6b30ca9282f172ce63531107bdebb (1203 files).
Evidence and inspected artifacts: routine save213 assertions/44 bad-save cases;
all prior fixture parsed values exact, six complete fixtures valid; independent
writer69272/reader25584 with exact full typed/forecast oracle and primary/backup;
real root unsafe-floor/blocked-spawn rollback, clock/day/weather and no-autosave
checks. Existing save/environment441/NPC569/social844/foraging111 pass, plus seven
affected consumers. Detailed mapping/commands/failures in R004_ACCEPTANCE.
Decisions/compatibility changes/retained limits: only schema8/content1 supported,
no migrations/defaults; environment saved day owns suppression expiry. Commands
validate session/day/revision/expected facts, publish detached facts once and reject
reentry. R011 still owns dialogue-context authority; R013 activation/R016 packages.
No ordinary/native/rendered schedule claim. Existing packages/source/geometry/art
unchanged. Owned checks exited, no input/editor/cleanup owed; no commit/push.
Next eligible ID and exact next action: R005; inspect explicit qualified portal,
PrototypeLocation/WorldHost/interactable/party-arrival contracts; implement only
multi-exit/NPC-query routing and required existing-travel rollback checks. Stop here.

R005 - Done 2026-10-09 UTC
Result and changed files: PortalBinding/PortalRoutes/UIDs and two active edge resources;
LocationDefinition/ContentCatalog/interactable/scene validation; existing exterior/
Tollworks bindings; narrow root/WorldHost weak-reference player dispatch and pure
NPC queries; three synthetic scenes/new portal checks/UID; affected compact/unsafe
fixtures and bounded travel-fixture refusal; exact ledger/gate/byte attributes,
architecture, handoff and [R005 acceptance](R005_ACCEPTANCE.md).
Verified prerequisites/preserved user changes: target clean cb324427/source60c20eb2;
R001 live-source PASS1624/88 inputs/ten refusals.45 exact target adaptations retain
original source/derived/baseline pins and prior R004 reasons. No baseline user changes;
AGENT_PROMPT/workspace instructions/geography/save8/content1 preserved.
Commands/cwd/isolation/results: repository cwd, PowerShell7, explicit Godot4.7.2.
Runner -Task R005 required location_travel/map_activation/save plus companion/routine-
save/content_catalog/interaction_dialogue PASS9 cases in101306934-3d036361; final
routine_portal_checks/parse PASS3 cases in101719323-6ff3196c.364 portal assertions,
100 inert NPC-query repetitions, two distinct physical fixture destinations/returns,
wrong/stale/missing/duplicate binding refusals and one navigation region. Ten real
Tollworks round trips and original no-floor/blocked-capsule rollback pass. All accepted
exits0/diagnostics empty/source.changed=false/error=null; each check independently
isolated including primary/backup and APPDATA/LOCALAPPDATA.
Evidence inspected: structured results/detailed reports/physical/save logs/manifests,
reference-final/results.json, fixture-geometry-audit.json and intended diff. Final1214-
file game/tool fingerprint c2d19d0d270bb1fb778dd01c391d623cff8e043568f12f7a5a074caa636b7e14.
Decisions/limits: only existing Tollworks pair enabled; planned home/inn pins stay
inactive. Legacy single-destination fields remain diagnostic only. WeakRef rejects
freed contacts safely. Synthetic placement/rooms are labeled, no ordinary/rendered/
native routine/interior claim. Original fixture physical geometry preserved; failed
and interrupted reports retained with exact repair history in acceptance/handoff.
All owned engines exited, no input/editor/cleanup owed. Blockers/unrun R005 criteria:
none. No commit/push. Next eligible R006; inspect qualified exterior anchors/door
approaches and implement measured registry/physical checks only. Stop here.
