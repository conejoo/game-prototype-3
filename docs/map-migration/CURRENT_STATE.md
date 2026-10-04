# Current map migration state

Updated 2026-10-03, America/Vancouver. M001-M015 verified complete.

## Selection and next action

- Active item: none. M015 production exterior and existing recovery route complete.
- Next eligible: M016 camera ground aiming and canopy visibility only. Validate
  projections/zoom over full map and correct mouse ground on physical ramps;
  use actual visual evidence before minimal roof/canopy occlusion treatment.
  Preserve UI pointer/modal/focus gates, source collision and party/service IDs.
  Do not start M017 saves, M018 performance or M019 native build in that session.
- Acceptance: [M015 validation](../evidence/M015/VALIDATION.md),
  [inspected views](../evidence/M015/views.png),
  [audit](../evidence/M015/audit-report.json).
- Normal game now selects larger prototype-alderwake. Isolated no-interaction
  candidate harness remains available. Parent P001-P014 compact build complete;
  M019 owns resulting larger-map packaged/native acceptance.

## Preparation and authority

Read workspace AGENTS(no nested),full migration prompt,parent architecture/state,
migration investigation/checklist/state/contract,pinned manifest/layout/catalog/
report,M014 evidence/artifacts,actual Git/project. Initial Git clean at a2898e7;
M015 marked in progress before edits. Exactly one item. Caveman full,Returning
Fair gameplay-testing and Computer Use focus instructions applied. No Blender
work,source write/generator/refresh/install/subagent/commit/push/publication.
Historical evidence preserved;M009 navigation report restored byte-exactly.

Snapshot alderwake-f4630f9-m002/source commit
f4630f9966d6637ef6579cd87623ea354758191c remains authoritative. Five pinned inputs,
layout/report unchanged; [hashes](../evidence/M015/audit-report.json).
Pinned map af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f;
catalog59e203c69560f9a3b630703862192b2df0fe7ef367311d7998d6186c88fb8dd2;
layout7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.
Current read-only source map now deda25dc53a7543c3c0705e8029f6c6ded6a63cf49107a7c7f019ce34ed30af5:
three added NPC placements tess-store-01/npc-06,ivo-passenger-dock-01/npc-07,
celia-basic-repairs-actor-01/npc-08,537 objects versus534 pinned. Existing objects/
other top-level fields unchanged;other four source inputs match. Explicit decision:
keep pinned snapshot,extra NPCs outside this recovery slice;no automatic refresh.
[source-drift.json](../evidence/M015/source-drift.json) holds exact discrepancy.

## Implementation and changed files

- game/world/alderwake.tscn now uses alderwake_exterior.gd/UID,subclass of existing
  typed terrain builder;production ID/default scene path retained. Full147x80m
  geography,art/props/height/water/docks/crossings unchanged. Two spawn IDs fixed:
  start(0,0,0),return(107.25,0,1.25),ally+1mX.
- Production composition adds exactly existing npc-03-counter at(-7.5,0,11),
  labeled noncanonical companion dialogue station at(-2,0,0),alderwake-travel-gate
  at(107.25,0,-1.25)->prototype-tollworks/tollworks-from-alderwake. Six other doors
  inert. Reserved service marker removed,old inactive forest label hidden,
  production start/return labels corrected. Existing counter/body/service variants
  unchanged;Maris source metadata retained. No duplicate source NPC/party.
- terrain_preview.gd adds empty service-nav hook;production contributes exact
  existing body/bench/station outlines with0.2m nav-only margin. Production nav
  has6,352 polygons;isolated candidate retains6,336. Art never becomes floor.
- game_root.gd applies existing0.04m snap/nearby marked-floor0.11m capsule-safe
  grounding callback on each exterior arrival/rollback;compact rooms restore
 0.1m/no callback. Candidate root duplicate callback removed. Owner/IDs/physics
  contracts unchanged;single-destination travel sufficient.
- Existing quest/Maris/companion dialogue and root hints now describe Dock Row,
  east Moonwood,bridge/ford and forest entrance. Quest/effect/reaction/upgrade IDs,
  guardian/vessel rules,schema4/content1 unchanged.
- map_activation_checks.gd/UID:production geometry/interaction/nav/party/grounding
  and synthetic attached/detached debug guardian observation. Geography-sensitive
  quest/recovery/travel tests use mapped targets/stable anchors. Original optional developer beacon mesh/material preserved;normal startup
  still removes developer fixtures. Post-review playable-slice PASS0. Baseline compact
  scene retained tests/fixtures/compact_alderwake.tscn;unsafe/nav-failure fixtures
  inherit it,avoiding dynamic production node-path assumptions.
- live_playtest_bridge.gd observes guardian only while inside tree. Two original
  return-unload transform errors retained and exact synthetic regression passes.
- README,ARCHITECTURE,parent CURRENT_STATE scope note,CONTRACT,CANDIDATE,migration
  CHECKLIST/CURRENT_STATE and docs/evidence/M015 updated. Production scope changed;
  service/session/party ownership did not.

## Checks, ordinary evidence and exact results

Supplied Godot console/editor paths verified,engine4.7.2.stable.mono.official.ed1daf0bf.
Commands from target root are recorded in VALIDATION.md and JSON result files.
Use C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe -B.

- Pinned extractor --check PASS0;initial/final --headless --editor --path game
  --import --quit exit0. Known missing .NET SDK10.0.9 retained,no install.
- --headless --path game --script res://tests/{map_activation_checks,
  map_candidate_checks,playable_slice_checks,recovery_presentation_checks,
  quest_checks,application_smoke,combat_checks,location_travel_checks,
  interaction_dialogue_checks,map_navigation_checks}.gd:all final PASS/exit0.
  These braces describe script list,not a PowerShell invocation;exact args in
  final-check-results/check-results/post-repair-results JSON. Initial failures
  remain labeled;quest final pass supersedes initial check-results exit1.
- Activation3,226 radius0.4m physical route samples,service LOS/safe return and
  grounding checks. Ten production travel round trips preserve health/identity/
  floor/input/rollback. Strict inherited nav336,373 samples,three rejections/four
  round trips;generation930.211ms,p95query1391us,warm arrival1240.236-1295.703ms.
  Production generation890.975ms. Existing focused budgets only,not M018.
- Accepted rendered b boot1791088829.423-53272:Compatibility/OpenGL3.3/RTX4070
  Laptop/NVIDIA581.29,960x640/orthographic zoom1.00. Fresh no setup/developer
  fixtures;named test slot in isolated builds/m015-user-data. Ordinary E/GUI lead,
  earned40-damage upgrade,forest walk with ally/ramps/trunks/bridge,east gate,
  actual guardian defeat,vessel choice,north return,bridge westbound/full town
  walk,three-line fitting/final choice,specialist preview. All six effects once,
  same two wrappers,HP100/50,187repaths,zero catch-ups/recoveries,no saves.
- 628 accepted b responses;41 retained a/b PNGs,eight indexed representative
  views/contact sheet plus full dialogue/pause frames inspected. Outbound
  requested movement40.643s,measured hold-step44.016s<=90s. Total resumed walking
  batches96.435s includes controlled resume/settle/observe/pause overhead;not
  described as uninterrupted speedrun. Every walking batch verified paused.
- Partial a exits0 after companion trust+1 only,discarded for full-route evidence.
  b normal F10 exit0 with two original debug observer transform errors explicitly
  retained. Observer guard/exact post-repair regression PASS0,no diagnostics.
  Fresh final-code c shows corrected production pad labels,zero effects,HP100/100,
  clean runtime/normal exit0,two startup PNGs. No source/gameplay mutation evidence.
- audit_m015.py PASS0:exact pinned/core/scene baseline checks,source drift,
  party counts/identity,normal inputs,effects/service/health,movement budget,
  restored historical M009 report,no rendered save files,repair/final startup.
  git diff --check/final intended-file review exit0.

## Retained failures and limits

Initial activation exact float32 equality repaired with is_equal_approx;initial
unsafe fixture inheritance stopped safely and moved to compact test fixture;
quest synthetic approach updated. One reader-sharing lock retried boundedly,
raw response recovered;ordinary route resumed from pause. Introduced text decoding
error corrected with explicit UTF-8 before accepted b;partial a remains labeled.
Command-scoped Git safe.directory resolved elevated-user read failure without
changing global config. Computer Use cursor access failed twice;bridge observed
actual focus throughout,no security/input gate changes. Original errors/logs
remain in M015/VALIDATION.md and evidence. All selected acceptance fulfilled.

M016 ground aim/canopy visibility,M017 comprehensive historical saves/new-process
load/retry,M018 performance,M019 resulting Windows native gate remain pending.
Source drift does not authorize new NPCs or snapshot refresh. P014 compact native
completion remains accurate. No larger-map native release claim;no next item started.
