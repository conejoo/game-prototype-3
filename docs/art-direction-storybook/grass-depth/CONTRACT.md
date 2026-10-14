# Grass depth contract

Goal: make user-selected grass A feel grounded around one existing building, stone wall and adjacent dirt corner. Preserve A's restrained painted character. This workflow plans a local depth iteration, not a town-wide rollout.

## Authority and scope

Project: D:/development/game-dev-blender/returning-fair-prototype. Godot application: game/. Workspace instructions: D:/development/game-dev-blender/AGENTS.md.

User decisions: A preferred over B/C; remaining issue is flat grass and clean object/ground boundaries. [Grass pilot record](../GRASS_PILOT.md) owns historical GRASS01 implementation/evidence. [Checklist](CHECKLIST.md) selects GD work; old AD001-AD020 checklist must not select it.

Look authority: [untouched target](../../../art/direction/2026-10-12-grass-pilot/target.png), SHA256 57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a. Target is painted concept, not proof of achievable pixels, geometry or engine performance.

A-only authority: [normal orthographic](../../../art/direction/2026-10-12-grass-pilot/gameplay-a-ortho.png), [normal perspective](../../../art/direction/2026-10-12-grass-pilot/gameplay-a-persp.png), [diagnostic close view](../../../art/direction/2026-10-12-grass-pilot/detail-a.png). A parameters: tile6m, blend.82, saturation.80, edge.12, value1.0. Preserve generated albedo bytes: game/assets/environment/storybook/grass-pilot-albedo-v1.png SHA256 3faa39cc29b5aabb53913a5f6402f820b143abff0ac3f68f65d4c217fd75cbef. Do not solve depth by making A denser/brighter or substituting B.

Existing pilot world XZ rectangle: (-20,-3,20,17). All new depth work stays inside it and focuses on:
- Building: mill-road-schoolhouse-exterior-building, foot(-16,0,2).
- Wall: mill-road-school-garden-wall-south, foot(-16,0,5).
- Closest suitable dirt/grass corner near that wall's east end. GD001 resolves exact point from current visible terrain and pins it; do not assume collision bounds equal visible model bounds.

These IDs exist in game/content/maps/alderwake_layout.json. Current layout and actual geometry own geography; concept does not authorize moving them.

## Preserve

Keep terrain semantics, existing terrain/water/riser vertices, collider geometry, walkable lane, navigation, elevations, prop IDs, doors/stations, actors, camera/input, weather rules, saves and gameplay unchanged. Added decorative tuft meshes are allowed; enumerate their separate geometry/resources rather than claiming all render geometry stayed identical.

New cues stay opt-in and reversible. Existing no-flag rendering and A-only comparison remain available. Existing A CLI: Godot --path game -- --grass-pilot=a. Depth controls are proposed and must be implemented/documented in GD001/GD002 before anyone cites them as working.

No global lighting retune, other asset redesign, package rebuild, commit/push, deployment, new rooms or unrelated checklist work. Diagnose broad lighting issues, record them for later; a local candidate must not depend on silently changing sun/weather across the world.

## Current architecture and tool facts

GL Compatibility; installed console:
D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe.
Editor: same directory, Godot_v4.7.2-stable_mono_win64.exe. Verify paths; engine install is not project.

Runtime inputs:
- game/world/map_candidate/grass_pilot_material.gd and grass_pilot.gdshaderinc: existing texture/context and A/B/C parameters.
- landscape_materials.gd, landscape.gdshader, terrain_preview.gd: shared ground batches and material integration.
- game/features/environment/environment_lighting.gd and environment_presenter.gd: sun shadows already enabled; broad ambient fill and near-overhead daytime light contribute to compressed depth. Do not assume turning shadows on is a fix.
- game/tests/grass_pilot_render.gd: existing actual-render fixture. Its short pan/performance/night samples currently use B, not chosen A.
- game/tests/art_direction_ground_render.gd: physical inventory helper; it does not fully hash every collider. Extend meaningful protection where required.
- game/tests/environment_review.gd: detached synthetic day/weather presets. Day preset0=.05 progress; night preset2=.625. Weather enum RAINY, not RAIN.
- tools/run_checks.ps1 and [versioned testing skill](../../../tools/skills/returning-fair-gameplay-testing/SKILL.md): isolated saves/evidence, parse/source-change gates, owned-process cleanup.

Use fresh source/Git inspection; existing uncommitted GRASS01 changes are prerequisite work, not disposable leftovers.

## Visual and cost gates

Evaluate three contacts separately: building base, wall base, dirt corner. Target cues: narrow grounding, irregular vegetation overlap, occasional upright silhouettes. Use Missing/Partial/Clear descriptions with named actual screenshots; these judgments are not automated similarity scores.

Compare A-only, individual cue toggles and cumulative candidate at identical camera, viewport, sun, weather and character positions. Target context remains visible alongside them. Inspect960x640 orthographic/perspective; closeups diagnose but cannot establish normal-scale success. Include short pans, day and night/rain with A, and one ordinary HUD view for actor/path readability. Label all synthetic placement/time/camera controls. Do not infer ordinary movement or broad performance from frozen captures.

Starting implementation ceilings for this small patch: <=64 new clumps, <=1536 new triangles, <=2 shared visual mesh/material batches, measured <=4 extra draw calls in the matched review view, <=2MiB added decoded texture storage including mipmaps. These are conservative project limits for this experiment, not engine limits or a promised FPS. Prefer opaque simple meshes; if cutouts are used, inspect overlap/overdraw and sorting. No blanket grass field, wind animation, expensive displacement or full-screen AO requirement.

Record draw calls, triangles/instances, new texture formats/dimensions and matched short timings; timings must describe warmup/scenario/sample length and cannot prove speedups. If limits or look criteria fail, revise within this patch and retain failed evidence.

Passing implementation checks does not establish art acceptance. GD005 Done means independent review and usable comparison delivered. User's depth decision remains explicit Pending until the user accepts or requests repairs. Wider rollout is outside this workflow even after review.


## User density revision — 2026-10-13

User found the original nine upright clumps extremely sparse with too little visible difference and requested more density/tufts. GD004 reopened for fuller local coverage around the same three contacts, keeping selected A bytes/parameters, geography, clearance and existing cumulative budgets. Verified revision36 upright clumps; implementation details/evidence in [GD004_DENSITY_REVISION](GD004_DENSITY_REVISION.md). This supersedes the original nine-clump visual recommendation, not the A pin or wider-rollout boundary. User visual acceptance remains Pending.


## User softness revision — 2026-10-13

User rejected current grass as darker/thicker than the painted concept and requested lighter green, thinner clumps plus lower-contrast, softer background details. This explicit request supersedes the prior fixed A appearance rule for the revised candidate. Keep the original albedo bytes, tile/blend/saturation/edge/value parameters, geography, local coverage and resource ceilings. Preserve original A appearance through `--grass-look=original`; revised A defaults to softened sampling/contrast. No B substitution, new texture, global light change or rollout. GD005 reopened for this bounded repair and renewed visual review; user acceptance Pending.


## User painterly/density revision — 2026-10-13

User finds softness revision better but requests ground with fewer sharply defined grass blades and a more painted/artistic surface, plus denser 3D grass. This authorizes a sibling painterly texture and denser local vegetation, superseding candidate-only original-albedo-use/placement pins. Preserve original albedo bytes and original-look comparison. All physical geography, pilot scope, lights, gameplay and existing cost ceilings remain. Rebalance triangles before adding clumps. GD005 reopened for bounded repair; user acceptance Pending.
