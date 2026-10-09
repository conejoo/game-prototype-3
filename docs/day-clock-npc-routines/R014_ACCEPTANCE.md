# R014 integration and measured runtime acceptance

Status: Done (2026-10-09 UTC). Exactly R014 completed; R015 and R016 remain Pending.
Baseline target HEAD: d84192a07427b1bba8acb5b7d6c5c3499c8b036f, clean tree and empty index.
Read-only source: D:/development/game-prototype-2, revision 60c20eb2816e7271fb84afaba286af006ebe3ccf.
Current schema8/content1 only; no migration, new save fields, new cast, geometry,
assets, packages or public full-day/native claims. This turn does not commit or push.

## Delivered checks and bounded repairs

The new lifecycle check uses the default production root, a complete synthetic
current-schema social/item/quest/weather/routine state, actual WorldHost transitions,
failed travel/load rollback, death/retry and ten settled town/home/inn cycles.
The process check uses separate writer and reader OS processes, real repository IO,
manual production Load/Save, exact full typed durable and forecast oracles, primary
and backup slots, and actual scheduled contacts. It verifies no duplicate rewards,
events or quest effects and no execution cursor/position/lease in save JSON.

The required companion regression found that activation incorrectly subjected the
existing prototype companion graph to a villager routine lease. Only the eight
villager roster members now acquire that lease; the existing graph keeps its own
root/service authority. A full-root check verifies valid companion dialogue and
holds without a villager lease, complete durable-state preservation on cancel,
and refusal of a stale villager contact.

The old social process fixture used fabricated contact IDs. Its reader now visits
each actor's actual scheduled map, opens the actual instance, cancels, and returns
to the original saved arrival. Exact full-state/forecast and IO recovery assertions
remain. The production instance guard is preserved.

The active scheduler originally rebuilt immutable condition wrappers, sampled
elapsed reconstruction plans and revalidated unchanged assignments every frame.
The assignment director caches detached immutable conditions. Its existing public
update defaults to fresh elapsed samples; execution requests assignment-only
samples and retains its physical cursors on unchanged decisions. Every update still
evaluates clock windows, authoritative day, weather, facts, suppression and event
recency. Dialogue closure still performs full reconciliation. Regression and
before/after performance evidence pass as recorded below.

## Verification method and isolation

Commands run from D:/development/game-dev-blender/returning-fair-prototype using
PowerShell7 tools/run_checks.ps1 and the explicit installed Godot4.7.2 Mono console.
Tests are typed GDScript, Compatibility; no SDK installation is needed.
Each runner report records isolated APPDATA/LOCALAPPDATA and named primary/backup
save groups under builds/testing/R014/<run>. No normal profile save is configured.
Source manifests bracket every case and the whole invocation. Failed reports and
logs remain under docs/evidence/R014; individual accepted cases in a failed overall
invocation never change that invocation's failed status.

The rendered profile uses Intel Core Ultra9 185H, RTX4070 Laptop GPU, NVIDIA581.29,
OpenGL3.3 Compatibility at960x640, max_fps0, transient vsync0, guarded window focus.
It measures six configurations: town empty/eight/eight/empty ABBA and the two real
interiors. Each has one second warmup and1000 focused active frames, raw CSVs,
nearest-rank percentiles and a paused synthetic capture. Peak-eight setup explicitly
relocates two indoor actors to legal town sites and cycles test-only short legs on
the existing eight real CharacterBody/rig/executor owners. Synthetic fixture reset
and diagnostics are outside the production scheduler interval; whole-frame cadence
still includes all work. Production timing includes visual holds/presentation,
context/selector/director and physical movement/rig requests. Occupancy probes are
separately measured. All authored consecutive map-qualified MOVE legs are queried,
with portal doors/arrivals decomposed and duplicate nonzero segments combined:
10 warmups plus100 timed queries per segment with actual navigation endpoint checks.
Maximum supported day3650/progress0.99 uses10 warmups plus100 detached stages;
all25 routines' participant reconstructions also receive elapsed1e100.

## Retained failures and repairs

- 20261009-220619292-dbb949cf: map companion Begin refusal cascaded to hold/recovery failures. Companion ownership repaired; later map companion check passed.
- 20261009-221004757-e18e1c7c: actual villager guard rejected two fabricated social contact IDs. Fixture repaired; later process pair passed.
- 20261009-221345806-bcbd9af0: profile had unintended vsync1 and Ivo's synthetic south leg entered real water, then stopped subsequent samples. Set transient established benchmark vsync0 and use legal east/west lane; all6000 samples then completed.
- 20261009-221720364-a926302c: valid before-optimization peak-eight p95 cost3.319/3.659ms exceeded original2ms. Bounded scheduler optimization above.
- 20261009-222158577-f5842f92: eight focused routine regressions passed, including3495 cross-map and2610 all25 activation assertions; optimized profile2.985/3.305ms still failed the original2ms ceiling. Explicit measured4ms revision recorded before rerun.
- 20261009-222850350-0cfa1def: parse preflight caught one over-indented profiler assertion during budget update. Fixed indentation; rerun started from fresh isolated paths.

Early accepted integration/import run20261009-220355282-11cd2235 is retained;
its pre-repair runtime is historical evidence, not the final acceptance source.
One intermediate ledger helper exited before writing when it found no previous
social adaptation; corrected helper added a baseline-pinned record and preserved
all unrelated ledger bytes. A later attribute-ledger helper used the wrong root
key after appending the narrow attributes; corrected the ledger before verification.
No source pins or unrelated records changed.

## Final acceptance

All R014 criteria pass under the explicit measured scheduler-budget revision.
[Final runner report](../evidence/R014/20261009-222953740-f71896fa/results.json) is **passed:15/15 cases**, zero
runtime diagnostics and identical1303-file source fingerprints before/after:
`5178e0bfc09c1a317863b1cbaa7df30542f65f77b43d356c2c98db5b88e00a32`.

| Acceptance criterion | Result/evidence |
| --- | --- |
| Current-schema distinct-process reconstruction, complete durable/forecast persistence, no duplicate effects or saved cursors | PASS: writer PID51992, reader PID69760;82/98 report assertions (83/99 including evidence write). Real Load/Save, primary/backup, stale prior-session authority refused. [Writer](../evidence/R014/20261009-222953740-f71896fa/process/routine_integration_process_checks/routine-integration-write.json), [reader](../evidence/R014/20261009-222953740-f71896fa/process/routine_integration_process_checks/routine-integration-read.json). |
| Failed travel/load restores all existing bindings, retry retains durable facts | PASS: production root/session/world/dialogue/party/camera/director ownership and actual contact/body/mover identity; unsupported7/9 schemas refuse even with valid backup; corrupt primary recovers backup without rewriting it; death/retry exact healed durable oracle. [Lifecycle](../evidence/R014/20261009-222953740-f71896fa/checks/routine_lifecycle_checks/routine-lifecycle.json). |
| Ten cycles, one room/region, zero owned growth | PASS:782 report assertions (783 including evidence write), exact per-room node/listener/wrapper/body/reservation counts before/after; old scenes/adapters freed. Process working set281993216 to287219712 bytes:5226496 bytes/4.984MiB growth<=64MiB after equal2s settling. |
| Numeric active profile, path requests, max-clock bounds | PASS:6000 focused active samples; all eight movers1876+ achieved-motion samples and60+ completed legs each;15032 unchanged-leg comparisons with zero per-frame path requests.23 unique qualified segments, each10warm+100 queries, worst p95.464ms<=5ms. Maximum reconstruction2.079ms<=50, total15 transitions<=512, each<=64. Every25-routine participant elapsed1e100 sweep terminates; huge tick.412ms and durable facts inert. [Profile](../evidence/R014/20261009-222953740-f71896fa/render/routine-performance.json). |
| Required preservation regressions | PASS: save_checks, environment_lifecycle_checks, combat_checks, map_companion_checks (19808 movement samples/14 routes), testing_support_checks; social_process_checks and fishing_process_checks each separate writer/reader pair. All are final current-source cases in the passed runner report. |
| Reference/drift and scoped preservation | PASS: [reference audit](../evidence/R014/reference-repaired-final.json):1626 assertions,25 routines,21 anchors,88 source inputs,82 exact adaptations,10 negative drift refusals. Original source/baseline/R001 budget bytes retained. [Final audit](../evidence/R014/final-audit.json) records exact allowlist, unchanged HEAD/empty index, links/status/dependencies and cleanup. |

| Configuration (1000 focused samples each) | Scheduler+NPC p95 ms | Frame p95 ms | Frame p99 ms | Draw p95 |
| --- | ---: | ---: | ---: | ---: |
| town-paired-empty/0 (0 loaded) | 0.684 | 6.046 | 9.638 | 196 |
| town-peak-eight/1 (8 loaded) | 2.491 | 8.974 | 13.525 | 202 |
| town-peak-eight/2 (8 loaded) | 2.556 | 9.168 | 13.302 | 202 |
| town-paired-empty/3 (0 loaded) | 0.680 | 6.416 | 9.670 | 196 |
| prototype-mayor-vale-home/0 (2 loaded) | 0.889 | 3.749 | 5.079 | 363 |
| prototype-lantern-rest/0 (1 loaded) | 0.798 | 3.132 | 3.926 | 271 |

Scheduler ceiling4ms; original2ms not met and not relabeled passed. Empty paired
frame baseline max6.416ms gives max(16.67,6.416+4)=16.67ms; every configuration
meets this, p99<=25ms and draw p95<=500. Maximum occupancy-eight-probe p95.171ms;
clock p95<=.034ms. Native AnimationPlayer/render work is represented in whole-frame
cadence; physical/rig timer measures the production movement/rig requests.

| Room | Nodes | Listeners | Wrappers/movers/presenters/speech | Bodies | Reservations | Executors/positions | Rooms/regions |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Town |3977|1011|5|7|5|8|1|
| Home |464|1005|2|4|2|8|1|
| Inn |371|1003|1|3|1|8|1|

All six final PNGs viewed: town-paired-empty-0/3, town-peak-eight-1/2,
prototype-mayor-vale-home-0 and prototype-lantern-rest-0. Actual terrain/two rooms
render with expected visible contacts (two home, one inn); town crop shows only
part of the eight loaded cast. Eight-owner activity is proven by live sampled
movement/cursor counts, not a claim that all eight fit this viewport. Captures
are paused synthetic context evidence; no ordinary walking, natural full day,
weather discovery, social journey or fresh native package acceptance claim.
Those remaining gates belong R015 and R016.

Final full command from repository root:

```powershell
./tools/run_checks.ps1 -Task R014 -Names routine_lifecycle_checks,save_checks,environment_lifecycle_checks,combat_checks,map_companion_checks,testing_support_checks -ProcessScripts routine_integration_process_checks,social_process_checks,fishing_process_checks -RenderScript routine_performance_profile -RenderPhases profile -TimeoutSeconds 240
```

Focused repair verification (all eight checks passed; overall report failed only
original2ms profile; retained under20261009-222158577-f5842f92):

```powershell
./tools/run_checks.ps1 -Task R014 -Names routine_resolver_checks,routine_clock_checks,routine_executor_checks,routine_cross_map_checks,routine_reconstruction_checks,routine_dialogue_checks,routine_directive_checks,routine_activation_checks -RenderScript routine_performance_profile -RenderPhases profile -TimeoutSeconds 240
```

The final lifecycle also directly compares assignment-only versus default sampled
plans across clock changes, learned facts, flags, player events, authored events,
suppression, day rollover and finite recency expiry, including same-object retention
for unchanged decisions. No production ownership/termination checks were relaxed.

Exact reference command (verified Python runtime, -B, no source writes):

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -B tools/routine_migration/reference_checks.py --source D:/development/game-prototype-2 --self-test --report docs/evidence/R014/reference-repaired-final.json
```

## Intended file allowlist and stop

- `.gitattributes`
- `docs/day-clock-npc-routines/CHECKLIST.md`
- `docs/day-clock-npc-routines/CONTRACT.md`
- `docs/day-clock-npc-routines/CURRENT_STATE.md`
- `docs/day-clock-npc-routines/R014_ACCEPTANCE.md`
- `game/features/npcs/npc_dialogue_service.gd`
- `game/features/routines/routine_assignment_director.gd`
- `game/features/routines/routine_execution_director.gd`
- `game/tests/social_process_checks.gd`
- `game/tests/routine_lifecycle_checks.gd`
- `game/tests/routine_lifecycle_checks.gd.uid`
- `game/tests/routine_integration_process_checks.gd`
- `game/tests/routine_integration_process_checks.gd.uid`
- `game/tests/routine_performance_profile.gd`
- `game/tests/routine_performance_profile.gd.uid`
- `tools/routine_migration/adaptations.json`
- `tools/routine_migration/reference_checks.py`

All17 intended paths reviewed. Default sandbox helper setup was unavailable;
scoped shell execution used automatic review. No approval rejection or outstanding
permission exists. Owned checks/windows exited; no held native input, live owned
Godot/editor, normal-save cleanup or packaging work owed. Unrelated Blender kept.
No commit/push: user reviews this implementation before a separate authorized
commit instruction. No R015 implementation begun.

Blockers/unrun R014 criteria:none. Remaining unfinished IDs:R015,R016.
Every checklist item through R016 complete:no. Next eligible:R015; read current
acceptance/testing guidance and perform ordinary600-active-second full-day and
social/recovery walkthrough plus its deterministic branch matrix.


## Approved budget and authorized R014 commit

The user explicitly approved the4ms scheduler-plus-NPC p95 ceiling after the
performance/FPS/cadence/threading review. The assistant asked: "Also, the 2.5 ms
measurement includes movement and visual updates, not just schedule decisions.
Are you happy to accept the 4 ms test budget and continue?" The user answered:
"yes, lets accept that and continue". This approval covers the revised mandatory
numeric gate; it does not assert compliance with the original2ms ceiling.

Original2ms failures, before/after measurements and original R001 budget pin
remain unchanged. Final peak2.491/2.556ms is the combined visual/execution/physical
request slice, not pure selection or FPS. Synthetic uncapped960x640 benchmark
drives one physical update per rendered sample; ordinary play has render-frame
selection and separate default60Hz physics. Some loaded NPCs are offscreen;
normal player/companion processing is disabled in this profiling fixture. No
ordinary full-day or packaged-game FPS claim is added. Threading investigation
is deferred; no new scheduler architecture or migration task is created.

Authorized commit stages exactly the17 reviewed task files, including this
tracked acceptance evidence, checklist and handoff. Generated raw reports/CSVs/
PNGs and original failures remain local under ignored docs/evidence/R014, as
established by .gitignore. Accepted1303 game/tools bytes, original source and
task allowlist were reverified unchanged before this documentation-only approval
record. Commit result/index/tree/source verification is recorded locally in
[commit audit](../evidence/R014/commit-audit.json) and Git. No push or R015 work.
