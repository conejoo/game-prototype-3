# Grass depth — reusable fresh-agent prompt

## Paste into each new chat

~~~text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/art-direction-storybook/grass-depth/AGENT_PROMPT.md.
Complete exactly one eligible GD task, including actual Godot visual checks. Preserve selected grass A. Update this workflow's CHECKLIST.md and CURRENT_STATE.md, then stop before the next task.
~~~

Creating this workflow does not start implementation. When the user invokes it, the files provide memory for one bounded task; this personal planning skill and previous chat history are not required.

## Bootstrap

Workspace D:/development/game-dev-blender; repository D:/development/game-dev-blender/returning-fair-prototype; application game/; scene res://app/game_root.tscn.
Active workflow: docs/art-direction-storybook/grass-depth. Goal: improve local grounding, irregular vegetation overlap and sparse height around selected schoolhouse/wall/path contacts, keeping grass A.

Read applicable AGENTS.md, this folder's CHECKLIST.md, CURRENT_STATE.md and CONTRACT.md. Read DEPTH_SPEC.md after GD001 creates it; absence before GD001 is expected. Follow linked GRASS01 evidence/source and versioned testing guidance as needed. Old AD/map/interior/routine checklists are references, not selectors.

Inspect current Git changes and actual runtime code/assets first. Preserve existing uncommitted pilot, art/direction, prompt/contract and interiors work. Never reset/stash work or treat recorded HEAD as checkout target. Command-local Git exception if needed:
~~~powershell
git -c safe.directory=D:/development/game-dev-blender/returning-fair-prototype status --short
~~~

## Select and execute

Resume the single In progress GD task first. Reassess a Blocked task when its specific blocker changes; exclude unresolved work and its dependents. Otherwise choose lowest Pending GD task with verified Done prerequisites. Reconcile status/evidence conflicts; if selection remains ambiguous, report exact conflict and stop. If all GD tasks Done, report review-package completion and outstanding user art decision; do not implement rollout.

State selected ID and observable outcome; mark In progress before edits. Complete exactly that task and required repairs/checks. Do not stop at a plan when implementation is required. Stop before successor.

No automatic agent spawning or new chats. User can invoke this prompt in a fresh session for each task. GD005 should be a fresh reviewer session with critical pixel inspection before prior self-assessments. Parallel source edits are unnecessary because later steps depend on earlier visual results.

Contract owns A pin, region, contacts, budgets, opt-in behavior and preservation boundaries. Do not switch to B, regenerate accepted albedo, move paths/walls, add gameplay, globally retune lighting or broaden patch. Proposed fixtures/controls in checklist are not pre-existing APIs: inspect current APIs and implement owned prerequisites first.

## Verification

Inspect actual target/A/candidate PNGs at normal960x640 as well as closeups. Keep camera, time, weather, exposure and geometry matched when isolating cues. Do not hide failures through different crops, global color changes, enlarged-only screenshots or AI repainting of engine captures. Passing code checks, quieter pixel statistics and a confident prose description do not establish visual fidelity.

Console Godot:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Check path before searching/installing. Use game/ as --path; GL Compatibility; PowerShell7 runner. Existing example from repository root:
~~~powershell
./tools/run_checks.ps1 -Task GD001 -RenderOnly -RenderScript grass_pilot_render -RenderPhases compare -TimeoutSeconds 180
~~~
This invokes existing GRASS01 fixture, whose B-only pan/night samples do not validate chosen A depth. GD001 creates proposed grass_depth_render; once created:
~~~powershell
./tools/run_checks.ps1 -Task GD001 -Names application_smoke -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180
~~~
Later tasks use their own GD ID and checklist's relevant checks. These commands are instructions, not claims of executed/passing runs.

Use runner's fresh task/run evidence and isolated save routes. Consume capture/helper errors, respect source-change gates, retain failed logs and clean only owned PIDs. Read versioned gameplay-testing skill before runtime work. Synthetic pose/time/camera review must be labeled; it does not prove normal movement. Finish source/import edits before final validation; no game/tools edits during a run.

## Handoff and stop

Done only with all task criteria evidenced. Otherwise retain In progress, or Blocked for a specific dependency that prevents progress, and record precise next action. Update checklist and current state for incomplete sessions too.

Record baseline/current changes; files touched; decisions; exact commands/CWD/data isolation; results/source fingerprint; actual inspected captures; failed/unrun criteria; remaining concept gaps; live process/editor state and cleanup owed. A debug review server may remain only if identified as a user-facing deliverable with PID/root/URL.

Final response: selected ID/status, visible result, verification, remaining gaps, next eligible task. Separate implementation completion from user visual acceptance. No automatic successor, package rebuild, commit/push or rollout.
