# F005 blocked-anchor decision

Historical decision recorded 2026-10-07, America/Vancouver.

**Geometry blocker resolved by subsequent user-approved relocation.**
[F005_RELOCATION](F005_RELOCATION.md) supersedes the retry/continuation below.
F005 now Pending, not Done; original diagnosis retained as history.
Exactly F005 selected this invocation; F006 was not started.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.

## Conflict and measured evidence

[CONTRACT](CONTRACT.md) requires authored X/Z/identity fixed, supported mapped feet,
unchanged pinned map/colliders/navigation and no blocker LOS bypass. Its F001 repair
boundary explicitly says: "if impossible under fixed origins, record exact conflict
and block F005." Fresh production physics confirms the same conflict; it is not a
sandbox or missing-tool blocker.

| Origin | Fixed foot, metres | Containing collision | Measured box bounds, metres | Existing sight endpoint |
| --- | --- | --- | --- | --- |
| fishing-rod-dock-01 | (-8,0,15.75) | south-water-06 | X[-10,-7.5], Y[-0.2,3], Z[15.5,17] | (-8,0.8,15.75), inside water |
| moonflower-01 | (26,0.25,-2) | cliff-47-15-east and cliff-47-16-east | X[25.99,26.01], Y[-0.2,2.25], Z[-3.01,-1.99] / [-2.01,-0.99] | (26,1.05,-2), inside both cliffs |
| moonflower-02 | (34,0.25,7) | none | No containing blocker | Clear from (34.75,0.25,7) |
| moonflower-03 | (30,0.5,-9) | none | No containing blocker | Clear from (30.75,0.5,-9) |

Float32 bounds shown rounded here; raw fresh report retains exact engine numbers.
Underlying terrain supports all four original heights, but rod and flower01 feet
occupy blockers. Current InteractionSelector rays end at target foot +0.8m. Fresh
rays from clear, in-range radius0.4m/height1.6m capsule approaches hit water/cliff.
Containment proves this is not merely a bad choice of approach: any ray from outside
these solid boxes to the current contained endpoint must cross their boundary.

Changing only meshes/visual children leaves collision and selection unchanged.
Raising wrapper feet above water/cliff tops would float them above original support;
offsetting actual pickups/interaction anchors to dry ground would change fixed X/Z.
Treating unrelated map blockers as target-owned sight hits would bypass LOS. None
satisfies all current constraints. No partial world activation or hold-controller
implementation was made while this prerequisite remains unsatisfied.

## Acceptance review

| F005 criterion | Current verification / remaining work |
| --- | --- |
| Three flowers and rod at supported mapped feet/reachable approaches | Blocked: two exact feet inside map blockers; other two clear in synthetic probes. No ordinary walking proof. |
| E0.6s/0.5s commits once | Unimplemented/unrun pending anchor decision. |
| Release/target/LOS/range/removal cancellation | Unimplemented/unrun. |
| Every modal/focus/travel/load/retry gate cancels | Held controller absent; unrun. Fresh F004 checks prove prior save/lifecycle APIs only. |
| Fresh press after completion/cancel; held E cannot trigger lamp/gate | Unimplemented/unrun. |
| Full bag/stack keeps physical node | World adapters absent; unrun. Prior service evidence is not this criterion. |
| Lifecycle reconstructs exact absence/count without leaked signals | F004 foraging_save and independent-process checks freshly pass; physical reconstruction remains unimplemented/unrun. |
| Existing four interaction kinds work | Existing code preserved; F005 interaction regression suites not run because production unchanged. |
| Rendered progress/cancel frames and normal walking approach | Unrun; no renderer/native process started. |

No F005 acceptance-completion claim. `foraging_anchor_checks` PASS means the documented
blocker remains reproducible, not that pickup gameplay passes.

## Commands, results and isolation

Repository-root PowerShell7 commands, installed console4.7.2.stable.mono.official.ed1daf0bf:

```powershell
./tools/run_checks.ps1 -Task F005 -Names foraging_save_checks,reference_mapping_checks -ProcessScripts foraging_process_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F005 -Import -Names foraging_anchor_checks -TimeoutSeconds 150
./tools/run_checks.ps1 -Task F005 -Names foraging_anchor_checks -TimeoutSeconds 150
```

- `docs/evidence/F005/20261007-191556187-ad924655/results.json`: PASS. Save111 assertions;
  four-node mapping/1,648 route capsule samples; separate writer52/reader55 assertions,
  exact whole-save restart oracle, staged rollback/retry/travel/rebinding/listener cleanup.
- `docs/evidence/F005/20261007-191707777-2d925cd8/results.json`: PASS import/parse/new
  diagnostic. Only previously allowed import-only missing .NET SDK10.0.9 diagnostic.
- `docs/evidence/F005/20261007-191757099-44340ed6/results.json`: final PASS after adding
  exact foot-containment assertions. Final report at
  `checks/foraging_anchor_checks/anchor-blocker-report.json` records four feet,
  sight endpoints, shape centres/sizes/local coordinates, LOS and empty failures.

All results and stdout/stderr inspected. No runtime diagnostics/timeouts/failed engine
runs. Runner isolates APPDATA/LOCALAPPDATA under builds/testing/F005/<run> and check
slots; normal save untouched. Source/map/runtime bytes unchanged. No installs/exports,
external messages, commits, agents or scheduled work. All runner-owned processes exited;
no live editor/game cleanup owed. Synthetic probes never claim ordinary-input proof.

## Retry boundary and continuation

F005 requires an explicit approved revision of the fixed-anchor/map geometry policy
before retry: choose supported runtime pickup offsets under original persistent IDs,
or authorize a precise map/dock/cliff repair with fresh support/navigation/LOS proof.
Suggested approach points above are measured examples, not approved replacement feet;
new pickup footprint and save migration implications must be checked before adoption.
Do not silently use them or change CONTRACT authority.

Unchanged blocker excludes F005/F007 dependents. **F006 next eligible independently**:
F004 save/inventory/active-selection restart prerequisites freshly verified. Future
invocation should inspect current changes and blocker first, then select F006 when
constraint remains unchanged. Stop this invocation before F006.
