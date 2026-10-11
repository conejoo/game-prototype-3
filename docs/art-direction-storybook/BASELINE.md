# AD001 current art baseline

Captured 2026-10-11 UTC. [LOOK_SPEC](LOOK_SPEC.md) defines the selected treatment; this is the unchanged production-art starting point, not acceptance of the painted look. [AD001 acceptance](AD001_ACCEPTANCE.md) records validation, discarded attempts and ownership.

## Revision and preservation authority

Git HEAD `8bbf35d8edbc327b1df5aa15a9a2a780af1360c3` (`chore: package R016 and record incomplete native acceptance`). Starting status contained only untracked `art/direction/`, `docs/art-direction-storybook/`, `docs/interiors-map-migration/`. Preserve those inputs and user-authored prompt/contract/task definitions. No external source checkout was read or refreshed.

Selected concept SHA256 `57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a` verified against actual file. Current project is Godot `4.7.2.stable.mono.official.ed1daf0bf`, entry `res://app/game_root.tscn`, Compatibility; SaveCodec schema8/content1. Map provenance remains `alderwake-f4630f9-m002`, source commit `f4630f9966d6637ef6579cd87623ea354758191c`; current NPC catalog source revision is `60c20eb2816e7271fb84afaba286af006ebe3ccf`. This observation does not authorize source refresh or checkout/reset.

Final baseline runner manifest covers 1,315 game/tools files; aggregate SHA256 `6aa3a331654ccd7712512d04b5dee6c04ca09ff54f51ffbd14724777e7040f19`, unchanged before/after. It includes AD001 test/helper sources; no production files changed. [Asset inventory](../evidence/AD001/source-audit-20261011/inventory.json) contains all 18 GLB hashes, primitive UV/color/material/image/clip observations and 31 source/mapping/layout/identity pins. [Source audit](../evidence/AD001/source-audit-20261011/blend-sources.json) opens all 18 existing .blend files in a separate Blender5.2.2 LTS background process without saving, reporting scenes, meshes, UV layers, materials, image nodes and armatures. No live Blender editor/connection was needed or modified.

Important immutable starting hashes:

| File | SHA256 |
| --- | --- |
| `game/content/maps/alderwake_layout.json` | `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` |
| `game/assets/environment/alderwake_town_mapping.json` | `588b36457a49547b86a388ffaf013ef509b7f3b2bc47873357628e1fd2a3337d` |
| `game/assets/environment/moonwood_tree_mapping.json` | `8b259f4d4d4346a8172512408afa6608de390c0393a542d012d71180a889f4f6` |
| `game/assets/environment/alderwake_landmark_mapping.json` | `0469e6467c3ebb0b78b6552b5af5ece3dd7a9570fd715f6273d3062ac474921e` |
| `game/assets/environment/exterior_light_mapping.json` | `79ccf0c2137ef886b403a0884501efe5c3eb948d0b80a0aee9350bd7f208b903` |
| `game/tests/fixtures/map_camera_poses.json` | `e6d7d99b49a6e4732a908b6d96602ea43d6cca0604139cde0a746fab57ecb331` |
| `game/world/maris_counter.tscn` | `d08ef5aa90455782bcef0b177d1786f0ae575320aa82fde6f46e286d96ab72b1` |
| `game/world/tollworks.tscn` | `e143fc0cb47eb3b95759af410a716bca8ad9fbce02d6f7816a769841b7fa3613` |

Preserve every ID/foot/outline/height/collider in the full pinned layout and mappings, rather than replacing them with concept geometry. Physics/navigation belong to `town_footprints.gd`, `forest_population.gd`, `crossings.gd`, `water_blockers.gd`, `elevation_surfaces.gd` and current room layouts. `npc_registry.gd`, `routine_exterior_registry.gd`, room `RoutineAnchors`, `portal_routes.gd` and the current routine registries own contact/station/door feet and map-qualified identities. Art belongs under replaceable VisualRoot/batches. Maris remains `npc-03-counter`, bench2.2x0.85x0.7m and capsule radius0.35/height1.6m, with existing basic/fitting/specialist visibility rules; her wrapper/bench bodies cannot move to improve a screenshot. Static source dimensions remain guardian0.74x1.58x0.4275m, vessel0.60x1.16x0.60m, plinth2x0.60x2m, with existing wrapper colliders unchanged.

Historical R016 is Blocked/incomplete: native full recovery and new-process GUI Load/exact restart/revisit acceptance were not run before the user stopped that workflow. Its local package/partial native evidence does not certify art work. AD001 neither resumes nor changes R016. Separate interiors workflow owns expansions; AD only styles currently implemented rooms.

## Current asset families and owners

All paths below are project-relative. A .blend basename in the source column means `art/source/<name>.blend`; environment GLBs/mappings live in `game/assets/environment/`; NPC GLBs/palettes live in `game/assets/models/npcs/`. Runtime procedural meshes have no .blend source or imported UV contract; their code/scene is the editable source.

| Family / coverage | Editable source and runtime path | Material / UV owner and adaptation reserved for future task |
| --- | --- | --- |
| Town: 24 structure wrappers, 14 building definitions plus two reusable modules | `alderwake_town_kit.blend`; `alderwake_town_kit.glb`, `alderwake_town_mapping.json`; `game/world/map_candidate/town_art.gd` | 16 meshes/primitives, one vertex palette material, COLOR_0 on all16, no UVs/images in source or GLB. Adapter duplicates material and enables vertex color. AD002 creates pilot atlas/UVs and replaces only obsolete `albedo_texture == null` assertion; AD009 rolls out. |
| Dock/plaza/low walls and town accents | Town kit; `game/world/map_candidate/town_footprints.gd`, `prop_grayboxes.gd`, `town_art.gd` | Imported dock-plank/quay-stone modules plus procedural remaining wrappers. Exact dock rectangles/quay cells/wall outlines remain physics pins. AD006. |
| Trees: 395 instances / 21 variants | `moonwood_tree_kit.blend`; `moonwood_tree_kit.glb`, `moonwood_tree_mapping.json`; `tree_art.gd` | 21 color primitives, one matte palette, no UVs/images. Chunk32m MultiMesh batching; `canopy_visibility.gdshader` uses COLOR*base_color and ignores imported textures. AD003 supplies texture-aware pilot; AD010 covers all variants. |
| Meadow, paths, sand, stone, wet shoreline, cliffs/elevation | `game/world/map_candidate/landscape_materials.gd`, `landscape.gdshader`, `terrain_preview.gd`, `elevation_surfaces.gd`; pinned `game/content/maps/alderwake_layout.json` | World-aligned procedural shader/294x160 semantic mask, not authored atlas UVs. Semantic mask is appearance data; collision/dry support separate. AD004. |
| River / shore / ford | `game/world/map_candidate/river.gdshader`, `landscape.gdshader`, `water_blockers.gd`, `crossings.gd` | World-space river animation and shore mask; preserve water union, dock exception and ford dry support. AD005. |
| Bridge, Moonwell, closed east gate | `alderwake_landmark_kit.blend`; `alderwake_landmark_kit.glb`, `alderwake_landmark_mapping.json`; `landmark_art.gd` | Five mesh/color primitives, one matte palette, no UVs/images. AD010; no relocation of crossings/closed exit. |
| Exterior lamps/windows/woven lights | `exterior_light_kit.blend`; `exterior_light_kit.glb`, `exterior_light_mapping.json`; `game/features/environment/exterior_lights.gd`, `exterior_light_consumer.gd`, `light_source_registry.gd` | Six color primitives/two materials, no UVs/images; 23 registered consumers/eight pooled emitter slots. Window surfaces generated from recipes; on/off/emission ownership stays. AD011/AD007. |
| Maris counter, oil/line, fitting/specialist gear/service board | `game/world/maris_counter.tscn`, `maris_counter.gd` | Native box/cylinder/torus meshes and flat materials; no texture. Counter remains location-owned; Maris rig mounted by NPC presenter. AD002 counter pilot, AD011 remaining states. |
| Eight villagers: npc-01 Edric, 02 Helena, 03 Maris, 04 Harlan, 06 Tess, 07 Ivo, 08 Celia, 14 Della | `art/source/npc-{01,02,03,04,06,07,08,14}.blend` plus `npc-01-actions.blend`, `npc-02-actions.blend`; matching GLBs and `art/exports/npc-*.json`, `npc-actions.json`; `game/features/npcs/npc_registry.gd`, `npc_visual_presenter.gd` | Named GLBs each one material/embedded 32x32 palette/extracted `*_TEX-npc-XX-palette.png` and UVs; action variants two mesh primitives share material, retain accessories/clips. Original identity sheets/portraits under `game/assets/npcs/{reference,portraits}/npc-XX/`; never paint over them. AD012. Calibration `npc_calibration.blend/.glb` is diagnostic, not ninth villager. |
| Hero/ally, guardian and feedback | `game/features/actors/actor_placeholder.gd`, `game/app/game_root.tscn`, `game/features/actors/companion.tscn`; `guardian.blend` / `game/assets/models/guardian.glb`, `game/features/combat/guardian.tscn` | Capsule party and code/scene materials; guardian19 primitives/five flat materials/no UVs/images. Hitboxes/aim/combat/death timing stay separate. AD013; no party redesign. |
| Recovery vessel/plinth | `recovery_vessel.blend`, `tollworks_plinth.blend`; `game/assets/models/{recovery_vessel,tollworks_plinth}.glb`; `game/features/interaction/recovery_vessel.tscn`, `game/world/tollworks.tscn` | Vessel16 primitives/three materials, plinth7/three; no UVs/images. Wrapper interaction/sign/physics remain. AD011/AD016. |
| Forage/rod/fish/backpack icons and fishing effects | `game/world/foraging_item_visual.gd`, `fishing_effects.gd`; `game/assets/items/{moonflower,fishing_rod}.svg`, `{bluegill,river_trout,golden_carp}.png`; `game/ui/backpack_view.gd`, `fishing_view.gd` | Procedural low-poly world items/flat matte/emission; icons are UI textures, not projected world atlases. Existing item identity/placement/feedback owners unchanged. AD011. |
| Mayor Vale home: existing four-room cutaway, furniture/books/textiles/fireplace | `game/world/mayor_vale_home.gd/.tscn`, `game/content/maps/mayor_vale_home.json` | Procedural box/furniture materials and plank seams, no painted atlas. Floor/wall/furniture collisions/station feet pinned; stable indoor profile. AD014. |
| Lantern Rest: current public inn/rooms/furniture | `game/world/lantern_rest.gd/.tscn`, `game/content/maps/lantern_rest.json` | Procedural surfaces/plank seams; fixed current room/cutaway/station bounds and indoor profile. AD015. |
| Compact Tollworks floor/walls/exit/recovery | `game/world/tollworks.tscn`, static assets above | Scene flat materials plus three imported assets; no new room. AD016. |
| Shared light/weather/camera presentation | `game/features/environment/{environment_presenter,environment_lighting,weather_visuals,world_rain}.gd`, `world_rain.gdshader`; `game/app/camera_rig.gd` | Root-owned environment, pooled exterior lights and existing rain; indoor stable profile. AD007 appearance only. Camera offset(10,14,16), size18, perspective45 degrees, zoom0.8-1.15. |
| Gameplay HUD/dialogue/choices/journal/backpack/fishing/pause/settings | `game/ui/prototype_ui.gd/.tscn`, `conversation_view.gd`, `people_journal_view.gd`, `backpack_view.gd`, `fishing_view.gd` | Current runtime controls/fonts/panels/Label3D world labels; no baked text textures. AD017 presentation pass; preserve modal focus/pointer gates. |

Town mapping IDs: `alderwake-hall`, `house-dockside`, `house-plaster-slate`, `house-plaster-terracotta`, `house-timber-slate`, `house-timber-terracotta`, `house-woodland-cottage`, `lantern-rest`, `mayor-vale-home`, `mill-road-schoolhouse`, `net-shed`, `passenger-control-shelter`, `reed-chandlery`, `tess-general-goods`, `dock-plank-module`, `quay-stone-module`.

Tree IDs: `alder-tree`; `birch-tree-{small,large}` and `birch-tree`; equivalent small/standard/large cherry/maple/oak/pine/willow; `rowan-tree`, `spruce-tree`. Landmark IDs: `bridge-deck`, `bridge-rail`, `bridge-landing`, `moonwell`, `closed-east-gate`. Full instance IDs/transforms and per-definition base polygons/heights remain in pinned layout/mapping files, not recreated from concept art.

## Reproducible controlled views

Primary [index](../evidence/AD001/20261011-044429132-895e7a0f/render/baseline-index.json): 18 PNGs, all actual Godot960x640, both projections, zoom1. [Contact sheets](../evidence/AD001/20261011-044429132-895e7a0f/render/derived/20261011-044525-3937487d/capture-report.json) validate capture provenance and hash all18 PNGs; pixels were inspected on both sheets and full-size Maris day/night and Tollworks frames. Sheet generation alone does not accept appearance.

Fixture: [art_direction_baseline_render.gd](../../game/tests/art_direction_baseline_render.gd). It reuses [map_camera_poses.json](../../game/tests/fixtures/map_camera_poses.json), existing `environment_review.gd`, `TestRunCapture`, `TestRunObservation` and root/WorldHost restore/travel lifecycle. `environment_review.initialize` normally runs before startup binds owners; the AD001 post-startup fixture explicitly performs a same-map synthetic restore to bind the detached review session before applying presets. Renderer/HUD time agreement is checked; the final index records actual sun energy/profile, both party feet, camera transform, session/weather and engine PID24404. This is a fixture adaptation, not production review behavior repair.

HUD: ordinary gameplay panels/labels, debug-shortcuts off, pause overlay verified then hidden only for each PNG; explicit synthetic review banner visible. Simulation stays paused; no actual WASD/E/Save/Load/native journey is claimed. NPC routines are frozen at the rebind startup placement, not evidence of naturally reaching the lighting preset's time. Quest lead before Tollworks uses existing service in this disposable synthetic process solely to display current guardian/vessel. No saves written.

Exterior clear day: day_index2/progress0.05, 11:12 AM, weather seed6, SUNNY(0), blend1, sun energy1.0896. Night/storm Maris: day_index2/progress0.625, 1:00 AM, seed30, THUNDERSTORM(3), blend1, sun0.0576. No light overrides. Home/inn/Tollworks retain day/sunny session metadata but use STABLE_INDOOR(0), sun1.1; no exterior rain. Storm precipitation is an actual rendered animated effect sampled under paused simulation, not a motion test. Pixel-identical particle phase is not promised.

All vectors are Godot metres, X/Y/Z; detailed index retains full precision. Primary orthographic size18, perspectiveFOV45, camera offset(10,14,16), zoom1.

| Labels (each `-orthographic` / `-perspective`) | Location / hero foot | Ally foot |
| --- | --- | --- |
| `maris`, `maris-night-storm` | prototype-alderwake / (-5.9959779,0,10.5802193) | (-4.4836068,0,10.2835331) |
| `dense-forest` | prototype-alderwake / (81.9547424,0,35.1094398) | (83.5087967,0,35.3465118) |
| `moonwell` | prototype-alderwake / (31.5501328,0.5,5.2740755) | (30.0271187,0.5,4.8583679) |
| `bridge-west` | prototype-alderwake / (92.9237289,0,-0.4195720) | (91.3467712,0,-0.2913315) |
| `ford-west` | prototype-alderwake / (66.0079269,approximately0,12.4766655) | (64.4629517,0,12.1036587) |
| `home` | prototype-mayor-vale-home / (0,0,-5) | (1,0,-4) |
| `inn` | prototype-lantern-rest / (0,0,-8) | (1,0,-7) |
| `tollworks` | prototype-tollworks / (0,0,3.3) | (1.2,0,3.5) |

Direct synthetic room transition spawns: `mayor-vale-home-from-alderwake`, `lantern-rest-from-alderwake`, `tollworks-from-alderwake`. These do not prove ordinary door access/travel. No feet/collider edits were made.

Secondary existing [map_camera_render survey](../evidence/AD001/20261011-044217805-f44d2253/render/index.json): 66 actual PNGs, ten fixture goals x two projections x zoom0.8/1/1.15 plus six synthetic recorded moving poses. Fresh default10:00 clear startup; clock/routines advance while party feet are artificially fixed. This tool does not pin per-image environment or pause provenance, so use it for crop/zoom diagnostics only, not controlled palette comparisons or ordinary motion proof. Full-size Maris orthographic0.8/perspective1.15 and dense-forest orthographic0.8/perspective1.15 were inspected; observed clock10:00/10:02/10:22/10:24 respectively. Use primary fixed-time fixture for before/after acceptance.

## Observational samples

Hardware observed in engine: Intel Core Ultra9 185H, NVIDIA GeForce RTX4070 Laptop GPU, OpenGL3.3.0 NVIDIA581.29. Godot Compatibility960x640, orthographic zoom1, VSync0/max_fps0. Six short frozen-scene samples:120 warmup frames then120 measured process-frame intervals (nearest rank); ordinary HUD/review banner visible, pause overlay hidden. Actors/routines frozen. These are current cadence/draw/memory observations, not whole-game performance acceptance or comparison to historical R014. Texture/buffer/static counters are engine estimates, **not process working set**. AD019 must measure full active scenes, process memory and travel growth.

| View | Frame p95/p99 ms | Draw p95 | Engine static bytes | Texture / buffer bytes | Nodes / resources |
| --- | --- | --- | --- | --- | --- |
| Maris clear day | 8.607 / 8.999 | 273 | 132953306 | 7324055 / 19729664 | 4067 / 426 |
| Dense forest clear day | 8.531 / 8.625 | 134 | 133102298 | 7324055 / 19729664 | 4067 / 426 |
| Maris night storm | 8.550 / 8.894 | 284 | 135253309 | 7324055 / 19977788 | 4079 / 426 |
| Mayor Vale home | 8.620 / 8.739 | 362 | 84384773 | 7338230 / 12395900 | 475 / 391 |
| Lantern Rest | 8.608 / 8.711 | 274 | 83862665 | 7294540 / 12362400 | 396 / 389 |
| Tollworks / guardian present | 8.599 / 8.693 | 130 | 83142965 | 8509687 / 12142476 | 298 / 450 |

## Pixel observations and next bounded action

Maris/Dock Row already has simple cream/blue/brown/teal color groups, distinct cyan/purple party, counter/supplies and roof tiles. It lacks broad painted surface variation; bright shore and sharp repeating dock/plaza detail dominate in places. Forest has grouped faceted foliage and party cutout, but bright repeated facets/flat trunks differ from the quieter painted masses. Night storm produces actual dark roofs/water, lit windows and rain; party remains identifiable, while small human silhouettes lose contrast. Home/inn use simple flat cutaway furniture/plank seams; Tollworks uses flat blue-grey floor/walls with guardian/vessel/exit cues. HUD/world labels occupy substantial scene area and overlap distant buildings; AD017 owns this existing presentation issue. All are baseline observations, not fixes or new task requirements.

Next eligible task is AD002 only: paint the identified Reed Chandlery/Maris shop and counter pilot with preserved footprints/IDs, using LOOK_SPEC and the controlled Maris views. Do not start rollout/tree/lighting/HUD tasks here.
