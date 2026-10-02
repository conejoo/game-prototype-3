# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P004.

## Current task

P004 complete. P005 next eligible, not started. Normal start loads labeled
Alderwake graybox; WASD moves, E near glowing gate travels to Tollworks and back.
Mouse facing, overhead camera/projection/zoom, pause/resume/quit remain runnable.
No saves, combat, runtime dialogue, active companion or Blender assets yet.

## Implementation and changed files

Root: `D:/development/game-dev-blender/returning-fair-prototype`; Godot path `/game`.
Baseline confirmed local P003 commit `77aed4b`. Initial staged snapshot cleared
externally during inspection; no preexisting changes remained before P004 edits.
Existing source/UIDs preserved. P004 source, documentation and evidence recorded
in local Git at user request. No push or publication.

- `game/app/world_host.gd`: explicit catalog/session/party injection; validates
  scene IDs, physical anchors and gate references before taking synchronous lock.
  Suspends Party, detaches old room, adds hidden candidate, waits for physics,
  refreshes navigation map, checks floor/capsule clearance, places party, then
  commits session location/spawn and releases old scene. Unsafe placement restores
  exact old scene/position/session and controls. Signals report completion.
- `game/app/party.gd`: persistent wrappers; suspend clears input/velocity/contact
  state and stops actor processing. Stable anchor placement resets interpolation
  and visual heading. Session still owns authoritative ActorState/health.
- `game/app/game_root.gd`, `.tscn`: default Alderwake start; composes new owners,
  awaits initial load; arbitrates nearby E, transition/pause/focus controls,
  camera target refresh and UI. Session time freezes during transition.
- `game/world/prototype_location.gd`, `spawn_anchor.gd`, `alderwake.tscn`,
  `tollworks.tscn`, `game/content/locations/*.tres`, catalog: two compact rooms,
  signs, props, floor/wall collision, explicit stable IDs/start/return anchors.
  Arrivals at (0,0,-2.5); gate at (0,0,-5), range1.6m. Test-room fixture retained
  and receives compatible anchor/base; its original geometry/UID remains.
  New scene headers and script .uid files retain Godot-generated identities;
  scene-uids.log records IDs, followed by passing travel metadata recheck.
- `game/ui/prototype_ui.*`: location label, travel/loading prompt, E instructions.
- `game/tests/location_travel_checks.gd`, `fixtures/unsafe_location.tscn`: ten
  round trips and rejection/rollback tests; unsafe content stays test-only.
  Earlier smoke/movement/bridge tests explicitly select original room and await
  loader; catalog tests accept seven production definitions.
- `game/tests/live_playtest_bridge.gd`, `tools/PLAYTEST.md`: E support and read-only
  location/transition/actor/health/count observations; no direct world mutation.
- README/checklist/current state and `docs/evidence/P004/` updated. Existing
  ARCHITECTURE contract retained; no deliberate design change required.

## Checks and evidence

Installed console engine: `4.7.2.stable.mono.official.ed1daf0bf`, --version exit0.
Exact commands/exits, acceptance mapping: `evidence/P004/VALIDATION.md`.

- Final editor import exit0; no GDScript errors. Existing unused C# SDK10.0.9 error.
- Final application smoke, catalog, movement/camera, bridge and location travel
  checks all PASS/exit0. Ten complete headless round trips: same actor/state,
  health37/time retained, one room/party/session actor, grounded arrivals, old
  scenes released. Invalid IDs/physical anchors/gates and unsafe floor/obstruction
  reject; rollback preserves old scene. Reentry/held-key/pause/focus locks pass.
- Actual Windows Compatibility renderer, RTX4070 Laptop/driver581.29: four normal
  WASD/E round trips in first run, one final round trip after sign-size repair.
  Captures inspected: both rooms, gate prompt, safe return, held-key clearing,
  pause rejecting E. No teleport/debug objective. Both F10 shutdowns exit0;
  readiness files removed. JSON evidence assertions exit0; runtime error scan
  finds no errors; final Git diff --check exit0.

## Decisions, repairs and limits

- Party wrappers survive travel; only room is replaced. Stable IDs are explicit
  metadata, not node paths/names. Session IDs publish after physical placement.
- Initial candidate PROCESS_MODE_DISABLED removed its static collision bodies,
  so floor check failed. Disable room logic only during validation; rechecked
  prior physics/pause behavior and unsafe-spawn rollback.
- Navigation map synchronized after removal/load and rollback. No navigation
  regions/agents or companion cached paths exist yet; AI/path reset comes P009.
- P003 physical-keyboard evidence retained. P004 rendered inputs use existing
  opt-in viewport harness; this verifies normal gameplay integration, not hardware
  input/OS focus or exported build. Headless health37 is labeled test setup only.
- Rooms/gates deliberately compress geography and remain prototype fixtures.
  Read source town/story excerpts read-only; no canonical character/plot decisions,
  retired currency ideas, source runtime port, source edits or permanent dialogue.
- Initial restricted Godot runs hit normal log/cache/certificate access limits;
  final checks used approved normal application access. Bundled Python found via
  workspace-dependency tool after `python` was absent from PATH. No installation.
- No push/publication/Windows export. No P005 work started; disk persistence absent.

## Next eligible task

P005 only: versioned plain-data saves in user://, validation before live-session
replacement, checked temporary write/backup recovery, player/location/party state,
compatibility rules and process restart evidence. Read architecture/checklist,
inspect actual Git state, rerun focused prerequisites. Do not start P006.
