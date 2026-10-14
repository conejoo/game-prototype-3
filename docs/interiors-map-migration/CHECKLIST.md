# Interiors, fairground and remaining maps execution checklist

Goal: deliver all nine authored map locations in existing Godot game, preserving current gameplay; public normal access and isolated Orchard inspection.
Target: D:/development/game-dev-blender/returning-fair-prototype; application game/.
[CONTRACT](CONTRACT.md) owns scope, mappings and preservation. This checklist alone owns status. [CURRENT_STATE](CURRENT_STATE.md) owns continuation; [AGENT_PROMPT](AGENT_PROMPT.md) supplies invocation.

## Selection and completion

All tasks start Pending. Resume the single In progress task first. Reassess Blocked work when its recorded blocker changes; unresolved blocks exclude it and dependents, not independent ready branches. Otherwise choose the lowest-numbered Pending task with verified Done dependencies and actual prerequisite capabilities/evidence. Reconcile ambiguous statuses first. If nothing ready, record exact blockage/dependencies and safe next action; if all Done, stop.

Complete exactly one task per invocation including its checks/repairs and handoff; stop before successor. Mark In progress before implementation. Done requires evidence for every criterion. Update CURRENT_STATE on interrupted/failed sessions too. Protect R016 concurrent work as CONTRACT specifies; IM001 is first ready reference task, not permission to overwrite its files or declare native delivery complete.

## Dependency table

| ID | Status | Dependencies | Observable outcome |
| --- | --- | --- | --- |
| IM001 | Pending | none | Pinned nine-map inventory, mappings and acceptance baseline |
| IM002 | Pending | IM001 | Deterministic target-local layout extraction/validation |
| IM003 | Pending | IM002 | Access policy and isolated labeled map-preview mode |
| IM004 | Pending | IM002 | Reusable 3D interior kit and assembly conventions |
| IM005 | Pending | IM003, IM004 | Public Hall with reciprocal town door |
| IM006 | Pending | IM003, IM004 | Starter-home inspection room and safe return |
| IM007 | Pending | IM003, IM004 | Existing Mayor home reconciled with selected source detail |
| IM008 | Pending | IM003, IM004 | Existing inn reconciled with selected source detail |
| IM009 | Pending | IM002, IM004 | Full authored Tollworks physical candidate |
| IM010 | Pending | IM003, IM009 | Expanded Tollworks runs existing recovery/combat |
| IM011 | Pending | IM002, IM004 | Fair candidate terrain/bridge/both approaches |
| IM012 | Pending | IM003, IM011 | Readable public fairground, lights and distinct returns |
| IM013 | Pending | IM003, IM004, IM010 | Outer Orchard preview, closed normal gate and safe return |
| IM014 | Pending | IM013 | Inner Orchard/House of Echoes preview route |
| IM015 | Pending | IM005, IM006, IM007, IM008, IM010, IM012, IM014 | Integrated nine-map lifecycle, items, environment and hints |
| IM016 | Pending | IM015 | Cross-map save/restart/retry/rollback compatibility |
| IM017 | Pending | IM015 | Measured performance/camera/repeated-travel bounds |
| IM018 | Pending | IM016, IM017 | Ordinary normal/preview walkthrough and visual coverage |
| IM019 | Pending | IM018 | Fresh Windows packages and native delivery |

Map branches are independent after real shared prerequisites. IM016/IM017 are sibling gates. Ordered selection does not imply a single dependency chain or authorize parallel agents/shared edits.

## IM001 - Pin sources, remaining work and acceptance

- Inputs/prerequisites: CONTRACT inventory, source/target bytes, existing pins and R007/R008/R015/R016 artifacts. Inspect current user changes/concurrent ownership first.
- Outputs/allowed changes: proposed tools/location_migration/reference/{manifest.json,map_mappings.json,coverage.json,acceptance.json}: full hashes, selected public snapshots/dependencies, eighteen-edge mapping/aliases, anchor IDs, per-map coordinates/access, art/geometry deltas, budgets and exact target preservation baseline. Update verified workflow references.
- Preserve: read-only source, runtime/art/export, previous pins and R016 files/packages. No map activation, source regeneration or gameplay launch just to inventory.
- Acceptance: account for nine maps, three reused scenes, compact Tollworks and five absent scenes. Every selected record/dependency has retain/adapt/inert/exclude classification and owner. Resolve20-unit source art versus32-unit gameplay scale; verify grouped doors/counts; identify clearance conflicts without claiming safety. Record R016 status and exact runtime-start ownership gate.
- Checks/evidence: create proposed tools/location_migration/reference_checks.py for hashes, coverage, ID/reference/transform vectors and drift refusal including negative cases. Record source tests read versus run, complete identities, installed paths, baseline evidence/machine/settings. IM001 can be Done while recording an unresolved external runtime-start gate.

## IM002 - Extract validated layouts without changing live maps

- Inputs/prerequisites: IM001 pins/coverage and stable selected-path ownership; existing home/inn converters and exterior conventions.
- Outputs/allowed changes: proposed tools/location_migration/extract_layouts.py, target-local layout schema/candidate data and validation. Reuse home/inn data with reconciliation reports; leave exterior extractor untouched.
- Preserve: live catalog/scenes/current rooms, pins and gameplay. Candidate extraction never overwrites manual scenes/art or applies live-source town drift.
- Acceptance: deterministic check/regeneration; logical/fractional coordinate round trips, mixed grids/null erasures, grouped point/cell rotation, prop collision switches/polygons, lights/portals/facings correct. Reject unknown/duplicate/broken references and unsupported geometry before publication. Correct cleared-floor masks; render offsets never become physical depth.
- Checks/evidence: create proposed location_layout_checks.gd and extractor fixtures. Compare frozen source-semantic vectors/output hashes, with malformed/rotated-group/erased-floor/clearance negatives. Detached data is not ordinary gameplay proof.

## IM003 - Enforce access and add isolated map inspection

- Inputs/prerequisites: IM002 IDs/edges; current PortalBinding/PortalRoutes/WorldHost, save isolation and review-flag patterns.
- Outputs/allowed changes: narrow access policy, proposed --map-preview typed launch mode, visible label/selector/return control and separate preview primary/backup slots. Guard player/direct/load/NPC eligibility; initially select only existing installed rooms.
- Preserve: normal startup/storage, current public doors/recovery, transactional travel/party ownership. No stage/campaign rewards, arbitrary-coordinate console or future scene activation.
- Acceptance: normal Orchard/shortcut denial at every boundary; preview only installed reviewed arrivals/safe returns. Wrong-mode/stale/forged/foreign bindings reject. Preview cannot read/write/reset normal saves or mint normal unlocks. Input/modal/focus and failed selection preserve playable world. Label readable across resize/restart; normal UI has none.
- Checks/evidence: create proposed location_access_checks.gd, location_preview_checks.gd and preview process checks; reuse routine_portal_checks, location_travel_checks, environment_review_flag_checks. Verify actual selector UI, direct-load bypass refusal, both namespaces/backups. Preview jumps are setup, not route proof.

## IM004 - Build reusable interior kit and assembly conventions

- Inputs/prerequisites: IM002 layouts; accepted home/inn presentation/art pipeline; exact public floor/wall/furniture references and actor dimensions.
- Outputs/allowed changes: reusable wall/door/floor/furniture modules/materials and small assembly helpers under proposed art/location_migration/ and game/assets/locations/. Reuse accepted art; provide editable sources/exports where needed and review gallery.
- Preserve: actors/capsules/current room collision/stations/exterior art. Map-specific fair/Orchard/Tollworks hero props belong to map owners. No live-room replacement.
- Acceptance: stable metre/origin/material conventions, coherent furniture/doors at actual scale, cutaways reveal party. Physics/appearance separate; batching/instancing avoids thousands of script/material nodes. Room screenshot/proxy boxes cannot be final art.
- Checks/evidence: create proposed location_asset_checks.gd/rendered kit review; inspect both projections/zoom0.8 and1.15 with actual silhouettes and representative door/furniture. Validate imports/VisualRoots. Gallery does not certify final map.

## IM005 - Deliver public Hall

- Inputs/prerequisites: IM003/IM004; pinned Hall, seven anchors and grouped town door.
- Outputs/allowed changes: Hall scene/layout/resource, reciprocal portals/arrivals, readable archive/planning/assembly rooms, selected props/warm lighting; narrow town door overlay/catalog registration.
- Preserve: pinned exterior/other doors/accepted roster/routines. Anchors remain metadata; do not relocate Vale actors or invent scenes.
- Acceptance: ordinary zero-affinity E entry/return, safe full-party arrival and connected required hooks; source furniture/wall/cleared-floor truth or documented measured repair. Both cameras readable, indoor dry/stable, truthful hints, preview entry and manual save/load work.
- Checks/evidence: create proposed hall_location_checks.gd and ordinary production-root room/return render; reuse routine_portal_checks, location_travel_checks and affected save/environment checks. Inspect captures; test blocked furniture/void/unsafe arrival and no duplicate party/world.

## IM006 - Deliver starter-home inspection room

- Inputs/prerequisites: IM003/IM004; pinned20x16 map, five hooks and grouped entrance/return.
- Outputs/allowed changes: furnished room/resource/portals, selected breakfast/personal-object/visitor/exit hooks and narrow safe exterior return overlay.
- Preserve: no ownership/household/storage/purchase/sleep/visitor scene/romance/reward; public inspection wording explicit.
- Acceptance: ordinary public/preview entry and return; full-party floor/door/furniture safety, readable functions, warm/dry room while clock advances. Anchors independent of node names; arrival save/load preserves possessions/quests/social.
- Checks/evidence: create proposed starter_home_checks.gd; ordinary root walkthrough/camera captures, source/target footprint probes and save/travel regressions. Unavailable service/cancel/failure yields no effects.

## IM007 - Reconcile delivered Mayor home

- Inputs/prerequisites: IM003/IM004; IM001 delta report, R007 layout/nine stations/two documented furniture adaptations/live routines.
- Outputs/allowed changes: only missing selected source props/hooks, visual enrichment and preview registration. If no runtime delta needed, deliver verified complete coverage/adaptation report instead of rewrites.
- Preserve: existing IDs/floor/colliders/doors/station feet/facings, paired Vale lanes/actions/leases and R007 pins.
- Acceptance: selected records implemented or explicitly inert; two accepted clearance repairs remain documented. Ordinary archive/breakfast/bedroom/return works with party/scheduled contacts. New art does not block contact/aim/camera; preview/manual restart and indoor weather behavior correct.
- Checks/evidence: reuse routine_home_checks, routine_cross_map_checks, routine_activation_checks; add proposed home_map_coverage_checks.gd as needed. Inspect coverage/furnished room and physical stations/social access. Synthetic clock probes labeled.

## IM008 - Reconcile delivered Lantern Rest

- Inputs/prerequisites: IM003/IM004; inn delta report, R008's 19 colliders/host and nine selected source anchors.
- Outputs/allowed changes: missing guest-room/breakfast/personal-object/visitor/exit metadata/details, visual enrichment and preview entry. Reuse inn and actual Della.
- Preserve: IDs/dry floor/door/host feet, single Della/routines/dialogue/gifts/absence reconstruction. No paid lodging/booking/sleep/morning trigger/private disclosure.
- Acceptance: all nine hooks covered and required approaches physically reachable; host/lounge/guest room/breakfast readable. Ordinary enter/talk/gift/explore/return and arrival save/load work; full party safe. Unimplemented services truthful and effect-free.
- Checks/evidence: reuse routine_inn_checks, routine_cross_map_checks, routine_activation_checks and social integration; add proposed inn_map_coverage_checks.gd. Inspect ordinary route/cameras and separate deterministic night/weather probes. Retain exact colliders unless measured bounded repair justified.

## IM009 - Build full Tollworks as isolated candidate

- Inputs/prerequisites: IM002/IM004; pinned40x30 map/group,27 top-level colliders/nine anchors and existing guardian/vessel/plinth art.
- Outputs/allowed changes: candidate full entrance/traversal/maintenance passage, structure/mechanism/index/log/vessel-site appearance, warm lighting and all selected hooks. Normal compact scene stays until IM010.
- Preserve: encounter/quest/save/exterior gate; no new guardian/memory outcome/index-log prerequisite or normal Orchard/shortcut activation.
- Acceptance: physical route entrance->guardian area->index/log/vessel/safe return->closed Orchard approach, full capsules/party fit and real wall/gap truth. Recognizable areas/group geometry; no walkable wall tops/decorative physics. Candidate arrival/exit probes safe.
- Checks/evidence: create proposed tollworks_layout_checks.gd/candidate render; sweep required routes with real shapes, blocked negatives, mechanism/camera inspection and source landmarks. Label candidate/synthetic placements; no normal quest completion claim.

## IM010 - Run existing recovery in expanded Tollworks

- Inputs/prerequisites: IM003/IM009; stable guardian/vessel/effect/quest/arrival IDs and actual combat/retry owners.
- Outputs/allowed changes: activate full scene under prototype-tollworks, relocate real guardian/vessel/returns to mapped safe sites, update HUD/quest directions, inert locked Orchard/shortcut treatment.
- Preserve: exterior approach/old town-Tollworks spawns/party health/trust/strike, defeat/retry/once-only effect order and shortened quest. Index/log/control never new mandatory steps.
- Acceptance: ordinary lead/forest/gate/win/vessel/return/fitting completes; cancel/fail/retry/ally assist safe. Defeated guardian remains defeated after travel/retry/restart. Earlier valid schema8 arrivals place party safely. Recovery never opens Orchard/shortcut; preview cannot mint normal unlock.
- Checks/evidence: reuse combat_checks, quest_checks, consequence_checks, recovery_presentation_checks, map_save_checks, location_travel_checks; create proposed tollworks_migration_checks.gd. Actual rendered recovery/save/restart/revisit and LOS/camera obstacles; effect injection cannot substitute for winning.

## IM011 - Build fair physical layout and approaches

- Inputs/prerequisites: IM002/IM004; pinned40x28 map/eight groups/fifteen hooks and both town approaches.
- Outputs/allowed changes: candidate terrain/water edges/bridge/stall footprints/lanes/exit sites/hooks. Normal doors stay inactive until IM012.
- Preserve: town/Moonwood geography/river/crossings; no demo ride, extra bypass/passenger travel/reward. Group transforms/collision switches explicit.
- Acceptance: distinct safe arrivals/returns and connected stalls/demo/beacon/meeting lanes; party clears bridge/structures without entering water/counters. Correct source footprint/elevation, no invisible water/erased-floor support; future interaction approaches physically validated.
- Checks/evidence: create proposed fairground_layout_checks.gd/candidate render. Test both approach/return chains/full-party/rails/water/group transforms. Label setup versus actual candidate movement; public activation remains IM012.

## IM012 - Deliver readable public fair and lights

- Inputs/prerequisites: IM003/IM011; clock/forecast/light registry and pinned stall/net/beacon/demo art.
- Outputs/allowed changes: fair-specific art/outdoor lighting/weather/resource, both narrow town entrance/return overlays and preview arrival.
- Preserve: no ceremony/ride/sleep/recovery-stage logic/new cast/optional displays; original23 town light IDs.
- Acceptance: ordinary north/south routes/returns and safe party arrivals; recognizable bridge/stalls/boat/beacon/nets. Readable day/dusk/night/storm, source-declared switchable lights independent/persistent. Unavailable ceremony/demo grants nothing. Manual save/load and preview work.
- Checks/evidence: create proposed fairground_location_checks.gd/fair_lighting_checks.gd; reuse environment_rule_checks, environment_lighting_checks, location_travel_checks. Inspect both public routes/cameras/zoom/day-night; light independence/no water bypass; deterministic environments labeled.

## IM013 - Deliver outer Orchard through preview only

- Inputs/prerequisites: IM003/IM004/IM010; pinned48x32 outer/ten hooks and forward/return edges.
- Outputs/allowed changes: outer scene/resource, orchard ground/trees/refuge/chime/hook appearance/outdoor environment, preview entrance/reciprocal Tollworks return. Inner gate unavailable until IM014.
- Preserve: normal service barrier/player-direct-load-NPC denial; no refuge quest/memory scene/reward/new cast or exterior forest replacement.
- Acceptance: physical preview Tollworks->outer/refuge/chime->closed inner approach->return, full-party support/bounds/hooks safe. Landmark scale/placement readable day/night/rain. Normal access denied even after Maris completion; preview slots isolated.
- Checks/evidence: create proposed orchard_outer_checks.gd/rendered preview journey; reuse access/preview/save/environment tests. Route proof starts after labeled preview setup; normal negatives and landmark/collision coverage required.

## IM014 - Deliver inner Orchard/House of Echoes preview

- Inputs/prerequisites: IM013 chain; pinned48x36 inner/three groups/seven anchors/outdoorCycle.
- Outputs/allowed changes: inner scene/resource, House shell/structure/approach/mechanism/heart-site appearance, outdoor environment and safe preview outer-inner pair.
- Preserve: closed normal gate; no ending/heart shutdown/new guardian/household/private scene. Flatten structural groups once; no duplicated blockers.
- Acceptance: physical preview outer->inner->outer->Tollworks safe with same party; mechanism/heart/return hooks recognizable. Cutaways preserve actors/doors; inner map stays source outdoorCycle. Both future regions reject normal bypasses; preview save/load safe.
- Checks/evidence: create proposed orchard_inner_checks.gd/group geometry tests; inspect preview route and both camera/zoom/weather views. Negative walls/void/normal access, outward return and absence of completion effects required.

## IM015 - Integrate nine-map lifecycle, items and UI

- Inputs/prerequisites: delivered map tasks in table; WorldHost/environment/routines/item-foreign-placement/fishing/UI owners.
- Outputs/allowed changes: bounded integration repairs, qualified hints/objectives/preview selector, cleanup/environment interfaces and safe rod placement support on delivered public/preview maps.
- Preserve: exterior/resource origins/relocations, eight villagers/25 routines, single session/clock/party/director, social/quest/combat and supported Alderwake-only fishing.
- Acceptance: nine production definitions/access modes, separate old fixtures, eighteen-edge mapping/aliases, no shortcut/second-city leak. One scene/nav region, correct contacts after travel, no duplicate listeners/actors. Cross-map rod drop/pickup/load uses real local/foreign support/collision and exactly-one conservation. Unsupported fishing/hooks explain denial. Pause/dialogue/journal/focus/travel/death clears unsafe input/presentation.
- Checks/evidence: create proposed location_integration_checks.gd; extend world_item_placement_checks/foraging_save_checks; reuse fishing_lifecycle_checks, routine_lifecycle_checks, routine_cross_map_checks, social_integration_checks, environment_lifecycle_checks, application_smoke. Actual-root public/preview travel and expected typed state/light identity preservation.

## IM016 - Prove saves/restarts/retries and rollback

- Inputs/prerequisites: IM015, actual schema, isolated earlier four-location current-format snapshots and new maps.
- Outputs/allowed changes: proposed location_save_checks.gd/location_process_checks.gd and necessary bounded restore repairs; documented schema/content/namespace decision.
- Preserve: normal slots/backup/current-format rejection/arrival policy and health/effects/trust/strike/items/social/routines/environment. No autosave/invented migration.
- Acceptance: manual GUI/ordinary saves and new-process loads for every normal location and both preview Orchards, followed by physical returns. Earlier four-location schema8 saves work if unchanged format. Failed construction/nav/party/item restore rolls back identity/state; validated matching backup recovery only. Wrong-mode/closed-map/malformed/unsupported data rejects before swap preserving bytes. Guardian/reward/rod conservation survives retry/restart.
- Checks/evidence: isolated primary+backup/process tests and exact typed durable-field before/after; reuse save_checks, map_save_checks, social_save_checks, foraging_save_checks, environment_save_checks. Labeled failure fixtures assert old world/actor identity, not just error code. Read actual ProcessScripts protocol.

## IM017 - Measure performance, cameras and travel ownership

- Inputs/prerequisites: IM015; IM001 settings/baseline/budgets and R014's 4ms revision; final map art/physics/access.
- Outputs/allowed changes: proposed location_performance_profile.gd/runner and narrow measured batching/culling/nav/camera fixes. Keep failed and final raw results.
- Preserve: source/physics/nav/actor/light/save truth; no silent cap weakening/art removal/hidden contacts.
- Acceptance: CONTRACT timing/draw/memory/nav/load bounds on recorded machine and declared stress views/cameras/zoom, cold/warm separate. Fair/Orchard/interior visibility/aim readable. Ten tours/equal settling restore owned counts and memory growth<=64MiB. Existing routine reconstruction/query/update bounds retained.
- Checks/evidence: >=1000 active frames/view after warmup, physical queries/cold-warm arrivals, process memory/exact ownership inventories. Reuse map_camera_checks/performance methods. Static poses/direct swaps are synthetic benchmarks, not walkthrough proof. Record settings/limits; numerical revisions need measured failure and explicit decision.

## IM018 - Walk normal/preview journeys and inspect final maps

- Inputs/prerequisites: IM016/IM017 evidence and unchanged deliverables; current guarded journey/capture tools.
- Outputs/allowed changes: focused final journey/visual coverage/route help and necessary scoped repairs.
- Preserve: IDs/source/state/access/normal saves and unrelated live processes. Rerun affected checks after fixes; old evidence cannot certify changed artifacts.
- Acceptance: fresh ordinary normal journey visits all seven public locations, both fair approaches, scheduled home/inn contacts and real recovery. Gather/gift/People/fishing still usable. Actual Save/quit/new-process Load/revisit preserves typed facts. Separate labeled preview walks both Orchards/returns without touching normal slots. Inspect source-plan/landmark/camera/zoom/indoor-outdoor matrix; no invisible actors/doors/rain indoors/softlock/misleading services.
- Checks/evidence: create proposed location_walkthrough.gd/route plan as needed and run affected checks. Ordinary viewport/native inputs prove routes; teleports/effect/clock/weather/preview initial selection are setup. Confirm pause between calls. No whole natural-day replay unless changed routines require it or indefinite wait for random storm.

## IM019 - Deliver fresh Windows packages and native acceptance

- Inputs/prerequisites: IM018, accepted artifact manifest, current Desktop/Validation presets/templates/native guards.
- Outputs/allowed changes: proposed tools/location_migration/{build_packages.py,package_audit.gd,launch_native.ps1,DELIVERY.md}/scoped route drivers, fresh nine-map local packs. Archive/hash prior canonical packages/overrides before scoped promotion.
- Preserve: source/normal saves, test/private/authoring exclusions, other workflow preset work and historical packages/evidence. No install/distribution/publication/automatic commit/push.
- Acceptance: both presets export/audit/start outside checkout without source/Flutter; all nine map/art/JSON/gates/eight rigs/portraits/routines/environment/social/items/current schema present. Actual release public doors/both fair returns/expanded recovery plus GUI Save/normal quit/new-PID Load/revisit pass. Separately isolated native preview reaches both Orchards/returns/restart without normal-slot changes. Guards intact; debug bridge/build-only proof insufficient.
- Checks/evidence: exact package hashes/entries/exclusions, isolated app-data/primary-backup slots, structured exits/diagnostics, inspected native captures/typed save oracle. Retain failed runs/cleanup; update discovery README/architecture only with verified final claims. Native unavailability leaves task incomplete with precise retry; never bypass guards.

## Completion records

No implementation completed. Append only for verified Done task:

    ID and completion date:
    Result and changed files:
    Commands, cwd, isolation and actual results:
    Evidence and inspected artifacts:
    Source/schema/adaptation decisions and retained limits:
    Next eligible task and exact action:
