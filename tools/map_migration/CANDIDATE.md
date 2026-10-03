# M003–M007 isolated terrain, water, crossing, town and forest candidate

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
```

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
Structure rims are 1m high, other blockers 0.6m, on the flat preview only.

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

Physical elevations/ramps remain flat until M008. Provisional navigation bakes
only explicit dry row-run triangles, clipping rail footprints and omitting effective water/gate before baking; it never
parses blocker tops, art or the full base floor. Radius0.4m, height1.6m, climb0.1m,
cell0.2m/height0.1m, contour error0.1 preserve bank corners. Recast surface is
Y0.2; gameplay floor remains Y0. This is temporary flat lifecycle support;
M006 projects town footprints and effective southern-water pieces as obstructions
with an extra 0.2m nav-only margin to prevent measured fractional corner cuts.
M009 owns complete physical-surface navigation, loading and route acceptance.
M010 still owns connected companion recovery. No new AI/service/save ownership.

M007 adds all 395 trees (nine species; 65 small/266 standard/64 large) and 17 remaining
props, bringing candidate to 468 unique prop wrappers / 455 enabled footprints.
Exact catalog trunk boxes/polygons, fractional feet, yaw and complete source
records are retained. Species colors and 0.9/1.4/1.8m size prisms are diagnostic
grayboxes, with flat preview feet; source heights stay in metadata for M008.
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
[PLAYTEST.md](../PLAYTEST.md), with a fresh `builds/playtest/m007-*` directory and
named test slot. Its commands inject ordinary viewport input, with no teleport
or session mutation. Use short resume/actions/pause batches and confirm pause.
Headless checks label their synthetic actor placements/physics stepping explicitly.
