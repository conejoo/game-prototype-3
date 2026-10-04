# Current map migration state

Updated 2026-10-04. M001-M019 complete; no active or pending migration task.
Next feature work belongs to [weather-lighting](../weather-lighting/CURRENT_STATE.md).

Production Alderwake is 147x80m: town, river crossings, layered Moonwood, imported
tree/town/landmark kits, navigation, elevation-aware aim/camera and existing
Tollworks recovery route. Only forest entrance portal is active. Gameplay wrapper
IDs/feet/collision and schema4/content1 remain authoritative; imported art is replaceable.

Pinned snapshot: alderwake-f4630f9-m002, source commit
f4630f9966d6637ef6579cd87623ea354758191c. Source/current drift never authorizes
refreshing it. Inputs/hashes: tools/map_migration/reference/manifest.json;
layout: game/content/maps/alderwake_layout.json; decisions: CONTRACT.md.
Extractor regression oracle includes independent portal-measurements.json.
Exact M016 hero/ally camera poses: game/tests/fixtures/map_camera_poses.json.
Historical save fixtures/provenance remain under game/tests/fixtures/map_saves/.

M019 acceptance passed on 2026-10-04: Windows Validation/Desktop exports and
standalone startup, genuine native fresh journey across ramps/Moonwell/ford/bridge,
blocked exit, guardian defeat/vessel/return/fitting/service preview, GUI Save,
quit, independent startup/GUI Load and replay. Six effects, hero/ally75, trust1 and
Strike40 restored; durable save fields exactly matched, elapsed time alone advanced.
Native runtime scans clean; real captures inspected. Normal saves untouched.

Focused application/slice/recovery/combat/save/extension, activation/camera,
navigation and M017 lifecycle/save fixtures passed. Final navigation warm maximum
1162.134ms; earlier over-budget run retained locally. M017 expected retry error is
synthetic. Import/export retain known missing .NET SDK10.0.9 editor diagnostic.
No unresolved acceptance criterion; no new benchmark during M019.

M018 baseline: Windows11/Core Ultra9 185H/~32GiB/RTX4070 Laptop, Compatibility,
960x640/orthographic1/VSync0/max_fps0; worst p95 6.690ms/p99 8.087ms/draws408,
peak438.621MiB/growth2.965MiB. Retained method/thresholds appear in weather CONTRACT
and tools/map_migration/profile_map.py. Measure anew after production changes.

Current local packages: builds/windows and builds/windows-validation; rebuild for
new changes. Native save isolation/pause input rules: tools/PLAYTEST.md and project
skill. Raw M/P evidence remains ignored locally, optional for targeted diagnosis;
future work uses contracts/current tests and small versioned fixtures.
