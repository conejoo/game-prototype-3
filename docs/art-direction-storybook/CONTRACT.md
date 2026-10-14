# Painted coastal storybook art contract

Prepared: 2026-10-10, America/Vancouver. Planning only.
[CHECKLIST](CHECKLIST.md) owns task status; [CURRENT_STATE](CURRENT_STATE.md) owns continuation.

## Accepted goal and authority

User selected style 1, Painted Coastal Storybook, and requested small sequential implementation tasks. Deliver that appearance in the existing Returning Fair Godot game: warm brush-painted plaster/timber, indigo roofs, sage/olive ground, apricot paths and sea-green water; welcoming, lived-in village with readable characters and economical reusable assets.

Authoritative look reference: [chosen render](../../art/direction/2026-10-10/01-painted-coastal-storybook.png), SHA256 57cbfbbaF4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a (case-insensitive hex). [Exact generation prompts](../../art/direction/2026-10-10/prompts.json) supply provenance, not implementation instructions.
Original screenshot: C:/Users/aldoc/Pictures/Screenshots/Screenshot 2026-10-10 115849.png. AD001 may retain a project-local reference copy if available. The chosen image is already in the project; missing external screenshot alone does not block the plan.

This is AI-generated concept art, not measured Godot output. It guides palette, brushwork, material hierarchy and mood. Actual target maps, asset mappings, IDs, collision, navigation, actor identity and existing source pins own geometry/behavior. Do not rebuild invented flowers, props, humanoid party replacements, roof heights or roads simply because they appear in the concept. A visual difference is not permission to change game geography.

## Scope and exclusions

Scope: current Alderwake town/river/Moonwood; existing Mayor Vale home, Lantern Rest and compact Tollworks; current props/items, existing eight villagers, guardian and current party placeholders; a bounded HUD readability pass. Use already-created GLB/Blender assets, sources and native GDScript/material pipeline.

Exclude new maps/rooms, full source-map migration, new services/items/quests/routines, redesigned characters/portraits, replacement party rigs, new combat features, economy/sleep/home ownership, renderer migration and web/mobile deployment. Art work must not change save/content versions. Hero/ally remain prototype capsules with improved finish and readability; replacing them is future scope.

The separate [interiors workflow](../interiors-map-migration/CONTRACT.md) owns new/expanded maps. These art tasks style only rooms actually implemented at task start. Do not wait for all IM tasks or execute its selector. If an IM task changes a shared room during this workflow, inspect/reconcile actual ownership and record precise overlap before editing; disjoint ready work may continue. New maps can reuse the completed material recipe later through a separately scoped extension.

## Verified project baseline

Workspace: D:/development/game-dev-blender.
Repository: D:/development/game-dev-blender/returning-fair-prototype.
Godot project: D:/development/game-dev-blender/returning-fair-prototype/game.
Entry: res://app/game_root.tscn; typed GDScript, Godot 4.7.2 GL Compatibility, 960x640 baseline.
Planning HEAD: 8bbf35d, chore: package R016 and record incomplete native acceptance. This is an observation, not a reset target. AD001 records full current revision and user changes.
[SaveCodec](../../game/core/save_codec.gd) currently accepts schema8/content1 only. Reinspect actual code when starting; older root/map/weather handoff schema numbers are historical.
[Routine handoff](../day-clock-npc-routines/CURRENT_STATE.md) records R001-R015 Done and R016 Blocked/incomplete following user-requested stop/as-is commit. This plan neither resumes R016 nor certifies its missing native recovery/restart criteria. Its limitation is not a blanket blocker for independent art work; use fresh bounded art evidence.

Existing relevant ownership:
- [Town adapter](../../game/world/map_candidate/town_art.gd) loads a named GLB kit/mapping, duplicates StandardMaterial3D surfaces and enables vertex colors. Texture integration must account for these multipliers. The current town art test explicitly forbids albedo textures; deliberate art-contract changes need meaningful replacement assertions, not broad test deletion.
- [Tree adapter](../../game/world/map_candidate/tree_art.gd) batches meshes in chunked MultiMesh groups. [Canopy shader](../../game/world/map_candidate/canopy_visibility.gdshader) currently multiplies COLOR by base_color and ignores imported albedo textures. AD003 must integrate texture sampling while preserving main-camera party cutout and intact shadow pass.
- [Landscape materials](../../game/world/map_candidate/landscape_materials.gd), [ground shader](../../game/world/map_candidate/landscape.gdshader) and [river shader](../../game/world/map_candidate/river.gdshader) use world-space coordinates and semantic masks. Physics/elevation/wet support are separate owners.
- [NPC presenter](../../game/features/npcs/npc_visual_presenter.gd) owns replaceable art/animation presentation under VisualRoot. Existing routines, achieved movement and holds own behavior.
- [Camera rig](../../game/app/camera_rig.gd) supports orthographic and 45-degree perspective; zoom range 0.8-1.15. Preserve world/input transforms.
- [Static asset pipeline](../../art/exports/PIPELINE.md), [NPC pipeline](../../art/exports/NPC_PIPELINE.md) and [action contract](../../art/exports/NPC_ACTIONS.md) own existing export/rig constraints. Their historical color-only material policy may be extended by scoped painted-UV/atlas rules, retaining roots, units, mapping names, animation clips and physical boundaries.

## Appearance and asset rules

AD001 writes LOOK_SPEC.md with measurable application of selected reference: palette swatches/value hierarchy, broad brush scale at game zoom, texel density, shared atlas families and reproducible views. Those filenames are proposed deliverables, not existing files or a second user approval gate.

- Keep low-poly silhouettes and current module footprints. Add depth through painted albedo and local contact accents under eaves/at joins; do not paint a fixed directional cast shadow which contradicts moving sun.
- Use calm low-frequency texture variation; ground carries less detail/contrast than actors, forage and useful interactions. Avoid full-scene outlines, heavy noisy brush overlays and detailed modeled roof tiles.
- Default to shared 1024px albedo atlases, opaque matte materials and mipmapped textures. Environmental 2048px atlases require measured density/memory justification. Reuse atlas regions/material resources; no unique material/texture per prop instance. Record texture bytes and import settings rather than assuming atlasing reduces every draw call.
- Preserve UV seams/gutters/mips and color-space handling. Never stretch a reference image over unrelated surfaces. Front/back/sides must receive intentional texture coverage.
- Texture-paint software/imagegen may create supporting albedo assets when appropriate. AI concept image itself is not a ready-made projected building texture. Final runtime assets must resolve locally without generator/source checkout/network.
- Save editable authoring sources under existing art/source, with a storybook subfolder for new shared textures/recipes where useful; runtime assets under game/assets. Choose sibling/versioned sources for significant replacements, retain recoverable originals and preserve stable imported identifiers as needed. Record exact final source/export/import paths per task.
- Blender studio rigs are authoring-only. Godot owns lighting. Use one metre per unit, ground-centred identity asset roots and existing glTF axis conventions. Do not import lights/cameras/collisions or change wrapper transforms to compensate for bad export.
- Named NPC caps remain 12,000 triangles, 32 bones, 3 material surfaces and one RGBA1024 atlas (4MiB before mipmaps) per person. Preserve all original costume/identity references, portraits, feet, walk/idle loops and authored action clips/accessories. Any changed material-only reference expectation needs a narrow documented adaptation, not replacement of pinned originals.
- Preserve tree batching/party visibility and all existing geometry/physics/station/portal/source pins. No new durable presentation fields, routine clock or authored gameplay effects.
- Existing sun/weather/environment owners remain. At most eight pooled active unshadowed exterior local emitters including fades, current override semantics and indoor profiles preserved. Use emission for the rest. No dependency on runtime GI, screen-space reflections, volumetric fog or expensive blur.

## Tools, checks and evidence

Installed console: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Installed editor: D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64.exe.
Check these before searching/installing. Engine installation is not the project. Use PowerShell7 for tools/run_checks.ps1.
Blender pipeline documents currently record Blender5.2.2 LTS/existing MCP; verify actual connection/version and preserve unrelated live scenes before use. Tool availability alone proves neither connection nor completed work.

Existing bounded runner example from repository root:
~~~powershell
./tools/run_checks.ps1 -Task AD002 -Import -Names application_smoke,map_town_art_checks -TimeoutSeconds 180
~~~
This example belongs to AD002 execution, not the planning session. Select the task's actual affected checks rather than running every suite. The runner provides unique reports under docs/evidence/<task>/<run> and isolated data under builds/testing/<task>/<run>. Use targeted imports/checks for asset edits and inspect actual rendered Godot frames; no fake headless visual acceptance.

Read [PLAYTEST](../../tools/PLAYTEST.md) and project [testing skill](../../tools/skills/returning-fair-gameplay-testing/SKILL.md) before live/native interaction. Bounded inputs, verified pause checkpoints, exact capture provenance and owned cleanup apply. Native release ignores debug save-slot arguments; use isolated APPDATA/LOCALAPPDATA and verified override.cfg custom user directory per current helper contract. Never read/write ordinary user saves as test data.

Existing review scripts and fixtures are reusable methods, not evidence of the new look. Inspect arguments before running. Old profile/build helpers hardcode W009/R016 paths and guards; a proposed task-local adapter under tools/art_direction/ must be implemented before use and retain isolation/ownership guarantees. Do not route new art acceptance into another workflow or weaken path guards. Package authoring/reference images/evidence outside game; audit imports/inventory rather than assuming export excludes every unused asset.

Raw evidence stays ignored under docs/evidence/ADxxx and builds; keep small durable acceptance summaries here and reusable fixtures where existing conventions place them. Synthetic pose/time/weather setups must be labeled. A rendered fixture is not ordinary play; Blender/imagegen is not engine output; GUI Save needs observed UI outcome and native restart needs a new PID.

Verification should be proportionate. Each asset task validates its own basic correctness immediately. Final visual integration/profile/native tasks cover combined behavior and do not postpone known UV/physics failures. Use a compact coverage set across camera/zoom/time/weather dimensions, not every Cartesian combination. No new test for a trivial color constant; retain meaningful inventory/units/mapping/physics/resource guarantees.

## Performance target and final delivery

AD001 records reproducible current samples; AD008 uses short pilot samples to detect obvious regressions. These do not replace AD019 full profiling.
Retain the existing weather/map method: Compatibility, 960x640, orthographic zoom1, VSync0/max_fps0; declared machine/hardware/driver; town/dense-forest/bridge/ford; clear day and storm/night; 10s warmup then three60s runs each. Art target: whole-frame p95<=16.67ms, p99<=25ms, draw-call p95<=500, process memory<=2GiB, growth<=64MiB after two warmup round trips plus ten further trips and10s idle, with stable nodes/resources/effects.
Historical routine contract includes a paired-baseline allowance for whole-frame timing. Record its actual current baseline separately; do not silently use that allowance to loosen this art target or claim a pre-existing failure was caused/fixed by art. If a target cannot be met, document failing scene/settings, before/after and next repair; leave AD019 incomplete.
Do not extrapolate historical RTX4070 Laptop measurements to other machines. Do not use --smoke results as full performance acceptance.

AD020 delivers fresh local Windows Desktop/Windows Validation using actual current export presets and bounded native visual/save-restart smoke. Preserve previous packages and isolated user data. This is not full R016 routine/recovery acceptance. No automatic commit, push, publication, schedule or delegation; documentation planning starts no implementation task.
