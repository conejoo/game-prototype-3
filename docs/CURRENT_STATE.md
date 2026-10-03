# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P010.

## Current task

P010 complete. P011 next eligible, not started. Normal play includes temporary
active companion, once-only prototype trust decision, lead-earned preparation
point and selectable Deliberate Strike. Maris recovery remains shortened/labeled;
practical return/shop presentation belongs to P011.

WASD moves; mouse faces/click attacks; Space dodges; E talks/travels; J journal;
Esc closes/pauses; R retries after death; F10 quits. Stationary purple stand-ins
host dialogue for noncanonical companion. Select +1 shared plan or -1 orders once.
Accept Maris lead, open J, select upgrade; strike damage changes 25→40. Scroll
journal to read saved reaction. Trust does not gate story or romance.

## Implementation and changed files

Root D:/development/game-dev-blender/returning-fair-prototype; Godot project /game.
Initial Git status clean (P009 already committed); preserved baseline. No source
project edits, subagents, Blender work, installations, commit/push/publication.
Workspace AGENTS/caveman skill read. Godot MCP get_project_info confirmed version/
project; installed console executable ran checks. Computer-use skill read as
possible focus fallback; no desktop automation needed or performed.

- features/relationships/: immutable ReactionDefinition, independent RelationshipState
  and RelationshipService. Stable decision alternatives prototype-shared-plan /
  prototype-orders; +1/-1 trust and reaction ID commit before signal. Same replay
  succeeds unchanged; alternate fails. content/relationships/ contains fixtures.
- features/progression/: immutable UpgradeDefinition, independent ProgressionState
  and ProgressionService. prototype-deliberate-strike adds15; earned by existing
  maris-lead-accepted effect. Unspent point = earned lead1 minus selected ID count.
  No stored point/currency or duplicate quest reward/effect. content/progression/ fixture.
- app/game_session.gd owns both states. app/game_root.gd composes/rebinds owners,
  validates live dialogue source/action and stable journal upgrade mode, derives
  wrapper damage on select/restore. Existing combat/companion APIs unchanged.
- dialogue choice/service, content/dialogue/temporary_companion.tres and catalog:
  authored reaction command injection/references; validate companion/effect IDs.
  Existing observation/leave choices retained; stale stand-in response repaired.
- core/save_codec.gd: schema4/content1 strict relationship/progression plain data;
  exact v1/v2 single-hero and v3 two-member migrations preserve prior facts, neutral
  trust/no selection. Existing accepted lead exposes unspent point. No disk rewrite
  on Read. Unknown/duplicate/conflicting/unearned/inconsistent data rejects candidate.
- ui/prototype_ui.gd/.tscn: Trust/damage HUD, journal upgrade command/state and bounded
  scroll. Modal/input/save/focus rules preserved. Root remains gameplay authority.
- tests/consequence_checks.gd/.uid: authored reference failures, positive/negative
  once-only transactions, point/replay protection, v4 rejection and exact migration,
  actual physical40 damage and separate-process negative trust/upgraded restore.
  Existing catalog/companion/quest tests adapted for15 definitions/current schema.
- tests/live_playtest_bridge.gd: read-only trust/upgrade/points/damage/button geometry;
  ordinary viewport input only, no state mutation commands. README, PLAYTEST,
  ARCHITECTURE, CHECKLIST and docs/evidence/P010 updated; script UIDs retained.

## Checks and evidence

Engine 4.7.2.stable.mono.official.ed1daf0bf; both installed paths verified.
Exact commands/results/acceptance mapping: docs/evidence/P010/VALIDATION.md.

- P009 prerequisite companion check PASS/exit0 with normal isolated user:// access.
  Initial restricted run failed save IO; no prerequisite behavior regression.
- Import exit0; existing unused Mono SDK10.0.9 warning only after wiring repairs.
- Eleven scripts PASS/exit0: application_smoke, content_catalog_checks,
  movement_camera_checks, live_playtest_checks, location_travel_checks, save_checks,
  interaction_dialogue_checks, quest_checks, combat_checks, companion_checks,
  consequence_checks. Six affected scripts rerun after UI/validator repairs PASS0.
- Separate save_process_checks, quest_process_checks, consequence_checks write/read:
  all six processes PASS0. Consequence reader restores Trust-1/damage40 and rejects
  conflicting outcome/repeated spending. Runtime SCRIPT ERROR/ERROR scan clean.
- Windows Compatibility renderer, RTX4070 Laptop, 960x640: normal WASD/E/GUI positive
  reaction0→1/replay1, fresh negative0→-1, accepted lead earns1, journal selection
  point1→0/strike25→40. Ally assists; actual hero swing kills guardian40→0.
  GUI Save/restart/Load restores Trust1/strike40/points0/clearance3. Alternative fails,
  spent button disabled, recorded reaction readable via scroll; normal room round
  trip retains facts. Three windowed processes quit0; error files empty.
- 128 exact command/response traces in live-trace.json; selected captured PNGs/JSON
  inspected. Initial idle fight died; labeled failed-idle-fight evidence superseded
  by continuous-input retry. git diff --check exit0.

## Decisions, limitations, blockers

No P010 blocker. Preparation point/trust dialogue explicitly provisional and
noncanonical. Trust consequence is recorded reaction plus visible score, no
behavior multiplier, affinity story gate or romance. Point available before first
fight allows normal upgrade evidence; existing quest reward authority retained.
Old saves with accepted lead may choose upgrade once; no auto-selection.

Journal initial overflow repaired with250px scroll. Python helper initially used
Windows default encoding and lacked PATH Python; bundled runtime/explicit UTF-8
fixed affected text/wiring before final checks. No tool/runtime installation.

Prior limits remain: tiny-room runtime navigation, safe companion catch-up outside
combat, transient unfinished guardian actions/health, arrival-anchor stable saves,
provisional art/difficulty. Viewport input proves normal gameplay integration, no
new hardware/OS focus claim. Normal save slot/source untouched. No Blender assets
or tested Windows export. No P011 work started.

## Next eligible task

P011 only — Recovery and persistent world presentation. Implement Maris return/
reconnection and restored specialist shop variant from authoritative quest/world
facts. Verify recovered versus unrecovered saves and travel/reload; add camera
occluder handling only where layout requires it. Read docs and verify P010 first.
