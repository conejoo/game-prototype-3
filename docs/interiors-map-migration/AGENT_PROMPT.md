# Interiors and remaining maps reusable fresh-agent prompt

Repository documents supply memory; executing agent does not need personal planner skill. Creating this workflow does not start implementation.

## Prompt to paste into each new chat

```text
Follow D:/development/game-dev-blender/returning-fair-prototype/docs/interiors-map-migration/AGENT_PROMPT.md in full. Resume its unfinished task first; otherwise implement its next eligible task. Complete exactly one task, verify all acceptance criteria, update CHECKLIST.md and CURRENT_STATE.md, then stop before the successor.
```

## Goal and environment

Deliver nine authored Returning Fair map locations in existing Godot game. Reuse town/Mayor home/Lantern Rest; add Hall/starter-home/fairground/both Orchards and expand Tollworks while preserving actual shortened recovery. Normal access has seven public locations; isolated labeled preview inspects Orchards. No new campaign/ownership/sleep/economy/cast outcomes.

- Workspace: D:/development/game-dev-blender.
- Repository/command working directory: D:/development/game-dev-blender/returning-fair-prototype.
- Godot application: repository game/; entry res://app/game_root.tscn.
- Read-only source: D:/development/game-prototype-2.
- Console: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
- Editor: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe.

Verify installed paths before searching/installing tools. Engine installation is not project. Typed GDScript/GL Compatibility; no C# SDK build/install required.

## Preparation and selection

1. Read D:/development/game-dev-blender/AGENTS.md/applicable nested instructions, then this folder's [CHECKLIST](CHECKLIST.md), [CURRENT_STATE](CURRENT_STATE.md), [CONTRACT](CONTRACT.md) and current [architecture](../ARCHITECTURE.md). This checklist alone selects work; other feature selectors are references.
2. Inspect Git/source/target artifacts, actual schema, evidence and user changes. Read [routine state](../day-clock-npc-routines/CURRENT_STATE.md) and verify R016 ownership/completion. Preserve that session/packages/files. IM001 can pin references while runtime work awaits stable ownership; apply CONTRACT overlap rule later. Recheck relevant process/editor state before interacting; preserve unrelated sessions.
3. Resume single In progress task. Reassess Blocked work when recorded blocker changes; unresolved blocks exclude task/dependents, not independent ready branches. Otherwise choose lowest-numbered Pending with verified Done prerequisites and real capabilities/evidence. Checkboxes insufficient.
4. Reconcile inconsistent status/artifacts. If ambiguous/no ready task/unresolved overlapping ownership, record exact conflict/dependency/safe action and stop without guessing. If all Done, report completion and stop.
5. State selected ID/outcome, intended-file allowlist/checks; mark In progress before implementation. Finish exactly that task including repairs/verification; stop before successor. Do not launch agents/chats/automations as side effect.

## Execution rules

Follow CONTRACT rather than stale original missing-feature list. Rooms/home/inn and multi-portal routing already exist; reverify/reuse. Source has more people than scope: retain eight villagers/25 routines. IM001 pins complete selected public dependencies; later tasks consume local pins/refuse unexplained drift. Never refresh exterior/earlier feature pins from live source.

Separate32-unit/metre gameplay space from texture density/source furniture art/projected offsets. Preserve groups/fractions/floor erasures/valid IDs/stations and actual capsule clearance. Keep fair bridge distinct from Moonwood crossing. Record bounded measured adaptation with before/after/proof; never shrink actors/remove meaningful obstacles. Apply relevant art/Blender skills when actually producing art; keep editable exports/VisualRoots separate from Godot collision/identity.

Reuse LocationDefinition/PortalBinding/PortalRoutes/WorldHost; legacy single-destination fields cannot dispatch. Guard player/direct/load/NPC access. New doors are narrow overlays; normal Orchard/shortcut/second-city gates remain closed even after Maris completion. Implement proposed --map-preview only in IM003; isolate slots/label setup. No full campaign/stage-preview machinery. Source hooks are metadata until future consumers exist.

Keep one room/nav region, persistent party/session/environment clock/forecast/director. New outdoor maps get bounded adapters, not copied clocks. Both Orchards outdoorCycle. Preserve gifts/facts/People, fishing/foraging/rod conservation, NPC art/identities, combat/trust/strike/recovery and strict current saves. Inspect actual schema first; geography alone does not justify format bump or migrations.

Implement selected task's proposed tools/tests before invoking. Proposed filenames are not existing capabilities. Each map owner proves local doors/return/camera/arrival/save correctness; final gates add cross-map coverage rather than deferring basic correctness. Fix only selected outcome's necessary regressions. Follow applicable permissions/existing authorization without blanket approval steps. No source writes/normal-save manipulation/external messages/deployment/publication/automatic commit or push.

## Verification and isolation

Use existing PowerShell7 tools/run_checks.ps1 from repository root. Example with known checks for implementation work:

```powershell
./tools/run_checks.ps1 -Task IM003 -Names application_smoke,routine_portal_checks,location_travel_checks -TimeoutSeconds 150
```

Use selected ID and actual required existing/newly created checks. IM001 reference work validates inventory/docs, without launching gameplay merely to inventory. Read runner/callers for ProcessScripts/restart protocols, RenderOnly/RenderScript; never guess unsupported CLI flags. Locate bundled Python/PowerShell through available dependency tooling if needed; no PATH assumption.

Runner supplies task evidence, isolated APPDATA/LOCALAPPDATA and save groups. Reuse [save isolation](../TESTING_SAVE_ISOLATION_ACCEPTANCE.md), [runner observation](../TESTING_RUNNER_OBSERVATION_ACCEPTANCE.md), [journey helpers](../TESTING_JOURNEY_ACCEPTANCE.md), [interaction captures](../TESTING_INTERACTION_CAPTURE_ACCEPTANCE.md), [native input](../TESTING_NATIVE_INPUT_ACCEPTANCE.md), tools/native_input.ps1 and game/tests/support/. Record primary/backup slots. Preview/normal namespaces independent; never load/reset user's normal run. Evidence under docs/evidence/IMxxx and isolated builds/testing/topic delivery directories, not historical feature evidence.

Inspect structured results/exits/runtime diagnostics; exit0 alone is insufficient. Label synthetic placement/effects/clock/weather/preview selection/route guidance separately. Ordinary movement/GUI proves route/save behavior. Inspect final game-scale rooms/landmarks, cameras/zoom and indoor/outdoor/day-night/weather; gallery/source screenshot alone cannot certify map.

Native/rendered input uses current guarded tools, bounded atomic holds/clicks, guaranteed release. Confirm pause before inspection between calls; closing dialogue is not confirmed pause, and time advances during tool gaps. Never bypass desktop/focus/identity guards or claim debug bridge as native release. IM019 requires fresh outside-checkout packages/native journeys/actual GUI Save/normal quit/new-process Load; build-only/historical feature evidence cannot substitute.

Run proportionate affected checks, repair/rerun failures; no repeated unrelated full suites without a concern. Preserve failures/limitations. Time exhaustion/blocked desktop/unfinished acceptance never means Done.

## Handoff and stop

After incomplete and completed sessions update CHECKLIST/CURRENT_STATE: selected ID/status, exact continuation/next eligible task, baseline/user changes/actual changed files, source/schema/adaptation decisions, commands/cwd/isolation/results, inspected evidence, failed/unrun criteria, blocker/retry and owned process/input/editor/cleanup state. Append completion record only for verified Done. Keep stable rules in CONTRACT, status in CHECKLIST.

Read back docs; verify links/IDs/dependencies/selection/intended diff. Report result/checks/limits/next safe action. Stop after exactly one task; no successor/automatic agent/publication.
