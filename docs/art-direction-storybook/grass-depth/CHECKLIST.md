# Grass depth execution checklist

Goal and constraints: [CONTRACT](CONTRACT.md). Target: D:/development/game-dev-blender/returning-fair-prototype. Status authority: this checklist. Continuation: [CURRENT_STATE](CURRENT_STATE.md).

GD001-GD005 Done, including painterly texture and fuller local3D grass repair. User visual acceptance Pending. Original A and prior softer captures preserved; no next eligible GD task.

| ID | Status | Depends on | Observable outcome |
|---|---|---|---|
| GD001 | Done | Existing GRASS01 A verified | Locked A baseline, exact contacts, usable comparison fixture |
| GD002 | Done | GD001 | Building and wall feel grounded through local contact shading |
| GD003 | Done | GD002 | Vegetation interrupts clean ground boundaries |
| GD004 | Done | GD003 | Upright clumps add visible height and density |
| GD005 | Done | GD004 | Fresh-agent critique, cumulative comparison and cost/readability review |

Resume single In progress task first. Reassess changed blockers; otherwise select lowest Pending task with verified Done prerequisites. Exactly one task per invocation, including its verification and repairs. Stop before successor. Update handoff even when interrupted. Done requires every stated criterion and linked evidence; do not replace failure with weaker acceptance.

## GD001 — Freeze A and establish depth evidence

Inputs: contract source identities; actual current Git changes, map props and A captures; existing grass_pilot_render/environment_review/testing runner.

Work: create DEPTH_SPEC.md in this folder with exact visible facade/wall segments, adjacent dirt corner world coordinates, target crop descriptions and three baseline gaps. Record A parameters/albedo hash, fixed camera/feet/day/weather, source manifest, physical protection inventory and fresh A-only draw/texture/timing observations. Capture A-only night/rain for later matched comparisons. Audit contact/cast-shadow visibility and current light settings; record global issues without retuning them.

Create proposed game/tests/grass_depth_render.gd by adapting/reusing existing capture helpers. Add task-owned comparison toggles/manifests for A-only and future local cues; no depth art yet. Preserve original GRASS01 fixture/evidence. Only baseline and fixture controls need work at this stage; do not claim future cue modes exist.

Acceptance:
- Fresh A-only captures agree with historical A intent; any baseline drift is explained before continuing.
- Three exact contacts are visible at normal960x640 and diagnostic close view; masks/contact shapes follow actual visible geometry.
- A-only comparison can be rerun with isolated data and provenance; captures record transforms, viewport and environment.
- Existing no-flag mode remains unchanged. Baseline collider/map/terrain protections and permitted added-visual inventory are recorded.
- Fixture passes parse and actual rendering, with source.changed=false.

Existing verification: run_checks with application_smoke and existing grass_pilot_render as needed. Proposed grass_depth_render must first be created, then executed. Outputs: DEPTH_SPEC.md, runtime fixture/control changes, actual A baselines, GD001 evidence/completion record.

## GD002 — Add narrow local grounding

Inputs: verified GD001 fixture/spec and pinned A baseline. Work: local contact cues at selected building and stone wall bases, using validated visual footprint masks/shading. Keep A hue/scale/density and world light settings fixed. Added contact shading is not claimed to be physical dynamic occlusion.

Acceptance:
- Building and wall bases read as touching ground at960x640; both contacts have named before/after evidence.
- Shading is narrow and soft; no broad dark halos, black outlines, luminous borders, detached shadows or dark stripes across path.
- A outside the contact zones and outside pilot rectangle stays equivalent under matched lighting.
- Depth cue can be disabled independently; terrain semantics/collision/navigation protections pass.
- Day and A night/rain captures remain readable.

Existing verification: application_smoke, map_landscape_checks. Proposed fixture: compare A-only vs grounding, both projections and close view. Inspect actual PNGs; record unresolved visual faults and matched draw/texture cost. Fix any acceptance failures within this task.

## GD003 — Break clean boundary joins

Inputs: GD002 and fixed A. Work: bounded visual edge blending/low ground-cover overlap at chosen facade, wall and dirt corner. Keep architectural walls straight and authored physical paths intact. Upright height remains GD004 work.

Acceptance:
- Small irregular groups interrupt the three clean joins; normal-scale evidence shows each location.
- No continuous fuzzy fringe, repeated sawtooth pattern, floating carpet, gaps/z-fighting or plants painted through stone surfaces.
- Dirt route stays visually legible; door/interaction feet and collision stay intact.
- Toggle isolates edge contribution while retaining grounding; A parameters/albedo remain pinned.
- Both projections and short pan inspected; costs stay within contract.

Existing verification: application_smoke, map_landscape_checks. Proposed fixture: A-only / grounding / grounding+edges under identical conditions. Add targeted semantic/coverage checks only if new masks require them; do not write tests that merely repeat color constants.

## GD004 — Add sparse height

Inputs: GD003. Work: a few reusable simple upright tuft/weed shapes, instanced/batched around the three contacts. Starting height guide .08-.25m; GD001 camera/hero scale and visible target cues govern final sizing. Vary placement/rotation in small groups; avoid evenly spaced rows. Source geometry may be Godot-native; Blender/imagegen are optional only if their assets are needed.

Acceptance:
- Upright silhouettes visibly overlap ground/wall/path at960x640, without needing the diagnostic close view.
- Grounded roots; no floating, flicker, sorting artifacts, excessive shadow noise or oversized vegetation.
- Actor feet/silhouettes, path and interactions remain readable with ordinary HUD and both cameras.
- Cumulative and tuft-disabled images isolate contribution.
- Contract clump/triangle/batch/texture/draw ceilings met; new decoration has no collision/navigation role and is explicitly inventoried.

Existing verification: application_smoke, map_landscape_checks, map_camera_checks. Proposed fixture: matched A-only and cumulative day/night/rain views, bounded pans and resource/cost inventory. Basic import/visibility/physics protections belong here, not deferred to review.

## GD005 — Independent visual review and handoff

Inputs: actual source/assets and GD001-004 evidence. Use a fresh agent/session as reviewer. Inspect target and actual pixels before reading earlier agents' self-assessments. This is a sequential review task, not another parallel implementation branch.

Work: review each named contact at normal scale and close view; produce target / A-only / cumulative comparison plus per-cue toggles and concise critique. Cite screenshot locations for observations. Verify matched view/light conditions, A identity, costs, protected geometry/semantics and ordinary HUD readability. Reuse existing checks; rerun relevant ones only for new edits or missing/invalid evidence.

Acceptance:
- Reviewer distinguishes improvement over A from remaining concept differences; no claim of exact match or automatic acceptance.
- Final comparison includes real Godot pixels, exact provenance, both cameras, A night/rain, short pan and ordinary HUD view.
- Final source agrees with validated implementation; any repairs stay within current task scope and receive affected checks/captures.
- Deliver a recommendation: ready for user's depth review, or specific unresolved failures requiring repair. If hard criteria fail, keep GD005 In progress with exact repair action; do not mark Done merely for writing a report.
- If hard criteria pass, mark GD005 Done for delivered review package; explicitly leave overall user depth acceptance Pending. No rollout/export follows automatically.

## Completion records

Completion records below. For each verified Done task append: ID/date; result and changed files; exact commands/CWD/isolation; actual results and inspected image paths; remaining concept gaps; next eligible task. Keep failed evidence linked. User depth acceptance: Pending.

### GD001 — Done, 2026-10-12 America/Vancouver

A preserved; repeatable A-only fixture delivered with exact facade/wall/corner geometry and physical inventory. See [DEPTH_SPEC](DEPTH_SPEC.md) for source pins, all acceptance findings and inspected PNG paths. Added game/tests/grass_depth_render.gd + .uid and DEPTH_SPEC.md; updated this checklist and CURRENT_STATE.md. No existing production/GRASS01 files edited.

CWD D:/development/game-dev-blender/returning-fair-prototype, PowerShell7:
`./tools/run_checks.ps1 -Task GD001 -Names application_smoke -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180`.
[Final results](../../evidence/GD001/20261013-061929137-1e26c96a/results.json): engine-version, parse-preflight, application_smoke and actual render-compare passed;17 PNGs,0 failures. Source.changed=false/source.error=null; fingerprint986f510c256f3d39a18fd94548cf9c82cfb220107c1f9ad7cd0acdf79f2dc3a5. Per-case named slots/app-data isolated under builds/testing/GD001/20261013-061929137-1e26c96a; normal saves untouched. Provenance helper passed,count17 with bundled Python; exact command/report in spec.

Inspected target, historical A normal views/detail and all17 final source PNGs: historical-camera pair; contacts/close pair; three pan frames per projection; clear/rain night pair; HUD ortho. Selected-contact pixels match historical A exactly in both projections; lower-water shader TIME and removed historical banner explain whole-image differences.1318 colliders,824 collision layer/mask records,306 town mesh records, terrain/water/riser vertices, floor/semantic/navigation/layout inventory unchanged across A switch. No-flag startup remains pilot-disabled.

Retained initial run20261013-061654490-9b19070d: renderer passed, provenance helper rejected reserved mode=a-only; initial corner marker was inside dirt. Both repaired before final rerun. `python` Store alias was unavailable; bundled runtime used. No outstanding GD001 failed/unrun acceptance criterion. Later movement/art/cost gates remain unrun as intended.

Remaining concept gaps: weak contact grounding, hard clean boundaries, flat botanical marks; night/rain preserve readability but compress contact contrast. Wall south base is on dirt; exact corner is(-12.5,4), not initial(-12,5.5). Next eligible GD002: narrow opt-in local grounding with A/light pins held. Stop reached before GD002. User depth acceptance Pending.
### GD002 — Done, 2026-10-12 America/Vancouver

Narrow opt-in facade/wall contact shading delivered; A and lights pinned. See [GD002 report](GD002_REPORT.md) for exact contacts, commands/isolation, inspected34 actual PNGs, protection/locality evidence, source fingerprint, retained attempts and costs. Added grass_depth.gdshaderinc + .uid; extended landscape shader/material creation and grass_depth_render fixture; updated this checklist, CURRENT_STATE and spec controls.

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD002 -Names application_smoke,map_landscape_checks -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180`. [Final run](../../evidence/GD002/20261013-063816186-e3e661c9/results.json) passed engine/parse/smoke/landscape/render; source.changed=false/error=null; fingerprint106dcf5ee72d4a1a8eb91c2f3a49b3c435dff2cb3870b2f9eab559af311e2521. Provenance helper passed34 captures. Independent cue improves normal-scale facade/wall roots; night/rain readable. Enabled-cue protection passes. +0 draws,0 added texture/mesh/triangle cost. Initial pixel crop included animated river; retained and diagnosed, scoped static check passes.

No failed/unrun GD002 hard criterion. Vegetation overlap/height, full actor movement evidence and fresh independent review remain later work; user art acceptance Pending. No Godot process/cleanup owed; existing GRASS01 server15316 retained. Next eligible GD003; stopped before successor.

### GD003 — Done, 2026-10-13 America/Vancouver

Twelve separated low leafy groups interrupt facade/wall/corner joins; A/grounding/physical paths/lights preserved. See [GD003 report](GD003_REPORT.md) for controls/commands/isolation, all criteria, inspected52 actual PNGs, preservation, retained repairs and costs. Added grass_depth_edges.gd + .uid; extended terrain_preview.gd, landscape_materials.gd and grass_depth_render.gd; updated spec/checklist/handoff.

CWD repository root, PowerShell7: ./tools/run_checks.ps1 -Task GD003 -Names application_smoke,map_landscape_checks -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180. [Final run](../../evidence/GD003/20261013-065755385-5b215300/results.json) passed engine/parse/smoke/landscape/render;52 captures,0 failures; source.changed=false/error=null, fingerprintf5696a32c9edba14c86071b975f4ca76154b1acab4b0ba61012a287d82f57218. Provenance count52; both cameras/six pans/night/rain/HUD/repeat inspected. Original geometry/semantics/nav/colliders intact; scoped static locality and prior A/grounding equality pass. Cumulative+1 draw,12 clumps,534 triangles,1 mesh-material batch,0 textures.

First code-passing run retained: pale leaves rejected on pixels, vertex colors converted to linear; repair/final passed. No failed/unrun GD003 hard criterion. Low cover stays shallow; upright silhouettes Missing; broad concept/stepped-path/top-seam gaps remain. Ordinary movement/full actor-readability and independent review stay later gates. User art acceptance Pending. No Godot process/cleanup owed; existing GRASS01 server15316 retained. Next eligible GD004; stopped before successor.


### GD004 — Done, 2026-10-13 America/Vancouver

Nine sparse upright clumps add visible height at facade/wall/corner; A/grounding/edges/geography/lights preserved. [GD004 report](GD004_REPORT.md) owns exact commands, source,75 inspected captures, protection, costs, retained attempts and remaining gaps. Added grass_depth_tufts.gd+.uid; extended terrain/material/edge selectors and grass_depth_render fixture; updated spec/checklist/handoff.

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD004 -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180`. [Final results](../../evidence/GD004/20261013-074633078-e7d25a6e/results.json) pass engine/parse/smoke/landscape/camera/render;75 actual960x640 captures,0 failures. Source.changed=false/error=null;1451 files,fingerprintc170b8b6b91da80db6cb0a6d88cc895fedebba360e0312d940899f506124f339. Separate `./tools/run_checks.ps1 -Task GD004 -Import -Names application_smoke -TimeoutSeconds 180` [passed](../../evidence/GD004/20261013-075054527-2f588b26/results.json), identical fingerprint; known SDK10.0.9 import-only diagnostic allowed by runner. Isolated named slots/APPDATA under builds/testing/GD004/run; normal saves untouched. Provenance count75 passed.

Both projections, all six pan samples, night/rain, frozen repeat and six ordinary HUD views after four real WASD legs inspected; initial feet/time synthetic, no teleport during movement. Grounded roots, small upright silhouettes and clear routes/actor feet; no observed sorting/flicker/shadow noise.1318 colliders/824 layer-mask records/306 town geometry records and terrain/semantics/floor/nav/layout unchanged; prior A/grounding/edge contact pixels equal GD003. Cumulative21 clumps/690 triangles/2 batches/+2 draws/0 textures. Initial71-capture run passed, retained; final adds contact-by-contact HUD evidence. River-only broad pixel diagnostic retained and scoped static locality passes.

No failed/unrun GD004 hard criterion. Sparse dark sprigs remain below target botanical richness; bright stepped paths/broad lighting/top seam remain. Independent critique and user art acceptance Pending. No Godot process or cleanup owed; existing GRASS01 server15316 retained. Next eligible GD005 requires fresh review session; stopped before successor.


GD004 reopened 2026-10-13: user finds nine clumps extremely sparse with little visible difference. Authorized density repair at the same contacts; A and physical geography stay pinned. Verify revised normal-scale pixels and costs before restoring Done.


### GD004 density revision — Done, 2026-10-13 America/Vancouver

User rejected original9-clump density as too sparse. ReopenedGD004, increased placements9->36 and blades52->305 with fuller width at the same three contacts. Only grass_depth_tufts.gd changed in game/tools; docs updated. A/grounding/low edges/light/physical geography pinned. [Revision report](GD004_DENSITY_REVISION.md) supersedes original visual recommendation; [normal before/after](../../evidence/GD004/20261013-080618921-cc4ecc48/render/density-review/before-after-contacts.png).

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD004 -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180`. [Results](../../evidence/GD004/20261013-080618921-cc4ecc48/results.json) all passed;75 captures,0 failures; source.changed=false/error=null,fingerprintf214c7303d37e2cc41ba1ed0a421d5d071adcbd5f16d25ba82843fbfc973d41f. Provenance75 passed. All24 current candidate captures inspected at1:1: both cameras/day/close/six pans/night/rain/repeat/six HUD checkpoints after four actual WASD legs; initial feet/day synthetic. Static locality/protection and prior A/grounding/edge pixel equivalence pass. Cumulative48 clumps/1449 triangles/2 batches/+2 draws/0 textures. No owned process/cleanup owed.

GD004 implementation Done; user art acceptance Pending. Remaining stylized dark sprigs, mostly flat painted lawn beyond contacts, night contrast and broad concept/path/top-seam gaps. GD005 remains Pending for fresh independent review; not started.

### GD005 — Done, 2026-10-13 America/Vancouver

Independent review of current36-tuft density revision delivered (36 upright +12 low groups); user art acceptance Pending. [GD005 report](GD005_REPORT.md) owns contact critique, source/commands/isolation, inspected40 fresh PNGs, costs, reviewer limitations, package QA and live server. [Interactive comparison](http://127.0.0.1:59859/) provides untouched target/A/cumulative/per-cue stages, both cameras, normal+close/night/rain/short pans/ordinary HUD arrivals. Local overlap and height Clear at all three contacts; dark angular sprigs, bright stepped paths, flat surrounding A and weaker night contrast remain. No exact-match/rollout approval.

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD005 -RenderOnly -RenderScript grass_depth_render -RenderPhases compare -TimeoutSeconds 180`. [Fresh results](../../evidence/GD005/20261013-182054688-1a4ef1e6/results.json) pass engine/parse/actual render;75 captures,0 failures; source.changed=false/error=null;1451 files,fingerprintf214c7303d37e2cc41ba1ed0a421d5d071adcbd5f16d25ba82843fbfc973d41f. Exact source equals verified density run; prior smoke/landscape/camera checks reused. Provenancecount75 passed; post-run rehash zero mismatches. Isolated render slot/APPDATA/LOCALAPPDATA under builds/testing/GD005/20261013-182054688-1a4ef1e6; normal saves untouched. Unchanged fixture retains internal GD004 labels, explicitly documented.

[Review QA](../../evidence/GD005/20261013-182054688-1a4ef1e6/review-qa.json) confirms matched camera/feet/environment/light, protected same-run/prior inventories, A identity, scoped locality, frozen repeat and four real WASD legs after synthetic setup. All24 cumulative +12 A/grounding/edge contacts/close +4 A night/rain PNGs inspected individually; target original/normal context too. Both cameras/six pans/six HUD arrivals inspected. Cumulative48 clumps/1449 triangles/2 batches/+2 draws/0 textures within ceilings. Browser70 states pass, exact960x640 display; HUD guards/pan visibility/A switch and final clean console verified.

Durable files: added GD005_REPORT.md, updated CHECKLIST/CURRENT_STATE; no game/tools edits. No failed Godot run/unrun hard criterion. User-facing local review serverPID68088 intentionally retained at http://127.0.0.1:59859/, root docs/evidence/GD005/20261013-182054688-1a4ef1e6/review-package. Existing GRASS01 serverPID15316 preserved. No Godot game/editor or owned runtime cleanup owed. GD001-GD005 Done; no successor. User acceptance Pending; stopped without rollout/package/commit/push.
### GD005 softness repair — Done, 2026-10-13 America/Vancouver

User rejected dark/thick clumps and high-contrast ground. [Softness revision](GD005_SOFTNESS_REVISION.md) supersedes prior appearance recommendation: roughly half-width blades/leaves, lighter tempered greens, lower-contrast A sampling with detail retained. Same36 upright/12 low groups and unchanged geometry/lights/paths. Original albedo and A parameters retained; `--grass-look=original` restores prior look. User request overrides fixed appearance rule; no rollout.

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD005 -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript grass_depth_render -RenderPhases compare,original -TimeoutSeconds 180`. [Final results](../../evidence/GD005/20261013-183935192-6201862e/results.json) pass engine/parse/smoke/landscape/camera/two actual render phases;150 captures,0 failures; source.changed=false/error=null,1451 files,fingerprintb5334e875d6c525bc332478c28f917a1b485e203132c66ac42da189649d5321e. Combined provenance150 passed; post-run rehash clean. Saves/APPDATA isolated, normal saves untouched.

[QA](../../evidence/GD005/20261013-183935192-6201862e/softness-qa.json): original contact pixels equal historical4 stages/both cameras; revised/original frozen conditions matched; protected inventories equal; repeat stable; four WASD legs per phase pass.36 final source PNGs individually inspected, covering all24 revised cumulative/both cameras/six pans/night/rain/HUD,8 original comparison frames,4 grass-only/low-leaf close. Resource48 clumps/1449 triangles/2 batches/+2 draws/0 new textures. Viewer140 states/control guards/console pass; exact960x640 images. Initial too-bright palette run retained and repaired before final verification.

Changed5 game/tools files plus contract/spec/checklist/handoff/report. [Updated comparison](http://127.0.0.1:59859/?revision=softness) served by intentionally retainedPID42716, current run/review-package; owned historicalPID68088 replaced, old evidence retained. GRASS01PID15316 preserved. No Godot game/editor/owned runtime cleanup owed. User visual acceptance Pending; simpler angular plants, stepped path edges/wall-top seam remain. No successor/rollout/package/commit/push.
### GD005 painterly/density revision — Done, 2026-10-13 America/Vancouver

User preferred softness pass but requested less defined/more painted ground and denser3D grass. [Revision report](GD005_PAINTERLY_DENSITY_REVISION.md) owns current asset/prompt/source/verification and remaining gaps. Added sibling generated painterly texture512px+mips; original A bytes preserved. Upright36->52 groups,305->548 blades; efficient2-triangle blades/4-triangle low leaves keep total64 groups/1452 triangles/2 batches/+2 draws plus~1MiB new texture within all ceilings. User acceptance Pending, no rollout.

CWD repository root, PowerShell7: `./tools/run_checks.ps1 -Task GD005 -Names application_smoke,map_landscape_checks,map_camera_checks -RenderScript grass_depth_render -RenderPhases compare,original -TimeoutSeconds 180`. [Final results](../../evidence/GD005/20261013-211710294-ea6c46da/results.json) pass engine/parse/smoke/landscape/camera/two actual render phases;150 fresh captures,0 failures; source.changed=false/error=null,1453 files,fingerprint06971f8a9e852af8bac6d10d9c2a365b0d58b3f9a735c01c043599beb7bdd79b. Current asset/mips match earlier stable import. Combined provenance150 passes, rehash clean. Slots/APPDATA isolated; normal saves untouched.

[QA](../../evidence/GD005/20261013-211710294-ea6c46da/painterly-qa.json): original appearance contact equality, matched frozen current/original/previous-soft conditions, protected inventory, repeat, geometry/texture/draw ceilings and four WASD legs per phase pass.36 final source PNGs individually inspected; both cameras/six pans/night/rain/HUD covered. Built-in imagegen source/512runtime/2x2 proof/concept inspected. Renderer pixels retained unaltered. Initial import metadata invalidation, missing mipmaps and reversed low-leaf winding diagnosed/repaired with all attempts retained. No final unresolved hard criterion.

[Viewer](http://127.0.0.1:59859/?revision=painterly) includes150 fresh frames+75 explicitly archived previous-soft frames.210 states decode/display960x640, controls/console pass. Current user-facing serverPID72244 retained, root current run/review-package; owned priorPID42716 replaced, all old packages retained. GRASS01PID15316 preserved. No Godot game/editor/owned runtime cleanup owed. Changed4 existing game/tools files+2 runtime assets, generated source/recipe and workflow docs. User visual acceptance Pending; no successor/rollout/package/commit/push.