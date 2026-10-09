# Day clock and NPC routines migration contract

Prepared 2026-10-08, America/Vancouver. R001 reference acceptance completed
2026-10-09 UTC; runtime implementation not started.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.

## Outcome and scope

Deliver physical, data-driven daily routines for the eight existing villagers, with walking, work/fishing actions, timed speech, group assignments, real fact/action/weather conditions, routine dialogue and cross-map travel. Reuse the delivered clock/weather. The earlier investigation's missing-clock claim is stale.

Roster: npc-01 Edric, npc-02 Helena, npc-03 Maris, npc-04 Harlan, npc-06 Tess, npc-07 Ivo, npc-08 Celia and npc-14 Della. Current source has 39 routines for 15 people; filtering to routines whose every participant is in this roster yields exactly the quoted 25. Exclude the other seven people/14 routines.

Selected IDs:

- celia-repairs-day; celia-repairs-evening.
- della-inn-day; della-inn-evening.
- edric-afternoon-river-notes; edric-afternoon-rounds; edric-evening-fishing; edric-evening-rain-shelter.
- harlan-docks-day; harlan-docks-evening.
- helena-afternoon-archive; helena-afternoon-ledger-review; helena-afternoon-moonflower-records; helena-evening-archive.
- ivo-docks-day; ivo-docks-evening.
- maris-chandlery-day; maris-chandlery-evening.
- tess-store-day; tess-store-evening.
- vale-breakfast; vale-evening-home; vale-midday-briefing; vale-morning-work; vale-overnight-home.

These use 21 distinct map-qualified move targets: 11 in alderwake, nine in mayor-vale-home, one in lantern-rest. Include two bounded source-informed 3D interiors and reciprocal town doors as necessary work: Mayor Vale home for archive/breakfast/rest and Lantern Rest for Della. They require real dry collision/navigation, party arrivals, routine stations, readable furnishings, camera/occlusion and stable indoor lighting. They are not prerequisites to defer indefinitely.

Exclude Hall/fair/Orchard/starter-home migration, paid lodging, room entitlement/sleep, ceremony/campaign progression, shops/economy, additional villagers/companions/relationships, player-model replacement, autosave, web/mobile delivery and bespoke editors. Della's building access does not enable booking/sleep choices.

## Authority and baseline

- Workspace: D:/development/game-dev-blender; read workspace AGENTS.md and any applicable nested instructions.
- Repository: D:/development/game-dev-blender/returning-fair-prototype; application game/, res://app/game_root.tscn; typed GDScript/GL Compatibility.
- Read-only source: D:/development/game-prototype-2.
- Inspected target HEAD e10d13edd6035aeb3bac4cbaded6f82b756f8e39; source HEAD 60c20eb2816e7271fb84afaba286af006ebe3ccf. Both initially clean. Recheck current work; these are observations, not reset targets.
- Geometry: [map contract](../map-migration/CONTRACT.md), snapshot alderwake-f4630f9-m002, game/content/maps/alderwake_layout.json. Do not refresh exterior geography from live source.
- NPC identities/graphs/art: [villager contract](../villagers-dialogue/CONTRACT.md), game/content/npcs/catalog.json and tools/npc_migration/reference/.
- Existing integrations: [social state](../gifts-friendship-people-journal/CURRENT_STATE.md), [foraging state](../foraging-items-backpack/CURRENT_STATE.md), [fishing state](../fishing/CURRENT_STATE.md), [environment contract](../weather-lighting/CONTRACT.md).
- Current schema7/content1 and strict current-format-only policy: [architecture](../ARCHITECTURE.md), game/core/save_codec.gd. Older feature handoffs contain historical schema statements; current architecture/code win.

Current target already includes a 600-second day, saved forecast/light state and heavy-rain query; eight fixed public NPC contacts with rigs/portraits/dialogue; persistent conversations/events/gifts/friendship/People journal; backpack/foraging/fishing; manual pause Save/Load; two persistent party actors and shortened Maris recovery/combat. N001-N018, G001-G009, F001-F010, FS001-FS008, W001-W010 and M001-M019 report delivery in their handoffs. Reverify needed capability; this plan did not rerun their acceptance. Their selectors do not govern this workflow.

Missing integration: NpcRegistry fixes all eight outdoors; NpcWorldAdapter uses static contact bodies/service_outlines baked into exterior navigation and forces zero locomotion. PrototypeLocation has one destination for every travel interaction. No routine director/executor or Mayor-home/inn target location exists.

## Source pinning and mappings

R001 delivered [local pins](../../tools/routine_migration/reference/manifest.json),
[mappings](../../tools/routine_migration/reference/mappings.json),
[coverage](../../tools/routine_migration/reference/coverage.json),
[vectors](../../tools/routine_migration/reference/vectors.json) and
[acceptance](R001_ACCEPTANCE.md).88 source authority inputs at60c20eb2; exact25 IDs,
eight people and21 targets. Relative source paths/revisions/SHA256 are recorded.
Runtime/export must not require source checkout, Flutter, private profiles or
historical candidate maps. Refuse unexplained drift; owning tasks document intentional
target changes with before/after hashes, never silently refresh source pins.

Source inputs to pin/read:

- assets/data/routines/catalog.json and the 25 selected documents; selected assets/data/npcs/<ID>/{runtime,dialogue,visuals}.json; assets/data/world_events/catalog.json.
- assets/maps/{project,mvp_world,mayor_vale_home,lantern_rest}.json, required world-object definitions and grouped portal dependencies.
- lib/game/routines/ models/codecs/resolver/validator; lib/game/npc/{npc_routine_director,npc_routine_executor,npc_component,world_map_npc_routine_anchor_source}.dart; relevant navigation/portal adapters, clock, runtime state/controller and player_event_journal.dart.
- docs/npc-routine-schema.md, npc-routines-production.md and INT-064 in docs/returning-fair-integration-checklist.md.
- test/game/routines/{routine_catalog_test,routine_resolver_test,routine_content_validator_test,production_routine_content_test}.dart; test/game/npc/{npc_routine_director_test,npc_routine_executor_test,npc_routine_diagnostics_test}.dart; test/game/world/npc_routine_production_acceptance_test.dart.

Keep routine/step/participant/source anchor IDs. Source alderwake maps to
prototype-alderwake; finalized room IDs are prototype-mayor-vale-home and
prototype-lantern-rest. Retain prototype-tollworks/current arrival identities.
Exterior origin(704,576), home(256,384), inn(448,672),32 source units/metre.
For each map X=(sourceX-localOriginX)/32,Z=(sourceY-localOriginY)/32. Exterior Y
comes from pinned terrain; indoor Y=0 is new floor proposal pending room physics.
No exterior spawn offset indoors. Group pivots multiply32; rotate all rectangle
corners before translation. Source anchor deltas remain zero; four reciprocal
doors/nine directed map-pair chains are reference-only until their owning tasks.

R001 audits all 21 targets, doors, routes and current footprints. Prefer pinned anchors; newer absent source anchors require additive target-local mappings and measured clearance. No exterior regeneration or silent closer anchor to hide a route bug. Record before/after/reason for unavoidable adaptations.

Preserve existing NPC/social activation and source pins. R011 narrowly restores/activates public routine nodes/directives and corrects obsolete location wording; never replace the entire graph catalog with an older export. Della moves indoors without a duplicate exterior contact. Maris keeps one person/counter and npc-03-counter quest/service identity; no automatic recovery.

## Clock, conditions and selection

EnvironmentClock is the only clock: 600 active seconds/day; fresh day0/progress0 is 10 AM; display midnight differs from the 10 AM day-index wrap. Preserve day_index 0..3650, finite progress [0,1), seed/lights and existing active-time bounds. Clear daily suppression on authoritative day-index rollover, not midnight. No offline/wall-clock progression, sleeping or accelerated ordinary play.

Current session time advances during dialogue, journal/backpack and focus loss, and freezes for pause/travel/load/retry. Preserve it. NPC motion/actions/speech respect pause/modal/focus/death/travel holds. Dialogue leases its atomic group; defer conflicting reassignment for that group until closure, then reconcile clock/conditions once with defined directive ordering. Visible held actors resume from real current feet; never teleport across a loaded map to catch up. Fresh arrival/load initialization is separately defined.

Pure selection: inclusive start/exclusive end, overnight windows, all conditions AND, priority descending then routine ID ascending. At most one assignment/person; accept a multi-person candidate only when all participants are free. Rejection precedence: suppression, outside window, condition failure, participant conflict. Read real learned facts/flags and bounded event counts/recency; inventory is not event history.

Effective events are authored active IDs union weather-derived conditions. Only thunderstorm contributes derived heavy-rain; ordinary rain does not. Authored events remain separate from forecast; clearing authored heavy-rain cannot clear a concurrent derived storm. Event commands do not change weather/water geometry. Pin source event allowlist and fixture-only versus production exposure.

Replan on actual window/day/condition/command/recency-expiry changes, not by restarting unchanged plans every frame. Recency must expire even without another player action. Plans include elapsed time from window start. R010 specifies bounded deterministic reconstruction and documents corrections to source defects.

## Movement, maps and ownership

Immutable catalogs own definitions/qualified references; session owns durable routine facts; root-owned director owns transient assignments/executors/leases; scene wrappers/presenters own physics/navigation/visuals. UI submits commands/displays snapshots. Proposed game/features/routines/ and game/content/routines/ hold focused typed components; do not build a global bus, behavior editor or NPC combat hierarchy.

Source movement is 64 units/second = 2m/s here, blocked wait 0.5s, maximum repaths two. R001 pins constants; deviations require measured reasons. Target capsule/terrain clearance controls fit, not source's smaller footprint alone. Drive animation from achieved speed. NPCs do not inherit attacks/dodge/damage or companion catch-up/recovery teleports.

Replace obsolete static NPC bake obstacles with dynamic footprints, preserving real counter/furniture/terrain collision. Include hero/ally/NPC occupancy and station reservations. Bounded deterministic yield/wait/repath ends in typed failure; no phasing, infinite search or visible relocation to conceal failure. Release reservations on cancel/unload/load/rollback.

Portals carry explicit source/destination/arrival IDs. NPC route queries/transfers never call player WorldHost travel or change party/camera/player location/quest state. Loaded NPCs visibly reach source door before departure. Offscreen legs may resolve directly only through a validated directed chain; do not simulate scene trees/physics for all unloaded maps. Materialize exactly one safe wrapper on the active map; no hidden stale interaction, collider, signal or navigation region. Reassignment on loaded maps starts from actual feet; scene replacement failure restores consistent previous bindings.

Source INT-064 remains Pending: Edric can fail offscreen overnight arrival under reconstruction. R010 must diagnose initial-map/origin/occupancy/routes, distinguish ordinary time from synthetic seek/load at 22:00/midnight/06:00, prove home rest/morning return and retain the regression. Do not copy or teleport around the failure. No-selected/failed routines retain safe last positions and ordinary dialogue where policy allows; no invented routine/reward.

## Dialogue, actions and speech

Interaction entry order: eligible current-step entry, routine default, ordinary graph. Ineligible preferred entry falls through; allowDialogue=false blocks. Lease all loaded group participants before overlay publication. Close/cancel defaults to resume. Validate bound context for resume, jumpToStep within declared participant plan, endRoutineForDay, activateWorldEvent and deactivateWorldEvent. Stale tokens, wrong person/instance/routine/step and reentry are inert. Apply directive while leased, then reconcile once on close.

Conversation flags/facts/affinity and directive-owned durable changes publish consistently. No half-applied state, repeated reward or fabricated event. Preserve manual-save exclusions and Maris ordinary/recovery switching. Unchosen directives never run; zero affinity cannot block ordinary contact/recovery/essential service.

Wait/action/speech timers use bounded active deltas. Speech is public authored text, readable at gameplay scale, expires and clears on cancel/unload. Diagnostics expose IDs/enums, not private text. Edric action grants no fish; Helena action grants no fact/item/quest. Existing npc-01-actions.glb/npc-02-actions.glb are review variants: R012 explicitly promotes suitable clips/accessories via production mappings after validation. Do not swap rigs every frame, animate walking in place or start action while moving. Others use documented declared-idle fallback; invent no action sheets. Preserve facing, feet, hold poses, transitions and camera/canopy readability.

## Save and preservation policy

R004 adds only validated authored active-event/current-day suppression facts and any genuinely required minimal fact found in R001. Reuse environment/conversation/event-memory fields. Do not save NPC positions, paths, cursor/step timers, leases, speech, animation or occupancy; reconstruct safely.

Check actual version before choosing the next schema, update complete current fixtures/consumers together, and support only that current schema/content. Reject old/newer/malformed before live swap; no migrations/missing-field defaults or invented history. Keep detached validation, temporary writes, backup recovery, failed-restore rollback and arrival-anchor player restoration. No autosave/exact-player-position-resume change.

Preserve geography/pins/crossings, aim/canopy/camera, weather/lights, item/rod conservation, fishing, gifts/People, separate companion trust/strike, party health/combat/retry, Maris effect order and Tollworks/future gates. Update fixed-contact tests to assert real scheduled access/uniqueness rather than deleting assertions or keeping invisible duplicates. Preserve canon/public-private boundaries.

## Acceptance gates

Every task has focused correctness/integration tests before Done; later gates do not postpone basic correctness. Proposed tools/checks in CHECKLIST do not exist until implemented. Label synthetic seek/placement/conditions, direct fixtures and generated route guidance; they are not ordinary movement or natural-weather proof.

R001 declared [numeric budgets](../../tools/routine_migration/reference/budgets.json)
before runtime implementation: scheduler plus eight loaded NPC p95<=2ms, path query
p95<=5ms (established target bound), unchanged unobstructed leg path requests/frame0;
0.5s blocked wait/two repaths, continuous blocked limit1.5s. Max-clock reconstruction
<=50ms,64 transitions/actor512 total, no day-by-day replay. One active room/region,
one wrapper/present NPC; after ten town/home/inn cycles/equal2s settling, owned
objects/reservations/listeners return exactly to baseline and working-set growth
<=64MiB. Retain whole-frame p95<=max(16.67ms,paired baseline+4ms),p99<=25ms,draw p95<=500.
Current Core Ultra9 185H/RTX4070 Laptop, Compatibility960x640 settings and historical
N017 fixed-contact ABBA/query baseline recorded; moving-runtime budgets unmeasured.
R014 samples>=1000 active updates after1s warmup, queries10 warmup+100/leg and
max day3650/progress0.99/huge finite delta, with failed evidence retained. Any
justified budget revision requires measured before/after record. Historical static
statistics do not prove moving-NPC performance. Basic termination/ownership gates
already belong R009/R010, not postponed to profiling.

R014 measured revision (original R001 budget pin retained): scheduler plus eight
loaded NPC p95<=4ms. Before optimization:3.319/3.659ms; after immutable-condition
cache/assignment-only sampling:2.985/3.305ms on the same machine/settings, with
physical/rig work p95 1.334/1.431ms and full-frame p95<=14.368ms. The original2ms
additive estimate came from fixed idle contacts and had no moving physics sample.
The4ms bound covers actual eight-body ground-support/collision/occupancy and
visual-owner work without weakening safety, path-request or frame limits. All other
R001 numeric budgets remain unchanged. See R014_ACCEPTANCE.md for raw before/after
reports and final remeasurement; a failed original-budget report stays failed.

R015 observes at least 600 active seconds without acceleration: night/rest/morning and solo/group departures/returns, both interiors, real learned-fact/gather/gift conditions, Helena outcomes and full existing recovery with river crossings. Deterministic matrices cover every routine/directive and thunderstorm shelter separately; random weather must not become an indefinite native gate. Claim a natural storm only when actually observed.

R016 builds fresh local Windows validation/release with routine/room/action assets and current schema, pack exclusions and outside-checkout startup, then ordinary native routes, conversation/gift/recovery plus GUI Save/quit/new-process Load/revisit. Isolate saves and preserve previous packages/override by verified archive before local promotion. No publication. Historical packages/build-only/debug-bridge evidence cannot certify routines.
