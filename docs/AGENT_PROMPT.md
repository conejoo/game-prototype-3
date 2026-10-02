# Reusable sequential implementation prompt

Paste the block below into a new agent/chat. It selects the next eligible task
from durable files. To target a particular item, replace the selection sentence
with its task ID while retaining prerequisite checks.

```text
Continue developing the Returning Fair Godot + Blender prototype.

Project root:
D:/development/game-dev-blender/returning-fair-prototype

First read applicable AGENTS.md instructions and these documents:
1. docs/ARCHITECTURE.md
2. docs/CHECKLIST.md
3. docs/CURRENT_STATE.md

Inspect actual project files and Git changes. Handoff notes can be stale; verify
before trusting their claims. If an unrelated user change exists, preserve it.

Work on exactly one checklist item: resume the in-progress item, otherwise
select the first pending item whose prerequisites are verified complete.
State selected ID and its acceptance criteria briefly, then implement it.
Continue through required fixes and checks until this item is complete or a
concrete dependency prevents further progress. Do not stop after a plan or
scaffold when acceptance requires runnable behavior. Do not start the next
item in the same session unless I explicitly authorize multiple items.

Keep architecture boundaries in ARCHITECTURE.md. Implement only abstractions
needed by current work. Definitions and mutable state stay separate; quest
effects are once-only; saves use stable IDs and versioned plain data; imported
art is replaceable inside Godot gameplay wrappers. Keep every stage runnable.
Changes that are necessary to repair this item's prerequisites are in scope;
record them and recheck affected behavior.

Source game at D:/development/game-prototype-2 is read-only reference. Reuse
selected Returning Fair story and canonical IDs selectively; do not port the
entire Flutter runtime, modify the source project, or silently revive retired
borrowed-days/memory-currency ideas. Temporary companions and dialogue remain
labeled prototype content. Ask only if a required permanent narrative decision
cannot safely use a temporary fixture; continue independent work while waiting.

Godot is installed outside PATH. Check these paths first:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe
Use console executable for captured checks and the project /game directory as
Godot project path. Do not confuse engine installation with project location.
Prefer available Godot MCP tools where useful. Verify missing dependencies
before proposing installations. Do not push or publish anything.

For Blender work, read applicable installed skills, inspect connection and
current scene, and preserve unrelated user work. Save prototype source .blend
files under this project's art/source and export GLB for Godot wrappers. An
exposed tool is not proof of live connection or completed asset work.

Validate according to this item's acceptance criteria. Use focused headless
checks for data/rules and actual interactive inspection for visual/gameplay
claims. Record commands, exit results, and evidence paths. A simulated debug
objective does not prove normal gameplay. An untested export is not a verified
Windows build. If a required check cannot run, leave the task incomplete and
record exact reason plus safe next action.

At start mark selected task in progress. At end:
- Mark complete only if every acceptance criterion has evidence.
- Add a completion record to CHECKLIST.md when complete.
- Update CURRENT_STATE.md with implementation summary, changed files, exact
  checks, decisions, known limitations/blockers, and next eligible task.
- Update ARCHITECTURE.md only for deliberate, justified design changes.
- Keep notes concise enough for the next session to resume without chat history.

Final response: task ID/status, what changed, what passed, what remains, and next
task. Follow workspace communication style. Do not spawn subagents merely
because this prompt addresses an agent; one sequential implementation session
is intended unless I explicitly request delegation.
```

## Short resume prompt

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/AGENT_PROMPT.md.
Implement the next eligible checklist item only. Verify its acceptance criteria
and update the durable handoff before finishing.
```

## Larger working sessions

If desired, explicitly authorize a bounded batch, for example P001–P003. Finish
and verify each item before beginning the next, and update durable notes at each
boundary. This preserves the same workflow while reducing chat overhead.
