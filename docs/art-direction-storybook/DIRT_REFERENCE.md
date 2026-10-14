# Reference dirt paths — 2026-10-13

User accepted the meadow improvement and requested dirt paths closer to `artbook-style.png`. Normal source startup now uses painted golden earth on every existing dirt surface. Small ochre dabs, quiet worn patches and softened pale flecks replace the previous broad, smooth wash. Existing irregular grass shoulders and upright boundary growth remain in place.

## Appearance and assets

`dirt_path.gdshaderinc` samples two fixed world-space scales with a 7m primary tile and an 18% rotated secondary layer. Mipmaps, anisotropic filtering and a small positive sampling bias keep the marks readable across camera distances. Color conversion follows the approved meadow pipeline. Contrast compression and RGB gains are calibrated in the actual daylight renderer; no lighting or screenshot edits were made.

New source albedo: `art/source/storybook/dirt-path-albedo-v1.png`. Runtime copy: `game/assets/environment/storybook/dirt-path-albedo-v1.png`. Both preserve the generated 1254×1254 PNG bytes, SHA256 `aad83f1ca59a673c60b65d41e681b066bdee7218c1cfe60509c0c5664d38f5d3`. [Exact generation prompt and provenance](../../art/source/storybook/dirt-path-recipe-v1.json). Reference SHA256: `57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a`.

Clean daylight path sample median is RGB(252,193,100), compared with reference RGB(253,193,100). Final sample rectangle is (310,405)-(650,465) in the close orthographic capture; reference samples are (640,330)-(825,385) and (570,375)-(635,425). Final q10/q90 are (244,172,89)/(254,202,109). Samples guide palette and contrast; different scenes cannot establish pixel-perfect fidelity. Building detail, shore, water and broader lighting still differ from the concept.

Only terrain kind2 uses this albedo. Grass appearance, contact shading, growth geometry, sand, cobblestone, water, terrain elevations, layout, collision and navigation are retained. No meshes or draw calls added by this change. `--dirt=original` restores the preceding smooth dirt while retaining the current meadow.

## Verification

[Final guarded run](../evidence/DIRT/20261014-014556562-3f4fd0c8/results.json): engine version, dependency parse, `application_smoke`, `map_landscape_checks`, `map_camera_checks` and rendered comparison all passed. Source fingerprint `b36b40d12c71928df9793dc90563db7e7a5e547c27e647d13c9720a72757757d`, 1467 files, `source.changed=false`, source error null. Godot4.7.2 Mono, GL Compatibility.

[Capture index](../evidence/DIRT/20261014-014556562-3f4fd0c8/render/dirt-reference-index.json): 26 actual Godot frames, zero failures. Four paired views in both projections, frozen repeat, bounded short pan, paired clear/rainy night and ordinary HUD framing. Day/weather, feet and camera positions are synthetic review setup; this does not claim ordinary movement or packaged release acceptance. All three provenance-validated contact sheets were visually inspected. No obvious seams or repeats found; paths remain readable at night.

Approved grass sample pixels remain exactly identical across the dirt toggle. Meadow visibility and mesh hashes, all other shader parameters, protected terrain, physics and navigation inventories are unchanged. Frozen close pixels repeat exactly. Imported texture has ten mip levels; source/runtime bytes and dimensions match. Frozen contact view has225 p95 draw calls and210,103 primitives for both looks. Both textures stay allocated in the comparison, so memory counters are not incremental cost measurements; short timings are not a gameplay benchmark.

Initial import correctly invalidated its source guard when sidecars were generated. First rendered comparison exposed an unset false shader parameter on non-dirt materials; explicit boolean assignment repaired that fixture failure. Subsequent render passed, then final contrast calibration and full checks passed. Failed and intermediate evidence remains retained. Runner isolated all test saves and app-data; ordinary saves were untouched. Existing Windows packages were not rebuilt. No commit or push.

## Test locally

Restart the source game from Godot with `game/project.godot` open and press F5 to run the project. No appearance flags required. From repository root, the direct equivalent is:

```powershell
& 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --path ./game
```

For the old dirt comparison, append `-- --dirt=original`. Review the junction by the long blue-roof house, the Maris/Dock Row paths and the northern plaza entrance. Switch projection and zoom to inspect mark scale and grass joins. Existing packaged EXEs still show the earlier exported appearance.

Reproduce automated checks:

```powershell
./tools/run_checks.ps1 -Task DIRT -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript dirt_reference_render -RenderPhases compare -TimeoutSeconds 240
```

[Previous dirt](../evidence/DIRT/20261014-014556562-3f4fd0c8/render/previous-junction-close-ortho.png) · [Current dirt close](../evidence/DIRT/20261014-014556562-3f4fd0c8/render/dirt-junction-close-ortho.png) · [Current town](../evidence/DIRT/20261014-014556562-3f4fd0c8/render/dirt-contacts-ortho.png).
