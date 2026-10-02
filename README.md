# Returning Fair prototype

P001–P006 complete. Start in Alderwake; approach purple temporary companion or
gold practice marker and press E to talk/inspect. Choose with mouse or Tab/Enter;
Finish/Close or Esc returns control. E at glowing gate travels to Tollworks/back.
Both rooms reuse labeled prototype interactions. Physical hero, mouse facing,
overhead follow, projection and zoom remain.

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
& $godotExe --headless --path $gamePath --script res://tests/location_travel_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/save_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/interaction_dialogue_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/save_process_checks.gd -- --phase=write
& $godotExe --headless --path $gamePath --script res://tests/save_process_checks.gd -- --phase=read
```

Verified engine: `4.7.2.stable.mono.official.ed1daf0bf`. Esc pauses/resumes; F10
quits, including while paused. Pause, Resume, and Quit prototype buttons accept
mouse/keyboard focus. Pausing freezes world simulation and elapsed play time.
WASD moves relative to camera; mouse faces cyan ground marker. P switches between
orthographic (provisional default) and 45° perspective. Wheel or +/- zooms between
0.8 and 1.15 framing factors. Walls/plinth block movement; diagonals retain normal
speed. Pause/UI focus/window focus loss clears held controls; press movement keys
again after control returns. HUD pointer regions block aim/wheel zoom. Attack,
Space dodge remain configured only. E selects nearest visible interaction;
dialogue blocks gameplay input, clears held movement, and excludes save/load.
Dialogue choices are temporary presentation only; no quest/reward/trust effects.
P003 rendered playtests and
manual keyboard/collision confirmation passed; orthographic retained provisionally.

Esc opens Save run / Load saved run. Save health, party and elapsed time while
paused outside travel/dialogue; Load returns to the last arrival anchor in the saved room,
not the saved physical position. No autosave: reopen, pause, choose Load to resume.
Normal slot is `user://saves/returning-fair.json` in Godot's application user-data
directory, with `.bak` recovery. Missing/corrupt primary may recover validated
backup visibly; incompatible versions are rejected and preserved. Both corrupt
files require repair or archiving that slot before saving. Version rules and
boundaries: [architecture](docs/ARCHITECTURE.md).

Installed Mono editor reports missing .NET SDK `10.0.9` during editor import.
Import finishes with exit 0; this GDScript game and its headless check run cleanly.
No C# build is needed for this stage. Restricted automation can block normal
Godot cache/certificate access; final checks used normal local application access.

## Layout and ownership

- `game/app/game_root.tscn`: persistent root, WorldHost, Party, CameraRig, UI.
- `game/core/`: typed catalog manifest, definition base, atomic validation/indexes.
- `game/core/save_codec.gd`, `save_repository.gd`: strict versioned plain-data
  validation, detached candidate runs, checked temporary writes and good backup.
- `game/content/`: authored actor/location/dialogue `.tres` definitions.
- `game/app/game_session.gd`: mutable time, location/spawn IDs, actor instances.
- `game/app/world_host.gd`, `party.gd`: synchronous travel lock, actor suspension,
  scene/anchor validation, physics/navigation synchronization, safe placement,
  rollback and resume. Actor wrappers/state survive room replacement.
- `game/features/actors/`: authored health defaults, independent runtime state,
  physical hero wrapper receiving session state and supplied camera/UI controls;
  facing rotates VisualRoot only. Combat not implemented.
- `game/features/interaction/`: reusable NPC/prop wrappers and range/LOS selector;
  stable gameplay identities and collision outside replaceable VisualRoot.
- `game/features/dialogue/`: authored choices and node-independent transient
  service with explicit results; GameRoot arbitrates controls/lifecycle, UI submits.
- `game/tests/interaction_dialogue_checks.gd`: invalid choice/action rejection,
  independent state, both-room input/GUI, modal attack-input probe, cancellation,
  save boundary, LOS and unload cleanup. Positioned fixtures are not playtest proof.
- `game/world/test_room.*`: graybox and rotating simulation marker.
- `game/world/alderwake.tscn`, `tollworks.tscn`: replaceable prototype locations;
  `SpawnAnchor.stable_id` identifies arrivals independently of node names.
- `game/ui/prototype_ui.*`: display/command signals, no session authority.
- `game/tests/application_smoke.gd`: actual root loaded headlessly; playtest separate.
- `game/tests/content_catalog_checks.gd`: malformed content/reference/duplicate
  rejection, startup failure, independent health/progress; detached test fixtures.
- `game/tests/movement_camera_checks.gd`: synthetic viewport input through actual
  root, physics walls/corners/plinth, camera/aim integration and input isolation.
- `game/tests/live_playtest_bridge.gd`, `tools/send_playtest.ps1`: opt-in timed
  input/chords, mouse/GUI events, rendered captures and state observations.
  Usage and limits: [live playtest tools](tools/PLAYTEST.md).
- `game/tests/location_travel_checks.gd`: ten round trips, actor/state identity,
  unsafe spawn rollback, reentry/input lock, pause/focus and stale-room release.
- `game/tests/save_checks.gd`, `save_process_checks.gd`: isolated user:// files,
  corrupt/newer save rejection, backup recovery, write failures, physical restore
  rollback and separate OS-process round trip; health changes are test fixtures.
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
fixtures; purple stand-ins demonstrate dialogue in both rooms, without companion
AI. Location/spawn IDs now map to validated physical anchors.
Navigation map synchronizes on travel; no companion paths exist yet (P009).

Exact check results: [P001 validation](docs/evidence/P001/VALIDATION.md),
[P002 validation](docs/evidence/P002/VALIDATION.md),
[P003 validation](docs/evidence/P003/VALIDATION.md),
[P004 validation](docs/evidence/P004/VALIDATION.md),
[P005 validation](docs/evidence/P005/VALIDATION.md),
[P006 validation](docs/evidence/P006/VALIDATION.md).
Next eligible task: P007 (not started). Read
[current state](docs/CURRENT_STATE.md) before work.
