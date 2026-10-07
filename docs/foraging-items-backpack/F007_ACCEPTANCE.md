# F007 — Safe rod drop and reposition acceptance

Completed 2026-10-07, America/Vancouver. Exactly F007 completed; F008-F010 Pending.
Initial HEAD `ae3eba7de2ba352f571c59f41fa2b292c5b54c62`; clean target worktree.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns rules.

## Observable result and ownership

Select the owned rod in B/Bag, then choose Drop rod. A successful nearby search
jointly consumes the bag rod, clears active selection, creates one generated world
placement and closes backpack. Failure leaves bag/active selection and modal intact,
with an explanatory message. Search starts toward facing and tries eight directions
at three radii; it never relocates the hero or changes map/navigation.

Press and hold the left mouse button over a nearby visible rod, move the pointer,
then release. Ground ray drives a green valid/red invalid ghost; original wrapper
and durable facts remain unchanged during preview. Valid release submits one atomic
move; invalid release keeps the original. Authored override uses the original ID;
generated move uses the existing dropped ID. Neither creates another rod.

WorldItemDrag owns only copied transient identity/revision/position and weak session/
target references. GameRoot owns mode, preview mesh, input latch, physical checks and
commands. ForagingState retains transactions; the existing location listener rebuilds
wrappers. Successful arrival/load binds one weak-session-qualified live placement
capability. Codec hydration revision remains0; live capability binding advances the
opaque token to1. Drag, ghost and input latch never enter saves.

## Every acceptance criterion

| Criterion | Fresh evidence and result |
| --- | --- |
| Normal pickup → activate → drop → drag → pickup | Final renderer walks from spawn with normal camera-relative WASD, moves authored rod, holds E, selects through B/Enter, clicks Drop, drags/recollects generated rod, then repeats placement. No teleport/grant/service setup. PASS. |
| Total rod1 across bag/world/origin/reload | Headless128 assertions, service587 assertions and exact independent process writer71/reader74; ordinary renderer checks rod1 after every command and restart. Bag drop clears active, pickup removes generated placement and keeps authored origin suppressed. PASS. |
| Authored/dropped move creates no duplicate | Both actual pointer routes replace the same wrapper/placement identity. Headless and renderer verify authored override, generated replacement, original suppression and rod1. PASS. |
| Water/blocked/outside/steep/unsupported/unreachable/reserved rejection and rollback | Production water/cliff/outside/height/arrival/portal/nonfinite geometry, synthetic slope, missing nav capability, supported disconnected island and narrow endpoint collider all reject. Actual invalid pointer-release matrix preserves exact item facts; ordinary water-directed invalid release also rolls back exactly. Synthetic cases are labeled. PASS. |
| No-space drop keeps bag/active | Actual production arrival reservation contains every nearby search candidate in synthetic hero-position fixture. Drop leaves exact bag/selection/world facts, modal and feedback; water-facing dock fixture proves alternate directions. PASS. |
| Attack/aim conflicts blocked | Drag press consumes attack; controls/combat/AI cleared/disabled. W/Space/E/P/+/- cannot move, dodge, gather, turn, aim or change camera during drag. Direct interaction/light commands reject. Fresh pointer attack works after cancel/travel/recollect. PASS. |
| Esc/focus/pause/travel/load/retry cancels without mutation | Headless matrix covers all named gates, backpack/journal/dialogue/GUI focus, entry hooks, changed revision/owner/target position and target removal. Preview disposed; exact durable item facts unchanged; old pointer release consumed. Esc cancels before pause; fresh E works. PASS. |
| Both projections and zoom bounds correct | Real camera ground-ray roundtrip and pointer hit/preview/cancel at orthographic/perspective × zoom0.8/1.15. Error <0.01m; preview has no fact mutation. PASS. |
| Rod retrievable after placement/travel | Ordinary Tollworks round trip and normal dock revisit find exact placed foot and reachable wrapper. Separate GUI Load process walks from restored last-arrival anchor and physically holds E to recollect. Synthetic indoor drop/foreign-room travel/revisit/pickup verifies both location branches. PASS. |

Shared geometry now covers all nine support points at X±0.5/Z±0.22m and a
1.0×0.14×0.44m clearance box centred0.1m above foot. Existing normalY≥0.9,
height tolerance0.06m, radius0.4/height1.6m capsule, navigation owner/0.4m tolerance,
arrival path/0.1m endpoint and 0.2m collision samples, 1.5m spawn/2m portal
reservations remain. Live commands additionally require hero distance≤1.5m,
0.1m dry local approach samples, adjacent height steps≤0.1m and clear LOS. This
prevents endpoint clipping and cross-bank shortcuts without weakening restore.

## Commands, isolation and outcomes

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7,
installed console4.7.2.stable.mono.official.ed1daf0bf. Fresh runner evidence/appdata/
localappdata/save slots under docs/evidence/F007 and builds/testing/F007. Normal save
untouched. All results.json and relevant full logs reviewed; final diagnostics empty.

| Run | Arguments after ./tools/run_checks.ps1 | Outcome |
| --- | --- | --- |
|20261007-220518849-11e36ba1| -Task F007 -Names foraging_interaction_checks,backpack_ui_checks -TimeoutSeconds 150 | PASS inspected prerequisites. |
|20261007-220843828-6ce5b7f4| -Task F007 -Import -Names application_smoke,foraging_anchor_checks -TimeoutSeconds 150 | PASS new drag class import/parse/startup/full-footprint anchors. Allowed existing editor-only missing .NET SDK10.0.9 diagnostic; no install. |
|20261007-221952288-bd1be44f| -Task F007 -Names world_item_placement_checks,foraging_anchor_checks -RenderScript world_item_placement_render -RenderPhases write,read -TimeoutSeconds 150 | PASS headless indoor/geometry and ordinary rod/travel/exact GUI restart. |
|20261007-222143996-d4aa795e| -Task F007 -Names world_item_placement_checks,backpack_ui_checks,foraging_transaction_checks,foraging_save_checks,map_navigation_checks,map_save_checks,movement_camera_checks,foraging_interaction_checks,location_travel_checks,live_playtest_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150 | All ten selected headless suites PASS; old process fixture token0 assertion FAIL. Retained; corrected below. |
|20261007-222237176-015ce980| -Task F007 -RenderOnly -RenderScript world_item_placement_render -RenderPhases write,read -TimeoutSeconds 150 | PASS settled final green/red preview, ordinary loop/travel, exact GUI process restart and physical recollect. |
|20261007-222352948-2d6c59fa| -Task F007 -Names world_item_placement_checks,interaction_dialogue_checks,light_interaction_checks,settings_debug_checks -TimeoutSeconds 150 | PASS final expanded128 placement assertions/direct guards; dialogue, lights151 and settings. |
|20261007-222435865-2b1a1307| -Task F007 -Names foraging_save_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150 | PASS strict save111, independent writer71/reader74. Exact all prior/item fields and physical authored/generated/foreign wrappers; no restored drag/latch. |

Final direct-command guards were added while the final render journey ran; they only
reject programmatic interaction/light calls during drag. Ordinary rendered events
already consumed these inputs. Final headless tests exercise the added guards.

Bundled Python reference/audit.py --self-test and --source-root
D:/development/game-prototype-2 --self-test PASS, saved in
`audit-20261007-222532-37ffd81f/results.json`.20 source,3 reference and3 geography
hashes unchanged;5 offline/6 live negative controls; source Git status clean.
Source/Flutter tests not run. No runtime dependency/export/install/publication.

## Render provenance and inspection

Final writer/read manifests in20261007-222237176-015ce980/render identify distinct
engine PIDs/version (writer25976/reader71292), isolated data, normal input traces and empty failures. Writer
has four live drag views, two unpaused backpack views and three paused world/Save
views. Reader has two paused Load/recollect views. Normal world/GUI captures use
unchanged TestRunCapture pause guard. Drag captures explicitly report paused=false,
active drag and disabled controls; pausing would cancel preview. No guard bypass.

TestRunSnapshot oracle compares every durable item and prior field and exact forecast
against writer and independently decoded disk at stable paused Load. Reader then
walks normally from the saved last-arrival anchor and physically recollects the rod.
Resumed travel/time checks remain separate from the exact stable restart oracle.

Full-size final water-red, generated-green, placed-rod-after-travel and
restored-rod-recollected images inspected. Invalid prompt is clear; red and green
ghosts appear at pointer ground, actual rod stays at original until commit. Red ghost
is small against brown dock, verified in final pixels (131 red pixels in inspected
region versus0 in green frame); F008 owns final art/feedback readability. Placed rod
is supported on dry dock after travel, and disappears after reader pickup. Earlier
passing Drop-ready backpack image inspected: active rod/count, enabled Drop and
Close fit. These prove viewport integration; Windows OS/native gate remains F010.

## Retained failures and necessary repairs

-221116827/221241462/221320859/221546231: synthetic disabled-region fixture inferred
  readiness too early, invalidating later arrival paths; first water-facing fixture
  stood on dry shore. Replaced with missing capability plus separately synchronized
  disconnected-island probe, restored production sync barrier and actual dock pose.
  No placement/nav/LOS policy weakened. Full run IDs carry20261007 prefix.
-221659582: disconnected probe lacked matching map cell size/sync barrier. Corrected
  fixture to0.01m cells and established WorldHost synchronization.
-221503679: inherited walk limit1800 frames exhausted before distant gate; added
  bounded normal intermediate waypoints.221753939: proposed gate approach was beyond
  nav edge; changed to reachable approach(107.25,0,0). No teleport/control bypass.
-222143996: inherited process assertion expected token0 after live binding. Codec
  still tests fresh0; physical process fixture now requires inventory revision0,
  exactly one capability token1, rod1 and empty drag/preview/latch. Writer/reader pass.

First preview inspection could not readily distinguish the small red ghost; cause
was not established. Added no-depth preview overlay and settled capture frames,
then repeated ordinary renderer; final actual red pixels/invalid prompt inspected.
Backpack open now forces presentation so restored active rod enables Drop without
reselection. Full endpoint volume probe closes a ray-start-inside narrow-prop gap.
Whitespace check uses command-local cr-at-eol for historical CRLF files.
First newline-preservation command hit elevated-user Git ownership rejection before
rewriting tracked files; command-local safe.directory retry passed. No global config.

Changed root, shared geometry, backpack, bridge observations, inherited process/UI
checks; added WorldItemDrag, placement checks/renderer and three UIDs. Parent and
workflow docs updated. All owned runner processes exited; no editor/game or cleanup
owed. Schema6/content1, source/geography, normal saves and historical packages retained.
No remaining F007 criterion. Next eligible F008; stop before successor.
