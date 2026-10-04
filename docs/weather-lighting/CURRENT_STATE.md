# Weather and interactive lighting current state

Updated 2026-10-04, America/Vancouver. Read [CHECKLIST](CHECKLIST.md),
[CONTRACT](CONTRACT.md), [AGENT PROMPT](AGENT_PROMPT.md) fully before selection.

## Selected task and next action

- W001: Done, source inventory and verified contract. No active W task.
- W002-W010: Pending. Next eligible W002 only; not started in this session.
- Safe next action: verify W001 [acceptance](../evidence/W001/VALIDATION.md),
  run its target-local audit, inspect session/root and then mark W002 In progress
  before typed clock/forecast implementation. Do not invoke P/M prompts.
- All W001 criteria pass; no unresolved design prerequisite/tool blocker.

## Baseline and preservation

Target `D:/development/game-dev-blender/returning-fair-prototype`, branch main,
HEAD `6a648a3cc1a216a063f83e844d181d0450e4e800`; Godot project `game/`.
Workspace AGENTS read, no nested AGENTS found. Both supplied Godot executable
paths exist; installed4.7.2 ed1daf0bf verified by startup probe.
Read-only source `D:/development/game-prototype-2`; no source writes/generators.
Pinned map snapshot `alderwake-f4630f9-m002` unchanged, mapSHA256 af67bd904eeaf9a8c08a763f60471a5be7d74e7dafe99753381d38577499294f,
layoutSHA2567477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be.

P001-P014/M001-M019 completion verified against current packages and native
records. All five M019 build/layout hashes match; new standalone startup clean.
Initial modified README/parent CHECKLIST/CURRENT_STATE/map CHECKLIST/CURRENT_STATE,
untracked M019/P014 m019-native evidence and existing weather workflow preserved.
10,825 existing production/art/tool/historical/parent files hashed before W001;
final audit checks equality. No reset/stash/commit/push/publish/install/subagent.

## Exact changed-file scope

- `docs/weather-lighting/CHECKLIST.md`: W001 Done/completion record; W005 inventory
  explicitly includes pinned luminous net discovered in W001.
- `docs/weather-lighting/CONTRACT.md`: verified reference hashes/links, all sources,
  clock/hash/cache bound/gates, exact future save shape/registry policy,
  physical anchor/asset recipes, room/renderer/performance decisions.
- This `CURRENT_STATE.md`: durable W001 completion/handoff. AGENT_PROMPT unchanged.
- New `docs/evidence/W001/`: .gitattributes (byte-stable reference/probe snapshots),
  audit.py, run_baseline.py, baseline_probe.gd,
  final_review.py, VALIDATION.md, LIGHT_INVENTORY.md, source-manifest.json,
  source-geography-drift.json, preserved-baseline.json, light-inventory.json,
  rule-vectors.json, audit-results.json, baseline-results.json,
  engine-baseline.json, final-review.json, final-review-initial.json, final-audit.log,
  baseline-probe-sha256.txt, engine-probe.stdout.log/
  engine-probe.stderr.log, release-startup.stdout.log/release-startup.stderr.log.
- Twenty-three exact reference copies under W001/reference/, exhaustively listed
  by source-manifest.json. Ignored staging under builds/weather-lighting/w001/.
- No game/art/tools/parent/map production or historical artifact changes.

## Verified decisions

Full details in CONTRACT and W001 inventory. Production remains schema4/content1,
fixed Sun/WorldEnvironment/manual saves/elapsed timer. W003 will implement v5;
W001 fixes environment {day_index,day_cycle_progress,weather_seed} and sorted
light_source_overrides array of exact {location_id,prop_id,source_id,enabled}.
Only six switchable lantern keys accept overrides; all 23 source identities
register without scene nodes. Source alderwake maps to prototype-alderwake.

Inventory: six dock lanterns (five disabled, Dock Row enabled), fourteen windows
(ten enabled/four disabled), two enabled answer-light waylights, one enabled
woven-lights net. Every ID/foot/default matches original pinned map/catalog.
All existing wrappers/VisualRoots/feet verified in actual headless root. W005 owns
lamp/window/waylight/net visual gaps and planned physical anchor calibration.
Buildings without declared sources stay dark. Tollworks quest vessel unaffected.

Behavior refs pinned separately at current sourceHEAD842704819cc681ccbabc629c6634c154a53b506b.
Current source map differs (deda25dc...), catalog matches; pinned geography wins.
Twenty-three exact source/doc/test copies with SHA256 plus49 forecast vectors
remove dependency on evolving source. Python vectors are source transcription;
source Flutter/Dart tests were read/pinned, not executed.

600 active seconds/day, progress0 displays10 AM; display midnight does not increment
day. Forecast uint32 mixing requires low16 product arithmetic to avoid signed-int64
overflow. Periods240..480 authored minutes, blends15, source transition graph;
only thunderstorms derive heavy-rain. Supported day0..3650/progress[0,1), max seed
4294967295; fewer than21,906 transition reconstructions. W002 reconstructs once
on hydrate/seek and samples cache between boundaries, verifies upper-bound cost.
Keep existing pause/travel/load freeze; dialogue/journal/indoor/focus-loss time
advances. Source fade policy differs; target retains its transaction gates.

Keep GL Compatibility; installed settings max_lights_per_object8,
max_renderable_lights32/max_renderable_elements65536. At most eight pooled
unshadowed local emitters, including fading entries; all emission independent
of pool/persistent enabled state. Actual per-mesh visual overlap remains W005/W009.
M018 method/thresholds retained including frame/draws/memory/travel lifecycle.

## Exact verification, paths and results

All cwd target root unless baseline-results records release build directory.
Python C:/Users/aldoc/.local/share/blender-skills/.venv/Scripts/python.exe.

- audit.py --capture-source: PASS/exit0; source copied only once. audit.py:
  final PASS/exit0,23 refs/23 sources/49 forecast vectors/five pinned inputs/
  matching M019 package hashes/10,825 preserved hashes.
- run_baseline.py: PASS/exit0. Engine/root probe0: safe two-party production
  arrival/all23 wrappers/pause timer/settings. Standalone release0 from
  builds/windows: normal fresh production arrival. Zero ERROR/SCRIPT ERROR scans.
- Exact argv/cwd/env/launcher PID/exits/logs: W001/baseline-results.json.
  Engine console launcher49668, actual child PID not measured; release51724.
  No performance claim. APPDATA and LOCALAPPDATA separately isolated under
  builds/weather-lighting/w001/{engine-probe,release-startup}/; no save command,
  normal save or previous P/M test save used.
- Initial final_review.py exit1: own output final-review.json did not exist
  during link audit. Failed JSON retained as final-review-initial.json; script
  now creates an in-progress output before checking links. No source/game failure.
- Final final_review.py + git diff --check: PASS/exit0 in W001/final-review.json;
  intended scope/status/local-link/whitespace checks required before final reply.
- No new rendered capture inspected/claimed; not required for W001 inventory.
  No full prior acceptance suite, import/export, benchmark or source Dart run.
  Weather/saves/assets/visual/native acceptance remain future W tasks.

## Process state and safe continuation

Initial restricted Win32_Process read failed access denied; elevated read succeeded.
Existing Blender PID2664/MCP helpers untouched, scene not accessed or changed.
No existing Godot/game found. W001 processes exited0, no held input/new live game.
Keep evidence and ignored staging; do not repin references or refresh map snapshot.
No incomplete W001 criterion. Stop after W001; next chat starts W002.
