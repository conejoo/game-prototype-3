# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P003.

## Current task

- P003 complete; P001/P002 prerequisites pass. P004 next eligible, not started.
- Physical hero, camera-relative WASD, mouse ground-facing, overhead follow,
  two projections, zoom, collidable graybox, pause/resume/quit and validated catalog.
- No location travel, saves, combat, runtime dialogue, companions or Blender assets.

## Implementation and changed files

Root: `D:/development/game-dev-blender/returning-fair-prototype`; Godot path `/game`.
Initial Git clean at `cddb606`. Existing scene/script UIDs and source preserved.

- `game/features/actors/actor_placeholder.gd`: CharacterBody3D wrapper; accepted
  unhandled presses/release clearing, 4 m/s normalized movement, gravity/sliding,
  viewport mouse aim and visual-only facing. Session still supplies ActorState.
- `game/app/game_root.tscn`: independent capsule collider/VisualRoot/aim marker.
  Minimum wall slide angle zero permits shallow-angle movement along walls.
- `game/app/camera_rig.gd`: supplied target follow, camera-relative axes/ground ray,
  orthographic size18 or perspective45°, offset (10,14,16), zoom0.8–1.15.
- `game/app/game_root.gd`, `game/project.godot`: explicit controls wiring; logical
  WASD, P projection, wheel/+/- zoom; pause/window focus clears accepted movement.
- `game/world/test_room.tscn`: four physical walls and beacon plinth; original
  floor retained. Near front/right walls lower for visibility.
- `game/ui/prototype_ui.gd`, `.tscn`: controls/camera label, UI/pointer isolation.
- `game/tests/movement_camera_checks.gd`, `live_playtest_checks.gd`,
  `application_smoke.gd`: focused physics/input/protocol checks; script UIDs kept.
- `game/tests/live_playtest_bridge.gd`, `tools/send_playtest.ps1`, `tools/PLAYTEST.md`:
  user-authorized opt-in local input/capture harness. Debug-only, no listener;
  bounded timed keys/chords, mouse/GUI events, observations, captures and quit.
  Normal InputMap/GUI paths; no direct actor/session/quest mutation.
- README/checklist/current state/evidence updated. ARCHITECTURE adds deliberate
  developer-tool boundary and records provisional camera decision.

## Checks and evidence

Engine `4.7.2.stable.mono.official.ed1daf0bf`, --version exit0.
Exact commands/exits, acceptance mapping and evidence: `evidence/P003/VALIDATION.md`.

- Editor import exit0; no GDScript errors. Existing unused C# SDK10.0.9 warning.
- Final application smoke, movement/camera and live bridge checks exit0/PASS.
  P002 catalog check exit0/PASS. Definitions/health/session isolation retained.
- Git diff --check exit0; no unconsumed bridge readiness files after shutdown.
- Real Windows Compatibility renderer: RTX4070 Laptop, driver581.29. Timed
  viewport input traversed actual room (no teleports): all four walls, two corners,
  escape and plinth contact. Screenshots inspected; responses retain exact state.
- Same-position projection comparison and two aim directions inspected;
  orthographic retained provisionally for consistent scale/readability.
- Rendered pause/held-key resume, focused Pause button, mouse Pause/Resume,
  HUD aim exclusion and zoom0.8/1.15 checks pass. Windowed quits exit0.
- User manually confirmed: “Collisions work, I can walk around.” Hardware key
  events/contact logs in interactive-verified.log; no normal-play debug setup.

## Decisions, repairs and limits

- Logical WASD and independent mouse facing are provisional controls. P/zoom
  remain comparison controls. Attack/dodge/interact bindings have no behavior yet.
- Default15° wall slide threshold caused shallow diagonal sticking; set zero,
  rechecked both corners/escape. Headless viewport explicitly960x640; aim uses
  viewport mouse events because synthetic motion does not update OS mouse query.
- Windows automation key taps lacked a sustained physics interval and sent a
  mismatched physical code. Logical bindings repaired mapping; user explicitly
  authorized timed local tools. Monotonic deadlines fix short timers after slow
  capture frames. Developer inputs still differ from OS hardware/focus behavior.
- Initial desktop lock blocked computer-use; user unlocked and manually played.
  Later rendered checks use in-game captures, not locked-desktop UI automation.
  Historical failed/blocked attempts remain labeled in validation record.
- Test harness starts only with explicit flag in a debug build, writes ignored
  builds/playtest sessions and releases input afterward. It cannot prove normal
  story progression, save behavior or an exported build. Commands/evidence reusable.
- Source reference now restored (game-story.txt/docs/lib etc. present). Old empty
  checkout note stale. Read-only inventory only; no P003 narrative adaptation.
- P003 implementation, tools and evidence recorded in local Git at user request
  on 2026-10-02. No unrelated user changes, source edits, push or publication.
  Missing C# SDK, Blender connection/assets and export remain outside current item.

## Next eligible task

P004 only: connected Alderwake/Tollworks grayboxes, stable spawn anchors, explicit
party suspend/load/place/resume lifecycle and repeated round-trip evidence.
Read architecture/checklist first; recheck P003 and source canon before narrative
adaptation. Live harness usage: `../tools/PLAYTEST.md`. No next-item work started.
