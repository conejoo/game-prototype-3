# R009 physical same-map movement acceptance

Done 2026-10-09 UTC. Exactly R009 completed; R010-R016 remain Pending.
No blockers or unrun R009 criteria. No commit/push; separate commit instruction
follows review. Baseline target `9e4521c`, clean index/worktree; read-only source
`60c20eb2816e7271fb84afaba286af006ebe3ccf` remains clean. No user changes existed.
Workspace instructions, source AGENTS/test-gameplay, installed/versioned Godot
testing guidance, current architecture and save/journey/capture/native guidance
were read. No applicable nested target AGENTS/.agents. Supplied engines exist.
Sandbox shell fails before execution; scoped reviewed PowerShell works. No
automatic approval rejection. Unrelated Blender PID2664 remains untouched.

## Delivered behavior and preservation

RoutineMovement owns one transient same-map leg; RoutineOccupancy accepts injected
live weak body registrations and exclusive station claims. One CharacterBody3D
per existing interaction wrapper; no ActorPlaceholder combat inheritance, attacks,
catch-up teleport, duplicate identity or saved position/path/cursor. Maris uses
her original 0.35m radius/1.6m capsule, every other villager 0.4m/1.6m.
Her original bench, supplies, fitting/specialist gear and board keep exact world
transforms under unchanged presentation paths; only her single interaction and
presenter move. Existing recovery/social command ownership remains intact.

Obsolete NPC contact outlines and inn host hole are removed from navigation;
real bench, furniture, terrain and unrelated fixed companion station stay solid.
No source geometry, anchor X/Z, room layout, graph, rig or geography pin changes.
Each leg starts at real current feet. One initial static path query, normalized
to measured physical floor heights, ends with an actual swept terminal leg.
No path query on unchanged clear frames. Actual kinematic displacement drives
walk speed/facing; stopped movement selects idle. Sorted NPC stepping and first
accepted station claims give deterministic contention. Blockage waits0.5s,
repaths at most twice, and fails within1.5 active blocked seconds. Typed failures
distinguish invalid targets, no path, blockage, unsupported floor and disposal.
Huge finite deltas cannot skip physical collision. Common root holds freeze
motion/timers/rigs; cancellation/failure/unload release reservations/weak bodies.
InteractionSelector's existing real-wrapper distance/ray path now follows moved
feet. No production schedule activation; R010/R013 own execution/activation.
Strict schema8/content1, clock/weather, item/gift/People, party/combat and manual
save owners remain unchanged.

## Acceptance mapping

| Criterion | Actual evidence |
| --- | --- |
| Actual world walks reach targets without terrain/capsule penetration | Movement check:18 continuous legs,412 physical samples,1363 assertions; all eight existing bodies, Edric's four stations, Ivo circuit, Helena's physical lane clearance/return, Harlan/Tess/Celia station lanes, Maris departure/return and indoor Della lane/return. Every sample checks actual support/capsule clearance and <=0.2m displacement per synthetic0.1s tick. All clear legs request one path/no repath and reach exact feet. Synthetic commands/setup explicitly labeled. |
| Opposing movers/player/ally blockers have deterministic bounded outcomes | Occupancy check311 assertions: exact repeat of opposing bodies, live hero/ally capsules, exclusive station/waiter transfer, cancel/dispose, thin barrier with huge finite delta, narrow0.6m door refusal versus1.4m door success. Never overlaps/phases; two repaths/three queries/<=1.5s blockage. |
| Typed no-path failure | Production disconnected `(107.25,0,-2)` rejects NO_PATH before motion; nonfinite input rejects INVALID_TARGET. Barrier/door tests yield finite typed BLOCKED; freed wrapper yields DISPOSED. |
| Pause/modal/focus/death stop motion | Direct hold/timer/rig tests plus actual root focus, journal, backpack, load, retry, death and pause gates; rendered public Esc/J/E suspend the actively moving Ivo. Resume starts at actual held feet. |
| Cancellation/unload releases reservations | Station contention/cancel/dispose and freed-body tests; active reserved production leg followed by actual inn travel clears retained old occupancy to zero bodies/reservations and disposes mover. One indoor Della/unchanged party remains. |
| Selector/LOS follows actual feet | Physically moved Maris selected from actual approach; intervening real wall rejects LOS; retired registry foot cannot select her; original recovery route still opens. Rendered public walk/E finds moved Ivo. |
| Animation reflects achieved motion | All physical samples assert exported walk/idle from actual displacement; live renderer asserts2m/s, walk/arrival idle, held rigs. Six inspected captures include both projections, planted dock feet and readable dialogue/journal. |
| Required existing integrations preserved | Final movement_camera_checks, companion_checks, interaction_dialogue_checks, npc_world_checks all pass. Affected anchor/inn/asset/recovery checks also pass, including existing party save/restore, NPC load/retry/travel rollback and counter reconnection. |

## Commands, isolation and exact results

Cwd `D:/development/game-dev-blender/returning-fair-prototype`; PowerShell7,
installed console `4.7.2.stable.mono.official.ed1daf0bf`, GL Compatibility960x640;
bundled Python3.12.14. Final command:

```powershell
./tools/run_checks.ps1 -Task R009 -Import `
  -Names routine_movement_checks,routine_occupancy_checks,movement_camera_checks,companion_checks,interaction_dialogue_checks,npc_world_checks,routine_anchor_checks,routine_inn_checks,npc_asset_pipeline_checks,recovery_presentation_checks `
  -RenderScript routine_movement_render -RenderPhases check `
  -ParseScripts features/routines/routine_movement,features/routines/routine_occupancy `
  -TimeoutSeconds 150
```

[Final report](../evidence/R009/20261009-181351610-f8325aab/results.json): PASS14
cases, every exit0/forbidden diagnostics empty/source.changed=false/error=null.
Stable import records only runner's existing exact SDK diagnostic allowance;
no C# build/install. Final1258-file game/tools fingerprint
`bc60cc4228e5fb3b17acb95c1a1e64e75e336bf9febfd8a77c5dc3bc7408e8bc`.
Movement1363/412samples; occupancy311; NPC-world9884/9757samples;
anchors51230/7095sweeps; inn1997/950sweeps; asset839; renderer31/6captures.
Independent checks have separate R009 save_group/slot/APPDATA/LOCALAPPDATA under
`builds/testing/R009/<run>`; renderer has its own group. Existing save/backup
paths stay inside isolated groups. Normal saves/source/packages untouched.

Live reference command: bundled Python `tools/routine_migration/reference_checks.py
--source D:/development/game-prototype-2 --self-test --report
docs/evidence/R009/reference-final/results.json` PASS1624 assertions/88source
inputs/25routines/21anchors/74exact target adaptations/ten negative refusals.
Original baseline before-hashes, source snapshots and prior reasons stay exact;
owning R009 changes append previous accepted hashes instead of refreshing pins.

Final `tools/capture_evidence.py` on renderer's movement-render-index.json passes
six state/provenance records. Viewed all six on
[final contact sheet](../evidence/R009/20261009-181351610-f8325aab/render/derived/20261009-181629-150131c7/contact-01.png)
and full ivo-walk-perspective.png: readable Ivo/rig/feet, docks/furniture and
party lane, distinct walk/idle, both projections, actual contact dialogue,
journal and confirmed pause. Earlier six captures also inspected. Public
WASD/E/J/Esc/P input uses shared journey/capture helpers; synthetic initial
party placement and Ivo leg commands never claim ordinary schedules/native input.

## Repairs and retained limits

First import175855 correctly fails source stability for four generated UIDs;
175932 occupancy passes, movement reveals bake waypoint Y versus physical Y
and furniture top-level transforms.180119 catches global-transform access
before staged scene enters tree; pinning now occurs on ready or ready-build.
180203 exposes legitimate blocking by Helena's actual body on civic return.
180258 retains an invalid synthetic Helena endpoint, old compact missing new
portal/spawn declarations and route audits expecting baked stationary NPC holes.
Repairs physically clear Helena to a verified civic lane; add only unused compact
portal/spawn metadata (geometry/old IDs unchanged); static route audits retain
all terrain/furniture/support/continuous sweeps while excluding transient NPC
bodies. Dedicated new tests retain actual occupancy/collision requirements;
placement/interaction/LOS checks still include live other contacts.
180546 passes all four repaired cases.180832 correctly fails only new renderer
UID source drift;180858 passes strengthened movement/occupancy/render cases.
Failed whole reports remain failed; no runtime diagnostic allowance was added.

The first ignored ledger helper omitted preservation_baseline; gate refused
`.gitattributes` drift. Repaired helper audits the full union. Its first report
path was reused; [exact failed stdout observation](../evidence/R009/reference-first-observation.json)
retains that failure transparently. Final live gate passes. No runtime source
was changed to evade a gate.

All owned Godot processes exited; no held input/editor/cleanup owed. Only
unrelated Blender2664 remains. No runtime performance/full-day/natural-weather/
cross-map/routine-dialogue/action/native claim; those remain R010-R016 gates.

[Final readback audit](../evidence/R009/final-audit.json) verifies all1258 accepted
source hashes, exact27 intended paths, all16 statuses/dependencies/relative links,
independent save groups, unchanged HEAD/empty index/clean source and whitespace.

## Exact intended allowlist

27 paths; preserve everything else. Raw evidence/staging remains ignored.

```text
.gitattributes
docs/ARCHITECTURE.md
docs/day-clock-npc-routines/CHECKLIST.md
docs/day-clock-npc-routines/CURRENT_STATE.md
docs/day-clock-npc-routines/R009_ACCEPTANCE.md
game/app/game_root.gd
game/features/npcs/npc_world_adapter.gd
game/features/routines/routine_movement.gd
game/features/routines/routine_movement.gd.uid
game/features/routines/routine_occupancy.gd
game/features/routines/routine_occupancy.gd.uid
game/tests/fixtures/compact_alderwake.tscn
game/tests/npc_asset_pipeline_checks.gd
game/tests/npc_world_checks.gd
game/tests/routine_anchor_checks.gd
game/tests/routine_inn_checks.gd
game/tests/routine_movement_checks.gd
game/tests/routine_movement_checks.gd.uid
game/tests/routine_movement_render.gd
game/tests/routine_movement_render.gd.uid
game/tests/routine_occupancy_checks.gd
game/tests/routine_occupancy_checks.gd.uid
game/world/alderwake_exterior.gd
game/world/lantern_rest.gd
game/world/maris_counter.tscn
tools/routine_migration/adaptations.json
tools/routine_migration/reference_checks.py
```

Next eligible R010 after separate successful-task commit review: consume these
physical wrappers and R003/R004/R007/R008, implement only group/cross-map executor
and bounded night reconstruction with actual source INT-064 regression. Stop here.
