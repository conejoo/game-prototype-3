# F005 acceptance - world resources and held interaction

Completed 2026-10-07, America/Vancouver. **Done**. Exactly F005 completed;
F006 remains Pending. [Checklist](CHECKLIST.md) owns status, [current state](CURRENT_STATE.md)
owns continuation, [contract](CONTRACT.md) owns mappings and rules.

## Result and ownership

Three moonflowers and one rod now have stable typed, nonblocking world wrappers and
simple replaceable visuals. ForagingWorldAdapter consumes actual selected inert
resourceNode identities, resolves approved ForagingRegistry runtime feet and applies
committed location facts. Collected origins disappear; saved authored/generated rod
placements override defaults, including foreign-room placements. Remaining wrappers
are reused; removal happens only after the joint inventory/collection commit.

ForagingAction is immutable command identity. Root owns a transient weak-target/session
ForagingHoldController and copied action/revision/position. Hold E0.6s for flowers,
0.5s for rod. Each tick revalidates input mode, target/LOS/range and unchanged owner/
revision/action/position before committing once through the existing atomic service.
Release is observed before GUI consumption. An E press is consumed until release,
including cancelled or completed holds, so adjacent lamps/gates require a fresh press.
Progress/feedback are transient; no hold field enters a save. Existing one-listener
location rebinding remains the sole fact-to-world route. Bridge additions are read-only.

Approved relocation: rod(-6.5,0,15.75) on existing dock; flower01(26.75,0.25,-2) east
of cliff. Original source feet/IDs, pinned geography, colliders/nav remain unchanged.
See [relocation](F005_RELOCATION.md) and historical [blocker](F005_BLOCKER.md).
Schema6/content1 unchanged. Temporary sphere/stem/cylinder art belongs to F005;
backpack B/UI, ordinary rod drop/drag, final art and native packages remain F006-F010.

## Every acceptance criterion

| Criterion | Evidence and result |
| --- | --- |
| Four supported mapped feet and reachable approaches | foraging_anchor_checks PASS for all four: dry five-point footprint/support/normals, capsule/nav/arrival path/reservations, clear in-range LOS, rod dock containment. foraging_interaction_checks validates stable identities/feet and no CollisionObject children. Rendered fresh ordinary WASD routes reach all four and select their wrappers without teleport. |
| Exact E0.6s/0.5s, once-only joint reward/removal | Synthetic tick tests reject599/499ms and commit600/500ms; observer sees inventory and collected fact together, one publication/node removal, rod count1. Continued held E grants nothing more. Ordinary rendered holds gather flower3/rod1 and remove all four. |
| Release/target/LOS/range/removal cancel | Real viewport E release, selector change, actual inserted ray-blocking wall, range loss, queued deletion, moved target, changed action and state revision all cancel without reward. Rendered live partial rod hold/release retains rod and empty bag; progress disappears. |
| Every modal/focus/travel/load/retry gate cancels | Synthetic pause, dialogue, journal, focus notification, travel/loading/retry, GUI focus, attack/dodge/death and actual paused settings fixtures cancel. Real transition and retry entry cancel synchronously; rejected unpaused load also cancels. Existing dialogue/settings/movement regressions pass. |
| Fresh press required after completion/cancel; adjacent lamp/gate protected | Mode fixtures cannot rearm from repeated held press. Continued E at lamp/gate does nothing; release/new E toggles real lamp. Immediate talk/inspect/travel/light regressions pass. |
| Full bag/stack keeps node | Synthetic valid test-only20-type full bag and flower99 fixtures leave node, collected ID and inventory unchanged. These are explicitly capacity fixtures, not ordinary-route rewards. |
| Exact lifecycle absence/count, no leaked signals | Actual Save/Load, travel and retry retain exact all-four absence/count. Old owner has zero listeners; current room exactly one after repeated travel. Authored/generated/foreign-room saved rod wrappers match committed feet/count and physical held pickup removes placement while conserving rod1. Independent process tests verify exact whole durable snapshot and physical wrapper reconstruction, with no hold restored. |
| Existing four interaction kinds preserved | interaction_dialogue_checks (talk/inspect/arbitration), light_interaction_checks151 assertions, location_travel_checks10 round trips, live_playtest_checks all PASS. Headless map/movement/settings/save regressions PASS. |
| Rendered hold/cancel, normal walking and image inspection | Final rendered debug-input journey write/read PASS at960x640 using camera-relative normal WASD, actual physics/selection/E and GUI Save/Load. No position/fact/reward setup. Ten paused writer views plus two explicitly live hold/release frames; three paused reader views. Full-size frames inspected as described below. |

## Commands and evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Installed console verified: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`;
engine4.7.2.stable.mono.official.ed1daf0bf. Fresh ignored evidence is under
`docs/evidence/F005/<run>/`; runner results.json records arguments, isolation,
PIDs, diagnostics and stdout/stderr. All reports/logs inspected.

| Run | Repository-root command after ./tools/run_checks.ps1 | Result |
| --- | --- | --- |
| 20261007-203307467-33c7731a | -Task F005 -Import -Names application_smoke,map_activation_checks,foraging_transaction_checks,foraging_save_checks,light_interaction_checks -TimeoutSeconds 150 | PASS; catalog parse/import, smoke/map/transactions587/save111/light. Only pre-existing allowed editor-import missing .NET SDK10.0.9 diagnostic. |
| 20261007-204127658-32178797 | -Task F005 -Names foraging_interaction_checks,foraging_anchor_checks,interaction_dialogue_checks,light_interaction_checks,location_travel_checks,live_playtest_checks,reference_mapping_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150 | PASS; initial84 hold assertions; all four anchors; dialogue/inspect; lights151; travel10 round trips; bridge; mapping4/1648 capsule samples; independent writer52/read55. |
| 20261007-204313167-f06d1cfe | -Task F005 -Names movement_camera_checks,settings_debug_checks,foraging_save_checks,map_activation_checks -TimeoutSeconds 150 | PASS; movement/camera/settings, save111, activation3226 capsule samples. |
| 20261007-204632170-6b9a55f0 | -Task F005 -Names foraging_interaction_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150 | PASS; enhanced99 interaction assertions, independent writer66/read69 including exact physical placement wrappers and foreign revisit. |
| 20261007-205238453-486e18c7 | -Task F005 -Names foraging_interaction_checks,light_interaction_checks,interaction_dialogue_checks -TimeoutSeconds 150 | PASS final code after HUD punctuation repair; interaction99/light151/dialogue. |
| 20261007-205250215-6f77c16d | -Task F005 -RenderOnly -RenderScript foraging_interaction_render -RenderPhases write,read -TimeoutSeconds 150 | PASS final rendered code, ordinary all-four walking/hold/release/GUI Save and new-process GUI Load/exact snapshot/rod revisit. |

Earlier successful rendered run20261007-204257020-70fb2177 and focused
run20261007-203721955-343e9b85 retained; final rows above supersede relevant proof.
All successful runtime diagnostics empty; no runtime warning/error or timeout.
No SDK/install action. APPDATA/LOCALAPPDATA and isolated save slots under
builds/testing/F005/<run>; ordinary user save untouched. Every owned runner process exited.

Final source audit `audit-20261007-205145-fc1c2562/results.json`: bundled Python
reference/audit.py --self-test and --source-root D:/development/game-prototype-2
--self-test equivalents PASS.20 source inputs,3 local reference and3 geography hashes
unchanged;5 offline/6 live in-memory drift rejection controls. Source read-only;
source tests were not run. No source/runtime dependency, export or publication.

## Rendered provenance and inspection

Final writer enginePID2768; separate readerPID53416. Writer records ordinary route
positions/timings/accepted keys, no teleport or state fixture. Save activated through
TestRunGui while paused; exact TestRunSnapshot.oracle (every prior and item durable
fact plus forecast) stored beside isolated save. New process begins with four fresh
wrappers, GUI Load compares typed disk oracle and distinct PID, finds all four absent,
then normally walks to former rod position. Synthetic process fixture suite separately
covers placed/authored/generated/foreign-room rod states and exact physical positions.

Final render/write-index.json and read-index.json record actual engine/window/camera/
world observations and empty failures. Paused world-only views use existing guarded
TestRunCapture (UI pause temporarily hidden only for world visibility). The two
live_frames deliberately report paused=false because pausing cancels the real hold;
no paused capture guard was weakened. Their inventory is empty, rod hold is active
with progress0.30986/visible then inactive0/hidden after release.

Full-size final PNGs inspected: write-rod-hold-progress, write-rod-release-cancel,
write-walk-approach-moonflower-01, write-walk-gathered-moonflower-03 and
read-restored-rod-absent. Prior passing rendered flower02/03 approach and GUI Load
frames also inspected. Rod visibly lies on dry dock; flower01 visibly clears cliff;
flower02/03 blooms and labels are readable at normal zoom. Progress is separate from
footer, readable hold prompt, no hovered/collider-embedded origin. Gathered/revisited
frames omit removed pickups. Final art/all-weather/all-projection/native proof awaits
its later tasks; this is ordinary rendered viewport input, not Windows OS input.

## Retained failures and repairs

- 20261007-203545433-0ebc756b: test-only capacity item definitions lacked required
  description; corrected fixture metadata.
- 20261007-203630939-c03d0e7c: synthetic settings fixture opened panel without real
  pause; corrected to actual paused settings gate, no production gate bypass.
- 20261007-203917232-2cc4853b: too-short startup movement preflight produced no motion;
  rest of ordinary writer completed. Added three post-resume process-frame settling
  and bounded15-physics-frame preflight with accepted-key/focus observations. Two
  subsequent full writer/reader journeys pass; original cause not otherwise assumed.
- 20261007-204602746-e14f24bc: added process helper referred to locally scoped game;
  explicit typed parameter fixed parse. Enhanced write/read PASS.
- Diff review found inadvertent UTF-8 punctuation corruption in root HUD strings;
  restored original characters and tested final interaction/light/dialogue plus full
  rendered write/read. Tracked unchanged line endings preserved.

Historical source/blocker/relocation findings and failed-run directories retained.
Diff/local-link/status review complete. F005 has no remaining acceptance criterion.
Next F006: implement backpack modal/active HUD using verified F004 inventory/save and
F005 input ownership. Do not activate F007 drop/drag before its geometry/UI prerequisites.
