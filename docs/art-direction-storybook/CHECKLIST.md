# Painted coastal storybook execution checklist

Prepared: 2026-10-10, America/Vancouver. Goal and architectural boundaries: [CONTRACT](CONTRACT.md).
Target repository: D:/development/game-dev-blender/returning-fair-prototype; Godot application: game/.
This checklist is the sole task-status authority. [CURRENT_STATE](CURRENT_STATE.md) records continuation; [AGENT_PROMPT](AGENT_PROMPT.md) starts a session.
AD001 baseline and AD002 shop/counter pilot are Done. AD003-AD020 remain Pending; next eligible task is AD003.

## Selection and completion

Use statuses Pending, In progress, Blocked and Done. Resume the single In progress task first. Reassess Blocked work only when its recorded blocker has changed; unresolved blockers exclude it and its dependents, not independent ready tasks. Otherwise choose the lowest-numbered Pending task whose prerequisites are verified Done, checking actual artifacts/evidence rather than checkboxes alone. If status/artifacts conflict and selection is ambiguous, record the exact conflict and stop.

Complete exactly one selected task per invocation. Mark it In progress before implementation; stop before its successor. A task may span sessions. Done requires all criteria and evidence; an interrupted or failing task stays incomplete. Update this checklist and CURRENT_STATE after complete and incomplete sessions. No automatic user approval gate is introduced at the pilot checkpoint; stopping after one task gives an assessable result for the next step.

Dependencies describe capabilities; the ready branches after AD008 can be worked independently, but default invocation still selects one lowest-numbered task. Do not select tasks from the older prototype, routine or interiors checklist.

## Task map

| ID | Status | Prerequisites | Observable outcome |
| --- | --- | --- | --- |
| AD001 | Done | Verified current project; no AD prerequisite | Pin art baseline and measurable look brief |
| AD002 | Done | AD001 | Painted shop and counter material pilot |
| AD003 | Pending | AD002 | Painted tree pilot with working canopy visibility |
| AD004 | Pending | AD002 | Paint meadow, dirt paths and elevation surfaces |
| AD005 | Pending | AD004 | Paint river and shore transitions |
| AD006 | Pending | AD002, AD005 | Paint dock, plaza and low-wall modules |
| AD007 | Pending | AD003, AD004, AD005, AD006 | Calibrate storybook day, night and weather lighting |
| AD008 | Pending | AD007 | Accept playable Maris and Dock Row pilot |
| AD009 | Pending | AD008 | Roll painted materials through town buildings |
| AD010 | Pending | AD008 | Extend painted treatment through forest and landmarks |
| AD011 | Pending | AD008 | Unify small props, lights and collectible visuals |
| AD012 | Pending | AD008 | Harmonize existing villagers with painted world |
| AD013 | Pending | AD008 | Harmonize party, guardian and combat cues |
| AD014 | Pending | AD008 | Paint existing Mayor Vale home |
| AD015 | Pending | AD008 | Paint existing Lantern Rest |
| AD016 | Pending | AD008 | Paint existing Tollworks and recovery scene |
| AD017 | Pending | AD008 | Make gameplay HUD fit the painted scene |
| AD018 | Pending | AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017 | Verify integrated visual and gameplay readability |
| AD019 | Pending | AD018 | Profile and optimize painted build within budget |
| AD020 | Pending | AD019 | Deliver local Windows art build and bounded native smoke |

AD001-AD008 establish the in-engine pilot. AD009-AD017 extend the recipe through current content. AD018 integrates the look, AD019 measures/repairs performance, and AD020 produces local packages. Each earlier task includes its own basic checks; final tasks do not excuse earlier defects.

## AD001 - Pin art baseline and measurable look brief

- **Prerequisites and inputs:** No AD prerequisite. Chosen image and prompts in art/direction/2026-10-10; current game/project.godot, asset pipelines, map/environment/routine contracts and actual source files.
- **Work and deliverables:** Create LOOK_SPEC.md and BASELINE.md in this folder. Inventory current exterior/room/actor/prop assets, their material/UV paths and owners; record reference image SHA256, current revisions, preserved IDs/feet/colliders and capture poses. Reuse current camera fixtures where useful. Capture the actual Maris/Dock Row view and a compact town/forest/room baseline using existing rendered review tools; label any injected pose/time as synthetic.
- **Allowed changes and preservation:** Documentation, baseline captures and only the minimal task-local capture configuration needed. No production art/material/lighting/UI changes; no map/source refresh. Record the existing R016 acceptance limitation without reopening it.
- **Acceptance criteria:** Brief translates selected look into palette/value hierarchy, brush scale, texture/texel-density rules and real-time budgets. Every affected asset family has a current owner/path. Before/after views can be reproduced with resolution, camera/zoom, pose, time/weather and HUD mode recorded. Baseline frame/draw/memory samples are observations, not a replacement for full profiling.
- **Verification and evidence:** Reuse map_camera_render, environment_review and existing camera fixtures after inspecting their supported invocation; use current capture tools. Proposed LOOK_SPEC.md and BASELINE.md do not exist yet. Capture/view actual pixels; no unrelated gameplay suite. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD002 - Painted shop and counter material pilot

- **Prerequisites and inputs:** AD001 verified Done. LOOK_SPEC/BASELINE; art/source/alderwake_town_kit.blend; game/world/map_candidate/town_art.gd; imported town kit/mapping; Maris counter visual hierarchy.
- **Work and deliverables:** Author one reusable painted plaster/timber/slate atlas and UV treatment, apply first to Maris's shop and counter/supplies. Save editable texture/Blender sources and portable runtime outputs. Add only necessary material/import handling; prevent exported vertex colors from multiplying the painted palette twice. Keep pilot scoped to identified visuals; document unavoidable shared-material effects.
- **Allowed changes and preservation:** Appearance and export/import wiring only. Preserve mesh mapping names, source base footprints/heights, Maris wrapper/bench bodies, anchors, interaction LOS and ownership. Art may add tiny bevels only within preserved silhouette/footprint contract. No imported light/camera/collision nodes.
- **Acceptance criteria:** Actual Godot shop reads as warm cream plaster, indigo slate and painted timber at gameplay zoom. Broad brushwork survives mipmaps without obvious seams or tiling. Counter/supplies remain legible. Imported texture is packed/resolved; no missing resources, double tint or material explosion; unchanged physical boundaries verified.
- **Verification and evidence:** Reuse map_town_art_checks and relevant asset checks/import. Existing town test explicitly requires albedo_texture == null: replace only that obsolete color-only assertion with meaningful atlas/UV/material checks, retaining inventory/footprint/height guarantees. Run affected interaction check only if integration touched it; inspect both projections. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD003 - Painted tree pilot with working canopy visibility

- **Prerequisites and inputs:** AD002 verified Done. LOOK_SPEC; art/source/moonwood_tree_kit.blend; game/world/map_candidate/tree_art.gd and canopy_visibility.gdshader; tree mapping/batch rules.
- **Work and deliverables:** Paint one representative tree's trunk and grouped foliage, then integrate texture/UV sampling into the existing MultiMesh-compatible visibility material. Prove intended texture/color multiplication and atlas sharing before rolling out all species. Preserve chunked batching and main-view party cutout.
- **Allowed changes and preservation:** One tree family plus necessary shared shader/adapter integration. Keep species/size mappings, instance transforms, source tree bodies, canopy shadow behavior and party-visibility logic. No per-tree runtime material generation or dense leaf geometry.
- **Acceptance criteria:** Painted foliage remains calm and faceted, trunk readable; no black/missing texture, tint error or atlas bleed. Hero and ally remain visible under canopy in orthographic/perspective at zoom bounds. Shadows do not inherit the main-view visibility hole; batching/node/resource counts remain bounded.
- **Verification and evidence:** Reuse map_tree_art_checks, map_camera_checks and canopy/camera rendered review. Extend only obsolete palette assumptions when necessary; prove existing visibility and batching invariants. Inspect close and normal gameplay frames plus motion. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD004 - Paint meadow, dirt paths and elevation surfaces

- **Prerequisites and inputs:** AD002 verified Done. LOOK_SPEC; landscape_materials.gd, landscape.gdshader, terrain_preview.gd, elevation_surfaces.gd; pinned layout/semantic mask.
- **Work and deliverables:** Introduce low-frequency sage meadow variation, warm dirt paths and restrained painted stone/cliff treatment. Use shared texture sampling or a measured simple shader where appropriate; preserve world-aligned scale and semantic edges. Make a material swatch strip in-engine only if useful for choosing texture scale.
- **Allowed changes and preservation:** Ground surface appearance only. No cell/layer/elevation edits, path widening, smoothing of collision, grass geometry carpet or altered dry support/navigation.
- **Acceptance criteria:** Actors/forage stand out against quieter ground. Surface scale is consistent across ramps, plots and seams; brush patterns do not shimmer or repeat conspicuously at both zoom limits. The physical path/river/elevation masks remain identical; materials work in clear and overcast previews.
- **Verification and evidence:** Reuse map_landscape_checks, map_layout_checks and map_camera_checks as affected. Compare same-pose baseline and inspect town/ramp/forest edge in actual Godot. Do not add tests which merely mirror color constants. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD005 - Paint river and shore transitions

- **Prerequisites and inputs:** AD004 verified Done. LOOK_SPEC; river.gdshader, landscape semantic-mask handling, water_blockers.gd and crossing definitions.
- **Work and deliverables:** Retune existing opaque river to sea-green with broad sparse painted ripple/foam strokes; tune shoreline color within existing wet mask. Retain inexpensive world-anchored motion and current surface geometry. Preserve visibility of ford/bridge/dock edges.
- **Allowed changes and preservation:** Water material/painted edge appearance only. No vertex displacement, reflection pipeline, transparency layers, new shoreline geometry, changed water blockers, dry/wet classification or fishing reach.
- **Acceptance criteria:** River matches storybook palette with readable shore and crossing boundaries in daylight and a night sample. Motion remains subtle, stable and inexpensive; water cannot visually cover a dry deck/bank or imply a false walkable crossing. Fishing cues remain distinguishable.
- **Verification and evidence:** Reuse map_water_checks and map_crossing_checks; fishing_targeting_checks or fishing_integration_checks only if affected. Compare actual animated captures and inspect both projections; synthetic time setup labeled. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD006 - Paint dock, plaza and low-wall modules

- **Prerequisites and inputs:** AD002, AD005 verified Done. LOOK_SPEC; town kit/mapping, town_art.gd, dock_surfaces.gd and actual quay/wall visuals.
- **Work and deliverables:** Author shared painted dock-board, muted plaza-stone and low-wall atlas regions. Replace texture-detail repetition with broad readable boards/joints; reuse modules and materials across the screenshot area.
- **Allowed changes and preservation:** Existing module visuals only; preserve dock rectangles, quay cells, walls, collision, deck top height, gaps and navigation. Do not model each tile/plank or add traversal obstacles.
- **Acceptance criteria:** Dock, sandy paths and plaza separate clearly without competing with characters. Shared modules have matching texel scale, no gaps/seams/z-fighting or alpha overdraw; stone contact accents stay local rather than baking a directional sun shadow.
- **Verification and evidence:** Reuse map_town_art_checks, map_town_checks and map_crossing_checks as affected. Inspect river-facing and street-facing views plus an ordinary physical dock approach; retain exact module/footprint assertions. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD007 - Calibrate storybook day, night and weather lighting

- **Prerequisites and inputs:** AD003, AD004, AD005, AD006 verified Done. LOOK_SPEC and painted pilot; environment_lighting.gd, environment_presenter.gd, weather_visuals.gd, exterior light consumers and weather contract.
- **Work and deliverables:** Tune only presentation palette/direct/ambient/shadow values so painted materials stay coherent in clear day, dusk, night, dawn, cloudy/rain/storm. Reuse existing sun, rain, emission and bounded local-light pool. Keep indoor profiles distinct and stable.
- **Allowed changes and preservation:** No new clock, forecast, persistent fields, weather frequency/timing changes or renderer switch. Retain logical lamp overrides, maximum eight active unshadowed local emitters and existing pause/focus/travel holds. Do not depend on runtime GI or expensive post effects.
- **Acceptance criteria:** No crushed characters/paths at night, washed-out plaster at noon or oversaturated rain. Lamps guide attention without lighting every asset; rain/lightning remain readable and pauses freeze the intended effects. Weather/clock/overrides and interior dry profiles behave unchanged.
- **Verification and evidence:** Reuse environment_lighting_checks, weather_presentation_checks, environment_lifecycle_checks and light_interaction_checks when affected. Use existing environment rendered reviews with labeled synthetic condition setup; inspect representative four day phases/four weather conditions, not a forced natural full-day run. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD008 - Accept playable Maris and Dock Row pilot

- **Prerequisites and inputs:** AD007 verified Done. LOOK_SPEC/BASELINE and AD002-AD007 evidence; production Maris/Dock Row scene, current wrapper/navigation/interaction owners.
- **Work and deliverables:** Assemble a concise same-pose before/after comparison of the actual running pilot. Repair palette, UV, brush scale, silhouette, water or lighting mismatches found across its pieces. Save a reusable material/asset recipe and task-scoped pilot acceptance record.
- **Allowed changes and preservation:** Pilot art integration only; do not start town-wide replacement or change physical geography. AI image is appearance inspiration, never coordinate/geometry authority. Existing NPC art and capsule party may remain at this stage.
- **Acceptance criteria:** Pilot conveys selected painted coastal look in-engine, not only Blender/imagegen. Shop/counter/tree/path/dock/river form one coherent scene; walking, Maris approach and party occlusion remain usable. Both projections/zoom extremes and day/night/rain samples inspected; short frame/draw/memory samples reveal no unexplained regression.
- **Verification and evidence:** Reuse affected existing checks from prior pilot tasks, not every suite again. Inspect real movement and contextual interaction in a bounded isolated session. Record qualitative comparison plus actual samples and limitations; no arbitrary pixel-perfect match or full-day acceptance claim. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD009 - Roll painted materials through town buildings

- **Prerequisites and inputs:** AD008 verified Done. Accepted pilot recipe; full town structure/mapping inventory and exterior-light window registrations.
- **Work and deliverables:** Apply painted plaster/timber/roof family across all existing Alderwake building definitions, using restrained variations to distinguish civic, inn, home and teal cottage groups. Reuse atlas regions/materials; keep registered window emission and entrances.
- **Allowed changes and preservation:** No new buildings, roof height changes, door relocation, map content/portal activation or new functionality. Preserve existing mapping names/source IDs and exact ground footprints.
- **Acceptance criteria:** Every current town building covered, no forgotten flat-color facades or UV stretching on rear/side faces. Variations support wayfinding without excessive unique textures. Window on/off and night presentation remain correct; wrapper/portal behavior unchanged.
- **Verification and evidence:** Reuse map_town_art_checks, map_town_checks and light_interaction_checks as affected. Inspect street/river/back views, both projections and a night sample; evidence inventory names every covered definition. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD010 - Extend painted treatment through forest and landmarks

- **Prerequisites and inputs:** AD008 verified Done. Tree pilot/ground recipe; all tree species/size mappings; landmark_art.gd and landmark kit; Moonwood terrain/forage/crossing contracts.
- **Work and deliverables:** Roll tree material treatment through all existing species/sizes and paint current landmark surfaces/forest accents. Keep denser forest visually quieter than actors, forage and route cues; reuse palette/atlas families and chunk batching.
- **Allowed changes and preservation:** No forest population edits, new landmarks, dense foliage carpet, moved Moonwell/bridge/ford, source refresh or changed visibility cutouts/collision.
- **Acceptance criteria:** All current forest species and landmark definitions covered; tree masses remain distinct and navigation routes readable. Party cutout and shadows work in dense stands; forage and interaction markers are discoverable. No new seams, unbounded resources or duplicate art instances.
- **Verification and evidence:** Reuse map_tree_art_checks, map_landmark_art_checks, map_forest_checks and relevant map_camera_checks. Inspect dense forest, Moonwell, bridge and ford at daytime/night and normal motion. Short worst-scene sampling belongs here; final profile remains AD019. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD011 - Unify small props, lights and collectible visuals

- **Prerequisites and inputs:** AD008 verified Done. Accepted material recipe; exterior_light_kit/mapping; Maris supplies and gear; current flowers, rod, fishing effects, vessel/plinth materials and item visual adapters.
- **Work and deliverables:** Apply restrained painted surface/color treatment to current exterior lamps, service props, forage/rod and recovery objects. Use atlas grouping appropriate to scale; protect semantic color/emission cues and avoid texture noise on tiny items.
- **Allowed changes and preservation:** No new items, services, collection rewards, lamp states, fishing rules or physics. Do not change existing interactable footprints/reach, model root units or feedback timing.
- **Acceptance criteria:** Existing prop/item inventory has coherent treatment and no missing textures. Rod, forage, gear states and recovery vessel remain identifiable at game zoom; logical lamp switching/emission still matches state. Tiny objects need no unique large textures or extra light emitters.
- **Verification and evidence:** Reuse asset_pipeline_checks, recovery_presentation_checks, light_interaction_checks and item/fishing visual checks selected from actual changed paths. Inspect affected ordinary interactions; no need to replay unrelated progression for unchanged textures. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD012 - Harmonize existing villagers with painted world

- **Prerequisites and inputs:** AD008 verified Done. NPC_PIPELINE.md, NPC_ACTIONS.md, existing eight named GLBs/sources/reference sheets and npc_visual_presenter.gd.
- **Work and deliverables:** Apply a consistent restrained painted material treatment to existing eight villagers, beginning with Maris as proof and reusing a common texture approach for the roster. Preserve original identity, costume color distinctions, portraits, skeletons, walk/idle and fishing/archive action clips/accessories.
- **Allowed changes and preservation:** Surface finish and palette harmonization only, not replacement faces/costumes/rigs or a new character pipeline. Stay within existing 12,000 triangles/32 bones/3 surfaces and texture-memory budget per NPC. No changes to routines, movement speed, station facing or speech timing.
- **Acceptance criteria:** All eight remain recognizable against town/forest/indoor backgrounds with readable skin/clothing value groups. Existing feet, bounds, armature/clip names and accessories preserved; idle/walk/actions show no texture popping. Original portrait/identity constraints retained and any permitted material-reference adaptation documented.
- **Verification and evidence:** Reuse npc_asset_pipeline_checks, npc_01/02/03/04/06/07/08/14_checks, npc_action_checks and routine_presentation_checks proportionate to modified exports. Inspect static roster plus short representative walk/action clips in Godot; no full routine/day replay. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD013 - Harmonize party, guardian and combat cues

- **Prerequisites and inputs:** AD008 verified Done. Current ActorPlaceholder scenes/feedback code, guardian.blend/GLB, combat and recovery visual contracts; accepted palette.
- **Work and deliverables:** Retune existing hero/ally capsule surfaces and guardian materials to fit painted world while preserving distinctive cyan/purple roles and combat feedback. If textures are useful, use simple shared painted surfaces; improve readable value separation rather than adding geometry.
- **Allowed changes and preservation:** Hero/ally remain current prototype capsules: selected concept's humanoids do not authorize new rig/model/animation scope. Preserve hitboxes, aim/combat markers, cooldowns, damage/health rules, facing and controls.
- **Acceptance criteria:** Hero/ally/guardian separate clearly from grass, water and night backgrounds. Damage, dodge/attack/aim and death cues retain meaning and timing. Replacing capsule characters remains an explicitly recorded future feature, not a false completion claim.
- **Verification and evidence:** Reuse combat_checks, recovery_presentation_checks and application_smoke when affected. Inspect a bounded actual movement/aim/combat sample in both projections; do not change gameplay to make screenshots prettier. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD014 - Paint existing Mayor Vale home

- **Prerequisites and inputs:** AD008 verified Done. Current mayor_vale_home.gd/tscn and R007 acceptance/room furniture bounds; accepted material recipe and stable indoor profile.
- **Work and deliverables:** Apply painted wood/plaster/textiles/books/fireplace surfaces across existing four-room cutaway, reusing common material families. Adjust appearance-only indoor lighting only where needed for palette consistency.
- **Allowed changes and preservation:** No room expansion, moved furniture/cutaway walls/station feet, household access/state changes or new routines. Preserve current nav clearance, party arrival pocket and reciprocal travel.
- **Acceptance criteria:** Home has coherent warm indoor treatment with readable rooms/stations, no texture-scale jump or hidden-contact regression. Party/NPC feet and narrow routes remain clear. Exterior weather never leaks rain/lighting changes into stable room profile.
- **Verification and evidence:** Reuse routine_home_checks, location_travel_checks and affected environment checks. Inspect cutaway at both projections/zoom limits, existing entry/return and one representative stationary/moving contact; synthetic placement labeled. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD015 - Paint existing Lantern Rest

- **Prerequisites and inputs:** AD008 verified Done. Current lantern_rest.gd/tscn and R008 acceptance/room bounds; shared painted recipe and indoor environment ownership.
- **Work and deliverables:** Apply warm painted floor, timber, wall and furniture treatment through existing inn. Reuse home/town atlas families where suitable and differentiate inn with restrained accent colors, without narrative additions.
- **Allowed changes and preservation:** No room/furniture/station movement, booking/sleep entitlement, new services/routines or portal changes. Keep host/party clearances, cutaway and indoor dry/stable presentation.
- **Acceptance criteria:** Inn visually belongs to same game; every existing room/material family covered with consistent scale. Current contacts, entry and return remain visible and physically usable. No extra local emitters beyond justified existing indoor budget.
- **Verification and evidence:** Reuse routine_inn_checks, location_travel_checks and affected environment checks. Inspect entrance, common room and authored routine areas in both projections; verify an ordinary bounded entry/return. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD016 - Paint existing Tollworks and recovery scene

- **Prerequisites and inputs:** AD008 verified Done. Current tollworks.tscn, guardian/vessel/plinth wrappers and static asset contract; selected storybook material language.
- **Work and deliverables:** Apply cooler, worn painted stone/timber/metal treatment to current compact Tollworks. Keep a restrained warm/cool contrast for guardian, vessel and exit so dungeon remains part of same art direction without copying village cheerfulness.
- **Allowed changes and preservation:** No expansion to source map, new encounters, relocated combat/recovery anchors, changed guardian or quest rules. Preserve current stable indoor profile and dry presentation.
- **Acceptance criteria:** Existing room geometry/materials consistently treated; guardian/vessel/exit distinguishable and combat floor readable. No clash between painted environment and recovery props, missing textures, altered collision or weather leak.
- **Verification and evidence:** Reuse asset_pipeline_checks, combat_checks, recovery_presentation_checks and location_travel_checks as affected. Inspect actual room in both projections and one bounded combat/recovery interaction; old release evidence is not acceptance. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD017 - Make gameplay HUD fit the painted scene

- **Prerequisites and inputs:** AD008 verified Done. prototype_ui.gd/tscn and existing conversation/backpack/fishing/people-journal views; LOOK_SPEC value hierarchy and actual small-window captures.
- **Work and deliverables:** Perform a bounded readability pass: compact persistent quest/health/time information, show relevant interaction prompts, reduce overlapping world labels, and use restrained storybook panel colors/typography. Reuse current controls and information sources. Keep debug diagnostics accessible in their existing debug/settings mode.
- **Allowed changes and preservation:** Presentation only; no menu-system rewrite, hidden required quest information, changes to interaction eligibility/priorities, input arbitration or persistent state. Keep unsupported portal labels truthful. No rendered text baked into world textures.
- **Acceptance criteria:** At 960x640 and screenshot-like wide window, HUD leaves world/actors readable, wraps cleanly and shows current usable interaction without overlapping labels. Health/time/quest remain available; dialogue/choices, inventory, journal, fishing, pause/settings and keyboard/mouse focus still function.
- **Verification and evidence:** Reuse settings_debug_checks, npc_dialogue_ui_checks, backpack_ui_checks and fishing_ui_checks only where affected; inspect actual UI states at both window shapes. Verify accepts_world_pointer and modal/pause blocking so compact panels cannot leak clicks into combat. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD018 - Verify integrated visual and gameplay readability

- **Prerequisites and inputs:** AD009, AD010, AD011, AD012, AD013, AD014, AD015, AD016, AD017 verified Done. All rollout evidence and LOOK_SPEC/BASELINE; production scenes and current capture/testing tools.
- **Work and deliverables:** Run one bounded integrated visual/behavior review of complete painted build, repair demonstrated presentation regressions and consolidate coverage inventory/before-after comparisons. Produce AD018_ACCEPTANCE.md; keep verification focused on changed capabilities.
- **Allowed changes and preservation:** No unrelated feature acceptance campaign, indefinite retesting or natural full-day replay. Preserve gameplay/save schema and all source pins. Do not overwrite old evidence or claim historic release gates are complete.
- **Acceptance criteria:** Town, dense forest, bridge/ford and all three existing interiors covered. Normal movement/interaction/occlusion and modal UI inspected. Coverage includes day/dusk/night/dawn, clear/cloudy/rain/storm, both projections and zoom bounds using a compact representative set, not a Cartesian product. No missing art, unreadable required cue, broken physical route or UI/input regression remains.
- **Verification and evidence:** Reuse focused camera/navigation/travel/save/environment/routine checks based on actual changed dependencies, not an indiscriminate full-suite rerun. Inspect real pixels and short moving clips; synthetic poses/weather/time are labeled and do not prove ordinary routine or quest completion. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD019 - Profile and optimize painted build within budget

- **Prerequisites and inputs:** AD018 verified Done. Accepted integrated look; BASELINE; weather/routine profiling contracts; current profile scripts and installed hardware.
- **Work and deliverables:** Measure fresh whole-frame/draw/memory performance at town/dense-forest/bridge/ford, clear day and storm/night, under existing Compatibility method. Repair demonstrated art/material/batching regressions; create a minimal task-owned profiling adapter when old scripts cannot route evidence safely. Save AD019_ACCEPTANCE.md with paired baseline/settings/hardware and raw evidence paths.
- **Allowed changes and preservation:** Do not lower game/capture resolution, disable ordinary actors/weather, loosen targets or delete historical evidence to force a pass. Preserve footprint/interaction fidelity and visual recipe. No scheduler/gameplay rewrite unless a verified prerequisite defect requires a separately recorded decision.
- **Acceptance criteria:** Full measurement follows CONTRACT performance method; declared art target p95<=16.67ms, p99<=25ms, draw p95<=500, process memory<=2GiB and repeated-travel growth<=64MiB with stable counts. Baseline differences and any pre-existing failure are explicit; a failed target leaves task incomplete with exact repair/retry action. Smoke samples are not full profiling acceptance.
- **Verification and evidence:** Reuse tools/weather_lighting/profile_weather.py, tools/map_migration/profile_map.py and routine_performance_profile methods only after inspecting routing/fixtures. Existing weather helper hardcodes W009 and --smoke is 1s/2s/one run; create scoped adapter for AD019 rather than mislabeling results. Warmup10s, three60s runs per view/condition; memory after two warmup round trips and ten further trips/10s idle. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## AD020 - Deliver local Windows art build and bounded native smoke

- **Prerequisites and inputs:** AD019 verified Done. Accepted art integration; current game/export_presets.cfg; current tools/routine_migration build/package/native helpers and their limitations; project testing skill.
- **Work and deliverables:** Build fresh local Windows Desktop and Windows Validation packages containing painted assets; archive/preserve previous packages rather than overwriting unrecoverable outputs. Audit packed resources/exclusions and launch outside checkout. Conduct a bounded native art smoke plus actual GUI Save/normal quit/new-process Load using isolated data.
- **Allowed changes and preservation:** Unsigned local delivery only: no push/publish, installer, web/mobile export or expanded gameplay claims. Do not mark R016 complete or repeat its unfinished full acceptance campaign. Verify helper path allowlists before reuse; add a narrowly scoped art-task adapter if required instead of spoofing an older task ID.
- **Acceptance criteria:** Both current presets start with correct renderer and no missing textures/resources; authoring/reference/evidence files are absent from runtime package. Desktop smoke displays painted town and existing interiors using ordinary inputs; Save/restart restores current state and same art with a new PID. Package hashes, build results, capture provenance and cleanup recorded. This limited smoke is clearly distinguished from full R016 native acceptance.
- **Verification and evidence:** Reuse current package-audit/launcher/native capture support after inspecting supported arguments and ownership guards; use tools/skills/returning-fair-gameplay-testing/SKILL.md for bounded input, observed pause and release save isolation. No exact command is presumed for unbuilt art-specific helpers. Inspect actual native frames; verify ordinary quits and owned process/input cleanup. Follow CONTRACT evidence/isolation rules. Record files/commands/results and inspected capture paths in CURRENT_STATE and completion record; no Done claim for an unrun required check.

## Completion records

Append only after every criterion passes. Record task ID/date; concrete result and changed paths; commands/cwd/actual exit results; inspected artifacts and evidence paths; deliberate adaptations/retained limitations; next eligible task. Never replace historical failures with a summary claiming all checks passed.

### AD001 - 2026-10-11 UTC - Done

Created [LOOK_SPEC](LOOK_SPEC.md), [BASELINE](BASELINE.md) and [AD001_ACCEPTANCE](AD001_ACCEPTANCE.md): measurable palette/value/brush/density/budget brief; all current asset-family source/runtime/material/UV owners; immutable IDs/feet/collider/source pins; controlled actual Godot18-frame town/forest/crossing/three-interior baseline, both projections, and six observational frame/draw/memory samples. Read-only inventory parsed18 GLBs and opened18 .blend sources without saving. Only task-local `game/tests/art_direction_baseline_render.gd` and `tools/art_direction/baseline_inventory.py` added alongside documentation; production art/material/lighting/UI/geometry unchanged.

Repository cwd; `./tools/run_checks.ps1 -Task AD001 -RenderOnly -RenderScript art_direction_baseline_render -RenderPhases baseline -TimeoutSeconds 180` passed engine/parse/render3/3 exit0 in `docs/evidence/AD001/20261011-044429132-895e7a0f/`, unchanged source digest. Existing `map_camera_render` with same routing passed3/3 exit0,66 PNGs in `20261011-044217805-f44d2253/`. Inventory/source-audit and capture-evidence commands exit0. Both derived sheets and critical full-size final/zoom frames inspected; exact commands/results/paths are in acceptance record.

Retained initial CIM sandbox failure, enum typo and excluded stale-session first captures; corrected fixture-only restore binding and rendered HUD time check before final acceptance. All AD001 criteria complete, no blockers/cleanup owed. Short paused samples do not accept AD019; synthetic room/quest/pose/time review does not prove ordinary/native gameplay. Historical R016 incomplete, unrelated direction/interiors inputs preserved. User requested review before separate commit instruction; no commit/push here. Next eligible AD002 only. Remaining unfinished AD002-AD020; final task AD020; every checklist item complete: no.

Authorized commit follow-up (2026-10-11 UTC): user supplied the separate post-review successful-task commit instruction. Commit includes only seven AD001 changed paths and this acceptance/checklist/handoff; untouched planning instructions, direction/interiors inputs and ignored raw evidence stay excluded. Exact commit identity and byte/scope/preservation audit recorded after commit in `docs/evidence/AD001/authorized-commit-20261011/commit-audit.json`. AD001 remains Done, AD002-AD020 remain Pending; no push or successor work.

### AD002 - 2026-10-11 UTC - Done

[AD002_ACCEPTANCE](AD002_ACCEPTANCE.md): painted Reed Chandlery and current counter/supplies/gear pilot using one1024 reusable plaster/timber/slate atlas. Editable sibling .blend/PNG/recipe and background authoring scripts; portable one-mesh/one-surface GLB; shared atlas/mip/clamp wiring. Original town source/export/mappings unchanged;15 unpainted meshes retain palette. Narrow town-test material/UV adaptation retains every inventory/height/footprint/physics invariant. All500 shop triangles match original;48 original source/runtime pins and counter nonmaterial content verified unchanged.

Repository cwd; `./tools/run_checks.ps1 -Task AD002 -Import -Names application_smoke,map_town_art_checks,recovery_presentation_checks -RenderScript art_direction_shop_render -RenderPhases pilot -TimeoutSeconds 180` passed7/7 exit0 in `docs/evidence/AD002/20261011-050946355-a0b97d26/`, unchanged1326-file source digest`b7366860625c020db2a2a978b3c94a8012c59f0681248da149948d585ddc4618`. Actual20 synthetic frozen Godot captures: both projections/zoom bounds, clear day/night storm, six close angles/three checker views/three counter states. Both provenance sheets and critical full-size frames inspected. Authoring, packed-image/geometry/pin audit and capture-evidence helper exit0. No missing texture, double tint, UV gap/atlas bleed or physical regression. Counter lifecycle/dialogue/cancel/travel/synthetic restore passed.

Retained failed import/fixture/palette/export attempts and exact corrections in acceptance; no allowances weakened. Existing.NET editor warning only. Two resident RGB8 atlas copies (portable embedded import plus active shared runtime image) cost8MiB total with full mips; no per-instance material/node expansion. Every AD002 criterion complete, no blockers/unrun checks/cleanup owed; owned enginePID20844/launcher21568 and all attempt processes exited. Original direction/interiors/instructions, schema8/content1 and historical R016 incomplete status preserved. No ordinary/native route/build/new-process GUI Load/full profiling claim. User requested separate post-review commit instruction; no commit/push here. Next eligible AD003 only. Remaining unfinished AD003-AD020; final task AD020; every checklist item complete: no.

Authorized commit follow-up (2026-10-11 UTC): user supplied the separate successful-task commit instruction after review. Commit contains exactly20 AD002 task paths, including this acceptance/checklist/handoff; unrelated direction/interiors/prompt/contract inputs and ignored raw evidence stay excluded. Validated source bytes and preservation scope verified; exact commit identity/tree/status and audit recorded after commit in `docs/evidence/AD002/authorized-commit-20261011/commit-audit.json`. AD001/AD002 remain Done, AD003-AD020 Pending. No push or AD003 implementation.
