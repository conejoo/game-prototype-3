# Grass depth current state

Current follow-up: [reference meadow revision](../MEADOW_REFERENCE.md),2026-10-13. The user's subsequent request supersedes the opt-in-only scope below: normal source startup now enables revised grass globally. This file retains the earlier GD005 local-pilot evidence; use the meadow revision for current behavior and verification. Prior A/depth modes remain available through their original launch flags. Packages were not rebuilt.

Updated2026-10-13 America/Vancouver. [Painterly/density revision](GD005_PAINTERLY_DENSITY_REVISION.md) owns current source, findings and evidence; prior softness pass remains historical comparison.

## Selection and decision

GD001-GD005 Done. GD005 repaired again after user requested more painted/less defined ground and denser3D grass. User visual acceptance **Pending**. No next eligible GD task or automatic rollout/package/export/commit/push. Review new candidate; further requests require explicit user direction.

## Current implementation

Runtime `--grass-pilot=a --grass-depth=tufts` uses new painterly sibling texture and fuller grass. `--grass-look=original` preserves original A/36-clump reference. Prior lighter/thinner/softer candidate is preserved as real archived captures, not another runtime flag. B/C and no-flag behavior unchanged.

New asset game/assets/environment/storybook/grass-painterly-albedo-v2.png,512x512 RGB8+mips, decoded1,048,575 bytes; SHA2563403c6abe54defa85074480d1fc07efeeb381760fdb186b4d8db2000964b80fa. Built-in imagegen style transfer, original texture+untouched town references. Full source art/source/storybook/grass-painterly-albedo-v2.png, exact prompt/provenance in grass-painterly-recipe-v2.json. Only RGB/Lanczos downsample for runtime. Original A albedo bytes3faa39cc29b5aabb53913a5f6402f820b143abff0ac3f68f65d4c217fd75cbef retained. Tile6/blend.82/saturation.80/edge.12/value1; revised contrast.60/bias.15, original1/0. User request authorizes sibling texture and denser local placement; fixed candidate appearance pins superseded.

Upright36->52 groups,305->548 blades (~80% more). Thin widths/green palette retained,16 additional selected-contact roots. Upright2 triangles/blade (1096), low4 triangles/leaf (356); total64 groups/1452 triangles/2 shared batches/+2 draws/1 new texture (~1MiB decoded). Original geometry path preserved separately. Heightsuprightmax.248145/low.047712m; stone/door/pilot constraints intact. No physics/nav/shadows/wind/transparency. Group ceiling64 reached;84 triangles remain. No physical geography/lights/gameplay changes.

Existing source changes4: grass_depth_tufts.gd, grass_depth_edges.gd, grass_pilot_material.gd, tests/grass_depth_render.gd. Added runtimePNG/import sidecar; generated source/recipe outside game scope. All other game/tools bytes unchanged from prior softness baseline. Texture mip/decoded-size guard added; simplified low-leaf winding repaired after pixel review.

## Verification

[Final run](../../evidence/GD005/20261013-211710294-ea6c46da/results.json) passes engine/parse/smoke/landscape/camera/compare/original.150 actual960x640 captures,0 failures; source.changed=false/error=null,1453 files,fingerprint06971f8a9e852af8bac6d10d9c2a365b0d58b3f9a735c01c043599beb7bdd79b. Rehash clean. Current asset/mip import previously passed unchanged; final GDScript winding repair fully rechecked/rendered. Combined capture provenance150 passes.

CWD repository root, PowerShell7:
`./tools/run_checks.ps1 -Task GD005 -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript grass_depth_render -RenderPhases compare,original -TimeoutSeconds 180`.
Previous stable import run added -Import. Bundled Python capture_evidence.py on both indices and run-local build_painterly_review.py; exact commands/provenance in report. Check slots000/001/002, shared render003, APPDATA/LOCALAPPDATA under builds/testing/GD005/20261013-211710294-ea6c46da. Normal saves untouched.

[QA](../../evidence/GD005/20261013-211710294-ea6c46da/painterly-qa.json): current/original/previous-soft frozen camera/feet/light/weather/snapshots equal. Original four-stage contact pixels reproduce prior reference in both cameras. Protected inventories equal (1318 colliders/824 layer-mask/306 original town geometry, terrain/water/riser/floor/semantics/nav/layout). Repeats stable; four real WASD legs per phase pass after synthetic setup. No native/fresh-start/night-movement/E-interaction claim.

36 final source PNGs individually inspected: all24 current cumulative,8 original contact/close/night/rain,4 current grass-only/low-leaf close. Both cameras/six pans/night/rain/six HUD arrivals covered. [Exact list](../../evidence/GD005/20261013-211710294-ea6c46da/inspected-captures.json). Other114 fresh frames retain provenance. Concept/texture/runtime2x2 proof/viewer inspected. No observed floating/sorting/flicker/clearance fault after winding repair. Ground has fewer recognizable blade-cluster shapes; density fuller at all three contacts. Angular plants/small clover-like flecks/hard path steps/wall seam/broad lighting differences remain. Luma variation similar to previous softness pass, not a claimed further contrast reduction. Art acceptance Pending.

Retained attempts:210756086-147511d7 invalidated by generated .png.import;210939873-064a046a passed but mipmaps missing;211251395-5d6d1165 passed with mips but reversed low-leaf winding found visually. All repaired before final run, no unresolved final hard criterion. No second independent-reviewer claim; repair follows user feedback in same session.

## Package and live state

[Updated viewer](http://127.0.0.1:59859/?revision=painterly) / [offline](../../evidence/GD005/20261013-211710294-ea6c46da/review-package/index.html). Painted/dense + original are150 fresh frames; previous softer look adds75 archived frames from183935192-6201862e, with explicit provenance.210 selectable states/control guards/console pass; exact960x640 copies, side-by-side source pixels, target context. Full viewer screenshot inspected.

ServerPID72244 intentionally retained, rootD:/development/game-dev-blender/returning-fair-prototype/docs/evidence/GD005/20261013-211710294-ea6c46da/review-package, localhost59859. Replaced ownedPID42716 after ownership check; old packages remain archived. GRASS01server15316 preserved. Final renderPIDs37728/40564 exited0; no Godot game/editor, no owned runtime cleanup owed. Optional later exact-PID server shutdown. No successor/rollout started.
