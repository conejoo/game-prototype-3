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
| R006 | Done | R002, R005 | Safe exterior anchors/door approaches on pinned geometry |
| R007 | Done | R005, R006 | Mayor Vale home and its nine required anchors |
| R008 | Done | R005, R006 | Lantern Rest and Della's real station |
| R009 | Done | R002, R006 | Physical same-map movement/bounded occupancy |
| R010 | Done | R003, R004, R007, R008, R009 | Group/cross-map execution and safe night reconstruction |
| R011 | Done | R004, R010 | Routine dialogue, group leases and directives |
| R012 | Done | R009, R010 | Readable walk/actions/speech under lifecycle holds |
| R013 | Done | R011, R012 | All 25 routines active in ordinary play |
| R014 | Done | R013 | Integrated restart/rollback/retry and measured runtime bounds |
| R015 | Done | R014 | Ordinary full-day/social/recovery rendered walkthrough |
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

- Approved correction (2026-10-10 UTC): user accepted "validate Ivo's movement, waits, and conversation, and verify routine actions/speech on Edric and Helena instead" with "yes, validate that". This resolves the recorded absent-Ivo-action/speech conflict; authored routine content stays exact. R015 is accepted below; R016 remains Pending. All R015 criteria pass.
- Inputs/prerequisites: R014 accepted integration, actual rendered/nav readiness and bounded input/capture/journey helpers.
- Outputs/allowed changes: task-owned ordinary rendered journey, concise criterion/coverage record and bounded repairs required to finish it.
- Preserve: no forced time/weather/state/health/affinity or teleport presented as ordinary play. Random thunderstorm is not a completion gate; earlier deterministic weather/path checks cover it.
- Acceptance: observe >=600 active seconds without acceleration, including night/rest/morning and solo/group transitions. Walk town/both interiors/returns, encounter Della/Vale family, observe Ivo movement, waits and conversation, and authored routine actions/speech on Edric and Helena; earn actual facts/gather/gift changes and exercise Helena routine choices. Complete Maris lead/Tollworks combat/vessel/fitting with ally and both crossings. Inspect rendering, Save/restart/revisit and cleanup.
- Checks/evidence: reuse public input and game/tests/support/ TestRunJourney/TestRunInteractionCapture helpers; create a proposed routine journey driver only if needed. Record viewed captures, actor IDs/location/context, confirmed pause/modal checkpoints, active versus inspection time, failures/runtime errors and owned-process cleanup. Rerun affected checks after repairs; no unrelated suite loops.

## R016 - Build fresh Windows packages and test native release

- Inputs/prerequisites: R015 accepted current gameplay and installed export/native guards; existing packages are historical only.
- Outputs/allowed changes: fresh Windows Desktop/Windows Validation, task-owned pack audit and isolated native writer/reader. Reuse/refactor current build/native tools; preserve previous packages/override by verified task-specific archive before local promotion.
- Preserve: no publication/deployment/installations, normal saves, source-checkout dependency or debug bridge standing in for native input. Release excludes tests/private profiles/Flutter/editable Blender.
- Acceptance: package audits cover rooms/25 routines/rig actions/current schema/exclusions; both start outside checkout. Native ordinary town/home/inn routes, a natural solo/group transition, talk/gift and Maris recovery pass; GUI Save/quit/new PID GUI Load/physical revisit retain exact durable oracle. R015 full-day and deterministic branch matrices complement native evidence; do not repeat luck-based species/weather requirements. Failed/unrun native criteria keep task unfinished.
- Checks/evidence: existing presets and explicit console engine; record hashes/schema/catalog/room/action inventory, APPDATA/LOCALAPPDATA/save/override isolation, PIDs/guard requests/viewed captures/exits. Adapt tools/native_input.ps1, native_evidence.py and recent tools/fishing/ or tools/social_migration/ package/native patterns; new routine tools remain proposed until created. Review final intended diff and update architecture/README only for delivered behavior.

## Completion records

R001-R015 completed; R016 Pending. Final task ID: R016.
R015 validated under the user-approved correction; next eligible R016.
Whole checklist complete: no. R015 complete; only R016 remains unfinished.
[R001 acceptance](R001_ACCEPTANCE.md), [R002 acceptance](R002_ACCEPTANCE.md) and
[R003 acceptance](R003_ACCEPTANCE.md), [R004 acceptance](R004_ACCEPTANCE.md) and
[R005 acceptance](R005_ACCEPTANCE.md), [R006 acceptance](R006_ACCEPTANCE.md) and
[R007 acceptance](R007_ACCEPTANCE.md), [R008 acceptance](R008_ACCEPTANCE.md),
[R009 acceptance](R009_ACCEPTANCE.md), [R010 acceptance](R010_ACCEPTANCE.md),
[R011 acceptance](R011_ACCEPTANCE.md), [R012 acceptance](R012_ACCEPTANCE.md),
[R013 acceptance](R013_ACCEPTANCE.md) and [R014 acceptance](R014_ACCEPTANCE.md) own evidence.
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

R006 - Done 2026-10-09 UTC
Result and changed files: detached RoutineExteriorRegistry/UID for eleven exact
exterior stations/two inactive entrances and safe party approaches/returns;
routine_anchor_checks/UID; actor-only Maris body separated from unchanged real
bench; two original bench assertion paths updated; stale navigation-failure
fixture/check repaired for current qualified portal contract; exact owner ledger/
gate, five byte-preservation attributes, architecture and this workflow's state/
checklist/[R006 acceptance](R006_ACCEPTANCE.md).
Verified prerequisites/preserved user changes: clean target3dfdea9b/source60c20eb2;
R002/R005 artifacts and original accepted1214-file baseline verified. R001 source
audit PASS1624/88 inputs/ten refusals;50 exact adaptations retain original pins.
No baseline user changes; user instructions/source/geography/schema8/content1,
fixed contact feet/nav outlines/current owners/packages preserved.
Commands/cwd/isolation/results: repository cwd, PowerShell7/console4.7.2. Final
anchor case104604 PASS53330 assertions/7491 collision sweeps/32 routes. Required
crossing/NPC-world/item and affected Maris/recovery cases104142 pass. Their whole
reports retain subsequently repaired nav failures, never relabeled. Final repaired
map_navigation_checks104721 PASS3 cases/336373 samples/three rollback probes/eight
replacements/query p95=856us. All accepted cases exit0/diagnostics empty/source
unchanged, independently isolated APPDATA/LOCALAPPDATA/named primary/backup slots.
Stable import/parse pass; final live-source reference gate PASS1624/50 adaptations.
Evidence inspected: full station/source/elevation/facing/approach and door records,
continuous physical routes/dry footprints/LOS/overlap/negative water/barrier/bench/
occupied shelter probes, structured reports/logs/manifests/isolation/intended diff.
Final1218 game/tool fingerprint cb1e4386fc8cc003cfd22a62735be635f56a9888c45526c039796a31f960e123.
Decisions/limits: source stations/doors stay exact; civic routine approach0.1m north,
home hero return0.9m south, ally uses existing1m east arrival. Real bench remains
solid under self-body exclusion. Synthetic geometry/sweeps are labeled; dynamic
occupancy/movement and actual interiors/ordinary travel/render/native remain their
own tasks. Retained UID/overlap/nav timeout/wrong fixture-ID failures repaired.
All owned engines exited, no held input/editor/cleanup owed; Blender2664 preserved.
Blockers/unrun R006 criteria: none. No commit/push. Remaining R007-R016; every item
through R016 complete: no. Next eligible R007; consume measured home doorway and
return metadata, build its bounded room/nine stations and verify its own criteria.
Stop after R006; await separate user commit request.

R007 - Done 2026-10-09 UTC
Result and changed files: source-informed bounded MayorValeHome scene/map/resource,
nine exact anchors, reciprocal public home portals and safe persistent-party
arrivals; additive exterior door/return, local converter, home physical/rendered
checks and blocked-home fixture; necessary old catalog-count/portal/registry
assertions, home-only HUD directions, exact ledger/attributes/architecture and
[R007 acceptance](R007_ACCEPTANCE.md). Thirty-one intended paths; no activation.
Verified prerequisites/preserved user changes: clean target2625957d/source60c20eb2;
actual R005 qualified routes and R006 doorway/return/registry inspected. R001 gate
PASS1624/88 pins/ten refusals/53 exact adaptations; source/baseline pins preserved.
No baseline user changes; instructions/normal saves/packages/Blender2664 untouched.
Commands/cwd/isolation/results: repository cwd, PowerShell7/console4.7.2. Final
113551246-df5b9349 PASS10 cases: home5368/2586 continuous sweeps/25 routes,
save/primary-backup, required travel10 round trips/weather157/camera330 samples,
portal364/exterior53682/7491 samples and renderer125/28 captures. Earlier112953
PASS5 cases covers repaired catalog/application; accepted112707 routine-content848.
All accepted exits0/diagnostics empty/source stable; final1233-file fingerprint
9fb61c22de4bbbdf5bc4850219d689c7e2abb71fcdaf81af5ac840b40836c5e5.
Separate check/render APPDATA/LOCALAPPDATA/save groups and slots; no normal saves.
Evidence inspected: final structured reports/source manifests/isolated saves,
all28 images on three contact sheets plus full archive perspective80 image;
public WASD/E/P/+/-/Esc entrance, four stations/return/revisit and verified pause.
Decisions/limits: all walls/nine source feet/facing exact; bed south edge-.30m,
sideboard west edge+.25m repair measured capsule bottlenecks; attempted chair
repair removed. Arrival uses existing doorway pocket(0,0,-2)/(1,0,-2); R006
exterior return unchanged. Synthetic paired Vale bodies/storm/rollback/save probes
labeled; ordinary route has only nav guidance and public inputs. All retained
UID/nav/weather/count failures repaired; final south-exit HUD verified. No failed
whole run relabeled. No routines/private facts/duplicate Vale/inn/native expansion.
All owned Godot processes exited, no held input/editor/cleanup owed. Blockers/unrun
R007 criteria:none. No commit/push. Remaining R008-R016; every item throughR016
complete:no. Next eligible R008: inspect pinned inn/host/current doorway, deliver
Lantern Rest and actual Della access criteria. Stop here, await separate commit.

R008 - Done 2026-10-09 UTC
Result/changed files: bounded source-informed LanternRest map/script/scene/resource,
reciprocal inn portals/public door and original safe party arrivals; exact host
and one actual indoor Della, map-aware registry/adapter, narrow obsolete wording/
HUD; converter, physical/rendered/blocked-arrival checks and necessary fixed-contact
fixtures,74-record exact ledger/attributes/architecture.53 paths listed in
[R008 acceptance](R008_ACCEPTANCE.md). All source geometry/host feet unchanged.
Prerequisites/preserved work: clean target2c81026e/source60c20eb2, actual R005/R006
routes/door/returns verified; no user changes, source/instructions/normal saves/
packages/Blender2664 preserved. Repository cwd,PowerShell7,console4.7.2; separate
check APPDATA/LOCALAPPDATA/named slots,only each renderer pair shares one group.
Final173207 completed inn1981/942sweeps,Della738,gift355,People134,travel10roundtrips,
environment157,NPC-world10130 before runner session interruption. Whole report
stays unfinished. Resumed173612 PASS10(engine/parse,anchors54016/7493samples,
NPC04/06/07/08,integration93,rendered write108/21/read22/3) on identical1248-file
fingerprint fec442fd426f3acd511937ffab3b56d18f9227ac55f2b0925c9f330d6bdc096a.
Every accepted case exit0/no diagnostics/stable source. Exact primary/backup and
separate-process GUI whole durable/forecast restore. Reference-complete PASS1624/
88pins/74adaptations/ten refusals; derivative --check passes19exact colliders.
Additional content/asset/map/social/fishing/routine/save regressions pass individually;
failed reports retained and affected failures repaired/rerun. Evidence inspected:
structured results/logs/manifests/saves,all24final captures on two sheets,earlier24/
full host perspective80. Ordinary affinity0 entry,talk/close,real flower gather,
reentry/preference/gift/close,GUI Save/Load,physical return; both projections/three
zooms/verified pause. Synthetic storms/capsules/unsafe-arrival probes labeled.
No geometry repair; strict schema8/content1/existing owners/social activation and
deferred room branch preserved. Paid lodging/booking/sleep/morning/routines stay
unavailable. No native/natural full-day claim. All owned Godot exited,no held input/
editor/cleanup owed. Blockers/unrun R008 criteria:none. No commit/push; separate
instruction follows review. Remaining R009-R016; every item throughR016 complete:no.
Next eligibleR009:physical same-map movement/bounded occupancy using R002/R006 and
pinned movement/wait/repath constants. Stop before successor.

R009 - Done 2026-10-09 UTC
Result/changed files: RoutineMovement/RoutineOccupancy and UIDs, dynamic existing
NPC wrappers/root party injection, removal of retired bake holes, fixed world
Maris furniture, physical/occupancy/render checks; necessary body/static-audit
and compact portal/spawn fixture assertions, exact ledger/attributes/architecture.
27 intended paths in [R009 acceptance](R009_ACCEPTANCE.md). No schedule activation.
Prerequisites/preserved work: clean target9e4521c/source60c20eb2; actual R002/R006
catalog/anchors/navigation verified. Source/user instructions/geography/schema8/
content1/normal saves/packages/Blender2664 preserved. Scoped reviewed shell works
around sandbox setup error; no automatic approval rejection or extra approval.
Repository cwd,PowerShell7,console4.7.2; isolated per-check R009 APPDATA/LOCALAPPDATA/
save_group/named primary-backup slots, separate renderer group. Final181351610
PASS14 import/parse/required and affected cases, all exits0/forbidden diagnostics
empty/source stable;1258-file fingerprint
bc60cc4228e5fb3b17acb95c1a1e64e75e336bf9febfd8a77c5dc3bc7408e8bc.
Movement1363/412samples/18legs/all eight bodies; occupancy311/opposing exact repeat/
hero-ally/barrier/narrow-wide door/cancel-unload; NPC-world9884/9757samples,
anchors51230/7095sweeps,inn1997/950sweeps,asset839,render31/6captures. Required
movement-camera/companion/interaction/recovery and isolated restores pass. Live
reference gate PASS1624/88pins/74exact adaptations/ten refusals; original before-
hashes/source pins/reasons retained. All final six captures and full perspective
walk inspected; both projections/planted feet/exported walk-idle/actual-foot
public E,J,Esc holds and physical resume. Synthetic commands/party setup labeled.
0.5s wait/two repaths/1.5s block, typed no-path/blocked/disposed, no per-frame path
query, no attacks/teleport/ghosting/new durable fields. Maris one counter/person,
bench/gear exact world transforms; static audits retain terrain/furniture while
live-body blocking has dedicated actual mover evidence. Failed UID/nav-height/
staged transforms/civic occupancy/stale compact-static assumptions retained and
repaired/rerun; first ledger report path reused with exact failed stdout retained.
All owned Godot exited,no input/editor/cleanup owed. Blockers/unrun R009 criteria:
none. No commit/push; separate instruction follows review. Remaining R010-R016;
every item throughR016 complete:no. Next eligibleR010:group/cross-map executor and
bounded night reconstruction/sourceINT-064 regression. Stop before successor.

R010 - Done 2026-10-09 (America/Vancouver and UTC)
Result and changed files: root-owned injected transient move/wait/action/speech
execution, qualified world/portal metadata, atomic assignments/cancellation,
physical loaded door legs, finite offscreen travel and one safe active arrival.
Detached restore staging and scene rollback/rebinding preserve actual feet/timers.
Exactly27 intended paths listed in R010_ACCEPTANCE.md; default activation R013.
Verified prerequisites and preserved user changes: R003/R004/R007/R008/R009 APIs
and evidence inspected; clean target4b9d45d/source60c20eb2, empty index/no baseline
user changes. Source, instructions, geography/room geometry/content/art/schema8/
content1 and existing clock/social/item/recovery/party/save owners preserved.
Commands/cwd/isolation and actual outcomes: repository cwd,PowerShell7,explicit
Godot4.7.2 console/GL960x640,bundled Python3.12.14. Final194406532 PASS7 cases:
executor71/cross-map3495/process writer20/reader30/render47/7 captures; distinct
22/00/06 primary/backup/full durable-forecast restart oracles.194742864 bounded
PASS3/495 assertions/20 max-clock samples/max31.246ms<50ms/64 actor-512 total cap.
193018784 clear morning PASS3/19 assertions/2 captures. All accepted exits0,
forbidden diagnostics empty/source stable. Existing movement/occupancy/NPC-world/
home/inn/save/travel/companion passed190708's first13 cases; its whole report stays
failed. Existing default game/check bytes unchanged; final lifecycle repair reruns
focused cross-map/restart checks. Every save group/slot/APPDATA/LOCALAPPDATA isolated
under R010 builds/testing; no normal save access. Live reference PASS1624/88pins/
74exact adaptations/ten refusals; original pins/before-hashes/prior reasons retained.
Evidence and inspected captures/artifacts: final seven-frame contact sheet, full
door/night-rest and clearer town-morning frame; both projections, actual visible
Edric/Helena rest, one civic Edric return, physical arrival reservations/rollback.
Synthetic initial clocks/party and deterministic deltas labeled; rendered clock
then unaccelerated with public viewport WASD/E/P/Esc and verified pause captures.
Decisions/compatibility changes/retained limits: sourceINT-064 original enum
unconfirmed/source not executed; mixed home-origin foot actually rejects physics.
Measured Helena near-side rest blocks Edric: physical archive yield/far-side first/
return repairs it without teleport/anchor/step edit. Occupied player return rightly
refuses; offscreen phase/timer now survive rollback and public finite wait/E retry
succeeds. Failed UID/preflight/count/party-lane/focus/optional-rest-dialogue/arrival
reports retained; unfinished185628 not relabeled. Extra rest-dialogue access is
explicit R011 interaction review, not a claimed R010 feature. No native/full-day/
presentation/default-activation claim. All owned Godot exited; no held input,
editor or cleanup owed; Blender2664 untouched. Final audit verifies exact27 paths,
1274 accepted game/tools hashes, all16 statuses/links, preserved content/pinned bytes,
unchanged HEAD/empty index/clean source/whitespace. Blockers/unrun R010 criteria:none.
No commit/push; separate commit instruction follows review. Remaining unfinished
IDs:R011,R012,R013,R014,R015,R016; every item throughR016 complete:no.
Next eligibleR011: bind routine dialogue/group leases/directives using R004 atomic
commands and R010 context; include far-side rest interaction access review.
Stop after exactly R010, before successor.
Final acceptance refresh: unchanged sparse assignments stay inert (20 repetitions,
no revision churn/group-lane cancellation); continuous loaded civil midnight keeps
both rest cursors/feet and consumes exactly19s of wait.194105's mistaken midnight
day-index test retained and corrected to minute wrap; existing clock day begins
10:00, no second calendar/semantics added. Refreshed194406532 combined PASS7,
194742864 bounded PASS3/max31.246ms and seven fresh inspected captures supersede
earlier accepted runtime; final audit-midnight owns current exact bytes.

## R011 completion record (2026-10-09 UTC)

Exactly R011 Done; every criterion passes. [R011 acceptance](R011_ACCEPTANCE.md)
owns scope, commands/isolation, source decisions, failed attempts and seven inspected
captures. Actual instance/routine/step group leases, eligible step/default/ordinary
entry order and strict staged resume/jump/end/event routing delivered. Only two
public Helena nodes/five real choices/practice fact activated after current social
overlay; gifts/milestones/Della indoor text/private gates/schema8/content1 retained.
Moving night group cannot cancel its leased leg; both loaded contacts/feet/timers
hold across10AM day rollover, independent assignments continue, close reconciles
once from actual feet. Ordinary prototype owner cancellation preserved.
Final203724924 PASS14; dialogue69/directives128, required rules/UI/social/gift/
recovery plus interaction/executor/Helena and distinct-process actual GUI Save/Load
primary/backup/full durable-forecast oracle. Seven fresh inspected frames include
far-side Edric access and both projections via bounded public input. Additional
content/People/integration/NPC-save/cross-map/reconstruction/routine/social-save
cases passed individually in retained202707 failed whole report; scoped final
repairs supersede affected behavior. Final source stable1285 files; only later
reference-tool audit change; live reference PASS1626/88pins/79exact adaptations/
ten refusals; original source/derived/before-hashes/reasons preserved. Conversion
PASS67 files; catalog changes only approved eight coverage entries. All failures
retained, no native/full-day/default-activation/art-promotion claim. No owned Godot,
held input/editor or cleanup owed; Blender2664 preserved. Blockers:none.
Remaining unfinished:R012,R013,R014,R015,R016; every item throughR016 complete:no.
Next eligibleR012 action/speech presentation; stop before successor. Separate
user follow-up authorizes the successful R011 commit after review. No push/R012.


## R012 completion record (2026-10-09 UTC)

Exactly R012 Done; all presentation criteria pass. [R012 acceptance](R012_ACCEPTANCE.md)
owns18 exact paths, commands/isolation, mappings, inspected images and retained
failures/limits. Production Edric/Helena action variants mount once per wrapper;
scene-owned public speech follows existing executor timers, facing and root holds.
Achieved motion owns walk; pause/focus preserve action pose, unsafe holds hide text/
props and resume same step. Active unload/cancel/disposal clear output; optional
unmapped actions use exported idle. No rewards/geometry/source/schema change.
Combined210402630 PASS10: action1814/asset839/camera330/movement1363/executor71/
dialogue69/render60 with13 inspected captures/two sheets. Final210904390 PASS3,
presentation94, active speech unload/accessory disposal and typed Tess-blocked
full river leg. All accepted exits0/no diagnostics/source stable; isolated per-case
APPDATA/LOCALAPPDATA/primary-backup slots, no normal saves. Runtime/render/assets/
reused checks retain exact combined accepted bytes; final1291-file fingerprint
8b7a473dd9a4b0b4556ad116b2e32948515ad718e92bed5da61a9cc1ef90a9a2.
Live reference PASS1626/88pins/80adaptations/ten refusals; original pins/before-
hashes/prior reasons retained. All13 images inspected, full far/near and archive
speech readable, planted feet/props; both projections and real0.8/1.15 public zoom.
Synthetic clocks/party and one-metre river art precursor labeled; later physical
steps/timers unaccelerated, public projection/zoom/J/Esc and verified pause.
Retained full-route failure identifies stationary Tess npc-06 at(6.6001,0,4.6001),
bounded BLOCKED/two repaths. R013 owns ordinary route/contact integration; this
negative case is explicit, not a successful full-route claim. R012 blockers/unrun
criteria:none. UID/encoding/boundary/camera-loop/short archive observation/incorrect
party-blocker assumptions retained and repaired; no failed whole run relabeled.
All owned Godot exited; no held input/editor/cleanup owed; Blender2664 preserved.
No commit/push/default activation/native/full-day claim. Remaining unfinished:
R013,R014,R015,R016. Every item throughR016 complete:no. Next eligibleR013; integrate
catalog and resolve/verify Tess obstruction. Stop before successor; separate user
instruction follows review for authorized successful-task commit.


## R013 completion record (2026-10-09 UTC)

Exactly R013 Done; all acceptance criteria pass. [R013 acceptance](R013_ACCEPTANCE.md)
owns30 intended paths, commands/isolation, exact25 coverage, retained failures and
19 inspected captures. Default root/world/dialogue share one owner; actual-map
contacts/hints and guarded ordinary Chat retain identities/group leases and
existing gifts/quests/party. Full Tess-blocked river leg now reaches unchanged
endpoint with one rendered physical repath; no geometry/anchor/source/speed change.
Matrix2610/25 routines/eight full physical Ivo/Vale/river plans; required NPC/social/
fishing/playable/recovery and affected movement/occupancy/dialogue/directive/UI/
gift/executor/cross-map checks pass as documented stable accepted cases. Failed
whole reports remain failed. Final214625899 PASS3; fresh ordinary101/16 captures/
94.54 active seconds earns introductions, gather/gift, ledger flag and both room
returns; separate synthetic river16/3 captures. All accepted exits0/zero diagnostics,
source stable/isolated primary-backup groups and APPDATA/LOCALAPPDATA, no normal saves.
Deferred Edric fishing fact remains unsaved synthetic selector input; no forged
save/source gate enabled. All original content/art/geography/schema8/content1 and
instructions preserved. Live reference1626/88pins/81 exact adaptations/ten refusals;
original before-hashes/prior reasons retained. Final game/tools1297 accepted bytes
remain exact except later offline ledger/owner gate; final audit records scope.
No owned Godot/held input/editor/cleanup owed; Blender2664 preserved. Blockers or
unrun R013 criteria:none. No commit/push; separate user instruction follows review.
Remaining unfinished:R014,R015,R016; every item throughR016 complete:no. Next eligible
R014 integrated restart/rollback/retry and runtime measurements; stop before successor.

R013 commit follow-up: user reviewed successful acceptance and explicitly authorized
the task commit. Commit turn verifies/stages only30 intended paths, including
acceptance/exact coverage/checklist/handoff. Git and local R013 commit-audit.json
record the result. No push or R014 work; R014-R016 remain Pending.


R014 - Done 2026-10-09 UTC
Result: default-root distinct-PID restart, rollback/retry, ten-cycle ownership and
focused rendered scheduling/path/reconstruction/memory checks; bounded companion
lease repair, actual-map social fixture and immutable-condition/assignment sampling
optimization. Exact17 paths and all methods in R014_ACCEPTANCE.md.
Prerequisites: R013 production director/25 routines/eight people verified. Baseline
HEAD d84192a0 clean/empty index; source60c20eb2 untouched; no user changes overwritten.
Final command/cwd/isolation: repository root tools/run_checks.ps1 -Task R014,
6 named integration/preservation checks,3 writer/reader pairs, rendered profile;
20261009-222953740-f71896fa PASS15/15, exact source fingerprint5178e0bf/1303files,
isolated named primary/backup and APPDATA/LOCALAPPDATA under builds/testing/R014.
Lifecycle783 including evidence write; writer51992/reader69760 exact complete state,
no duplicate effects/cursors. Ten cycles exact per-room ownership, growth4.984MiB.
6000 focused samples, eight live movers,23 qualified query segments; final peak
p952.556ms, frame p959.168ms/p9913.525ms, draw363; path maxp95.464ms,
reconstruction max2.079ms/15 total transitions, huge tick.412ms.
CONTRACT allowed explicit measured scheduler ceiling revision2->4ms after
3.319/3.659ms before and2.985/3.305ms optimized; original2ms failures/pins retained,
all other budgets unchanged. Eight focused routine checks also passed on identical
runtime owners; reference audit1626/25routines/21anchors/88pins/82adaptations/10refusals.
All failed reports/parse and helper repair history retained; six paused synthetic
PNGs inspected. No ordinary full-day/native proof claimed. Schema8/content1,
source pins/geography/art/save/social/item/party owners preserved.
Final diff/link/status/dependency/index/source/process readback: final-audit.json.
No blockers/unrun R014 criteria. Owned engines/windows exited; no held input or
cleanup owed, unrelated Blender preserved. No commit/push; await separate user
instruction after review. Remaining R015,R016; all through R016 complete:no.
Next eligible R015: ordinary600-active-second full day/social/recovery rendered
walkthrough and its deterministic branch matrix. Stop after exactly R014.


R014 approved budget / authorized commit follow-up
User approved the4ms scheduler p95 ceiling after the measured FPS/cadence review:
"yes, lets accept that and continue". Original2ms noncompliance/failed evidence and
original R001 pins preserved; combined-slice/synthetic-fixture limits unchanged.
Commit only17 reviewed task paths, including tracked R014 acceptance evidence,
checklist/handoff; ignored raw evidence retained locally. All1303 accepted source
bytes and task hashes were reverified unchanged before this approval record.
Git and local docs/evidence/R014/commit-audit.json record commit/hash/index/tree
verification. No push or R015 work. Threading investigations deferred.
Remaining R015,R016; every item through R016 complete:no.

R015 - Done 2026-10-10 UTC
Exactly one task completed under user-approved Ivo movement/waits/conversation and
Edric/Helena authored action/speech correction. Ten intended paths and all retained
failures/results in [R015 acceptance](R015_ACCEPTANCE.md). Real Helena earned intro
plus ledger Save receipt rejection repaired narrowly; strict tamper/opposite-intro
regression passes. Original schema8/content1/source/content/geography/assets and
R0144ms approval/original2ms misses/measurement limits/threading deferral preserved.
Final005834284-09fd668e PASS4: writer17464/reader12208,236/28 assertions,50 viewed
captures;681.722769 active/687.976 observed wall seconds, actual night/rest/breakfast/
morning, Ivo14.999771m circuit, two rooms/returns, earned gift/facts/ledger, full
six-effect Maris recovery with ally and bridge/ford, GUI Save/new-PID Load exact
complete typed primary/backup/forecast and physical Maris/Della remembered revisits.
Stable earlier case checks: NPC-save568/510 refusals, routine-save213, directive139,
exact25 matrix2610, integrated synthetic restart82/98. Prior whole report remains
failed for corrected driver backup assumption; final rerun fixes it. All accepted
case exits0/zero diagnostics/source stable, isolated saves/app-data. Static reference
1626/88pins/82 exact adaptations/ten drift refusals; final audit verifies scope,
links/history/index/bytes. Simultaneous speech overlap recorded; solo lines readable.
No Godot/held input/editor changes/cleanup owed; unrelated Blender preserved.
Blockers/unrun R015 criteria:none. No commit/push; user separately instructs commit
after review. Remaining:R016; every item throughR016 complete:no. Next eligibleR016
fresh Windows/native packages; stop before successor.
R015 authorized successful-task commit follow-up (2026-10-10 UTC)
User reviewed the successful R015 result and explicitly instructed this commit.
Include only the ten reviewed task paths; verify accepted game/tools bytes and
staged blobs before committing. Retain ignored raw evidence locally. Git and
../evidence/R015/commit-audit.json record the verified commit/tree/index outcome.
No push or R016 work. R016 remains the only unfinished task; all throughR016
complete:no. R0144ms approval/original2ms misses/measurement limits and deferred
threading remain unchanged. Historical implementation-turn no-commit statements
above retain their original meaning.
Commit portability correction: initial ten-path staging normalized the validated
ordinary driver (work SHA256f910c600... vs stagedd27f2396...). Added exactly one
root .gitattributes driver/UID -text/-eol rule, making commit scope eleven paths.
Exact existing attribute adaptation retains original before-hash, previous accepted
7f9c203d... hash, all earlier rules/reasons and immutable pins. Only that offline
ledger changes inside accepted game/tools source; every tested game/other tool byte
remains exact. Restage verifies exact blobs. Static reference audit reruns; gameplay
checks are not repeated for Git attributes/offline ownership metadata.
First restage reused the cached normalized blob. Explicit path-scoped
git add --renormalize applies the new exact-byte attribute rule; all tested
game bytes stay unchanged. Commit verification refuses any remaining mismatch.
