# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P007.

## Current task

P007 complete. P008 next eligible, not started. Normal start: Alderwake; WASD,
mouse facing, E interaction/travel, J journal, Esc close/pause, F10 quit. Accept
Maris's lead at southwest prototype counter, travel north to Tollworks. Normal
play stops at guardian objective; actual combat remains P008. Pause Save/Load
persists quest/effects and returns to last arrival anchor; no autosave.

For downstream P007 checks only, debug --quest-test-fixtures adds labeled TEST
ONLY clearance prop in southwest Tollworks. E/choice explicitly simulates the
objective through quest rules. Then recover southeast vessel, return north to
Alderwake, and choose reconnection at Maris's counter. Six stable completion/effect
IDs persist. Full return scene/shop presentation remains P011.

## Implementation and changed files

Root: D:/development/game-dev-blender/returning-fair-prototype; Godot project /game.
Git baseline 544f505 (P006), initially clean; no unrelated user changes found.
P007 source, documentation and evidence committed locally at user request.
Source D:/development/game-prototype-2 read-only;
no push/publication. Applicable workspace AGENTS.md/caveman skill read.

- game/features/quests/: immutable QuestDefinition/QuestStep Resources, independent
  QuestState, node-independent QuestService. Previous ordered step is prerequisite;
  location/source/action validation precedes atomic step/effect commit. Retry returns
  success without granting/notifying twice. Effects are durable facts, not currency.
- game/content/quests/maris_recovery.tres and dialogue/maris_counter.tres,
  recovery_vessel.tres, guardian_test.tres; catalog now 12 definitions. Stable Maris
  npc-03. Shortened labeled adaptation from source MQ03's missing fitting judgment,
  vessel identification/return path and familiar-counter reconnection. No campaign
  reorder, runtime port, retired currencies or permanent companion/story invention.
- game/app/game_session.gd owns quest states/effects; core/content_catalog.gd
  validates quest steps/references/global effect uniqueness and dialogue quest/action.
- core/save_codec.gd: schema2/content1 exact quest set, ordered completion prefixes,
  matching unique effects. Exact schema1/content1 migrates to unstarted quest/no
  effects while preserving validated old facts. Copies candidate; read leaves files
  unchanged. core/save_repository.gd carries migration notice; explicit Save writes2.
- features/dialogue/dialogue_choice.gd/service.gd: authored quest/action IDs,
  injected owner command. Rejected choices preserve cursor and show prerequisite
  message; practice/temporary companion remain presentation-only.
- app/game_root.gd: composition/service injection, eligible successful-travel arrival
  events, service rebind after safe restore, no arrival replay on load; debug fixture
  opt-in only. Journal input/save arbitration; no world/UI quest authority.
- ui/prototype_ui.gd/.tscn, project.godot: J/header journal, objective HUD, modal
  Close/J/Esc with held-input clearing and contained Tab focus. Pause copy includes
  quest/effects. world/alderwake.tscn/tollworks.tscn add replaceable gameplay wrappers
  at (-4,0,3)/(4,0,3); base P006 fixtures preserved.
- tests/quest_checks.gd/quest_process_checks.gd (+ UIDs): rules, migration/files,
  journal/root lifecycle and separate-process persistence. Existing catalog count,
  future-schema tests and P006 fixture-presence check adjusted. live_playtest_bridge
  adds J and read-only quest/journal observations; still no state/objective commands.
- README, ARCHITECTURE delivered P007 boundary, CHECKLIST, tools/PLAYTEST.md and
  docs/evidence/P007 updated. Ownership architecture unchanged; ordered-step and
  strict migration choices documented. All new script UIDs retained.

## Checks and evidence

Engine 4.7.2.stable.mono.official.ed1daf0bf. Both provided executable paths verified.
Exact commands, per-command exits, repaired failure, logs and inspected PNG/JSON:
docs/evidence/P007/VALIDATION.md and check-results.txt. Commands from project root:

```powershell
$taskEngine = 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe'
& $taskEngine --headless --path game --editor --quit
foreach ($check in @('application_smoke','content_catalog_checks','movement_camera_checks','live_playtest_checks','location_travel_checks','save_checks','interaction_dialogue_checks','quest_checks')) {
    & $taskEngine --headless --path game --script "res://tests/$check.gd"
}
foreach ($check in @('save_process_checks','quest_process_checks')) {
    foreach ($phase in @('write','read')) {
        & $taskEngine --headless --path game --script "res://tests/$check.gd" -- "--phase=$phase"
    }
}
git diff --check
```

- Prerequisites and final eight focused scripts PASS/exit0; both writer/reader pairs
  PASS/exit0. After final UI/content edits, affected six scripts + quest writer/reader
  repeated PASS/exit0. Final normal-access editor import exit0, no GDScript errors;
  existing unused Mono SDK10.0.9 warning only. No installations.
- Initial sandbox denied isolated user:// save IO; interrupted old test exit1, normal
  access rerun passed. Initial new prop placement interfered with P006 tests; moved
  new wrappers apart, updated fixed prop-count assumption, rechecked PASS/exit0.
  HUD overlap repaired; explicit modal focus loops fix Tab reaching background UI.
- Rule checks cover out-of-order/unknown/wrong-source/location actions, atomic
  notifications, repeat/decode replay idempotency, independent mutable state,
  malformed quest/effect save rejection, exact v1 migration and unchanged read bytes.
- Actual Windows Compatibility renderer, RTX4070 Laptop/driver581.29, 960x640:
  normal WASD/E/GUI reaches lead, travel, vessel and reconnection. Guardian action
  is explicitly simulated test fixture. Journal blocks held movement/E/click,
  Esc clears holds, fresh movement works; Tab remains modal. Vessel/reconnect
  retries retain effect count. GUI Save/quit/new-process Load tested at vessel and
  completed state; counts4/6 and correct rooms/anchors restored. No-flag normal
  Tollworks has no test prop. Four windowed runs quit via F10 exit0, logs clean.
- git diff --check exit0; source files/evidence paths recorded. Normal user save
  untouched; isolated playtest-p007-validation and p007-migration/root/process files
  only, alongside prior test-specific slots.

## Decisions, limitations, blockers

No P007 blocker. Schema2/content1 migration is deliberate; strict v2 never defaults
missing quest data. Journal/dialogue transient and unsaveable while open. Saves
remain arrival-anchor/stable pause boundary, not arbitrary mid-scene snapshots.

Simulated clearance is not combat proof. Reconnection is labeled text checkpoint,
not P011 service world variant. No actual attack/dodge, active companion AI, trust,
upgrade, Blender assets or verified Windows export. Viewport injection verifies
integration/rendering, not hardware/OS focus. Source story/market/town canon read
selectively; no source project edits or permanent narrative decision required.

## Next eligible task

P008 only: hero attack/dodge/health/damage windows, protective guardian defeat and
retry feedback. Replace prototype-guardian-test event source with actual guardian
instance defeat. Preserve existing saved quest/step/effect IDs deliberately; decide
schema compatibility before persisting new guardian/combat facts. Normal gameplay
must clear guardian and death/retry must not duplicate effects. Do not begin P009
in the same session unless explicitly authorized.
