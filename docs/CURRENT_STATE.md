# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P008.

## Current task

P008 complete. P009 next eligible, not started. Normal play: accept Maris's lead
at southwest Alderwake counter; north gate to Tollworks; defeat guardian; inspect
southeast vessel; return north and reconnect at counter. Shortened prototype
adaptation, not full campaign or P011 restored-service presentation.

WASD moves; mouse faces/click attacks; Space dodges; E interacts/travels; J journal;
Esc closes/pauses; R retries after death; F10 quits. Gold windup/red strike, cyan
dodge, white hit flash/body squash, health HUD and flattened nonblocking corpses.

## Implementation and changed files

Root D:/development/game-dev-blender/returning-fair-prototype; Godot project /game.
Git baseline b096c64, initially clean; no unrelated user changes. P008 source,
documentation and evidence committed locally at user request; no push/publication.
Source D:/development/game-prototype-2 untouched.
Applicable workspace AGENTS.md and caveman skill read; no subagents or Blender work.

- features/combat/combat_state.gd: node-independent transient attack windows,
  locked direction, one contact per target/swing, recovery, dodge protection and
  health clamp. Hero windup/active/recovery 0.18/0.14/0.30s; damage25/range2.2m;
  dodge0.30s at 10m/s. Actor definition Resources remain immutable.
- features/actors/actor_placeholder.gd: shared move/facing/attack/dodge/damage APIs,
  range/cone and world LOS checks; marker/visual feedback and per-wrapper material
  copy. Player input and guardian AI share rules; no damage authority in UI.
- features/combat/guardian_controller.gd, guardian.tscn (+ scene/script UIDs),
  content/actors/guardian.tres: 100-health prototype construct, approach at2m/s,
  5m engagement, stop/strike at1.65m; windup0.75/recovery0.85/range2m/damage25.
  Replaceable VisualRoot; collision/IDs remain Godot wrapper-owned.
- app/game_root.gd/.tscn: spawn eligible guardian after expedition; actual death
  callback submits stable source tollworks-guardian-01 to QuestService. R validates
  arrival placement before restoring hero health; quest facts retained. Failed
  travel preserves guardian references/health/targets. Combat modal/save guards.
- content/quests/maris_recovery.tres: actual guardian source/objective. Existing
  quest, step, action and effect IDs preserved. Catalog adds guardian definition
  and removes old simulation dialogue (count stays12); guardian_test.tres deleted;
  --quest-test-fixtures no longer creates anything.
- project.godot/UI: R input, attack/dodge instructions, health/action/death feedback,
  combat pause permits Resume while Save/Load disabled. HUD spacing/modal layering
  repaired from actual captures; combat hints replace unavailable interactions.
- tests/combat_checks.gd (+UID): rules, physical hits/LOS, pause, failed-travel
  rollback, death/retry, clearance/retry once-only and save restore. P006 test waits
  for real swing recovery; quest process writer now uses labeled synthetic physical
  defeat instead of changing quest facts while leaving a living guardian.
- tests/live_playtest_bridge.gd: SPACE/R input; read-only attack/dodge/guardian/
  screen observations. Still no health/quest/defeat/state mutation commands.
- README, tools/PLAYTEST.md, ARCHITECTURE, CHECKLIST and evidence/P008 updated.

## Checks and evidence

Engine 4.7.2.stable.mono.official.ed1daf0bf; both installed paths verified.
MCP get_project_info also resolved /game and matching engine version. Commands,
acceptance mapping, repaired failures, logs and inspected PNG/JSON:
docs/evidence/P008/VALIDATION.md. Commands from project root:

```powershell
$taskEngine = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $taskEngine --headless --path game --editor --quit
foreach ($check in @('application_smoke','content_catalog_checks','movement_camera_checks','live_playtest_checks','location_travel_checks','save_checks','interaction_dialogue_checks','quest_checks','combat_checks')) {
    & $taskEngine --headless --path game --script "res://tests/$check.gd"
}
foreach ($check in @('save_process_checks','quest_process_checks')) {
    foreach ($phase in @('write','read')) {
        & $taskEngine --headless --path game --script "res://tests/$check.gd" -- "--phase=$phase"
    }
}
git diff --check
```

- Final import exit0, nine checks PASS/exit0; save writer/reader PASS/exit0;
  repaired and verified quest writer/reader PASS/exit0. Existing unused Mono SDK
  10.0.9 warning only; GDScript runtime logs clean. No installation needed.
- Normal Windows renderer, RTX4070 Laptop/driver581.29, 960x640: WASD/E/GUI lead,
  expedition, guardian pursuit/strike, death, R retry and four actual clicks kill
  guardian100->75->50->25->0. Effects2->3 exactly once. Final hero health50.
- Dodge-contact JSON: hero health75 unchanged while dodge0.05/0.03s remaining;
  guardian active at0.83/0.85s consumed party-player contact. Cyan/gold/red rings
  inspected. Combat pause freezes action/damage; Save/Load disabled, GUI Resume works.
- GUI Save, F10 quit0, new process GUI Load restored cleared guardian/hero50/effects3;
  room round trip retained3; normal vessel advanced4. Final vessel Save/restart
  restored4 at Tollworks arrival. Five windowed runs quit0; final retry run log is clean.
- Initial sandbox blocked isolated test IO; normal-access reruns pass. Initial
  low-prop attack ray missed plinth: lowered LOS query and rechecked. Old P006
  fixtures attempted new interactions during attack recovery: fixed test timing.
  Old process writer changed quest fact without physical defeat: now synthetic
  damage goes through actor callback; writer and reader rerun together, both pass.
- Final scan caught four bridge null-collider errors in run c after retry freed
  guardian; guarded cached collision references in bridge/actor trace. Run e repeats
  normal death/R/four-click victory, exit0 and clean log; affected smoke/movement/
  bridge/combat checks rerun PASS. Git trailing EOF blank lines trimmed, check exit0.

## Decisions, limitations, blockers

No P008 blocker. Schema2/content1 unchanged: existing tollworks-guardian-cleared
quest effect is sole durable instance fact. Prior P007 simulated completion saves
remain compatible and show defeated guardian; no reward replay or silent ID rewrite.
Partial guardian health/actions reset on travel/retry/load; hero health persists.
Save/load only with living hero outside attack/dodge and living guardian engagement;
no mid-fight snapshots. R restores health after safe placement, keeps quest facts.

Combat timing/difficulty provisional; guardian uses direct pursuit and can be
blocked by props. Navigation recovery/active companion is P009. Reconnection stays
text checkpoint until P011. No trust/upgrades, Blender art or Windows export claim.
Viewport-injected normal input verifies actual game integration/rendering; hardware
bindings/OS focus for new controls not separately verified. Normal save untouched;
only isolated test/playtest slots used. No new permanent narrative decision.

## Next eligible task

P009 only: active companion follow/fight/return, navigation recovery/catch-up,
shared actor combat API, travel lifecycle and required persistence. Read architecture
and checklist, verify P008 before starting. P009 deliberately not begun this session.
