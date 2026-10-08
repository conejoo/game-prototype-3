# N017 acceptance - integrated eight-person route

Completed 2026-10-08 UTC. Exactly N017. N018 remains Pending; no commit/push.
Target began clean at `dd82a3aa90317db41ec2191cf6a1af5e9b51eada`.
Read-only source remains clean/pinned at `60c20eb2816e7271fb84afaba286af006ebe3ccf`.
Applicable workspace instructions, current architecture/contracts, N010-N016
packages/acceptance and actual shared testing fixtures were inspected. No other
agent conversation was used. All prerequisite character/action capabilities
remain present; no art, catalog, source text/portrait or placement was changed.

## Every acceptance criterion

| Requirement | Evidence and result |
| --- | --- |
| Fresh ordinary player safely reaches all eight | Fresh writer PID26980 and separate fresh neutral PID60076 use production GameRoot, bounded shared navigation/WASD, E and pointer/Tab controls. No position, branch, memory or quest seeding. All eight approaches, full simultaneous capsule/support/LOS validation and ordinary interaction selection pass. |
| Correct portraits, branches, public facts and remembered reopens | Each authored node snapshot is compared with exact source text/expression path; actual visible response controls are clicked. Friendly/careful versus neutral/passing choices run in independent fresh sessions, one exclusive receipt/person and affinity1/0. Whole old durable fields and other people's memories stay unchanged by introductions. Ordinary paths disclose exactly21 public facts. Reopens, scrolling and unavailable-choice clicks pass without replayed rewards. |
| Woods/crossings/full shortened recovery | Actual first and second woods trips precede Moonflower priority, real E-hold gather commits one item, Edric/Helena source hints appear. Writer accepts Maris lead, uses J and actual upgrade button (strike40), walks main bridge to107.25 gate, travels to Tollworks, clicks actual floor-aim attacks to defeat guardian, opens vessel, returns through gate/ford and completes Maris fitting/reconnect. Six quest effects and specialist presentation; eight contacts/two-member party after travel. Prototype helper/adaptation labels retained. |
| GUI Save, quit, fresh-process GUI Load and exact prior/new state | Writer performs real pause GUI Save and exits normally. Reader PID22624 starts empty, performs GUI Load and compares entire full-precision typed SaveCodec snapshot and reconstructed forecast against writer's binary TestRunSnapshot oracle and independently decoded disk session. Health, quest/effects, trust/upgrade, environment/lights, items/collection/placements, party and NPC memories/events match exactly before movement. All eight physical revisits preserve independent memories and each conversation's before/after event snapshot; actual new woods entries during walking are legitimate new events. No duplicate effects/wrappers. |
| All enabled paths, explicit deferred coverage/placements | Strict coverage audit proves writer+neutral union covers all58 enabled source nodes/38 choices, enters no deferred node. Owning check reports12 deferred nodes,16 choices,3 facts, each with explicit reason. Consolidated policies and placement differences below. |
| Day/night/rain, long text and focus/cancel | 24 labeled synthetic production environment views (8x3) plus ordinary body/dialogue captures inspected. Rendered actual modal fixture checks all48 expressions, scrollable facts/choices, long text at actual960x640 and1350x900 (requested1440 window constrained by desktop), Tab/Enter/Esc and blocked world controls. 452 UI assertions/68 captures pass. Source expressions and fixed public-adaptation labels remain readable. |
| Travel/death/retry | Ordinary writer travel/return passes. Owning115 pre-evidence assertions plus evidence write=116 include legal synthetic independent memories for all eight, real root receive_damage/death/retry and exact whole healed durable-state equality with eight reconstructed contacts/two party actors. Rendered UI lifecycle verifies modal close/cancel on actual root travel/retry/death and focus boundaries; named/action world lifecycle suites pass. Synthetic death setup is explicitly distinguished from ordinary combat victory. |
| Crowd frame/navigation comparison against current map | Same current production map with/without contacts, full focused unpaused ABBA idle profile and13 navigation endpoints. Established p95/p99/draw/query budgets pass. Paired timing and unavoidable small actor draw cost disclosed below. Ordinary physical routes separately prove reachability. This is a development idle benchmark, not native/combat performance certification. |
| Required NPC and affected existing regressions | All46 selected existing headless suites have passing evidence:45 in broad sweep, repaired foraging-save in final focused run; companion/map-save also rerun. All eight skin suites, action/pipeline, rules/content/save/world/UI, application/content, quest/recovery/combat/companion/consequence, map/travel/camera/crossings, foraging/backpack/items, environment/weather/lights pass. Final14-case focused group includes owning checks, repaired fixtures and NPC/quest/foraging/save independent process pairs. Zero forbidden runtime diagnostic, source change or timeout in accepted final groups. |
| Viewed visual evidence and honest delivery scope | All316 final captures viewed in27 contact sheets plus full-size long-text, ordinary facts, recovery/load and weather frames. No new package/native release assertion; N018 owns that gate. |

## Implementation and files

`game/tests/npc_integration_checks.gd` measures exact current-map baseline/crowd,
validates eight footprints and duplicate exclusions, coverage/deferred reasons,
wrong-geometry preflight and whole-state death/retry.
`game/tests/npc_integration_render.gd` extends existing input/capture helpers with
ordinary write/read/neutral routes, exact state oracle, source path coverage,
actual combat and separately labeled survey/ABBA profile. Both own stable UIDs.
`tools/npc_migration/check_integration_evidence.py` refuses failed runner reports,
changed manifests, reused writer PID, missing enabled paths or deferred-node
entry. It passes original captures through strict shared capture validation;
separate profile PNGs retain their own manifest/run bounds.

Only production change: NpcWorldAdapter rejects enabled contacts on a scene
that merely claims Alderwake's ID but lacks the pinned AlderwakeExterior type,
before creating any contact. No invalid cast or partial actors. Compact
companion/map-save/foraging-save negative fixtures now disable production
contacts only for their synthetic room; original navigation/rollback behavior
remains tested. Foraging-save waits for arrival only after accepted synchronous
preflight. Foraging process fixture preserves zero movement/control/dialogue/
hold/drag input while allowing an inert newly selected real NPC at the arrival
anchor; selection must belong to the current room, never an old wrapper.

No new actor, story system, routine, reward, content/schema or geometric update.
All432 production/runtime asset files match the broad accepted sweep exactly.

## Commands, accepted runs and isolation

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Verified installed Godot console:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Version `4.7.2.stable.mono.official.ed1daf0bf`, Compatibility/OpenGL, RTX4070 Laptop.
Analysis Python `C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe`.
Required owned-child process inspection used authorized sandbox escalation;
runner's ownership, timeout, diagnostic and source guards remained enabled.

```powershell
./tools/run_checks.ps1 -Task N017 -RenderOnly -RenderScript npc_integration_render -RenderPhases write,read,neutral,survey -TimeoutSeconds 240
./tools/run_checks.ps1 -Task N017 -RenderOnly -RenderScript npc_dialogue_ui_checks -RenderPhases check -TimeoutSeconds 150
./tools/run_checks.ps1 -Task N017 -RenderOnly -RenderScript npc_integration_render -RenderPhases profile -TimeoutSeconds 180
./tools/run_checks.ps1 -Task N017 -Names npc_integration_checks,companion_checks,map_save_checks,foraging_save_checks -ProcessScripts npc_process_checks,quest_process_checks,foraging_process_checks,save_process_checks -TimeoutSeconds 180
```

| Accepted group | Local run | Result |
| --- | --- | --- |
| Ordinary writer/read/neutral and environment survey | [171412290-7c5b095c](../evidence/N017/20261008-171412290-7c5b095c/results.json) |6/6 cases;651/70/603/27 assertions respectively;112/10/101/24 captures. Distinct writer26980/reader22624/neutral60076 PIDs. |
| Rendered UI | [172032949-abbe5440](../evidence/N017/20261008-172032949-abbe5440/results.json) |3/3 cases;452 assertions,48 expressions,68 captures. |
| Focused idle profile, no competing owned engine load | [172105064-77204813](../evidence/N017/20261008-172105064-77204813/results.json) |3/3 cases;34 assertions,12 ABBA rows,1 paused capture. |
| Final owning/affected fixtures plus four process pairs | [172332070-b7c9be6e](../evidence/N017/20261008-172332070-b7c9be6e/results.json) |14/14 cases;owning116,foraging-save111,foraging-process80/83 assertions;map-save5 fixtures/24 round trips/5 rejections/5 retries. |

All cases use fresh per-case or writer/reader-group APPDATA/LOCALAPPDATA and
named slots under `builds/testing/N017/<run>/`; normal user saves never opened.
Accepted processes exit0 normally; no live owned Godot process remains.
Final group879 game/tool files stable SHA256
`c7383c75da0c85011c62af68d751f853c44826f56416099857bacc5cf9764b8a`.
Ordinary/UI/profile groups each observed exact879-file manifest
`4f7e8e46aa165315014d166e3bc497e0f018bf3303083a2851880cea4c76ada9`.
Subsequent differences are exclusively the repaired, unconsumed
foraging_process_checks fixture and analysis-only capture helper. Exact
[final source reuse audit](../evidence/N017/20261008-172332070-b7c9be6e/final-source-reuse-audit.json)
proves every ordinary selected parse dependency and all production/asset/runner
bytes unchanged. Changed fixture rerun on final bytes; capture helper executed
on final bytes. No replay of unaffected ordinary journey needed.

Broad [164847232-305538a5](../evidence/N017/20261008-164847232-305538a5/results.json)
remains **failed overall**, with47 individually passing cases and one
foraging-save timeout. Only unchanged individually passing suites are reused.
Manifest audit proves broad-to-final differences limited to five owned test/
analysis paths, with432 production/asset files and shared runner unchanged.
Companion/map-save/foraging-save and all four process pairs subsequently pass
in the final focused group. No failed report was relabeled as passing.

Broad command selected46 existing headless scripts (version/parse add2 cases):
application_smoke,content_catalog_checks,npc_content_checks,npc_dialogue_rule_checks,
npc_save_checks,npc_world_checks,npc_asset_pipeline_checks,npc_action_checks,
npc_01_checks,npc_02_checks,npc_03_checks,npc_04_checks,npc_06_checks,npc_07_checks,
npc_08_checks,npc_14_checks,npc_dialogue_ui_checks,save_checks,quest_checks,
recovery_presentation_checks,combat_checks,companion_checks,consequence_checks,
playable_slice_checks,interaction_dialogue_checks,location_travel_checks,
map_activation_checks,map_navigation_checks,map_crossing_checks,map_companion_checks,
map_save_checks,movement_camera_checks,foraging_anchor_checks,
foraging_interaction_checks,foraging_transaction_checks,foraging_save_checks,
inventory_checks,backpack_ui_checks,world_item_placement_checks,
environment_rule_checks,environment_lifecycle_checks,environment_save_checks,
environment_lighting_checks,weather_presentation_checks,light_interaction_checks,
exterior_light_checks. Runner arguments are retained in results; timeout150s.

Read-only source check and capture audits:

```powershell
$analysisPython = "C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe"
& $analysisPython tools/npc_migration/convert_content.py --check --source D:/development/game-prototype-2
& $analysisPython tools/npc_migration/check_integration_evidence.py docs/evidence/N017/20261008-171412290-7c5b095c --ui docs/evidence/N017/20261008-172032949-abbe5440 --profile docs/evidence/N017/20261008-172105064-77204813
& $analysisPython tools/capture_evidence.py docs/evidence/N017/20261008-172032949-abbe5440/render/npc-dialogue-ui.json
```

Converter132 authority inputs/67 outputs,8 people/48 portraits/18 sheets exact;
catalog SHA256`9490a7a2ca4e4cb926c9919c52be1a53f47cc0699a44059723b17d814068f9d9`.
Source Git clean/pinned; target HEAD unchanged. No Blender process/scene modified.

## Timing and navigation measurements

Profile one-second warmup/three-second sample for each of three views in ABBA
(no contacts/all8/all8/no contacts), focused/unpaused960x640. This retains the
current whole map/session, player and temporary companion. Small scheduling
variation and actor cost are disclosed rather than claiming zero cost.

| View | Baseline worst paired p95 ms | Crowd worst p95 ms | Crowd worst p99 ms | Crowd worst draw p95 |
| --- | ---: | ---: | ---: | ---: |
| Civic |6.943|7.539|9.121|227|
| Dock |11.933|11.590|14.327|444|
| East bridge |12.984|11.170|13.592|126|

Civic p95 delta+0.596ms; dock/bridge decrease within observed variation. Guards
p95<=max(16.67ms,paired baseline+4ms), p99<=25ms, draws<=500 pass. No threshold
frame regression. Full distributions/sample counts in
[profile](../evidence/N017/20261008-172105064-77204813/render/npc-crowd-profile.json).
Final navigation:13 endpoints including both bridge/ford sides, gate and eight
approaches;10 warmup+100 query samples/endpoint/configuration. Baseline maximum
p95=1.193ms, crowd maximum=1.190ms; established5ms bound passes. Endpoints within
.3m; maximum reservation detour3.376324m, within2m-or10%-of-baseline path bound.
All eight actual ordinary walks pass independently. [Owning measurements](../evidence/N017/20261008-172332070-b7c9be6e/checks/npc_integration_checks/npc-integration-checks.json).

## Consolidated coverage, placement differences and remaining limits

Exactly8 requested packages; seven other source residents stay outside scope.
70 source nodes/54 choices retained;58/38 enabled,12/16 deferred. Exactly21 of24
public declarations have ordinary authored disclosure. Edric public-role/river-
fishing and Helena archive-practice stay unknown: no automatic role/art facts.
All8 gift rules remain typed/inert even with Moonflower owned; no item consume,
affinity cap progression or milestone. Archive routines/ledger/preferred entries,
Edric level1 milestone and Della indoor directions stay deferred. Full People
journal, schedules, campaign/director/private testimony, transactions, fishing
minigame, booking/salvage/departures, repair/demo services, room/sleep, new interiors,
new companions, romance/household changes, autosave and old-schema migration are
outside this workflow. Disabled controls explain the missing capability and
valid Close/Continue remains available. [Complete stable-ID coverage](../../tools/npc_migration/reference/COVERAGE.md)
and [registry](../../tools/npc_migration/reference/contact_registry.json) remain authority.

| Person | Source placement/anchor | Production foot -> ordinary approach (m) | Difference retained |
| --- | --- | --- | --- |
| Edric npc-01 |alderwake:npc-01 / edric-town-square|( -.5,0,-1.5 ) ->( -.5,0,-.5 )|Pinned civic anchor; newer ordinary actor lies .5m east. |
| Helena npc-02 |alderwake:helena-town-square|(1.5,0,-1.5)->(2.5,0,-1.5)|Public civic anchor; archive/home unavailable. |
| Maris npc-03 |alderwake:maris-chandlery-01 / maris-fitting-01|(-7.5,0,11)->(-6,0,11)|Existing npc-03 counter/body/bench and quest identity reused. |
| Harlan npc-04 |alderwake:harlan-dockmaster-01 / harlan-sluice-practice-01|(41,0,17)->(42.5,0,17)|Pinned dry control-hut neighborhood; no sluice controls. |
| Tess npc-06 |alderwake:tess-store-01 / store-service-tess-01|(7.5,0,5)->(9,0,5)|Newer source actor absent from pinned geography; local wrapper at existing anchor. |
| Ivo npc-07 |alderwake:ivo-passenger-dock-01 / passenger-booking-ivo-01|(36,0,20)->(34.5,0,20)|Local wrapper on safe dry booking shore. |
| Celia npc-08 |alderwake:celia-basic-repairs-actor-01 / celia-basic-repairs-01|(-3.5,0,12)->(-3.5,0,13)|Local wrapper at existing repair anchor. |
| Della npc-14 |lantern-rest:della-inn-host-01 / inn-host-01 indoor(256,288)|(-9,0,3.5)->(-9,0,4.5)|Explicit public exterior adaptation; interior coordinates never transformed. Door/portal unchanged. |

Named bodies retain ordinary idle/facing. Walk clips and separate N016
river-fishing/archive-work variants remain review-only: no approved ambient
routine/location consumer or expanded prop reservation. Temporary companion
remains honestly labeled and independent of villager affinity/quests.
Night views preserve existing darker world lighting, visible actor silhouettes
and unchanged production camera scale; dialogue portraits remain unaffected.
Manual schema7/content1, pinned geometry and previous release history unchanged.
N018 is the sole remaining task and owns fresh Windows/native acceptance.

## Capture provenance and inspection

[Strict integration coverage](../evidence/N017/20261008-171412290-7c5b095c/derived/20261008-172300-fa3f74d6/integration-coverage.json)
proves58/38 ordinary coverage and248 valid captures in21 sheets. Separate
[UI capture report](../evidence/N017/20261008-172032949-abbe5440/render/derived/20261008-172107-060a2622/capture-report.json)
proves68 in6 sheets. All27 sheets opened/inspected, including both fresh paths,
reopens, unavailable reasons, source hobby expressions, full recovery/restart,
24 world day/night/rain views and profile pause.

Full frames inspected: UI long-text-960/long-text-1440 (actual1350x900);
ordinary write-093-scrolled-facts-npc-14,write-110-reconnected,
read-load-confirmed; survey-npc-04-night,survey-npc-03-rain. Earlier passing
writer body-npc-04/save-confirmed and retained original failed-run full frames
also inspected, without substituting for final proof. Capture helpers verify
four settled frames/frame_post_draw, contained modal focus/cursor token and
blocked world controls; paused world captures verify pause overlay separately
from whether it is shown. Original PNGs/hashes/logs/PIDs/isolation remain local.

## Retained failures and repairs

Initial sandbox process observation Access denied; required escalation approved.
First imports generated new UIDs and invalidated manifests; stable reruns used.
First woods priority attempt followed a dock walk that already entered woods;
explicit first/repeat trips now occur before dock/gather. Revisited captures had
duplicate filenames; indexed labels retain every frame. Invented2ms query gate
was replaced by established5ms M018 threshold with100 sampled queries; no bad
run accepted. Initial compact companion/map fixtures caused invalid cast; pinned
geometry guard and explicit contact-free synthetic fixtures repaired it.
Map fixture newline cleanup during a run invalidated source; final original
mixed line endings plus four owned inserts preserved.

Old combat aim above guardian/too-close collision target failed; actual ground
feet aim, public mouse position/global_position and reachable -.5 approach pass
in separate labeled synthetic diagnostic and final full ordinary writer.
Foraging-save synchronous compact-room rejection caused150/180s timeouts; fixture
now disables contacts for intended navigation failure and conditionally awaits.
First reader overbroad event equality rejected legitimate woods entries during
walking; exact whole state at Load plus per-conversation snapshots/independent
memories resolves the test error. Foraging process's empty arrival-selection
assumption rejected real civic contact; current-room inert selection and stronger
movement/dialogue/hold/drag checks pass. First split-run capture manifest rejected
profile PNG outside its run; separate manifests preserve strict original bounds.
All failed/invalidated runs remain failed/invalidated and raw evidence ignored.

No blocker, unrun N017 criterion, live owned engine/helper or cleanup remains.
No normal-save/source write, Blender change, package promotion, new agent/chat/
schedule, external message, commit/push or N018 implementation. Stop after N017.


## Authorized commit follow-up (2026-10-08 UTC)

User authorized committing the successful N017 task. Preflight verifies16 owned
paths and879 accepted runtime/tool files, no unrelated/staged changes or source
drift. Runtime/asset/test bytes and N task status rows remain unchanged. Concise
acceptance evidence is tracked; raw runs/captures/isolated appdata retain existing
ignored policy. Final commit scope/tree/identity/status audit is retained beside
the final local run. Commit identity is available in Git history and follow-up
report. No push or N018 implementation.
