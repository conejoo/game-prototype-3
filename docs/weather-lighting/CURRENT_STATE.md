# Current weather and lighting state

Updated 2026-10-04. W001-W005 Done; W006-W010 Pending. No active/blocked W task.
Completed: W005 exterior light assets and source bindings. Next eligible: W006.
Read CHECKLIST, CONTRACT, AGENT_PROMPT and [W005 acceptance](W005_ACCEPTANCE.md).
W004 moving sun/profile evidence remains in [W004 acceptance](W004_ACCEPTANCE.md).

Production Alderwake explicitly builds one ExteriorLights compositor with23
wrapper-owned ExteriorLightConsumers. Existing registry/state own identities,
instance defaults and saved override resolution. Six dock lamps, fourteen window
sources, two waylights and one nonblocking woven net all have visual consumers.
Five dock lamps default off; Dock Row on; four window sources off. Each consumer
owns its glow material; original imported wall/roof material never emits.

One reusable six-mesh Blender light kit (2,344 triangles/186,252-byte GLB) supplies
lamp/waylight frame/core and net frame/knots. Editable source and rebuild script
live under art/source; runtime kit/23 physical recipes under game/assets/environment.
No source-checkout/runtime reference dependency. W001 mapping values retained.
Windows follow actual wall polygons with four panes around each existing crossbar;
0.0095m outward registration passes both projections and zoom endpoints.

Exactly eight fixed-identity unshadowed Omni emitters: six lamps/two waylights.
Windows/net emit only. Lamp height1.55m/range1.8946m; waylight.65m/.9517m.
Source light-opacity smoothstep follows day0/dusk.42/night1/dawn.62/day0.
Illumination fades with horizontal hero distance12..18m without changing enabled
facts or mesh emission. No temporal timer or shader TIME added. GameRoot presents
through its existing gate/committed rebinding; pause freezes and indoor replacement
releases exterior resources. W006 E commands are not implemented.

W003 schema5/content1 clock/uint32 seed/six validated overrides remain unchanged.
W004 presenter/outdoor sun/stable Tollworks profiles retained. Physical wrappers,
source IDs/defaults/fractional feet/yaw, collision, aim/navigation, geography and
canopy policy untouched. P001-P014/M001-M019 summaries/packages preserved.

W005 changed files:

- art/source/build_exterior_light_kit.py, exterior_light_kit.blend
- art/exports/exterior_light_kit.json
- game/assets/environment/exterior_light_kit.glb/.glb.import, exterior_light_mapping.json
- game/features/environment/exterior_lights.gd/.gd.uid, exterior_light_consumer.gd/.gd.uid
- game/world/alderwake_exterior.gd, game/app/game_root.gd
- game/tests/exterior_light_checks.gd/.gd.uid, exterior_light_render.gd/.gd.uid
- docs/weather-lighting/CHECKLIST.md, CURRENT_STATE.md, CONTRACT.md, W005_ACCEPTANCE.md
- docs/ARCHITECTURE.md, docs/CURRENT_STATE.md, README.md

Verification: reference/hash/asset audit; Godot import; eight focused headless
checks (consumer13,289; lighting30,053; codec517; application, interaction,
ten-round-trip travel, town-art and forest). All final runtime exits0/error and
warning scans clean. All65 actual960x640 Compatibility captures inspected through
six sheets and full-size lamp comparisons: each23 default-night sources, four-phase
town/facade/both-waylight matrices in both projections, on/off/emission-only,
armed-town and facade zoom endpoints. Ground pools visibly supplement emission;
windows stay registered and wall/roof/crossbars remain non-emissive. No W005
failed/unrun criterion. Commands and exact results in acceptance.

Cwd target root; process-local APPDATA=builds/weather-lighting/W005/appdata,
LOCALAPPDATA=builds/weather-lighting/W005/localappdata. Observed user_data beneath
APPDATA/Godot/app_userdata/Returning Fair — Prototype. Named debug slots begin
w005; codec/P005 test directories stay isolated there. Normal saves untouched.
Raw evidence ignored at docs/evidence/W005/run-20261004-01; final render-final
index/65 originals/six sheets. Final consumer engine PID39828, codec6080, renderer
21856. Ignored runner/asset/capture/handoff audits under builds/weather-lighting/W005.
Final import retains known missing .NET SDK10.0.9 editor diagnostic.

Retained repairs: initial exporter included other scenes; active-scene-only final
GLB audited. Zero-range net recipe initially allocated a ninth emitter; now only
positive ranges allocate. Net's retained collision_enabled flag does not imply a
shape; test inspects real absence. Initial sandbox certificate-store failures,
failed checks and initial/intermediate render runs preserved. Final camera labels
synchronize after synthetic projection changes. Source snapshot prepared as normal
editable mainfile; background userpref read warning changed no preferences.

Initial Git tree had W004 modifications/untracked files; preserved. No reset,
commit/push/subagent, source generator/install/renderer change, native input or
user editor mutation. All owned game/background processes exited; no held input.
Existing live Blender PID2664 remains on RF-RecoveryVessel (original empty filepath,
selection/viewport preserved); isolated saved RF-W005-ExteriorLightKit scene remains.

Remaining limits: phase/pose/override review is synthetic. No normal E/restart,
full quest/native route, weather, frame benchmark or package claim; W006-W010 own
those. Historical schema4 packages remain unchanged. Next safe action: select W006
only, extend typed interactable light action and existing command/input boundary,
then prove independent switching, gates and isolated Save/restart/Load persistence.
