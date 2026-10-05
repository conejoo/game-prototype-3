# W007 acceptance

Completed 2026-10-04 (America/Vancouver). Only W007 selected and implemented.
W006 dependencies were verified against current typed commands, registry,
consumers, retained acceptance and fresh 151/13,289/517 checks. The initially
dirty W006/testing tree was preserved; no reset, commit, push, subagent,
dependency installation, source mutation, generator, Blender edit or renderer change.

## Criteria and evidence

| W007 criterion | Verified result |
| --- | --- |
| Four distinct conditions and smooth transitions | WeatherVisuals derives cubic smoothstep overcast/rain/storm from the existing previous/current forecast and its 15-authored-minute blend. Clear retains W004 lighting; clouds soften direct light/shadows; rain adds sparse streaks; storms are darker and denser with deterministic atmospheric flashes. 16 transition pairs, endpoints and bounded steps pass. Real GPU images cover all four conditions at five views in both projections and natural rainy-to-storm beginning/mid/end. |
| Stable world-space rain near the view | WorldRain uses fixed 16m tiles and 24x24 jittered world cells per tile. Camera frustum selects tiles but never translates existing drop origins. Surviving buffers, rebuilt tile data, shared seam spacing, real uploaded transforms and camera pan/input movement pass. Both projections and zoom0.8/1.15 are covered. No visible batch seam or camera dragging observed. |
| Roof/terrain/river exclusion | All21 imported building roof bounds are conservatively expanded0.12m and exclude complete rain columns. Each remaining column starts0.05m above the actual elevation height; streak bottoms stay above that floor. Shader draws no below-floor segment. Pure generated-data audits and actual GPU transform comparisons pass across town, raised Moonwell, dense forest, bridge and ford. River and crossing captures show coherent rain coverage; covered town areas remain excluded. |
| Session motion and pause | New rain shader never uses TIME. Vertical phase comes from (day+progress)*600, reduced modulo64 seconds, exactly forty1.6-second fall cycles. Flash also uses that authoritative time. Headless pause freezes phase/uniform/flash/sun; Resume advances them. Two actual rain-only GPU images separated by0.5 seconds are byte-identical while paused. Existing river TIME animation was hidden only in that isolated pixel test; it was not changed or counted as weather motion. |
| Save/load reconstruction | Writer PID56332 performs actual paused GUI Save and exits0. Fresh reader PID1028 performs GUI Load; every durable fact and exact forecast matches the typed disk session and independent-process oracle. Exact cloud/rain/storm/flash/phase/sun render JSON matches after restart and outdoor return. Saved seed20/day1/progress0.802317222222222 reconstructs storm/flash0.1799518128728563/phase57.39033333333305. Rain particle data remains transient and is recreated from world coordinates. |
| Bounded resources and owner disposal | Hard maximum64 MultiMesh batches, each at most576 columns, one shared per-location mesh/material, no per-drop Nodes, collisions or shadow passes. Final inspected matrix peaks36 batches/17,221 instances. Retire-before-add keeps the bound during camera changes. Dry weather hides and retains only that bounded set. Travel frees the old location/rain owner; one fresh owner hydrates on outdoor return. No outdoor rain node exists in Tollworks. These are resource-count checks, not a W009 frame-budget claim. |
| Restrained lightning and stable indoor profile | At most one0.32-second smooth pulse per8-second window, admitted by seeded1-in-3 hash, peak ambient increment0.18. No gameplay event/damage/audio/new light. Determinism, bounds and spacing pass; viewed storm-flash retains actors/labels. Tollworks restores original sun/ambient/background, even during a saved storm flash. Both indoor projection captures show readable gold guardian windup and no rain/flash leakage. |
| Existing ownership and compatibility | GameSession remains the only clock/forecast/save authority. GameRoot passes committed facts to its existing presenter and the location-owned rain. Camera arrival is set before rain-frustum hydration. Schema5/content1, all23 lights/eight local emitters, lamp commands, pinned map/IDs/art/collision/navigation and historical P/M packages remain intact. |

## Commands, results and isolation

Cwd: D:/development/game-dev-blender/returning-fair-prototype.
Engine: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe,
4.7.2.stable.mono.official.ed1daf0bf, real GL Compatibility at960x640.
Python: bundled C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe.
No installation required.

All runner invocations use process-local APPDATA/LOCALAPPDATA under
builds/testing/W007/<unique-run>/appdata and localappdata. This is the existing
shared runner's isolated staging convention; no manual staging/build/package
output was needed. Actual user_data is APPDATA/Godot/app_userdata/Returning Fair — Prototype.
Debug primary is user://saves/playtest-check-<run-id>.json; W007 oracle is
user://saves/w007-oracle.json in the same isolated appdata. Normal saves untouched.

| Exact runner/audit command from target root | Result |
| --- | --- |
| ./tools/run_checks.ps1 -Task W007 -Names light_interaction_checks,exterior_light_checks,environment_save_checks -TimeoutSeconds 120 | Prerequisites pass151/13,289/517; run20261005-005824437-4137873e. |
| ./tools/run_checks.ps1 -Task W007 -Import -Names weather_presentation_checks,environment_lighting_checks,application_smoke -RenderScript weather_presentation_render -RenderPhases write,read -TimeoutSeconds 180 | Pass; run20261005-010903287-6c38237b. Import exit0 permits only known missing .NET SDK10.0.9 diagnostic; weather193,417, W00430,053 and startup pass. Render writer/reader exit0,66 captures. |
| ./tools/run_checks.ps1 -Task W007 -Names environment_rule_checks,environment_session_checks,environment_save_checks,exterior_light_checks,light_interaction_checks,location_travel_checks,map_camera_checks,combat_checks -TimeoutSeconds 120 | Eight checks exit0, runtime scans clean; run20261005-011023448-a16ef4f4. Rules12,792, codec517, consumers13,289, switches151, session gates, ten travel/rejection cycles, map-camera330 samples (maximum aim error0.000007691m) and combat checks pass. |
| ./tools/run_checks.ps1 -Task W007 -Names weather_presentation_checks -RenderScript weather_presentation_render -RenderPhases write,read -TimeoutSeconds 180 | Final labeled-camera/motion assertions pass; run20261005-011225850-d89ecce5. Check PID7020, writer56332/read1028; every exit0 and runtime scan clean.60 writer+6 reader captures. |
| Python tools/capture_evidence.py docs/evidence/W007/20261005-011225850-d89ecce5/render/write-index.json docs/evidence/W007/20261005-011225850-d89ecce5/render/read-index.json | Exit0;66 original960x640 PNGs with verified pause, provenance, camera and engine metadata. All six final contact sheets inspected; important original hill/indoor/restart storm views also inspected. Derived directory20261005-011333-7f1bf7d7. |
| Python docs/weather-lighting/reference/audit.py | Exit0; four exact sources,23 lights,49 forecasts and uint32/clock vectors; pinned geography unchanged. |
| git diff --check and intended source/document/UID/local-link/status audit | Pass. W007 Done; W008 Pending and next. Prior dirty work remains intact. |

The versioned runner records full actual arguments/cwd/PIDs/exits/error scans
in each ignored docs/evidence/W007/<run>/results.json. Final render manifests,
66 originals and six derived sheets are under that final run's render directory.
Raw failures and earlier successful renders remain local; future agents need
only this record, source/tests and contract unless diagnosing a specific issue.

## Repairs and limits

Retained failures: wrong initial clock constant (corrected to CYCLE_SECONDS);
headless dummy MultiMesh returns zero transforms (now test the shared generated
column data and verify actual uploaded transforms in the real GPU renderer);
test exact float comparison against indoor1.1 (now engine-appropriate approximate
comparison, while restart uses exact typed strings); RainBatchData replaces an
initial TileData name that shadows a native class. Arrival camera sequencing
was repaired so paused committed outdoor rain covers the arrival immediately.
W004 phase tests now select a real sunny seed to isolate their original clear
lighting assertions. Fixture camera labels and actual resumed-motion checks were
clarified. No acceptance gate was weakened; all failed raw runs retained. An escalated-shell git diff check reported no repository; rerunning in the verified target read shell passed.

Visual matrix facts/poses and guardian setup are explicitly synthetic. The0.4s
D movement and GUI Save/Load use real viewport input in those isolated sessions;
they do not prove a full normal/native quest or packaged release. No weather
performance result, new package, audio, wind, wetness mechanics or NPC schedule
is claimed. W008 lifecycle/HUD/developer-review controls, W009 full phase/weather
performance matrix and W010 packaged/native acceptance remain Pending.
All W007 criteria pass; no failed/unrun W007 criterion remains.

All owned Godot processes exited. Input released; no editor was started.
Existing user Blender PID2664 and unrelated MCP helpers were untouched.
Next eligible task: W008 only; not started.
