# Day clock and NPC routines reusable fresh-agent prompt

Creation of this workflow does not start implementation. Disk files supply memory; no personal planner skill is required by an executing agent.

## Prompt to paste into each new chat

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/day-clock-npc-routines/AGENT_PROMPT.md in full. Resume its unfinished task first; otherwise implement its next eligible task. Complete exactly one task, verify all acceptance criteria, update CHECKLIST.md and CURRENT_STATE.md, then stop before the successor.
```

## Goal and environment

Deliver the 25 routines for the eight existing villagers: actual physical movement, groups, fact/action/weather reactions, routine dialogue and the two required interiors. Reuse delivered clock/weather and preserve current recovery/social/item/party behavior.

- Workspace: D:/development/game-dev-blender.
- Repository/working directory: D:/development/game-dev-blender/returning-fair-prototype.
- Godot application: repository game/; entry res://app/game_root.tscn.
- Read-only source: D:/development/game-prototype-2.
- Console engine: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
- Editor: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe.

Check installed paths before searching/installing Godot. Engine installation is not the project. This is typed GDScript/GL Compatibility; no C# SDK build/install is required.

## Preparation and selection

1. Read workspace AGENTS.md/applicable nested instructions, this folder's [CHECKLIST](CHECKLIST.md), [CURRENT_STATE](CURRENT_STATE.md), [CONTRACT](CONTRACT.md), and current [architecture](../ARCHITECTURE.md). This workflow alone selects its work; old feature handoffs are prerequisite references.
2. Inspect current Git changes, source/target bytes, actual schema, selected artifacts/evidence and relevant live editor/process state. Preserve concurrent/unsaved work. Historical handoff schema statements never override current architecture/code.
3. Resume the single In progress task. Reassess Blocked work if its blocker changed; unresolved blocks exclude their dependents, not independent ready branches. Otherwise choose the lowest-numbered Pending task with verified Done prerequisites. Verify capabilities/evidence, not checkboxes alone.
4. Reconcile inconsistent statuses/artifacts first. If selection is ambiguous or nothing is ready, record exact conflict/blocker/dependencies and next safe action, then stop. If all tasks Done, report completion and stop.
5. State selected ID/outcome/scope/checks and mark In progress before implementation. Record baseline/user changes and bounded intended-file allowlist. Finish exactly that task, including necessary checks/repairs, then stop before its successor.

## Implementation rules

Follow CONTRACT's roster, clock, conditions, save, geometry, movement and dialogue semantics. Source currently has 39 routines; selected scope is the enumerated 25 for existing eight people. No automatic additional cast/import. Two bounded rooms are owned work, not a full interior/campaign migration.

R001 pins public references/vectors and exclusions. Later tasks consume target-local pins, reject unexplained drift and document measured adaptations. Runtime/export cannot depend on Flutter, source absolute paths, private profiles or regenerated source maps. Preserve the target exterior's pinned geography. Source INT-064 overnight reconstruction is still unresolved; implement a real regression and repair rather than hidden actors or catch-up teleport.

Reuse EnvironmentClock/WeatherConditionService, conversation/event memory, navigation/rig APIs and strict current-schema-only policy. Do not add duplicate clock/history/cursor save fields. NPC portal travel never moves player WorldHost/party/camera. Replace stale fixed NPC navigation obstacles deliberately; preserve real furniture/counter collision. Do not keep duplicate contacts to satisfy fixed-location tests. Preserve Maris identities/quest ordering, social/gift atomicity, item conservation, fishing, weather/lights and separate companion trust/combat.

Implement only selected task's proposed components/tests before invoking them. Source/fixture/asset presence is not ordinary gameplay proof; a build alone is not native delivery. Do not insert a general behavior editor/global bus or silently enable campaign/sleep/economy. Follow applicable permissions and existing authorization without manufacturing blanket approval steps. No source writes, external messages, deployments/publication, automatic commits/pushes, schedules/extra chats or spawned implementation agents as a side effect.

## Verification and data isolation

Use existing PowerShell 7 tools/run_checks.ps1 from repository root. Example of an existing runner/check invocation for an implementation task:

```powershell
./tools/run_checks.ps1 -Task R002 -Names application_smoke,npc_content_checks -TimeoutSeconds 150
```

Use selected ID and actual required existing/newly implemented checks. R001 is reference/planning work: do not run gameplay solely to create its inventory. Proposed routine_* scripts and reference_checks.py in CHECKLIST do not yet exist. Create them in their owning task before calling them. Read actual runner/recent callers for ProcessScripts restart-pair and rendered options; do not guess an absent CLI.

Runner supplies explicit engine, parse/import observation, task evidence, save groups and isolated APPDATA/LOCALAPPDATA. Inspect both exit status and structured/runtime-error results. Test both primary and backup slots; never configure live tests to the normal user save. Reuse [save isolation](../TESTING_SAVE_ISOLATION_ACCEPTANCE.md), [journey helpers](../TESTING_JOURNEY_ACCEPTANCE.md), [interaction captures](../TESTING_INTERACTION_CAPTURE_ACCEPTANCE.md), [native guards](../TESTING_NATIVE_INPUT_ACCEPTANCE.md), tools/native_input.ps1, tools/native_evidence.py and game/tests/support/.

Store evidence under selected R ID and isolated build/task directories, not historical P/M/W/N/G/FS/F acceptance paths. Current-format fixture updates must be complete and scoped; preserve historical evidence. Failed checks must be repaired/rerun or leave task unfinished, with exact failure and retry. Do not erase failures, claim unrun checks, repeat passing suites without a new concern, or run unrelated whole suites for documentation.

For rendered/native work use bounded atomic inputs, guaranteed release and guarded focus. Confirm pause checkpoints; inspect while paused because game time continues through tool-call gaps. Closing dialogue is not proof of pause. Keep synthetic seek/placement/seeded-weather/state/route-guidance evidence labeled separately from ordinary input. R015 observes a natural full active day; deterministic storm branch tests cannot be claimed as natural weather. R016 requires fresh packaged native acceptance outside checkout; historical packages or a debug bridge cannot substitute.

## Handoff and stop

After incomplete as well as completed sessions update CHECKLIST status and CURRENT_STATE: selected ID/status, actual changes, preserved baseline/user work, commands/cwd/isolation/results, compatibility/source decisions, evidence viewed, failed/unrun criteria, blockers/retry, live owned processes/held input/editor state and cleanup owed. Append completion record only after all criteria pass.

Read back documentation, verify links/IDs/dependencies/status/next selection and intended diff. Report selected result/checks/limits and next eligible ID/exact action. Stop after one task. Time exhaustion is not completion; retain exact continuation instead.
