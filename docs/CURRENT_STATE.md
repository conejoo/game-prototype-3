# Current prototype state

Last updated: 2026-10-01 (America/Vancouver). Verified implementation state.

## Current task

- P001 complete. P002 next eligible; P002–P014 remain pending.
- Actual Windows game opens, pauses/freezes, resumes, quits normally (exit 0).
- Hero stationary. No movement, quests, combat, companion, saves, Blender assets,
  or Windows export yet. Room/capsule are prototype fixtures.

## Implementation and changed files

Root: `D:/development/game-dev-blender/returning-fair-prototype`.
Godot path: root plus `/game`. Read-only source game untouched.

- `.gitignore`, `README.md`, `game/project.godot`: repo ignores, commands,
  Compatibility renderer, nine InputMap actions, default main scene.
- `game/app/game_root.gd`, `.tscn`: persistent root, explicit WorldHost/Party/
  CameraRig/UI, initialization, pause/quit authority, session composition.
- `game/app/game_session.gd`: separate mutable play time, no scene references.
- `game/app/camera_rig.gd`: supplied target; provisional angled perspective.
- `game/world/test_room.gd`, `.tscn`: graybox, rotating gold pause marker.
- `game/ui/prototype_ui.gd`, `.tscn`: HUD/menu, command signals, focus handling.
- `game/tests/application_smoke.gd`: composition/bindings/state/pause checks.
  Six generated script UIDs and three scene UIDs retained.
- `docs/CHECKLIST.md`, this handoff, `docs/evidence/P001/`: status, completion,
  commands/results, logs, screenshots.

No architecture design change; ARCHITECTURE.md and AGENT_PROMPT.md preserved.
Architecture's original preparation status describes its historical proposal;
this handoff and CHECKLIST.md now establish actual implementation status.

## Checks and evidence

`docs/evidence/P001/VALIDATION.md` records exact commands, executable/project
paths, exit codes, inspection sequence, earlier attempts, and repairs.

- Console `--version`: exit 0, `4.7.2.stable.mono.official.ed1daf0bf`.
- `--headless --editor --path <game> --import`: exit 0; import finishes, no
  GDScript parse errors; `editor-final.log`. Mono C# diagnostic noted below.
- `--headless --path <game> --script res://tests/application_smoke.gd`: exit 0,
  PASS, no errors/warnings; `smoke-final.log`. Rechecked after scene UID changes.
- `--path <game>` actual window: Escape/buttons pause/resume; time and beacon
  freeze then advance; F10 quits while paused, exit 0, no runtime errors.
  `interactive-final.log`, `running.png`, `paused.png`, `paused-later.png`,
  `resumed.png`, `window-closed.json`.
- `git diff --cached --check -- . ':!docs/evidence/P001/*.log'`: exit 0;
  raw engine logs retain original whitespace. Dedicated repo on `main`. P001
  source, planning docs, and evidence included in the initial progress commit
  at the user's request, authored by `conejoo <aldo.canepa.g@gmail.com>`.
  No remotes, push, or publication. Cache/builds ignored; scene/script UIDs kept.

## Decisions and limitations

- GameRoot/UI always process; world/party/camera explicitly pause. No autoload
  or speculative services. Replaceable visuals under VisualRoot.
- Logical Esc/F10 repaired after actual input exposed physical-binding failure;
  physical WASD retained. Other gameplay actions only configured.
- Perspective FOV 45 and Compatibility rendering are provisional launch choices.
  P003 must compare projection using playable movement evidence.
- Mono editor reports missing .NET SDK `10.0.9`; `dotnet --list-sdks` exits 0,
  empty output. GDScript imports and runs cleanly; C# tooling unavailable.
  Nothing installed.
- Initial sandbox cache/certificate diagnostics cleared in final normal-access
  runs. One approval review timed out; successful retry resolved access.
- MCP UID updater processed zero files despite claimed success. Local Godot API
  assigned scene UIDs; headers inspected, checks rerun, temporary script removed.
- No source canon imported in P001. Companion identity, hero motive, romance,
  permanent dialogue, final projection/palette/hardware target remain open.
  No retired borrowed-days/memory-currency concepts introduced.
- Blender connectivity/current scene and export templates remain unverified.
- No blocker remains for P001 or starting P002.

## Next session

Read applicable instructions, ARCHITECTURE.md, CHECKLIST.md, and this handoff;
inspect actual files and Git changes. Select P002 only: stable-ID definitions,
separate mutable actor/session state, initialization/content validation. Read
source canon before importing Maris (`npc-03`) facts; label temporary companion/
dialogue fixtures. Preserve P001 baseline and any subsequent user changes.
