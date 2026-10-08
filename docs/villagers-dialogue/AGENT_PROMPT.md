# Villagers and dialogue reusable fresh-agent prompt

## Prompt to paste into each new chat

Follow D:/development/game-dev-blender/returning-fair-prototype/docs/villagers-dialogue/AGENT_PROMPT.md. Resume unfinished work first; otherwise implement the next eligible task. Complete exactly one task, verify every acceptance criterion, update checklist and durable state, then stop.

Pasting this invocation requests execution of one task. Creation of this workflow alone starts no implementation, agent, chat or schedule.

## Full execution instructions

Goal: the eight requested villagers in the existing 3D game, real ordinary branching dialogue/portraits, remembered choices/public facts, and source-informed character/action assets.
Workspace: D:/development/game-dev-blender.
Repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot project: repository game/, entry res://app/game_root.tscn.
Read-only source: D:/development/game-prototype-2.
Bootstrap files: this folder's CHECKLIST.md, CURRENT_STATE.md and CONTRACT.md.
Only this CHECKLIST selects N tasks. Parent/map/weather/foraging plans are baseline references, not task selectors.

### Preparation and selection

1. Read D:/development/game-dev-blender/AGENTS.md and any applicable newer nested instructions. Use caveman full responses unless the user changes mode; write durable technical documentation clearly.
2. Read sibling CHECKLIST, CURRENT_STATE and CONTRACT; target docs/ARCHITECTURE.md; actual artifacts/evidence required by candidate task. Check current Git status, versions and user changes in target/source. Preserve user work and source read-only policy. No reliance on chat history or the personal planning skill.
3. Resume the single In progress N task first. Reassess a Blocked task when its recorded blocker changes. Otherwise choose the lowest-numbered Pending task whose prerequisites are verified Done. Actual prerequisite capabilities/evidence matter, not checkboxes alone.
4. Unresolved blockers exclude dependent tasks, not independent ready branches. Reconcile contradictory statuses with artifacts; if selection remains ambiguous, record exact conflict and stop. No ready task: record dependencies/blocker and next safe action. All Done: report completion and stop.
5. State selected ID, scope and acceptance in commentary. Mark it In progress in CHECKLIST before implementation. An interrupted task may span sessions; do not skip it to claim another completion.

### Execute exactly one task

Implement its bounded outputs, integration, meaningful checks and necessary repairs. Do not stop at a proposal and do not begin its successor. Follow CONTRACT authority, deferred-capability coverage, actor/graph IDs, public disclosure, 3D art, placement and strict save rules.
The requested eight stay fixed even though source catalog has 15 people. Preserve source text/portraits/identity and target pinned geometry, P/M/W/F features, companion role, normal saves and manual Save/Load policy. Never auto-refresh the geographic snapshot or modify Flutter sources.
Proposed scripts/classes/tests do not exist until their owning task creates them. Record actual names/interfaces when implemented; keep docs usable.
If source drift, shared-format changes or missing Blender/native capability affect acceptance, retain work and record exact blocker/next action. A placeholder or a developer scene cannot substitute for completed ordinary character access.
No automatic agents/chats/schedules, external messages, publication, unrelated installations or destructive cleanup. Future execution authorization covers only the selected project task; obey actual permissions.

### Verify

Installed console:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe
Editor:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe

Check these paths before searching for or installing Godot. Installation folder is not the project. Use typed GDScript and current Compatibility renderer.

Existing reusable baseline command, PowerShell 7 from repository root:

```powershell
./tools/run_checks.ps1 -Task N001 -Import -Names application_smoke,content_catalog_checks,interaction_dialogue_checks -TimeoutSeconds 150
```

This command exists; it has not been run by plan creation. N001 is a reference/document audit and need not rerun unaffected runtime suites when existing verified capabilities suffice. For later tasks use the selected N ID and checks actually created by that task, not this baseline command as a substitute for new acceptance.

Read tools/PLAYTEST.md and tools/skills/returning-fair-gameplay-testing/SKILL.md plus relevant linked testing-tools/native-input/visual recipes before live input. Use shared bounded runner/journey/GUI oracle and fresh isolated appdata/slots; inspect its results and runtime log diagnostics, not exit code alone. No normal user save access. Retain failed attempts as failed evidence.

Use current Blender connection and applicable project/installed modeling, animation, rendering and export instructions for ART tasks. Editable sources outside game import tree; GLBs inside replaceable VisualRoots. Static P012 pipeline is historical and needs explicit animation extension. View actual Godot renders/portrait captures/contact sheets.
A synthetic seeded branch or service call is rule proof; ordinary input is route/UI proof; new standalone native release is package proof. Do not exchange these claims. Keep world paused and confirm overlay before long analysis gaps; full-size images and capture/input provenance matter.

Run task-specific checks and affected regressions. Expand/repeat only when new changes, failures or unresolved concerns require it. Record exact commands/cwd/isolation, outcomes, source/asset hashes, paths and viewed captures. Use docs/evidence/<selected-ID>/<fresh-run>/ under current evidence policy; tracked reusable fixtures and concise acceptance summaries are separate from raw runs.

### Handoff and stop

CHECKLIST owns status, CONTRACT stable rules/mappings, CURRENT_STATE the active continuation.
Done only after every selected criterion has evidence. Append completion record then. Otherwise retain In progress, or Blocked with exact missing input/failure and safe retry; no Done claim merely because time ran out.
Update CURRENT_STATE even after incomplete sessions: selected task/status, next eligible ID/exact action, baseline/user changes, files changed, version/placement/interface decisions, commands/results/isolation/evidence, remaining acceptance/failed/unrun checks and owned live processes/editor cleanup.
Preserve historical task IDs and records; document pending scope/dependency changes rather than renumbering completed work. Useful actual production/discovery updates may go in parent README/architecture while retaining previous release history.
Review intended diff, links, references, dependency/status consistency. Report task ID/status, result, checks/limits and next eligible task. Stop after this task.
