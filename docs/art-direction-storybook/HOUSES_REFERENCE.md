# Remaining reference houses — 2026-10-13

All 20 remaining exterior building instances now use detailed Blender-authored meshes across 13 designs. The accepted [schoolhouse study](HOUSE_REFERENCE.md) and its shader remain byte-identical. Normal source startup enables all 21 detailed buildings, following the accepted grass, dirt and wall revisions.

## Appearance and source

Staggered overlapping roof tiles, warm plaster, timber posts and gable framing, layered four-pane windows and sills, plank doors with hardware, two foundation stone courses and capped chimneys extend the schoolhouse treatment. Slate, terracotta, teal dockside and woodland palettes retain the existing building identities. Civic buildings retain their taller walls and turrets; shops retain fascia bands. Skewed dockside and inn footprints receive edge-aligned details.

- Generator: [build_houses_reference.py](../../tools/art_direction/build_houses_reference.py).
- Editable source: [houses-reference-v1.blend](../../art/source/storybook/houses-reference-v1.blend).
- [Recipe and provenance](../../art/source/storybook/houses-reference-recipe.json) record the source dimensions, construction counts and reference hash.
- Runtime asset: [houses-reference-v1.glb](../../game/assets/environment/storybook/houses-reference-v1.glb), 10,137,864 bytes; SHA256 `5e5cababbf60d529b4bbdbf8125ca984530b2e7f0c765eb3cafc2b987e939425`.
- Integration: [houses_reference.gd](../../game/world/map_candidate/houses_reference.gd) and [town_art.gd](../../game/world/map_candidate/town_art.gd).

The kit contains 13 meshes, seven material surfaces per mesh and 126,410 unique triangles; the 20 placed instances total 187,604 triangles. Runtime meshes share 35 materials across five palette families. The original shared building kit remains intact for comparison. Roof colors were calibrated in actual Godot lighting; the final sampled terracotta region is approximately RGB 205/93/45 versus 209/95/41 in the concept. This local sample does not establish whole-image equivalence.

Coverage includes Alderwake Hall, Lantern Rest, Mayor Vale's home, Reed Chandlery, Tess General Goods, the passenger shelter, two net sheds, two woodland cottages, two dockside homes and eight plaster/timber homes with slate/terracotta roofs.

## Preserved behavior

Original ground polygons, opening horizontal anchors, maximum heights, collision, navigation, metadata, entry pads and light identities remain intact. Roof overhang stays within 0.16 m. `meadow_growth.gd` reads each replacement's original foundation mesh metadata, preventing imported-coordinate rounding from changing grass distribution. The complete meadow geometry and metadata inventory matches the accepted schoolhouse run exactly: 3,333 clumps, 26,020 blades, 78,060 triangles and 58 batches.

The short passenger shelter needs one deliberate visual correction: its original door and windows protruded above its 0.85 m wall. New windows are centered at 0.52 m with 0.55 vertical scale; the door top is 0.75 m. Horizontal anchors, widths, footprint and maximum height remain unchanged. The shelter has no registered window lights.

All 14 existing window-light consumers retain their independent state: ten on and four off in the fixture. Existing glow planes remain outside the new recessed glass. All seven replacement material types remain non-emissive; registered glow panes supply the existing night behavior. The accepted schoolhouse has no registered night windows and remains unchanged.

## Verification

[Final guarded run](../evidence/HOUSES/20261014-033626282-7ef491b1/results.json) passes nine cases: engine version, import, dependency parsing, `application_smoke`, `map_town_art_checks`, `map_landscape_checks`, `map_camera_checks`, `exterior_light_checks` and rendered comparison. Godot 4.7.2 Mono / GL Compatibility. Source fingerprint `9b7920d939b01ec7ef4526b62588ddcee5217ac092c21c1ab695af392478302d`, 1,487 files; source unchanged and source error null.

[Capture index](../evidence/HOUSES/20261014-033626282-7ef491b1/render/houses-reference-index.json) records 56 actual engine frames: representative before/after views in both projections, every design by day and night, town comparisons, frozen repeat, camera pan, rain and HUD framing. All five provenance-validated contact sheets and selected close views were inspected. These are fixed-camera synthetic checks with frozen simulation, not ordinary movement or exported-release acceptance.

All 13 meshes pass bounds, normals, winding, UV/color, nondegenerate-triangle, retained ground-corner and roof-overhang checks. All 352 registered pane probes pass: the new glass sits behind the existing glow plane without intervening trim. Protected geometry, collision, navigation, metadata and accepted schoolhouse remain identical across toggles. Cached materials match at the same weather/time, night material changes are recorded, and the frozen repeated house region matches exactly.

The short frozen town comparison records p95 draw calls 229 to 385 and primitives 280,267 to 416,435. Frame cadence is 8.606 to 8.643 ms on the review machine. This is not a gameplay benchmark. Both original and replacement assets remain allocated for comparison, so memory counters do not establish incremental cost.

Retained diagnostics: the first import generated sidecars and invalidated its source guard; an editor Mono SDK warning also occurred. Subsequent guarded imports/runtime checks passed without an installation change. The first render found eight tiny bevel triangles in narrow foundation end fragments; removing bevels from fragments below 12 mm resolved them. Initial orange roofs were too bright and were calibrated before the final run. Final geometry counters and failure list are empty. Saves and app-data were isolated. No Windows package rebuild, commit or push.

## Test locally

Open `game/project.godot` and restart with F5. No appearance flags are needed. Check the town houses, shops, civic buildings, woodland cottages, net sheds and passenger shelter. Existing packaged EXEs retain their older exported appearance.

Compare the previous remaining houses while keeping the accepted schoolhouse:

```powershell
& 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --path ./game -- --houses=original
```

The separate `--house=original` flag still affects only the schoolhouse study. Reproduce the complete guarded checks from the repository root:

```powershell
./tools/run_checks.ps1 -Task HOUSES -Import -Names application_smoke,map_town_art_checks,map_landscape_checks,map_camera_checks,exterior_light_checks -RenderScript houses_reference_render -RenderPhases compare -TimeoutSeconds 300
```

[Town view](../evidence/HOUSES/20261014-033626282-7ef491b1/render/houses-town-ortho.png) · [Terracotta house](../evidence/HOUSES/20261014-033626282-7ef491b1/render/houses-house-timber-terracotta-ortho.png) · [Dockside house](../evidence/HOUSES/20261014-033626282-7ef491b1/render/houses-house-dockside-ortho.png) · [Dockside at night](../evidence/HOUSES/20261014-033626282-7ef491b1/render/houses-house-dockside-night-ortho.png).
