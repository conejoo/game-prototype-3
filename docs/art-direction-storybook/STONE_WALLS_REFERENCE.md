# Reference stone walls — 2026-10-13

The user requested stone walls next, after the meadow and dirt revisions. Source startup now enables masonry on six retained garden walls, four passenger-quay walls and four low perimeter rims. Existing stone-wall bounds, collision, navigation and ground remain owned by their original systems.

## Appearance

The previous walls sampled a faint atlas at a scale that produced only one or two large courses. `stone_wall_mesh.gd` now builds a closed body and individually chamfered capstones inside each original mesh's exact bounding box. Caps are approximately0.56m long,0.15m high, with0.008m internal joints and0.023m bevels. Their real facets catch the existing scene lighting. No collider is added or moved; perimeter walls retain their separate tall escape blockers.

`painted_wall.gdshader` adds three0.15m staggered courses below the cap on ordinary0.6m walls. Taller authored walls continue the same course scale. Narrow, filtered joints, restrained painted edges and deterministic block variation distinguish stones without a noisy rock texture. Warm pale gray tops and neutral gray faces were calibrated against the supplied concept in actual Godot daylight. The shader uses fixed positions, with no animation, transparency or extra texture assets.

Fourteen replacement meshes share one material and contain41,792 triangles in total. Old meshes and materials remain available for `--walls=original`. This switch restores only the preceding wall visuals; current meadow and dirt remain enabled. Buildings, foundations, unrelated shore barriers, docks, trees and gameplay are outside this wall revision.

## Verification

[Final guarded run](../evidence/WALL/20261014-020048031-4414b57a/results.json) passed all seven cases: engine version, dependency parsing, `application_smoke`, `map_town_art_checks`, `map_landscape_checks`, `map_camera_checks` and actual rendered comparison. Godot4.7.2 Mono, GL Compatibility. Source fingerprint `8a799e70083b20bbc33f3ed63382a6bc0bfc030afdf3bfd179decd7ad576bfc9`,1471 files; `source.changed=false`, source error null.

[Capture index](../evidence/WALL/20261014-020048031-4414b57a/render/wall-reference-index.json) records30 actual Godot frames with zero failures: paired mill junction, town, Alder Rise, perimeter and passenger quay in both projections; frozen repeat; short camera pan; paired clear/rainy night; ordinary HUD framing. All three provenance-validated contact sheets were inspected. These use synthetic fixed feet/camera/day/weather and frozen simulation, not ordinary movement or packaged release acceptance. Screenshots were not generated or retouched.

All replacement vertices remain inside original bounds. Every triangle passes finite/unit-normal, nondegenerate and clockwise-winding checks. Non-wall geometry/material parameters, meadow geometry, collider properties/layers, terrain, layout and navigation hashes remain unchanged across wall swaps. Clear lawn and dirt sample pixels match exactly, as do frozen repeated wall pixels. New bevel geometry legitimately changes nearby wall silhouettes and contact shadows.

In the frozen town view, p95 draw calls remain225; rendered primitives change210,103→248,043. Short p95 frame cadence changes1.730→1.801ms on the review machine. This is a bounded paused comparison, not a gameplay benchmark; both wall versions remain allocated, so memory counters do not establish incremental memory cost.

Retained initial import correctly failed its source guard when two UID sidecars were generated. The first comparison flagged48 changed pixels in an old grass sample that touched the wall's shadow/silhouette. Inspection located all changes within(260,254)-(274,259). The final sample uses clear lawn(280,200,90,45), with exact equality still required; no tolerance or engine diagnostic rule was relaxed. That first render also guided the final warmer face and softer mortar calibration.

Runner saves and app-data were isolated. Existing Windows exports were not rebuilt; no commit or push was made. This revision improves wall fidelity without claiming the entire scene matches the concept.

## Test locally

Open `game/project.godot` in Godot and restart with F5. No appearance arguments required. From the repository root:

```powershell
& 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --path ./game
```

Append `-- --walls=original` for the preceding wall appearance. Inspect the walls beside the long blue-roof house, Alder Rise and the western boundary; change projection and zoom to compare mortar and caps. Existing packaged EXEs retain the earlier exported appearance.

Reproduce guarded checks:

```powershell
./tools/run_checks.ps1 -Task WALL -Names application_smoke,map_town_art_checks,map_landscape_checks,map_camera_checks -RenderScript wall_reference_render -RenderPhases compare -TimeoutSeconds 240
```

[Previous walls](../evidence/WALL/20261014-020048031-4414b57a/render/previous-mill-close-ortho.png) · [Current walls close](../evidence/WALL/20261014-020048031-4414b57a/render/wall-mill-close-ortho.png) · [Current perimeter](../evidence/WALL/20261014-020048031-4414b57a/render/wall-perimeter-ortho.png).
