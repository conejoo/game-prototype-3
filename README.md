# Returning Fair prototype

P001–P013 complete. Full shortened recovery slice is playable from a fresh run.
One labeled temporary ally follows, routes around obstacles and assists combat.
Approach the purple companion station and press E for its optional trust choice.
Choose with mouse or Tab/Enter;
Finish/Close or Esc returns control. E at glowing gate travels to Tollworks/back.
Both rooms retain labeled prototype companion stations. Physical hero, mouse facing,
overhead follow, projection and zoom remain. Maris's prototype counter is southwest;
accept her lead, travel north, and read J journal. Defeat the protective guardian
with mouse clicks; Space dodges its gold windup/red strike. R retries after death.
Then inspect the southeast vessel, return north, and reconnect at Maris's counter.
Read the returned experience, compare familiar gear and finish the practical fitting.
Cancellation keeps specialist service unavailable. Completion restores displayed
river gear and specialist service preview; basic supplies stay available. Both
variants survive travel and save/restart. Purchases/inventory are outside this slice.
Companion dialogue offers one mutually exclusive Trust +1 / -1 prototype decision.
Accepting Maris's lead earns one preparation point; J journal lets you select
Deliberate Strike, raising hero damage from 25 to 40. Choices/upgrades persist.

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
& $godotExe --headless --path $gamePath --script res://tests/playable_slice_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/content_catalog_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/movement_camera_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/live_playtest_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/location_travel_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/save_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/interaction_dialogue_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/quest_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/combat_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/companion_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/consequence_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/recovery_presentation_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/recovery_presentation_checks.gd -- --phase=write
& $godotExe --headless --path $gamePath --script res://tests/recovery_presentation_checks.gd -- --phase=read
& $godotExe --headless --path $gamePath --script res://tests/consequence_checks.gd -- --phase=write
& $godotExe --headless --path $gamePath --script res://tests/consequence_checks.gd -- --phase=read
& $godotExe --headless --path $gamePath --script res://tests/save_process_checks.gd -- --phase=write
& $godotExe --headless --path $gamePath --script res://tests/save_process_checks.gd -- --phase=read
& $godotExe --headless --path $gamePath --script res://tests/quest_process_checks.gd -- --phase=write
& $godotExe --headless --path $gamePath --script res://tests/quest_process_checks.gd -- --phase=read
```

Verified engine: `4.7.2.stable.mono.official.ed1daf0bf`. Esc pauses/resumes; F10
quits, including while paused. Pause, Resume, and Quit prototype buttons accept
mouse/keyboard focus. Pausing freezes world simulation and elapsed play time.
WASD moves relative to camera; mouse faces cyan ground marker. P switches between
orthographic (provisional default) and 45° perspective. Wheel or +/- zooms between
0.8 and 1.15 framing factors. Walls/plinth block movement; diagonals retain normal
speed. Pause/UI focus/window focus loss clears held controls; press movement keys
again after control returns. HUD pointer regions block aim/wheel zoom/attack.
Click starts one swing with windup, active and recovery windows; each target is
contacted once per swing, through range/facing and world-obstruction checks.
Space dodges in held movement direction, or current facing when stationary;
dodge lasts 0.30s and blocks damage. E selects nearest visible interaction;
dialogue blocks gameplay input, clears held movement, and excludes save/load.
The first two companion choices remain presentation-only guidance.
Practice markers/test beacons appear only with explicit debug-only
`--developer-fixtures`; P006 checks enable their fixtures deliberately.
The other companion choices record mutually exclusive once-only trust reactions. Maris/vessel choices
submit quest commands with prerequisite/source checks and durable once-only effects.
J opens the journal; J/Esc/Close returns control. Both modals clear held movement,
contain Tab focus, and block world input/save/load. Scroll journal to inspect recorded companion reaction; upgrade button spends the
one earned point, then disables. Trust is companionship only, with no romance gate.
P003 rendered playtests and
manual keyboard/collision confirmation passed; orthographic retained provisionally.

Esc opens Save run / Load saved run. Save health, party, elapsed time, quest progress
and effects while paused outside travel/dialogue/journal/combat/action/death;
Load returns to the last arrival anchor in the saved room,
not the saved physical position. No autosave: reopen, pause, choose Load to resume.
Normal slot is `user://saves/returning-fair.json` in Godot's application user-data
directory, with `.bak` recovery. Missing/corrupt primary may recover validated
backup visibly; incompatible versions are rejected and preserved. Both corrupt
files require repair or archiving that slot before saving. Version rules and
boundaries: [architecture](docs/ARCHITECTURE.md). Schema v4/content v1 requires hero
and temporary companion records plus validated reaction/trust and upgrade IDs.
Exact v1/v2 saves add fixture ally at full health; v1 starts with no quest effects.
Exact v3 preserves both members. All legacy saves start with neutral trust and
no selected upgrades; a previously accepted lead provides one unspent preparation
point. Load does not rewrite files; explicit Save writes v4. Malformed/newer data is rejected.

Guardian appears after accepting the lead and entering Tollworks. Its stable
instance `tollworks-guardian-01` reports actual death to the quest owner. Clearance
uses the existing durable `tollworks-guardian-cleared` effect; saved P007 completion
remains compatible. No simulated guardian prop/flag remains. An unfinished fight
resets on room reload; party health persists. R restores full party health at the
arrival anchor after death, preserving quest facts. Cleared guardians stay defeated
through retry, travel and save/restart. Combat pause permits Resume, but locks
Save/Load; retreat outside guardian engagement to use other interactions.
This remains a shortened, labeled adaptation. The practical fitting restores
specialist service; vessel recovery does not repair the ship.

Ally deals 10 damage through the same swing/LOS rules, follows within 1.6m and
returns outside its 6m combat leash. Health zero means incapacitated; after 3s
outside enemy threat, it recovers at a verified safe point near the living hero.
Stuck routes (2.5s) or large separation (8m) permit safe catch-up outside combat.
Pause/dialogue/journal/focus loss freeze AI. Saves preserve ally health, including
zero; route/action/recovery timers restart. Stationary dialogue stand-ins are
separate prototype presentation fixtures. Temporary trust decisions are noncanonical; no permanent companion story.

Installed Mono editor reports missing .NET SDK `10.0.9` during editor import.
Import finishes with exit 0; this GDScript game and its headless check run cleanly.
No C# build is needed for this stage. Restricted automation can block normal
Godot cache/certificate access; final checks used normal local application access.

## Layout and ownership

- `game/app/game_root.tscn`: persistent root, WorldHost, Party, CameraRig, UI.
- `game/core/`: typed catalog manifest, definition base, atomic validation/indexes.
- `game/core/save_codec.gd`, `save_repository.gd`: strict versioned plain-data
  validation, detached candidate runs, checked temporary writes and good backup.
- `game/content/`: authored actor/location/dialogue/quest `.tres` definitions.
- `game/app/game_session.gd`: mutable time, location/spawn IDs, actor instances,
  independent quest states and completed effect IDs.
- `game/features/relationships/`, `progression/`: immutable authored outcomes and
  upgrade, separate mutable session states, once-only rule services. Root applies
  derived strike damage; journal/HUD display reactions and submit upgrade command.
- `game/tests/consequence_checks.gd`: alternative/replay protection, earned point,
  strict consequence data/legacy migrations, physical strike and separate-process save.
- `game/features/quests/`: ordered immutable steps, separate runtime progress,
  legal command/effect transactions and journal queries.
- `game/tests/quest_checks.gd`, `quest_process_checks.gd`: legality/idempotency,
  strict save progress/migration, root journal/travel/rebinding and OS-process
  persistence. Direct rule/guardian setup is explicitly synthetic test content.
- `game/app/world_host.gd`, `party.gd`: synchronous travel lock, actor suspension,
  scene/anchor validation, physics/navigation synchronization, safe placement,
  rollback and resume. Actor wrappers/state survive room replacement.
- `game/features/actors/`: authored health defaults, independent runtime state,
  physical hero wrapper receiving session state and supplied camera/UI controls;
  facing rotates VisualRoot only. Hero, companion and guardian use its movement, attack,
  dodge and damage APIs.
- `game/features/combat/`: node-independent transient CombatState rules, shared
  guardian wrapper with replaceable VisualRoot, injected approach/strike controller.
- `game/features/actors/companion_controller.gd`, `companion.tscn`: injected follow/
  fight/return, collision-derived navigation, safe recovery and persistent wrapper.
- `game/tests/companion_checks.gd`: physical obstacle/barrier fixtures, safe catch-up,
  incapacitation/recovery, combat assist, party restore and v1/v2 migration/rejection.
- `game/tests/combat_checks.gd`: windows, single hit, dodge, range/facing/LOS,
  pause, rollback, death/retry, durable defeat and save restore. Direct fixtures are
  rule/lifecycle checks; normal rendered combat is recorded separately.
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
P007 selectively adapts her missing customer fitting experience and familiar-counter
reconnection from source MQ03, without changing campaign order. Source `D:/development/game-prototype-2`
now contains source files (rechecked 2026-10-02); previous empty-checkout note was
stale. Consult relevant canon before story adaptation. Companion/greeting are labeled noncanonical
fixtures; purple stand-ins host dialogue in both rooms, separate from active ally
AI. Location/spawn IDs map to validated physical anchors.
Collision-derived navigation synchronizes on travel and supplies companion paths.

Exact check results: [P001 validation](docs/evidence/P001/VALIDATION.md),
[P002 validation](docs/evidence/P002/VALIDATION.md),
[P003 validation](docs/evidence/P003/VALIDATION.md),
[P004 validation](docs/evidence/P004/VALIDATION.md),
[P005 validation](docs/evidence/P005/VALIDATION.md),
[P006 validation](docs/evidence/P006/VALIDATION.md),
[P007 validation](docs/evidence/P007/VALIDATION.md),
[P008 validation](docs/evidence/P008/VALIDATION.md),
[P009 validation](docs/evidence/P009/VALIDATION.md),
[P010 validation](docs/evidence/P010/VALIDATION.md),
[P011 validation](docs/evidence/P011/VALIDATION.md),
[P012 validation](docs/evidence/P012/VALIDATION.md),
[P013 validation](docs/evidence/P013/VALIDATION.md).
Blender sources and reusable export workflow: [asset pipeline](art/exports/PIPELINE.md).
Imported guardian, recovery vessel and Tollworks plinth live under gameplay
VisualRoots; Godot retains collision/navigation/IDs. Focused checks:
`res://tests/asset_pipeline_checks.gd`; rendered inspection:
`res://tests/asset_gallery.gd` (windowed only).
Next eligible task: P014 (not started). Read
[current state](docs/CURRENT_STATE.md) before work.

## Remaining canon deviations

This slice starts directly at Maris's lead, skipping MQ00–MQ02 and the full fair
opening. A direct room gate replaces the Old Ford/Moonwood approach; one guardian
and one vessel shorten the Tollworks. The unnamed companion, trust dialogue,
lead-earned strike training and customer/helper stand-ins remain noncanonical
prototype content. The helper stands in for the authored Helena reconnection.
Maris retains `npc-03`, basic supplies remain available, and a practical fitting
restores specialist judgment. Service is a preview without purchases/inventory.
Salvage gear, Ivo's work scene, hull lift and onward Night Orchard leads remain
outside this slice; the ship and fair are not restored. No retired currency idea
was adopted. Reference: read-only source `docs/market-of-borrowed-days.md`, MQ03.
