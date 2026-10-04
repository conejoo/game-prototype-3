# Current map migration state

Updated 2026-10-04, America/Vancouver. M001–M018 verified complete.

## Selection and next action

- Active item: none. M018 measured map performance complete.
- Next eligible: M019 full walkthrough and Windows build only. Follow its full
  acceptance: rendered fresh journey through both crossings/Moonwell/closed exit/
  recovery/save/restart/revisit, then resulting packaged Windows/native gate.
  M018 synthetic benchmark does not complete this gate. No M019 work started.
- Evidence: [M018 validation](../evidence/M018/VALIDATION.md),
  [independent raw-data audit](../evidence/M018/audit.json),
  [full benchmark](../evidence/M018/acceptance/report.json),
  [process/memory result](../evidence/M018/acceptance/process-results.json),
  [focused exits](../evidence/M018/focused-results.json).
- Normal larger prototype-alderwake retained. Parent P014 compact native completion
  remains historical; M019 must certify the larger-map packaged/native build.

## Preparation and source identity

Full migration prompt, workspace AGENTS (no nested target instructions), parent
architecture/state, migration investigation/checklist/state/contract, retained
layout/provenance and M017 evidence/actual artifacts inspected. Initial HEAD
8683729e276c8ddd97a3c7fe335ba5c7772459ee, Git clean. M018 marked in progress before
work; exactly one item. Caveman/gameplay-testing skills applied. No source write,
generator/refresh, Blender, dependency installation, subagent, commit, push,
publication or next-item work.

Snapshot alderwake-f4630f9-m002/source commit
f4630f9966d6637ef6579cd87623ea354758191c unchanged. MapSHA256
 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
layoutSHA2567477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
Five pinned inputs/extractor unchanged and audited. M015 source NPC drift
(537 objects versus534 pinned) remains recorded there; no source refresh or live
source revalidation. Schema4/content1, all production IDs and normal save fixed.

## Implementation and changed files

- game/world/map_candidate/elevation_surfaces.gd: exact original cliff appearance
  batched into nine16m regions/shared material, replacing238 riser mesh/material
  instances. Preserve original six vertices/order/normals per cliff, shadows,
  all238 named bodies and independent navigation/physical geometry. Release
  construction buffers. Trees remain original32m/106 batches.
- game/tests/map_performance_profile.gd + UID: full-production rendered profiling,
  exact source tree transforms/IDs/collision inventory and riser vertex multiset,
  path/loading budgets, safe arrival/weakref/nav/party lifecycle checks. Synthetic
  static placement at recorded M016 ordinary-tour poses; no save/quest writes.
- tools/map_migration/profile_map.py: Windows runner, isolated AppData, fresh
  evidence directories, exact argv, actual engine PID working-set/peak sampling,
  bounded execution and runtime-error rejection. Console launcher PID is separate.
- docs/evidence/M018/: raw12 acceptance CSVs/working-set stream, four inspected
  captures, settings/report/launch/process logs, fresh machine/driver info, focused
  checks and copied reports, independent audit/hashes, retained failed smokes.
- tools/map_migration/README.md and CANDIDATE.md: reproducible profile command and
  current measured riser batching note. Migration CHECKLIST/CURRENT_STATE updated.

No production scope/ownership or contract target change, so parent ARCHITECTURE,
CONTRACT and parent P014 state remain untouched. Prior evidence preserved; focused
runner restores old M008/M015/M016 report bytes after copying new results locally.

## Verification

Machine: Windows11 Home10.0.26200 x64/Core Ultra9 185H/33,736,015,872 bytes RAM/
RTX4070 Laptop, driver32.0.15.8129/API581.29. Godot4.7.2.stable.mono.official.ed1daf0bf,
Compatibility/OpenGL3.3,960x640,orthographic zoom1,VSync0,cap0. Python
C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe -B.

- Full acceptance exit0,798.339s. Four views each10s warm-up then three60s samples;
  176,653 focused frame intervals, unpaused normal actor/companion/UI/aim/canopy
  processing. Nearest-rank percentiles independently recomputed from all12 CSVs.
  Worst three-run p95/p99/draws: town6.448/7.900ms/238; dense forest6.690/8.087/408;
  bridge6.525/7.947/156; ford5.365/7.127/274. All<=16.67/25ms/500. Raw maximum41.995ms
  retained; no maximum-frame or zero-spike claim. Four final captures inspected.
- Cold generation/bake751.372ms<=5s, cold full arrival1025.819ms. Maximum24 warm
  request-to-safe-commit arrivals873.942ms<=2s.120 connected full-map path queries,
  30 per view, p95840us<=5ms.
- Actual engine PID17280, launcher31636.0.25s working-set samples/historical peak:
  peak438.621MiB<=2GiB. Two warm-up round trips+10s idle baseline409,694,208 bytes;
  ten further round trips+10s idle final412,803,072: growth2.965MiB<=64MiB.
  Every replaced scene/region gone; one world/region, same two safe party wrappers.
  Baseline/final3702nodes/7321objects/271resources/zero orphan nodes.
- Exact initial/final inventory:818 physics nodes,6352 nav polygons,395 trees,
  21 variants/106 tree batches,24 structures/seven landmark instances/six terrain
  batches/nine riser batches. All1428 original riser vertices preserved; all tree
  batch transforms and source collision/metadata checked.
- Final import0, known missing.NET SDK10.0.9 editor diagnostic; no new script/import
  issue. map_elevation_checks/map_camera_checks/map_activation_checks/application_smoke
  PASS0, no runtime errors:64 ramps/2646 cliffs,330 aim samples,3226 production
  capsule samples plus one round trip. Final extractor check0, smoke-focus0,
  independent audit0; final git diff --check0 and intended-file review.
- Exact commands/environments in VALIDATION/launch/focused/import JSON and scripts.
  All writes use builds/m018-* AppData; normal user save never opened. Historical
  M001-M017/P014 evidence and pinned source/layout hashes unchanged.

## Retained failures and limits

Initial smoke drew637 dense/503 ford, failed1; its launcher-only memory invalid.
64m tree experiment still609 draws, failed1/reverted. Original attribution failed1
but isolated238 riser draws. First batched smoke assumed indexed mesh arrays,
raised SCRIPT ERROR despite engine0; entire run invalid, fixed to handle unindexed
meshes and reject runtime errors. Focus-lost smoke-final failed1; real foreground
request after arrival/before warm-up fixed it, focus gates unchanged. One PowerShell
edit request failed to parse before execution; corrected. Failed/invalid logs and
partial reports retained, never reclassified. Final accepted runs have no runtime
errors or acceptance failures.

Static poses and direct WorldHost round trips are labeled synthetic benchmarks,
not ordinary quest walking or native release evidence. Performance applies to
recorded development machine/settings/views, not combat/minimum PC/all camera
settings. Source drift remains outside scope. M019 packaged/native larger-map
release gate remains open; parent P014 compact completion preserved. No unresolved
M018 criterion; no next item started.
