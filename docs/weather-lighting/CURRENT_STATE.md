# Current weather and lighting state

Updated 2026-10-04 (America/Vancouver). W001-W007 Done; W008-W010 Pending.
No In progress or Blocked W task. Only W007 selected this session.
Completed: clouds, world-space rain and deterministic atmospheric lightning.
Next eligible: W008 lifecycle, HUD and isolated review controls; not started.
Read CHECKLIST, CONTRACT, AGENT_PROMPT and [W007 acceptance](W007_ACCEPTANCE.md).

GameSession still owns the600-second10AM clock, seeded cached forecast and
schema5/content1 environment/light facts. GameRoot passes committed forecast/time
to WeatherVisuals and its existing EnvironmentPresenter. Cubic smooth overcast
composition reduces direct illumination/shadow contrast and distinguishes clear,
cloud, rain and storm without altering forecast arithmetic or saves. Rain density
blends0/.48/1; storms add bounded seeded atmospheric pulses. Tollworks keeps its
original stable lighting while global time advances.

Alderwake owns one WorldRain. Fixed16m world tiles contain up to576 jittered
columns; camera selection never translates drop origins. Every column starts
above actual terrain;21 imported roof bounds exclude covered areas. One shared
mesh/material and at most64 MultiMesh batches replace per-drop Nodes. Rain uses
session phase modulo64 seconds;1.6-second/6.4m fall cycles freeze on pause.
Lightning is a0.32s smooth pulse in seeded8-second windows, peak ambient+.18,
without damage/audio/additional lights. Rain disposal follows the owning location.
Camera arrives before environment/rain hydration, including paused commits.

Retained baseline: moving outdoor sun/stable indoor profile, all23 independent
lamp/window/waylight/net consumers, eight unshadowed local emitters, six typed
persistent E switches, exact v1-v4 migrations and validated restore/backup rules.
Pinned map, collision/navigation/aim/art/IDs and historical P001-P014/M001-M019
packages remain intact. Existing W006/testing local edits were preserved.

## W007 changed files

- game/features/environment/weather_visuals.gd/.gd.uid (new)
- game/features/environment/world_rain.gd/.gd.uid, world_rain.gdshader and world_rain.gdshader.uid (new)
- game/features/environment/environment_presenter.gd
- game/app/game_root.gd, game/world/alderwake_exterior.gd
- game/tests/weather_presentation_checks.gd/.gd.uid, weather_presentation_render.gd/.gd.uid (new)
- game/tests/environment_lighting_checks.gd (explicit real sunny seed for W004 phase checks)
- docs/weather-lighting/CHECKLIST.md, CURRENT_STATE.md, CONTRACT.md, W007_ACCEPTANCE.md
- docs/ARCHITECTURE.md, docs/CURRENT_STATE.md, README.md

## Verification and evidence

Final weather rules:193,417 assertions. W004 lighting30,053 and application startup
pass. Eight focused regressions pass: environment_rule_checks12,792,
environment_session_checks, environment_save_checks517, exterior_light_checks13,289,
light_interaction_checks151, location_travel_checks(ten cycles/rejections),
map_camera_checks and combat_checks. Runtime exits0 and ERROR/SCRIPT ERROR/WARNING
scans clean. Import exits0 with only known missing .NET SDK10.0.9 editor diagnostic.
Retained W001 reference/hash audit passes. Diff/link/UID/status audits pass.

Final real-render writer PID56332/reader1028 exit0.66 actual960x640 Compatibility
captures, six final contact sheets and important original views inspected.
Five views (Maris/roofed town, raised Moonwell, dense forest, bridge and ford)
show four distinct conditions in both projections; storm/night zoom0.8/1.15,
camera pan,0.4s actual D movement, natural rain-to-storm blend and flash are covered.
Actors/floor/labels/canopy/gold indoor telegraph remain readable; no visible batch
seam, camera dragging, below-ground streak or indoor leakage observed.
Rain-only paused captures0.5s apart are byte-identical; existing river TIME shader
was hidden only for that isolated test and was not changed.

Actual GUI Save -> new process GUI Load restores complete exact typed snapshot,
forecast and cloud/rain/storm/flash/phase/sun render JSON. Saved seed20/day1/
progress0.802317222222222 yields flash0.1799518128728563 and phase57.39033333333305.
Storm remains reconstructed on return; indoor original lighting/rain disposal pass.
Captured maximum36 rain batches/17,221 instances stays inside hard64 cap.
These counts are not performance acceptance. No W007 criterion remains unrun/failed.

Cwd target root; engine installed4.7.2 ed1daf0bf console. Exact commands and criteria:
[acceptance](W007_ACCEPTANCE.md). Ignored evidence runs:
prerequisites20261005-005824437-4137873e;
import/W004/startup20261005-010903287-6c38237b;
eight regressions20261005-011023448-a16ef4f4;
final weather+render20261005-011225850-d89ecce5.
Final indexes/originals under that last run's render; six sheets/capture-report under
render/derived/20261005-011333-7f1bf7d7. Earlier failed/successful runs retained.

Shared runner uses process-local APPDATA/LOCALAPPDATA in
builds/testing/W007/<unique-run>/appdata and localappdata; final run ID above.
Actual user_data: APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Debug primary user://saves/playtest-check-20261005-011225850-d89ecce5.json;
oracle user://saves/w007-oracle.json. Ordinary saves and old archives untouched.
No manual staging/package output needed; no dependency installation.

Repairs retained in acceptance: initial wrong clock constant, dummy headless
MultiMesh inspection, native class-name collision, indoor float comparison,
arrival camera ordering and fixture camera/motion clarity. All resolved.
No gate weakened. No subagent/reset/commit/push/source/generator/renderer change.
All owned Godot processes exited; no input held/editor started.
User Blender PID2664 and unrelated MCP helpers remain untouched.

Limits: forced seed/time/poses/guardian are synthetic debug review; real GUI/input
inside those sessions does not certify a normal/native full quest or package.
No new benchmark, full four-phase matrix, HUD, developer controls, audio, wetness
mechanics or NPC routine claim. W008-W010 own those remaining in-scope gates.
Next safe action: select W008 only, verify W007 from source/acceptance/current
checks, then complete lifecycle/HUD/isolated review requirements.

## Earlier completion and tooling context

W001-W006 concise acceptance remains in CHECKLIST and linked W001 references/
W002-W006 acceptance records. W006 established independent E choices and actual
GUI Save/new-process Load; no need to read its entire optional raw archive.
The authorized testing follow-up remains complete:
[tooling acceptance](../TESTING_TOOLS_ACCEPTANCE.md). Shared bounded runner,
exact typed restart/capture helpers, pause/provenance manifests, read-only bridge
observations and native path/no-overwrite guards remain unchanged this session.
Their project/installed skill copies remain as found; no additional W task selected.
