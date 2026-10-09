# R010 group/cross-map execution acceptance

Done 2026-10-09 UTC/America/Vancouver. Every R010 criterion passed; no R010 blockers
or unrun criteria. Exactly R010 completed; R011-R016 remain Pending. Earlier reports
and the final sparse-assignment/civil-midnight refresh are retained.
R001-R009 prerequisites verified. Baseline target
`4b9d45d56d4884b22fb6aaf80579d94d8d10f8d8`, clean index/worktree, no user changes.
Read-only source `60c20eb2816e7271fb84afaba286af006ebe3ccf` and user instructions
preserved. Applicable workspace/source instructions, source test-gameplay skill,
installed and repository Godot testing guidance, architecture, contract, current
handoff and save/journey/capture/native guidance read. No nested target instructions.
Both supplied Godot executables exist. Default sandbox shell fails before execution;
scoped reviewed PowerShell works. No automatic approval rejection.

## Delivered behavior

GameRoot optionally owns one transient RoutineExecutionDirector. RoutineExecutor
exposes typed move/wait/action/speech states, active finite timers, failure enums,
qualified map/foot and bounded diagnostic details. Whole participant assignments
validate before publication; unchanged assignment retains its cursor. Loaded
reassignment starts at actual feet. Root lifecycle holds freeze execution/timers.

RoutineExecutionWorld consumes current public anchors and measured source-door/
arrival metadata plus validated directed PortalRoutes. It does not instantiate
unloaded rooms. Loaded actors walk the physical source door, then remove their
single collider/contact/presenter synchronously. Offscreen moves consume finite
distance/2m-per-second legs. Active arrival validates floor/capsule/navigation,
actual NPC/hero/ally bodies and station claims before publishing one wrapper and
one reservation. Blocked arrival fails within1.5 active seconds at its safe source;
the whole routine group cancels and no stale destination actor is published.
Groups share assignment/cancellation, while authored participant steps may target
different maps (morning Edric town/Helena home is intentional).

Fresh/restore reconstruction uses map-qualified guaranteed predecessor stations,
sweeps authored steps once, and never replays rewards or historical days. Partial
historical moves retain a safe qualified origin and walk when loaded. Limits are
64 transitions/actor and512 total. Scene replacement stages detached restore state;
only successful physical publication commits it. Rollback reattaches old actual
bodies and reissues unfinished loaded movement from actual feet without restarting
waits or unrelated offscreen travel phases/timers. Occupied player arrival refuses
safely; a bounded ordinary retry succeeds after the NPC leg naturally clears it.

No source/geography/room geometry/content/art edits, extra cast, new clock,
saved cursors/positions, reward replay, NPC-driven player travel or combat party
members. Save schema8/content1, clock/weather, manual save, social/item/recovery
and party owners remain unchanged. Default activation remains R013; dialogue
leases/directives belong to R011, action/speech art to R012, whole-runtime stress
and profiling to R014, full natural day/native package delivery to R015/R016.

## Acceptance mapping

| R010 criterion | Actual evidence |
| --- | --- |
| Typed move/wait/action/speech and atomic groups | Executor71 assertions: all four authored kinds, actual finite timing/expiry, unchanged cursor/revision including20 repeated sparse plans, common holds, partial group rejection before mutation, no durable/reward/private-text publication. Unchanged absent assignments cannot clear an unrelated group lane. |
| Loaded actor walks source door | Cross-map3495 assertions sample <=0.2001m/0.1s loaded movement and transfer records prove actual source foot `(5,0,-5.15)`. Renderer pauses at the actual <=0.25m door approach, then observes contact removal and follows via public WASD/E. |
| Valid offscreen chains; one safe active arrival | Measured qualified home/town/inn metadata; unmeasured player-only Tollworks NPC chain rejects. Active town Edric enters through the measured arrival, reserves one wrapper/body and physically walks to `(-0.5,0,-1.5)`; Helena remains home. Hero-blocked arrival publishes nothing, keeps safe source foot and cancels the whole group. |
| Ordinary night differs from seek/fresh/load22/00/06 | Continuous-clock physical night/breakfast/morning tests never seek after their labeled setup. Separate fresh detached22/00/06/08 cases verify qualified predecessor origins. Independent-process actual paused root Load/Save validates22/00/06 against full durable/forecast oracles and exact primary/backup JSON. |
| Diagnose/regress hidden overnight failure; home rest/morning | Retained source INT-064 observation plus actual mixed-coordinate floor/capsule refusal; no hidden town body after departure. Ordinary loaded-home22:00 regression physically reaches Edric `(-5.5,0,0.25)` and Helena `(-3.5,0,0.25)` with one wrapper/station claim each; continuous midnight/breakfast/morning returns Edric to town. Rendered door, visible pair/rest and morning walk/return inspected. |
| Bounded max clock/huge delta | Reconstruction495 assertions cover every participant of all25 definitions at0/1/50/600/1e100 seconds, finite feet/<=64 transitions. Day3650/progress0.99:20 final reconstructions, maximum31.246ms, <=512 transitions. Nonfinite/negative deltas and invalid origins/chains refuse; huge active delta cannot mutate durable clock/rewards or skip physical collision. |
| Failed transfer/scene replacement restores ownership | Blocked arrival has typed ARRIVAL_BLOCKED, no stale wrapper/reservation. Existing unsafe R007 home replacement refuses, restores exact logical snapshot/same room, exact two NPC plus two party body bindings and one navigation region. Actual Edric-occupied town player arrival also refuses; rollback preserves exact offscreen cursor/remaining/feet and qualified ownership, retains loaded Helena feet, then finite progress/public E retry safely publishes town. |
| Same-map reassignment uses actual feet | Executor reads real adapter foot before publishing changed assignment; no elapsed catch-up placement. |
| Required travel/companion integrations | Current default movement/occupancy, NPC-world, home, inn, save, location-travel and companion checks pass; activation remains absent in ordinary default root. |

## Commands and evidence

Cwd `D:/development/game-dev-blender/returning-fair-prototype`; PowerShell7,
installed console `4.7.2.stable.mono.official.ed1daf0bf`, GL Compatibility960x640,
bundled Python3.12.14. Final combined command:

```powershell
./tools/run_checks.ps1 -Task R010 `
  -Names routine_executor_checks,routine_cross_map_checks `
  -ProcessScripts routine_reconstruction_checks `
  -RenderScript routine_cross_map_render -RenderPhases check -TimeoutSeconds 180
```

[Final combined report](../evidence/R010/20261009-194406532-09e2abb0/results.json)
PASS7 cases, every exit0/forbidden diagnostics empty/source.changed=false/error=null.
Executor71/cross-map3495/restart writer20/reader30/render47 assertions,7 captures.
1274-file fingerprint `e8158a168e4a30e01e159f45dc056e239ed4aa70bf7d2629e3c0148ff56d19b5`.

`./tools/run_checks.ps1 -Task R010 -Names routine_reconstruction_checks
-TimeoutSeconds 180`:
[final bounded report](../evidence/R010/20261009-194742864-677989af/results.json)
PASS3 cases/495 assertions; same1274 source hashes,20 samples/max31.246ms.

`./tools/run_checks.ps1 -Task R010 -RenderOnly -RenderScript
routine_cross_map_render -RenderPhases morning -TimeoutSeconds 180`:
[final clear morning report](../evidence/R010/20261009-193018784-064f399c/results.json)
is retained earlier supplemental evidence, PASS3 cases/2 captures. Final combined
run now also captures unobstructed morning return with verified pause/state.

Earlier regression/restart command:

```powershell
./tools/run_checks.ps1 -Task R010 `
  -Names routine_executor_checks,routine_movement_checks,routine_occupancy_checks,npc_world_checks,routine_home_checks,routine_inn_checks,save_checks,location_travel_checks,companion_checks `
  -ProcessScripts routine_reconstruction_checks `
  -RenderScript routine_cross_map_render -RenderPhases check -TimeoutSeconds 180
```

[Regression/restart report](../evidence/R010/20261009-190708819-28bd002d/results.json)
has13 passed engine/parse/check/process cases, then a failed optional rest-contact
render probe. Whole report remains failed. Movement1363/occupancy311/NPC-world9884,
home5368/2586sweeps, inn1997/950sweeps; save/travel/companion pass. Restart writer20/
reader30 assertions, distinct PIDs, three exact22/00/06 primary/backup/full oracles.
All existing default gameplay/check bytes remain identical to final run; changed
game/tools files since that report are new R010 director (offscreen timer repair),
cross-map check (real occupied player-return/midnight regression), executor check
(sparse assignment stability), renderer and ledger.
Final combined run repeats the restart pair after that lifecycle repair.

Each independent check has its own save group/slot/APPDATA/LOCALAPPDATA under
`builds/testing/R010/<run>`; process writer/reader share only their isolated pair,
renderer has its own group. Normal saves, source and packages untouched. Inspect
exit status, forbidden diagnostics and source stability as well as structured
assertions. No SDK installation/build; only existing runner's exact SDK diagnostic
allowance applies to import observations.

Bundled Python `tools/routine_migration/reference_checks.py --source
D:/development/game-prototype-2 --self-test --report
docs/evidence/R010/reference-final-midnight/results.json`:
[live gate](../evidence/R010/reference-final-midnight/results.json) PASS1624 assertions,
88pins/25routines/21anchors/74 exact adaptations/ten negative refusals. Original
before-hashes/source pins and all previous reasons retained; six R010-owned
adaptations append previous accepted hash/owner. No source test execution claim.

Capture helper validates all7 combined and2 clearer morning records. Viewed all
seven on [combined contact sheet](../evidence/R010/20261009-194406532-09e2abb0/render/derived/20261009-194747-77e579d0/contact-01.png),
plus full town-edric-door/home-pair-night-rest and
[clear morning return](../evidence/R010/20261009-193018784-064f399c/render/town-edric-morning-return.png).
Doorway feet and exported Edric identity readable; both home actors visible at
exact rest, no hidden town copy, warm room/furniture intact, Edric back at civic
station with persistent party and unchanged town. Both projections inspected.
Original morning pause-overlay capture retained; final combined capture hides
only the overlay while tree pause remains verified.

## Diagnosis, retained failures and limits

Source INT-064 reports Edric hidden with town foot `(704,528)` during overnight
reconstruction; original enum remains unconfirmed and source was not executed.
Regressing its coordinate class against actual target physics transforms that
town foot using home origin `(256,384)/32` into `(14,0,4.5)`, which genuinely fails
home floor/capsule checks. Repair keeps map identity and foot inseparable, uses
qualified predecessor stations, and refuses before unsafe publication.

Loaded-home21:59-to22:00 initially exposed a second real failure: Helena at her
near-side rest blocks Edric's far-side physical path. Edric stopped around
`(-2.825706,0,-0.487288)`, typed BLOCKED, blocker npc-02, two repaths/three queries.
Retained in [failed physical report](../evidence/R010/20261009-185241549-4aecaa4d/results.json).
Repair uses a bounded three-phase physical lane: Helena yields to her existing
archive desk, Edric reaches far-side rest, Helena returns to unchanged rest.
No teleport, authored anchor/step/geometry edit, hidden actor or timer replay.

Other retained attempts:183737/184428 imports generated UIDs and correctly failed
source stability;183838 exposed expected body count omitting persistent party;
184134/190640 preflight rejected incorrect runner arguments;184609 exposed morning
town count including Helena although she stays home;184753 renderer left party
in the central NPC lane;185628 runner session disappeared with unfinished report
and no remaining Godot. No unfinished report relabeled.185935 passed cross-map
but rendered focus loss held execution while the clock advanced; real OS foreground
activation with verified root focus now restores focus, never overwrites guards.

190708 rendered both exact rest stations, then its extra public Edric dialogue
probe hit Helena's solid capsule in the bed passage. Failure retained, collision
unchanged. That probe was outside R010 acceptance and was removed from final
driver; no rest-dialogue success claimed. R011's interaction/group lease review
must consider far-side rest access. This is a successor interaction concern;
R010's required physical rest, departure/arrival and morning return remain gates.

191407 passed focused checks but morning viewing party lay in the breakfast lane;
Edric/Helena remained home and public exit hit a contact body. Moving only the
synthetic initial party pose to the study preserved ordinary companion AI and
allowed physical departure.191842/192206 then exposed a real safe player-arrival
refusal: Edric still occupied town return foot during his2.7s offscreen leg.
Rollback incorrectly reset unrelated offscreen timers. Binding now reissues only
physical loaded legs; offscreen phase/remaining remain exact. New actual refusal/
rollback/wait/retry regression passes;192437 morning-only repair and final combined
run both pass. No collision exclusion, NPC/player teleport or geometry edit.

Final review also regresses unchanged sparse plans: absent-to-absent participants
must not churn revisions or clear an unrelated group lane.20 repeated sparse plans
retain the revision. Loaded rest continues through actual civil midnight with the
same Edric/Helena cursors/feet and exactly19s of wait consumption (233.7->214.7).
The194105 failed test mistakenly expected environment day_index to increment at
midnight. Existing clock cycles begin10:00; corrected test observes minute wrap
and unchanged authoritative day. Speculative calendar-continuation code removed;
no clock/day semantics changed. Failed report retained, final refresh passes.

Initial clock/party placements and deterministic/headless active-delta sequences
are explicitly synthetic. Rendered driver then uses unaccelerated root clock,
real NPC physics and public viewport WASD/E/P/Esc with verified pause captures.
No natural full-day/weather, native input, package, default schedule activation,
routine dialogue or action/speech presentation claim.

## Exact intended changes and stop

Exactly27 paths:

```text
.gitattributes
docs/ARCHITECTURE.md
docs/day-clock-npc-routines/CHECKLIST.md
docs/day-clock-npc-routines/CURRENT_STATE.md
docs/day-clock-npc-routines/R010_ACCEPTANCE.md
game/app/game_root.gd
game/app/world_host.gd
game/features/npcs/npc_world_adapter.gd
game/world/prototype_location.gd
tools/routine_migration/adaptations.json
tools/routine_migration/reference_checks.py
game/features/routines/routine_execution_director.gd
game/features/routines/routine_execution_director.gd.uid
game/features/routines/routine_execution_world.gd
game/features/routines/routine_execution_world.gd.uid
game/features/routines/routine_executor.gd
game/features/routines/routine_executor.gd.uid
game/tests/routine_cross_map_checks.gd
game/tests/routine_cross_map_checks.gd.uid
game/tests/routine_cross_map_render.gd
game/tests/routine_cross_map_render.gd.uid
game/tests/routine_executor_checks.gd
game/tests/routine_executor_checks.gd.uid
game/tests/routine_reconstruction_checks.gd
game/tests/routine_reconstruction_checks.gd.uid
game/tests/support/routine_execution_fixture.gd
game/tests/support/routine_execution_fixture.gd.uid
```

[Final readback audit](../evidence/R010/final-audit-midnight.json) verifies27 intended paths,
1274 exact accepted game/tools hashes,1448 unchanged pinned hashes and unchanged
content of all1459 unrelated tracked files (two ordinary CRLF checkouts checked
separately),all16 statuses/links,unchanged HEAD/empty index/clean source/whitespace.
All owned Godot exited; no held input/editor or cleanup owed. Unrelated Blender
PID2664 untouched. No commit/push; separate instruction follows review.
Next eligible:R011, read group/context APIs and implement routine dialogue leases/
directives including far-side rest interaction review. Remaining unfinished IDs:
R011,R012,R013,R014,R015,R016. Whole checklist throughR016 complete:no.
