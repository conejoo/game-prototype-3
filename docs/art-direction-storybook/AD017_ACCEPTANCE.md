# AD017 - Storybook HUD readability

Done, 2026-10-11 UTC. Every AD017 criterion verified; blockers, remaining required checks and cleanup: none. AD001-AD017 Done; unfinished AD018, AD019, AD020. Next eligible AD018 only, in a fresh implementation invocation. Every checklist item through AD020 complete: **no**. No staging, commit or push; separate post-review commit instruction awaits.

## Result and ownership

Existing controls now share quiet olive/timber panels (`#38372E`), warm cream type (`#F0DFBB`), muted sage buttons and apricot keyboard-focus borders. No new font, texture, baked text, blur or asset import. Current title/location, clock/weather, quest/optional objectives, hero/ally health, trust/mode and active tool remain sourced from their original owners. Quest text is retained verbatim and wraps in its bounded panel. Hero and ally use one footer row; footer stays visible during fishing, whose original panel now reserves the health bar.

At 960x640 the header is 75px and ordinary footer 76px: combined 151px / 23.6% of height. At 1872x872 both remain the same pixel height, leaving more world visible. Quest panel is 540x82px in the measured initial objective. Current usable interaction appears above the footer; feedback stacks upwards with a gap, rather than across world actors. Generic repeated `E near ...` help is quiet in ordinary mode and remains visible in the existing debug mode. Full camera/control diagnostics remain in that same mode; FPS/settings behavior is unchanged.

Static world labels are cached by current location and refreshed every 0.15s: at most one original, nearby non-interaction label within 5m is visible ordinarily. Current interaction uses its authoritative screen prompt instead of duplicate floating instructions, including nested Maris counter signs. Spawn/debug labels are quiet; debug restores original local visibility. No label text, unsupported portal wording, font/mesh/transform, interaction eligibility, reach, priority or source ID changes. Routine public speech and fishing target output retain their own presentation/timing owners. Freed/detached labels are checked before typed assignment or global-coordinate access during startup, rollback and teardown.

All original modal/control identities, signals, focus cycles and root input owners remain. The existing `accepts_world_pointer` gate additionally owns visible quest/prompt/feedback panel bounds; real clicks there cannot reach combat. No new modal system, game input action, durable state, scene/physics/navigation/actor/portrait/asset/material/lighting/camera/save-format change. SaveCodec remains schema8/content1. Historical R016 remains Blocked/incomplete.

Ten task paths:

- `game/ui/storybook_hud.gd` and its generated `.gd.uid`: shared appearance/layout and static-label visibility adapter.
- `game/ui/prototype_ui.gd`: adapter attachment, retained companion label reference/compact text and visible-panel pointer ownership.
- `game/ui/fishing_view.gd`: presentation-only configurable bottom inset.
- `game/app/game_root.gd`: one existing footer visibility statement keeps health present while fishing; all other statements retained.
- `game/tests/art_direction_hud_render.gd`: reusable isolated, rendered size/modal/pointer/health acceptance fixture.
- `game/tests/people_journal_checks.gd`: one explicit optional-routine-owner disable for its existing synthetic social contacts; every original assertion retained.
- This acceptance, `CHECKLIST.md`, `CURRENT_STATE.md`.

Starting HEAD `b287bf49bc58a773206440747196e5320e7af1c0` is context only. Unrelated untracked direction, AGENT_PROMPT/CONTRACT and interiors-workflow inputs remain. No `.agents/skills` or additional repository AGENTS exists here; workspace instructions, art contract/look/baseline, architecture, prerequisite AD008/current AD016 evidence, PLAYTEST and versioned testing skill supplied guidance. Chosen reference pixels were opened; no Blender/editor/source checkout work was needed for this UI task.

## Acceptance evidence

| Criterion | Verified result |
| --- | --- |
| World/actors readable at both window shapes | All 32 final actual Godot frames and three provenance sheets inspected, with full-size world, dialogue/choice, fishing and storm-night review. Actual image dimensions are 960x640 and 1872x872. Both projections retain their original camera modes/zoom1. Persistent panels fit, header/quest/footer do not overlap, all four header buttons fit, ordinary static-label count <=1. |
| Current information and interaction | Actual selected Maris counter prompt, E dialogue and Enter-authored recovery choice are visible; resulting quest text remains complete. Hero/ally health, time/weather and selected rod remain visible in fishing; its panel is above the footer. No duplicate counter signs obscure party or Maris. All original unsupported portal text and data remain unchanged. |
| Dialogue/choices, bag, journal/People, fishing, pause/settings | Rendered viewport E/Enter, B/Enter, J/mouse People tab/Esc, F/click/E/F release, Esc/Tab/Enter/mouse settings toggles exercise real controls. Paused GUI activation requires a new observed outcome. Live captures retain validated focus, blocked actors/modal identity and four settled frames. Original headless suites additionally verify all eight people, 48 original portraits, long-text/scroll/lifecycle/facts and inventory/fishing behavior. |
| Pointer/focus/modal blocking | 174 new rendered assertions include real clicks at quest, current prompt, header and footer with no attack; world point remains available; pause, dialogue, journal, bag and fishing own pointer as before. Existing suites pass their input/focus/movement/attack/pause and teardown checks. |
| Preservation | Final 1,407-file source manifest remains exact; all 1,400 protected game/tools inputs from the initial task checkpoint match. No unexpected source change. Fourteen incidental older import UIDs were removed only after matching their generated hashes; new HUD UID retained. Index unchanged and all 98 recorded owned Godot PIDs exited. |

Final command, PowerShell7, cwd `D:/development/game-dev-blender/returning-fair-prototype`:

~~~powershell
./tools/run_checks.ps1 -Task AD017 -Names application_smoke,settings_debug_checks,backpack_ui_checks,fishing_ui_checks,npc_dialogue_ui_checks,people_journal_checks,combat_checks -RenderScript art_direction_hud_render -RenderPhases check -TimeoutSeconds 180
~~~

[Results](../evidence/AD017/20261011-115835123-1f741655/results.json): **10/10 cases passed, exit0**, including engine version, dependency parse gate, seven existing suites and rendered acceptance. `source.changed=false`, `source.error=null`; aggregate SHA256 `4d70437e843bd48ae43da3d1854178b5f5b97de99603ee936508f42c13722527`. Existing inventory148, fishing75, NPC dialogue384 and People journal134 assertions pass; settings/debug and original combat lifecycle suites pass. [HUD index](../evidence/AD017/20261011-115835123-1f741655/render/hud-index.json): 174 assertions, zero failures, 32 images, actual engine PID52352. [Capture report](../evidence/AD017/20261011-115835123-1f741655/render/derived/20261011-115949-83ce0925/capture-report.json) validates all hashes/provenance. [Audit](../evidence/AD017/authoring-20261011/acceptance-audit.json) and [cleanup](../evidence/AD017/authoring-20261011/cleanup-pids.json) record scope and source/process preservation.

Runner isolates APPDATA, LOCALAPPDATA and named save groups under `builds/testing/AD017/20261011-115835123-1f741655`; ordinary user saves are untouched. Engine is installed Godot4.7.2 Mono, GL Compatibility, NVIDIA RTX4070 Laptop/OpenGL3.3 NVIDIA581.29. The renderer fixture explicitly sets root content-scale size and window size to each requested shape; this is a synthetic review configuration, not a change to project window/stretch/camera settings. Registered Maris/shore feet, legal rod pickup, encounter seed and explicit day/night clock/weather are synthetic. Default routine owner remains active in this rendered process; selected contact dialogue and choice use current normal input. Fishing phase setup advances its original service before automatic live capture. Night uses day2/progress0.625/seed30; recorded HUD shows 1:00 AM/Thunderstorm. Every capture carries current typed facts, focus, camera, environment, PID and dimensions.

Capture command (same cwd, bundled Python executable):

~~~powershell
& C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe tools/capture_evidence.py docs/evidence/AD017/20261011-115835123-1f741655/render/hud-index.json
~~~

It returns32 images/three sheets, zero provenance failures; visual inspection accepts those pixels. Audit command is the same Python executable with `docs/evidence/AD017/authoring-20261011/audit.py`. Command-local `git -c safe.directory=... -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check` passes; existing Windows CRLF is preserved without global Git changes.

## Retained attempts and limits

Initial sandbox runner could not inspect its owned child via CIM; scoped escalation approved, no automatic-review rejection. First import generated missing old UIDs and correctly invalidated its source checkpoint; warning/SDK diagnostics retained. Stable final run follows hash-checked incidental cleanup and uses established imports.

Earlier rendered attempts caught a freed cached label, header/quest overlap, old fixed logical viewport despite window resize, stale synthetic speaker binding, and health hidden during fishing. All repaired within presentation/fixture scope and final gates rerun. The source/stale-binding failures were not accepted as visual proof. Two mistaken combat check names failed preflight before launch; final command uses verified existing `combat_checks`.

People Journal's old synthetic contact setup failed under the now-default routine owner. [Unchanged HEAD proof](../evidence/AD017/authoring-20261011/prepaint-proof/results.json) reproduces the same `SocialSaveFixture.introduce:18`/`preference:31` assertions and partial-roster/lifecycle failures with stable source. Archive of starting HEAD and copied import cache were confined to `builds/testing/AD017/prepaint-1153`; no working-tree reset. One fixture-only `routine_execution=null` matches its explicit synthetic contact contract; original assertions remain. Current default owner and actual Maris interaction are separately exercised by final rendered acceptance.

No ordinary map journey, native input/export/startup, actual GUI Save/Load/new-process restart, full integrated AD018 review or AD019 performance claim. Existing suites' synthetic save round trips are labeled tests. No live process, held input, editor/Blender mutation or cleanup owed. All AD017 criteria are complete; stop before AD018. Implementation stopped before commit; subsequent authorized follow-up is recorded below. Do not push.

## Authorized commit follow-up - 2026-10-11 UTC

The user supplied the separate successful-task commit instruction after review, explicitly including acceptance evidence. This follow-up makes only the local AD017 commit; no push or AD018 implementation. All ten reviewed task hashes, 1,407 validated source files, 10/10 final cases, 32 capture hashes and 3,389 protected tracked/untracked inputs were reverified before documentation-only follow-up edits and staging. Existing failed attempts, synthetic provenance and acceptance limitations remain recorded.

Scope includes ten task paths, final32 engine frames/three sheets, final reports/logs/source manifests, retained failed-run reports/logs and compact prepaint proof, implementation audit/cleanup and pre-commit verification. Intermediate duplicate/rejected PNGs, temporary scripts/build/save archives and unrelated direction/interiors/AGENT_PROMPT/CONTRACT remain excluded. [Commit review](../evidence/AD017/commit-review.json) records exact selected paths/hashes; local `docs/evidence/AD017/authorized-commit-20261011/commit-audit.json` records verified commit/tree/blob identity and final working-tree status after commit. AD001-AD017 remain Done; AD018-AD020 Pending. No cleanup owed.
