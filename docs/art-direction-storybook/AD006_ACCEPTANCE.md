# AD006 painted dock, plaza and low-wall acceptance

Done, 2026-10-11 UTC. Exactly AD006 implemented. AD002/AD005 prerequisites verified from their acceptance records, source/runtime files and current handoff. Starting HEAD `65cfcca3d8f5b8d62fe911dd7aee2bf700c46232` is context, not a checkout target. Initial unrelated inputs were `art/direction/`, this workflow's AGENT_PROMPT/CONTRACT and `docs/interiors-map-migration/`; all preserved. No commit, push or AD007 implementation.

## Result and acceptance

| Criterion | Evidence and outcome |
| --- | --- |
| Shared painted boards, muted plaza stone and low walls | One RGB1024 atlas with three padded regions, broad broken strokes and restrained symmetric mortar. Original dock/quay modules receive full-face UVs; existing semantic cobblestone samples the plaza region in world metres. Six current town garden walls plus four authored passenger basin/quay walls share one stone shader material. Other props, counter, buildings, forest-owned markers and pilings/baffles retain their existing appearance. |
| Dock, sandy/apricot routes and plaza remain distinct; actors remain readable | Inspected all 50 final engine captures: street/river/plaza/quay, both projections, zoom0.8/1/1.15, clear day/night, close angles, checker controls and fresh ordinary approach. Timber is warm brown, routes retain their existing warm yellow/apricot, stone is quiet grey-sage; cyan/purple actors, white rod and lamp remain identifiable. Plaza local fine pixel delta decreases6.021 to2.359. Dock luma91.216 to105.631; its retained physical board joints remain sharper than the broad paint, so its local pixel delta increases5.894 to10.390 rather than claiming all detail decreased. |
| Matching texel scale, intentional coverage, no introduced gaps/seams/z-fighting/alpha overdraw |64texels/m on every source-module face. One shared cached UV-crop mesh handles the four half-metre dock edge pieces without altering vertices/transforms/material. Full-precision imported UV attributes make the engine's per-triangle world-density assertion pass within0.05texels/m. Both checker views inspected, including fractional pieces; no missing face or incompatible atlas bleed. Dock/wall static-repeat crops are pixel-identical after0.5s. Existing authored grooves remain; no new coverage gap, flickering duplicate surface or alpha pass introduced. |
| Local stone contact accents rather than directional baked sun shade | Atlas contains low-contrast symmetric mortar/brush marks only; no AO/sun-shadow texture, displacement, normal map or emission. Existing moving sun and lamp owners remain unchanged. |
| Preserve module/footprint/deck/navigation invariants and ordinary approach | Both exported72-triangle modules match original triangles at1e-5m. Tests retain24 structures/16 kit meshes/6110 triangles/168 exact base samples,215 modules/165 quay cells,48m² dock area/seven rectangles and deck top0.022m. Town physics37325 probes/18325 path samples/74 physical routes; crossings4032 clearance/floor probes/94 walk-dodge lanes/four rail slides. Fresh normal WASD preflight plus four successful dock/return routes, with no position/session/weather setup in that process. |

## Changed files and deliberate adaptations

22 task paths, excluding ignored raw evidence:

- `art/source/storybook/alderwake_dock_pilot.blend`, `dock-painted-albedo.png`, `dock-painted-recipe.json`.
- `game/assets/environment/storybook/alderwake_dock_pilot.glb`, its `.import`, extracted `alderwake_dock_pilot_dock-painted-albedo.png` and `.import`, shared `dock-painted-albedo.png` and `.import`.
- `game/world/map_candidate/town_art.gd`, `painted_wall.gdshader` and `.uid`, `landscape.gdshader`, `landscape_materials.gd`.
- `game/tests/map_town_art_checks.gd`, `art_direction_dock_render.gd` and `.uid`.
- `tools/art_direction/paint_dock_atlas.py`, `export_dock_pilot.py`.
- This acceptance, CHECKLIST and CURRENT_STATE.

Authoring uses separate background Blender5.2.2 LTS, opening the original town source without saving it and retaining unchanged geometry/topology in a sibling scene. Read-only live MCP scene preflight produced no result and was terminated; no live editor state changed or second server installed. Atlas script is deterministic(seed6006), source/render swatches `#62442E`, `#777C73`, `#74796F`;64texels/m,16px dilated gutters. The packed source and GLB each contain one image and one shared material; no cameras/lights/animations/collisions exported. Original .blend/GLB/mapping and other asset/source pins remain intact. Intermediate sibling backup moved into ignored authoring evidence, leaving only final source in versionable scope.

The town adapter disables vertex palette multiplication for the two new modules and shares their matte material. It changes only selected low-wall `material_override` resources. Closed procedural walls use dominant world-plane projection; semantic cobblestone keeps its existing coverage and shoulders. Full metre UVs plus the shared fractional crop replace scale-induced texture stretch. `meshes/force_disable_compression=true` applies only to this small two-mesh GLB because compressed UVs failed the strict thin-face density assertion. Tests extend the prior painted-shop policy narrowly to these two modules and retain all unpainted/physical/source-ID checks; new opaque/mip/density/shared-resource/wall-coverage checks add meaningful guards.

Runtime albedo imports are RGB8 sRGB, lossless(mode0), full mips, linear mip filtering and clamp. One embedded-import atlas copy and one active shared image remain resident:8,388,606 extra texture bytes, about8MiB, recorded rather than hidden. No per-instance material, node or surface expansion. One additional shared fractional mesh replaces existing edge visuals. Final short quay observation: draw516 before/after, nodes4067 before/after, resources445 to454, buffer19,910,476 to19,929,628 bytes; frame p95/p99 before2.852/3.420ms, after2.742/3.346ms. Hardware Ultra9 185H / RTX4070 Laptop / NVIDIA581.29 OpenGL3.3. These frozen120-frame observations do not pass AD019:516 draws already exceeds its declared500-draw target in this extra quay view, and no process memory/travel-growth/full measurement was run here.

## Commands and engine evidence

Cwd for commands: `D:/development/game-dev-blender/returning-fair-prototype`. Runner invoked through installed PowerShell7 at `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`, `-NoProfile -File`. Godot console4.7.2 at workspace-documented path, `game/`, Compatibility960x640. Analysis Python `C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe`; Blender `C:/Program Files/Blender Foundation/Blender 5.2/blender.exe`.

```powershell
# Source authoring; both commands exit0 (Blender stdout retained).
& $analysisPython tools/art_direction/paint_dock_atlas.py
& $blender --background --python tools/art_direction/export_dock_pilot.py

# Fresh unchanged-production baseline:3/3 exit0,41 real captures.
./tools/run_checks.ps1 -Task AD006 -RenderOnly -RenderScript art_direction_dock_render -RenderPhases before -TimeoutSeconds 180

# Final full-precision import/density gate:4/4 exit0.
./tools/run_checks.ps1 -Task AD006 -Import -Names map_town_art_checks -TimeoutSeconds 180

# Final acceptance:8/8 exit0, stable1352-file source identity.
./tools/run_checks.ps1 -Task AD006 -Names application_smoke,map_town_art_checks,map_town_checks,map_crossing_checks -RenderScript art_direction_dock_render -RenderPhases pilot,approach -TimeoutSeconds 180

& $analysisPython tools/capture_evidence.py docs/evidence/AD006/20261011-064336010-9cef4899/render/dock-index.json docs/evidence/AD006/20261011-064336010-9cef4899/render/dock-approach-index.json
& $analysisPython docs/evidence/AD006/authoring-20261011/audit.py
& $analysisPython docs/evidence/AD006/authoring-20261011/compare.py
git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype diff --check
```

Baseline [results](../evidence/AD006/20261011-062651202-81a1fbfc/results.json); final import [results](../evidence/AD006/20261011-064303716-f48cf80e/results.json); final acceptance [results](../evidence/AD006/20261011-064336010-9cef4899/results.json). Final digest `c296990f309b3b790f229675b009da71c38300451206ffbabcfdb12541698284`, source.changed=false/error=null, all8 cases exit0, no timeout/forbidden runtime diagnostic.

[Final45 synthetic views/index](../evidence/AD006/20261011-064336010-9cef4899/render/dock-index.json), [five ordinary input views/journey](../evidence/AD006/20261011-064336010-9cef4899/render/dock-approach-index.json), [50-frame provenance/hash report and five sheets](../evidence/AD006/20261011-064336010-9cef4899/render/derived/20261011-064446-4636c1ea/capture-report.json). All five final sheets and full-size dock/quay checker, wall/quay close, ordinary dock arrival, representative river/street/plaza/day/night/projection frames inspected. Four baseline sheets also inspected.35 comparable labels preserve exact feet/ally/camera/environment/HUD time; corrected wall/quay close crops are explicitly excluded from paired comparisons. [Comparison](../evidence/AD006/authoring-20261011/comparison.json) verifies identical semantic/floor/all16 terrain-water-riser fingerprints and stable final town geometry/transforms. [Asset/pin audit](../evidence/AD006/authoring-20261011/asset-preservation-audit.json) verifies all1592 starting pins except the six authorized existing paths, original144 module triangles, padded UVs/no COLOR_0, opaque RGB image and identical embedded/runtime pixels. Original layout hash remains `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`.

Synthetic views pin day11:12/night1:00 clear presets, frozen actors/routines, fixed feet and close camera poses. Ordinary process starts fresh default town at(0,0,0), uses a15-physics-frame D preflight then TestRunJourney.walk to(-6.5,0,14.1),(-6.5,0,15.5),(-8,0,18.25) and back; every route passes unchanged0.16m arrival tolerance and owner/focus/stall/release checks. Render-approach PID22200 differs from pilot36984. Captures require observed pause overlay before hiding it for the PNG. No teleport, fact/quest/reward/environment/actor mutation, Save/Load or fixture restore in the ordinary process. This proves viewport/game input integration, not native hardware/export or GUI restart acceptance.

## Retained attempts, isolation and stop

Raw AD006 run folders retain every attempt. Initial sandbox import failed CIM ownership observation; guarded elevated runners then worked. First fixture/asset imports generated UID/import/extracted-image bytes and correctly invalidated source identity; stable reruns followed. Existing exact import-only.NET10.0.9 SDK diagnostic is retained, not allowed during runtime. Initial renderer rejected the fixture's nil index array on unindexed procedural meshes; fixed fixture handling. A phase reused `dock-index.json` and was correctly refused; ordinary phase now uses its own index. First normal waypoints(-7.5,0,11) and(-6.5,0,13) were outside current nav near the counter; no arrival guard loosened, production/nav unchanged, final route uses clear14.1 landing. Close wall/quay focus labels were corrected to the actual surfaces. Palette/coplanar UV repairs and later fractional UV/full-precision import gate are retained in previous captures/results. Diagnostic pixel helper initially treated RGBA as RGB and mislabeled a plaza crop as sand; corrected to explicit RGB and an unchanged apricot path crop. Nonfatal Python base-runtime warning retained. No failed attempt is promoted to acceptance.

Each runner case uses unique AD006 appdata/localappdata/save group under `builds/testing/AD006/<run>`; render phases share their own isolated group and start independent processes. Ordinary user saves untouched; no Save request issued. Final launcher62024/engine36984(pilot) and launcher23056/engine22200(approach), plus every owned attempt PID, have exited. [PID cleanup audit](../evidence/AD006/authoring-20261011/cleanup-pids.json); read-only CIM scan found no remaining Godot process or read-only MCP helper. No keys held, live editor changed or cleanup owed.

All AD006 criteria complete; no blocker or unrun required criterion. Schema8/content1 and historical R016 incomplete remain. Next eligible AD007 only: inspect current sun/weather/pooled lights and calibrate shared day/night/weather against the completed pilot, preserving ownership and light cap. Remaining unfinished AD007-AD020. Checklist ends AD020; every item complete: no. User requested implementation review before separate commit instruction; no staging/commit/push here.

Authorized commit follow-up (2026-10-11 UTC): user supplied the separate successful-task commit instruction after review. Commit scope is exactly22 AD006 paths, including acceptance/checklist/handoff; unrelated direction/interiors/prompt/contract inputs and ignored raw evidence remain excluded. Accepted source bytes and unrelated-file preservation verified before documentation-only updates/staging. Exact verified commit identity/tree/path/blob scope and final status recorded after commit in `docs/evidence/AD006/authorized-commit-20261011/commit-audit.json`. Pre-existing quay516-draw observation and AD019 profiling limit retained. AD001-AD006 remain Done, AD007-AD020 Pending. No push or AD007 implementation.
