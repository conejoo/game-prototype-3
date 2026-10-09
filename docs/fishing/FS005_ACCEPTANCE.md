# FS005 root fishing orchestration acceptance

Status: Done, 2026-10-09 UTC. Exactly FS005 executed; FS006 not started.
Entry/final HEAD `199dd77a977b2a56fa156294f1644104ca80b438`; entry Git clean.
[CHECKLIST](CHECKLIST.md) owns status; [CURRENT_STATE](CURRENT_STATE.md) owns handoff.
No commit or push. FS003/FS004 acceptance and current owners reviewed; fresh
challenge/targeting checks pass against the integrated root.
The execution record describes the pre-commit acceptance boundary. Subsequent
user authorization requests the successful FS005 local commit only; no push.

## Criteria and evidence

| FS005 criterion | Implementation and verification |
| --- | --- |
| Root-owned transient owner, selected owned rod, one attempt | New FishingSessionService is composed by GameRoot. It binds weak session/location/catalog/inventory identities, exact rod capability signature and starting hero health. Only the owned selected cap1 fishing rod enables targeting. F enters/exits targeting without echo activation. Cast is accepted only from targeting; repeated clicks during an attempt cannot start another. No catalog, durable inventory, save or event-bus owner added. |
| Fresh cast validation, area/species/capacity, no consumption | Root refreshes FS004 preview during targeting and revalidates immediately on click. Service independently queries the current camera ray/foot/UI permission rather than accepting a supplied eligibility result. Tests cover UI/deck/no-area and moved-player rejection; invalid/no-area consumes neither RNG draw. Production uses independent strictly half-open uint32-scaled encounter/wait draws. No-area returns immediately; miss waits the normal interval and resolves no_bite. Selected fish cap99/full-bag failure rejects before waiting, while an existing stack can grow in a full twenty-type bag. Rod and all other durable facts stay exact. |
| Input ownership and continuing world simulation | F/world-click casting and fresh E hook/hold/release use actual viewport input. Active attempts clear hero movement/velocity and disable player controls; root consumes attack/dodge/world interaction/B/J and blocks drag, lamp, backpack, journal, save/load and normal travel routes. Targeting retains normal movement. Hero damage, companion/enemy simulation and active clock/weather remain enabled; the whole tree is never paused for fishing. Explicit root stepping proves elapsed time/environment progress continue. Normal mouse attack/Space/E/B and social/companion/world-item regressions pass. |
| Safe lifecycle cancellation | Forty-five phase/reason combinations cover waiting/bite/fighting against F, right-click, Esc, pause command, focus loss, external modal, dialogue, retry, rod selection loss, invalid rod capability, hero combat, ally combat, damage, death and session replacement. Actual failed physical transition rollback, save/load and successful room replacement additionally prove cancellation and no resurrection. Root teardown invalidates retained service access. Preview hides on every exit. Combat/context validation runs before controller advance/commit. |
| Fresh inputs, cancellation controls and no stranded reel | Esc cancels and opens an observed existing pause overlay in one action. F/right-click cancel safely; held E remains consumed until release, echoes cannot act after exit, and held-at-cast cannot automatically hook. Keyboard/pointer sources aggregate without double hook or release confusion; cancellation blocks old pointer presses until an observed release. Immediate recast starts fresh. Fresh movement works after exit, while old movement echoes do not. FS006 will supply the public pointer view for the already-shared reel command. |
| One verified landed token, atomic existing reward command | Private challenge terminal/result identity, token, exact outcome/species/eligibility and unconsumed generation must match. Service consumes token and guards reentry before synchronous InventoryState.can_add/add(+1), with no callback between validation and mutation. Legal feedback trajectories land all three species. Complete exact typed snapshots differ only by one fish count and inventory revision increments once. Null/fabricated/replayed/stale/reentrant results alter no facts; the actual verified result is rejected on replay too. |
| Immediate landing revalidation and honest success | Isolated fixtures defer the actual legal controller result, then replace session, map or inventory, unselect rod, invalidate capability or fill capacity before commit. Every case terminates without a reward. Capacity disappearance during a normal legal trajectory publishes full-bag failure, never landed success. Success text/count/HUD are published only after the existing inventory add succeeds. Failures have separate provisional outcome messages. No deferred reward is retried by bag/load/recast. |
| Manual persistence and preservation | Attempt/tension/tokens/RNG/targets remain absent from schema7/content1 saves. Every phase is canceled before exact manual save/load proof; active Load request cancels and refuses the load. Actual rendered GUI Save/Load restores complete exact typed facts, one bluegill and fish selection, with no attempt/preview. No fishing autosave. Pinned layout/source/instructions/native tools/packages/current social/quest/party/environment owners remain unchanged. |

Owner: [service](../../game/features/fishing/fishing_session_service.gd),
[root](../../game/app/game_root.gd), F binding in
[project](../../game/project.godot). Reusable proof:
[session](../../game/tests/fishing_session_checks.gd),
[reward](../../game/tests/fishing_reward_checks.gd),
[lifecycle](../../game/tests/fishing_lifecycle_checks.gd),
[render](../../game/tests/fishing_session_render.gd) and
[shared fixture](../../game/tests/support/fishing_root_fixture.gd), plus six UIDs.
These tests explicitly label synthetic poses, RNG, capacity and timing. Private
dispatch/reentry fixtures are not runtime commands or ordinary-play evidence.

## Commands and accepted evidence

Cwd: `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7.
Supplied installed console4.7.2 verified; no installation. Root AGENTS, fishing
prompt/checklist/handoff/contract, architecture, FS003/FS004 acceptance and current
project-owned gameplay-testing skill/testing-tools/PLAYTEST read. No nested AGENTS
or workspace/repository `.agents` directory exists. No agents/chats/conversations used.

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/fishing/reference_audit.py --source-root D:/development/game-prototype-2
./tools/run_checks.ps1 -Task FS005 -Names fishing_session_checks,fishing_reward_checks,fishing_lifecycle_checks,fishing_challenge_checks,fishing_targeting_checks,inventory_checks,foraging_transaction_checks,backpack_ui_checks,combat_checks,companion_checks,interaction_dialogue_checks,location_travel_checks,social_transaction_checks,environment_lifecycle_checks,foraging_save_checks,social_save_checks,people_journal_checks,world_item_placement_checks,application_smoke -RenderScript fishing_session_render -RenderPhases check -ParseScripts features/fishing/fishing_session_service,app/game_root,tests/environment_review,tests/live_playtest_bridge -TimeoutSeconds 150
git -c core.whitespace=cr-at-eol diff --check
```

Accepted final report: `docs/evidence/FS005/20261009-041614814-97f748a6/results.json`.
All22 cases PASS/exit0: engine version/explicit parse, nineteen selected checks and
actual renderer. Session57/reward72/lifecycle344/render33 assertions; challenge8786,
targeting135, inventory199, foraging transaction587, backpack148, social transaction238,
environment lifecycle157, foraging save111, social save844, People134 and world-item128.
Combat/companion/dialogue/travel/startup regressions pass, including ten round trips,
real guardian routing, ally assistance/recovery, atomic saves and modal focus.
No runtime/parse diagnostics or timeouts. source.changed=false/error=null; all1010
game/tool files stable, SHA256
`17a92c7979b09433eba69725c43f889ac6f8adf7b25397d1ff120e099a21ec91`.
Twenty isolated groups under matching `builds/testing/FS005/<run>/`: nineteen
independent check slots and one rendered group. Normal saves/old evidence untouched.

Seven final960x640 PNGs inspected: live waiting/bite/fighting, canceled visible
pause, bluegill1/99 in existing bag, actual GUI Saved and actual GUI Loaded at arrival
anchor. Live captures keep automatic root/challenge/world time running, verify
same phase/token/session/location after settling and post-draw, and record before/
after timers and wall duration. They are never labeled as paused active attempts.
Three live frames and bag reviewed full-size; pause/bag/Save/Load also reviewed on
the shared capture validator's contact sheet. Local live capture is read-only and
bounded; shared fishing observation/native extensions remain FS006.

The current root feedback is intentionally provisional. Existing static rod help
still says fishing unavailable; fish icons and overly general gift wording remain
FS006's assigned public UI work. This acceptance covers functional input/phase/
outcome correctness, not FS006's finished HUD, pointer button, icons or effects.
No ordinary unforced catch or independent-process fishing restart claim; FS007 owns
those. No Windows export/native proof or package replacement; FS008 owns delivery.

Live reference audit143 assertions PASS before/after; all18 pins unchanged.
Read-only source HEAD `60c20eb2816e7271fb84afaba286af006ebe3ccf`, clean.
Pinned layout SHA256
`7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be` unchanged.
Failed launch/UID-generation/fixture runs retained and excluded, detailed in handoff.
Only verified runner-owned stalled fixture processes were stopped; final owned
processes exited, no editor/input or cleanup owed. No auto-review rejection.

Every FS005 criterion verified; blockers none. Next eligible FS006. Remaining
unfinished FS006, FS007, FS008; every item through FS008 is not complete. Stop here;
commit awaits separate user instruction. No push, publication or successor work.
