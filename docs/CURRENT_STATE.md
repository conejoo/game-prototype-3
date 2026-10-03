# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P009.

## Current task

P009 complete. P010 next eligible, not started. Normal start includes one active,
explicitly noncanonical temporary companion. It follows, navigates obstacles,
assists guardian combat, returns to hero, and safely recovers/catches up.
Maris's shortened recovery loop remains playable; restored shop presentation P011.

WASD moves; mouse faces/click attacks; Space dodges; E interacts/travels; J journal;
Esc closes/pauses; R retries after hero death; F10 quits. Stationary purple NPCs
are labeled dialogue stand-ins; blue-violet actor is the active party companion.

## Implementation and changed files

Root D:/development/game-dev-blender/returning-fair-prototype; Godot project /game.
Initial Git worktree contained P008 changes against b096c64. HEAD advanced externally
to 08420ce (P008) during this session; preserved that baseline and all existing work.
This session performed no Git commit/push/publication, source-project edits,
subagents, Blender work or installation. Workspace AGENTS.md/caveman skill read;
computer-use skill used only to restore actual game window focus.

- app/game_session.gd: ordered party-player / party-companion states, existing
  prototype-companion immutable definition; session owns both mutable health values.
- features/actors/companion_controller.gd/.uid, companion.tscn (embedded UID):
  transient follow/fight/return paths and safe catch-up/recovery. Reuses existing
  ActorPlaceholder APIs/VisualRoot; 4.4m/s, damage10, swing0.35/0.14/0.6s. Hero/ally
  do not block each other. No actor rules duplicated or new generic AI abstraction.
- world/prototype_location.gd, app/world_host.gd: location-owned NavigationRegion3D
  baked from static gameplay collision before placement/server synchronization;
  radius0.4, height1.6, climb0.1. Old regions leave with room; rollback reactivates.
- app/game_root.gd: persistent ally composition, AI/target suspension, restore
  rebinding, party save/modal gates, both members healed only after safe R retry.
  features/combat/guardian_controller.gd: nearest living party target; locked swings
  unchanged. Existing real defeat callback/once-only quest effects remain authority.
- core/save_codec.gd: schema3/content1, exact two-member identity/health validation;
  exact v1/v2 single-hero migration deliberately adds fixture ally at full health.
  v1 adds empty quest state; v2 retains progress. Reads do not alter caller/disk.
- ui/prototype_ui.gd/.tscn, features/interaction/npc_interaction.tscn: ally health/
  mode/down-state in footer; stationary fixtures labeled dialogue stand-ins. Footer
  repaired after first render overlapped ally HUD with gate label. P009/hints updated.
- tests/companion_checks.gd/.uid: both obstacle routes, physical blocked-route
  catch-up, separation, safe floor/capsule placement, down/recovery, combat/leash,
  migration/rejection, restore and party retry. Optional windowed fixture captures.
- Existing smoke/travel/save/dialogue/quest/combat/process tests: two-member counts,
  distinctive persisted ally health43, both wrapper identities through rollback/
  ten trips, future-version constants, exact legacy fixture, isolated hero hit tests.
- tests/live_playtest_bridge.gd: read-only ally path/combat/health/counters/identity,
  actual focus and retry lock. Input only; no state/teleport/objective mutation.
- README, tools/PLAYTEST.md, ARCHITECTURE, CHECKLIST and evidence/P009 updated.

## Checks and evidence

Engine 4.7.2.stable.mono.official.ed1daf0bf; both installed paths verified.
No Godot MCP capability exposed this session; used installed console executable.
Exact commands, acceptance map, repaired failures, logs, input trace and inspected
PNGs/JSON: docs/evidence/P009/VALIDATION.md. Commands from project root:

```powershell
$taskEngine = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $taskEngine --headless --path game --editor --quit
foreach ($check in @('application_smoke','content_catalog_checks','movement_camera_checks','live_playtest_checks','location_travel_checks','save_checks','interaction_dialogue_checks','quest_checks','combat_checks','companion_checks')) {
    & $taskEngine --headless --path game --script "res://tests/$check.gd"
}
foreach ($check in @('save_process_checks','quest_process_checks')) {
    foreach ($phase in @('write','read')) {
        & $taskEngine --headless --path game --script "res://tests/$check.gd" -- "--phase=$phase"
    }
}
& $taskEngine --path game --resolution 960x640 --script res://tests/companion_checks.gd
git diff --check
```

- Final import exit0; ten scripts PASS/exit0 across first/final runs; runtime error
  scan clean. Separate save and quest writer/readers PASS/exit0. Final affected
  nine rerun after HUD/retry repairs. Existing editor-only unused Mono SDK10.0.9
  warning remains; no GDScript installation dependency. Scene UID assignment exit0.
- Windows Compatibility renderer RTX4070 Laptop/driver581.29, 960x640: normal
  WASD/E/GUI follows in both rooms around plinth, zero catch-ups; same ally wrapper.
  Lead/expedition normal input; autonomous ally deals60 guardian damage without hero
  attacks, becomes downed; actual hero clicks clear guardian once, effects2->3.
  Ally recovers0->100 after3s. GUI Save/restart/Load restores hero50/ally100, two
  members, clearance3, arrival anchor and empty route. Post-load round trip and
  obstacle follow preserve state. Final windowed run b quits normally, exit0.
- Windowed physical test-only barrier blocks ally on stale route; verified safe
  catch-up to hero side, no world overlap. Down/recovery renders inspected. Fixture
  run PASS/exit0; it is not evidence of normal objective completion.
- Initial prerequisite save IO denied in sandbox; normal-access rerun PASS. First
  smoke exposed typed-Array assignment despite exit0/PASS: repaired, error scan now
  clean. Rounded nav radius warning removed. First normal fight attempts missed
  timing; later genuine window focus loss disabled input. Restored real focus with
  computer-use, repeated normal clicks/recovery/save successfully. Failed captures
  prefixed failed-. No focus bypass or game-state mutation was added.

## Decisions, limitations, blockers

No P009 blocker. Follow1.6m; combat leash6m; paths refreshed0.4s. Stalled2.5s or
separated8m can catch up only outside living enemy threat. Candidate requires nav,
level floor, full capsule/actor clearance and LOS to hero. No safe point means no
placement/healing. Downed ally recovers after3s outside threat with living hero;
R heals both only after safe placement. Health (including zero) persists; all
route/action/recovery timers are transient. Saves lock on either actor's action
or enemy threat; no mid-fight snapshot, recruitment, commands or trust yet.

Runtime navigation baking suits these tiny static rooms; future large levels may
pre-bake. Safe catch-up is a deliberate prototype fallback, not seamless large-world
navigation. Guardian direct pursuit/timing and all art remain provisional.
Companion identity/dialogue noncanonical. No retired currency ideas revived.
Normal save slot untouched; only isolated test/playtest slots used. Viewport input
verifies normal game integration/rendering; hardware control mappings are not newly
claimed. No Blender assets or tested Windows export; P010/P011/P012 remain pending.

## Next eligible task

P010 only: authored prototype companion reaction/trust and earned selectable
combat upgrade, with once-only transactions and deliberate save compatibility.
Read architecture/checklist and verify P009 first. Not started this session.
