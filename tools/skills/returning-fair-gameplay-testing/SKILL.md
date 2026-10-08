---
name: returning-fair-gameplay-testing
description: Test Returning Fair Godot prototype gameplay, combat, UI, travel, saves and Windows releases using bounded input and verified pause checkpoints. Use for this project at D:/development/game-dev-blender/returning-fair-prototype, including its map migration; not unrelated games.
---

# Returning Fair gameplay testing

Produce evidence for the requested gameplay acceptance criteria. The project keeps
this skill's versioned source under `tools/skills/returning-fair-gameplay-testing`;
the installed personal copy is scoped to this project by its description.

## Establish current state

Read applicable AGENTS.md, docs/ARCHITECTURE.md, the active checklist/handoff and
Git changes. Migration has separate docs/map-migration state; follow whichever
task the user selected. Preserve unrelated work and source game at
`D:/development/game-prototype-2` (read-only). Verify actual code/build/tool state;
old evidence, exposed tools, past PIDs and earlier completion claims are not proof
of today's runtime. Do not start another checklist item while testing the current one.

Godot project is `<project>/game`. Check supplied console/editor paths under
`D:/development/Godot_v4.7.2-stable_mono_win64` before searching or installing.
Use console for captured checks. Keep definitions/state, once-only effects,
versioned plain saves and replaceable visual wrappers intact.

## Preflight current APIs and movement

Before writing fixtures, use `rg` to inspect the current actor/combat, camera,
interaction and save APIs. Verify method signatures and property names from code;
past fixtures/chat are not an API contract. Movement is camera-relative through
`PrototypeCameraRig.movement_direction`, not world X/Z. Observe
`camera_controls.move_right/move_back`, projection and zoom before planning holds;
verify a short normal input batch before a longer route. Synthetic placement cannot
prove normal movement.
For scripted viewport journeys, use `TestRunJourney.walk` and consume its returned
`ok/error`; the shared reference covers exact-region readiness and failure traces.
Do not copy movement loops from historical scenario tests.

Use `tools/run_checks.ps1` for import/headless/render runs: names and evidence routes
preflight before launch, followed by a parse gate covering literal script/scene
dependencies. Add computed/dynamic paths with `-ParseScripts`; import alone does
not prove those scripts compile. Use `-RenderOnly` for rendered-only verification.
The runner isolates evidence/app-data/save slots, flushes live logs, stops on
diagnostics and cleans only owned PIDs. Read
[shared testing tools](references/testing-tools.md) for commands and helper contracts.
Do not bypass a failed runner scan; diagnose its retained stdout/stderr/results.
Read `RUN_REPORT` and the running case's logs to diagnose a stalled run without
waiting for timeout. Historical P/M/W task-root destinations are rejected. Use
TestRunEvidence for report files and consume failures; never route a current check
to an archived report or loosen output guards to make a legacy fixture pass.
## Choose evidence path

- Exact damage, swing contacts, rules, migrations and illegal transitions: focused
  headless checks with isolated actors/state. Synthetic fixtures are labeled.
- Actual camera, collision, combat integration, companion, UI and journey: rendered
  normal gameplay through current input paths, with inspected screenshots.
- Editor/debug runs: existing opt-in viewport bridge, `tools/send_playtest.ps1` and
  `tools/PLAYTEST.md`. No teleport/health/quest mutation for normal-play acceptance.
- Windows release: actual exported exe+pck from build directory, native
  `tools/native_input.ps1`. The debug bridge is excluded/guarded in release.
  Read [native commands](references/native-commands.md) when using this route.

Use available purpose-built tools when suitable. Native helper supplies holds when
the Computer Use API only supplies taps; inspect applicable installed Computer Use
instructions before choosing that fallback. Respect the active tool/permission
boundaries. Never weaken game input gates just to satisfy automation.

## Time and pause are part of the test

**Game time continues between tool calls, while the model reasons, during helper
startup and during captures. A requested 500ms hold controls the hold, not the
time until the next observation.** Wall timing is not deterministic physics stepping.

For hostile gameplay, start from an inspected pause screen. In one short native
request: activate observed Resume -> bounded actions -> release inputs -> Esc ->
allow rendered UI to settle -> capture. Inspect the pause overlay before reasoning
or sending another batch. Record actual elapsed wall time. Increase batch length
only when the scenario needs continuous play; include a verified safe checkpoint.

Esc is mode-dependent: it can close dialogue/journal, resume a pause, or be ignored
during travel. A sent Esc is not proof of pause. If the expected overlay is absent,
reobserve current mode and perform its appropriate action; do not blindly toggle
Esc repeatedly. After interruptions, discard stale coordinates/mode assumptions.

Dialogue/journal suspend actor actions but may still advance session time. Do not
infer a global time freeze. Companion and enemy continue acting within resumed
batches: combined HP changes cannot establish hero-only damage, one-hit timing or
the cause of death. Use isolated rule checks for those claims, and rendered combat
for integration. Normal death/R retry is valid play; record it rather than hiding
an idle-time failure or manufacturing a victory.

## Save isolation and completion

Independent runner checks receive distinct named slots and APPDATA/LOCALAPPDATA
directories. Each process script's write/read pair explicitly shares one save group;
render phases share their own group. Inspect per-case `save_group/save_slot/appdata`
in schema-2 results; the top-level app-data paths are group containers.
For synthetic fixture repositories, await startup `transition_finished`, then
consume `TestRunSave.configure(game, "user://saves/fixture.json")` errors. Never
assign a fixture repository before adding GameRoot: `_ready()` replaces it with
the runner slot. The helper refuses incomplete startup, load/retry/travel and the
normal slot; it does not clear files or change production startup behavior.

Verify the save directory before Save/Load. Debug uses a named test slot; native
release currently uses adjacent override.cfg for its separate validation user://.
Never assume release honors debug --save-slot. Preserve the normal slot and existing
validation runs; create unique capture/command directories.

Observe fresh startup, invoke actual GUI Load, verify restored facts/world, and
exercise required replay/revisit paths. A click or a successful input request is
not a successful load: inspect status/HUD/world and actual plain save. Prefer
observed Tab/Enter focus when mouse activation is unreliable. For rendered fixtures,
use `await TestRunGui.activate(game, button, outcome)` and require `ok`: it verifies
pause/focus and a new observable outcome, not merely input delivery. Give Save/Load
predicates actual status/file/world completion; keep the exact restart oracle.
Retain a launch
process handle so normal quit has an exact exit result.

Record commands, build/version/hash/context, input traces, inspected PNGs, save
snapshots, runtime errors and failures. Separate synthetic/debug/native evidence.
At a verified paused Save/GUI Load boundary, use TestRunSnapshot for exact typed
durable facts and full-precision forecast; raw JSON numeric dictionaries are unsafe.
After resumed travel/replay, assert intended persistent fields and monotonic time
separately; do not weaken the stable restart oracle to tolerate unexpected drift.
Use TestRunCapture plus capture_evidence.py for pause/provenance manifests and unique
contact sheets; capture preserves the current settings modal and focused control.
Hold, backpack and drag evidence uses `TestRunInteractionCapture` instead: it verifies
the live state while frames settle, without pausing or freezing time. Read the live
capture recipes in [shared testing tools](references/testing-tools.md); consume refusals
and never label an expired/canceled interaction as a successful active-state capture.
Inspect actual PNGs before accepting visuals. The bridge environment
observation reports clock/seed/forecast/overrides and live intensities without commands.
Describe FPS samples by scenario, including pause/UI, rather than calling them a
combat benchmark. Update the active checklist/handoff only for criteria with
evidence; blocked checks stay incomplete with exact reason and next safe action.

Raw runs under ignored `docs/evidence/` are optional local archives. Start with
current code/tests and concise handoffs; missing old reports do not block work.
Version only reusable fixtures and durable decisions, never raw logs/captures.
