# Fishing migration reusable fresh-agent prompt

## Prompt to paste

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/fishing/AGENT_PROMPT.md.
Read its full preparation, selection and execution rules. Resume unfinished fishing
work first; otherwise implement the next eligible FS task. Complete exactly one task,
verify its acceptance, update CHECKLIST.md and CURRENT_STATE.md, then stop.
```

These files supply durable memory. This invitation selects fishing, not another
migration. Planning alone does not start any task; execution starts when the user
invokes this prompt or explicitly requests a task.

## Goal and bootstrap

Deliver existing-rod casting, authored weighted catch areas, bite/hold-release
tension challenge, bluegill/river trout/golden carp rewards, manual persistence
and usable Windows delivery in the current Godot game.

- Workspace: `D:/development/game-dev-blender`.
- Repository: `D:/development/game-dev-blender/returning-fair-prototype`.
- Godot application: repository `game/`; source inspiration:
  `D:/development/game-prototype-2`, read-only.
- Console: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
- Editor: `D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe`.
  Check supplied paths first. Use typed GDScript/Compatibility, existing templates.
  No Godot/Flutter/SDK/plugin installation needed for this workflow.

From repository root, read applicable workspace/project/nested AGENTS instructions.
Use caveman full for chat unless user disables it; write project docs/code normally.
Then read [CHECKLIST](CHECKLIST.md), [CURRENT_STATE](CURRENT_STATE.md),
[CONTRACT](CONTRACT.md), current [architecture](../ARCHITECTURE.md) and relevant actual
artifacts. Inspect Git HEAD/status/diff and user changes before selection or writes.
Do not reset/stash/commit/revert current work, clear slots or stop unowned processes.

Read the prerequisite acceptance and current code from foraging-items-backpack,
weather-lighting, villagers-dialogue and gifts-friendship-people-journal only as
needed. Their prompts do not select this workflow. Current schema policy in
architecture overrides historical backward-compatibility text. Re-read actual
root/item/social/native interfaces; snapshots in this plan are historical observations.

For gameplay verification, read the project-owned
[gameplay testing workflow](../../tools/skills/returning-fair-gameplay-testing/SKILL.md)
and its referenced recipes plus [PLAYTEST](../../tools/PLAYTEST.md).
The executor does not need the personal plan-agent-tasks skill to recover this task.

## Selection

1. Resume the single FS In progress item first.
2. Reassess Blocked work when its recorded cause changed. An unresolved blocker
   excludes that item and descendants; independent ready items remain eligible.
3. Otherwise choose the lowest-numbered Pending FS task with verified Done prerequisites.
   Check evidence and current prerequisite capability, not checkbox text alone.
4. Reconcile contradictory statuses/artifacts. If selection is ambiguous, report
   exact conflict and stop. If none ready, record blocker/dependency and next safe
   action. If all Done, report completion and stop.
5. State task ID/scope/acceptance and mark In progress before implementation.
   Finish exactly one task per invocation. Do not begin its successor.

FS003/FS004 form independent branches; default order is numeric. Do not launch agents,
new chats, schedules or parallel work as a side effect. An explicit user task request
does not waive unfinished prerequisites. Source drift affecting selected references
requires a bounded recorded reconciliation, never geography regeneration.

## Execute selected task

Create a bounded file allowlist from current artifacts; preserve newer unrelated
work, pinned layout/portals/collision/navigation, rod conservation and current
social/quest/party/environment facts. Stop and record a real coordination conflict
before overwriting another active workflow's files/packages. G009's native helpers
and package work may still be in progress; FS008's explicit gate handles delivery.

Implement and verify the selected task instead of stopping at another plan.
All proposed scripts/reference paths must first be created and reviewed by their
owning task. Keep immutable content in catalog, mutable inventory in GameSession,
pure challenge rules separate, GameRoot mode ownership and snapshot-only UI.
No parallel inventory/save/catalog/event bus or scene-owned durable counts.
No source-game edits, runtime dependency on Flutter/source checkout, new
gifts/economy/campaign/autosave, collision shortcuts or tuning fish luck to pass a test.

Use CONTRACT for cell/range, source area probabilities, species/tension rules,
controls, cancellation, atomic landed reward and transient/save boundaries.
Preserve normal mouse attack/Space dodge/E interactions/B backpack and modal focus.
All lifecycle entry points must invalidate stale attempts and fresh-input gates.

## Verify

Use repository-root PowerShell7 `./tools/run_checks.ps1` with selected FS task,
run-specific evidence/isolation and only created/existing script names.
Dynamic script dependencies must be added to -ParseScripts. Review results,
case logs, source.changed/error, parse/import diagnostics and owned PID cleanup.
Do not claim an engine exit0 passed if runner records runtime errors or changed sources.
Run focused checks first; broaden only when selected scope/failures justify it.

Use existing TestRunJourney/Gui/Snapshot/Capture/Evidence helpers; consume their
returned failures and actual GUI completion. No copied timing/navigation loops.
Synthetic RNG/capacity/phase setups prove rules, not ordinary unforced catches or routes.
Render actual user flows and inspect PNGs. Active fishing time continues during
capture/helper startup/model reasoning; pause cancels attempts. Record live-phase
provenance rather than labeling canceled frames as bites/fights.

Independent writer/reader processes use one isolated pair slot; other checks get
distinct slots. Preserve normal saves and prior evidence. Observe actual GUI
Save/Load, compare exact typed stable oracle before resuming, then assert intended
persistent fields and monotonic time separately. No fishing state survives load.
Fresh Windows/native proof belongs only to FS008, using actual exported exe+pck,
bounded ordinary input and verified pause screenshots. Debug bridge/forced RNG
cannot substitute. Missing native timing support leaves the stated human gate open.

## Durable handoff and stop

For complete or incomplete sessions, update CURRENT_STATE with:
- Selected FS status, next eligible ID and exact next safe action.
- Entry HEAD/user changes and actual files touched; source/reference identities.
- Decisions, ownership/version changes and preservation checks.
- Commands/cwd, isolated slots/app-data/evidence and actual results.
- Remaining criteria, failed/unrun checks, exact blockers and safe retry.
- Relevant process/editor state and cleanup owed.

CHECKLIST owns status. Mark Done only with evidence for every criterion; append
completion record then. Otherwise retain In progress, or Blocked for a specific
missing capability/input/conflict; never mark Done for budget/time exhaustion.
Missing optional historical raw runs do not require reenacting whole migrations:
verify current capability proportionately and retain limitations honestly.

Read back changed docs, check local links/task IDs/dependencies and intended diff.
Report selected ID/status, outcome, checks/limits and next eligible task, then stop.
No commits/push, package publication, deployment, outside messages, schedules,
unrelated deletions or automatic successors are authorized by this prompt.
