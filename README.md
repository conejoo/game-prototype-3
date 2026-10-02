# Returning Fair prototype

P001–P003 complete. Physical hero, mouse facing, overhead follow, projection toggle and
zoom run in the same primitive room. Room content remains a prototype fixture.

## Run and check

PowerShell, from any directory. Engine installation and project are separate.

```powershell
$godotExe = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
$gamePath = 'D:/development/game-dev-blender/returning-fair-prototype/game'
& $godotExe --version
& $godotExe --editor --path $gamePath
& $godotExe --headless --editor --path $gamePath --import
& $godotExe --path $gamePath
& $godotExe --headless --path $gamePath --script res://tests/application_smoke.gd
& $godotExe --headless --path $gamePath --script res://tests/content_catalog_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/movement_camera_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/live_playtest_checks.gd
```

Verified engine: `4.7.2.stable.mono.official.ed1daf0bf`. Esc pauses/resumes; F10
quits, including while paused. Pause, Resume, and Quit prototype buttons accept
mouse/keyboard focus. Pausing freezes the gold beacon and elapsed play time.
WASD moves relative to camera; mouse faces cyan ground marker. P switches between
orthographic (provisional default) and 45° perspective. Wheel or +/- zooms between
0.8 and 1.15 framing factors. Walls/plinth block movement; diagonals retain normal
speed. Pause/UI focus/window focus loss clears held controls; press movement keys
again after control returns. HUD pointer regions block aim/wheel zoom. Attack,
Space dodge and E interaction remain configured only. P003 rendered playtests and
manual keyboard/collision confirmation passed; orthographic retained provisionally.

Installed Mono editor reports missing .NET SDK `10.0.9` during editor import.
Import finishes with exit 0; this GDScript game and its headless check run cleanly.
No C# build is needed for this stage. Restricted automation can block normal
Godot cache/certificate access; final checks used normal local application access.

## Layout and ownership

- `game/app/game_root.tscn`: persistent root, WorldHost, Party, CameraRig, UI.
- `game/core/`: typed catalog manifest, definition base, atomic validation/indexes.
- `game/content/`: authored actor/location/dialogue `.tres` definitions.
- `game/app/game_session.gd`: mutable time, location/spawn IDs, actor instances.
- `game/features/actors/`: authored health defaults, independent runtime state,
  physical hero wrapper receiving session state and supplied camera/UI controls;
  facing rotates VisualRoot only. Combat not implemented.
- `game/world/test_room.*`: graybox and rotating simulation marker.
- `game/ui/prototype_ui.*`: display/command signals, no session authority.
- `game/tests/application_smoke.gd`: actual root loaded headlessly; playtest separate.
- `game/tests/content_catalog_checks.gd`: malformed content/reference/duplicate
  rejection, startup failure, independent health/progress; detached test fixtures.
- `game/tests/movement_camera_checks.gd`: synthetic viewport input through actual
  root, physics walls/corners/plinth, camera/aim integration and input isolation.
- `game/tests/live_playtest_bridge.gd`, `tools/send_playtest.ps1`: opt-in timed
  input/chords, mouse/GUI events, rendered captures and state observations.
  Usage and limits: [live playtest tools](tools/PLAYTEST.md).
- `docs/`: architecture contract, sequential checklist, durable current state.

Root/UI process while paused; world/party/camera explicitly stop. Camera gets
its target from GameRoot. Replaceable hero visuals live under
`Party/PlayerPlaceholder/VisualRoot`. No global autoload needed yet.

Scene UIDs and script `.uid` files belong in Git. `.godot/`, local builds, and
private export credentials are ignored. Dedicated local repo on `main`; P001
source, documentation, and evidence recorded in the initial progress commit.
No remote configured.

Maris retains supplied `npc-03` identity. Her health is a prototype default;
no additional canon facts imported. Source `D:/development/game-prototype-2`
now contains source files (rechecked 2026-10-02); previous empty-checkout note was
stale. Consult relevant canon before story adaptation. Companion/greeting are labeled noncanonical
fixtures, catalog-only. Spawn ID is metadata until P004 adds world anchors.

Exact check results: [P001 validation](docs/evidence/P001/VALIDATION.md),
[P002 validation](docs/evidence/P002/VALIDATION.md),
[P003 validation](docs/evidence/P003/VALIDATION.md).
Next eligible task: P004 (not started). Read
[current state](docs/CURRENT_STATE.md) before work.
