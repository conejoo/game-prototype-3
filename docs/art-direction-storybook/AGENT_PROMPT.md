# Painted coastal storybook reusable agent prompt

## Paste this into each new chat

~~~text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/art-direction-storybook/AGENT_PROMPT.md.
Use its full instructions. Resume unfinished work first; otherwise implement the next eligible AD task only. Verify its acceptance criteria, update CHECKLIST.md and CURRENT_STATE.md, then stop before the next task.
~~~

This workflow is self-contained; the personal plan-agent-tasks skill and previous chat history are not required. These instructions implement the selected painted coastal storybook art direction when the user invokes this prompt; creating this document does not start implementation.

## Goal and bootstrap

Workspace: D:/development/game-dev-blender.
Repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot project/application: D:/development/game-dev-blender/returning-fair-prototype/game.
Workflow: D:/development/game-dev-blender/returning-fair-prototype/docs/art-direction-storybook.
Entry scene: res://app/game_root.tscn.
Goal: achieve the chosen [painted coastal storybook look](../../art/direction/2026-10-10/01-painted-coastal-storybook.png) in the current playable game using shared painted textures and existing simple 3D assets, while preserving real-time performance and gameplay.

Before selecting work:
1. Read applicable workspace/ancestor AGENTS.md instructions. Communication defaults to caveman full unless user says normal mode or stop caveman.
2. Read this folder's [CHECKLIST](CHECKLIST.md), [CURRENT_STATE](CURRENT_STATE.md) and [CONTRACT](CONTRACT.md). Read LOOK_SPEC.md and BASELINE.md after AD001 creates them; their absence before that task is expected.
3. Inspect actual Git changes, current assets/code and relevant [architecture](../ARCHITECTURE.md)/feature contracts. Root CURRENT_STATE and old feature summaries contain historical schemas; current SaveCodec/project files and latest task-specific evidence win. Do not let older checklists select this task.
4. Open the chosen image, relevant source .blend/texture/material artifacts and prerequisite evidence for the selected scope. Imagegen concept is look authority, not geometry authority.
5. Preserve unrelated user work, especially art/direction and docs/interiors-map-migration. Read current routine/interiors handoffs only as needed for ownership overlap. R016 remains incomplete historically; neither resume it nor mark it Done through art work.

For this machine, read-only Git can need a command-local ownership exception:
~~~powershell
git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype status --short
~~~
Use actual current permissions; never change global Git configuration, reset/stash another session's work or treat recorded HEAD as a checkout target.

## Select exactly one task

- Resume the single In progress AD task first.
- Reassess Blocked AD work if its specific blocker changed. An unresolved blocker excludes that task and dependents; independent ready tasks may proceed.
- Otherwise choose the lowest-numbered Pending AD task with verified Done prerequisites.
- If statuses/artifacts disagree, reconcile from evidence. Stop with the exact conflict if there is no unambiguous selection; do not guess multiple active tasks.
- If nothing is ready, record the exact dependency/blocker and safe next action. If all tasks are Done, report completion and stop.
- State selected ID, bounded outcome and acceptance briefly. Mark it In progress before edits.

Finish exactly that task, including necessary fixes and checks. Do not stop at another plan/scaffold if the task requires running art. Do not start its successor, even if it appears quick. Do not spawn agents/chats, schedule work, commit/push or publish automatically.

## Execute within existing architecture

CONTRACT owns scope, source authority, budgets and tools. Preserve current pinned map geography, physical footprints/heights, navigation, stable IDs, door/station feet, actor identity, source references, strict current save format and current gameplay services. This art workflow does not add new rooms or features. Treat the external source D:/development/game-prototype-2 as read-only if consulted; runtime may not depend on it.

Use task-scoped material/UV/atlas/export changes and the existing replaceable VisualRoot structure. Keep tree MultiMesh/party canopy cutout, world-aligned terrain/wet masks, existing sun/weather/light pool and current camera/input semantics. Extend obsolete color-only asset assertions narrowly with meaningful new material/UV checks; retain geometry/physics/identity guarantees and immutable original pins. Record adaptations rather than regenerating every baseline.

Hero/ally remain prototype capsules; existing eight villager rigs/identities and guardian are harmonized, not redesigned. HUD work is bounded presentation, not new interaction/gameplay logic. Each branch targets currently implemented rooms only; separate interiors workflow owns expansions.

For Blender work, read relevant installed skills when available, verify the actual live connection/version, inspect current scene and preserve unrelated work. Editable sources stay under art/source; runtime GLBs/textures under game/assets with recoverable originals and recorded import settings. Do not install a second server or export authoring cameras/lights/collision.

Godot installed outside PATH:
- Console: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
- Editor: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe.
Check these first. Use game/ as --path, GL Compatibility and PowerShell7 for existing runner. Missing APIs/fixtures/tools must be identified and created by the owning task before use.

## Verify proportionately

Use each task's stated existing checks plus actual rendered Godot inspection for look/readability/motion. Select checks from affected dependencies, not every historical workflow. Test basic UV/import/collision/visibility correctness within that task; AD018-AD020 address integrated review, fresh profile and local native delivery.

CONTRACT contains a verified runner example and existing tool paths. Old profile/package helpers have hardcoded W009/R016 routing; inspect before reuse and add a narrow task-owned adapter if required. Do not spoof an older task ID or weaken path/data guards. Proposed LOOK_SPEC/BASELINE/ADxxx acceptance records and art adapters are deliverables, not tools that already exist.

Before live/native input, read [PLAYTEST](../../tools/PLAYTEST.md) and the versioned [testing skill](../../tools/skills/returning-fair-gameplay-testing/SKILL.md). Use bounded input and observed pause checkpoints; isolate saves/data; never touch ordinary user save directories. Record native PID/window/capture provenance and owned cleanup. Native Save/Load smoke must observe actual GUI outcome and new-process Load, not substitute a fixture or old report.

Record commands, cwd, exact results and evidence paths. Label synthetic camera/time/weather/pose setups explicitly. Inspect image pixels; imagegen/Blender renders cannot pass engine acceptance. Short samples/--smoke cannot pass full AD019 performance gate. Build success is not native startup or release acceptance. Missing/unrun required checks leave task incomplete; record reason and exact retry.

## Handoff after every session

Update this folder's CHECKLIST status and CURRENT_STATE even on interruption:
- Selected ID/status, completed criteria, remaining criteria, next eligible task and exact next action.
- Baseline/user changes, actual changed files and deliberate architectural/material/source adaptations.
- Verification commands/cwd/data isolation/results, inspected evidence and failures/unrun checks.
- Current engine/schema/content observations, live owned process/editor/input state and cleanup still owed.
- Concrete blocker and safe retry if any. Use Blocked for an actual unavailable prerequisite, not merely because a task needs another session.

Mark Done and append a completion record only when every criterion has evidence. Keep CURRENT_STATE concise; link detailed acceptance/raw outputs rather than accumulating transcripts. Preserve historical incomplete R016 and other workflows' statuses. Update shared architecture/pipeline docs only for justified changes, not routine progress.

Final response: selected ID/status, visible change, what verification actually passed, limitations and next task. Stop after this task. No implementation beyond user-authorized scope or automatic external action is implied.
