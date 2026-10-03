# Current prototype state

Last updated: 2026-10-02 (America/Vancouver). Verified through P011.

## Current task

P011 complete. P012 next eligible, not started. Maris now has basic, returned/fitting
and restored specialist counter variants. WASD/mouse/Space combat, E interaction,
J journal/upgrade, Esc modal/pause, R retry and F10 quit remain runnable.

Normal path: accept southwest Maris lead, optionally select Deliberate Strike in J,
travel north, defeat guardian, inspect southeast vessel, return to Alderwake.
E at Maris opens labeled return/comparison/practical fitting scene. Final choice
restores service; Esc or pause choice leaves fitting unfinished. E afterward
previews specialist river gear/repair fittings. Basic supplies stay available.

## Implementation and changed files

Git initially clean; P010 prerequisite consequence checks PASS0. Applicable
workspace AGENTS/caveman skill, architecture/checklist/handoff, actual files and
read-only source story/MQ03/town canon inspected. Godot MCP project info confirmed
correct game path/version. Source project and normal save slot preserved. No
subagents, Blender work, installations, commits, push/publication or export.

- game/world/maris_counter.gd/.uid/.tscn: location-owned interaction wrapper retains
  npc-03-counter; fixed collision and replaceable VisualRoot. Basic shelf always
  visible; fitting prop or specialist gear/sign/service board derives from effects.
  Missing variant definitions fail scene validation. Alderwake instances wrapper.
- game/content/dialogue/maris_fitting.tres and maris_specialist.tres: immutable,
  labeled return/practice and specialist preview. Unnamed customer/helper temporary
  fixtures; no new permanent narrative facts. maris_counter.tres removes stale
  P011-future response. prototype_catalog.tres adds both definitions (17 total).
- game/app/game_root.gd: refresh presentation on quest change and successful
  transition/load after session rebinding. QuestService remains once-only authority.
  game/features/quests/quest_service.gd and ui/prototype_ui.gd show delivered result.
- game/tests/recovery_presentation_checks.gd/.uid: stage fixtures, cancel/leave/input,
  effect replay, unchanged definitions/collision, travel, bidirectional root restores,
  and separate writer/reader loading basic/fitting/specialist saves.
  content_catalog_checks.gd updated count; live_playtest_bridge.gd adds read-only
  counter/line/button observations, no mutation commands.
- README, tools/PLAYTEST, ARCHITECTURE, CHECKLIST, CURRENT_STATE and docs/evidence/P011 updated.

## Checks and evidence

Exact commands and acceptance map: docs/evidence/P011/VALIDATION.md.
Engine 4.7.2.stable.mono.official.ed1daf0bf; both supplied paths verified.

- P010 consequence prerequisite PASS0 with normal local access. Restricted first
  run passed rules but lacked log/certificate access; normal rerun clean.
- Initial/final editor import exit0; existing unused Mono SDK10.0.9 error remains.
  Nine focused scripts PASS0: recovery_presentation, content_catalog, quest,
  interaction_dialogue, save, companion, consequence, live_playtest, application_smoke.
  Final recovery/companion/smoke/catalog reruns PASS0 after label repair.
- Separate recovery writer/reader processes PASS0: exact 0/5/6 step states show
  basic/fitting/specialist variants. Root load replaces restored and unrecovered
  sessions both directions without arrival/effect replay. Schema4/content1 unchanged.
- Five Windows Compatibility renderer runs b–f quit0. Normal viewport WASD/E/GUI
  lead, upgrade40, actual guardian defeat, vessel, town return, three fitting lines,
  Esc cancel, final completion and specialist preview inspected. GUI save/restart
  preserves recovered result; room round trip preserves it. Separate GUI unrecovered
  save/restart/load shows basic shelf and no specialist gear. 213 exact input traces,
  PNG/JSON and logs retained. No simulated objective or state-mutation playtest path.
- Initial run a had malformed shell bridge argument and was closed; successful
  launches corrected it. Board initially clipped by bench; shortened/raised and
  no_depth_test fixed it, verified in final d/f captures. Runtime checks/windows
  clean; import SDK message recorded separately. Git whitespace check exit0.

## Decisions, limitations, blockers

No P011 blocker. Shop service is visible availability/preview, with no coin,
transactions or inventory. Reconnection is short dialogue-led scene with practical
work; no full MQ03/cinematic claim. Existing trust/companion/upgrade fixtures remain
noncanonical. Ship salvage/repair and fair reopening remain separate future work.
No new persistent flags, reward counters, effects or migration. Completed older
schema4-compatible saves display service from existing maris-reconnected effect.

Low room walls and counter do not hide standing actors; no camera fade added.
Service board alone ignores depth to avoid billboard/bench clipping. Imported art
can replace visuals later; collision/navigation remain Godot-owned. Tiny-room nav,
transient unfinished combat, stable arrival-anchor saves remain prior limits.
Input injected into actual rendered viewport proves gameplay integration, not new
OS/hardware-focus evidence. No Blender connection or Windows export claimed.

## Next eligible task

P012 only — Reusable Blender asset pipeline. Read applicable skills, verify live
connection/current scene and preserve unrelated work; save .blend in art/source,
export vessel/guardian/modular prop GLBs into Godot wrappers. Validate replacement
and re-export in game. No P012 work started this session.
