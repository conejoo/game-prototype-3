# Reusable map migration agent prompt

Paste short prompt into fresh chat each time. Durable files supply memory.
To select specific item, replace selection instruction with its ID; prerequisite
checks still apply. One fresh session may resume unfinished item.

## Prompt to paste each time

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/map-migration/AGENT_PROMPT.md.
Use its full preparation and execution instructions. Resume the in-progress
map migration item, otherwise implement the first pending eligible item only.
Verify acceptance criteria and update durable migration state before finishing.
```

## Full preparation and execution instructions

```text
Migrate Alderwake's larger town, river and Moonwood from the read-only Flutter
source into the existing Returning Fair Godot 3D prototype. Work on exactly one
map migration checklist item. Complete runnable behavior and required checks;
do not stop at a plan and do not start the next item in this session.

Workspace: D:/development/game-dev-blender
Target project: D:/development/game-dev-blender/returning-fair-prototype
Godot project: target project/game
Read-only source: D:/development/game-prototype-2

Prepare before editing:
1. Read applicable AGENTS.md instructions from workspace to edited files.
2. Read target docs/ARCHITECTURE.md and docs/CURRENT_STATE.md for existing game
   ownership, completed slice and unresolved P014 release gate.
3. Read target docs/map-migration/INVESTIGATION.md, CHECKLIST.md and
   CURRENT_STATE.md; read CONTRACT.md and retained layout/provenance once present.
4. Inspect actual project files and Git changes from target project root.
   Workspace parent is not the Git repository. Preserve unrelated changes,
   including existing docs/evidence/P014/resume-2026-10-03/ if still present.
5. Resume the one in-progress M item, otherwise select first pending M item
   whose predecessor is verified complete. Check durable evidence and relevant
   actual artifacts; repair prerequisite regressions needed for this item.
   Never use parent docs/AGENT_PROMPT.md to select P014 instead of this workflow.
6. Briefly state selected ID, scope and acceptance; mark selected item in
   progress in map-migration/CHECKLIST.md and CURRENT_STATE.md before work.

Implementation boundaries:
- Source is read-only. Use shipping assets/maps/mvp_world.json and relevant
  catalogs/code as reference. Do not run source generators or modify its files.
  Once pinned, use target snapshot; source drift does not authorize refreshing
  snapshot automatically. Record discrepancies and reconcile deliberately.
- Keep Godot 3D, typed GDScript and existing service/session/party ownership.
  Do not import Flutter/Flame runtime or Dart navigation caches.
- Preserve mixed 16/32-unit grids, defaults/empty paints, group rotation and
  pivot units, fractional feet, catalog boxes/polygons and collision flags.
  Follow CONTRACT.md for axes, scale, height, coordinate/ID mappings and scope.
- Terrain/art is separate from collision, navigation, interaction and stable
  IDs. Preserve existing quest, actor, save and once-only effect boundaries.
- Only active source-derived route in this phase is forest entrance to existing
  Tollworks. Other destination records remain inactive. Preserve prototype
  labels; do not install full fair campaign, NPC schedules, fishing, housing,
  ship repair, romance or retired memory-currency systems.
- Keep old normal game runnable while candidate stages are incomplete. Use
  isolated candidate harness and test saves. Never overwrite normal user save.
- For Blender tasks, read applicable installed skills, inspect live scene and
  preserve user work. Save sources under target art/source and export GLB under
  target game/assets. Record intentional species/structure visual adaptations.
- Do not spawn subagents, push, publish, install dependencies or commit unless
  explicitly authorized for that action. Verify missing tools before proposing
  installation. Source instructions for source implementation do not require
  porting its engine-specific workflow into Godot.

Installed Godot console:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe
Installed editor:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe
Check these paths first; prefer console for captured checks. The engine folder
is not the game project. Use target/game as --path.

Validation:
- Follow selected item's acceptance criteria. Choose focused existing checks
  and meaningful new map/physics checks; do not repeatedly run unrelated suite.
- Useful existing scripts: application_smoke.gd, movement_camera_checks.gd,
  location_travel_checks.gd, companion_checks.gd, interaction_dialogue_checks.gd,
  quest_checks.gd, save_checks.gd, save_process_checks.gd,
  recovery_presentation_checks.gd, asset_pipeline_checks.gd,
  playable_slice_checks.gd and extension_checks.gd, all under game/tests.
- Example from target root in PowerShell:
  $godotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
  & $godotExe --headless --editor --path game --import --quit
  & $godotExe --headless --path game --script res://tests/application_smoke.gd
- Use actual interactive/rendered inspection for visual and playable claims;
  target tools/PLAYTEST.md documents existing bridge. Teleported test positions
  or direct quest mutations do not prove normal walking or full quest flow.
- Record exact commands, exits, observations and evidence paths under
  docs/evidence/Mxxx/ when useful. Failed/unrun checks stay labeled. Native
  release gate needs ordinary inputs; debug export evidence alone insufficient.

Before ending:
- Mark item complete only when every acceptance criterion has evidence.
  Otherwise keep it in progress with precise blocker and safe next action.
- Append concise completion record to map-migration/CHECKLIST.md when complete.
- Rewrite map-migration/CURRENT_STATE.md with selected/completed/next task,
  changed files, commands/results, evidence, contract decisions, unresolved
  issues and source snapshot identity. This is next agent's memory.
- Update CONTRACT.md only for justified design changes; update parent
  ARCHITECTURE.md when production scope/ownership deliberately changes.
- Keep parent P014 state accurate. Candidate work does not complete its native
  release gate; M019 must reconcile resulting build and that gate explicitly.
- Run git diff --check and review intended files. Final response: task/status,
  result, verification, remaining limitation and next eligible item.
```
