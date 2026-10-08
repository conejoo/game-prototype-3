# F008 — Art and peaceful feedback acceptance

Completed 2026-10-07, America/Vancouver. Exactly F008 completed; F009-F010 Pending.
Initial HEAD `df6a907318f0cc9a02b9df741889de9301dd3ccc`; target worktree clean.
[CHECKLIST](CHECKLIST.md) owns status; [CONTRACT](CONTRACT.md) owns rules.

## Observable result and editable sources

Moonflowers now have five pale blue petals, a warm centre, stem and paired leaves.
The horizontal fishing rod has an ivory shaft, cork grip, teal bindings and reel.
The reusable typed [ForagingItemVisual](../../game/world/foraging_item_visual.gd)
mesh kit is both editable art source and runtime asset. Matching local editable
[SVG icons](../../game/assets/items/README.md) appear beside backpack names/counts.
Art was authored with Godot meshes; this task did not edit a Blender scene.
Mild material emission preserves night silhouettes without adding lights or a timer.

The existing VisualRoot remains separate from wrapper identity/action, physics,
navigation, session facts and placement validation. Labels have readable dark outlines
and draw above foliage; this visual-only depth setting does not bypass interaction LOS.
Rod meshes fit the existing 1.0 x 0.14 x 0.44m validated clearance box. Ground clearance
is 0.03m; flowers' stems start at supported ground and bloom tops stay below 0.51m.
No placement, geography, stable ID, hold duration, schema6/content1 or save rule changed.

Gather progress now has a dark outlined track and restrained mint fill. Prompt, health
and transient feedback use separate stacked rows, below modal draw layers. Received,
full, cancelled and invalid-placement messages are readable on a dark background.
New E attempts clear old feedback. Modal entry hides feedback immediately. Drag retains
its valid green/invalid red ghost and explicit release/cancel text, so color is not the
only validity indication. All feedback, progress and preview remain transient.

## Every acceptance criterion

| Criterion | Evidence and result |
| --- | --- |
| Three flowers and rod readable at normal zoom | Final ordinary all-four WASD approach/gather renderer plus 72 paused art views at four real registry feet, both projections and zoom1.0/1.15/0.8. Names and distinct flower/rod silhouettes readable; all reachable target checks pass. PASS. |
| Progress/errors readable day/night/rain and both projections | Final art renderer: 72 paused pose/clock/presentation samples plus 24 actual live E hold/release/green/red pointer captures at sunny day, clear night and rain, orthographic/perspective. Live helper verifies active target/ownership/input, four settling frames and actual rendered frame; exact item facts remain unchanged after cancellation/invalid release. PASS. |
| Art removed only after success | Final foraging_interaction_checks103 assertions verify early600/500ms boundaries, release and every existing cancellation gate, full99 stack/full20-type bag retaining wrappers, success joint facts/removal and no duplicate publication. Additional assertions verify actual cancel/full/received feedback. Final ordinary renderer gathers rod and all three flowers, then independently restores exact facts and revisits absence. PASS. |
| Invalid preview clear | Final live red matrix across all six environment/projection combinations and final ordinary water-directed release show red ghost plus “Cannot place here / Release keeps original”. Cancel/invalid release preserves exact item facts. Ordinary green commit, travel/reload/recollect also pass. Placement suite128 assertions retains all physical rejection guards. PASS. |
| No clipping, hovering, foliage-obscured prompt or UI overlap | Mesh AABB endpoint checks prove rod inside unchanged clearance and all four visuals grounded/nonblocking. Reachable selection checks pass in every art view. Full-size normal, near/wide, night/rain and ordinary approach images show no selected-item foliage obstruction or prompt/health/feedback/progress/footer overlap. UI rectangle checks and modal-layer regression pass. Final empty/owned/capacity backpack captures fit960x640 and smaller requested800x600 window (actual stretched raster800x533 recorded in manifests). PASS. |
| No Flame dependency | New mesh/SVG/UI sources use local Godot assets only. Live-source F001 auditor verifies20 source hashes, three local reference hashes and three pinned geography hashes with six negative controls; source Git status clean. No Flutter/Flame dependency, runtime source-checkout path or map refresh added. PASS. |

Backpack renderer also verifies actual B/Tab/Enter/pointer selection, rod/flower icons,
empty/owned/capacity views, modal input gates and exact separate-process GUI restore.
Capacity displays and forced environment/pose fixtures are explicitly synthetic.
Ordinary F005/F006/F007 renderer journeys use viewport WASD/E/B/GUI/pointer input,
without teleport/grant/selection/save shortcuts. These are debug viewport proofs;
F009 integrated acceptance and F010 exported/native acceptance remain separate.

## Commands, isolation and final source identity

Cwd `D:/development/game-dev-blender/returning-fair-prototype`, PowerShell7;
installed Godot console4.7.2.stable.mono.official.ed1daf0bf, Compatibility/NVIDIA renderer.
Raw evidence is ignored under `docs/evidence/F008/<run-id>`; each runner creates fresh
`builds/testing/F008/<run-id>/appdata` and `localappdata`, independent check slots and
explicitly shared write/read render slots. Normal saves and source checkout untouched.

Arguments below follow `./tools/run_checks.ps1`; each command used `-TimeoutSeconds 150`.

| Run ID | Arguments | Actual result |
| --- | --- | --- |
|20261008-023604025-07197561| -Task F008 -Names foraging_interaction_checks,backpack_ui_checks,world_item_placement_checks,map_camera_checks,environment_lighting_checks,weather_presentation_checks,movement_camera_checks -RenderScript world_item_placement_render -RenderPhases write,read | Seven headless suites PASS (hold103, backpack148, placement128, lighting30053, weather193417 assertions). Ordinary rod authored/generated/drop/drag/recollect, Tollworks return, GUI Save/separate Load/exact prior+item facts/physical recollect PASS;11 captures. |
|20261008-023932515-6c0a4fcc| -Task F008 -RenderOnly -RenderScript foraging_art_render -RenderPhases check | PASS880 assertions,96 captures:72 paused synthetic art/presentation views and24 actual live input views after labeled synthetic setup. |
|20261008-023952938-ee775a1c| -Task F008 -RenderOnly -RenderScript backpack_ui_render -RenderPhases write,read | PASS ordinary owned-item acquisition/keyboard/pointer, icons, small-window/modal views, detached capacity fixture and exact GUI independent restart;10 captures. |
|20261008-024024303-277571c5| -Task F008 -RenderOnly -RenderScript foraging_interaction_render -RenderPhases write,read | PASS ordinary spawn→rod→all three flowers, held/released E, actual four-node removal, GUI Save/separate Load/exact whole-save/revisit absence;15 captures. |

All four final results.json/source manifests/logs inspected: every case exit0, no timeout,
no runtime errors/warnings/diagnostics, source.changed=false and source.error=null.
All share490-file before/after SHA256
`87580ae010b1da7fc06c0928afeddbdad257fe0aef2cbec1c821641cdd72112b`.
Earlier supplementary interaction_dialogue/light_interaction/settings_debug/application
checks PASS in runs023327646-29ef41b0 and023035168-c956232f (20261008 prefix).

Import/parse PASS in022711813-b9b3de37 before its corrected runtime icon failure.
Only narrowly allowed existing editor-only missing .NET SDK10.0.9 diagnostic retained;
no SDK/install action. New SVG import metadata and script UIDs are tracked.

Bundled Python commands:

- `docs/foraging-items-backpack/reference/audit.py --source-root D:/development/game-prototype-2 --self-test`: PASS, six in-memory negative controls, source status clean.
- `tools/capture_evidence.py` with final art-index, and each final renderer's write/read
  index pair: all PASS structural/state/provenance checks;96/10/15/11 source PNGs hashed.
  Derived review directories: art `20261008-024024-2b50c666`, backpack
  `20261008-024111-da0f430f`, gather `20261008-024138-2f88e277`, rod
  `20261008-023944-7b092cfe` under the respective render/derived directory.
- `git -c core.whitespace=cr-at-eol diff --check`: PASS. No Git config change.

## Visual review and retained failures

Reviewed all72 art combinations in six contact sheets, final live combinations in two
additional sheets, and full-size rod night/perspective, flower01 day/orthographic,
flower02 night/wide/perspective, flower03 rain/night/perspective, actual live hold,
red/green preview, all three ordinary approach, backpack rod/flower/capacity small-window
and restored rod absence images. Final art full-size samples confirm camera HUD matches
actual projection/zoom. Modal shade covers field status after the stacking repair.
Capture provenance validation does not itself establish visual quality or native input;
manual image inspection supplies visual findings above.

Retained failed runs (20261008 prefix):022520206-af811127 and022649706-8391e7da
were rejected by source-change guards as import generated metadata/UIDs. The latter also
exposed a Windows-encoded new fixture, repaired to UTF-8.022711813-b9b3de37 failed
because icon_max_width is a Button theme constant, corrected to a theme override.
022753593-b47e1e22 had all six headless suites pass but rod-height fixture comparison
failed at a float rounding boundary, corrected to0.1299m. Visual review then found fixed
HUD-row overlap and modal draw order; both repaired and freshly reverified above.
Earlier successful runs remain supplemental; final claims use final source identity.

Changed production: GameRoot, PrototypeUI, BackpackView, ForagingWorldAdapter;
new ForagingItemVisual+UID, two SVG icons/imports and asset README. Updated two existing
feature check scripts; new foraging_art_render+UID. Updated parent README/architecture
and workflow checklist/current state/contract/this acceptance. No export/publication,
automatic agent/chat/schedule, native OS input or unrelated work.

Every F008 criterion evidenced. All owned runner/game processes exited normally; no
editor/live process or cleanup owed. Next eligible F009; F008 prerequisites verified.
Completed exactly F008; stop before successor.
