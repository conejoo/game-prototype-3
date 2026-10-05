# Foraging, items and backpack reusable agent prompt

## Prompt to paste into each new chat

Follow D:/development/game-dev-blender/returning-fair-prototype/docs/foraging-items-backpack/AGENT_PROMPT.md. Resume unfinished task first; otherwise implement next eligible task. Complete exactly one task, verify every acceptance criterion, update checklist and durable state, then stop.

## Full instructions

Goal: peaceful moonflower gathering,20-slot backpack, active item/tool selection,
movable rod in current3D Godot prototype. Old fishing supplies interaction/feedback
inspiration; full fishing minigame excluded.
Workspace: `D:/development/game-dev-blender`.
Repository: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot project: repository `game/`, entry `res://app/game_root.tscn`.
Read-only source: `D:/development/game-prototype-2`.
Only sibling CHECKLIST selects tasks. Parent/map/weather workflows are baseline history.

### Prepare and select

1. Read workspace/applicable AGENTS.md and any new nested instructions. Caveman full
   responses unless user changes mode. Read sibling CHECKLIST.md, CURRENT_STATE.md,
   CONTRACT.md, docs/ARCHITECTURE.md and actual task-relevant artifacts. Inspect Git
   status/current user changes before editing; preserve existing work.
2. Resume single In progress task. Reassess Blocked when recorded blocker changes.
   Otherwise lowest-ordered Pending with verified Done prerequisites. Inspect
   capability/evidence, not checkbox alone. Unresolved blocker excludes dependents,
   not independent ready work; F006 can proceed if F005 blocked after verified F004.
3. Reconcile inconsistent statuses/artifacts. If still ambiguous, record exact
   conflict and stop. No task ready: record specific blocker/next safe action.
   All Done: report complete and stop.
4. State selected ID/scope/acceptance in commentary, mark In progress before editing.

### Execute exactly one task

Follow CONTRACT source/mapping/ownership/transactions/save/scope. Source read-only;
no auto-refresh pinned geography, Flutter dependency or full fishing port. Preserve
P/M/W behavior and user work. Proposed files/checks must first be created; existing
checks are reusable inputs, not claims they pass current code.
Finish selected task's behavior, checks and necessary repairs. Stop before successor.
No automatic agents/chats/schedules. User project authorization does not authorize
external messages, publication, installs, destructive cleanup or unrelated work.

### Validate

Check installed executable first:
`D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe`.
Editor: same folder's `Godot_v4.7.2-stable_mono_win64.exe`.
Installation directory is not project. Keep typed GDScript/Compatibility.

Existing initial baseline command, PowerShell7 from repository root:

```powershell
./tools/run_checks.ps1 -Task F001 -Import -Names application_smoke,content_catalog_checks,map_activation_checks,environment_save_checks -TimeoutSeconds 150
```

Later use selected ID and actual implemented check names. Runner isolates APPDATA/
LOCALAPPDATA/evidence; inspect results.json/log diagnostics, not exit alone. New
classes need import/parse. Runtime errors/warnings fail. Existing narrowly allowed
editor-only missing .NET SDK diagnostic recorded; no SDK install for GDScript checks.

Before live/rendered/native input, read tools/PLAYTEST.md and project-local
`tools/skills/returning-fair-gameplay-testing/SKILL.md` plus linked references.
Use bounded normal input, isolated save slot/appdata and fresh run directory.
Bridge B absent at planning baseline: F006 adds it. Native B/drag requires explicit
helper support, not invented commands. Respect actual focus/verified pause. Inspect
full-size images/capture provenance; synthetic/service calls do not prove ordinary
routes/OS input. Exact restart oracle must compare all durable item and prior facts.

Raw evidence ignored under docs/evidence/<selected-ID>/<fresh-run>; reusable fixtures
tracked. Normal user save untouched. Preserve failed runs; record commands/cwd/
isolation/outcomes. Run task checks and affected regressions; repeat broad tests
only after new changes/failures/concerns.

### Handoff and stop

CHECKLIST owns status; CURRENT_STATE owns continuation; CONTRACT owns mappings/rules.
Mark Done only after every criterion evidenced. Append completion record and tracked
acceptance summary when useful. Otherwise In progress, or Blocked with exact cause/
retry action. Never claim unrun checks or mark Done from time budget alone.
Update CURRENT_STATE after complete/incomplete sessions: task/status, next eligible
ID/action, baseline/user changes, files changed, decisions, commands/results/isolation/
evidence, remaining criteria/failed/unrun checks and owned live process/editor cleanup.
Preserve historical IDs/records when refining pending scope/dependencies.
Review intended diff/local links/references/status consistency. Update parent docs
for useful discovery or actual production changes; retain honest release history.
Report task ID/status, outcome, verification, limits and next task. Stop.