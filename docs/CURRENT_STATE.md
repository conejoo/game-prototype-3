# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P005.

## Current task

P005 complete. P006 next eligible, not started. Normal start loads Alderwake;
WASD moves, nearby E travels to Tollworks/back. Esc pause menu now saves/loads.
Reopen, pause, choose Load to resume saved room at last arrival anchor. No autosave.
No combat, runtime dialogue, active companion or Blender assets yet.

## Implementation and changed files

Root: `D:/development/game-dev-blender/returning-fair-prototype`; Godot path `/game`.
Baseline `93b38f4` (P004), initial Git clean. P005 source, documentation and evidence
recorded in local Git at user request. Existing source/UIDs preserved; no source-
project edits/push/publication. One task only.

- `game/core/save_codec.gd`: schema/content v1, <=128KiB plain JSON, strict fields,
  stable location/spawn/player/party/actor IDs, integer health and finite time.
  Creates detached GameSession only after full validation. Definition health
  limits remain authored; live health remains ActorState. No scene/Resource saves.
- `game/core/save_repository.gd`: normal `user://saves/returning-fair.json`, `.bak`,
  checked `.tmp` and `.bak.tmp` writes/flush/reopen/validate/rename. First save
  creates recovery backup; later backup is previous valid primary. Recovery read
  leaves disk untouched; corrupt primary never replaces good backup. Unsupported
  versions and IO errors block fallback/write; both corrupt files require repair
  or archiving before Save. Leftover uncommitted temporary files never load.
- `game/app/game_session.gd`: explicit ordered `party_member_ids`; P005 one hero.
- `game/app/game_root.gd`: pause-only stable save commands, loading/reentry/input
  lock, WorldHost physical placement/rollback reused. Root adopts candidate and
  rebinds wrapper only after success, before later transition observers. Same
  actor node/camera remain. Debug named slot only isolates disk files for tests.
- `game/ui/prototype_ui.gd/.tscn`: Save/Load command signals, visible results,
  arrival-anchor/no-autosave explanation, loading disables commands. Resume now
  clears any focused menu control. Paused arrival refreshes stale travel prompt.
- `game/tests/save_checks.gd`, `save_process_checks.gd`: meaningful rejection,
  isolation, filesystem recovery/failure, unsafe floor/obstruction rollback,
  save boundaries and two-process tests. Health37/time42.5 are labeled test setup.
  New script `.uid` files retained after editor import.
- `game/tests/live_playtest_bridge.gd`: read-only save/party observations; Save/Load
  exercised via normal GUI/input, no bypass command. `tools/PLAYTEST.md`, README,
  checklist, architecture compatibility/boundary contract and P005 evidence updated.

## Checks and evidence

Engine: `4.7.2.stable.mono.official.ed1daf0bf`; --version exit0.
Exact commands/exits and acceptance mapping: `evidence/P005/VALIDATION.md`.

- Final `--headless --path ./game --editor --quit` exit0; no GDScript errors.
  Existing unused Mono .NET SDK10.0.9 error remains; GDScript checks clean.
- `--headless --path ./game --script res://tests/<name>.gd`: application_smoke,
  content_catalog_checks, movement_camera_checks, live_playtest_checks,
  location_travel_checks, save_checks all PASS/exit0. Travel/save rechecked after
  prompt repair; previous stages retain collision, pause, focus and lifecycle.
- `save_process_checks.gd -- --phase=write`, then separate `--phase=read`: both
  PASS/exit0; final PIDs22400/5752. Reader starts fresh Alderwake, loads Tollworks,
  exact health37/time42.5, one hero, safe (0,0,-2.5) anchor.
- Save checks reject invalid/missing fields, IDs, versions, party duplicates,
  numeric bounds, malformed/oversized JSON. Temporary/backup staging directory
  obstructions report failure and preserve both files. Invalid runtime snapshot
  cannot overwrite good saves. Missing/truncated primary recovers valid backup;
  read preserves bytes; subsequent Save retains backup. Newer primary cannot
  downgrade via backup; newer backup cannot be overwritten; both corrupt reject.
- Root rejects unpaused/in-flight/repeated requests. Invalid/newer candidates
  preserve live owners; unsafe saved floor/obstruction restores exact old room,
  state, position, controls and pause. Successful load rebinds authoritative state.
- Actual Windows Compatibility renderer, RTX4070 Laptop/driver581.29, 960x640:
  WASD/E reaches Tollworks; mouse Save; travel back without saving; F10 close0.
  Fresh process mouse Load restores Tollworks/health100/exact time23.3421449999991;
  Resume and A move, quit0. Third process Tab/Enter Load after prompt repair also
  restores saved data, readable menu/correct travel prompt, movement and quit0.
  Three distinct boot IDs retained in raw JSON. Selected PNGs inspected; assertion
  script exit0 (`live-evidence-check.txt`); runtime error scan no matches.
- Final Git diff --check exit0. Final runtime logs contain no errors/warnings.
  Earlier restricted prerequisite logs have log/certificate access errors; final
  tests used approved normal Godot access. No dependencies installed.

## Decisions and limits

- Save resumes last stable arrival anchor, not arbitrary position/heading/velocity.
  Supported pause boundary excludes transitions; future combat/dialogue must
  extend gates deliberately. Loading stays paused, no implicit startup load.
- Strict v1 JSON supports one `party-player` / `prototype-hero`. No prior schema
  exists to migrate. P007 must bump/migrate v1 for quests/effects; P009 extends
  party state. Incompatible content IDs/stats require deliberate version policy.
- Single-writer local slot; staged-write fault tests, no physical power-loss test.
  User's normal slot untouched: windowed checks use playtest-p005-validation-20261002;
  headless checks retain isolated p005-checks-* / p005-process-check files in user://.
- Rendered input comes through ordinary viewport InputMap/GUI; does not claim
  new hardware/OS focus evidence. No debug quest objective, Blender asset or
  exported Windows build. Grayboxes and catalog-only companion/dialogue remain
  labeled prototype fixtures. No permanent narrative decision required.

## Next eligible task

P006 only: reusable interaction selection/prompts/arbitration, authored NPC/prop
interactions and dialogue choices; movement/attack gating, cancellation/control
restoration, both-room playable evidence. Read architecture/checklist, inspect
actual Git, recheck prerequisites. P006 not started.
