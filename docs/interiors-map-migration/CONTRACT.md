# Interiors, fairground and remaining maps migration contract

Prepared 2026-10-09, America/Vancouver. Planning only; implementation has not started.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.

## Outcome and scope

Deliver source-informed, physically playable 3D versions of all nine shipping map locations in the existing Returning Fair Godot game. Reuse the accepted town, Mayor Vale home and Lantern Rest; add Hall, starter-home interior, fairground and both Orchards; expand compact Tollworks to its authored traversal footprint while preserving the existing shortened recovery quest.

Normal play exposes seven locations: town, Hall, starter-home inspection interior, Lantern Rest, Mayor Vale home, fairground and existing Tollworks recovery. Both Orchards remain closed in normal play and accessible through an explicitly labeled, isolated map-preview session. Public home entry grants no ownership/household/storage/sleep. Inn access grants no booking/sleep entitlement. Fair/demo/beacon scenery grants no ceremony, ride, quest or reward. Preserve current Tollworks access/guardian activation; do not introduce source's unfinished expedition-preparation prerequisite.

Exclude full campaign/MQ/SQ execution, economy/paid work, home ownership, sleep, new villagers/routines/relationships/companions, ship recovery stages, optional outcome displays, keepsake galleries, second-city passage, autosave/exact-position resume, web/mobile delivery and bespoke editors. Preserve accepted eight villagers and 25 routines. New story anchors are metadata, not invented scenes. Orchard mechanisms/guardian sites are inspectable scenery/hooks, not new encounters.

## Baseline and concurrent ownership

Workspace: D:/development/game-dev-blender. Repository: D:/development/game-dev-blender/returning-fair-prototype. Application: game/, entry res://app/game_root.tscn, typed GDScript/GL Compatibility, 960x640 baseline.

Inspected target HEAD4a2afda40c68f1bfc37ac3af06ebcad38ad313ae; read-only source D:/development/game-prototype-2 at HEAD60c20eb2816e7271fb84afaba286af006ebe3ccf. Observations are not reset targets. Source Git status was clean. Target has ongoing R016 changes listed in CURRENT_STATE.

[Routine checklist](../day-clock-npc-routines/CHECKLIST.md) records R001-R015 Done, R016 In progress; native/package acceptance remains incomplete. Recheck live handoff before work. IM001 can pin/audit references without changing runtime/shared files. Runtime/art activation/export/shared testing changes require a stable ownership baseline: verified R016 completion/evidence or explicitly coordinated handoff of overlapping paths. Unresolved collisions exclude affected tasks; genuinely disjoint ready work may proceed. Record exact overlap, never mark R016 complete or use its selector to execute unrelated work.

Already delivered, to verify/reuse:

- [R007 home](../day-clock-npc-routines/R007_ACCEPTANCE.md), [R008 inn](../day-clock-npc-routines/R008_ACCEPTANCE.md): actual cutaway rooms, physical furniture/navigation, safe full-party arrivals and reciprocal public doors. Reconcile selected source detail; do not rebuild from scratch.
- [Routine state](../day-clock-npc-routines/CURRENT_STATE.md): default shared director, 25 routines/eight villagers, groups, cross-map execution/actions/speech and current release gate.
- [Map contract](../map-migration/CONTRACT.md): pinned exterior alderwake-f4630f9-m002; preserved terrain/elevation/river/crossings. Live source town differs; no wholesale refresh.
- [Foraging](../foraging-items-backpack/CURRENT_STATE.md), [fishing](../fishing/CURRENT_STATE.md), [villagers](../villagers-dialogue/CURRENT_STATE.md), [social](../gifts-friendship-people-journal/CURRENT_STATE.md), [environment](../weather-lighting/CURRENT_STATE.md).
- [Architecture](../ARCHITECTURE.md), [SaveCodec](../../game/core/save_codec.gd): inspected schema8/content1, strict current-format-only saves, manual Save/Load and arrival-anchor restoration. Current code supersedes historical handoff version statements.

## Source inventory and mapping

Paths are relative to read-only source root; dimensions are 32-unit gameplay cells. Hash prefixes identify planning observations only. IM001 must pin full SHA256 and selected public dependencies locally.

| Source map / assets/maps file | Cells | Lighting | SHA256 prefix | Target location / work |
| --- | --- | --- | --- | --- |
| alderwake / mvp_world.json | 147x80 | outdoorCycle | 777b99288fb18852 | prototype-alderwake; preserve pinned target |
| alderwake-hall / alderwake_hall.json | 28x22 | interiorWarm | 3b35a2a47abeebc4 | prototype-alderwake-hall; new |
| alderwake-starter-home / alderwake_starter_home.json | 20x16 | interiorWarm | 8086cfbb1daf1357 | prototype-alderwake-starter-home; new inspection room |
| buried-tollworks / buried_tollworks.json | 40x30 | interiorWarm | cf71bd7406922fa9 | prototype-tollworks; expand, retain ID |
| lantern-rest / lantern_rest.json | 28x24 | interiorWarm | fbe3d5e901d65586 | prototype-lantern-rest; reuse/enrich |
| mayor-vale-home / mayor_vale_home.json | 16x14 | interiorWarm | 1a97bf6182c8dcd2 | prototype-mayor-vale-home; reuse/enrich |
| night-orchard-inner / night_orchard_inner.json | 48x36 | outdoorCycle | 02ee9631d9e93cc6 | prototype-night-orchard-inner; preview only |
| night-orchard-outer / night_orchard_outer.json | 48x32 | outdoorCycle | 4af354bd6d6f22d1 | prototype-night-orchard-outer; preview only |
| old-bridge-fairground / old_bridge_fairground.json | 40x28 | outdoorCycle | 379701bd7b187687 | prototype-old-bridge-fairground; new public area |

New IDs above are plan decisions, not existing resources. Shipping assets/maps/project.json/JSON own source geometry; historical candidate/generator files do not. Reuse R001 home/inn pins and documented home furniture adaptations. Observed top-level anchors: Hall7, starter-home5, home9, inn9, Tollworks9, fair15, outer10, inner7. IM001 verifies flattened counts and classifies every selected prop/collider/group/marker/light/tile/erasure/anchor/portal as retained, adapted, inert or excluded, with downstream owner. Source now has people beyond accepted roster; do not activate them incidentally.

Pin/read selected inputs:

- assets/data/world_objects/catalog.json, required public prop/light definitions, terrain/art metadata and exact referenced appearance images; nine shipping maps/project and earlier target room/exterior pins.
- lib/world_map/{world_map.dart,world_map_codec.dart,world_map_flattening.dart,world_object_collision.dart,world_map_validator.dart}; lib/game/world/{elevation_navigation.dart,world_collision_map.dart}.
- lib/game/presentation/{world_portal_eligibility.dart,world_presentation.dart,world_presentation_bindings.dart,world_presentation_resolver.dart}; retain eligibility semantics without importing unfinished campaign execution.
- docs/{map-contracts.md,returning-fair-integration-contract.md,world-presentation.md,interior-measurements.md,clean-hd-art-guidelines.md,towns/alderwake.md} and relevant map-readiness tests. Current code/JSON wins over stale candidate counts in prose.

Runtime/export must work without source checkout, Flutter/Dart, private profiles or authoring directories. Later tools consume local pins and refuse unexplained drift. Record deliberate adaptations with source-before/target-after, reason, physical/visual evidence and owning task. Pinning current source never authorizes replacing accepted earlier feature snapshots/exterior geometry. Existing exact target-byte audits may need scoped adaptation-ledger entries for intentional migration changes; preserve original pinned hashes/reasons and prove unaffected bytes, rather than regenerating the audit baseline wholesale.

## Coordinates, physics and appearance

One Godot metre per32 logical source units. Exterior origin(704,576), delivered home(256,384), inn(448,672). New maps use pinned playerSpawn as origin unless IM001 records a justified alternative. X=(sx-originX)/32, Z=(sy-originY)/32, Y=physical height; east+X, south+Z. Existing elevation increment0.25m. Preserve fractions, mixed grids, layer/default order, null erasures and group pivot/quarter-turn transforms. Point versus cell-top-left rotation requires separate vectors.

Source visual elevation, sprite envelopes, renderDepthOffsetY and4x texture density are appearance data. Source interior furniture art uses20 source units/metre for interpreting art proportions; do not apply a second room-space scale or rescale accepted actors/floor plans. IM001 documents this difference and any bounded visual adaptation.

Retain current capsules (verify exact dimensions; accepted room navigation uses0.4m clearance), speeds/actions and two persistent party members. Floors/walls/furniture/water/cliffs own physics/navigation independently of art. Erased floor cells cannot acquire invisible support; wall/furniture tops cannot become alternate floors. Full-party arrivals need dry support, clearance from doors/NPC reservations and connected exits. Preserve old spawn IDs and accepted home/inn stations.

Narrow door/furniture conflicts require bounded measured repairs with before/after probes; do not shrink actors, erase meaningful blockers, widen every room or teleport through furniture. Stairs/ramps require physical sweeps/floor/aim tests. Preserve distinct fair bridge versus Moonwood footbridge; demo scenery creates no new crossing/passenger route.

Match authored functions, landmark silhouettes/relative placement, warm indoor/cool outdoor palette and accepted target style. Reuse Godot/Blender modules; follow [asset pipeline](../../art/exports/PIPELINE.md) where applicable and relevant asset skills when producing art. Keep editable sources/target-local exports and replaceable VisualRoots. A room-sized screenshot or final proxy boxes cannot stand in for required 3D presentation. Each map needs inspected game-scale renders.

## Travel, eligibility and isolated preview

Reuse [LocationDefinition](../../game/world/location_definition.gd), [PortalBinding](../../game/world/portal_binding.gd), [PortalRoutes](../../game/world/portal_routes.gd), [PrototypeLocation](../../game/world/prototype_location.gd) and [WorldHost](../../game/app/world_host.gd). Multi-portal travel already exists. Never dispatch by legacy destination_id/destination_spawn_id. Preserve transactional actor suspension, placement/synchronization/rollback and stale-contact guards.

Nine source maps expose eighteen base directed portals after flattening; IM001 verifies/mapping all. Both fair approaches/returns remain distinct. Four town doors are grouped children. Source tollworks-town-exit-01 maps to existing target tollworks-exit-to-alderwake alias; retain physical interaction and old town/Tollworks/home/inn arrival identities. New arrivals derive from qualified portal/destination coordinates, not node names or inferred reverse edges. Existing measured home/inn approaches take precedence over naive source rectangle centers.

Dynamic shortcut portals are absent from source base graph: remain closed/inert even after existing Maris completion. No second-city/ferry/passenger portal. Activate Hall/starter/fair through narrow exterior overlays, never a live-town regeneration. Normal Orchard denial must cover player dispatch, direct transition/load, NPC routing and physical/prompt eligibility; registered resources alone grant no access. Preview outward exits remain usable.

IM003 provides only required map inspection: proposed --map-preview flag, explicit typed launch mode, visible label, allowlisted installed destinations/reviewed safe arrivals, small selector/return control and isolated preview primary/backup storage. Implement/document before invoking. At IM003 only existing locations selectable; map owners register new arrivals. Normal UI has no selector and normal startup/load/save/reset never reads/writes/deletes preview slots. Preview grants no normal rewards/unlocks/ownership and cannot serialize its access token as campaign progress. Return to normal requires new normal session. Final Windows packages support this explicit preview. No full stage selector, arbitrary teleport console or extra galleries.

## Existing feature ownership

One physical location/navigation region and authoritative session/party/clock/forecast/routine director/UI command owner. Do not mount nine worlds to simulate unloaded NPCs. Existing25 routines retain accepted three-map anchor/door metadata and transient reconstruction; new anchors do not imply new routines. Extra registered edges must not break measured NPC chains or accept missing door/arrival metadata.

Extend bounded per-location environment interfaces rather than copying clock/weather. Hall/starter/home/inn/Tollworks stay warm/dry while forecast advances; fair and both Orchards use outdoorCycle, including inner House-of-Echoes setting. Map-qualified light identities preserve23 town sources/saved overrides; add only mapped source lights with explicit finite emitter/render limits.

Preserve eight NPC identities/rigs/portraits/gifts/facts/People, party trust/strike/health, inventory/fishing and Maris effect order. IM010 relocates the real existing guardian/vessel into authored Tollworks sites while preserving one encounter/reward and defeat/retry/restart. Index/log/control hooks remain inert/unavailable, never new mandatory recovery steps.

IM015 extends safe movable-rod placement to delivered public maps and preview Orchards with actual local/foreign-room support/collision validation, stable map identity and exactly-one-rod conservation. Original four resource origins/approved relocations remain exact; scenery yields no inferred pickup. Fishing stays in currently supported authored Alderwake areas; other water rejects clearly instead of fake fishing.

## Save policy

Inspect actual SaveCodec before editing. Geography/catalog additions should retain schema8/content1 and all existing spawn/location/effect IDs; preserve manual save and arrival-anchor restoration. Test valid earlier schema8 snapshots from all four existing locations. If genuinely new durable fields/meaning unavoidable, justify/version in owning task and update current consumers/fixtures together, following strict rejection; no automatic legacy migrations/defaulted history or rewriting files on Load. Never save NPC positions/paths/timers, scene objects, preview access tokens or duplicate clocks.

Validate mode/location eligibility before live swap. Failed construction/navigation/full-party/item-placement restore preserves previous session/world and saved bytes. Retain temporary writes, validated backup recovery/error feedback. Every map task proves local travel/save correctness; IM016 adds cross-map restart/failure coverage.

## Acceptance and local delivery

Tasks own focused correctness plus actual visual/physical proof. IM001 freezes coverage/settings before runtime. Proposed tools/tests in CHECKLIST do not exist until created. Label synthetic placement/effect/time/weather/preview setup and generated route guidance; none substitutes for ordinary route or natural-weather evidence.

Reuse existing bounds at recorded machine/960x640/Compatibility: frame p95<=max(16.67ms,paired baseline+4ms), p99<=25ms; draw p95<=500; working-set peak<=2GiB; cold generation/bake<=5s; warm safe arrival<=2s; path query p95<=5ms. Preserve accepted R014 scheduler-plus-eight-loaded-NPC p95<=4ms revision, not superseded2ms estimate. Sample>=1000 active frames after warmup, cold/warm separately. After ten tours/equal settling, owned scene/nav/contact/listener/reservation counts return to baseline; memory growth<=64MiB. Numeric revisions need retained measured failure/before/after and explicit decision, never silent weakening.

IM018 walks all seven normal locations, both fair approaches, real recovery/gifts/foraging/fishing and Save/restart/revisit; separate preview traverses both Orchards/returns without touching normal storage. Deterministic weather probes are labeled; no indefinite wait for random storm. IM019 builds fresh Validation/Desktop packs with all local resources and excludes tests/private/source/authoring files; starts outside checkout; verifies actual native public/preview travel and GUI Save/quit/new-process Load/revisit. Old packages/build-only/debug bridges do not certify changes. Archive/hash prior canonical packages/overrides before local promotion. No automatic commit/push or publication.
