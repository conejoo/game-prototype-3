# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P006.

## Current task

P006 complete; P007 next eligible, not started. Normal start: Alderwake. WASD
moves, mouse faces, E selects nearest visible purple companion/gold marker/gate.
NPC talk and prop inspection work in both rooms; mouse or Tab/Enter chooses,
Finish/Close/Esc returns control. Esc pauses only after dialogue closes.
Pause Save/Load restores last arrival anchor; no autosave. No combat, quest,
active companion AI or Blender assets yet.

## Implementation and changed files

Root: D:/development/game-dev-blender/returning-fair-prototype; Godot path /game.
Git baseline c953ce8 (P005), initially clean; P006 source, documentation and
evidence recorded in local Git at user request. No unrelated change found.
Source project read-only, no push/publication.

- game/features/interaction/: PrototypeInteractable wrapper IDs/kind/prompt/reach/
  dialogue ID, NPC/prop reusable scenes, replaceable VisualRoot and wrapper-owned
  collision. InteractionSelector chooses nearest in-range LOS target, ID tie order.
- game/features/dialogue/: authored DialogueChoice and extended DialogueDefinition;
  transient node-independent DialogueService separates cursor/source/choice/result
  from definitions. Explicit ActionResult returns ok/message/action ID; malformed,
  duplicate/unknown/out-of-order/repeated choices fail. Intro then terminal choice
  response is sufficient for P006; no general graph engine.
- game/content/dialogue/temporary_companion.tres, practice_marker.tres and
  prototype_catalog.tres: two choices each, eight catalog definitions. All temporary,
  noncanonical/presentation-only. No NPC facts, quest rewards or trust changes.
- game/app/game_root.gd: same selector routes E to talk/inspect or existing WorldHost
  travel. Reselects on command; clears held movement, disables actor input, blocks
  world keys/mouse during dialogue, keeps GUI usable. Esc cancels before pause;
  pause cannot stack. Unload cancels dialogue/stale target; save/load rejects active
  dialogue even if forced paused. Root owns orchestration; UI owns no rules.
- game/ui/prototype_ui.gd/.tscn: dialogue modal/choices, typed command signals and
  results, focus release, no world prompt under modals; readable P006 controls.
- game/world/prototype_location.gd, alderwake.tscn, tollworks.tscn: validate interaction
  IDs/references; NPC at (-2,0,0), prop at (2,0,1), distinct room instance IDs; gate
  retains 1.6m reach. Enlarged fixture signs; redundant clipping room signs removed,
  room identity remains in HUD. Existing spawn safety, floor/walls/plinth preserved.
- game/tests/interaction_dialogue_checks.gd: meaningful rules/lifecycle/input checks.
  content_catalog_checks expects eight definitions; save_checks expects new prompt.
  New script .uid and scene UIDs retained.
- game/tests/live_playtest_bridge.gd, tools/send_playtest.ps1, PLAYTEST.md: read-only
  interaction/dialogue observations. One transient request read failure rejected
  before input; client now publishes via native File.Move, bridge checks open/read
  before deletion. Rechecked protocol and actual windowed reader.
- README, CHECKLIST, architecture delivered-boundary note and P006 evidence updated.
  Ownership architecture unchanged; transient/save-boundary decisions documented.

## Checks and evidence

Engine 4.7.2.stable.mono.official.ed1daf0bf. Exact commands/exits, acceptance
mapping and selected inspected PNGs: evidence/P006/VALIDATION.md.

- Prerequisites P001–P004 PASS/exit0; initial restricted save test hit denied
  user:// IO and was interrupted. Normal-access isolated save rerun PASS/exit0.
- Final headless editor import, including last scene/UID changes: exit0. Existing
  unused Mono SDK10.0.9 error only; no GDScript errors. No dependencies installed.
- Seven headless scripts PASS/exit0: application_smoke, content_catalog_checks,
  movement_camera_checks, live_playtest_checks, location_travel_checks, save_checks,
  interaction_dialogue_checks. Separate process write/read PASS/exit0. Relevant
  smoke/save/dialogue/bridge checks repeated after UI/reader repairs PASS/exit0.
- P006 tests: rejected actions/choices, independent runtime state/multiline intro,
  both-room normal viewport E + GUI Enter, held movement clearing, attack-input
  probe, camera/reentry lock, cancel/fresh movement, save boundary, LOS and unload.
  Positioned fixtures prove rules, not ordinary play; actual rendered walk separate.
- Windows Compatibility renderer, RTX4070 Laptop/driver581.29, 960x640: normal
  WASD/E reaches both-room NPC/prop, all four choices via keyboard/mouse, Esc/Close/
  Finish, blocked movement/click, held keys remain cleared after cancel, fresh input
  works. Normal gate travel, GUI Save/Load and replayed NPC after load pass.
  assert-live.ps1 PASS/exit0; full reviewed replay boot 1790976207.97-7732.
- Final layout boot 1790976462.745-67352: both rooms load/visible signs and modal
  inspected; E travel/talk and F10 quit while dialogue active exit0. Five windowed
  runs all quit0. Reader/labels logs and focused final logs have no runtime errors.
  Reviewed log retains one pre-repair harness empty-read rejection, safely retried;
  no gameplay input executed on that rejected request.
- git diff --check exit0. See git-check.txt, check-results.txt and raw response files.

## Decisions, limitations, blockers

No blocker. Save schema/content stay v1: only additive presentation definitions,
no persistent fields. Dialogue is transient and cannot be saved mid-conversation;
P007 must deliberately migrate v1 before adding quest/effect data. Future persistent
dialogue actions route through quest/relationship owners with durable once-only IDs.

Attack/dodge remain bindings only; input blocking is tested, damage/combat is P008.
Temporary companion is stationary dialogue stand-in, not P009 active party member.
No permanent narrative decision made. Source game is now populated: game-story.txt,
docs/market-of-borrowed-days.md and docs/towns/alderwake.md read; older empty-source
handoffs stale. Maris npc-03 remains unchanged; no Flutter runtime port or retired
currency ideas. No Blender source/export or Windows build claim.

Rendered input uses ordinary viewport InputMap/GUI, not physical keyboard/OS focus.
Normal user save untouched; playtest-p006-* and existing isolated p005-check/process
fixtures only. Existing Mono SDK warning nonblocking for GDScript.

## Next eligible task

P007 only: one shortened recovery quest, legal prerequisite transitions, journal,
stable action/effect IDs and durable once-only effects. Extend/migrate schema v1
deliberately and prove progress across travel/process restart. Combat objective
may use clearly labeled test setup until P008; do not claim normal combat.
