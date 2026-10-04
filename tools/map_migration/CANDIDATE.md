# M015 production activation

Normal `res://app/game_root.tscn` now loads the larger exterior as
`prototype-alderwake`. Existing Maris counter, labeled companion dialogue
station and single forest Tollworks gate are active. Six other source portals
stay inactive. Start/return IDs and schema4/content1 remain unchanged.

The explicit `res://tests/map_candidate.tscn` remains an isolated no-interaction
harness with detached candidate ID and named save slot. Root now configures
exterior grounding on every transition for both harness and production.
Pinned snapshot/data retain their original candidate-only metadata; production
composition is the explicit activation adapter, not a snapshot refresh.
The notes below are historical stage records, including prior statements that
normal selection was compact or activation remained pending.
See docs/evidence/M015/VALIDATION.md and docs/map-migration/CURRENT_STATE.md
for current production acceptance and subsequent gates.

# M003–M011 isolated exterior, navigation and landscape

From the target repository root:

```powershell
$godotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $godotExe --path game res://tests/map_candidate.tscn
# Optional alternate safe arrival, not a travel interaction:
& $godotExe --path game res://tests/map_candidate.tscn -- --candidate-return
& $godotExe --headless --path game --script res://tests/map_candidate_checks.gd
& $godotExe --headless --path game --script res://tests/map_water_checks.gd
& $godotExe --headless --path game --script res://tests/map_crossing_checks.gd
& $godotExe --headless --path game --script res://tests/map_town_checks.gd
& $godotExe --headless --path game --script res://tests/map_forest_checks.gd
& $godotExe --headless --path game --script res://tests/map_elevation_checks.gd
& $godotExe --headless --path game --script res://tests/map_navigation_checks.gd
& $godotExe --headless --path game --script res://tests/map_landscape_checks.gd
```

M009 navigation/forest/town/water/candidate checks pass. The historical M008
Moonwell corner failure remains in its evidence; M009 repairs it with exact
agent-centre clipping. See [M009 acceptance and commands](../../docs/evidence/M009/VALIDATION.md).

M011 replaces the neutral terrain/water materials with world-space meadow,
warm paths, sand, irregular cobbles and restrained teal river flow. One nearest
294x160 appearance mask preserves source half-metre paint registration and exact
effective water edges, including approved dock cutouts. Six terrain batches,
physical surfaces, navigation and wrapper IDs remain unchanged. River animation
changes fragment color only; no displaced vertices, wet decks or transparency.
Cosmetic flow continues during pause while gameplay time remains frozen.
Six source swatches inform the palette; zero source images copied into runtime.
Raw diagnostic dots become generic matte ground flecks, with original 183 raw
IDs/positions retained. Tree/building/landmark art remains M012-M014. See
[M011 validation](../../docs/evidence/M011/VALIDATION.md) for exact surface/mask
checks and inspected ordinary-input town/ramps/forest/crossing/gate captures.

Normal main scene and catalog remain unchanged. The alternate root extends the
existing root and appends one location to a detached manifest. Session/services,
WorldHost safe placement, party wrappers, controls and camera are reused. Candidate
defaults to `user://saves/playtest-map-candidate.json`; optional debug `--save-slot`
still selects a named `playtest-*.json` slot. Normal catalog rejects candidate saves.
There is no automatic load or normal save write. Candidate ID is `candidate-alderwake`;
start/return spawn IDs are retained within that detached definition. Production
activation and quest interactions remain M015. The journal is hidden in this harness.

Only normalized `res://content/maps/alderwake_layout.json` is read at runtime.
Snapshot `alderwake-f4630f9-m002` stays authoritative. Run extractor `--check`
before further migration work; do not refresh pinned source inputs automatically.

The construction history below describes M003-M010 neutral materials; M011's
materials above now replace that appearance. Underlying geometry stays identical.

Preview resolves each visible tile layer separately, preserving layer order, defaults,
explicit null clears, layer origins and 0.5m/1m grids. Center/connected paints use
their named solid material color; masks, variants and animation are deferred to M011.
Adjacent same-material cells merge into row rectangles and six terrain render batches:
grass, three dry terrain materials, shoreline, and raw decoration markers. Water paint
is inventoried unchanged but its M004 preview is a separate authored-blocker union
mesh, preventing painted crossing/dock openings from being shown as blocked water. All 183 raw
records keep a 0.12m dot at the center of their source 1m cell; these are explicitly
diagnostic markers, not source artwork. Individual tile IDs and paint kinds remain
in the unchanged layout and preview report. Unsupported material/kind fails scene
validation; pinned extractor validates raw references. Hidden layers emit no visuals.

One separate flat floor covers X[-22,125), Z[-18,62), with four 3m outside perimeter
walls; their visible graybox rims are 0.6m tall to keep party readable. There is
no jump mechanic; taller separate colliders guard the full capsule/dodge. Visual
offsets of 0.003m per layer prevent overlapping planes without changing
physical Y=0. Start (0,0,0) and return (107.25,0,1.25) have the existing +1m X ally
offset and validated clearance after M004 water. Return is safe in this flat stage only; revalidate
after water/props/heights. Torus/labels identify pads and add no collision.

M004 retains 90 source-authored water rectangles (`moonwood-water-*`,
`south-water-*`, `passenger-basin-water-01`) and `future-exit-gate` with exact
IDs/original X/Z bounds. Independent static boxes span Y[-0.2,3], guarding the full capsule
and dodge; the separate base floor remains intact. One neutral blue union mesh
at Y0.015 shows effective occupied footprint (8,598 half-metre cells after M006), including
lake/river, southern shore and basin. Gate has a low 0.6m diagnostic rim under
M007's disabled source prop wrapper; water owner keeps its single collider.
M014 owns final landmark art.

M005 adds a 6×3m bridge deck at X[95,101), Z[-2,1), derived from all18 pinned
bridge art cells. Two thin0.1m edge rails leave2.8m clear width; no inward posts
or end caps. Each landing is2×3m, extending to the converted source route probes
X93 and103. Physical surfaces are flushY0; visual tops areY0.018 to avoid terrain
overlap. Replaceable VisualRoot meshes do not own physics. M014 will replace art;
the source's single1m middle art row is deliberately expanded to the full dry
movement corridor rather than turning full outer art rows into solid blockers.

Sand ford uses terrain cells x89–95,y29–31, X[67,74),Z[11,14), with1×3m landings
to route probes X66 and75. `moonwood-sand-ford` is a candidate wrapper name, not
a source record ID; its cell range is metadata. The unrelated western `old-ford`
zone remains inert. Both crossings pass rendered ordinary hero walking both ways;
rails slide without end snags, adjacent water blocks walking/dodge, and all90
water records/8,766 authored cells remain unchanged. M006's explicitly approved
southern dock cutouts affect effective occupancy only. No swimming/ferry.

M006 adds 56 town/passenger props (44 enabled catalog footprints, 12 nonblocking
records), 11 independent authored town colliders, 165 art-only quay deck tiles,
six labeled inactive portal pads and three Maris/fitting foot markers. All source
IDs, fractional feet, group provenance/yaw, enabled flags and vertices remain
in data/wrapper metadata. Triangulated convex prisms preserve polygon outlines,
including concave test fixtures; no box/convex hull substitutes for a polygon.
Prop and authored-collider namespaces may share IDs; collider wrapper names use
`collider--` while metadata keeps original ID. VisualRoot never owns collision.
Structure rims start at 1m high, other blockers at 0.6m, using pinned physical
feet; M008 extends vertical bounds where needed to cover adjacent terrain.

All three original western dock art bounds overlap authored southern water fully.
User approved a deliberate target-only exception: seven registered deck/landing
rectangles in `dock_surfaces.gd`, 48m² total with 42m² previously blocked water.
Straight 5×2m bars and a T junction retain source feet/5m width; safe landings
connect shore. Their floor tops are Y0, visuals Y0.022. The water owner subtracts
the masks from `south-water-01`–`07`, preserving original records/union and exact
remaining shapes. 168 half-metre cells become deck, no other cell changes.
Moonwood crossings/gate/basin unchanged. Both rendered directions and water-edge
walking/dodge pass; this is a documented art/movement adaptation, not source
regeneration or swimming. See [contract](../../docs/map-migration/CONTRACT.md) and
[reconciliation](../../docs/evidence/M006/dock-reconciliation.json).

M003–M007 used flat physical elevations. M008 now implements472 raised cells,
16 directional ramps and238 independent cliff barriers, with matching batched
terrain/riser visuals and exact pinned prop Y. Solid base owns default Y0;
raised/ramp collision does not duplicate it. Candidate actors use0.04m floor
snap plus actual-nearby-floor ray/full-capsule correction, bounded0.11m; normal
rooms inject no callback. Both candidate party pads,crossings and seven approved
dock surfaces remain Y0. See contract/evidence for measured grounding repairs.

Exterior navigation bakes
only explicit dry row-run triangles, clipping rail footprints and omitting effective water/gate before baking; it never
parses blocker tops, art or the full base floor. Radius0.4m, height1.6m, climb0.1m,
cell0.2m/height0.05m, contour error0.1. Dry faces follow physical terrain,cliff
barriers are projected obstructions,and Recast surfaces are slightly above actual
floors. M009 additionally limits maximum slope to20degrees;
M006 projects town footprints and effective southern-water pieces as obstructions
with an extra 0.2m nav-only margin to prevent measured fractional corner cuts.
M008 extends water's same conservative margin to river/lake pieces. The strict
Moonwell corner capsule-clearance defect is repaired with post-erosion cliff
carving and exact clipping against cliff/gate0.44m exclusions and inset bounds.
Vertices weld to0.01m plus0.0001m raster bias, at physical ground+0.05m; isolated
world merge cells are0.01m. Whole-mesh/route0.4m capsule checks, route budgets,
cold/warm/query timings and region-release/rollback checks pass. Measured single
synchronous region requires no cache/background task. WorldHost waits for this
region's nonzero queryable iteration before committing or completing rollback.
M010 verifies connected companion recovery. No new AI/service/save ownership.

M007 adds all 395 trees (nine species; 65 small/266 standard/64 large) and 17 remaining
props, bringing candidate to 468 unique prop wrappers / 455 enabled footprints.
Exact catalog trunk boxes/polygons, fractional feet, yaw and complete source
records are retained. Species colors and 0.9/1.4/1.8m size prisms are diagnostic
grayboxes; M008 now uses pinned physical feet with source heights retained in metadata.
Shared prop_grayboxes.gd preserves M006's exact triangular-prism physics and
replaceable VisualRoot. Moonwell keeps its eight-corner outline, gate art adds no
second body, and six retained source markers plus Tollworks entrance are labeled
but inactive. 85 routines/resources/NPCs,25 zones/three activities stay data only.
Source sprites/lights/animation/canopies and final appearance remain deferred.
Provisional 0.2m nav-only margin also guards forest polygons and thin bridge
rails. Server iteration is asynchronous; focused checks wait for region readiness.
Pinned bridge supply cache occupies part of northwest landing, so lane checks
explicitly account for that record rather than placing actors inside its blocker.
Inventory, omitted-content disposition and routes: docs/evidence/M007/.
Maris has a reserved pad only; no
counter/service/actor exists in the candidate before M015. Normal game remains compact.

For rendered evidence, use the existing opt-in bridge and `send_playtest.ps1` from
[PLAYTEST.md](../PLAYTEST.md), with a fresh `builds/playtest/m011-*` directory and
named test slot. Its commands inject ordinary viewport input, with no teleport
or session mutation. Use short resume/actions/pause batches and confirm pause.
Headless checks label their synthetic actor placements/physics stepping explicitly.

M010's shared controller stops near a leader only with similar height and clear
sight, so it continues through necessary ramps/detours. Catch-up/recovery requires
a complete navigation path and capsule-checked floor corridors along that path
and directly to the landing; connected banks alone never permit a water/cliff
shortcut. Stale blockers/disconnected islands/combat reject placement. A blocked
ally may remain stalled/down until a safe connected corridor becomes available.
Existing session/party ownership, timers, threat and modal/focus/travel gates stay.
`map_companion_checks.gd` accelerates14 physical AI routes, true curb stall then
safe catch-up after removal, shared-API incapacitation/recovery and rejections.
Northern isolated terrace is a direct-placement fixture only. Rendered acceptance
uses ordinary WASD from fresh town through Moonwell and both crossings both ways;
zero catch-ups,132 repaths,64 retained captures and normal F10 exit0. Evidence:
`docs/evidence/M010/VALIDATION.md`. M011 landscape and M012 tree kit complete;
M013 town exterior art kit next.
No production activation/Windows export/native map release claim.

M012 replaces all395 diagnostic tree visuals with a self-contained Blender GLB:
nine species,21 actual catalog definitions,all three source sizes. Source wrappers,
feet/yaw/records/catalog physics stay unchanged. VisualRoot metadata names mesh/
batch/index; location-owned tree_art.gd groups repeated mesh resources into106
MultiMesh batches by definition and32m spatial chunks. Bole bases follow exact
catalog boxes; canopy heights deliberately compressed for overhead camera.
Portable vertex-color matte PBR,zero external textures; Godot adapter explicitly
enables imported COLOR_0. Source:art/source/moonwood_tree_kit.blend;
exports/mapping:game/assets/environment/. map_tree_art_checks.gd requires real
Compatibility renderer because dummy headless renderer returns identity instance
transforms. Candidate/crossing/nav/application/companion regressions pass.
Fresh ordinary WASD forest tour and both crossings both ways inspected;23 clear
frames,zero catch-ups,normal quit0. Evidence:docs/evidence/M012/VALIDATION.md.
M016 broader camera/aim/canopy gates and M018 performance remain pending.
Town kit M013 follows below; landmark kit M014 remains pending.

M013 replaces all24 source town structure visuals with14 footprint-sized Blender
building variants and shared metre plank/stone deck modules. Every original foot,
yaw, ID, collision flag/body and seven approved dock floors/cutouts remain fixed.
Exact skew polygons stay polygons; roof/facade art adds no blocker. Imported
COLOR_0 matte palette carries slate/terracotta roofs, plaster/timber/teal fronts,
civic/inn height variants and shop fascia, with compressed1.76–3.41m heights.
Source:art/source/alderwake_town_kit.blend; GLB/mapping:game/assets/environment/.
town_art.gd replaces only VisualRoot children, with repeated definition meshes
and50 plank/165 quay modules sharing resources. 16 kit meshes/6,110 triangles,
490,396bytes,zero external textures. Other props, inactive door labels and Maris
reservation remain existing grayboxes; no new interiors/behaviors or service.
map_town_art_checks.gd audits geometry/materials/source registration/modules;
town/water/candidate/application/companion regressions pass. Fresh ordinary WASD
town circulation/all three docks out-and-back/passenger quay tour:17 inspected
clear views,zero catch-ups,normal F10 exit0. See docs/evidence/M013/VALIDATION.md.
Candidate isolated until M015; M014 appearance completion follows below.

M014 replaces three landmark VisualRoots with the isolated authored Blender kit:
five modules/seven mesh instances,4,276 triangles,337,120bytes,portable vertex
colors/no external textures. Bridge6x3m deck/two2x3m landings/6x0.1x0.6m rails
align with existing floors/bodies;full2.8m usable corridor and floorY0 remain.
Plank top0.022m/bolt tips0.027m. Moonwell's exact fractional foot/eight-corner
catalog polygon and six physics prisms remain;low stone courses/inset blue static
spiral basin replace graybox. East gate art follows sole authored2x8m blocker,
1.48m boarded timber walls/closed-trail label;disabled source catalog body stays
absent. Source18 bridge tiles/well/gate images were reference only.
Source:art/source/alderwake_landmark_kit.blend;GLB/mapping:game/assets/environment/.
landmark_art.gd owns appearance only. Replacing art retains all816 physical
node/shape identities/transforms and same6,336-polygon navigation mesh. Seven
focused checks pass;fresh ordinary Moonwell/bridge both ways/gate contact tour,
eight clear inspected views,zero catch-ups,no saves,normal quit0. Historical
M009 reports restored;failed initial assertions/focus request retained explicitly.
See docs/evidence/M014/VALIDATION.md. Normal compact game remains selected.
Next eligible M015 activation and existing quest route only;M016 camera,M017
save compatibility,M018 performance,M019 packaged/native map gate remain pending.
