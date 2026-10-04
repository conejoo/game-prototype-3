# Current map migration state

Updated2026-10-03, America/Vancouver. M001–M016 verified complete.

## Selection and next action

- Active item:none. M016 camera/ground aim/canopy visibility complete.
- Next eligible:M017 save load retry and scene replacement compatibility only.
  Verify pre-migration schema4 town spawn IDs and Tollworks, full-party safe
  arrival, preserved quest/defeat/trust/upgrade/health, retry/rollback/lifecycle,
  isolated new-process save/load and invalid-save rejection/backup behavior.
  Never use normal user save. Do not start M018/M019 in that session.
- Evidence:[M016 validation](../evidence/M016/VALIDATION.md),
  [measurements](../evidence/M016/camera-report.json),
  [final rendering audit](../evidence/M016/survey-final/audit.json),
  [dense forest repair](../evidence/M016/dense-forest-final-views.png).
- Normal larger prototype-alderwake retained. P001–P014 compact native build
  complete; M019 still owns resulting larger-map packaged/native acceptance.

## Preparation and snapshot

Full migration prompt, workspace AGENTS(no nested),parent architecture/state,
investigation/checklist/state/contract, pinned layout/provenance and M015 actual
artifacts/evidence read. Initial Git clean at343e7ac. M016 marked in progress
before implementation. Exactly one item. Caveman/gameplay-testing/Computer Use
focus skills applied. No source writes/generators/refresh, Blender, installs,
subagents, commit, push or publication. M012/M015 reports restored to Git bytes.

Snapshot alderwake-f4630f9-m002/source commit
f4630f9966d6637ef6579cd87623ea354758191c unchanged. MapSHA256
 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
layoutSHA2567477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
Five pinned inputs/extractor unchanged. M015 source-drift.json retains last known
live tess-store-01/npc-06,ivo-passenger-dock-01/npc-07,
celia-basic-repairs-actor-01/npc-08:537 objects versus534 pinned. Extra NPCs outside
slice, no refresh or live-source revalidation here. Schema4/content1 unchanged.

## Implementation and changed files

- game/app/camera_rig.gd:marked physics-floor targeting, three tiny screen rays
  (0,+/-(0.02,0.01)px) for concave seams. Skip unmarked blockers/art; reject hidden
  candidate base through cliff side using vertical marked-floor check. No selected
  floor hides marker. Existing camera offset/projections/zoom bounds unchanged.
- game/world/prototype_location.gd/test_room.gd:compact floor aim metadata/super
  ready. map_candidate/terrain_preview.gd:base support role metadata only, no
  physical floor/height/collision/navigation changes.
- actor_placeholder.gd:marker at physical hit+0.03m; horizontal visual yaw/attack
  direction. Existing pointer/modal/focus arbitration retained.
- map_candidate/tree_art.gd/canopy_visibility.gdshader:exported vertex palette/
  matte roughness preserved; main-view-only foreground0.95m cutout around party
  feet+0.8m, fragment at least0.45m in front, original shadows retained.
  game_root.gd supplies transient camera matrices/party positions. All395 source
  tree IDs/feet,21 variants/106 MultiMeshes/geometry/physics unchanged.
  Inspected town roofs/services clear, so no roof treatment added.
- game/tests/map_camera_checks.gd/UID:330 independent triangle/marker/facing/
  attack samples, two exact cliff negatives, prop/miss/camera/modal checks and
  read-only nav guide. map_camera_render.gd/UID:final renderer at recorded party
  feet and moving-pose replay, explicitly synthetic visual evidence.
  map_tree_art_checks.gd adapted shader palette audit. Opt-in live bridge adds
  read-only combat_direction; no command/mutation/input bypass added.
- docs/evidence/M016:exact logs/exits,input/response arrays, before/final images,
  contact sheets,reports/local drivers. CHECKLIST/CURRENT_STATE updated. Parent
  scope/ownership and CONTRACT scale/height/grid/movement masks unchanged.

## Verification

Exact commands/args in M016 VALIDATION.md/final-check-results.json. Both engine
paths verified; console4.7.2.stable.mono.official.ed1daf0bf. Checks isolate APPDATA/
LOCALAPPDATA under builds/m016-check-data and m016-check-local-data. Ordinary tour
uses m016-user-data/m016-local-data with --save-slot=m016-final; normal save untouched.

- Python -B tools/map_migration/extract_layout.py --check exit0.
- --headless --editor --path game --import --quit exit0,existing missing .NET
  SDK10.0.9 diagnostic; no new script/asset error/install.
- --headless --path game --script res://tests/{map_camera_checks,
  movement_camera_checks,interaction_dialogue_checks,combat_checks,
  map_activation_checks,application_smoke}.gd:all final PASS0. Braces summarize
  script list, not literal command. Latest camera rerun0.
-330 samples:16 ramps+7 landmarks,2 projections,zoom0.8/1/1.15;
  max0.000007691208m<=0.15m;18 intended targets hidden by nearer terrain correctly
  select nearest visible triangle. Old plane max1.175598m. Two cliff-side pointers
  now null. Marker/horizontal facing/attacks/stable camera/modal/focus checks pass.
- --path game --script res://tests/map_tree_art_checks.gd:actual Compatibility
  renderer PASS0:395 trees,21 variants,106 batches,28,298 triangles. Headless
  dummy renderer intentionally refused1, historical failed log retained.
- Ordinary10-site camera tour:Maris,entry ramp,Moonwell,ford/bridge both banks,
  Tollworks,closed exit,dense forest.633 movement holds/73.097s requested;
  106 unpaused views,100/100 HP,same two wrappers,179 repaths,zero catch-ups.
  Accepted batches start/end focused/paused; normal F10 quit exact0. This tour
  finds canopy/hidden-base faults; those pre-fix views are rejected for final pass.
- --path game --script res://tests/map_camera_render.gd:60 final static views+
  six recorded moving-pose replays,exit0/zero runtime or shader errors. Both
  projections/all zooms. Final sheets/full-size images inspected; dense party
  now visible, hero inspection-guide pixels753–1763 versus pre-fix perspective0–1.
  Synthetic replay proves visual repair, not ordinary walking/quest/save flow.
- Preservation audit:pinned layout/report/manifest and GLB bytes unchanged;
  mapping/save codec content unchanged with checkout line endings. Historical
  M012/M015 reports restored to Git bytes. git diff --check/final review0.

## Failures and remaining limits

Initial hidden-target fixture corrected with independent triangles; measured
concave seam misses repaired. Ordinary buried-base pointers now negative tests;
dense perspective canopy repaired. Initial shader builtin-scope error/dummy-tree
renderer refusal/test-edit parse failures retained separately, not accepted.
Windows camera-label decoding repaired with explicit UTF-8. One actual focus-loss
batch stopped paused, observed game refocused then ordinary tour resumed; no gate
bypass. Early baseline normal quit exact exit UNVERIFIED(lost handle), accepted
main tour/final survey exact0. Git ownership solved command-scoped only. Preservation
audit accounts for Git LF versus untouched CRLF text checkout. Failed evidence kept.

M016 complete; stable IDs/once-only/session/party/service/save authority unchanged.
M017 comprehensive historical saves/new-process load/retry next. M018 must measure
new shader/ray costs; no performance/minimum-PC claim. M019 native larger-map
release pending; P014 compact completion retained. No next item started.
