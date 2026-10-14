# Reference house study — 2026-10-13

Subsequent [remaining-house rollout](HOUSES_REFERENCE.md) is now enabled. This record describes the accepted one-house study; its source assets remain unchanged.

The long blue-roof schoolhouse behind the mill-road garden wall now uses a new Blender-authored exterior by default. This is one house study, following the accepted grass, dirt and stone-wall revisions. Other house instances retain the existing shared kit for comparison.

## Appearance and source

The replacement adds 328 staggered, overlapping blue roof tiles with beveled lower lips, a modest eave overhang and dark fascia. Warm cream plaster, timber posts and gable framing, eight layered four-pane windows with projecting sills, a planked door with iron hardware, two foundation stone courses and a capped masonry chimney replace the flat atlas details. The foundation core is recessed behind the visible stones to avoid coplanar flicker.

- Target prop: `mill-road-schoolhouse-exterior-building`, world foot `(-16, 0, 2)`.
- Editable source: [schoolhouse-reference-v1.blend](../../art/source/storybook/schoolhouse-reference-v1.blend).
- Generator: [build_schoolhouse_reference.py](../../tools/art_direction/build_schoolhouse_reference.py). Run `build()` in Blender, inspect the model, then call `export_verified()`.
- [Recipe and provenance](../../art/source/storybook/schoolhouse-reference-recipe.json) record dimensions, anchors, material names, reference hash and construction counts.
- Runtime model: [schoolhouse-reference-v1.glb](../../game/assets/environment/storybook/schoolhouse-reference-v1.glb), 913,508 bytes, SHA256 `6a632117e27024466cc680ef2221832c1742cc638dacf8af1bcff4d04711c287`.

The joined model has 11,354 triangles and seven material surfaces. `schoolhouse_reference.gd` duplicates that imported mesh and assigns fresh materials using `painted_house.gdshader`; the original shared kit remains intact. Per-part vertex colors control quiet plaster/wood variation and stronger tile-to-tile blue variation. Colors were tuned in actual Godot lighting against the supplied concept, not only Blender's preview. One sampled front plaster region is RGB 189/158/117 against approximately 190/158/116 in the reference; this is a local comparison, not a claim of whole-image equivalence.

The original 6.21875 by 1.46875 m foundation polygon, four ground corners, door center, eight window centers and 2.46 m maximum height are retained in the authored model. Roof overhang is at most 0.153 m. Original collision, navigation, gameplay metadata and doorway pads are retained. This schoolhouse had no exterior-light registry entry; its panes remain non-emissive at night.

## Verification

[Final guarded run](../evidence/HOUSE/20261014-031101409-e4091c2e/results.json) passes all nine cases: engine version, import, dependency parsing, `application_smoke`, `map_town_art_checks`, `map_landscape_checks`, `map_camera_checks`, `exterior_light_checks` and rendered comparison. Godot 4.7.2 Mono / GL Compatibility. Source fingerprint `6d546280ddb7a771dce6693744f178d25c882b339955da52af431ed2c29cca8a`, 1,480 files; `source.changed=false`, source error null.

[Capture index](../evidence/HOUSE/20261014-031101409-e4091c2e/render/house-reference-index.json) contains 30 actual engine frames: paired front/town/left/right/rear views in both projections, frozen repeat, short pan, clear/rainy night and HUD framing. All three provenance-validated contact sheets and the final close view were inspected. These are synthetic fixed camera, feet, time and weather with frozen simulation, not ordinary movement or exported-release acceptance. Screenshots are actual game output.

Geometry passes finite bounds, unit normals, winding, nondegenerate triangles, seven-surface coverage and retained foundation corner checks. Only one house uses the new mesh. Full non-house material inventories match across every same-environment toggle; existing night glow changes are recorded separately and the original day state restores exactly. Collision/navigation/metadata, all other meshes and meadow geometry remain unchanged across toggles. Clear grass/dirt pixels and frozen repeated house pixels match exactly.

The meadow still contains 3,333 clumps and 78,060 triangles in 58 batches. Compared with the preceding wall-run inventory, Godot's imported foundation coordinate differs by approximately 0.000021 m on one edge; this shifts nearby grass data in two batches at that tiny scale. Counts, distribution, shaders and all other grass batch hashes remain unchanged. No broad grass redistribution occurred.

The short paused town comparison records p95 draw calls 225 to 237 and rendered primitives 248,043 to 259,461. Frame cadence is 8.627 to 8.652 ms on the review machine. This is not a gameplay benchmark; both old/new assets remain allocated during comparison, so memory counters do not establish incremental cost.

Retained diagnostics include initial generated import/UID sidecars invalidating the first source guard, and a first fixture that incorrectly compared night glow materials against a day baseline. The corrected fixture compares complete material state within each environment, without a whitelist. The following model passes softened subpixel roof edges and recessed the foundation core. Final source and capture checks are clean. Saves/app-data were isolated. Windows packages were not rebuilt; no commit or push was made.

## Test locally

Open `game/project.godot` and restart with F5. No appearance arguments are needed. Find the long blue-roof house behind the stone garden wall near the western edge of town. Existing packaged EXEs retain their older exported appearance.

To compare the preceding house from the repository root:

```powershell
& 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --path ./game -- --house=original
```

Reproduce checks:

```powershell
./tools/run_checks.ps1 -Task HOUSE -Names application_smoke,map_town_art_checks,map_landscape_checks,map_camera_checks,exterior_light_checks -RenderScript house_reference_render -RenderPhases compare -TimeoutSeconds 240
```

[Previous house](../evidence/HOUSE/20261014-031101409-e4091c2e/render/previous-front-close-ortho.png) · [Current house](../evidence/HOUSE/20261014-031101409-e4091c2e/render/house-front-close-ortho.png) · [Town view](../evidence/HOUSE/20261014-031101409-e4091c2e/render/house-town-ortho.png).
