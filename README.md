# Returning Fair prototype

Current feature work: [foraging, items and backpack migration](docs/foraging-items-backpack/CHECKLIST.md),
with [fresh-agent prompt](docs/foraging-items-backpack/AGENT_PROMPT.md).
F001/F002 Done; F003-F010 Pending. [Inventory rules acceptance](docs/foraging-items-backpack/F002_ACCEPTANCE.md)
verifies immutable item/resource content and session-owned20-slot/caps99/1 rules.
World pickups/backpack UI remain pending; schema5 saves retained.
[Pinned geometry findings](docs/foraging-items-backpack/F001_ACCEPTANCE.md) record
two blocked authored anchors for F005 repair.

Current work: [weather and lighting](docs/weather-lighting/CURRENT_STATE.md).
W001-W010 verified Done; no next item. Clock/seed/cached forecast rules run through
the existing session gate and schema v5 saves retain environment/light facts.
Moving sun and smooth day/dusk/navy-night/dawn lighting now apply outdoors;
Tollworks keeps its stable indoor profile while the global clock advances.
All23 exterior sources have independent lamp/window/waylight/net visuals and
bounded local illumination. Six lamps support persistent E switching.
Smooth clouds, fixed-world rain with terrain/roof exclusion and bounded lightning
now render from saved forecast/time and freeze on pause. Committed time/weather
HUD, lifecycle/rollback/teardown and isolated developer review controls are verified.
Measured weather performance and fresh Windows/native feature acceptance pass.
[W010 acceptance](docs/weather-lighting/W010_ACCEPTANCE.md) records package hashes,
ordinary recovery/lamp controls and exact GUI Save/restart/Load persistence.
Durable agent context lives in current state,
contracts,
checklists, source/tests and pinned references. Generated captures/logs under
`docs/evidence/` stay local and ignored; agents need them only for specific diagnosis.

Town/river/forest migration: [source investigation](docs/map-migration/INVESTIGATION.md),
[19 sequential tasks](docs/map-migration/CHECKLIST.md), and
[fresh-session agent prompt](docs/map-migration/AGENT_PROMPT.md).
M001-M019 complete; larger exterior and resulting Windows native release verified.
[Durable state](docs/map-migration/CURRENT_STATE.md) and
[current acceptance summary](docs/map-migration/CURRENT_STATE.md).
Original P014 compact release evidence remains historical; no next migration item.

P001–P014 complete. Full shortened recovery slice is playable from a fresh run.
One labeled temporary ally follows, routes around obstacles and assists combat.
Approach the purple companion station and press E for its optional trust choice.
Choose with mouse or Tab/Enter;
Finish/Close or Esc returns control. E at glowing gate travels to Tollworks/back.
Both rooms retain labeled prototype companion stations. Physical hero, mouse facing,
overhead follow, projection and zoom remain. Maris's counter is at Reed Chandlery
on Dock Row, southwest of town start;
accept her lead, walk east into Moonwood, cross bridge or sand ford and enter
Tollworks at the glowing forest gate. Read J journal. Defeat the protective guardian
with mouse clicks; Space dodges its gold windup/red strike. R retries after death.
Then inspect the southeast vessel, use Tollworks north return gate, walk west
through Moonwood to Reed Chandlery and reconnect at Maris's counter.
Read the returned experience, compare familiar gear and finish the practical fitting.
Cancellation keeps specialist service unavailable. Completion restores displayed
river gear and specialist service preview; basic supplies stay available. Both
variants survive travel and save/restart. Purchases remain outside recovery slice; foraging inventory workflow above adds separate rules.
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
& $godotExe --headless --path $gamePath --script res://tests/environment_rule_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/environment_session_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/environment_save_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/environment_lighting_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/weather_presentation_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/exterior_light_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/application_smoke.gd
& $godotExe --headless --path $gamePath --script res://tests/playable_slice_checks.gd
& $godotExe --headless --path $gamePath --script res://tests/extension_checks.gd
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
Esc → Settings opens the paused settings menu. Show FPS toggles a live counter
independently of Enable debug shortcuts. Both settings apply immediately for this
run, including while paused; Esc inside Settings returns to the pause menu first.
Launch with `& $godotExe --path $gamePath -- --debug-shortcuts` to start with debug
shortcuts enabled (also available in release builds). The Settings switch controls
that same mode and can turn it off again. With debug shortcuts on, F6 advances the
environment clock by exactly one game hour and refreshes lighting/weather. It
does not simulate an hour of combat or add to elapsed play time. The shortcut
ignores key repeats and is blocked during pause, dialogue, journal, travel,
loading, defeat/retry or window/GUI focus loss. Normal startup defaults both
settings off. Time skips change the clock facts included in ordinary run saves.
Header shows global time/weather, including indoors; hover for active play seconds.
For explicitly synthetic debug reviews, launch with
`--environment-review=<safe-name>`: an independent session starts paused, F7 cycles
day/dusk/night/dawn and F8 cycles weather. Review Save/Load is disabled, including
repository writes; restart without the flag for normal play. This controller is
excluded from release exports and does not complete native acceptance.
WASD moves relative to camera; mouse faces cyan ground marker. P switches between
orthographic (provisional default) and 45° perspective. Wheel or +/- zooms between
0.8 and 1.15 framing factors. Walls/plinth block movement; diagonals retain normal
speed. Pause/UI focus/window focus loss clears held controls; press movement keys
again after control returns. HUD pointer regions block aim/wheel zoom/attack.
Click starts one swing with windup, active and recovery windows; each target is
contacted once per swing, through range/facing and world-obstruction checks.
Space dodges in held movement direction, or current facing when stationary;
dodge lasts 0.30s and blocks damage. E selects nearest visible interaction; six dock lamps offer Turn on/Turn off with independent saved choices. Daytime on arms the lamp for dusk; manual off stays dark. Other exterior lights remain automatic;
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
boundaries: [architecture](docs/ARCHITECTURE.md). Schema v5/content v1 requires hero
and temporary companion records, validated reaction/trust and upgrade IDs,
environment day/progress/uint32 seed and map-qualified exterior light overrides.
Exact v1/v2 saves add fixture ally at full health; v1 starts with no quest effects.
Exact v3 preserves both members; v1-v3 start with neutral trust/no selected upgrades.
V4 retains existing trust/reactions/upgrades. V1-v4 use day 0/progress 0/fixed
migration seed and original light defaults while preserving elapsed play time.
Load does not rewrite files; explicit Save writes v5. Six lantern keys accept
boolean overrides; automatic sources and malformed/newer data are rejected.

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
- `game/features/items/`: immutable item/resource definitions, session-owned20-type
  inventory rules and detached sorted snapshots; no world/UI activation yet.
- `game/tests/inventory_checks.gd`: synthetic capacity/caps/rejection/selection and
  catalog/session/resource isolation acceptance; test-only extra types.
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

Exact check results: P001 validation (optional local archive),
P002 validation (optional local archive),
P003 validation (optional local archive),
P004 validation (optional local archive),
P005 validation (optional local archive),
P006 validation (optional local archive),
P007 validation (optional local archive),
P008 validation (optional local archive),
P009 validation (optional local archive),
P010 validation (optional local archive),
P011 validation (optional local archive),
P012 validation (optional local archive),
P013 validation (optional local archive).
Blender sources and reusable export workflow: [asset pipeline](art/exports/PIPELINE.md).
Imported guardian, recovery vessel and Tollworks plinth live under gameplay
VisualRoots; Godot retains collision/navigation/IDs. Focused checks:
`res://tests/asset_pipeline_checks.gd`; rendered inspection:
`res://tests/asset_gallery.gd` (windowed only).
No further item defined in the prototype checklist. Read
[current state](docs/CURRENT_STATE.md) before work.

## Local Windows exports (W010 verified)

`game/export_presets.cfg`: Windows Desktop (release, tests excluded) and Windows
Validation (debug, existing review/input test tools). Official standard 4.7.2 template executables
are extracted under ignored `builds/p014/templates`; pure GDScript needs no C#
runtime/SDK. Current package/version/hash records: [W010 acceptance](docs/weather-lighting/W010_ACCEPTANCE.md).
No system template install. From project root, using console executable above:

```powershell
& $godotExe --headless --path game --export-release 'Windows Desktop' ../builds/windows/ReturningFair.exe
& $godotExe --headless --path game --export-debug 'Windows Validation' ../builds/windows-validation/ReturningFairValidation.exe
```

Keep each `.exe` beside matching `.pck`. Run directly without editor or `--path game`.
Debug export completed normal slice and restored/revisited progress in new processes.
Native release full slice, GUI save/process restart/load, replay and room revisit
passed using project-local Windows SendInput holds; both normal quits exit0.
Fresh W010 release also passes independent lamps, genuine clock/weather progression,
exact environment/forecast/party/quest restoration and restored service revisit.
Raw W010 evidence remains optional local archive; P014/M019 packages and evidence
preserved. No build published.

Current local release directory contains `override.cfg`, isolating validation saves
under `%APPDATA%/ReturningFair-P014-ReleaseValidation/saves`. Keep it and set separate
APPDATA/LOCALAPPDATA for each validation session; W010 native tooling records and
verifies these paths. Normal slot stays untouched. File lives outside source/export tree.
Without override, release uses normal application directory; it ignores debug
`--save-slot`. Text-resource conversion is disabled after binary exports lost
packed spawn/dialogue arrays. Isolated extension fixture remains only under tests.

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

Shared agent testing: [bounded runner and evidence helpers](tools/skills/returning-fair-gameplay-testing/references/testing-tools.md).
PowerShell7 `./tools/run_checks.ps1 -Task W006 -Names light_interaction_checks,application_smoke`
preflights current scripts, isolates saves and retains diagnostics/timeouts.
[Tooling verification](docs/TESTING_TOOLS_ACCEPTANCE.md) covers deliberate failures,
exact restart, read-only environment observations and guarded native capture paths.
