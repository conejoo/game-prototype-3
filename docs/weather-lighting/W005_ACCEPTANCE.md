# W005 acceptance

Completed 2026-10-04 (America/Vancouver). W005 was the only selected task.
W001-W004 prerequisites checked against current code, pinned reference audit and
[W004 acceptance](W004_ACCEPTANCE.md). Initial tree contained uncommitted W004
files; those changes were preserved. Historical P/M records/packages and normal
saves remain intact. W006 has not started.

## Criteria and evidence

| Criterion | Verified result |
| --- | --- |
| All 23 registry entries have intended consumers | Production Alderwake explicitly builds ExteriorLights; all six lanterns, fourteen window sources, two answer-lights and the woven-lights source bind to the existing wrappers. Runtime mapping is a target-local subset of W001 recipes. Registry/default/anchor checks and one inspected default-night capture per source pass. No invented building source or external runtime dependency. |
| Reusable authored lamp, waylights and nonblocking net | Six-mesh Blender kit contains frame/core pairs for lamps/waylights and frame/knots for the net. Editable source and authoring script under art/source; runtime GLB under game/assets/environment. GLB audit verifies exactly six meshes/nodes, one scene, 2,344 triangles, 186,252 bytes, embedded geometry and no camera/animation/image/external URI. Imported opaque rough palette materials match existing stylized art. |
| Correct source defaults and independent overrides | W001 registry remains the enabled-state authority: dock-lamp-01..05 off, dock-row-lamp-01 on, ten windows on/four off, both waylights/net on. Every consumer owns its glow material. Synthetic overrides arm one lamp, disable another and return to daylight without changing other sources; codec517 regressions remain passing. No E command was added. |
| Physical anchors and pools align with art | Lamp local anchor (-0.1875,1.55,-0.265625), range1.8946m; waylight (0,0.65,-0.125), range0.9517m. Ranges include physical height, intended1m/.625m ground radius and margin. Net knot display centred around (0,1,-0.45), emission only. Numeric anchors/feet/yaw and actual day/dusk/night/dawn town/waylight captures pass. Dock Row on versus emission-only frames visibly isolate warm illumination on deck/shore. |
| Dedicated windows; walls do not emit | Panes follow original mapped wall edges at fractions.23/.77 and authored heights, with0.0095m outward offset between original glass and crossbars. Four panes per window leave0.05m dark mullion gaps. Typical source has32 panes; civic two-level sources64. Tests inspect every vertex against recipe and original building material emission stays disabled. Captures show dark walls/roof/crossbars and aligned bright panes, including both zoom endpoints; no depth repair required. |
| Visible on/off and dawn/dusk intensity | Source light-opacity knots use the retained smoothstep: day0, dusk.42, night1, dawn.62, then0 by.96. All23 night defaults, two town/facade and both waylight four-phase matrices in both projections, lamp override comparisons and net knots inspected. Off sources stay dark; daytime enabled lamps remain armed with no emission/local energy. |
| Bounded illumination does not change facts | Exactly eight fixed-identity unshadowed Omni nodes: six lamps/two waylights. Windows/net emit only. Spatial smoothstep fades illumination between12m and18m horizontal hero distance, independently of enabled state and visible mesh emission. Near/mid/far tests preserve overrides and full source emission; all23 materials remain independent. Total scene count bounds every batched mesh to <=8 local lights; actual Compatibility setting remains8. Armed-town capture checks existing batched terrain/trees without missing required light consumers. |
| Wrapper, physics, aim/nav and lifecycle preservation | Only VisualRoot grayboxes are replaced or supplemented. Exact source wrapper feet/yaw, identities, collision metadata and source snapshot unchanged; consumers add no physics/nav. Existing town-art/forest/interaction/application checks pass. Pause freezes presentation; indoor travel disposes old consumer owner, return rehydrates defaults; ten-round-trip regression and W004 commit/rollback/profile checks pass. |

## Commands, isolation and inspected outputs

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot console: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`;
installed `4.7.2.stable.mono.official.ed1daf0bf`.
Python: `C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
Blender: `C:/Program Files/Blender Foundation/Blender 5.2/blender.exe`,5.2.2 LTS.

Every Godot run sets process-local APPDATA=`<cwd>/builds/weather-lighting/W005/appdata`
and LOCALAPPDATA=`<cwd>/builds/weather-lighting/W005/localappdata`.
Observed user_data is APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Debug slots begin w005; test-created w003-codec/P005 directories stay beneath that
isolated user_data. No normal save writes, restart/native evidence or package export.

Raw evidence: ignored `docs/evidence/W005/run-20261004-01/`.
Final renderer: Compatibility/OpenGL3.3, NVIDIA RTX4070 Laptop driver581.29,
960x640, both projections, default zoom1 plus.8/1.15 facade review. All65 PNGs
inspected through six labeled sheets and original lamp comparisons. Startup pause
was confirmed; simulation remained paused with overlay hidden for source matrices.
Maximum observed single-frame draw count421 is context, not a performance gate.

| Invocation | Exit/result | Evidence |
| --- | --- | --- |
| Python `docs/weather-lighting/reference/audit.py` | 0; four sources,23 lights,49 forecasts and pinned map | reference-audit.log |
| Blender MCP read-only scene/art inspection; execute `art/source/build_exterior_light_kit.py` | six-mesh isolated scene, GLB/library source; existing RecoveryVessel restored | authored files and art/exports/exterior_light_kit.json |
| Blender `--background art/source/exterior_light_kit.blend --python builds/weather-lighting/W005/prepare_light_source.py` | 0; editable mainfile,6 meshes/active W005 scene | source-prepare.log |
| Python `builds/weather-lighting/W005/audit_assets.py` | 0; exact six-mesh/2,344-triangle GLB and all23 mapping rows | asset-audit.log |
| Godot `--headless --editor --path game --import --quit` | 0; script/import clean; known missing .NET SDK10.0.9 diagnostic only | import-final.log |
| Eight headless checks below | each0; runtime-error/warning scans clean | regression-results.json and named .log files |
| Godot `--path game --script res://tests/exterior_light_render.gd -- --save-slot=w005-render-final --report-dir=res://../docs/evidence/W005/run-20261004-01/render-final` | 0;65 captures, engine PID21856; runtime scan clean | render-final.log, render-final/index.json,65 PNGs/six sheets |
| Python capture metadata/link/status/UID/runtime audit and Git `diff --check` | 0; metadata, local links, task/handoff consistency and whitespace clean | handoff-audit.log, diff-check.log |

Headless invocation for each name:
`--headless --path game --script res://tests/<name>.gd -- --save-slot=w005-<name>`.
Names: exterior_light_checks (13,289 assertions, engine PID39828),
environment_lighting_checks (30,053), environment_save_checks (517, PID6080),
application_smoke, interaction_dialogue_checks, location_travel_checks (ten round
trips and rejection cases), map_town_art_checks and map_forest_checks.
Ignored runner `builds/weather-lighting/W005/run_checks.ps1 -Import -Render`
records arguments/cwd/isolated paths/exits/scans. Its prior renderer PID10884
produced65 captures under render-verified; final UI-label rerun is recorded above.

GLB SHA256: `fe0ad843e490d26946ef0512950c62f8612b89c2109a55d4583e0f6c06e00885`.
For fresh background regeneration, run Blender `--background --factory-startup
--python art/source/build_exterior_light_kit.py`; the script saves an editable
mainfile in background mode and a scoped library snapshot when invoked live.
Live scene names are intentionally protected against implicit replacement.

## Focused repairs and limits

Initial Blender export included other already-authored scenes because its default
exports multiple scenes. Inspection caught this before import. Authoring now uses
use_active_scene=True; final GLB audit proves only the six required meshes/nodes.
No old source object was deleted. Dormant core vertex colors are intentionally not
exported because core materials are overridden per instance in Godot.

Initial runtime rejected nine local lights: the net recipe explicitly contains a
zero range. Allocation now requires positive range, leaving net emission only.
That failed startup remains in checks-initial.log. A later test incorrectly used
the source collision_enabled flag to infer a collider; the pinned net has no
collision shape despite that flag. Test now inspects actual CollisionObject3D
absence, preserving all source metadata. checks-second.log retains that failure.
Final13,289 checks pass; no criterion was weakened.

Initial sandbox import/check logs retain Windows certificate-store errors.
Approved outside-sandbox isolated Godot runs remove those; final import retains
only the known missing .NET SDK10.0.9 editor diagnostic. Background source
preparation also retained a sandbox userpref read warning but successfully saved
the editable task-owned source, without writing preferences. Initial63-capture
review is preserved; a65-capture refinement added Dock Row illumination isolation.
Final rerun also synchronizes camera UI labels after synthetic projection changes.

All W005 criteria passed. Forced phases/poses/overrides are explicitly synthetic;
they do not prove normal E input, a native route/restart, weather or frame budgets.
W006 owns E switching/persistence acceptance; W007-W010 retain weather, final
lifecycle/HUD, measured performance and packaged/native acceptance. Historical
packages remain unchanged. No commit/push/subagent/install/renderer change.

All owned Godot/background processes exited and no input was held. Existing live
Blender PID2664 remains on RF-RecoveryVessel with its original file/selection and
viewport; the separately saved RF-W005-ExteriorLightKit scene remains available.
Next eligible task: W006 only.
