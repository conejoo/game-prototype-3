# Grass pilot GRASS01

Date: 2026-10-12 local / 2026-10-13 UTC. User requested a focused grass iteration after rejecting the broad storybook result.

**User selected A as the preferred grass material. Depth/grounding remains unresolved; no wider rollout authorized by that preference alone.** AD001-AD020's historical completion does not establish reference fidelity.

Review: [interactive comparison](../../art/direction/2026-10-12-grass-pilot/index.html). Untouched target, original game grass, and three actual Godot candidates. All copied engine PNGs preserve original bytes; [manifest](../../art/direction/2026-10-12-grass-pilot/manifest.json) pins hashes. Original reference SHA256: `57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a`.

## Implemented

Opt-in grass material on existing ground mesh within world XZ rectangle (-20,-3,20,17), near Maris/Dock Row. Shared generated gouache albedo contains identifiable blade/leaf groups, broad green patches and sparse cream flowers. A 128x128 visual mask changes texture mixing near foundations, trunks and dirt/stone boundaries. Mask has no physics/navigation role. Grass sample color is calibrated to the existing ground's linear authoring convention in GL Compatibility.

| Variant | Tile span | Blend | Edge mix | Intent |
|---|---:|---:|---:|---|
| A | 6 m | .82 | .12 | smaller, quieter marks |
| B | 8 m | 1.0 | .30 | clearer botanical groups; original agent recommendation |
| C | 10 m | 1.0 | .48 | larger marks and stronger edge variation |

Original grass stays default. Launch source project from repository root, with installed console Godot:
```powershell
& 'D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe' --path game -- --grass-pilot=a
```
Use b/c for other candidates; omit flag for original. Existing Windows packages remain the AD020 packages, without this pilot.

Texture source and exact generation prompt: `art/source/storybook/grass-pilot-albedo-v1.png` and `grass-pilot-recipe.json`. Runtime copy under `game/assets/environment/storybook/`. Actual generated/imported dimensions 1254x1254; mipmaps enabled. No image generation was used on engine captures.

## Evidence

[Final run report](../evidence/GRASS01/20261013-001039914-38e60dec/results.json): engine version, parse preflight, application_smoke, map_landscape_checks, map_camera_checks and render-compare all passed. Source fingerprint unchanged during run: `301423edf52dd6243ac2c5596d0009862d6d4b8f19165b4a3d9f06530d2c5384`.

[Capture index](../evidence/GRASS01/20261013-001039914-38e60dec/render/grass-index.json): 29 actual Godot captures. Fixed detached synthetic feet/camera/day/weather; HUD and Label3D hidden only inside review fixture. Overview/detail at1440x960; all four choices also at960x640 in both projections. Short original/B pan sequences and B night/rain capture included. This is not ordinary gameplay evidence.

Semantic mask, terrain/water/riser vertices, floors, levels/slopes/cliffs, six terrain batches and daytime node count4071 matched before/after material switches. Existing landscape and camera checks also passed. Inventory is compared before night/rain; existing weather nodes are excluded from the grass-only node gate.

Original/B short paused samples: both248 p95 draw calls; frame p95 respectively2.312/1.893 ms (see index for authoritative values). Timing does not prove a speedup or certify real-time cost. Texture-memory counters include transition cleanup/cache and are not a clean incremental allocation measurement. Estimated decoded RGBA8 albedo+mips approximately8 MiB, plus16 KiB context; driver allocation can differ. Enabled grass adds two albedo samples and one mask sample; no additional geometry/draw calls.

## Visual judgment and remaining gaps

First engine pass rejected: detail existed, but texture appeared luminous. Preserved failed run `20261013-000629672-6f9b0997` also caught fixture node inventory spanning a weather change. Corrected color calibration and measured grass inventory before weather switch. Earlier parse failure `20261013-000548963-8e96a5ed` retained; fixture used RAIN instead of existing RAINY enum.

Corrected captures show blades, leaves and flowers at normal scale. A is the user-selected starting point; user specifically identified missing depth at houses, dirt paths and stone walls. Still below target: ground detail is flat; path silhouettes remain hard/stair-stepped; repeated botanical groups remain detectable. Buildings, lighting and water remain visibly different and are outside this pilot. Rectangular fade is the temporary pilot boundary.

## Next visual gate

User requested stepwise fresh-agent work. New [grass-depth checklist](grass-depth/CHECKLIST.md) and [reusable prompt](grass-depth/AGENT_PROMPT.md) own the next iteration. Five GD tasks start Pending; planning has not launched implementation.

User chose A. Keep its texture/color/scale stable for a proposed focused depth pass; do not treat material preference as depth acceptance or a global rollout request.

For a follow-up, keep this same patch/camera and compare target, original and candidate together. Require visible botanical groups at960x640, sparse flowers, varied patch density, believable wall/path growth, no luminous grass, no obvious seams and bounded pan inspection. Record failures explicitly. Small neighboring-pixel deltas or improvement over the old game cannot establish target fidelity.

Proposed next pass: same A patch, one house foundation, one stone wall and one path corner. Inspect existing contact/cast shadows, add narrow grounding cues and irregular edge overlap, then sparse upright clumps. Daylight currently uses broad ambient fill and a near-overhead sun; shadows are already enabled. Compare A-only against A plus these depth cues at normal zoom. Other asset improvements will not automatically supply these ground-contact cues. Breaking repeated clusters remains later work. Keep art-only geometry separate from collision, record actual engine pixels and draw/texture cost, and obtain visual acceptance before wider rollout.
