# Current weather and lighting state

Updated 2026-10-04 (America/Vancouver). W001-W009 Done; W010 Pending.
Exactly W009 selected/completed this session. Next eligible W010 only; not started.
Read CHECKLIST, CONTRACT and AGENT_PROMPT. Initial Git tree clean; no nested AGENTS.
Installed Godot paths verified; user Blender2664 and existing MCP helpers preserved.
All owned Godot processes exited; no held native input or live test editor.

## W009 result and changed files

[W009 acceptance](W009_ACCEPTANCE.md) contains every criterion, command, failed
attempt, focused retest, isolation path and raw selection. No failed/unrun W009
criterion remains. Production behavior, assets, renderer, schema5/content1,
geography/IDs/physics/navigation and normal saves unchanged. Parent architecture/
README/state need no production-behavior edits. P001-P014/M001-M019 and prior
[user-requested testing improvements](../TESTING_TOOLS_IMPROVEMENTS.md) preserved.

- game/tests/weather_visual_matrix.gd/.gd.uid: detached review;256 exterior
  phase/weather/view/projection/zoom combinations; eight night combat, eight
  default lamp/waylight, four pause/rollback and four indoor telegraph captures.
  Physical aim tolerance0.15m; all64 indoor presets exclude rain. Synthetic setup.
- game/tests/weather_performance_profile.gd/.gd.uid: inherits M018 full unpaused
  root/cadence/draw/navigation/inventory/travel;10s/three60s per case. Clear-day
  defaults, storm-night all six lamps. Real seed/phase resets between samples
  only. Actual foreground checks and fail-fast; full/storm/ford subset selection.
- tools/weather_lighting/profile_weather.py: isolated appdata/fresh W evidence,
  actual engine PID/hardware/Win32 memory/raw logs, deadline/owned-tree cleanup.
- tools/weather_lighting/audit_profile.py: independent24-case raw percentile/
  settings/focus/weather/memory/lifecycle audit; supports retained focused clear/
  storm subsets, strictly replaces failed cases; fresh exclusive audit output.
- docs/weather-lighting/CHECKLIST.md, CONTRACT.md, CURRENT_STATE.md,
  W009_ACCEPTANCE.md.

## Verification and reproducible evidence

Cwd D:/development/game-dev-blender/returning-fair-prototype; Godot project game/.
Console D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Bundled Python C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.
Godot4.7.2 ed1daf0bf, NVIDIA Compatibility OpenGL3.3/581.29,960x640,
orthographic zoom1,VSync0/max_fps0. Same M018 baseline: Windows11/Core Ultra9
185H/33,736,015,872 RAM bytes/RTX4070 Laptop driver32.0.15.8129.

Commands run via tools/run_checks.ps1 -Task W009:
- -Names environment_lifecycle_checks,weather_presentation_checks:157/193,417 pass.
- Nineteen focused environment/rule/session/save/lighting/consumer/input/dialogue/
  combat/companion/quest/consequence/camera/map/slice/travel checks and rendered
  matrix: all pass; exact -Names/flags in acceptance.
- -Import -RenderOnly -RenderScript weather_visual_matrix -RenderPhases matrix
  -ParseScripts tests/weather_performance_profile: import/parse pass; initial
  float32 comparison failed, repaired; final280 capture run72304 exit0/clean scan.
- -RenderOnly -RenderScript environment_lifecycle_render -RenderPhases write,read
  -ParseScripts tests/weather_performance_profile: GUI writer45068/fresh reader
  49544 exact Save/Load snapshot/forecast/HUD and E room/return pass.

Python tools/weather_lighting/profile_weather.py full then --storm-only then
--storm-only --ford-only produces24 accepted60s windows across three retained
attempts:12 focused clear-day from13472, nine focused town/forest/bridge storm from
23152, three focused ford storm from31936. All341,144 accepted frames focused;
worst p95=6.805ms,p99=9.188ms,draw p95=280. Every run passes16.67/25/500 gates.
Two smoke runs verify harness/caption/focus only, never replace duration criteria.

Final engine31936 exit0/runtime scan empty;12 trips/24 commits stable
nodes3836/objects7573/resources305/orphans0/nav1/world1/party2. Presenter/rain
owner1, consumers23/emitters8/batches12 stable; map inventory unchanged.
Final peak442.33MiB (all contributing peaks<=444.44MiB), growth4.08MiB,
within2GiB/64MiB. Navigation p95=986us, max warm commit910.9ms.

Ignored docs/evidence/W009/:
- 20261005-031009181-10dec3f8 prerequisites;031640259-eea41aea nineteen regressions.
- 20261005-031947535-5c1cc700 GUI;032242594-6360b369 final matrix.
- profile-20261005-032449-6a0141ed original full: exit1/ten storm focus faults;
  clear-day twelve rows only accepted; all invalid storm rows/raw failed audit kept.
- profile-20261005-035447-6983ec4f storm: fail-fast exit1/ford0 focus fault;
  nine valid storm rows only accepted. No lifecycle claim from interrupted attempt.
- profile-20261005-040811-81ffc9f7 final ford: clean/full travel/memory.
  tools/weather_lighting/audit_profile.py <final> --baseline <original-full>
  --storm-baseline <storm> --name raw-audit-corrected.json: exit0/status passed,
  exact24 cases/CSV hashes/settings/hardware/focus/conditions/lifecycle/memory.
- Matrix/GUI derived20261005-032503-86d500c6:289 images/25 inspected sheets.
  Three accepted-local benchmark manifests -> original full
  render/derived/20261005-041528-fae64c74:24 images/two inspected sheets.
  Repaired smoke035243-0a1da62e:four images/one inspected sheet. Important originals
  inspected too; all317 selected captures960x640, paused/provenance labeled.

## Isolation, retained repairs and next action

Runner appdata/localappdata under builds/testing/W009/<run>/; profile equivalents
under builds/weather-lighting/W009/<stamp>/. Godot suffix
Godot/app_userdata/Returning Fair — Prototype. GUI isolated playtest-check slot/
w008-oracle; review namespace w009-matrix/w009-profile prohibits Save.
Normal saves, historical evidence/source snapshot and live Blender untouched.

Retained failures: exact indoor float32 test; stale camera/banner captions;
two focus-loss attempts; audit source-path variable alias; rejected mixed-run
capture index. All focused repairs/accepted replacements documented in acceptance;
no threshold/renderer/production-focus/desktop-lock change. Old evidence intact.
Import retains known missing .NET SDK10.0.9; final runtime scans clean.
Reference four sources/23 lights/49 vectors, links/UID/status/intended CRLF-aware
diff checks pass. No commit/push/install/export/native release work.

Next safe action in a fresh chat: verify W009 concise acceptance/current artifacts,
select W010 and mark it In progress before implementing packaged Windows/native
acceptance. Synthetic W009 facts/poses do not certify ordinary native release.
