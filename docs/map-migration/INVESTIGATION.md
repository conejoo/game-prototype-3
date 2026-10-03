# Alderwake map migration investigation

Inspected 2026-10-03. Goal: migrate larger Alderwake, Alder River and Moonwood
into existing Godot 3D prototype, retaining its playable Maris recovery slice.
Source geography and gameplay boundaries can be reused; Flutter rendering and
navigation code need Godot equivalents. This investigation covers files and
implementation, not a source-game playtest or verified migration.

## Verified source snapshot

Source root: `D:/development/game-prototype-2`.
Source HEAD: `f4630f9966d6637ef6579cd87623ea354758191c`.
Authoritative exterior: `assets/maps/mvp_world.json`, map ID `alderwake`.
Observed file SHA-256:
`af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f`.

| Authored content | Observed value |
| --- | --- |
| Gameplay footprint | 147 columns × 80 rows, 32 source units per cell |
| World extent | 4704 × 2560 source units |
| Player spawn | (704, 576) |
| Moonwood rectangle | left 1504, top 0, width 3200, height 2560 |
| Tile layers | ground, terrain, shoreline-details, decorations |
| Layer cell sizes | 16, 16, 16, 32 respectively |
| Explicit tile cells | 0, 13478, 156, 183 respectively |
| Objects outside groups | 534: 443 props, 78 routine anchors, 6 markers, 4 resource nodes, 3 NPCs |
| Groups | 31; contain another 25 props, 8 colliders, 4 portals |
| Explicit colliders | 94 outside groups; 102 after including groups |
| Portals | 3 outside groups; 7 after including groups |
| Zones and activities | 25 zones; 3 activity areas |
| Elevation | 472 explicit cells, levels up to 7; 16 slopes |

Counts are authored records, not total runtime collision or rendered instance
counts. Catalog props and cliff/slope rules add derived blockers. Empty ground
cell list still paints default grass. Source forest checklist describes 360
**added** trees; do not treat that as the current whole-map tree count.

Current JSON hash differs from hash written in
`docs/moonwood-forest-expansion-checklist.md`. Shipping JSON wins. That document
also leaves source runtime acceptance open; neither its status nor its tests
prove a live walkthrough. Do not regenerate map from older generator.

## Source files and implementation

Paths below relative to source root.

| Concern | Read these files | Migration implication |
| --- | --- | --- |
| Shipping map selection | `assets/maps/project.json`, `lib/world_map/world_map_repository.dart` | Exterior plus eight connected maps exist. Use shipping exterior, not preview/candidate maps. |
| Parsing and validation | `lib/world_map/world_map.dart`, `world_map_codec.dart`, `world_map_validator.dart` | Preserve IDs, defaults, layer order, mixed grids, fractional positions and explicit empty paints. Reject unsupported data visibly. |
| Group transforms | `lib/world_map/world_map_flattening.dart`, `WorldMapGroup` in `world_map.dart` | Group pivots use 32-unit gameplay cells. Point rotation and cell top-left rotation differ. Retain transformed grouped props, colliders and portals. |
| Terrain appearance | `lib/world_map/world_tile_grid.dart`, `tile_paint_resolver.dart`, `terrain_material_catalog.dart`; `assets/tiles/tile_manifest.csv`, `assets/generated/terrain_atlas/terrain_materials.json` | Material paint is semantic data, sometimes connected/masked/animated. Texture dimensions are separate from world dimensions. |
| Prop appearance and collision | `assets/data/world_objects/catalog.json`, `lib/world_map/world_object_collision.dart`, `lib/game/world/world_prop_component.dart` | Sprites use bottom-center foot anchors. Boxes/polygons are anchor-relative; rotation applies to collision too. Respect `collisionEnabled`; visual sprite bounds are not collision bounds. |
| Collision and elevation | `lib/game/world/world_collision_map.dart`, `elevation_navigation.dart`; `lib/world_map/world_map_cliff_edge.dart` | Explicit blockers plus catalog footprints plus derived cliffs/slope walls decide traversal. Water paint alone is not the movement contract. |
| 2D elevation presentation | `lib/game/visuals/visual_elevation_projection.dart`, `terrain_plan.dart` | Source elevation shifts artwork separately from logical coordinates. Godot needs physical heights and ramps; never use displaced screen positions as X/Z coordinates. |
| Navigation | `lib/game/world/world_navigation_static_map.dart`, `world_map_navigation_portal_graph.dart`; `lib/game/navigation/`, `tool/build_navigation_cache.dart` | Source uses radius-aware occupancy, elevation traversal, portal graph and cached grids. Keep behavior; rebuild using Godot navigation. Dart caches cannot be imported as NavigationMesh. |
| World assembly and rendering | `lib/game/world/cozy_adventure_world.dart`, `location_world.dart`, `chunked_static_world_renderer.dart` | World consumes catalog/map data and culls static render work by chunks. Build batched Godot surfaces/instances, not thousands of script-driven tile nodes. |
| Travel and persistent presentation | `lib/game/world/world_map_portal_component.dart`, `lib/game/presentation/effective_world.dart`, `world_portal_eligibility.dart` | Portals and presentation variants have eligibility. Map markers/anchors alone do not install their quests, NPC routines or campaign stages. |
| Behavioral probes | `test/tool/moonwood_production_map_test.dart`, `moonwood_forest_population_test.dart`; `test/world_map/mvp_world_map_test.dart` | Reuse intended route/water/gate assertions as Godot acceptance targets. Source tests were read, not run. |
| Canon and map constraints | `docs/towns/alderwake.md`, `map-contracts.md`, `moonwood-forest-expansion-checklist.md`, `market-of-borrowed-days.md` | Preserve geography and named identities; current slice stays a shortened adaptation. |

## Geography to carry forward

Western town includes Alder Rise, Market Lane, Mill Road, Dock Row and Moonwood
Edge. Eastern forest contains river-to-lake channel, two crossings, Moonwell,
maintenance trails, Tollworks entrance and blocked future east exit.

- Timber footbridge: group `moonwood-footbridge`, pivot (117,16), 6 × 3 art
  cells. Separate north rail, walkable deck and south rail. Source route probes:
  (3680,560) ↔ (4000,560).
- Sand ford: gameplay cells x89–95, y29–31. Source route probes:
  (2816,976) ↔ (3104,976).
- Water negative probes: gameplay cells (120,15), (120,19), (92,28), (92,32).
  Test their centers, with actor footprint clearance, rather than texture color.
- `moonwell-prop`: (1712.421630859375,723.8731079101562). Keep fractional foot.
- Maris instance `maris-chandlery-01`, definition `npc-03`: (464,928).
  Nearby fitting/player/customer anchors: (464,928), (512,944), (560,944).
- `tollworks-entrance-01`: rectangle (4104,512,64,48), source destination
  `buried-tollworks`. Adapt to existing Godot Tollworks and its safe arrival ID.
- Future east exit: explicit blocker `future-exit-gate`; approach (4592,352),
  blocked beyond-gate probe (4680,352). Gate remains closed.

Other six source exterior portals lead to fairground twice, starter home, hall,
inn and mayor's home. Keep their records in migration data, but leave entrances
inactive/labeled until destination content exists. This phase does not port
those interiors, fair stages, orchard, fishing, resources, NPC schedules or
ship-repair campaign. Resources and routine anchors may remain inert records.

## Current Godot integration points

Target root: `D:/development/game-dev-blender/returning-fair-prototype`.
Inspected HEAD: `073c924142cb0551a14510d6cd2e85c7f1b8678b`.
Existing untracked `docs/evidence/P014/resume-2026-10-03/` belongs to prior work.

- `game/world/alderwake.tscn`: 14 × 12m graybox, southwest Maris counter,
  one north travel gate. No river or forest.
- `game/world/prototype_location.gd`: `Spawns`, one destination/gate,
  interaction validation; synchronously bakes all layer-1 static collision
  on location creation with navigation radius 0.4m and max climb 0.1m.
- `game/app/world_host.gd`: validates location/spawn, suspends persistent party,
  replaces scene, synchronizes physics/navigation, validates floor/capsule,
  commits arrival or rolls back. Party arrives at anchor plus 1m X offsets.
- `game/app/game_root.gd`: dispatches every travel interaction through location's
  single destination. HUD/journal assume north gate and compact-room directions.
  Seven source portals cannot become seven functional routes with this API.
- `game/app/camera_rig.gd`: overhead follow, orthographic size 18m, modest zoom;
  aiming intersects horizontal plane at actor height. Sloped ground and tall
  trees require aiming and visibility review.
- `game/features/actors/actor_placeholder.gd`: 4m/s hero, gravity, physical
  movement/combat; hero capsule radius 0.35m, height 1.6m in root scene.
- `game/features/actors/companion_controller.gd`: routes every 0.4s; catch-up
  after 2.5s stuck or 8m separation. Placement checks floor, capsule, local
  height and LOS to hero, but not traversable path from companion to placement.
  Low river barriers could allow invalid cross-bank recovery.
- `game/core/save_codec.gd`: schema 4/content 1; stable location/spawn IDs,
  quest, party, trust and upgrade data. Loads arrival anchor, not physical foot.
- `game/world/maris_counter.*`, `game/content/locations/alderwake.tres`,
  `game/content/quests/maris_recovery.tres`: retain interaction/source IDs and
  once-only quest effects while moving service into town.

## Proposed migration choices

These are planning defaults for M001 to confirm against actual geometry.

1. Keep one continuous exterior location. Start with isolated candidate scene;
   activate it only after terrain, blockers, crossings and navigation work.
2. Preserve current production location/spawn IDs through explicit mapping:
   source `alderwake` → `prototype-alderwake`; source `buried-tollworks` →
   existing `prototype-tollworks`. Keep `alderwake-start`,
   `alderwake-from-tollworks`, and `tollworks-from-alderwake` valid.
3. Try one 32-unit gameplay cell = 1m: `X=(sourceX-704)/32`,
   `Z=(sourceY-576)/32`, `Y=height`. Full extent becomes 147 × 80m;
   terrain subcells are 0.5m. Evaluate routes against actual actor/nav radii.
4. Try 0.25m per elevation level with authored directional ramps. Source's
   8-unit visual lift is reference appearance, not a physical engine rule.
   Ramps need grounded movement, safe spawns, navigation and aim validation.
5. Copy a pinned source snapshot and extract a small engine-neutral layout in
   target repo. No absolute source path in runtime/export. Record all excluded
   records; tool reruns never overwrite hand-authored Godot scenes or Blender art.
6. Block ordinary water and retain only authored crossings. Use actual walkable
   surfaces for navigation; do not bake water/barrier tops as usable floor.
7. Build primitive footprints first, then a reusable Blender tree/town/landmark
   kit. Keep geometry, collision, IDs and interaction outside replaceable art.
8. Retain current abbreviated quest. Geography migration does not silently
   activate full source campaign or create new NPC/private-story facts.

Open technical choices: scale clearance, physical height/ramps, nav bake cost,
canopy visibility and measured performance budget. M001/M008/M009/M016/M018 own
those decisions. Existing P014 full native release walkthrough remains open;
map planning does not mark it complete. Final migration release needs that
gate resolved against the resulting build.

Follow [migration checklist](CHECKLIST.md) using [agent prompt](AGENT_PROMPT.md).
