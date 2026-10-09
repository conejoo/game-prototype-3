# FS003 deterministic fishing challenge acceptance

Status: Done, 2026-10-09 UTC. Exactly FS003 executed; no successor started.
Entry/final HEAD `044a0fe9c99eb7b876ebd509644d6dcf258e9ab8`; entry Git status clean.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) owns handoff.
Execution finished without commit/push. Subsequent user instruction authorizes the
successful FS003 local commit only; no push. Existing FS001/FS002 capability and
frozen source identities verified.

## Criteria and evidence

| FS003 criterion | Implementation and verification |
| --- | --- |
| Pure transient ownership | New RefCounted FishingChallengeController owns only one attempt's timers/input/token and a detached copy of validated FishingChallengeDefinition. Typed Snapshot, Resolution and CommandResult are nested feature classes. No node, inventory, catalog publication, session, save, RNG generator, UI or reward command. FS005 must bind the local controller token to the actual session/location/rod before any reward. |
| Waiting, bite, fighting, terminal/cancel | Supplied independent finite [0,1) wait roll gives 1.5+1.5*roll seconds. Paired empty ID/null feature models a miss, which waits normally before no_bite. Fish reaches bite, fresh held press reaches fighting, then exactly one terminal resolution. Cancellation preserves reason and never permits reward. Wait endpoints, pre-boundary/exact-boundary behavior, wait-to-bite overshoot, hitch spanning the hook window and hook-update fight time are tested. |
| Species metadata and source curves | Current catalog provides bluegill/easy hook1.2 fight2/5, trout/medium hook.9 fight6/12, carp/hard hook.7 fight15/30. Frozen reference tier bounds/struggle waves match at seven sample times each. Initial tension .5, held rise .65, release fall .55, optimal progress1, warning progress.25, danger progress0, progress/minimum duration and tension clamp0..1 preserved. All species' exact hook expiry and last-moment fresh hook pass. |
| Fresh inputs and distinct failures | Generation baseline captures presses before cast. Holding across cast/bite cannot hook; an observed release then new press is required. A released press does not hook; held rise without a new generation, repeated fresh press while held and generation rewind reject. Early reel, missed hook, no bite, line slack, line snapped, exhausted, landed and canceled are distinct. Input is sampled at the beginning of the supplied interval; a waiting press stays early even when that interval crosses bite time. |
| Danger grace/reset and priorities | Inclusive danger bounds and optimal edges tested for all species, including warning samples on both sides. Danger lasts .75 seconds continuously; exact grace produces slack/snap, returning to safety resets it, and renewed danger starts from zero. Synthetic isolated threshold/priority states prove danger beats simultaneous landing/timeout and landing beats timeout. Exact fractional final-fight boundary is simulated, rather than rounded to a whole tick. |
| One terminal/token and rejection safety | Resolution has local attempt token, exact fish ID and reward_eligible only for landed. Further update/cancel rejects every resolved/canceled attempt; restart creates a larger token and fresh tension/progress/danger/carry. Stale callbacks cannot affect restarted attempts. Snapshot, returned resolution and source Resource mutation cannot mutate live state. Invalid rolls/deltas/types/generations/tokens/paired metadata/tier/times/cancellation reject without state mutation. No reward is added here. |
| Deterministic bounded elapsed carry | Waiting/bite use exact elapsed carry. Fight uses fixed 1/240-second end-sample Euler increments and retains substep remainder. Maximum fight duration can use a shorter last step. Accepted dt is finite [0,60] seconds: at most 14,401 steps per call including carry, so hostile giant hitches reject rather than stall. Source's frame-boundary overshoot loss is deliberately removed. Same input changes at the same timestamps give phase/outcome equality and numeric state differences <=1e-9 across split frames/hitches, including all-three scripted landing paths. |
| Every species and failure | Legal synthetic feedback trajectories land all three species at approximately 2/6/15 fight seconds; all-held/all-released trajectories snap/slacken each species. Warning-band strategies exhaust at 5/12/30 seconds. Twelve retained traces show actual terminal/tension/progress. Maximum 60-second hitch still checks danger before any success. Cancellation/restart covers waiting/bite/fighting and seven explicit/lifecycle reason categories. |

Simulation/input timing precision is one 1/240-second tick (4.167ms), with numeric
comparison tolerance 1e-9 and boundary floating tolerance 1e-10. Fractions carry into
the next tick, whose held input is the latest sampled value; input edges are
quantized at that precision. Partition tests preserve the same input timestamps.
This does not claim identical outcomes for inputs pressed at different wall times,
or equality with the source's frame-dependent Euler integration.

Boundary/priority fixtures directly seed private state in the isolated test only;
there is no production force-state/RNG/reward command. Land/failure trajectories
otherwise use legal start/update input calls. All proof is synthetic pure rules.
Root lifecycle invocation, player controls, ordinary catches, captures, inventory
commit, persistence and native delivery remain their FS004-FS008 task owners.
No rendered/player/native claim or scene-owned durable count.

## Commands and accepted run

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Supplied console/editor paths checked; installed console 4.7.2 used.
Project-owned gameplay-testing skill, shared testing-tools recipe and PLAYTEST read.
No applicable nested AGENTS or workspace/repository .agents directory found.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS003 -Import -Names fishing_challenge_checks,fishing_content_checks,fishing_activity_checks -ParseScripts features/fishing/fishing_challenge_controller,features/fishing/fishing_challenge_definition -TimeoutSeconds 150
git -c core.whitespace=cr-at-eol diff --check
```

Accepted local report:
`docs/evidence/FS003/20261009-033554872-0f0043b7/results.json`.
All six cases PASS/exit0: engine version, import, explicit dependency parse,
challenge 8,786, content 255 and activity 208 assertions. The three checks have distinct
save slots `check-20261009-033554872-0f0043b7-000` through `-002`, each with its own
APPDATA/LOCALAPPDATA under matching `builds/testing/FS003/` run child.
No normal save accessed. No timeout/runtime/parse diagnostics; known import-only
missing SDK 10.0.9 advisory retained separately, no installation/C# claim.
All 990 game/tools files remained stable, digest
`a8fb54f8e337f45adc618143ecf01e19b5203ea4e56fdcd8ec3d8df2d8b078e0`;
source.changed=false/error=null. Case logs, result, challenge JSON and twelve traces
reviewed. Live source audit 143 assertions PASS before/after, all18 source pins and
target layout SHA256 `7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be`
unchanged. No live-source reconciliation required.

Retained runs: `20261009-033347206-b3b5813e` failed sandbox process launch (Access
denied), resolved by scoped runner escalation; no automatic approval rejection.
`20261009-033410139-23b3fab9` first import generated two UIDs, correctly rejected
as source changed. Reviewed/retained UIDs, then stable focused run
`20261009-033430121-259a9c46` passed challenge 8,675/content 255/activity 208 before
final additional species-hook/replay/detachment checks. Only the final stable run
above accepts final bytes; failed evidence preserved.

Touched files: controller/test and their two UIDs, CHECKLIST/CURRENT_STATE and this
acceptance. Existing production files, immutable content, schema7/content1,
source game, authored instructions, pinned geography/collision/navigation/portals,
social/native tools/packages, normal saves and prior evidence preserved.
All owned launcher PIDs exited; no editor/game/input or cleanup owed.
Final docs/link/status/scope/whitespace and stable byte review recorded in the local
accepted run's `final-review.json`.

FS003 remaining criteria/blockers: none. Next eligible FS004. Remaining unfinished
FS004, FS005, FS006, FS007, FS008; every item through FS008 is not complete.
Stop before successor. The subsequent commit authorization is recorded in the
handoff; execution acceptance remains the pre-commit boundary above.
