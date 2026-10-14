# GD001 depth baseline specification

Established 2026-10-12 America/Vancouver (run UTC 2026-10-13). Status: GD001 verified; user depth acceptance Pending. Scope and ceilings remain [CONTRACT](CONTRACT.md). No depth artwork exists yet.

## Source and A identity

Untouched [target](../../../art/direction/2026-10-12-grass-pilot/target.png): SHA256 `57cbfbbaf4b011c0e393aa13f3fde3237a722dfd31be62c1e4dc50aa8bac6e8a`. Inspect its small blue-roof house at left, horizontal wall above/right, and nearby grass/dirt elbow: narrow dark roots, irregular leaf overlap and occasional upright blades. Target geography is inspiration only; current map geometry owns contacts below.

A parameters asserted in fixture: tile6m, blend.82, saturation.80, edge.12, value1.0. Runtime albedo1254x1254 SHA256 `3faa39cc29b5aabb53913a5f6402f820b143abff0ac3f68f65d4c217fd75cbef`. Existing mipmapped RGBA8 decoded estimate approximately8MiB plus128x128 R8 context16KiB; this is existing A cost, not added depth texture. Driver allocation can differ.

Source hashes:

| Source | SHA256 |
|---|---|
| grass_pilot_material.gd | 66d2c88f7c012d05d956622de46dad9ec00abfa8c1af7578bee1aacdca4cc551 |
| grass_pilot.gdshaderinc | 1b964611e2ea2d73184a07563ed5082207db5ab2432116fc19856837bd69fbc8 |
| alderwake_layout.json | 7477b17b82025ba6089fdad12bbb86f814cac8bb813d3fe9f7694b3cb53c78be |
| alderwake_town_rollout.glb | f705eeb26c421b508a8b2fcd51d193436a4c6185be012ee325b0cd699a99ca8c |

Full game/tools manifest: [source-before](../../evidence/GD001/20261013-061929137-1e26c96a/source-before.json), fingerprint `986f510c256f3d39a18fd94548cf9c82cfb220107c1f9ad7cd0acdf79f2dc3a5`,1445 files. Final manifest matches; source.changed=false, source.error=null. External target/historical images are outside runner source scope and pinned separately.

Fresh historical-camera captures agree with accepted A. [Pixel comparison](../../evidence/GD001/20261013-061929137-1e26c96a/historical-a-comparison.json): selected-contact crops are byte-identical to historical images in both projections: ortho box(275,90,550,275), perspective(310,115,550,290). Full world differs only in lower water region; river.gdshader uses TIME for brush motion even while simulation is paused. Historical provenance banner is absent from new captures. Neither difference is grass drift. Visual inspection independently confirms A scale/color/marks.

## Exact contacts and shape policy

World axes X east, Z south. Entire experiment stays within X[-20,0], Z[-3,14]. Heights below come from actual loaded visible vertices, not assumed collision footprints. Baseline renderer exports transformed extrema and unique lowest vertices for both props in [grass-depth-index](../../evidence/GD001/20261013-061929137-1e26c96a/render/grass-depth-index.json).

| Contact | Visible geometry and selected segments | Review point XYZ |
|---|---|---|
| Schoolhouse facade | ID mill-road-schoolhouse-exterior-building; foot(-16,0,2). Imported base corners X[-19.3125,-13.09375], Z[.375,1.84375], Y0. South facade base follows Z1.84375. Initial safe decoration/shading segments X[-18.8,-17.3] and[-14.8,-13.3], excluding central door. East return X-13.09375, Z[.6,1.8] available only within same subject. | (-17.7,0,1.84375) |
| South garden wall | ID mill-road-school-garden-wall-south; foot(-16,0,5). Actual visible prism X[-18,-14], Z[4.46875,4.96875], Y[-.2,.6]. Selected south face follows Z4.96875, X[-17.8,-14.2]. North face Z4.46875 may be diagnosed separately. Roots meet terrain around Y0, not buried mesh minimum Y-.2. | (-16,0,4.96875) |
| Dirt/grass corner | Closest clean elbow east of wall: XZ(-12.5,4), about1.78m from wall east/south endpoint. Grass NW; dirt east and south. Exact join arms: Z4 with X[-13.25,-12.5], and X-12.5 with Z[3.5,4]. Semantic cells: (-12.75,3.75)=grass1; (-12.25,3.75)=dirt2; (-12.75,4.25)=dirt2. | (-12.5,0,4) |

Important geography: wall south face is over dirt; even immediately north of its prism terrain is dirt, with grass ending around Z4. Do not invent a grass strip against that wall, move path, shade entire collision rectangle, or draw grass through masonry. Later small weeds may root on existing dirt; terrain semantics remain unchanged. Initial investigation point(-12,5.5) was inside dirt, corrected before final captures/spec.

Full building render AABB includes slight decorative protrusions X[-19.3225,-13.08375], Z[.365,1.85675], Y[0,2.46]. Those protrusions/roof are not a foundation footprint. Future masks must follow the base segments above and actual local terrain, remain narrow/soft, and avoid central door/interaction feet. No mask or depth visual was added in GD001.

## Capture contract

All17 final PNGs are actual Godot GL Compatibility960x640, synthetic frozen scene, detached review session. Hero feet(-5.99598,0,10.58022); companion(-4.48361,0,10.28353). Neither synthetic camera placement nor pan proves normal movement. HUD/Label3D hidden except named HUD image; no label painted over world captures.

Historical view aim(-10.5,0,6.5). Selected-contact view aim(-14.7,0,3.5). Both use camera offset(10,14,16), size18, FOV45, zoom1, same orientation. Close ortho size8; close perspective offset*.55, FOV45, same aim. Pan takes offsets X0,.08,.16m from contact aim, preserving other conditions. Camera transform, viewport, projection, party positions, environment snapshot and actual light values are recorded per capture.

Day: day_index2, progress.05, fully blended SUNNY. Night: day_index2, progress.625, fully blended SUNNY or RAINY. Existing review helper selects deterministic real weather seed; exact seed/snapshot in each capture. Exposure1 throughout. Night rain particles advance during frame settling; do not claim particle-frame matching in future pairs.

| View | Facade pixel | Wall pixel | Corner pixel |
|---|---|---|---|
| a-contacts-ortho | (420.76,256.56) | (413.13,331.79) | (536.91,353.69) |
| a-contacts-persp | (430.30,266.77) | (416.96,331.12) | (535.66,352.94) |
| a-close-ortho | (346.71,177.25) | (329.53,346.53) | (608.05,395.80) |
| a-close-persp | (396.02,230.06) | (363.53,340.54) | (586.18,382.85) |

Diagnostic regions in a-close-ortho: facade around x240-675/y125-295; wall x190-490/y245-400; corner x570-650/y350-430. These are descriptions for inspecting source pixels, not replacement rendered crops. At normal scale all three contacts are visible without enlarging image.

## Inspected visual baseline and light audit

All final captures listed below inspected at original960x640 with view_image. Target original and historical normal ortho/perspective/detail also inspected.

1. Grounding: **Partial** at facade (dark base trim exists), **Missing** clear ground contact falloff at wall south face. See a-contacts-ortho/persp and a-close-ortho/persp. Wall dark side is surface shading; it does not establish a grounding band on dirt. No obvious physical floating gap; visual attachment remains weak.
2. Irregular joins: **Missing** at named facade/wall/corner. Painted marks stay flat within clean object/terrain boundaries. Corner has hard half-metre steps and a bright edge. Wall has an existing dotted/top seam; no new seam introduced. See same normal/close images.
3. Height: **Missing** at all three contacts. A has readable leaf/blade marks and sparse flowers, but no upright vegetation silhouettes or roots overlapping stone. See a-close views and both normal contact views.

Day actual sun direction(.145809,-.986262,.077639), energy.97376, shadow_enabled=true, opacity.62624; ambient energy.67792. Both selected meshes cast shadows. Near-overhead rays keep cast shadows short; broad fill compresses contrast. Night clear direct.18, ambient.60; night rain direct.09648, ambient.552. Shadow opacity0 at night despite enabled shadow flag. This is existing light policy, not a missing on/off switch. No global lighting retune made.

Night clear/rain retain legible dirt route, building/wall shapes and A markings, with weaker grounding. Short pan shows no newly introduced surface gaps/flicker; discrete frames do not certify all motion. Ordinary HUD screenshot retains contacts below quest box; detached review banner covers some lower actor area, so it is layout context only and not full gameplay/actor-readability acceptance. GD004/GD005 must supply ordinary actor/readability evidence appropriate to their work.

## Protection and cost baseline

Before/after A switch matched:1318 CollisionShape3D records (class, stored shape properties, global transforms, disabled),824 CollisionObject3D layer/mask pairs,306 town visual geometry records (transforms and full surface arrays), terrain/water/riser vertex hashes, semantic mask, floor faces, nav vertices/polygons and layout bytes. Six terrain batches, nine riser batches,472 levels,16 slopes,238 cliffs,8598 wet cells,4069 nodes. Comparison occurs before existing night/weather node changes.

Semantic digest `d66938e542c041d96c01831e0cc97f27483246d06cdacdd8494b6f57293f30c6`; floor digest `807753f8310ed7df4918f51fec2f13e3ad59176f3fb184fe713ec19fbd1d7b79`; navigation digest `51aa56a8ff8f4815738947e82d0ac5e6edd2b18eefe33c708e8ce4e1bd2a616f`. These inventory digests hash the helper's serialized/hex representation, not file bytes. File SHA256 values above hash raw file bytes. Runtime node paths include engine-generated names; compare owned same-run before/after, not anonymous path numbering across runs.

No added depth meshes, clumps, triangles, batches, textures, colliders or navigation roles: inventory []. Later tasks must enumerate permitted visual additions separately; protected terrain and physical geometry stay fixed. Existing no-flag startup asserted pilot-disabled. Production files/assets were not edited by GD001.

A-only paused contact view, 120-frame warmup then120-frame sample, VSync off/max_fps0, RTX4070 Laptop OpenGL3.3: draw p95217; frame cadence p952.548ms/p993.110ms; observed217 render objects,179239 primitives; aggregate texture counter38541720 bytes, buffer26356444 bytes. These are short scene observations, not FPS certification or incremental memory allocation. Different aim/HUD from historical GRASS01 explains lower draw count; no performance improvement claim. Future candidates must use same view/sample settings for <=4 extra draw comparison. Contract remains <=64 clumps,1536 new triangles,2 shared visual batches,2MiB added decoded texture including mips.

## Reproduction and inspected evidence

CWD: D:/development/game-dev-blender/returning-fair-prototype; PowerShell7. Installed console verified. Exact final command:

```powershell
./tools/run_checks.ps1 -Task GD001 -Names application_smoke -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180
```

[Results](../../evidence/GD001/20261013-061929137-1e26c96a/results.json): engine-version/parse-preflight/application_smoke/render-compare passed;17 captures,0 fixture failures; unchanged source. Schema2 save groups isolate smoke and render under builds/testing/GD001/20261013-061929137-1e26c96a/{appdata,localappdata}; render review repository user://environment-review/gd001-depth/disabled.json. Normal saves untouched. Exact slots/engine PIDs/arguments in results.

Fixture adapts existing grass_pilot helpers without changing them. It always renders A-only, accepts optional --grass-depth-mode=a-only, rejects any other depth-mode argument. Runner requires no new flag. Existing runtime --grass-pilot=a remains available. Grounding/edges/tufts explicitly recorded as future_unimplemented; those toggles must be implemented by their respective task before comparison claims.

[Capture index](../../evidence/GD001/20261013-061929137-1e26c96a/render/grass-depth-index.json), [provenance report](../../evidence/GD001/20261013-061929137-1e26c96a/render/derived/20261013-062102-262e701f/capture-report.json). Exact inspected files under that render directory:

- a-day-ortho.png, a-day-persp.png (historical-camera A comparison).
- a-contacts-ortho.png, a-contacts-persp.png; a-close-ortho.png, a-close-persp.png.
- a-pan-ortho-0.png through a-pan-ortho-2.png; a-pan-persp-0.png through a-pan-persp-2.png.
- a-night-clear-ortho.png, a-night-clear-persp.png; a-night-rain-ortho.png, a-night-rain-persp.png.
- a-hud-ortho.png.

Provenance helper command:

```powershell
& 'C:/Users/aldoc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' tools/capture_evidence.py docs/evidence/GD001/20261013-061929137-1e26c96a/render/grass-depth-index.json
```

Returned ready-for-visual-review,count17. Initial runner run [20261013-061654490-9b19070d](../../evidence/GD001/20261013-061654490-9b19070d/results.json) passed engine checks but its capture index incorrectly used reserved mode=a-only; helper rejected Unknown capture mode. Also initial corner marker was inside dirt. Retained run, corrected source field to depth_mode and pinned real corner, then fully reran. Initial `python` alias attempt failed because Windows Store alias has no interpreter; bundled Python worked. Failed attempts were not used for completion.

GD001 acceptance complete. New depth/art improvements, semantic/camera regression suites for later source changes, and ordinary movement are not GD001 outcomes. Next eligible GD002 only after separate invocation. No rollout, package, commit or push.
## GD002 implementation extension (2026-10-12)

The preceding GD001 baseline is historical and remains valid; depth artwork now exists. GD002 adds narrow independently reversible grounding, documented with final evidence in [GD002_REPORT](GD002_REPORT.md). Runtime candidate: `--grass-pilot=a --grass-depth=grounding`; A-only: `--grass-pilot=a`. Fixture now defaults to paired A/grounding captures; `--grass-depth-mode=a-only` restricts images but still measures/protects candidate. Future edges/tufts remain unimplemented. Baseline geography, A pins, lighting and camera contract unchanged. Next eligible task GD003; overall user acceptance Pending.

## GD003 implementation extension (2026-10-13)

Historical GD001/GD002 sections remain source evidence. Current cumulative runtime: --grass-pilot=a --grass-depth=edges, production low opaque groups from grass_depth_edges.gd; grounding-only and A-only remain available. Fixture defaults to matched A/grounding/edge triplets plus frozen repeat,52 actual captures. Grounding parameter/edge visibility independent; no tuft mode exists. Twelve groups/534 triangles/one mesh-material batch/zero textures, Y.014-.047712m. Exact roots, geometry audit, commands/isolation, source fingerprint, inspected pixels, locality, costs and retained repairs in [GD003_REPORT](GD003_REPORT.md). A/light/geography/protection pins unchanged. Next eligible GD004; user depth acceptance Pending.


## GD004 implementation extension (2026-10-13)

Historical GD001-GD003 records remain evidence. Current cumulative runtime: `--grass-pilot=a --grass-depth=tufts`; `edges` keeps grounding/low overlap while disabling upright blades. Nine upright groups/52 blades/156 triangles/one additional opaque batch/zero textures; rootsY.010m, actual maximumY.240337m. Total depth21 clumps/690 triangles/2 batches/+2 matched draws. Fixture defaults to17 four-way comparisons plus frozen repeat and six HUD captures after bounded real WASD approach (75 total); initial feet/time synthetic. Both cameras/day/night/rain/pans/ordinary actor-foot readability inspected, full protection/import/source gates passed. [GD004_REPORT](GD004_REPORT.md) records final source fingerprint, commands/isolation, source/pixel audits and all evidence. A/light/geography pins unchanged. Next eligible GD005: fresh independent review; user depth acceptance Pending.


## GD004 density revision (2026-10-13)

User rejected nine-clump density as too sparse. Current cumulative `--grass-pilot=a --grass-depth=tufts` now uses36 upright clumps/305 blades/915 triangles; same one upright batch, seed4004/palette/height cap, fuller .030-.050m blade width and staggered pockets12/contact. Total depth48 clumps/1449 triangles/2 batches/+2 draws/0 textures. Only tuft script changed in game/tools. Fresh75-capture run/provenance, both-camera normal/close/pan/night/rain/HUD inspections, protected inventory, locality and four WASD legs pass. See [density revision report](GD004_DENSITY_REVISION.md); initialGD004 source/evidence historical. User acceptance Pending; nextGD005 fresh independent review.


## User softness revision — 2026-10-13

GD005 reopened/repaired after user rejected dark/thick clumps and strong background contrast. [GD005_SOFTNESS_REVISION](GD005_SOFTNESS_REVISION.md) owns current appearance/evidence. Original A bytes/tile/blend/saturation/edge/value remain; original appearance uses --grass-look=original. Revised A defaults to contrast.60/filterbias.15 plus thinner/lighter clump geometry. This explicit user request supersedes fixed A appearance for candidate. Original baseline above stays historical, reproducible and unchanged. User acceptance Pending; no rollout.


## Painterly/density repair - 2026-10-13

Current candidate uses sibling grass-painterly-albedo-v2.png512px+mips and52 upright groups/548 blades plus12 low groups. Total64 groups/1452 triangles/2 batches/+2 draws/~1MiB new decoded texture. Original A bytes and --grass-look=original reference retained. Explicit user request supersedes candidate albedo-use/placement pins; scope/physics/lights/budgets remain. [GD005_PAINTERLY_DENSITY_REVISION](GD005_PAINTERLY_DENSITY_REVISION.md) owns current evidence. Prior baseline/softness specs are historical. User acceptance Pending; no rollout.
