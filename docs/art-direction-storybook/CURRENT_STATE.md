# Painted coastal storybook current state

Updated: 2026-10-11 UTC.
[CHECKLIST](CHECKLIST.md) is status authority; [CONTRACT](CONTRACT.md) owns scope; [AGENT_PROMPT](AGENT_PROMPT.md) starts each one-task invocation.

## Current selection

AD001 Done; no active task. All four acceptance criteria verified in [AD001_ACCEPTANCE](AD001_ACCEPTANCE.md). Remaining unfinished IDs: AD002, AD003, AD004, AD005, AD006, AD007, AD008, AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017, AD018, AD019, AD020, all Pending. Final checklist task ID AD020; every item complete: no. No AD001 blocker or required decision remains.

Next eligible task: AD002 - Painted shop and counter material pilot. Exact next action after this stopped turn: read [LOOK_SPEC](LOOK_SPEC.md)/[BASELINE](BASELINE.md), inspect controlled Maris captures and existing town source/UV/material/import ownership, then implement only Maris shop/counter pilot with original outlines/heights/bench bodies/IDs. Do not begin tree, rollout, lighting, HUD, interiors expansions or historical R016.

Implementation stopped for review without a commit. The user has now supplied the separate instruction authorizing the successful AD001 task commit. Commit scope is only the five changed AD001 Markdown files plus the task-local capture fixture and inventory helper; raw evidence and untouched AGENT_PROMPT/CONTRACT/direction/interiors inputs remain excluded. Exact post-commit hash/tree/status and preserved-input hashes are recorded locally in `docs/evidence/AD001/authorized-commit-20261011/commit-audit.json` after the commit. No push or AD002 work.

## Completed baseline and boundaries

LOOK_SPEC translates selected concept into starting sRGB palette/value bands, contrast hierarchy, metre/screen-pixel brush scales, texel density, shared atlas/mip/gutter/color-space rules and exact real-time/NPC/light budgets. BASELINE inventories every current exterior/room/actor/prop/UI family and source/runtime/material/UV owner, preserved IDs/feet/colliders/source pins and fixed camera/pose/time/weather/HUD recipe. Reference SHA verified; actual concept pixels inspected. No claim painted art has been implemented.

Current observation: HEAD8bbf35d8edbc327b1df5aa15a9a2a780af1360c3; Godot4.7.2 stable Mono, Compatibility, schema8/content1. Town/tree/landmark/light kits lack authored UVs/images; named villagers already use UV32x32 embedded palettes. AD002 owns town vertex-color/double-tint and obsolete texture-null test adaptation; AD003 owns texture sampling in canopy shader while retaining MultiMesh and shadow/party visibility.

All18 existing GLBs inventoried with hashes and material/UV/image/clip data; all18 .blend files opened in a separate read-only Blender5.2.2 LTS background process, never saved/exported. Original source/layout/mapping/identity pins retained. No live Blender editor/MCP scene touched.

## Verification and inspected evidence

Cwd: D:/development/game-dev-blender/returning-fair-prototype, PowerShell7.6.5. Installed console path verified before launching.

- Controlled baseline runner: `./tools/run_checks.ps1 -Task AD001 -RenderOnly -RenderScript art_direction_baseline_render -RenderPhases baseline -TimeoutSeconds 180`; engine/parse/render3/3 exit0, no diagnostics/timeouts/source changes. [Results](../evidence/AD001/20261011-044429132-895e7a0f/results.json), [index](../evidence/AD001/20261011-044429132-895e7a0f/render/baseline-index.json). Source digest6aa3a331654ccd7712512d04b5dee6c04ca09ff54f51ffbd14724777e7040f19, files1315 unchanged. EnginePID24404/launcher67304 exited.
- Actual18 PNGs: Maris/Dock Row clear day and night thunderstorm, dense forest, Moonwell, bridge, ford, home, inn, Tollworks/guardian; both projections960x640/zoom1. Synthetic feet/restore/direct transitions/quest prerequisite, frozen routines and review-only environment disclosed. Rendered clock/weather matches preset. Six short paused frame/draw/static+render-memory samples are observations, not AD019 profiling.
- Existing `map_camera_render` with same task/RenderOnly/phase routing passed3/3 exit0; [66-PNG survey](../evidence/AD001/20261011-044217805-f44d2253/render/index.json), including both projections/zoom bounds and synthetic recorded moving poses. Unpinned advancing clock limits this to crop/zoom diagnostics. EnginePID52048/launcher2256 exited.
- Inventory/source audit and `capture_evidence.py` exit0. All18 controlled captures provenance-validated/hash-indexed; [two derived sheets](../evidence/AD001/20261011-044429132-895e7a0f/render/derived/20261011-044525-3937487d/capture-report.json) inspected, plus full-size final Maris day/night/Tollworks and secondary Maris/forest zoom-bound frames. Current image/geometry/texture evidence confirms baseline, not future-look acceptance.

Exact command/tool versions/PNG paths/sample numbers and retained attempts live in acceptance and BASELINE. Initial sandbox CIM provenance failure needed authorized runner escalation. Parse gate caught fixture enum typo. First rendered attempt passed structurally but pixel review found post-startup environment helper detached session without rebinding owners; excluded from final baseline. Fixed task fixture through existing restore lifecycle and added rendered HUD-time check. No production code/helper changed. Source audit retained Blender deprecation/Python location-resolution warnings with successful exit0; no Godot error allowances added.

No ordinary/native input, saves, natural routine replay, builds or full profiling run; none required by AD001. Isolated runner APPDATA/LOCALAPPDATA/save slots and evidence/build children recorded in results; ordinary user data untouched. Final scope/pin audit passed49 hashes,61 local links,20 task rows/exactly AD001 Done and tracked `git diff --exit-code`0. Current game/tools snapshot still matches final runner1315 files/digest above. All owned Godot/Blender processes ended, no held input/editor/standalone-copy cleanup owed.

## Changed scope and preserved work

Task files: LOOK_SPEC.md, BASELINE.md, AD001_ACCEPTANCE.md, CHECKLIST.md, CURRENT_STATE.md in this folder; new game/tests/art_direction_baseline_render.gd and tools/art_direction/baseline_inventory.py. Test excluded by existing tests/* export filters. Raw evidence stays ignored under docs/evidence/AD001 and builds/testing/AD001; no force-add or package edits.

Starting untracked art/direction/, docs/art-direction-storybook/ and docs/interiors-map-migration/ preserved. Existing AGENT_PROMPT.md/CONTRACT.md and all original task definitions retained. No tracked production/art/import/physics/gameplay/save/UI changes; no source checkout refresh. Current latest routine handoff still says R001-R015 Done, R016 Blocked/incomplete after user stop; this AD task neither resumes nor completes its missing native recovery/restart gates. Interiors migration remains separate and untouched.
